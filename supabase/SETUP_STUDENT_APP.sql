-- =====================================================================
-- ÖĞRENCİ UYGULAMASI KURULUMU: tek dosya, tek seferde çalıştır.
-- İçerik: (1) doğru şıkkı gizle, (2) çözüm adımları + süre doldu desteği,
-- (3) örnek sorular. Sırayla 20260920000300, 000400 ve seed dosyalarıdır.
-- =====================================================================

-- =====================================================================
-- Doğru şıkkı istemciden gizle
-- Öğrenci uygulaması soruları doğrudan okur; dogru_sik sütununu okuyamamalı.
-- Cevap kontrolü yalnızca public.submit_answer() (SECURITY DEFINER) ile yapılır.
-- =====================================================================

set client_encoding = 'UTF8';

-- Tablo düzeyindeki SELECT yetkisini kaldır, dogru_sik dışındaki sütunlara ver
revoke select on public.questions from authenticated;

grant select (
  id, okul, ders, konu, alt_konu, zorluk, soru_metni, siklar,
  onay_durumu, created_at, updated_at
) on public.questions to authenticated;

-- Not: artık istemcide "select *" yerine sütun listesi kullanılmalı.
-- service_role ve SECURITY DEFINER fonksiyonlar bu kısıttan etkilenmez.

-- =====================================================================
-- Adım adım çözüm metni + "süre doldu" (boş cevap) desteği
--   * questions.cozum_adimlari : çözüm adımları (JSON metin dizisi)
--     Bu sütun istemciye AÇILMAZ (20260920000300'deki sütun listesinde yok);
--     çözüm yalnızca cevap verildikten sonra submit_answer() sonucunda döner.
--   * submit_answer(): p_secilen_sik NULL ise süre dolmuş demektir → yanlış sayılır.
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.questions
  add column if not exists cozum_adimlari jsonb not null default '[]'::jsonb;

alter table public.questions
  drop constraint if exists questions_cozum_adimlari_is_array;
alter table public.questions
  add constraint questions_cozum_adimlari_is_array
  check (jsonb_typeof(cozum_adimlari) = 'array');

-- Süresi dolan soruda seçilmiş şık yoktur
alter table public.user_answers
  alter column secilen_sik drop not null;

create or replace function public.submit_answer(
  p_question_id  uuid,
  p_secilen_sik  text,
  p_sure_ms      integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := (select auth.uid());
  v_q      record;
  v_a      public.user_answers%rowtype;
  v_exists boolean;
  v_dogru  boolean;
  v_due    boolean;
  v_kalite integer;
  v_ef     numeric;
  v_rep    integer;
  v_aralik integer;
  v_next   timestamptz;
  v_award  jsonb;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler soru cevaplayabilir' using errcode = '42501';
  end if;

  select id, zorluk, dogru_sik, siklar, cozum_adimlari
    into v_q
    from public.questions
   where id = p_question_id and onay_durumu = 'onaylandi';
  if not found then
    raise exception 'Soru bulunamadı' using errcode = 'P0002';
  end if;

  -- NULL = süre doldu (yanlış sayılır); doluysa geçerli bir şık olmalı
  if p_secilen_sik is not null and not (v_q.siklar ? p_secilen_sik) then
    raise exception 'Geçersiz şık' using errcode = '22023';
  end if;

  v_dogru := (p_secilen_sik is not null and p_secilen_sik = v_q.dogru_sik);

  select * into v_a
    from public.user_answers
   where student_id = v_uid and question_id = p_question_id
   for update;
  v_exists := found;

  if v_exists then
    v_ef := v_a.ease_factor;
    v_rep := v_a.tekrar_sayisi;
    v_aralik := v_a.aralik_gun;
    v_next := v_a.sonraki_tekrar_tarihi;
    v_due := v_a.sonraki_tekrar_tarihi <= now();
  else
    v_ef := 2.5;
    v_rep := 0;
    v_aralik := 0;
    v_next := now();
    v_due := true;
  end if;

  -- SM-2: zamanı gelmeden doğru cevap programı değiştirmez; yanlış her zaman sıfırlar
  if v_due or not v_dogru then
    v_kalite := case when v_dogru then 4 else 1 end;

    if v_kalite < 3 then
      v_rep := 0;
      v_aralik := 1;
    else
      v_rep := v_rep + 1;
      v_aralik := case v_rep
                    when 1 then 1
                    when 2 then 6
                    else round(v_aralik * v_ef)::integer
                  end;
    end if;

    v_ef := greatest(
      1.3,
      v_ef + 0.1 - (5 - v_kalite) * (0.08 + (5 - v_kalite) * 0.02)
    );
    v_next := now() + make_interval(days => v_aralik);
  end if;

  insert into public.user_answers as ua (
    student_id, question_id, secilen_sik, dogru_mu, son_sure_ms, son_cevap_tarihi,
    deneme_sayisi, dogru_sayisi, ease_factor, tekrar_sayisi, aralik_gun, sonraki_tekrar_tarihi
  )
  values (
    v_uid, p_question_id, p_secilen_sik, v_dogru, p_sure_ms, now(),
    1, case when v_dogru then 1 else 0 end, v_ef, v_rep, v_aralik, v_next
  )
  on conflict (student_id, question_id) do update
    set secilen_sik           = excluded.secilen_sik,
        dogru_mu              = excluded.dogru_mu,
        son_sure_ms           = excluded.son_sure_ms,
        son_cevap_tarihi      = excluded.son_cevap_tarihi,
        deneme_sayisi         = ua.deneme_sayisi + 1,
        dogru_sayisi          = ua.dogru_sayisi + case when excluded.dogru_mu then 1 else 0 end,
        ease_factor           = excluded.ease_factor,
        tekrar_sayisi         = excluded.tekrar_sayisi,
        aralik_gun            = excluded.aralik_gun,
        sonraki_tekrar_tarihi = excluded.sonraki_tekrar_tarihi;

  if v_dogru then
    -- XP yalnızca yeni veya tekrar zamanı gelmiş soruda verilir
    v_award := public.award_xp_and_streak(v_uid, v_q.zorluk, v_due);
  else
    select jsonb_build_object(
             'kazanilan_xp', 0,
             'xp', s.xp,
             'level', s.level,
             'streak_count', s.streak_count,
             'last_active_date', s.last_active_date
           )
      into v_award
      from public.student_stats s
     where s.student_id = v_uid;
  end if;

  return coalesce(v_award, '{}'::jsonb) || jsonb_build_object(
    'dogru_mu',              v_dogru,
    'dogru_sik',             v_q.dogru_sik,
    'cozum_adimlari',        v_q.cozum_adimlari,
    'sure_doldu',            p_secilen_sik is null,
    'sonraki_tekrar_tarihi', v_next
  );
end;
$$;

revoke execute on function public.submit_answer(uuid, text, integer) from public, anon;
grant  execute on function public.submit_answer(uuid, text, integer) to authenticated;

-- =====================================================================
-- Örnek sorular (deneme amaçlı), adım adım çözümleriyle.
-- Tablo boş değilse hiçbir şey eklemez (tekrar çalıştırmak güvenlidir).
-- 20260920000400_solution_steps_and_timeout.sql'den SONRA çalıştırılmalı.
-- =====================================================================

set client_encoding = 'UTF8';

do $seed$
begin
  if exists (select 1 from public.questions limit 1) then
    raise notice 'questions tablosu dolu, örnek sorular eklenmedi.';
    return;
  end if;

  insert into public.questions
    (okul, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik, onay_durumu, cozum_adimlari)
  values
  -- Matematik
  ('ortaokul', 'Matematik', 'Kesirler', 'Toplama', 1,
   '1/2 + 1/4 işleminin sonucu kaçtır?',
   '{"A":"1/6","B":"2/6","C":"3/4","D":"1"}', 'C', 'onaylandi',
   '["Paydaları eşitle: 1/2 = 2/4.","Payları topla: 2/4 + 1/4 = 3/4.","Sonuç 3/4 olur, doğru şık C."]'),
  ('ortaokul', 'Matematik', 'Kesirler', 'Çıkarma', 2,
   '5/6 − 1/3 işleminin sonucu kaçtır?',
   '{"A":"1/2","B":"4/3","C":"2/3","D":"1/3"}', 'A', 'onaylandi',
   '["Paydaları eşitle: 1/3 = 2/6.","Payları çıkar: 5/6 − 2/6 = 3/6.","3/6 sadeleşince 1/2 olur, doğru şık A."]'),
  ('ortaokul', 'Matematik', 'Yüzdeler', null, 2,
   '200 sayısının %15''i kaçtır?',
   '{"A":"15","B":"20","C":"30","D":"35"}', 'C', 'onaylandi',
   '["%15, 15/100 demektir.","200 × 15/100 = 30.","Doğru şık C."]'),
  ('ortaokul', 'Matematik', 'Denklemler', 'Birinci derece', 3,
   '3x − 7 = 11 denkleminde x kaçtır?',
   '{"A":"4","B":"5","C":"6","D":"18"}', 'C', 'onaylandi',
   '["Her iki tarafa 7 ekle: 3x = 18.","Her iki tarafı 3''e böl: x = 6.","Doğru şık C."]'),

  -- Türkçe
  ('ortaokul', 'Türkçe', 'Sözcükte Anlam', 'Eş anlamlı sözcükler', 1,
   '"Güzel" sözcüğünün eş anlamlısı aşağıdakilerden hangisidir?',
   '{"A":"Çirkin","B":"Hoş","C":"Büyük","D":"Hızlı"}', 'B', 'onaylandi',
   '["Eş anlamlı sözcükler aynı anlama gelen sözcüklerdir.","''Güzel'' ile aynı anlama gelen sözcük ''hoş''tur.","''Çirkin'' zıt anlamlıdır. Doğru şık B."]'),
  ('ortaokul', 'Türkçe', 'Yazım Kuralları', 'Büyük harf', 1,
   'Aşağıdaki cümlelerin hangisinde büyük harf kullanımı yanlıştır?',
   '{"A":"Yarın Ankara''ya gideceğiz.","B":"Ali okula erken geldi.","C":"annem bana kitap aldı.","D":"Dicle Nehri çok uzundur."}', 'C', 'onaylandi',
   '["Cümleler büyük harfle başlar; özel adlar da büyük harfle yazılır.","C şıkkı ''annem'' ile başlıyor, oysa ''Annem'' olmalıydı.","Doğru şık C."]'),
  ('ortaokul', 'Türkçe', 'Cümlede Anlam', 'Neden-sonuç', 2,
   '"Yağmur yağdığı için maç ertelendi." cümlesinde sonuç hangisidir?',
   '{"A":"Yağmurun yağması","B":"Maçın ertelenmesi","C":"Havanın bozulması","D":"Seyircilerin gitmesi"}', 'B', 'onaylandi',
   '["Neden, bir olayın sebebidir: yağmurun yağması.","Sonuç, o sebebin doğurduğu olaydır: maçın ertelenmesi.","Doğru şık B."]'),
  ('ortaokul', 'Türkçe', 'Noktalama', 'Virgül', 3,
   'Aşağıdakilerin hangisinde virgül yanlış kullanılmıştır?',
   '{"A":"Elma, armut, muz aldım.","B":"Ali, gel buraya.","C":"Dün, akşam eve geldim.","D":"Kitabı, masanın üstüne bıraktım."}', 'C', 'onaylandi',
   '["Virgül; sıralı sözcükleri ve seslenmeleri ayırmak için kullanılır.","C şıkkında ''dün'' ile ''akşam'' arasında böyle bir gerek yoktur.","Doğru şık C."]'),

  -- Fen Bilimleri
  ('ortaokul', 'Fen Bilimleri', 'Güneş Sistemi', null, 1,
   'Güneş Sistemi''nde Güneş''e en yakın gezegen hangisidir?',
   '{"A":"Venüs","B":"Dünya","C":"Merkür","D":"Mars"}', 'C', 'onaylandi',
   '["Güneş''e yakınlık sırası: Merkür, Venüs, Dünya, Mars.","İlk sırada Merkür bulunur.","Doğru şık C."]'),
  ('ortaokul', 'Fen Bilimleri', 'Madde ve Değişim', 'Hal değişimi', 2,
   'Suyun gaz hâlinden sıvı hâle geçmesine ne denir?',
   '{"A":"Buharlaşma","B":"Erime","C":"Yoğuşma","D":"Donma"}', 'C', 'onaylandi',
   '["Sıvıdan gaza geçiş buharlaşma, gazdan sıvıya geçiş yoğuşmadır.","Soru gazdan sıvıya geçişi soruyor.","Doğru şık C."]'),
  ('ortaokul', 'Fen Bilimleri', 'Kuvvet ve Hareket', 'Sürat', 2,
   '120 km yolu 2 saatte giden aracın ortalama sürati kaç km/sa''tir?',
   '{"A":"40","B":"60","C":"80","D":"240"}', 'B', 'onaylandi',
   '["Sürat = yol ÷ zaman.","120 km ÷ 2 saat = 60 km/sa.","Doğru şık B."]'),
  ('ortaokul', 'Fen Bilimleri', 'Hücre', 'Organeller', 3,
   'Hücrede enerji üretiminden sorumlu organel hangisidir?',
   '{"A":"Ribozom","B":"Mitokondri","C":"Golgi cisimciği","D":"Koful"}', 'B', 'onaylandi',
   '["Besinlerden enerji üretimi mitokondride gerçekleşir.","Bu yüzden mitokondriye ''hücrenin enerji santrali'' denir.","Doğru şık B."]');
end
$seed$;

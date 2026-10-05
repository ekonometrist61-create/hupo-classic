-- =====================================================================
--  Karakter Koleksiyonu — Brawl Stars tarzı 40 karakter (8 sınıf × 5)
--  Rozet sistemiyle (20260920000500_badges.sql) aynı kalıbı izler.
--  Tarih: 2026-09-28
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) character_definitions — 40 karakterin tanım kataloğu
-- ---------------------------------------------------------------------
create table if not exists public.character_definitions (
  kod              text primary key,
  ad               text not null,
  aciklama         text not null,
  ikon             text not null,   -- assets/characters/<kod>.png
  sinif            text not null,   -- ozgur_ruhlar | firtina | kasifler | bozkir |
                                    --   zihin_ustalari | muhafizlar | ustalar | efsaneler
  sinif_sira       integer not null check (sinif_sira between 1 and 8),
  karakter_sira    integer not null check (karakter_sira between 1 and 5),
  kosul_turu       text not null,   -- baslangic | xp | streak | soru_sayisi | seviye | ders_basari
  kosul_deger      integer not null default 0,
  constraint character_definitions_sinif_check check (sinif in (
    'ozgur_ruhlar','firtina','kasifler','bozkir',
    'zihin_ustalari','muhafizlar','ustalar','efsaneler'
  )),
  constraint character_definitions_kosul_check check (kosul_turu in (
    'baslangic','xp','streak','soru_sayisi','seviye','ders_basari'
  )),
  constraint character_definitions_sira_unique unique (sinif, karakter_sira)
);
comment on table public.character_definitions is
  'Koleksiyondaki 40 karakter tanımı. kosul_deger: xp için toplam XP, streak için gün sayısı, soru_sayisi için doğru cevap sayısı, seviye için tier (1-5), ders_basari için ustalaşılan ders sayısı.';

-- ---------------------------------------------------------------------
-- 2) user_characters — öğrencinin kazandığı karakterler
-- ---------------------------------------------------------------------
create table if not exists public.user_characters (
  student_id   uuid not null references public.profiles(id) on delete cascade,
  karakter_kod text not null references public.character_definitions(kod) on delete cascade,
  kazanildi_at timestamptz not null default now(),
  constraint user_characters_pkey primary key (student_id, karakter_kod)
);
comment on table public.user_characters is
  'Öğrencinin kazandığı karakterler. Sunucu tetikçisi tarafından eklenir; istemci doğrudan INSERT yapamaz.';

-- ---------------------------------------------------------------------
-- 3) RLS — doğrudan erişim kapalı, yalnızca RPC üzerinden
-- ---------------------------------------------------------------------
alter table public.character_definitions enable row level security;
alter table public.user_characters       enable row level security;

-- Karakter tanımları herkes okuyabilir (kilitli kartlar gösterilmek zorunda)
create policy "character_definitions_herkese_acik"
  on public.character_definitions for select
  using (true);

-- Öğrenci yalnızca kendi kazanımlarını okur
create policy "user_characters_kendi"
  on public.user_characters for select
  using (auth.uid() = student_id);

-- ---------------------------------------------------------------------
-- 4) Indexler
-- ---------------------------------------------------------------------
create index if not exists character_definitions_sinif_idx
  on public.character_definitions (sinif, sinif_sira, karakter_sira);

create index if not exists user_characters_student_idx
  on public.user_characters (student_id);

-- ---------------------------------------------------------------------
-- 5) Karakter değerlendirme fonksiyonu
--    Badge evaluate_badges() ile aynı mantık: yeni kazanımları bulup ekler.
-- ---------------------------------------------------------------------
create or replace function public.evaluate_characters(p_student_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_xp          integer;
  v_streak      integer;
  v_soru_sayisi integer;
  v_seviye      integer;
  v_ders_basari integer;
  r             record;
begin
  -- Öğrenci istatistiklerini çek (student_stats: badge sistemiyle aynı kaynak)
  select
    coalesce(xp, 0),
    coalesce(streak_count, 0),
    coalesce(level, 1)
  into v_xp, v_streak, v_seviye
  from public.student_stats
  where student_id = p_student_id;

  v_xp     := coalesce(v_xp, 0);
  v_streak := coalesce(v_streak, 0);
  v_seviye := coalesce(v_seviye, 1);

  -- Toplam doğru cevap sayısı
  select coalesce(sum(dogru_sayisi), 0)::integer
  into v_soru_sayisi
  from public.user_answers
  where student_id = p_student_id;

  -- Ustalaşılan ders sayısı: accuracy ≥ 80 % ve en az 20 soru
  select count(*)::integer
  into v_ders_basari
  from (
    select q.ders
    from public.user_answers ua
    join public.questions q on q.id = ua.question_id
    where ua.student_id = p_student_id
    group by q.ders
    having sum(ua.deneme_sayisi) >= 20
       and (sum(ua.dogru_sayisi)::float / sum(ua.deneme_sayisi)) >= 0.8
  ) t;

  -- Kazanılabilecek her karakter için kontrol et
  for r in
    select cd.kod, cd.kosul_turu, cd.kosul_deger
    from public.character_definitions cd
    where not exists (
      select 1 from public.user_characters uc
      where uc.student_id = p_student_id and uc.karakter_kod = cd.kod
    )
  loop
    if (r.kosul_turu = 'baslangic') or
       (r.kosul_turu = 'xp'          and v_xp          >= r.kosul_deger) or
       (r.kosul_turu = 'streak'       and v_streak      >= r.kosul_deger) or
       (r.kosul_turu = 'soru_sayisi'  and v_soru_sayisi >= r.kosul_deger) or
       (r.kosul_turu = 'seviye'       and v_seviye      >= r.kosul_deger) or
       (r.kosul_turu = 'ders_basari'  and v_ders_basari >= r.kosul_deger)
    then
      insert into public.user_characters (student_id, karakter_kod)
      values (p_student_id, r.kod)
      on conflict do nothing;
    end if;
  end loop;
end;
$$;

revoke execute on function public.evaluate_characters(uuid) from public, anon;
grant  execute on function public.evaluate_characters(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 6) Tetikçi: istatistikler değiştiğinde karakterleri değerlendir
--    (badge sistemiyle aynı iki kaynak: student_stats ve user_answers)
-- ---------------------------------------------------------------------
create or replace function public.characters_after_change()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.evaluate_characters(new.student_id);
  return new;
end;
$$;

revoke execute on function public.characters_after_change() from public, anon;
grant  execute on function public.characters_after_change() to authenticated;

-- XP / seviye / seri değişince
drop trigger if exists trg_characters_after_profile on public.profiles;
drop trigger if exists trg_characters_after_stats on public.student_stats;
create trigger trg_characters_after_stats
  after update of xp, level, streak_count
  on public.student_stats
  for each row
  execute function public.characters_after_change();

-- Cevap kaydedilince (soru sayısı, ders başarısı)
drop trigger if exists trg_characters_after_answer on public.user_answers;
create trigger trg_characters_after_answer
  after insert or update
  on public.user_answers
  for each row
  execute function public.characters_after_change();

-- ---------------------------------------------------------------------
-- 7) get_my_characters() RPC — istemci bu RPC'yi çağırır
-- ---------------------------------------------------------------------
create or replace function public.get_my_characters()
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı';
  end if;

  return (
    select jsonb_agg(
      jsonb_build_object(
        'kod',          cd.kod,
        'ad',           cd.ad,
        'aciklama',     cd.aciklama,
        'ikon',         cd.ikon,
        'sinif',        cd.sinif,
        'sinif_sira',   cd.sinif_sira,
        'karakter_sira',cd.karakter_sira,
        'kosul_turu',   cd.kosul_turu,
        'kosul_deger',  cd.kosul_deger,
        'kazanildi',    (uc.karakter_kod is not null),
        'kazanildi_at', uc.kazanildi_at
      ) order by cd.sinif_sira, cd.karakter_sira
    )
    from public.character_definitions cd
    left join public.user_characters uc
      on uc.karakter_kod = cd.kod and uc.student_id = v_uid
  );
end;
$$;

revoke execute on function public.get_my_characters() from public, anon;
grant  execute on function public.get_my_characters() to authenticated;

-- ---------------------------------------------------------------------
-- 8) Tohum verisi — 40 karakter (8 sınıf × 5)
-- ---------------------------------------------------------------------
insert into public.character_definitions
  (kod, ad, aciklama, ikon, sinif, sinif_sira, karakter_sira, kosul_turu, kosul_deger)
values
  -- 🦅 ÖZGÜR RUHLAR (sınıf 1) — XP yolu
  ('ozgur_ruh',      'Özgür Ruh',      'Her şeyin başlangıcı. Harika bir yolculuk seni bekliyor!',
   'ozgur_ruh.png',       'ozgur_ruhlar', 1, 1, 'baslangic', 0),
  ('kivilcim',       'Kıvılcım',        'İlk adımını attın, içindeki ışık parlamaya başladı.',
   'kivilcim.png',        'ozgur_ruhlar', 1, 2, 'xp',        500),
  ('ateskanat',      'Ateşkanat',       'Alev alev öğreniyorsun. Hiçbir şey seni durduramaz!',
   'ateskanat.png',       'ozgur_ruhlar', 1, 3, 'xp',        1500),
  ('gece_kartali',   'Gece Kartalı',    'Karanlıkta bile yolunu bulan, güçlü ve özgür bir ruh.',
   'gece_kartali.png',    'ozgur_ruhlar', 1, 4, 'xp',        3500),
  ('oba_muhafizi',   'Oba Muhafızı',    'Topluluğunu koruyan efsanevi savaşçı. Herkese ilham veriyorsun.',
   'oba_muhafizi.png',    'ozgur_ruhlar', 1, 5, 'xp',        7500),

  -- 🌪️ FIRTINA (sınıf 2) — Seri yolu
  ('ruzgar_ciragi',     'Rüzgâr Çırağı',    'Rüzgâr gibi hızlısın. Her gün biraz daha güçleniyorsun.',
   'ruzgar_ciragi.png',     'firtina', 2, 1, 'streak', 3),
  ('ruzgar_kosucusu',   'Rüzgâr Koşucusu',  'Koşmayı bırakma! Ritmin harika bir güç oluşturuyor.',
   'ruzgar_kosucusu.png',   'firtina', 2, 2, 'streak', 7),
  ('simsek',            'Şimşek',            'Düşüncen şimşek gibi çakıyor, cevapların anında geliyor!',
   'simsek.png',            'firtina', 2, 3, 'streak', 14),
  ('firtina_binicisi',  'Fırtına Binicisi',  'Fırtınayı ehlileştirdin. Engellerden zevk alıyorsun.',
   'firtina_binicisi.png',  'firtina', 2, 4, 'streak', 21),
  ('firtina_ustasi',    'Fırtına Ustası',    'Fırtınayı yaratan sensin artık. Eşin benzerin yok!',
   'firtina_ustasi.png',    'firtina', 2, 5, 'streak', 30),

  -- 🏹 KAŞİFLER (sınıf 3) — Toplam doğru cevap yolu (az sayı)
  ('iz_surucu',    'İz Sürücü',   'Henüz başlıyorsun ama izlerin görünüyor. Devam et!',
   'iz_surucu.png',    'kasifler', 3, 1, 'soru_sayisi', 10),
  ('yol_bulucu',   'Yol Bulucu',  'Kendi yolunu çiziyorsun. Haritana güven!',
   'yol_bulucu.png',   'kasifler', 3, 2, 'soru_sayisi', 50),
  ('sir_avcisi',   'Sır Avcısı',  'Gizli bilgileri keşfediyorsun. Her soru yeni bir kapı açıyor.',
   'sir_avcisi.png',   'kasifler', 3, 3, 'soru_sayisi', 150),
  ('buyuk_kasif',  'Büyük Kaşif', 'Maceralarınla efsaneleşiyorsun. Dünya seni biliyor!',
   'buyuk_kasif.png',  'kasifler', 3, 4, 'soru_sayisi', 500),
  ('dunya_kasifi', 'Dünya Kaşifi','Bütün sınırları aştın. Sen artık efsanesin!',
   'dunya_kasifi.png', 'kasifler', 3, 5, 'soru_sayisi', 1000),

  -- 🐺 BOZKIR (sınıf 4) — Toplam doğru cevap yolu (büyük sayı)
  ('bozkir_yoldasi',  'Bozkır Yoldaşı',  'Bozkırda yalnız değilsin. Bilgi senin yoldaşın.',
   'bozkir_yoldasi.png',  'bozkir', 4, 1, 'soru_sayisi', 25),
  ('bozkir_izci',     'Bozkır İzci',     'Çevreye dikkatli bakıyorsun. Hiçbir şey seni atlatamaz.',
   'bozkir_izci.png',     'bozkir', 4, 2, 'soru_sayisi', 100),
  ('bozkir_kurdu',    'Bozkır Kurdu',    'Güçlü, hızlı ve akıllı. Bozkırın efendisi sensin.',
   'bozkir_kurdu.png',    'bozkir', 4, 3, 'soru_sayisi', 250),
  ('bozkir_kartali',  'Bozkır Kartalı',  'Yüksekten bakıyorsun ve her şeyi görüyorsun.',
   'bozkir_kartali.png',  'bozkir', 4, 4, 'soru_sayisi', 750),
  ('bozkir_reisi',    'Bozkır Reisi',    'Herkese önderlik ediyorsun. Bozkırın kağanısın!',
   'bozkir_reisi.png',    'bozkir', 4, 5, 'soru_sayisi', 2000),

  -- 🧠 ZİHİN USTALARI (sınıf 5) — Avatar tier yolu
  ('fikir_kivilcimi',  'Fikir Kıvılcımı',  'Beynin çalışmaya başladı. Harika fikirler geliyor!',
   'fikir_kivilcimi.png',  'zihin_ustalari', 5, 1, 'seviye', 1),
  ('bilgi_avcisi',     'Bilgi Avcısı',      'Bilgiyi avlıyorsun. Her öğrendiğin seni güçlendiriyor.',
   'bilgi_avcisi.png',     'zihin_ustalari', 5, 2, 'seviye', 2),
  ('bulmaca_ustasi',   'Bulmaca Ustası',    'Bulmacalar senin oyun alanın. Her problemi çözersin.',
   'bulmaca_ustasi.png',   'zihin_ustalari', 5, 3, 'seviye', 3),
  ('akil_ustasi',      'Akıl Ustası',       'Akıl oyunlarının şampiyonusun. Kimse seni yenemiyor!',
   'akil_ustasi.png',      'zihin_ustalari', 5, 4, 'seviye', 4),
  ('zihin_simsegi',    'Zihin Şimşeği',     'Düşüncelerin ışık hızında! En zor soruyu bile aşıyorsun.',
   'zihin_simsegi.png',    'zihin_ustalari', 5, 5, 'seviye', 5),

  -- 🛡️ MUHAFIZLAR (sınıf 6) — Seri yolu (büyük sayılar)
  ('genc_muhafiz',   'Genç Muhafız',    'Kaleyi korumaya yemin ettin. Güçlü bir başlangıç!',
   'genc_muhafiz.png',   'muhafizlar', 6, 1, 'streak', 5),
  ('kale_bekcisi',   'Kale Bekçisi',    'Gözlerin her yerde. Hiçbir şey gözünden kaçmıyor.',
   'kale_bekcisi.png',   'muhafizlar', 6, 2, 'streak', 10),
  ('gok_muhafizi',   'Gök Muhafızı',    'Gökyüzünden koruyorsun. Seni kimse durduramaz!',
   'gok_muhafizi.png',   'muhafizlar', 6, 3, 'streak', 20),
  ('ates_muhafizi',  'Ateş Muhafızı',   'Ateş gibi kararlısın. Her engeli aşıyorsun.',
   'ates_muhafizi.png',  'muhafizlar', 6, 4, 'streak', 40),
  ('bas_muhafiz',    'Baş Muhafız',     'En büyük onur sana verildi. Efsane bir muhafızsın!',
   'bas_muhafiz.png',    'muhafizlar', 6, 5, 'streak', 60),

  -- 🏹 USTALAR (sınıf 7) — XP yolu (büyük sayılar)
  ('genc_kemankes',       'Genç Kemankeş',       'Yayını ilk gerdirdin. Büyük bir yolculuğun başlangıcı!',
   'genc_kemankes.png',       'ustalar', 7, 1, 'xp', 200),
  ('usta_kemankes',       'Usta Kemankeş',       'Ok atışın ustalık seviyesine ulaştı. Hedefini hiç kaçırmıyorsun.',
   'usta_kemankes.png',       'ustalar', 7, 2, 'xp', 1000),
  ('gok_akincisi',        'Gök Akıncısı',        'Gökyüzü senin at meydanın. Özgür ve güçlüsün!',
   'gok_akincisi.png',        'ustalar', 7, 3, 'xp', 2500),
  ('ustalar_firtina',     'Fırtına Ustası',       'İki dünyanın gücünü taşıyorsun — rüzgâr ve akıl.',
   'ustalar_firtina.png',     'ustalar', 7, 4, 'xp', 5000),
  ('buyuk_usta',          'Büyük Usta',           'Tüm sırları öğrendin. Sen artık efsanesin!',
   'buyuk_usta.png',          'ustalar', 7, 5, 'xp', 10000),

  -- 👑 EFSANELER (sınıf 8) — Ders ustalığı yolu
  ('ay_kasifi',          'Ay Kaşifi',           'Bir derste ustalaştın. Ay kadar parlıyorsun!',
   'ay_kasifi.png',          'efsaneler', 8, 1, 'ders_basari', 1),
  ('gunes_muhafizi',     'Güneş Muhafızı',      'Üç derste muhteşem başarı! Güneş gibi ışıl ışıl.',
   'gunes_muhafizi.png',     'efsaneler', 8, 2, 'ders_basari', 3),
  ('goklerin_akincisi',  'Göklerin Akıncısı',   'Beş alanda hükmeden efsanevi savaşçı. İnanılmazsın!',
   'goklerin_akincisi.png',  'efsaneler', 8, 3, 'ders_basari', 5),
  ('simsek_kagani',      'Şimşek Kağanı',       'Sekiz derste zirveye ulaştın. Ülkende senin gibi yok!',
   'simsek_kagani.png',      'efsaneler', 8, 4, 'ders_basari', 8),
  ('efsaneler_efsanesi', 'Efsaneler Efsanesi',  'Tüm sınırları aştın. Adın tarihe geçti. Sen bir efsanesin!',
   'efsaneler_efsanesi.png', 'efsaneler', 8, 5, 'xp',          15000)

on conflict (kod) do update set
  ad            = excluded.ad,
  aciklama      = excluded.aciklama,
  kosul_turu    = excluded.kosul_turu,
  kosul_deger   = excluded.kosul_deger;

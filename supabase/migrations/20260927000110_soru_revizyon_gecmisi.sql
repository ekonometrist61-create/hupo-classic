-- =====================================================================
--  KURTARMA: soru revizyon geçmişi (moderasyon izi)
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  NEDEN GEREKLİ?
--    Canlıdaki admin_upsert_question() bir soru güncellendiğinde ESKİ hâlini
--    public.question_revisions tablosuna yazar; panel bunu
--    admin_question_history() ile "kim, ne zaman, hangi alanları değiştirdi"
--    olarak gösterir. Diskte ne tablo ne bu iki fonksiyon vardı.
--
--  KAYNAK (canlı gövdeler, BİREBİR kopya):
--    kurtarilan/parcalar/admin_upsert_question.sql   → §2
--    kurtarilan/parcalar/admin_question_history.sql  → §3
--    Yetkiler: "-- secdef: true | search_path='' | anon: false | auth: true | servis: true"
--
--  ⚠️ TEK TAHMİN (dökümde YOK) — public.question_revisions TABLO TANIMI
--    Canlı katalog dökümünde tablonun kolon listesi bulunmuyor
--    (kurtarilan/*.csv içinde 'question_revisions' yalnızca fonksiyon
--    gövdelerinde geçiyor; 'information_schema' dökümü hiç alınmamış).
--    Tablo, canlı gövdelerdeki KULLANIMDAN geri kuruldu:
--      admin_question_history : r.id, r.changed_at, r.old_data,
--                               r.degisen_alanlar, r.revised_by, r.question_id
--      admin_upsert_question  : insert (question_id, revised_by, old_data, degisen_alanlar)
--    Tip/kısıt/indeks varsayımları mevcut şema desenine (admin_audit_log) uyduruldu.
--    TODO(kurtarma): canlıdan aşağıdaki sorgu ile teyit edilip tazelenmeli:
--      select column_name, data_type, is_nullable, column_default
--        from information_schema.columns
--       where table_schema='public' and table_name='question_revisions'
--       order by ordinal_position;
--      select conname, pg_get_constraintdef(oid) from pg_constraint
--       where conrelid = 'public.question_revisions'::regclass;
--
--  ⚠️ İKİNCİ TAHMİN — public._soru_anlik(uuid)
--    Bu yardımcı fonksiyonun canlı gövdesi dökümde YOK (kurtarilan/parcalar
--    içinde dosyası bulunmuyor; katalog dökümü de gövdesini içermiyor).
--    Çağrı biçiminden (p_id uuid → jsonb) ve tek kullanım amacından
--    (güncelleme öncesi/sonrası satır anlık görüntüsü; iki görüntünün
--    jsonb_object_keys farkı 'değişen alanlar'ı verir) yeniden kuruldu.
--    TODO(kurtarma): canlıdan teyit:
--      select pg_get_functiondef('public._soru_anlik(uuid)'::regprocedure);
--
--  BAĞIMLILIKLAR (diskte VAR ✓):
--    public.questions (…, sinif → 20260927000040), public.profiles,
--    public._soru_hatasi(jsonb), public.require_admin(), public.log_admin_action(text, jsonb)
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. question_revisions — soru düzenleme geçmişi
-- ---------------------------------------------------------------------
-- Yalnızca SECURITY DEFINER fonksiyonlar yazar/okur; istemciye kapalıdır.
-- Desen: 20260920000900_admin_role_and_payments.sql → admin_audit_log
create table if not exists public.question_revisions (
  id              uuid primary key default gen_random_uuid(),
  question_id     uuid not null references public.questions (id) on delete cascade,
  revised_by      uuid references public.profiles (id) on delete set null,
  old_data        jsonb not null,
  degisen_alanlar text[] not null default '{}',
  changed_at      timestamptz not null default clock_timestamp()
);

create index if not exists question_revisions_question_time_idx
  on public.question_revisions (question_id, changed_at desc);

alter table public.question_revisions enable row level security;

create policy "question_revisions_select"
  on public.question_revisions for select to authenticated
  using (public.is_admin());

revoke all on public.question_revisions from anon;
revoke insert, update, delete on public.question_revisions from authenticated;

-- ---------------------------------------------------------------------
-- 2. _soru_anlik — güncelleme öncesi/sonrası anlık görüntü (TÜRETİLMİŞ)
-- ---------------------------------------------------------------------
-- TODO(kurtarma): canlı gövde dökümde yok; yalnızca çağrı sözleşmesi biliniyor:
--   _soru_anlik(p_id uuid) returns jsonb
--   * soru yoksa null döner (admin_upsert_question 'Soru bulunamadı' fırlatır)
--   * dönen jsonb'nin anahtarları, güncellemede alan bazlı fark için kullanılır
--     (jsonb_object_keys(v_eski) ↔ v_yeni). Bu yüzden TÜM satırın anlık
--     görüntüsüdür; alan seçilmez.
create or replace function public._soru_anlik(p_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select to_jsonb(q)
    from public.questions q
   where q.id = p_id;
$$;

revoke execute on function public._soru_anlik(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. admin_upsert_question — CANLI sürüm (revizyon kaydı yazar)
-- ---------------------------------------------------------------------
-- Diskteki ESKİ sürüm (20260920000900) geçmiş kaydı yazmıyordu; canlı sürüm
-- güncellemede eski satırı question_revisions'a yazar. Aynı imza olduğu için
-- create or replace yeterlidir.
create or replace function public.admin_upsert_question(p_id uuid, p_soru jsonb)
returns uuid
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_hata   text;
  v_id     uuid;
  v_eski   jsonb;
  v_yeni   jsonb;
  v_fark   text[];
  v_sinif  smallint;
begin
  perform public.require_admin();

  v_hata := public._soru_hatasi(p_soru);
  if v_hata is not null then
    raise exception '%', v_hata using errcode = '22023';
  end if;

  -- _soru_hatasi doğruladı: sınıf zorunlu ve 1-12 (NULL üretilemez)
  v_sinif := trim(p_soru ->> 'sinif')::smallint;

  if p_id is null then
    insert into public.questions
      (okul, sinif, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik,
       cozum_adimlari, onay_durumu, created_by)
    values
      (trim(p_soru ->> 'okul'), v_sinif, trim(p_soru ->> 'ders'), trim(p_soru ->> 'konu'),
       nullif(trim(coalesce(p_soru ->> 'alt_konu', '')), ''),
       (p_soru ->> 'zorluk')::smallint, trim(p_soru ->> 'soru_metni'),
       p_soru -> 'siklar', upper(p_soru ->> 'dogru_sik'),
       coalesce(p_soru -> 'cozum_adimlari', '[]'::jsonb),
       coalesce(p_soru ->> 'onay_durumu', 'beklemede'), (select auth.uid()))
    returning id into v_id;
    perform public.log_admin_action('soru_eklendi', jsonb_build_object('soru_id', v_id));
  else
    v_eski := public._soru_anlik(p_id);
    if v_eski is null then
      raise exception 'Soru bulunamadı' using errcode = 'P0002';
    end if;

    update public.questions
       set okul = trim(p_soru ->> 'okul'),
           -- sinif anahtarı hiç gönderilmediyse (eski istemci) mevcut değer korunur
           sinif = case when p_soru ? 'sinif' then v_sinif else sinif end,
           ders = trim(p_soru ->> 'ders'),
           konu = trim(p_soru ->> 'konu'),
           alt_konu = nullif(trim(coalesce(p_soru ->> 'alt_konu', '')), ''),
           zorluk = (p_soru ->> 'zorluk')::smallint,
           soru_metni = trim(p_soru ->> 'soru_metni'),
           siklar = p_soru -> 'siklar',
           dogru_sik = upper(p_soru ->> 'dogru_sik'),
           cozum_adimlari = coalesce(p_soru -> 'cozum_adimlari', '[]'::jsonb),
           onay_durumu = coalesce(p_soru ->> 'onay_durumu', onay_durumu)
     where id = p_id
    returning id into v_id;

    v_yeni := public._soru_anlik(v_id);
    select coalesce(array_agg(k order by k), '{}') into v_fark
      from jsonb_object_keys(v_eski) k
     where v_eski -> k is distinct from v_yeni -> k;
    if coalesce(array_length(v_fark, 1), 0) > 0 then
      insert into public.question_revisions (question_id, revised_by, old_data, degisen_alanlar)
      values (v_id, (select auth.uid()), v_eski, v_fark);
    end if;

    perform public.log_admin_action('soru_guncellendi', jsonb_build_object('soru_id', v_id));
  end if;

  return v_id;
end;
$function$;

comment on function public.admin_upsert_question(uuid, jsonb) is
  'Soru ekler/günceller; güncellemede eski hâli question_revisions''a yazılır (moderasyon izi).';

revoke execute on function public.admin_upsert_question(uuid, jsonb) from public, anon;
grant  execute on function public.admin_upsert_question(uuid, jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 4. admin_question_history — CANLI gövde (birebir)
-- ---------------------------------------------------------------------
create or replace function public.admin_question_history(p_id uuid)
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
begin
  perform public.require_admin();
  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.changed_at desc)
      from (
        select r.id, r.changed_at, r.old_data, r.degisen_alanlar, p.full_name as duzenleyen
          from public.question_revisions r
          left join public.profiles p on p.id = r.revised_by
         where r.question_id = p_id
         order by r.changed_at desc
         limit 50
      ) x
  ), '[]'::jsonb);
end;
$function$;

comment on function public.admin_question_history(uuid) is
  'Bir sorunun son 50 düzenleme kaydı: değişen alanlar, eski hâli ve düzenleyen.';

revoke execute on function public.admin_question_history(uuid) from public, anon;
grant  execute on function public.admin_question_history(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- NOT (kurtarma): bu dosyayla birlikte çözülen boşluklar
--   ✓ public.question_revisions (tablo, kullanımdan geri kuruldu)
--   ✓ public._soru_anlik(uuid) (davranış sözleşmesinden geri kuruldu)
--   ✓ public.admin_upsert_question(uuid, jsonb)  (canlı gövde birebir)
--   ✓ public.admin_question_history(uuid)        (canlı gövde birebir)
--
-- Hâlâ canlıdan ALINMASI gerekenler (tahmin edilmedi):
--   · questions.sinif kolonunun NOT NULL olup olmadığı
--     (yerelde bilinçli NULLABLE — 20260927000040)
--   · public._soru_hatasi(jsonb) gövdesinin canlı kopyası:
--     canlı gövdeler "sınıf zorunlu ve 1-12" doğrulandığını söylüyor,
--     diskteki sürümde sınıf kuralı YOK. İmza aynı olduğu için katalog
--     dökümü bu farkı göstermiyor.
--   Ayrıntı: supabase/KURTARMA_DURUMU.md §3 ve §4
-- ---------------------------------------------------------------------

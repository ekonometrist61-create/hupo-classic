-- =====================================================================
-- CANLI ŞEMA KURTARMASI: repoda olmayan nesneler (TASKS.md §11.7)
--
-- 2026-10-10 tarihinde canlı veritabanının katalog sorgusundan üretildi
-- (pg_catalog: DDL, indeks, trigger, RLS, politika, yetki; fonksiyonlar pg_get_functiondef ile birebir).
-- Kapsam: 7 tablo, 24 fonksiyon, 7 politika, 4 indeks, 1 trigger.
-- Tüm ifadeler yeniden çalıştırılabilir: if not exists, drop ... if exists + create, create or replace, revoke/grant.
-- Canlıda zaten var olduğu için uygulamanın etkisi no-op olmalıdır; yine de deploy öncesi doğrulanmalı.
-- Not: auth_bridge_tokens ve exchange/issue_auth_bridge_token için güvenlik kararı bekleniyor (TASKS.md §11.7).
-- =====================================================================

-- SQL-dil fonksiyonlarının gövdesi, bağımlı fonksiyonlar sonradan oluştuğu için oluşturma anında doğrulanmasın
set check_function_bodies = false;

-- 1) Tablolar
create table if not exists public.auth_bridge_tokens (
  id uuid not null default gen_random_uuid(),
  token_hash text not null,
  user_id uuid not null,
  access_token text,
  refresh_token text,
  expires_at timestamp with time zone not null,
  used_at timestamp with time zone,
  created_at timestamp with time zone not null default now(),
  constraint auth_bridge_tokens_pkey PRIMARY KEY (id),
  constraint auth_bridge_tokens_token_hash_key UNIQUE (token_hash),
  constraint auth_bridge_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

create table if not exists public.deneme_sinavi_cevaplari (
  deneme_id uuid not null,
  question_id uuid not null,
  secilen_sik text,
  dogru boolean not null default false,
  cevap_zamani timestamp with time zone not null default now(),
  constraint deneme_sinavi_cevaplari_deneme_id_fkey FOREIGN KEY (deneme_id) REFERENCES deneme_sinavi_denemeleri(id) ON DELETE CASCADE,
  constraint deneme_sinavi_cevaplari_pkey PRIMARY KEY (deneme_id, question_id),
  constraint deneme_sinavi_cevaplari_question_id_fkey FOREIGN KEY (question_id) REFERENCES questions(id)
);

create table if not exists public.deneme_sinavi_katilimlari (
  id uuid not null default gen_random_uuid(),
  exam_id uuid not null,
  student_id uuid not null,
  veli_id uuid not null,
  telefon text not null,
  kayit_zamani timestamp with time zone not null default now(),
  constraint deneme_sinavi_katilimlari_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES deneme_sinavlari(id) ON DELETE CASCADE,
  constraint deneme_sinavi_katilimlari_exam_id_student_id_key UNIQUE (exam_id, student_id),
  constraint deneme_sinavi_katilimlari_pkey PRIMARY KEY (id),
  constraint deneme_sinavi_katilimlari_student_id_fkey FOREIGN KEY (student_id) REFERENCES profiles(id) ON DELETE CASCADE,
  constraint deneme_sinavi_katilimlari_telefon_uzunluk CHECK (((length(TRIM(BOTH FROM telefon)) >= 7) AND (length(TRIM(BOTH FROM telefon)) <= 20))),
  constraint deneme_sinavi_katilimlari_veli_id_fkey FOREIGN KEY (veli_id) REFERENCES profiles(id) ON DELETE CASCADE
);

create table if not exists public.ogrenci_baglanti_kodlari (
  id uuid not null default gen_random_uuid(),
  kod character(6) not null,
  ogrenci_id uuid not null,
  son_gecerlilik timestamp with time zone not null default (now() + '00:15:00'::interval),
  kullanildi_at timestamp with time zone,
  kullanan_veli uuid,
  created_at timestamp with time zone not null default now(),
  constraint ogrenci_baglanti_kodlari_kod_check CHECK ((kod ~ '^[0-9]{6}$'::text)),
  constraint ogrenci_baglanti_kodlari_kullanan_veli_fkey FOREIGN KEY (kullanan_veli) REFERENCES profiles(id) ON DELETE SET NULL,
  constraint ogrenci_baglanti_kodlari_ogrenci_id_fkey FOREIGN KEY (ogrenci_id) REFERENCES profiles(id) ON DELETE CASCADE,
  constraint ogrenci_baglanti_kodlari_pkey PRIMARY KEY (id)
);

create table if not exists public.questions_sinifsiz_yedek (
  id uuid,
  okul text,
  ders text,
  konu text,
  alt_konu text,
  zorluk smallint,
  soru_metni text,
  siklar jsonb,
  dogru_sik text,
  onay_durumu text,
  created_by uuid,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  arama_vektoru tsvector,
  cozum_adimlari jsonb,
  inceleme_gerekli boolean,
  sinif smallint,
  yedek_tarihi timestamp with time zone
);

create table if not exists public.site_icerik (
  anahtar text not null,
  dil text not null default 'tr'::text,
  deger text not null,
  guncellenme timestamp with time zone not null default now(),
  guncelleyen uuid,
  constraint site_icerik_anahtar_check CHECK ((((char_length(anahtar) >= 1) AND (char_length(anahtar) <= 200)) AND (anahtar ~ '^[A-Za-z0-9_.-]+$'::text))),
  constraint site_icerik_deger_check CHECK (((char_length(btrim(deger)) >= 1) AND (char_length(btrim(deger)) <= 5000))),
  constraint site_icerik_dil_check CHECK ((dil = ANY (ARRAY['tr'::text, 'en'::text]))),
  constraint site_icerik_guncelleyen_fkey FOREIGN KEY (guncelleyen) REFERENCES auth.users(id) ON DELETE SET NULL,
  constraint site_icerik_pkey PRIMARY KEY (anahtar, dil)
);

create table if not exists public.veli_baglama_hatalari (
  id bigint not null generated always as identity,
  veli_id uuid not null,
  created_at timestamp with time zone not null default now(),
  constraint veli_baglama_hatalari_pkey PRIMARY KEY (id),
  constraint veli_baglama_hatalari_veli_id_fkey FOREIGN KEY (veli_id) REFERENCES profiles(id) ON DELETE CASCADE
);

-- 2) RLS (canlıdaki durum: tümü açık)
alter table public.auth_bridge_tokens enable row level security;
alter table public.deneme_sinavi_cevaplari enable row level security;
alter table public.deneme_sinavi_katilimlari enable row level security;
alter table public.ogrenci_baglanti_kodlari enable row level security;
alter table public.questions_sinifsiz_yedek enable row level security;
alter table public.site_icerik enable row level security;
alter table public.veli_baglama_hatalari enable row level security;

-- 3) Tablo yetkileri (canlı relacl ile birebir)
revoke all on table public.auth_bridge_tokens from public, anon, authenticated, service_role;
grant  insert, select, update, delete, truncate, references, trigger, maintain on table public.auth_bridge_tokens to service_role;
revoke all on table public.deneme_sinavi_cevaplari from public, anon, authenticated, service_role;
grant  insert, select, update, delete, truncate, references, trigger, maintain on table public.deneme_sinavi_cevaplari to service_role;
revoke all on table public.deneme_sinavi_katilimlari from public, anon, authenticated, service_role;
grant  insert, select, update, delete, truncate, references, trigger, maintain on table public.deneme_sinavi_katilimlari to service_role;
revoke all on table public.ogrenci_baglanti_kodlari from public, anon, authenticated, service_role;
grant  insert, select, update, delete, truncate, references, trigger, maintain on table public.ogrenci_baglanti_kodlari to service_role;
revoke all on table public.questions_sinifsiz_yedek from public, anon, authenticated, service_role;
grant  insert, select, update, delete, truncate, references, trigger, maintain on table public.questions_sinifsiz_yedek to service_role;
revoke all on table public.site_icerik from public, anon, authenticated, service_role;
grant  insert, select, update, delete, truncate, references, trigger, maintain on table public.site_icerik to service_role;
grant  select on table public.site_icerik to anon;
grant  insert, select, update, delete on table public.site_icerik to authenticated;
revoke all on table public.veli_baglama_hatalari from public, anon, authenticated, service_role;
grant  insert, select, update, delete, truncate, references, trigger, maintain on table public.veli_baglama_hatalari to service_role;

-- 4) Fonksiyonlar (canlı pg_get_functiondef, birebir)
CREATE OR REPLACE FUNCTION public._abonelik_ver(p_veli uuid, p_plan_kod text, p_saglayici text, p_ref text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_plan public.plans%rowtype;
  v_bas  timestamptz;
  v_sub  uuid;
begin
  select * into v_plan from public.plans where kod = p_plan_kod;
  if not found then
    raise exception 'Plan bulunamadı' using errcode = 'P0002';
  end if;
  select max(s.bitis) into v_bas
    from public.subscriptions s
   where s.veli_id = p_veli and s.plan_kod = p_plan_kod and s.durum = 'aktif' and s.bitis > now();
  v_bas := coalesce(v_bas, now());
  insert into public.subscriptions (veli_id, plan_kod, durum, baslangic, bitis, saglayici, saglayici_ref)
  values (p_veli, p_plan_kod, 'aktif', v_bas, v_bas + make_interval(days => v_plan.sure_gun), p_saglayici, p_ref)
  returning id into v_sub;
  return v_sub;
end;
$function$;

CREATE OR REPLACE FUNCTION public._cocuk_hesabi_bagla(p_ogrenci uuid, p_veli uuid, p_sinif integer, p_kullanici_adi text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_role text;
begin
  select role into v_role from public.profiles where id = p_veli for update;
  if v_role is distinct from 'veli' then
    raise exception 'Yalnızca veli hesapları çocuk hesabı oluşturabilir' using errcode = '42501';
  end if;
  if public.veli_cocuk_sayisi(p_veli) >= 5 then
    raise exception 'En fazla 5 çocuk hesabı oluşturabilirsiniz' using errcode = '22023';
  end if;
  if p_sinif is null or not (p_sinif = any (public._desteklenen_siniflar())) then
    raise exception 'Bu sınıf şu an desteklenmiyor' using errcode = '22023';
  end if;

  update public.profiles
     set parent_id = p_veli, sinif = p_sinif::smallint, kullanici_adi = p_kullanici_adi
   where id = p_ogrenci and role = 'ogrenci' and parent_id is null;
  if not found then
    raise exception 'Öğrenci profili bulunamadı' using errcode = 'P0002';
  end if;
end;
$function$;

CREATE OR REPLACE FUNCTION public._dc_sec(p_gun date, p_anahtar text)
 RETURNS uuid[]
 LANGUAGE plpgsql
 STABLE
 SET search_path TO ''
AS $function$
declare
  v_recent uuid[];
  v_ids    uuid[];
  v_n      integer := case when p_anahtar ~ '^sinif[0-9]+$'
                           then substr(p_anahtar, 6)::integer end;
begin
  -- Sınıfsız soru kalmadığı için 'hepsi'/'ilkokul'/'ortaokul' havuzları üretilmez.
  if v_n is null then
    return null;
  end if;

  select coalesce(array_agg(distinct q), '{}') into v_recent
    from public.daily_challenges d, unnest(d.question_ids) q
   where d.anahtar = p_anahtar and d.gun < p_gun and d.gun >= p_gun - 14;

  with cand as (
    select q.id, q.zorluk,
           (q.id = any (v_recent))::int as used,
           md5(q.id::text || p_gun::text) as h
      from public.questions q
     where q.onay_durumu = 'onaylandi'
       and q.sinif = v_n
  ), ranked as (
    select c.*, row_number() over (partition by c.zorluk order by c.used, c.h) as rn from cand c
  ), first_pick as (
    select * from ranked
     where (zorluk = 1 and rn <= 2) or (zorluk = 2 and rn <= 2) or (zorluk = 3 and rn <= 1)
  ), fill as (
    select r.* from ranked r
     where r.id not in (select id from first_pick)
     order by r.used, r.h
     limit greatest(5 - (select count(*) from first_pick), 0)
  ), picked as (
    select * from first_pick union all select * from fill
  )
  select array_agg(id order by zorluk, h) into v_ids from picked;

  if v_ids is null or cardinality(v_ids) < 5 then
    return null;
  end if;
  return v_ids;
end;
$function$;

CREATE OR REPLACE FUNCTION public._dc_seviye(p_sinif smallint)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO ''
AS $function$
  select case when p_sinif is null then 'hepsi'
              when p_sinif <= 4 then 'ilkokul'
              when p_sinif <= 8 then 'ortaokul'
              else 'lise' end;
$function$;

CREATE OR REPLACE FUNCTION public._deneme_bitis_zamani(p_exam deneme_sinavlari)
 RETURNS timestamp with time zone
 LANGUAGE sql
 IMMUTABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select p_exam.baslangic_zamani + (p_exam.sure_dakika || ' minutes')::interval;
$function$;

CREATE OR REPLACE FUNCTION public._deneme_sinavi_bitir(p_deneme_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_deneme  public.deneme_sinavi_denemeleri%rowtype;
  v_toplam  integer;
  v_dogru   integer;
  v_yanlis  integer;
  v_bos     integer;
  v_puan    numeric(5, 2);
begin
  select * into v_deneme from public.deneme_sinavi_denemeleri where id = p_deneme_id for update;
  if not found then
    raise exception 'Deneme bulunamadı' using errcode = 'P0002';
  end if;

  if v_deneme.bitis_zamani is not null then
    -- Zaten bitmiş: idempotent — mevcut özeti döndür.
    return jsonb_build_object(
      'dogru_sayisi', v_deneme.dogru_sayisi, 'yanlis_sayisi', v_deneme.yanlis_sayisi,
      'bos_sayisi', v_deneme.bos_sayisi, 'puan', v_deneme.puan
    );
  end if;

  select count(*) into v_toplam
    from public.deneme_sinavi_sorulari
   where exam_id = v_deneme.exam_id and sinif = v_deneme.sinif;

  select count(*) filter (where dogru), count(*) filter (where not dogru and secilen_sik is not null)
    into v_dogru, v_yanlis
    from public.deneme_sinavi_cevaplari
   where deneme_id = p_deneme_id;
  v_dogru := coalesce(v_dogru, 0);
  v_yanlis := coalesce(v_yanlis, 0);
  -- Boş = (hiç cevaplanmamış sorular) + (açıkça boş bırakılan sorular). İkisi
  -- birlikte tam olarak "doğru ya da yanlış olmayan" sorulardır.
  v_bos := greatest(v_toplam - v_dogru - v_yanlis, 0);
  v_puan := case when v_toplam > 0 then round(v_dogru * 100.0 / v_toplam, 2) else 0 end;

  update public.deneme_sinavi_denemeleri
     set bitis_zamani = now(), dogru_sayisi = v_dogru, yanlis_sayisi = v_yanlis,
         bos_sayisi = v_bos, puan = v_puan
   where id = p_deneme_id;

  return jsonb_build_object('dogru_sayisi', v_dogru, 'yanlis_sayisi', v_yanlis, 'bos_sayisi', v_bos, 'puan', v_puan);
end;
$function$;

CREATE OR REPLACE FUNCTION public._kupon_kullanim(p_coupon uuid, p_veli uuid DEFAULT NULL::uuid)
 RETURNS integer
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select count(*)::integer from public.coupon_redemptions r
   where r.coupon_id = p_coupon
     and (p_veli is null or r.veli_id = p_veli)
     and (r.durum = 'kullanildi' or (r.durum = 'rezerve' and r.rezerve_bitis > now()));
$function$;

CREATE OR REPLACE FUNCTION public._uret_meydan_kod()
 RETURNS text
 LANGUAGE sql
 SET search_path TO ''
AS $function$
  select upper(substring(md5(gen_random_uuid()::text) from 1 for 6))
$function$;

CREATE OR REPLACE FUNCTION public._veli_bagla_hata(p_veli uuid, p_mesaj text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  insert into public.veli_baglama_hatalari (veli_id) values (p_veli);
  -- HTTP 200 ile döner (hata fırlatılmaz): başarısız deneme kaydı her koşulda kalıcı olsun.
  -- İstemci gövdedeki 'hata' alanına bakar.
  return jsonb_build_object(
    'code', 'P0001', 'message', p_mesaj, 'details', null, 'hint', null, 'hata', p_mesaj);
end;
$function$;

CREATE OR REPLACE FUNCTION public.exchange_auth_bridge_token(p_token text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_row public.auth_bridge_tokens%rowtype;
begin
  if p_token is null or length(p_token) < 10 then
    raise exception 'Token eksik' using errcode = '22023';
  end if;

  select * into v_row
    from public.auth_bridge_tokens
   where token_hash = md5(p_token)
     and used_at is null
     and expires_at > now()
   for update;

  if not found then
    raise exception 'Bağlantının süresi dolmuş veya zaten kullanılmış' using errcode = 'P0002';
  end if;

  update public.auth_bridge_tokens set used_at = now() where id = v_row.id;

  return jsonb_build_object(
    'access_token', v_row.access_token,
    'refresh_token', v_row.refresh_token
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.finish_mock_exam_attempt(p_deneme_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.deneme_sinavi_denemeleri where id = p_deneme_id and student_id = v_uid
  ) then
    raise exception 'Deneme bulunamadı' using errcode = 'P0002';
  end if;

  return public._deneme_sinavi_bitir(p_deneme_id);
end;
$function$;

CREATE OR REPLACE FUNCTION public.get_mock_exam_result(p_exam_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid    uuid := (select auth.uid());
  v_deneme public.deneme_sinavi_denemeleri%rowtype;
  v_sira   bigint;
  v_toplam bigint;
  v_onceki jsonb;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;

  select * into v_deneme
    from public.deneme_sinavi_denemeleri
   where exam_id = p_exam_id and student_id = v_uid;
  if not found or v_deneme.bitis_zamani is null then
    raise exception 'Bu sınava ait tamamlanmış bir denemen bulunamadı' using errcode = 'P0002';
  end if;

  select count(*) filter (where d.puan > v_deneme.puan) + 1, count(*)
    into v_sira, v_toplam
    from public.deneme_sinavi_denemeleri d
   where d.exam_id = p_exam_id and d.sinif = v_deneme.sinif and d.bitis_zamani is not null;

  -- Bir önceki deneme sınavı: bu sınavdan daha ÖNCE başlamış, öğrencinin
  -- tamamladığı en yakın deneme sınavı (karşılaştırma amaçlı).
  select jsonb_build_object('ad', e.ad, 'puan', d.puan)
    into v_onceki
    from public.deneme_sinavi_denemeleri d
    join public.deneme_sinavlari e on e.id = d.exam_id
   where d.student_id = v_uid
     and d.bitis_zamani is not null
     and e.baslangic_zamani < (select baslangic_zamani from public.deneme_sinavlari where id = p_exam_id)
   order by e.baslangic_zamani desc
   limit 1;

  return jsonb_build_object(
    'puan', v_deneme.puan,
    'dogru_sayisi', v_deneme.dogru_sayisi,
    'yanlis_sayisi', v_deneme.yanlis_sayisi,
    'bos_sayisi', v_deneme.bos_sayisi,
    'sira', v_sira,
    'toplam', v_toplam,
    'onceki_deneme', v_onceki
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.get_my_mock_exam_status()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := (select auth.uid());
  v_sinif smallint;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  select sinif into v_sinif from public.profiles where id = v_uid;

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.baslangic_zamani)
      from (
        select e.id, e.ad, e.baslangic_zamani, e.sure_dakika,
               (k.id is not null) as kayitli
          from public.deneme_sinavlari e
          left join public.deneme_sinavi_katilimlari k
                 on k.exam_id = e.id and k.student_id = v_uid
         where e.aktif
           and public._deneme_bitis_zamani(e) > now()
           and v_sinif = any (e.siniflar)
           and not exists (
             select 1 from public.deneme_sinavi_denemeleri d
              where d.exam_id = e.id and d.student_id = v_uid
           )
      ) x
  ), '[]'::jsonb);
end;
$function$;

CREATE OR REPLACE FUNCTION public.get_next_mock_exam_public()
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select jsonb_build_object('ad', ad, 'baslangic_zamani', baslangic_zamani)
    from public.deneme_sinavlari
   where aktif and baslangic_zamani > now()
   order by baslangic_zamani asc
   limit 1;
$function$;

CREATE OR REPLACE FUNCTION public.get_upcoming_mock_exams_for_child(p_cocuk_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := (select auth.uid());
  v_sinif smallint;
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi görüntüleyebilir' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = p_cocuk_id;

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.baslangic_zamani)
      from (
        select e.id, e.ad, e.baslangic_zamani, e.sure_dakika,
               (k.id is not null) as kayitli,
               coalesce(k.telefon, p.telefon, '') as telefon
          from public.deneme_sinavlari e
          left join public.deneme_sinavi_katilimlari k
                 on k.exam_id = e.id and k.student_id = p_cocuk_id
          left join public.profiles p on p.id = p_cocuk_id
         where e.aktif
           and e.baslangic_zamani > now()
           and v_sinif = any (e.siniflar)
      ) x
  ), '[]'::jsonb);
end;
$function$;

CREATE OR REPLACE FUNCTION public.issue_auth_bridge_token(p_access_token text, p_refresh_token text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid   uuid := (select auth.uid());
  v_token text;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if p_access_token is null or length(p_access_token) < 10
     or p_refresh_token is null or length(p_refresh_token) < 10 then
    raise exception 'Token eksik veya geçersiz' using errcode = '22023';
  end if;

  -- Bu kullanıcının eski/süresi dolmuş/kullanılmış satırlarını temizle.
  delete from public.auth_bridge_tokens
   where user_id = v_uid and (used_at is not null or expires_at < now());

  v_token := replace(gen_random_uuid()::text, '-', '') || replace(gen_random_uuid()::text, '-', '');

  insert into public.auth_bridge_tokens (token_hash, user_id, access_token, refresh_token, expires_at)
  values (md5(v_token), v_uid, p_access_token, p_refresh_token, now() + interval '90 seconds');

  return v_token;
end;
$function$;

CREATE OR REPLACE FUNCTION public.ogrenci_baglanti_kodu_olustur()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid   uuid := auth.uid();
  v_prof  public.profiles%rowtype;
  v_n     bigint;
  v_kod   text;
  v_son   timestamptz := now() + interval '15 minutes';
  i       integer;
begin
  if v_uid is null then
    raise exception 'Lütfen önce giriş yapın' using errcode = '42501';
  end if;

  select * into v_prof from public.profiles where id = v_uid for update;
  if not found or v_prof.role <> 'ogrenci' then
    raise exception 'Bağlantı kodunu yalnızca öğrenci hesapları oluşturabilir' using errcode = '42501';
  end if;
  if v_prof.parent_id is not null then
    raise exception 'Hesabınız zaten bir veliye bağlı' using errcode = '22023';
  end if;

  -- Temizlik: süresi dolmuş kullanılmamış kodlar + bu öğrencinin önceki kodu
  delete from public.ogrenci_baglanti_kodlari
   where kullanildi_at is null
     and (son_gecerlilik < now() or ogrenci_id = v_uid);

  for i in 1..20 loop
    -- Kriptografik rastgele 32 bit; modülo yanlılığı olmasın diye reddetmeli örnekleme
    v_n := ('x' || encode(extensions.gen_random_bytes(4), 'hex'))::bit(32)::bigint;
    continue when v_n >= 4294000000;
    v_kod := lpad((v_n % 1000000)::text, 6, '0');
    begin
      insert into public.ogrenci_baglanti_kodlari (kod, ogrenci_id, son_gecerlilik)
      values (v_kod, v_uid, v_son);
      return jsonb_build_object('kod', v_kod, 'son_gecerlilik', v_son);
    exception when unique_violation then
      -- aynı kod başka bir aktif kayıtta var: yeniden dene
      null;
    end;
  end loop;

  raise exception 'Kod oluşturulamadı, lütfen tekrar deneyin' using errcode = 'P0001';
end;
$function$;

CREATE OR REPLACE FUNCTION public.register_for_mock_exam(p_exam_id uuid, p_cocuk_id uuid, p_telefon text, p_surum text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid  uuid := (select auth.uid());
  v_exam public.deneme_sinavlari%rowtype;
  v_sinif smallint;
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi kayıt yapabilir' using errcode = '42501';
  end if;
  if p_telefon is null or length(trim(p_telefon)) < 7 or length(trim(p_telefon)) > 20 then
    raise exception 'Geçerli bir telefon numarası girin' using errcode = '22023';
  end if;

  select * into v_exam from public.deneme_sinavlari where id = p_exam_id;
  if not found or not v_exam.aktif then
    raise exception 'Sınav bulunamadı' using errcode = 'P0002';
  end if;
  if now() >= v_exam.baslangic_zamani then
    raise exception 'Bu sınav için kayıtlar kapandı' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = p_cocuk_id;
  if v_sinif is null or v_sinif <> all (v_exam.siniflar) then
    raise exception 'Bu sınav öğrencinin sınıfı için açık değil' using errcode = '22023';
  end if;

  if not exists (
    select 1 from public.consents
     where cocuk_id = p_cocuk_id and tur = 'sinav_pazarlama_izni' and surum = p_surum
  ) then
    raise exception 'Önce pazarlama/KVKK onayı verilmeli' using errcode = '42501';
  end if;

  insert into public.deneme_sinavi_katilimlari (exam_id, student_id, veli_id, telefon)
  values (p_exam_id, p_cocuk_id, v_uid, trim(p_telefon))
  on conflict (exam_id, student_id) do update set telefon = excluded.telefon;

  update public.profiles set telefon = trim(p_telefon) where id = p_cocuk_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.set_exam_marketing_consent(p_cocuk_id uuid, p_surum text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi bu onayı verebilir' using errcode = '42501';
  end if;
  if p_surum is null or length(trim(p_surum)) = 0 then
    raise exception 'Sürüm gerekli' using errcode = '22023';
  end if;

  insert into public.consents (cocuk_id, veli_id, tur, surum)
  values (p_cocuk_id, v_uid, 'sinav_pazarlama_izni', p_surum);
end;
$function$;

CREATE OR REPLACE FUNCTION public.site_icerik_damga()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
  new.guncellenme := now();
  new.guncelleyen := (select auth.uid());
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.start_mock_exam_attempt(p_exam_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid   uuid := (select auth.uid());
  v_exam  public.deneme_sinavlari%rowtype;
  v_sinif smallint;
  v_bitis timestamptz;
  v_deneme_id uuid;
  v_sorular jsonb;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;

  select * into v_exam from public.deneme_sinavlari where id = p_exam_id;
  if not found or not v_exam.aktif then
    raise exception 'Sınav bulunamadı' using errcode = 'P0002';
  end if;

  v_bitis := public._deneme_bitis_zamani(v_exam);
  if now() < v_exam.baslangic_zamani then
    raise exception 'Bu sınav henüz başlamadı' using errcode = '42501';
  end if;
  if now() >= v_bitis then
    raise exception 'Bu sınavın süresi doldu' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = v_uid;
  if v_sinif is null or v_sinif <> all (v_exam.siniflar) then
    raise exception 'Bu sınav sizin sınıfınız için açık değil' using errcode = '22023';
  end if;

  if not exists (
    select 1 from public.deneme_sinavi_katilimlari where exam_id = p_exam_id and student_id = v_uid
  ) then
    raise exception 'Önce veli panelinden bu sınava kaydolmalısınız' using errcode = '42501';
  end if;

  if exists (select 1 from public.deneme_sinavi_denemeleri where exam_id = p_exam_id and student_id = v_uid) then
    raise exception 'Bu sınava zaten başladınız, tekrar giremezsiniz' using errcode = '42501';
  end if;

  insert into public.deneme_sinavi_denemeleri (exam_id, student_id, sinif)
  values (p_exam_id, v_uid, v_sinif)
  returning id into v_deneme_id;

  -- Doğru şık ASLA istemciye gönderilmez.
  select coalesce(jsonb_agg(to_jsonb(x) order by x.sira), '[]'::jsonb) into v_sorular
    from (
      select s.sira, q.id, q.ders, q.konu, q.zorluk, q.soru_metni, q.siklar
        from public.deneme_sinavi_sorulari s
        join public.questions q on q.id = s.question_id
       where s.exam_id = p_exam_id and s.sinif = v_sinif
    ) x;

  return jsonb_build_object(
    'deneme_id', v_deneme_id,
    'bitis_zamani', v_bitis,
    'sure_dakika', v_exam.sure_dakika,
    'sorular', v_sorular
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.submit_mock_exam_answer(p_deneme_id uuid, p_question_id uuid, p_secilen_sik text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid   uuid := (select auth.uid());
  v_deneme public.deneme_sinavi_denemeleri%rowtype;
  v_exam  public.deneme_sinavlari%rowtype;
  v_dogru_sik text;
  v_dogru boolean;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;

  select * into v_deneme from public.deneme_sinavi_denemeleri where id = p_deneme_id;
  if not found or v_deneme.student_id <> v_uid then
    raise exception 'Deneme bulunamadı' using errcode = 'P0002';
  end if;
  if v_deneme.bitis_zamani is not null then
    raise exception 'Bu deneme zaten bitti' using errcode = '42501';
  end if;

  select * into v_exam from public.deneme_sinavlari where id = v_deneme.exam_id;
  if now() >= public._deneme_bitis_zamani(v_exam) then
    perform public._deneme_sinavi_bitir(p_deneme_id);
    raise exception 'Sınav süresi doldu' using errcode = '42501';
  end if;

  if not exists (
    select 1 from public.deneme_sinavi_sorulari
     where exam_id = v_deneme.exam_id and sinif = v_deneme.sinif and question_id = p_question_id
  ) then
    raise exception 'Bu soru bu sınavda yok' using errcode = '22023';
  end if;

  select dogru_sik into v_dogru_sik from public.questions where id = p_question_id;
  v_dogru := p_secilen_sik is not null and p_secilen_sik = v_dogru_sik;

  insert into public.deneme_sinavi_cevaplari (deneme_id, question_id, secilen_sik, dogru)
  values (p_deneme_id, p_question_id, p_secilen_sik, v_dogru)
  on conflict (deneme_id, question_id)
  do update set secilen_sik = excluded.secilen_sik, dogru = excluded.dogru, cevap_zamani = now();
end;
$function$;

CREATE OR REPLACE FUNCTION public.veli_cocuk_bagla(p_kod text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid     uuid := auth.uid();
  v_role    text;
  v_hata    integer;
  v_kod     text := btrim(coalesce(p_kod, ''));
  v_kayit   public.ogrenci_baglanti_kodlari%rowtype;
  v_ogr     public.profiles%rowtype;
begin
  if v_uid is null then
    raise exception 'Lütfen önce giriş yapın' using errcode = '42501';
  end if;

  -- Veli satırını kilitle: aynı velinin eşzamanlı istekleri sıraya girer (5 çocuk sınırı)
  select role into v_role from public.profiles where id = v_uid for update;
  if v_role is distinct from 'veli' then
    raise exception 'Çocuk bağlama işlemini yalnızca veli hesapları yapabilir' using errcode = '42501';
  end if;

  select count(*) into v_hata from public.veli_baglama_hatalari
   where veli_id = v_uid and created_at > now() - interval '1 hour';
  if v_hata >= 5 then
    raise exception 'Çok fazla hatalı deneme yaptınız. Lütfen bir saat sonra tekrar deneyin.'
      using errcode = '42501';
  end if;

  if public.veli_cocuk_sayisi(v_uid) >= 5 then
    raise exception 'En fazla 5 çocuk hesabı bağlayabilirsiniz' using errcode = '22023';
  end if;

  if v_kod !~ '^[0-9]{6}$' then
    return public._veli_bagla_hata(v_uid, 'Kod 6 haneli bir sayı olmalıdır');
  end if;

  select * into v_kayit from public.ogrenci_baglanti_kodlari
   where kod = v_kod and kullanildi_at is null
   for update;
  if not found or v_kayit.son_gecerlilik < now() then
    return public._veli_bagla_hata(v_uid,
      'Kod hatalı ya da süresi dolmuş. Lütfen çocuğunuzdan yeni bir kod isteyin.');
  end if;

  select * into v_ogr from public.profiles where id = v_kayit.ogrenci_id for update;
  if not found or v_ogr.role <> 'ogrenci' or v_ogr.parent_id is not null then
    return public._veli_bagla_hata(v_uid, 'Bu öğrenci hesabı bağlanamıyor');
  end if;

  perform set_config('app.veli_cocuk_bagla', 'on', true);
  update public.profiles set parent_id = v_uid where id = v_ogr.id;
  perform set_config('app.veli_cocuk_bagla', 'off', true);

  update public.ogrenci_baglanti_kodlari
     set kullanildi_at = now(), kullanan_veli = v_uid
   where id = v_kayit.id;

  return jsonb_build_object('ogrenci_id', v_ogr.id, 'ad', v_ogr.full_name);
end;
$function$;

CREATE OR REPLACE FUNCTION public.veli_cocuk_sayisi(p_veli uuid)
 RETURNS integer
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select count(*)::integer from public.profiles
   where parent_id = p_veli and role = 'ogrenci';
$function$;

-- 5) Fonksiyon yetkileri (canlı proacl ile birebir)
revoke execute on function public._abonelik_ver(p_veli uuid, p_plan_kod text, p_saglayici text, p_ref text) from public, anon, authenticated, service_role;
grant  execute on function public._abonelik_ver(p_veli uuid, p_plan_kod text, p_saglayici text, p_ref text) to service_role;
revoke execute on function public._cocuk_hesabi_bagla(p_ogrenci uuid, p_veli uuid, p_sinif integer, p_kullanici_adi text) from public, anon, authenticated, service_role;
grant  execute on function public._cocuk_hesabi_bagla(p_ogrenci uuid, p_veli uuid, p_sinif integer, p_kullanici_adi text) to service_role;
revoke execute on function public._dc_sec(p_gun date, p_anahtar text) from public, anon, authenticated, service_role;
grant  execute on function public._dc_sec(p_gun date, p_anahtar text) to service_role;
revoke execute on function public._dc_seviye(p_sinif smallint) from public, anon, authenticated, service_role;
grant  execute on function public._dc_seviye(p_sinif smallint) to service_role;
revoke execute on function public._deneme_bitis_zamani(p_exam deneme_sinavlari) from public, anon, authenticated, service_role;
grant  execute on function public._deneme_bitis_zamani(p_exam deneme_sinavlari) to service_role;
revoke execute on function public._deneme_sinavi_bitir(p_deneme_id uuid) from public, anon, authenticated, service_role;
grant  execute on function public._deneme_sinavi_bitir(p_deneme_id uuid) to service_role;
revoke execute on function public._kupon_kullanim(p_coupon uuid, p_veli uuid) from public, anon, authenticated, service_role;
grant  execute on function public._kupon_kullanim(p_coupon uuid, p_veli uuid) to service_role;
revoke execute on function public._uret_meydan_kod() from public, anon, authenticated, service_role;
grant  execute on function public._uret_meydan_kod() to anon;
grant  execute on function public._uret_meydan_kod() to authenticated;
grant  execute on function public._uret_meydan_kod() to service_role;
revoke execute on function public._veli_bagla_hata(p_veli uuid, p_mesaj text) from public, anon, authenticated, service_role;
grant  execute on function public._veli_bagla_hata(p_veli uuid, p_mesaj text) to service_role;
revoke execute on function public.exchange_auth_bridge_token(p_token text) from public, anon, authenticated, service_role;
grant  execute on function public.exchange_auth_bridge_token(p_token text) to anon;
grant  execute on function public.exchange_auth_bridge_token(p_token text) to authenticated;
grant  execute on function public.exchange_auth_bridge_token(p_token text) to service_role;
revoke execute on function public.finish_mock_exam_attempt(p_deneme_id uuid) from public, anon, authenticated, service_role;
grant  execute on function public.finish_mock_exam_attempt(p_deneme_id uuid) to authenticated;
grant  execute on function public.finish_mock_exam_attempt(p_deneme_id uuid) to service_role;
revoke execute on function public.get_mock_exam_result(p_exam_id uuid) from public, anon, authenticated, service_role;
grant  execute on function public.get_mock_exam_result(p_exam_id uuid) to authenticated;
grant  execute on function public.get_mock_exam_result(p_exam_id uuid) to service_role;
revoke execute on function public.get_my_mock_exam_status() from public, anon, authenticated, service_role;
grant  execute on function public.get_my_mock_exam_status() to authenticated;
grant  execute on function public.get_my_mock_exam_status() to service_role;
revoke execute on function public.get_next_mock_exam_public() from public, anon, authenticated, service_role;
grant  execute on function public.get_next_mock_exam_public() to anon;
grant  execute on function public.get_next_mock_exam_public() to authenticated;
grant  execute on function public.get_next_mock_exam_public() to service_role;
revoke execute on function public.get_upcoming_mock_exams_for_child(p_cocuk_id uuid) from public, anon, authenticated, service_role;
grant  execute on function public.get_upcoming_mock_exams_for_child(p_cocuk_id uuid) to authenticated;
grant  execute on function public.get_upcoming_mock_exams_for_child(p_cocuk_id uuid) to service_role;
revoke execute on function public.issue_auth_bridge_token(p_access_token text, p_refresh_token text) from public, anon, authenticated, service_role;
grant  execute on function public.issue_auth_bridge_token(p_access_token text, p_refresh_token text) to authenticated;
grant  execute on function public.issue_auth_bridge_token(p_access_token text, p_refresh_token text) to service_role;
revoke execute on function public.ogrenci_baglanti_kodu_olustur() from public, anon, authenticated, service_role;
grant  execute on function public.ogrenci_baglanti_kodu_olustur() to authenticated;
grant  execute on function public.ogrenci_baglanti_kodu_olustur() to service_role;
revoke execute on function public.register_for_mock_exam(p_exam_id uuid, p_cocuk_id uuid, p_telefon text, p_surum text) from public, anon, authenticated, service_role;
grant  execute on function public.register_for_mock_exam(p_exam_id uuid, p_cocuk_id uuid, p_telefon text, p_surum text) to authenticated;
grant  execute on function public.register_for_mock_exam(p_exam_id uuid, p_cocuk_id uuid, p_telefon text, p_surum text) to service_role;
revoke execute on function public.set_exam_marketing_consent(p_cocuk_id uuid, p_surum text) from public, anon, authenticated, service_role;
grant  execute on function public.set_exam_marketing_consent(p_cocuk_id uuid, p_surum text) to authenticated;
grant  execute on function public.set_exam_marketing_consent(p_cocuk_id uuid, p_surum text) to service_role;
revoke execute on function public.site_icerik_damga() from public, anon, authenticated, service_role;
grant  execute on function public.site_icerik_damga() to anon;
grant  execute on function public.site_icerik_damga() to authenticated;
grant  execute on function public.site_icerik_damga() to service_role;
revoke execute on function public.start_mock_exam_attempt(p_exam_id uuid) from public, anon, authenticated, service_role;
grant  execute on function public.start_mock_exam_attempt(p_exam_id uuid) to authenticated;
grant  execute on function public.start_mock_exam_attempt(p_exam_id uuid) to service_role;
revoke execute on function public.submit_mock_exam_answer(p_deneme_id uuid, p_question_id uuid, p_secilen_sik text) from public, anon, authenticated, service_role;
grant  execute on function public.submit_mock_exam_answer(p_deneme_id uuid, p_question_id uuid, p_secilen_sik text) to authenticated;
grant  execute on function public.submit_mock_exam_answer(p_deneme_id uuid, p_question_id uuid, p_secilen_sik text) to service_role;
revoke execute on function public.veli_cocuk_bagla(p_kod text) from public, anon, authenticated, service_role;
grant  execute on function public.veli_cocuk_bagla(p_kod text) to authenticated;
grant  execute on function public.veli_cocuk_bagla(p_kod text) to service_role;
revoke execute on function public.veli_cocuk_sayisi(p_veli uuid) from public, anon, authenticated, service_role;
grant  execute on function public.veli_cocuk_sayisi(p_veli uuid) to service_role;

-- 6) İndeksler
CREATE INDEX IF NOT EXISTS auth_bridge_tokens_expires_idx ON public.auth_bridge_tokens USING btree (expires_at);
CREATE UNIQUE INDEX IF NOT EXISTS ogrenci_baglanti_kodlari_aktif_kod_uq ON public.ogrenci_baglanti_kodlari USING btree (kod) WHERE (kullanildi_at IS NULL);
CREATE UNIQUE INDEX IF NOT EXISTS ogrenci_baglanti_kodlari_aktif_ogrenci_uq ON public.ogrenci_baglanti_kodlari USING btree (ogrenci_id) WHERE (kullanildi_at IS NULL);
CREATE INDEX IF NOT EXISTS veli_baglama_hatalari_veli_idx ON public.veli_baglama_hatalari USING btree (veli_id, created_at DESC);

-- 7) Triggerlar
drop trigger if exists site_icerik_damga on public.site_icerik;
CREATE TRIGGER site_icerik_damga BEFORE INSERT OR UPDATE ON public.site_icerik FOR EACH ROW EXECUTE FUNCTION site_icerik_damga();

-- 8) Politikalar (canlı pg_policies ile birebir)
drop policy if exists "carpim_ilerleme_select_own" on public.carpim_ilerleme;
create policy "carpim_ilerleme_select_own" on public.carpim_ilerleme as PERMISSIVE for SELECT to authenticated using ((user_id = ( SELECT auth.uid() AS uid)));
drop policy if exists "carpim_sifreleri_select" on public.carpim_sifreleri;
create policy "carpim_sifreleri_select" on public.carpim_sifreleri as PERMISSIVE for SELECT to authenticated using (true);
drop policy if exists "question_reports_select_own" on public.question_reports;
create policy "question_reports_select_own" on public.question_reports as PERMISSIVE for SELECT to authenticated using ((reporter_id = ( SELECT auth.uid() AS uid)));
drop policy if exists "site_icerik_oku" on public.site_icerik;
create policy "site_icerik_oku" on public.site_icerik as PERMISSIVE for SELECT to anon, authenticated using (true);
drop policy if exists "site_icerik_admin_sil" on public.site_icerik;
create policy "site_icerik_admin_sil" on public.site_icerik as PERMISSIVE for DELETE to authenticated using (( SELECT is_admin() AS is_admin));
drop policy if exists "site_icerik_admin_guncelle" on public.site_icerik;
create policy "site_icerik_admin_guncelle" on public.site_icerik as PERMISSIVE for UPDATE to authenticated using (( SELECT is_admin() AS is_admin)) with check (( SELECT is_admin() AS is_admin));
drop policy if exists "site_icerik_admin_ekle" on public.site_icerik;
create policy "site_icerik_admin_ekle" on public.site_icerik as PERMISSIVE for INSERT to authenticated with check (( SELECT is_admin() AS is_admin));

reset check_function_bodies;

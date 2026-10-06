-- =====================================================================
--  CRM derinleştirme: iletişim tercihleri (kanal bazlı izin), veli notları,
--  aile profili + zaman çizelgesi, gerekçeli dışa aktarma, denetim izi, ekip listesi
--  Proje : Hupo / Yönetim Merkezi  (Aşama B + F)
--  Tarih : 2026-10-07
--
--  NE EKLİYOR?
--    tablolar   : public.iletisim_tercihleri, public.iletisim_tercih_gecmisi,
--                 public.veli_notlari
--    veli RPC   : veli_tercihlerim, veli_tercih_ayarla   (izin geri çekme dahil)
--    admin RPC  : admin_veli_profil, admin_veli_not_ekle, admin_veli_tercih_ayarla,
--                 admin_export_aileler, admin_audit_listele, admin_ekip_listele
--
--  GÜVENLİK
--    * Tüm tablolar RLS açık + istemciye tüm yetki kapalı (fail-closed); yalnızca
--      SECURITY DEFINER RPC'ler okur/yazar (set search_path = '').
--    * KVKK: pazarlama izni kanal bazlıdır; her değişiklik iletisim_tercih_gecmisi'ne
--      (kim, ne zaman, kaynak, gerekçe) yazılır. Varsayılan = izin YOK.
--    * Admin izin değiştirirken GEREKÇE zorunludur; dışa aktarmada gerekçe + satır
--      sayısı denetim izine yazılır. PII denetim izi detayına yazılmaz.
--    * Çocuk hesaplarına iletişim tercihi tanımlanamaz (yalnızca rolü 'veli' olanlara).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Tablolar
-- ---------------------------------------------------------------------
create table if not exists public.iletisim_tercihleri (
  veli_id         uuid not null references public.profiles (id) on delete cascade,
  kanal           text not null,
  izin            boolean not null,
  kaynak          text not null default 'admin',
  guncelleyen_id  uuid references public.profiles (id) on delete set null,
  updated_at      timestamptz not null default now(),
  primary key (veli_id, kanal),
  constraint iletisim_tercihleri_kanal_check
    check (kanal in ('eposta', 'push', 'sms', 'uygulama_ici')),
  constraint iletisim_tercihleri_kaynak_check
    check (kaynak in ('veli', 'admin', 'web_form', 'sistem'))
);

create table if not exists public.iletisim_tercih_gecmisi (
  id              uuid primary key default gen_random_uuid(),
  veli_id         uuid not null references public.profiles (id) on delete cascade,
  kanal           text not null,
  izin            boolean not null,
  kaynak          text not null,
  guncelleyen_id  uuid references public.profiles (id) on delete set null,
  gerekce         text,
  created_at      timestamptz not null default now()
);
create index if not exists iletisim_tercih_gecmisi_veli_idx
  on public.iletisim_tercih_gecmisi (veli_id, created_at desc);

create table if not exists public.veli_notlari (
  id          uuid primary key default gen_random_uuid(),
  veli_id     uuid not null references public.profiles (id) on delete cascade,
  yazar_id    uuid references public.profiles (id) on delete set null,
  metin       text not null,
  created_at  timestamptz not null default now(),
  constraint veli_notlari_metin_uzunluk check (char_length(btrim(metin)) between 1 and 2000)
);
create index if not exists veli_notlari_veli_idx on public.veli_notlari (veli_id, created_at desc);

alter table public.iletisim_tercihleri     enable row level security;
alter table public.iletisim_tercih_gecmisi enable row level security;
alter table public.veli_notlari            enable row level security;

revoke all on table public.iletisim_tercihleri     from public, anon, authenticated;
revoke all on table public.iletisim_tercih_gecmisi from public, anon, authenticated;
revoke all on table public.veli_notlari            from public, anon, authenticated;

comment on table public.iletisim_tercihleri is
  'Veli başına kanal bazlı ticari iletişim izni. Satır yoksa izin YOKTUR. Yalnızca RPC yazar.';
comment on table public.iletisim_tercih_gecmisi is
  'İzin değişikliklerinin değiştirilemez kaydı (KVKK ispatı): kim, ne zaman, kaynak, gerekçe.';

-- ---------------------------------------------------------------------
-- 2. İç yardımcı: tercih yaz + geçmişe ekle (istemciye KAPALI)
-- ---------------------------------------------------------------------
create or replace function public._tercih_yaz(
  p_veli_id  uuid,
  p_kanal    text,
  p_izin     boolean,
  p_kaynak   text,
  p_actor    uuid,
  p_gerekce  text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if p_kanal not in ('eposta', 'push', 'sms', 'uygulama_ici') then
    raise exception 'Geçersiz kanal.' using errcode = '22023';
  end if;
  if not exists (select 1 from public.profiles where id = p_veli_id and role = 'veli') then
    raise exception 'Veli hesabı bulunamadı.' using errcode = 'P0002';
  end if;

  insert into public.iletisim_tercihleri (veli_id, kanal, izin, kaynak, guncelleyen_id, updated_at)
  values (p_veli_id, p_kanal, p_izin, p_kaynak, p_actor, now())
  on conflict (veli_id, kanal) do update
    set izin = excluded.izin, kaynak = excluded.kaynak,
        guncelleyen_id = excluded.guncelleyen_id, updated_at = now();

  insert into public.iletisim_tercih_gecmisi (veli_id, kanal, izin, kaynak, guncelleyen_id, gerekce)
  values (p_veli_id, p_kanal, p_izin, p_kaynak, p_actor, nullif(btrim(coalesce(p_gerekce, '')), ''));
end;
$function$;

revoke execute on function public._tercih_yaz(uuid, text, boolean, text, uuid, text)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. VELİ RPC — kendi tercihlerini görür / değiştirir (izin geri çekme)
-- ---------------------------------------------------------------------
create or replace function public.veli_tercihlerim()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_uid uuid := (select auth.uid());
  v_res jsonb;
begin
  if v_uid is null or not exists (select 1 from public.profiles where id = v_uid and role = 'veli') then
    raise exception 'Bu işlem yalnızca veli hesabı içindir.' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
           'kanal', k.kanal, 'izin', coalesce(t.izin, false), 'guncelleme', t.updated_at
         ) order by k.sira), '[]'::jsonb)
    into v_res
    from (values ('eposta', 1), ('push', 2), ('sms', 3), ('uygulama_ici', 4)) as k(kanal, sira)
    left join public.iletisim_tercihleri t on t.veli_id = v_uid and t.kanal = k.kanal;

  return v_res;
end;
$function$;

create or replace function public.veli_tercih_ayarla(p_kanal text, p_izin boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null or not exists (select 1 from public.profiles where id = v_uid and role = 'veli') then
    raise exception 'Bu işlem yalnızca veli hesabı içindir.' using errcode = '42501';
  end if;
  if p_izin is null then
    raise exception 'İzin değeri gerekli.' using errcode = '22023';
  end if;
  perform public._tercih_yaz(v_uid, p_kanal, p_izin, 'veli', v_uid, null);
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. ADMIN RPC — aile profili (çocuklar, abonelik, tercihler, notlar, zaman çizelgesi)
-- ---------------------------------------------------------------------
create or replace function public.admin_veli_profil(p_veli_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_veli     jsonb;
  v_cocuklar jsonb;
  v_abonelik jsonb;
  v_tercih   jsonb;
  v_notlar   jsonb;
  v_zaman    jsonb;
begin
  perform public.require_admin();

  select jsonb_build_object('id', p.id, 'ad', p.full_name, 'email', u.email, 'uyelik_tarihi', p.created_at)
    into v_veli
    from public.profiles p
    join auth.users u on u.id = p.id
   where p.id = p_veli_id and p.role = 'veli';
  if v_veli is null then
    raise exception 'Veli bulunamadı' using errcode = 'P0002';
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
           'id', c.id, 'ad', c.full_name, 'sinif', c.sinif, 'son_aktif', s.last_active_date
         ) order by c.created_at), '[]'::jsonb)
    into v_cocuklar
    from public.profiles c
    left join public.student_stats s on s.student_id = c.id
   where c.parent_id = p_veli_id;

  select to_jsonb(x) into v_abonelik
    from (
      select sb.plan_kod, pl.ad as plan_ad, sb.durum, sb.baslangic, sb.bitis
        from public.subscriptions sb
        join public.plans pl on pl.kod = sb.plan_kod
       where sb.veli_id = p_veli_id
       order by sb.created_at desc
       limit 1
    ) x;

  select coalesce(jsonb_agg(jsonb_build_object(
           'kanal', k.kanal, 'izin', coalesce(t.izin, false),
           'kaynak', t.kaynak, 'guncelleme', t.updated_at
         ) order by k.sira), '[]'::jsonb)
    into v_tercih
    from (values ('eposta', 1), ('push', 2), ('sms', 3), ('uygulama_ici', 4)) as k(kanal, sira)
    left join public.iletisim_tercihleri t on t.veli_id = p_veli_id and t.kanal = k.kanal;

  select coalesce(jsonb_agg(jsonb_build_object(
           'id', n.id, 'metin', n.metin, 'yazar', a.full_name, 'tarih', n.created_at
         ) order by n.created_at desc), '[]'::jsonb)
    into v_notlar
    from (
      select * from public.veli_notlari
       where veli_id = p_veli_id
       order by created_at desc
       limit 50
    ) n
    left join public.profiles a on a.id = n.yazar_id;

  select coalesce(jsonb_agg(to_jsonb(z) order by z.zaman desc), '[]'::jsonb)
    into v_zaman
    from (
      select 'kayit'::text as tur, p.created_at as zaman, '{}'::jsonb as detay
        from public.profiles p where p.id = p_veli_id
      union all
      select 'odeme', pa.created_at,
             jsonb_build_object('durum', pa.durum, 'tutar_kurus', pa.tutar_kurus)
        from public.payments pa where pa.veli_id = p_veli_id
      union all
      select 'islem', l.created_at, jsonb_build_object('islem', l.islem)
        from public.admin_audit_log l where l.detay ->> 'veli_id' = p_veli_id::text
      union all
      select 'tercih', h.created_at,
             jsonb_build_object('kanal', h.kanal, 'izin', h.izin, 'kaynak', h.kaynak)
        from public.iletisim_tercih_gecmisi h where h.veli_id = p_veli_id
      order by zaman desc
      limit 30
    ) z;

  return jsonb_build_object(
    'veli', v_veli, 'cocuklar', v_cocuklar, 'abonelik', v_abonelik,
    'tercihler', v_tercih, 'notlar', v_notlar, 'zaman_cizelgesi', v_zaman
  );
end;
$function$;

create or replace function public.admin_veli_not_ekle(p_veli_id uuid, p_metin text)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_metin text := btrim(coalesce(p_metin, ''));
begin
  perform public.require_admin();
  if char_length(v_metin) < 1 or char_length(v_metin) > 2000 then
    raise exception 'Not 1-2000 karakter olmalı.' using errcode = '22023';
  end if;
  if not exists (select 1 from public.profiles where id = p_veli_id and role = 'veli') then
    raise exception 'Veli bulunamadı' using errcode = 'P0002';
  end if;

  insert into public.veli_notlari (veli_id, yazar_id, metin)
  values (p_veli_id, (select auth.uid()), v_metin);

  -- Not metni (PII olabilir) denetim izine YAZILMAZ.
  perform public.log_admin_action('veli_notu_eklendi', jsonb_build_object('veli_id', p_veli_id));
end;
$function$;

create or replace function public.admin_veli_tercih_ayarla(
  p_veli_id  uuid,
  p_kanal    text,
  p_izin     boolean,
  p_gerekce  text
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_gerekce text := btrim(coalesce(p_gerekce, ''));
begin
  perform public.require_admin();
  if char_length(v_gerekce) < 5 then
    raise exception 'İzin değişikliği için gerekçe (en az 5 karakter) zorunludur.' using errcode = '22023';
  end if;
  if p_izin is null then
    raise exception 'İzin değeri gerekli.' using errcode = '22023';
  end if;

  perform public._tercih_yaz(p_veli_id, p_kanal, p_izin, 'admin', (select auth.uid()), v_gerekce);
  perform public.log_admin_action('iletisim_izni_degistirildi',
    jsonb_build_object('veli_id', p_veli_id, 'kanal', p_kanal, 'izin', p_izin));
end;
$function$;

-- ---------------------------------------------------------------------
-- 5. Gerekçeli dışa aktarma (veli listesi) — satır sayısı + gerekçe denetim izinde
-- ---------------------------------------------------------------------
create or replace function public.admin_export_aileler(
  p_arama    text default null,
  p_gerekce  text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_gerekce text := btrim(coalesce(p_gerekce, ''));
  v_arama   text := public.tr_normalize(nullif(btrim(coalesce(p_arama, '')), ''));
  v_rows    jsonb;
  v_adet    integer;
begin
  perform public.require_admin();
  if char_length(v_gerekce) < 10 then
    raise exception 'Dışa aktarma için gerekçe (en az 10 karakter) zorunludur.' using errcode = '22023';
  end if;

  select coalesce(jsonb_agg(to_jsonb(x) order by x.uyelik_tarihi desc), '[]'::jsonb), count(*)::integer
    into v_rows, v_adet
    from (
      select p.full_name as ad, u.email,
             coalesce((select pl.ad
                         from public.subscriptions sb
                         join public.plans pl on pl.kod = sb.plan_kod
                        where sb.veli_id = p.id and sb.durum = 'aktif' and sb.bitis > now()
                        order by sb.bitis desc limit 1), 'Free') as plan,
             (select count(*)::integer from public.profiles c where c.parent_id = p.id) as cocuk_sayisi,
             p.created_at as uyelik_tarihi
        from public.profiles p
        join auth.users u on u.id = p.id
       where p.role = 'veli'
         and (v_arama is null or public.tr_normalize(coalesce(p.full_name, '') || ' ' || coalesce(u.email, ''))
                                  like '%' || v_arama || '%')
       order by p.created_at desc
       limit 5000
    ) x;

  perform public.log_admin_action('aileler_disa_aktarildi',
    jsonb_build_object('adet', v_adet, 'gerekce', v_gerekce));

  return v_rows;
end;
$function$;

-- ---------------------------------------------------------------------
-- 6. Denetim izi listesi + ekip listesi
-- ---------------------------------------------------------------------
create or replace function public.admin_audit_listele(
  p_islem   text    default null,
  p_limit   integer default 25,
  p_offset  integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_islem  text := nullif(btrim(coalesce(p_islem, '')), '');
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();

  select count(*)::integer into v_toplam
    from public.admin_audit_log l
   where v_islem is null or l.islem = v_islem;

  select coalesce(jsonb_agg(to_jsonb(x) order by x.zaman desc, x.id), '[]'::jsonb) into v_satir
    from (
      select l.id, l.created_at as zaman, a.full_name as admin_ad, l.islem, l.detay
        from public.admin_audit_log l
        left join public.profiles a on a.id = l.admin_id
       where v_islem is null or l.islem = v_islem
       order by l.created_at desc, l.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$function$;

create or replace function public.admin_ekip_listele()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_res jsonb;
begin
  perform public.require_admin();

  select coalesce(jsonb_agg(to_jsonb(x) order by x.rol, x.ad), '[]'::jsonb) into v_res
    from (
      select p.id, p.role as rol, p.full_name as ad, u.email,
             (select max(l.created_at) from public.admin_audit_log l where l.admin_id = p.id) as son_islem,
             (select count(*)::integer from public.admin_audit_log l
               where l.admin_id = p.id and l.created_at > now() - interval '30 days') as islem_30_gun
        from public.profiles p
        join auth.users u on u.id = p.id
       where p.role in ('admin', 'ogretmen')
    ) x;

  return v_res;
end;
$function$;

-- ---------------------------------------------------------------------
-- 7. REVOKE / GRANT
-- ---------------------------------------------------------------------
revoke execute on function public.veli_tercihlerim()                       from public, anon;
revoke execute on function public.veli_tercih_ayarla(text, boolean)        from public, anon;
revoke execute on function public.admin_veli_profil(uuid)                  from public, anon;
revoke execute on function public.admin_veli_not_ekle(uuid, text)          from public, anon;
revoke execute on function public.admin_veli_tercih_ayarla(uuid, text, boolean, text) from public, anon;
revoke execute on function public.admin_export_aileler(text, text)         from public, anon;
revoke execute on function public.admin_audit_listele(text, integer, integer) from public, anon;
revoke execute on function public.admin_ekip_listele()                     from public, anon;

grant execute on function public.veli_tercihlerim()                       to authenticated;
grant execute on function public.veli_tercih_ayarla(text, boolean)        to authenticated;
grant execute on function public.admin_veli_profil(uuid)                  to authenticated;
grant execute on function public.admin_veli_not_ekle(uuid, text)          to authenticated;
grant execute on function public.admin_veli_tercih_ayarla(uuid, text, boolean, text) to authenticated;
grant execute on function public.admin_export_aileler(text, text)         to authenticated;
grant execute on function public.admin_audit_listele(text, integer, integer) to authenticated;
grant execute on function public.admin_ekip_listele()                     to authenticated;

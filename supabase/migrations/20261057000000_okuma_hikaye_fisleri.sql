-- =====================================================================
-- Okuma Dünyası — hikâye üretim fişleri (ilk 120 havuz, yalnız fiş katmanı)
--   * Fiş = üretim brifi (kurgu çekirdeği, sınıf bandı, söz varlığı, ikon önerisi, telif sınıfı).
--     Tam hikâye metni DEĞİL; bu tabloda metin alanı yoktur.
--   * İçe aktarma idempotent: fis_kodu (HR-001…) anahtarıdır, tekrar çalıştırmak kayıt çoğaltmaz.
--   * Yalnız brief_draft fişlerin içeriği içe aktarmayla güncellenir; onay ve telif alanları
--     içe aktarmayla değişmez.
--   * Kuru çalıştırma (p_kuru = true) hiçbir şey yazmaz; hatalı batch hiçbir şey yazmaz.
--   * Yönetim RPC'leri require_admin() ile başlar ve log_admin_action yazar.
-- =====================================================================

set client_encoding = 'UTF8';

create table if not exists public.okuma_hikaye_fisleri (
  id                    uuid primary key default gen_random_uuid(),
  fis_kodu              text not null unique check (fis_kodu ~ '^HR-[0-9]{3}$'),
  baslik                text not null check (char_length(baslik) between 2 and 120),
  sinif                 smallint not null check (sinif between 2 and 8),
  sinif_bandi           text not null check (sinif_bandi in ('2-4', '5-6', '7-8')),
  tur                   text not null check (char_length(tur) between 2 and 40),
  kurgu_cekirdegi       text not null check (char_length(kurgu_cekirdegi) between 20 and 400),
  soz_varligi           text check (char_length(soz_varligi) <= 300),
  bilgi_beceri_deger    text check (char_length(bilgi_beceri_deger) <= 300),
  ikon_onerileri        text[] not null default '{}',
  telif_sinifi          text not null check (telif_sinifi in ('O', 'A', 'K')),
  kaynak_sinifi         text not null check (char_length(kaynak_sinifi) between 2 and 300),
  telif_notu            text check (char_length(telif_notu) <= 600),
  -- Telif ve müfredat kapıları: A/K fişler hak onayı olmadan incelemeye girmez.
  hak_onayi             boolean not null default false,
  mufredat_onayi        boolean not null default false,
  durum                 text not null default 'brief_draft'
                        check (durum in ('brief_draft', 'metin_taslak', 'incelemede', 'arsiv')),
  check (durum <> 'incelemede' or telif_sinifi = 'O' or hak_onayi),
  olusturma             timestamptz not null default now(),
  guncelleme            timestamptz not null default now()
);

alter table public.okuma_hikaye_fisleri enable row level security;
revoke all on public.okuma_hikaye_fisleri from public, anon, authenticated;
create policy okuma_hikaye_fisleri_admin_select on public.okuma_hikaye_fisleri
  for select to authenticated using (public.is_admin());

-- ---------------------------------------------------------------------
-- 1. Doğrulama (iç; istemciye kapalı). Boş dönerse fiş geçerli.
-- ---------------------------------------------------------------------
create or replace function public._okuma_fis_hatasi(p jsonb)
returns text
language plpgsql
stable
set search_path = ''
as $$
declare
  v_anahtar text;
  v_bant    text;
begin
  if jsonb_typeof(p) is distinct from 'object' then return 'fiş nesne olmalı'; end if;

  for v_anahtar in select jsonb_object_keys(p) loop
    if v_anahtar not in ('fis_kodu', 'baslik', 'sinif', 'sinif_bandi', 'tur', 'kurgu_cekirdegi',
                         'soz_varligi', 'bilgi_beceri_deger', 'ikon_onerileri', 'telif_sinifi',
                         'kaynak_sinifi', 'telif_notu') then
      return 'bilinmeyen alan: ' || v_anahtar;
    end if;
  end loop;

  if not public._okuma_js_dizge(p -> 'fis_kodu', '^HR-[0-9]{3}$', 6, 6) then return 'fis_kodu HR-000 biçiminde olmalı'; end if;
  if not public._okuma_js_dizge(p -> 'baslik', null, 2, 120) then return 'baslik 2-120 karakter olmalı'; end if;
  if not public._okuma_js_tam(p -> 'sinif', 2, 8) then return 'sinif 2-8 tam sayı olmalı'; end if;
  if not public._okuma_js_enum(p -> 'sinif_bandi', array['2-4', '5-6', '7-8']) then return 'sinif_bandi 2-4, 5-6 veya 7-8 olmalı'; end if;
  v_bant := case when (p ->> 'sinif')::integer <= 4 then '2-4'
                 when (p ->> 'sinif')::integer <= 6 then '5-6'
                 else '7-8' end;
  if (p ->> 'sinif_bandi') <> v_bant then
    return 'sinif_bandi sınıfla uyuşmuyor';
  end if;
  if not public._okuma_js_dizge(p -> 'tur', null, 2, 40) then return 'tur 2-40 karakter olmalı'; end if;
  if not public._okuma_js_dizge(p -> 'kurgu_cekirdegi', null, 20, 400) then return 'kurgu_cekirdegi 20-400 karakter olmalı'; end if;
  if char_length(coalesce(p ->> 'soz_varligi', '')) > 300 then return 'soz_varligi en çok 300 karakter'; end if;
  if char_length(coalesce(p ->> 'bilgi_beceri_deger', '')) > 300 then return 'bilgi_beceri_deger en çok 300 karakter'; end if;
  if (p -> 'ikon_onerileri') is not null then
    if jsonb_typeof(p -> 'ikon_onerileri') <> 'array' then return 'ikon_onerileri dizi olmalı'; end if;
    if jsonb_array_length(p -> 'ikon_onerileri') > 12 then return 'ikon_onerileri en çok 12 öğe'; end if;
    if exists (select 1 from jsonb_array_elements(p -> 'ikon_onerileri') e where not public._okuma_js_dizge(e, null, 1, 40)) then
      return 'ikon_onerisi 1-40 karakter metin olmalı';
    end if;
  end if;
  if not public._okuma_js_enum(p -> 'telif_sinifi', array['O', 'A', 'K']) then return 'telif_sinifi O, A veya K olmalı'; end if;
  if not public._okuma_js_dizge(p -> 'kaynak_sinifi', null, 2, 300) then return 'kaynak_sinifi 2-300 karakter olmalı'; end if;
  if char_length(coalesce(p ->> 'telif_notu', '')) > 600 then return 'telif_notu en çok 600 karakter'; end if;

  return null;
end
$$;

-- ---------------------------------------------------------------------
-- 2. İçe aktarma (yönetim). Hatalı batch yazılmaz; sonuç her durumda döner.
-- ---------------------------------------------------------------------
create or replace function public.okuma_fis_ice_aktar(p_fisler jsonb, p_kuru boolean default true)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_f         jsonb;
  v_hata      text;
  v_sira      integer := 0;
  v_hatalar   jsonb := '[]'::jsonb;
  v_durum     text;
  v_eklenen   integer := 0;
  v_guncellen integer := 0;
  v_atlanan   integer := 0;
begin
  perform public.require_admin();

  if jsonb_typeof(p_fisler) is distinct from 'array' or jsonb_array_length(p_fisler) = 0 then
    raise exception 'BAD_FIS: en az bir fişlik dizi gerekli' using errcode = '22023';
  end if;
  if jsonb_array_length(p_fisler) > 200 then
    raise exception 'BAD_FIS: tek içe aktarmada en çok 200 fiş' using errcode = '22023';
  end if;

  -- Önce tüm batch doğrulanır.
  for v_f in select value from jsonb_array_elements(p_fisler) loop
    v_sira := v_sira + 1;
    v_hata := public._okuma_fis_hatasi(v_f);
    if v_hata is not null then
      v_hatalar := v_hatalar || jsonb_build_array(jsonb_build_object(
        'sira', v_sira, 'fis_kodu', case when jsonb_typeof(v_f) = 'object' then v_f ->> 'fis_kodu' end, 'hata', v_hata));
    end if;
  end loop;

  if v_hatalar <> '[]'::jsonb then
    return jsonb_build_object('ok', false, 'kuru', p_kuru, 'hatalar', v_hatalar);
  end if;

  -- Sayım (kuru ve gerçek çalıştırmada aynı).
  for v_f in select value from jsonb_array_elements(p_fisler) loop
    select f.durum into v_durum from public.okuma_hikaye_fisleri f where f.fis_kodu = v_f ->> 'fis_kodu';
    if not found then v_eklenen := v_eklenen + 1;
    elsif v_durum = 'brief_draft' then v_guncellen := v_guncellen + 1;
    else v_atlanan := v_atlanan + 1;
    end if;
  end loop;

  if not p_kuru then
    for v_f in select value from jsonb_array_elements(p_fisler) loop
      insert into public.okuma_hikaye_fisleri (
        fis_kodu, baslik, sinif, sinif_bandi, tur, kurgu_cekirdegi, soz_varligi, bilgi_beceri_deger,
        ikon_onerileri, telif_sinifi, kaynak_sinifi, telif_notu)
      values (
        v_f ->> 'fis_kodu', v_f ->> 'baslik', (v_f ->> 'sinif')::smallint, v_f ->> 'sinif_bandi',
        v_f ->> 'tur', v_f ->> 'kurgu_cekirdegi', v_f ->> 'soz_varligi', v_f ->> 'bilgi_beceri_deger',
        coalesce(array(select jsonb_array_elements_text(v_f -> 'ikon_onerileri')), '{}'::text[]),
        v_f ->> 'telif_sinifi', v_f ->> 'kaynak_sinifi', v_f ->> 'telif_notu')
      on conflict (fis_kodu) do update set
        baslik             = excluded.baslik,
        sinif              = excluded.sinif,
        sinif_bandi        = excluded.sinif_bandi,
        tur                = excluded.tur,
        kurgu_cekirdegi    = excluded.kurgu_cekirdegi,
        soz_varligi        = excluded.soz_varligi,
        bilgi_beceri_deger = excluded.bilgi_beceri_deger,
        ikon_onerileri     = excluded.ikon_onerileri,
        telif_sinifi       = excluded.telif_sinifi,
        kaynak_sinifi      = excluded.kaynak_sinifi,
        telif_notu         = excluded.telif_notu,
        guncelleme         = now()
      where public.okuma_hikaye_fisleri.durum = 'brief_draft';
    end loop;

    perform public.log_admin_action('okuma_fis_ice_aktar', jsonb_build_object(
      'eklenen', v_eklenen, 'guncellenen', v_guncellen, 'atlanan', v_atlanan, 'adet', jsonb_array_length(p_fisler)));
  end if;

  return jsonb_build_object('ok', true, 'kuru', p_kuru, 'eklenen', v_eklenen,
                            'guncellenen', v_guncellen, 'atlanan', v_atlanan);
end
$$;

-- ---------------------------------------------------------------------
-- 3. Listeleme (yönetim). Fiş kodu sırasıyla.
-- ---------------------------------------------------------------------
create or replace function public.okuma_fis_listele(p_durum text default null, p_sinif integer default null)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();
  return coalesce((
    select jsonb_agg(to_jsonb(f) - 'id' order by f.fis_kodu)
      from public.okuma_hikaye_fisleri f
     where (p_durum is null or f.durum = p_durum)
       and (p_sinif is null or f.sinif = p_sinif)
  ), '[]'::jsonb);
end
$$;

revoke execute on function public._okuma_fis_hatasi(jsonb) from public, anon, authenticated;
revoke execute on function public.okuma_fis_ice_aktar(jsonb, boolean) from public, anon;
revoke execute on function public.okuma_fis_listele(text, integer) from public, anon;
grant execute on function public.okuma_fis_ice_aktar(jsonb, boolean) to authenticated;
grant execute on function public.okuma_fis_listele(text, integer) to authenticated;

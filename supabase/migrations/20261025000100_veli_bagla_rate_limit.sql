-- veli_cocuk_bagla hız sınırı sıkılaştırması
-- Önceki: hesap başına saatte 5 başarısız deneme
-- Yeni:   hesap başına 15 dakikada 3 başarısız deneme
--
-- Gerekçe: bağlantı kodu 15 dakika geçerli, bu yüzden saatlik pencere çok geniş.
-- 15 dk'lık pencere kodun ömrüyle örtüşür; hesap çoğaltma saldırısında her hesap
-- 3 denemeyle sınırlı kalır. Kalıcı çözüm: Auth Dashboard'dan e-posta onayını aç (§11.4).

set client_encoding = 'UTF8';

create or replace function public.veli_cocuk_bagla(p_kod text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
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

  -- Hız sınırı: hesap başına 15 dakikada en fazla 3 başarısız deneme.
  -- (Kod ömrüyle örtüşür; e-posta onayı olmadan hesap çoğaltma riskini azaltır.)
  select count(*) into v_hata from public.veli_baglama_hatalari
   where veli_id = v_uid and created_at > now() - interval '15 minutes';
  if v_hata >= 3 then
    raise exception 'Çok fazla hatalı deneme yaptınız. Lütfen 15 dakika sonra tekrar deneyin.'
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
$$;

-- Mevcut yetkileri koru
revoke execute on function public.veli_cocuk_bagla(text) from public, anon;
grant  execute on function public.veli_cocuk_bagla(text) to authenticated;
grant  execute on function public.veli_cocuk_bagla(text) to service_role;

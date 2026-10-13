-- =====================================================================
-- İletişim kanalı genişletme: 'telefon' ekleme + kayıt triggerı 3 kanala çıkarma
--
-- 1. iletisim_tercihleri.kanal check constraint'e 'telefon' eklendi.
-- 2. _kayit_iletisim_izni: artık e-posta doğrulandığında
--    iletisim_eposta + iletisim_sms + iletisim_telefon metadata alanlarını
--    ayrı kanal girişleri olarak yazar. Her kanal yalnızca metadata'da
--    değer varsa yazılır (eski hesapları etkilemez).
-- =====================================================================

set client_encoding = 'UTF8';

-- 1. Kanal kısıtını genişlet
alter table public.iletisim_tercihleri
  drop constraint if exists iletisim_tercihleri_kanal_check;

alter table public.iletisim_tercihleri
  add constraint iletisim_tercihleri_kanal_check
    check (kanal in ('eposta', 'push', 'sms', 'telefon', 'uygulama_ici'));

-- 2. Trigger fonksiyonunu 3 kanala güncelle
create or replace function public._kayit_iletisim_izni()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_rol      text    := new.raw_user_meta_data ->> 'role';
  v_surum    text    := left(coalesce(new.raw_user_meta_data ->> 'iletisim_metin_surumu', 'bilinmiyor'), 60);
  v_eposta   text    := new.raw_user_meta_data ->> 'iletisim_eposta';
  v_sms      text    := new.raw_user_meta_data ->> 'iletisim_sms';
  v_telefon  text    := new.raw_user_meta_data ->> 'iletisim_telefon';
begin
  -- Yalnızca e-postası yeni doğrulanmış veli hesapları için
  if new.email_confirmed_at is null then return new; end if;
  if tg_op = 'UPDATE' and old.email_confirmed_at is not null then return new; end if;
  if v_rol is distinct from 'veli' then return new; end if;

  if v_eposta in ('true', 'false') then
    perform public._tercih_yaz(
      new.id, 'eposta', v_eposta = 'true', 'web_form', new.id,
      'kayıt formu; metin sürümü: ' || v_surum
    );
  end if;

  if v_sms in ('true', 'false') then
    perform public._tercih_yaz(
      new.id, 'sms', v_sms = 'true', 'web_form', new.id,
      'kayıt formu; metin sürümü: ' || v_surum
    );
  end if;

  if v_telefon in ('true', 'false') then
    perform public._tercih_yaz(
      new.id, 'telefon', v_telefon = 'true', 'web_form', new.id,
      'kayıt formu; metin sürümü: ' || v_surum
    );
  end if;

  return new;
end;
$$;

revoke execute on function public._kayit_iletisim_izni() from public, anon, authenticated;

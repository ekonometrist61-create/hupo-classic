-- =====================================================================
--  Veli kaydında isteğe bağlı "uygulama bildirimleri (push)" izni
--  Tarih : 2026-10-16
--  Ön koşul: 20261007000010 (_tercih_yaz, iletisim_tercihleri: kanal 'push' tanımlı),
--            20261015000000 (on_auth_user_created_iletisim trigger),
--            20261020000300 (_kayit_iletisim_izni, 3 kanal)
--
--  NE DEĞİŞİYOR?
--    * _kayit_iletisim_izni: auth metadata'daki iletisim_push alanı da okunur ve
--      iletisim_tercihleri'ne 'push' kanalı olarak yazılır.
--
--  KURALLAR
--    * Varsayılan İŞARETSİZ. Kutu işaretsizse form iletisim_push = false gönderir ve
--      diğer kanallarla aynı şekilde izin = false kaydı yazılır (açık ret kanıtı). Alan hiç
--      gelmezse (eski form sürümü) satır yazılmaz; bu durumda izin yoktur.
--    * Kayıt, pazarlama iznine BAĞLI DEĞİLDİR. Kutu boş bırakılarak kayıt olunabilir.
--    * Yalnızca rolü 'veli' olan hesaplar için yazılır (çocuk hesaplarına pazarlama izni tanımlanmaz).
--    * Metin sürümü (iletisim_metin_surumu) kayda yazılır; push metni yeni sürümle birlikte değişir.
-- =====================================================================

set client_encoding = 'UTF8';

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
  v_push     text    := new.raw_user_meta_data ->> 'iletisim_push';
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

  if v_push in ('true', 'false') then
    perform public._tercih_yaz(
      new.id, 'push', v_push = 'true', 'web_form', new.id,
      'kayıt formu; metin sürümü: ' || v_surum
    );
  end if;

  return new;
end;
$$;

revoke execute on function public._kayit_iletisim_izni() from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Düzeltme: _tercih_yaz 'telefon' kanalını reddediyordu.
--   20261020000300 kayıt trigger'ını 3 kanala çıkardı ve 'telefon' yazar; ama _tercih_yaz
--   (20261007000010) kanal listesinde 'telefon' yoktu. Sonuç: form her zaman iletisim_telefon
--   gönderdiği için e-posta onayı sırasında trigger "Geçersiz kanal." hatasıyla düşüyordu.
--   Kanal listesi iletisim_tercihleri CHECK'i ile eşitlendi. Gövde 20261007000010 ile aynıdır.
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
  if p_kanal not in ('eposta', 'push', 'sms', 'telefon', 'uygulama_ici') then
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

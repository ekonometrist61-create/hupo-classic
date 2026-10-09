-- =====================================================================
--  Ticari iletişim izni: kayıtta rıza + e-posta ile iptal + bastırma listesi
--  Tarih : 2026-10-09
--
--  NE EKLİYOR?
--    trigger    : _kayit_iletisim_izni  (auth.users)  — veli hesabı e-postasını
--                 doğruladığında kayıt formundaki ticari ileti rızasını yazar.
--    RPC (anon) : iletisim_izni_iptal_et(email)  — e-postadaki/sayfadaki iptal bağlantısı.
--    yardımcı   : ticari_iletisim_engelli_mi(email) — gönderim katmanı bunu çağırır.
--
--  KVKK NOTLARI
--    * Rıza, kutu işaretlenmiş olsa bile e-posta DOĞRULANMADAN yazılmaz. Böylece
--      başkasının adresiyle kayıt olup o kişi adına rıza işaretlenemez.
--    * Varsayılan = izin YOK. Rıza bir kez verilip geri alınabilir; her değişiklik
--      iletisim_tercih_gecmisi'ne (değiştirilemez) yazılır.
--    * Hesabı olmayan kişiler (aday/lead) için iptal, e-posta karmasıyla (sha256)
--      growth_prospect_suppressions'a yazılır: ham e-posta bastırma listesinde tutulmaz.
--      Bu kayıt süresiz tutulur (yeniden iletişimi önlemek için).
--    * Iptal RPC'si kimlik doğrulamasız çağrılabilir ama yalnızca izin KALDIRIR ve
--      her zaman aynı sonucu döndürür (hesabın var olup olmadığı sızmaz).
--
--  UYARI: Repoda henüz e-posta gönderen bir worker yok. Gönderim eklendiğinde her
--  alıcı için ticari_iletisim_engelli_mi(email) = false ve (veli ise)
--  iletisim_tercihleri.izin = true koşulu gönderim ANINDA yeniden kontrol edilmelidir.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Kayıt rızası: e-posta doğrulanınca yaz
-- ---------------------------------------------------------------------
create or replace function public._kayit_iletisim_izni()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_rol   text := new.raw_user_meta_data ->> 'role';
  v_izin  text := new.raw_user_meta_data ->> 'iletisim_eposta';
  v_surum text := left(coalesce(new.raw_user_meta_data ->> 'iletisim_metin_surumu', 'bilinmiyor'), 60);
begin
  -- Yalnızca e-postası doğrulanmış veli hesapları için (öğrenci hesaplarına ticari ileti yok).
  if new.email_confirmed_at is null then
    return new;
  end if;
  if tg_op = 'UPDATE' and old.email_confirmed_at is not null then
    return new;
  end if;
  -- Anahtar yoksa (v_izin null) rıza yazılmaz; NULL karşılaştırması da burada güvenli sayılır.
  if v_rol is distinct from 'veli' or v_izin is null or v_izin not in ('true', 'false') then
    return new;
  end if;

  perform public._tercih_yaz(
    new.id, 'eposta', v_izin = 'true', 'web_form', new.id,
    'kayıt formu rızası; metin sürümü: ' || v_surum
  );
  return new;
end;
$function$;

-- Ad, sıralama için: handle_new_user ('on_auth_user_created') önce çalışmalı (profil oluşsun).
drop trigger if exists on_auth_user_created_iletisim on auth.users;
create trigger on_auth_user_created_iletisim
  after insert or update of email_confirmed_at on auth.users
  for each row execute function public._kayit_iletisim_izni();

revoke execute on function public._kayit_iletisim_izni() from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Bastırma yardımcıları
-- ---------------------------------------------------------------------
create or replace function public._eposta_karmasi(p_email text)
returns text
language sql
immutable
set search_path = ''
as $function$
  select encode(sha256(convert_to(lower(btrim(coalesce(p_email, ''))), 'UTF8')), 'hex');
$function$;

revoke execute on function public._eposta_karmasi(text) from public, anon, authenticated;

-- Gönderim katmanı (service_role) bu fonksiyonla bastırılmış adresleri eler.
create or replace function public.ticari_iletisim_engelli_mi(p_email text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select exists (
    select 1
      from public.growth_prospect_suppressions s
     where s.email_hash = public._eposta_karmasi(p_email)
       and (s.channel is null or s.channel = 'eposta')
       and (s.expires_at is null or s.expires_at > now())
  );
$function$;

revoke execute on function public.ticari_iletisim_engelli_mi(text) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. İptal (kimlik doğrulamasız; her zaman aynı sonuç)
-- ---------------------------------------------------------------------
create or replace function public.iletisim_izni_iptal_et(
  p_email text,
  p_kanal text default 'eposta'
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_email text := lower(btrim(coalesce(p_email, '')));
  v_hash  text;
  v_veli  uuid;
begin
  if p_kanal is distinct from 'eposta' then
    raise exception 'Bu kanal için iptal desteklenmiyor.' using errcode = '22023';
  end if;
  if char_length(v_email) < 5 or char_length(v_email) > 254
     or v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'Geçerli bir e-posta adresi gir.' using errcode = '22023';
  end if;

  v_hash := public._eposta_karmasi(v_email);

  -- Hesabı olsun olmasın bu adrese bir daha ticari ileti gönderilmez.
  if not exists (
    select 1 from public.growth_prospect_suppressions s
     where s.email_hash = v_hash and s.channel = 'eposta' and s.reason = 'kullanici_iptali'
  ) then
    insert into public.growth_prospect_suppressions (email_hash, channel, reason, source)
    values (v_hash, 'eposta', 'kullanici_iptali', 'iptal_sayfasi');
  end if;

  -- Aday (lead) kaydındaki açık onayı kaldır.
  update public.veli_adaylari
     set pazarlama_izni = false, updated_at = now()
   where email = v_email and pazarlama_izni;

  -- Veli hesabı varsa kanal izni kaldırılır; geçmişe kaydedilir.
  select p.id into v_veli
    from public.profiles p
    join auth.users u on u.id = p.id
   where p.role = 'veli' and lower(u.email) = v_email
   limit 1;
  if v_veli is not null then
    perform public._tercih_yaz(v_veli, 'eposta', false, 'veli', v_veli, 'e-posta iptal bağlantısı');
  end if;
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. Yetkiler
-- ---------------------------------------------------------------------
revoke execute on function public.iletisim_izni_iptal_et(text, text) from public;
grant  execute on function public.iletisim_izni_iptal_et(text, text) to anon, authenticated;

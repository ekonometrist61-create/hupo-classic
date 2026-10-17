-- =====================================================================
--  Veli–çocuk eşleşme bildirimi, bağlı çocuk listesi ve bağlantı kaldırma
--  Tarih : 2026-10-17
--  Ön koşul: 20261016000000 (veli_eslestirme_kodu), 20261035000000 (notifications.kategori),
--            20260920000700 (notifications), 20260920000800 (consents), 20260920001000 (push)
--
--  NE DEĞİŞİYOR?
--    * eposta_outbox                    : e-posta kuyruğu. Adres burada tutulmaz; alıcı kimliği
--                                         tutulur, adres gönderim anında auth kullanıcısından okunur.
--    * bildirim_eposta_kuyrukla()       : iç yardımcı; e-posta satırı ekler.
--    * bildirim_gonder()                : iç tek giriş: uygulama kutusu + isteğe bağlı e-posta.
--    * cocuk_riza_durumu()              : iç yardımcı; 'verildi' | 'geri_cekildi' | 'bekliyor'.
--    * redeem_parent_link_code()        : bağlanınca veliye ve çocuğa bildirim (yeniden tanımlandı).
--    * veli_bagli_cocuklar()            : veli için bağlı çocuk listesi.
--    * veli_cocuk_baglantisini_kaldir() : veli bağlantıyı koparır; veri paylaşım onayı geri çekilir,
--                                         çocuğa ve veliye bildirim gider.
--
--  KANALLAR (hepsi aynı olaydan beslenir)
--    * Uygulama kutusu : her zaman yazılır (notifications). Web bildirim menüsünde görünür.
--    * Push            : notifications trigger'ı (enqueue_push) üzerinden. Opt-in, veli rızası ve
--                        sessiz saat kuralları geçerlidir. Push hattı henüz canlıda değil (GÖR-030).
--    * E-posta         : eposta_outbox'a yazılır; gönderim supabase/functions/eposta-gonder ile yapılır.
--                        Bunlar hesap işlemi bildirimidir (pazarlama değil); ticari ileti izni gerektirmez.
--
--  VERİ KORUMA
--    * Bağlantı kaldırılınca consents'e 'veli_riza_geri_cekildi' yazılır. Böylece sonradan bağlanan
--      başka bir veli öncekinin onayını devralmaz.
--    * Listede çocuğun e-posta ve telefonu yoktur: yalnızca ad, kullanıcı adı ve durum.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. E-posta kuyruğu (istemciye kapalı; yalnızca servis rolü ve tanımlayıcı fonksiyonlar)
-- ---------------------------------------------------------------------
create table if not exists public.eposta_outbox (
  id            uuid primary key default gen_random_uuid(),
  alici_id      uuid not null references public.profiles (id) on delete cascade,
  konu          text not null check (char_length(konu) between 1 and 200),
  govde         text not null check (char_length(govde) between 1 and 4000),
  durum         text not null default 'bekliyor'
                  check (durum in ('bekliyor', 'gonderildi', 'basarisiz')),
  deneme        integer not null default 0 check (deneme >= 0),
  son_hata      text,
  created_at    timestamptz not null default now(),
  gonderildi_at timestamptz
);

create index if not exists eposta_outbox_bekleyen_idx
  on public.eposta_outbox (created_at)
  where durum = 'bekliyor';

alter table public.eposta_outbox enable row level security;
revoke all on public.eposta_outbox from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. İç yardımcılar (istemciden çağrılamaz)
-- ---------------------------------------------------------------------
create or replace function public.bildirim_eposta_kuyrukla(
  p_alici uuid,
  p_konu  text,
  p_govde text
)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.eposta_outbox (alici_id, konu, govde)
  select p.id, left(p_konu, 200), left(p_govde, 4000)
    from public.profiles p
   where p.id = p_alici;
$$;

-- Tek giriş: uygulama kutusu (push trigger'ı bunun üzerinden çalışır) + isteğe bağlı e-posta.
create or replace function public.bildirim_gonder(
  p_alici  uuid,
  p_baslik text,
  p_mesaj  text,
  p_eposta boolean default false
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notifications (alici_id, tur, baslik, mesaj, ikon, kategori)
  values (p_alici, 'bilgi', p_baslik, p_mesaj, 'bell', 'sistem');

  if p_eposta then
    perform public.bildirim_eposta_kuyrukla(p_alici, p_baslik, p_mesaj);
  end if;
end;
$$;

-- Çocuğun veri paylaşım onay durumu. Yalnızca p_bagli_since (mevcut bağlantının zamanı) sonrasındaki
-- kayıtlara bakar: önceki velinin onayı ya da geri çekilmesi yeni veliye geçmez.
-- p_bagli_since null ise (yönetici bağlantısı, zaman kaydı yok) tüm kayıtlar değerlendirilir.
create or replace function public.cocuk_riza_durumu(
  p_cocuk_id    uuid,
  p_bagli_since timestamptz default null
)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select case c.tur
             when 'veli_acik_riza'         then 'verildi'
             when 'veli_riza_geri_cekildi' then 'geri_cekildi'
           end
      from public.consents c
     where c.cocuk_id = p_cocuk_id
       and c.tur in ('veli_acik_riza', 'veli_riza_geri_cekildi')
       and (p_bagli_since is null or c.created_at >= p_bagli_since)
     order by c.created_at desc
     limit 1
  ), 'bekliyor');
$$;

revoke execute on function public.bildirim_eposta_kuyrukla(uuid, text, text) from public, anon, authenticated;
revoke execute on function public.bildirim_gonder(uuid, text, text, boolean) from public, anon, authenticated;
revoke execute on function public.cocuk_riza_durumu(uuid, timestamptz) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. Eşleştirme: bağlanınca veliye ve çocuğa bildirim
--    (20261016000000 gövdesi aynen korunur; yalnızca bildirim çağrıları eklenir)
-- ---------------------------------------------------------------------
create or replace function public.redeem_parent_link_code(p_kod text)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid      uuid := auth.uid();
  v_role     text;
  v_parent   uuid;
  v_kod      text := upper(regexp_replace(coalesce(p_kod, ''), '[\s-]', '', 'g'));
  v_kayit    public.parent_link_codes%rowtype;
  v_veli_ad  text;
  v_cocuk_ad text;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;

  select role, parent_id into v_role, v_parent
    from public.profiles where id = v_uid;

  if v_role is distinct from 'ogrenci' then
    raise exception 'Bu kod yalnızca öğrenci hesabıyla kullanılabilir' using errcode = '42501';
  end if;
  if v_parent is not null then
    raise exception 'Hesabın zaten bir veliye bağlı' using errcode = 'P0001';
  end if;

  -- Hız sınırı: son 1 saatte 5 hatalı deneme
  if (select count(*) from public.parent_link_attempts
       where ogrenci_id = v_uid and denendi_at > now() - interval '1 hour') >= 5 then
    return jsonb_build_object('durum', 'cok_deneme');
  end if;

  select * into v_kayit
    from public.parent_link_codes
   where kod = v_kod
     and kullanildi_at is null
     and son_kullanma > now()
   for update;

  if not found then
    insert into public.parent_link_attempts (ogrenci_id) values (v_uid);
    return jsonb_build_object('durum', 'gecersiz');
  end if;

  perform set_config('app.parent_link_rpc', 'on', true);
  update public.profiles set parent_id = v_kayit.veli_id where id = v_uid;
  perform set_config('app.parent_link_rpc', 'off', true);

  update public.parent_link_codes
     set kullanildi_at = now(), kullanan_ogrenci_id = v_uid
   where kod = v_kayit.kod;

  delete from public.parent_link_attempts where ogrenci_id = v_uid;

  select full_name into v_veli_ad  from public.profiles where id = v_kayit.veli_id;
  select full_name into v_cocuk_ad from public.profiles where id = v_uid;

  -- Veli: kim bağlandı + veri paylaşım onayının gerektiği (e-posta dahil)
  perform public.bildirim_gonder(
    v_kayit.veli_id,
    'Çocuğunuz hesabını bağladı',
    coalesce(nullif(v_cocuk_ad, ''), 'Öğrenciniz')
      || ' Hupolingo hesabını veli hesabınıza bağladı. Çalışma bilgilerini görmek için'
      || ' veli panelindeki Çocuklarım sayfasından veri paylaşım onayını vermeniz gerekir.',
    true
  );

  -- Çocuk: kiminle bağlandı (veli onayı beklenir)
  perform public.bildirim_gonder(
    v_uid,
    'Veli hesabına bağlandın',
    coalesce(nullif(v_veli_ad, ''), 'Bir veli')
      || ' hesabına bağlandın. Veliniz çalışma bilgilerini görmeden önce onay verir.',
    false
  );

  return jsonb_build_object('durum', 'baglandi', 'veli_ad', v_veli_ad);
end;
$$;

revoke execute on function public.redeem_parent_link_code(text) from public, anon;
grant  execute on function public.redeem_parent_link_code(text) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Veli: bağlı çocuk listesi
--    Dönüş: [{ id, ad, kullanici_adi, baglandi_at, riza }]
--    baglandi_at null olabilir (yönetici tarafından bağlanan hesaplarda kayıt yoktur).
-- ---------------------------------------------------------------------
create or replace function public.veli_bagli_cocuklar()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_sonuc jsonb;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;
  if not exists (select 1 from public.profiles where id = v_uid and role = 'veli') then
    raise exception 'Bu liste yalnızca veli hesaplarına açıktır' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(
           jsonb_build_object(
             'id',            c.id,
             'ad',            c.full_name,
             'kullanici_adi', c.username,
             'baglandi_at',   b.kullanildi_at,
             'riza',          public.cocuk_riza_durumu(c.id, b.kullanildi_at)
           )
           order by c.full_name
         ), '[]'::jsonb)
    into v_sonuc
    from public.profiles c
    left join lateral (
      select pc.kullanildi_at
        from public.parent_link_codes pc
       where pc.kullanan_ogrenci_id = c.id
         and pc.kullanildi_at is not null
       order by pc.kullanildi_at desc
       limit 1
    ) b on true
   where c.parent_id = v_uid;

  return v_sonuc;
end;
$$;

-- ---------------------------------------------------------------------
-- 5. Veli: bağlantıyı kaldırma
--    profiles_guard_immutable zaten "parent_id'yi boşaltma" yetkisini veliye tanır
--    (old.parent_id = auth.uid()); bu yüzden bayrak gerekmez.
-- ---------------------------------------------------------------------
create or replace function public.veli_cocuk_baglantisini_kaldir(p_cocuk_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid      uuid := auth.uid();
  v_cocuk_ad text;
  v_veli_ad  text;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;

  select full_name into v_cocuk_ad
    from public.profiles
   where id = p_cocuk_id and parent_id = v_uid;

  if not found then
    raise exception 'Bu öğrenci hesabı size bağlı değil' using errcode = '42501';
  end if;

  update public.profiles set parent_id = null where id = p_cocuk_id;

  -- Onay geri çekilir: sonradan bağlanacak başka bir veli bu onayı devralmasın.
  insert into public.consents (cocuk_id, veli_id, tur, surum)
  values (p_cocuk_id, v_uid, 'veli_riza_geri_cekildi', 'baglanti_kaldirildi');

  select full_name into v_veli_ad from public.profiles where id = v_uid;

  perform public.bildirim_gonder(
    p_cocuk_id,
    'Veli bağlantısı kaldırıldı',
    coalesce(nullif(v_veli_ad, ''), 'Veliniz')
      || ' hesabınızla olan bağlantıyı kaldırdı. Yeniden bağlanmak için yeni bir kod gerekir.',
    false
  );

  perform public.bildirim_gonder(
    v_uid,
    'Çocuk bağlantısı kaldırıldı',
    coalesce(nullif(v_cocuk_ad, ''), 'Öğrenciniz')
      || ' ile bağlantı kaldırıldı. Bu öğrencinin çalışma bilgilerini artık göremezsiniz.',
    true
  );

  return jsonb_build_object('durum', 'kaldirildi');
end;
$$;

revoke execute on function public.veli_bagli_cocuklar() from public, anon;
grant  execute on function public.veli_bagli_cocuklar() to authenticated;
revoke execute on function public.veli_cocuk_baglantisini_kaldir(uuid) from public, anon;
grant  execute on function public.veli_cocuk_baglantisini_kaldir(uuid) to authenticated;

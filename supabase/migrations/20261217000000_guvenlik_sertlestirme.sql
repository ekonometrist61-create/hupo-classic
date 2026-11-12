-- =====================================================================
--  Güvenlik sertleştirme (K-0257: GÖR-098, GÖR-099, GÖR-103)
--  Tarih : 2026-11-12
--
--  NE YAPIYOR?
--    1. site-gorselleri kovası : image/svg+xml izni kaldırılır (SVG betik taşıyabilir;
--                                kovada SVG yok, 2026-11-12 katalog sorgusu: 0 nesne).
--    2. anon tablo yetkileri   : character_definitions, user_characters,
--                                identity_merge_candidates üzerindeki INSERT/UPDATE/DELETE/
--                                TRUNCATE/REFERENCES/TRIGGER geri alınır. RLS bu yazmaları
--                                zaten engelliyordu; tek savunma hattı kalmasın.
--                                character_definitions herkese açık okunmaya devam eder;
--                                user_characters (anon) ve identity_merge_candidates (anon +
--                                authenticated) SELECT'i de kapanır.
--    3. SMS tavanları          : telefon_dogrulama_kodlari'na her kod eklenişinde
--                                numara başına (1 saatte 3, 24 saatte 6) ve tüm proje için
--                                (24 saatte 500) sınır. Mevcut kullanıcı başına 10 dk sınırı
--                                telefon_kod_uret içinde aynen kalır.
--                                Sayaç ayrı tablodadır, çünkü telefon_kod_dogrula başarıda
--                                kullanıcının kod satırlarını siler (kod tablosu sayımı eksik
--                                kalırdı). Numara düz yazılmaz, SHA-256 özeti tutulur;
--                                kayıtlar 2 günden eski olunca silinir.
--                                Hata kodu P0001: telefon-kod-gonder bunu 429'a çevirir.
--
--  Geri alma: tetikleyiciyi düşür (drop trigger telefon_sms_tavan_kontrol ...);
--  kovaya SVG yeniden eklenmez.
-- =====================================================================

-- 1. Kova: SVG yok
update storage.buckets
   set allowed_mime_types = array['image/webp', 'image/png', 'image/jpeg']
 where id = 'site-gorselleri';

-- 2. anon yazma yetkileri
revoke insert, update, delete, truncate, references, trigger
  on public.character_definitions, public.user_characters, public.identity_merge_candidates
  from anon;

-- Okuma da kapanır (GÖR-107 bulgu 3): anon bu iki tablodan hiçbir şey görmemeli; birleştirme
-- adaylarını yalnız admin RPC'leri okur (istemci tabloyu doğrudan okumuyor, 2026-11-12 tarandı).
-- user_characters'ı öğrenci kendi oturumuyla okumaya devam eder.
revoke select on public.user_characters from anon;
revoke select on public.identity_merge_candidates from anon, authenticated;

-- 3. SMS tavanları
create table if not exists public.telefon_sms_gunlugu (
  id           bigint generated always as identity primary key,
  telefon_ozet text        not null,
  olusturma    timestamptz not null default now()
);

create index if not exists telefon_sms_gunlugu_ozet
  on public.telefon_sms_gunlugu (telefon_ozet, olusturma desc);
create index if not exists telefon_sms_gunlugu_zaman
  on public.telefon_sms_gunlugu (olusturma);

-- Politika yok: yalnızca aşağıdaki security definer tetikleyici erişir.
alter table public.telefon_sms_gunlugu enable row level security;
revoke all on public.telefon_sms_gunlugu from public, anon, authenticated;

create or replace function public.telefon_sms_tavan_kontrol()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_ozet    text := encode(extensions.digest(coalesce(new.telefon, ''), 'sha256'), 'hex');
  v_saat    int;
  v_gun     int;
  v_toplam  int;
begin
  delete from public.telefon_sms_gunlugu where olusturma < now() - interval '2 days';

  select count(*) filter (where olusturma > now() - interval '1 hour'),
         count(*)
    into v_saat, v_gun
    from public.telefon_sms_gunlugu
   where telefon_ozet = v_ozet
     and olusturma > now() - interval '24 hours';

  if v_saat >= 3 or v_gun >= 6 then
    raise exception 'Bu numaraya çok fazla kod istendi. Lütfen daha sonra tekrar deneyin'
      using errcode = 'P0001';
  end if;

  select count(*) into v_toplam
    from public.telefon_sms_gunlugu
   where olusturma > now() - interval '24 hours';

  if v_toplam >= 500 then
    raise exception 'Doğrulama SMS''i şu an gönderilemiyor. Lütfen daha sonra tekrar deneyin'
      using errcode = 'P0001';
  end if;

  insert into public.telefon_sms_gunlugu (telefon_ozet) values (v_ozet);
  return new;
end;
$$;

revoke execute on function public.telefon_sms_tavan_kontrol() from public, anon, authenticated;

drop trigger if exists telefon_sms_tavan_kontrol on public.telefon_dogrulama_kodlari;
create trigger telefon_sms_tavan_kontrol
  before insert on public.telefon_dogrulama_kodlari
  for each row execute function public.telefon_sms_tavan_kontrol();

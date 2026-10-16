-- =====================================================================
--  Anket yayın mecraları: web_sitesi kaldırılıyor
--  Proje : Hupo / Yönetim Merkezi
--  Tarih : 2026-10-16
--  Ön koşul: 20261029000000 (anketler.yuzeyler)
--  Karar : docs/hupo-design-growth/ANKET_SISTEMI_MIMARI.md §1 (web sitesi anket yüzeyi kaldırıldı)
--
--  NE DEĞİŞİYOR?
--    * anketler.yuzeyler: web_sitesi değeri temizlenir; kısıt yalnız
--      mobil, web_app, veli_paneli kabul eder.
--
--  NE DEĞİŞMİYOR?
--    * duyurular.yuzeyler: web_sitesi duyuru şeridi için kalır (ayrı tablo, ayrı kısıt).
--    * anket_yanitlari.yuzey: geçmiş yanıtlar olduğu gibi kalır (kısıt web_sitesi'ni kabul etmeye devam eder).
--    * anket_aktif_listem / anket_yanit_gonder: p_yuzey = 'web_sitesi' hâlâ kabul edilir.
--      Eski bir istemci (önceki landing bundle'ı) hata almaz; web_sitesi'ni içeren anket
--      kalmadığı için boş liste / P0002 döner.
--
--  VERİ GÜVENLİĞİ
--    * Yalnız web_sitesi içeren (başka mecrası olmayan) anket varsa migration DURUR.
--      Böyle bir anketin hangi mecraya taşınacağı bir insan kararıdır; sessizce
--      veli_paneli'ne atanmaz.
--    * web_sitesi + başka mecra içeren anketlerde yalnız web_sitesi düşer.
--    * Anket silinmez, arşivlenmez, sürümü değişmez (yüzey içerik değildir).
-- =====================================================================

set client_encoding = 'UTF8';

-- 1. Güvence: yalnız web_sitesi içeren anket var mı? Varsa dur.
do $$
declare
  v_n integer;
begin
  select count(*) into v_n
    from public.anketler
   where 'web_sitesi' = any (yuzeyler)
     and cardinality(array_remove(yuzeyler, 'web_sitesi')) = 0;
  if v_n > 0 then
    raise exception 'web_sitesi dışında yayın mecrası olmayan % anket var; önce yönetim panelinden mecra seçilmeli', v_n
      using errcode = '23514';
  end if;
end
$$;

-- 2. Veri: web_sitesi, başka mecra varken düşer.
update public.anketler
   set yuzeyler = array_remove(yuzeyler, 'web_sitesi'),
       updated_at = now()
 where 'web_sitesi' = any (yuzeyler);

-- 3. Kısıt: web_sitesi artık anket mecrası değil.
alter table public.anketler drop constraint if exists anketler_yuzeyler;
alter table public.anketler add constraint anketler_yuzeyler check (
  cardinality(yuzeyler) between 1 and 3
  and yuzeyler <@ array['mobil', 'web_app', 'veli_paneli']::text[]
);

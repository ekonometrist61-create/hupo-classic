-- =====================================================================
--  P3b · TOHUM KARAR KAYITLARI: mevcut matristen modul_paket_karar türet
--  Tarih : 2026-10-29
--  Tasarım: docs/paketler/ESNEK_PAKET_VE_ODEME_MIMARISI.md §3
--  Ön koşul: 20261130 (P1 matris), 20261131 (P2 modul_paket_karar), 20261134 (ücretsiz matris)
--
--  NEDEN?
--    P1 tohumu modülleri ve paketleri paket_modul matrisiyle ekledi ama modul_paket_karar'a
--    karar satırı yazmadı. Bu yüzden admin_modul_etki_onizleme her modül için "karar eksik"
--    diyordu. Bu migration mevcut matrisi karar kaydına çevirir; matrisin kendisi değişmez.
--
--  KURALLAR (her etkin paket × yayındaki modül için bir satır)
--    * Kapsam: yalnız paketler.durum <> 'arsiv' ve moduller.durum = 'yayinda'.
--    * paket_modul erisim 'tam'      → karar 'dahil',   erisim 'tam',     kota = matristeki değer
--    * paket_modul erisim 'sinirli'  → karar 'sinirli', erisim 'sinirli', kota = matristeki değer
--    * satır yok / 'yok' / 'onizleme'→ karar 'haric',   erisim NULL,      kota NULL
--    * mevcut_aboneleri_kapsar = false, karar_veren = NULL,
--      gerekce = 'İlk kurulum: mevcut matristen türetildi'.
--    * İdempotent: on conflict (modul_kod, paket_kod) do nothing. Yönetici kararları ezilmez.
--
--  ETKİ (YALNIZ EKLEME)
--    paket_modul, paket_surum ve abonelik sürümleri DEĞİŞMEZ; erişim davranışı aynı kalır.
--    Yalnız karar tablosu dolar: yönetim panelinde "karar eksik" uyarısı kalkar.
--  Rollback: delete from public.modul_paket_karar
--             where gerekce = 'İlk kurulum: mevcut matristen türetildi' and karar_veren is null;
-- =====================================================================

insert into public.modul_paket_karar
  (modul_kod, paket_kod, karar, erisim, gunluk_kota, mevcut_aboneleri_kapsar, gerekce, karar_veren)
select
  m.kod,
  p.kod,
  case pm.erisim when 'tam' then 'dahil' when 'sinirli' then 'sinirli' else 'haric' end,
  case pm.erisim when 'tam' then 'tam' when 'sinirli' then 'sinirli' else null end,
  case when pm.erisim in ('tam', 'sinirli') then pm.gunluk_kota else null end,
  false,
  'İlk kurulum: mevcut matristen türetildi',
  null
from public.moduller m
cross join public.paketler p
left join public.paket_modul pm
       on pm.modul_kod = m.kod and pm.paket_kod = p.kod
where m.durum = 'yayinda'
  and p.durum <> 'arsiv'
on conflict (modul_kod, paket_kod) do nothing;

-- =====================================================================
--  Kampanya listesi aşırı yükleme (overload) çakışmasını gider.
--  Tarih : 2026-10-14
--
--  SORUN
--    public.admin_kampanya_listele() (20261007000020) — Yönetim Merkezi ekranı
--      (iletisim_kampanyalari tablosu, CampaignsManager.tsx) bunu argümansız çağırır.
--    public.admin_kampanya_listele(text, int, int) (20261014000200) — growth_campaigns
--      tablosunu okur. Uygulamada çağıran yok; yalnızca tanımlı.
--    Her iki imza da argümansız çağrılabildiği için "function ... is not unique"
--    (42725) oluşur ve PostgREST'te de belirsizlik (PGRST203) doğurur.
--
--  ÇÖZÜM
--    Eski sürüm DROP EDİLMEZ: Yönetim Merkezi kampanya ekranı onu kullanıyor ve farklı bir
--    tabloyu okuyor. Bunun yerine growth sürümü yeni bir ada taşınır. Gövde ve yetkiler
--    (grant/revoke) ALTER ... RENAME ile olduğu gibi korunur.
--    Çağıran yalnızca bu migration ile yeni adı kullanmalı: admin_growth_kampanya_listele.
-- =====================================================================

alter function public.admin_kampanya_listele(text, int, int)
  rename to admin_growth_kampanya_listele;

comment on function public.admin_growth_kampanya_listele(text, int, int) is
  'Growth kampanyalarını (growth_campaigns) sayfalı listeler. Yalnızca yönetici.';

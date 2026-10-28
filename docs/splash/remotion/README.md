# Hupo Uyanır: hareket önizleme (Remotion)

Açılış senaryosunun ([../ACILIS_SENARYOSU_PLANI.md](../ACILIS_SENARYOSU_PLANI.md) §3.1) zamanlama önizlemesi.
**Flutter uygulaması değildir**: Faz 4'te Flutter'da yeniden kurulacak sahnenin onay ve zamanlama referansıdır.
Katmanlar `mobile-app/assets/hupo/splash/` içindeki `hupo_govde`, `hupo_kanat`, `hupo_goz_kapali` dosyalarıdır
(`public/` klasörüne kopyalanır; bu klasöre konmadı, tekrar kopyalamamak için).

- Kompozisyon: `HupoUyanir`, 1080×1920, 30 fps, 96 kare (3,2 sn).
- Zaman çizelgesi (kare): 0–12 uyku · 12 gözler açılır, 20–22 kırpma · 10–34 büyüme ve yerleşme, 14–26 sıçrama ·
  24–54 kanat selamı (−4°…+6°) · 26–46 altın yay · 38+ marka adı (harf harf) · 62+ konuşma balonu.
- Çıktı: `../uretim-2026-10-28/hupo-uyanir-onizleme.mp4`.

## Güncel: `HupoGelir` (kullanıcı isteğiyle tüm vücut uçuşu)
1080×1920, 30 fps, 132 kare (4,4 sn). Akış: plan §3.1b. Katman dosyaları (`public/` içine kopyalanır):
`hupo_govde_kanatsiz`, `hupo_kanat_sag`, `hupo_kanat_sol`, `hupo_goz_mutlu`, `hupo_goz_kapali` (`.webp`, `mobile-app/assets/hupo/splash/`).
Render: `npx remotion render src/index.ts HupoGelir out/hupo_gelir.mp4 --public-dir=public --codec=h264`.
Çıktı: `../uretim-2026-10-28/hupo-gelir-onizleme.mp4`. `HupoUyanir` ilk (kanat selamı) senaryo olarak kalır.

## Nasıl render edilir
Remotion CLI ve Chrome içeren herhangi bir ortamda:
```
mkdir public && cp ../../../mobile-app/assets/hupo/splash/hupo_{govde,kanat,goz_kapali}.webp public/
npx remotion render src/index.ts HupoUyanir out/hupo_uyanir.mp4 --public-dir=public --codec=h264
```
28 Ekim 2026'da Oracle ücretsiz sunucusunda, mevcut `video-studio-render` Docker imajından tek seferlik kapsayıcıyla
(`--cpus=2 --memory=4g`) render edildi; çalışan hizmetlere ve `video-studio` deposuna dokunulmadı.
Yazı tipi: Nunito (`@remotion/google-fonts`; render sırasında ağ gerekir).
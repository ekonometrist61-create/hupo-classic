# Hupo tasarım kararları
Bu dosya yeni, doğrulanmış proje kararları içindir. Paket önerileri kullanıcı onayı verilmiş kararlar değildir.

| Tarih | Karar | Kullanıcı faydası / gerekçe | Kaynak ve durum | Etkilenen ekran/dosya |
|---|---|---|---|---|
| 2026-10-06 | İlk dalga kapsamı: yalnız web landing sayfası (+ gerçek `/demo`) | Mevcut landing beğenilmedi; en görünür satış yüzeyi önce düzeltilir | Kullanıcı onayı (oturum) — ONAYLI | `web-panel/.../(full-width-pages)/page.tsx` |
| 2026-10-06 | Ana UI rengi Learning Teal `#147D8A`; Hupo Gold `#F5C842` yalnız maskot/XP/ödül | Kit önerisi + web zaten teal; Hupo paletiyle uyumlu | Kullanıcı onayı (oturum) — ONAYLI | `web-panel/src/app/globals.css` |
| 2026-10-06 | Mobil menekşe `#6C4DF6` → teal geçişi bu dalgada YAPILMAZ | Çalışan uygulamaya dokunmadan önce ayrı onay | ERTELENDİ | `mobile-app/lib/theme/app_theme.dart` |
| 2026-10-06 | **Marka adı Hupolingo** (maskot Hupo). Web: `landing.brand` + meta; mobil: `android:label`, iOS `CFBundleDisplayName`, `MaterialApp.title`. Paket kimlikleri (`com.ogrencihazirlik...`) DEĞİŞMEDİ | Kullanıcı onayı | ONAYLI — UYGULANDI | landing, demo, mobil |
| 2026-10-06 | **Mobil tema web ile birleşti:** primary Teal #147D8A, Hupo Gold #F5C842 (XP/ödül), zemin Cream #FFF9ED, metin Navy #17324D; yanlış/tekrar = amber (kırmızı değil). Karakter sınıf renkleri aynı kaldı | Kurumsal kimlik tek palet | Kullanıcı onayı — UYGULANDI | `mobile-app/lib/theme/app_theme.dart` |
| 2026-10-06 | Mobilde Hupo görselleri şeffaf WebP (rembg); eski 20 PNG `assets_arsiv/` altına taşındı (silinmedi, pakete girmiyor) | AGENTS.md assets silinmez kuralı | UYGULANDI | `assets/hupo/**`, `hupo_pose.dart` |
| 2026-10-06 | **100 soru (Türkçe, Fen, Sosyal, Din Kültürü, İngilizce) + Matematik'in 50 seed sorusu `onaylandi` yüklenir.** Kaynak/sınav yılı/okul adı DOĞRULANMADI (`taslak_ornek`); çıkmış sınav sorusu olarak sunulmaz. Sorumluluk ürün sahibinde; her dersten rastgele 5 madde cevap anahtarı elle yeniden doğrulandı (25/25 doğru) | Uygulamada soru görünmüyordu (hepsi 'beklemede') | Kullanıcı kararı — migration hazır, **uzak DB'ye uygulanmadı** | `supabase/migrations/20261006030000_soru_bankasi_5_ders_onayli.sql` |
| 2026-10-06 | Hata dayanıklılığı: `student_stats` sorgusu `aktif_karakter` sütunu yoksa (42703) onsuz yeniden denenir; `submit_answer` yeni imza yoksa (PGRST202) eski imzayla denenir | Migration'lar uzak DB'ye uygulanana kadar uygulama bozulmasın | UYGULANDI | `quiz_repository.dart` |
| 2026-10-06 | Landing CTA'ları gerçek `/demo` + `/signup`; "hesap gerekmez" yalnız demo için ve doğru | Önce `/ogrenci/soru` girişsiz `/signin`'e atıyordu (yanlış vaat); `/demo` artık girişsiz, ağ/depolama kullanmıyor | Doğrulandı (CDP testi 25/25) — UYGULANDI | landing, `/demo` |
| 2026-10-06 | Landing'de fiyat/deneme süresi/kota YOK; "Ücretli plan hazırlık aşamasında" | `plans` tablosu anon'a kapalı (RLS) ve onaylı fiyat yok; önceki ₺49/₺99 ve "7 gün ücretsiz" i18n'den uydurmaydı | Repo doğrulaması — UYGULANDI | landing `plans` bölümü |
| 2026-10-06 | Halka açık yüzeylerde (landing, demo) Nunito + Hupo master pozları (şeffaf WebP); panel fontu Outfit kalır (latin-ext eklendi) | Türkçe karakter desteği + çocuk/veli dostu sıcaklık | UYGULANDI | `marketingFont.ts`, `public/hupo/` |
| 2026-10-06 | Karşılama ekranı (WelcomeSplash) yalnız panel layout'larında; halka açık sayfalarda yok | TailAdmin logosu ve "devam edelim" metni ilk ziyaretçiyi karşılıyordu | UYGULANDI | `(admin)/layout`, `(student)/layout` |
| 2026-10-06 | Demo soruları `soru-bankasi` taslak_ornek içeriğinden 5 adet; seçenek sırası harf dağılımı için değiştirildi | "Örnek" etiketi ve "resmî sınav sorusu değildir" notu ile sunulur | Cevap anahtarları tek tek yeniden doğrulandı; **kullanıcı onayı bekliyor** | `demoQuestions.ts` |

## Paket ile repo çelişkileri
- **Renk:** Kit "Leaf Green #6DA940" önceki kimlik referansı olarak anıyor; repo mobil tokenları `mint #22C58B`, `sun #FFC533`, `primary #6C4DF6`. Repo tokenları esas; kit'in Gold `#F5C842` ile mobil `sun #FFC533` birbirine yakın, birleştirme mobil dalgasında karara bağlanacak.
- **Karakter adları:** Repo `assets/characters/bozkir/*` (Bozkır İzci/Reisi…) kullanıyor; kit 35 adı yeniden tanımlamıyor. Repo tablosu yetkili.
- **Bileşen adları:** Kit'teki `HupoButton`, `HupoXPBar` vb. Flutter/TailAdmin kodunda yok; yeniden adlandırma yapılmaz.
- **AGENTS.md §0 "alt ajan yok":** Tasarım/büyüme için kurulu proje agent'ı ile istisna olarak not düşüldü.
- **MASTER_BRIEF.md:** Eski OneDrive yolu geçersiz (proje `C:\Dev\hupo`).
- **Gizli anahtarlar:** `.claude/settings.json` ve `.claude/mcp.json` düz metin API anahtarı içeriyordu; anahtarlar `settings.local.json`'a taşındı / `${DEGISKEN}` referansına çevrildi. Anahtarlar git geçmişinde kaldığı için **döndürülmeli** (kullanıcı eylemi).

Repo ile paket arasındaki çelişkileri burada kısa kaydet; fiyat, karakter adı ve onaylı asset bilgilerini kaynaksız kalıcılaştırma.

# Yüzeyler arası uyum planı (2026-10-22)

Kalıcı ilke: mobil app, Flutter web, halka açık site, yönetim, veli ve öğretmen panelleri arasında tam uyum. Bir yüzeyde yapılan değişiklik diğerlerini de günceller.

Durum: doğrulanan bulgular aşağıda; ajan envanteri API oturum sınırı nedeniyle tamamlanamadı (sınır 04:40'ta sıfırlandı). Bu belge o eksiği kapatmak için kısmi bir başlangıçtır.

## 1. Doğrulanan bulgular

| Konu | Mevcut | Eksik |
|---|---|---|
| Genel bayrak | Açıldı (20261063), herkes için modül görünür | Katalogda yayında hikâye yok; hikâyeler taslak |
| Veli özeti (`okuma_veli_ozeti`) | okunan/tamamlanan hikâye, ort. süre, soru doğruluğu (beceri bazında), tema, değer, ders, zorluk seyri, hedef durumları | Okunan kelime sayısı; kavram listesi (hedef adları) yok; yeni tür etiketleri yok |
| Öğretmen özeti (`okuma_ogretmen_sinif_ozeti`) | RPC var | Kapsamı ve alanları henüz denetlenmedi |
| Yönetim paneli | Liste (`okuma_yonetim_liste`), karne, boşluk haritası, yüklemek (`okuma_paket_ice_aktar`), durum değiştirme (`okuma_surum_durum_degistir`) | Düzenleme, düzeltme, silme yok; genel istatistik panosu yok |
| Kullanım süresi | Mobilde analitik altyapısı yok (`env.dart` yalnız yapılandırma). Web panelde `AnalyticsProvider.tsx` var | Mobil, Flutter web, site ve paneller için ekran süresi takibi yok |
| Tür etiketleri | Mobil: 12 tür etiketi (yeni 7 dahil) | Web paneller ve site yeni türleri tanımıyor |
| Sahne görselleri | Mobilde 30 görsel, `OkumaSahne` yükleniyor | Yönetim panelinde görsel yönetimi yok (Faz 2) |

## 2. Fazlar

**Faz A — Yönetim CRUD (hikâye yönetimi).**
- Yeni RPC'ler: düzenleme (yayındaki sürüm değişmez, yeni taslak sürüm), düzeltme (taslak içinde), arşivleme, silme (yalnız oturumu olmayan taslak/arşiv).
- Dört göz kuralı ve `log_admin_action` kaydı. PGlite testleri.
- Yönetim paneline arayüz ve genel istatistik panosu (yayında hikâye sayısı, toplam okuma, tamamlama oranı, ortalama doğruluk).

**Faz B — Veli ve öğretmen dashboard'u.**
- Veli özetine: okunan kelime sayısı, öğrenilen kavramların adları, tür dağılımı.
- Öğretmen özetini bu alanlarla hizala; min-N ve rıza kuralları korunur.
- Web panellerde tür etiketlerini 12 tür için tanımla.

**Faz C — Kullanım süresi analitiği.**
- Ortak olay şeması: yüzey, ekran, süre_sn, anonim oturum kimliği (çocuk kimliği yok).
- Flutter: uygulama arka plana gidince oturum kapanır; boşta süre sayılmaz.
- Web ve site: sayfa görünürlüğüne göre süre.
- Yönetim raporu: yüzey × ekran × süre; min-N bastırma.
- KVKK ve rıza kararları (saklama süresi, çocuk verisi) kullanıcıya sorulacak.

**Faz D — Site ve tutarlılık.** Halka açık sitede tür, kavram ve süre bilgisini kaynak veriden göster; eksik alanları sabit metinle değil veriyle doldur.

## 3. Karar bekleyen konular

1. Yayın: test için en az kaç hikâye yayınlansın? Yayın için denetim ve insan onayı gerekiyor; onaylar sizde.
2. Kullanım süresi verisinin saklama süresi (önerim: 90 gün, toplu özetler daha uzun).
3. Öğretmenin hangi çocuk verisini görebileceği (önerim: yalnız sınıf toplulaştırması, bireysel veri yok).
4. Faz sırası: önerim A → B → C → D.

## 4. Bu turda yapılmayanlar

- Yeni 15 hikâye, uyum planı netleşene kadar bekletildi.
- Kod değişikliği yok; yalnız bayrak migration'ı uygulandı.

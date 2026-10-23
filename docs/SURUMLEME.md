# Sürümleme kuralı (app ve panel)

Bu kural mobil uygulama (`mobile-app`) ve web paneli + site (`web-panel`) için geçerlidir. Veritabanı migration'ları iki tarafın ortak sözleşmesidir; bu yüzden her sürüm notu migration numaralarını da listeler.

## Sürüm numarası: MAJOR.MINOR.PATCH

- **MAJOR (X.0.0):** Geriye uyumsuz değişiklik. Eski app ya da eski panel yeni veriyle çalışmaz; eski sürümlerin desteği biter.
- **MINOR (x.Y.0):** Büyük değişiklik. Aşağıdakilerden biri varsa MINOR artar:
  - Yeni bir modül ya da kullanıcı yüzeyi (ör. Okuma Dünyası).
  - Veri sözleşmesine (RPC, paket biçimi, migration) geriye uyumlu eklenti.
  - Tek bir değişikliğin 5'ten fazla alanı ya da 2 yüzeyi etkilemesi.
- **PATCH (x.y.Z):** Hata düzeltmesi, metin, küçük görünüm düzeltmesi. Veri değişmez ya da yalnız düzeltme migration'ı içerir.

Panel 0.x iken: büyük değişiklik 0.Y.0, düzeltme 0.y.Z. Panel 1.0.0'a ancak tüm yüzeyler kararlı olduğunda çıkılır.

## Nerede tutulur

- **App:** `mobile-app/pubspec.yaml` içinde `version: X.Y.Z+B`. `+B` (build numarası) her APK derlemesinde bir artar (Android `versionCode`).
- **Panel:** `web-panel/package.json` içinde `"version": "X.Y.Z"`.
- **Git etiketi:** Her sürümde `app-vX.Y.Z` ve/veya `panel-vX.Y.Z` etiketi, sürümün birleştirme (merge) commit'ine konur.
- **Sürüm notu:** Bu dosyanın altında, en yeni en üstte.

## Yayın akışı

1. Değişiklik bir feature branch'inde geliştirilir; her mantıklı adım ayrı commit'tir.
2. Sürüm numarası, büyük değişiklik tanımına göre belirlenir ve ilgili `pubspec.yaml` / `package.json` güncellenir.
3. Sürüm notu eklenir: tarih, app ve panel sürümleri, değişiklikler, eklenen migration numaraları, uyumluluk notu.
4. Test kapıları: app için `flutter test`; panel için `tsc --noEmit`, `eslint`, `npm run build`; veritabanı için PGlite testleri.
5. Migration'lar önce `db:preview`, sonra onayla `db:deploy` ile uygulanır.
6. Branch master'a birleştirilir; etiketler eklenir ve master push edilir. Panel Vercel'de otomatik yayınlanır.
7. App APK'sı derlenir ve kurulur (ya da mağazaya gönderilir).

## Uyumluluk

- Panel değişikliği veri sözleşmesi değiştiriyorsa, sürüm notunda hangi app sürümünden itibaren çalıştığı yazılır.
- Migration'lar geri alınamaz varsayılır; geri dönüş gerekirse yeni bir ileri migration yazılır.

---

## Sürüm notları

### app 1.1.0+2 · panel 0.2.0 · 2026-10-23

Büyük değişiklik (MINOR).

**Okuma Dünyası (yeni modül)**
- Mobil: okuma akışı, kelime ve atasözü anlamları (hikâye paketi içinde), kavram ikonları, otomatik kaydırma, soru geri bildirimi, anket (isteğe bağlı puan), sonuç ekranı, PDF indirme (kapakta sahne görseli).
- Panel: Hikâye Atölyesi (içe aktarma, düzenleme, sürüm yönetimi, toplu arşiv/silme, karne uyarıları, sözlük yükleme), veli ve öğretmen dashboard metrikleri, kullanım süresi raporu.
- Site: `/okuma-demo` ve `/okuma/sinif-okuma-anlama` (bağlantısız, noindex); ana sayfada gerçek sayılarla "Hikâyeler" bölümü.

**Migration'lar (uzak veritabanında uygulandı):** 20261057, 20261058, 20261059, 20261060, 20261061, 20261062, 20261063, 20261064, 20261065, 20261066, 20261067, 20261068, 20261069, 20261070, 20261071, 20261072, 20261074, 20261075, 20261076, 20261077, 20261078, 20261079.

**Uyumluluk:** Okuma modülü app 1.1.0+2 ile birlikte çalışır. Önceki app sürümlerinde okuma modülü yoktur, etkilenmez. Panel 0.2.0 yeni RPC'leri kullanır; 20261078 ve 20261079 uygulanmadan yeni alanlar ve toplu işlem gelmez.

**Bilinen açıklar:** Yayına alınmamış yeni hikâye sürümleri; insan okuması bekliyor. Gerçek cihazda PDF indirme ve otomatik kaydırma henüz doğrulanmadı.

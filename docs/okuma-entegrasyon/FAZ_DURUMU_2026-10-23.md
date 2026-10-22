# Okuma Dünyası: faz durumu (2026-10-23)

Kaynak plan: `ENTEGRASYON_PLANI_2026-10-21.md` ve `UYUM_PLANI_2026-10-22.md`. Bu belge, o planların bugünkü durumunu ve kalan işleri tek yerde toplar. Durum dürüstçe yazılır: "yapıldı" yalnız test ya da kontrol ile doğrulananlar için kullanılır.

## Faz 0: Sabitleme
- Veritabanı: `npm run db:status` (2026-10-23) yerel ve uzak migration listesini birebir eşleşiyor gösterdi.
- Taban çizgisi: `flutter test` 398/398 (o tarihte), PGlite zinciri hatasız (kos 186/187; #18 bilinen, atölye paket etiketi kuralı), web `tsc` ve `eslint` temiz.
- Durum: **tamam**.

## Faz 1: V3 arayüzünü Hupolingo'ya taşı
- (a) Gösterim kuralları okuma_motoru'nda, birim testli: **tamam**.
- (b) V3 bileşenleri, süre kuralı tek kaynak, geri sayım: **tamam**.
- (c) Otomatik geçiş (doğru 3 sn, yanlış 6 sn, hareket azaltmada anlık): **tamam**.
- (d) Sahne görseli: 30 sahne JPEG'i uygulamada; yoksa tür yedeği. Eksik 15 hikâye için görsel üretimi **açık** (Faz 2 maddesi 4).
- (e) PDF: uygulamada "indir" dosyayı kaydediyor; kapakta maskot yok, sahne görseli var. Web'de PDF indirme ve gerçek cihazda uçtan uca kontrol **açık** (cihaz bağlı olmalı).
- Kabul ekran görüntüleri (390×844, 1024×768, 360×640 + yazı 2.0): ajan ile golden testleri üretiliyor (bkz. aşağıdaki güncelleme).

## Faz 2: Sunucu sözleşmesi ve içerik
- 2.0 fiş katmanı: **tamam** (20261057; 120 fişten 45'i yazıldı, 75'i yazılmadı).
- 2.1 şema genişletme: ikon kimliği 24 karakter, paket içinde hikâyeye özgü `sozluk`: **tamam** (20261076). `sahne`, `bilgi_kutusu`, `benzer/zit` alanları **açık** (bilgi kutusu ve benzer/zıt içerik gerektirir; ayrı karar).
- 2.2 sözlük yükleme (yuva anlamları): anlamlar artık paket içinde; yönetimde sözlük JSON yükleme ekranı **ajan kontrolünde** (bkz. Faz 3).
- 2.3 içerik hattı: 12 hikâye test yayınında (eski sürüm); 45 hikâyenin yeni taslak sürümleri uzakta (20261077). Ajan A/B denetimi: önceki 12 hikâye için var; diğerleri **açık**. İnsan okuması kullanıcıda.
- 2.4 sahne görselleri: 30/45 var; 15 eksik **açık**.

## Faz 3: Paneller
- Yönetim (Hikâye Atölyesi):
  - Yükleme, durum değiştirme, karne, boşluk haritası, istatistik: **var**.
  - Düzenleme (yeni taslak sürüm), silme kuralı, toplu işlem, karne eşik uyarıları, sözlük yükleme: **ajan kontrolünde** (sonuç bekleniyor).
  - Düşün/Bilgi kutusu/benzer anlam editörü: **açık** (2.1 kararına bağlı).
- Veli (`okuma-dunyasi`): özet, hedef durumları, tema, değer, zorluk seyri, soru doğruluğu: **var**. Eksik metrikler ve rıza kapısının denetimi: **ajan kontrolünde**.
- Öğretmen: sınıf toplamı ve bireysel veri (rıza sunucuda, min-N): RPC'ler **var**; web arayüzü ve eksik metrikler **ajan kontrolünde**.

## Faz 3b: Kullanım süresi analitiği
- Olay tablosu, RPC'ler, 300 gün temizliği (pg_cron, 20261070): **tamam** (uzakta).
- Mobil (`kullanim_suresi.dart`), web (`KullanimSuresi.tsx`), yönetim raporu (`/yonetim/kullanim`): **tamam** (kod, test). Uygulamada gerçek cihazda doğrulama **açık**.
- KVKK notu: `KULLANIM_SURESI_KVKK_NOTU.md`; hukuk onayı kullanıcı beyanı (GÖR-045).

## Faz 4: Web sitesi
- Landing'e "Hikâyeler" bölümü (gerçek sayılar, `okuma_site_ozeti`): **tamam**, navigasyonda.
- `/okuma-demo` (statik örnek), veli bölümü bileşeni, `/okuma/sinif-okuma-anlama` SEO sayfası: **ajan kontrolünde**; navigasyona ve sitemap'e **bağlanmayacak** (yayın pilot bitişi ve hukuk sonrası kararı kullanıcıda).
- Fiyat sayfası okuma hakkı kalemi: **açık** (öneri notu).

## Faz 5: Kapalı pilot
- Plan: izinli 4–5. sınıf hesapları. Kullanıcı genel bayrağı açtı (20261063); pilot sınırı bu karara göre yeniden tanımlanmalı. Hukuk onayı verildi (GÖR-045). **Kullanıcı kararı bekliyor**: pilot hesap listesi mi, genel erişim mi.

## Faz 6: Sonra (kapsam dışı; ayrı kararlar)
- İngilizce (K-0091 ön analizi), Storage/CDN'e geçiş (egress eşiği), sesli okuma (TTS kararı), hikâye atama, 1. sınıf pilotu, release imzası.

## Dört ek gereksinim (kullanıcı, 2026-10-21)
1. Veli/öğretmen dashboard'u: Faz 3 ajan kontrolünde.
2. Yönetim yaşam döngüsü (düzenleme, silme kuralı, toplu işlem, genel pano): Faz 3 ajan kontrolünde; genel pano mevcut.
3. Kullanım süresi: Faz 3b, bkz. yukarı.
4. 120 hikâyelik içerik hattı: Faz 2. Kullanıcının 15'er hikâye partileri geldikçe aynı hat çalışır (derleme, sözlük, ikon, taslak içe aktarma, PGlite, insan okuması).

## Kullanıcı kararları (açık)
- Yeni sürümlerin (12 test yayını + 33 taslak) yayına alınması ve insan okuması.
- Sözlük yaklaşımı: anlamlar hikâye paketinde (dört göz kapısı dışında).
- İkon yoğunluğu (sayfa başına en çok 3).
- Faz 5 pilotunun kapsamı (genel bayrak açık).
- Sahne görselleri: 15 eksik için üretim onayı (Gemini).

## Son durum (2026-10-23, günlük K-0104)
- Faz 0: tamam (db:status birebir; taban testleri).
- Faz 1: kod tamam; kabul golden ekran görüntüleri (390×844, 1024×768, 360×640; 1.0 ve 2.0) tamam; cihaz uçtan uca ve web PDF indirme açık.
- Faz 2: 2.0 fiş ve 2.1 sözleşme (ikon kimliği, paket sözlüğü) tamam. Açık: sahne/bilgi kutusu/benzer-zıt alanları (karar), Ajan A/B (33 hikâye), 15 eksik sahne görseli, insan okuması.
- Faz 3: yönetim (düzenleme, silme kuralı, toplu işlem, karne uyarıları, sözlük yükleme) ve veli/öğretmen dashboard metrikleri kodlandı, PGlite geçti. 20261078 ve 20261079 uzakta uygulanmadı.
- Faz 3b: kullanım süresi tamam (uzakta, pg_cron 300 gün). Cihazda doğrulama açık.
- Faz 4: /okuma-demo ve /okuma/sinif-okuma-anlama hazır, bağlantısız ve noindex; yayın bloke.
- Faz 5: genel bayrak açık; pilot kapsamı kullanıcı kararı.
- Faz 6: kapsam dışı.
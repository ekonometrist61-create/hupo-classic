# Hupolingo giriş filmi: "Kelime Evreni" (mobil + web)

> Tarih: 28 Ekim 2026 · Kayıt: K-0167 · Kaynak: `docs/splash/remotion/src/HupoGiris.tsx`
> Bu belge `ACILIS_SENARYOSU_PLANI.md` içindeki ilk-açılış sahnesinin (§3.1) **yerine geçen aday** senaryodur.
> Durum: film onaylandı (kullanıcı, 28 Ekim) ve **mobil + Flutter web uygulamasına bağlandı** (§5, K-0169). Video uygulamaya gömülmez; aynı senaryo Flutter'da çizilir.

## 1. Fikir

Önceki denemeler (uyanma, uçuş, imza) hep aynı hatayı yaptı: Hupo sahnede bir *çıkartma* gibi hareket etti.
Bu senaryoda Hupo'nun **dünyası** var ve giriş bir *olay* anlatıyor:

> Ses kısılır, gece olur, gökyüzünde iki yıldız yanar. Bunlar Hupo'nun gözleridir. Gökyüzündeki yıldızlar
> (ve Türkçenin ğ, ş, ı, ç, ö, ü harfleri) ona doğru akar, onu *oluşturur*. Hupo gözünü açar, selam verir,
> kanadından çıkan altın iz "Hupolingo" yazısını sarar. Sabah olur.

Neden bu: baykuş zaten gece/bilgelik; ürün kelime ve soru ("Kelime Evreni"); harfler gökyüzünde yıldız olur → "bilgi
toplandıkça Hupo belirir". Mekanik açıdan da avantajı var: **karakter hareketi küçük** (göz, sıçrama, kanat
selamı); etkileyici olan kısım ışık, parçacık ve tipografi. Onaylı master'ın kemik animasyonuyla uğraşılmaz.

## 2. Senaryo (5,0 sn, tek zaman çizelgesi; mobil ve web aynı)

| Zaman (sn) | Ne olur | Notlar |
|---|---|---|
| 0,00 | Düz **#147D8A** (native splash ile aynı) | Kesilmeden devralınır |
| 0,00 – 0,55 | Turkuaz "gece"ye kararır, yıldızlar ve harf bulutu belirir | Dünya sessizleşir |
| 0,45 – 0,95 | **İki göz yıldızı** yanar (nabız atar) | İlk "tanıma" anı |
| 0,85 – 1,95 | Gökyüzündeki ~1100 nokta, gözlerden dışa doğru **Hupo'nun siluetine** toplanır; kamera yavaşça yaklaşır | Noktaların konumu ve rengi onaylı master'dan örneklenir |
| 1,95 – 2,50 | Noktalar gerçek Hupo'ya dönüşür (çapraz geçiş), yumuşak hale | Gözler kapalı |
| 2,48 – 2,60 | **Gözler açılır**: yıldızlar küçük kıvılcımlara dağılır | Dramatik doruk |
| 2,48 – 3,00 | Sıkışma → sıçrama → oturma; kanat **selam** sallanır (sönümlü) | Gece → sabah geçişi (1,9–3,2) |
| 3,08 – 3,20 | Göz kırpma | |
| 3,00 – 3,70 | "Hupolingo" harf harf yükselir (45 ms aralık) | Nunito 900 |
| 3,12 – 3,95 | Kanat ucundan **altın iz** akar, yazıyı sarıp altına oturur | Altın yalnız imzada |
| 3,95 – 4,55 | Harfler soldan sağa kısa parlar; slogan: "Birlikte öğrenelim" | Metin önerisidir (`hupo-ux-writing` onayı) |
| 4,55 – 5,00 | Kilit kare: Hupo + kelime işareti + altın iz | Poster karesi |

**Yerleşim:** mobil 1080×2340 (Hupo üstte, yazı altta, ortalı); web 1920×1080 (Hupo solda, kelime işareti sağda,
altın iz tüm kilidi sarar). Son kare açık turkuaz; uygulamanın Giriş/Ana sayfasına çapraz geçişle devredilir.

## Ses tasarımı (v2, K-0169)

**v1 neden yetmedi (ölçümle):** enerjinin %94'ü 200–1000 Hz'de (pad baskın, telefonda boğuk); tiz çan (E6/B6) ve 2,6–7,9 kHz kıvılcımlar
"efekt demeti" gibi duyuluyordu; notalar pad ve yankıda eriyordu; drone tam gözler açılmadan önce en yüksekteydi, yani zirvenin kontrastı yoktu.

**v2 ilkeleri** (kanıta dayalı tasarım ilkeleri; ölçülmüş tüketici tepkisi **değil**, bkz. sınırlar):

1. **Ses imzası = ürün adı.** "Hu-po-lin-go" dört hece = dört nota (A4 · D5 · F#5 · A5, D majör arpej). Kısa, basit, yükselen kontur;
   hece parçalama ve ezber için uygun; ödül/seviye seslerinde aynı motifle yeniden kullanılabilir.
2. **Gerilim → çözülme.** Sessiz gece (D3+A3 drone), hızlanan 6 notalık yaklaşma, gözler açılmadan hemen önce ≈ 100 ms **nefes çekme** boşluğu
   (Hupo'nun ezilme anıyla aynı), sonra tek zirve: sıcak D majör vuruşu. Beklenti kurup çözmek zirveyi öne çıkarır.
3. **Ayıklama.** Her ses olayı bir görsel olaya bağlıdır, ama her görsel olaya ses konmaz (iniş bilerek sessiz). Az olay = net olay.
4. **Sıcak, güvenli tonlar.** Marimba/celesta benzeri modal sentez + yumuşak pad, yalnız D majör ve yakın tonlar (konsonans). Tiz kıvılcım, hışırtı,
   "kumar/slot" dinglemesi yok: 8–14 yaş ve veli güveni için düşük uyarılma, yüksek sıcaklık.
5. **Senkron.** Ses, görünür kare zamanından **+17…+40 ms sonra** (ITU-R BT.1359: ses geriden gelirse tolerans, önden gelirse düşük).
6. **Seviye.** −16 LUFS (bütünleşik, K-ağırlıklı), örnek tepe ≤ −3 dBFS; ani yüksek tepe yok.

| Zaman (sn) | Ses (tam sürüm) | Görsel bağ |
|---|---|---|
| 0,05 | Drone yükselir, yumuşak "dünya sessizleşir" havası | Turkuaz → gece |
| 0,48 | İki yıldız notası (D5 sol, A5 sağ) | İki göz yıldızı yanar |
| 1,00–1,98 | Hızlanan pentatonik yükseliş (D E F# A B D) | Noktalar Hupo'ya toplanır |
| 2,35–2,50 | **Nefes çekme**: drone söner | Ezilme (hazırlık) |
| 2,55 | **Zirve**: D majör vuruşu + celesta + yumuşak "kalp" + pad | Gözler açılır |
| 3,03 / 3,14 / 3,25 / 3,415 | **İmza** A4 · D5 · F#5 · A5 | H-u · p-o · l-i-n · g-o harfleri yükselir |
| 3,97 | Kapanış akoru (D4 A4 F#5) + D6 celesta; 4,04'te sakin parlama | İz tamamlanır, harfler parlar |
| 4,10 → | Yalnız yumuşak pad söner (boşluk) | Slogan okunur |

**İki sürüm:** `tam` (varsayılan) ve `sade` (yaklaşma arpeji, hava, parlama yok; yalnız drone, yıldız, zirve, imza, kapanış).
Kulakla seçim için `giris-film/onizleme.html` iki sürümü birlikte oynatır. `remotion/tools/giris_ses_uret.py [tam|sade|ikisi]`.

**Ölçümler (kod çıktısı, dinleme değil):**

| Ölçü | Tam | Sade |
|---|---|---|
| Bütünleşik ses seviyesi | −16,0 LUFS | −16,0 LUFS |
| Örnek tepe | −3,0 dBFS | −3,5 dBFS |
| Kırpma | 0 örnek | 0 örnek |
| Spektrum: 200–1k / 1–2k / 2–4k / >4k | %85 / 7,6 / 5,6 / 0,4 | %91 / 4,0 / 3,2 / 0,3 |
| Zirve (2,55) enerji yükselişi | +15 dB | +25 dB |
| İmza notaları (hu/po/lin/go) yükselişi | +6 / +3 / +4 / +6 dB | +5 / +7 / +7 / +8 dB |
| MP4 (AAC) ve WebM (Opus) içine gömülen sesin kaynak WAV'a göre kayması (çapraz korelasyon) | 0,00 ms (r = 0,9999 / 0,9998) | 0,00 ms (r = 0,9998) |
| Akış süreleri (ffprobe) | video 5,000 sn = ses 5,000 sn | aynı |

**Doğrulanmayanlar ve sınırlar:** sesi **kulakla dinleyemedim** (sentez ve ölçümle tasarlandı); telefon hoparlöründe, kulaklıkta ve tarayıcıda gerçek dinleme yapılmadı.
"Nöropazarlama" etkileri (hatırlanma, duygusal tepki) **ölçülmedi**; yukarıdakiler literatürdeki genel tasarım ilkeleridir, bu filmin sonucunu garanti etmez.
Doğrulama için öneri: `tam` ve `sade` sürümlerini ebeveyn panelinde (rıza ile; çocuk katılımı etik/KVKK onayı gerektirir) A/B tercih + ertesi gün hatırlama sorusuyla sınamak.
Webde video varsayılan olarak sessiz başlar (tarayıcı politikası), ses için kullanıcı bir kez dokunur; mobilde film yalnız ilk açılışta oynar (D4).

## 3. Üretim planı ve durumu

| Faz | İş | Durum |
|---|---|---|
| 1 | Konsept, senaryo, bu belge | Yapıldı |
| 2 | Parçacık verisi: master'dan örnekleme (`remotion/tools/noktalar_uret.py`, sabit tohum) | Yapıldı (1099 nokta, 24 KB) |
| 3 | Remotion kompozisyonu `HupoGirisMobil` / `HupoGirisWeb` (tek bileşen, yerleşim ekran oranından) | Yapıldı |
| 4 | Oracle'da kare incelemesi (2 tur: kusurlar bulundu ve düzeltildi, §4) ve 60 fps final render | Yapıldı |
| 5 | **Onay:** kullanıcı filmi izler (senaryo, süre, slogan, ses) | **Bekliyor** |
| 6 | Web entegrasyonu (§5-A) | Yapılmadı |
| 7 | Mobil entegrasyonu (§5-B) | Yapılmadı |
| 8 | Ses tasarımı ve eşleme (v2, iki sürüm) | Yapıldı; **kulak onayı bekliyor** |
| 9 | Cihaz/tarayıcı QA (S23 FE, düşük uç Android, iOS, Safari, reduced-motion) | Yapılmadı |

**Render:** `powershell -File docs/splash/remotion/oracle-render.ps1 -Mod video -Comp HupoGirisMobil,HupoGirisWeb -Webm -Crf 22 -PosterFrame 299 -OutDir <klasör>`
(Oracle'da tek seferlik kapsayıcı, 2 çekirdek / 4 GB, `--rm`; servislere dokunmaz). Süre: 1080×2340 + 1920×1080, 60 fps, her biri MP4 + WebM + poster ≈ 7 dk.
Önizleme için `-Mod kareler` (küçük JPEG dizisi, ≈ 1 dk).

## 4. Üretim sırasında bulunan ve düzeltilen kusurlar (kare incelemesi)

- Erken karelerde uzun, dağınık çizgiler (iz uzunluğu eased ilerlemeye bağlıydı) → yol uzayında kısa sabit kuyruk.
- Altın iz dikdörtgen "ayraç" gibi duruyor ve kenara yaklaşıyordu → tek akıcı S eğrisi, kenar payı.
- Işık süpürmesi "H" üstünde kutu olarak çıkıyordu (`background-clip:text` flex içinde çalışmadı) → harf başına parlama.
- Hupo altında çamurlu altın leke (turkuaz üstünde %16 altın) → soğuk açık turkuaz ışık.
- Web yerleşimi sağa/sola kayıktı → kilit (Hupo + yazı + iz) ortalandı. İlk kare gradyanlıydı → native ile aynı düz #147D8A.

## 5. Uygulamaya entegrasyon (yapıldı, K-0169)

**Karar (kullanıcı: "bunu kullanalım, ama uygulamaya ağırlık yapmasın"):** video (≈ 2,4 MB) uygulamaya **gömülmedi**; aynı senaryo
Flutter'da tek `CustomPainter` ile çizilir (`mobile-app/lib/widgets/splash/hupo_giris_filmi.dart`). Remotion filmleri
(`giris-film/`) onay ve tanıtım içindir; zamanlama kaynağı `HupoGiris.tsx` ile aynıdır (saniye cinsinden).

- **Nerede oynar:** yalnız **cihazda ilk açılış** (`AppOpenScene.full`, `SplashGate`). Sonraki açılışlar eski kısa sahneyi (900 ms), hareket azalt ise statik kareyi kullanır; değişmedi.
  Flutter web (app.hupolingo.com) aynı kodu kullanır: yatay ekranda Hupo solda, yazı sağda. Yönetim paneli ve veli paneli (Next.js) etkilenmez.
- **Ses:** `AudioEvent.brand` artık `assets/audio/brand/hupo_giris_sesi.m4a`'yı çalar (eski `hupo_marka_sesi.mp3` silindi). Film, ses başladıktan sonra (en çok 350 ms bekler) başlar, böylece ikisi aynı anda açılır. Ses başlamazsa (web otomatik oynatma engeli, ses kapalı, hata) film **sessiz oynar**; çökme yok.
- **Atlama:** dokununca 600 ms sonra (mevcut kapı). **Hareket azalt:** film oynamaz.
- **Kalite uyumu:** ilk 12–30 karede ortalama kare süresi > 18 ms ise parçacıklar yarıya iner, izler kalkar (yalnız aşağı yönde).
- **Sistem splash'iyle süreklilik:** ilk karede sistem splash'indeki Hupo aynı boyda (144 dp) ve ortada durur, ≈ 0,35 sn'de geceye erir. (Sistem splash'i değişmedi.)
- Sahne, Remotion sürümünden bilerek şu kadar farklıdır: kanat sallanması yerine gövde hafifçe sallanır (kanat katmanı ≈ 190 KB ek görsel olurdu), bulanıklık yok, parçacık ışımaları yok.

## Uygulama ağırlığı (ölçülen / ölçülmeyen)

| Kalem | Boyut | Not |
|---|---|---|
| Yeni: `hupo_giris_sesi.m4a` (AAC 72 kb/s, 5 sn) | 47 KB | WAV'a göre kayma 0,00 ms, korelasyon 0,996 |
| Yeni: `hupo_goz_kapali.webp` (göz yaması) | 28 KB | tek ek görsel |
| Yeni: `giris_noktalar.json` (1099 nokta) | 22 KB | yükleme sonrası bellekten atılır |
| Silinen: `hupo_marka_sesi.mp3` | −25 KB | |
| **Net varlık artışı** | **≈ +72 KB** | plan bütçesi ≤ 400 KB; APK/IPA ve web paketi **derlenip ölçülmedi** (sıkıştırma ve tree-shaking sonrası farklı olabilir) |
| Yeni paket bağımlılığı | 0 | video_player, Rive, Lottie eklenmedi |
| Yeni kod | ≈ 600 satır Dart (tek dosya) | |
| Bellek | film bitince çözülmüş görseller atılır (≈ 3,5 MB) ve nokta metni önbellekten silinir | cihazda ölçülmedi |
| CPU (test ortamı, zayıf PC, ölçüm paralel koşunun gürültüsüne açık) | kare başına ort. ≈ 7 ms, p95 ≈ 16–18 ms (build+layout+çizim kaydı) | **GPU/raster ve gerçek cihaz kare süresi ölçülmedi** |

Ölçüm komutları: `HUPO_OLCUM=1 flutter test test/hupo_giris_filmi_test.dart --plain-name CPU`; anahtar kareleri PNG olarak almak için `HUPO_KARE_DIR=<klasör>`.
Testler: `test/hupo_giris_filmi_test.dart` (yaşam döngüsü, ses sözleşmesi, 3 ekran boyutunda 11 anda çizim), `splash_entrance_test.dart`, `splash_gate_test.dart`.
## 6. Dürüstlük: doğrulananlar / doğrulanmayanlar

**Doğrulandı:** Remotion'da iki biçimin tüm kareleri üretildi; 12–16 anahtar kare ve 0,08 sn adımlı hareket şeridi gözle incelendi (göz açılışı, sıçrama, kayma, kırpma, ark, yazı hizası); dosyalar sunucuda render edildi ve indirildi (boyutlar `docs/splash/giris-film/`).
**Uygulama (Flutter) tarafı doğrulananlar:** 24 widget testi geçti (ilk açılışta film, ses gecikmesi/hatası, atlama, hareket azalt, sızıntı yok); portre/yatay/küçük ekranda 11 anahtar karede hatasız çizim ve kareler gözle Remotion filmiyle karşılaştırıldı.
**Doğrulanmadı (uygulama):** gerçek cihazda (Galaxy S23 FE, düşük uç Android) ve iOS'ta oynatma, kare süresi/jank, sesin kulakla dinlenmesi ve ses-görüntü kayması (yalnız ses başlatma sözleşmesi ve süre testlendi), web tarayıcısında otomatik ses engeli davranışı, sistem gezinme çubuğu renginin gece sahnesinde koyulaşmaması (turkuaz kalır), APK/IPA/web paket boyutu.

**Doğrulanmadı (film):** filmi **baştan sona akıcı izlemedim** (yalnız kareler; hareketin hissi, yavaş/hızlı olma kullanıcı değerlendirmesi); uygulamada ve tarayıcıda oynatma; ses; Safari/Firefox/iOS; düşük uç cihaz; kare süresi; mobil ekran oranı farklılığında kırpma (ör. 16:9 ve 20:9 mobil); slogan metni ve hukuk/marka onayı. Hupo katmanları ve master onaylı varlıklardır, **yeni karakter çizimi yok**; ancak "Hupo yıldız noktalarından oluşur" yorumu marka sahibinin onayına tabidir. Harf bulutu yalnız dekor; pedagojik içerik değildir.

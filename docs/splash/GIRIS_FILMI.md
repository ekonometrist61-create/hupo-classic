# Hupolingo giriş filmi: "Kelime Evreni" (mobil + web)

> Tarih: 28 Ekim 2026 · Kayıt: K-0167 · Kaynak: `docs/splash/remotion/src/HupoGiris.tsx`
> Bu belge `ACILIS_SENARYOSU_PLANI.md` içindeki ilk-açılış sahnesinin (§3.1) **yerine geçen aday** senaryodur.
> Durum: film üretildi; **uygulamalara bağlanmadı**. Onay bekliyor (§6).

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

**Ses (üretilmedi):** marka sesi yalnız ilk açılışta (D4, kullanıcı kararı). Önerilen işaretler: 0,45 göz yıldızı
(tek yumuşak çan) · 0,85–1,95 yükselen ışıltı · 2,48 göz açılışı (hafif "pırt") · 3,12 altın iz (cam/çıngırak süpürmesi).
Mevcut `hupo_marka_sesi.mp3` zamanlamaya uyarlanmadı; dinlenmeden filme eklenmedi.

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
| 8 | Ses tasarımı ve eşleme | Yapılmadı |
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

## 5. Entegrasyon önerisi (yapılmadı)

**A. Web (app.hupolingo.com ve hupolingo.com girişi)**: `<video muted playsinline>` + poster (`HupoGirisWeb.webm` önce, MP4 yedek),
oturumda bir kez (`sessionStorage`), dokununca/tuşla atla, `prefers-reduced-motion` ve `Save-Data` açıkken yalnız poster.
Ağırlık ≈ 2,4 MB (ilk yükte değil, sayfa etkileşime geçince yüklenir). Panel (`/yonetim`, `/veli-paneli`) hariç: yöneticiye/veliye her girişte film oynatılmaz.
Not: çalışma ağacında `web-panel/src/components/common/WelcomeSplash.tsx` başka bir oturum tarafından silinmiş durumda; web bağlama işi o değişikliği tamamlayan oturumla çakışmamalı.

**B. Mobil**: yalnız **cihazda ilk açılış** (§3.3-A "Merhaba" kartıyla birleşir). Seçenekler: (1) `video_player` ile MP4 (+ 2,4 MB asset, bütçe ≤ 400 KB aşılır → ilk açılışta indirilebilir/uzak asset) veya (2) aynı senaryonun Flutter katmanlı sahnesi (parçacıklar `CustomPainter`, JSON 24 KB). **Öneri: (2)**, çünkü video ekran oranına/oynatıcıya bağımlı, sonraki açılışlarla tutarlı değil ve paket bütçesini aşıyor; film zamanlama + görsel referans olur. Sonraki açılışlar bu filmi **oynatmaz** (≤ 900 ms kuralı sürer).

## 6. Dürüstlük: doğrulananlar / doğrulanmayanlar

**Doğrulandı:** Remotion'da iki biçimin tüm kareleri üretildi; 12–16 anahtar kare ve 0,08 sn adımlı hareket şeridi gözle incelendi (göz açılışı, sıçrama, kayma, kırpma, ark, yazı hizası); dosyalar sunucuda render edildi ve indirildi (boyutlar `docs/splash/giris-film/`).
**Doğrulanmadı:** filmi **baştan sona akıcı izlemedim** (yalnız kareler; hareketin hissi, yavaş/hızlı olma kullanıcı değerlendirmesi); uygulamada ve tarayıcıda oynatma; ses; Safari/Firefox/iOS; düşük uç cihaz; kare süresi; mobil ekran oranı farklılığında kırpma (ör. 16:9 ve 20:9 mobil); slogan metni ve hukuk/marka onayı. Hupo katmanları ve master onaylı varlıklardır, **yeni karakter çizimi yok**; ancak "Hupo yıldız noktalarından oluşur" yorumu marka sahibinin onayına tabidir. Harf bulutu yalnız dekor; pedagojik içerik değildir.

# Okuma Dünyası ("Senin Hikâyen") — Platform ve Tasarım Denetimi

- Tarih: 2026-10-21
- Kapsam: `mobile-app/lib/screens/okuma/*`, `mobile-app/lib/widgets/okuma/*`, `mobile-app/lib/providers/okuma_akis.dart`, `mobile-app/lib/services/okuma_repository.dart`, `mobile-app/lib/models/okuma_kahraman.dart`, Öğren kartı `okuma_bugun_karti.dart`
- Mod: SALT OKUNUR. Kaynak dosyalarında değişiklik yapılmadı. Yalnızca bu rapor yazıldı. `PROJE_GUNLUGU.md` ve `decisions.md` güncellenmedi (salt okunur kapsam gereği).
- Etiketler: DOĞRULANDI (kod okuma + önizleme/test kanıtı), KISMİ (kısmen kanıt), DOĞRULANMADI (kanıt yok, neden yazılı).
- Önem: Kritik (canlı açılıştan önce kapanmalı), Yüksek, Orta, Düşük.

---

## 1. Özet

Akış mantığı (kahraman → liste → okuma → sorular → anket → sonuç), hata/kota/çevrimdışı ayrımı, şık durumlarında ikon+metin kullanımı, güvenli alan, hareket azaltma ve ceza dilinden kaçınma iyi uygulanmış. Buna karşılık bir ürün kararı (yasak ad listesi) kodda yok, birkaç durumda çocuk çıkış yolu bulamıyor, ve erişilebilirlik etiketlerinde bir yer tutucu hata var.

Bu rapordaki en önemli 8 bulgu:

1. **OK-01 (Kritik):** K-0024 E-8 kararı (çocuğun giremeyeceği yasak ad listesi: din büyükleri, küfür, çizgi film/marka adları, gerçek kişiler) kodda uygulanmamış. `adKontrol` yalnızca uzunluk ve karakter kontrol ediyor. Canlı açılıştan önce kapanmalı.
2. **OK-02 (Yüksek):** Zaman aşımı yok. Yükleme ve "bitiriliyor" ekranlarında geri tuşu devre dışı ve görünür çıkış yok. Askıda kalan bağlantıda çocuk sonsuz spinner'da kalır.
3. **OK-03 (Yüksek):** Sorular ekranında görünür geri düğmesi yok. Fiziksel geri tuşu cevapları sessizce siler ve listeye döndürür.
4. **OK-04 (Yüksek):** Otomatik soru geçişi (doğru 3 sn, yanlış 6 sn) açıklama okunmadan ilerletebilir; duraklatma ve kapatma yok. Süre kullanıcı kararı (K-0048) ile uyumlu, ancak 6 sn okuma süresi için yetersiz olabilir.
5. **OK-05 (Yüksek, KISMİ):** 360x640 gibi kısa ekranlarda yanlış cevap geri bildirimi seçeneklerin altında kalıp kaydırma olmadan görünmeyebilir (aritmetik tahmin).
6. **OK-06 (Yüksek):** Sonuç ekranındaki "Sıradaki hikâye" kartının ekran okuyucu etiketi `': . .'` (yer tutucu). Kart erişilebilirlikte anlamsız okunuyor.
7. **OK-07 (Yüksek):** Yazı ölçeği 2.0'da başlık kelime ortasından kırılıyor ("Kahrama / nın kim"). Önizleme kanıtlı. Aynı bileşen hikâye ekranında da kullanılıyor.
8. **OK-08 / OK-10 (Orta):** Anket "Gönder" çift tıklamaya açık ve cevapsız sorular sunucuya `false` olarak gidiyor. "Cevapsız" ile "Hayır" ayırt edilemiyor.

Görsel kontrol özeti: 22 okuma önizlemesinin 11'i görüldü (390 px: 9, 1024 px: 2). 2.0 ölçeği yalnızca kahraman ekranında görsel olarak kontrol edildi. 360x640 için görsel kanıt yok. Test çalıştırıldı: `okuma_akis_test`, `okuma_kart_test`, `okuma_veri_test` — 59 test geçti.

---

## 2. Ekran başına tablo

| Ekran (dosya) | Hedef | Ana eylem | Durumlar (kod / önizleme) | Kabul |
|---|---|---|---|---|
| Kahraman seçimi (`kahraman_secim_ekrani.dart`) | Çocuk, hikâyenin kahramanını seçer | "Hikâyeleri gör" (tek birincil; pasifken neden yazısı) | Pasif neden: var ✔. 1024: 5 sütun ✔ (önizleme). 390: 3 sütun ✔. 2.0: başlık kırılıyor ✗ (önizleme). Ad hatası her tuşta ✗ (OK-21). Yasak ad yok ✗ (OK-01). 360x640: DOĞRULANMADI | KALDI (OK-01, OK-07) |
| Hikâye listesi (`hikaye_secim_ekrani.dart`) | Kahramana uygun hikâyeyi seçmek | Hikâye kartına dokunmak | Yükleniyor ✔, hata + "Yeniden dene" ✔, kahramana uygun hikâye yok ✔ (copy doğru), filtre boşu ✔, "Yeni" etiketi ✔. 390 önizleme ✔. 2.0 başlık: kod çıkarımı (OK-07), görsel yok | KISMİ |
| Açılış/bekleme (`okuma_akis_ekrani.dart:184-216`, `_Bekleme`) | Hikâye hazırlanırken beklemek | Yok | Zaman aşımı yok ✗, geri devre dışı ✗, görünür çıkış yok ✗ (OK-02) | KALDI |
| Okuyucu (`okuyucu_ekrani.dart`) | Sayfa sayfa okumak | "Sonraki sayfa" / "Sorulara geç" | 390 önizleme ✔. Çevrimdışı şerit ✔ (liveRegion). Sayfadaki kelimeler (H4) ✔. Sade vurgu bütçesi metinle tutarsız (OK-12). Kelime dokunma hedefi küçük (OK-13). 2.0 ve 1024: görsel yok | KISMİ |
| Sorular (`sorular_ekrani.dart`) | Cevaplamak, geri bildirim almak | Seç → "Cevapla" → "Sonraki soru" | Seçim, pasif "Cevapla", yanlış geri bildirim (390 önizleme ✔, "Bu kez olmadı", X yok ✔), doğru ✔, hata + "Yeniden dene" ✔. Geri yok ✗ (OK-03). Otomatik geçiş (OK-04). Geri bildirim kaydırmadan görünmeyebilir (OK-05, KISMİ) | KALDI |
| Anket (`anket_ekrani.dart`) | Hikâyeyi puanlamak (ödülsüz, atlanabilir) | "Gönder" (yıldız seçilince) / "Şimdi değil" | Atlanabilir ✔, yıldız dokunma alanı 56 dp ✔, çift gönderim korumasız ✗ (OK-08), cevapsız=false ✗ (OK-10), ek sorular ekranın altında kalıyor (OK-11, 390 önizleme) | KISMİ |
| Sonuç (`sonuc_ekrani.dart`) | Bitirdiğini ve ne kadar bildiğini görmek; sonraki adım | "Yeni hikâye seç" (kota doluysa "Tamam") | Kutlama yalnız tümü doğruyken ve hareket azaltma kapalıyken ✔. Sunucu XP/seri ✔ (uydurma yok). 390 önizleme: öneri kartı yarım görünüyor (Düşük). 1024 önizleme ✔. "': . .'" etiketi ✗ (OK-06). Çıkış eylemi yok (OK-09). 2.0 başlık: widget testi taşma yok ✔ (320x568, 360x640); görsel yok | KISMİ |
| Kota dolu (`_KotaEkrani`, akış) | Bugünkü hak doldu; sakin bitiş | "Tamam" / "Okuduklarım" | 390 önizleme ✔. Copy ✔ ("Yarın yeni bir hikâye seni bekliyor"). Ödeme yönlendirmesi yok ✔ | GEÇTİ |
| Hata (akış `OkumaAsama.hata`) | Hatadan kurtulmak | "Yeniden dene" / "Hikâyelere dön" | Kod ✔ (adım bazlı yeniden deneme). Önizleme yok. Metinler teknik kod göstermiyor ✔ | KISMİ (görsel yok) |
| Okuduklarım (`okuduklarim_ekrani.dart`) | Bitirilenleri görmek, yeniden okumak | Kart (tamamı dokunulabilir) | Boş durum + davet ✔, etiket ✔, geri ✔. Tarih biçimi (OK-26) | GEÇTİ (küçük bulgular) |
| Öğren kartı (`okuma_bugun_karti.dart`) | Bugünkü hikâyeye tek dokunuşla ulaşmak | "Hikâyeye başla" | Erişim bayrağı ✔ (kart yoksa hiç görünmez). Kota ✔, geri dönüş metni (OK-23), sabit 56 dp düğme (OK-19). Önizleme yok | KISMİ |

---

## 3. Bulgular

Her bulgu: kimlik, önem, dosya:satır, sorun ve kullanıcı etkisi, öneri, etiket.

### Kritik

**OK-01 · Kritik · Yasak ad listesi uygulanmamış · DOĞRULANDI**
- Dosya: `mobile-app/lib/models/okuma_kahraman.dart:82-95` (`_adKurali`, `adKontrol`). Repo genelinde (`C:\Dev\hupo`) "yasak/forbidden/hassas ad" listesi aramasında eşleşme yok.
- Sorun: K-0024 E-8 kararı ONAYLI ve metni: "Listeye yeni ad ekleme yetkisi kimseye verilmez... Tam liste kodda yazılacak." Kodda yalnızca uzunluk (24) ve karakter kümesi kontrolü var.
- Etki: Çocuk, din büyükleri, küfür, çizgi film/marka karakter adları ya da gerçek kişi adlarını kahraman olarak girebilir. Ad hikâye metnine işlenir; telif ve içerik güvenliği riski.
- Öneri: Listeyi kodda tut (Türkçe büyük/küçük harf ve boşluk normalizasyonu ile), eşleşmede sakin bir mesaj ver ("Bu adı kullanamazsın, başka bir ad dene."), listeyi hukuk/ürün onayına bağla. Bayrak açılmadan önce kapanmalı.
- Not: Sunucu tarafında ayrı bir kontrol olup olmadığı doğrulanmadı (ad sunucuya gitmiyor; sunucu tarafı bu denetimin kapsamı dışında).

### Yüksek

**OK-02 · Yüksek · Zaman aşımı yok, bekleme ekranlarında çıkış yok · DOĞRULANDI (kod)**
- Dosyalar: `okuma_repository.dart:137-152` (`_rpc`: zaman aşımı yok; grep'te "timeout" eşleşmesi yok), `okuma_akis.dart:214-283` (`_ac`), `:355-361` (`cevapKontrol`), `:398-421` (`_sonucuBekle`), `okuma_akis_ekrani.dart:59-61` (yukleniyor/bitiriliyor'da geri tuşu yutulur), `:184-216` (`_Bekleme`, geri düğmesi yok).
- Sorun: İstek askıda kalırsa "Hikâyen hazırlanıyor…" ya da "Sonucun hazırlanıyor…" ekranı sonsuza kadar döner. Geri tuşu bu aşamada bilerek engellenmiş ve ekranda çıkış düğmesi yok.
- Etki: Zayıf bağlantıda çocuk ekrandan çıkamaz; uygulamayı zorla kapatmak tek yol. Sorular aşamasında cevap bekleyen "Cevapla" düğmesi de aynı şekilde dönebilir.
- Öneri: İstemci tarafında zaman aşımı (ör. 15 sn) ekle; aşımda hata ekranına ve "Yeniden dene"ye düş. Bekleme ekranına "Vazgeç" ekle.
- Etiket: DOĞRULANDI (kod). Ağ askıda kalma senaryosu cihazda test edilmedi.

**OK-03 · Yüksek · Sorular ekranında görünür geri yok; geri tuşu cevapları siler · DOĞRULANDI**
- Dosyalar: `sorular_ekrani.dart:172-175` (`OkumaEkranIskeleti` `geri` verilmemiş), `okuma_akis_ekrani.dart:51-56` (sorular için geri tuşu → `listeyeDon`), `okuma_akis.dart:186-191`.
- Kanıt: `okuma_6_soru_yanlis_390.png` ve `okuma_5_soru_390.png` üst çubukta geri oku yok.
- Sorun: Çocuk sorular sırasında görünür çıkış bulamıyor. Fiziksel geri tuşu sessizce listeye döndürüyor; verilen cevaplar kaybolur ve hikâye baştan açılır.
- Öneri: Üst çubuğa "Hikâyeye dön" ekle. Cevaplar varken çıkışta onay sor ("Cevapların kaybolacak. Yine de çıkmak ister misin?"). Karar bekleyen maddelerde var.
- Not: Sonuç ekranı için de aynı eksik var (OK-09).

**OK-04 · Yüksek · Otomatik geçiş açıklamayı okutmadan ilerletebilir · DOĞRULANDI (kod); süre karar kullanıcıya ait**
- Dosyalar: `sorular_ekrani.dart:59-65` (`_gecisiZamanla`), `okuma_tema.dart:146-147` (3 sn / 6 sn).
- Dayanak: K-0048 (3) "Soru geçişleri zamanlansın" kullanıcı isteğiyle uyumlu. Ancak kayıt süre gerekçesini yalnızca "yanlışta doğru şıkkı okuma süresi" olarak veriyor; açıklama metninin uzunluğuna göre ölçülmemiş.
- Sorun: Yanlış cevapta 6 sn sonra geri bildirim ve açıklama kaybolur. Duraklatma, kapatma ya da süre uzatma yok. Ekran okuyucu kullanan çocuk için içeriğin kendiliğinden değişmesi (WCAG 2.2.1 zamanlama ayarlanabilir, 2.2.2) ihlal riski taşır. Uygulama arka plana alındığında zamanlayıcının nasıl davrandığı test edilmedi.
- Öneri: Varsayılanı "Sonraki" ile ilerleme yap; zamanlayıcıyı isteğe bağlı yap ya da açıklama etkileşim aldığında duraklat. En azından yanlış cevapta süreyi açıklama uzunluğuna göre hesapla ve kapatma seçeneği sun.
- Etiket: DOĞRULANDI (kod). Okuma süresi ölçümü yapılmadı.

**OK-05 · Yüksek · Kısa ekranda yanlış cevap geri bildirimi kaydırmadan görünmeyebilir · KISMİ (aritmetik)**
- Dosya: `sorular_ekrani.dart:206-209` (geri bildirim seçeneklerin altında), `:211` (alt eylem sabit), `okuma_tema.dart:101-109` (Hupo boyutları).
- Tahmin: 4 seçenek (64 dp + 12 aralık) + soru (≈2 satır × 31 dp) + gösterge satırı (56 dp + 16) ≈ 450 dp; 640 dp yükseklikte kullanılabilir alan ≈ 430 dp. Geri bildirim (Hupo 96 dp + açıklama kartı) ancak kaydırınca görünür.
- Kanıt: 390x844 önizlemede (`okuma_6_soru_yanlis_390.png`) geri bildirim görünüyor; 360x640 önizleme yok.
- Öneri: Geri bildirimi seçeneklerin üstünde ya da alt eylem bölgesinde göster; ya da cevap sonrası geri bildirim alanına otomatik kaydır.

**OK-06 · Yüksek · Sıradaki hikâye kartı ekran okuyucuda yer tutucu etiketle okunuyor · DOĞRULANDI**
- Dosya: `sonuc_ekrani.dart:245-249` (`OkumaKart(etiket: ': . .', ...)`).
- Etki: TalkBack/VoiceOver bu kartı anlamsız okur; hikâye önerisi erişilebilir değil.
- Öneri: `etiket: 'Sıradaki hikâye: ${oneri.baslik}. Bu hikâyeyi oku.'` gibi gerçek başlık kullan.

**OK-07 · Yüksek · Yazı ölçeği 2.0'da başlık kelime ortasından kırılıyor · DOĞRULANDI (önizleme)**
- Kanıt: `okuma_buyuk_yazi_kahraman_390.png`: "Kahrama / nın kim / olsun?" (kelime bölündü).
- Kaynak: `okuma_bilesenler.dart:260-300` (`BaslikSatiri`: `Expanded` içinde `Text`, `maxLines` yok, maskot sabit 80–88 dp), `kahraman_secim_ekrani.dart:97-101`. Aynı bileşen `hikaye_secim_ekrani.dart:65-70` ekranında da kullanılıyor (kod çıkarımı; 2.0 görseli yok, DOĞRULANMADI).
- Etki: Türkçe ek ve kelime bütünlüğü bozuluyor; okuma zorlaşıyor.
- Öneri: 2.0'da maskotu başlığın üstüne al ya da küçült; başlık tam genişlikte olsun. Düzeltme başka ajanda; bu rapor yalnızca bulgu kaydıdır.

### Orta

**OK-08 · Orta · Anket "Gönder" çift gönderime açık, yükleme göstergesi yok · DOĞRULANDI (kod)**
- Dosyalar: `anket_ekrani.dart:152` (`onPressed: _yanitVar ? _gonder : null`, meşgul durumu yok), `okuma_akis.dart:385-396` (`anketBitti`: istek bitene kadar durum güncellenmiyor; ekran anket'te kalıyor).
- Etki: Hızlı çift dokunuş iki `geriBildirimGonder` çağrısı üretebilir. Sunucunun idempotency davranışı doğrulanmadı.
- Öneri: Gönder'e meşgul durumu ekle, istek sürerken düğmeleri kilitle (sonuç ekranındaki `_pdfBusy` deseni ile aynı).

**OK-09 · Orta · Sonuç ekranında görünür çıkış yok; düşük skorda "tekrar oku" eylemi yok · DOĞRULANDI**
- Dosyalar: `sonuc_ekrani.dart:310-333` (`OkumaEkranIskeleti` geri yok), `:216-223` (düşük skor metni "istersen sayfalara dönüp tekrar bakabilirsin" ama bunun eylemi yok), `:285-306` (ana eylem "Yeni hikâye seç"; ikincil "Kahramanı değiştir" ve PDF).
- Etki: Çocuk çıkmak için 2–3 geri adımı gerekir; iOS'ta kaydırma ile geri de engelli (PopScope). Düşük skorda sayfalara dönüş vaat ediliyor ama düğme yok.
- Öneri: "Kapat" ya da "Okuma ekranına dön" ekle; düşük skor için "Bu hikâyeyi tekrar oku" ikincil eylemini değerlendir (karar bekleyen).

**OK-10 · Orta · Cevapsız anket sorusu "Hayır" olarak gönderiliyor · DOĞRULANDI**
- Dosya: `anket_ekrani.dart:40-41` (`baskaKahraman: _baskaKahraman ?? false`, `ayniTurden: _ayniTur ?? false`).
- Etki: "Hiç cevaplamadı" ile "Hayır dedi" ayırt edilemiyor; hikâye geliştirme verisi yanıltıcı olur.
- Öneri: Cevapsız durumu null olarak gönder ya da sunucu sözleşmesinde üçlü değer (evet/hayır/yok) kullan.

**OK-11 · Orta · Anket ek soruları ekran altında kalıyor, "Gönder" sorunun hemen altında · DOĞRULANDI (önizleme 390x844)**
- Kanıt: `okuma_8_anket_390.png`: "Başka bir kahraman ister misin?" başlığının hemen altında Gönder düğmesi; Evet/Hayır seçenekleri ve "Bu türden başka hikâye" sorusu görünmüyor.
- Etki: Çocuk başlığın cevabının Gönder olduğunu düşünebilir; ek sorular atlanabilir.
- Öneri: Ek soruları sıkıştır (iki soruyu tek satırda Evet/Hayır'la), ya da sorular arasına ayırıcı ve gerekirse "isteğe bağlı" etiketi koy.

**OK-12 · Orta · Sade modda vurgu kuralı metinle çelişiyor · DOĞRULANDI (kod)**
- Dosyalar: `okuma_tema.dart:142` (`okumaVurguSade = 1`), `okuyucu_ekrani.dart:104-120` (`_butce`: kelime, deyim ve önemli yer aynı tek hakkı paylaşıyor; kelime önceliklidir), `okuma_tema.dart:240` (`modSadeNot`: "Önemli yer ve çıkartmalar gizlenir").
- Sorun: Sade modda sayfada yalnız önemli yer varsa, bu sayfada önemli yer gösteriliyor (metin "gizlenir" diyor). Ayrıca `PROJE_GUNLUGU.md:522` kaydı "Sade modda 1 önemli yer" diyor; kod ise 1 vurguyu tüm türler arasında paylaştırıyor.
- Öneri: Kararı netleştir (karar bekleyen #5), sonra kodu ve `modSadeNot` metnini aynı kurala getir.

**OK-13 · Orta · Kelime ve deyim dokunma hedefi 48 dp'nin altında · KISMİ**
- Dosya: `okuyucu_ekrani.dart:160-180` (metin içi `TapGestureRecognizer`). 19 sp × 1.75 satır yüksekliği ≈ 33 dp; kelime genişliği değişken.
- Hafifletici: "Sayfadaki kelimeler" listesi (`okuyucu_ekrani.dart:245-295`, H4 onaylı) her kelimeyi ≥48 dp satır olarak sunuyor.
- Öneri: Kelime alanına şeffaf dokunma alanı ekle (satır yüksekliğine kadar büyüt) ya da dokunma yerine kısa basılı tut kullanma; ölçüm cihazda yapılmalı.

**OK-14 · Orta · Ekran odağı şartnamesi uygulanmamış · DOĞRULANDI (grep)**
- Kaynak: `C:\Dev\Senin Hikayen - HupoRead\docs\tasarim\OKUMA_DUNYASI_EKRANLARI.md:349` ("Açıklama odağı otomatik alınır. Sonuç ekranında ilk odak başlığa gider.").
- Kod: `screens/okuma` ve `widgets/okuma` içinde `requestFocus`, `FocusNode` ya da `autofocus` yok (eşleşme sayısı 0).
- Etki: Ekran okuyucu kullanan çocuk cevap sonrası geri bildirimi ya da sonuç başlığını bulmak için tüm ekranı taramak zorunda kalır.
- Öneri: Geri bildirim kartına ve sonuç başlığına `FocusNode` ile odak ver.

**OK-15 · Orta · Kahraman ekranı anahtarları (Switch) kapalıyken zayıf görünüyor · KISMİ**
- Dosya: `kahraman_secim_ekrani.dart:149` (yol arkadaşı), `:181` (kaydet). Switch için özel tema yok.
- Kanıt: `okuma_1_kahraman_1024.png`: kapalı Switch'in kenarı ve düğmesi arka plana karışıyor.
- Öneri: Switch'e açık kenar ve belirgin kapalı-durum rengi ver; kontrast ölçümü cihazda yapılmalı (WCAG 1.4.11 için 3:1).

**OK-16 · Orta · Öğren kartı: sabit 56 dp düğme ve etiketsiz tam kart dokunma alanı · DOĞRULANMADI (2.0 görseli yok)**
- Dosya: `okuma_bugun_karti.dart:74-80` (`GameCard onTap` tüm kart), `:129` (`ChunkyButton`, `height` verilmemiş), `chunky_button.dart:20,157` (sabit 56 dp yükseklik, metin ölçeğine bağlı değil).
- Etki: 2.0 ölçeğinde düğme metni kırpılabilir; ekran okuyucu için tam karta dokunma hedefi etiketli değil.
- Öneri: Düğme yüksekliğini `_butonYuksekligi` ile hesapla (OkumaButon kullan); karta `etiket` ver.

**OK-17 · Orta · Sonuç ekranı başlığı 2.0'da kırılma riski (test taşma yapmıyor, görsel yok) · KISMİ**
- Kod: `sonuc_ekrani.dart:158-168` (başlık `maxLines` yok, dikey Column'da). Test: `okuma_akis_test.dart` "sonuç ekranı 320x568 / 360x640 yazı 2.0": taşma yok, başlık görünür (geçti).
- Kalan risk: Test kelime kırılmasını (OK-07 türü) kontrol etmiyor. Görsel kanıt yok.

### Düşük

**OK-18 · Düşük · Cevap sonrası ekran okuyucu: emoji çıkartmaları ham metin olarak okunuyor · DOĞRULANMADI**
- Dosya: `okuyucu_ekrani.dart:187-192` (`Stil.isaret`, metin içi TextSpan).

**OK-19 · Düşük · "İpucu" düğmesi uygulama yazı tipini almıyor · DOĞRULANMADI (önizlemede okunmuyor)**
- Dosya: `sorular_ekrani.dart:178-183` (`TextButton.icon`), `OkumaTemaKapsayici` (`okuma_bilesenler.dart:28-81`) TextButton temasını kapsamıyor.
- Kanıt: `okuma_5_soru_390.png`'de "İpucu" etiketi okunamayan blok olarak çıkıyor. Test ortamı yazı tipi kaynaklı olabilir; cihazda doğrulanmalı.

**OK-20 · Düşük · Okuyucu ayar başlıkları başlık olarak işaretlenmemiş · DOĞRULANDI (kod)**
- Dosya: `okuyucu_ekrani.dart:673-685` (`_AyarBasligi` için `Semantics(header: true)` yok).

**OK-21 · Düşük · Ad alanı her tuşta hata gösteriyor · DOĞRULANDI (kod)**
- Dosya: `kahraman_secim_ekrani.dart:315` (`errorText: metin.isEmpty ? null : adKontrol(metin)`). Çocuk yazarken yarım ad için hata görünür; "Ad yalnızca harf..." uyarısı yazma sırasında kırmızıya döner.
- Öneri: Hatayı odak kaybında ya da "Hikâyeleri gör" denemesinde göster.

**OK-22 · Düşük · Kahramanlarım silme düğmesi küçük hedef · DOĞRULANMADI**
- Dosya: `kahraman_secim_ekrani.dart:258-266` (InputChip `deleteIcon`, 18 dp ikon). 48 dp hedef garantisi kodda yok.

**OK-23 · Düşük · Geri dönüş metni suçlayıcı tona yakın · DOĞRULANDI (metin)**
- Dosya: `okuma_geri_donus.dart:19`: "3 gündür yeni bir hikâye okumadın. Seni bekliyoruz!" "okumadın" ifadesi kayıp üzerinden konuşuyor.
- Öneri: "Yeni bir hikâye seni bekliyor." Gün sayısı yerine olumlu bir çağrı.

**OK-24 · Düşük · Anket yardım metni bozuk · DOĞRULANDI (metin)**
- Dosya: `okuma_tema.dart:286` ("Göndermek için bir yıldız seç ya da şimdi değil de.").
- Öneri: "Göndermek için bir yıldız seç. Ya da 'Şimdi değil'e dokun."

**OK-25 · Düşük · Hata metinleri dışlayıcı ya da teknik · DOĞRULANDI (metin)**
- Dosya: `okuma_repository.dart:36` ("Senin Hikâyen şu an senin için açık değil."), `:40` ("Bu hikâye başka bir ayarla başlatılmış..."). Öneri: çocuk diliyle, eylem odaklı yeniden yaz.

**OK-26 · Düşük · Okuduklarım tarih biçimi ve silme yok · DOĞRULANDI (kod)**
- Dosya: `okuduklarim_ekrani.dart:77` (`d.m.yyyy`, sıfırsız). Öneri: `dd.MM.yyyy`. Tek kaydı silme seçeneği yok (karar bekleyen #9).

**OK-27 · Düşük · Uzun başlıklar 2.0'da kesiliyor · DOĞRULANMADI**
- Dosya: `hikaye_secim_ekrani.dart:286-296` (2 satır + 3 satır tanıtım, ellipsis), `okuduklarim_ekrani.dart:53-58`. Ekran okuyucu tam başlığı okur; görsel kesilme ölçülmedi.

**OK-28 · Düşük · Sonuç: XP ve seri, doğru sayısıyla aynı kartta · DOĞRULANDI (tasarım gözlemi)**
- Dosya: `sonuc_ekrani.dart:198-226`. Veri sunucudan geliyor, uydurma yok (olumlu). Ödül çipleri öğrenme cümlesinin hemen altında; öğrenme ve ödül karışma riski düşük ama izlenmeli. Öneri: ödül çipini motivasyon kartının dışına al.

**OK-29 · Düşük · PDF hakkı metni veli kapısı olarak yazılmış · DOĞRULANDI (metin)**
- Dosya: `okuma_tema.dart:327-328` ("PDF hakkın bu ay doldu. Bu özellik için velinle devam et."). Veli kapısı tasarım ilkesine uygun; hakkın ücretli olup olmadığı karar bekleyen (#8).

**OK-30 · Düşük · Kart ve ilerleme kenarlıkları düşük kontrast · KISMİ**
- Kart kenarı `AppColors.line` (#F0E6CF) beyaz üstünde ≈1.24:1; ilerleme çubuğu izi `lineDark` (#E0D2B0) arka planda ≈1.4:1. Metin kontrastı etkilenmiyor; kart zaten metin ile tanımlanıyor. WCAG 1.4.11 için karar gerekli.

**OK-31 · Düşük · Öğren kartı ve okuma ekranlarında sabit ölçü değerleri · DOĞRULANDI (kod)**
- Dosya: `okuma_bugun_karti.dart:75, 88, 95, 97, 102, 109, 114` (`appText` ile sabit boyut ve değerler). OkumaTema token sistemine bağlı değil; tutarlılık için token'a taşı.

---

## 4. Olumlu bulgular (korunmalı)

- Akış ve durum ayrımı: yükleniyor, hata, boş, kota, çevrimdışı ve başarılı durumlar ayrı ekran/metin ile ele alınmış (`okuma_akis.dart`, `okuma_akis_ekrani.dart`).
- Yanlış cevap metni ceza içermiyor: "Bu kez olmadı. Açıklamaya bakalım." Kırmızı X yok; yanlış şık ampül ikonu ile işaretleniyor (`sorular_ekrani.dart:369`) ve doğru şık metinle "Doğru cevap bu" diye gösteriliyor. Renk tek başına bilgi taşımıyor.
- Hata metinleri teknik kod göstermiyor (`okuma_repository.dart:36-46`).
- Ödeme ve satın alma çocuk ekranında yok (`okuma` ekranlarında "satın/premium/fiyat/ücret" eşleşmesi 0).
- Sahte sosyal kanıt, puan/sınav garantisi, sayaç baskısı yok.
- Sunucu XP ve seri kararını veriyor; istemci ikinci ödül üretmiyor (`sonuc_ekrani.dart:15` yorumu ve uygulama).
- Hareket azaltma: `OkumaTema.sure` ve `disableAnimationsOf` her animasyonda kullanılmış; kutlama Lottie'si hareket azaltmada oynamıyor (`sonuc_ekrani.dart:95`).
- PDF: çift tıklama koruması (`_pdfBusy`, `sonuc_ekrani.dart:57`).
- Güvenli alan ve alt eylem bölgesi: `SafeArea` ve sabit alt eylem (`okuma_bilesenler.dart:219`).
- Kahraman seçiminde pasif düğmenin nedeni canlı bölgede okunuyor (`kahraman_secim_ekrani.dart:203-206`).
- Çevrimdışı okuma şeridi `liveRegion` ile duyuruluyor (`okuyucu_ekrani.dart:439-458`).

---

## 5. Karar bekleyen maddeler

Bu maddeler kullanıcı kararı gerektirir. Öneriler yalnızca öneridir.

1. **Otomatik soru geçişi (OK-04):** K-0048 (3) ile yapılan süreli geçiş kalsın mı? Öneri: varsayılan "Sonraki" ile ilerleme; zamanlayıcı kapalı ya da duraklatılabilir.
2. **Yasak ad listesi (OK-01):** Liste kapsamı (E-8 dört kategori) ve onay sahibi. Öneri: canlıya açmadan önce kodda tamamlanması ve hukuk/ürün onayı. Bayrak durumu bu denetimde doğrulanmadı.
3. **Sorular ekranında çıkış (OK-03):** Çıkışta onay ("Cevapların kaybolacak") mı, yoksa cevaplar saklanıp kaldığı yerden devam mı? Öneri: onay ve kaldığı yerden devam seçeneği.
4. **Sonuç ekranı (OK-09):** "Kapat" eylemi eklensin mi? Düşük skorda "Bu hikâyeyi tekrar oku" ikincil eylemi eklensin mi?
5. **Sade mod kuralı (OK-12):** Sade modda sayfa başına toplam 1 vurgu mu (kod), yoksa yalnız 1 önemli yer mi (PROJE_GUNLUGU:522)? Metin de buna göre yazılmalı.
6. **Kahraman görünümü:** "Hazır Hupo" kartı maskotla, diğerleri daire ikonla gösteriliyor (görsel ağırlık farkı). Maskotlu tek kart mı, yoksa tüm kartlar aynı görsel dilde mi? Switch görünürlüğü (OK-15) da bu kararla birlikte ele alınabilir.
7. **Maskot boyutları:** Soru 56 dp, kahraman başlığı 80–88 dp, sonuç 120–160 dp. 2.0 ölçeğinde başlık için maskot küçültülsün mü? (OK-07 için gerekli.)
8. **PDF hakkı (OK-29):** Aylık ücretsiz hak mı, ücretli mi? Çocuk ekranındaki "velinle devam et" metni veli kapısı olarak mı kalacak? Monetizasyon kararı (çocuk ekranında satın alma yok, veli alanında olur) ile uyumu teyit edilmeli.
9. **Anket ve Okuduklarım:** Anket cevapsız durumu için üçlü yanıt (OK-10)? Okuduklarım'dan tek kayıt silme (OK-26)?
10. **Belge tutarlılığı (bilgi):** K-0035 kaydındaki "cihazda cinsiyet sorusu" ifadesi K-0048 ile geçersiz (cinsiyet kaldırıldı; kod da bunu yansıtıyor). K-0035 notu güncellenmeli mi?

---

## 6. Karar kontrolü: H1–H4 (K-0036, ONAYLI)

Bu bölüm yalnızca uygunluk kontrolüdür; kararlar yeniden tartışılmadı.

- **H1 (anında geri bildirim):** Kodda uygulanmış (`sorular_ekrani.dart:78-104`, `okuma_akis.dart:355-361`). Sunucu RPC'si `supabase/migrations/20261050000200_okuma_dunyasi_ogrenci.sql` içinde var. Uzak veritabanında deploy durumu doğrulanmadı. Uygun.
- **H2 (ad en çok 24 karakter):** Uygulanmış (`okuma_kahraman.dart:82` regex `{0,23}` + ilk harf = 24; `maxLength: 24`). Uygun.
- **H3 (vurgu rengi #8A5B00):** Uygulanmış (`okuma_tema.dart:35`). Arka plan üzerinde 5.6:1 (hesaplandı). Yalnız alt çizgi olarak kullanılıyor (`okuyucu_ekrani.dart:155`); metin rengi değil. Uygun.
- **H4 (sayfadaki kelimeler yedek listesi):** Uygulanmış (`okuyucu_ekrani.dart:245-295`, tooltip ve ≥48 dp satırlar). Uygun. Not: liste yalnız mevcut sayfayı kapsıyor; kararla çelişmiyor.

Kapsam dışı ama kontrol edilen: K-0048 cinsiyet kaldırma kararı kodda uygulanmış (kahraman ekranında cinsiyet sorusu yok, `kahraman_secim_ekrani.dart:11`, `okuma_kahraman.dart:5`).

---

## 7. Kontrast ölçümleri (WCAG 2.x formülü, hesaplandı; cihaz ölçümü değil)

| Çift | Oran | Yorum |
|---|---|---|
| ink #17324D / background #FFF9ED | 12.52 | Geçer |
| muted #4A6A85 / background | 5.42 | Geçer |
| muted / surface (beyaz) | 5.69 | Geçer |
| muted / line (pasif düğme metni) | 4.58 | Geçer (sınırda) |
| beyaz / primary #147D8A | 4.85 | Geçer |
| primary / background | 4.62 | Geçer |
| mintDark #237A4B / mintSoft | 4.69 | Geçer |
| coralDark #A64B24 / coralSoft | 5.14 | Geçer |
| coralDark / beyaz | 5.75 | Geçer |
| vurguAmber #8A5B00 / background | 5.60 | Geçer (alt çizgi, metin değil) |
| beyaz / coralDark (yanlış rozeti) | 5.75 | Geçer |
| lineDark #E0D2B0 / beyaz | 1.50 | Dekoratif kenar; 1.4.11 kararı gerekli |
| line #F0E6CF / beyaz | 1.24 | Kart kenarı; OK-30 |

Sonuç: Metin çiftlerinde 4.5:1 altında kalan kullanım bulunmadı. Non-text bileşen sınırları (kart kenarı, ilerleme izi, Switch) OK-15 ve OK-30'da.

---

## 8. Görsel kontrol kapsamı

Kullanılan önizlemeler (`mobile-app/tool/previews/okuma_*.png`, üretim tarihi 2026-10-18 12:19; kaynak dosyalarının son değişimi 12:18'den önce, yani önizlemeler güncel kaynakları yansıtıyor görünüyor — yalnızca dosya zamanı kanıtı, birebir eşleşme kanıtı değil):

- Görüldü (11/22): `1_kahraman_390`, `3_liste_390`, `4_okuyucu_390`, `5_soru_390`, `6_soru_yanlis_390`, `8_anket_390`, `9_sonuc_390`, `kota_390`, `buyuk_yazi_kahraman_390`, `1_kahraman_1024`, `9_sonuc_1024`.
- Görülmedi: `2_kahraman_ad_390/1024`, `7_soru_dogru_390/1024`, `3_liste_1024`, `4_okuyucu_1024`, `5_soru_1024`, `6_soru_yanlis_1024`, `8_anket_1024`, `2_kahraman_ad_1024` (toplam 11).

Önizleme üreticisi (`tool/okuma_previews_test.dart`) yalnız 390x844 ve 1024x768 ile 2.0 ölçekli kahraman/kota ekranlarını kapsıyor. Yani 360x640, 320x568, sorular/sonuç/okuyucu 2.0 ve klavye durumu için önizleme üretilmedi; bu yüzden ilgili maddeler DOĞRULANMADI veya KISMİ.

---

## 9. Test ve doğrulama

- Çalıştırıldı: `flutter test test/okuma_akis_test.dart test/okuma_kart_test.dart test/okuma_veri_test.dart` (mobile-app kökünde). Sonuç: **"All tests passed!" (59 test)**. Bu testler arasında sonuç ekranı 2.0 yazı taşma kontrolü (320x568 ve 360x640) ve akış durumları var.
- Çalıştırılmadı: `flutter analyze`, `tool/okuma_previews_test.dart` (önizlemeleri yeniden üretmek için), tam `flutter test` (okuma dışı testler).
- Test ortamı, gerçek cihaz davranışının yerini tutmaz.

---

## 10. Doğrulanmayanlar ve nedenleri

- **360x640 ve 320x568 görsel düzen:** Önizleme yok; yalnızca aritmetik tahmin (OK-05). Neden: üreteç 390x844 ve 1024x768 kullanıyor.
- **2.0 yazı boyutu, sorular / okuyucu / hikâye / Öğren kartı / sonuç (görsel):** Önizleme yok. Yalnız kahraman ekranı 2.0 ile görüldü. Sonuç başlığı için yalnız widget testi var (OK-17).
- **Klavye açılınca kahraman ad alanı:** Test ve önizleme yok.
- **Ekran okuyucu gerçek okuma sırası (TalkBack / VoiceOver):** Cihaz testi yok. Metin içi kelime dokunuşlarının erişilebilirliği de doğrulanmadı (OK-13).
- **Yatay yön, web klavye odağı ve odak halkası:** Kod okundu; tarayıcı ve cihaz testi yapılmadı.
- **Android geri tuşu:** `PopScope` davranışı kodda okundu (`okuma_akis_ekrani.dart:173-179`); cihazda çalıştırılmadı.
- **Ağ askıda kalma (OK-02):** Kod incelemesi; gerçek ağ senaryosu test edilmedi.
- **Sunucu tarafı:** RPC migration'ı var; uzak veritabanı deploy durumu, idempotency (anket, bitir), yasak ad kontrolü (sunucu tarafı) doğrulanmadı.
- **PDF üretimi ve Lottie animasyonları:** Kod okundu; çıktı görsel olarak kontrol edilmedi.
- **Okuma süreleri ve otomatik geçiş yeterliliği (OK-04):** Ölçüm yok; yalnızca kod ve metin uzunluğu gözlemi.
- **Kelime dokunma hedef boyutu (OK-13):** Hesap tahmini; cihazda ölçülmedi.
- **Öğren kartının 2.0 görünümü (OK-16):** Önizleme yok.
- **Hikâye listesinin 1024 görünümü ve 2.0 başlık kırılması (OK-07 uzantısı):** Önizleme yok; kod çıkarımı.

---

## 11. Sonraki adım (öneri sırası)

1. OK-01 (yasak ad listesi): canlı açılıştan önce kapat; karar #2 ile birlikte.
2. OK-02 (zaman aşımı, bekleme ekranında çıkış): akış katmanında küçük bir değişiklik.
3. OK-03 ve OK-09 (görünür çıkış, sorular ve sonuç): karar #3 ve #4 sonrası.
4. OK-06 (`': . .'` etiketi) ve OK-14 (odak): hızlı erişilebilirlik düzeltmeleri.
5. OK-07 (2.0 başlık kırılması): karar #7 ile birlikte, tüm `BaslikSatiri` kullanımları için.
6. OK-04 ve OK-05 (otomatik geçiş ve geri bildirim görünürlüğü): karar #1 sonrası; cihazda ölçülerek.
7. OK-08 ve OK-10 (anket çift gönderim ve cevapsız değer): sunucu sözleşmesi ile birlikte.

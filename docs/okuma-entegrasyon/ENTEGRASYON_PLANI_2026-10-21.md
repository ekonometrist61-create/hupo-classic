# HupoRead → Hupolingo entegrasyonu: değerlendirme ve plan (2026-10-21)

Durum: **ONAY BEKLİYOR.** Bu oturumda kod, veritabanı ve içerik değiştirilmedi; yalnız okundu.
Önceki planlar: `C:\Dev\Senin Hikayen - HupoRead\docs\HUPO_ENTEGRASYON_PLANI.md` (§10 kesinleşen kararlar hâlâ geçerli), `docs/hupo-design-growth/okuma-*.md`, `PROJE_GUNLUGU.md` K-0080…K-0091.

## 1. Tespit: "entegre edilecek" şey aslında iki çatal

Modül Hupolingo'da büyük ölçüde zaten var. Asıl iş **iki kopyayı tek kaynakta birleştirmek** ve canlıya hazırlamak.

| Parça | Hupolingo (`C:\Dev\hupo`) | Bağımsız prototip (`Senin Hikayen - HupoRead\flutter_prototip`) |
|---|---|---|
| Veri | Gerçek RPC'ler, 7 migration uzakta uygulanmış (`20261050…`–`20261051…`) | `ornek_veri.dart` (122 KB gömülü), cevap kontrolü yerelde |
| Mobil/Web ekranları | 9 ekran, `okuma_motoru` paketi, Bugün kartı, Okuduklarım + Sözlüğüm, Düşün kartı, SVG çıkartma, yeni PDF | **V3 görsel dil** (`okuma_v3.dart`), sahne görselleri (8 jpg), gösterim kuralları, süre etiketi, soru otomatik geçişi |
| Yönetim | Hikâye Atölyesi (8 sekme) | yok |
| Veli / öğretmen | `/veli-paneli/okuma-dunyasi`; öğretmen kartı `/yonetim/siniflar` içinde | yok |
| Canlı durum | Bayrak KAPALI, yayında hikâye yok, sözlük yüklenmedi | APK telefonda |

## 2. Değerlendirme (kanıtlı bulgular)

1. **En büyük risk: okuma işi git'te değil.** `git ls-files` yalnız 2 okuma dosyası gösteriyor. Mobil modül, web panel sayfaları, testler ve **uzakta uygulanmış 7 migration** commit'siz (untracked). Disk ya da dal kazası, canlı DB ile repo arasında kopukluk yaratır.
2. **Görsel kalite açığı Hupolingo tarafında.** Kullanıcının istediği V3 arayüz yalnız prototipte; Hupolingo okuyucusu K-0078/K-0083 dönemindeki sade hâlde. Port gerekiyor.
3. **Sahne görseli için sunucu sözleşmesi yok.** Sözleşmedeki "sahne" anlatı varyantıdır (`deger_sahneleri` vb.), görsel değil. Prototip 8 jpg'yi (3,6 MB) uygulamaya gömüyor; bu ölçeklenmez.
4. **Sözleşme boşlukları (V3 içeriği için):** Bilgi Kutusu, eş/zıt anlam, Düşün soruları için onaylı veri alanı yok (prototipte taslak, editör onaysız). `dusun` alanı (≤3) uzakta var ama içerik yok.
5. **Gösterim kuralları yalnız prototipte.** "Hikâye başına en çok 2 atasözü" kuralı kodda bile zorlanmıyor; panel içe aktarması da kontrol etmiyor.
6. **İçerik hazır değil (kritik yol):** 24 taslak denetimsiz (Ajan A/B + insan okuması yok), sözlük yüklenmedi, "Hazır Hupo" kahramanı için hikâye yok, süreler tahmin.
7. **Ticari taraf yarım:** Kota ve PDF hakkı (`okuma_gunluk_hikaye=1`, `okuma_pdf_aylik_ucretsiz=3`) DB'de var. Landing, fiyat sunumu ve Planlar ekranında okuma yok.
8. **Web (Flutter Web) doğrulanmadı:** PDF indirme/paylaşma (`printing`, `file_saver`) web'de, 2,8 MB okuma varlığının ilk yüklemeye etkisi ve 1024 px düzeni test edilmedi.
9. **Hukuk ve güvenlik kapıları açık:** GÖR-045 (KVKK m.6 sorusu, saklama, AI metin telifi), GÖR-049 (dört göz için iki yönetici hesabı), GÖR-001 (Gemini anahtarı döndürme).

Doğrulanmayanlar: bu oturumda `flutter analyze/test`, `npm run build/lint` çalıştırılmadı; günlükteki test sayıları (PGlite 171/172, Flutter okuma testleri 70+) rapordan alınmıştır.

## 3. Hedef mimari ve ilkeler

- **Tek kaynak: `C:\Dev\hupo`.** Prototip dondurulur (README'ye "arşiv, geliştirme Hupolingo'da" notu). `okuma_motoru`, derleyici (`atolye`) ve içerik taslakları da Hupolingo'ya taşınır (`tools/okuma-atolye`, `docs/okuma/`, `soru-bankasi` benzeri `icerik/`).
- Öğrenci: **Flutter tek kod** (mobil + `app.hupolingo.com`). Veli/yönetim/öğretmen: Next.js.
- Sahne görselleri sunucudan: Storage'da sürümlü dosya, pakette `sahne{yol,alt_metin,sha256}` alanı, cihazda önbellek. Uygulamaya gömülmez.
- Öğrenme çekirdeği (okuma, sorular, geri bildirim) kısıtlanmaz; fark veli içgörüsü ve PDF'te (önceki karar).
- Canlıya dönük her adım (db:deploy, bayrak, içerik yükleme/yayın, push, landing yayını) ayrı kullanıcı onayı ister.

## 4. Plan

### Faz 0 — Sabitleme (1 gün, kod değişikliği yok denecek kadar az)
1. Dal: `feature/huporead-entegrasyon`. Okuma dosyalarını (mobil, web panel, testler, migration, docs) mantıklı commit'lere böl. `learn_screen`, `VeliSidebar`, `adminNav`, `SiniflarManager` farkları yalnız okuma satırlarını içersin; öteki birikmiş değişiklikler (Kelime Evreni vb.) ayrı commit.
2. `npm run db:status`: repo migration'ları uzakla birebir mi? (7 dosya.)
3. Taban çizgisi: `flutter analyze`, `flutter test`, `supabase/tests/okuma_dunyasi` (PGlite), web `lint` + `build`. Sonuçlar yazılır.
4. Prototipi dondur; bu planı `PROJE_GUNLUGU.md`'ye kayıt et (GÖR-053 kapanır).

### Faz 1 — V3 arayüzünü Hupolingo'ya taşı (öğrenci mobil + web)
Sıra: (a) gösterim kuralları → `okuma_motoru` (saf Dart, birim test; ≤2 atasözü, sayfa bütçesi, Sade/Zengin) → (b) `okuma_v3` bileşenleri `mobile-app/lib/widgets/okuma/` altına, mevcut `okuma_tema`/`AppColors`/`GameCard`/`ChunkyButton` ile; Düşün, Sözlüğüm ve SVG çıkartma korunur → (c) hikâye kartında "N dk", soru ekranında otomatik geçiş (hareket azaltmada animasyonsuz) → (d) sahne görseli: önce yedek sahne (görselsiz çalışır), sonra Faz 2'deki alanla → (e) PDF: Hupolingo üreticisi esas; prototipin kapak kırpma kusuru ve yeni sahne bandı kontrol edilir.
Kabul: 390×844 ve 1024×768 (+360×640 ve 2.0 yazı ölçeği) ekran görüntüsü; gerçek cihazda uçtan uca; web'de PDF indirme; APK/web paket boyutu farkı ölçülür (>1 MB artış bütçe dışı).

### Faz 2 — Sunucu sözleşmesi ve içerik (ayrı onaylı migration)
1. Paket şemasına isteğe bağlı, geriye uyumlu alanlar: `sahne` (görsel), `bilgi_kutusu`, kelime `benzer/zit` (yalnız onaylı veri). Doğrulayıcı, içe aktarma, derleyici, panel önizlemesi birlikte güncellenir. `db:preview` → onay → `db:deploy`.
2. Sözlük yükleme (yuva anlamları, sınıf bantları), "Hazır Hupo" hikâyeleri.
3. İçerik hattı: 24 taslak → Ajan A (bilgi) + Ajan B (dil/edebiyat) → insan okuması → ilk yayın seti **4–5. sınıf, 12–24 hikâye**. Süreler gerçek okuma ölçümüyle güncellenir (pilotta).
4. Sahne görsellerini üret/seç (8 mevcut + yenileri); kahraman çocuğun seçimi olduğu için sahnede sabit yüz yok (mevcut kural).

### Faz 3 — Paneller
- **Yönetim (Hikâye Atölyesi):** sahne görseli yükleme + önizleme; Düşün/Bilgi Kutusu/benzer anlam editörü ve onay; içe aktarmada gösterim-kuralı denetimi (hata/uyarı); sözlük yükleme ekranı; karne eşik uyarıları (tamamlama ≥%70, anlama ≥%60 vb.); ayarlara kota/PDF hakkı. GÖR-049 çözülmeden "dört göz" yalnız test hesaplarıyla denenir.
- **Veli (`/veli-paneli/okuma-dunyasi`):** rıza yoksa kilitli kart; değer önceliği (≤5/20); açıklanabilir özet (işlem türü, hedef durumu, tema/değer); PDF; geri dönüş bildirim tercihi (hukuk onayına kadar kapalı); ücretsiz/premium farkı net ve dürüst (puan/sınav garantisi yok). Planlar/abonelik sayfasında okuma hakları görünür.
- **Öğretmen:** ayrı panel yok; `/yonetim/siniflar` içindeki sınıf kartı kalır (toplulaştırma, min-N). Hikâye atama ve okul paketi sonraki faz.

### Faz 4 — Web sitesi (hupolingo.com)
Şu an landing/demo'da okuma yok. Önerilen sıra: (1) **içerik ve pilot sonuçları gelmeden iddia yok**; (2) veli odaklı bölüm "Çocuğun kahramanı olduğu hikâyeler": Maarif değerleri, sınıfa uygun kelime/deyim/atasözü, açıklanabilir veli özeti, PDF; sahte sosyal kanıt, sınav/puan garantisi yok, "MEB onaylı değildir" ifadesi; (3) `/demo`'ya statik tek örnek hikâye (kayıt gerektirmez); (4) fiyat sayfasında hak kalemi olarak (ayrı SKU yok); (5) SEO sayfası ("sınıfa göre okuduğunu anlama"), tasarım ajanıyla (`hupo-design-growth-director`). Yayın, pilot bitişi + hukuk onayı sonrası.

### Faz 5 — Kapalı pilot
İzinli 4–5. sınıf hesapları, bayrak yalnız onlara; ölçütler ve eşikler önceki plan §3'teki gibi; GÖR-045 kapanmadan açılmaz; push veli onayıyla ve hukuk sonrası. Çıkışta: bayrak genel açılış kararı (kullanıcı).

### Faz 6 — Sonra
İngilizce (K-0091'deki ön analiz), Storage/CDN'e geçiş (egress eşiği), sesli okuma (TTS kararı), hikâye atama, 1. sınıf ayrı pilot, release imzası.

## 5. Kullanıcıdan gereken kararlar

1. Faz 0'ı başlatayım mı (commit bölme, dal, taban testleri)? Commit onayı sizde.
2. Prototip dondurulsun, tüm geliştirme Hupolingo'da mı? (Önerim: evet.)
3. Sahne görselleri sunucudan (Storage + paket alanı) mı, ilk pilotta gömülü mü? (Önerim: sunucudan; Faz 1'de yedek sahne ile görselsiz çalışır.)
4. Landing bölümü pilot sonrasına mı kalsın? (Önerim: evet; öncesinde yalnız `/demo` örneği.)
5. İlk yayın seti 4–5. sınıf, 12–24 hikâye ve insan okuması için kim (siz mi, bir Türkçe öğretmeni mi)?

# 17 Risk ve Uyum

Durum: Taslak (hukuk görüşü değildir; avukat onayı gerekir) · Tarih: 2026-10-29 · Rol: Pazarlama + Uyum · Bağımlı: 03, 07, 11, 12, 19, 20

Kesin hukuki iddia yazılmaz; koşullarla kod çelişirse burada raporlanır.

## 1. Risk kaydı (olasılık × etki: D/O/Y)
| # | Risk | O | E | Önlem | Sahibi |
|---|---|---|---|---|---|
| R1 | Kanıtsız iddia (iade garantisi, %100, tasarruf, "en çok tercih edilen") canlıda | Y | Y | Y2 kapısı; lint; kanıt kaydı | Ana oturum |
| R2 | Mağaza rozeti, uygulama mağazada yokken | Y | O | Y1 | Ana oturum |
| R3 | Ticari ileti izni/İYS olmadan e-posta/SMS/WhatsApp | O | Y | Kapı: hukuk onayı + 3 ayrı kutu + sürümlü metin; gönderim yok | Proje sahibi |
| R4 | Çocuk verisi (ad, foto, okul) içerikte/analytics'te | D | Y | Lint, moderasyon kuralı, PostHog kısıtı | MAR-OTO-AI |
| R5 | Çocuğa yönelik reklam/hedefleme, çocuk politikası ihlali | D | Y | Hedefleme yalnız 25+ veli; çocuk hesabı "çocuklara yönelik" kararı; R-2 doğrulaması | Proje sahibi |
| R6 | Aldatıcı dark pattern (sayaç, stok, gizli ücret) | D | Y | Yasak, lint | MAR-OTO-AI |
| R7 | Resmî ortaklık/MEB/okul izlenimi | O | Y | "MEBİ ile birlikte" nötr dil; ortaklık yazılmaz; 4/8. sınıf kazanım iddiası yok | Tümü |
| R8 | Yarışma içeriğinin AI ile üretilmesi/ilişkilendirilmesi (2026 MEB hikâye yarışması) | D | Y | Yasak; Okuma modülü anılmaz | MAR-OTO-AI |
| R9 | AI üretimi metnin sayı/iddia uydurması | O | O | `olgular.json` + lint + insan onayı | MAR-OTO-AI |
| R10 | Hesap güvenliği (token, çalınma, tek kişiye bağlı) | O | Y | 2FA, yedek yönetici, API bağlama yok | Proje sahibi |
| R11 | Telif: müzik/font/stok/görsel | O | O | Yalnız telifsiz/lisanslı; kaynak notu; Nunito/Inter OFL | Üretici |
| R12 | Mağaza politikası: çocuk uygulamasında dış satın alma yönlendirmesi (Apple 3.1.1 / Google) | O | Y | Çocuk ekranında dış bağlantı yok; GÖR-081 mesaj gözden geçirme | Ana oturum |
| R13 | Landing/çocuk dilinde veli satışı karışması | O | D | 06 E3 | CRO |
| R14 | Ürün hazır değil (ödeme, hukuk, mağaza) iken trafik | Y | Y | Kapı kuralı: Y1–Y5 kapanmadan yönlendirme yok | Proje sahibi |
| R15 | Küçük ekip tükenmesi / içerik sürdürülebilirliği | Y | O | Düşük frekans, yeniden kullanım, otomasyon, durdurma kuralı | CMO |
| R16 | Yanlış nedensellik/yanlı ölçüm (çerez onaylılar) | Y | D | 13 sınırları, n<5 yetersiz | Analitik |
| R17 | Taktik havuzu uygulaması: gizli reklam, spam, otomatik DM | O | Y | 20 §6; yönetici onayı; DM otomasyonu yok | Tümü |
| R18 | Rakip/karşılaştırma iddiası (MEBİ) yanlış anlaşılması | O | O | Yalnız kamu sayfası bilgisi, nötr; tarih ve kaynak | MAR-OTO-AI |

## 2. KVKK ve çocuk verisi (hukuk onayı bekliyor)
- Aydınlatma metni, çerez, saklama süreleri, çocuk aydınlatma metni (GÖR-080), veri güvenliği formu (GÖR-083) **onaylı değil**; "KVKK uyumlu" ifadesi yasak.
- Pazarlama verisi: yalnız veli e-postası + sürümlü izin; çocuk verisi pazarlamada kullanılmaz; kullanıcı adı/okul bilgisi UTM'ye yazılmaz; PostHog çocuk/mobil yok.
- Kişisel veri içeren işler Oracle'a gönderilmez. Görüşme kayıtları: yazılı rıza, ad/çocuk adı kaydı yok.
- Veri ihlali: `docs/hukuk/VERI_IHLALI_PROSEDURU.md`.

## 3. Ticari ileti ve kanal
Kanallar ayrı kutu (e-posta/SMS/arama), sürümlü metin, `/ticari-ileti-izni`. İYS ve şirket bilgileri (unvan, MERSİS, adres, KEP) tamam olmadan toplu mesaj tasarımı "gönderilmez" statüsünde kalır. Organik sosyal paylaşım ticari ileti kapsamı dışındadır (KANAL §5.4), e-posta kapıları aynen sürer. WhatsApp: Channels/toplu mesaj izin ve platform ticari koşulları doğrulanmadı; kullanılmıyor.

## 4. Platform kuralları (yayın öncesi doğrulanacaklar; bu oturumda doğrulanmadı)
Meta reklam politikaları (çocuk/eğitim, hedefleme sınırları), Google Ads eğitim/çocuk politikası, YouTube "çocuklara yönelik" işaretleme sonuçları, Instagram yorum/DM API kuralları, Apple Kids kategorisi ve Google Play Families politikası, Apple 3.1.1 / Play ödeme politikası. Doğrulananlar: Apple etkinlik/öne çıkarma süreleri, Play in-app review kuralları (`20` §1).

## 5. Etik ikna kontrol listesi (her kampanya)
[ ] Sahte aciliyet/sayaç/stok yok [ ] Utandırma/korku yok [ ] Gerçek ve doğrulanmış sosyal kanıt yok ya da kaynaklı [ ] Çocuğa satın alma baskısı yok [ ] Fiyat/toplam/dönem birlikte [ ] Mutlak vaat (%100, garanti) yok [ ] "Bilim kanıtladı" yok [ ] Çocuk verisi/fotoğrafı yok [ ] AI etiketi gerekli mi [ ] Telif kaynağı yazılı.

## 6. Dışa dönük işlem kuralı
Yayın, e-posta/SMS gönderimi, reklam harcaması, hesap bağlama, deploy, migration, dış toplulukta paylaşım: **işe özel açık onay**. Bu çalışma onların hiçbirini yapmadı.

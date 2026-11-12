> TASLAK şablon · Sürüm: `veri-isleyen-2026-11-v1` · Avukat onayı bekliyor.
> **Ne zaman kullanılır:** Yurt içindeki ajans, serbest çalışan (tasarımcı, yazar, çağrı merkezi), muhasebeci, yazılım geliştirici gibi Hupolingo adına kişisel veriye erişen herkesle. **Yurt dışındaki** sağlayıcılarla bu şablon yetmez; Kurul'un standart sözleşmesi (değiştirilmeden) imzalanır ve imzadan sonra 5 iş günü içinde Kurum'a bildirilir (Ek A).

# Kişisel Verilerin İşlenmesine İlişkin Veri İşleyen Sözleşmesi

## 1. Taraflar
**Veri sorumlusu:** [ŞİRKET UNVANI] ("Hupolingo")
**Veri işleyen:** [UNVAN / AD SOYAD], [ADRES], [VERGİ NO/TCKN] ("İşleyen")

## 2. Konu ve kapsam
İşleyen, taraflar arasındaki [ANA SÖZLEŞME / İŞ TANIMI] kapsamında, yalnızca Ek B'de yazılı veri kategorileri, amaçlar ve süreyle, Hupolingo adına kişisel veri işler (KVKK m.12/2).

## 3. İşleyenin yükümlülükleri
3.1. Verileri yalnızca Hupolingo'nun **yazılı talimatıyla** ve sözleşme amacıyla işler; kendi amacı için kullanmaz, satmaz, üçüncü kişiye aktarmaz.
3.2. Verilere erişen çalışanlarına gizlilik yükümlülüğü getirir; erişimi ihtiyaç kadarla sınırlar.
3.3. KVKK m.12'ye ve Kurul'un "Kişisel Veri Güvenliği Rehberi"ne uygun teknik ve idari tedbirleri alır: şifreli iletim ve saklama, güçlü parola ve iki adımlı doğrulama, erişim kaydı, kişisel cihazlarda veri tutmama.
3.4. Hupolingo'nun yazılı izni olmadan alt işleyen kullanmaz; izinle kullanırsa aynı yükümlülükleri ona da yükler ve ondan sorumludur.
3.5. Verileri yurt dışına aktarmaz; aktarım gerekirse önce Hupolingo'ya bildirir ve KVKK m.9 şartları sağlanmadan aktarım yapmaz.
3.6. Bir veri ihlalini öğrendiği anda, en geç **24 saat** içinde Hupolingo'ya [KVKK E-POSTASI] üzerinden bildirir; ihlali sınırlamak için iş birliği yapar (bkz. `docs/hukuk/VERI_IHLALI_PROSEDURU.md`).
3.7. İlgili kişi başvurularında ve Kurul incelemelerinde Hupolingo'ya 5 iş günü içinde gerekli bilgiyi verir.
3.8. Hupolingo'nun makul önceden bildirimle denetim yapmasına veya bilgi istemesine izin verir.
3.9. Hupolingo adına ticari ileti gönderiyorsa yalnızca Hupolingo'nun ilettiği, İYS'den doğrulanmış listeyi kullanır; kendi listesini kullanmaz.

## 4. Sona erme
Sözleşme bittiğinde veya Hupolingo istediğinde İşleyen, verileri 15 gün içinde Hupolingo'ya iade eder veya geri getirilemez biçimde siler ve bunu yazılı olarak teyit eder. Kanunen saklaması gereken veriler bu kapsam dışındadır ve yalnızca o amaçla tutulur.

## 5. Sorumluluk
İşleyen, bu sözleşmeye veya KVKK'ya aykırılıktan doğan idari para cezası, tazminat ve masraflar dahil Hupolingo'nun uğradığı zararı karşılar. Bu madde sözleşme sona erse de geçerlidir.

## 6. Genel
Bu sözleşme ana sözleşmenin ayrılmaz parçasıdır; çelişki hâlinde kişisel veriler bakımından bu sözleşme uygulanır. [İL] mahkemeleri yetkilidir.

**Hupolingo** — Ad, unvan, imza, tarih · **İşleyen** — Ad, unvan, imza, tarih

---

## Ek A — Hizmet sağlayıcılar ve aktarım dayanağı (iç izleme tablosu) <a id="ek-a"></a>

| Sağlayıcı | Hizmet | Konum | Dayanak | Standart sözleşme imza tarihi | Kurum'a bildirim tarihi |
|---|---|---|---|---|---|
| Supabase | Veritabanı, kimlik | [BÖLGE] | KVKK standart sözleşme | [ ] | [ ] |
| Vercel | Barındırma | ABD/AB | KVKK standart sözleşme | [ ] | [ ] |
| Cloudflare | Güvenlik, Turnstile | Küresel | KVKK standart sözleşme | [ ] | [ ] |
| Brevo | E-posta | AB (Fransa) | KVKK standart sözleşme | [ ] | [ ] |
| Resend | E-posta | ABD | KVKK standart sözleşme | [ ] | [ ] |
| Google (Firebase, Drive) | Bildirim, yedek | ABD/AB | KVKK standart sözleşme | [ ] | [ ] |
| Sentry | Hata izleme | ABD/AB | KVKK standart sözleşme | [ ] | [ ] |
| PostHog | Analitik | AB | KVKK standart sözleşme | [ ] | [ ] |
| Qonversion | Abonelik | [ ] | KVKK standart sözleşme | [ ] | [ ] |
| Meta, Google Ads | Reklam (İzin 2, pazarlama çerezi) — **lansmanda kullanılmıyor (K-0256)**; standart sözleşme talebi gönderilecek | AB/ABD | KVKK standart sözleşme | [ ] | [ ] |
| [SMS SAĞLAYICI] | SMS | Türkiye | Veri işleyen sözleşmesi (bu şablon) | — | — |
| [ÖDEME KURULUŞU] | Ödeme | Türkiye | Veri işleyen sözleşmesi / ayrı veri sorumlusu | — | — |

**Pratik zorluk:** Büyük yabancı sağlayıcılar çoğunlukla AB (GDPR) standart sözleşmesi sunar; KVKK standart sözleşmesi metni değiştirilmeden imzalanmalıdır. Sağlayıcı imzalamıyorsa: (1) Türkiye/AB bölgeli alternatif, (2) avukatla Kurul'a taahhütname izni başvurusu, (3) hizmeti kapsamdan çıkarmak değerlendirilir. Açık rıza düzenli aktarım için dayanak **değildir**.

## Ek B — İşleme ayrıntıları (her işleyen için doldurulur)

| Alan | Değer |
|---|---|
| Veri konusu kişiler | [Veliler / adaylar / öğrenciler] |
| Veri kategorileri | [Kimlik, iletişim, …] |
| Amaç | [ ] |
| Süre | [ ] |
| Erişim biçimi | [Panel erişimi / dosya / API] |
| Alt işleyenler | [ ] |

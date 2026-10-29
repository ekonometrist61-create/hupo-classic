# 11 / E-posta yaşam döngüsü (TASLAK; GÖNDERİM YOK)

Durum: Taslak · Tarih: 2026-10-29 · Rol: CRM / Copywriter · Bağımlı: 12, 17, 19

**Kapılar (hepsi gerekli):** (1) İletişim izni: `/ticari-ileti-izni`, e-posta kanalı ayrı kutu, sürümlü metin, İYS/hukuk onayı; (2) şirket bilgileri (unvan, MERSİS, adres, KEP) hukuk kayıtlarında tamam; (3) E1 e-posta sağlayıcı cron'u ve E4 sıklık/sessiz saat fonksiyonu kuruldu (`ILETISIM_EKSIKLERI_PLANI`); (4) kampanya bayrağı açma ana oturum/kullanıcı onayı; (5) her gönderim insan onaylı. Bu dosya yalnız metin. **İşlemsel** e-postalar (hesap doğrulama, ödeme makbuzu) ticari ileti değildir, ayrı sınıf (hukuk teyidi). Çocuğa e-posta yok (veli adresi). Geri çıkış: her e-postada tek tıkla abonelikten çık + izin yönetim bağlantısı. Şablon alanları: `{veli_adi}` (yalnız izinle kullanılırsa; yoksa "Merhaba"), `{cocuk_adi}` **kullanılmaz**.

Gönderen: Hupolingo · Yanıt adresi: doğrulanmış destek adresi [DOĞRULA: `iletisim@hupolingo.com` yer tutucu]. Metin: ünlemsiz, kısa.

## A. Onboarding (5) — tetik: veli hesabı oluşturuldu + e-posta izni var
**A1 · T+0 (hesap sonrası, izinli)** Konu: Hupolingo'ya hoş geldiniz — ilk adım
Merhaba,
Hesabınız hazır. İlk adım çocuğunuzla eşleştirme: uygulamada çocuğunuzun ekranında görünen 6 haneli kodu veli panelinizde girin. [DOĞRULA: eşleştirme akışı adımları]
Ardından günlük hedefi (5–20 soru; varsayılan 10) siz belirleyebilirsiniz.
Bağlantı: Veli paneli (utm_source=email&utm_medium=lifecycle&utm_campaign=onb&utm_content=a1)
Hupolingo pilot sürümde; görüşleriniz bizim için değerli.
— Hupolingo ekibi · Abonelikten çık · İzin tercihleri
**Çıkış koşulu:** eşleştirme tamamlandı → A2'ye geçme, B akışı.

**A2 · T+2 gün (eşleştirme yoksa)** Konu: Çocuğunuzla eşleştirme tek adım
Eşleştirme yapılmadıkça çocuğunuzun çalışması veli panelinde görünmez. Kod nerede? (3 adım, ekran görüntüsü). Takılırsanız bu e-postayı yanıtlayın.

**A3 · T+5 gün (eşleşti, ilk oturum yok)** Konu: İlk 10 soru için küçük bir öneri
İlk görev için yalnız 5 soruluk hedef deneyebilirsiniz; başlamak bitirmekten kolaydır. Çocuğunuz hazır olduğunda uygulamada "Başla" yeterli. Baskı kurmadan, bir sonraki gün kaldığı yerden devam edebilir.

**A4 · İlk oturum sonrası (olay: ilk oturum tamamlandı)** Konu: İlk görev tamamlandı
Çocuğunuz ilk görevini tamamladı. Veli panelinizde ders bazında özet ve tekrar önerisi görünür. Az veriyle yüzde göstermediğimizi unutmayın; birkaç oturum sonra özet netleşir. [Sayı yok.]

**A5 · T+14 gün (aktif ise)** Konu: İki haftalık küçük bir not
Geçen iki hafta için panel özetine göz atın. Yararlı bulduğunuz ve bulmadığınız şeyleri iki dakikada bize yazın (yanıtla). Yanıtlar çocuk bilgisi içermeyecek şekilde yalnız ürün geliştirme için okunur.

## B. Premium geçiş (5) — **yalnız ödeme canlı + plan kaydı + hukuk onayı sonrası; "ücretsiz deneme" ifadesi yok**
**B1 · Veli panelinde özet görüldükten sonra (izinli)** Konu: Planlar hakkında bilgi
Planlar ve kapsam veli panelinizde. Tutar ve dönem ödeme öncesi görünür; ödeme tek seferliktir, otomatik yenileme yoktur. [DOĞRULA]
**B2 · Sınır dolduğunda (veli bilgilendirmesi, olay: günlük hak doldu)** Konu: Bugünlük hak doldu
Çocuğunuz bugünlük soru hakkını kullandı; yarın yeniden açılır. İsterseniz plan seçeneklerini inceleyebilirsiniz. (Çocuk ekranında satın alma yönlendirmesi yok.) [Sınır sayısı kayıttan.]
**B3 · Deneme bitişi T-3 (pilot hane, admin denemesi)** Konu: Denemeniz sona eriyor
Hesabınıza tanımlanan deneme erişimi {bitis_tarih} tarihinde sona erecek. Otomatik ücret alınmaz. Devam etmek isterseniz planı siz seçersiniz. (Kaynak: DENEME_SINIR_KURALI §5 metin; hukuk onayı bekliyor)
**B4 · Deneme bitti** Konu: Denemeniz sona erdi
Ücret alınmadı. İlerleme verisi ve tekrar listesi açık kalır. [DOĞRULA]
**B5 · Ödeme sonrası** (işlemsel sınıf, ticari değil) Konu: Ödemeniz alındı — nasıl kullanılır
Makbuz bilgisi ve kullanım özeti. Ticari ek teklif eklenmez.

## C. Geri kazanım (5) — hareketsiz veli (örn. son oturum üzerinden uzun süre geçti; eşik 13'te tanımlı)
**C1 · Nazik hatırlatma** Konu: Çocuğunuzun görevi sizi bekliyor — baskı yok
Bir süredir yeni görev yok. Küçük bir görevle yeniden başlayabilirsiniz; 5 soru yeter. İsterseniz günlük hedefi düşürün.
**C2 · Değer özeti** Konu: Panelde sizi bekleyen özet
Son çalışma özetiniz ve tekrar listesi panelde duruyor. (Sayı: yalnız gerçek veriden, kişisel veriye girmeden; veri yoksa metne sayı koyma.)
**C3 · Soru** Konu: Neden ara verdik? (2 dakika)
Tek sorulu mini anket: zaman, ilgi, teknik sorun, diğer (serbest yanıt alma yok, analytics'e taşıma). 
**C4 · Rehber içeriği** Konu: Çocuklar için tekrar rutini üzerine kısa bir yazı
Blog bağlantısı (rehber 3/9). Ürün satışı yok.
**C5 · Veda ve izin tercihleri** Konu: Size daha az yazalım mı?
Sıklığı azalt veya aboneliği bitir. Kesinti olursa verileriniz saklama politikasına göre. [Saklama süresi hukuk onayı bekliyor, sayı yazma.]
**Sıklık sınırı (öneri):** haftada en fazla 1 ticari e-posta; sessiz saat 21:00–09:00; C akışı toplam 5 e-posta, ardından 90 gün sessizlik.

## Ölçüm
Gönderim/açılma/tıklama `growth_message_log` yazıcısı (E3) kurulunca; açılma oranı güvenilir ölçü değil (Apple Mail Privacy Protection, Hipotez). Ana metrik: tıklama → panel görüntüleme → görev; koruma: abonelikten çıkış ve şikâyet.

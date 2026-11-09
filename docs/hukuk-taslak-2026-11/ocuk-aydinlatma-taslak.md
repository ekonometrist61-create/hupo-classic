> Hukuk onayı bekliyor, yayın yok. (GÖR-080 taslağı; hukuki görüş değildir, KVKK avukatı onayı gerekir.)

# Çocuk aydınlatma metni: eksik analizi ve taslak

Karşılaştırılan kaynaklar:
- Mobil: `mobile-app/lib/content/privacy_notice.dart` (`kPrivacyNoticeVersion = '2026-09-taslak-1'`, 5 kısa bölüm)
- Web: `web-panel/src/lib/legal/content.ts` (`privacySections`: veri sorumlusu, işlenen veriler, hukuki sebep, çocuklar, rıza, aktarım, yurt dışı, saklama, güvenlik, haklar, başvuru)

## 1) Eksik analizi (mobil metin web metnine göre)

| Konu | Mobil metin | Web metni | Sonuç |
|---|---|---|---|
| Veri sorumlusu (unvan, adres, MERSİS, e-posta, KEP, VERBİS) | Yok | Var ama tamamı yer tutucu | Mobilde eksik; web'de bilgi bekliyor |
| Aktarım alıcıları | "Sen ve velin görebilir" (yalnız uygulama içi görünürlük). Hizmet sağlayıcılar anılmıyor | Supabase, Vercel, iyzico, İleti Merkezi, Brevo, Resend, Cloudflare, PostHog, Sentry, FCM, Google Drive, mağazalar | Mobilde eksik. Ayrıca "seni takip eden araçlar yok" ifadesi Sentry/Turnstile/FCM ile birlikte gözden geçirilmeli (aşağıda) |
| Yurt dışına aktarım | Yok | Var, dayanak yer tutucu | Mobilde eksik; dayanak hukukçuya bağlı |
| Saklama süreleri | Yok | Var, birçok süre `[X GÜN]` | İkisinde de eksik; süreler karar bekliyor |
| Hukuki sebep | Yok | Var (m.5/2-c, ç, f; veli onayı) | Mobilde eksik |
| KVKK başvuru yolu / Kurul'a şikâyet | Yok (yalnız "Ayarlar'dan kopyala/sil") | Var, iletişim bilgileri yer tutucu | Mobilde eksik |
| Veli onayı ve geri çekme | Var (kısa) | Var | Tutarlı |
| Girişte işlenen veriler (giriş olayı, 180 gün) | Yok | Yok | İkisinde de eksik; kaynak: `supabase/migrations/20261107000000_giris_olaylari.sql` (kullanıcı kimliği, rol, kanal, zaman; doğrulanmadı: canlıda uygulanıp uygulanmadığı) |
| Bildirim belirteci | Yok | Var | Mobilde eksik |
| Hata raporu (Sentry) | Yok | Var | Mobilde eksik |
| Bot kontrolü (Turnstile) | Yok | Var | Mobilde eksik |
| Meydan okuma verisi | Yok | Yok | İkisinde de eksik |

Ek tutarsızlıklar:
- Mobil "Uygulamada ... seni takip eden araçlar yok" diyor; kod Sentry (hata), FCM (bildirim) ve Cloudflare Turnstile (kayıt) içeriyor. Bunlar reklam/takip aracı değil, ancak ifade "kesin" olduğu için hukukçu onayıyla "reklam amaçlı takip yok" gibi daraltılması önerilir.
- Web "çocuk 3-7. sınıf" diyor; proje talimatında 2026-27'de 4 ve 8. sınıf farklı program notu var. Hedef kitle ifadesi ürün kararıyla netleştirilmeli (doğrulanmadı).
- Web metni çocuğun giriş e-postasının "veli tarafından oluşturulduğunu" söylüyor; mobil kayıt kodu (`lib/auth/signup.dart`) çocuğun kendisinin kayıt olabildiğini gösteriyor. İki metin birbirine uymuyor, hangisinin doğru olduğu doğrulanmalı.
- Web, ödeme için yalnız iyzico yazıyor; hafızadaki karar PayTR/Param yönünde. Kodda (`supabase/functions`) yalnız iyzico görüldü (doğrulanmadı: yayında hangisi aktif).

## 2) Önerilen taslak metin (çocuğa sade dil; sürüm `2026-11-taslak-2` olarak önerilir, kod değiştirilmedi)

**Bu bildirimi kim hazırladı? (Veri sorumlusu)**
Hupolingo'yu [DOLDURULACAK: şirket unvanı] işletir. Adres: [DOLDURULACAK: adres]. MERSİS no: [DOLDURULACAK: MERSİS]. E-posta: [DOLDURULACAK: iletişim e-postası]. KEP: [DOLDURULACAK: varsa]. Veri Sorumluları Siciline kayıt: [DOLDURULACAK: VERBİS kaydı veya muafiyet, hukukçu teyidi].

**Hangi bilgilerini tutuyoruz?**
Adını (veya takma adını), sınıfını, giriş e-posta adresini, çözdüğün soruları ve cevaplarını, XP, seviye, seri ve rozetlerini, deneme sonuçlarını tutuyoruz. Bildirim izni verirsen bildirim göndermek için cihazının bildirim kodunu da tutarız. Giriş yaptığında güvenlik için girişin zamanını kaydederiz [DOLDURULACAK: giriş kaydının doğrulanması ve süresi].

**Bunları neden kullanıyoruz ve buna hakkımız ne?**
Sana uygun soruları göstermek, ilerlemeni hesaplamak ve velinin gelişimini görebilmesi için kullanıyoruz. Hesabın ve öğrenme hizmeti için bu bilgiler gereklidir. Hukuki dayanak ve çocuğa ait işlemlerde veli onayının kapsamı: [DOLDURULACAK: hukukçu teyidi].

**Bilgilerini kimler görür?**
Sen ve velin görebilirsin. Diğer öğrenciler adını veya bilgilerini göremez; ligde yalnızca isimsiz sıra numaran görünür. Uygulamayı çalıştırmamıza yardım eden şirketler bilgilerine yalnızca hizmeti sunmak için erişir: veritabanı ve giriş (Supabase), hata izleme (Sentry; kişisel bilgiler temizlenir), bildirim (Google Firebase), bot koruması (Cloudflare) ve e-posta gönderimi (Brevo, Resend) [DOLDURULACAK: güncel alıcı listesi, kodla ve sözleşmeyle teyit]. Bu şirketlerin bir kısmı bilgileri Türkiye dışında işleyebilir; dayanak: [DOLDURULACAK: KVKK m.9 aktarım dayanağı]. Bilgilerini satmayız.

**Reklam ve takip var mı?**
Uygulamada reklam yok ve seni reklam için takip eden araç kullanmıyoruz. [DOLDURULACAK: hukukçu, Sentry/FCM/Turnstile nedeniyle ifadeyi onaylamalı.]

**Bilgilerini ne kadar saklıyoruz?**
Hesabın açık olduğu sürece. Hesabını silersen bilgilerin [DOLDURULACAK: X gün] içinde silinir veya kimliği belirsiz hale getirilir. Yedekler en çok 30 gün sonra silinir (web metnindeki ifade; doğrulanmadı). Giriş kayıtları [DOLDURULACAK: 180 gün, migration'a göre; teyit]. Hata kayıtları [DOLDURULACAK: süre].

**Haklarını nasıl kullanırsın?**
Ayarlar bölümünden bilgilerini kopyalayabilir ve hesabını silebilirsin. Velin veli panelinden onay verebilir veya onayını geri çekebilir. Bilgilerinin işlenip işlenmediğini sorabilir, düzeltilmesini veya silinmesini isteyebilirsin. Bunun için velinle birlikte [DOLDURULACAK: e-posta], [DOLDURULACAK: KEP] veya [DOLDURULACAK: adres] üzerinden bize yazabilirsin. Başvurular en geç 30 gün içinde sonuçlandırılır. Yanıtı yetersiz bulursan Kişisel Verileri Koruma Kurulu'na şikâyette bulunabilirsin.

## 3) Karar / onay gereken noktalar
1. Veri sorumlusu bilgileri (unvan, MERSİS, adres, KEP, VERBİS durumu).
2. Yurt dışı aktarım dayanağı ve Supabase sunucu bölgesi.
3. Saklama süreleri (hesap silme sonrası, hata raporu, analitik, giriş kaydı).
4. Çocuk verisinde rıza modeli ve yaş eşiği; kodda `record_notice_read` / `set_parental_consent` var, hangi rızanın gerektiği avukata bağlı.
5. Çocuğun kendi başına kayıt olması (kodda var) ile web metnindeki "veli tarafından oluşturulur" ifadesinin uyumu.
6. Yayınlanırsa `kPrivacyNoticeVersion` artırılır (şu an değiştirilmedi), web `content.ts` ile birlikte güncellenir.

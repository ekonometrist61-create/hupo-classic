# Yayın Denetimi (Launch Checklist)

Tarih: 9 Ekim 2026. Kapsam: `mobile-app/` (Flutter), `web-panel/` (Next.js), `supabase/`.
Yöntem: her madde için kod/konfigürasyon kanıtı tarandı; "✅" yalnızca kodda kanıtlanmış
maddeler için kullanıldı. Cihaz üzerinde manuel test yapılmadı.

Durum anahtarı: ✅ tamam · ⚠️ kısmi / doğrulama bekliyor · ❌ eksik · ➖ uygulanamaz (bilinçli)

## Bu turda yapılan geliştirmeler

| Alan | Değişiklik | Dosyalar |
|---|---|---|
| Web kayıt | Gönderme işleyicisi olmayan TailAdmin şablon formu gerçek veli kaydı oldu (`role: "veli"`, en az 8 karakter, gizlilik/koşul onayı, doğrulama e-postası akışı). Sahte Google/X butonları kaldırıldı. | `web-panel/src/components/auth/SignUpForm.tsx` |
| Parola sıfırlama (web) | `/sifre-unuttum` (bağlantı isteği) ve `/sifre-yeni` (PKCE `code` ve hash akışı). Giriş ekranına "Parolanı mı unuttun?" bağlantısı. | `web-panel/src/components/auth/ForgotPasswordForm.tsx`, `ResetPasswordForm.tsx`, `SignInForm.tsx`, `app/[locale]/(full-width-pages)/(auth)/sifre-*` |
| Parola sıfırlama (mobil) | Giriş ekranından web sayfasına yönlendirme. Sıfırlama web'de başlatılır çünkü mobil PKCE doğrulayıcısı bağlantıyla eşleşmez. | `mobile-app/lib/auth/login.dart`, `lib/services/web_links.dart`, `lib/config/env.dart` |
| Yasal sayfalar | `/gizlilik` ve `/kosullar` (TASLAK, avukat onayı bekliyor). Footer'daki `href="#"` bağlantıları gerçek sayfalara bağlandı. Mobil ayarlara "Kullanım koşulları" satırı eklendi. | `web-panel/src/lib/legal/content.ts`, `components/legal/LegalDocument.tsx`, `app/[locale]/(full-width-pages)/gizlilik`, `kosullar`, `components/landing/Footer.tsx`, `mobile-app/lib/screens/settings_screen.dart` |
| Hata yakalama | Yakalanmamış Flutter/platform hataları tek noktadan geçiyor; yalnızca hata türü ve yığın izi loglanır (mesaj PII içerebileceği için loglanmaz). | `mobile-app/lib/services/error_reporting.dart`, `lib/main.dart` |
| Lint | `.netlify/` derleme çıktısı lint kapsamından çıkarıldı (önceden 103 hata bu çıktıdan geliyordu). `src/` lint: 0 hata. | `web-panel/eslint.config.mjs` |
| Test | Giriş ekranında parola sıfırlama bağlantısını doğrulayan widget testi. | `mobile-app/test/auth_password_reset_test.dart` |

Doğrulama:
- `web-panel`: `npm run build` başarılı (yeni rotalar üretildi), `npx tsc --noEmit` temiz, `npm run lint` 0 hata / 13 önceden var olan uyarı.
- Tarayıcı kontrolü (production sunucusu, konsol hatası ve başarısız istek yok): `/tr/signup`, `/tr/signin`, `/tr/sifre-unuttum`, `/tr/gizlilik` doğru Türkçe metinle render oldu; "Parolanı mı unuttun?" giriş ekranında görünüyor; eski İngilizce şablon metinleri (`Sign up with Google`, `Terms and Conditions,`) yok. Mobil genişlikte (390px) kayıt formu düzgün göründü.
- `mobile-app`: `flutter test` ilgili 3 test dosyası + yeni test: tümü geçti (37/37 ilgili test). `flutter analyze` 24 hata veriyor (aşağıda, bu turda değiştirmediğim dosyalardan).

## Madde madde durum

### Ana liste

| Madde | Durum | Kanıt / açıklama |
|---|---|---|
| Kullanıcı izinleri | ✅ | Android manifest yalnızca `INTERNET` izni içeriyor. |
| Gizlilik politikası | ⚠️ | Uygulama içi taslak (`lib/content/privacy_notice.dart`) ve web `/gizlilik` taslağı var. Herkese açık URL henüz yok; şirket unvanı, iletişim, sunucu bölgesi, saklama süresi yer tutucu. Avukat onayı gerekli. |
| Hesap silme | ⚠️ | Uygulama içi: Ayarlar > "Hesabımı sil" (SİL onayı ile), `delete_my_account` `auth.users` kaydını siler, ilişkili veriler cascade ile gider. Google, web üzerinden silme talebi bağlantısı isteyebilir: henüz yok. |
| Veri güvenliği | ⚠️ | `mobile-app/store/VERI_GUVENLIGI_VE_GIZLILIK.md` taslağı hazır. Form henüz gönderilmedi; Firebase/FCM kullanımı da beyan edilmeli. |
| Kayıt ve giriş | ✅ | Mobil giriş/kayıt; web'de artık gerçek veli kaydı. |
| E-posta doğrulama | ⚠️ | Mobil ve web kayıt sonrası doğrulama mesajı gösteriyor, "e-posta doğrulanmadı" hatası Türkçe. Yeniden gönderme düğmesi yok. Canlı Supabase "Confirm email" ayarı repodan doğrulanamıyor (`config.toml` yalnızca yerel ortam, `enable_confirmations = false`). |
| Şifre sıfırlama | ⚠️ | Kod tamam (web). Canlı Supabase URL ayarlarına `https://<alan-adı>/sifre-yeni` ve `/sifre-unuttum` eklenmeli (dış adım). |
| Onboarding | ❌ | Karşılama ekranı ve giriş/kayıt var; öğrenci için tanıtım akışı yok. Ürün kararı gerekiyor. |
| Ana kullanıcı akışı | ⚠️ | Kod ve widget testleri mevcut; gerçek cihaz akışı test edilmedi. |
| Verilerin kaydı | ✅ | Soru cevabı idempotent RPC (`submit_answer`); kaydedilemezse sonuç sayfasında uyarı gösteriliyor. |
| Ödeme ve abonelik | ⚠️ | Ödeme web panelinde (iyzico), tutar sunucudan alınıyor, callback sunucudan doğrulanıyor. Çocuk uygulamasında satın alma düğmesi yok (bilinçli). Ancak profilde "Premium hakkında" `hupolingo.com/premium` bağlantısı var; mağaza politikası açısından bir ürün/hukuk kararı gerekiyor. |
| Satın alımları yükleme | ➖ | Mobilde uygulama içi satın alma yok; geri yükleme gerekmiyor. |
| Yükleniyor ekranları | ✅ | `HupoLoading` ve yükleme durumları çok sayıda ekranda (ör. 34 dosya). |
| Boş ekranlar | ⚠️ | Birçok ekranda boş durum var; ekran başına sistematik kontrol yapılmadı. |
| Hata ekranları | ⚠️ | Snackbar ve satır içi hata mesajları var. Bakım/sürüm kapısı yapılandırma hatasında bilerek açık kalıyor (fail-open). |
| İnternet bağlantısı | ❌ | Bağlantı kesildiğinde genel mesaj gösteriliyor; çevrimdışı tespiti ve bildirim şeridi yok (`connectivity_plus` yok). |
| Bildirimler | ⚠️ | Push kodu, outbox ve tercihler var; ancak `firebase_core`/`firebase_messaging` `pubspec.yaml`'da yok (aşağıdaki blokaj). Firebase projesi kurulmadan push kapalı kalır. |
| Analytics ve crash | ⚠️ | Mobil çökme raporlama (Sentry) kodda; DSN verilmeden kapalı (`--dart-define=SENTRY_DSN`). Olaylarda kişisel veri gitmez (kullanıcı bilgisi yok, mesaj/istisna metni gizli, breadcrumb yok). Web panel için çökme raporlama henüz yok. Analitik: ❌ — hangi araç ve çocuk verisi için hangi rıza modeli olacağı kararı bekliyor. |
| Farklı cihazlar | ⚠️ | `ResponsivePage` yaygın kullanılıyor; tablet/küçük ekran testi yapılmadı. Web kayıt formu 390px'te doğrulandı. |
| Gerçek kullanıcı testi | ❌ | Yapılmadı. Store kontrol listesindeki "release APK gerçek telefonda" maddesi bekliyor. |

### Diğer önemli maddeler

| Madde | Durum | Açıklama |
|---|---|---|
| Erişilebilirlik | ⚠️ | Semantics birçok widget'ta; yazı boyutu (0.8–2.0) ve "hareketi azalt" ayarı var; web formlarında etiketler bağlı. Kontrast ve ekran okuyucu denetimi yapılmadı. |
| Yerelleştirme (i18n) | ⚠️ | Mobil yalnızca `tr` (`main.dart`). Web `tr`/`en`; yasal sayfalar bilinçli olarak yalnızca Türkçe (hukuki çeviri ayrıca onaylanmalı). |
| Karanlık/aydınlık mod | ➖ | Kapsam dışı bırakıldı (ürün kararı). |
| Şartlar ve koşullar | ⚠️ | Taslak hazır (`/kosullar`, mobil bağlantı). Avukat onayı ve yer tutucular gerekli. |
| Çerez / KVKK rıza | ⚠️ | Web'de analitik veya takip betiği yok; çerez onay bandı şu an gerekmiyor (yalnızca zorunlu oturum çerezleri). Analitik eklenirse banner zorunlu. Ticari ileti rızası: kayıt formunda işaretsiz ayrı kutu; rıza e-posta doğrulanınca yazılır; iptal `/iletisim-izni` sayfasından ve veli panelinden; her değişiklik değiştirilemez geçmişe işlenir. Migration henüz canlıya uygulanmadı ve yerelde çalıştırılamadı. |
| Performans ve kaynak | ⚠️ | Ses ön yüklemesi var; ölçüm (pil, RAM, açılış süresi, APK boyutu) yapılmadı. |
| ASO ve mağaza varlıkları | ⚠️ | `mobile-app/store/` altında metinler ve ikon kaynakları var. Gerçek ekran görüntüleri ve yaş derecelendirmesi henüz yok. iOS mağaza URL'i yer tutucu (`id000000000`). |
| Deep linking | ❌ | Yalnızca launcher intent-filter var. Uygulama bağlantıları için alan adı doğrulaması (assetlinks/apple-app-site-association) gerekiyor. |
| Güvenlik ekleri | ⚠️ | Rate limit: Supabase Auth'un kendi limitleri var, uygulama katmanında yok. SSL pinning yok (Supabase anahtar rotasyonunu zorlaştırdığı için önerilmiyor). Kod obfuscation (`--obfuscate`) build komutunda kullanılmıyor. |
| Zorunlu sürüm güncellemesi | ✅ | `MaintenanceGate` `get_app_config.min_surum` değerini uygulama sürümüyle karşılaştırıyor ve güncelleme ekranı gösteriyor (test var). iOS mağaza URL'i yer tutucu. |

## İkinci tur (9 Ekim): parola, rıza, iptal, çökme raporlama

- Parola: mobil kayıt ve web kayıt en az 8 karakter; `supabase/config.toml` `minimum_password_length = 8`. Canlı Supabase ayarı ayrıca güncellenmeli.
- Kayıt rızası: web kayıt formunda ticari ileti kutusu işaretsiz. Rıza, e-posta doğrulandığında `iletisim_tercihleri` ve `iletisim_tercih_gecmisi` tablolarına yazılır (migration `20261015000000`). Öğrenci hesaplarına ticari ileti rızası yok.
- İptal: `/iletisim-izni` herkese açık sayfası (hesap olsun olmasın aynı yanıt). Veli panelinde "İletişim izinlerim" kartı. İptal, hesap varsa kanal iznini kaldırır ve geçmişe yazar; her durumda e-posta karması `growth_prospect_suppressions` listesine eklenir (ham e-posta tutulmaz).
- Gönderim kuralı: repoda henüz e-posta gönderen bir worker yok. Gönderim eklendiğinde `ticari_iletisim_engelli_mi(email)` ve `iletisim_tercihleri.izin` gönderim anında kontrol edilmeli.
- Çökme raporlama (mobil): Sentry, DSN verilmeden kapalı. Kod ve birim testi hazır.

Doğrulanamayanlar: migration yerel Postgres olmadığı için çalıştırılamadı; web build ve testler ayrıca çalıştırıldı (sonuçlar oturum notlarında).

## Bu turda çözülmeyen blokajlar

1. **`flutter analyze` 24 hata veriyor (önceden var).** Kaynak: `lib/ads/student_banner_ad.dart` (`google_mobile_ads`) ve `lib/services/push/push_backend_firebase.dart` (`firebase_core`, `firebase_messaging`). Bu iki dosya hiçbir yerden import edilmiyor, yani derlemeye girmiyor; ama paketler `pubspec.yaml`'da yok. Karar gerekiyor:
   - Önerim: Firebase projesi kurulunca (`docs/PUSH_KURULUM.md`) `firebase_core` ve `firebase_messaging` eklemek.
   - Reklam paketini eklemeyin: `google_mobile_ads` için AndroidManifest'te AdMob uygulama kimliği meta-data'sı olmadan uygulama açılışında çökme riski var. Reklamlar kapalı olduğu için dosyanın kaldırılması veya kurtarma klasörüne taşınması daha güvenli.
2. **Canlı Supabase ayarları** (repodan doğrulanamaz): e-posta onayı, redirect URL'leri, SMTP.
3. **Yasal metinler**: şirket unvanı, iletişim e-postası, sunucu bölgesi, saklama süresi, iade/iptal koşulları, uygulanacak hukuk. Taslaklar açık uyarıyla yayınlanıyor; avukat onayı olmadan yayınlanmamalı.
4. **Footer'daki "Hakkımızda", "Blog", "İletişim" bağlantıları** hâlâ `href="#"`; içerik ve iletişim bilgisi olmadan bağlanamadı.
5. **Mağaza kararları**: "Premium hakkında" bağlantısı, Google Play'in dijital ürün ödeme politikası açısından gözden geçirilmeli.

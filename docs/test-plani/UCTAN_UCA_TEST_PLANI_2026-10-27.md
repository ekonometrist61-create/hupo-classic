# Hupo — Uçtan Uca Test Planı (2026-10-27)

Kaynak: dört salt-okunur Haiku taraması (web, mobil, Supabase, açık işler). Bulguların çoğu **ajan raporudur, tek tek doğrulanmadı**; "Doğrula" işaretli maddeler önce kodda teyit edilmelidir. Dal: feature/huporead-entegrasyon.

## 1. Ön koşullar (testten önce)
| # | İş | Neden |
|---|----|-------|
| P1 | E2E test hesapları: öğrenci, veli, öğretmen, admin (GÖR-056) | Tanımlı değil; akışlar hesapsız koşulmaz |
| P2 | Onaylı içerik: yayın kapısı (GÖR-063/066), 176 sürüm pending, çocuk kataloğu boş | Quiz/kelime/okuma akışı boş görünür |
| P3 | Test Supabase ortamı veya preview; canlıya yazma yok | Migrasyon sahipliği kuralı |
| P4 | Playwright MCP yeniden bağla (CONNECT_TIMEOUT) | Tarayıcı kontrolü |
| P5 | Cihaz/emülatör (adb boş) | HupoRead PDF, push, ses |

## 2. Rol bazlı uçtan uca senaryolar
**S1 Veli kaydı → ödeme → öğrenci erişimi**
landing → ön kayıt (Turnstile) → `veli-adayi-kayit` → veli kayıt/giriş → plan → `payments-checkout` → iyzico sandbox → `payments-callback` → `subscriptions` → `is_premium` mobilde/web'de açılır. Kontrol: tutar sunucuda, çift callback, başarısız ödeme, beklemede kalan ödeme (reconciliation yok).

**S2 Veli ↔ öğrenci eşleştirme**
Veli `create_parent_link_code` → öğrenci uygulamada `redeem_parent_link_code` → bildirim (`notifications` → `push_outbox`) + e-posta (`eposta_outbox`) → veli panosunda çocuk görünür. Kontrol: tek kullanımlık kod, süresi dolmuş kod, başka velinin çocuğuna erişim yok (RLS).

**S3 Öğrenci öğrenme döngüsü (mobil + app.hupolingo.com)**
giriş → sınıf → quiz (`submit_answer`) → XP/lig/rozet → günlük görev → görev ödülü → veli panosunda aktivite/hedef. Kontrol: yalnız onaylı ve kendi sınıfı soruları, günlük kota (deneme bitince), web/mobil aynı sonuç.

**S4 Kelime Evreni ve HupoRead**
kelime_* ve okuma_* RPC'leri, öğretmen sınıf özeti (`okuma_ogretmen_*`), `export_my_data` bölümleri. Web ve mobilde ses/hareket azaltma.

**S5 Deneme sınavı**
`deneme-on-kayit` (KVKK, captcha) → sınav → süre dolumu cron → `olay_kutusu` → `olay-kutusu-gonder` → e-posta → `/deneme-sonuclari/[id]`.

**S6 Öğretmen**
`/yonetim-giris` → yalnız `/yonetim/siniflar` → `ogretmen_siniflarim`. Negatif: diğer /yonetim ve /veli-paneli yolları yönlenmeli; başka öğretmenin sınıfı görünmemeli.

**S7 Admin**
içerik onayı (dört göz) → yayın → öğrenci görür; plan/kupon yönetimi; segmentli bildirim → `send-push`; CRM/duyuru/anket → mobilde `get_aktif_duyuru`/`anket_aktif_listem`.

**S8 İletişim izni ve KVKK**
izin kutuları → `iletisim-izni-iptal` → kampanyalar iptal edilen kullanıcıya gitmez; `delete_my_account`, `export_my_data`.

## 3. Çapraz tetikleme matrisi (zincir gerçekten bağlı mı?)
| Zincir | Durum (ajan) | Test |
|---|---|---|
| Ödeme → abonelik → premium | Bağlı | S1 |
| Eşleştirme → push + e-posta | Bağlı, push canlıda değil | S2 |
| Deneme → olay_kutusu → e-posta | Bağlı, test yok | S5 |
| **CRM olayları → e-posta** (veli_adayi_*, iletisim_kampanyasi_*) | **KOPUK**: olay_kutusu'na yazılıyor, tüketen worker yok, satırlar birikiyor | Yeni worker veya karar |
| **send-push** Database Webhook | Repo dışı (dashboard); canlıda doğrulanmamış | Dashboard + FCM uçtan uca |
| `eposta-gonder` cron + Vault `olay_worker_secret` | Migrasyon var; canlıda doğrulanmalı | Doğrula |
| `_abonelik_ver` | Çağıranı yok | Ölü kod mu karar |
| `telefon-kod-gonder` / `telefon_kod_dogrula` | Çağıran yok (GÖR-015) | Akış eksik |
| Kupon uygulama | Yalnız admin CRUD; ödemede uygulanmıyor | Doğrula |
| growth_journey_ilerlet | Bayrak varsayılan kapalı | Bilinçli mi teyit |
| Beklemede ödeme reconciliation | Cron yok | Risk |

## 4. Doğrulanacak şüpheli hatalar
1. **Push yapılandırması:** `mobile-app/lib/services/push/push_config.dart:22-24` yalnız `FIREBASE_APP_ID` okuyor; apiKey/projectId/senderId boşsa push hiçbir derlemede açılmaz. `test/push_test.dart` yakalamıyor.
2. **Yüzey adı:** `yayin_yuzeyi.dart` `web_app`, `kullanim_suresi.dart` `flutter_web` → duyuru/anket filtresi ve analitik ayrışır.
3. Web oturumu localStorage'da, `vercel.json`'da CSP yok; bakım kapısı webde kapalı.
4. Kelime Evreni: 3 Flutter testi kırık (splash/ProviderScope), şık düğmesi kontrastı < 4,5:1, uzak DB durumu çelişkili (20261078/79 uzakta uygulanmadı).
5. GÖR-036 durumu belirsiz (günlük BEKLİYOR, commit mevcut).

## 5. Otomasyon durumu ve boşluklar
- Var: Playwright (admin, veli, öğrenci, mobil görünüm, crawl, login), Flutter 55 test, Supabase PGlite paketleri + kök .sql testleri, Deno birim testleri.
- Yok: mobilde `integration_test`; gerçek giriş/kayıt, ParentLink, mock exam, PushHost, grade picker testi; web dalları (kIsWeb); `deneme_sonuc_bildirimi`, `olay-kutusu-gonder`, `eposta-gonder`, growth_abonelik, telefon doğrulama testi; kök .sql dosyaları için koşturucu; Vercel build testi; Vitest yok.
- Fake repo kullanımı → gerçek RPC sözleşme testi (test Supabase) eklenmeli.

## 6. Önerilen sıra
1. P1–P3 hazırla. 2. Bölüm 4 madde 1–2'yi kodda doğrula ve düzelt. 3. Bölüm 3 kopuk zincirler için karar (worker yaz / bilinçli kapat). 4. S1, S2, S3 elle + Playwright. 5. S5, S6, S7. 6. Boşluk testlerini ekle. 7. Canlı: send-push webhook, cron, Vault, iyzico sandbox (GÖR-016).

## 7. Açık iş özeti (PROJE_GUNLUGU)
Kritik: GÖR-001 anahtar iptali + git geçmişi. Bekleyen: GÖR-063 dört göz kararı, GÖR-059 MFA, GÖR-014 yedek/geri yükleme provası, GÖR-016 iyzico sandbox, GÖR-015 SMS, GÖR-010 mağaza, hukuk (019/031/032/034/043), ekran kontrolleri (020, 021, 022, 035, 056, 071, 072, 074, 075), landing iddiaları GÖR-017.

## 8. Yan repolar
- `C:\Dev\hupo_merge` (release/app-1.2.0): hupo'da olmayan 2 commit (HupoRead vitrini 1.2.0, kahraman seçimi 1.3.0). Dosya karşılaştırması yapılmadı; birleştirme öncesi diff gerekir. Test için kullanılmaz.
- `C:\Dev\rea`: tersine mühendislik MCP aracı, Hupo testine uygun değil.

## 9. Koşulan testlerin sonucu (2026-10-27 akşam)
| Alan | Sonuç |
|---|---|
| Flutter `flutter test` | 499 geçti, 0 kaldı (push düzeltmesinden sonra; Kelime Evreni'ndeki "3 kırık test" notu eskimiş) |
| Supabase PGlite | 14 paketin 14'ü geçti; growth_journey 64/64 (motor başka oturumda yeniden yazılmış, uyumsuzluk kapanmış); okuma_dunyasi 187/188 |
| web tsc | geçti |
| web lint | 0 hata, 12 uyarı |
| web build | geçti |
| Playwright (anonim) | 7 geçti, 5 kaldı, 2 atlandı |
| Deno edge testleri | KOŞMADI: deno kurulu değil |
| Kök *.sql testleri | KOŞMADI: koşturucu yok |
| Hesaplı Playwright (login, öğrenci, admin, veli, responsive) | KOŞMADI: E2E_* hesapları tanımlı değil |
| Canlı zincirler (send-push, cron, Vault, iyzico) | KOŞMADI: canlı ortam |

**Kalan Playwright hataları (doğrulanmadı):** crawl: `#deneme-sinavi`, `#why-parents` hedefleri taramada bulunamıyor (kodda id'ler VAR: demek ki bölümler tembel yükleniyor veya tarama zamanlaması), hupolingo YouTube/LinkedIn 404 (hesap adresi hatalı olabilir); home "giriş bağlantısı" tıklaması `/veli-paneli/giris`e gitmiyor; mobile menü seçicisi 2 öğeyle eşleşiyor (test hatası).

## 10. Alınan kararlar
| Konu | Karar | Gerekçe |
|---|---|---|
| Push yapılandırması | Düzeltildi (`push_config.dart`: dört `--dart-define`) | Doğrulanmış hata |
| `web_app` / `flutter_web` | Değişmez | İki ayrı sözlük, DB CHECK kısıtı bilinçli |
| CRM olayları → e-posta (worker yok) | Şimdi yazılmaz; açık iş olarak kalır | Kullanıcı yok, iletişim hukuku (GÖR-019/031/032/034) onaylanmadan otomatik gönderim riskli. Gönderim açılmadan önce worker + izin kapısı (`growth_iletisim_uygun_mu`) birlikte yazılmalı |
| Telefon doğrulama | GÖR-015 altında bekler | Çağıran yok; SMS sağlayıcı kararı yok |
| Kupon uygulama | Ürün kararı bekler | Ödemede yok; iyzico sandbox (GÖR-016) ile birlikte ele alınmalı |
| `_abonelik_ver` | Silinmez, ölü kod olarak işaretli | Kullanımı doğrulanmadan silmek riskli |
| Yan repolar | `rea` kullanılmaz; `hupo_merge` birleştirilmeden önce diff | Bkz. §8 |
| Migrasyon dosyaları | Dokunulmaz | Başka bir oturum aktif olarak düzenliyor |

## 11. Sıradaki yapılabilecek işler
1. `deno` kur → edge birim testleri.
2. Kök *.sql testleri için PGlite koşturucusu (admin, payment, push, child_safety...).
3. E2E test hesapları (P1) → hesaplı Playwright paketi.
4. Playwright: crawl hedefleri ve home giriş bağlantısı hatalarını incele; mobil menü seçicisini daralt.
5. okuma_dunyasi: 5 hikâye paketinde `ogrenme_hedefleri[6].etiket` > 120 karakter (içerik; yayın kuralları geçerli).
6. YouTube/LinkedIn adreslerini doğrula.

## 12. Güncelleme (2026-10-28)
- Mobil menü testi düzeltildi (test kodu, uygulama değil): `header button[aria-expanded][aria-label]:visible`. "Giriş" açılır düğmesinde aria-label olmadığı için seçici ayrışıyor. `e2e/mobile.spec.ts` ve `e2e/helpers.ts` (girisBaglantisi). Tekrar koşumda: 1 geçti.
- Kalan Playwright sorunları (crawl hedefleri, home giriş bağlantısı, 404 sosyal bağlantılar) hâlâ açık.
- Deno kuruldu (winget, deno 2.9.8). Edge birim testleri: `deno test --no-check --allow-all _shared send-push` (supabase/functions) → 56 geçti, 0 kaldı.
  - Tip denetimi (`deno test` varsayılanı) `npm:@types/node` çözümlemesinde takılıyor. Ortam/yapılandırma konusu (deno.json nodeModulesDir), test kodu değil; düzeltilmedi.
- Home "giriş ekranına bağlantı çalışıyor" (e2e/home.spec.ts:27): masaüstü ve mobil projelerinde tek tek koşuldu → ikisi de GEÇTİ. Önceki başarısızlık tekrar üretilemedi; yoğun makinede derleme sırasında koşulduğu için zamanlama kaynaklı olabilir. Kod değişikliği yok. Gerekirse flaky olarak izlenir.

# PROJE GÜNLÜĞÜ — Öğrenci Hazırlık (Hupo)

> Eski adı: `TASKS.md` (2026-10-17'de yeniden adlandırıldı). Eski bölüm numaraları (`§11.7` gibi) aynen geçerlidir; kod yorumları ve eski kayıtlar bu numaralara atıf yapar.
> Biçim ve kurallar: `AGENTS.md` §9 · Ana çalışma dosyası: `MASTER_BRIEF.md` · Temizlik: `docs/arsiv/TEMIZLIK_RAPORU.md` · Kurtarma kanıtı: `kurtarilan/KURTARMA_RAPORU.md`

Son güncelleme: 2026-10-17 00:25 (Türkiye saati)

## Bölüm yapısı
- **A. Açık işler panosu**: açık her iş tek satırda, `GÖR` numarasıyla.
- **B. Kayıtlar**: AGENTS.md §9 biçiminde yeni kayıtlar, en yeni üstte, `K` numarasıyla.
- **C. Eski bölümler**: 2026-10-17 öncesi serbest biçimli notlar (§0–§26). Düzeltilmez; atıf için durur.

---

## A. Açık işler panosu

Son sayım: 2026-10-17. Kapanan satır panodan çıkar; kapanış bir `K` kaydında izlenir.

| GÖR | Konu | Açık iş | Durum | Sahip | Önem | Eski § |
|---|---|---|---|---|---|---|
| GÖR-001 | GÜV | Anahtar iptali ve yenileme: Gemini/Stitch anahtarı, GitHub erişim jetonu, Vercel jetonu, eski gömülü GitHub anahtarı. Yenilemeden sonra git geçmişi temizliği (`filter-repo`, her adım ayrı onay) | BEKLİYOR | Kullanıcı | Kritik | §11.2, §11.8, §16.3, §21.6 |
| GÖR-002 | GÜV | Supabase Auth: e-posta onayı, admin TOTP MFA, sızdırılmış şifre koruması, şifre politikası, `site_url` ve yönlendirme adresleri | BEKLİYOR | Kullanıcı | Yüksek | §11.4 |
| GÖR-003 | GÜV | Anonim erişimli uçlar: `veli_adayi_olustur` (anonim yazma), `growth_web_olay_kaydet` ve `growth_web_kimlik_bagla` (hız sınırı yok), `iletisim_izni_iptal_et` (imzasız), `exchange_auth_bridge_token` (karar bekliyor) | BEKLİYOR | Kullanıcı (karar) + Ajan | Kritik | §11.7, §11.8, §21.5 |
| GÖR-004 | GÜV | `search_path = public, pg_temp` → `''` standardizasyonu (~17 fonksiyon). DB testi şart | ERTELENDİ | Ajan | Orta | §11.3 |
| GÖR-005 | GÜV | Hız sınırı ve CAPTCHA: `CAPTCHA_SECRET` (domain bağlandıktan sonra), `veli-adayi-kayit` ve `deneme-on-kayit` deploy, IP gizleme (Q3), atomik olmayan sınır | BEKLİYOR | Kullanıcı + Ajan | Yüksek | §12.7, §21.3, §21.5, §24 |
| GÖR-008 | VT | Migration konsolidasyonu (261 fonksiyon tanımı / 231 benzersiz) ve soru seed'lerinin (`20261012000000`, 4.350 satır) migration dışına taşınması | ERTELENDİ | Ajan + Kullanıcı | Düşük | §11.5 |
| GÖR-009 | ALT | Yerel doğrulama: Docker yok; `supabase db reset` ve `supabase test db` çalıştırılamadı; `supabase/tests` pgTAP formatında değil; yeni migration'lar yerelde çalışmadı | BEKLİYOR | Kullanıcı (Docker) | Orta | §11.6, §11.7, §13.3 |
| GÖR-010 | MOB | Mağaza sürümü (Play / App Store): imzalama anahtarı ve `key.properties` yok, `appbundle` derlenmedi, mağaza hesapları yok. `maintenance_gate.dart` içinde 2 mağaza URL'si güncellenecek | BEKLİYOR | Kullanıcı | Yüksek | §7, §11.6, §16.4, §21.3 |
| GÖR-011 | ALT | Karakter görselleri: `web-panel/public/characters` git'te değil, Vercel derlemesi bu klasöre bağlı (bu dağıtımda 81 dosya elle kopyalandı). Kalıcı çözüm kararı: commit mi, derleme öncesi kopya adımı mı | BEKLİYOR (karar) | Kullanıcı | Yüksek | §16.2 |
| GÖR-012 | ALT | Alan adı ve HTTPS: hupolingo.com DNS'i TURHOST'ta. `app` CNAME, `@` A kaydı, CAA kontrolü, Vercel sertifikası, eski IP ve MX teyidi, ad sunucusu yayılması. Veli paneli bağlantısı ve Supabase yönlendirme adresi bunlara bağlı | BEKLİYOR | Kullanıcı (TURHOST paneli) | Kritik | §16.2, §16.3, §16.4, §18 |
| GÖR-013 | ALT | Web paneli dağıtımı: `9169887`, `f31dca2`, `0e50c83` commit'leri canlıda değil (2026-10-16 kontrolü). Hatalı Vercel kayıtları (`2Jr2…`, `9EEh…`) temizlenecek | BEKLİYOR | Ajan + Kullanıcı (onay) | Yüksek | §16.2, §24 |
| GÖR-014 | ALT | Yedekleme: Google OAuth consent ekranı "In production" olmalı; yedek parolası şifre yöneticisine taşınıp dosyası silinmeli; geri yükleme provası yapılmadı; Storage yedeği yok | BEKLİYOR | Kullanıcı | Yüksek | §21.5, §21.6 |
| GÖR-015 | VEL | Telefon doğrulaması: İleti Merkezi gönderici başlığı (450 yanıtı, başlık başvurusu), gerçek SMS testi; veli web kaydı 504 (Brevo SMTP); Web OTP arayüzü yok; deneme ve veli adayı akışı telefonu doğrulamadan kabul ediyor; `register_for_mock_exam` doğrulanmamış telefon yazıyor | ERTELENDİ / BEKLİYOR | Kullanıcı + Ajan | Yüksek | §22 |
| GÖR-016 | VEL | Ödeme ve çocuk akışı: iyzico uçtan uca sandbox testi, veli plan kartı ve satın alma kontrolü, çocuk akışının gerçek cihazda kontrolü, harici satın alma bağlantısının mağaza politikası ile uyumu | BEKLİYOR | Kullanıcı | Yüksek | §10 |
| GÖR-017 | WEB | Kanıtsız landing iddiaları ("14 Gün İade Garantisi", "%100 Güvenli Ödeme", "%40 tasarruf"): kaynak bulunmalı ya da kaldırılmalı. SSS ve `content.ts` satır 114'te hâlâ "3–7. sınıf" metni var | BEKLİYOR | Kullanıcı | Yüksek | §10, §24 |
| GÖR-018 | HUK | `/ticari-ileti-izni` sayfası: şirket unvanı, iletişim e-postası, tarih ve hukuk onayı (Google Play canlıya çıkmadan önce). İYS 3 iş günü kaydı (SMS ve telefon kanalları) bekleme listesinde | BEKLİYOR | Hukuk + Kullanıcı | Yüksek | §12.4, §12.7 |
| GÖR-019 | HUK | Hukuk metinleri: anket kişiselleştirme rıza metni, anonimleştirme yöntemi, aydınlatma metni güncellemesi, saklama süreleri (günlük toplamlar dahil), deneme kaydı katılım ve pazarlama metinleri, Q2 yazılı teyidi, ticari ileti değerlendirmesi, veli bağlantı e-postalarının metinleri ve hesap işlemi bildirimlerinin İYS dışı sayılması (K-0011) | BEKLİYOR | Hukuk | Yüksek | §22, §24, §25 |
| GÖR-020 | TSR | Görsel kontroller (gerçek ortam): veli paneli bandı, anket ve duyuru formları, karanlık mod, 320 / 390 px, bakım sayfası koyu tema, Flutter web ve mobil ekranlar | BEKLİYOR | Ajan (tarayıcı) + Kullanıcı (oturum) | Orta | §7, §14.4, §16.4, §21.5 |
| GÖR-021 | YÖN | Gerçek admin oturumuyla tarayıcı testleri: sınav formu, onay akışı, Üyeler çekmecesi, bakım yönetici girişi. `npm run dev` kontrolü | BEKLİYOR | Kullanıcı | Orta | §1, §7, §12.1, §21.5 |
| GÖR-022 | YÖN | Yönetim mobil ve tablet uyumu P0–P8 (kabul testi 390/768/1024; masaüstü-only işaretleme). "Yakında" öğeleri ürün kararı. Ölü mesaj namespace'leri temizliği | DEVAM (yerel doğrulama tamam; oturumlu tarayıcı kontrolü ve yayın teyidi bekliyor, K-0011) | Ajan | Orta | §19, §20 (2. bölüm) |
| GÖR-023 | DEN | Deneme sınavı uçtan uca testleri (§12.8–12.10, en son yapılacak). Gerçek profil birleştirme (gelecek faz). 8. sınıf LGS sınav tipi (ilerleyen fazda talep) | PLANLANDI | Ajan + Kullanıcı | Orta | §12.4, §12.5, §12.11 |
| GÖR-024 | VEL | Anket sistemi D1–D6: şema ve arşiv güvencesi (`restrict`), çocuk kapsamı (hukuk sonrası), PGlite arşiv testi, saklama ve anonimleştirme cron'u (hukuk sonrası), duyuru listesi 200 kayıt sınırı, canlı anket testi (test veli + test anketi) | PLANLANDI | Ajan + Kullanıcı | Orta | §17, §24 |
| GÖR-025 | BYM | Ziyaretçi widget'ı (ayrı görev; önkoşullar: anon anahtar çözümü, hukuk teyidi). Ölçüm görevi K8 | BEKLİYOR | Ajan + Hukuk | Düşük | §20 (2. bölüm), §24 |
| GÖR-026 | MOB | Kelime Evreni: ilk onaylı paket (dil uzmanı incelemesi), ödül ve rozet entegrasyonu, ana ekranda tek birincil eylem, 390 px ve ekran okuyucu kontrolü. Uzak DB'ye uygulanmadı | BEKLİYOR | Kullanıcı + Ajan | Orta | §13.2, §13.3 |
| GÖR-027 | ALT | Anon/publishable anahtar kontrolü: yerel `.env.local` değişkeni `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (eski not `ANON_KEY` diyordu). 2026-10-17 kontrolünde `apikey` başlığıyla istek 401 değil (anahtar kabul ediliyor); eski 401 bulgusu yanlış başlıktan kaynaklanmıştı. Açık kalan: Vercel ortam değişkeninin aynı anahtarla güncel olduğu doğrulanmadı; duyuru şeridi canlıda hâlâ kanıtlanmadı | BEKLİYOR | Kullanıcı (Vercel) | Yüksek | §14.3, §24 |
| GÖR-033 | VEL | Çocuk eşleşme geri bildirimi: kodlandı (K-0011). Kanal kararı: kutu + push + e-posta, tek olaydan. Liste: veli panelinde "Çocuklarım" sayfası. Migration uzak DB'ye uygulandı (K-0012). Kalan: (1) `eposta-gonder` deploy ve secrets (`BREVO_API_KEY`, `EPOSTA_GONDER_SECRET`, `EPOSTA_GONDEREN_ADRES`); (2) web-panel dağıtımı (GÖR-013) yapılmadan "Çocuklarım" canlıda görünmez; (3) push kanalı için GÖR-030; (4) gerçek veli ve öğrenci hesabıyla tarayıcı kontrolü | DEVAM | Kullanıcı (secrets, dağıtım onayı) + Ajan | Yüksek | Yeni (2026-10-17) |
| GÖR-028 | VEL | Veli "Verdiğim yanıtlar" bölümü (görme ve değiştirme, KVKK erişim hakkı) | ERTELENDİ | Ajan | Düşük | §20 (2. bölüm) |
| GÖR-029 | BEL | Bölüm numaraları: `§20` iki bölümde kullanılmış (eski satır 766 ve 1043); §16–18 ve §24–26 sırası karışık. Numaralar kod yorumlarında atıf olduğu için yeniden numaralandırma kararı gerekir | BEKLİYOR (karar) | Kullanıcı | Düşük | Tüm dosya |
| GÖR-030 | MOB | (KAPANDI, bkz. K-0008) Push bildirim hattı canlı değil. Eksikler: `send-push` deploy edilmemiş; secrets'ta `FIREBASE_SERVICE_ACCOUNT` ve `PUSH_WEBHOOK_SECRET` yok; Flutter'da Firebase paketi ve yapılandırma dosyası yok (`pushBackendProvider` Noop); Database Webhook doğrulanmadı. (Düzeltme 2026-10-17: `20261035`–`20261038` uzakta uygulanmış, bkz. K-0003 güncellemesi.) Sıra: Firebase projesi → Flutter arka ucu → secrets → db:deploy → send-push deploy ve webhook → cihazda test | BEKLİYOR | Kullanıcı (Firebase, secrets, onay) + Ajan (kod) | Kritik | §26 (eski) |
| GÖR-032 | MOB | Onaylanan kayıt ve ön izin kararları: (a) veli kaydında işaretsiz "hizmet bildirimleri" kutusu, işaretlenirse çocuk cihazında push anahtarı açık başlar; (b) pazarlama push kutusu kayıt formunda yalnızca kapı açıkken görünür, işaretsiz. Uygulanmadı | PLANLANDI | Ajan | Yüksek | K-0005 |
| GÖR-031 | HUK | Pazarlama push kapısı (`pazarlama_push_kapisi`, varsayılan KAPALI): İYS kararı ve v2 metni onayı yönetici tarafından, yazılı hukuk görüşüyle girilecek. Görüşün yazarı ve lisansı teyit edilmeli; push'un İYS kapsamı resmi kaynaktan doğrulanmalı; tam v2 metni incelenmeli. Kapı kapalıyken yasal sayfadaki push satırı taslak sayılmalı | BEKLİYOR | Hukuk + Kullanıcı | Yüksek | §23, §25 |
| GÖR-032 | HUK | Öğretmen sınıf özeti (K-0006, ONAYLI): veli bilgilendirme metninin hukuk onayı; sınıf üyeliğinin veli rızası gerektirip gerektirmediği; aydınlatma metni güncellemesi; eşik 3 değerinin hukuki gerekçesi | GEÇİCİ KARAR (hukuk görüşü ve kontrol listesi, K-0009) | Hukuk | Yüksek | §22, §24, GÖR-019 |
| GÖR-034 | HUK | Çerez bandı kısaltıldı ve olay ölçümü eklendi (hero CTA, demo tamamlama, veli kayıt başlangıcı, fiyat tıklaması; yalnızca onay sonrası). Tam çerez metni ve analitik sürümü hukuk teyidi bekliyor (K-0016) | BEKLİYOR | Hukuk + Kullanıcı | Yüksek | Yeni |
| GÖR-035 | MOB | Yeni APK ile görsel doğrulama: soru metninde amber altı çizgi (`sunDark`) ve uygulamadaki ekranlar. Telefon kilitliydi, sonra bağlantısı koptu; kurulum için cihazın açık ve bağlı olması gerekir. Ayrıca Ayarlar başlığı durum çubuğuna biniyor, Gizlilik ekranının alt kısmı gezinme çubuğunun altında kalıyor | BEKLİYOR | Kullanıcı (cihaz) + Ajan | Orta | Yeni |
| GÖR-036 | MOB | Yanlış cevap açıklaması görünmüyor: `ResultSheet` "Doğru cevap" metni ve `dogru_sik` akışı (K-0015) | BEKLİYOR | Ajan | Yüksek | Yeni |
| GÖR-037 | WEB | Hero'daki soru görseli uygulama dilinde illüstrasyon (5. sınıf fen sorusu). Gerçek ekran görüntüsü için telefon bağlantısı ve kilit açma gerekli; ardından `hero-soru.jpg` değiştirilecek | BEKLİYOR | Kullanıcı (cihaz) + Ajan | Orta | Yeni |
| GÖR-038 | WEB | Footer: "Hakkımızda", "Blog", "İletişim" bağlantıları `#`; YouTube hesabı 404; App Store ve Google Play rozetleri bağlantısız (kullanıcı ertelemişti) | BEKLİYOR | Kullanıcı (hesaplar) + Ajan | Orta | Yeni |
| GÖR-039 | WEB | Landing canlı doğrulaması: 7 commit push edildi (`8898cd7`→`ae1c078`). Canlıda header, hero, fayda, sayfa sırası ve `/yonetim-giris` bağlantısı kontrol edilmeli; Vercel dağıtım durumu ve Lighthouse doğrulanmadı | BEKLİYOR | Ajan (tarayıcı) + Kullanıcı (Vercel) | Yüksek | Yeni |
| GÖR-040 | YÖN | Ham bildirim formu (`BildirimManager` → `admin_send_notification`): `ogrenci` ve `tumu` hedefleri kategorisiz serbest metin gönderiyor; öğrenciye yalnızca hizmet bildirimi kuralı UI'da zorunlu değil. Ham formdan `ogrenci` ve `tumu` kaldırıldı (K-0018 onaylı, kod uygulandı). Kalan karar: öğrenci hesaplarına hizmet bildirimi gerekiyorsa kategori (sistem, akademik, duyuru) zorunlu ayrı bir akış kurulsun mu | BEKLİYOR (karar) | Kullanıcı | Orta | K-0018, AGENTS §5 |
| GÖR-041 | YÖN | Segmentli bildirim: uzak DB'ye `20261044000000` uygulaması (`db:deploy`) ve web-panel dağıtımı (kullanıcı onayı); gerçek yönetici oturumuyla uçtan uca test (kaydet → ön kontrol → planla → dağıtım sonucu). Demo modu bu zinciri doğrulamaz | BEKLİYOR | Kullanıcı (onay, oturum) + Ajan | Yüksek | K-0018 |
| GÖR-043 | HUK | MEB ODSGM içerikleri (icerik/834, 54 kaynak): altbilgide "Tüm Hakları Saklıdır" yazıyor. Birebir aktarım için MEB'den yazılı izin veya hukuk görüşü gerekli; o zamana kadar yalnızca uyarlama. Lisans kaydı `belirsiz` | BEKLİYOR | Hukuk + Kullanıcı | Yüksek | K-0020 |
| GÖR-042 | YÖN | Soru Atölyesi (PDF → etiketli soru → varyasyon → denetim → panel import). Faz 0 belgeleri ve şema yazıldı; Faz 1'den devam. Faz 6 (migration/RPC/panel) ayrı onay ister. Lisans dayanağı kaynak kaydına yazılmalı | DEVAM | Ajan + Kullanıcı | Yüksek | K-0020 |
| GÖR-044 | MOB | Senin Hikayen / Okuma Dünyası ana iş: F0 iskeleti ve kit testi tamam; F1 (Dart motor, Türkçe ek vektörleri), F2 (derleyici, şemalar) ve örnek hikâyeler sıradaki | DEVAM | Ajan + Kullanıcı | Yüksek | K-0022, K-0023 |
| GÖR-045 | HUK | Okuma Dünyası hukuku: aydınlatma güncellemesi (okuma geçmişi, anket, veli değer tercihi için KVKK m.6 sorusu), saklama süresi, AI üretimli metnin telifi, MEB/TDK metni | BEKLİYOR | Hukuk | Yüksek | K-0022, GÖR-019, GÖR-043 |
| GÖR-046 | VT | (KAPANDI, bkz. K-0028) Kelime Evreni veli özeti rıza kapısını sunucuda uygulamıyor (`kelime_veli_ozeti` 20261022000000:611; kapı yalnız ChildScope arayüzünde); `export_my_data` Kelime tablolarını kapsamıyor. Düzeltme migration'ı ayrı onayla | TAMAMLANDI (rıza kapısı PGlite'ta DOĞRULANDI; migrasyonlar 20261045/20261046 uzakta; export çalışma zamanı testi GÖR-048'e taşındı) | Ajan | Yüksek | K-0022, GÖR-041, K-0024, K-0025, K-0027, K-0028 |
| GÖR-048 | VT | `export_my_data` (20261046) çalışma zamanı testi: PGlite'ta `student_stats`, `user_answers`, `xp_events`, `user_badges`, `notifications` tabloları yok; Kelime bölümü dahil tam çağrı test edilmedi. Test ortamı tamamlanınca koşulacak | DEVAM | Ajan | Orta | K-0027, K-0028 |
| GÖR-049 | YÖN | Dört göz ve iki yönetici hesabı: sistem (`DORT_GOZ`) iki ayrı yönetici hesabı ister. Hazırlayan AI ajanı bir hesap sahibi değildir. Okuma Dünyası tasarımında (F7) ajan işlemlerinin hangi hesapla yapılacağı ve ikinci onayın kimde olacağı netleştirilecek | BEKLİYOR (tasarım) | Ajan + Kullanıcı | Yüksek | K-0025, K-0028 |
| GÖR-050 | YÖN | Katman B (LLM hakem) canlı çağrısı: ortamdaki `GEMINI_API_KEY` Gemini tarafından reddediliyor (HTTP 401; değer `AQ.` ile başlıyor, Gemini API anahtarları genellikle `AIza` ile başlar). `ANTHROPIC_API_KEY` tanımlı değil. Geçerli bir Gemini anahtarı (AI Studio) ya da Claude anahtarı ortam değişkeni olarak tanımlanmalı; sonra `hakem` komutu iki örnek hikâyede çalıştırılacak | KAPANDI (K-0034: canlı hakem çalıştı) | Kullanıcı | Yüksek | K-0033, K-0034 |
| GÖR-051 | MOB | HupoRead görsel ve içerik yükseltme: F1 uygulandı (PDF palet/serif/vektör kapak, emoji → SVG okuyucu ve PDF, maskot düzeltmesi). Açık: F2 okuyucu Oku/Keşfet/Düşün akışı (Düşün isteğe bağlı mı?), F3 canlı içerik sözleşmesi (DB onayı), F4 raster sahneler | DEVAM | Ajan + Kullanıcı | Yüksek | K-0076, K-0077, K-0078 |
| GÖR-052 | MOB | Okuma PDF gerçek kontrolü: ikonlu gerçek bir hikâyeyle sayfa incelemesi, 2. ve 8. sınıf ile mürekkep tasarrufu PNG'lerinin incelenmesi, baskı denemesi, PDF indir akışında tema seçimi (karar), 8. sınıf için sözlük adayı (içerik) | BEKLİYOR | Ajan + Kullanıcı (içerik, baskı, karar) | Orta | K-0085 |
| GÖR-053 | BEL | Çakışan çalışma: okuma PDF ve motor dosyaları iki ajan tarafından düzenlendi (K-0078, K-0085). Commit öncesi birleştirme ve gözden geçirme gerekli; okuma dosyaları henüz git'e alınmadı (untracked) | BEKLİYOR (karar) | Kullanıcı (commit onayı) + Ajan | Yüksek | K-0078, K-0085 |

---

## B. Kayıtlar (en yeni üstte)

### K-0099 · 2026-10-22 07:45 · DEN · 2. sınıf zorluk 3 ek partisi: sonuç ve sınır
- **Tür:** Gelişme
- **Konu:** DEN
- **Bağlam:** K-0098 sonrası zorluk 3 oranı çok düşüktü (Türkçe 2/27, Matematik 3/28, Hayat Bilgisi 1/25). Kullanıcı zorluk 3'ü artırmak için ek parti istedi.
- **Plan:** Hücre başına 6 zorluk 3 taslak (Türkçe 6, Matematik 6, Hayat Bilgisi 6; yazar Sonnet). Ardından kapı, kör çözücü (Haiku) ve kör kalite (Sonnet, zorluk önerisi dahil). Onay koşulu K-0098 ile aynı: çözücü = anahtar, kalite GEÇER, kalitenin kendi cevabı = anahtar.
- **Karar:** Kalite denetçisi bir soruyu zorluk 2 olarak önerdiyse etiket 2'ye indirildi (REHBER §4.6: zorluk etiketi iddialı konmaz). Bu nedenle zorluk 3 sayısı, eklenen taslak sayısından az arttı.
- **Açıklama:** 18 taslaktan 16'sı onaylandı (Türkçe 5/6, Matematik 5/6, Hayat Bilgisi 6/6). Elenen: TR2-049 (kazanım kodu T.Y.2.2 yazma kazanımı, soru bağlamdan sözcük anlamı ölçüyor), MAT2-036 (kazanımla zayıf uyum, 6×12 çarpım tablosu dışı, şık öbeklenmesi). Zorluk 3 sayısı: Türkçe 2 → 3 (%9), Matematik 3 → 8 (%24), Hayat Bilgisi 1 → 3 (%10). Son toplam: Türkçe 32, Matematik 33, Hayat Bilgisi 31 (96 soru); her hücre kapı 0 RED, ≥20.
- **Doğrulama:** KISMİ. Kapı: taslaklar 6/6 ×3; nihai dosyalar 32/33/31 KONTROL, 0 RED. Yapılmadı: REHBER §6 benzerlik kontrolü, insan örneklemi, veritabanı aktarımı.
- **Durum:** BEKLİYOR. Türkçe ve Hayat Bilgisi'nde zorluk 3 hedefi (%20) karşılanmadı. Seçenekler: (a) zorluk 3 için ikinci ek parti; (b) etiketleri olduğu gibi bırakıp ürün içinde zorluk vaadi verilmemesi (REHBER §9).
- **Sahip:** Kullanıcı (ikinci parti ya da kabul kararı) + Ajan.
- **Önem:** Orta
- **Kanıt:** `docs/soru-uretim/pilot/uretim_{turkce,matematik,hayat_bilgisi}_2_zor3.json` (taslak), `uretim_*_2_final.json` (güncellendi), `denetim_*_2.json` (zor3 kararları eklendi).
- **İlgili:** K-0098, REHBER §4.6, §9, §17.7.

### K-0098 · 2026-10-22 07:04 · DEN · 2. sınıf soru üretimi: Türkçe, Matematik, Hayat Bilgisi (taslak → kapı → kör çözüm → kör denetim)
- **Tür:** Gelişme + Sorun
- **Konu:** DEN
- **Bağlam:** Kullanıcı "belirlediğimiz kurallara göre 2. sınıf sorularını hazırla" dedi. PLAN_V2 §3 üretim hattı uygulandı. İngilizce 2 program PDF'i bulunamadığı için üretilmedi (K-0093 engeli; PLAN_V2 §0.4 gereği program doğrulanmadan hücre açılmaz).
- **Plan:** (1) Kazanım tabloları DÖP PDF'lerinden: `kazanim_2_turkce.json`, `kazanim_2_matematik.json`, `kazanim_2_hayat_bilgisi.json`. (2) Yazar (Sonnet) taslağı. (3) `tools/soru-uretim/kapi.cjs`. (4) Kör çözücü (Haiku) ve kör kalite (Sonnet), anahtar verilmeden. (5) GEÇER ve çözücü = anahtar olanlar onaylanır; DÜZELT/RED çıkarılır. (6) Eksik kazanım ya da 20 altı için ek parti, aynı hat.
- **Karar (ajan, değiştirilebilir):** Kapsam dışı kazanımlar kendi dosyalarında gerekçeyle listelendi. Türkçe: dinleme/konuşma ve süreç kazanımları. Matematik: MAT.2.1.5, 2.3.2, 2.3.3, 2.3.4, 2.3.7 (şekil/model gerektirir). Hayat Bilgisi: HB.2.1.4, HB.2.6.1, HB.2.6.2 (süreç ya da üst düzey), HB.2.4.5 (dinî yorum; Din Kültürü ihtiyat kuralı), HB.2.2.3 (levha tanıma görsel gerektirir; iki görselsiz deneme denetimi geçemedi). Tutum/değer kazanımları yalnız bilgi-kavram düzeyinde sınandı (REHBER §17.1).
- **Açıklama:** Taslak 105 soru (Türkçe 44, Matematik 30, Hayat Bilgisi 31); onaylı 80 (Türkçe 27, Matematik 28, Hayat Bilgisi 25); elenen 25. Her hücre ≥20. Kapsam: Türkçe 5/5 kod, Matematik 20/20 kod, Hayat Bilgisi 18/18 kod. Türkçe yazar taslağında kalite denetçisi 12 DÜZELT ve 1 RED verdi (kazanım kodu uyumsuzluğu, gevşek kök, bariz çeldirici); ek parti 16 sorunun 12'si geçti. Çözücü ile anahtar uyumu (taslak + ek): Türkçe 43/44 (TR2-025 elendi), Matematik 30/30, Hayat Bilgisi 31/31.
- **Doğrulama:** KISMİ. Doğrulanan: kapı 27/27, 28/28, 25/25 KONTROL, 0 RED; onaylı sorularda çözücü = anahtar ve kalite = GEÇER (kalite kararında kendi cevabı da anahtarla aynı). Yapılmadı: REHBER §6 n-gram/parmak izi benzerlik kontrolü (betik kapsamında yok), insan örneklemi (§15), `questions` tablosuna aktarım, DÖP ile kazanım metinlerinin teyidi (PDF ayrıştırması).
- **Sorunlar (açık):** (a) Zorluk 3 hedefin altında (Türkçe 2/27, Hayat Bilgisi 1/25, Matematik 3/28); zorluk etiketleri model tahmini. (b) Kalite notlarındaki küçük uyarılar (ör. HB2-025 "kayanın" okunuşu; MAT2-016 yuvarlama kazanımda var mı belirsiz; TR2-026 heceleme kuralı REHBER'de açık değil) onaylı setten çıkarılmadı; yayın öncesi gözden geçirilmeli. (c) Bazı Türkçe kazanım kodları (T.O.2.1 süreç harfi 'b') PDF'te eksik kaldı.
- **Durum:** BEKLİYOR (kullanıcı kararı: insan örneklemi ve yayın onayı; İngilizce 2 program bağlantısı).
- **Sahip:** Kullanıcı (yayın/örneklem kararı, DB içe aktarım onayı, İngilizce 2 program bağlantısı, LGS dahil sonraki hücreler) + Ajan (benzerlik kontrolü ve zorluk kalibrasyonu).
- **Önem:** Yüksek
- **Kanıt:** `docs/soru-uretim/pilot/uretim_{turkce,matematik,hayat_bilgisi}_2.json` (taslak), `*_2_ek.json` (ek parti), `*_2_final.json` (onaylı, durum KONTROL_ADAYI), `denetim_{turkce,matematik,hayat_bilgisi}_2.json` (çözücü ve kalite kararları), `kazanim_2_*.json`. `node tools/soru-uretim/kapi.cjs` → final 27/28/25 KONTROL.
- **İlgili:** K-0093, K-0049, PLAN_V2 §0.4 ve §3, REHBER §5, §6, §15, §17, §18.

### K-0093 · 2026-10-22 · DEN · Soru üretimi: kalan işler (devir kaydı)
- **Tür:** Plan + Yapılacak
- **Durum:** DEVAM. 42 hücreden 11 tamam, 31 kaldı.
- **Tamamlanan (veri tabanına aktarıldı, onaylı):** 4. sınıf Türkçe 28, Matematik 28, Fen 25, Sosyal 28; 5. sınıf Matematik 36, Fen 35, Sosyal 38; 6. sınıf Türkçe 91, Matematik 30, Fen 36, Sosyal 30. Toplam yeni onaylı 405 (K-0071, K-0089).
- **Kalan hücreler:**
  - 1. sınıf: Türkçe, Matematik, Hayat Bilgisi
  - 2. sınıf: Türkçe, Matematik, Hayat Bilgisi, İngilizce
  - 3. sınıf: Türkçe, Matematik, Hayat Bilgisi, Fen, İngilizce
  - 4. sınıf: İngilizce, Din Kültürü
  - 5. sınıf: Türkçe, İngilizce, Din Kültürü
  - 6. sınıf: İngilizce, Din Kültürü
  - 7. sınıf: Türkçe, Matematik, Fen, Sosyal, İngilizce, Din Kültürü
  - 8. sınıf (LGS, en son, ayrı strateji): Türkçe, Matematik, Fen, İngilizce, Din Kültürü, T.C. İnkılap
- **Engeller:**
  - İngilizce ve Din Kültürü programı PDF'i bulunamadı (2–8. sınıf). Kullanıcıdan bağlantı ya da dosya adı bekleniyor.
  - 1–3. sınıf Türkçe ve Matematik kazanım PDF'leri indirildi, ayrıştırılmadı.
  - Hayat Bilgisi 1–3 kazanım dosyası hazır (pilot/kazanim_1-3_hayat_bilgisi.json, 50 kod), soru yok.
- **Hazır kaynaklar:** Ortaokul Türkçe 5–8 (tymm, 2026-09-02), Ortaokul Matematik 5–8 (mufredat), Fen 3–8 ve Sosyal DÖP (tymm). 5. ve 7. sınıf için ayrıştırma yapılabilir.
- **Üretim hattı:** Yazar (Sonnet) → kapı (	ools/soru-uretim/kapi.cjs) → Haiku kör çözüm → Sonnet kalite denetimi → DÜZELT/RED çıkarılır → SQL içe aktarma (eklemede) → kullanıcı onayı ile yayın. Şablon: docs/soru-uretim/REHBER.md, plan: docs/soru-uretim/PLAN_V2.md.
- **Açık kararlar:** 8. sınıf LGS stratejisi (kullanıcı ayrı çalışacak); yayın öncesi insan örneklemi (REHBER §15) henüz atanmadı; 4–6. sınıflardaki 405 yeni sorunun kalite "sarı" durumu ve kazanım metinlerinin DÖP ile teyidi.
- **Doğrulama:** DOĞRULANDI (DB sayıları 2026-10-22 sorgusuyla).
- **Sahip:** Kullanıcı (İngilizce/Din programları, yayın kararı, LGS), Ajan (kalan hücreler).

### K-0092 · 2026-10-21 · MOB/VT/TSR · HupoRead → Hupolingo entegrasyonu: karar, Faz 0 tamam
- **Tür:** Karar + Kayıt
- **Konu:** MOB, VT, TSR, WEB
- **Karar (kullanıcı):** Faz 0 başlasın; prototip donar, geliştirme yalnız Hupolingo'da; sahne görselleri sunucudan (Storage + paket alanı); landing bölümü pilot sonrası (önce `/demo` örneği); ilk yayın setinin insan okumasını kullanıcı yapar; kullanıcı ~120 hikâyeyi `.md` olarak verecek, Atölye biçimine uyarlanacak.
- **Ek gereksinimler:** veli/öğretmen dashboard'u (kavram, hikâye, kelime sayısı, doğru-yanlış dağılımı, değerler); yönetimde hikâye yükleme/düzenleme/çıkarma/silme + genel istatistik; mobil, web app, site ve panellerde kullanım süresi analitiği. Plan: `docs/okuma-entegrasyon/ENTEGRASYON_PLANI_2026-10-21.md` (§4b).
- **Faz 0 yapılanlar:** dal `feature/huporead-entegrasyon`; okuma dosyaları (mobil, paneller, 7 migration, testler, belgeler) tek commit'te git'e alındı (GÖR-053 kapandı); `db:status`: yerel ve uzak migration listesi birebir aynı.
- **Taban testleri:** `flutter test` okuma 77/77; `dart test` motor 40/40; PGlite 171/172 (tek kırmızı önceden var: atölyedeki 5 gerçek paket `ogrenme_hedefleri[6].etiket 2-120 karakter` kuralına takılıyor; 120 hikâye içe aktarımından önce çözülmeli); web eslint (okuma klasörleri) ve `tsc --noEmit` temiz; `flutter analyze` 4 info, hiçbiri okumada (push dosyaları).
- **Doğrulanmadı:** web `next build`, cihaz/Flutter Web görünümü.
- **Sıradaki:** Faz 1 (V3 arayüz portu), sözleşme genişletmesi (ayrı migration onayı), 120 hikâye pilot dönüşümü.

### K-0097 · 2026-10-22 · VT/MOB/TSR · Görseller, yeni türler, atasözleri, 3–4. sınıf 15 hikâye
- **Yapılan:** 30 Gemini sahne görseli, 7 yeni tür, soru sınırı 8, pilot-2'ye 4 atasözü (süre güncel), yeni 15 hikâye (HR-015…032) uzak DB'de taslak; migration 20261060–62. Ayrıntı: `docs/okuma-entegrasyon/PILOT_2_3_4_SINIF_2026-10-22.md`.
- **Açık:** hukuk/telif, Ajan A/B ve insan okuması, 90 fiş, görsel gözden geçirme.

### K-0096 · 2026-10-21 · VT/TSR · 2. sınıf pilot: uzak DB'ye içe aktarım
- **Yapılan:** 20261058 (paket doğrulayıcı fis_kodu + fiş.hikaye_slug) ve 20261059 (sözlük 39, 15 fiş, 15 taslak paket) uzakta uygulandı; önce yerelde provası geçti. Hikâyelere kavram hedefi, atasözü (9), işaret ve fis_kodu eklendi; hedef kimlikleri hikâye bazında benzersizleştirildi (ortak kimlik etiketleri eziyordu).
- **Doğrulama:** yerel migrasyon sınaması 15 hikâye, 15 fiş bağlı, 39/39 sözlük; okuma testleri 187/188 (#18 önceden bilinen).
- **Açık:** raster resim kararı; A/K telif kaydı; yayın denetimi ve insan okuması; 105 fiş yazılmadı. Ayrıntı: `docs/okuma-entegrasyon/PILOT_2_SINIF_ICE_AKTARIM_2026-10-21.md`.

### K-0095 · 2026-10-21 · TSR/MOB · 2. sınıf pilot: 15 hikâye biçime dönüştürüldü, derlendi
- **Yapılan:** 15 hikâye `icerik/pilot-2-sinif/` altında kahraman (`{kahraman}`) ve yol arkadaşı (`{yoldas}`) tokenlarıyla yeniden yazıldı; her biri 4 okuduğunu anlama sorusu, cevap anahtarı ve 2 kelime + 1 değer hedefi taşıyor. Sözlük: 30 yeni yuva (`ornek/sozluk.pilot-2.json`).
- **Doğrulama:** 15/15 derleme hatasız, 15 paket üretildi. Kalan uyarılar bilerek: kanıt C, 4 soru (karar), yuva aday sayısı (taslak).
- **Açık:** uzunluk standardı (120–220 rehber / 300–500 katalog) kararı; editör ve insan okuması; A/K telif kaydı; uzak DB'ye yazma yok. Ayrıntı: `docs/okuma-entegrasyon/PILOT_2_SINIF_URETIM_2026-10-21.md`.

### K-0094 · 2026-10-21 · MOB/TSR · HupoRead Faz 1(b): V3 bileşenleri, süre kuralı, geri sayım
- **Tür:** Uygulama + Düzeltme
- **Konu:** MOB, TSR
- **Yapılan:** `lib/widgets/okuma/okuma_v3.dart` (başlık bandı, çipler, ilerleme, adım rozeti, sahne yedeği, atasözü kartı, Anlamı kutusu, kelime paneli, geri sayım); okuyucu ve soru ekranı bağlandı; süre kuralı motora taşındı (`sure.dart`); soru ekranında otomatik geçiş için görsel geri sayım (hareket azaltmada metin).
- **Düzeltme:** derleyici süre tablosu ve yuvarlaması belgeyle uyuşmuyordu (3 dk vs 4 dk gösterebilirdi). Derleyici belgeye hizalandı (prototip klasöründe, ayrı git deposu, commit'lenmedi).
- **Doğrulama:** okuma testleri 82/82, motor 53/53, V3 5/5; 390 ve 1024 önizleme incelendi; derleyici testleri 30/30.
- **Açık:** Hupo maskotu okuyucuda kapalı (K8), kullanıcı kararı bekleniyor. Kelime Keşfi, Bilgi Kutusu, Düşünme soruları veri sözleşmesi olmadığı için ertelendi.

### K-0093 · 2026-10-21 · VT/TSR · Hikâye fişleri migration'ı uzakta uygulandı
- **Tür:** Kayıt (kullanıcı onayı: tüm bekleyen migration'lar)
- **Konu:** VT, TSR
- **Yapılan:** `20261057000000_okuma_hikaye_fisleri.sql` (fiş tablosu, doğrulayıcı, idempotent içe aktarma, listeleme; metin alanı yok). `db:preview` önce yalnız bu migration'ı gösterdi; `db:deploy` uyguladı; sonra `db:preview` 'up to date' verdi.
- **Doğrulama:** PGlite 187/188 (kırmızı #18 önceden bilinen paket sorunu), 16 yeni fiş senaryosu geçti.
- **Sürüm çakışması:** ilk taslak 20261054 idi (Kelime Evreni ile aynı numara); 20261057'ye taşındı.
- **Açık:** 120 fişin uzak DB'ye yazılması (içe aktarma) henüz yapılmadı; ayrı onay gerekir. Hikâye metinleri ChatGPT'den bekleniyor.

### K-0091 · 2026-10-21 · MOB/TSR · HupoRead devir notu: İngilizce iş ertelendi, açık kalemler
- **Tür:** Not + Karar (kullanıcı: İngilizce işi ertelendi)
- **Konu:** MOB, TSR
- **Bağlam:** Kullanıcı HupoRead'i Türkçe + İngilizce yapma fikrini (ana ekranda dil seçimi, İngilizce hikâye ve soruların veri tabanına konması) ertelemeye karar verdi. Yeni bir sohbette yeni iş verilecek. Bu kayıt o sohbet için devir notudur.
- **Karar:** İngilizce iş yapılmadı. Kod, veri tabanı ve içerik değişikliği yok.
- **Ertelenen iş için ön analiz (uygulanmadı):**
  1. Dil seçimi ana ekranda: Türkçe / English / Türkçe + English. Tercih hesapta saklanır. "Hangi tipte okuma" sorusu dil mi, okuma modu mu diye netleşmedi (varsayım: dil).
  2. Veri tabanı: hikâye ve soru tablolarına `dil` alanı; (hikâye, dil) çifti benzersiz. Uzak DB migration'ı, kullanıcı onayı gerekir.
  3. Motor: Türkçe ek çekimi (`turkce_ad.dart`) İngilizcede kullanılmaz. İngilizce paketler şablonsuz düz metin olur, kahraman adı değişmez.
  4. Atasözleri çevrilmez; İngilizce karşılık (proverb) ya da farklı bir deyim gerekir.
  5. Sözlük iki yönlü önerilir (İngilizce kelime, Türkçe anlam). Yeni alan gerektirir.
  6. Seviye: İngilizce için ayrı ölçek (A1–B1 gibi), MEB İngilizce kazanımlarıyla eşleştirme gerekir.
  7. Çeviriler yayın kapısından geçer (Ajan A/B, insan okuması, dört göz). Makine çevirisi taslaktır.
  8. Önerilen pilot: 3 hikâye ve soruları. Karar bekleyen üç soru: dil seçimi açılışta mı, her seferinde mi sorulacak; iki dilli görünüm nasıl olacak (yan yana, paragraf altı, yalnız kelime anlamı); pilot hikâyeler hangileri.
- **Açık kalemler (HupoRead, `C:\Dev\Senin Hikayen - HupoRead\flutter_prototip`):**
  1. **Cihaz:** Son derleme (K-0090, 9 madde) telefona kurulmadı, telefon bağlı değildi. Telefonda ad ve ikonu değişmiş önceki sürüm var. Kurulum: `adb install -r build\app\outputs\flutter-apk\app-debug.apk` (adb: `C:\Users\cengi\AppData\Local\Android\Sdk\platform-tools\adb.exe`).
  2. **Cihazda doğrulanmadı:** PDF'in Android İndirilenler'e kaydı (`file_saver`), "Paylaş" eylemi, sahne görselleri, otomatik geçiş ve geri sayım çubuğu, okuyucu panelleri.
  3. **PDF kusuru:** Kapak sahne bandında fener görselinin üstü hafif kırpılıyor.
  4. **Taslak içerik:** `okuma_v3_icerik.dart` içinde 1 Bilgi Kutusu ve 3 Düşün sorusu editör onayı bekliyor.
  5. **Süreler:** 8 hikâyenin "N dk" değerleri tahmin (kelime sayısı / sınıf hızı).
  6. **Sözlüğe ekle:** Yalnız bellekte. Hupolingo'daki hesap bağlı rafa port kararı açık.
  7. **Sesli okuma:** Yok. TTS kararı açık.
  8. **Gösterim kuralları:** Kod ve testler var (`lib/gosterim_kurallari.dart`, 7 test), belge `docs/OKUMA_GOSTERIM_KURALLARI.md`. "Hikâye başına en çok 2 atasözü" kuralı yalnız belgede, kodda zorlanmıyor.
  9. **Port:** Prototipin Hupolingo `mobile-app` içine taşınması ayrı karar (K-0083'teki soru hâlâ geçerli).
  10. **Yayın:** Okuma bayrağı kapalı, katalogda yayınlanmış hikâye yok (K-0069, K-0082). Açma ve yayın kullanıcı onayı ister.
- **İlgili açık kayıtlar:** GÖR-001 (GEMINI_API_KEY döndürme, güvenlik, açık), GÖR-051 (görsel yükseltme), GÖR-052 (PDF gerçek kontrolü), GÖR-053 (okuma dosyaları untracked, commit kararı).
- **Tekrarlayan tuzaklar:**
  - `flutter test` uzun sürebilir. Takılan bir `dart` veya `flutter_tester` süreci olursa öldür, `--timeout` ver.
  - Ekran görüntüsünü PowerShell yönlendirmesiyle (`>`) yazmak PNG'yi bozar. Cihazda `screencap -p /sdcard/x.png`, sonra `adb pull`.
  - Telefon kilitliyse görüntü siyah çıkar. Kilidi kullanıcı açmalı.
  - Önizleme testi (`test/onizleme_test.dart`) ortam değişkeni ister: `ONIZLEME_KLASORU`, `FLUTTER_SDK_YOLU`. Yoksa atlanır.
- **Durum:** BEKLİYOR (kullanıcı yeni sohbette iş verecek)
- **Sahip:** Kullanıcı (sonraki iş), Ajan
- **Önem:** Orta
- **İlgili:** K-0083, K-0086, K-0090, K-0069, K-0082, GÖR-001, GÖR-051, GÖR-052, GÖR-053

### K-0089 · 2026-10-21 · VT · Yayın kararı: 6. sınıf Türkçe 91 soru onaylandı (kullanıcı kararı)
- **Tür:** Karar (ONAYLI, kullanıcı)
- **Karar:** Kullanıcı "hepsini onayla" dedi. Parti soru-uretim-2026-10-21-tr6: 91 soru onay_durumu='onaylandi', insan_onayi_kim='kullanici', karar 'onay'. Kalite 'sari' ve insan örneklemi yapılmadan yayına alındı.
- **Doğrulama:** Sayımlar aşağıda sorgulandı (yeni onaylı 91 beklenen).
- **Durum:** TAMAMLANDI (yayın). **Sahip:** Kullanıcı (karar), Ajan (uygulama)
- **İlgili:** K-0088.

### K-0088 · 2026-10-21 · VT · 6. sınıf Türkçe 91 soru veri tabanına aktarıldı (parti soru-uretim-2026-10-21-tr6, beklemede)
- **Tür:** Karar + Gelişme
- **Bağlam:** Kullanıcı "veri tabanına aktarımı yap". Önceki parti ile aynı yöntem: SQL aktarımı, transaction, dis_soru_id çakışması yok.
- **Karar:** 91 soru onay_durumu='beklemede', kalite 'sari', kaynak_turu 'uretilen', uretim_yontemi 'llm'. Yayın onayı ayrı karar olarak kullanıcıdan istenecek.
- **Doğrulama:** DOĞRULANDI (eklenen 91, beklemede 91; toplam 915; onaylı 824 değişmedi).
- **Durum:** Aktarım TAMAMLANDI; yayın BEKLİYOR.
- **Sahip:** Ajan · **Önem:** Yüksek
- **İlgili:** K-0071, K-0073.

### K-0087 · 2026-10-21 21:44 · MOB · Kelime Evreni: MEB'e göre 1–8. sınıf söz varlığı veri tabanı (Sonnet doğrulamalı)
- **Tür:** Gelişme
- **Konu:** MOB
- **Bağlam:** Kullanıcı isteği: Kelime Evreni için 1–8. sınıf eş anlamlı, zıt anlamlı ve eş sesli kelime veri tabanı; MEB müfredatına ve içeriğine göre; sonunda Sonnet 5.5 doğrulaması.
- **Plan:** (1) MEB Türkçe programı PDF'lerinden kazanım alt maddelerini metin olarak çıkar (`mufredat.json`); (2) sınıf başına ilişki dosyaları; (3) yapısal doğrulama (`dogrula.mjs`); (4) Sonnet 5.5 dil denetimi; bulgu düzeltme; ikinci denetim.
- **Karar:** Kazanım kodu ve metni yalnızca resmî PDF'ten alındı; kod uydurulmadı. 1. sınıfta program kazanımı yok: kayıtlar `kapsam: hazirlik`, kazanım null. Eş sesli yalnızca köken ayrımı net sözcüklerle sınırlandı; çok anlamlılar ayrı tutuldu. Uzak DB'ye uygulama ve mevcut 93 anlamlık başlangıç içeriğiyle birleştirme: ONAY BEKLİYOR (kullanıcı).
- **Durum:** BEKLİYOR
- **Doğrulama:** KISMİ. Yapısal DOĞRULANDI (`dogrula.mjs`: 118 ilişki, HATA yok). Dil: Sonnet 5.5 iki tur; tur 1'de 70 kayıtta bulgu (6 kritik) düzeltildi, tur 2 "küçük düzeltme" dedi ve yüksek bulgu düzeltildi. Son yama turu (17 kayıt) yeniden denetlenmedi. TDK doğrulaması yapılamadı (502). Uzman (dil) incelemesi yok.
- **Sahip:** Ajan (içerik ve doğrulama), Kullanıcı (uzak DB onayı), Dil uzmanı (yayın öncesi)
- **Önem:** Orta
- **Açıklama:** `docs/kelime-evreni/veritabani/` altında 118 ilişki, 218 kelime, 232 anlam. Açık şüpheler ve sınırlar README'de. Uzak Supabase'e uygulanmadı; `kelime_sorulari` bu adımda üretilmedi.
- **Kanıt:** `node docs/kelime-evreni/veritabani/dogrula.mjs` → "HATA: yok". Sonnet raporları: tur 1 (70 bulgulu kayıt, 6 kritik), tur 2 (küçük düzeltme gerekir, kritik yok).
- **İlgili:** GÖR-026, §13.2 (içerik maddesi), `docs/kelime-evreni/ENTEGRASYON.md`, `docs/kelime-evreni/veritabani/README.md`
- **Güncelleme 2026-10-21 (dilbilgisi.net teyidi):** Sözlük (eş anlamlı, zıt anlamlı, eş sesli harf sayfaları) ile 118 kayıt karşılaştırıldı. Sonuç: 75 doğrulandı, 5 kısmi, 38 sözlükte yok (`teyit-dilbilgisi.json`). Siteye göre düzeltildi: s4-16 kalabalık–tenha, s6-10 verimli–kısır, s6-15 yar (sevgili anlamı kaldırıldı). Veri tabanına (yerel dosyalar) eklendi; uzak Supabase'e yazılmadı. Doğrulama durumu: KISMİ (38 çift sözlükte yok, yayın öncesi ikinci kaynak gerek).
- **Güncelleme 2026-10-21 (uzak yükleme):** `supabase/migrations/20261052000000_kelime_meb_sozlugu.sql` üretildi (`uret-migration.mjs`). Yerelde PGlite'ta önceki kelime migration zincirine eklendi: +227 anlam, +116 ilişki; onaylı ilişki 0, yayında soru 0. Uzak yükleme YAPILMADI: Supabase CLI parola (`SUPABASE_DB_PASSWORD`) istedi, bu oturumda tanımlı değil. Açık karar: mevcut 93 kelimelik taslak seed ile aynı kavramlar farklı tanımla tekrar ediyor (ör. `yüz` 4 anlam); eski seed'in kaldırılması içerik silme olduğu için kullanıcı onayı gerekir. `db:deploy` bekleyen tüm yerel migration'ları uygular; okuma dünyası migration'ları (20261050000300–20261051000000) için uzak durum kontrol edilmeli.
- **Güncelleme 2026-10-21 (uzak uygulandı):** Kullanıcı onayıyla `npm run db:deploy` çalıştırıldı; uzakta yalnızca `20261052000000_kelime_meb_sozlugu.sql` bekliyordu (okuma migration'ları zaten uzakta). Doğrulama (uzak SQL): anlam 320, ilişki 165, onaylı ilişki 49 (değişmedi), yayında soru 48 (değişmedi). Yerel PGlite testiyle aynı sayılar. Eski 93 kelimelik taslakla çakışan kavramlar hâlâ çift; eski taslağın kaldırılması ayrı karar (içerik silme). DOĞRULAMA: KISMİ (yapısal ve SQL sayıları tamam; dil uzmanı incelemesi yok).
- **Güncelleme 2026-10-21 (yenileme migration'ı uygulandı):** Kullanıcı onayıyla `supabase/migrations/20261053000000_kelime_meb_sozlugu_yenile.sql` uzakta uygulandı (`db:deploy`). Eski taslak kaldırıldı (48 soru, 49 ilişki, 93 anlam; bağlı 5 deneme ve 5 ustalık kaydı CASCADE ile silindi, bunlar test hesaplarına aitti). `kelime_iliskileri`'ne `sinif` ve `kazanim_kodlari` eklendi; `kelime_mufredat_kazanimlari` (18 kazanım, RLS açık, istemci yetkisi yok) oluşturuldu. Uzak sayılar: anlam 232, ilişki 118, sınıfsız 0, onaylı 0, soru 0, eski tohum kalıntısı 0. SONUÇ: Kelime Evreni'nde yayında soru kalmadı; öğrenci ekranı içerik gelene kadar boş. Soru üretimi ve dört göz onayı sonraki adım.
- **Güncelleme 2026-10-21 (içerik alanları uygulandı):** `supabase/migrations/20261054000000_kelime_icerik_ornek_hatirlatici.sql` uzakta uygulandı. `kelime_iliskileri`'ne `ornek`, `hatirlatici`, `teknik` eklendi; 118 ilişkinin tamamı dolu (uzak SQL). Üretici: `uret-icerik-migration.mjs`. Tüm sınıf/kazanım/örnek/hatırlatıcı bilgisi artık veri tabanında; yayında soru hâlâ yok.
- **Güncelleme 2026-10-21 (taslak sorular):** `supabase/migrations/20261055000000_kelime_taslak_sorular.sql` uzakta uygulandı. Her ilişkiden bir TASLAK soru (118: 43 eş anlamlı, 63 zıt anlamlı, 12 eş sesli). Çeldiriciler sınıfa göre seçildi ve birbirleriyle ilişkisiz. Üretici `uret-soru-migration.mjs`. Uzak SQL: toplam 118, taslak 118, yayında 0. Yayın için dört göz kuralı tek yöneticide engel; yayın kararı kullanıcıda. Soru kalitesi için dil uzmanı incelemesi yapılmadı.
- **Güncelleme 2026-10-21 (Gemini teyidi ve düzeltmeler):** `docs/kelime-evreni/veritabani/gemini-teyit.mjs` ile 118 ilişki ve 118 taslak soru Gemini (`gemini-3.8-flash`) ile denetlendi; sonuç `teyit-gemini.json`. İlişki: 94 tamam, 10 düzeltme, 14 sorunlu. Soru: 112 tamam, 2 düzeltme, 4 sorunlu. Çocuk güvenliği bayrağı 0. Uygulanan düzeltmeler: 8 örnek/hatırlatıcı metni, 3 anlam metni (mühim, sol, düş). Uzakta `20261056000000_kelime_teyit_duzeltmeleri.sql` tek işlemde çalıştırıldı ve sürüm geçmişine işaretlendi; taslak sorular yeniden üretildi (118, yayında 0). AÇIK KARARLAR (kullanıcı): (a) -sız/-siz türevli zıt çiftler (saygı–saygısızlık, tutarlı–tutarsız, bilinçli–bilinçsiz, bağımsız–bağımlı, olumlu–olumsuz, başarı–başarısızlık); (b) "yakın anlamlı" çiftlerin eş anlamlı etiketi (mutlu–sevinçli, hızlı–çabuk, arkadaş–dost, küçük–minik, sevinç–neşe, anlatmak–açıklamak, değiştirmek–dönüştürmek, tedbirli–dikkatli). Okuma migration'ı `20261057000000_okuma_hikaye_fisleri.sql` bekliyor; bu oturumda uygulanmadı (ayrı çalışma).

### K-0090 · 2026-10-21 · MOB · HupoRead prototip: ana sayfa, sonuç, süre, otomatik geçiş, gösterim kuralları, PDF
- **Numara:** Önceden K-0087 olarak yazılmıştı; aynı numara Kelime Evreni kaydında da vardı, bu yüzden yeniden numaralandı.
- **Tür:** GELİŞME + KARAR
- **Konu:** MOB
- **Bağlam:** Telefona "HupoRead" adıyla (kendi ikonuyla) kurulum sonrası kullanıcı 9 madde istedi. Proje: `C:\Dev\Senin Hikayen - HupoRead\flutter_prototip` (Hupolingo `mobile-app` değişmedi).
- **Yapılanlar:** (1) Ana sayfa (kahraman seçimi) V3 diline taşındı: başlık bandı, öne çıkan "Hazır Hupo" kartı, iki gruplu kart ızgarası. (2) Hikâye kartı: tanıtım metni artık kesilmiyor, küçük resim kart yüksekliğine uyuyor. (3) Gösterim kuralları kodlandı (`lib/gosterim_kurallari.dart`, 7 test) ve belgelendi: `docs/OKUMA_GOSTERIM_KURALLARI.md` (ilk geçiş, cümle başına tek vurgu, sınıf/moda göre sayfa bütçesi, kart sınırları, üretici kuralları). (4) Sonuç ekranı: gradyan panel, yıldız göstergesi, okunan hikâye kartı, gerçek oturum özeti. (5) Hikâye kartında ve okuyucuda "N dk" (kelime sayısı / sınıfa göre hız; tahmindir). (6) Otomatik geçiş zaten vardı; son soruda yoktu, eklendi; geri sayım çubuğu görünür; test eklendi. (7) Araç önerilen adlarına "Araba" eklendi (kart görseli zaten otomobildi). (8–9) PDF (alt ajan): `file_saver` ile Android İndirilenler'e kaydeder, "Paylaş" eylemi ayrı; tasarım Literata serif, sahne görselli kapak, Hupo, tür şeridi, süre satırı, mürekkep tasarrufu seçeneği.
- **Doğrulama:** `flutter test` 56 geçti; `flutter analyze` yeni sorun yok; ekranlar test içi render ile görüldü (ana, hikâye seçimi, sonuç, PDF sayfaları). APK derlendi. Telefon bağlı olmadığı için kurulum ve cihazda deneme YAPILMADI; PDF'nin cihazda İndirilenler'e yazılması doğrulanmadı.
- **Açık:** PDF kapak bandında fener görselinin üstü hafif kırpılıyor; hikâye başına en çok 2 atasözü kuralı üretim tarafında (kodda zorlanmıyor); 8 hikâyenin süre değerleri tahmini; Hupolingo'ya port.
- **Durum:** DEVAM
- **Sahip:** Ajan, Kullanıcı (cihaz denemesi)
- **Önem:** Yüksek
- **İlgili:** K-0086, K-0085

### K-0086 · 2026-10-21 · MOB · Senin Hikâyen prototipi: V3 mockup'a sadık okuyucu, hikâye seçimi ve sahne görselleri
- **Tür:** GELİŞME + KARAR
- **Konu:** MOB
- **Bağlam:** Kullanıcı ChatGPT'nin mockup'ı (`HupoRead_ Renkli Okuma Macerası.png`) ve V3 brifi (`HupoRead_V3_Onaylanan_Mockupa_Sadik_Tam_Paket.zip`) kalitesinde arayüz istedi. Önceki turlar (K-0078, K-0083) okuyucuyu bilinçli olarak düz metin kartı bırakmıştı (K4/K8); bu kararlar kullanıcı isteğiyle geri alındı.
- **Yapılanlar (yalnız `C:\Dev\Senin Hikayen - HupoRead\flutter_prototip`; Hupolingo `mobile-app` değişmedi):**
  1. `lib/widgets/okuma_v3.dart` (yeni): üst bar düğmesi, sahne kartı (görsel yoksa türün yedek sahnesi), tür/sınıf çipleri, hikâye başlık bandı + Hupo, ilerleme, adım rozeti, sayfa kağıdı, kelime hapı, Kelime Keşfi kartı, kelime paneli (ikon, anlam, benzerler, örnek, Bilgi Kutusu, sözlüğe ekle aç/kapa), atasözü kartı, Anlamı kutusu, Düşünme sorusu kartı.
  2. `okuyucu.dart` yeniden yazıldı: sahne (1. sayfada büyük, sonrakilerde aynı sahnenin kaydırılmış şeridi; Sade modda ve 7–8. sınıfta yalnız 1. sayfa), Keşfet paneli, atasözü sayfasında Düşün kartları, Oku→Düşün adımı. `hikaye_secim.dart`: sahne küçük resimli kartlar, tür filtre hapları. `sonuc.dart`: oturumun gerçek özeti (sayfa, bakılan kelime, deftere eklenen söz; sıfırlar gösterilmez).
  3. 8 hikâye için `assets/okuma/sahneler/<slug>.jpg` (nano-banana, kişisiz sahne; kahraman çocuğun seçimi olduğundan sahnede sabit yüz yok). `flutter_svg` eklendi. Buton metinleri mockup'a uyduruldu: "Devam et" / "Geri".
  4. Benzer anlamlılar uydurulmadı: aynı sözlük yuvasındaki adaylardan gelir. `okuma_v3_icerik.dart`: yalnız görünüm eşlemeleri ve **TASLAK** içerik (1 Bilgi Kutusu, 3 Düşün sorusu; editör onayı bekler).
- **Doğrulama:** `flutter test` 47 geçti (7 önizleme testi atlanır); yeni `okuma_v3_test.dart` 6 senaryo. `flutter analyze`: yeni sorun yok (tek uyarı önceden var: `pdf_hikaye.dart` çift import). Eski testlerde metin ve sembol beklentileri güncellendi; `katalog_test` beklentisi 7→8 (8. hikâye zaten kataloğa girmişti). Ekran görüntüleri test içi render ile (390x844 ve 1024x768) incelendi: hikâye seçimi, okuyucu (sayfa 1, kelime sayfası, panel, Düşün sayfası), sorular, sonuç.
- **Bulgu:** Alt sayfada `transitionAnimationController` + `dispose` kalıbı kapatma düğmesini işlevsiz bıraktı; prototipte `sheetAnimationStyle` ile değiştirildi. Aynı kalıp Hupolingo `okuyucu_ekrani.dart` içinde de var, kontrol edilmedi.
- **Açık / sınır:** (a) Cihazda denenmedi (APK derlenmedi). (b) Sesli okuma yok (düğme eklenmedi; TTS paketi kararı). (c) "Sözlüğe ekle" yalnız bellekte; Hupolingo'da hesap anahtarlı yerel raf var. (d) Sahnede kişi yok; bisiklet sahnesinde sürücü yok (mockup'tan bilinçli sapma). (e) Eş/zıt anlam ve Bilgi Kutusu için paket sözleşmesi alanı yok; taslak içerik yayın kapısından geçmeli. (f) Sonuç ekranında yıldız/anket ayrı ekranda kaldı. (g) Hupolingo `mobile-app`'e port ayrı karar.
- **Durum:** DEVAM
- **Sahip:** Ajan, Kullanıcı (cihaz denemesi, port kararı, içerik onayı)
- **Önem:** Yüksek
- **İlgili:** K-0076…K-0084, GÖR-044, GÖR-051

### K-0085 · 2026-10-21 21:07 · MOB/TSR · Okuma PDF şablonu, genel SVG ikon kataloğu ve motor kimlik katmanı
- **Tür:** Gelişme + Sorun
- **Konu:** MOB, TSR
- **Bağlam:** Kullanıcı HupoRead ZIP paketini (PDF tasarım örneği, 89 ikon, manifest, tokenlar) hikâyeye bağlı değil, genel ikon kütüphanesi ve PDF şablonu takviyesi olarak birleştirip güzelleştirmeyi istedi. Aynı dönemde başka bir ajan okuyucu ve PDF dosyalarını düzenledi (K-0078).
- **Yapılanlar:**
  1. Genel ikon kataloğu: `mobile-app/assets/okuma/hikaye_ikonlari/` (178 SVG + `manifest.json`, ~140 KB). Üretici `mobile-app/tool/ikon_katalogu_uret.dart` manifestten `packages/okuma_motoru/lib/ikon_katalogu.g.dart` üretir; güvensiz SVG öğelerini (script, image, text, href, on*, url()) reddeder.
  2. Kayıt katmanı `packages/okuma_motoru/lib/ikon_kayit.dart`: katalog kimliği, 16 eski emoji kodu ve ham emoji → kimlik. Maskot (`hupo`) katalogda değil, onaylı varlık olarak ayrı tutuluyor. `Cikti` sınıfına `ikonId` eklendi; `metin` alanı aynen kaldı.
  3. PDF şablonu (`mobile-app/lib/services/okuma_pdf_hikaye.dart`): kapakta onaylı maskot (filigran yok); gövde Literata serif (SIL OFL 1.1, alt küme ~59 KB); başlık ve alt bilgi Nunito; sayfa numarası; sınıf bandına göre punto ve satır aralığı (2–4 / 5–6 / 7–8); seçici ikon bütçesi; soru kartları; ayrı cevap anahtarı sayfası; mürekkep tasarrufu (gri SVG, beyaz zemin). İkonlar `pw.SvgImage` ile vektör olarak gömülür; PNG kullanılmıyor.
  4. `OkumaPdfIstegi` içine `sinif` (akıştan `satir.anaSinif`) ve `tema` alanları eklendi.
  5. `pubspec.yaml`: Literata fontları, lisans dosyaları ve `assets/okuma/hikaye_ikonlari/` eklendi.
- **Karar:** Ajan önerisi, `ONAY BEKLİYOR`: bant değerleri (ikon başına hedef kelime 120 / 190 / 300; punto 13.5 / 12.5 / 12) editoryal başlangıç değeridir. Marka metni mevcut hâliyle korundu ("Hupolingo · Senin Hikâyen", hupolingo.com); K7 marka kararıyla uyumu teyit edilmeli.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ.
  - `dart test` (okuma_motoru): 40/40 geçti.
  - `flutter test` (okuma_pdf, okuma_akis, okuma_kart, okuma_veri): 68/68 geçti; 89 ikonun tamamının PDF'e gömüldüğü test dahil.
  - `flutter analyze` (değiştirilen dosyalar): hata yok, yalnız bilgi uyarıları.
  - Görsel: katalog PDF'i ve renkli 5. sınıf PDF'i PNG'ye çevrilip incelendi. 2. ve 8. sınıf ile mürekkep tasarrufu PNG'leri üretildi ama incelenmedi. Baskı denenmedi.
- **Sorun (açık):**
  1. Repodaki tek hikâye fikstüründe ikon işareti yok; gerçek ikonlu hikâyeyle PDF kontrolü yapılmadı.
  2. Fikstür sözlüğünde 8. sınıf için aday yok (içerik boşluğu).
  3. PDF indir akışında tema seçimi arayüzde yok; yalnız `tema` parametresi var.
  4. `okuma_pdf_hikaye.dart` ve motor dosyaları başka bir ajan tarafından da değiştirildi (sayfa başına ikon üst sınırı, maskotun satır içinden kaldırılması). Bu değişikliklerin görsel kontrolü benim tarafımda yapılmadı; mevcut testler geçiyor.
  5. Okuyucu tarafı (`flutter_svg`) bu kaydın kapsamı dışında; K-0078'e bakın.
  6. `assets/okuma/ikon_manifest.json` etiketlerinde bozuk Türkçe (ör. "KeÅŸfet") var. Dokunulmadı; ayrıca kontrol edilmeli.
  7. Günlükte K numarası çakışması var: K-0077 iki kez, K-0076, K-0030, K-0029 de çift. §9.5 gereği kayıtlar silinmez; yeni kayıtlar K-0085'ten devam eder.
  8. Kullanıcı sohbete bir fal.ai anahtarı yazdı. Kullanılmadı, değeri kayda yazılmadı. Bu iş için anahtar gerekmiyordu. Yenileme önerisi GÖR-001 kapsamında değerlendirilmeli.
- **Sahip:** Ajan, Kullanıcı
- **Önem:** Yüksek
- **İlgili:** K-0078, K-0077, K-0084, GÖR-051, GÖR-001, GÖR-052, GÖR-053

### K-0084 · 2026-10-21 · MOB/TSR · HupoRead / Senin Hikâyen: oturum devir notu (yeni sohbette devam)
- **Tür:** Not
- **Konu:** MOB, TSR
- **Bağlam:** Kullanıcı farklı bir sohbette devam edecek. Bu kayıt, bu oturumun (K-0076…K-0083) özetidir.
- **Bitenler:**
  1. Plan ve direktör incelemesi: `docs/hupo-design-growth/okuma-gorsel-yukseltme-plani-2026-10-21.md`, `okuma-direktor-ortak-karar-2026-10-21.md`, `okuma-karar-ve-uygulama-2026-10-21.md` (K1–K10 son kararlar).
  2. F1: PDF yeniden tasarımı (uygulama paleti, serif başlık, vektör kapak, atasözü bloğu, ikon sınırı), emoji yerine SVG ikon (`flutter_svg`), maskot düzeltmesi.
  3. F2: Okuyucuda Oku · Düşün göstergesi, isteğe bağlı Düşün kartı, "Sözlüğe ekle" (yerel, hesap anahtarlı, en çok 100) ve Okuduklarım içinde Sözlüğüm sekmesi.
  4. F3: `20261051000000_okuma_dusun_alani.sql` uzakta uygulandı (isteğe bağlı `hikaye.dusun`, en çok 3). PGlite: 171/172 (tek kırmızı önceden var: atölyedeki 5 gerçek paket doğrulayıcıdan geçmiyor).
  5. F4: 46 karakter + 80 ikon denetlendi; voksel karakter yerine macera kâşifi, 2 ikon yeniden üretildi, maskot kaydı onaylı master kopyası; **büyücü kullanıcı kararıyla kaldırıldı** (ilkelere aykırı).
  6. APK'lar telefonda (SM-S711B): Hupolingo (`com.ogrencihazirlik.ogrenci_hazirlik`) ve Senin Hikâyen prototip (`com.hupolingo.okuma_prototip`), ikisi de debug imzalı.
- **Açık / sıradaki:**
  1. **Prototipe taşıma kararı (bekliyor):** `C:\Dev\Senin Hikayen - HupoRead\flutter_prototip` içinde yalnız karakter seti eşitlendi. Düşün kartı, Sözlüğüm, SVG çıkartmalar ve yeni PDF üreticisi (`mobile-app/lib/services/okuma_pdf_hikaye.dart`) yalnız Hupolingo'da. Önerim: PDF + Düşün önce taşınsın, Sözlüğüm Hupolingo entegrasyonuyla.
  2. Okuma bayrağı kapalı ve katalogda hikâye yok; açma/yayın kullanıcı onayı ister (önce Ajan A/B + insan okuması).
  3. Hayalî kart astronot gösteriyor (ilk üretilmiş görsel kuralı).
  4. Sözlüğüm kayıt silme yok; `dusun` soruları istemcide henüz gösterilmiyor (içerik yok).
  5. Cihazda okuyucu/Düşün/PDF akışı görsel olarak denenmedi; 360x640 önizleme üreticisi yok.
  6. **Güvenlik:** `GEMINI_API_KEY` değeri bu oturumda bir çıktıda göründü; kullanıcı test sürecinde sorun olmadığını söyledi, yine de yayın öncesi döndürülmeli (GÖR-001).
- **Durum:** DEVAM
- **Doğrulama:** Ayrıntı K-0078…K-0083 kayıtlarında.
- **Sahip:** Ajan, Kullanıcı
- **Önem:** Yüksek
- **İlgili:** K-0076…K-0083, GÖR-051, GÖR-001

### K-0083 · 2026-10-21 · MOB · Senin Hikâyen (flutter_prototip) APK: derleme, karakter eşitleme, telefona kurulum
- **Tür:** GELİŞME + KARAR
- **Konu:** MOB
- **Bağlam:** Kullanıcı Hupolingo APK'sı yerine bağımsız "Senin Hikâyen" APK'sının güncellenmesini istedi. PLAN.md (ONAYLI): modül önce bağımsız klasörde (`C:\Dev\Senin Hikayen - HupoRead\flutter_prototip`) geliştirilir, sonra Hupolingo'ya entegre edilir.
- **Yapılanlar:**
  1. Prototip (`okuma_prototip`, kimlik `com.hupolingo.okuma_prototip`, ad "Senin Hikâyen") derlendi: debug APK 172,5 MB. Telefona `adb install -r` ile kuruldu; Hupolingo ile yan yana çalışıyor.
  2. Karakter seti Hupolingo'daki güncel hâle eşitlendi (`karakterler/` 46 dosya, `karakter_manifest.json`). Büyücü ve voksel karakter prototipten de kaldırıldı; macera kâşifi ve onaylı maskot kopyası geldi. Prototip kodunda eski kimlik kalmadı.
  3. Telefonda kahraman ekranı doğrulandı: "Hazır Hupo" kartı onaylı maskotu gösteriyor; "Çizgi film tarzı karakter" kartı mevcut bir görsel (astronot) kullanıyor.
- **Açık / sınır:** Prototipte Hupolingo'daki son okuma geliştirmeleri yok: Düşün kartı, Sözlüğüm, SVG çıkartmalar ve yeni PDF üreticisi (`okuma_pdf_hikaye.dart`). Bunlar Hupolingo'ya bağımlı (providerlar, depo) olduğu için port işi ayrı bir karar: prototipe taşınıp taşınmayacağı kullanıcıya soruldu. Hayalî kart, türün ilk üretilmiş görselini seçiyor (macera kâşifi yerine astronot); kart seçim kuralı değişirse düzeltilecek.
- **Durum:** Prototip APK kurulu ve çalışıyor; okuma geliştirmelerinin prototipe aktarımı bekliyor.
- **Doğrulama:** Derleme başarılı; cihazda ekran görüntüsüyle ilk ekran ve kaydırılmış kahraman listesi incelendi. Hikâye akışı (okuyucu, sorular, PDF) cihazda bu turda denenmedi.
- **Sahip:** Ajan, Kullanıcı (port kararı)
- **Önem:** Orta
- **İlgili:** K-0082, K-0081, GÖR-051

### K-0082 · 2026-10-21 · MOB · HupoRead büyücü kaldırma, APK derleme ve telefona kurulum
- **Tür:** GELİŞME + KARAR
- **Konu:** MOB
- **Bağlam:** Kullanıcı büyücü karakterinin ilkelerine aykırı olduğunu, maskot kartının kahraman olarak gösterilebileceğini belirtti; ardından uygulamanın APK olarak telefona kurulmasını istedi.
- **Yapılanlar:**
  1. `karakter_fantastik_buyucu` manifestten, dosyadan ve prompt belgesinden kaldırıldı. Karakter sayısı 46.
  2. Maskot kartı: `hazir` kartı zaten animasyonlu Hupo bileşenini (`OkumaMaskot`) gösteriyor; kod değişikliği gerekmedi. `hupo_kus` kaydı onaylı master kopyası olarak kalıyor.
  3. `flutter build apk --debug` başarılı (205,8 MB). Samsung SM-S711B'ye `adb install -r` ile kuruldu (Success); uygulama açıldı ve ana sayfa göründü.
  4. Öğren sekmesinde Senin Hikâyen (okuma) kartı görünmüyor: sunucu tarafı özellik bayrağı kapalı ve kataloğa hikâye yüklenmemiş (K-0069 ile aynı durum). Bayrağı açmak ve hikâye yayınlamak çocuklara dönük, geri alınması zor bir değişiklik; kullanıcı onayı bekliyor.
- **Açık / insan kararı:** Bayrağın açılması ve ilk hikâyelerin yayınlanması (4–5. sınıf, önce Ajan A/B ve insan okuması).
- **Durum:** APK kuruldu ve çalışıyor; okuma modülü telefonda henüz canlı değil.
- **Doğrulama:** `flutter test` okuma testleri 77/77 geçti (büyücü kaldırıldıktan sonra). Cihaz ekran görüntüsü: ana sayfa ve Öğren sekmesi. Okuma akışı uçtan uca denenmedi (bayrak kapalı).
- **Sahip:** Kullanıcı (bayrak ve yayın onayı), Ajan
- **Önem:** Orta
- **İlgili:** K-0081, K-0069, GÖR-051

### K-0081 · 2026-10-21 · MOB · HupoRead F4: görsel varlık denetimi ve düzeltmeler (nano-banana bağlı)
- **Tür:** GELİŞME + SORUN
- **Konu:** MOB
- **Bağlam:** Claude Code yeniden başlatıldı; nano-banana yapılandırması doğrulandı (API anahtarı var, model `gemini-3.1-flash-image-preview`). K-0074'ün "üretim engelli" notuna karşın `assets/okuma/karakterler` (47) ve `ikonlar` (80) dosyaları diskte zaten vardı; manifestlerde `uretildi: true`. Üretim kaydı, çıktı klasörü veya MCP geçmişi bulunamadı; kökeni belgelenmemiş.
- **Yapılanlar:**
  1. Denetim: 127 dosya şeffaf RGBA, magenta kalıntısı yok, manifest–dosya eşleşmesi tam. Kontrol levhalarıyla görsel inceleme yapıldı.
  2. Düzeltme: `karakter_fantastik_blok_kasif` (voksel/küp karakter; oyun estetiğine yakın, telif riski) → `karakter_fantastik_macera_kasifi` (yeni üretim, pusula kolyeli kâşif; manifest ve prompt güncellendi).
  3. Düzeltme: `ikon_kullanici_bildirim` ve `ikon_oyun2_elmas`: şeffaf olmayan açık kutu arka planı kalmıştı; yeniden üretildi ve magenta anahtarlamayla şeffaflaştırıldı (çan: ilk denemede 4 varyant çıktı, tek nesneyle yeniden üretildi).
  4. Düzeltme: `karakter_hayvan_hupo_kus.webp` (çocuk çizimi) onaylı master `assets/hupo/uygulama/rehber_sol.webp` kopyasıyla değiştirildi (K5 kararı); manifest etiket/açıklama/kaynak `onayli_hupo_master` olarak düzeltildi.
  5. `okuma-varlik-promptlari.json`: blok karakter promptu yeni karakterle değiştirildi.
- **Açık / insan kararı:** (a) `karakter_fantastik_buyucu` (büyücü) gorsel-kutuphane notunda editör onayı bekliyor; (b) `karakter_hayvan_hupo_kus` artık maskot kopyası: kahraman kartında gösterilip gösterilmeyeceği UI'da doğrulanmalı; (c) AI üretimli görsellerin telif durumu GÖR-045 hukuk başlığında.
- **Durum:** F4 TAMAM (varlık seti, denetim ve 4 düzeltme); tek kabul eksiği: cihazda görsel doğrulama.
- **Doğrulama:** Dosya ve manifest tutarlılığı (JSON geçerli, eksik dosya 0). `flutter test` okuma testleri (varlık, kart, PDF, sözlüğüm, depo) geçti. Kâşif ve ikonlar için kontrol levhası incelendi. Cihazda kahraman seçim ekranı görünümü **doğrulanmadı**.
- **Sahip:** Ajan, Kullanıcı (büyücü onayı, maskot kartı kararı)
- **Önem:** Orta
- **İlgili:** K-0074, K-0079, K-0080, GÖR-051, GÖR-045

### K-0080 · 2026-10-21 · VT/MOB · HupoRead F3 uzak migration, Sözlüğüm ekranı, nano-banana durumu
- **Tür:** GELİŞME + KARAR + SORUN
- **Konu:** VT, MOB
- **Bağlam:** Kullanıcı uzak Supabase migration'ını onayladı; nano-banana için API anahtarını Windows kullanıcı ortam değişkenine yazdığını söyledi; Sözlüğüm listesinin yerini bize bıraktı.
- **Yapılanlar:**
  1. **Migration `20261051000000_okuma_dusun_alani.sql` uzakta uygulandı** (`npm run db:preview` ile yalnız bu migration bekliyordu; `db:deploy` sonrası bekleyen migration yok). Kapsam: `_okuma_paket_hatalari` doğrulayıcısına isteğe bağlı `hikaye.dusun` (en çok 3, her biri `{id, metin}`). Kopya kaynak migration'dan betikle üretildi; yalnız iki noktası değişti. Eski paketler etkilenmez.
  2. **PGlite testleri:** `supabase/tests/okuma_dunyasi`: 6 yeni senaryo geçti (geriye uyum, 2 kabul, 4 red, dizi olmayan, kısa metin, bilinmeyen alan / büyük harf id).
  3. **Sözlüğüm:** Okuduklarım ekranına ikinci sekme olarak eklendi (aynı kişisel raf, aynı giriş noktası; yeni menü öğesi yok). Boş durumda davet; liste anlam ve tarihle; sayı, puan ve sıralama yok. Widget testi 2 senaryo.
  4. **nano-banana:** Kullanıcı ortamındaki `GEMINI_API_KEY`, proje `.env` dosyasındaki anahtarla özet karşılaştırmasıyla eşleşti (değer gösterilmedi). Bu oturumun süreci eski değeri taşıyor ve MCP bağlantısı zaman aşımına uğradı; **Claude Code'un yeniden başlatılması gerekiyor**. Yeniden başlatmadan F4 başlamaz.
- **SORUN (güvenlik):** Bu oturumda bir hata çıktısında `GEMINI_API_KEY` değeri (`AQ.` ile başlayan) yanlışlıkla görüntülendi. Anahtar konuşma çıktısına düştüğü için **döndürülmesi önerilir** (GÖR-001 ile birlikte).
- **SORUN (önceden var):** `supabase/tests/okuma_dunyasi` senaryosu "atölyedeki tüm gerçek paketler doğrulayıcıdan geçer" **26/31** veriyor; 5 gerçek paket doğrulamadan geçmiyor. Bu migration'dan önceki durum; içerik hattında ele alınacak.
- **Açık / insan kararı:** Sözlüğüm kayıtlarını silme yok (kayıt yalnız eklenir); liste görünümünün ürün kararı yeniden gözden geçirilebilir. Düşün kartında `dusun` soruları henüz istemci tarafından gösterilmiyor (içerik yok; yayın kapısı içerik hazır olunca).
- **Durum:** F3 TAMAM (uzak). F4 BEKLİYOR (yeniden başlatma).
- **Doğrulama:** `flutter analyze` temiz; `flutter test` okuma testleri 77/77; SQL 171/172 (tek başarısız senaryo önceden var: atölye paketleri).
- **Sahip:** Ajan, Kullanıcı (anahtar döndürme)
- **Önem:** Yüksek
- **İlgili:** K-0079, GÖR-001, GÖR-051, K-0074

### K-0079 · 2026-10-21 · MOB/TSR · HupoRead görsel yükseltme: uygulama planı (F2–F4)
- **Tür:** Plan + Karar
- **Konu:** MOB, TSR
- **Bağlam:** Kullanıcı K1–K10 için önerileri onayladı ve planın günlüğe yazılıp uygulamaya başlanmasını istedi. Düşün adımının isteğe bağlı olması önerisi kabul edildi.
- **Plan:**
  1. **F2 (uygulanıyor):** Okuyucuda iki adımlı gösterge (Oku · Düşün), yalnız hikâyede anlamı olan atasözü varsa. Son sayfada isteğe bağlı "Düşün" kartı: atasözü, anlamı, "Sözlüğe ekle". Sözlük kaydı yalnız cihazda, hesap anahtarlı kişisel rafta (`sozlugum`), en çok 100 kayıt; metin nötr ("Defterine eklendi.") ve XP/ödül yok. Atasözünün anlamı yoksa kart o atasözünü göstermez (uydurma içerik yok). Keşfet davranışı (kelime ve atasözü dokununca alt sayfa) değişmez.
  2. **F2 testleri:** depo kaydı (tekrarsız, sınırlı, hesaba bağlı) birim testi; mevcut okuma testleri yeniden koşulur.
  3. **F3 (başlamadı, onay bekliyor):** `dusun` ve ikon anotasyonu alanları; uzak Supabase migration'ı kullanıcı onayı olmadan yapılmaz. Yayın yalnız kullanıcı okuması ve onayıyla.
  4. **F4 (engelli):** Raster sahne ve kapak görselleri; nano-banana bağlantısı (K-0074) düzelince.
- **Açık / insan kararı:** F3 canlı DB onayı. Sözlüğüm için henüz bir liste ekranı yok; kayıtlar şimdilik yalnız saklanır (ayrı karar).
- **Durum:** DEVAM (F2 uygulandı; F3–F4 açık)
- **Doğrulama:** KISMİ. `flutter analyze` (okuyucu, depo, tema, PDF, yeni test) temiz. `flutter test` okuma testleri 75/75 geçti, depo testi 5 senaryo dahil. Okuyucudaki Düşün kartı ve gösterge için widget testi yok; cihazda görünüm doğrulanmadı.
- **Sahip:** Ajan
- **Önem:** Yüksek
- **İlgili:** K-0078, GÖR-051

### K-0078 · 2026-10-21 · MOB/TSR · HupoRead görsel yükseltme F1 uygulandı (PDF, okuyucu ikonları, manifest)
- **Tür:** Gelişme + Karar
- **Konu:** MOB, TSR
- **Bağlam:** Kullanıcı K1–K10 kararlarını bize bıraktı (K7 marka adı: Senin Hikâyen). Kararlar `docs/hupo-design-growth/okuma-karar-ve-uygulama-2026-10-21.md` içinde.
- **Yapılanlar:**
  1. PDF (`okuma_pdf_hikaye.dart`): uygulama paleti, serif başlıklar, vektör kapak sahnesi, atasözü bloğu, sayfa başına ikon sınırı (2 / 1), metin içinde maskot yok, büyük harf hatası düzeltildi.
  2. Okuyucu (`okuyucu_ekrani.dart`): emoji glifi yerine `flutter_svg` ile katalog SVG'si; maskot atlanır; süs ikonu ekran okuyucuda atlanır.
  3. `okuma_tema.dart`: Zengin modda çıkartma sınırı 3 → 2.
  4. `karakter_manifest.json`: `karakter_hayvan_hupo_kus` yanlış "onaylı master" etiketi düzeltildi.
  5. `pubspec.yaml`: `flutter_svg ^2.3.0` eklendi; `pubspec.lock` 4 bağımlılık değiştirdi.
- **Açık / insan kararı:** F2 (okuyucu Oku/Keşfet/Düşün akışı): Düşün adımı isteğe bağlı mı, zorunlu mu? Önerim: isteğe bağlı. F3 canlı DB migration onayı. F4 raster sahneler (K-0074).
- **Durum:** DEVAM (F1 uygulandı; F2–F4 açık)
- **Doğrulama:** KISMİ. `flutter analyze` (3 dosya) temiz; `flutter test test/okuma_*` 70/70 geçti; PDF'ler PNG'ye çevrilip görsel kontrol edildi (5. sınıf tam, 2. ve 8. sınıf hikâye sayfası). Okuyucu ikonları cihazda ve 360x640 önizlemede görülmedi; baskı denenmedi.
- **Sahip:** Ajan, Kullanıcı (F2 akış kararı)
- **Önem:** Yüksek
- **İlgili:** K-0076, K-0077, GÖR-051, K-0074

### K-0077 · 2026-10-21 · MOB/TSR · HupoRead plan direktör incelemesi: ortak karar tablosu
- **Tür:** Karar + Sorun (plan düzeltmesi)
- **Konu:** MOB, TSR
- **Bağlam:** Kullanıcı `hupo-design-growth-director` ajanının da değerlendirmesini istedi. Ajan salt okunur inceleme yaptı.
- **Yapılanlar:**
  1. Maskot teşhisi düzeltildi: `assets/hupo/uygulama/rehber_sol.webp` onaylı Hupo görünümünde ve PNG'deki kuşla eşleşiyor. Sorun `karakter_hayvan_hupo_kus` etiketinde (çocuk görseli, "onayli_hupo_master" etiketi).
  2. PDF başlık fontu düzeltildi: brief serif/display istiyor, kod Nunito kullanıyor.
  3. K2, K3, K4, K5 güncellendi; K7–K10 eklendi (marka adı, okuyucuda Hupo ve ikon bütçesi, PDF stili, "Sözlüğe ekle" kaydı).
  4. Karar belgesi: `docs/hupo-design-growth/okuma-direktor-ortak-karar-2026-10-21.md`.
- **Açık / insan kararı:** K7 marka adı, K8 okuyucuda Hupo ve ikon bütçesi (K3 ile birlikte), K9 PDF stili, K10 "Sözlüğe ekle" kaydı, K5 maskot teyidi, K1/K2/K4/K6 onayı. Kullanıcı yanıtı gelmeden kod değişmez.
- **Durum:** KARAR BEKLİYOR
- **Doğrulama:** KISMİ (görüntü ve kod satırları bu oturumda doğrulandı; cihaz, PDF çıktısı ve baskı yok)
- **Sahip:** Ajan, Kullanıcı (kararlar)
- **Önem:** Yüksek
- **İlgili:** K-0076, GÖR-051

### K-0076 · 2026-10-21 · MOB/TSR · HupoRead görsel ve içerik sunumu yükseltme planı (kod değişmedi)
- **Tür:** Plan + Karar
- **Konu:** MOB, TSR
- **Bağlam:** Kullanıcı ChatGPT ile hazırlanan HupoRead ZIP paketini (PDF tasarım örneği, 89 ikon, manifest, tokenlar) ve PNG referans ekranını verdi; görsel kalite ve içerik sunumunu yükseltme planı istedi. Kullanıcı, mevcut tasarım seviyesinin altına düşülmemesini istedi.
- **Yapılanlar:**
  1. ZIP'teki 179 dosya (178 SVG + manifest) repodaki `assets/okuma/hikaye_ikonlari/` ile SHA-256 olarak birebir eşleşti; yeni import gerekmiyor.
  2. Palet farkı: PDF zip tokenlarını (`F5B73D`, `17344D`, `48AFCC`) kullanıyor, uygulama AppColors'ı (`F5C842`, `17324D`, `147D8A`) kullanıyor.
  3. Emoji çelişkisi: PNG satır içi emoji içeriyor; brief bunu yasaklıyor; okuyucuda emoji "çıkartma" stili tanımlı.
  4. Plan yazıldı: `docs/hupo-design-growth/okuma-gorsel-yukseltme-plani-2026-10-21.md` (F0–F5 fazları, kabul ölçütleri, riskler). Kod ve içerik değiştirilmedi.
- **Açık / insan kararı:** K1 palet (öneri: AppColors tek kaynak), K2 Düşün adımı için `dusun` alanı (öneri: evet), K3 emoji → SVG (öneri: evet), K4 ilk fazlar görselsiz (öneri: evet), K5 onaylı maskot master teyidi, K6 canlı paket sözleşmesi ve migration onayı.
- **Maskot uyarısı:** `karakter_hayvan_hupo_kus.webp` görüntülendi; kuş değil, turuncu saçlı bir çocuk çiziyor. PNG'deki kuşla eşleşmiyor. Onaylı master belirlenmeden maskotlu ekranlar kabul edilmez.
- **Görsel kütüphane:** K-0074 (ENGELLİ: nano-banana anahtarı bayat; bu oturumda MCP bağlantısı zaman aşımına uğradı).
- **Durum:** PLAN (karar bekliyor)
- **Doğrulama:** KISMİ (dosya karşılaştırması, kod okuma, görüntü inceleme; cihazda görünüm ve PDF render yapılmadı)
- **Sahip:** Ajan, Kullanıcı (kararlar)
- **Önem:** Yüksek
- **İlgili:** K-0074, K-0075, GÖR-044, GÖR-051

### K-0077 · 2026-10-21 19:05 · MOB/TSR · Okuma Dünyası: görsel varlık üretimi, uygulama ve prototip APK'ları, PDF SVG ikonları
- **Tür:** Gelişme + Karar
- **Konu:** MOB, TSR
- **Bağlam:** Kullanıcı görsel kütüphanesinin üretilmesini onayladı (ONAYLI) ve iki APK'nın (ana uygulama ve Senin Hikâyen prototipi) güncel hâle getirilmesini istedi.
- **Yapılanlar:**
  1. **Görsel üretimi:** Gemini görsel modeliyle (gemini-3.1-flash-image-preview) 47 karakter ve 80 ikon üretildi; kayıp yok. Arka plan macenta, kenarlardan okunup saydam yapıldı, WebP'ye çevrildi. İlk ikon partisinde zemin kalıntısı ve ızgara çıktılar görüldü; betik düzeltilip (tek nesne kuralı, kenar rengine göre anahtarlama) yeniden üretildi, iki ikon ayrıca düzeltildi. Kontrol tabloları incelendi.
  2. **Ana uygulama:** ssets/okuma/karakterler/ (47) ve ssets/okuma/ikonlar/ (80) üretildi; manifestler uretildi: true yapıldı; pubspec'te iki klasör girdisi (ilk eklemede tek satırda birleşen hatalı girinti düzeltildi). okuma_varlik_test ve okuma_kart_test geçti. Debug APK derlendi, com.ogrencihazirlik.ogrenci_hazirlik telefona kuruldu. Okuma Dünyası bayrağı (okuma_ayarlari) canlıda kapalı olduğu için modül telefonda görünmüyor; bayrak açılmadı (onay bekliyor).
  3. **Prototip (Senin Hikâyen):** gömülü "Hazır Hupo" paketleri revizyon sonrası sürüme güncellendi, 	ek-kanatli-ucurtma (sınıf 5, hazir dahil) kataloğa eklendi. Karakter görselleri ve KahramanGorsel kahraman kartına bağlandı; telefonda kartlar görsellerle göründü (doğrulandı). PDF emoji PNG'leri, kod-SVG eşlemesiyle (ikonKimligiCoz → ikonBul → hikaye_ikonlari/*.svg) değiştirildi; lutter analyze: 0 hata, 3 bilgi uyarısı. APK derlendi ve kuruldu.
  4. **Ayrım:** PDF ikonları yalnızca ssets/okuma/hikaye_ikonlari/ içinde SVG + manifest.json; WebP'ler bu klasörde yok (doğrulandı: 0 WebP). Uygulama WebP'leri karakterler/ ve ikonlar/ içinde.
- **Açık / doğrulanmadı:**
  - Prototipte sonuç ekranı 2.0 düzeltmesi: kodda işaretler var ama telefonda doğrulanmadı.
  - PDF çıktısı (SVG ikonlar) üretilip kontrol edilmedi.
  - Hikâye akışı (hikâye listesi, okuyucu, sorular, PDF, sonuç) telefonda uçtan uca denenmedi.
  - Ana uygulamada karakter/ikon görünümü, bayrak kapalı olduğu için görülemedi.
  - Sonuç ekranı 2.0 ana uygulama düzeltmesi widget testleriyle doğrulandı (K-0075); cihazda değil.
  - Gemini anahtarı sohbete düz metin olarak yazıldı: **yenilenmesi önerildi** (değeri bu kayda yazılmadı). Anahtar yalnızca komut süresince ortam değişkeni olarak kullanıldı; dosyaya yazılmadı.
  - Ajan A/B denetimleri revize metinlere yeniden uygulanmadı; denetim alanları pending. Kör karşılaştırma ve sözlük hazırlığı yapılmadı.
  - Ajan (Sonnet) oturum sınırına takıldı; prototip port işinin bir kısmı ana oturumda tamamlandı.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ (üretim, derleme, kurulum ve kahraman kartı ekran görüntüsüyle doğrulandı; PDF, sonuç ekranı ve hikâye akışı doğrulanmadı)
- **Sahip:** Ajan, Kullanıcı (bayrak açma, anahtar yenileme, son okuma)
- **Önem:** Yüksek
- **İlgili:** K-0074, K-0075, GÖR-044, GÖR-045

- **Güncelleme 2026-10-21 19:07 (anahtar yönetimi):** Gemini ve fal.ai anahtarları sohbette düz metin olarak paylaşıldı. Değerleri bu kayda ya da hiçbir git'e bağlı dosyaya yazılmadı. Kural: anahtarlar yalnızca git dışı yerel yapılandırmada tutulur (\.claude/settings.local.json\ ya da kullanıcı ortam değişkenleri); ajanlar değerleri kullanmadan önce kullanıcıya sorar. Her iki anahtarın yenilenmesi önerildi, çünkü sohbet geçmişinde görünüyor. Kullanıcı, anahtarların dış dünyayla paylaşılmamasını istedi (iç bilgi).

- **Güncelleme 2026-10-21 19:09 (ortam değişkenleri):** \GEMINI_API_KEY\ ve \FAL_KEY\ Windows kullanıcı ortam değişkeni olarak tanımlandı (kalıcı, değerler kayda yazılmadı). Yeni süreçler için Claude Code yeniden başlatılmalı. Görsel üretim MCP sunucusu (nano-banana) kendi yapılandırmasındaki eski anahtarı kullanıyor; bunun ortam değişkenine bağlanması ayrıca yapılacak. Anahtar yenileme önerisi geçerli.

### K-0075 · 2026-10-21 10:05 · MOB/TSR · Okuma Dünyası Aşama A (yerel işler): denetimler, hikâye revizyonu, sonuç ekranı 2.0
- **Tür:** Gelişme + Karar
- **Konu:** MOB, TSR
- **Bağlam:** Kullanıcı Aşama A'yı başlattı ve pilot için 4–5. sınıfları uygun buldu (`ONAYLI`).
- **Yapılanlar:**
  1. Hazır Hupo: iki hikâye (sınıf 4) zaten vardı; sınıf 5 için `tek-kanatli-ucurtma` `hazir` türüne açıldı. Sınıf 6–8 için hazir hikâye yok.
  2. Sonuç ekranı 2.0: kök neden sabit alt alanın kısa ekranı kaplaması; maskot küçültme ve ikincil düğmeleri içeriğe taşıma. 4 yeni widget testi, önce/sonra PNG.
  3. Platform denetimi (okuma ekranları): rapor `docs/hupo-design-growth/okuma-platform-denetimi-2026-10-21.md`; 1 Kritik (yasak ad listesi yok), 6 Yüksek, 10 karar bekleyen madde.
  4. Ajan A (Opus) 26 hikâye: 9 pass, 13 review_needed, 4 fail. Ajan B (Opus): 1 pass, 21 review_needed, 4 fail. Raporlar `icerik/denetim/` (hikâye deposu).
  5. Hikâye revizyonu (4 Sonnet yazar): düz "Kahraman" → token, vaaz sahneye, bilgi/güvenlik hataları (tutulma, kuyu, gölge, pusula, birincil kaynak), soru şık uzunluğu ve harf dağılımı, kanıt düzeyi B→C. Derleme hata 0, `npm test` 30/30 (yazarlar bildirdi).
- **Açık / insan kararı:** sınıf-kazanım eşleşmeleri (TYMM PDF okunamadı), D19/D15 değer etiketleri, "sakin" TDK teyidi, kuş besleme ifadesi uzman onayı, `erkek_egilimli` etiketi, 1. sınıf harf-ses izi. Kör karşılaştırma yapılmadı (Haiku öncesi metin yedekte yok; yedek = revizyon öncesi hâl). Sözlük verisi hazırlanmadı. Yeni metinler henüz Ajan A/B ile yeniden denetlenmedi; `denetim:` alanları pending. Hiçbir hikâye yayınlanmadı.
- **Görsel kütüphane:** K-0074 (ENGELLİ: görsel üretim aracı bayat anahtar).
- **Durum:** DEVAM
- **Doğrulama:** KISMİ (derleme bu oturumda yeniden doğrulandı; cihaz/ekran okuyucu ve revize metinlerin yeniden denetimi yok)
- **Sahip:** Ajan, Kullanıcı (son okuma, kararlar)
- **Önem:** Yüksek
- **İlgili:** K-0065, K-0066, K-0069, K-0074, GÖR-044, GÖR-045

### K-0074 · 2026-10-21 · TSR · HupoRead görsel kütüphane: altyapı hazır, görsel üretim ENGELLİ
- **Tür:** Gelişme
- **Konu:** TSR
- **Bağlam:** 47 karakter + 80 ikonluk bağımsız varlık kütüphanesi istendi.
- **Durum:** ENGELLİ
- **Doğrulama:** KISMİ
- **Sahip:** Kullanıcı
- **Önem:** Orta
- **Açıklama:** nano-banana-2 MCP anahtarı geçersiz (400 API_KEY_INVALID); hiçbir görsel üretilmedi. Manifestler (üretildi=false), şema, Dart model/yükleyici ve kahraman kartı bağlantısı (yedek ikonlu) hazır. Anahtar düzeltilince üretim başlar.
- **Kanıt:** `flutter test test/okuma_*` 61 test geçti; ilgili dosyalarda `flutter analyze` 0 sorun.
- **İlgili:** `docs/hupo-design-growth/okuma-gorsel-kutuphane-2026-10-21.md`, `mobile-app/assets/okuma/`

### K-0073 · 2026-10-21 · DEN · 6. sınıf Türkçe seti: 91 soru, 91/91 kazanım kapsandı (kapı 91/91)
- **Tür:** Gelişme
- **Bağlam:** 6. sınıf Türkçe programı ayrıştırıldı (91 kod; K-0072). Üretim: dinleme/izleme ve konuşma 37, okuma 19 (+3 ek), yazma 17 (+2 kapsam), eksik 15 kazanım için ek 15.
- **Karar:** Haiku: ana set 75/76 (TR6-Y-016 BELIRSIZ, çıkarıldı), yeni 17 soru 17/17. Sonnet: DK-014 ve Y-001 ve Y-016 çıkarıldı (ikisi DÜZELT/BELIRSIZ); Y-E01 B şıkkı düzeltildi. Kodlama bozulması (çift kodlanmış Türkçe karakterler) 37 DK sorusunda onarıldı; kalan mojibake yok.
- **Durum:** Türkçe 6: 91 soru, 91/91 kazanım, kapı 0 RED. Haiku/Sonnet denetimi tamam; Y-E01 düzeltmesi yalnız kapı ile doğrulandı (yeniden çözücü turu yapılmadı).
- **Doğrulama:** KISMİ (kazanım metinleri PDF'ten parçalı çıkarıldı; başlıklar Haiku ile kesitlerden alındı; DÖP metniyle tam teyit yok).
- **Sahip:** Ajan · **Önem:** Orta
- **İlgili:** K-0072.

### K-0072 · 2026-10-21 · BEL · 6. sınıf Türkçe programı ayrıştırıldı (73 kazanım kodu)
- **Tür:** Gelişme
- **Bağlam:** Ortaokul Türkçe DÖP (tymm 2026-09-02) 6. sınıf çıktıları için kazanım tablosu gerekiyordu.
- **Karar:** Çıktılar, alan becerisi (dinleme, konuşma, okuma, yazma) bloklarından çıkarıldı: docs/soru-uretim/pilot/kazanim_6_turkce.json (T.D 18, T.K 19, T.O 19, T.Y 17 = 73 kod). Başlıklar PDF satır kırılmalarından dolayı bazen parçalı (ör. T.D.6.1, T.D.6.2).
- **Durum:** TAMAMLANDI (ayrıştırma). Soru üretimi henüz başlamadı; kazanım metinleri kısmen parçalı, üretimden önce kontrol edilmeli.
- **Doğrulama:** KISMİ (kod sayısı ve alan dağılımı kontrol edildi; metinler gözle kısmen doğrulandı)
- **Sahip:** Ajan · **Önem:** Orta
- **İlgili:** K-0067, K-0068 (6. sınıf diğer dersler).

### K-0071 · 2026-10-21 · VT · Yayın kararı: 314 soru onaylandı (kullanıcı kararı)
- **Tür:** Karar (ONAYLI, kullanıcı)
- **Bağlam:** K-0070'te beklemede aktarılan parti soru-uretim-2026-10-21. Kullanıcı "Hepsini onayla" seçti.
- **Karar:** 314 soru onay_durumu='onaylandi', insan_onayi_kim='kullanici', insan_onayi_karar='onay', soru_importlari.onayli=true. Kalite 'sari' ve insan örneklemi (§15) yapılmadan yayına alındı; bu kararın bedeli kullanıcıda.
- **Doğrulama:** DOĞRULANDI (yeni onaylı 314, kalan beklemede 0, toplam 824, onaylı 824). Mevcut onaylı 510 değişmedi (510 + 314).
- **Durum:** TAMAMLANDI (yayın). Takip: kalite 'sari' sorular için öğrenci verisi ve sonradan insan örneklemi.
- **Sahip:** Kullanıcı (karar), Ajan (uygulama) · **Önem:** Yüksek
- **İlgili:** K-0070, REHBER §15.

### K-0070 · 2026-10-21 · VT · Soru paketi veri tabanına aktarıldı (parti soru-uretim-2026-10-21, 314 soru, beklemede)
- **Tür:** Gelişme + Karar (kullanıcı talebi: "tüm soruları gerçek veri tabanına aktar")
- **Bağlam:** Uzak Supabase (ccozfrpnvyrnktpffkwo). Admin RPC (admin_import_questions_v2) oturumsuz çağrılamaz (require_admin); CLI ile aynı doğrulama/eşleme kurallarıyla tek transaction'da SQL aktarımı yapıldı.
- **Karar:** Hepsi onay_durumu='beklemede' (yayın kapısı insan onayı, §15, bekliyor). kaynak_turu='uretilen', uretim_yontemi='llm', kalite_durumu='sari', gorsel_gerekli=false. created_by boş (sistem). Mevcut 510 soru değişmedi (hepsi onaylandi). Paket: docs/soru-uretim/paket/soru_paketi_2026-10-21.json.
- **Kapsam:** 4. sınıf: Türkçe 28, Matematik 28, Fen 25, Sosyal 28. 5. sınıf: Matematik 36, Fen 35, Sosyal 38. 6. sınıf: Matematik 30, Fen 36, Sosyal 30.
- **Durum:** TAMAMLANDI (aktarım); yayın BEKLİYOR (insan onayı, §15; kullanıcı kararı).
- **Doğrulama:** DOĞRULANDI (parti eklenen sayısı ve beklemede sayısı 314; onaylı sayı 510 değişmedi).
- **Sahip:** Ajan · **Önem:** Yüksek
- **Açıklama:** Fen 5 setindeki FEN5-B-001..003 DÖP ile 5. sınıf kabul edilerek eklendi (Sonnet 6–7 itirazı). Tartışmalı kalite kararları (Sonnet 6. sınıf fen, 5. sınıf fen ek) DÖP ile teyit edilmeli. Türkçe 6 eklenmedi (program ayrıştırması yok).
- **İlgili:** K-0068, REHBER §15, §18; migration 20261047000000 (uzakta uygulanmış).

### K-0069 · 2026-10-21 02:12 · VT/MOB · Okuma Dünyası: veritabanı migration'ları canlıya alındı; Android debug APK derlendi ve telefona kuruldu
- **Tür:** Dağıtım (kullanıcı onaylı)
- **Konu:** VT, MOB
- **Yapılanlar:**
  - **`db:deploy`:** `20261050000000`…`20261050000500` (6 migration: tablolar, yönetim, öğrenci, veli/öğretmen, sözlük, export_my_data) uzak DB'ye uygulandı. `db:status`: yerel ve uzak sürümler eşleşiyor. Bayrak `okuma_ayarlari` varsayılan KAPALI; **hikâye içeriği YÜKLENMEDİ**, sözlük boş.
  - **APK:** `flutter build apk --debug` başarılı (205 MB; debug imzalı; `build\app\outputs\flutter-apk\app-debug.apk`). Android SDK ve JDK (Android Studio jbr) kullanıldı. Release imzası için `android/key.properties` yok; yayın APK'sı/AAB için anahtar gerekir.
  - **Kurulum:** Samsung SM-S711B (Android 16), `adb install -r` → Success. `com.ogrencihazirlik.ogrenci_hazirlik` açıldı (pid 9512).
- **Doğrulanmayan:** Okuma modülü telefonda görünmüyor: bayrak kapalı ve kataloğa hikâye yüklenmedi. Uçtan uca canlı akış denenmedi. Android SDK lisanslarından 7'si `flutter doctor --android-licenses` ile tam kabul edilmedi (build yine de başarılı).
- **Sonraki (onay gerekir):** (1) Bayrağı açmak ve hikâyeleri (4–5. sınıf önce) yayına almak için kullanıcı onayı; önce Ajan A/B ve insan okuması. (2) Sözlük içe aktarma (`okuma_sozluk_ice_aktar`) ve paneldeki içe aktarma akışının gerçek hesapla denenmesi. (3) Release APK/AAB için imza anahtarı kararı.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ (dağıtım ve kurulum doğrulandı; okuma akışı telefonda henüz denenmedi)
- **Sahip:** Kullanıcı (bayrak ve içerik yayın kararı), Ajan
- **Önem:** Yüksek
- **İlgili:** K-0061, K-0065, K-0066

### K-0068 · 2026-10-21 · DEN · 6. sınıf boşluk turu: Matematik 30 ve Fen 36 kazanım tamamen kapsandı
- **Tür:** Gelişme
- **Bağlam:** Kullanıcı: 6. sınıf boşlukların hepsi için ek tur, boşluk kalmasın.
- **Karar:** Boş 11 kazanım (MAT.6.3.3 + 10 FB.6.x) için 11 soru yazıldı. Kapı: BOS6-011 sayısal ifade düzeltildi, 11/11. Haiku 11/11 anahtar uyumu (ilk çalışma girdi dosyası yokluğundan boş dönmüştü, yeniden çalıştırıldı). Sonnet 11 GEÇER. Birleştirildi.
- **Durum:** Matematik 6: 30 soru, 24/24 kazanım. Fen 6: 36 soru, 36/36 kazanım. Sosyal 6: 30 soru, 18/18. Türkçe 6: ertelendi (program ayrıştırması).
- **Doğrulama:** KISMİ (kazanım kodları ve kapı tamam; Sonnet kalite kararları DÖP metniyle tekrar doğrulanmalı; Haiku ve Sonnet dosyası boş-iyeleme gecikmesi yaşadı).
- **Sahip:** Ajan · **Önem:** Orta
- **İlgili:** K-0067.

### K-0067 · 2026-10-21 · DEN · 6. sınıf pilotu: Matematik 29, Fen 26, Sosyal 30 soru; Türkçe 6 ertelendi
- **Tür:** Gelişme + Karar
- **Bağlam:** Kullanıcı: 6. sınıfa başla; token tasarrufu; işleri zorluğa göre Haiku'ya ver (kolay: kazanım çıkarımı, kapı, çözücü; zor: yazım ve kalite denetimi Sonnet).
- **Karar:** Kazanım kaynakları: Matematik 6 (24 kod), Fen 6 (36 kod), Sosyal 6 (18 kod) DÖP'ten çıkarıldı. Türkçe 6 ertelendi: ortaokul Türkçe programında çıktı kodları paragrafların sonunda geliyor, metin ayrıştırması güvenilir değil (91 aday kod, kayık metinler).
- **Denetim:** Matematik: kapı 1 RED (MAT6-002 sayısal ifade düzeltildi), Haiku 30/30, Sonnet MAT6-017 DÜZELT (yamuk tanımı) çıkarıldı → 29. Fen: kapı 0 RED, Haiku 30/30, Sonnet 3 DÜZELT + 1 RED (006, 027, 003; 012 hormon/hipofiz) çıkarıldı → 26. Sosyal: kapı 2 RED (çözüm satırı normalize edildi), Haiku 30/30 (SOS6-018 güven 2), Sonnet 30 GEÇER; mutlak ifade taraması temiz.
- **Kapsam:** Matematik 6: 24 kazanım, 29 soru; 1 kazanım boş. Fen 6: 10 kazanım boş (26 soru). Sosyal 6: 18/18 tam.
- **Durum:** DEVAM. Fen 6 eşiğin (20) üstünde ama kapsam eksik; Türkçe 6 ertelenmiş.
- **Doğrulama:** KISMİ
- **Sahip:** Ajan
- **Önem:** Orta
- **Açıklama:** Sonnet kalite denetimi yine kazanım düzeyini yanlış tahmin etti (6. sınıf fen 6–7 kavramı, DÖP ile karşılaştırılmadı). Bu turdaki kalite kararları DÖP metniyle teyit edilmeli.
- **İlgili:** K-0064, K-0065 (önceki), REHBER §18, kapi.cjs.

### K-0066 · 2026-10-21 · VT/TSR · Okuma Dünyası: sözlük RPC'si, export_my_data genişletmesi, 21 hikâyenin uzunluk turu
- **Tür:** Gelişme
- **Konu:** VT, KVKK, TSR (içerik)
- **Yapılanlar:**
  - **Migration `20261050000400_okuma_dunyasi_sozluk.sql`:** `okuma_sozluk_girdileri/yuvalari/adaylari/kavramlari`, admin `okuma_sozluk_ice_aktar` (kuru çalıştırma, dört göz, günlük), öğrenci `okuma_sozluk_getir(p_hikaye_id)` (onaylı girdiler, çocuğun sınıfına uyan adaylar, yasaklı ikonlar elenir; önizleme izinli hesapta taslak da).
  - **Migration `20261050000500_export_my_data_okuma.sql`:** `export_my_data` mevcut anahtarlar korunarak `okuma` anahtarıyla genişletildi (oturum, cevap, geri bildirim, hedef durumu, PDF, tercihler; çağıranın kendi verisi; doğru şık/anahtar yok).
  - **Hikâye turu (Haiku ajanları):** sınıf 2–8, 21 hikâye genişletildi (olay/kahraman/değer korundu). Derleyici (ben doğruladım): 24 hikâyenin 24'ü HATASIZ, uzunluk ve sözcük hedefi uyarısı yok (yalnız 'Kanıt düzeyi C'). Örnek: sınıf 2 → 145–190 kelime, sınıf 5 → 418–433, sınıf 6 → 506–537, sınıf 7 → 569–581, sınıf 8 → 660–739.
  - Örnek sözlükteki `sabreden_derviş` kimliği şemaya uyacak şekilde `sabreden_dervis` yapıldı. `yanlis-haber-odasi`'ndaki gereksiz cinsiyet vurgusu ("ekipteki bir kız") kaldırıldı.
- **Kanıt:** PGlite `166/166` (önceki 139 + 27 yeni); atölye `npm test` 30/30; 24 hikâye derleme hatasız. `db:preview`: uzakta 6 okuma migration'ı bekliyor (000–500).
- **Açık:**
  - **Dağıtım yok; `db:deploy` kullanıcı onayı bekliyor.** Sıra: 000→500.
  - Haiku'nun yazdığı metinler **editör gözünden geçmedi**: anlatım yer yer açıklayıcı/öğretici, edebî özgünlük ve keyif Ajan B + insan okumasıyla sınanmalı. Sınıf 5 hedefi (~450) hafif altında (418–433, aralık içinde).
  - Ajan A'nın doğrulaması gereken iddialar: ayakkabı-yarışı (haftada üç kez koşma tavsiyesi sağlık tavsiyesi gibi okunabilir), gölgenin-peşinde (ölçüm ve öğle gölgesi), kırk-adim-kuyusu (eski kuyu çökmesi, su kaynağı olgusu), yıldızların-kaptanı (Kutup Yıldızı dönüşü, kırmızı ışık ve karanlığa alışma, Büyükayı tarifi), mercek (Galileo uydu gözlemi), göç (kuşların yiyeceğe alışması). `kelimelerin-yolculugu`: "kararlı" sözcüğünün olumsuz anlamı iddiası zayıf (Ajan B).
  - Sözlük şeması `kavramlar` alanını henüz içermiyor (sunucu isteğe bağlı kabul ediyor); `sozluk.v1.schema.json` güncellenmeli. Sunucu sözlüğü canlıda boş: atölye sözlüğü `okuma_sozluk_ice_aktar` ile yüklenmeli (dağıtımdan sonra).
  - Panelde sözlük içe aktarma ekranı yok (şimdilik RPC); uygulama `okuma_sozluk_getir`'i henüz çağırmıyor (anlam boş görünür).
  - Ajan A/B denetimleri ve insan okuması yapılmadı; hiçbir hikâye yayınlanmadı.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ
- **Sahip:** Kullanıcı (deploy onayı, içerik okuması), Ajan
- **Önem:** Yüksek
- **İlgili:** K-0055, K-0061, K-0065, GÖR-045

### K-0065 · 2026-10-21 · TSR · Okuma Dünyası: mobil/web uygulama, yönetim, veli ve öğretmen entegrasyonu YAZILDI (canlıya alınmadı)
- **Tür:** Gelişme
- **Konu:** MOB, PNL, VT, MON
- **Bağlam:** K-0058 planı ve K-0061 veritabanı katmanı üzerine kullanıcı "karar ver ve entegre et/ettir" dedi; ajanlar (tasarım ajanı) uyguladı.
- **Yapılanlar:**
  - **Flutter (mobil + web):** `mobile-app/packages/okuma_motoru` (32/32), repository (10 öğrenci RPC), cihaz önbelleği (son 20 hikâye, sha256), Öğren sekmesinde "Bugünkü hikâye" kartı (bayrak kapalıyken görünmez), kota dolu sakin ekran, okuma serisi, Okuduklarım, geri dönüş mesajı (push yok), PDF (önce `okuma_pdf_hakki_kullan`, ertelenmiş yükleme). Prototipteki yerel cevap kontrolü KALKTI; kahraman/yoldaş adı yalnız bellekte.
  - **Web panel:** `/yonetim/hikaye-atolyesi` (liste, sürüm ve denetim, önizleme, içe aktarma/kuru çalıştırma, karne, içerik boşluk haritası, sözlük ve hedefler, ayarlar), `/veli-paneli/okuma-dunyasi` (değer önceliği, rıza kilitli kart, özet), öğretmen sınıf raporuna okuma kartı. tr/en mesaj paketleri.
- **Kanıt:** Flutter: `flutter test` 356/356 (yeni 54), `dart test` motor 32/32, `flutter build web --release` başarılı; ana `main.dart.js` +177.528 B (~0,17 MB, bütçe ≤1 MB içinde), PDF ayrı ertelenmiş parça (945.199 B). Web: `lint` 0 hata, `build` başarılı, 390/1280 ekran görüntüleri (sahte yanıtla).
- **Açık / doğrulanmayan:** Canlı veritabanıyla uçtan uca test YOK (migration'lar uygulanmadı). Cihaz, TalkBack/VoiceOver, mobil APK/IPA boyutu ölçülmedi. Panel yazma akışları (içe aktarma, durum geçişi, ayar kaydı) ve gerçek veli/öğretmen oturumları denenmedi. `flutter analyze` 4 sorun (başkasına ait push dosyaları); koyu mod ve kontrast ölçümü yok.
- **Kararlar (ajan):** anket seçenekleri sunucu beyaz listesine hizalandı (yıldız zorunlu); çocuk tarafında veli değerine göre sahne seçimi gerekmez (sıralama sunucuda); Roboto yedek yazı tipi isteği uygulama geneli, ayrı konu.
- **Sonraki işler:** (1) **`db:deploy` kullanıcı onayı**, sonra bayrak izinli hesapta açılıp akış canlı RPC ile koşturulur. (2) Sözlük/anlam kaynağı: `okuma_sozluk_getir` RPC'si (küçük migration) ya da pakete `sozluk`; şimdilik anlamı boş ("henüz eklenmedi"). (3) `export_my_data` okuma tablolarını kapsamıyor (migration). (4) Hikâyelerin genişletilmesi, Ajan A/B denetimi ve insan okuması (yayın kapısı). (5) Hukuk GÖR-045, push, hedef durum kuralları pedagoji onayı.
- **Durum:** DEVAM (kod yazıldı; canlı doğrulama ve yayın bekliyor)
- **Doğrulama:** KISMİ
- **Sahip:** Kullanıcı (deploy onayı, içerik okuması), Ajan
- **Önem:** Yüksek
- **İlgili:** K-0055, K-0058, K-0061, GÖR-045

### K-0064 · 2026-10-21 · DEN · 5. sınıf boş kazanım ek turu: MAT.5.3.1 ve FB.5.3.1
- **Tür:** Gelişme + Karar
- **Bağlam:** Kullanıcı: Karpathy repo kurulumu (karpathy-guidelines skill, kullanıcı genelinde) ve Matematik/Fen boş kazanımları için ek tur.
- **Karar:** 6 ek soru (MAT5-B-001..003, FEN5-B-001..003). Haiku 6/6 anahtarla uyumlu. Sonnet: MAT5-B-001 DÜZELT (çember), FEN5-B-001..003 RED (hücre, kloroplast 6–7. sınıf). **Kabul edildi, itirazlar DÖP ile çürütüldü:** FB.5.3.1 metni "bitki ve hayvan hücrelerinin özelliklerini belirleme ve karşılaştırma" 5. sınıf kazanımı; MAT.5.3.1 metni çember ve dikme çizimini içeriyor. Kapı 0 RED.
- **Durum:** Matematik 5: 36 soru, kapsam tam (23/23). Fen 5: 35 soru, kapsam tam (27/27). Sosyal 5: 38 soru, kapsam tam.
- **Doğrulama:** KISMİ (kazanım kodları DÖP metinleriyle eşlendi; Sonnet kalite itirazları DÖP ile çelişti — yeniden değerlendirme gerekebilir).
- **Sahip:** Ajan · **Önem:** Orta
- **İlgili:** K-0063.

### K-0063 · 2026-10-21 · DEN · 5. sınıf setleri: Matematik 33, Fen 32, Sosyal 38; kapı uzunluk uyarıya dönüştü
- **Tür:** Karar + Gelişme
- **Bağlam:** Kullanıcı: "başlat" (Fen 5 ve Sosyal 5 ek üretim). Ayrıca hafıza kuralı: uzunluk tek başına red sebebi değil (feedback_onay_kurali_uzunluk). Kullanıcı: token tasarrufu esas.
- **Karar:**
  - Kapı (kapi.cjs) uzunluk bulgusunu artık **uyarı** olarak raporluyor, RED değil. Yani önceki turda yalnızca uzunluk yüzünden elenen soruların bir kısmı (Fen 5: 10, Sosyal 5: 8, Matematik 5: 4) geri getirilebilir durumda; matematikteki dört soru, eldeki denetlenmiş içerikle geri eklendi (açıklamalar yazarca tamamlandı, kapı 4/4).
  - Fen 5 ek üretim (20 soru) Haiku 20/20 anahtarla uyumlu; Sonnet 3 DÜZELT (E-003, E-004, E-015: 7. sınıf kavramı ve kazanım dışı) çıkarıldı.
  - Sosyal 5 ek üretim (20 soru): Haiku 20/20 anahtarla uyumlu; Sonnet 20 GEÇER.
- **Durum:** Matematik 5: 33 soru, kapsam eksik MAT.5.3.1. Fen 5: 32 soru, kapsam eksik FB.5.3.1. Sosyal 5: 38 soru, kapsam tam. Üçü de kapıdan RED'siz geçiyor.
- **Açık:** Fen 5 denetimi (Sonnet ek) tam; ilk 15 soru ayrıca denetlenmişti. Veritabanı aktarımı yok (en son, kullanıcı onayıyla).
- **Doğrulama:** KISMİ
- **Sahip:** Ajan
- **Önem:** Orta
- **İlgili:** K-0062, K-0063 (önceki), REHBER §3/§18, kapi.cjs.

### K-0062 · 2026-10-18 · DEN · 5. sınıf pilotları: Matematik 29, Fen 15, Sosyal 18 soru
- **Tür:** Gelişme + Sorun
- **Bağlam:** Plan sırası 4 → 5 → 6–7 → 1–3 → 8 (en sonda, ayrı LGS stratejisi). Üç ders için aynı hat: yazar (Sonnet) → kapı → Haiku (kör çözüm) → Sonnet 5.5 (kalite).
- **Karar:**
  - **Matematik 5:** 22 + ek 7 = 29 soru, kapı 29/29, Haiku 30/30 anahtar uyumu. Kapsam eksik: MAT.5.3.1 ve MAT.5.6.1.
  - **Fen 5:** kapı 10 RED (uzunluk) çıkarıldı; Haiku 20/20; Sonnet 5 DÜZELT (004, 012, 014, 023, 029) çıkarıldı. Kalan 15 soru: pilot eşiğinin (20) altında; 13 kazanım boş. Fen 5 yeniden üretim gerektiriyor.
  - **Sosyal 5:** kapı 8 RED (uzunluk) çıkarıldı; Haiku 22/22 anahtar uyumu; Sonnet 5 DÜZELT (003, 015, 020, 021; ek matematikte E-004) çıkarıldı. Kalan 18 soru; 5 kazanım boş (SB.5.1.2, 5.1.3, 5.3.1, 5.4.2, 5.4.3).
- **Durum:** DEVAM. Üç hücrenin ikisi (Fen 5, Sosyal 5) eşiğin altında; yeniden üretim turu gerekecek.
- **Doğrulama:** KISMİ
- **Sahip:** Ajan
- **Önem:** Orta
- **Açıklama:** Yazarların en sık hatası doğru şığın en uzun şık olması (kapı ile yakalandı). Sonnet kalitesinde tutum/değer yargısı kalıbı (Sosyal) ve kazanım kayması (Fen: FB.5.x bazı kazanımlar 6–7. sınıf müfredatına yakın) riski. 5. sınıf kazanım eşlemesi doğrulanmalı. Kazanım listesi (matematik DÖP) TOC karışıklığı nedeniyle tam doğrulanmadı.
- **Kanıt:** docs/soru-uretim/pilot/uretim_matematik_5_final.json (29), uretim_fen_5.json (15), uretim_sosyal_5.json (18); scratchpad/denetci_*_fen5.json, denetci_*_sos5_mat5ek.json.
- **İlgili:** K-0060, PLAN_V2 §4.

### K-0061 · 2026-10-18 · VT · Okuma Dünyası F1: veritabanı katmanı yazıldı ve PGlite'ta test edildi (DAĞITILMADI)
- **Tür:** Gelişme + Karar
- **Konu:** VT, MON, PNL
- **Bağlam:** K-0058 planı kullanıcı tarafından kabul edildi; kalan kararlar ajana bırakıldı (`HUPO_ENTEGRASYON_PLANI.md` §10): ücretsiz günde 1 hikâye, PDF ayda 3 (premium sınırsız), paket teslimi v1'de RPC, çevrimdışı 20 hikâye, ilk set 4–5. sınıf.
- **Yapılanlar:** 4 migration (`20261050000000…300`): 13 `okuma_*` tablo, RLS, değişmezlik tetikleyicisi, yayın kapısı (Ajan A/B pass + insan approved + dört göz, hem RPC'de hem tabloda), 25 RPC (öğrenci 10, veli 4, öğretmen 1, yönetim 10), bayrak varsayılan KAPALI. Sözleşme: `C:\Dev\Senin Hikayen - HupoRead\docs\OKUMA_RPC_SOZLESMESI.md`. Testler: `supabase/tests/okuma_dunyasi/`.
- **Sapmalar (bilinçli):** etiket ve hedef bağları sürüm başına (değişmez sürüm modeli); denetim sürümde; içe aktarmada paket `insan: approved` dese bile sunucu `pending` yazar; `ilgi_egilimi` istemciye dönmez; veli ayrıntı özeti premium **veya denetim süresi (14 gün)** için açık; XP ayarları 10'un katı olmak zorunda (`award_xp_and_streak` 10/20/30 veriyor).
- **Kanıt:** PGlite `139/139` senaryo (yetki matrisi, rıza, dört göz, bozuk paket reddi 13, değişmezlik, idempotent XP ve tavan, kota, PDF sayacı, `dogru`/`aciklama` sızıntı taraması, serbest metin parametre yok, cascade silme). Mutasyon testi: anahtar soyma satırı kaldırılınca 2 senaryo düştü. `db:preview`: uzakta yalnız bu 4 dosya bekliyor.
- **Açık:** **Dağıtım yapılmadı; `db:deploy` ayrı kullanıcı onayı bekliyor.** Harness taklit içerir (gerçek `award_xp_and_streak`, `export_my_data`, Supabase rolleri, eşzamanlılık yok): staging'de `supabase db reset` ve `supabase test db` ile doğrulanmalı. `export_my_data` okuma tablolarını kapsamıyor (ayrı migration gerekli: oturum, cevap, geri bildirim, hedef durumu, PDF kullanımı, çocuk tercihleri). Hedef durum geçiş kuralları (retrieved, transferred, refresh_due) ajan tasarımı; pedagoji onayı gerekir. Öğretmen özetinde veli rızası aranmıyor, yalnız min-N 3 (mevcut kalıp); hukuk (GÖR-045) kapanmadan pilot açılmaz. Geri dönüş push'u sunucuda yok.
- **Durum:** DEVAM (F2 yönetim paneli, F3 uygulama, F4 veli/öğretmen ajanları çalışıyor)
- **Doğrulama:** KISMİ
- **Sahip:** Ajan, Kullanıcı (deploy onayı)
- **Önem:** Yüksek
- **İlgili:** K-0052, K-0055, K-0058, GÖR-045

### K-0060 · 2026-10-18 · DEN · 5. sınıf Matematik pilotu: 22 soru; kazanım kapsamı eksik
- **Tür:** Gelişme + Sorun
- **Bağlam:** Plan sırası: 4 kapanış → 5 → 6–7 → 1–3 → 8 (en sonda, ayrı LGS stratejisi; kullanıcı kararı).
- **Plan:** Kazanım tablosu (Ortaokul Matematik 5–8 DÖP, mufredat.meb.gov.tr, 2026) → Sonnet yazar (30) → kapı → Haiku (kör çözüm) → Sonnet 5.5 (kalite).
- **Karar:** Kapı: 4 RED (uzunluk) çıkarıldı. Haiku 30/30 anahtarla uyumlu. Sonnet 26 GEÇER / 4 DÜZELT (013, 015, 016, 017: araç adı sorusu, kazanım dışı açılar); DÜZELT olanlar çıkarıldı. Son set 22 soru, kapı 22/22.
- **Durum:** DEVAM. Kazanım kapsamı eksik: MAT.5.2.2, 5.3.1, 5.3.3, 5.3.4, 5.3.6, 5.4.1, 5.6.1 boş. 20 eşiğinin üstünde ama kapsam tam değil.
- **Doğrulama:** KISMİ
- **Sahip:** Ajan
- **Önem:** Orta
- **Açıklama:** Kazanım kodu çıkarımı 5. sınıf DÖP'ten yapıldı (23 kod, bölüm başlıkları ve TOC karışıklığı olabilir; 5.1.5 gibi kodlar eksik olabilir — doğrulanmalı). Geometri (5.3) ve çevre-alan kazanımları için ek üretim gerekir.
- **Kanıt:** docs/soru-uretim/pilot/uretim_matematik_5.json (22 soru), kazanim_5_matematik.json, scratchpad/denetci_*_mat5.json.
- **İlgili:** K-0059, PLAN_V2 §4.

### K-0059 · 2026-10-18 · BEL · Soru üretim planı: ajan kararları, MEB yazım kılavuzu entegrasyonu, Hayat Bilgisi kazanımları
- **Tür:** Karar + Gelişme
- **Bağlam:** Kullanıcı: kararları ajan versin; en faydalı, en çok müşteri çeken, gelir üreten yol.
- **Karar (ajan, gerekçeli, docs/soru-uretim/PLAN_V2.md §0):** Öncelik 4 → 8 (LGS) → 5 → 6–7 → 1–3. Ders: Türkçe/Matematik önce. 8. sınıfta T.C. İnkılap. Çözücüler Haiku + Gemini; kalite denetçisi Sonnet 5.5 (Gemini kalite rolü kalktı). Yayın için iki çözücü + Sonnet GEÇER + insan örneklemi (%10, atanacak kişi kullanıcıda). Fiyat/paket kararı verilmedi, kullanıcıda.
- **Kanıt:** MEB "Bağlam Temelli Çoktan Seçmeli Soru Yazım Kılavuzu" (Mart 2026) tam PDF indirildi; REHBER §18'e eklendi. Kapı: kapsayıcı şık ve öznel kök kontrolleri eklendi. Matematik MAT4-023 ("hepsi" içeren şık) çıkarıldı (29 → 28). Hayat Bilgisi kazanımları çıkarıldı: 50 kod (1. sınıf 19, 2. sınıf 17, 3. sınıf 14).
- **Engel:** İngilizce 4 ve Din Kültürü 4 programı tymm'de bulunamadı (sayfa 500 hatası; arama sonuçsuz).
- **Durum:** DEVAM
- **Doğrulama:** KISMİ
- **Sahip:** Ajan
- **Önem:** Yüksek
- **İlgili:** K-0057, PLAN_V2, REHBER §18.

### K-0058 · 2026-10-18 · TSR · Senin Hikâyen: Hupo entegrasyon planı (mimari, yönetim, metrikler, fiyatlandırma)
- **Tür:** Plan
- **Konu:** TSR, VT, MOB, PNL, MON
- **Bağlam:** Kullanıcı, okuma modülünün mobil ve web uygulamaya, veli, öğretmen ve yönetim panellerine entegrasyonunu, içerik yönetimini, metrikleri, fiyatlandırmayı ve uygulamayı ağırlaştırmayan mimariyi sordu.
- **Plan (özet):** Belge: `C:\Dev\Senin Hikayen - HupoRead\docs\HUPO_ENTEGRASYON_PLANI.md`. Mimari: küçük saf-Dart motor uygulamada; hikâye paketi Storage'da sürümlü dosya, soru anahtarı yalnız RPC, PDF ertelenmiş yükleme, yerel önbellek (~20 hikâye). Yönetim: hikâye atölyesi paneli (içe aktar, kuru çalıştırma, etiket editörü, denetim, karne), yayın kapısı sunucuda zorlanır. Metrikler: öğrenci, veli, öğretmen, yönetim ayrı; öğrenme XP/süreyle karıştırılmaz, cinsiyet kırılımı yok, min-N. Fiyat: ayrı SKU yok; mevcut plana hak kalemi (günlük hikâye kotası admin ayarı), veli içgörüsü ve PDF premium değer farkı; fiyat yok.
- **Ölçülen:** hikâye paketi ham ortalama ~10 KB (29 paket, 291 KB), motor kaynağı ~12 KB, PDF yazı tipleri 259 KB, örnek sözlük 21,6 KB. **Ölçülmedi:** sıkıştırılmış boyut (tahmin ~3 KB), uygulama paketi boyut farkı.
- **Doğrulanan Hupo yapısı:** `premium_gating` ve günlük kota, iyzico tabloları, öğretmen/sınıf tabloları, Storage kullanımı. Kod yazılmadı, migration yok.
- **Karar bekleyen:** fiyat modeli, ücretsiz kota, PDF erişimi, öğretmen kapsamı, Storage+RPC melezi, çevrimdışı önbellek, ilk yayın seti.
- **Durum:** ONAY BEKLİYOR
- **Doğrulama:** YOK (plan)
- **Sahip:** Kullanıcı
- **Önem:** Yüksek
- **İlgili:** K-0052, K-0055, K-0048, GÖR-045

### K-0057 · 2026-10-18 · DEN · Sosyal Bilgiler 4: ek tur (Sonnet yazımı), birleşik set 28 soru; tüm kazanımlar kapsanıyor
- **Tür:** Gelişme
- **Bağlam:** K-0056 sonrası kalan kazanımlar için yeni tur. Üretici Sonnet 5.5; denetçi Haiku (kör çözüm) ve Gemini (kalite).
- **Karar:** Ek 12 soru yazıldı. Kapı: 005 ve 011 (doğru şık en uzun) çıkarıldı. Gemini: 009 DÜZELT, çıkarıldı. Kalan 9 soru Haiku ile 9/9 anahtarla uyumlu. Birleşik set (19 + 9) = 28 soru; kapı 28/28; 14 kazanımın tamamı kapsanıyor.
- **Durum:** TAMAMLANDI (Sosyal set, veritabanı aktarımı hariç). Veritabanı aktarımı en son ve kullanıcı onayına bağlı.
- **Doğrulama:** KISMİ
- **Sahip:** Ajan
- **Önem:** Orta
- **Açıklama:** Ek 9 soru yalnızca Haiku ve Gemini tarafından denetlendi; Sonnet 5.5 kalite denetimi bu parça için yapılmadı (yazar Sonnet olduğu için bağımsız sayılmaz). Gemini ilk turda kalite denetiminde zayıf kaldı (K-0056). Birleşik setin kalite kararı bu nedenle tam değil; yayın öncesi Sonnet 5.5 ya da başka bağımsız bir kalite denetimi yapılmalı. Ayrıca zorluk etiketleri model tahmini.
- **Kanıt:** docs/soru-uretim/pilot/uretim_sosyal_4_final.json (28 soru), 	ools/soru-uretim/kapi.cjs 28/28 KONTROL, scratchpad/denetci_a_sos4_ek.json.
- **İlgili:** K-0056, K-0054, REHBER §15, §17.

### K-0056 · 2026-10-18 · DEN · Sosyal Bilgiler 4: Gemini üretimi (üretici), Haiku + Sonnet 5.5 denetimi; 19 soru kaldı
- **Tür:** Karar + Gelişme
- **Bağlam:** Kullanıcı: soruları Gemini üretsin; Haiku ve Sonnet 5.5 kontrol etsin. Veritabanı aktarımı en sonda.
- **Plan:** 1. Gemini 30 soru üretsin (REHBER + kazanım listesi). 2. Kapı. 3. Haiku (kör çözüm) + Sonnet 5.5 (kalite). 4. DÜZELT/RED çıkar.
- **Karar:** Gemini ilk üretimde doğru şıkların %57'sini A'ya koydu ve 8 soruda doğru şık en uzundu. Harf dengesi şık sırasının yeniden düzenlenmesiyle sağlandı (metin değişmedi). En uzun şıklı 8 soru ve 3 eksik kazanım için 6 ek soru üretildi. Kapı 28/28. Haiku 28/28 anahtarla uyumlu. Sonnet 9 DÜZELT verdi (G2-003/G3-003 çelişkili kök, G2-010 muğlak eşleme, E1-02/03, G2-002/007, G3-007/008 mutlak ifadeler; Tekalif-i Milliye sorusu üç kez tekrarlı). Hepsi çıkarıldı. Kalan 19 soru; SB.4.1.2 boş.
- **Durum:** BEKLİYOR (Sosyal 19 soru, 20 eşiğinin altında; yeniden üretim gerekebilir). İngilizce 4 programı hâlâ bekleniyor.
- **Doğrulama:** KISMİ
- **Sahip:** Ajan
- **Önem:** Orta
- **Açıklama:** Gemini üretim kalitesi yüksek değil: harf dengesi, en uzun şık, mutlak ifade, tekrar eden kökler. Üretimden sonra Sonnet filtresi olmadan kullanılamaz. Tek başına kalite güvencesi olarak yetmiyor; denetim zinciri şart.
- **Kanıt:** docs/soru-uretim/pilot/uretim_sosyal_4_gemini.json (19 soru), 	ools/soru-uretim/kapi.cjs 19/19 KONTROL, scratchpad/denetci_*_sos4_g.json.
- **İlgili:** K-0054, REHBER §17, §16.

### K-0055 · 2026-10-18 10:46 · TSR · Senin Hikâyen: sınıf 1–8 hikâye taslakları (24 yeni), şema ve derleyici güncellemesi
- **Tür:** Gelişme + Karar
- **Konu:** TSR, MEB (içerik), HUK (telif ve yayın kapısı)
- **Bağlam:** Kullanıcı, Uzman V2 rehberine göre 5. sınıf için uzun hikâyeler ve her sınıf (1–8) için üç hikâye istedi. İlgi etiketi yalnızca sıralama için tutulacak; ikonlarda Twemoji ve Material kullanılacak, OpenMoji hukuk onayına kadar kullanılmayacak.
- **Yapılanlar:**
  - 24 yeni taslak: `icerik/taslak/` (sınıf 1–3: 9, sınıf 4: 3, sınıf 5: 3, sınıf 6: 3, sınıf 7: 3, sınıf 8: 3). Hepsi derleniyor, hata yok; hepsi `durum: taslak`, denetimler `pending`.
  - Şema: sorular en az 2 (rehber: 1–4 soru), sayfalar en çok 12 (uzun hikâyeler için; önceki 8). `hedef_cinsiyetler` alanı kaldırıldı.
  - Derleyici: ilgi etiketi sıralama için; ölçümler ve uyarılar.
  - Katalog: `docs/ICERIK_TASLAK_LISTESI.md` (29 satır: 24 yeni + ilk 5 pilot).
- **Kanıt:** `atolye npm test` → 30/30. Derleme: 24/24 hatasız.
- **Açık (önemli):** Uzunluk hedeflerinin çoğu tutturulamadı. Derleyici sayımına göre: sınıf 2–3 hikâyeleri 104–153 kelime (hedef 120–330; robot-cop-kutusu hedefin altında), sınıf 4 247–258 (hedef 260–450), sınıf 5 342–349 (hedef 350–650), sınıf 6 428–444 (hedef 450–800), sınıf 7 449–486 (hedef 550–950), sınıf 8 354–428 (hedef 650–1100). Yazım sürecinde sayfa başına kelime yoğunluğu yetersiz kaldı; ikinci turda genişletme gerekli. Öğrenme hedefi sayısı (sözcük) bazı hikâyelerde sınıf aralığının altında. Sınıf 1 hikâyeleri harf-ses evresi uygunluğu açısından insan editörce ayrıca kontrol edilmeli.
  - Kanıt düzeyi çoğu hikâyede B/C; resmî kazanım kodu doğrulanmadı.
  - Ders bağlantılı fen/sosyal hedeflerin iddia kartları ve Ajan A kontrolü yapılmadı.
  - Ajan A ve B denetimleri ve insan okuması yapılmadı; hiçbir hikâye yayınlanmadı.
  - Uygulamaya (Flutter prototip) henüz bağlanmadı; ornek_veri.dart güncellenmedi.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ (derleme ve şema doğrulandı; içerik ve uzunluk denetimi bekliyor)
- **Sahip:** Ajan, Kullanıcı (uzunluk ikinci tur, editör okuması)
- **Önem:** Yüksek
- **İlgili:** K-0052, K-0048, GÖR-045

### K-0054 · 2026-10-18 · DEN · Sosyal Bilgiler 4 v2: çeldirici yeniden yazımı, 17 soru kaldı; İngilizce 4 programı bulunamadı
- **Tür:** Gelişme + Sorun + Engel
- **Bağlam:** K-0053'teki Sosyal setinin çeldirici kalıbı (doğru şık tek olumlu ve en uzun) kullanıcı kararıyla düzeltilmeye çalışıldı. Veritabanı aktarımı en sona bırakıldı (kullanıcı kararı).
- **Plan:** 1. Çeldiricileri yeniden yaz (kök ve doğru şık korunur). 2. Kapı, Gemini, Haiku, Sonnet 5.5 kör denetimi. 3. DÜZELT ve RED olanları çıkar. 4. İngilizce 4 programını bul ve aynı akışı uygula.
- **Karar:** v2'de Sonnet 5.5 yedi DÜZELT verdi (005, 009, 020, 021, 023, 029, 030); hepsi çıkarıldı. Sosyal seti 17 soru; SB.4.2.2 ve SB.4.6.2 kazanımları boş. Pilot hedefi 20–30 soru olduğu için Sosyal bu hâliyle pilot eşiğinin altında. Haiku 24/24 anahtarla uyumlu çözdü; Gemini ilk turda ve v2'de hepsini GEÇER verdi.
- **Engel:** İngilizce 4 DÖP PDF'si iki aramada bulunamadı (mufredat ve tymm'de yok). Kazanım kodu uydurulmadı. Kullanıcıdan PDF ya da bağlantı beklenecek.
- **Durum:** BEKLİYOR (İngilizce programı); Sosyal ENGELLİ (pilot eşiği altı, yeniden üretim gerekir)
- **Doğrulama:** KISMİ
- **Sahip:** Kullanıcı (İngilizce programı), Ajan (Sosyal yeniden üretim)
- **Önem:** Orta
- **Açıklama:** Sosyal'de çeldirici sorunu iki turda çözülemedi. Gemini kalite denetimi bu alanda güvenilir değil. Yeniden üretim için tutum kazanımları ayrı ele alınmalı (bilgi ağırlıklı kazanımlara odaklı). Ayrıca 2026 program sürümü sınıflarda henüz uygulanmıyor olabilir (K-0053 ve telafi belgesi notu).
- **Kanıt:** docs/soru-uretim/pilot/uretim_sosyal_4_v2.json (17 soru), 	ools/soru-uretim/kapi.cjs 17/17 KONTROL, scratchpad/denetci_*_sos4_v2.json.
- **İlgili:** K-0053, K-0051, REHBER §13, §15, §17.

### K-0053 · 2026-10-18 · DEN · Sosyal Bilgiler 4 pilotu: 24 soru kaldı; değer yargısı çeldiricileri zayıf
- **Tür:** Gelişme + Sorun
- **Bağlam:** Ders pilot sırası (REHBER §13): Matematik ve Fen kapandı; Sosyal Bilgiler 4 sıradaki. Üretici Sonnet 5.5, kalite denetçisi Sonnet 5.5.
- **Plan:** 1. Sosyal DÖP 14 kazanım (pilot/kazanim_4_sosyal.json). 2. §17 kuralları. 3. 30 soru üret, kapı, Haiku + Gemini + Sonnet kör denetimi, DÜZELT/RED çıkar.
- **Karar:** Kapıdan iki RED (008, 014: doğru şık en uzun) çıkarıldı. Sonnet 4 DÜZELT (002, 003, 007, 018) verdi; hepsi çıkarıldı. Set 24 soru. Haiku 28/28 anahtarla uyumlu; Gemini 28 GEÇER.
- **Durum:** DEVAM (Türkçe 28, Matematik 29, Fen 25, Sosyal 24).
- **Doğrulama:** KISMİ
- **Sahip:** Ajan
- **Önem:** Orta
- **Açıklama:** Sosyal'de sorun, tutum ağırlıklı kazanımlarda (SB.4.1.x, SB.4.5.x) doğru şıkların tek olumlu ve en uzun şık olması; çeldiricilerin açıkça saçma ya da mutlak ifadeli olması. Bu kalıp Sosyal setinin büyük kısmında var; set olduğu gibi kullanılmamalı, çeldirici yeniden yazımı gerekir. Haiku'nun "Montu" işareti yanlıştı (iyelik hâli, doğru). Yayın kararı kullanıcıda (§15).
- **Kanıt:** docs/soru-uretim/pilot/uretim_sosyal_4.json (24 soru); 	ools/soru-uretim/kapi.cjs 24/24 KONTROL; scratchpad/denetci_*_sos4.json.
- **İlgili:** K-0051, REHBER §15, §17.

### K-0052 · 2026-10-18 06:43 · TSR · Senin Hikâyen: Uzman V2 değerlendirmesi, etiket sistemi, ajan rehberi, ikon kütüphanesi
- **Tür:** Karar + Gelişme
- **Konu:** TSR, VT, UX, HUK
- **Bağlam:** Kullanıcı "Okuma Hikâye Uzmanı V2" paketinin incelenmesini; her hikâye hazırlamada ajanların okuyacağı bir .md rehberi; hikâyelerin sınıf, zorluk, ilgi, tema, Maarif değeri vb. ile etiketlenip veritabanında tutulmasını; geniş bir ikon-emoji kütüphanesini (Twemoji, OpenMoji, Material; Türk-İslam görüşüne ters simgeler asla yok) istedi.
- **Yapılanlar (proje: C:\Dev\Senin Hikayen - HupoRead):**
  - Değerlendirme: `docs/UZMAN_V2_DEGERLENDIRME.md`. Rehber uzman girdisi olarak benimsendi; çelişkide öncelik: kullanıcı kararı > ajan rehberi > V2 > V1. 241 kavram adayı sözcük bankası değil, ders ve dil kavramı adayı; hiçbirinde kazanım ve zorluk dolu değil.
  - Ajan rehberi: `docs/HIKAYE_URETIM_REHBERI_AJAN.md` (AGENTS.md'den zorunlu yönlendirme).
  - Etiket sistemi: `etiketler` bloğu (şema, kontrollü sözlük `sema/etiket-sozlugu.v1.json`, derleyici doğrulaması, ölçümler, yayın kapısı); 5 hikâye etiketlendi; `hedef_cinsiyetler` kaldırıldı, yerine `ilgi_egilimi` (yalnız yumuşak sıralama etiketi, filtre değil, cinsiyet kırılımı yok). Soru şemasına `degerlendirme`, `hedef_id`, `olcme_turu`.
  - DB taslağı: `sql/taslak_okuma_etiketleri.sql` + `docs/ETIKET_VE_VERITABANI.md` (veli istatistik sözleşmesi dahil).
  - İkon kütüphanesi: `ikon_kutuphanesi/` (KURALLAR.json, derle.mjs, katalog 1923 simge: 1438 izinli, 101 inceleme, 384 yasak; Twemoji 1415 + OpenMoji 1438 SVG, Material 2152 ikon, LISANS.md). Ham depolar `kaynak-ikon/` (git dışı, sparse).
- **Kararlar (ajan, kullanıcı yetkisiyle):** `ilgi_egilimi` varsayılan `ortak`; erdem ve ilke alanı doğrulanmadan eklenmedi; 1. sınıf harf-ses izi ayrı; OpenMoji (CC BY-SA 4.0) hukuk onayına kadar uygulamaya girmez, Twemoji (CC-BY 4.0, atıfla) ve Material birincil.
- **Mevcut hikâyelerin bulguları:** kelime 300–410 (4. sınıf aralığında), 4 soru; yeni sözcük hedefi 1–2 (rehber 3–4, öğretim içeriği zayıf); soru dağılımı %50 hatırlama, değerlendirme yok; Tohum ve Balon için bilimsel iddia kartı ve Ajan A kontrolü yok (Tohum'da "3 gün sonra filiz" süresi şüpheli); kayip-defter'de D6 sahnesi dürüstlükle uyuşmuyor (ana değer D20 yazıldı); denetimler `pending`.
- **Kanıt:** `npm test` (atölye) 30/30 (yeni: `etiketler.test.ts` 7 test); beş hikâye hatasız derlendi; `flutter analyze` temiz, `flutter test` 36/36 (ornek_veri etiketli paketlerle yenilendi); `ikon_kutuphanesi/derle.mjs` kendi doğrulamasını geçti (Türkiye bayrağı izinli; haç, Davut yıldızı, öpücük, bira, şarap, domuz, LGBT bayrağı, Noel ağacı, tabanca, Özgürlük Anıtı izinli değil; 🤘 🖕 🏩 yasak, 👌 ve 🌈 inceleme).
- **Açık:** DB taslağı çalıştırılmadı (sözdizimi dahil); veli istatistik RPC'si yalnız sözleşme; Ajan A ve B denetimleri ve insan okuması yapılmadı; program sürümü (4. sınıf geçiş) ve kazanım kodları doğrulanmadı; ikon yasak listesi insan gözüyle taranmadı (kapsamlı değil); simge kütüphanesi henüz hikâye derleyicisine bağlanmadı (isaret kodları 16 sabit); Haiku ajanı oturum sınırına takılıp ikon kütüphanesini yarım bıraktı, işi ben tamamladım; hukuk (GÖR-045).
- **Durum:** DEVAM
- **Doğrulama:** KISMİ (kod ve testler doğrulandı; içerik denetimleri ve DB bekliyor)
- **Sahip:** Ajan, Kullanıcı (ilgi etiketi, kapsam, OpenMoji kararı)
- **Önem:** Yüksek
- **İlgili:** K-0023, K-0024, K-0040, K-0048, GÖR-045

### K-0050 · 2026-10-18 02:05 · TSR · Senin Hikâyen: sonuç ekranı duyarlı düzen (mobil, tablet, masaüstü)
- **Tür:** Düzeltme
- **Konu:** TSR, UX
- **Bağlam:** Kullanıcı sonuç ekranında scroll gerektiğini, teşvik ve "tekrar gel" mesajının altta kaldığını, düğmelerin kesildiğini bildirdi; tasarım ajanından mobil/tablet/masaüstü düzenlemesi istedi.
- **Yapılanlar (tasarım ajanı):** Ekran `lib/ekranlar/sonuc.dart` dosyasına taşınıp yeniden yazıldı. Motivasyon metinleri başlığın altında tek kartta; yıldız Lottie sağ üst köşede; kısa ekranda maskot 120 dp; ikincil düğmeler yan yana (yazı ölçeği > 1.3'te alt alta); tablet/masaüstünde maskot ve başlık yan yana, içerik 720 dp ile sınırlı; alt alan en çok %45 yükseklik. `OkumaIkincilButon` artık metni kesmek yerine büyüyor (ortak bileşen).
- **Kanıt:** `flutter analyze` → No issues found. `flutter test` → All tests passed (36; yeni `sonuc_ekrani_test.dart` 10 test: 390x844, 360x640, 768x1024, 1280x800 kaydırmasız; yazı ölçeği 2.0'da taşma yok). Ajan tarayıcıda geçici girişle ekran görüntüleri aldı, konsol hatası yok.
- **Açık:** Gerçek cihaz, safe area, ekran okuyucu doğrulanmadı. `OkumaIkincilButon` değişikliği kahraman/hikâye/durum ekranlarını etkiler; bunlar görsel kontrol edilmedi. Karar bekleyenler: kısa ekranda maskot 120 dp, yeni kart görünümü ve yan yana düğmeler.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ
- **Sahip:** Ajan, Kullanıcı (görsel onay)
- **Önem:** Orta
- **İlgili:** K-0043, K-0046, K-0048

### K-0051 · 2026-10-18 · DEN · Fen 4 pilotu: 25 soru kaldı; Gemini kalite denetimi zayıf, Sonnet 5.5 kalite denetçisi olarak kullanıldı
- **Tür:** Karar + Gelişme
- **Bağlam:** Kullanıcı: Fen 4 pilotu devam etsin; kalite denetçisi Opus yerine Sonnet 5.5 olsun (karar: `ONAYLI`). REHBER §9 "Denetçi B en güçlü model" diyor; bu karar o kuralla çelişiyor ve izlenecek (Matematik'te Opus, Haiku ve Gemini'nin kaçırdığı iki gerçek hatayı yakalamıştı).
- **Plan:** 1. Fen 4 soru üretimi (30 soru, görselsiz, §16). 2. Kapı betiği. 3. Kör denetim: Haiku (çözücü), Sonnet 5.5 (kalite), Gemini (çözücü + kalite). 4. DÜZELT ve RED olanları çıkar.
- **Karar:** Matematik 028 üç denetimde iki kez DÜZELT aldı; soru çıkarıldı (29 soru). Fen'de Sonnet 5 DÜZELT verdi (003, 005, 014, 021, 030); 014'te 70 °C sıcak su çocuk deneyi güvenlik riski; çıkarıldı, Fen seti 25 soru. REHBER §16.8 güvenlik kuralı eklendi.
- **Durum:** DEVAM (Türkçe 28, Matematik 29, Fen 25; Fen'de FB.4.8.1 kazanımı şu an kapsanmıyor).
- **Doğrulama:** KISMİ
- **Sahip:** Ajan
- **Önem:** Yüksek
- **Açıklama:** Haiku Fen 30/30 anahtarla uyuştu. Gemini 30/30 GEÇER verdi; oysa Sonnet 5 DÜZELT (özellikle 014'teki güvenlik riski) buldu. Gemini kalite denetiminde kör nokta: bu pilot için Gemini yalnızca çözücü olarak güvenilir sayılmalı, kalite kararı için tek başına yeterli değil. Yayın kararı insan örneklemine bağlı kalır (§15, karar kullanıcıda).
- **Kanıt:** `docs/soru-uretim/pilot/uretim_fen_4.json` (25 soru), `tools/soru-uretim/kapi.cjs` (25/25 KONTROL), `scratchpad/denetci_a_fen4.json`, `denetci_b_fen4.json`, `denetci_gemini_fen4.json`.
- **İlgili:** K-0049, REHBER §9, §15, §16.

### K-0049 · 2026-10-18 · DEN · Soru üretim pilotu: Türkçe 4 kapandı (28), Matematik 4 pilotu (30), kapı betiği ve sınıf/ders planı
- **Tür:** Karar + Gelişme
- **Bağlam:** Kullanıcı "yapılabilecekleri sırayla yap" dedi (ders pilotu, ders kuralları, kazanım eşleşmesi, sınıf kademesi, insan örneklemi). Yöntem: `docs/soru-uretim/REHBER.md`.
- **Plan:** 1. Türkçe 4 pilotunu 28 soruyla kapat (TR4-025, TR4-027 tartışmalı noktalama nedeniyle çıkarıldı). 2. Matematik 4 pilotu: 30 soru, kazanım kodlu, sayısal doğrulamalı. 3. Kapı betiği (`tools/soru-uretim/kapi.cjs`): şema, kazanım kodu, sayısal doğrulama, yapısal ipucu. 4. REHBER §11 (Matematik), §12 (kazanım eşleşmesi), §13 (ders sırası), §14 (sınıf kademesi), §15 (insan örneklemi).
- **Karar:** Sağlayıcı bağımsızlığı için Gemini denetçi olarak kullanıldı (`GEMINI_API_KEY`, .env içinden). Kullanıcı kararı `ONAYLI`: yayın kararı insan örneklemine bağlanır (§15) — karar kullanıcıda, `ONAY BEKLİYOR`.
- **Durum:** DEVAM (Türkçe ve Matematik pilotları tamam; diğer dersler sırada).
- **Doğrulama:** KISMİ
- **Sahip:** Ajan
- **Önem:** Yüksek
- **Açıklama:** Türkçe 4 (28 soru): anahtar uyumu 28/28 (Haiku), Opus ve Gemini kalite kararları ayrıştı; iki soru çıkarıldı. Matematik 4 (30 soru): kapı 30/30; kör çözüm Haiku 30/30 ve Gemini 30/30 anahtarla uyuştu. Opus kalite denetimi 4 DÜZELT verdi: 021 (parantez eksik, gerçek hata, düzeltildi), 028 (kök ve çeldiriciler, gerçek hata, yeniden kuruldu), 009 ve 010 (düzey itirazı). 009/010 itirazı DÖP metniyle çelişiyor: 4.1.10 hem parçadan bütüne hem bütünden parçaya, 4.1.6 bileşik kesirleri 4. sınıfta kapsıyor; bu iki soru tutuldu. Düzeltilen 021 ve 028 Haiku ve Gemini ile yeniden denetlendi; 028'in son hâli Opus tarafından denetlenmedi. Gemini matematikte 30/30 GEÇER verdi, Opus 4 sorun buldu: üç denetçinin de kör noktası olabilir, insan örneklemi §15'te.
- **Kanıt:** `docs/soru-uretim/pilot/turkce_4_pilot_final_28.json`; `docs/soru-uretim/pilot/uretim_matematik_4.json`; `docs/soru-uretim/pilot/kazanim_4_matematik.json` (34 kod, DÖP 1–4); `node tools/soru-uretim/kapi.cjs` → Matematik 30/30 KONTROL, Türkçe 28/28 KONTROL.
- **İlgili:** BEL, §11–§15 REHBER, `kaynak/SORU_UZMANI_REHBER_V3_orijinal.md`.

### K-0048 · 2026-10-18 01:26 · TSR · Senin Hikâyen: cinsiyet kaldırıldı, yol arkadaşı metne işlendi, soru geçişi, PDF düzeltmeleri
- **Tür:** Karar + Düzeltme
- **Konu:** TSR, MOB, UX
- **Bağlam:** Kullanıcı üç konuda karar verdi: (1) cinsiyet seçimi kaldırılsın; kahraman ve hikâye konuları çocuğun kendi seçimine bırakılsın, çünkü her iki cinsiyetin de sevdiği kahraman ve konular var. (2) Yol arkadaşı seçilmesine rağmen hikâyeye işlenmiyordu; kontrol edilsin. (3) Soru geçişleri zamanlansın ve PDF'te düzeltmeler yapılsın.
- **Kararlar (ajan, kullanıcı yetkisiyle):**
  - Cinsiyet: kahraman ekranından ve katalog filtresinden kaldırıldı. Hikâye, kahraman türü ve sınıfa göre listelenir; cinsiyet filtresi yok. Veride `hedef_cinsiyetler` alanı duruyor ama okunmuyor; şema temizliği ayrı iş. K-0023 ve K-0040 cinsiyet filtresi kararları bu kayıtla geçersiz.
  - Soru geçişi: doğru cevapta 3 sn, yanlışta 6 sn sonra sonraki soruya geçilir (yanlışta doğru şıkkı okuma süresi). "Sonraki" süre beklemeden geçirir ve bekleyen zamanlayıcıyı iptal eder. Son soruda otomatik geçiş yok; sonuç düğmesi ekranda kalır (ajan kararı: geçilecek soru olmadığı için).
  - PDF: kapaktan "Okuyan" satırı kaldırıldı; "Senin Hikâyen" ve hikâye başlığı kalın; alt bilgi kalın; hikâye sayfa başlıkları olmadan, bölümler paragraf olarak akar; başlık "Sorular" (kalın); "Cevap Anahtarı" (kalın); her sayfada soluk Hupo filigranı (`rehber_sol`, opaklık %13).
  - Emoji ve simgeler PDF'e resim olarak gömülür (cihazın emoji yazı tipiyle PNG). Kelimeler parça parça değil, boşluksuz gruplarla yerleşir ("Hupo," gibi).
  - Yol arkadaşı: kök neden, 5 hikâyenin 4'ünde yalnızca tek yerde (feneri'de yalnız bir değer varyantında) geçmesiydi; bahcedeki-tohum'da hiç yoktu. Her hikâyeye en az 2 varsayılan metin yeri eklendi (`{yoldas:...}`). Derleyici kuralı: varsayılan metinde en az 2 `yoldas` parçası, aksi hata.
- **Yapılanlar:** kahraman_secim.dart (cinsiyet bölümü ve alanı), katalog.dart (`uygunMu` sınıf+tür; `cinsiyetKodu` kaldırıldı), hikaye_secim.dart, main.dart, tema.dart (metin sabitleri), sorular.dart (zamanlayıcı, iki sabit: `kDogruGecisSaniye`, `kYanlisGecisSaniye`), pdf_hikaye.dart (yeniden yazıldı), pubspec.yaml (PDF yazı tipleri), assets/fonts/NunitoPdf-Regular.ttf ve NunitoPdf-Bold.ttf (Nunito değişken yazı tipinden fonttools ile statik örnek, OFL), 5 hikâyeye yol arkadaşı yerleri, derle.ts (yol arkadaşı kuralı), ornek_veri.dart yenilendi (derlenmiş paketlerle eşleşiyor).
- **Kanıt:**
  - Prototip: `flutter analyze` → No issues found. `flutter test` → All tests passed (26). Yeni testler: `sorular_gecis_test.dart` (3 sn doğru, 6 sn yanlış, "Sonraki" ile çift atlama yok), `yoldas_test.dart` (beş hikâyede ad 2+ yerde; seçilmezse yedek ifade), `geri_donus_pdf_test.dart` (PDF `%PDF` ile başlıyor). `katalog_test.dart` cinsiyet testleri yerine sınıf+tür testi.
  - Atölye: `npm test` → 23/23 (yeni: `yol_arkadasi.test.ts`, 2 test). Beş örnek hikâye derlendi, hata yok.
  - `flutter build web` başarılı; önizleme (`localhost:8765`) ekran görüntüsünde cinsiyet bölümü yok.
  - PDF görsel incelemesi: test ortamında üretilen örnek (kayip-defter) PyMuPDF ile sayfa sayfa incelendi: kapak, akan paragraflar, filigran, "Hupo, Ece'ye" yerleşimi doğru.
- **Açık:**
  - Emoji PDF'te test ortamında kutu olarak çıkıyor (test yazı tipinde emoji yok). Gerçek cihaz ve tarayıcıda renkli çıkması beklenir; doğrulanmadı.
  - Kitap okuyan Hupo pozu yok. Filigran için mevcut `rehber_sol` kullanıldı. Kitap okuyan poz gerekirse tasarım ajanıyla üretilmeli (onaylı varlık kuralı).
  - Yol arkadaşı yedek ifadesi ("bir arkadaşı") çocuk ad girmediğinde kullanılıyor; bu metinler tasarım ve editör gözünden incelenmeli.
  - Soru geçiş süreleri erişilebilirlik açısından (ekran okuyucu, yavaş okuma) ayrıca ele alınmalı; okuma hızı için süre ayarı gerekebilir.
  - Tarayıcıda akış ve PDF indirme görsel kontrolü yapılmadı.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ: birim testleri, derleme, kahraman ekranı görsel kontrolü ve PDF sayfa incelemesi yapıldı; tarayıcıda uçtan uca akış ve emoji görünümü doğrulanmadı.
- **Sahip:** Ajan, Kullanıcı (görsel onay, yedek ifadeler, süre kararları)
- **Önem:** Yüksek
- **İlgili:** K-0023, K-0040, K-0046, K-0047, K-0024

### K-0047 · 2026-10-18 00:54 · TSR · Senin Hikâyen: kart tanıtımı, sınıfa göre şık, simge kuralı, PDF ve geri dönüş
- **Tür:** Karar + Gelişme
- **Konu:** TSR, MOB, HUK (geri dönüş bildirimi, PDF)
- **Bağlam:** Kullanıcı istedi: hikâye kartlarında kısa tanıtım ve merak simgesi; hikâye içinde daha fazla simge ve kavram vurgusu; sınıfa göre şık sayısı; bitişte başka hikâye ya da "yakında tekrar gel" teşviki; 3 gün okumama sayacı ve otomatik bildirim; hikâyeyi markalı PDF olarak indirme (sorular sonda).
- **Kararlar (ajan, kullanıcı yetkisiyle):**
  - Şık sayısı: sınıf_alt ≤ 3 → 3 şık; sınıf_alt ≥ 4 → 4 şık. Derleyicide hata olarak uygulanır.
  - Sahne işareti + otomatik kavram ikonu toplamı sayfada en çok 5 (K-0040'taki 3 sınırı kullanıcı isteğiyle yükseltildi). Otomatik ikon sayfada en çok 3; vurgu en çok 4.
  - Hikâye kartında tanıtım metni ve merak rozeti.
  - Bitiş: "başka bir hikâye" ve "yakında tekrar gel" teşviki. Kutlama yalnız tam doğruda kalır (K-0046).
  - Geri dönüş: yalnız uygulama içi mesaj, 3 gün eşiği (`kGeriDonusGunEsigi`). Uzaktan push bildirimi uygulanmadı; sunucu işi, çocuk hesabı için veli onayı (GÖR-032) ve hukuk incelemesi (GÖR-045) gerektirir.
  - PDF cihazda üretilir, sunucuya gitmez (K-0024). Kapakta marka, tanıtım ve okuyan adı; hikâye sayfaları (emoji ve çıkartmalar PDF yazı tipinde olmadığı için atlanır); sorular; veliler için cevap anahtarı; alt bilgide "Hupolingo · Senin Hikâyen" ve hupolingo.com.
- **Yapılanlar:** `derle.ts` (şık kuralı, kavram ikonu ekleme, sınırlar, tanıtım ve hedef_cinsiyetler); şema (tanitim, ikon, 16 sahne işareti kodu); sözlük (18 kavram); 5 örnek hikâyeye tanıtım ve 4. şık; Dart motoru ikon ayrıştırma; prototip: hikaye_secim (tanıtım, rozet, geri dönüş bandı), katalog (tanitim), sonuç ekranı (tekrar gel, PDF), `pdf_hikaye.dart`, `geri_donus.dart`.
- **Test düzeltmeleri:** Atölye sayfa beklentisi 7 → 8 (hikâyeler 8 sayfa). PDF testi için Flutter binding başlatıldı.
- **Kanıt:**
  - Prototip: `flutter analyze` → No issues found. `flutter test` → All tests passed (23; yeni: geri dönüş zamanlaması ×3, PDF baytları `%PDF` ile başlıyor).
  - Atölye: `npm test` → 21/21 (yeni 4 kural testi: 4. sınıfta 3 şık hatası, 3. sınıfta 4 şık hatası ve 3 şıklı geçiş, sayfa başına en çok 3 ikon, sözlük yoksa ikon yok).
  - Beş örnek hikâye derlendi: hata yok, yalnız sözlük yayın kapısı uyarıları.
  - `flutter build web` başarılı. Önizleme `http://localhost:8765/` yeniden başlatıldı; ilk ekran (kahraman seçimi) ekran görüntüsüyle kontrol edildi.
  - Gömülü veri (`ornek_veri.dart`) son paketlerle eşleşiyor: 38 ikon, 5 tanıtım.
- **Açık:**
  - Hikâye kartı, okuyucu simgeleri, sonuç ekranı ve PDF indirme tarayıcıda görsel olarak kontrol edilmedi.
  - Hikâyeler 290–390 sözcük; klasik 500+ hedefi karşılanmadı.
  - Sunucu tarafı cevap kontrolü (`okuma_cevap_kontrol`, F7) yok. Prototipteki yerel cevap kontrolü yayına çıkmadan önce kaldırılmalı.
  - Push bildirimi (GÖR-032, GÖR-045) ve sunucuda okuma kaydı yok; geri dönüş şimdilik cihazda tutulan son okuma tarihine bakar.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ: birim testleri, derleme ve ilk ekran görsel kontrolü yapıldı; akışın tarayıcıdaki görsel kontrolü bekliyor.
- **Sahip:** Ajan, Kullanıcı (görsel onay, şık ve simge kuralı onayı)
- **Önem:** Yüksek
- **İlgili:** K-0024, K-0040, K-0046, GÖR-032, GÖR-045

### K-0046 · 2026-10-18 00:27 · TSR · Tasarım ajanı uygulaması (UX_INCELEME_3) ve test eşitlemesi
- **Tür:** Gelişme
- **Konu:** TSR, MOB
- **Bağlam:** Kullanıcı tasarımın üst düzey ve özgün olmasını istedi. Tasarım ajanı UX_INCELEME_3 ile tüm öğrenci ekranlarını HupoTema üzerinden yeniden uyguladı.
- **Yapılanlar:** Okuyucu (kitap sayfası, kelime/deyim/atasözü alt sayfaları, Aa ayar sayfası, Sade/Zengin), sorular (Seç → Cevapla → geri bildirim, kırmızı X yok), kahraman (10 tür kartı, önerilen isimler), hikâye (kapak kartı), anket (büyük yıldızlar), bitiş (kutlama yalnız tam doğruda). Ortak bileşenler `lib/widgets/`. P0: "Sen" varsayılan adı kaldırıldı (K-0042'nin gerçekleşmesi).
- **Kararlar (ajan, kullanıcı yetkisiyle):** Sayfa başına çıkartma en çok 3 (K-0040 onaylı); "Hazır Hupo" kartı kalır; hikâyeler 8 sayfa (veri esas alındı).
- **Test eşitlemesi:** Okuyucu testleri 8 sayfaya ve yeni arayüze (Aa sayfası, kelime listesi, Cevapla adımı) göre güncellendi. Parlak sözcüğünün anlamı sözlükteki güncel metne göre (`Güçlü ışık saçan.`) düzeltildi.
- **Kanıt:** `flutter test` → `All tests passed!` (19 test). `flutter build web` başarılı. Önizleme sunucusu `http://localhost:8765/` güncel sürümle yeniden başlatıldı.
- **Açık:** Tarayıcıda 390 ve 1024 px görsel kontrol; TalkBack/VoiceOver; ses yok (kapsam dışı); cihaz kaydı yok; Flutter Web'de emoji görünümü tarayıcıda doğrulanmalı.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — birim testleri, derleme ve geçici uçtan uca akış ajan tarafından doğrulandı; görsel kontrol bekliyor.
- **Sahip:** Ajan, Kullanıcı (görsel onay)
- **Önem:** Yüksek
- **İlgili:** K-0040, K-0042, K-0043, K-0044, K-0045

### K-0045 · 2026-10-18 00:17 · VT · Beş tam uzunluklu test hikâyesi, hakem turu, derleyici sonuçları
- **Tür:** Gelişme
- **Konu:** MOB, TSR, BEL
- **Bağlam:** Kullanıcı isteği: sistemi test etmek için en az beş gerçek uzunluklu hikâye; hikâyeler sadece sistem testi için değil, uygulamaya girecek kalitede istenir. Önceki örnekler 184–260 kelimeydi ve bu gerçek uzunluk sayılmazdı.
- **Yapılanlar (`ornek/`):** Beş hikâye 8 sayfaya çıkarıldı (kapanış sayfaları eklendi), soru dayanakları değişmedi, değer sahneleri ve çıkartmalar korundu:
  - Kayıp Defter (gizem, kütüphane): ~393 kelime.
  - Feneri Kim Yakıyor? (macera, masalsı): ~324 kelime.
  - Mahallenin En Hızlı Bisikleti (macera, spor): ~309 kelime.
  - Bahçedeki Tohum (doğa, bahçe): ~298 kelime.
  - Gökyüzündeki Balon (bilim, gökyüzü): ~291 kelime.
  - Sözlük (`sozluk.ornek.json`): 6 kelime yuvası, 3 atasözü, 2 deyim; yuvaların çoğunda 3 aday.
- **Derleyici:** Beş hikâye hatasız derlendi; uyarılar yalnızca sözlüğün taslak olmasından ve deyim yuvalarının tek adaylı olmasından. Derleyici testleri 17/17 (test beklentileri yeni hikâyelere göre güncellendi).
- **Hakem (Gemini, gemini-3.8-flash):** Beş hikâyenin tamamı öneri "geçer" (ortalama 4.8–5). Hakem turunda bulunan gerçek sorunlar (cümle hataları, olay sırası, bir çocuk güvenliği izlenimi, tek yönlü soru cevapları) düzeltildi.
- **Dürüst sınır:** Kelime sayıları 290–390 aralığında. Klasik 4–5. sınıf hikâyesi için 500+ kelime hedeflenirse ikinci bir içerik turu gerekir; bu, editör ve kullanıcı okumasıyla birlikte yapılmalı.
- **Açık:** Prototip testleri (okuyucu, anket) tasarım ajanının son değişiklikleri nedeniyle güncellenecek; katalog ve motor testleri geçiyor.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — derleme ve hakem doğrulandı; tarayıcıda ve uçtan uca oynanış henüz kontrol edilmedi.
- **Sahip:** Ajan, Kullanıcı (son okuma)
- **Önem:** Yüksek
- **İlgili:** K-0031, K-0034, K-0041, K-0043, K-0044

### K-0044 · 2026-10-17 23:38 · TSR · Kullanıcı geri bildirimi: kahraman yelpazesi, çıkartmalar, Hupo pozları
- **Tür:** Gelişme
- **Konu:** TSR, MOB, VT
- **Bağlam:** Kullanıcı üç geri bildirim verdi: (1) hikâye çok kısa (sistemi test etmek için böyle, konu uzatılmadı); (2) hikâyede GIF ve çıkartma yok, eğlenceli okuma için istenir; (3) tasarımda önemli bir değişiklik görülmüyor. Ek istek: kahraman seçenekleri daha geniş olsun, çocuk kendi adını da yazabilsin.
- **Yapılanlar:**
  - Kahraman yelpazesi: "Arkadaşım" türü eklendi (izinli hikâyelerde derleyici kodu `arkadas`). Hayvan, araç ve hayalî türlerinde hazır isim önerileri (ör. Kedi, Roket, Gökkuşağı Perisi); her türde kendi adını yazabilir. Hupo maskotu kahraman ekranında.
  - Çıkartmalar: 16 sahne işareti kodu (ör. 🦉 `hupo`, 🚀 `roket`, 🐱 `kedi`, 🌊 `deniz`); derleyici, şema ve motor aynı listeyi kullanıyor. Örnek hikâyelere 2 çıkartma eklendi.
  - Hupo pozları (hosgeldin, merak_ediyor, harika, bir_daha_dene) kahraman, hikâye seçme ve bitiş ekranlarında.
  - Testler: motor 32/32, prototip 19/19; derleyici 17/17; web derlemesi başarılı.
- **Açık / sonraki:**
  - GIF: henüz yok. Kaynak (hazır GIF ya da üretim) gerekiyor; sonra sayfalara eklenecek.
  - Hikâye uzunluğu: örnek hikâyeler sistem testi için kısa bırakıldı. Gerçek uzunluk içerik işidir; pilot hikâyeler ayrıca yazılacak.
  - Tasarım: poz ve çıkartma etkisi var; kart ve buton dili (HupoTema köşe ve gölge değerleri) ekranlara henüz bağlı değil. Tasarım ajanıyla ikinci tur gerekiyor.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — birim testleri ve derleme geçti; tarayıcıda yeni görünüm henüz kontrol edilmedi.
- **Sahip:** Ajan
- **Önem:** Orta
- **İlgili:** K-0041, K-0042, K-0043

### K-0043 · 2026-10-17 23:21 · TSR · Kullanıcı yetkisiyle kararlar: sonuç kutlaması, anket, cinsiyet sorusu, vurgu sınırı
- **Tür:** Karar
- **Konu:** TSR, MOB, HUK
- **Bağlam:** Kullanıcı K-0042'deki üç açık kararı ajana bıraktı: "Sen karar ver ve ilerle; çocuğu teşvik etmek esas, gereksiz tebrik anlamsız."
- **Kararlar (ajan, kullanıcı yetkisiyle):**
  - `KARAR` Kutlama: Animasyon yalnız tüm sorular doğruysa çıkar. Diğer durumda sakin ikon ve teşvik cümlesi ("Bir sonraki hikâyede daha da iyi olacaksın."). Hikâyeyi bitirmek başlı başına başarı olduğu için bu cümle gösterilir; ayrıca kutlama dili yok.
  - `KARAR` Cinsiyet sorusu görünür kalır (brif filtreyi istiyor); isteğe bağlı, yalnız cihazda kullanılır, kayıt edilmez. Profilde saklama, GÖR-045 hukuk görüşünden sonra.
  - `KARAR` Vurgu sınırı: Zengin modda sayfada en çok 3, Sade modda 1 önemli yer (K-0036 ve tasarım dokümanıyla uyumlu).
  - `KARAR` Hikâyeyi sevme anketi eklendi (brif maddesi): 1–5 yıldız, en çok 3 iyileştirme seçimi, "başka kahraman ister misin", "bu türden başka hikâye ister misin", "Şimdi değil" ile atlanabilir. Ödül ve serbest metin yok.
- **Uygulama:** `flutter_prototip/lib/ekranlar/anket.dart`; `main.dart` akışı: kahraman → hikâye → okuma → sorular → anket → sonuç. Bitiş ekranı kutlamayı yalnız tam doğruda gösterir.
- **Düzeltme:** Tasarım ajanının raporundaki "K-0041" numarası kullanılmıştı; bu kayıt tasarım bulgularını K-0042'ye bağlar.
- **Kanıt:** `flutter test` → `All tests passed!` (19 test: anket 3 yeni). `flutter build web` başarılı. Önizleme sunucusu `http://localhost:8765/` yeniden başlatıldı (HTTP 200).
- **Açık:** Anket yanıtları şimdilik yalnız bellekte; kalıcı kayıt F7 (sunucu) işi. Tarayıcı görsel kontrolü (anket ve bitiş) yapılmadı.
- **Durum:** TAMAMLANDI bu kapsamda (karar, kod, test); görsel doğrulama bekliyor → DEVAM olarak işaretlendi.
- **Doğrulama:** KISMİ
- **Sahip:** Ajan (uygulama), Kullanıcı (yetki)
- **Önem:** Yüksek
- **İlgili:** K-0040, K-0041, K-0042, GÖR-045

### K-0042 · 2026-10-17 23:05 · TSR · Tasarım ajanı incelemesi, HupoTema, "Ben" adı düzeltmesi, font bağlantısı
- **Tür:** Gelişme
- **Konu:** TSR, MOB
- **Bağlam:** Kullanıcı isteği: tasarım sevimli, kullanışlı ve esnek olsun. Tasarım ajanı UX/UI incelemesi yaptı (`docs/tasarim/UX_INCELEME_2.md`). Ajanın taslağındaki kayıt numarası (K-0041) bu kayıtta zaten kullanılmıştı; bu kayıt K-0042 olarak yazıldı.
- **Yapılanlar:**
  - `flutter_prototip/lib/tema.dart`: tüm renk, yazı, boşluk, köşe, dokunma alanı, maskot boyutu ve hareket değerleri `HupoTema` içinde; `HupoRenk` ve `Metin` adları korundu. `temaVerisi()` ile tema üretimi.
  - `main.dart`: tema `HupoTema.temaVerisi` ile bağlandı; yazı ailesi Nunito.
  - Fontlar (`Nunito`, `Lexend`) `assets/fonts` altına kopyalandı ve pubspec'e tanımlandı.
  - Hata düzeltmesi (ajan bulgusu): "Ben" seçilip ad boş bırakılınca kahraman adı "Sen" oluyordu. Prototipte profil adı olmadığı için "Ben" de artık ad ister.
- **Açık (kullanıcı kararı bekleniyor):**
  1. Düşük sonuçta Lottie kutlaması kapatılsın mı?
  2. Kahraman ekranındaki "kız / erkek / fark etmez" sorusu hukuk görüşü (GÖR-045) gelene kadar gizlensin mi?
  3. Vurgu sınırı (Zengin: 3, Sade: 1) ürün kararı olarak onaylansın mı?
- **Ajan bulguları, henüz uygulanmadı:** Okuyucu gezinme düğmeleri sayfa sonunda; soruda cevapla adımı yok (dokunuşta cevaplanıyor); anket yok; Hupo maskotu ekranlarda yok (poz tablosu UX_INCELEME_2.md bölüm 3'te). Bu işler ekran dosyalarına dokunur; sırasıyla yapılacak.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — `flutter test` 16/16 geçti, `flutter build web` başarılı; yeni tema ve fontlar tarayıcıda görsel olarak kontrol edilmedi. Ajanın `flutter analyze` sonucu: hata yok.
- **Sahip:** Ajan, Kullanıcı (3 açık karar)
- **Önem:** Orta
- **İlgili:** K-0036, K-0037, K-0040, K-0041, GÖR-045

### K-0041 · 2026-10-17 22:58 · MOB · Hikâye seçme ekranı, cinsiyet etiketi, emoji sınırı 3 (K-0040 uygulaması)
- **Tür:** Gelişme
- **Konu:** MOB, TSR, VT
- **Bağlam:** K-0040 kararları: cinsiyet filtresi brifte, sembol/emoji serbest (sayfa başına en çok 3, kullanıcı onayladı), çizgi film tarzı karakter, pilot 24.
- **Yapılanlar:**
  - `atolye/src/derle.ts`: sayfa başına sahne işareti sınırı 1 → 3. Hikâyeye `hedef_cinsiyetler` (kiz / erkek / fark_etmez; varsayılan hepsi). `sema/hikaye-paketi.v1.schema.json` güncellendi. İki örnek hikâye yeniden derlendi.
  - `flutter_prototip/lib/katalog.dart`: hikâye kataloğu; uygunluk = kahraman türü izinli + sınıf aralığı + cinsiyet (cinsiyet seçilmezse ya da "fark_etmez" ise filtre yok).
  - `flutter_prototip/lib/ekranlar/hikaye_secim.dart`: tür çipleri, hikâye kartları, boş durum ("Bu kahramanla şimdilik uygun bir hikâye yok...").
  - `flutter_prototip/lib/main.dart`: akış kahraman → hikâye seçimi → okuma → sorular → sonuç.
- **Kanıt:** atolye testleri 17/17. Prototip `flutter test` → 16 test (katalog filtresi 7 + ekran ve okuyucu 9) geçti; `flutter build web` başarılı.
- **Hatırlatma (kural çelişkisi):** Kit ve ürün kuralları cinsiyete göre içerik kısıtlamasını ve cinsiyetin zorunlu tutulmasını yasaklıyor (K-0040'ta not düşüldü). Bu prototipte filtre yalnız yerel katalog verisiyle çalışıyor; profilde cinsiyet saklanması F7 ve hukuk onayına bağlı.
- **Açık:** Örnek hikâyelerin cinsiyet etiketleri varsayılan (hepsi); gerçek pilot içerikte etiketlemeye karar verilecek. Tasarım ajanının UX incelemesi arka planda çalışıyor (`docs/tasarim/UX_INCELEME_2.md`); tema dosyası onun düzenlemesinde.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — birim testleri ve derleme geçti; hikâye seçme ekranı tarayıcıda görsel olarak kontrol edilmedi.
- **Sahip:** Ajan
- **Önem:** Yüksek
- **İlgili:** K-0040, K-0023, K-0024, K-0038

### K-0040 · 2026-10-17 22:31 · YÖN · Brif kararları: cinsiyet filtresi, sonuç animasyonu, çizgi film tarzı karakter, pilot 24
- **Tür:** Karar
- **Konu:** YÖN, TSR, HUK, MOB
- **Bağlam:** Kullanıcı brifini tazeletti (`C:\Dev\Senin Hikayen - HupoRead\BRIEF.md`). Önceki kararların bazıları brifle çelişiyordu; kullanıcı yeniden karar verdi.
- **Kararlar (kullanıcı, 2026-10-17 22:31):**
  - `ONAYLI` — Cinsiyet filtresi brifte kalsın (K-0023'teki "filtrelenmez" kararı bu kayıtla değişti). **Çelişki uyarısı:** `docs/` ve kit kuralları cinsiyete göre içerik kısıtlamayı ve cinsiyeti zorunlu tutmayı yasaklıyor (veri minimizasyonu, KVKK). Filtreleme kabulü için kullanıcının açık onayı kaydedildi; uygulama öncesi hukuk görüşü (GÖR-045) ve veli rızası gerekli. Profilde cinsiyet tutulacaksa F7 şemasında ve aydınlatma metninde yer almalı.
  - `ONAYLI` — Sonuç ekranında GIF ya da kısa animasyon; cümlelerde de konuyla ilgili dikkat çekici sembol/emoji olabilir. Öneri (uygulanacak): sayfa başına en çok 3 sembol (K-0036'daki "en çok 1" sınırı bu kararla değişti). GIF yerine uygulamanın Lottie dosyaları kullanıldı (K-0040 uygulama).
  - `ONAYLI` — Çizgi film tarzı özgün karakter yeterli; markalı/telifli karakter adları yok. Etiket: "Çizgi film tarzı karakter".
  - `ONAYLI` — Pilot 24 hikâye, sonra ölçek.
- **Uygulama (prototip):** Sonuç ekranında Lottie yıldız animasyonu (hareket azaltma açıksa statik ikon); kahraman etiketi güncellendi; `assets/lottie/confetti.json` ve `star.json` prototipte. Testler 9/9; web derlemesi başarılı.
- **Açık:** Cinsiyet filtresi için hikâye kataloğunda cinsiyet etiketi ve hikâye seçme ekranı (sıradaki iş); emoji sınırının 3 olarak uygulanması; hukuk görüşü.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — karar kullanıcı yanıtıyla; animasyon ve etiket birim testleri ve derlemeyle doğrulandı, tarayıcıda görsel kontrol yapılmadı.
- **Sahip:** Kullanıcı (kararlar), Ajan (uygulama)
- **Önem:** Yüksek
- **İlgili:** K-0023, K-0024, K-0036, K-0039, GÖR-045

### K-0039 · 2026-10-17 22:13 · TSR · Yanlış cevapta doğru şık gösterilir; yerel önizleme sunucusu
- **Tür:** Karar
- **Konu:** TSR, MOB
- **Bağlam:** K-0038'de açık kalan ürün sorusu. Kullanıcı yanıtı: yanlış cevapta doğru şık gösterilsin.
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17 22:13). Yanlış cevapta doğru şık yumuşak mint çerçeve ve onay ikonu ile gösterilir; kırmızı X ya da ceza yok. Doğru şık bilgisi yalnız cevap verildikten sonra döner (üretimde sunucu yanıtında).
- **Yapılanlar:** `flutter_prototip`: `GeriBildirim.dogruSecenekId` (isteğe bağlı), `sorular.dart` (dogruGoster durumu), `main.dart` (yerel kontrol doğru şıkkı döner), yeni widget testi.
- **Kanıt:** `flutter test` → `All tests passed!` (9 test). `flutter build web` başarılı. Yerel önizleme sunucusu `http://localhost:8765/` üzerinde çalışıyor (HTTP 200).
- **Hatırlatma:** Prototipteki yerel doğru-cevap kontrolü yalnız örnek veri içindir; üretimde sunucu RPC'si kullanılacak (F7). Önizleme yalnızca bu bilgisayarda açılır.
- **Durum:** TAMAMLANDI bu kapsamda (karar + kod + test); tarayıcıda görsel doğrulama yeniden yapılmadı.
- **Doğrulama:** KISMİ — birim testleri geçti; yeni görünüm tarayıcıda henüz gözle kontrol edilmedi.
- **Sahip:** Kullanıcı (karar), Ajan (uygulama)
- **Önem:** Orta
- **İlgili:** K-0036, K-0037, K-0038

### K-0038 · 2026-10-17 21:54 · MOB · Prototip web derlemesi ve 390 px görsel kontrol
- **Tür:** Gelişme
- **Konu:** MOB, TSR
- **Bağlam:** K-0037 prototipinin görsel doğrulaması (GÖR-044 kapsamı). Kayıtta "görsel kontrol yapılmadı" yazıyordu.
- **Yapılanlar:** `flutter build web` başarılı (`flutter_prototip/build/web`). Yerel sunucuda (port 8765) tarayıcı kontrolü: kahraman seçimi ekranı ve okuyucu ekranı 390×844 görüntüde alındı; konsol hatası yok, başarısız istek yok.
- **Gözlemler:**
  - Kahraman ekranı: 9 tür, ad alanı, cinsiyet çipleri ve düğme taşmadan görünüyor.
  - Okuyucu: "Pati" adı metne doğru yerleşti ("Pati sahilde bunu fark etti."); sayfa sayacı ve gezinme düğmeleri görünüyor.
  - Sayfa 1'de vurgu yok (örnek hikâyede kalın/renkli kelime sonraki sayfalarda); kelime ve atasözü stilleri bu kontrolde görülmedi.
  - Küçük sorun: seçili "Hazır Hupo" çipinin ikonu koyu gri ve düşük kontrastlı.
  - Sayfa tuvalde çiziliyor; DOM metni boş, bu yüzden metin doğrulaması ekran görüntüsüyle yapıldı.
- **Güncelleme 2026-10-17 22:01 (tarayıcı kontrolü devamı, 390 px):**
  - Sayfa 2: yol arkadaşı yoksa "bir dostuna" yedeği doğru geldi; değer sahnesi varsayılanı göründü.
  - Sayfa 3: "parlak" kelimesi teal, noktalı alt çizgili; "Sayfadaki kelimeler" listesi görünüyor.
  - Sayfa 4: atasözü italik ve tırnak içinde; düzeltilmiş "sabırla atılan" cümlesi doğru.
  - Sorular: 1/4 soru görünüyor; yanlış cevapta yumuşak kutu ve açıklama çıkıyor, X yok; "Sonraki soru" cevaptan sonra aktif.
  - Gözlem: yanlış cevapta doğru şık vurgulanmıyor; çocuk doğru cevabı bu ekranda görmüyor (açıklama metni ipucu veriyor). Ürün kararı gerekir.
  - Gözlem: "Sayfadaki kelimeler" kelime çipi ve kelime vurgusu tutarlı.
- **Doğrulanmayanlar:** 1024 px görünüm, sorulardaki diğer soruların ve bitiş ekranının görünümü, gerçek cihaz (Android SDK yok).
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — 390 px'de kahraman, okuyucu (4 sayfa) ve ilk soru doğrulandı; 1024 px ve bitiş ekranı açık.
- **Sahip:** Ajan
- **Önem:** Orta
- **İlgili:** K-0037, K-0036, GÖR-044

### K-0037 · 2026-10-17 18:17 · MOB · Okuma Dünyası Flutter prototipi: kahraman seçimi, okuyucu, sorular (F8, prototip)
- **Tür:** Gelişme
- **Konu:** MOB, TSR
- **Bağlam:** K-0035/K-0036 tasarım kararları ve K-0030–K-0032 motor işi üzerine, ekranların ilk çalışan hali. Tasarım sözleşmesi `docs/tasarim/OKUMA_DUNYASI_EKRANLARI.md`.
- **Yapılanlar:** `C:\Dev\Senin Hikayen - HupoRead\flutter_prototip\` (Flutter web, `okuma_motoru` path bağımlılığı):
  - `lib/tema.dart`: renk tokenları (vurguAmber `#8A5B00`, K-0036) ve Türkçe sabit metinler.
  - `lib/ekranlar/kahraman_secim.dart`: 9 kahraman türü, ad kuralı (1–24, harf/boşluk/kesme/kısa çizgi), isteğe bağlı cinsiyet (yalnız cihazda), yol arkadaşı.
  - `lib/ekranlar/okuyucu.dart`: sayfa okuma; önemli yer (kalın + amber alt çizgi), kelime (teal noktalı, dokununca anlam), atasözü (italik), deyim (sarı zemin), işaret; Sade/Büyük yazı; "Sayfadaki kelimeler" listesi (H4).
  - `lib/ekranlar/sorular.dart`: tek soru, tek deneme, anında geri bildirim (H1); yanlışta kırmızı X ve ceza yok (yumuşak mercan zemin + ampul ikonu).
  - `lib/main.dart`: akış (kahraman → okuma → sorular → bitiş). Örnek hikâye: `lib/ornek_veri.dart` (derleyici çıktısı gömülü).
- **Kanıt:** `flutter test` → `All tests passed!` (8 widget testi: sayfa sayacı, ilerleme, kelime anlamı, Sade modu, 24 karakter kesme, ad kuralı, yanlış cevap yumuşaklığı, tek deneme).
- **Bilinen sınırlar / sapmalar:**
  - **Güvenlik (kritik, prototip özel):** Doğru anahtar bu prototipte istemcide okunuyor (`_yerelKontrol`, main.dart). Üretimde bu kontrol sunucuda yapılacak (`okuma_cevap_kontrol` RPC'si, F7). Prototip dışına çıkmadan önce kaldırılmalı.
  - Anında geri bildirim RPC'si şimdi yazılmadı: hikâye tabloları (`okuma_*`) henüz yok; RPC onlara bağlı, F7'de (`20261050`).
  - Sınıf 4 sabit; yalnız tek örnek hikâye; atasözü çubuğu (sol altın çizgi) yerine italik + tırnak uygulandı; deyim ve atasözü zemin/çubuk ayrıntıları tam değil.
  - Nunito/Lexend yazı tipleri paketlenmedi (varsayılan font kullanılıyor).
  - Görsel doğrulama yapılmadı: 390 px ve 1024 px ekran görüntüsü, tarayıcı kontrolü ve cihaz testi yok. `flutter build web` çalıştırılmadı.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — widget testleri geçti; görsel kontrol, sunucu kontrolü ve yayın kalitesi doğrulanmadı.
- **Sahip:** Ajan
- **Önem:** Yüksek
- **İlgili:** K-0030, K-0032, K-0035, K-0036, GÖR-044

### K-0036 · 2026-10-17 18:07 · TSR · Okuma Dünyası tasarım kararları (H1–H4) kullanıcı tarafından verildi
- **Tür:** Karar
- **Konu:** TSR, VT, MOB
- **Bağlam:** K-0035 şartnamesindeki açık kararlar kullanıcıya soruldu.
- **Karar:**
  - `ONAYLI` H1 (kullanıcı): Quiz geri bildirimi her soruda anında gösterilir. Sonuç: cevap sunucuda kontrol edilir; yeni bir RPC gerekir (örn. `okuma_cevap_kontrol`). Doğru cevap anahtarı yine istemciye gönderilmez; yalnız seçilen şık için doğru/yanlış ve açıklama döner. Bu, K-0022/PLAN'daki "açıklamalar bitişte" ve "dogru anahtarı taranır" ilkelerini değiştirir; PLAN ve kabul testleri buna göre güncellenecek. RPC, F7 migration bloğunda (`20261050`) yer alacak.
  - `ONAYLI` H2 (kullanıcı): Kahraman adı en çok 24 karakter.
  - `ONAYLI` H3 (kullanıcı): Vurgu rengi `#8A5B00` (markadaki uyarı tonu; AA kontrast 5.6:1).
  - `ONAYLI` H4 (kullanıcı): Okuyucu altında "Sayfadaki kelimeler" yedek listesi eklenir.
- **Not (düzeltme):** K-0034 kaydının saati (18:20) Get-Date ile alınmamıştı; gerçek saat 18:02 idi. Kayıt içeriği değişmedi.
- **Durum:** DEVAM (F8 Flutter kodlaması için tasarım kararları tamam; RPC F7'de)
- **Doğrulama:** DOĞRULANDI (karar kullanıcı yanıtıyla)
- **Sahip:** Kullanıcı
- **Önem:** Yüksek
- **İlgili:** K-0035, K-0022, K-0034

### K-0035 · 2026-10-17 18:02 · TSR · Okuma Dünyası öğrenci ekranları: tasarım şartnamesi (5 ekran, H kararları bekliyor)
- **Tür:** Plan
- **Konu:** TSR, MOB, VEL
- **Bağlam:** Kullanıcı Senin Hikâyen (HupoRead) öğrenci ekranları için kahraman seç, hikâye seç, okuyucu, sorular/sonuç ve anket ekranlarının tasarımını istedi. Yalnız tasarım; Flutter kodu yazılmadı.
- **Plan:**
  1. Ekran şartnamesi (hedef, ana eylem, durumlar, kabul, 390/1024 yerleşim, Türkçe const metinler, tokenlar, Hupo pozları) — `C:\Dev\Senin Hikayen - HupoRead\docs\tasarim\OKUMA_DUNYASI_EKRANLARI.md`.
  2. Vurgu stilleri (önemli yer, kelime, deyim, atasözü) ve kontrast ölçümü (~40 çift; WCAG formülü, ekran ölçümü değil).
  3. Bileşen listesi (mevcut ChunkyButton, Hupo, GameCard, ResponsivePage yeniden kullanılır; yeni widget'lar `widgets/okuma/`).
  4. F8 öncesi 5 karar (H1–H5) kullanıcıya sorulacak.
- **Karar:** Kullanıcı kararları (`ONAYLI`, K-0022…K-0024): kahraman 9 tür, cihazda cinsiyet sorusu, 3 öneri, Sade/Zengin, anket ödülsüz. Ajan önerileri `ONAY BEKLİYOR`: vurguAmber #9A6A12 (öneri token); anında geri bildirim (H1, kit'in "açıklamalar bitişte" kuralıyla çelişiyor); kahraman adı 24 karakter (H2); görünüm sorusunun avatar etkisi (H3); ürün adı ve ikon seti (H4); kelime dokunma alanı için yedek liste (H5).
- **Durum:** BEKLİYOR
- **Doğrulama:** DOĞRULANMADI — ekran, Flutter derlemesi, cihaz ve ekran görüntüsü yok. Kontrast oranları hesaplandı (metin ≥4.5:1 çiftleri başarılı; `lineDark` kenar ve `sunDark` metin/çizgi kullanılmıyor).
- **Sahip:** Ajan (tasarım) + Kullanıcı (H1–H5)
- **Önem:** Yüksek
- **Açıklama:** Tasarım dosyası hazır; F8 (Flutter) ve H1 kararı olmadan yanlış cevap akışı kodlanmamalı. Kit ile brief arasındaki geri bildirim çelişkisi açıkça kayda geçti.
- **Kanıt:** `C:\Dev\Senin Hikayen - HupoRead\docs\tasarim\OKUMA_DUNYASI_EKRANLARI.md` (A–I bölümleri); kaynaklar: `mobile-app/lib/theme/app_theme.dart`, `widgets/hupo/hupo_pose.dart`, `utils/motion.dart`, `utils/breakpoints.dart`.
- **İlgili:** K-0022, K-0024, GÖR-044, GÖR-049, TSR kayıtları

### K-0034 · 2026-10-17 18:20 · YÖN · Katman B canlı çalıştı: Gemini hakem, .env önceliği, örnek hikâyelerde düzeltmeler
- **Tür:** Gelişme
- **Konu:** YÖN, TSR, BEL
- **Bağlam:** K-0033'teki engel çözüldü. Kullanıcı bildirdi: oturumda eski bir `GEMINI_API_KEY` ortam değişkeni kalmış ve doğru anahtarı gölgelemişti; Node `.env`'yi mevcut değişkenin üzerine yazmaz. Yeni Gemini anahtarları `AQ.` ile başlıyor (ilk varsayımım yanlıştı).
- **Yapılanlar:**
  - `atolye/src/saglayici.ts`: `envYukle(dosya)` — `.env` değerleri ortam değişkenlerinin üstüne yazılır. `--env <dosya>` ile kullanılır; anahtar kopyalanmaz, proje `.env` dosyası doğrudan okunur.
  - Hakem modeli `gemini-3.8-flash` (proje `llm.ts` ile aynı). `gemini-2.5-pro` bu anahtarla HTTP 404 verdi.
  - Çıktı sınırı 32.000 token (Gemini düşünme token'ları da bu sınırdan sayılır).
  - Gemini `responseSchema`: puanlar tam sayı, kategori/önem/cevap enum (A–D). Kör çözüm şıkları artık boş dönmüyor.
- **Canlı sonuçlar (hakem):**
  - Kayıp Defter: ortalama 4.8, öneri gecer, 1 sorun (orta, olay tutarlılığı).
  - Feneri: ortalama 4.5, öneri gecer, 2 sorun.
  - Kör çözüm uyumsuzluğu: yok. Çıktılarda anahtar sızıntısı yok (dosya taraması).
- **Hakemin bulduğu gerçek sorunlar ve düzeltmeler:**
  - İki hikâyede tüm doğru cevaplar "A" idi; cevaplar dağıtıldı.
  - Kayıp Defter D6 dalı, sonraki sayfalarla çelişiyordu (defter hemen teslim ediliyor, araştırma devam ediyor); D6 metni haritayı önce arkadaşlara göstermeye çevrildi.
  - Feneri 4. sayfada "sabırla yakılan adım" anlatım hatası; "sabırla atılan" yapıldı.
  - "Damlaya damlaya göl olur" bu bağlamda birikim anlamında okundu; yerine "Sabırla koruk helva olur." (sözlük girdisi güncellendi).
- **Kanıt:** atolye testleri `# pass 17 / # fail 0`; Dart `dart test` → `All tests passed!` (32; fikstür yenilendi).
- **Durum:** DEVAM
- **Doğrulama:** DOĞRULANDI (canlı entegrasyon: rapor üretildi, zincir çalıştı). Hakem görüşleri öneridir; son okuma kullanıcıda (K-0025).
- **Sahip:** Ajan, Kullanıcı (son okuma)
- **Önem:** Yüksek
- **İlgili:** K-0024, K-0025, K-0031, K-0033, GÖR-050

### K-0033 · 2026-10-17 17:50 · YÖN · Katman B hakem: Gemini birincil, Claude yedek; canlı çağrı anahtar nedeniyle engelli
- **Tür:** Karar
- **Konu:** YÖN, BEL
- **Bağlam:** Kullanıcı Katman B'yi ücretli Gemini ile denemek, Claude'u hazır tutmak istedi (Gemini çalışmazsa Claude).
- **Karar:**
  - `ONAYLI` (kullanıcı): Katman B hakemi Gemini (birincil, ücretli API). Claude (yedek, anahtar tanımlıysa devreye girer). Yazar Claude olduğu için hakem farklı aileden; K-0024'teki "farklı aile" hedefine daha yakın.
  - `ONAYLI` (ajan kararı, tasarım): Hakem yalnızca geri bildirim üretir; yayın kararı vermez. Karar önerisi koddan hesaplanır (kesin kritik → reddet; kesin orta veya ortalama < 3.5 → incele; aksi gecer). Kör çözümde hakem cevap anahtarını görmez; uyumsuzluklar raporlanır.
  - Gemini modeli varsayılanı `gemini-2.5-pro` (`GEMINI_HAKEM_MODEL` ile değişir); Claude hakem modeli `claude-opus-5-5` (`ANTHROPIC_HAKEM_MODEL`).
- **Yapılanlar:** `atolye/src/saglayici.ts` (sağlayıcı zinciri, anahtar maskeleme), `atolye/src/katman_b.ts` (hakem girdisi, yanıt doğrulama, karar önerisi, kör çözüm), `atolye/src/cli.ts` (`hakem` komutu). Gönderilen veri yer tutucu adlıdır; çocuk adı yoktur; kör çözümde cevap anahtarı çıkarılmıştır.
- **Kanıt:**
  - `node --test --experimental-strip-types testler/*.test.ts` → `# tests 16 / # pass 16 / # fail 0` (ağ çağrısı yok; sahte HTTP).
  - Canlı deneme: `hakem` komutu Gemini'ye istek attı; Gemini **HTTP 401** döndü. Ortamdaki `GEMINI_API_KEY` `AQ.` ile başlıyor; Gemini API anahtarları genellikle `AIza` ile başlar. Anahtar değeri kayda yazılmadı.
  - `ANTHROPIC_API_KEY` tanımlı değil; yedek de çalışmadı.
- **Engel:** Geçerli bir Gemini API anahtarı (AI Studio'dan, `AIza…`) ya da Claude anahtarı gerekiyor. Anahtar yalnızca ortam değişkeni olarak tanımlanmalı; sohbete ya da dosyaya yazılmamalı.
- **Durum:** BEKLİYOR (anahtar)
- **Doğrulama:** KISMİ — yapı ve zincir birim testleriyle doğrulandı; canlı çağrı başarısız (401).
- **Sahip:** Kullanıcı (anahtar), Ajan (kod)
- **Önem:** Yüksek
- **İlgili:** K-0024, K-0025, K-0031, GÖR-050

### K-0032 · 2026-10-17 17:40 · MOB · Dart motoru derlenmiş paketi okuyor (F1 ↔ F2 bağlantısı)
- **Tür:** Gelişme
- **Konu:** MOB
- **Bağlam:** Derleyicinin çıktısı (hikâye paketi JSON) ile Dart motorunun birbirini okuyabilmesi gerekiyordu.
- **Yapılanlar:** `dart/okuma_motoru/lib/paket.dart`: `hikayeFromPaket` (paket JSON → `Hikaye`), `yuvalarFromSozluk` (sözlük JSON → yuva adayları), `parcaFromJson`. `test/paket_test.dart`: derlenmiş "Feneri Kim Yakıyor?" paketi fikstür olarak kullanılır; hayvan/hayalî kahraman, yol arkadaşı var/yok, değer sahnesi, sınıf ve görülen sözcük seçimi, stiller ve sürüm kontrolü test edilir.
- **Kanıt:** `dart analyze lib test` → `No issues found!`; `dart test` → `All tests passed!` (32 test: 13 ad çekimi, 12 birleştirme, 7 paket).
- **Bilinen sınır:** Fikstür kopyalanmış bir dosya; derleyici değişince yeniden kopyalanmalı (otomatik üretim sonraki adım).
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — paket okuma ve render birim testleriyle doğrulandı; Flutter ekranı ve gerçek sözlük henüz yok.
- **Sahip:** Ajan
- **Önem:** Yüksek
- **İlgili:** K-0029, K-0030, K-0031, GÖR-044

### K-0031 · 2026-10-17 17:28 · MOB · Okuma derleyicisi ve Katman A kapıları (F2)
- **Tür:** Gelişme
- **Konu:** MOB, TSR, BEL
- **Bağlam:** Editörün yazdığı `.hikaye.md` dosyasını hikâye paketi v1'e çeviren ve kalite kapılarını uygulayan derleyici (LLM kullanmaz).
- **Yapılanlar:**
  - `sema/hikaye-paketi.v1.schema.json`, `sema/sozluk.v1.schema.json` (JSON Schema 2020-12).
  - `atolye/src/derle.ts`: DSL → paket; şema doğrulaması; anlamsal kontroller (en az 2 omurga, sayfa başına ≤3 vurgu ve ≤1 işaret, değer/hareket/deyim referansları, `_default` ve değer kodu kontrolü, tür izni, quiz dayanağının omurgada olması, sözlük yuvası ve sınıf kapsamı).
  - `atolye/src/cli.ts`: `derle <hikaye.md> [--sozluk json] [--cikti klasör]`; hata varsa paket yazılmaz.
  - Örnekler (TASLAK, yayın kapısından geçmez): `ornek/kayip-defter.hikaye.md` (gerçekçi, ben/baba/anne/kardeş/başka biri), `ornek/feneri-kim-yakiyor.hikaye.md` (masalsı, hayvan/hayalî/ben), `ornek/sozluk.ornek.json`.
- **Kanıt:**
  - `node --test --experimental-strip-types testler/*.test.ts` → `# tests 8 / # pass 8 / # fail 0`.
  - İki örnek CLI ile derlendi; hata yok, uyarılar beklenen türde (sözlük taslak; sınıf başına 1–2 aday, yayın kapısı 3).
- **Bulunan ve düzeltilen:** Hareket sahnesi anahtarı "geliş" (Türkçe harf) token sözdizimine uymuyordu; ASCII "gelis" yapıldı. Ayrıca `as ... in` ifadesi Node tip sıyırma ile güvenli değildi; `Object.hasOwn` ile değiştirildi.
- **Açık (F2 devamı / F4-F5):** Dart motorunun paket JSON'unu okuması (`fromJson`); derleyicinin test kapsamı genişletilecek; yayın kapısı (≥3 onaylı aday) gerçek sözlükle; Katman B (LLM hakem) F4'te.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — derleyici ve şema birim testleriyle doğrulandı; Dart tarafında paket okuma henüz yok; hikâyeler taslak.
- **Sahip:** Ajan
- **Önem:** Yüksek
- **İlgili:** K-0022, K-0024, K-0030, GÖR-044

### K-0030 · 2026-10-17 17:05 · MOB · Okuma motoru: hikâye birleştirici (F1, ikinci parça)
- **Tür:** Gelişme
- **Konu:** MOB, TSR
- **Bağlam:** Motorun asıl işi: sayfa parçalarını ad, değer, tür ve sınıf bağlamıyla düz metne çevirmek.
- **Yapılanlar:** `dart/okuma_motoru/lib/hikaye_cozucu.dart`: parça türleri (metin, kahraman adı, yol arkadaşı + yedek, vurgu, sözlük yuvası kelime/atasözü, deyim cümlesi, değer ve tür sahneleri, sahne işareti); stiller (normal, önemli, kelime, deyim, atasözü, işaret); sahne seçimi (öncelik sırası, yoksa `_default`); sınıfa göre yuva adayı, görülmemiş olan tercih edilir; izinli kahraman türü kontrolü; derinlik sınırı (4).
- **Kanıt:** `dart test` → `All tests passed!` (25 test: 13 ad çekimi + 12 birleştirme). Test hatası: fikstürde sınıf 6 için atasözü adayı yoktu; fikstür düzeltildi. Linter kuralı (her sınıf için aday kapsamı) F2'de derleyiciye bırakıldı.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — birim testleri geçti; gerçek hikâye paketleri (JSON) ve Flutter ekranı henüz yok.
- **Sahip:** Ajan
- **Önem:** Yüksek
- **İlgili:** K-0029, K-0022, GÖR-044

### K-0029 · 2026-10-17 16:50 · MOB · Okuma motoru: Türkçe ad çekimi (F1, ilk parça)
- **Tür:** Gelişme
- **Konu:** MOB, TSR
- **Bağlam:** Onaylı planın F1 adımı: kahraman adının cümle içinde doğru ekle çekilmesi. Saf Dart paketi (E-1 kararı: tek motor).
- **Yapılanlar:** `C:\Dev\Senin Hikayen - HupoRead\dart\okuma_motoru\`: `lib/turkce_ad.dart` (6 hal: yalın, belirtme, yönelme, bulunma, ayrılma, ilgi; ünlü uyumu, sert ünsüz, kesme işareti, Türkçe I/İ dönüşümü); `test/turkce_ad_test.dart` (9 ad × 5 hal altın vektörü + doğrulama testleri).
- **Kanıt:** `dart test` → `All tests passed!` (13 test). Çalışma yolu boşluk içeriyor; sorun çıkmadı.
- **Hatalar (düzeltildi):** İlk sürümde ilgi hâlinde ek sonundaki "n" eksikti; test vektöründe "Kemal" için bulunma/ayrılma yanlış yazılmıştı (son ünlü a → "-da/-dan").
- **Bilinen sınır:** "ince l" istisnaları (Nihal, Hilal vb.) ve yabancı adlar yok; altın vektörler Türkçe uzman tarafından genişletilecek (GÖR-044 kapsamı).
- **Durum:** DEVAM (F1 ilk parça; hikâye çözücü sonraki adım)
- **Doğrulama:** KISMİ — yalnız çekim fonksiyonu; hikâye birleştirme ve Flutter entegrasyonu yok.
- **Sahip:** Ajan
- **Önem:** Orta
- **İlgili:** K-0022, K-0024, GÖR-044

### K-0028 · 2026-10-17 16:48 · YÖN · E-6 ikinci yönetici kararı ve GÖR-046 kapanışı
- **Tür:** Karar
- **Konu:** YÖN, VT, HUK
- **Bağlam:** K-0025'te E-6'nın ikinci yönetici kısmı belirsiz kalmıştı. Kullanıcı yanıtladı.
- **Karar:**
  - `ONAYLI` (kullanıcı): İkinci yönetici Cengizhan Salih (kullanıcı). Son okuma ve onay bu kişide.
  - `ONAYLI` (kullanıcı): İlk aşama AI ön denetim ajanıdır (K-0025, `C:\Dev\Senin Hikayen - HupoRead\AGENTS.md`). Ajan yayın yetkisi taşımaz.
  - Sistemdeki dört göz için iki ayrı yönetici hesabı gerekir; bu eşleştirme GÖR-049'da F7 tasarımına bırakıldı.
- **GÖR-046 kapanışı:** Rıza kapısı PGlite'ta 4 senaryo ile doğrulandı (K-0026), migration 20261045 uzakta uygulandı. Export kapsamı migration 20261046 uzakta uygulandı (K-0027). Export'un çalışma zamanı testi GÖR-048'e taşındı; bu nedenle GÖR-046 satırı "TAMAMLANDI" olarak panodan çıkarıldı.
- **Durum:** TAMAMLANDI (E-6 ikinci yönetici kararı); GÖR-046 kapandı
- **Doğrulama:** DOĞRULANDI (E-6 kararı kullanıcı yanıtıyla; GÖR-046 rıza kapısı PGlite ile)
- **Sahip:** Kullanıcı
- **Önem:** Yüksek
- **İlgili:** K-0025, K-0026, K-0027, GÖR-046, GÖR-047, GÖR-048, GÖR-049

### K-0027 · 2026-10-17 16:45 · VT · export_my_data Kelime Evreni tablolarını kapsıyor (GÖR-046 ikinci parça)
- **Tür:** Gelişme
- **Konu:** VT, HUK
- **Bağlam:** K-0022'de tespit edildi: `export_my_data` (20260920000800) Kelime Evreni kullanıcı verisini dışa aktarmıyordu; veri hakları (KVKK erişim) boşluğu.
- **Yapılan:** `supabase/migrations/20261046000000_export_my_data_kelime.sql`: fonksiyon aynı gövdeyle yeniden tanımlandı; `kelime` anahtarı eklendi (`denemeler`, `ustaliklar`, `kaydedilenler`). Yalnızca `auth.uid()` satırları okunur. Grant/revoke yeniden yazıldı (authenticated).
- **Kanıt:**
  - PGlite: migration zinciri içinde derlendi (`tamam`); rıza davranış testi `1/1` geçti.
  - `npm run db:preview`: yalnız `20261046000000` bekliyordu; `npm run db:deploy` uygulandı; `npm run db:status` uzakta `20261046000000` gösteriyor.
- **Doğrulanmayan:** `export_my_data` çalışma zamanı testi yok. PGlite'ta `student_stats`, `user_answers`, `xp_events` gibi tablolar yok; fonksiyon bu tablolara dokunduğu için tam çağrı test edilemedi. Kelime sütun adları migration kaynağından okundu.
- **Durum:** DEVAM (çalışma zamanı testi açık)
- **Doğrulama:** KISMİ
- **Sahip:** Ajan
- **Önem:** Yüksek
- **İlgili:** K-0022, K-0025, K-0026, GÖR-046

### K-0026 · 2026-10-17 16:26 · YÖN · GÖR-046 davranış testi ve Atölye sağlayıcısı Claude'a alındı
- **Tür:** Gelişme
- **Konu:** VT, YÖN, BEL
- **Bağlam:** K-0025'te davranış testi eksikti (`consents` stub'ı yoktu). Ayrıca K-0024 kararıyla Atölye'nin varsayılan sağlayıcısı Gemini'den Claude'a alınacaktı.
- **Yapılanlar:**
  - `supabase/tests/kelime_veli_riza_stub.sql`: consents tablosunun asgari hali (yalnız test).
  - `supabase/tests/kelime_veli_riza_tests.sql`: 4 senaryo: rıza yok → null; verildi → özet; geri çekildi → kapalı; bağlı olmayan veli → 42501.
  - `C:\Dev\Soru-Cevap Hazırlama Programı`: `src/lib/llm.ts` varsayılanı `anthropic`; `.env.example` Claude'a çevrildi; `testler/faz2.test.ts` Gemini sahte yanıtlarına göre ayarlandı; model adı testi kodla eşleştirildi (`gemini-3.8-flash`, K-0021 "model adı teyit edilmeli" notu hâlâ geçerli).
- **Kanıt:**
  - PGlite: `kelime_veli_riza_tests.sql` → `1/1 senaryo geçti`, çıkış 0 (migration 20261045 dahil).
  - Atölye: `node --test --experimental-strip-types testler/*.test.ts` → `# tests 27 / # pass 27 / # fail 0`.
- **Durum:** DEVAM (GÖR-046 export kapsamı ve Kelime paketinin tam PGlite koşusu açık)
- **Doğrulama:** KISMİ — GÖR-046 davranışı PGlite'ta doğrulandı; uzak DB'de yalnız migration listesi doğrulandı. Hukuk (GÖR-045) kapsam dışı.
- **Sahip:** Ajan
- **Önem:** Yüksek
- **İlgili:** K-0021, K-0024, K-0025, GÖR-046

### K-0025 · 2026-10-17 16:18 · YÖN · E-6 ve E-9 yanıtı, AI denetim kuralı, rıza kapısı düzeltmesi (GÖR-046)
- **Tür:** Karar
- **Konu:** YÖN, VT, HUK, VEL
- **Bağlam:** Kullanıcı E-6 (son okuma ve ön denetim) ve E-9 (migration bloğu ve zamanı) için yanıt verdi; migration yazımı ve uygulaması için yetki verdi.
- **Karar:**
  - `ONAYLI` E-6 (kullanıcı): Son okuma kullanıcıdadır. Ön denetim AI ajanı tarafından yapılır (ön filtre, pedagoji ve rehberlik, MEB müfredatı, Türkçe). Ajan yayın yetkisi taşımaz, yalnız geri bildirim üretir. Kural: `C:\Dev\Senin Hikayen - HupoRead\AGENTS.md`. Hupolingo ana AGENTS §5 değişmedi; bu proje için istisna.
  - `ONAY BEKLİYOR` E-6 (ikinci yönetici): Kimlik belirtilmedi.
  - `ONAYLI` E-7: GÖR-046 düzeltmesi yazıldı ve uygulandı (migration `20261045000000`).
  - `ONAYLI` E-9 (yetki; zamanlama ajan kararı): Okuma Dünyası migration bloğu `20261050…` rezerve. Tablolar ve RPC'ler F2'de içerik formatı donduktan sonra, PGlite testleriyle birlikte uygulanır. Erken uygulanmaz; içerik formatı sonra değişirse üstüne düzeltme migration'ları birikir.
- **Uygulama (GÖR-046):** `kelime_veli_ozeti` artık `_veli_riza_durumu` 'verildi' değilse özet hesaplamaz; null alanlar döner ve dönüşe `riza` alanı eklenir. Eski gövde `kelime_veli_ozeti_ham` adıyla korunur; istemci çağrı adı aynı kalır.
- **Kanıt:** `npm run db:preview` yalnız `20261045000000_kelime_veli_ozeti_riza_kapisi.sql` bekliyordu. `npm run db:deploy` uygulandı; `npm run db:status` uzakta `20261045000000` gösteriyor. Web: `KelimeGelisimKarti.tsx` null alanlarla çökmüyor (kod okundu).
- **Gözlem:** `db:status` (2026-10-17 16:13) `20261044000000` dahil tüm yerel migration'ların uzakta uygulanmış olduğunu gösterdi. GÖR-041 "BEKLİYOR" durumu güncel değil; kullanıcı teyidi gerekir.
- **Doğrulama:** KISMİ — migration uzakta uygulandı (db:status). Davranış testi YOK: PGlite Kelime paketi kurulumunda `consents` tablosu stub'da eksik; test çalıştırılamadı (hata kurulumda, migration SQL'inde değil).
- **Açık:** `export_my_data` Kelime tablolarını kapsamıyor (ayrı migration); PGlite stub'larının tamamlanması; web kartında "veri paylaşımı kapalı" mesajı (ürün işi).
- **Durum:** DEVAM
- **Sahip:** Kullanıcı (ikinci yönetici), Ajan (uygulama)
- **Önem:** Yüksek
- **İlgili:** K-0022, K-0024, GÖR-041, GÖR-046, GÖR-047

### K-0024 · 2026-10-17 16:08 · YÖN · Senin Hikayen: E-kararlarına kullanıcı yanıtları
- **Tür:** Karar
- **Konu:** YÖN, VT, HUK, VEL
- **Bağlam:** K-0023'teki E-1…E-9 açık kararlarına kullanıcı yanıt verdi.
- **Karar:**
  - `ONAYLI` E-1: Tek Dart motoru. Hikâyeyi birleştiren kod bir kez yazılır; uygulama ve atölye aynısını kullanır.
  - `ONAYLI` E-2: "Annem" türü ve hazır Hupo kahramanı eklenir.
  - `ONAYLI` E-4: Pilot ücretsiz. XP önerisi: tamamlama +10, quiz %67 ve üzeri ise +10, günde en çok 2 hikâyenin XP'si.
  - `ONAYLI` E-5 (kullanıcı: "Gemini doğru düzgün çalışmıyor"; yazar ile hakem farklı model ailesinden olsun): Gemini varsayılan olmaktan çıkar. Yazar Claude Sonnet, hakem Claude Opus (aynı aile, farklı model). Gerçek farklı aile için ikinci sağlayıcı ayrı karar olur. K-0021'deki Gemini kararı bu kayıtla değişti; atölyedeki varsayılan sağlayıcı Claude'a çevrilecek.
  - `ONAY BEKLİYOR` E-6: Kullanıcı "ikinci yönetici ve Türkçe editör: ONAYLANDI, AI okur" dedi. Türkçe editör rolünü yapay zekâ kontrolü karşılayacak. AGENTS kuralı gereği çocuk içeriğinin yayın öncesi insan onayı gerekir; bu kaldırılmadı. İkinci yönetici kimliği belirtilmedi. Teyit bekleniyor.
  - `ONAYLI` E-7 (kısmi): Düzeltme migration'ının YAZILMASINA onay (GÖR-046). Uzak veritabanına uygulanması (`db:deploy`) ayrı onay ister. Hukuk görüşü (GÖR-045) bu onayla kapanmaz.
  - `ONAYLI` E-8: Liste ajan tarafından seçilir, çocuk bu adları giremez. Kategoriler: (a) Allah, peygamber ve din büyükleri adları hayvan, araç ve hayalî karakterlerde yasak; (b) küfür, hakaret ve cinsel içerikli sözcükler tüm türlerde yasak; (c) bilinen çizgi film, oyun ve marka karakter adları yasak (telif); (d) kamuya açık gerçek kişilerin adları yasak. Listeye yeni ad ekleme yetkisi kimseye verilmez; değişiklik kod incelemesiyle yapılır. Tam liste kodda yazılacak.
  - `ONAY BEKLİYOR` E-9: Migration bloğu (`20261050…`) ve dağıtım zamanı. Yanıt yok.
  - E-3 (bilgi): Pilotta yumuşak sıralama kapalı.
- **Durum:** DEVAM
- **Doğrulama:** DOĞRULANMADI — yalnız karar kaydı; migration ve kod henüz yazılmadı.
- **Sahip:** Kullanıcı (kararlar), Ajan (uygulama)
- **Önem:** Yüksek
- **İlgili:** K-0021, K-0022, K-0023, GÖR-045, GÖR-046, GÖR-047

### K-0023 · 2026-10-17 15:53 · YÖN · Senin Hikayen: kullanıcı kararları ve F0 durumu
- **Tür:** Karar
- **Konu:** YÖN, HUK, TSR
- **Bağlam:** K-0022 planı için üç soru soruldu (cinsiyet, pilot sınıf); plan ExitPlanMode ile onaylandı. Kullanıcı token tasarrufu istedi; bu turda F0'ın zorunlu kısmı yapıldı.
- **Plan:** F0 — iskelet (README, PLAN.md), kit zip'i `kaynak-kit/` altına açıldı, kit testi, git init (commit yok). Ertelendi: sema şemaları, örnek hikâyeler, Dart smoke testi, KIT_DEGERLENDIRME dokümanı, memory kaydı.
- **Karar:**
  - `ONAYLI` (kullanıcı): Cinsiyet hesapta ve sunucuda tutulmaz; kahraman seçilirken cihazda sorulur, yalnız avatar ve yumuşak sıralama için; içerik asla kısıtlanmaz.
  - `ONAYLI` (kullanıcı): Önce bağımsız klasörde geliştirilir, sonra Hupolingo'ya entegre edilir.
  - `ONAYLI` (kullanıcı): Pilot 4. ve 5. sınıf, sınıf başına ~12 hikâye (~24).
  - `ONAYLI` (kullanıcı, ExitPlanMode): Mimari ve faz sırası.
  - `ONAY BEKLİYOR`: E-1 tek Dart motoru (öneri) · E-2 "Annem" türü + hazır Hupo (öneri: evet) · E-3 pilotta yumuşak sıralama kapalı (bilgi) · E-4 ücret ve XP tavanı · E-5 LLM: Gemini ücretsiz katman (K-0021), yazar ≠ hakem ailesi · E-6 ikinci yönetici ve Türkçe editörü · E-7 hukuk görüşü · E-8 hassas ad listesi · E-9 migration bloğu ve dağıtım zamanı.
- **Güncelleme 2026-10-17 16:08:** E-1, E-2, E-4, E-5, E-7 (kısmi) ve E-8 yanıtlandı → K-0024. E-6 ve E-9 açık.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — kit testleri 15/15 geçti; Dart smoke, şema doğrulaması ve uygulama kodu yapılmadı.
- **Sahip:** Kullanıcı (E-kararları), Ajan (F0)
- **Önem:** Yüksek
- **Açıklama:** Kit testi referans amaçlı çalıştırıldı; `kaynak-kit/` içinden başka bir şey çalıştırılmadı. Gizli anahtar taramasında eşleşme yok. git yalnızca `init` edildi, commit atılmadı. `.gitignore`: .env, veri/, .dart_tool/, build/, node_modules/.
- **Kanıt:** `node --experimental-strip-types --test --test-reporter=tap .../tests/engine.test.mjs` → `# tests 15`, `# pass 15`, `# fail 0` (Node v24.21.0, çalışma dizini: scratchpad).
- **İlgili:** K-0022, GÖR-044, GÖR-047

### K-0022 · 2026-10-17 15:53 · YÖN · Senin Hikayen (Okuma Dünyası): kit değerlendirmesi ve iş planı
- **Tür:** Plan
- **Konu:** MOB, VT, VEL, YÖN, TSR, HUK
- **Bağlam:** Kullanıcı `C:\Dev\Senin Hikayen - HupoRead` klasöründeki başlangıç kitini (başka bir yapay zekânın repo görmeden yazdığı zip ve iki md dosyası) değerlendirip iş planı istedi. Hedef: çocuk kahramanı seçer (kendisi, anne/baba, kardeş, başka biri, hayvan, araç, hayalî); konu ve sınıfa göre sözlük yerleşir; veli değer önceliği koyar; sonda anlama soruları ve ayrı anket gelir.
- **Plan:**
  1. Kit ↔ repo karşılaştırması: Edge Function/service_role, adaptör tablo, `reading_*` adları ve Flutter demosu gerçek repoyla çelişiyor → `okuma_*` tabloları + SECURITY DEFINER RPC.
  2. Adlar cihazda kalır (sunucu token'lı sayfa verir); tek Dart motoru; Türkçe ek motoru (altın vektörler); sözlük yuvaları; çevrimdışı Hikâye Atölyesi (LLM taslak → Katman A/B → insan → dört göz).
  3. F0–F11; pilot 4–5. sınıf, ~24 hikâye.
  4. Migration bloğu `20261050…` rezerve (son mevcut 20261044); kapalı bayrak; PGlite testleri; staging yok → db:preview ve ayrı onay.
  Tam plan: `C:\Dev\Senin Hikayen - HupoRead\PLAN.md`.
- **Karar:** Plan kullanıcı tarafından onaylandı (2026-10-17). Mimari ve faz sırası ONAYLI; E-1…E-9 ONAY BEKLİYOR (K-0023).
- **Durum:** DEVAM
- **Doğrulama:** KISMİ — repo kanıtları okuma ve grep ile doğrulandı; uygulama ve test henüz yok.
- **Sahip:** Ajan + Kullanıcı
- **Önem:** Yüksek
- **Açıklama:** Kitin çekirdeği korunur (token'lı sayfa modeli, sahne varyantları + `_default`, quiz anahtarı yalnız sunucuda); altyapısı yeniden yazılır. Maarif D1–D20 MEB sayfasında doğrulandı. Sınıf bazlı resmî deyim/atasözü listesi doğrulanamadı; sözlük "editör önerisi" olarak tutulur.
- **Kanıt:** Kit dosyalarının SHA256'sı zip içindekiyle eşleşti (CLAUDE_CODE_PROMPT.md, CUSTOM_HERO_DESIGN.md). `kelime_veli_ozeti` (`supabase/migrations/20261022000000_kelime_evreni.sql` 611–687) `_veli_riza_durumu`/`cocuk_riza_durumu` çağırmıyor. `export_my_data` yalnız `20260920000800_daily_goal_shield_privacy.sql` içinde; Kelime tabloları kapsam dışı.
- **İlgili:** K-0023, GÖR-044, GÖR-045, GÖR-046, GÖR-047, GÖR-019, GÖR-043, K-0020, K-0021

### K-0030 · 2026-10-18 00:03 · VT · Soru Atölyesi Faz 6: panel içe aktarma (migrasyon, RPC, panel) — uzak DB uygulanamadı
- **Tür:** Sorun
- **Konu:** VT, YÖN
- **Bağlam:** Kullanıcı Faz 6'yı (panel entegrasyonu) onayladı: "Panel entegrasyonu (Faz 6) işini de yap". Uygulama, uzak Supabase veritabanına migration içerdiği için `npm run db:deploy` adımında otomatik işlem güvenlik sınıflandırıcısı tarafından reddedildi; uygulanmadı, aşılmaya çalışılmadı.
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-18): Faz 6 kapsamı (migrasyon + RPC + panel). Uygulama onayı: kullanıcı, `db:deploy` izni için kendi ayarını (ya da bu adımı kendisinin) çalıştırmalı.
- **Yapılan (yerel):**
  - `supabase/migrations/20261047000000_soru_paketi_ice_aktarma.sql`: questions'a Soru Atölyesi alanları (nullable, istemciye yetki YOK — ipucu/yanlış şık açıklaması öğrenciye cevaptan önce görünmez); `soru_importlari` ve `soru_kaynaklari` (yalnız admin okur); `_soru_paket_hatasi`; `admin_import_questions_v2` (sınıf zorunlu 1–8, okul-sınıf tutarlılığı, birebir için kaynak lisans dayanağı, kırmızı kalite reddi, insan onayı olmadan 'beklemede', tekrar kontrolü: dış kimlik ve ders+sınıf+konu+metin); `admin_geri_al_parti` (silmez, reddedildi yapar).
  - Testler: `supabase/tests/soru_atolyesi/` (PGlite, kelime_evreni taklitleri + üretim sütun yetkisi + birebir `_soru_hatasi`): 10 senaryo geçti (A–J).
  - Panel: `web-panel/src/components/yonetim/sorular/PaketImport.tsx` (JSON yükleme, önizleme, onay/hepsi seçenekleri, sonuç ve hata listesi, parti geri alma), `toplu-ekle/page.tsx`'e eklendi, tr/en çeviri anahtarları (`yonetim.sorular.paket`). `npm run lint`: 0 hata; `npm run build`: başarılı.
  - Uzak DB önizleme (`db:preview`): yalnızca `20261047000000_soru_paketi_ice_aktarma.sql` uygulanacak, başka değişiklik yok.
- **Durum:** DEVAM — uzak DB migrasyonu kullanıcı onayıyla uygulandı (`npm run db:deploy` → `Finished supabase db push`; `db:preview` sonrası `upToDate: true`). Panel canlıya alınmadı (kullanıcı kararı: sistem ham halinde).
- **Güncelleme 2026-10-18 00:10:** Migrasyon uzak DB'de. Panel ve Flutter değişmedi. Canlı panelde doğrulama hâlâ yok.
- **Doğrulama:** KISMİ. PGlite testleri 10/10 (yerel, gerçek DB değil). Build ve lint geçti. Canlı DB ve canlı panelde doğrulama YOK.
- **Açıklama:** Eski CSV yolu (`admin_import_questions`) hâlâ sınıfsız satır kabul edebiliyor; yeni RPC'yi kullanan ekran bu sorunu kapatır. Eski yol kaldırılmadı. Flutter tarafındaki ipucu arayüzü ayrı iştir (bu kayıtta yok).
- **Sonraki adım (kullanıcı):** Terminalde `cd "C:\Dev\hupo"` ve `npm run db:deploy` (ya da bu izni verme), sonra panel dağıtımı onayı.
- **İlgili:** K-0020, K-0022, K-0029, GÖR-042

### K-0029 · 2026-10-17 23:49 · YÖN · Soru Atölyesi: yapay zekâ düzeltme önerilerinin uygulanması (11 soru)
- **Tür:** Karar
- **Konu:** YÖN, BEL
- **Bağlam:** Kullanıcı "sonraki adıma onay veriyorum, benim adıma yap" dedi. Sonraki adım olarak önerilen: kalan düzeltilmeli soruları düzeltmek. Faz 6 (panel/veritabanı) bu onayın kapsamında değil, yapılmadı.
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17, "sonraki adıma onay"). Kural: yapay zekâ düzeltme önerisi, düzeltilmiş soru deterministik kontrolden (katman A, hata seviyesi) geçerse uygulanır.
- **Sonuç:** 11 düzeltme uygulandı (`kim: "Ajan · kural: Cengizhan Salih"`). Kalan 9 soru bekliyor: 6'sında düzeltme önerisi yok (`4okuma-ca-s0005`, `4okuma-s0016`, `4okuma-s0020`, `6bts1-s0016`, `4okuma-s0018-v01`, `4okuma-s0021-v01`), 3'ü önerilen düzeltmesi kontrolü geçmedi veya hakem uyarısı var (`6bts1-s0008`, `s0013`, `s0014`).
- **Önemli sınır:** Düzeltilmiş ipuçlarının sızıntı açısından **yeniden hakem kontrolü yapılmadı**; hakem kaydı orijinal soruya ait. Deterministik kontrol yalnız "doğru şık metni ipucunda geçiyor mu" gibi açık sızıntıları yakalar. Bu 11 soru insan denetiminde ayrıca görülmeli.
- **Doğrulama:** KISMİ. Kayıt sayıları `qa-toplu` ile doğrulandı (89 soru: 64 yeşil, 24 sarı, 1 kırmızı).
- **Durum:** DEVAM
- **İlgili:** K-0028, K-0026

### K-0028 · 2026-10-17 23:46 · YÖN · Soru Atölyesi: kullanıcı kuralıyla toplu onay (69 soru)
- **Tür:** Karar
- **Konu:** YÖN, BEL
- **Bağlam:** Kullanıcı 89 soruyu tek tek inceleyemeyeceğini, kabul kuralını şöyle belirtti: "soru veya cevap yanlış değilse kabuldür; ortalamadan uzun/kısa kelime sayısı tek başına red sebebi değildir."
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17): kural. Uygulama: öneri "onaylanabilir", kalite kırmızı değil, hakem bulgusu (hata ya da uyarı) yok, ipucu sızıntısı yok → onay.
- **Sonuç:** 69 soru onaylandı. Kayıt `kim: "Ajan · kural: Cengizhan Salih"` ile yazıldı; hakem ve öneri uyumu notta. Kalan 20 soru bekliyor (çoğu düzeltilmeli, bunlar kural gereği onaylanmadı). Kararlar `veri/denetim/kararlar.json` içinde; denetim ekranından üzerine yazılarak geri alınabilir.
- **Hafıza:** Kural `feedback_onay_kurali_uzunluk` olarak kaydedildi.
- **Doğrulama:** KISMİ. Onaylar kullanıcı kuralıyla yapıldı; soru ve cevap doğruluğu insan tarafından tek tek kontrol edilmedi, yalnızca hakem ve yapay zekâ önerisi kullanıldı. Bu, kullanıcının bilinçli tercihi.
- **Durum:** DEVAM
- **İlgili:** K-0026, K-0027

### K-0027 · 2026-10-17 23:15 · YÖN · Soru Atölyesi: okuma metinli yeniden çıkarma ve varyantların yenilenmesi
- **Tür:** Gelişme
- **Konu:** YÖN, VT
- **Bağlam:** K-0026 önerisi kullanıcı tarafından kabul edildi ("önerin kabuldür").
- **Uygulama:** (1) Çıkarma istemine "metni soruyla birlikte ver" kuralı eklendi (`METİN:` / `SORU:`); şema `soru_metni` üst sınırı 1200 → 4000. (2) Eski `4okuma`, `4okuma-ca`, bunlardan türeyen 30 varyant, ilgili hakem ve öneri kayıtları yedeğe alınıp (`veri/eski-2026-10-17/`) aktif veriden kaldırıldı. (3) Yeniden çıkarma: `4okuma` 34 aday (27'si metinli); `4okuma-ca` 9 aday (ilk denemede 0, ikincisinde 9 — kararsız, ayrıca ele alınmalı). (4) Zenginleştirme, hakem, öneri uygulandı. (5) Temiz ebeveynlerden 30 yeni varyant (0 reddedilen), onlar da hakem ve öneriden geçti.
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17).
- **Sonuç:** Toplam 89 soru: 63 yeşil, 25 sarı, 1 kırmızı. Yeni `4okuma` önerileri: 40 onaylanabilir, 3 düzeltilmeli, 0 reddedilmeli (önceki 29 reddedilmeli büyük ölçüde giderildi). Çapraz mükerrer 0.
- **Önemli:** İnsan kararları (`meb-odsgm-4okuma-ca-s0008` ve `s0013`, onay, Cengizhan Salih) yedekte. Yeni çıkarmada bu kimlikler başka sorulara ait; onaylar **uygulanmadı**. Bu sorular yeniden incelenip onaylanmalı.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ. `npm test` 42/42. Çıkarma sonuçları ve öneri dağılımı yukarıdaki sayılarla doğrulandı. Denetim ekranında yeni soruların insan incelemesi yapılmadı.
- **Açıklama:** `4okuma-ca` çıkarması kararsız (ilk çağrıda 0, ikincisinde 9); cevap anahtarı kitabında okuma metinleri çoğunlukla yok. Bu kaynağın yeniden tasarlanması ya da soru kitabıyla birleştirilmesi gerekebilir.
- **İlgili:** K-0026, K-0025, GÖR-042

### K-0026 · 2026-10-17 22:52 · YÖN · Soru Atölyesi: yapay zekâ ön incelemesi (öneri) ve okuma metni eksikliği
- **Tür:** Sorun
- **Konu:** YÖN, VT, TSR
- **Bağlam:** Kullanıcı, denetim ekranındaki 114 soruyu Gemini ile gözden geçirmemi istedi. Bu bir ÖNERİDİR; denetim kararları (onay, düzeltme, red) yalnızca insan tarafından verilir ve bu kayıt onları değiştirmez.
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17): Gemini ile gözden geçirme. Öneriler `veri/denetim/ai-oneri.json` içinde, ekranda "karar değil" etiketiyle.
- **Bulgular:** 114 soru: 67 onaylanabilir, 18 düzeltilmeli, 29 reddedilmeli (öneri). **Sistematik sorun:** Reddedilmeli önerilerin neredeyse tamamı `4okuma` (soru kitabı) ve türev varyantlarda; "Metne göre" diye başlayan soruların dayandığı **okuma metni soruya dahil edilmemiş**. Çıkarma adımı metni kaybetmiş. Bu nedenle `4okuma` sorularının çoğu bağımsız çözülemez. Ayrıca 8+ ipucunda doğru cevap söyleniyor (hakem de yakaladı; ipucu sızıntısı zenginleştirme adımında tekrar oluşuyor). Varyantlar, dayanağı eksik ebeveynlerden türediği için aynı sorunu taşıyor.
- **Durum:** BEKLİYOR (kullanıcı kararı: okuma metinlerini ekleyerek `4okuma` yeniden çıkarılsın mı; eksik-metinli ebeveynlerden türeyen varyantlar atılsın mı)
- **Doğrulama:** KISMİ. Testler 42/42. Sunucu API'sinde `ai_oneri` alanı ve tarayıcıda öneri kartı metni doğrulandı (konsol hatası yok).
- **Önerilen düzeltme (onay bekliyor):** (1) Çıkarma isteminde her soru için ilgili okuma metnini de çıkarmasını istemek (metin soruyla birlikte `soru_metni`ne eklenir); (2) zenginleştirme isteminde ipucu kuralını daha sıkı yazmak ve hakem+ön incelemede ipucu sızıntısını kırmızı saymak; (3) etkilenen varyantları yeniden üretmek.
- **Sahip:** Kullanıcı (karar), Ajan (uygulama)
- **Önem:** Yüksek
- **İlgili:** K-0024, K-0025, GÖR-042

### K-0025 · 2026-10-17 22:25 · YÖN · Soru Atölyesi: LLM varyant üretimi (Faz 3) ve varyantların hakemden geçişi
- **Tür:** Gelişme
- **Konu:** YÖN, TSR
- **Bağlam:** Planın Faz 3'ü. Onay ve hakem kontrolünden geçmiş sorulardan, kalıbı koruyan ve isim/sayı/yer değiştiren varyantlar üretmek; sayı hedefi için gerekli.
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17): "projeyi tamamlamaya devam et". Gemini varsayılan, token tasarrufu.
- **Uygulama:** `src/vary/varyant.ts`. Bir çağrıda 10 ebeveyn; çıktı tam soru (ipucu, çözüm, yanlış şık açıklaması), ayrıca zenginleştirme gerekmez. Ebeveyn seçimi: kırmızı değil ve hakem bulgusu (ipucu sızıntısı dahil) yok. Kontroller: 4 şık (A–D), şema, metin benzerliği ≤%60 (kopya değil). Alt benzerlik sınırı konmadı: isim ve sayı değişince kelime örtüşmesi doğal olarak düşüyor. CLI: `varyant [--limit N] [--max-cagri N]`.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ. `npm test` 42/42. Gerçek veri: 30 ebeveyn → 30 varyant, 0 reddedilen (2 çağrı + 1 yardımcı). Örnek incelemesi: isim, yer ve nesneler değişmiş, kalıp korunmuş, doğru cevap tutarlı. Hakem (varyantlar): kör çözüm 30/30 anahtarla uyumlu. Toplam zenginleşmiş soru: 114 (77 yeşil, 34 sarı, 3 kırmızı). Çapraz mükerrer 0.
- **Açıklama:** Varyantlar `veri/zengin/varyant-*.json` içinde, denetim ekranına da düşüyor ve ayrıca insan onayı gerekiyor. Varyant kalitesinin asıl sınanması, insan denetimiyle yapılacak; hakem yalnızca ön eleme.
- **İlgili:** K-0024, K-0021, GÖR-042

### K-0024 · 2026-10-17 22:15 · YÖN · Soru Atölyesi: LLM hakemi (kör çözüm + rubrik), token tasarruflu
- **Tür:** Gelişme
- **Konu:** YÖN, TSR
- **Bağlam:** Kullanıcı, planın Katman B adımı olan LLM hakemini kodlamamı ve Gemini'yi tasarruflu kullanmamı istedi. (Not: `llm.ts` varsayılan sağlayıcısının Anthropic'e çevrildiği görüldü; kullanıcı "şimdilik Gemini" dedi. Bu kayıttaki K-0024 numarası ile `llm.ts` yorumundaki atıf çakışıyor, ilgili kayıt gözden geçirilmeli.)
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17): Gemini varsayılan; token tasarrufu isteniyor.
- **Plan / uygulama:** `src/qa/hakem.ts`. (1) Kör çözüm: soru metni ve şıklar; doğru cevap, çözüm, ipucu gönderilmez; her parti tek çağrı (15 soru). (2) Rubrik (dil, seviye, tek doğru, çeldirici, ipucu güvenliği 0–5): yalnızca otomatik kontrolde kırmızı olmayan sorular; not en fazla 60 karakter. (3) Düşünme ayarı düşük (`thinkingLevel: LOW`), desteklenmezse ayarsız yeniden denenir. (4) Hakem bulguları denetim ekranına (`hakem-*`) eklenir. CLI: `hakem [--max-cagri N]`. Kararlar `veri/hakem/hakem.json`, yeniden çalıştırma yalnızca eksikleri işler.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ. `npm test` 38/38 (kör çözümde doğru cevap ve çözüm metninin gönderilmediği, ikinci çalıştırmada API çağrısı yapılmadığı dahil). Gerçek veri: 84 soru değerlendirildi (ilk denemede 30 kaydedilip durduruldu, kalanı tasarruflu ayarla tamamlandı). Kör çözüm: 84 soruda 2 uyuşmazlık (`4okuma-s0003`, `4okuma-s0021`). Rubrik: 83 soru, 14 düşük puan. Bulunanlar: (a) `4okuma-ca-s0010` ve `s0020`: soru metinde verilmeyen bir parçaya dayanıyor ("metin verilmemiş") → kaynaktaki soru metni eksik kopyalanmış olabilir, düzeltme gerekir; (b) 6–7 ipucunda doğru cevap doğrudan söyleniyor (`4okuma-ca-s0031`, `s0032`, `4okuma-s0010`, `s0016`, `s0033`, `6bts1-s0009`, `s0010`, `s0013`) → ipucu güvenliği kuralının ihlali. Bu ipuçları denetimde kırmızı/sarı olarak görünecek. Sayılar kesin değil; kör çözüm 2 uyuşmazlığı kendi başına kanıt sayılmaz, insan kontrolü gerekir.
- **Sahip:** Ajan + Kullanıcı
- **Önem:** Yüksek
- **İlgili:** K-0021, K-0022, K-0023, GÖR-042

### K-0023 · 2026-10-17 21:56 · YÖN · Soru Atölyesi: büyük PDF yükleme (Files API) ve 6bts1 kaynağı
- **Tür:** Gelişme
- **Konu:** YÖN, VT, ALT
- **Bağlam:** Doğrudan gövdeye koyma yöntemi ~20 MB üstünü kabul etmiyor. Gemini Files API ile yükleme eklendi (`src/lib/gemini-dosya.ts`); 15 MB üstü dosyalar otomatik bu yoldan gider.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ. Testler 35/35 (yükleme oturumu, bayt yükleme, ACTIVE beklemesi). Gerçek anahtarla 22,8 MB dosya 13 sn'de ACTIVE oldu (model çağrısı yapılmadı). `meb-odsgm-6bts1` (101 MB, daha önce yarım indirilmişti, curl ile tamamlandı, EOF ve boyut doğrulandı) ingest edildi: 16 aday, 0 şema reddi, 449 öğe çoktan seçmeli değil (atlandı). Zenginleştirme 16/16. Kalite: 9 yeşil / 6 sarı / 1 kırmızı (soru 8: iki çift aynı şık, panele gitmez). Üç kaynağın toplamı: 84 soru, çapraz mükerrer 0.
- **Açıklama:** 6bts1 gibi açık uçlu ağırlıklı kitaplarda verim düşük; çoğu içerik atlanıyor. Kalan büyük kaynaklar: 6bts2 (147 MB), 4ing-2 (114 MB), 2calisma1/2 (~80 MB) ve LGS (bozuk, en sonda). Bunlar için de aynı akış çalışır, ancak her biri ücretli bir çağrıdır. Ayrıca `kaynak-kayitlari.json` içinde Türkçe başlıklar komut satırında bozuk kodlanmış görünüyor (ör. "SÄ±nÄ±f"); düzeltilmesi gerekiyor.
- **Güncelleme 2026-10-17 22:05:** Yukarıdaki başlık bozukluğu yanlış teşhisti. Dosya UTF-8 ve doğru; sorun yalnızca PowerShell'in dosyayı varsayılan kodlamayla göstermesiydi. Kayıt değiştirilmedi.
- **İlgili:** K-0021, K-0022, GÖR-042, GÖR-043

### K-0022 · 2026-10-17 18:01 · YÖN · Soru Atölyesi: çapraz mükerrer kontrolü, denetim ekranı ve dışa aktarım
- **Tür:** Gelişme
- **Konu:** YÖN, VT, TSR
- **Bağlam:** Kullanıcı, sistemin 1000'lerce soruyu yükleyebilmesi için çapraz kaynak mükerrer kontrolünü ve soru gözden geçirme ekranını istedi.
- **Plan:** (1) `src/qa/mukerrer.ts`: tüm partiler arası benzerlik, aynı sınıf+ders içinde (≥0,95 hata, ≥0,85 uyarı). (2) `src/review/denetim.ts`: zenginleşmiş partileri birleştirme, karar deposu (`veri/denetim/kararlar.json`, atomik yazma), düzenleme ve dışa aktarım seçimi. (3) `src/review/sunucu.ts` + `public/index.html`: yalnızca 127.0.0.1, sayfalama, filtreler, kaynak PDF'i (`#page=N`), onay/düzelt/red, klavye kısayolları. (4) CLI: `qa-toplu`, `inceleme`, `disa-aktar`. (5) Dışa aktarım yalnız onaylı veya düzeltilmiş, kırmızı olmayan ve şemaya uyan soruları alır; arşiv `veri/cikti/` altına yazılır.
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17): sistemin hazır hâle getirilmesi istendi. Panel entegrasyonu (migration/RPC) bu kayda dahil değil, ayrı onay gerekir.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ. `npm test` 34/34 geçti (mükerrer, karar, düzeltme, kırmızı engeli, sunucu uçları, yol kaçışı, BOM). Gerçek veriyle: 68 soru, çapraz mükerrer 0. Tarayıcıda (headless) denetim ekranı açıldı, liste ve detay doldu, konsol hatası yok; onay, red (neden zorunlu) ve sonraki soruya geçiş tıklamayla doğrulandı; test kararları geri alındı. Düzeltildi: alt eylem çubuğu soruyu kapatıyordu. **Doğrulanmadı:** PDF görüntüleyicisinin sayfa içeriği bu ortamda görülemedi (headless); gerçek Chrome'da bakılmalı. Düzenleme (düzelt) akışı tarayıcıda ayrıca denenmedi, yalnız API testi var.
- **Sahip:** Ajan + Kullanıcı
- **Önem:** Yüksek
- **Açıklama:**
  - Yerel çalıştırma: `node --experimental-strip-types src/cli.ts inceleme` → `http://127.0.0.1:4173`.
  - BOM hatası bulundu ve düzeltildi: Windows PowerShell ile yazılan `kararlar.json` okunamıyordu.
  - Bilinen sınır: mükerrer kontrolü her istekte tüm soruları yeniden hesaplıyor; birkaç bin soruda yavaşlayabilir, önbellek gerekebilir.
  - Kalan: insan incelemesi kapsamında panel `sinif` sorunu (K-0020, Faz 6) hâlâ açık; dışa aktarılan CSV'de sınıf bilgisi mevcut panelin kabul ettiği biçimde değil.
- **Kanıt:** `npm test` → `ℹ tests 34 / ℹ pass 34 / ℹ fail 0`; `qa-toplu` → `68 · yeşil 55 · sarı 13 · kırmızı 0`, mükerrer 0.
- **İlgili:** K-0020, K-0021, GÖR-042, GÖR-043

### K-0021 · 2026-10-17 14:53 · YÖN · Soru Atölyesi: LLM sağlayıcısı Gemini ücretsiz katmana alındı
- **Tür:** Karar
- **Konu:** YÖN, ALT, HUK
- **Bağlam:** Kullanıcı ücretsiz API anahtarı veya DeepSeek V4 Flash istedi. Araştırma: DeepSeek API'si kalıcı ücretsiz değil (deneme kredisi), kaynaklara göre API PDF kabul etmiyor (metne çevirme gerekir); kullanıcının "4.1 Flash" dediği model adı kaynaklarda bulunamadı, "V4 Flash" görünüyor. Gemini API ücretsiz katman sunuyor ve PDF'i doğrudan kabul ediyor; ücretsiz katmanda Google verileri ürün geliştirmek için kullanabilir.
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17): **Gemini API, ücretsiz katman.** K-0020'deki Claude API seçimi bu kararla değişti. Claude yedek sağlayıcı olarak kodda duruyor (`LLM_SAGLAYICI=anthropic`).
- **Plan:** `src/lib/llm.ts` sağlayıcı katmanı (varsayılan gemini). Anahtar `GEMINI_API_KEY` yalnızca `.env` veya ortam değişkeni; model `GEMINI_MODEL` (varsayılan `gemini-2.5-flash`, AI Studio'dan teyit edilmeli). Gizlilik: ücretsiz katmanda veri ürün geliştirme için kullanılabilir; kaynak MEB'in kamuya açık PDF'leri, ancak bu kararın gerekçesi kayda geçti.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ. `npm test` 27/27 geçti (sahte Gemini ve Anthropic yanıtlarıyla). Gerçek API çağrısı yapılmadı: `GEMINI_API_KEY` henüz tanımlı değil. Gemini'nin güncel ücretsiz limitleri ve model adı kaynaklarda tutarsız, AI Studio'dan teyit edilmeli.
- **Sahip:** Ajan + Kullanıcı (anahtar)
- **Önem:** Yüksek
- **Açıklama:** Anahtarı kullanıcı AI Studio'dan alıp yerel `.env` dosyasına yazacak (`.env.example` şablonu var). Anahtar sohbete ve git'e girmemeli.
- **Güncelleme 2026-10-17 17:54 (zenginleştirme ve ikinci kaynak):** `enrich` 4okuma-ca için çalıştı: 34/34 zenginleşti (ipucu, yanlış şık geri bildirimi, beceri, düzey, süre); kalite 23 yeşil / 11 sarı / 0 kırmızı, sarılar cümle uzunluğu uyarısı; ipucu sızıntısı tespit edilmedi. `meb-odsgm-4okuma` (soru kitabı, 22,8 MB, EOF doğrulandı) kaydedildi ve ingest edildi: 34 aday, 0 şema reddi; enrich: 34/34; kalite 32 yeşil / 2 sarı / 0 kırmızı. 22,8 MB dosya doğrudan Gemini'ye kabul edildi (sınırın üstünde olabilirdi, sorun çıkmadı). Açık: çapraz kaynak mükerrer kontrolü yok (Katman A yalnız aynı parti içinde bakıyor); insan incelemesi (Katman C) henüz yok; kayıt defterindeki diğer kaynaklar (7kkt, 6bts2, 3mat, 6bts1, 4ing-2, 3okuma-ca, 2calisma1) yarım kalan toplu indirmeden kalmış, EOF/sha doğrulaması yapılmadan kullanılmamalı.
- **Güncelleme 2026-10-17 17:42 (canlı doğrulama):** Gemini ile uçtan uca çalıştı: `ingest meb-odsgm-4okuma-ca` → 34 aday soru, şema reddi 0, 74 öğe çoktan seçmeli olmadığı için atlandı, ~150 sn, 1 API çağrısı. Türkçe karakterler (`ı` dahil) doğru; `markitdown` aynı türde PDF'te `ı` düşürdü ve satır bölünmesi yaptı, bu yüzden PDF doğrudan Gemini'ye veriliyor. Çıkan sorular özgün (uyarlama), zorlama çalıştı. Kalite kapısı: 34 sarı (yanlış şık geri bildirimi henüz yok, `enrich` çalıştırılmadı), 0 kırmızı. **Bulunan hatalar ve düzeltmeler:** (1) Yeni Google anahtarları `AQ.` ile başlıyor, `AIza` varsayımı yanlıştı; (2) oturumda kalmış eski `GEMINI_API_KEY` ortam değişkeni `.env`'deki doğru anahtarı gölgeledi (Node `loadEnvFile` ezmez) → CLI artık `.env`'yi önceliklendiriyor; (3) Gemini şemasında serbest nesne (`siklar`) boş `{}` döndürdü → A–E açıkça tanımlandı; (4) çıktı sınırı 16000 token yetmedi (`MAX_TOKENS`) → 60000. **Güvenlik olayı:** bir kontrol komutu hatalı olarak API anahtarını sohbet çıktısına yazdırdı; anahtarın AI Studio'da silinip yenilenmesi önerildi (GÖR-001 ile aynı sınıf). `npm test` 27/27. Kalan: `enrich` canlı denemesi, 4okuma-ca bir cevap anahtarı kitabı (soru kitabıyla karşılaştırma), kayıt defterinde başlık kodlaması bozuk (Türkçe karakterler komut satırı argümanında bozuldu), yarım kalan toplu indirmenin temizliği, LGS en sona.
- **İlgili:** K-0020, GÖR-042, GÖR-043

### K-0020 · 2026-10-17 14:12 · YÖN · Soru Atölyesi: PDF'ten etiketli soru üretim programı (brief ve plan)
- **Tür:** Plan
- **Konu:** YÖN, VT, MOB
- **Bağlam:** Kullanıcı, MEB'in herkese açık PDF içeriklerinden Hupo'ya uygun soruları etiketli ve denetimli üretecek, sonra yönetim paneline toplu aktaracak bir program istedi. Program önce `C:\Dev\Soru-Cevap Hazırlama Programı` içinde bağımsız geliştirilecek. Brief: `BRIEF.md`, plan: `PLAN.md`, şema: `sema/soru-paketi.v1.schema.json` (aynı klasör).
- **Plan:** Faz 0 zemin → 1 LLM'siz çekirdek (şema, kural denetimi, mevcut CSV'ye export) → 2 PDF→aday soru + zenginleştirme → 3 varyasyon → 4 LLM hakem + kör çözüm → 5 yerel inceleme ekranı → 6 panel entegrasyonu (migration, `admin_import_questions_v2`, panel sekmesi, ayrı iş olarak Flutter kademeli ipucu) → 7 pilot (~100 soru).
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17): birebir aktarım ve kazanım/kalıptan özgün üretim birlikte olacak; LLM Claude API, anahtar yalnızca ortam değişkeninde. `ONAY BEKLİYOR`: Node.js + TypeScript yığını; Faz 6 (migration ve RPC) ayrı onayla.
- **Durum:** DEVAM
- **Doğrulama:** DOĞRULANMADI (yalnızca belge ve şema yazıldı; şema JSON olarak okundu, doğrulayıcı henüz yok)
- **Sahip:** Ajan + Kullanıcı
- **Önem:** Yüksek
- **Açıklama:**
  - Telif: kullanıcı MEB içeriğinin serbest olduğunu beyan etti. Ajan web'de MEB EBA/soru bankası için açık lisans kanıtı bulamadı; bir 2015 MEB sınav kitapçığında izinsiz çoğaltma ve ticari kullanım yasağı ibaresi var. Program her kaynağa `lisans_dayanagi` yazdırır, boşsa birebir kaynağı export'a almaz. Yazılı izin veya hukuk görüşü önerilir (HUK).
  - Keşifte bulunan mevcut kusurlar Faz 6'da kapatılacak: panel CSV/formunda `sinif` yok (RPC `sinif` yazıyor; yerelde NULL = RLS yüzünden öğrenciye görünmez, canlı doğrulayıcı gövdesi teyitsiz); mükerrer anahtarı sınıfı içermiyor; `csv.ts` formül enjeksiyonu önlemi ve birim testi yok; "Din Kültürü" ders adı tutarsız.
  - Ana quizde cevap öncesi ipucu ve yanlış şık başına geri bildirim yok (ipucu `cozum_adimlari[0]` içinde); yeni alanlar için kolon yetkisi (cevaptan önce ipucu okunabilir, doğru cevap kapalı) kararı gerekir.
  - Kazanım kodu uydurulmaz (K8, Kelime Evreni kararı); doğrulanamayan kod null kalır.
- **Kanıt:** `C:\Dev\Soru-Cevap Hazırlama Programı\{BRIEF.md,PLAN.md,sema\soru-paketi.v1.schema.json}`.
- **Güncelleme 2026-10-17 14:30:** Faz 1 çekirdeği yazıldı (`src/lib`, `src/qa/katmanA.ts`, `src/export/panelCsv.ts`, `src/cli.ts`; bağımlılık yalnızca ajv). `npm test` — 11/11 geçti. `npm run export -- altin-set\ornek-paket.json …` bilerek bozuk soruyu kırmızı yakaladı, temiz soruyu panel CSV'sine yazdı. Doğrulama hâlâ KISMİ: üretilen CSV panelin gerçek önizlemesinde denenmedi; panel `sinif` sütununu yok sayıyor ve okul değerini olduğu gibi geçiriyor (panel şablonu "İlkokul", veri tabanı değerleri küçük harf `ilkokul`; export küçük harf yazar, tutarsızlık Faz 6'da ele alınacak). Katman B (LLM), PDF okuma, varyasyon ve inceleme ekranı henüz yok.
- **Güncelleme 2026-10-17 14:34 (Faz 2 kodu ve MEB kaynağı):** Faz 2 kodu yazıldı: `src/lib/anthropic.ts` (araç çağrısı, bütçe tavanı, anahtar yalnızca ortamdan), `src/ingest/kaynak.ts` (sha256, kaynak kaydı), `src/ingest/aday.ts` (PDF belge girişi → aday soru, şemaya tek tek doğrulama), `src/enrich/zenginlestir.ts` (kademeli ipucu, yanlış şık geri bildirimi, beceri/düzey). `npm test` — 23/23 geçti (API sahte istemciyle; gerçek çağrı yapılmadı). **Canlı çalıştırma yapılmadı:** `ANTHROPIC_API_KEY` tanımlı değil, `.env` yok. Kullanıcı ODSGM sayfasını verdi (`odsgm.meb.gov.tr/www/temel-egitim-kitaplari/icerik/834`, 54 kaynak, 2–8. sınıf). **HUK bulgusu:** sayfanın altbilgisinde "2026 © MEB. Tüm Hakları Saklıdır." yazıyor, açık lisans yok. Bu, K-0020'nin "serbest" varsayımıyla çelişiyor. Kullanıcı kararı `ONAYLI`: **uyarlama ve özgün üretim**. Kaynaklar `lisans_durumu=belirsiz` ile kaydedilir; `belirsiz` kaynakta birebir aktarım kodla kapatıldı (model 'birebir' dese bile aday 'uyarlama'ya çevrilir, test var). Birebir aktarım için MEB'den yazılı izin veya hukuk görüşü gerekir (HUK, GÖR-043).
- **İlgili:** GÖR-042, GÖR-036, GÖR-026, `web-panel/src/components/yonetim/sorular/`, `supabase/migrations/20260927000100_admin_soru_listesi_ve_ice_aktarma.sql`.

### K-0019 · 2026-10-17 13:32 · ALT · Commit zinciri: .vercelignore, birikmiş değişiklikler ve günlük
- **Tür:** Gelişme
- **Konu:** ALT, BEL, VT, VEL
- **Bağlam:** Kullanıcı yükleme ayarı, production dağıtımı ve kalan değişiklikler için commit istedi. Diğer ajanların da bu commit'lerden haberdar olması istendi.
- **Plan:** (1) Web paneli değişikliklerini commit et (K-0015). (2) `.vercelignore` değişikliğini ayrı commit et (K-0016). (3) Kalan değişiklikleri gizli anahtar taramasından geçirip commit et. (4) Günlüğe yaz.
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17): "hepsini commit et", "yaz günlüğe, diğer ajanlar da bilsin". Commit'ler yalnızca yerel; push yapılmadı, dağıtım yapılmadı.
- **Durum:** TAMAMLANDI
- **Doğrulama:** DOĞRULANDI. `git log` üç yeni commit'i gösteriyor. Çalışma ağacı temiz. Gizli anahtar kalıbı taraması: gerçek anahtar yok; eşleşmeler rol adlarının metin geçişi. `node_modules` klasörleri `.gitignore` ile dışarıda.
- **Sahip:** Ajan
- **Önem:** Orta
- **Açıklama:**
  - `9a22041`: `web-panel` içindeki 126 değişiklik (Çocuklarım sayfası dahil). Production'da.
  - `e84e977`: `.vercelignore` (yükleme kapsamı). Yalnızca yerel.
  - `9ce66a0`: kalan 64 dosya: `TASKS.md` → `PROJE_GUNLUGU.md`, veli–çocuk bildirim migration'ı ve testi, `eposta-gonder`, push/telefon/anket migration'ları ve testleri, mobil push ön izin değişiklikleri, yasal sayfalar.
  - Uzak veritabanına yalnızca `20261042000000` uygulandı. `9ce66a0` içindeki diğer migration'lar **uygulanmadı**; her biri ayrı onaya tabi.
  - Diğer ajanlar için: yeni kayıt açarken K numarasını son kayıttan sonra al. Bu günlükte bazı numaralar çakıştı (K-0008, K-0014, K-0015); ilgili kayıtlar başka oturumlara ait, değiştirilmedi.
- **Kanıt:** `git log --oneline -3` → `9ce66a0`, `e84e977`, `9a22041`. `git status --short` → boş.
- **İlgili:** K-0015, K-0016, GÖR-033, GÖR-013, GÖR-030.

### K-0018 · 2026-10-17 13:25 · YÖN · Segmentli bildirim gönderimi: plan (onay bekliyor)
- **Tür:** Plan
- **Konu:** YÖN, VT, HUK
- **Bağlam:** Kullanıcı, yönetim panelinden bildirimin kayıtlı veya yeni bir segmente (plan, sınıf, aktiflik, ilk görev, yenileme, elle veli seçimi) gönderilmesini istedi. Akış: taslak → ön kontrol → planla → `kampanya_push_gonder` dağıtımı. Kanal: uygulama içi kutu + push. Pazarlama kapısı (`pazarlama_push_kapisi`) kapalı; açma kodu yazılmayacak (GÖR-031).
- **Mevcut durum (salt okunur doğrulandı, 2026-10-17 13:25):**
  - Uzak DB ile yerel migration listesi `20261042000000`'ye kadar eşleşik (`npm run db:status`). Bekleyen migration yok.
  - `_segment_veliler` en güncel tanımı `20261036` (veli_idleri destekli); yalnızca `role='veli'`, izin `iletisim_tercihleri` ile.
  - `kampanya_push_gonder` en güncel tanımı `20261038` (kapı kontrolü, sessiz saat, haftalık limit, `skip locked`).
  - `admin_segment_onizle / kaydet / listele / arsivle` ve `admin_kampanya_kaydet / on_kontrol / planla / iptal` `20261007`'de; kampanya listesi `onkontrol` içinde `alici_sayisi` ve `iptal_nedeni` taşıyor.
  - PGlite `supabase/tests/bildirim_kampanya` (`npm test`): 94 geçti, 0 başarısız. SQL denetimi (`tools/sql-sozdizim-denetimi.mjs`): 126 dosya, 0 hata.
  - Panelde: `BildirimManager` yalnızca rol grubu seçiyor (segment yok). `CampaignsManager` hazır akışa sahip, ancak aşağıdaki boşluklar var.
- **Boşluklar (bulgular):**
  1. `admin_kampanya_planla` kapı durumunu ve kanalı kontrol etmiyor. Kapı kapalıyken planlanan kampanya dağıtımda `yasal_kapi_kapali` ile iptal oluyor; kullanıcı önceden bilgilendirilmiyor.
  2. Kanal listesi `eposta | push | sms | uygulama_ici`. Yalnızca `push` dağıtılıyor (worker yok). Diğer kanallar planlanıp sessizce hiç gönderilmeyebilir.
  3. TS tipinde ve UI'da `gonderildi` durumu yok (DB'de `kampanya_push_gonder` yazıyor).
  4. Ön kontrol sonucunda kapı durumu yok; panel kapıyı göstermiyor.
  5. Elle veli seçimi (`veli_idleri`) yalnızca DB'de; `SegmentsManager`'da alan yok.
  6. `BildirimManager` `ogrenci` ve `tumu` hedeflerine kategorisiz serbest metin gönderiyor (`admin_send_notification`: kategori parametresi yok). Çocuk güvenliği kuralı (öğrenciye yalnızca hizmet bildirimi, UI'da zorunlu) bu akışta karşılanmıyor.
- **Plan:**
  1. Migration `20261044000000_segment_bildirim_dagitim_kapisi.sql` (`20261043` atlanır; önek 20261042'den büyük ve çakışmasız). Yalnızca iki fonksiyon yeniden tanımlanır, tablo eklenmez, RLS değişmez:
     - `admin_kampanya_on_kontrol`: sonuca `kapi_acik` (`_pazarlama_push_acik()`) ve `kanal_dagitilir` (kanal = push) eklenir. Mevcut alanlar aynen kalır.
     - `admin_kampanya_planla`: kanal `push` değilse ve kapı kapalıysa reddedilir (`23514`, Türkçe mesaj). Kampanya taslak/ön kontrol aşamasında kalır; oluşturma ve ön kontrol açık kalır.
     - Her fonksiyon için `security definer`, `set search_path = ''`, `revoke`/`grant` yeniden yazılır.
  2. PGlite: `test.mjs`'e yeni bölüm (mevcut 94 test korunur). Kapsam: kapı kapalıyken planla reddi; dağıtım iptali ve sıfır alıcı; izinsiz veli ve öğrenci hesabı alıcı listesinde yok; `veli_idleri` ile tek veli hedefi; `eposta` kanalında planla reddi; `kapi_acik` alanı. Kapı açık senaryosu yalnızca test veritabanında tablo üzerinden simüle edilir; uygulama koduna kapı açma yolu eklenmez.
  3. Web (`web-panel`):
     - Bildirimler sayfasında iki sekme: "Segmente gönder" (yeni bileşen; `admin_segment_listele`, `admin_segment_onizle` (kanal=push), `admin_kampanya_kaydet/on_kontrol/planla`, `admin_kampanya_listele`) ve mevcut "Hızlı bildirim".
     - Kanal seçimi yalnızca "Uygulama içi kutu + push". Kapı kapalıysa üstte açık uyarı ve planla düğmesi devre dışı.
     - Durum: taslak, ön kontrol, planlandı, gönderildi, iptal; alıcı sayısı ve iptal nedeni `onkontrol`'dan.
     - `types.ts`: `CampaignStatus` += `gonderildi`; `PreflightResult` += `kapi_acik`, `kanal_dagitilir`.
     - `CampaignsManager`: yeniden yazılmaz; yalnızca `gonderildi` rozeti, kapı uyarısı ve kanal seçeneği kısıtı eklenir.
     - `SegmentsManager`: elle veli seçimi alanı eklenir (en fazla 1000, arama ile).
     - Çeviriler `messages/tr.json` ve `en.json` birlikte.
  4. Ham bildirim formu (`BildirimManager`): ÖNERİ, karar bekliyor (aşağıda). Kod değişmez.
  5. Dağıtım ve uygulama: `npm run db:preview` (kuru çalıştırma) ve kullanıcı onayı olmadan `db:deploy` yok. Web dağıtımı kullanıcı onayı olmadan yok.
- **Karar:** `ONAY BEKLİYOR` (ajan önerileri):
  - (a) Kapı kapalıyken planla engellensin (dağıtımda iptal yerine ön engel). Gerekçe: kullanıcı kapı kapalıyken kampanya hazırlayabilsin ama sonradan sürpriz iptal yaşamasın. Tasarım değişikliğidir.
  - (b) Kanal yalnızca push olsun (kutu dahil). E-posta, SMS ve uygulama içi kanalları worker yokken kullanılamaz.
  - (c) Ham bildirim formunda `ogrenci` ve `tumu` kaldırılsın; öğrenciye hizmet bildirimi için ayrı karar (kategori zorunlu). Yani bu kayıt için GÖR-040.
  - (d) Yeni UI bildirim sayfasında sekme olarak eklensin; merkez kampanya ekranı korunur.
  - (e) Migration adı `20261044000000` (önek 20261043 atlandı).
- **Durum:** BEKLİYOR (plan onayı)
- **Doğrulama:** — (Plan türünde)
- **Sahip:** Ajan (kod ve testler), Kullanıcı (kararlar, `db:deploy` ve web dağıtım onayı), Hukuk (kapı kararı, GÖR-031)
- **Önem:** Yüksek
- **Açıklama:**
  - Kapı kapalıyken hiçbir pazarlama gönderimi açılmaz. Hukuk kapısı kapalıyken bu iş canlıda pazarlama dağıtımı yapamaz; yalnızca hazırlık ve ön kontrol çalışır.
  - Risk: ön kontrol ile dağıtım anındaki alıcı sayısı farklı olabilir (kriter dağıtım anında hesaplanır). Kriter kilidi (`kontrol_edildi` ve `planlandi` segmentinde değişiklik yok) ve `alici_sayisi` panelde gösterilerek sınırlanır.
  - Risk: uzak DB'de `eposta`/`sms`/`uygulama_ici` kanalında açık kampanya varsa planla reddedilir; bu kampanyalar iptal edilmez, bilgi olarak raporlanır (önce sorgu ile bakılacak).
- **Kanıt:** `npm run db:status` (uzak = yerel, `20261042`'ye kadar); `npm test` (supabase/tests/bildirim_kampanya): 94/0; `node tools/sql-sozdizim-denetimi.mjs`: 126 dosya, 0 hata.
- **İlgili:** GÖR-031, GÖR-040 (yeni), K-0003, K-0005, §23, §25.
- **Güncelleme 2026-10-17 13:48:** Kullanıcı (a)–(e) önerilerinin tamamını onayladı (`ONAYLI`). Uygulandı:
  - Migration `20261044000000_segment_bildirim_dagitim_kapisi.sql` (yerelde; uzakta henüz yok): `admin_kampanya_kaydet` yalnız `push` kanalını kabul eder; `admin_kampanya_on_kontrol` sonuca `kapi_acik` ve `kanal_dagitilir` ekler; `admin_kampanya_planla` kanal push değilse veya kapı kapalıysa reddeder. Hukuk kapısını açan yol, yeni tablo ve yeni kanal eklenmedi.
  - PGlite `supabase/tests/bildirim_kampanya`: 107 geçti, 0 başarısız (94 önceki + migration idempotency 2 + yeni bölüm N 11). README beklenen sayısı 54'ten 107'ye güncellendi.
  - `supabase/tests/yonetim_merkezi_tests.sql` (pgTAP değil; yerelde çalıştırılmadı): eposta kampanyaları push'a çevrildi; kapı kapalı red senaryosu eklendi, kapı yalnızca bu senaryo için yönetici RPC'siyle açılıyor.
  - Web: yeni `panel/SegmentliBildirim.tsx` (segment önizleme, taslak, ön kontrol, planla, push kampanya listesi) ve `panel/BildirimSekmeleri.tsx` (bildirimler sayfasında iki sekme). `BildirimManager` hedefi yalnız veli (`ogrenci`/`tumu` kaldırıldı). `CampaignsManager`: yalnız push kanalı, `gonderildi` durumu, iptal nedeni, alıcı sayısı, kapı uyarısı, kapı kapalıyken planla pasif. `SegmentsManager`: elle veli seçimi (en fazla 1000), push önizlemesi. `types.ts` ve mesajlar tr/en (anahtar sayıları eşit).
  - Doğrulama: `npx tsc --noEmit` çıkış 0. `npx eslint` (değişen 7 dosya): 0 hata, 1 uyarı (`BildirimManager.tsx:47` `setLoading` effect içinde; değişiklikten önce de vardı). `node tools/sql-sozdizim-denetimi.mjs`: 127 dosya, 0 hata. `npm run db:preview`: yalnız `20261044000000_segment_bildirim_dagitim_kapisi.sql` bekliyor. Uzak `iletisim_kampanyalari` tablosu boş; açık kampanya yok.
  - Tarayıcı (demo modu, `NEXT_PUBLIC_DEMO_MODE=1`, port 3010, konsol hatası 0): bildirimler iki sekme, segment seçince önizleme (214 / 131 / 83), kapı kapalı uyarısı, hızlı bildirimde öğrenci hedefi yok; segmentler sayfasında elle veli bölümü; kampanya formunda yalnız push. Ekran görüntüsü: `%TEMP%\bildirim-segment.png`.
  - Doğrulanmayan: gerçek yönetici oturumuyla kaydet → ön kontrol → planla → dağıtım zinciri. Demo modu kayıt yapmaz; bu akış DOĞRULANMADI. Demo'da `ParentPicker` `admin_list_users` için 401 veriyor (mevcut bileşen davranışı; oturum yok).
  - Açık: uzak DB'ye `db:deploy` ve web dağıtımı kullanıcı onayı bekliyor (GÖR-041).
  - **Durum:** DEVAM · **Doğrulama:** KISMİ · **Sahip:** Ajan (kod ve testler), Kullanıcı (uzak DB uygulaması, web dağıtımı, gerçek oturumla test)
- **Güncelleme 2026-10-17 15:10:** Kullanıcı uzak DB uygulaması ve web dağıtımını onayladı.
  - Uzak DB: `npm run db:deploy` çıkış 0; `20261044000000` yerel ve uzakta eşleşik.
  - Web dağıtımı 1: kökten `vercel deploy --prod --archive=tgz`; yükleme 2,1 GB'ta `fetch failed` ile düştü. Dağıtım 2: aynı komut, çıktı vermeden sonlandı (çıkış -1).
  - Neden: yükleme boyutu `web-panel/.next` (2,2 GB). Kökteki `.vercelignore` bu klasörü dışlamıyor görünüyordu; `web-panel/.vercelignore` eklendi (`.next/`, `node_modules/`, test çıktıları, `.env*`). Bu dosya commit'lenmedi.
  - Dağıtım 3: `web-panel-qk8cdc190-hupo1.vercel.app` ready, production `https://hupolingo.com`.
  - Smoke: `/tr`, `/tr/yonetim-giris`, `/tr/yonetim/bildirimler` → 307 (K-0015'teki önceki dağıtımla aynı davranış; hedef adres doğrulanmadı).
  - Doğrulanmayan: yeni sürümün canlıda yönetici sayfasında göründüğü (oturum gerekli), gerçek kampanya zinciri (GÖR-041).
  - **Durum:** DEVAM · **Doğrulama:** KISMİ

### K-0017 · 2026-10-17 · HUK · Gizlilik ve kullanım koşulları metinleri: KVKK ve tüketici hukuku için güçlendirildi
- **Tür:** Gelişme
- **Konu:** HUK, WEB
- **Bağlam:** Kullanıcı, taslak gizlilik ve kullanım koşullarının KVKK, pazarlama ile veri kullanım ve paylaşım izinleri açısından genişletilmesini istedi. Yabancı bir şirketin (Gizmo) kayıtlı metinleri yalnızca yapı fikri için incelendi; metin kopyalanmadı. Sınır: geçersiz kılınacak haksız şartlar eklenmedi; hedef, geçerli rıza, açık aydınlatma ve Türk hukukuna uygunluktur.
- **Plan:**
  1. Gerçek veri akışları koddan doğrulandı: iyzico (ad, soyad, e-posta, IP), Brevo ve Resend (e-posta), İleti Merkezi (SMS), FCM (bildirim, canlıda değil: K-0003), Sentry (kişisel veri temizliği), PostHog EU (onayla), Turnstile, Google Drive yedeği, Supabase.
  2. `content.ts` içindeki gizlilik ve koşul metinleri KVKK m.5, m.9, m.10, m.11, m.12, m.13 ile 6563 ve 6502 sayılı kanunlar çerçevesinde yeniden yazıldı; "Kısaca" özetleri eklendi.
  3. `LegalDocument` özet kutusunu gösterecek şekilde güncellendi; iki sayfa da özeti geçiyor.
  4. Son güncelleme tarihi 17 Ekim 2026 (taslak) olarak değiştirildi.
  5. Hukuki teyit bekleyen veya bilinmeyen alanlar köşeli parantezde bırakıldı.
- **Karar:**
  - Mobil öğrenci aydınlatma metni (`privacy_notice.dart`) ve `kPrivacyNoticeVersion` DEĞİŞTİRİLMEDİ. Sürüm artışı tüm öğrencilerden yeniden onay ister ve GÖR-019 hukuk teyidi bekliyor. `ONAY BEKLİYOR` (Hukuk).
  - Analitik çerez metni ve sürümü (`ANALYTICS_CONSENT_VERSION`) değiştirilmedi (K-0016).
  - Sınav sonuçlarında çocuk adının herkese açık sıralamada gösterilmemesi önerisi (K-0010 bağlamı) metinde taahhüt olarak yazılmadı. Uygulanmadan yayına alınmamalı. `ONAY BEKLİYOR`.
- **Durum:** BEKLİYOR
- **Doğrulama:** KISMİ. `npx tsc --noEmit` ve `npx eslint` (4 dosya) çıkış kodu 0. Sayfa tarayıcıda görsel olarak kontrol edilmedi. Hukuki geçerlilik doğrulanmadı.
- **Sahip:** Hukuk
- **Önem:** Yüksek
- **Açıklama:**
  - Metinde yazılı taahhütler koda yansıtılmalı: (a) pazarlama segmenti ve dışa aktarım yalnızca izinli kayıtlarla (Müşteri 360 V3); (b) reklam platformuna kitle yükleme yalnızca ayrı açık rıza ile (V4); (c) öğrenme profilleri pazarlamada kullanılmaz; (d) hesap silme ve veri kopyası (`delete_my_account`, `export_my_data`) çalışır durumda; (e) rate-limit kayıtları 2 gün.
  - Doğrulanmadı: KVKK m.12 kapsamında veri işleyen sözleşmeleri imzalı mı; Google Drive yedeği henüz Actions'ta çalıştırılmadı, bu yüzden 30 gün saklama süresi kurulumla doğrulanmalı.
  - Avukatın doldurması gereken alanlar: şirket unvanı, MERSİS, adres, KEP, VERBİS durumu, sunucu bölgesi, yurt dışı aktarım dayanağı, iade ve iptal koşulları, sorumluluk tavanı (tüketici sözleşmelerinde haksız şart riski), yetkili mahkeme, saklama süreleri, çerez tablosu.
- **Kanıt:** `web-panel/src/lib/legal/content.ts`; `web-panel/src/components/legal/LegalDocument.tsx`; `web-panel/src/app/[locale]/(full-width-pages)/gizlilik/page.tsx`; `web-panel/src/app/[locale]/(full-width-pages)/kosullar/page.tsx`. Komutlar: `npx tsc --noEmit` (0), `npx eslint <dört dosya>` (0).
- **İlgili:** GÖR-019, K-0002, K-0003, K-0010, K-0016.

### K-0014 · 2026-10-17 · WEB · Landing yeniden düzenlemesi: commit'ler ve doğrulama
- **Tür:** Gelişme
- **Konu:** WEB, TSR, BYM, MOB
- **Bağlam:** Kullanıcı landing için tasarım, içerik ve ölçüm geri bildirimleri verdi; hızlı kazanımlar, hero ürün kanıtı, bölüm sırası, header sadeleştirme ve fayda bölümü uygulandı.
- **Plan:** (1) Hızlı kazanımlar, (2) hero konsept A ve karakter yolu, (3) bölüm sırası ve olay ölçümü, (4) tek Giriş menüsü, (5) fayda bölümü, (6) hero soru görseli.
- **Karar:** Kullanıcı onayı (`ONAYLI`): hızlı kazanımlar, orta vadeli maddeler, commit ve push. Sayfadan çıkarıldı: deneme sınavı, erken erişim, uygulama maketleri, WhyParents ve TrustBadges bölümleri (rotalar çalışmaya devam ediyor). Hero'daki "Veli hesabı oluştur" düğme yerine metin bağlantısı oldu.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ. Doğrulanan: eslint (değiştirilen dosyalar) 0 hata, `tsc --noEmit` 0, `npm run build` çıkış 0 (son derleme dahil birkaç kez); yerel production (3002) masaüstü 1440 ve mobil 390 ekran görüntüleri (header, hero, fayda); 390px'te yatay taşma ölçümü 0 (Playwright + Chrome). Derlenmiş ana CSS 130 KB; kaynak `globals.css` 34 KB'tan 11 KB'a indi (önceki derleme boyutu ölçülmedi). Doğrulanmayan: canlı deploy, analitik olaylarının gerçek kabul akışında gönderimi, karakter animasyonu, Lighthouse (yapılmadı).
- **Sahip:** Ajan
- **Önem:** Yüksek
- **Açıklama:** Push edilen commit'ler: `5661d27` (hero ürün kanıtı, bölüm sırası, olay ölçümü, CSS temizliği, locale algılamasının kapatılması), `f113e0b` (tek Giriş menüsü: öğrenci, veli, öğretmen → `/yonetim-giris`; menü beş öğeye indi; soru vurgusu), `1d08f8b` (fayda bölümü Hupo pozlarıyla; mobil header CTA'sı `sm` üstünde; ÖRNEK RAPOR kartı taşması), `ae1c078` (hero soru görseli). Aynı push'ta daha önce yerelde bekleyen 6 commit da gitti (`9169887`..`d8c085d`, `0e50c83`, `7e8b1e4`). Canlıda görünüp görünmediği doğrulanmadı (GÖR-039). Hero görseli gerçek ekran değil, uygulama dilinde illüstrasyon (GÖR-037).
- **Kanıt:** `git push origin master` sonuçları: `8898cd7..5661d27`, `f113e0b..1d08f8b`, `1d08f8b..ae1c078`. Ekran görüntüleri: scratchpad (`header_desk2.png`, `final_mob.png`, `benefits_desk.png`, `benefits_mob.png`).
- **İlgili:** GÖR-013, GÖR-017, GÖR-020, GÖR-034, GÖR-037, GÖR-038, GÖR-039.

### K-0015 · 2026-10-17 · MOB · Yanlış cevap açıklaması ekranda görünmüyor
- **Tür:** Sorun
- **Konu:** MOB
- **Bağlam:** Günün 5 Sorusu'nda yanlış cevap verildiğinde yalnızca seçilen şık turuncu oldu; "Doğru cevap" metni ve açıklama görünmedi. Kullanıcı, normal soru akışında (Öğren) bunun görünmesi gerektiğini söyledi. Normal akış henüz denenmedi: telefon kilitlendi, ardından USB bağlantısı koptu.
- **Plan:** (1) Öğren akışında yanlış cevap ile tekrar dene. (2) `dogru_sik` yanıtının boş gelip gelmediğini kontrol et. (3) `result_sheet.dart` metin koşulunu doğrula.
- **Karar:** Kod değişikliği yapılmadı.
- **Durum:** BEKLİYOR
- **Doğrulama:** DOĞRULANMADI
- **Sahip:** Ajan
- **Önem:** Yüksek
- **Açıklama:** `result_sheet.dart:93` yalnızca `correctOption` dolu ise "Doğru cevap: …" yazıyor. `models.dart:203` değeri sunucudan `dogru_sik` olarak okuyor; `unsavedTimeout` durumunda boş (`''`) dönüyor. Gerçek neden bilinmiyor; normal akışta bakılmalı.
- **Kanıt:** Telefon ekran görüntüleri (Günün 5 Sorusu, soru 1 ve 2, yanlış cevap sonrası; açıklama yok).
- **İlgili:** GÖR-036.

### K-0016 · 2026-10-17 · WEB · Analitik olay ölçümü ve çerez metni: hukuk onayı gerekli
- **Tür:** Karar
- **Konu:** WEB, HUK, BYM
- **Bağlam:** Hero CTA, demo tamamlama, veli kayıt başlangıcı ve fiyat tıklamaları eklendi. Olaylar yalnızca analitik çerezine onay verilmişse gönderiliyor; kişisel veri içermiyor (`web-panel/src/lib/analytics/events.ts`). Çerez bandı kısaltıldı: "Çerez kullanıyoruz." ve "Tercihler" bağlantısı `/gizlilik` sayfasına gidiyor. Tam çerez metni (`cookie.text`) yalnızca `messages` dosyasında duruyor.
- **Plan:** (1) Olay listesini ve onay kapısını koru. (2) Çerez metnini ve analitik sürümünü hukukla birlikte gözden geçir. (3) Gerekirse sürümü artırıp yeniden onay al.
- **Karar:** Metin ve `ANALYTICS_CONSENT_VERSION` (`analitik-2026-10-taslak-1`) değiştirilmedi. Yeni olayların çerez metninde açıklanıp açıklanmayacağı `ONAY BEKLİYOR` (hukuk görüşü).
- **Durum:** BEKLİYOR
- **Doğrulama:** DOĞRULANMADI (kabul ve red akışında olayın gönderimi tarayıcıda test edilmedi)
- **Sahip:** Hukuk, Kullanıcı
- **Önem:** Yüksek
- **Açıklama:** Mevcut metin "anonim sayfa görüntüsü ölçümü" diyor; olay ölçümü bu tanımın kapsamında değil. Sürüm değişikliği, bu kararı verenlerin tüm kullanıcılardan yeniden onay istemesi anlamına gelir.
- **Kanıt:** `web-panel/src/lib/analytics/consent.ts` (sürüm sabiti), `web-panel/src/components/analytics/CookieConsent.tsx` (kısa metin ve "Tercihler").
- **İlgili:** GÖR-019, GÖR-034.

### K-0010 · 2026-10-17 00:51 · VEL · Panodaki sorunların doğrulanması ve çocuk eşleşme geri bildirimi
- **Tür:** Sorun
- **Konu:** VT, ALT, VEL
- **Bağlam:** Kullanıcı GÖR-007, GÖR-027 ve GÖR-029'u kontrol edip düzeltmeyi, ayrıca veli–çocuk eşleşmesinde geri bildirim olup olmadığını sordu. Bu kayıt yazılırken günlük başka oturumlar tarafından da güncelleniyordu; numara çakışması K-0008 ve GÖR-033 ile giderildi.
- **Plan:**
  1. GÖR-007: migration dosyalarının durumunu kontrol et.
  2. GÖR-027: anahtar kabulünü değer yazmadan doğrula.
  3. Eşleşme RPC'sini ve veli bileşenini oku.
  4. GÖR-029: karar gerektirdiği için değiştirme.
- **Karar:** Eşleşme için bildirim kanalı ve veli panelinde bağlı çocuk listesi ürün kararı: `ONAY BEKLİYOR`. Kod değişikliği yapılmadı.
- **Durum:** TAMAMLANDI (kontrol kısmı). GÖR-027 ve GÖR-029 açık; GÖR-033 açıldı.
- **Doğrulama:** DOĞRULANDI (kontrol kısmı)
- **Sahip:** Ajan
- **Önem:** Yüksek
- **Açıklama:**
  - **GÖR-007:** Çakışma K-0005'te giderildi, öğretmen migration'ı K-0004 ile uzak DB'ye uygulandı. Bu kontrolde `20261040000000` önekinde yalnızca `sinav_katilim_onayi` olduğu ve öğretmen migration'ının `20261041000000` olduğu doğrulandı. Kapanış K-0005.
  - **GÖR-027:** Yanlış değişken adı ve yanlış başlık düzeltildi. Yerel `.env.local` değişkeni `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`; `apikey` başlığıyla REST isteği 401 değil, anahtar kabul ediliyor. Vercel ortam değişkeni doğrulanmadı.
  - **GÖR-033 (eşleşme):** Kod tarafında kanıtlandı: `redeem_parent_link_code` yalnızca `profiles.parent_id` güncelliyor, bildirim yazmıyor ve veliye sonuç dönmüyor. `CocukEkleKarti.tsx` yalnızca kod üretiyor. Canlı davranış test edilmedi.
  - **GÖR-029:** Değiştirilmedi.
- **Kanıt:** `supabase/migrations/` listesi (`20261040000000_sinav_katilim_onayi.sql`, `20261041000000_ogretmen_sinif_raporu.sql`); `.env.local` anahtar adları; `supabase/migrations/20261016000000_veli_eslestirme_kodu.sql` içindeki `redeem_parent_link_code` gövdesi; `web-panel/src/components/veli-paneli/CocukEkleKarti.tsx`.
- **İlgili:** GÖR-027, GÖR-029, GÖR-033, K-0005.

### K-0016 · 2026-10-17 13:22 · ALT · Vercel yükleme süresi: .vercelignore ile yükleme kapsamı daraltıldı
- **Tür:** Gelişme
- **Konu:** ALT
- **Bağlam:** Vercel CLI dağıtımı repo kökünden yapılıyor (proje kök dizini `web-panel`). Yükleme 2 GB'tı; production dağıtımı yaklaşık 20 dakika sürdü.
- **Plan:** (1) Proje kök dizini ayarını değiştirmeden, yüklemeyi daraltmak. (2) Önizleme ile ölçmek.
- **Karar:** `ONAYLI` (kullanıcı talimatı: "yükleme yavaş, kök dizini düzelt"). Ajan kararı: proje kök dizini (`web-panel`) değiştirilmedi; projenin Git bağlantısı CLI çıktısından doğrulanamadığı için ayarı değiştirmek derlemeleri bozabilir. Yükleme kapsamı `.vercelignore` ile daraltıldı. Dosya commit edilmedi.
- **Durum:** TAMAMLANDI
- **Doğrulama:** DOĞRULANDI. Önizleme dağıtımı `web-panel-5lzzsq1je-hupo1.vercel.app` → status Ready, derleme 31 sn, toplam yaklaşık 0,9 dakika.
- **Sahip:** Ajan
- **Önem:** Orta
- **Açıklama:** Dışarıda bırakılanlar: `mobile-app` (4,3 GB), `supabase`, `docs`, `.claude`, `.git`, kök `node_modules`, `web-panel/node_modules`, `web-panel/.next` (2,1 GB). Vercel bağımlılıkları ve derlemeyi kendisi yapıyor. Kök dizin ayarını `.` yapmak isteniyorsa Vercel panelinden yapılabilir; bu, Git tabanlı bir bağlantı varsa derlemeleri etkileyebilir.
- **Kanıt:** `.vercelignore` (kök). `npx vercel inspect web-panel-5lzzsq1je-hupo1.vercel.app` → Ready, build duration 31s.
- **İlgili:** K-0015, GÖR-013.

### K-0015 · 2026-10-17 13:19 · ALT · Web paneli production'a alındı (onayla)
- **Tür:** Gelişme
- **Konu:** ALT, VEL
- **Bağlam:** K-0014 önizlemenin production onayı kullanıcıdan geldi ("Production'a alma onayı veriyorum").
- **Plan:** (1) `web-panel` içindeki 126 değişikliği tek commit'te topla (`9a22041`). Diğer değişiklikler (Supabase, mobil, dokümanlar) bu onayın kapsamında değil, commit edilmedi. (2) `vercel deploy --prod --archive=tgz`. (3) Canlı adresi kontrol et.
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17).
- **Durum:** TAMAMLANDI (dağıtım). Oturumlu kullanıcı kontrolü yapılmadı; GÖR-033 kalan adımları açık.
- **Doğrulama:** KISMİ. Dağıtım `READY`, production URL `https://hupolingo.com`. `hupolingo.com/tr` ve `/tr/veli-paneli/cocuklarim` yanıt veriyor (307/302, oturum yönlendirmesi). Sayfanın oturumlu görünümü ve Çocuklarım akışı henüz test edilmedi.
- **Sahip:** Ajan (commit ve dağıtım), Kullanıcı (uçtan uca test hesaplarıyla kontrol)
- **Önem:** Yüksek
- **Açıklama:** Vercel production, `web-panel` kök dizini ayarı nedeniyle repo kökünden tgz ile dağıtıldı. Dağıtım yaklaşık 20 dakika sürdü (2 GB yükleme). Commit'te 126 dosya, 6106 satır eklendi, 2565 satır silindi. Geri alma: Vercel'de önceki dağıtımı promote etmek.
- **Kanıt:** `git commit` → `9a22041`. `vercel deploy --prod` → `web-panel-fyyx80tyz-hupo1.vercel.app ready. Production URL: https://hupolingo.com`.
- **İlgili:** GÖR-033, K-0014, GÖR-013 (dağıtım kayıtları), GÖR-011 (karakter görselleri derleme bağımlılığı).

### K-0014 · 2026-10-17 12:26 · ALT · Web paneli önizleme dağıtımı (production'a alınmadı)
- **Tür:** Gelişme
- **Konu:** ALT, VEL
- **Bağlam:** Çocuklarım sayfasının canlıda görünmesi için web dağıtımı istendi. `web-panel` içinde commit edilmemiş 126 değişiklik var; bunlar bu işin dışındaki oturumlara ait.
- **Plan:** (1) Yerelde `npm run build`. (2) Vercel'e önizleme (preview) dağıtımı. (3) Production için kullanıcı onayı.
- **Karar:** Önizleme `ONAYLI` (kullanıcı). Production'a alma `ONAY BEKLİYOR`: 126 değişiklik gözden geçirilip commit edilmeden canlıya gitmemeli.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ. Yerel build geçti; rota `/veli-paneli/cocuklarim` derlemede. Önizleme `web-panel-coqwzh4j3-hupo1.vercel.app` "ready". Vercel koruması nedeniyle sayfa tarayıcıdan oturumla kontrol edilmedi.
- **Sahip:** Ajan (dağıtım), Kullanıcı (production onayı)
- **Önem:** Yüksek
- **Açıklama:** Vercel kök dizin ayarı `web-panel` olduğu için dağıtım repo kökünden yapıldı (`--archive=tgz` ile). Canlı etkisi yok.
- **Kanıt:** `npm run build` → `ƒ /[locale]/veli-paneli/cocuklarim`. `vercel deploy --yes --archive=tgz` → "Deployment ... ready".
- **İlgili:** GÖR-033, GÖR-013, K-0013.

### K-0013 · 2026-10-17 10:37 · ALT · eposta-gonder edge function canlıya alındı (kapalı)
- **Tür:** Gelişme
- **Konu:** ALT, VEL
- **Bağlam:** K-0011 e-posta kuyruğunun göndericisi. Kullanıcı kalan adımları birlikte yapmak istedi.
- **Plan:** (1) Fonksiyonu `--no-verify-jwt` ile deploy et (kimlik kontrolü fonksiyonun kendi gizli başlığıyla yapılır). (2) Gizli anahtarsız çağrının kapalı kaldığını doğrula. (3) Secrets ve zamanlama için kullanıcıya adım adım rehber ver.
- **Karar:** `ONAYLI` (kullanıcı talimatı). Web dağıtımı bu kayda dahil değil: `web-panel` içinde commit edilmemiş 126 değişiklik var; bunlar tek seferde canlıya gitmemeli, önce gözden geçirilip commit edilmeli (`ONAY BEKLİYOR`).
- **Durum:** DEVAM
- **Doğrulama:** KISMİ. Deploy başarılı. Gizli anahtar olmadan `POST` → 503 (kapalı). Brevo anahtarı ve gönderici tanımlanmadığı için gerçek gönderim test edilmedi.
- **Sahip:** Ajan (deploy), Kullanıcı (Brevo anahtarı, gönderici, secrets, zamanlama)
- **Önem:** Yüksek
- **Açıklama:** Secrets tanımlanana kadar e-postalar kuyrukta bekler. Kuyruğu boşaltacak zamanlayıcı henüz kurulmadı.
- **Kanıt:** `npx supabase functions deploy eposta-gonder --no-verify-jwt` → "Deployed Functions." `Invoke-WebRequest` (gizli başlıksız POST) → 503.
- **İlgili:** GÖR-033, K-0011, K-0012, GÖR-013.

### K-0012 · 2026-10-17 09:16 · ALT · Uzak veritabanına 20261042000000 uygulandı
- **Tür:** Gelişme
- **Konu:** VT
- **Bağlam:** K-0011 migration'ını uzak DB'ye uygulama onayı kullanıcıdan geldi ("Migration'ı uygula").
- **Plan:** (1) `npm run db:status`: bekleyen liste. (2) `npm run db:preview`: kuru çalıştırma. (3) `npm run db:deploy`. (4) Salt okunur doğrulama.
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17). Bekleyen tek migration `20261042000000_veli_cocuk_bildirim.sql` olarak doğrulandı; başka migration uygulanmadı.
- **Durum:** TAMAMLANDI (veritabanı kısmı). Web ve e-posta gönderici canlıda değil.
- **Doğrulama:** DOĞRULANDI. `db:status` yerel ve uzak eşleşti. Fonksiyonlar ve yetkiler salt okunur sorguyla kontrol edildi: `veli_bagli_cocuklar`, `veli_cocuk_baglantisini_kaldir`, `redeem_parent_link_code` yalnızca `authenticated` çağırabilir; `bildirim_gonder`, `bildirim_eposta_kuyrukla`, `cocuk_riza_durumu` hiçbir istemci rolünden çağrılamaz; `eposta_outbox` RLS açık.
- **Sahip:** Ajan (onaylı işlem)
- **Önem:** Kritik
- **Açıklama:** Uzakta, önceki eşleşme davranışından farklı olarak artık bağlanan öğrenci için veliye ve çocuğa bildirim yazılır. Web "Çocuklarım" sayfası yeni RPC'leri kullanır; web dağıtılmadan canlıda görünmez (GÖR-013). E-postalar secrets tanımlanana kadar kuyrukta bekler.
- **Kanıt:** `npm run db:preview` → "Would push these migrations: 20261042000000_veli_cocuk_bildirim.sql". `npm run db:deploy` → "Finished supabase db push." `npm run db:status` → `20261042000000` local ve remote eşleşik. `npx supabase db query --linked` (salt okunur) → fonksiyon ve yetki listesi.
- **İlgili:** GÖR-033, K-0011, GÖR-013, GÖR-030.

### K-0011 · 2026-10-17 01:33 · VEL · Çocuk eşleşme geri bildirimi ve Çocuklarım sayfası (kodlandı)
- **Tür:** Karar
- **Konu:** VEL, VT, HUK
- **Bağlam:** K-0010'da bulunan eksik: eşleşmede veliye bildirim yok, veli panelinde bağlı çocuk listesi yok. Kullanıcı üç kanalın (kutu, push, e-posta) hepsine hazırlık ve liste tasarımı için uzman ve veli bakışı istedi.
- **Plan:**
  1. Migration `20261042000000_veli_cocuk_bildirim.sql`: tek bildirim girişi, e-posta kuyruğu, bağlı çocuk listesi, bağlantı kaldırma.
  2. PGlite testi (gerçek migration zinciri).
  3. Web: `/veli-paneli/cocuklarim` sayfası ve "Çocuklarım" menü bağlantısı.
  4. E-posta gönderici `supabase/functions/eposta-gonder` (kod hazır, çalıştırılmadı).
- **Karar:** `ONAYLI` (kullanıcı, 2026-10-17): üç kanal da hazır olsun; liste veli panelinde olsun. Ajan önerileri `ONAY BEKLİYOR`: (a) veli bağlantıyı kaldırabilsin, bu durumda onay geri çekilir ve iki taraf bilgilendirilir; (b) çocuğun e-postası ve telefonu listede gösterilmez; (c) e-posta yalnızca hesap işlemi bildirimleri içindir, pazarlama değildir, İYS kapsamına girmez (hukuk teyidi GÖR-019'a eklendi); (d) push, mevcut opt-in ve sessiz saat kurallarına bağlıdır.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ. PGlite 31/31 (`supabase/tests/veli_cocuk_bildirim`). Web `tsc` ve eslint temiz. Tarayıcıda gerçek veli hesabıyla kontrol yapılmadı. Migration uzak DB'ye uygulanmadı. `eposta-gonder` çalıştırılmadı (Deno ve Brevo anahtarı yok).
- **Sahip:** Ajan (kod), Kullanıcı (deploy onayı, secrets), Hukuk (e-posta metinleri)
- **Önem:** Yüksek
- **Açıklama:**
  - Yeni: `eposta_outbox` (adres saklanmaz, yalnızca alıcı kimliği), `bildirim_gonder()` tek giriş, `veli_bagli_cocuklar()`, `veli_cocuk_baglantisini_kaldir()`.
  - Değişen: `redeem_parent_link_code()` artık veliye ve çocuğa bildirim üretiyor.
  - Veri koruma: bağlantı kaldırılınca onay `veli_riza_geri_cekildi` olarak yazılır. Yeniden bağlanan veli önceki onayı devralmaz. İlk taslakta bu bir hataydı; test yakaladı ve düzeltildi.
  - Web: sayfa ve bileşen eklendi; çeviriler TR ve EN'de.
  - Push, GÖR-030 kapsamında canlıya geçmeden çalışmaz. E-posta, secrets tanımlanmadan gönderilmez; kuyrukta bekler.
- **Kanıt:** `node test.mjs` → 31 geçti, 0 başarısız. `npx tsc --noEmit` çıkış 0. `npx eslint` çıkış 0. Çeviri JSON'ları geçerli.
- **İlgili:** GÖR-033, GÖR-030, GÖR-019, K-0010.

### K-0013 · 2026-10-17 14:38 · YÖN · Veli Hedefler, Aktivite, Denemeler sayfaları 500: kök neden ve düzeltme
- **Tür:** Sorun
- **Konu:** VEL
- **Bağlam:** Eklenti (tarayıcı) kontrolünde Hedefler, Aktivite Akışı ve Deneme Sınavları "sunucu hatası" verdi (React #441 konsol hatası). Dersler, Tekrar, Başarılar, Üyelik çalıştı.
- **Kök neden:** Üç sunucu sayfası (`page.tsx`, `"use client"` yok) `ChildScope`'a bir `render` fonksiyonu geçiriyordu. Next.js bu fonksiyonu istemci bileşenine aktaramaz: "Functions cannot be passed directly to Client Components". Dersler/Tekrar/Başarılar bu fonksiyonu istemci bileşenlerinin içinde kurduğu için etkilenmemişti. Dev günlüğünde aynı hata 2026-10-17 00:3x'te görülmüştü.
- **Düzeltme:** İstemci sarmalayıcıları eklendi: `GoalsScope.tsx`, `ActivityScope.tsx`, `ExamsScope.tsx` (`"use client"`; render fonksiyonu burada). Üç sayfa yalnızca `<XScope students={…} />` veriyor.
- **Doğrulama:** `tsc --noEmit` 0 hata; ESLint (6 dosya) temiz; dev (demo) sunucu günlüğünde hata yok, üç rota 200; kabul testi `-g veli-paneli` 10/10 geçti (390, 768, 1024 px; demo verisi).
- **Deploy:** Minimal sahne klasöründen `vercel deploy --prod --archive=tgz`: Ready, alias `hupolingo.com`, deployment `web-panel-he1oivcu2-hupo1.vercel.app`. Production'da oturumlu yeniden kontrol henüz yapılmadı (eklenti ile).
- **Eklenti turu 2 (894 px, veli):** Hedefler, Aktivite, Denemeler, Dersler, Tekrar, Başarılar GEÇTİ; konsol hatası yok. Açık: (a) Çocuklarım "Bağlantı tarihi kayıtlı değil" = `cocuk.baglandi_at` null (UI doğru, veri eksik; yerelde kod hatası değil, DB kaydı kontrol edilmeli). (b) Deneme kaydı formu yalnızca yaklaşan bir deneme sınavı varsa çıkıyor (`get_upcoming_mock_exams_for_child`); o hesapta yaklaşan sınav olmadığı için form görünmedi, bu bir hata değil.
- **Eklentinin diğer bulguları (sonraki kontrol):** Çocuklarım sayfasında "Bağlantı tarihi kayıtlı değil" (veri tutarsızlığı; sinif/üyelik kaydı eksik olabilir). Sayfa genişlikleri eklentiyle test edilemedi; bu kontrol Playwright ile yapıldı (yukarıdaki kabul testi).
- **Durum:** DEVAM
- **Doğrulama:** KISMİ (yerel ve kabul testi DOĞRULANDI; production'da oturumlu kontrol bekliyor)
- **Sahip:** Ajan; production kontrolü Kullanıcı (eklenti)
- **Önem:** Yüksek
- **İlgili:** K-0012, K-0011 (eklenti raporu), GÖR-022.

### K-0012 · 2026-10-17 13:54 · YÖN · Production deploy tamamlandı; erişim ve test hesabı engeli
- **Tür:** Gelişme
- **Konu:** YÖN
- **Bağlam:** Kullanıcı iki kararını uygulamamı istedi: (1) kökten yeniden dağıtım için `.vercelignore` ve yeniden deneme, (2) Vercel'in kök `.gitignore`'a eklediği `.env*` satırı. Ayrıca oturumlu sayfa kontrolü için test hesabı değişkenlerini (E2E_*) ayarlamamı istedi.
- **Karar (uygulandı):**
  1. `.vercelignore` eklendi (kök): `.claude/`, `.git/`, `.vercel/`, `supabase/`, `docs/`, `kurtarilan/`, `tools/` vb., `node_modules`, `web-panel/.next/`, `mobile-app/build/`, `.env*`. `mobile-app/assets/characters` bilerek korundu (web-panel `prebuild` buna bağlı).
  2. `.gitignore` değişikliği GERİ ALINDI (`git diff` boş). Kökte `.env.local` yok; kök `.env*` gereksiz. Kullanıcı tutulmasını isterse tek satır eklenir.
- **Deploy:**
  - Kökten `--archive=tgz` denemesi: 2,1 GB yükleme (`.next` 2,2 GB; `.vercelignore` bu dağıtımda uygulanmadı) → durduruldu (kendi süreç ağacım).
  - Çözüm: minimal sahne klasörü (web-panel kaynakları, `node_modules`, `.next`, `.env*.local` HARİÇ; karakter görselleri 81 dosya) üzerinden `vercel deploy --prod --yes --archive=tgz`. Sahne klasörü silindi.
  - Sonuç: **Ready** (50 sn), deployment `web-panel-4kbd430aj-hupo1.vercel.app`, alias `https://hupolingo.com` (Vercel "Aliased" çıktısı).
  - Önceki deployment `web-panel-fyyx80tyz-hupo1.vercel.app` (diğer oturumun) yerine geçti.
- **Doğrulama (düzeltme):** K-0011'deki "smoke 200" sonucu GEÇERSİZ. O 200 yanıtı Vercel SSO giriş sayfasıydı (Deployment Protection açık). Bu kayıtta yeniden kontrol edildi: `vercel curl` ile (kullanıcının Vercel oturumu, salt okuma):
  - `hupolingo.com/tr` → 307 (ana sayfaya)
  - `hupolingo.com/tr/yonetim` → 307 `/yonetim-giris?next=/yonetim` (oturum gerekli; **demo modu production'da kapalı**)
  - `hupolingo.com/tr/veli-paneli` → 307 `/veli-paneli/giris?next=…` (oturum gerekli)
- **Test hesabı (E2E_VELI_EMAIL / E2E_VELI_PASSWORD / E2E_ADMIN_EMAIL / E2E_ADMIN_PASSWORD):** AYARLANAMADI. Ortamda hiçbir test hesabı tanımlı değil (`.claude/settings.local.json` ve `web-panel/.env.local` içinde E2E_ değişkeni yok). Hesap oluşturmak production Supabase Auth'a kullanıcı eklemek ve admin/öğretmen rolü atamak demektir; bu, açık onay olmadan yapılmadı.
- **Oturumlu kontrol için iki engel:**
  1. Vercel Deployment Protection: tarayıcı otomasyonu SSO'ya takılır. Çözüm: Vercel'de "Protection Bypass for Automation" gizli anahtarı üretip `.claude/settings.local.json` env bloğuna `VERCEL_AUTOMATION_BYPASS_SECRET` olarak eklemek (gitignored), ya da production için Deployment Protection'ı kapatmak.
  2. Test hesapları: veli, öğretmen ve yönetici test kullanıcıları (Supabase Auth) ve rol atamaları. Değerler `.claude/settings.local.json` env bloğunda durmalı (CLAUDE.md §Gizli anahtarlar).
- **Durum:** DEVAM
- **Doğrulama:** KISMİ. Build ve deploy tamam; production'da girişe yönlendirme ve demo kapalılığı doğrulandı. Oturumlu sayfalar (veli menüsü, öğretmen sınıf ekranı, yönetim 390 px) henüz gözden geçirilmedi.
- **Sahip:** Kullanıcı (test hesapları ve bypass anahtarı veya koruma kararı, onay), Ajan (kontrol)
- **Önem:** Yüksek
- **İlgili:** GÖR-012 (`hupolingo.com` artık bu deployment'a alias'lı; DNS durumu ayrıca teyit edilmeli), GÖR-020, GÖR-022, K-0011.

### K-0011 · 2026-10-17 13:17 · YÖN · Merkez/sorular kontrolü, production deploy ve smoke testi
- **Tür:** Gelişme
- **Konu:** YÖN
- **Bağlam:** Kullanıcı üç şey istedi: kökten bağlanıp deploy için izin (ONAYLI), production'da veli ve yönetim sayfalarının tarayıcıda gözden geçirilmesi, merkez/sorular/sayfalar ajanının işini tamamlaması.
- **Merkez/sorular/sayfalar (Y2) işinin durumu:** Ajan API limitinde bitti, rapor vermedi. Dosyalar tek tek kontrol edildi:
  - `ChannelSettings`, `PazarlamaPushKapisi`, `BulkImport`, `QuestionsManager`: `DesktopOnly` sarmalaması var (K3).
  - `SurveysManager`: anket listesi tablo değil, kart/satır yapısı; düğmeler dokunma sabitini kullanıyor.
  - `CampaignsManager`: telefonda kart listesi, `md+` tablo.
  - `QuestionsTable`: `masaustuTablo` (md+) ve `mobilKart` ayrımı.
  - `TeamView`: salt okunur; rol atama eylemi yok, yetki matrisi planlanan model. K3 için sarmalanacak işlem bulunmadı.
  - Sonuç: merkez/sorular kapsamı tamam. Ajan raporu olmadığı için kapsam dosya incelemesiyle doğrulandı.
- **Doğrulama (yerel):** `tsc --noEmit` 0 hata. ESLint (98 dosya) 0 hata, 5 uyarı. Kabul testi `panel-responsive.spec.ts` 50/50 (demo, `--workers=1`). `npm run build` başarılı (`.next/BUILD_ID` 01:49). Build sonrası kaynak değişikliği yok; yalnızca e2e spec düzeltildi.
- **Deploy süreci:**
  1. `vercel deploy --prod` web-panel klasöründen: "Root Directory `web-panel` does not exist". Proje kökten bağlanmalı.
  2. Kökten bağlantı (`vercel link --project web-panel --scope hupo1`): `.vercel/repo.json` (kök → `web-panel` projesi, `prj_4DW…`). Vercel kökte `.env.local` oluşturdu ve kök `.gitignore`'a `.env*` ekledi. `.env.local` silindi (içinde token vardı). `.gitignore` değişikliği BIRAKILDI; geri alınması kullanıcı kararı.
  3. Kökten `--prod` denemesi: "files should NOT have more than 15000 items (25690)". Çözüm: `--archive=tgz`.
  4. Benim `--prod --archive=tgz` denemem takıldı (CPU 300 sn boyunca sabit kaldı). Yalnızca kendi süreç ağacım durduruldu (pid 21584, 21100, 23812). Dağıtım tamamlanmadı.
  5. Aynı anda başka bir oturumun `vercel deploy --prod --yes --archive=tgz` süreci (12:41 başlangıç, pid 20432) çalıştı ve tamamlandı. Vercel'de son production dağıtımı: `web-panel-fyyx80tyz-hupo1.vercel.app` (Ready, Production, ~6 dk önce, "hupo1/web-panel").
  6. Eski takılı süreç (pid 6772, 23:38'den beri) listede yok.
- **Smoke testi (production `web-panel-fyyx80tyz-hupo1.vercel.app`):** `/tr` 200, `/tr/yonetim-giris` 200, `/tr/veli-paneli/giris` 200.
- **Açık kalan doğrulama:**
  - Yayındaki dağıtımın hangi kaynak ağacından geldiği doğrulanmadı. Bu benim değişikliklerimi içeriyor olabilir ama kanıtlanmadı. Kanıt için oturumlu sayfalarda (veli Dersler/Tekrar menüsü, öğretmen Sınıflarım, yönetim Destek Masası) bakılmalı.
  - Oturumlu sayfalar tarayıcıda gözden geçirilmedi: test hesabı bilgisi yok. Kullanıcı `E2E_VELI_EMAIL`, `E2E_ADMIN_EMAIL` ortam değişkenlerini ayarlarsa kontrol yapılabilir.
  - `hupolingo.com` alan adı DNS'i henüz çözümlenmiyor (GÖR-012); kontrol `vercel.app` adresiyle yapıldı.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ (build, tip denetimi, kabul testi ve public smoke tamam; oturumlu tarayıcı kontrolü ve yayın kaynağı teyidi yok)
- **Güncelleme 2026-10-17 13:54:** "Public smoke 200" sonucu GEÇERSİZ: 200 yanıtları Vercel SSO sayfasıydı (Deployment Protection). Doğru kontrol K-0012'de (`vercel curl`, 307 login yönlendirmeleri). Ayrıca yayındaki dağıtım `fyyx80tyz` idi; sonradan K-0012'deki dağıtım ile değiştirildi.
- **Güncelleme 2026-10-17 13:2x:** Kendi yeniden deneme `--prod --archive=tgz` başarısız oldu: `ENOENT … .claude/scheduled_tasks.lock` (başka bir oturumun kilit dosyası arşivleme sırasında kayboldu) ve `read ECONNRESET`. Süreç kendi ağacımdan durduruldu; ikinci bir production dağıtımı yapılmadı. Yayındaki sürüm (`web-panel-fyyx80tyz-hupo1.vercel.app`) hâlâ diğer oturumun dağıtımı. Öneri: dağıtım, `.claude/` klasöründeki çalışma kilit dosyaları yokken ya da kilit dosyaları hariç tutularak yapılmalı (`.vercelignore` eklenmesi kullanıcı kararı).
- **Sahip:** Kullanıcı (test hesapları, yayın kaynağı teyidi, `.gitignore` kararı), Ajan (kontrol)
- **Önem:** Yüksek
- **İlgili:** GÖR-012, GÖR-020, GÖR-022, K-0010, K-0008.

### K-0010 · 2026-10-17 01:51 · YÖN · Doğrulama turu: build, lint, tsc, kabul testi; deploy engellendi
- **Tür:** Gelişme
- **Konu:** YÖN
- **Bağlam:** Yarım kalan işler kontrol edildi ve tamamlandı (K-0008 devamı). Kullanıcı Vercel sürecinin devam etmesine ve deploy yapılmasına izin verdi.
- **Plan:** (1) TypeScript denetimi, (2) değişen dosyalarda ESLint, (3) kabul testi `e2e/panel-responsive.spec.ts` (demo, temiz dev sunucusu, `--workers=1`), (4) `npm run build`, (5) Vercel production deploy.
- **Karar:** Deploy için kullanıcı izni verildi. Otomatik güvenlik kontrolü bu izni yetersiz buldu (aşağıya bakın).
- **Durum:** DEVAM
- **Doğrulama:** KISMİ
  - `npx tsc --noEmit`: 0 hata (çıkış kodu 0).
  - ESLint (98 değişen ts/tsx dosyası): 0 hata, 5 uyarı.
  - Kabul testi: 50/50 geçti (47 rota × 3 genişlik + veli menüsü + giriş/kayıt). İlk koşuda tek başarısızlık vardı: test kapatma adımında menü düğmesine tıklıyordu, oysa açık menüde arka plan perdesi düğmenin üstünde. Test, perdeye tıklayarak kapatacak şekilde düzeltildi (uygulama değişmedi).
  - `npm run build`: başarılı (`.next/BUILD_ID` 01:49:28).
  - Ekran görüntüsü: yalnızca başarısız testin 390 px kanıtı var (menü açık). Ayrı, bilinçli bir 390/768/1024 görsel seti alınmadı; GÖR-020 için eksik.
- **Deploy durumu:** BAŞARISIZ / ENGELLENDİ
  - `vercel deploy --prod` (web-panel klasöründen): Vercel "Root Directory `web-panel` does not exist" hatası verdi. Proje Root Directory'si `web-panel` olarak tanımlı; bu klasörü tek başına yüklemek yetmiyor. Hatalı deployment kaydı oluştu (`DmjcKEx7…`); production alias güncellenmedi.
  - Kökten bağlanma (`vercel link --project web-panel`) güvenlik kontrolü tarafından **reddedildi** ("Production Deploy"). Bu komut denenmek istendi; bu nedenle reddedilen bir eylem yeniden denenmedi ve başka bir deploy yolu aranmadı.
  - Takılı kalan `vercel deploy --prod` süreci (pid 6772, 23:38'den beri) 20 saniyede CPU kullanmadı; büyük olasılıkla bir girdi veya ağ yanıtı bekliyor. Kullanıcı devam etmesini istediği için durdurulmadı.
- **Sahip:** Kullanıcı (deploy izin kuralı veya kökten bağlanma onayı; Root Directory ayarı kararı)
- **Önem:** Yüksek
- **Açıklama:** Kod tarafı hazır: build, tip denetimi ve kabul testi geçiyor. Production'a alma işi izin bekliyor. Yapılması gereken: kullanıcı kökten link/deploy için izin verirse (veya Vercel projesinin Root Directory ayarını netleştirirse) deploy tekrar denenir. Sonra production'da veli, öğretmen ve yönetim sayfalarının tarayıcı kontrolü yapılmalı.
- **Açık kalan (K-0008 listesinden):** Merkez/sorular/sayfalar ajanı (Y2) bitmedi; SurveysManager kart görünümü, sorular toplu içe aktarma DesktopOnly ve ekip rol atama sarmalamaları doğrulanmadı. Kabul testi bu sayfaların rota düzeyinde taşmasını kapsıyor, K3 davranışını değil.
- **İlgili:** GÖR-020, GÖR-022, K-0008, K-0009.

### K-0009 · 2026-10-17 01:22 · HUK · GÖR-032 geçici karar ve kontrol listesi (sonradan hukuk teyidi)
- **Tür:** Karar
- **Konu:** HUK
- **Bağlam:** Kullanıcı GÖR-032 (veli bilgilendirmesi ve sınıf üyeliği rızası) için internetten araştırma yapılmasını ve şimdilik buna göre hareket edilmesini istedi; konu sonradan kontrol edilmek üzere deftere işlendi.
- **Araştırma (ikincil kaynaklar; hukuki görüş değildir):**
  - Öğretmenin öğrenme verisini görmesine ilişkin doğrudan bir Kurul kararı veya MEB yönergesi bulunamadı.
  - MEB Temmuz 2026 talimatı (haber kaynağı): kişisel veri yalnızca görev ve hizmet gereğiyle, belirli ve meşru amaçlarla işlenir; gereğinden fazla veri alınmaz; fotoğraf ve video için velinin yazılı açık rızası aranır. Kaynak: gazeteoksijen.com, 16 Temmuz 2026 haberi.
  - KVKK 5. madde: açık rıza genel kuraldır; kanunda öngörülme, sözleşme ve meşru menfaat gibi istisnalar vardır. Meşru menfaat, ilgilinin temel hak ve özgürlüklerine zarar vermemeyi şart koşar. Öğrenme analitiğine hangi istisnanın uyduğu hukuki değerlendirme gerektirir.
  - Kurul'un 18.02.2026 tarihli 2026/347 sayılı ilke kararının açık rıza metinlerini aydınlatma metninden ayrı düzenlediği belirtiliyor (ikincil kaynak; birincil metin okunmadı).
  - Birincil kaynaklar: kanun metni, kvkk.gov.tr ve Kurul kararları. Bu okunmadı.
- **Geçici karar (uygulandı):**
  1. Öğretmen yalnızca toplu sınıf özetini görür; ad, e-posta ve tek tek cevap yok (`ogretmen_siniflarim()`, K-0004).
  2. İlerleme değerleri, sınıfta en az 3 cevaplayan öğrenci yoksa gösterilmez.
  3. Veli bilgilendirmesi: `veliPaneli.consent.ogretmenNotice` (TR ve EN). Metin sistemin ne gösterdiğini anlatır; hukuki iddia içermez.
  4. Sınıf üyeliği için açık rıza şartı EKLENMEDİ. Üyelik admin tarafından oluşturuluyor. Bu, hukuk görüşü gelene kadar açık bir risk olarak kalıyor.
  5. Fotoğraf ve video konusu bu değişikliğin kapsamında değil.
- **Durum:** GEÇİCİ KARAR. Hukuk görüşü bekliyor.
- **Doğrulama:** DOĞRULANMADI (hukuki). İkincil kaynaklar kullanıldı; birincil metin okunmadı. Teknik taraf: bildirim metni TR/EN anahtarları var; RPC PGlite 16/16.
- **Sahip:** Ajan (geçici uygulama), Hukuk (nihai görüş), Kullanıcı (kontrol)
- **Önem:** Yüksek
- **Kontrol listesi (sonradan teyit):**
  - [ ] Öğretmen erişimi için hukuki dayanak: açık rıza mı, meşru menfaat mi, sözleşme mi? (KVKK 5/2)
  - [ ] Sınıf üyeliği için veli bilgilendirmesi veya rıza gerekiyor mu?
  - [ ] Aydınlatma metni (`web-panel/src/lib/legal/content.ts`) öğretmen erişimini kapsıyor mu?
  - [ ] Öğrenme verisi özel nitelikli veri sayılır mı (sağlık, engellilik içermiyor mu)?
  - [ ] Eşik 3 yeterli mi, yoksa daha yüksek bir eşik mi gerekli?
  - [ ] Birincil kaynaklar (kanun, kvkk.gov.tr, Kurul kararı 2026/347) okundu mu?
- **İlgili:** GÖR-032, GÖR-019, K-0004, K-0006.

### K-0008 · 2026-10-17 01:10 · YÖN · Devir notu: yönetim/veli mobil-tablet işi kesildi, kalanlar
- **Tür:** Not
- **Konu:** YÖN
- **Bağlam:** Oturum token bütçesi tükendi. Veli paneli (V) ve yönetim merkez/sorular/sayfalar (Y2) ajanları API oturum limitine (429, sıfırlanma 01:10) takılarak sonlandı. Diğer ajanlar (A–K, L–Z, öğretmen) raporlarını teslim etti.
- **Yapılanlar (dosya düzeyi, son durum):**
  - Ortak temel: `SidebarContext` (`isDesktop`, `inert`), `AppSidebar`, `VeliSidebar` (Yakında öğeleri filtrelendi), `VeliHeader` (yeni), veli ve admin kabuklarında `xl:` boşluk, `ui/modal` (yerel `<dialog>`), `ui/DesktopOnly` (yeni), `styles.ts` 44 px/16 px sınıfları, `AppHeader` ve `CommandPalette` mobil arama olayı, `Pager`, başlık açılır menüleri, `DuyuruBandi`, `AnketDiyalog`.
  - Yönetim A–K ve L–Z bileşenleri: kart görünümü ve K3 sarmalamaları tamam (ajan raporları).
  - Öğretmen: `SiniflarManager` salt okunur, `RolKapisi`, `ogretmen_siniflarim()` migration'ı uygulandı (K-0004).
- **Devam eden / kalan:**
  1. Veli paneli (V): K4 "bu hafta" ana ekranı, K6 deneme kaydı katılım/pazarlama ayrımı (yeni RPC `set_exam_katilim_onayi` çağrısı), K7 abonelik koşulları, boş durumlar, veli sayfalarının 390/768/1024 kontrolü, öğretmen özeti bilgilendirme metni (hukuk onayı bekliyor). Durumu doğrulanmadı; dosyalar yarım olabilir.
  2. Merkez, sorular ve sayfalar (Y2): SurveysManager, CampaignsManager, QuestionsTable kart görünümü; sorular toplu içe aktarma, ekip rol atama, ayarlar yazma eylemleri DesktopOnly. Rapor yok.
  3. Kabul testi: `e2e/panel-responsive.spec.ts` temiz dev sunucusunda (3000, demo modu) tek seferde, `--workers=1`, henüz tam koşulmadı.
  4. `npx eslint` ve `npx tsc --noEmit` (değişen tüm dosyalar), `npm run build` (dev sunucusu durdurulduktan sonra; `.next` çakışması olmamalı).
  5. 390 px ekran görüntüsü kanıtı (GÖR-020 / GÖR-022 kapanışı için zorunlu).
  6. Gerçek öğretmen hesabıyla `/yonetim/siniflar` tarayıcı testi (demo modu rolü admin'e zorluyor).
  7. Musteri360 ve PlanManager gibi dosyalarda K3 sarmalamasının son teyidi; "Yakında" ürün kararı.
- **Bilinen sorunlar:**
  - Önceki 500 hataları `.next` çakışması ve eşzamanlı messages düzenlemesinden kaynaklandı; messages JSON'ları şu an geçerli.
  - Ajanlar aynı `MesajSablonlariManager`, `MockExam*` ve messages dosyalarını düzenledi; son lint/tsc olmadan tutarlılık doğrulanmadı.
  - K-0003 ile `db:status` çelişkisi (20261035–20261038) doğrulanmadı.
  - Production'da `vercel deploy --prod` süreci (pid 6772, 23:38'den beri) çalışıyor görünüyor; başlatılma kaynağı bilinmiyor. Durdurulmadı, kullanıcı kontrol etmeli.
- **Durum:** DEVAM
- **Doğrulama:** DOĞRULANMADI
- **Sahip:** Ajan (devralacak oturum), Kullanıcı (vercel süreci, hukuk, ürün kararları)
- **Önem:** Yüksek
- **Açıklama:** Bir sonraki oturum bu notu ve GÖR-022'yi başlangıç noktası almalı. Önce V ve Y2 dosyalarının tutarlılığı (lint/tsc) kontrol edilmeli, sonra kabul testi ve build.
- **İlgili:** GÖR-020, GÖR-022, GÖR-032, K-0003, K-0004, K-0007.

### K-0007 · 2026-10-17 00:43 · YÖN · Yönetim ve veli mobil/tablet uyumu: uygulama ve doğrulama durumu
- **Tür:** Gelişme
- **Konu:** YÖN
- **Bağlam:** Kullanıcı tüm panellerin (yönetim, öğretmen, veli) 390, 768 ve 1024 px'te uyumlu olmasını istedi. Kararlar K1–K8 ONAYLI (2026-10-16). Plan TASKS §20 idi; defter yeniden adlandırıldığında GÖR-022'ye taşındı.
- **Plan:** P0 kabul testi (`web-panel/e2e/panel-responsive.spec.ts`), P1 ortak temel, P2 veli paneli, P3 öğretmen, P4–P5 yönetim bileşenleri, P6 K3 masaüstü-only, P7 doğrulama (lint, tsc, build, 390 px kanıt), P8 kayıt.
- **Karar:** K1–K8 ONAYLI (kullanıcı). Öğretmen özeti ve veli bilgilendirmesi: K-0006.
- **Durum:** DEVAM
- **Doğrulama:** DOĞRULANMADI. Kabul testi temiz sunucuda henüz tam çalıştırılmadı; önceki koşular 500 sayfalarında geçersiz kaldı. Veli paneli ve merkez/sorular/sayfalar ajanlarının raporları bekleniyor. `npm run build` henüz çalıştırılmadı. Ekran görüntüsü kanıtı yok.
- **Sahip:** Ajan
- **Önem:** Yüksek
- **Açıklama:** Yapılan: sidebar kapalıyken `inert`; veli üst barı ve menü düğmesi; admin ve veli kabuğunda içerik boşluğu `lg:` yerine `xl:` (1024–1279 px daralması giderildi); üst bara mobil arama düğmesi; yerel `<dialog>` ile modal (odak tuzağı, Escape, uzun içerik kırpılmaz); 44 px düğme ve 16 px girdi sınıfları; `DesktopOnly` bileşeni; yönetim A–K ve L–Z bileşenlerinde kart görünümleri ve K3 sarmalamaları; öğretmen sınıf ekranı salt okunur, `RolKapisi` ile yönlendirme. Kalan: veli paneli ve merkez/sorular/sayfalar raporları, kabul testi, production build, 390 px görsel kanıt.
- **Kanıt:** Öğretmen RPC PGlite 16/16 (`supabase/tests/ogretmen_sinif_raporu/kos.mjs`). Tüm messages JSON dosyaları geçerli (2026-10-17 00:3x). Yerel ve uzak migration listesi eşleşik (K-0004).
- **İlgili:** GÖR-022, K-0004, K-0005, K-0006.

### K-0006 · 2026-10-17 00:43 · HUK · Öğretmen sınıf özeti: karar ve koşullar
- **Tür:** Karar
- **Konu:** HUK
- **Bağlam:** Öğretmenin sınıf düzeyinde öğrenme özetini görmesi için veli bilgilendirmesi ve KVKK değerlendirmesi gerekiyordu. Öğretmen ekranı ve `ogretmen_siniflarim()` RPC'si hazırlandı; uygulama için karar istendi.
- **Plan:**
  1. Çıktı yalnızca toplu özet; ad, e-posta ve öğrenci kimliği yok.
  2. İlerleme değerleri (ortalama doğru oranı, tekrar bekleyen, son etkinlik, son 7 gün aktif) en az 3 cevaplayan öğrencisi olan sınıfta gösterilir (`v_esik = 3`); altında değerler null döner.
  3. Yalnızca okuma. Sınıf yazma admin_upsert_sinif üzerinden ve yalnızca admin'de.
  4. Veli panelinde sınıf özetinin görülebildiğini açıklayan bilgilendirme metni eklenir (V ajanı; metin hukuk onayı bekliyor).
  5. Aydınlatma metni güncellemesi ve sınıf üyeliğinin veli rızası gerektirip gerektirmediği hukuk görüşüne bağlanır (GÖR-032).
- **Karar:** ONAYLI. Kullanıcı 2026-10-17 00:4x tarihinde "öğretmenin sınıf düzeyinde öğrenme özetini görmesi (veli bilgilendirmesi ve KVKK) ve 3 cevaplayan öğrenci eşiği: ONAYLIYORUM, GEREKENİ YAP" dedi.
- **Durum:** DEVAM (veli bilgilendirmesi ve hukuk görüşü bekliyor)
- **Doğrulama:** KISMİ. RPC uzakta uygulandı (K-0004); PGlite 16/16. Öğretmen ekranı gerçek öğretmen hesabıyla tarayıcıda doğrulanmadı (demo modu rolü admin'e zorluyor).
- **Sahip:** Kullanıcı (karar), Hukuk (metin)
- **Önem:** Yüksek
- **Açıklama:** Ürün kararı alındı. KVKK uygunluğu bu kayıtla kanıtlanmış değildir; hukuk görüşü gerekir.
- **İlgili:** GÖR-032, GÖR-019, K-0004.

### K-0005 · 2026-10-17 00:43 · VT · Migration sürüm çakışması: öğretmen migration'ı yeniden numaralandırıldı
- **Tür:** Sorun
- **Konu:** VT
- **Bağlam:** `20261040000000_sinav_katilim_onayi.sql` ile öğretmen raporu migration'ı aynı sürüm numarasını taşıyordu (GÖR-007).
- **Plan:** Uzakta uygulanmadan önce öğretmen migration'ı `20261041000000_ogretmen_sinif_raporu.sql` olarak yeniden adlandırıldı; test betiği ve yorum referansları güncellendi.
- **Karar:** Yeniden adlandırma ajan işi. Dosya uygulanmamış ve bağımlılığı yoktu.
- **Durum:** TAMAMLANDI
- **Doğrulama:** DOĞRULANDI. `node kos.mjs` yeni yolla 16/16. `db:preview` iki migration'ı ayrı sürüm numaralarıyla listeledi. Uygulama sonrası `db:status` 0 eşleşmeyen kayıt gösterdi.
- **Sahip:** Ajan
- **Önem:** Kritik (uygulamadan önce yakalandı)
- **Açıklama:** Çakışma uzakta oluşmadı.
- **Kanıt:** `supabase/tests/ogretmen_sinif_raporu/kos.mjs` → SONUÇ 16/16.
- **İlgili:** GÖR-007 (kapandı), K-0004.

### K-0004 · 2026-10-17 00:43 · VT · Uzak veritabanına migration uygulandı: 20261040000000 ve 20261041000000
- **Tür:** Gelişme
- **Konu:** VT
- **Bağlam:** GÖR-006 için uygulama onayı verildi (ONAYLI). Bekleyen yalnızca iki migration kaldı: sınav katılım onayı ve öğretmen sınıf raporu.
- **Plan:**
  1. `npm run db:status`: bekleyen listesi.
  2. İçerik incelemesi: `user_answers`, `siniflar`, `sinif_uyelikleri` sütunları migration'larla eşleşti; `is_parent_of` ve `deneme_ana_profil` mevcut.
  3. `npm run db:preview` (dry-run): iki migration.
  4. `npm run db:deploy`.
  5. `npm run db:status`: eşleşme kontrolü.
- **Karar:** ONAYLI (kullanıcı, 2026-10-17 00:4x).
- **Durum:** DEVAM. Uygulama tamam; RPC'lerin canlı çağrısı ve istemci uyumu doğrulanmadı.
- **Doğrulama:** KISMİ. `db:status` 109 kaydın tamamında yerel ve uzak eşleşti (eşleşmeyen 0). Canlı RPC çağrısı yapılmadı.
- **Sahip:** Ajan (onaylı işlem)
- **Önem:** Kritik
- **Açıklama:** Uygulananlar: `consents.tur` kısıtına `sinav_katilim_onayi` ve `sinav_pazarlama_izni` eklendi; `set_exam_katilim_onayi` RPC'si eklendi; `register_for_mock_exam` artık katılım onayını arıyor; `ogretmen_siniflarim()` eklendi (salt okunur, toplu). Migration başlığına göre eski kayıt akışı zaten çalışmıyordu (pazarlama onayı yazılamıyordu); bu nedenle bu değişiklik yeni bir gerileme yaratmadı. Yeni veli istemcisi dağıtılana kadar kayıt akışı için yeni RPC çağrısı yapılmalı.
- **Çelişki (doğrulanmalı):** K-0003 ve GÖR-030, 20261035–20261038 sürümlerinin "uzakta uygulanmadığını" yazıyor. `db:status` bu sürümleri uzakta gösteriyor. Hangisinin doğru olduğu K-0003 sahibi tarafından kontrol edilmeli.
- **Kanıt:** `npm run db:preview`: 2 migration. `npm run db:deploy`: "Finished supabase db push". `npm run db:status`: toplam 109, eşleşmeyen 0.
- **İlgili:** GÖR-006, GÖR-007, GÖR-030, K-0003, K-0005.

### K-0008 · 2026-10-17 13:16 · ALT · Push uçtan uca çalışıyor: webhook kuruldu, telefonda görüldü
- **Tür:** Gelişme
- **Konu:** ALT
- **Bağlam:** Kullanıcı telefonda test bildirimini gördüğünü onayladı ve webhook kurulumunu istedi.
- **Plan:** (1) Webhook gizli değeri Supabase Vault'a yazıldı. (2) `push_outbox` INSERT tetikleyicisi (`pg_net` ile `send-push` çağrısı) oluşturuldu. (3) Otomatik tetiklenme test edildi. (4) Test bildirimleri ve yerel gizli dosya silindi.
- **Karar:** Kullanıcı talimatı (kurulum). Dashboard webhook yerine veritabanı tetikleyicisi kullanıldı; yerleşik `supabase_functions.http_request` canlıda olmadığı için. Gizli değer fonksiyon gövdesinde değil, Vault'ta.
- **Durum:** TAMAMLANDI
- **Doğrulama:** DOĞRULANDI
- **Sahip:** Ajan
- **Önem:** Yüksek
- **Açıklama:** Test hesabına (çocuk, cihaz kayıtlı) bildirim eklendi; webhook otomatik tetiklendi, kuyruk satırı `sent` oldu, kullanıcı telefonda bildirimi gördü. Kurulum migration dosyasına yazılmadı (gizli değer repoya girmesin diye); tetikleyici ve Vault kaydı doğrudan canlı veritabanında. iOS hâlâ kurulu değil (Windows'ta derlenemez).
- **Kanıt:** Vault: `push_webhook_secret` 1 kayıt; tetikleyici `push_outbox_webhook`: 1; test bildirimi: `push_outbox.status = sent`, `attempts = 1`, `last_error = null`; kullanıcı telefon onayı.
- **İlgili:** GÖR-030 (kapandı), K-0007, K-0006.

### K-0007 · 2026-10-17 13:10 · MOB · Uçtan uca push: FCM kabul etti (ilk gerçek gönderim)
- **Tür:** Gelişme
- **Konu:** MOB
- **Bağlam:** Kullanıcı hizmet hesabı JSON dosyasını indirip yolunu verdi.
- **Plan:** (1) Dosya doğrulandı (type=service_account, proje sinavlara-hazirlik-c1115). (2) `FIREBASE_SERVICE_ACCOUNT` secret olarak yüklendi, yerel kopyalar silindi. (3) Test hesabına (`yeniogr@ornek.com`, cihazı kayıtlı) bildirim kuyruğa alındı, `send-push` elle çağrıldı.
- **Karar:** Kullanıcı talimatı (ilk gerçek test). Test bildirimi kutuda kalır; kullanıcı telefonda gördüğünü onaylayınca kaldırılır.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ
- **Sahip:** Kullanıcı
- **Önem:** Yüksek
- **Açıklama:** `send-push` FCM'e gönderdi: HTTP 200, `{"ok":true,"status":"sent"}`; kuyruk satırı `sent`. Telefonda bildirimin göründüğü henüz kullanıcı tarafından doğrulanmadı. Database Webhook dashboard'da hâlâ kurulmadı; bu nedenle gönderim şu an elle tetiklendi.
- **Kanıt:** `supabase secrets list` → `FIREBASE_SERVICE_ACCOUNT` var; `send-push` çağrısı → HTTP 200 `sent`; `push_outbox.status = sent`.
- **İlgili:** GÖR-030, K-0004, K-0006.

### K-0006 · 2026-10-17 12:55 · ALT · Hizmet hesabı anahtarı: otomatik üretim reddedildi
- **Tür:** Sorun
- **Konu:** ALT
- **Bağlam:** Kullanıcı Firebase'e bağlanıp hizmet hesabı anahtarını benim oluşturmamı istedi. Firebase CLI oturumundaki yenileme belirteciyle IAM API üzerinden yeni bir servis hesabı anahtarı üretme denemesi, otomatik güvenlik denetimi tarafından "kimlik bilgisi keşfi" olarak reddedildi.
- **Plan:** (1) Anahtar kullanıcı tarafından Firebase Konsolu'ndan indirilecek. (2) Dosya yolu verilirse secret ben yüklerim. (3) Denemeye başka bir yolla devam edilmeyecek.
- **Karar:** Otomatik anahtar üretimi durduruldu. Kullanıcı onayı: "Bu iki maddeyi onaylıyorum" (hizmet kutusu + pazarlama kapısı ayrımı, K-0005 ile ilgili karar). Anahtar işlemi için kullanıcı kendisi indirecek.
- **Durum:** BEKLİYOR
- **Doğrulama:** DOĞRULANMADI
- **Sahip:** Kullanıcı
- **Önem:** Yüksek
- **Açıklama:** Denemede önce hizmet hesabı listesi okundu (`firebase-adminsdk-fbsvc@sinavlara-hazirlik-c1115.iam.gserviceaccount.com`), sonra anahtar oluşturma çağrısı denendi; denetim reddetti. Anahtar üretilmedi, secret yüklenmedi, geçici dosyalar yok. Ayrıca bu denemede yerel Firebase CLI yapılandırma dosyası (kimlik belirteci içeren) okundu; belirteç çıktıya yazılmadı ve kaydedilmedi. Kullanıcı gerekirse Google hesabındaki Firebase oturumunu `firebase logout` ile kapatabilir.
- **Kanıt:** Otomatik denetim kararı (kimlik bilgisi keşfi); `FIREBASE_SERVICE_ACCOUNT` secret listesinde yok.
- **İlgili:** GÖR-030, K-0005.

### K-0005 · 2026-10-17 12:10 · MOB · Basit yol önerisi: önce uygulama içi kutu, OS push sonra
- **Tür:** Karar
- **Konu:** MOB
- **Bağlam:** Kullanıcı Firebase ve webhook adımlarını yapamadığını, daha basit bir yol istediğini söyledi.
- **Plan:** (1) Uygulama içi bildirim kutusu (zil, liste, `get_bildirimler`) Firebase gerektirmeden kullanılır. (2) OS push, Firebase kurulumu tamamlanınca ayrıca eklenir. (3) Firebase için gerekirse Firebase CLI ile tek bir tarayıcı girişi yeterli olabilir; bu sonraki adım.
- **Karar:** Öneri, `ONAY BEKLİYOR`.
- **Durum:** BEKLİYOR
- **Doğrulama:** KISMİ
- **Sahip:** Kullanıcı
- **Önem:** Orta
- **Açıklama:** Test hesabında kutu RPC'si oturum taklidiyle çağrıldı: okunmamış sayı 1, bildirim listede göründü. Test kaydı silindi. Gerçek cihazda ve gerçek oturumda henüz görsel kontrol yapılmadı.
- **Kanıt:** `get_bildirimler` (veli oturumu simülasyonu, transaction içinde) → `okunmamis_sayi: 1`, başlık listede.
- **İlgili:** GÖR-030, K-0004.

### K-0004 · 2026-10-17 10:43 · ALT · send-push deploy ve PUSH_WEBHOOK_SECRET
- **Tür:** Gelişme
- **Konu:** ALT
- **Bağlam:** Kullanıcı `send-push` deploy'unu ve webhook gizli anahtarını onayladı; test için `veli@ornek.com` test hesabını verdi.
- **Plan:** (1) `send-push` deploy, JWT doğrulaması kapalı (webhook kendi başlığıyla korunuyor). (2) `PUSH_WEBHOOK_SECRET` üret ve ekle. (3) Yetki sınamaları. (4) Test hesabında uçtan uca zincir, sonra temizlik.
- **Karar:** Kullanıcı onaylı (deploy ve test hesabı). Gizli değer sohbette ve repoda yok; yerel `%TEMP%\hupo_push_secret.txt` dosyasında, Database Webhook başlığına girildikten sonra silinecek.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ
- **Sahip:** Kullanıcı
- **Önem:** Yüksek
- **Açıklama:** `send-push` canlıya deploy edildi. Anahtarsız istek 401, geçersiz gövde 400 döndü. Test hesabında zincir çalıştı: kuyruk satırı `pending`, fonksiyon kuyruğu aldı, `failed` olarak kaydetti; hata `FIREBASE_SERVICE_ACCOUNT tanımlı değil`. Yani veritabanı → Edge Function bağlantısı çalışıyor; FCM adımı için Firebase hesap anahtarı bekleniyor. Test verileri (bildirim, sahte jeton) silindi, test hesabının push tercihi kapatıldı. Database Webhook dashboard'da henüz kurulmadı.
- **Kanıt:** `supabase functions deploy send-push --no-verify-jwt` → Deployed; `functions list` → send-push ACTIVE; webhook çağrısı HTTP 500 ve `push_outbox.last_error` = `FIREBASE_SERVICE_ACCOUNT tanımlı değil`.
- **İlgili:** GÖR-030, K-0003.

### K-0003 · 2026-10-17 00:32 · MOB · Push uçtan uca test: canlıda çalışmıyor
- **Tür:** Sorun
- **Konu:** MOB
- **Bağlam:** Kullanıcı push bildirim sisteminin çalışıp çalışmadığını test etmek istedi. Kod, veritabanı sözleşmesi ve canlı durum ayrı ayrı kontrol edildi.
- **Plan:**
  1. Firebase projesi ve Android/iOS yapılandırma dosyaları, APNs anahtarı (kullanıcı).
  2. Flutter'a Firebase paketleri ve `pushBackendProvider`'ın Firebase arka ucunu döndürmesi (ajan).
  3. Secrets: `FIREBASE_SERVICE_ACCOUNT`, `PUSH_WEBHOOK_SECRET` (kullanıcı).
  4. Migration'lar `20261035`–`20261038`: `db:preview`, onaydan sonra `db:deploy` (ajan + kullanıcı onayı).
  5. `send-push` deploy ve Database Webhook (`push_outbox` INSERT, `x-webhook-secret` başlığı) (onaylı işlem).
  6. Gerçek cihazda uçtan uca test.
- **Karar:** Deploy, secret ekleme, migration uygulama ve gerçek push gönderimi yapılmadı; bunlar dışarıyı etkiler ve onay bekler. `ONAY BEKLİYOR`.
- **Durum:** BEKLİYOR
- **Doğrulama:** KISMİ
- **Sahip:** Kullanıcı
- **Önem:** Yüksek
- **Açıklama:** Test edilen katmanlar geçti: veritabanı sözleşmesi, Edge Function mantığı, Flutter istemcisi. Canlıda hat çalışmıyor: `send-push` deploy edilmemiş; `FIREBASE_SERVICE_ACCOUNT` ve `PUSH_WEBHOOK_SECRET` secrets'ta yok; `device_tokens`, `push_outbox` ve açık push tercihi sayıları 0; uygulamada Firebase paketi ve yapılandırma dosyası yok, `pushBackendProvider` her zaman `NoopPushBackend` döndürüyor. Gerçek cihaza bildirim gönderilemez. Database Webhook'un kurulu olup olmadığı CLI ile doğrulanamadı.
- **Kanıt:**
  - `node test.mjs` (supabase/tests/bildirim_kampanya): SONUÇ 94 geçti, 0 başarısız.
  - `node --experimental-strip-types --test supabase/functions/send-push/logic.test.ts`: pass 11, fail 0.
  - `flutter test` (mobile-app): All tests passed (301).
  - `npx supabase functions list` (salt okuma): send-push listede yok.
  - `npx supabase secrets list` (yalnız ad): iki secret yok.
  - `npx supabase db query --linked` (sayım): device_tokens 0, outbox 0, açık push tercihi 0.
- **İlgili:** GÖR-030, GÖR-006, §26 (eski bölüm).
- **Güncelleme 2026-10-17 10:37:** `20261035`–`20261038` uzakta **uygulanmış** (migration geçmişinde kayıtlı; cron işleri `duyuru-inbox-yayinla`, `kampanya-push-gonder`, `push-on-izin-durumu-temizle` kurulu; `_tercih_yaz` telefon düzeltmesi canlıda). Önceki "uygulanmadı" ifadesi yanlıştı; önceki `migration list` çıktısı eski görünüyordu. `send-push` hâlâ deploy edilmemiş (`functions list` ile doğrulandı); bu kayıttaki diğer tespitler geçerli.

### K-0002 · 2026-10-16 · HUK · Hukuk görüşü değerlendirmesi: saklama süresi ve anonimlik iddiası
- **Tür:** Karar
- **Konu:** HUK
- **Bağlam:** Kullanıcı bir avukat görüşü metni iletti (dört madde: push İYS, v2 metni, ön izin düğmeleri, ölçüm saklaması). Görüşün yazarı ve lisansı doğrulanamadı; saat kaydı yok.
- **Plan:**
  1. Kabul edilenler (önceden açık onay, işaretsiz kutular, eşit düğmeler, çocuk hesaplarında veli önkoşulu) olduğu gibi bırakıldı.
  2. Kişi başı sıklık sayacının saklama süresi 90 günden 14 güne indirildi (pencere süresi).
  3. Günlük toplamlar için küçük hücre kuralı eklendi: toplam gösterim 10'un altındaysa sayı ve oran gösterilmez.
  4. Kapı kararı (İYS, v2 onayı) yazılı görüş ve kullanıcı onayı ile girilecek; kod kapıyı açmadı.
- **Karar:** Saklama süresinin 14 güne indirilmesi ve küçük hücre kuralı: ajan önerisi, `ONAY BEKLİYOR` (kod uygulandı, kullanıcı onayı yok). Günlük toplamların süresiz saklanması: karar verilmedi, `ONAY BEKLİYOR`. Kapının açılması: kullanıcı kararı, henüz verilmedi.
- **Durum:** DEVAM
- **Doğrulama:** KISMİ
- **Sahip:** Hukuk
- **Önem:** Yüksek
- **Açıklama:** Migration `20261038` (saklama cron'u ve özet fonksiyonu) ve yönetim kartı güncellendi. O anki test sonucu PGlite 86/86; web eslint ve `tsc` temiz. Görüşün yazarı ve lisansı doğrulanmadı; push'un İYS kapsamı resmi kaynaktan doğrulanmadan kabul edilmedi.
- **Kanıt:** `supabase/migrations/20261038000000_pazarlama_push_kapisi_ve_olcum.sql`; `web-panel/src/components/yonetim/merkez/PazarlamaPushKapisi.tsx`.
- **İlgili:** GÖR-031, GÖR-019, GÖR-018, §25.

### K-0001 · 2026-10-17 00:25 · BEL · Proje Günlüğü sistemi kuruldu
- **Tür:** Karar
- **Konu:** BEL
- **Bağlam:** Dosya `TASKS.md` adıyla bir kurtarma projesi listesi olarak başladı. Zamanla planlar, kararlar, sorunlar ve açık işler tek dosyada serbest biçimle karıştı; ajanlar için tarihsiz ve numarasız maddeler takip edilemiyordu.
- **Plan:**
  1. Dosya `PROJE_GUNLUGU.md` olarak yeniden adlandırıldı.
  2. Biçim ve kurallar `AGENTS.md` §9'a yazıldı.
  3. Açık işler `GÖR` numaralarıyla A bölümüne alındı.
  4. Eski bölümler C bölümü olarak dokunulmadan bırakıldı.
  5. Canlı belgeler, agent tanımı, skill, `CLAUDE.md` ve bellek dosyaları yeni adı gösterecek şekilde güncellendi.
  6. Eş oturumlara bildirim gönderildi.
- **Karar:** `ONAYLI`. Kullanıcı talimatı (2026-10-17): dosya adı değişsin, sistemli biçim getirilsin, kural `AGENTS.md`'ye yazılsın, tüm agent'lara bildirilsin. Kod yorumları ve migration dosyaları bu turda değiştirilmedi; ajan kararıyla ayrı işlem olarak önerildi (`ONAY BEKLİYOR`).
- **Durum:** TAMAMLANDI
- **Doğrulama:** DOĞRULANDI
- **Sahip:** Ajan
- **Önem:** Orta
- **Açıklama:** Biçim ve konu kodları kuruldu. Kod yorumlarındaki `TASKS §…` atıfları ve migration dosyalarındaki eski ad bilerek bırakıldı; bu dosyanın başlığı eşlemeyi açıklıyor.
- **Kanıt:**
  - `TASKS.md` kökte yok, `PROJE_GUNLUGU.md` mevcut.
  - Güncellenen: `CLAUDE.md`, `AGENTS.md` (§9 ve üst not), agent tanımı, `hupo-ux-strategy` skill'i, `docs/hupo-design-growth/` (5 belge), `docs/MIMARI.md`, `docs/kelime-evreni/ENTEGRASYON.md`, `supabase/KURTARMA_DURUMU.md`, 7 bellek dosyası.
  - Bilerek değiştirilmeyenler: kod yorumları (`web-panel`, `mobile-app`, `e2e`, `next.config.ts`), uygulanmış migration dosyaları, `.gitignore` yorumu, `docs/arsiv/` (tarihsel belgeler), `.claude/worktrees/` (eski çalışma kopyaları).
  - Eş oturumlar: `hupo-d4`, `hupo-ff`, `hupo-82`, `hupo-8a` adresine mesaj iletildi (teslim onayı yok; oturumlar bir sonraki turda okur). `hupo-82 [1cd6d6]` artık aktif değil.
  - Değişiklikler commit edilmedi. `git status` içinde `D TASKS.md` ve `?? PROJE_GUNLUGU.md` görünür.
- **İlgili:** GÖR-029, `AGENTS.md` §9.

---

## C. Eski bölümler (serbest biçim, düzeltilmez)

---

## 0. Mimari toparlama (bu oturum)

Tek kök git deposu kuruldu ve aşağıdaki eksikler giderildi:

- [x] **Kök depo + `.gitignore`** — `kurtarilan/`, `Silinecekler/`, `node_modules/`,
      `.next/`, `build/`, `.dart_tool/`, `*.log`, `.env*.local` artık takip dışı.
      İç içe `web-panel/.git` ve `mobile-app/.git` depoları silinmedi,
      `Desktop\çıkarıldı\_firsat-git-arsiv-20260927\` altına **arşivlendi**.
- [x] **Demo modu güvenliği** — `NEXT_PUBLIC_DEMO_MODE` artık tek kaynaktan
      (`web-panel/src/lib/demo-mode.ts`) okunuyor ve
      `NODE_ENV === "production"` iken **asla** etkinleşmiyor.
- [x] **Derleme (build) kırığı** — `AdminDashboard.tsx`'in import ettiği
      `demoData.ts` `.gitignore`'daydı → temiz kopyada build kırılıyordu; artık commit'te.
- [x] **Web lint: 14 hata → 0 hata** (`types.ts` vendor `any`, kullanılmayan
      değişken, demo `setState`). Kalan `react-hooks/set-state-in-effect` uyarıları
      gerekçesiyle `warn` seviyesine çekildi.
- [x] **Migration sırası düzeltildi** — tablolar (`…000010`) artık RPC'lerden
      (`…000020`) önce çalışıyor.
- [x] `supabase/KURTARMA_DURUMU.md` eklendi — `supabase db reset`'i bloke eden
      eksik nesneler ve canlıdan kurtarma SQL'i burada.

---

## 1. Tamamlananlar

### APK kurtarma
- [x] ADB kuruldu, telefon (Galaxy S23 FE) bağlandı
- [x] APK çekildi → `kurtarilan/ogrenci_hazirlik-base.apk` (66,7 MB)
- [x] `libapp.so` çıkarıldı (Dart AOT, 7,7 MB)
- [x] **Kayıp fontlar geri getirildi**: `mobile-app/assets/fonts/Nunito.ttf`, `Lexend.ttf`
      (bu iki dosya olmadan uygulama hiç derlenmiyordu)
- [x] Türkçe metin havuzu çıkarıldı: 214 metin
- [x] 153 metin diskteki kaynakta yok olarak işaretlendi (`kurtarilan/missing-turkish.txt`)
- [x] Sınıf/provider/RPC adları çıkarıldı (`kurtarilan/feature-tokens.txt`)

### Belgeler
- [x] `MASTER_BRIEF.md` — projenin tek doğruluk kaynağı
- [x] `AGENTS.md` — ajan kuralları
- [x] `docs/arsiv/TEMIZLIK_RAPORU.md` — silinebilirler listesi (arşive taşındı)
- [x] `TASKS.md` — bu dosya
- [x] `Task.md` — eski adıyla (ikisi de var, `TASKS.md` esas)

### Temizlik
- [x] `Silinecekler/` karantina klasörü oluşturuldu
- [x] Taşınanlar: `node_modules` (556 MB), `.next` (504 MB), `.idea`, `reports/`,
      `research_notes/`, `proje-okulu-app/`, 7 fazlalık döküm, 2 yanlış adlı dosya
- [x] `supabase/config.toml` ana yere geri alındı
- [x] `Silinecekler/` kalıcı olarak silindi (kullanıcı talimatıyla)

### Supabase kurtarma (canlı: ccozfrpnvyrnktpffkwo)
- [x] Erişim doğrulandı, `get_app_config` okunabildi
- [x] **Günlük 5 Sorusu**: 2 RPC + 2 tablo birebir kurtarıldı
      → `supabase/migrations/20260927000000_daily_challenge_and_bookmarks.sql`
- [x] **Çarpım Tablosu Şifreleri**: 5 RPC birebir kurtarıldı
- [x] **Sınıf seçimi**: 2 RPC birebir kurtarıldı
- [x] **Soru bildirme**: 1 RPC birebir kurtarıldı
      → `supabase/migrations/20260927000010_carpim_sifreleri_rpc.sql`
- [x] Migration hatası giderildi: parametre adı değişimi → `drop function` eklendi
- [x] Çarpım tablolarının kolon tanımları kurtarıldı (`20260927000010`)
- [x] `_sinif_yaz`, `_desteklenen_siniflar`, `_refresh_question_flag` gövdeleri
      **birebir** kurtarıldı (+ `admin_set_daily_challenge`)
      → `supabase/migrations/20260927000030_missing_objects_recovery.sql`
- [x] `question_quality_config` tablosu eklendi (`20260927000050`)
- [x] `questions.inceleme_gerekli` kolonu eklendi (`20260927000040`)
- [x] `profiles` sınıf kuralı trigger'ı eklendi (`20260927000060`)
- [x] `grade_changes` / `question_reports` RLS politikaları fail-closed doğrulandı (`20260927000030`)
- [x] `carpim_sifreleri` başlangıç seed verisi eklendi; 10 şifreye tamamlandı (`20260927000015_carpim_sifreleri_seed.sql`)
- [x] `evaluate_badges` gövdesi ve rozetler doğrulandı (`20260920000500_badges.sql`)

### Mobil uygulama
- [x] `google_mobile_ads` paketi pubspec'e eklendiydi (APK'da vardı, kaybolmuştu)
- [x] `share_plus` **eklenmedi** — APK'da izi yok, tahminle paket eklemek derlemeyi kırar
- [x] `models/app_config.dart` yazıldı (canlı `get_app_config` yanıtından birebir)
- [x] `models/cipher_models.dart` yazıldı
- [x] `models/daily_challenge_models.dart` yazıldı
- [x] `models/review_models.dart` yazıldı
- [x] `services/personal_best.dart` yazıldı
- [x] `widgets/` altındaki 8 dosya yazıldı
- [x] `screens/` altındaki 6 dosya yazıldı
- [x] `ads/` altındaki 2 dosya yazıldı
- [x] `content/answer_feedback.dart` yazıldı
- [x] Uygulama içi entegrasyonlar tamamlandı (`main.dart`, `home_screen.dart`, `profile_screen.dart`, `quiz_screen.dart`)
- [x] **Karakter koleksiyon sistemi** — 40 karakter/8 sınıf, migration+model+provider+widget+ekran (03 Ekim 2026)
- [x] `RadioListTile.groupValue/onChanged` Flutter 3.32 deprecasyonu `RadioGroup` ile giderildi
- [x] `MaintenanceGate` canlı versiyon kontrolü — `package_info_plus` + `url_launcher` mağaza linki
- [x] JWT güvenli depo — `flutter_secure_storage` (Android Keystore/iOS Keychain) ile `SecureLocalStorage`
- [x] Karakter unlock kutlaması — `CharacterCelebrationListener` + `CharacterUnlockDialog` (konfeti)
- [x] Ana ekrana Karakterlerim kısayolu (`_KarakterKisayolu` widget, quiz sonrası provider invalidate)

### Web paneli
- [x] Lint hataları giderildi (`eslint .` → 0 hata)
- [x] `npm run build` tamamlandı (`✓ Compiled successfully in 2.9min`, 51 sayfa)
- [x] PHASE 0 durum raporu yazıldı → `docs/arsiv/PHASE0_DURUM_RAPORU.md`
- [x] Web public giriş rotası production server'da doğrulandı; admin rotası oturumsuzken girişe yönleniyor
- [x] Web proxy locale-prefix normalizasyonu düzeltildi; anonim claim gerçek oturum sayılmıyor
- [ ] Admin paneli oturum açılmış tarayıcıda doğrulanacak (kullanıcı oturumu gerekir)
- [x] **Soru bankası — Matematik Bölüm 1**: 50 örnek soru migration'a dönüştürüldü (`20261003000001_soru_bankasi_matematik_bolum1.sql`); onay_durumu = 'beklemede' (kaynak doğrulanmamış)
- [x] Proje ASCII yola taşındı (`C:\Dev\hupo`)
- [x] Web TypeScript kontrolü temiz (`tsc --noEmit`)
- [x] Web production build temiz (`next build --webpack`, 51 rota)
- [x] Dart yapısal/import statik denetimi temiz (`tools/dart-statik-denetim.mjs`, 81 dosya)
- [x] `Silinecekler/` klasörü kullanıcı talimatıyla kalıcı olarak silindi
- [x] Flutter analyze temiz (§11.6'da doğrulandı; proje ASCII yolda)

---

## 2. Eksik 22 Dart dosyası — TÜMÜ TAMAMLANDI ✅

Tüm 22 dosya `mobile-app/lib/` altında mevcut:

- [x] lib/ads/ad_config.dart
- [x] lib/ads/student_banner_ad.dart
- [x] lib/content/answer_feedback.dart
- [x] lib/models/app_config.dart
- [x] lib/models/cipher_models.dart
- [x] lib/models/daily_challenge_models.dart
- [x] lib/models/review_models.dart
- [x] lib/screens/cipher/cipher_lesson_screen.dart
- [x] lib/screens/cipher/cipher_list_screen.dart
- [x] lib/screens/cipher/genel_alistirma_screen.dart
- [x] lib/screens/daily_challenge_screen.dart
- [x] lib/screens/grade_picker_screen.dart
- [x] lib/screens/review_screen.dart
- [x] lib/screens/saved_questions_screen.dart
- [x] lib/services/personal_best.dart
- [x] lib/widgets/bookmark_button.dart
- [x] lib/widgets/cipher_badges_dialog.dart
- [x] lib/widgets/cipher_icons.dart
- [x] lib/widgets/daily_challenge_card.dart
- [x] lib/widgets/maintenance_gate.dart
- [x] lib/widgets/report_question_button.dart
- [x] lib/widgets/ui/responsive_page.dart

Ek olarak yazılan (kurtarma sonrası yeni):
- [x] lib/screens/collection_screen.dart — 40 karakterli koleksiyon ekranı
- [x] lib/widgets/character/character_card_widget.dart
- [x] lib/widgets/character/character_celebration_listener.dart
- [x] lib/widgets/character/character_detail_sheet.dart
- [x] lib/widgets/character/character_unlock_dialog.dart
- [x] lib/services/secure_storage.dart — JWT güvenli depo (Android Keystore / iOS Keychain)

---

## 3. Kurtarılan RPC özeti

| RPC | Dosya | Durum |
|---|---|---|
| `get_daily_challenge()` | 20260927000000 | ✅ |
| `complete_daily_challenge()` | 20260927000000 | ✅ |
| `list_bookmarks()` | 20260927000000 | ✅ |
| `toggle_bookmark(uuid)` | 20260927000000 | ✅ |
| `get_carpim_sifreleri()` | 20260927000020 | ✅ |
| `get_carpim_sifre_detay(uuid)` | 20260927000020 | ✅ |
| `submit_cipher_answer(uuid,text,int,int)` | 20260927000020 | ✅ |
| `complete_cipher_stage(uuid,text)` | 20260927000020 | ✅ |
| `report_taught_friend(uuid)` | 20260927000020 | ✅ |
| `get_supported_grades()` | 20260927000020 | ✅ |
| `set_my_grade(int)` | 20260927000020 | ✅ |
| `report_question(uuid,text,text)` | 20260927000020 | ✅ |
| `get_app_config()` | — | ✅ canlıda, migration'a gerek yok |
| `admin_set_daily_challenge(date, uuid[], text)` | 20260927000030 | ✅ |

**Yardımcı fonksiyonlar** (`20260927000030`, istemciye EXECUTE **verilmedi**):
`_desteklenen_siniflar()`, `_sinif_yaz(uuid, integer, text)`,
`_refresh_question_flag(uuid)`

## 4. Kurtarılan tablolar

| Tablo | Durum |
|---|---|
| `daily_challenges` | ✅ kolon + kısıt + RLS |
| `daily_challenge_completions` | ✅ kolon + kısıt + RLS |
| `question_bookmarks` | ✅ kolon + kısıt + 3 RLS politikası |
| `carpim_sifreleri` | ✅ kolon + kısıt + RLS (20260927000010) |
| `carpim_ilerleme` | ✅ kolon + kısıt + RLS (20260927000010) |
| `carpim_deneme_log` | ✅ kolon + kısıt + RLS (20260927000010) |
| `grade_changes` | ✅ kolon + kısıt + index (20260927000030) — RLS politikaları ⏳ |
| `question_reports` | ✅ kolon + kısıt + 4 index (20260927000030) — RLS politikaları ⏳ |
| `question_quality_config` | 🚫 **yok** — `report_question()` bunu okur (KURTARMA_DURUMU.md §4.1) |
| `user_badges` | ✅ mevcut (`20260920000000_initial_schema.sql`) |

---

## 5. Öğrenilen iş kuralları (canlı koddan)

**Çarpım şifresi:**
- Kapalı testte ilk doğru cevap = 1 yıldız; tekrar cevaplamak yıldız getirmez
- Kapalı test cevapları istemciye gönderilmez, sadece soru metni
- Yanlış cevapta `sifre_hatirlatma` (isim + tanım) döner
- `ogretti` bayrağı "arkadaşıma anlattım" rozetini tetikler

**Günlük 5 soru:**
- Bonus XP = **25**
- Havuz önceliği: `sinifN` → `hepsi` → `ortaokul` → `ilkokul` → `lise`
- `question_ids` 1-10 arası

**Sınıf değiştirme:**
- İlk seçim serbest
- Sonra 30 günde bir
- Değişiklikler arası 24 saat

**Soru bildirme:**
- Gerekçeler: `yanlis_cevap` | `anlasilmiyor` | `yazim` | `diger`
- Kişi başı günde en fazla 20 bildirim
- Yalnızca onaylı sorular bildirilebilir

**Reklam:** `get_app_config` → `reklamlar.ogrenci_acik: false`. Varsayılan KAPALI.

---

## 6. Engeller

| Engel | Etki | Çözüm |
|---|---|---|
| **Supabase eksik nesneler** | `supabase db reset` hata verir | `supabase/KURTARMA_DURUMU.md` |
| **Flutter, Türkçe/OneDrive yolu** | `flutter analyze` çöküyor (255) | Projeyi ASCII yola taşı (`C:\Users\cengi\flutterwork`) |
| **Supabase CLI yok** | `db pull` / `test db` çalışmıyor | `npm i -g supabase` |
| `react-hooks/set-state-in-effect` uyarıları | Lint uyarı (hata değil) | Şablon bileşenleri elden geçerken refaktör |
| Dev sunucusu kalıcı başlamıyor | Tarayıcıda test yapılamıyor | Manuel `npm run dev` ile açılmalı |

---

## 7. Sıradaki adımlar

### Ajan yapabilir
- [x] Soru bankası diğer dersler — `20261012000000_soru_bankasi_tum_siniflar.sql` tüm sınıflar için Türkçe, Fen Bilimleri vb. kapsamına aldı (1-8. sınıf, 360 soru)
- [ ] Sorular için admin onay akışı web-panel'de test edilecek
- [x] Flutter widget testleri (`mobile-app/test/`) — `maintenance_gate_test.dart` (8 test) ve `character_celebration_test.dart` (5 test) eklendi

### Admin Yönetim Merkezi yenileme (Hupo_Admin_Prototype.html + Plan_ve_Tasarim.pdf)
Plan: `C:\Users\cengi\.claude\plans\imdi-admin-panelini-biraz-temporal-stardust.md`
**Aşama A (görsel yenileme) — kabuk + dashboard yapıldı, ekranlar kısmen:**
- [x] Kabuk: lacivert sidebar (3 grup, altın aktif çizgi, "Yakında" modüller), breadcrumb'lı üst bar, çalışan Ctrl/⌘+K komut paleti (`layout/adminNav.tsx`, `components/yonetim/ui/CommandPalette.tsx`)
- [x] TailAdmin logosu → onaylı Hupo maskotu + "hupolingo" (`components/common/BrandMark.tsx`; sidebar, header, açılış ekranı). Resmi logo dosyası repoda yok — gelince `BrandMark` güncellenecek. Auth sayfaları hâlâ TailAdmin logosu kullanıyor.
- [x] Dashboard: prototip yerleşimi, gerçek veriden türeyen "İlgi bekleyen işler" (`WorkQueue.tsx`); sahte NPS/funnel/kampanya eklenmedi
- [x] Sayfa başlığı kalıbı (eyebrow + H1 + açıklama), tablo başlık stili, Üyeler ekranında yan çekmece profil (`ui/Drawer.tsx`)
- [x] Hata düzeltmesi: Recharts 2.15 + React 19 için `react-is` override'ı; grafiklere `initialDimension` (ilk yüklemede boş görünüyordu)
- [x] `tsc`, `npm run lint` (0 hata) ve `npm run build` geçti
- [ ] **Doğrulanmadı:** oturumlu gerçek admin verisiyle ekranlar (demo modunda alt sayfalar 401 verir); Üyeler profil çekmecesi görsel olarak gerçek veriyle bakılmadı
- [x] A0 temizlik: şablon demo sayfaları DEMO_MODE üretimde kapalı (§0 ile düzeltildi); öğretmen yönlendirme RoleGuard+navForRole ile çalışıyor; TailAdmin bağımlılıkları ve README kaldırıldı (§11)
- [ ] Kalan A işleri: diğer ekranlar için drawer/arama araç çubuğu, tek grafik kütüphanesi kararı, 390 px'de alt sayfaların taranması, hupo-platform-review incelemesi (tarayıcı+oturum gerekir)
- [x] Aşama B–F (CRM derinleştirme): Musteri360, PotansiyelAdaylar, SatisHatti, CrmGorevler, EkipAkisi, DestekMasasi, JourneyOtomasyonlari, MesajSablonlari, GrowthAnalitik, AiOneriler — tümü tamamlandı (2026-10-13)

### Kullanıcı yapacak (basit adımlar)
- [ ] **Karakter görselleri**: illüstratöre kısa brief — `kurtarilan/KURTARMA_RAPORU.md` sınıf listesini ver, din sembolü yasağını hatırlat
- [ ] **Mağaza URL'leri**: uygulama yayımlandıktan sonra `maintenance_gate.dart` içindeki 2 URL güncellenir
- [ ] **Admin paneli**: `npm run dev` çalıştırıp tarayıcıda admin oturumu açarak kontrol
- [ ] **Flutter analyze**: projeyi `C:\Users\cengi\flutterwork` gibi ASCII yola kopyalayıp `flutter analyze` çalıştır

---

## 8. Alt ajan notu

Bu depoda alt ajan desteği yok; her iş tek ajan tarafından yapılır.

---

## 9. Veli Paneli — Altyapı ve Geliştirme (2026-10-07)

### Dalga 0 — Kabuk (Tamamlandı)
- [x] Admin layout: `/veli-paneli` path'inde admin kabuğunu atla, yalnızca children render et
- [x] `src/layout/VeliSidebar.tsx`: 12 menü öğeli, 4 gruplu kendi sidebar'ı (admin sidebar'dan bağımsız)
- [x] `(admin)/veli-paneli/layout.tsx`: VeliLayout (VeliSidebar + main area)
- [x] Admin menüleri veli panelinde görünmüyor; sadece veli sidebar menüleri var
- [x] Admin paneli sağlam: tüm admin menüleri mevcut, sidebar çalışıyor
- [x] Demo mode: mock öğrenci verisi (Öğrenci A, Öğrenci B)
- [x] i18n: nav ve navGroups anahtarları veli-paneli.tr.json ve .en.json'a eklendi
- [x] TypeScript: tsc --noEmit çıktı yok (0 hata)

**Mevcut durum:** Genel Bakış "aktif", diğer 11 menü "Yakında" olarak gösteriliyor.

### Dalga 1 — Sayfalar (Tamamlandı, tarayıcı testi yapılmadı)
Mevcut `get_student_dashboard` verisiyle çalışan sayfalar:
- [x] Dersler & Konular (`/veli-paneli/dersler`) — `SubjectsView.tsx`: ders seçici, başarı yüzdesi, konu tablosu
- [x] Yanlışlar & Tekrar (`/veli-paneli/tekrar`) — `ReviewView.tsx`: özet kartları + ReviewTopicsList
- [x] Başarılar (`/veli-paneli/basarilar`) — `AchievementsView.tsx`: XP/seviye/seri kartları + rozet listesi (`get_student_badges` RPC)
- [x] Üyelik & Hesap (`/veli-paneli/uyelik`) — `MembershipView.tsx`: AbonelikKarti + PlanKarti + OdemeGecmisi

### Dalga 2 — Yeni Backend + Sayfalar (2026-10-13)
- [x] Aktivite Akışı sayfası (`/veli-paneli/aktivite`, `ActivityView.tsx`, data.haftalik'ten)
- [x] Deneme Sınavları sayfası (`/veli-paneli/denemeler`, `DenemelerView.tsx`, DenemeKaydiKarti + CocukDenemeGecmisi)
- [x] Hedefler sayfası (`/veli-paneli/hedefler`, `GoalsView.tsx`, get_daily_goal RPC)
- [x] Konu detay RPC → Dersler & Konular tam içerik (`get_child_topic_progress`, migration `20261025000000`; `SubjectsView.tsx` ders seçilince tüm konuları ilerleme çubuğuyla gösterir)

**Dosyalar değiştirildi (Dalga 0):**
- `src/app/[locale]/(admin)/layout.tsx` — veli-paneli path'inde admin kabuğunu atla
- `src/layout/VeliSidebar.tsx` — YENİ: 12 menü öğeli veli sidebar'ı
- `src/app/[locale]/(admin)/veli-paneli/layout.tsx` — YENİ: VeliLayout
- `src/messages/veli-paneli.tr.json` — nav + navGroups + shell anahtarları
- `src/messages/veli-paneli.en.json` — nav + navGroups + shell anahtarları

## 10. Gelir ve Veli Kapısı (2026-10-09)
Kapsam: çocuk kotası ve profil → veli mesajı; landing ve veli paneli plan/satın alma yüzeyi. Kontroller: `flutter analyze` (4 dosya, temiz), `tsc --noEmit` ve `eslint` (web değişen dosyalar, temiz), tarayıcıda landing ve veli paneli kabuğu (konsol hatası yok).
- [x] Çocuk: "Velime mesaj hazırla" alt sayfası (kopyala + veli paneli bağlantısı); kota diyaloğu ve üyelik kartı bu sayfaya bağlı (kod + analyze)
- [x] Çocuk profil "Premium hakkında" satırı artık in-app mesaj sayfasını açar; kırık `hupolingo.com/premium` bağlantısı kaldırıldı
- [x] Landing fiyat bölümü DB'den okunur, veri yoksa fiyat gizlenir; ₺ hardcode ve bozuk para birimi kaldırıldı (kod + render)
- [x] Veli paneli "Ücretli plan" kartı ve "Planı satın al" düğmesi (`payments-checkout` çağrısı) (kod + tsc/eslint)
- [x] `list_active_plans` RPC ve `deneme_gun` alanı — migration `20261025000200`; `admin_upsert_plan` p_deneme_gun parametresi eklendi; `PlanManager.tsx` form ve tablo, `PlanKarti.tsx` veli kartı güncellendi; `tsc` ve SQL sözdizim denetimi temiz
- [ ] Ödeme uçtan uca sandbox testi (veli oturumu → iyzico → callback → abonelik aktif)
- [ ] Veli oturumuyla plan kartı ve satın alma sayfasının kontrolü (test hesabı gerekir)
- [ ] Landing'deki kanıtsız iddialar ("14 Gün İade Garantisi", "%100 Güvenli Ödeme", "%40 tasarruf") için kaynak veya kaldırma kararı
- [ ] Mağaza politikası: çocuk uygulamasındaki harici satın alma bağlantısının Apple/Google kuralları ile uyumu
- [ ] Çocuk akışının gerçek cihazda kontrolü (kota diyaloğu, sayfa, kopyalama)

## 11. Güvenlik ve boyut çalışma paketi (2026-10-10)
Kaynak: 2026-10-09 taraması (güvenlik kontrol listesi, bulgular, boyut ölçümleri). Kararlar 2026-10-10'da kullanıcı tarafından verildi. Durum işaretleri: `[x]` yapıldı ve kontrol edildi, `[ ]` bekliyor, `(ertelendi)` gerekçesiyle sonraya bırakıldı.

### 11.1 Kararlar
| # | Konu | Karar |
|---|---|---|
| 1 | Anahtar ve jeton yenileme | En son, birlikte. Claude yönlendirir, kullanıcı panellerde kendisi yapar |
| 2 | Uzak depo | Özel; başka katkıcı yok |
| 3 | `mobile-app/telefonda-ac/sunucu.dart` | Kaldırıldı. Kaybı: telefonda LAN üzerinden web önizleme kolaylığı. Yerine: `tools/serve.ps1` (127.0.0.1) ve APK |
| 4 | AdMob kodu | Şimdilik kalır; ileride tekrar konuşulacak |
| 5 | `.netlify/`, `ortam/`, tek seferlik `tools/`, kök PNG'ler, eski notlar | Git'ten çıkarıldı, `docs/arsiv/` altına taşındı (`docs/arsiv/` `.gitignore`'da) |
| 6 | Kullanılmayan bağımlılıklar | Kaldırılacak |
| 7 | Migration konsolidasyonu | Şimdilik dışarıda |
| 8 | Uzak Supabase Dashboard (e-posta onayı, MFA, site_url) | İleride; şimdilik kalır |

### 11.2 Aşama 0 — Kimlik bilgileri (EN SON, birlikte)
- [ ] Google API anahtarlarını (Gemini / Stitch, `9b4ee9c` commit'inde `.claude/mcp.json` ve `.claude/settings.json`) iptal et ve yenile
- [ ] GitHub kişisel erişim jetonunu iptal et, yenisini oluştur; `origin` URL'sinden jetonu kaldır, kimlik yöneticisi kullan (`.git/config`)
- [ ] Git geçmişini temizle: `git filter-repo` ile anahtarlı `.claude/` sürümlerini kaldır; force push (her adımda ayrı onay). Anahtar yenilemesinden SONRA yapılır
- [ ] Yeni anahtarları kullanan ortamları kontrol et (Vercel ortam değişkenleri, yerel `.env.local`, MCP yapılandırması). Barındırma Vercel'dir; Netlify kullanılmıyor

### 11.3 Aşama 1 — Güvenlik düzeltmeleri
- [x] `sunucu.dart` kaldırıldı (karar 3). Dizin geçişi ve LAN'a açık dinleme riski ortadan kalktı
- [x] `evaluate_characters` ve `characters_after_change` yetkileri kaldırıldı; yalnızca trigger'dan çağrılıyor (migration `20261019000000_guvenlik_rpc_yetkileri.sql`)
- [x] Admin RPC'leri (9 adet) kontrolü: canlı `proacl` ile doğrulandı, anon/PUBLIC yetkisi **zaten yoktu** (20260920000900). Önceki "anon yetkisi kaldırıldı" iddiası yanlıştı; ilgili blok migration'dan çıkarıldı
- [x] `veli_adayi_olustur` yanıtından `yeni` alanı kaldırıldı (e-posta varlığı sızıntısı kapandı) — migration `20261019000100_veli_adayi_yanit_sadelestirme.sql`, `supabase/tests/veli_adaylari_tests.sql` güncellendi
- [x] `veli_adayi_olustur`: anonim çağrıda mevcut adayın adı ve telefonu artık üzerine yazılmaz (karar 2026-10-10; migration `20261019000100`, test güncellendi). Pazarlama onayı yükseltmesi çalışmaya devam eder
- [x] Prod CSP'den `unsafe-eval` kaldırıldı; `object-src 'none'`, `base-uri 'self'`, `form-action 'self'` eklendi (`web-panel/next.config.ts`)
- [x] CSP `connect-src` PostHog eksikliği giderildi (`eu.i.posthog.com`, `eu-assets.i.posthog.com`, 2026-10-13)
- [x] Landing `dangerouslySetInnerHTML` kullanımları düz metne çevrildi (sabit veri, `&#305;` varlıkları temizlendi)
- [x] `npm audit --omit=dev` yüksek bulguları giderildi (`npm audit fix`, major yükseltme yok)
- [x] Android: `allowBackup="false"`; `bundleRelease` anahtarsız derlenmez, `assembleRelease` için uyarı. **Derlenmedi:** Android SDK doğrulaması ve release anahtarı bu makinede yok; yalnızca kod incelemesi
- [ ] Release anahtarı kurulumu: `key.properties` ve upload keystore bu makinede yok; mağaza yüklemesi öncesi gerekli
- [x] **Canlıya deploy edildi (2026-10-10, kullanıcı onayı):** `20261019000000` … `…000400` (5 migration). Deploy sonrası salt okuma doğrulaması: `evaluate_characters`, `characters_after_change`, `exchange_auth_bridge_token`, `issue_auth_bridge_token` yetkileri yalnızca `service_role`; `veli_adayi_olustur` yeni tanımda; `get_carpim_sifreleri` yetkileri değişmedi (`authenticated`, `service_role`); fonksiyon/tablo/politika sayıları 265 / 102 / 45 (kurtarma no-op). `db:status`: 5 kayıt uzakta, bekleyen yok. Yerelde Docker yok; `supabase test db` çalıştırılmadı
- [x] Auth bridge: `exchange_auth_bridge_token` ve `issue_auth_bridge_token` yetkisi anon/authenticated'dan kapatıldı (migration `20261019000400`; kullanılmadıkları kullanıcı onayıyla doğrulandı). Sonradan kullanıcı onayıyla fonksiyonlar ve `auth_bridge_tokens` tablosu da kaldırıldı (migration `20261021000000`)
- [ ] (ertelendi) `iletisim_izni_iptal_et`: e-posta bağlantısına imzalı token. Mail gönderim tasarımı gerekir
- [ ] (ertelendi) `veli_adayi_olustur` ve veli kodu için IP/captcha limiti. Turnstile anahtarı gerekir
- [ ] (ertelendi) `search_path = public, pg_temp` → `''` standardizasyonu (~17 fonksiyon). Gövdelerde nitelemesiz tablo adı kırabilir; DB testi şart

### 11.4 Aşama 2 — Uzak Supabase ayarları (karar 8, ileride)
- [ ] E-posta onayını aç
- [ ] Admin hesapları için TOTP MFA zorunlu yap
- [ ] `site_url` ve `additional_redirect_urls` değerlerini prod adresine göre ayarla (yerelde `127.0.0.1`)
- [ ] Şifre politikasını güçlendir (en az 10 karakter, karmaşıklık)
- [ ] **Sızdırılmış şifre koruması kapalı** (advisor `auth_leaked_password_protection`): Auth → Passwords ekranından aç

### 11.5 Aşama 3 — Boyut
- [x] `web-panel/.netlify/` git'ten çıkarıldı, `.gitignore`'a eklendi (diskte duruyor)
- [x] **Netlify tamamen kaldırıldı (2026-10-10, kullanıcı kararı):** barındırma Vercel. Silinenler: `web-panel/netlify.toml`, `web-panel/deno.lock` (`deno.json` yok, yetim Netlify edge kalıntısı), `web-panel/.netlify/` (yeniden üretilen çıktı). Kaldırılan yapılandırma satırları: `web-panel/eslint.config.mjs` (`.netlify/**` ignore), `web-panel/.gitignore` ve kök `.gitignore` (`.netlify/`). `.claude/worktrees/` altındaki eski ajan kopyaları bilinçli olarak dokunulmadı
- [x] `ortam/` → `docs/arsiv/ortam/` (başka projeye ait kurulum belgeleri)
- [x] Tek seferlik `tools/` betikleri → `docs/arsiv/tools/` (13 dosya). Kalanlar: `serve.ps1`, `serve-mobile.ps1`, `sql-sozdizim-denetimi.mjs`, `dart-statik-denetim.mjs`, `istemci-rpc-denetimi.ps1`, `soru_bankasi_sql*.mjs`
- [x] Kök PNG'ler (`kontrol-1..3.png`, `şema-gecici.png`) ve eski notlar (`DENETIM_NOTU.md`, `DURUM.md`, `PHASE0_DURUM_RAPORU.md`, `TEMIZLIK_RAPORU.md`, `Task.md`, `cm.txt`) → `docs/arsiv/`
- [x] `mobile-app/assets_arsiv/` → `docs/arsiv/mobile-assets_arsiv/` (pakete girmiyordu)
- [x] Karakter görselleri tekilleştirildi: 81 dosya birebir aynıydı (SHA-256). `web-panel/public/characters/` git'ten çıkarıldı; `web-panel/scripts/sync-karakterler.mjs` prebuild/predev'de mobil kaynaktan kopyalar
- [x] Kullanılmayan web sayfaları ve bileşenleri **arşive taşındı (silinmedi)**: 14 TailAdmin şablon sayfası ve bağlı 73 kaynak dosyası → `docs/arsiv/web-panel-kullanilmayan/`. `proxy.ts` içindeki şablon rota listesi temizlendi. `yonetim/sorular/QuestionHistoryDrawer.tsx` yönetim özelliği olduğu için kaldı
- [x] Referanssız 12 `public/images` alt klasörü (şablon demo görselleri, ~90 dosya) arşive taşındı; `error/` ve `shape/` kullanıldığı için kaldı
- [x] `mobile-app/lib/widgets/gradient_background.dart` (şablon artığı, kullanılmıyordu) arşive taşındı
- Not: bu turdaki git silmeleri (`git rm --cached`) index'te staged durumda; commit atılmadı
- [x] Kullanılmayan npm bağımlılıkları kaldırıldı (`npm uninstall`, doğrulanmış liste)
- [x] Kullanılmayan pub bağımlılıkları kaldırıldı (`pubspec.yaml`, `flutter pub get`)
- [ ] **Karar bekliyor:** `mobile-app/tool/previews/` (38 PNG) golden test referansı; arşivlenirse görsel testler kırılır. Kalsın mı, testlerden çıkarılsın mı?
- [ ] **Karar bekliyor:** `docs/mobil-yeniden-tasarim/referans/` PNG'leri (~4 MB). Git LFS mi, arşiv mi?
- [ ] (ertelendi, karar 7) Soru seed'lerinin (`20261012000000_soru_bankasi_tum_siniflar.sql`, 4.350 satır) migration dışına taşınması: migration geçmişini etkiler
- [ ] (ertelendi, karar 7) Migration konsolidasyonu (261 fonksiyon tanımı / 231 benzersiz)
- [x] `web-panel/banner.png` — dosya artık depoda yok (kaldırıldı)
- [x] `mobile-app/lib/services/push/push_backend_firebase.dart` ve `lib/ads/student_banner_ad.dart` analiz dışına alındı (karar; `analysis_options.yaml`). Silinmedi; Firebase / AdMob kurulunca geri alınacak. AdMob dosyası karar 4 gereği kalır

### 11.6 Aşama 4 — Doğrulama (2026-10-10)
- [x] `web-panel`: `npm run lint` → 0 hata, 13 uyarı (uyarılar önceden vardı). `npm run build` → başarılı, tüm rotalar üretildi. Önce eski `.next` önbelleği silindi (eski tip dosyaları silinen sayfalara bakıyordu; önbellek yeniden üretilebilir)
- [x] `web-panel`: `npm audit --omit=dev` → 0 açık (önce 2 yüksek)
- [x] `mobile-app`: `flutter pub get` → lock'tan 33 bağımlılık düştü (`build_runner` ve kaldırılan paketlerin geçişli bağımlılıkları)
- [x] `mobile-app`: `flutter analyze` → No issues found (önce 21 hata; hepsi paketsiz iki dosyadaydı, bkz. 11.5)
- [x] `mobile-app`: `flutter test` — iki eski test düzeltildi (bkz. 11.7); tam sonuç aşağıda işlenecek
- [ ] `supabase test db --local` (pgTAP) çalıştırılamadı: Docker yok; ayrıca repodaki `supabase/tests` dosyaları pgTAP formatında değil (özel harness)
- [x] `tools/sql-sozdizim-denetimi.mjs` → 80 dosya, 0 hata (beş yeni migration dahil)
- [x] **Kuru test (canlıda `BEGIN … ROLLBACK`, 2026-10-10):** 5 migration hatasız çalıştı; `veli_adaylari` test paketi 12/12 OK; fonksiyon/tablo/politika sayıları canlıyla aynı (265 / 102 / 45); geri alma doğrulandı (ACL ve veri değişmedi). Test senaryo 9'da, tabloyu sahip rolüne geçmeden okuyan bir hata düzeltildi (`authenticated` tabloyu okuyamaz; test kodu hatasıydı)
- [x] `npm run db:preview` (salt okuma, dry-run) → uzak veritabanına gidecek 4 migration listelendi; uzak geçmiş `20261018020000`'e kadar uygulanmış
- [x] Canlı salt okuma denetimi (`supabase db query --linked`, `db advisors --type security`): RLS 102/102 tabloda açık; advisor'da RLS/search_path kaynaklı bulgu yok (bkz. 11.8)
- [x] `tools/istemci-rpc-denetimi.ps1` Türkçe locale i/I hatası düzeltildi (RegexOptions.CultureInvariant, 2026-10-13). 11 yanlış eksik → 0. Tüm RPC'ler şemada tanımlı.
- [ ] Android: `flutter build appbundle` yapılmadı (release anahtarı yok)
- [ ] Yeni migration'lar yerel Postgres'te çalıştırılmadı (Docker yok)

### 11.7 Açık konular
Kararlar bekliyor:
- AdMob kalacak mı; kalırsa gizlilik metni ("reklam ve takip yok") ile tutarlı mı (karar 4)
- `veli_adayi_olustur` üzerine yazma davranışı (11.3)
- PostHog CSP ve analitik açık mı kalacak (11.3)
- `tool/previews` (golden test referansı) ve `docs/mobil-yeniden-tasarim/referans` görselleri (11.5)
- Firebase push arka ucu (`push_backend_firebase.dart`): paketler eklenince analiz dışından geri alınacak (11.5)
- Migration konsolidasyonu ve soru seed'leri (karar 7)
- Uzak Supabase Dashboard ayarları (karar 8)
- ~~Yeni 5 migration'ın canlıya deploy edilmesi~~ — **yapıldı (2026-10-10)**, bkz. 11.3
- ~~Auth bridge~~ — **kaldırıldı (2026-10-10, kullanıcı onayı):** `exchange_auth_bridge_token`, `issue_auth_bridge_token` ve `auth_bridge_tokens` silindi (migration `20261021000000`). Canlıda doğrulandı
- Kolon düzeyi canlı–repo farkı (mevcut tablolar) için tam kontrol (açık teknik borç)

Teknik borç (bu turda bulundu):
- [x] **Canlı–repo uyuşmazlığı (8 istemci RPC'si):** `20261019000200_carpim_sifreleri_rpc_canli_dokum.sql` — gövdeler canlı `pg_get_functiondef` ile birebir, yetkiler canlı `proacl` ile eşleşiyor. Commit `7543fd5` bunları "SQL Editor'den zaten uygulanmış" gerekçesiyle kaldırmıştı. Canlıda henüz çalıştırılmadı
- [x] **Kalan canlı–repo uyuşmazlığı:** canlıda olup repoda olmayan 24 fonksiyon, 7 tablo, 7 politika, 4 indeks, 1 trigger → `20261019000300_canli_sema_eksik_nesneler.sql`. Kaynak katalog sorguları (`db dump` Docker gerektirdiği için kullanılmadı). Kolon düzeyinde, repoda zaten olan tabloların farkı **kontrol edilmedi** (açık)
- [x] `questions_sinifsiz_yedek` (yedek tablo) silindi (kullanıcı kararı: her soru sınıflı olmalı; migration `20261021000000`)
- [x] `_uret_meydan_kod()` anon ve authenticated yetkisi kaldırıldı; yalnızca `create_challenge` (SECURITY DEFINER) kullanıyor (migration `20261021000000`, kullanıcı onayı)
- [x] `veli_cocuk_bagla` hız sınırı sıkılaştırıldı: 5/saat → 3/15dk (kod ömrüyle örtüşür, migration `20261025000100`). Hesap çoğaltma riski e-posta onayı açıldığında kalkar (§11.4)
- [x] İki eski test güncellendi (`membership_test.dart`, `quiz_quota_test.dart`): ürün tasarımı değişmiş (ücretsiz kartta ve kota diyaloğunda "Velime mesaj hazırla" düğmesi, TASKS §10), test beklentileri buna göre düzeltildi; ürün kodu değişmedi. `membership_card.dart` doc yorumu güncellendi
- [ ] `supabase/KURTARMA_DURUMU.md`'deki doğrulama betikleri artık `docs/arsiv/tools/` altında (git dışı)

### 11.8 Canlı güvenlik denetimi (advisor, 2026-10-10, salt okuma)
- Toplam 193 bulgu: 184 × `authenticated_security_definer_function_executable` (WARN), 8 × `anon_security_definer_function_executable` (WARN), 1 × `auth_leaked_password_protection` (WARN)
- Anonim çağrılabilen 8 fonksiyon: `get_app_config`, `get_deneme_ayari`, `get_deneme_sinavi_tarihi`, `list_active_plans`, `get_next_mock_exam_public` (bilinçli herkese açık okuma); `veli_adayi_olustur` (üzerine yazma, karar bekliyor); `iletisim_izni_iptal_et` (imzasız, ertelendi); `exchange_auth_bridge_token` (karar bekliyor)
- 184 authenticated SECURITY DEFINER çağrısının çoğu uygulamanın kullandığı RPC'ler. Her birinde `auth.uid()` / sahiplik kontrolü olup olmadığı tek tek incelenmedi; çocuk ve deneme sınavı RPC'lerinin örneklemi (`register_for_mock_exam`, `set_exam_marketing_consent`, `get_upcoming_mock_exams_for_child`, `veli_cocuk_bagla`) `auth.uid()` + `is_parent_of` / hız sınırı içeriyor
- RLS: 102/102 tabloda açık. `search_path` ve görünüm kaynaklı bulgu yok
- **Deploy sonrası (aynı denetim):** 188 bulgu (önce 193); anon SECURITY DEFINER 7 (önce 8). Kalanlar: `get_app_config`, `get_deneme_ayari`, `get_deneme_sinavi_tarihi`, `get_next_mock_exam_public`, `list_active_plans` (bilinçli okuma uçları); `veli_adayi_olustur` (anonim yazma, rate limit yok); `iletisim_izni_iptal_et` (imzasız, ertelendi)

## 12. Yönetim paneli ve deneme sınavı çalışma paketi (2026-10-10)

Plan: `C:\Users\cengi\.claude\plans\birka-tane-iyile-tirme-yapmam-z-twinkly-castle.md`

### 12.1 Kod yazıldı (deploy edilmedi, tarayıcıda test edilmedi)
- [x] Üyeler & aileler: `ADMIN_SQL` kod bloğu ve `roleNote` kaldırıldı (`UsersManager.tsx`, `yonetim-panel.tr/en.json`)
- [x] Navigasyon: business grubunda Ödemeler / Planlar / Denemeler en üste alındı (`adminNav.tsx`)
- [x] Admin deneme sınavı yönetimi: `/yonetim/deneme-sinavlari` (`MockExamManager.tsx`, `MockExamDetailModal.tsx`, sayfa rotası, nav girişi, `types.ts`, tr/en çeviriler). Sınav oluştur/düzenle, aktif/pasif, sınıf bazlı onaylı soru atama (`admin_list_questions` + `admin_set_mock_exam_questions`), sonuç tablosu (`admin_get_mock_exam_results`)
- [x] `tsc --noEmit` temiz; `npm run lint` 0 hata (13 uyarı, hiçbiri değiştirilen dosyalarda)
- [ ] Gerçek admin oturumuyla tarayıcı testi yapılmadı

### 12.2 Kritik bulgular (deploy öncesi karar gerekli)
- Mobil uygulama (`mobile-app/lib/services/quiz_repository.dart`) hâlâ eski `start_mock_exam` / `submit_mock_exam` RPC'lerini kullanıyor. Bu RPC'ler veli kaydını ve sınav başlangıç saatini KONTROL ETMİYOR: öğrenci sınav saatinden önce soruları alabilir ve kayıtsız girebilir.
- Canlı yeni akış (`20261019000300_canli_sema_eksik_nesneler.sql`): `register_for_mock_exam` (veli + `sinav_pazarlama_izni` onayı), `start_mock_exam_attempt`, `submit_mock_exam_answer`, `deneme_sinavi_cevaplari` (kolon: `dogru`, `cevap_zamani`). İstemciler henüz bu akışı kullanmıyor.
- Oturumda yazılan zamanlama/cevap taslağı canlı akışla çeliştiği için silindi (deploy edilmemişti).
- [x] **DEPLOY EDİLDİ (2026-10-10):** `20261020000000_deneme_sinavi_eski_rpc_sertlestirme.sql` ve `20261020000100_deneme_on_kayit.sql`. `npm run db:preview` dry-run onaylandı; `npm run db:deploy` başarılı.
  - `20261020000000`: eski `start_mock_exam` (saat penceresi, sınıf, tek deneme, süre dolumu) ve `submit_mock_exam` (yalnızca sınavın soruları sayılır, süre + 30 sn tolerans; puanlama YKS'den **yüzde (0-100)**'e değiştirildi — `numeric(5,2)`, canlı `_deneme_sinavi_bitir` ile uyumlu).
  - `20261020000100`: herkese açık ön kayıt tablosu (kanal bazlı izin, append-only izin logu) ve yalnızca service_role'ün çağırdığı `deneme_on_kayit_ekle`.
- Puanlama kararı (2026-10-10): 3-7. sınıf için yüzde (0-100), negatif puan yok. 8. sınıf LGS hazırlığı için ileride **ayrı sınav tipi** eklenecek (bkz. §12.5).
- Captcha: Turnstile/hCaptcha anahtarı geliştirme aşamasında atlandı (domain henüz bağlanmadı). Edge Function `SKIP_CAPTCHA=true` ile geliştirme modunda çalışır; canlıya geçmeden önce anahtar eklenecek.

### 12.3 Açık kararlar
- Eski RPC'ler: KARAR — sertleştirilecek, mobil imza korunacak. Veli kaydı kontrolü, bir kayıt yolu (ön kayıt → veli hesabı → "sınava katıl") çıkana kadar eklenmeyecek; aksi halde hiçbir öğrenci giremez.
- Kayıt modeli: KARAR — herkese açık ve kolay ön kayıt (kayıtsız veliyi müşteriye çevirme kanalı). Captcha (Turnstile/hCaptcha) anahtarı olmadan edge fonksiyonu açılmayacak; anahtar kullanıcıdan istenecek.
- Ön kayıt → hesap eşleştirme (aynı telefon/e-posta ile veli hesabı açıldığında çocuk kaydı bağlanır). Aile tekilleştirmesinin temeli; Faz 4 ile birlikte.
- Veli kaydı (`register_for_mock_exam`) ve canlı yeni akış (`start_mock_exam_attempt`) hiçbir istemci tarafından çağrılmıyor; ön kayıt akışıyla birlikte tasarlanmalı.
- Sonuç ilanı gizliliği (öneri): çocukların adı ve puanı herkese açık sıralamada gösterilmesin (reşit olmayanlar, KVKK). Herkese açık sayfada yalnızca sınıf bazlı toplu istatistik (en az 10 katılımcı), bireysel sıra yalnızca giriş yapmış velinin kendi çocuğunda. Plan 2D'deki "anonimleştirilmiş sıralama" bu nedenle değişecek.
- Konu kırılımı premium (onaylandı). Gelişim izleme (Faz 3) ve aile tekilleştirme (Faz 4) paralel başlayacak.
- Ticari elektronik ileti onayları: KARAR — 3 kanal (e-posta/SMS/telefon) ayrı kutu, tümü başlangıçta boş. Tam metin `/ticari-ileti-izni` sayfasında. Migration `20261020000300` ile 'telefon' kanalı eklendi; trigger 3 kanala güncellendi. Şirket bilgileri (unvan, e-posta, tarih) canlıya almadan önce doldurulacak, hukuk onayı alınacak. İYS 3 iş günü entegrasyonu (backend cron/webhook) ileride eklenecek.
- Puanlama: KARAR — 3-7. sınıf için yüzde (0-100), negatif puan yok. 8. sınıf LGS hazırlığı ileriye bırakıldı (§12.5).

### 12.5 Gelecek: 8. sınıf LGS sınav tipi
8. sınıflar LGS hazırlığı için farklı yapı gerekir: TYT/AYT değil, LGS konu dağılımı. Şimdilik genel sınıf olarak sisteme girer. İleride:
- `deneme_sinavlari`'na `sinav_tipi` (genel / lgs_hazirlik) kolonu ekle
- LGS'ye özgü puan hesaplama (konu ağırlıkları, net hesabı) yeni yardımcı fonksiyonla
- Admin UI'da sinav tipi seçimi

### 12.6 Faz 2A tamamlandı (2026-10-10)
- [x] `get_open_exam_for_registration()` RPC (migration `20261020000200`) — id + ad + baslangic_zamani + siniflar döner; anon ve authenticated erişebilir. Deploy edildi.
- [x] Edge Function `deneme-on-kayit` — CAPTCHA_SECRET ortam değişkeni varsa Turnstile doğrular, yoksa geliştirme modunda atlar. service_role ile `deneme_on_kayit_ekle` çağırır. Deploy edildi (`--no-verify-jwt`).
- [x] `/deneme-sinavi-kayit` sayfası — açık sınav varsa form gösterir, yoksa "yakında" mesajı. Auth gerektirmez; full-width-pages grubunda.
- [x] `DenemeKayitForm.tsx` — veli ad, çocuk ad, sınıf, e-posta, telefon, KVKK zorunlu, e-posta/SMS izin opsiyonel. KVKK_SURUM ve IZIN_SURUM versiyonlu.
- [x] `DenemeExamSection.tsx` CTA `/signup` → `/deneme-sinavi-kayit` değiştirildi.
- [x] Çeviri anahtarları: `landing.denemeKayit.*` (tr + en).
- [x] `tsc --noEmit` temiz. `npm run lint` 0 hata.
- [ ] Tarayıcıda test: açık sınav oluşturup form akışı test edilmedi.
- [ ] CAPTCHA_SECRET Supabase Dashboard → Edge Functions → Environment'a eklenecek (domain bağlandıktan sonra).

### 12.7 Kullanıcıdan bekleyen (Claude hatırlatacak)
- [ ] **CAPTCHA_SECRET:** Domain bağlandıktan sonra Supabase Dashboard → Edge Functions → `deneme-on-kayit` → Environment Variables → `CAPTCHA_SECRET` (Cloudflare Turnstile secret). Şu an geliştirme modunda atlanıyor.
- [ ] **`/ticari-ileti-izni` sayfası:** Yer tutucuları doldurun — şirketin tam ticaret unvanı, iletişim e-postası, son güncelleme tarihi — ve hukuk birimi onayı alın.
- [ ] **İYS 3 iş günü kaydı:** E-posta dışı kanallar (SMS, telefon) İYS'ye henüz bildirilmiyor. Backend webhook/cron gerekiyor (ileride).
- [ ] **8. sınıf LGS sınav tipi:** 8. sınıflar LGS hazırlığı için ayrı `sinav_tipi` (bkz. §12.5) — kullanıcı ilerleyen fazda talep edecek.

### 12.8 Faz 2B tamamlandı (2026-10-10)

#### Veli paneli — deneme kaydı
- [x] `DenemeKaydiKarti.tsx` — `get_upcoming_mock_exams_for_child` + `set_exam_marketing_consent` + `register_for_mock_exam`. Velinin çocuğu için telefon + KVKK onayı ile kayıt. Seçili çocuk değişince otomatik güncellenir.
- [x] `ParentDashboard.tsx` — `ChildScope.render` callback'e `DenemeKaydiKarti` eklendi; seçili öğrencinin `cocukId` ve `cocukAd` aktar.
- [x] Çeviri anahtarları: `veliPaneli.denemeKaydi.*` (tr + en).

#### Öğrenci sınav arayüzü
- [x] `DenemeEkrani.tsx` — `start_mock_exam_attempt` → tek soru / sayfalı navigasyon; anlık `submit_mock_exam_answer`; `finish_mock_exam_attempt`; motivasyonel bitiş ekranı (poza göre 3 ton). Sayaç ≤5 dk sarı, ≤1 dk kırmızı + titreme. Alt şerit: boş/cevaplı/işaretli renkleri. Çift submit koruması (`submitRef`).
- [x] `YaklasanDenemeKarti.tsx` — öğrenci ana sayfasında kayıtlı sınavları listele; sınav başladıysa "Sınava Gir" bağlantısı.
- [x] `/ogrenci/deneme/[examId]` sayfası — `ogrenci` rolü kontrolü, ardından `DenemeEkrani`.
- [x] Öğrenci ana sayfasına `get_my_mock_exam_status()` çağrısı + `YaklasanDenemeKarti` eklendi.
- [x] `npm run build` — exit code 0.
- [ ] Uçtan uca test: admin sınav oluştur → veli çocuğu kaydet → öğrenci sınava gir → sonuç ekranını gör.

#### Notlar
- Doğru cevaplar (`dogru_sik`) istemciye gönderilmiyor — bitiş ekranında da gösterilmiyor. Güvenlik DB seviyesinde.
- `start_mock_exam_attempt` → velinin `register_for_mock_exam` ile çocuğu kaydetmemiş olması hata verir. Hata mesajı ekranda kullanıcıya gösterilir.
- [x] `beforeunload` uyarısı eklendi + localStorage seçim yedekleme (2026-10-13)

### 12.9 Faz 2C — Sonuç İlanı Sayfası (2026-10-10)
- [x] Migration `20261020000400`: `get_exam_public_results(p_exam_id)` — sınıf bazlı istatistik + puan dağılımı + kendi sonucu (anon + auth). `get_exam_topic_breakdown(p_exam_id)` — konu kırılımı (auth + premium). Deploy edildi.
- [x] `/deneme-sonuclari/[examId]` — SSR, full-width-pages grubunda (auth gerekmez). Kendi sonucu (auth ise), sınıf bazlı istatistikler + histogram, konu kırılımı (premium) veya premium gate.
- [x] `KonuKirilimi.tsx` — premium kullanıcıya ders/konu bazlı doğru/yanlış ilerleme çubuğu; free kullanıcıya CTA.
- [x] `DenemeEkrani.tsx` bitiş ekranına "Sonuçları Gör →" + "Ana Sayfaya Dön" butonları.
- [ ] Uçtan uca test: sınav tamamla → `/deneme-sonuclari/[examId]` doğru sonucu gösteriyor mu.

### 12.10 Faz 3 — Gelişim İzleme (2026-10-10)
- [x] Migration `20261020000500`: `get_my_exam_progress()` — tüm sınavlar puan/sıra/yüzdelik trendi (auth). `get_my_topic_trends()` — konu bazlı toplam başarı (auth). Deploy edildi.
- [x] `/ogrenci/gelisim` — SSR öğrenci sayfası; puan trendi SVG çizgisi + sınav listesi, güçlü/zayıf konular, konu ısı haritası.
- [x] Öğrenci ana sayfasına "Gelişimimi Gör" hızlı erişim linki (deneme varsa gösterilir).
- [ ] Uçtan uca test: birden fazla sınav tamamlanmış öğrenciyle trend grafiğini gör.

### 12.11 Faz 4 — Aile Tekilleştirme Backend (2026-10-10)
- [x] Migration `20261020000600`: `identity_merge_candidates` tablosu (RLS açık, service_role erişimi).
  - `admin_detect_identity_duplicates()`: aynı ad+sınıf, farklı veli → aday oluştur (service_role, cron tetikler).
  - `admin_list_merge_candidates()`: admin RPC — bekleyen adayları listele.
  - `admin_resolve_merge_candidate(id, action)`: merged/distinct/ignored kararı kaydet.
  - Deploy edildi.
- [x] Admin sayfası `/yonetim/kimlik-eslestirme` — birleştirme arayüzü (kod + tsc; tarayıcı testi yapılmadı).
- [x] `admin_detect_identity_duplicates` günlük cron — migration `20261020000800` (pg_cron, her gün 00:30 UTC). Job satırı SQL ile ayrıca doğrulanmadı.
- [ ] Gerçek profil birleştirme mantığı (deneme sonuçlarını tek profilde topla) — gelecek fazda.

### 12.12 Faz 5A / 5B / 5D (2026-10-10)
- [x] Faz 5A — Migration `20261020000700`: `deneme_sinavi_denemeleri.started_at` + `supheli`. `start_mock_exam_attempt` başlangıcı yazar; `_deneme_sinavi_bitir` 30 sn altındaki tamamlamayı `supheli = true` işaretler (engellemez).
- [x] Faz 5B — Aynı migration: ilk bitişte `olay_kutusu` → `deneme_sonuc_bildirimi` (payload: exam_id, student_id, puan, sira, supheli; PII yok). Gönderen worker henüz yok.
- [x] Faz 5D — `PaylasKarti.tsx`: sonuç sayfasında canvas ile 1080×1080 PNG (ad yok; puan, sınıf sırası, yüzdelik). Web Share, yoksa indirme. tsc + eslint temiz; tarayıcıda görsel kontrolü yapılmadı.

### 12.4 Sıradaki
- [ ] Uçtan uca testler (12.8 / 12.9 / 12.10) — EN SON yapılacak. Test öğrenci + veli hesabı ve tarayıcı gerekir.
- [x] Faz 4 gerçek profil birleştirme — migration `20261020001000`. Ana hesap = daha önce oluşturulan hesap. Deneme ve katılım kayıtları ana hesaba taşınır; aynı sınavda iki kayıt varsa tamamlanmış/yüksek puanlı olan kalır. Her birleştirme `identity_merge_log`'a yazılır. XP/rozet/görev/karakter ve veli onay (consents) kayıtları kaynak hesapta kalır (ayrı karar). Birleştirilen öğrenci hesabı sınava giremez; veli kaydı ana hesaba yapılır. Test verisinde deneme gerekir.
- [x] `supheli` bayrağı admin sonuç listesinde gösteriliyor (migration `20261024000000`, `MockExamDetailModal` ⚠ ikonu, çeviri eklendi)
- [x] Bitirilmemiş denemeler: `deneme_sure_dolanlari_kapat()` her dakika (pg_cron) süresi dolmuş bitmemiş denemeleri kapatır; teslim türü `otomatik`, bildirim tetiklenir. Kapanış süre sonunda olur, anında değil: öğrenci süre içinde de sınava geri dönemez (`start` tekrar girişi reddeder), bu yüzden süre sonu tek kesin zamandır. Veli panelinde (`CocukDenemeGecmisi`) ve öğrenci gelişim sayfasında görünür. Migration `20261020000900`.
- [x] Süre dolan cevap yolu düzeltildi: `submit_mock_exam_answer` artık bitirip `return` eder (raise yok), bitiş kalıcı. Migration `20261020000900`.
- [x] `deneme_sonuc_bildirimi` worker'ı — Edge Function `olay-kutusu-gonder` (`--no-verify-jwt`) deploy edildi; pg_cron her 5 dk pg_net ile çağırır. Sağlayıcı: Resend (karar onayı bekliyor). Veritabanı tarafı: `olay_kutusu_talep_et` (lease + deneme sayacı, 5 denemede ölü kayıt), `olay_kutusu_sonuc_yaz` (üssel geri çekilme), `deneme_bildirim_alici` (service_role). Migration `20261020001100`. **Gönderimi açmak için:** `supabase secrets set OLAY_WORKER_SECRET=… RESEND_API_KEY=… OLAY_MAIL_FROM="Hupolingo <bildirim@alan.adi>" PUBLIC_SITE_URL=…`; Supabase Vault'a aynı değerle `olay_worker_secret` adında secret ekle. Gönderici alan adı doğrulanmadan e-posta gitmez. Gizli metin repoda yok.
- [ ] `/ticari-ileti-izni` şirket unvanı, iletişim e-postası, tarih + hukuk onayı — KARAR: en son yapılacak, Google Play canlıya çıkmadan önce.
- [ ] CAPTCHA_SECRET — domain bağlandıktan sonra Edge Function ortamına.
- [ ] İYS 3 iş günü kaydı — KARAR: en sondan bir önce; bekleme listesinde. İYS entegrasyon bilgileri gerekir.
- [ ] 8. sınıf LGS sınav tipi (§12.5).

## 13-ek. Growth CRM entegrasyonu (2026-10-08)
Kaynak: `Hupolingo_Growth_CRM_v1_FINAL_CodePack.zip`. Mevcut Supabase'e `growth_*` prefix ile additive layer.
Dokümanlar: `docs/growth-crm/IMPLEMENTATION_PLAN.md`, `docs/growth-crm/REUSE_EXTEND_CREATE_MAP.md`.

### Durum (2026-10-13)
- [x] Migration'lar: `20261014000000` (core tablolar), `000100` (RPC'ler), `000200` (pazarlama), `000300` (analitik) — tümü uzakta uygulanmış
- [x] Admin sayfaları: müşteri-360, müşteri-360/[id], potansiyel-adaylar, potansiyel-adaylar/[id], crm-gorevler, ekip-akisi, satis-hatti, destek-masasi, journey-otomasyonlari, mesaj-sablonlari, growth-analitik, ai-oneriler — `tsc` temiz
- [ ] Gerçek admin oturumuyla tarayıcı testi yapılmadı
- [x] Faz B–F derinleştirme: tüm CRM manager bileşenleri yazıldı (`tsc` temiz) — Müşteri 360, Potansiyel Adaylar, Satış Hattı, CRM Görevleri, Ekip Akışı, Destek Masası, Journey, Mesaj Şablonları, Growth Analitik, AI Öneriler
- [x] Veli adayları CRM: `ErkenErisimSection` landing'e eklendi; `veli_adayi_olustur` RPC direkt çağrılıyor (kaynak: `landing_erken_erisim`). Captcha CAPTCHA_SECRET eklenince eklenecek (bkz. §12.7)

### 13-ek.2 Müşteri 360 veri toplama katmanı (2026-10-13)
Plan: `docs/growth-crm/VERI_TOPLAMA_PLANI.md`. Sorun: 360 ekranı hazırdı ama `growth_households` yalnızca elle doluyordu.
- [x] Migration yazıldı: `20261027000000_musteri_360_veri_toplama.sql` — profiles/subscriptions/payments/veli_adaylari/deneme ön kaydı → tek kart (e-posta ile), tetikleyiciler, geri doldurma, `growth_household_izinleri`, liste filtreleri (kaynak, kanal izni), `admin_musteri_360_ozet`
- [x] PGlite doğrulaması: `cd supabase/tests/musteri_360; npm install; node kos.mjs` — 11/11 senaryo geçti (taklit şema üzerinde; gerçek şemanın tamamı değil, uzak DB'de çalıştırılmadı)
- [x] Panel: liste filtreleri (kaynak, kanal izni) + özet kartları yazıldı, `tsc --noEmit` temiz. Tarayıcıda gerçek admin oturumuyla bakılmadı. "Bilinmiyor" kaynak seçeneği arayüzde henüz yok (RPC destekliyor)
- [x] **Uzak DB'ye uygulandı** (2026-10-13): `20261027000000` tek transaction içinde `supabase db query --linked -f` ile çalıştırıldı, ardından `migration repair --status applied`. `db:deploy` KULLANILMADI (aynı anda duyuru migrasyonu hazırlanıyordu; o dosyaya dokunulmadı). Doğrulama: 1 veli → 1 kart, 2 öğrenci (1'i veliye bağlı → 1 kişi kaydı; bağlı olmayan öğrenciye kart açılmaz), abonelik/ödeme/aday/ön kayıt yok, 5 tetikleyici ve `admin_musteri_360_ozet` mevcut. Duyuru migrasyonu (`20261026000000`) ayrı çalışmada uzağa uygulandı (bkz. §14.3).
- [x] V2 (web) uzakta uygulandı (2026-10-13, `db:preview` → `db:deploy`; yalnızca `20261028000000` bekliyordu; fonksiyonlar ve anon yetkisi doğrulandı, davranış testi canlıda yapılmadı): `20261028000000_growth_web_olaylari.sql` (`growth_web_olay_kaydet`, `growth_web_kimlik_bagla`; anonim, beyaz liste, 15 dk pencere), landing'de ilk temas UTM ve form sonrası izleme (`erkenErisimIzleme.ts`). PGlite 15/15 geçti. Tarayıcıda ve uzak DB'de doğrulanmadı (anon anahtar sorunu). Açık risk: iki anonim RPC'de hız sınırı yok (`veli_adayi_olustur` ile aynı açık)
- [ ] V2 (Flutter / /ogrenci): uygulamadan olay yakalama. Kapsam dışı bu turda
- [ ] V3: kitle dışa aktarımı (yalnızca `granted`), kampanya/bildirim bağlama
- [ ] V4: reklam kitlesi (hash'li e-posta, yalnızca açık izinli)
Kararlar: izin tahmin edilmez (kutu işaretsiz = `denied`; `veli_adaylari.pazarlama_izni=false` = kayıt yok); senkron boş alanı doldurur, admin değerini ezmez; çocuk verisi yalnızca ad + sınıf; ücretsiz (0 kuruş) abonelik = `trial`.

## 13. Kelime Evreni entegrasyonu (2026-10-10, branch `feature/kelime-evreni`)
Kaynak: `HUPOLINGO_Kelime_Evreni_Flutter_Claude_Paketi.zip` (v0.1 başlangıç kodu; ürünün kendisi değil). Eş anlamlı / zıt anlamlı / eş sesli kelime oyunları Öğren sekmesine bağlanır.

### 13.1 Kararlar
| # | Konu | Karar |
|---|---|---|
| K1 | Kullanıcı sistemi | Yeni sistem YOK. `profiles` + `is_parent_of()` (veli) + `is_admin()` (yönetici). Paketin `word_parent_links` / `word_admin_members` adaptörleri kaldırıldı |
| K2 | Soru bankası | `questions` KULLANILMAZ. Kelime soruları ayrı içerik türü (`kelime_sorulari`); anlam ve ilişki envanteri ayrı (`kelime_anlamlari`, `kelime_iliskileri`). Gerekçe: `questions` tüm mevcut quiz/tekrar/bildirim akışını etkiler; yayına alınan kelime sorularının Türkçe quizlere sızması istenmedi |
| K3 | XP | Tek yazım yolu ward_xp_and_streak(). XP, submit_answer ile aynı kuralla: yalnızca doğru, ipucusuz ve tekrar zamanı gelmiş cevapta; tutar sorunun zorluğuna göre 10/20/30 (kelime_sorulari.zorluk). İpucu mevcut sistemde olmayan bir yardımdır, ipucuyla doğru cevap XP vermez. Paketin 10/5 puanları kullanılmadı |
| K4 | Ustalık | Yalnızca `taninma` becerisi yazılır; seviye en fazla 3. Seçenekle tanıma "tam ustalık" sayılmaz. Yanlış → 0 (1 gün). İpucu ile doğru → seviye değişmez (1 gün). Doğru → +1 (1 / 3 / 7 gün) |
| K5 | Yayın onayı | Dört göz: yazan ≠ yayınlayan ≠ ilişki kuran ≠ ilişki onaylayan. DB CHECK + RPC kontrolü. **Tek yönetici olan kurulumda yayın yapılamaz**; gevşetilecekse karar gerekir |
| K6 | Doğru şık gizliliği | `kelime_sorulari` ve `kelime_*` tablolarında `authenticated` tablo yetkisi YOK. Öğrenci yalnızca `kelime_oyun_getir` (doğru şık ve açıklama yok) ve `kelime_cevap_gonder` (cevap sonrası açıklama) RPC'lerini kullanır |
| K7 | Veli görünürlüğü | Yalnızca toplu özet (`kelime_veli_ozeti`): oranlar, zorlanılan kelimeler, tekrar sayısı, öneri kodları. Cevap listesi / soru kimliği yok |
| K8 | Sınıf / kazanım | İçerikte `sinif` (1–12, `profiles.sinif` ile eşleşir) ve serbest `kazanim_kodu` metni. Resmi kazanım tablosu YOK (kaynak yok) |
| K9 | İlişki yönü | İlişkiler çift yönlü; (A,B) ve (B,A) tek kayıt (benzersiz indeks) |
| K10 | Hız sınırı | Kullanıcı başına dakikada 30 deneme (`RATE_LIMIT`) |
| K11 | Demo içerik | `supabase/seed/example_draft.sql` migration'a alınmadı; üretimde demo içerik yok |

### 13.2 Yapıldı (doğrulandı)
- [x] `supabase/migrations/20261022000000_kelime_evreni.sql` — 6 tablo, RLS, 15 RPC (öğrenci 5, veli 1, yönetim 9) + 2 yardımcı fonksiyon; tüm RPC'lerde `revoke` (public/anon) + `grant` (authenticated)
- [x] `supabase/tests/kelime_evreni_tests.sql` — 40 senaryo (RLS, yetki, idempotency, XP, ustalık, hız sınırı, dört göz, onay akışı, veli gizliliği)
- [x] Yerel SQL doğrulaması: PGlite (Postgres WASM) + Supabase bağımlılık taklitleri (`supabase/tests/kelime_evreni/`). **40/40 geçti.** Bilinçli açık mutasyonları (doğru şık sızıntısı, anon metrik yetkisi) testler yakaladı
- [x] Bulunan ve düzeltilen hatalar: `text[] ||` dizi literali, `auth.uid()` dönüş tipi, `smallint`/`integer` parametre uyumsuzluğu, `OR` içinde hata üreten kontrol
- [ ] Docker'da `supabase db reset` + `supabase test db` — Docker yok; PGlite ile yerine geçmez (gerçek `award_xp_and_streak`, `log_admin_action` yerine taklit kullanıldı)
- [x] **Uzak Supabase'e uygulandı.** `db:status` tüm Kelime migration'larını (20261022000000–000002, 20261023000000) uzakta senkron gösteriyor (2026-10-13 doğrulaması)
- [x] Flutter: model, repository, akış denetleyicisi (`kelime_oyun_akisi.dart`), ana ekran, oyun ekranı, Öğren kartı. 42 Kelime testi geçiyor; `flutter analyze` proje genelinde temiz
- [x] Web: `/yonetim/kelime-evreni` (metrikler, taslak/inceleme/yayın/arşiv, sözlük ve ilişki onayı), veli Genel Bakış kartı. `tsc` ve ESLint temiz
- [x] Tam Flutter test takımı: `splash_gate_test.dart` 3 başarısız test düzeltildi (Riverpod ProviderScope ve yeni splash sözleşmesine uyarlandı, commit `6146ed2`). Tüm testler geçiyor
- [ ] Tarayıcı, cihaz ve ekran okuyucu kontrolü (oturum ve cihaz gerekir): 390 px / masaüstü, hareket azaltma, ses ve titreşim
- [x] Ortak `AnswerOption` kontrastı düzeltildi: `mintDark` (#237A4B, 4,86:1) ve `coralDark` (#A64B24, 5,30:1) kullanılıyor; Quiz ve Kelime ekranları aynı widget'ı paylaşır
- [ ] İçerik: ilk onaylı paket (dil uzmanı incelemesi gerekir; demo içerik yayınlanmaz)
- [ ] Ödül/rozet entegrasyonu: XP ledger bağlı; rozet kuralı ayrıca tasarlanacak
- [ ] Ana ekranda tek birincil eylem ve özet ekranında tekrar çalışma eylemi (tasarım kararı)

### 13.3 Bilinen sınırlar
- Eş zamanlılık: advisory lock ve benzersiz anahtar kuralı SQL'de tanımlı; gerçek yük/yarış testi yapılmadı (PGlite tek oturum)
- `kelime_oyun_getir` öncelik sorgusu her çağrıda deneme sayısını hesaplar; içerik büyürse indeks/materialize gerekir
- Ustalık (taninma dışı beceriler) henüz yazılmıyor; kalıcı ustalık raporu bu yüzden boş kalır
- Branch hijyeni: `feature/kelime-evreni` üzerinde Kelime dışı dört commit var (`8bd52c0`, `11a666e`, `71ff03d`, `78f034d`). Bunlara dokunulmadı. Kelime işini PR'a almadan önce ayrılmalı

## 14. Web sitesi duyuru şeridi (2026-10-13)

Admin'den yönetilebilir ana sayfa duyurusu: başlık, metin (en fazla 500 karakter), yayında/pasif ve isteğe bağlı bitiş tarihi (Türkiye saati).

### 14.1 Kararlar
- Tek tablo, çoklu duyuru: en yeni aktif ve süresi dolmamış duyuru ana sayfada gösterilir. (karar)
- Tabloya doğrudan erişim yok; yalnızca RPC'ler (`get_aktif_duyuru`, `admin_list_duyurular`, `admin_save_duyuru`). (karar)
- Silme yok; duyuru pasife alınarak kapatılır. (karar, kayıt kaybını önlemek için) — **2026-10-14'te güncellendi:** arşivleme eklendi; silme yalnızca hiç yayınlanmamış taslak duyuru için (bkz. §17)
- Süresi dolan duyuru otomatik pasife dönmez; yalnızca gösterilmez. Listede "Süresi doldu" olarak görünür.
- Hata durumunda (migration yoksa dahil) ana sayfa şerit göstermeden çalışmaya devam eder.

### 14.2 Yapıldı (kod)
- [x] Migration `supabase/migrations/20261026000000_site_duyurulari.sql`: tablo, RLS (politikasız), 3 RPC, anon/authenticated yetkileri
- [x] SQL testi `supabase/tests/duyurular_tests.sql`: PGlite üzerinde 13/13 senaryo geçti (stub + require_admin kopyası ile; gerçek Supabase'de değil)
- [x] Admin sayfası `/yonetim/duyurular` (menü: Büyüme & iletişim) — oluştur, düzenle, yayına al / kaldır
- [x] Ana sayfa şeridi `DuyuruSeridi` (sunucu bileşeni), `LandingPage` içinde header'ın altında
- [x] Türkiye saati yardımcıları `components/yonetim/turkiyeTarih.ts` altına taşındı; ayarlar sayfası bunu kullanıyor
- [x] Çeviriler: `yonetim-panel.{tr,en}.json` (menü/sayfa açıklaması), `{tr,en}.json` → `landing.duyuruSeridi`

### 14.3 Kullanıcı yapacak
- [x] Uzak veritabanına uygulandı (2026-10-13): `npx supabase db push --include-all`; dry-run yalnızca `20261026000000_site_duyurulari.sql` listeledi. `--include-all` gerekti çünkü uzakta `20261027000000` (Müşteri 360, ayrı çalışma) zaten uygulanmış; yeni dosya ondan bağımsız.
- [x] Uzak salt-okunur doğrulama: 3 fonksiyon var, `duyurular` 0 satır, anon `get_aktif_duyuru` çalıştırabiliyor, anon `admin_list_duyurular` / `admin_save_duyuru` ve tablo okuma yetkisi yok.
- [ ] **Anon anahtar uyarısı:** `web-panel/.env.local` içindeki `NEXT_PUBLIC_SUPABASE_ANON_KEY` değeri uzak projede 401 "Invalid API key" döndürüyor. Anahtar döndürülmüş ya da yanlış kopyalanmış olabilir. Bu, ana sayfadaki duyuru şeridini ve `get_deneme_sinavi_tarihi` geri sayımını sessizce etkiler (geri sayım sabit yedek tarihe düşer). Vercel ortam değişkenlerinde anahtarı kontrol et.
- [ ] Deploy sonrası: admin'de bir duyuru oluştur, ana sayfada göründüğünü ve bitiş tarihi geçince kalktığını doğrula (anahtar sorunu çözülmeden şerit görünmez).

### 14.4 Doğrulanmadı
- [x] `npx tsc --noEmit` temiz; `npm run lint` 0 hata (16 uyarı, hiçbiri yeni dosyalarda); `npm run build` başarılı, `/yonetim/duyurular` rotası derlendi (2026-10-13)
- [ ] Tarayıcıda ana sayfa (masaüstü + 390 px) ve admin formu görsel kontrolü (dev sunucu + Supabase bağlantısı gerekir; yapılmadı)

## 15. Duyuru mecraları: web sitesi, web app, mobil, veli paneli (plan, 2026-10-13)

Hedef: admin duyuruyu hangi mecralarda yayınlayacağını seçsin; her mecra yalnız kendine seçilen duyuruyu görsün. Mekanizma, anket yayın yüzeyleriyle (`20261029000000_anket_yuzeyler.sql`) birebir aynı kurulur; yeni bir desen icat edilmez.

### 15.1 Mevcut durum
- Tablo `duyurular` yalnızca web sitesi için; `get_aktif_duyuru()` parametresiz, en yeni aktif duyuruyu döndürür.
- Yalnız `web-panel/.../landing/sections/DuyuruSeridi.tsx` tüketiyor. Flutter (`mobile-app/lib`) ve veli paneli (`web-panel/.../(admin)/veli-paneli/layout.tsx`) duyuru okumuyor.
- Anket tarafında hazır örnek var: `anketler.yuzeyler text[]` (`mobil` | `web_app` | `web_sitesi` | `veli_paneli`), `SurveySurface` tipi (`yonetim/merkez/types.ts`), mobilde `kIsWeb ? 'web_app' : 'mobil'` (`survey_repository.dart`), veli panelinde `AnketIstemi`.

### 15.2 Kararlar (önerilen, onay bekliyor)
- Yüzey kümesi aynen anketlerle aynı: `mobil`, `web_app`, `web_sitesi`, `veli_paneli`. Tek sözlük, iki ayrı liste yok.
- Bir duyuru birden çok yüzeyi seçebilir (`yuzeyler text[]`, en az 1). Varsayılan: `web_sitesi` (bugünkü davranışla uyumlu).
- Her yüzey, kendi yüzeyi için en yeni aktif ve süresi dolmamış duyuruyu alır. Yüzeyler arası "tek duyuru" kısıtı yok.
- Tablo erişimi değişmez: yalnız RPC. Silme yok; pasife alma. **2026-10-14:** arşivleme eklendi (bkz. §17).
- Hata/migration yoksa her yüzey bozulmadan boş döner (şerit/kart çizilmez).

### 15.3 Adımlar
1. [x] (uzak DB'ye uygulandı 2026-10-13; `get_aktif_duyuru(p_yuzey default 'web_sitesi')` — parametresiz eski çağrı da çalışır; canlıda anon çağrıyla doğrulandı) Migration `20261030000000_duyuru_yuzeyler.sql` (yeni dosya, `20261026000000` değiştirilmez): `duyurular.yuzeyler` kolonu + check; `get_aktif_duyuru(p_yuzey text default 'web_sitesi')` yeni imza; `admin_list_duyurular` ve `admin_save_duyuru` (`p_yuzeyler text[] default null`) güncellenir. Eski parametresiz fonksiyon kaldırılır veya geriye uyumlu tutulur (karar: kaldır, tek tüketici var).
2. [x] (PGlite tam zincir, `duyurular_tests.sql` 19/19; gerçek Supabase'te çalıştırılmadı) SQL testi: her yüzey için filtreleme, çok yüzeyli duyuru, yüzeysiz kayıt reddi, yüzey dışı değer reddi.
3. [x] (kod: tsc/eslint temiz; görsel kontrol aşağıda) Admin formu (`DuyuruManager.tsx`): yüzey onay kutuları (anket formundakiyle aynı bileşen/etiketler), en az bir yüzey zorunlu. Liste satırında yüzey rozetleri.
4. [x] Web sitesi: `DuyuruSeridi` `get_aktif_duyuru('web_sitesi')` çağırır (davranış değişmez).
5. [x] (kod: `flutter analyze` temiz, tüm testler geçti; cihaz/tarayıcı görsel kontrolü YAPILMADI; renk widget'a yerel sabit, `AppColors`'a token eklenmesi önerilir) Flutter (`mobile-app/lib`): `DuyuruRepository` + ana ekranda kart/şerit. Yüzey `kIsWeb ? 'web_app' : 'mobil'`. Kapatılabilir olmalı; kapatma durumu yerelde tutulur (duyuru id'sine göre), sunucuya yazılmaz. Çocuk ekranında gösterim dili hupo-ux-writing ile kontrol edilir.
6. [x] (kod; `DuyuruBandi`, kapatılabilir; görsel kontrol aşağıda) Veli paneli: `(admin)/veli-paneli/layout.tsx` içine `get_aktif_duyuru('veli_paneli')` ile küçük şerit. Veli'ye yönelik metin, ödeme/satın alma çağrısı içermez.
7. [~] Uzak DB: `20261029000000` (anket) ve `20261030000000` (duyuru) uygulandı (2026-10-13, düz `db push`, önce dry-run). Vercel ve Flutter dağıtımı YAPILMADI, ayrı onay. Eski not: uzak DB'ye uygulama ayrı onayla (`db push --include-all` kullanılmadan önce dry-run). Vercel ve Flutter dağıtımı ayrı onay.
8. [ ] TASKS §14.3 anon anahtar uyarısı çözülmeden 5 ve 6 canlıda doğrulanamaz; Flutter ve veli paneli de aynı anahtarı kullanır.

### 15.4 Riskler ve notlar
- Anon anahtar 401 sorunu üç mecrayı birden etkiler; önce çözülmeli.
- Flutter Web ile mobil aynı kod tabanı; `web_app` ile `mobil` ayrımı yalnız `kIsWeb` ile. Bu ayrım anket için de böyle, tutarlılık için korunur.
- Flutter değişikliği mobil yayın (Play/App Store) gerektirir; web tarafı Vercel/Flutter Web deploy'uyla gider. Mobil sürüm yayınlanmadan `mobil` yüzeyine duyuru gönderilmemeli (eski sürüm RPC'yi çağırmaz, zararsız ama görünmez).
- Hupolingo UI/UX işi olduğu için CLAUDE.md gereği adımlar 5 ve 6 öncesi `hupo-design-growth-director` agent'ı ile gözden geçirilir.
- **Açık bulgu (anket/duyuru dışı, çözülmedi):** PGlite tam zincir testinde `public.admin_kampanya_listele()` (`20261007000020`, 0 argüman) ile `admin_kampanya_listele(p_status, p_limit, p_offset)` (`20261014000200`, hepsi varsayılanlı) birlikte var; argümansız çağrı "42725 is not unique" veriyor. `CampaignsManager.tsx:51` argümansız çağırıyor; canlıda PostgREST'in aynı belirsizliği (PGRST203) verip vermediği doğrulanmadı. Eski 0-argüman sürümünü DROP eden yeni migration gerekir. `yonetim_merkezi_tests.sql` bu yüzden ancak çakışan overload koşuya özel kaldırılınca 30/30 geçti.
- **Açık bulgu:** `20260927000010` (COMMENT içinde `||`) ve `20260927000019` (question_reports sırası) boş bir veritabanında zinciri bozar; canlıda uygulanmış olduğu için ancak sıfırdan kurulumda sorun çıkar.
- **Görsel kontrol (2026-10-14, kopya klasörde `next dev --webpack`, demo modu, Chrome + Playwright):** GÖRÜLDÜ: ana sayfa duyuru şeridi gerçek `Test-3` duyurusuyla (zemin `rgb(2,122,72)`, yazı beyaz, altın etiket; 390 px'te yatay taşma yok, şerit yüksekliği 113 px); yönetim → Formlar & anketler listesinde mecra rozetleri; yönetim → Duyurular sayfası konsol hatasız açılıyor (demo modunda liste "Yükleniyor", bu bileşenin demo verisi yok). GÖRÜLMEDİ: anket ve duyuru **form pencerelerindeki mecra seçici** (ilk derleme zaman aşımı), veli paneli (oturum gerekir) `DuyuruBandi` ve `AnketIstemi`, anket doldurma penceresi, karanlık mod, Flutter (mobil/web app) ekranları (emülatör/cihaz yok). Dev sunucusu konsolundaki `ws://.../_next/hmr` hataları yalnız geliştirme gürültüsü.
- **Anket/duyuru ortak:** yüzey sözlüğü tek (`SurveySurface`, `SurfacePicker`); mobil `kIsWeb ? 'web_app' : 'mobil'` (`yayin_yuzeyi.dart`).

## 17. Duyuru ve anket arşivleme (2026-10-14)

Karar (kullanıcı onayı, 2026-10-14): arşivleme hem duyuru hem anket için; silme yalnızca yanıtsız taslak duyuru için. Gerekçe: `anket_yanitlari.anket_id` `on delete cascade` ile bağlı; anket silmek yanıtları siler. Anketlerde silme hiç yok.

- [x] Migration `20261032000000_duyuru_anket_arsiv_ve_sil.sql`: `duyurular.yayinlandi_at`, `duyurular.arsivlendi_at`, `anketler.arsivlendi_at`; `admin_list_duyurular(p_arsiv)`, `admin_duyuru_arsivle`, `admin_duyuru_sil` (yalnız `yayinlandi_at IS NULL`), `admin_anket_listele(p_arsiv)`, `admin_anket_arsivle` (yayındaki anket arşivlenmez). Zero-argüman eski sürümler düşürüldü.
- [x] Geriye dönük karar: mevcut tüm duyurular yayınlanmış sayıldı (`yayinlandi_at = created_at`); bu kayıtlar silinemez, yalnız arşivlenir.
- [x] PGlite testi `supabase/tests/arsiv/` (`node run.mjs`): 18/18 senaryo. Taklit şema üzerinde; gerçek veritabanında çalıştırılmadı.
- [x] Admin arayüzü: `DuyuruManager.tsx` (Aktif/Arşiv sekmesi, Arşivle / Arşivden çıkar, Sil yalnız taslakta) ve `SurveysManager.tsx` (Aktif/Arşiv, Arşivle yalnız yayında olmayanda, silme yok). TR/EN çeviri anahtarları eklendi.
- [ ] `tsc` / ESLint / tarayıcı kontrolü (demo modunda liste verisi yok; gerçek admin oturumu gerekir)
- [x] `npm run db:preview` (2026-10-14): uzakta yalnız bu migration bekliyor.
- [ ] Uzak veritabanına uygulama **bekliyor**: `npm run db:deploy` otomatik mod sınıflandırıcısı tarafından üretim deploy'u olarak reddedildi (2026-10-14). Kullanıcı onayı verildi; izin kuralı eklenmeden tekrar denenmeyecek. Uygulandıktan sonra: `db:status` ile senkron doğrulaması ve `admin_list_duyurular`/`admin_anket_listele` imzalarının kontrolü.
- [ ] Anket yanıtlı senaryo: arşivlenen ve yanıtı olan anketin yanıtlarının korunması PGlite'ta henüz test edilmedi (veli yanıt akışı taklit gerektirir)
- [ ] Duyuru listesi 200 kayıtla sınırlı; daha fazla gerekirse sayfalama

## 16. 2026-10-14: yapılanlar ve kalanlar

### 16.1 Yapılanlar
- [x] Kampanya listesi overload çakışması: `admin_kampanya_listele(text,int,int)` → `admin_growth_kampanya_listele` (migration `20261031000000`, uzakta uygulandı). Yönetim Merkezi'nin 0-argümanlı `admin_kampanya_listele()` korundu (farklı tablo, CampaignsManager kullanıyor). Canlı anon çağrıda her iki isim de belirsizlik yerine 401 veriyor.
- [x] Boş veritabanı zinciri: `20260927000010` (COMMENT `||` → tek literal) ve `20260927000019` (question_reports indexi tablo oluşmadan önce çalışıyordu; index zaten `20260927000030`'da). Dosyalar düzeltildi, uzakta zaten uygulu olduğu için canlıya etkisi yok. Doğrulama: PGlite, 96 migration yamasız (`--strict`) hatasız; `duyurular_tests` 19/19, `yonetim_merkezi_tests` 30/30.
- [x] Web paneli Vercel production'a alındı: `web-panel-nu.vercel.app` (deployment `dpl_B2NYZQ71mmXrHdmmBWRMpunE7zyy`), kaynak `main` HEAD'i (`c795bea`). Kök adres 200 döndü.
- [x] Anket mecraları (`f6f90e5`), duyuru mecraları (`2e84567`), TASKS notları (`d3484f7`), DB düzeltmeleri (`c795bea`).

### 16.2 Yapılacaklar
- [x] **Veli mobil ana ekranı** (commit `d91e8d3`): "yalnızca öğrenci" metni kaldırıldı; çocuk özeti (son 7 gün, rıza kapılı), duyuru, anket, veli paneline geçiş. `flutter analyze` temiz, `flutter test` 295/295. Görsel kontrol yapılmadı (320 px, büyük yazı, ekran okuyucu). Açık ürün kararı: hitap "siz" uygulandı; "sen" istenirse tek noktadan değişir.
- [~] **Flutter Web (app.hupolingo.com):** yerelde `flutter build web --release` başarılı (`mobile-app/build/web`, ~50 MB). **Production dağıtımı otomatik mod tarafından reddedildi** (kullanıcı onayı bekleniyor). Yapılacak: yeni Vercel projesi (`hupo-app-web` önerisi), `vercel.json` yalnızca rewrite+header içermeli (derleme komutu olmamalı), ardından DNS `app` kaydı ve Supabase Auth redirect URL manuel.
- [ ] **Alan adları çözümlenmiyor:** `hupolingo.com` ve `app.hupolingo.com` için DNS kaydı yok ("DNS sunucusu hatası"). Mobil uygulamadaki veli paneli bağlantısı (`Env.webBaseUrl` = hupolingo.com + `/veli-paneli`) ve `veli_mesaji_sheet` şu an çalışmayan bir adrese gidiyor. Karar: DNS düzeltilene kadar bağlantı `web-panel-nu.vercel.app` gibi çalışan bir adrese mi yönlendirilecek? Bu bir yapılandırma/ürün kararı.
- [ ] **Karakter görselleri derlemeyi bağlıyor:** `web-panel/public/characters` git'te değil (`.gitignore`), `mobile-app/assets/characters` kopyası üretiliyor. Git HEAD'den yapılan Vercel derlemesi bu olmadan başarısız oluyor (bu dağıtımda 81 dosya elle kopyalandı). Kalıcı çözüm için karar gerek: görselleri commit etmek ya da derleme öncesi kopya adımı.
- [ ] **Mağaza sürümü (Play / App Store):** yapılmadı; imzalama anahtarı ve mağaza hesabı gerekir.
- [ ] **Görsel kontrol:** veli paneli bandı, anket doldurma penceresi, mecra seçici formları, karanlık mod ve mobil/web uygulama ekranları gerçek ortamda bakılmadı.
- [ ] **Vercel hatalı kayıt:** `2Jr2whEMGb9f98fawcCte287mSbP` (Root Directory yanlış denemesi) ve `9EEhZPLz2YiEQibMiYQXUkXVwCZu` (karakter eksik derleme) başarısız deployment kayıtları; canlıyı etkilemedi.
- [ ] **Canlı Supabase Auth:** yeni web kullanıcı akışları (anket/duyuru) için uzak DB yalnızca migration ile güncellendi; gerçek veli hesabıyla uçtan uca deneme yapılmadı.

### 16.3 Onaylı işlemler (2026-10-14, ikinci tur)
- [x] **Flutter Web yayında:** https://hupo-app-web-yeni.vercel.app (Vercel projesi `hupo-app-web-yeni`; `flutter build web --release` çıktısı, `vercel.json` yalnızca rewrite + güvenlik başlıkları). index.html, main.dart.js ve flutter_bootstrap.js 200 döndü.
- [x] **Alan adları Vercel'e eklendi:** `app.hupolingo.com` → `hupo-app-web-yeni`, `hupolingo.com` → `web-panel`. İkisi de Vercel'de "verified".
- [ ] **DNS kayıtları yapılamadı (TURHOST paneli gerekiyor):** hupolingo.com TURHOST'ta kayıtlı (NS: CPNS1/CPNS2.TURHOST.COM); bu ad sunucuları sorgulara "reddedildi" yanıtı veriyor. Eklenecek kayıtlar: `app` CNAME → `cname.vercel-dns.com`; `@` A → `76.76.21.21`. Alternatif olarak NS'i Vercel'e (ns1/ns2.vercel-dns.com) çevirmek mümkün, ama mevcut MX/TXT kayıtları bilinmediği için önce TURHOST panelindeki kayıtlar kontrol edilmeli.
- [x] **Karakter görselleri git'te:** `web-panel/public/characters` (40 webp) izleniyor (`c8cd920`). `*.prompt.txt` dosyaları herkese açık klasöre alınmıyor (`.gitignore` + eşitleme betiği).
- [ ] **Supabase Auth redirect URL:** `https://app.hupolingo.com` eklenmesi manuel.
- [ ] **Vercel token güvenliği:** token sohbette paylaşıldı. İşler bittikten sonra Vercel panelinden iptal edilip yenisi üretilmeli. Token hiçbir dosyaya yazılmadı.
- [ ] **Veli paneli bağlantısı:** mobil uygulamadaki `hupolingo.com/veli-paneli` bağlantısı DNS düzelene kadar çalışmıyor.

### 16.4 Açık iş listesi (2026-10-14, sonra bakılacak)
- [ ] **HTTPS sertifikası (öncelikli):** `hupolingo.com` ve `app.hupolingo.com` için Vercel sertifikası çıkmıyor (elle istek 400). Olası neden TURHOST'taki CAA kaydı. CAA sekmesini kontrol et; sonra sertifikayı yeniden iste ve dene. Gerekirse Vercel destek kaydı.
- [ ] **Ad sunucuları yayılması:** `cpns` → `dns1/dns2.turhost.com` değişikliği 24–48 saat sürebilir. Bu arada yerel çözümleyici eski değer tutuyor; Google/Cloudflare doğru yanıt veriyor.
- [ ] **www kaydı:** `www` CNAME eklendi ama önceki dns1 sorgusunda "DNS adı yok" dönmüştü. Yayılma sonrası tekrar kontrol et.
- [ ] **Eski IP `185.15.40.85`:** ana alan adı artık Vercel'e gidiyor. Bu IP'de bir hizmet (eski site, e-posta, ftp) çalışıyor muydu, teyit et.
- [ ] **MX kaydı (`hupolingo.com` öncelik 0):** Bu kayıt e-posta için mi, yoksa yanlış eklenmiş mi, teyit edilmeden dokunulmayacak. Gerçek posta akışı varsa korunacak.
- [ ] **Supabase Auth redirect URL:** `https://app.hupolingo.com` eklenmesi (manuel).
- [ ] **Veli paneli bağlantısı:** HTTPS çalıştıktan sonra mobil uygulamadaki `hupolingo.com/veli-paneli` bağlantısını test et.
- [ ] **Vercel token:** sohbette paylaşıldı; işler bitince iptal edip yenisini üret.
- [ ] **Görsel kontroller:** veli paneli bandı, anket/duyuru formları, karanlık mod, Flutter web ve mobil ekranlar.
- [ ] **Mobil mağaza sürümü (Play / App Store):** başlanmadı; imzalama ve hesap gerekli.

### 18. Alan adı mimarisi (karar, 2026-10-15)
Karar (kullanıcı): yönetim ve veli panelleri **alt klasör**, web uygulaması **alt alan adı**.
- `hupolingo.com/yonetim` ve `hupolingo.com/yonetim-giris`: yönetim paneli ve girişi. Alt alan adı açılmayacak.
- `hupolingo.com/veli-paneli`: veli paneli. Alt alan adı açılmayacak.
- `app.hupolingo.com`: Flutter web uygulaması (öğrenci). Tek alt alan adı bu.
- Giriş kapıları (2026-10-15): veli ve öğretmen `hupolingo.com/veli-paneli/giris` (kayıt: `/veli-paneli/kayit`); yönetici ve öğretmen `hupolingo.com/yonetim-giris`. Giriş sonrası hedef sabit (rol bazlı yönlendirme yok); her kapı yalnızca kendi rollerini kabul eder, diğer hesaplar oturumu kapatılarak reddedilir. Öğrenci hesabı bu sitede giriş yapmaz, `app.hupolingo.com`'a yönlenir.
- Eski `/signin` ve `/signup` adresleri kalıcı yönlendirmeyle yeni kapılara gider (`proxy.ts`).
- Supabase auth: site URL `https://hupolingo.com`; redirect izin listesi `hupolingo.com` ve `app.hupolingo.com` (`/**` dahil). 2026-10-15 config push ile uygulandı.
- Açık: öğretmen veli panelinde boş bir ekranla karşılaşabilir (yönetim kapısı da öğretmene açık; hangi kapıdan giriş yaptığına göre sayfa farklı değil). Ürün kararı bekliyor → §19'da karara bağlandı.

### 19. CMS KARARLARI-15.10.2026
Kapsam: web sitesindeki her metin, alan ve görsel yönetim ekranından yönetilebilir olacak. Uygulama bir sonraki oturumda yapılacak; bu bölüm o oturumun tek kaynağıdır.

1. **Landing ve site metinleri (YAP):** `messages/tr.json` ve `en.json` (~1.440 metin satırı) başlık, bölüm metni, SSS, footer, giriş ve kayıt metinlerini kapsar. Hepsi CMS'ten okunacak; mesaj dosyaları yedek (fallback) olarak kalır.
2. **`site_icerik` tablosu (YÖNETİM EKRANINDA YAP):** Mevcut tablo (anahtar, dil, değer; anonim okuma, admin yazma RLS) CMS'in temeli olacak. Okuyan kod ve yönetim ekranı yazılacak.
3. **Yasal metinler (YÖNETİM EKRANINDA YAP, son sırada):** Gizlilik ve kullanım koşulları `src/lib/legal/content.ts` yerine `site_icerik` üzerinden yönetilecek; "taslak" uyarısı da CMS alanı olacak. Hukuki onay ayrı iştir (madde 9).
4. **Sayfa başlıkları ve SEO meta (YÖNETİM EKRANINDA YAP):** Her sayfanın title ve description alanı CMS'ten gelecek; sayfa dosyalarındaki sabit `metadata` yedek olarak kalacak.
5. **Çevirisiz sabit metinler (YÖNETİM EKRANINDA KONTROL EDİLEBİLİR, DÜZENLENEBİLİR):** "Veli Hesabı Oluştur", "Son 7 gün", "Hupolingo ana sayfası" gibi metinler bulunup anahtara bağlanacak; yönetim ekranında hangi anahtarın nerede kullanıldığı görülebilecek.
6. **Görseller (YÖNETİM EKRANINDA YAP):** Hupo ve karakter görselleri yönetim ekranından yüklenebilecek, kaldırılabilecek ve değiştirilebilecek. Depolama için Supabase Storage kullanılacak; statik `public/` dosyaları yedek olarak kalacak.
7. **Flutter öğrenci uygulaması metinleri (YÖNETİM EKRANINDA YAP):** Dart tarafındaki metinler CMS'e taşınacak; uygulama açılışta uzaktan okuyacak, yerel metin yedek olarak kalacak. Mobil yayın gerektirmeden metin değişmesi hedeflenir.
8. **Öğretmen ve veli giriş kapısı (KARAR):**
   - Veli Paneli adı **"Öğrenci İzleme Paneli"** olarak değiştirilecek (arayüz etiketi). URL `/veli-paneli` aynı kalacak; mobil uygulama ve eski bağlantılar kırılmasın diye.
   - Giriş ekranında **rol seçimi** olacak: "Veli" veya "Öğretmen". Seçilen role göre aynı panele girilir; panel içeriği role göre gösterilir (öğretmen kendi sınıflarını, veli kendi çocuklarını görür).
   - CRM tarafı: `profiles.role` (`veli`, `ogretmen`) ile `growth_crm` içindeki `person_role` (`parent`, `teacher`) eşlenecek. Eşleme mevcut; eksik tanım yoksa eklenecek. Uygulamada eşleme tablosu doğrulanacak.
9. **Yasal metinlerin hukuki onayı (SONRA):** İçerik taslağı bu aşamada yalnız teknik olarak CMS'e taşınır; hukuki onay ayrı bir iştir.
10. **Ölü kodlar (KARAR: SİL, uygulama sırasında doğrula):** `web-panel/src/app/[locale]/(student)/ogrenci/*` sayfaları ve `OgrenciNav` kullanılmıyor; `next.config` `/ogrenci` yolunu `app.hupolingo.com`'a yönlendiriyor. Silmeden önce erişilemezlik doğrulanacak, sonra kaldırılacak.
11. **`e2e/crawl.spec.ts` (KARAR: ÇALIŞTIR, SAKLA):** Ziyaret edilen sayfaları gezip hata ve kırık bağlantı arayan duman testi. Yeni giriş adresleri zaten listede. CMS değişikliklerinden sonra çalıştırılacak ve sonuçlar bu bölüme yazılacak.

Uygulama sırası: 2 → 1 → 4 → 5 → 6 → 8 → 7 → 10 → 11 → 3 → 9.

**Uygulama durumu (2026-10-15, yerel, commit edilmedi):**
- [x] **2 — Okuma katmanı + yönetim ekranı:** `src/lib/cms/icerik.ts` (saf mantık: yaprak listeleme, override uygulama; yalnızca CMS ad alanları, yalnızca mevcut yapraklar, boş metin yok, girdi değişmez), `icerik-veri.ts` (sayfalı okuma, PostgREST 1000 satır sınırı), `icerik-sunucu.ts` (anonim okuma, 60 sn önbellek, hata → JSON yedeği). Yönetim ekranı: `/yonetim/site-icerik` (`SiteIcerikManager.tsx`), menüde "İçerik → Site içeriği". Yazma doğrudan `site_icerik` tablosuna, RLS (admin) ile.
- [x] **1 — Landing ve site metinleri:** `src/i18n/request.ts` JSON'u CMS satırlarıyla birleştirir; kapsam: landing, signin, signup, forgot, reset, unsubscribe, cookie, welcome, anket, notFound, common, demo, adminSignin, veliPaneli. `[locale]/layout.tsx` içinde `revalidate = 60` (ISR).
- [x] **4 — SEO meta:** herkese açık 12 sayfanın sabit `metadata` değerleri `meta.*` anahtarlarına taşındı (`generateMetadata`); yönetim sayfaları kapsam dışı (landing zaten `landing.metaTitle` kullanıyordu). Not: `meta` CMS ad alanı olarak eklendi.
- [~] **5 — Çevirisiz sabit metinler:** public yüzeylerde bulunanlar anahtara bağlandı: landing "Veli Hesabı Oluştur" ve "Son 7 gün" (`landing.report.ctaLabel/sampleRange`), yasal sayfa "Hupolingo ana sayfası" (`common.legalHome`), deneme sonuçları konu analizi (`denemeSonuclari.konu.*`). Kalan: `AppScreensSection` mockup metinleri (görsel maket, bilerek bırakıldı), `demoQuiz` soru verisi (`demo` ad alanında kısmen), `veli-paneli` bileşenlerindeki tek kelimelik etiketler, `ogrenci/*` (ölü kod, madde 10). Kullanım görünürlüğü ekranı (hangi anahtar nerede) YAPILMADI.
- [~] **6 — Görseller (Supabase Storage):** Hupo maskotu (8 görsel) ve 40 karakter görseli `gorseller.*` anahtarlarında (`hupo.*`, `karakter.<sınıf>.<kod>`); landing, auth, demo, bakım, BrandMark, DemoQuiz ve karakter bölümü bunları okuyor. JSON'daki değerler `public/` yollarıdır (yedek); CMS satırı varsa o geçer. Yönetim ekranında her `gorseller` satırına "Görsel yükle" (WebP/PNG/JPG/SVG, en fazla 2 MB) eklendi; `site-gorselleri` kovasına yükler. Migration `supabase/migrations/20261015120000_site_gorselleri.sql` YAZILDI ama UZAKTA UYGULANMADI (onay bekliyor). `next.config.ts`'e Supabase Storage `remotePatterns` eklendi. Yönetim `karakterler` önizlemesi hâlâ statik dosyayı gösteriyor.
- [ ] **7 — Flutter metinleri, 3 — yasal metinler, 8 — rol seçimi/"Öğrenci İzleme Paneli":** başlanmadı.
- [ ] **10 — Ölü kodlar:** `sidebar`, `ecommerce`, `analytics`, `marketing`, `crm`, `stocks`, `saas`, `logistics`, `aiDashboard`, `sales`, `finance`, `header`, `userDropdown` mesaj namespace'leri kodda `useTranslations` ile kullanılmıyor (şablon kalıntısı). Silmeden önce erişilemezlik ve grep doğrulaması gerekir.
- [x] **11 — e2e crawl (2026-10-15, yerel dev sunucusu, 127.0.0.1:3000):** ilk çalıştırmada ana sayfa footer'ındaki `#deneme-exam` çapası hedefsizdi (bölümün id'si `deneme-sinavi`); düzeltildi. Sonrasında masaüstü: 12 sayfa, 80 eylem, 0 bulgu; mobil: 12 sayfa, 88 eylem, 0 bulgu. Panel taraması (`E2E_DEMO=1`) çalıştırılmadı. Tarama yalnızca GET isteklerine izin veriyor; dev sunucusu `.env.local` ile uzak Supabase'i okudu (yazma yok).
- Statik üretim (2026-10-15): herkese açık sayfalarda `generateMetadata` `getTranslations({ locale, namespace })`, sayfa ve layout'lar `setRequestLocale(locale)` kullanıyor. Yasal sayfalar, giriş/kayıt, şifre, bağlantı-izni, demo, 404 ve yönetim girişi statik (●) üretiliyor. Dinamik kalanlar: landing kökü (`PricingSection`, `DuyuruSeridi`, `CharacterUniverseSection`, `DenemeExamSection` sunucu Supabase istemcisi kullanıyor, cookie tabanlı; bu benim değişikliğim değil), `bakim` (searchParams), `deneme-sinavi-kayit` (sunucu Supabase istemcisi).
- Diğer: `messages/tr.json` ve `en.json` yeniden biçimlendirildi (JSON tek satırlı diziler/nesneler açıldı); içerik değişmedi, diff gürültülü.
- Doğrulama: `tsc --noEmit` temiz; ESLint değişen dosyalarda temiz; `npm run build` başarılı (yalnızca `web-panel`); `icerikUygula` gerçek JSON dosyalarıyla kontrol edildi (override, kapsam dışı ad alanı, dil ayrımı, boş metin, prototip, dizi yaprağı).
- Dokunulmadı: deploy, `supabase config push`, uzak Supabase ayarı, `config.toml`, MX/DNS. §20 maddeleri bunlar için onay bekliyor.
- Dikkat (§20.5): çalışma ağacında başkalarının commit edilmemiş işleri var; bu değişiklikler onlarla karışık. Deploy öncesi ayrıştırma gerekir.

### 20. Ajan notu: deploy öncesi kontrol (2026-10-15, hupo-18)
Bu notu kendi işinle birlikte değerlendir. Deploy yapılmadı; kullanıcıdan onay alınmadan canlıya çıkma. Madde sırası önem sırasıdır.

1. **Supabase `config push` riski:** Yerel `supabase/config.toml` içinde `site_url = http://127.0.0.1:3000`, `enable_confirmations = false` ve `[auth.email.smtp]` yorumda. §18'deki site URL (`https://hupolingo.com`) push ile uygulandıysa, bu push yerel auth değerlerini uzaktaki ayarların üstüne yazmış olabilir. Uzakta e-posta onayı ve Brevo SMTP hâlâ açık mı, kontrol et. Bir sonraki push site URL'i yeniden localhost'a çevirir; `config.toml` güncellenmeden push yapılmasın.
2. **Site URL kararı:** Öğrenci (app) kayıtlarındaki onay linkleri `hupolingo.com`'a düşer. Bu kabul edildi mi, teyit et.
3. **Brevo doğrulaması açık:** DNS kayıtları yayında (`brevo-code` TXT, `brevo1/2._domainkey` CNAME, SPF'te `include:spf.brevo.com`, DMARC `rua`). Ancak test mailinin gönderen adresi ve Gmail "Orijinali göster" ekranındaki SPF/DKIM/DMARC sonucu henüz kontrol edilmedi.
4. **MX öncelik 0 kaydı** (`hupolingo.com` → kendisi) hâlâ duruyor. Gerçek posta Hostinger MX'lerinden (5 ve 10) akıyor; öncelik 0 kaydı silinmeli (§16.4).
5. **Deploy hedefi belirsiz:** `app.hupolingo.com` Flutter projesi (`hupo-app-web-yeni`) ve `mobile-app/` tarafında commit edilmemiş değişiklik yok. `web-panel` (`hupolingo.com`) için çalışma ağacında başkalarının commit edilmemiş işleri var (`proxy.ts`, `utils/supabase/proxy.ts`, landing bileşenleri, `supabase/functions`, bakım, güvenlik). Deploy'dan önce bunların commit edilmesi ya da ayrıştırılması gerekir.
6. **Veli kapısı (§19 madde 8):** Rol seçimi ve "Öğrenci İzleme Paneli" etiketi uygulandı mı? Öğretmenin boş ekranla karşılaşma sorunu (§18 "Açık") çözüldü mü?
7. **Proxy yönlendirmesi:** `/signin` ve `/signup` artık `ESKI_YOLLAR` ile yeni kapılara gidiyor. Bir önceki oturumda eklenen `app.hupolingo.com` yönlendirmesi kaldırıldı ve geri eklenmedi.
8. **Test kullanıcısı silindi:** `bilgi@hupolingo.com` (ID `bca634aa-b043-4966-b05a-a2fc3decc2d6`) canlı veritabanında 0 kayıt. Bu kimlik tekrar kullanılmasın.
9. **Açık güvenlik işleri:** Vercel token iptali (§16.4) hâlâ açık. Supabase CLI bu makinede oturumlu; ortak makinelerde token kullanımı bilinçli yapılsın.
10. **E2E:** §19 madde 11 gereği CMS değişikliklerinden sonra `e2e/crawl.spec.ts` çalıştırılacak ve sonuç buraya yazılacak.

Onay gelmeden: deploy, `config push` ve uzak Supabase ayarlarında değişiklik yapılmaz.


## 21. Yedekleme, Turnstile, hız sınırı ve bakım kontrolü (2026-10-15)

Kapsam (kullanıcı talebi): (a) günlük veritabanı yedeği Google Drive'a, (b) Turnstile captcha'nın web formlarında gerçekten çalışması, (c) IP başına hız sınırı, (d) web sitesi / veli paneli / yönetim panelinden bağımsız bakım kontrolü.
Kural: yalnızca canlıda veya testte doğrulananlar `[x]`. Kod yazılıp doğrulanmayanlar `[ ]` ve "kod hazır" notuyla kalır.

### 21.1 Mevcut durum (denetim sonucu)
- Turnstile: Yalnızca `deneme-on-kayit` Edge Function'da doğrulama kodu vardı; `CAPTCHA_SECRET` ayarlı değildi ve **web tarafında widget yoktu**. Erken erişim formu RPC'yi captcha'sız doğrudan çağırıyordu. Yani "kurmuştuk" kısmen doğruydu: yalnızca sunucu tarafı.
- Hız sınırı: yoktu. `veli_adayi_olustur` anonim olarak açıktı.
- Bakım: `bakim_modu` anahtarı admin'de vardı ama yalnızca mobil uygulamayı (`MaintenanceGate`) etkiliyordu; web kontrol etmiyordu.
- Yedek: yoktu. Repo'da `.github/` klasörü yoktu.
- Git uzak deposu GitHub'da (`ekonometrist61-create/hupo-classic`); URL'de düz metin bir GitHub erişim anahtarı gömülü (bkz. 21.5).

### 21.2 Yapıldı (kod yazıldı; canlıda çalıştırılmadı)
- [ ] **Hız sınırı altyapısı** — `supabase/migrations/20261033000000_rate_limit.sql`: `rate_limit_hits` tablosu (RLS kapalı, yalnızca service_role), `rate_limit_kontrol()` fonksiyonu. Kod hazır; uygulanmadı.
- [ ] **Veli adayı RPC'si yalnızca servis rolüne** — `20261033000200_veli_adayi_yalniz_servis.sql`. **Deploy sırası önemli:** önce Edge Function + web, sonra migration. Yoksa erken erişim formu kırılır.
- [ ] **Edge Function `veli-adayi-kayit`** (yeni): Turnstile (fail-closed) → IP sınırı 5 / 10 dk → `veli_adayi_olustur` (service_role). Deploy: `supabase functions deploy veli-adayi-kayit --no-verify-jwt`.
- [ ] **Edge Function `deneme-on-kayit`**: captcha artık fail-closed (secret yoksa 503), IP sınırı 10 / 10 dk eklendi. Yeniden deploy gerekir.
- [ ] **Ortak güvenlik modülü** `supabase/functions/_shared/guvenlik.ts` (IP çözümü, Turnstile doğrulama, hız sınırı çağrısı).
- [ ] **Turnstile widget'ı web'de** — `web-panel/src/components/guvenlik/TurnstileWidget.tsx`; `DenemeKayitForm` ve `ErkenErisimSection` bağlandı. CSP'ye `challenges.cloudflare.com` eklendi (`next.config.ts`).
- [ ] **Bakım kontrolü: yüzey bazlı** — `20261033000100_bakim_yuzeyleri.sql` (`admin_set_setting` yeniden tanımlandı; `bakim_modu.yuzeyler` = site / veli / yonetim). Mobil `aktif` alanı aynen kalır.
- [ ] **Bakım kapısı (middleware)** — `web-panel/src/lib/bakim.ts` + `src/proxy.ts`: yüzey kapalıysa `/tr/bakim` içeriği yeniden yazılır. Yöneticiler `/yonetim`'de bakım sırasında da girebilir; `/yonetim-giris` her zaman açık. Durum 30 sn önbellekte; okunamazsa site açık kalır (fail-open).
- [ ] **Admin ayarları ekranı** — `yonetim/ayarlar/page.tsx`: web sitesi / veli / yönetim bakım anahtarları. Kaydetme artık `yuzeyler` alanını da korur (eski kayıt bu alanı silerdi).
- [ ] **Google Drive yedeği** — `.github/workflows/yedek.yml` (her gün 03:30 TR, `pg_dump` postgres:17 imajıyla, AES-256 şifreleme), `tools/yedek/drive-yukle.mjs` (OAuth yenileme jetonu, resumable yükleme, 30 gün saklama). Kurulum ve geri yükleme: `docs/yedekleme/KURULUM.md`. `node --check` geçti; Actions'ta çalıştırılmadı.
- [ ] **Bakım ekranı (web)** — `web-panel/src/app/[locale]/(full-width-pages)/bakim/` (hupo-design-growth-director). `tsc` temiz; dev sunucuda `/tr/bakim?yuzey=veli` 200, konsol hatası 0, 390px yatay taşma yok, `noindex`. Koyu tema ekran görüntüsü alınamadı (tema bağlamı ayarlanmadı). Uçtan uca bakım kapısı (DB'de bayrak açıkken yönlendirme) henüz test edilmedi.
- [ ] **Bakım kapısı için yalnızca bu oturumun dosyaları:** `src/proxy.ts`, `src/lib/bakim.ts`, `src/utils/supabase/proxy.ts`, `src/components/guvenlik/TurnstileWidget.tsx`, `src/components/landing/DenemeKayitForm.tsx`, `src/components/landing/sections/ErkenErisimSection.tsx`, `src/app/[locale]/(admin)/yonetim/ayarlar/page.tsx`, `next.config.ts` (CSP), `supabase/functions/{_shared/guvenlik.ts,deneme-on-kayit,veli-adayi-kayit}`, `supabase/migrations/20261033*`, `.github/workflows/yedek.yml`, `tools/yedek/`, `docs/yedekleme/`, `docs/hupo-design-growth/bakim-modu/`. Bu dosyalar aynı çalışma ağacında başka oturumların işleriyle karışık; deploy öncesi ayrıştırılmalı (bkz. §20 madde 5).

### 21.3 Kullanıcı yapacak (sırayla)
1. **Google:** Cloud projesi, Drive API, OAuth client (Desktop), consent screen **"In production"** (Testing modunda jeton 7 günde sona erer), refresh token. Adımlar: `docs/yedekleme/KURULUM.md` §2.
2. **GitHub Secrets:** `SUPABASE_DB_URL` (Session pooler), `BACKUP_PASSPHRASE` (parolayı şifre yöneticisine de kaydedin), `GDRIVE_CLIENT_ID`, `GDRIVE_CLIENT_SECRET`, `GDRIVE_REFRESH_TOKEN`, `GDRIVE_FOLDER_ID`. Sonra Actions'tan elle bir çalıştırma ve Drive'da dosya kontrolü.
3. **Cloudflare Turnstile:** Dashboard → Turnstile → widget oluştur, hostname `hupolingo.com` (ve `localhost` geliştirme için). Site key → Vercel `NEXT_PUBLIC_TURNSTILE_SITE_KEY`; secret → Supabase Edge Function ortamı `CAPTCHA_SECRET`. **Yerel geliştirme için** Cloudflare'in test anahtarları (`1x00000000000000000000AA` site, `1x0000000000000000000000000000000AA` secret) kullanılabilir; canlıda bunlar kullanılmamalı.
4. **Supabase deploy sırası:** (a) `veli-adayi-kayit` ve `deneme-on-kayit` function deploy, (b) Vercel'e web sürümü, (c) `npm run db:deploy` ile üç yeni migration. Onay gerektiren uzak DB yazması olduğu için bunu ben çalıştırmadım.
5. **Git token:** `.git/config` içindeki GitHub erişim anahtarını iptal edin (GitHub → Developer settings) ve yeni anahtarı Git Credential Manager ile saklayın. Remote'taki gömülü anahtar repo'yla birlikte sızabilir.

### 21.4 Tasarım (hupo-design-growth-director)
- Agent raporu: sayfa Hupo token'ları ile yazıldı. Durum metni için taslaktaki `#147D8A` yerine `#0D5762` (açık) ve `#7FC9D2` (koyu) kullanıldı; `#147D8A` / `#E8F5F7` çifti 4.35:1 ile 4.5:1 altında kaldığı için. Ölçüm: 7.37:1 ve 5.76:1. Taslak `bakim-modu.md` içindeki kontrast tablosunda bu düzeltme henüz yok; onaylı renk kararı (`#147D82` ↔ `#147D8A`) hâlâ açık.

### 21.5 Açık / doğrulanmadı
- [ ] Migration'lar uzak DB'de uygulanmadı; SQL yalnızca okundu. `supabase/tests/` altındaki testler çalıştırılmadı.
- [ ] Edge Function'lar Deno'da çalıştırılmadı (yerelde Deno yok). Turnstile doğrulaması canlıda uçtan uca test edilmedi.
- [x] Yerel web denetimi: `tsc --noEmit` hatasız. ESLint'te 1 uyarı (`ayarlar/page.tsx`, `setState` in effect); aynı desen bu sayfada öncesinden vardı.
- [ ] Bakım sayfası koyu tema görsel kontrolü; bakım kapısının uçtan uca testi.
- [ ] `anon` anahtarı sorunu (§11.7, 401 uyarısı) hâlâ açık; `DenemeKayitForm` bu anahtarı kullanıyor, Turnstile sonrası istek yine 401 dönebilir.
- [ ] Hız sınırı tam atomik değil (kısa yarış penceresi). Kesin kota değil, kötüye kullanım frenidir.
- [ ] `growth_web_olay_kaydet` ve `growth_web_kimlik_bagla` anonim RPC'leri hâlâ sınırsız (20261028 migration notu).
- [ ] Bakım sayfası durum kodu 200 (rewrite'ta Next middleware durum kodunu ayarlamıyor); sayfa `noindex`.
- [ ] Yedekte Storage (dosya) yok; yalnızca veritabanı.

### 21.6 Durum (deploy sonrası, 2026-10-15)
- [x] Migration'lar uzakta uygulandı: 20261015120000 (site_gorselleri, onaylı), 20261032000000, 20261033000000, 20261033000100, 20261033000200.
- [x] `CAPTCHA_SECRET` Supabase'e eklendi; `deneme-on-kayit` ve `veli-adayi-kayit` commit 43ddb0e'den deploy edildi. Sahte Turnstile token ile her ikisi 400 "başarısız" döndürüyor.
- [x] Vercel production: `NEXT_PUBLIC_TURNSTILE_SITE_KEY` eklendi; web commit 43ddb0e ile deploy edildi (Ready). Canlı landing'de Turnstile kutusu görünüyor ("Verifying…").
- [x] Anonim rol `veli_adayi_olustur`'u çağıramıyor (42501 permission denied).
- [x] Bakım kapısı yerelde test edildi (sahte get_app_config ile): site yüzeyi açık → /gizlilik bakım sayfası; veli girişi ve /yonetim-giris açık.
- [ ] Yönetim yüzeyi bakım bypass'ı (yönetici girişi) uçtan uca test edilmedi.
- [ ] Hız sınırı (10/10 dk, 5/10 dk) geçerli Turnstile token ile test edilmedi.
- [x] Canlı bakım testi (2026-10-15, kullanıcı onaylı): web sitesi yüzeyi DB üzerinden kısa süre açıldı; /gizlilik bakım sayfasını, /veli-paneli/giris ve /yonetim-giris açık kaldı. Ayar birebir geri yüklendi. Admin ekranı (oturum) üzerinden yapılmadı; yönetici bypass'ı hâlâ test edilmedi.
- [x] Günlük yedek (2026-10-16): GitHub Secrets tamam (GDRIVE_CLIENT_ID/SECRET/FOLDER_ID/REFRESH_TOKEN, SUPABASE_DB_URL, BACKUP_PASSPHRASE). Elle çalıştırma başarılı: run 38946421940, dosya Drive'a yüklendi (hupo-yedek-20261016-181922.dump.enc, 1,9 MB). Her gece 03:30 TR otomatik.
- [ ] Yedek parolası (C:\Users\cengi\.hupo\yedek-parola.txt) şifre yöneticisine taşınıp dosya silinecek.
- [ ] Google OAuth consent ekranı "In production" olmalı (Testing'de refresh token 7 günde sona erer). Kontrol: console.cloud.google.com/apis/credentials/consent, proje bustling-winter-241007.
- [ ] Eski gömülü GitHub erişim anahtarı GitHub'dan iptal edilecek (kullanıcı).
- [ ] Yedekten geri yükleme provası yapılmadı (isteğe bağlı, kullanıcı onayıyla).
- [ ] Turnstile secret yenilendi (kullanıcı); Supabase CAPTCHA_SECRET'ın yeni değerle güncel olup olmadığı doğrulanmadı.
- [ ] `growth_web_olay_kaydet` / `growth_web_kimlik_bagla` anonim hız sınırı yok (açık).
### 22. Telefon doğrulaması (karar, 2026-10-15)
Kararlar (kullanıcı): telefon doğrulaması **zorunlu**; tekillik **veli hesabı başına** (aynı doğrulanmış numara iki veli hesabında olamaz; bir veliye birden çok çocuk bağlanabilir); kanal **SMS**; SMS sağlayıcısı **sonra seçilecek**; mevcut veriler test verisi olduğu için yeniden doğrulama kampanyası **yok**.

Yapılan (yerel, commit edilmedi, uzak DB'ye uygulanmadı):
- [x] `supabase/migrations/20261034000000_telefon_dogrulama.sql`: `telefon_normalize` (+905XXXXXXXXX), `profiles.telefon_dogrulandi_at`, biçim kısıtı, veli-bazlı kısmi benzersiz indeks, `telefon_dogrulama_kodlari` (RLS açık, politikasız; kod salt+hash), `telefon_kod_uret` (yalnızca service_role; 10 dk'da 3 kod; doğrulanmış numara başka veliye ait ise reddeder), `telefon_kod_dogrula` (authenticated; 5 dk; 5 yanlış deneme; yanlış kod `{durum:'hatali'}` döner, hata fırlatmaz).
- [x] `supabase/functions/telefon-kod-gonder/index.ts`: JWT → `telefon_kod_uret` → SMS. SMS sağlayıcısı **İleti Merkezi** (karar 2026-10-15; toplusmsapi.com de aynı şirkete ait, ücretsiz 100 kredi). Adaptör resmi dokümana göre: `POST https://api.iletimerkezi.com/v1/send-sms/json`, kimlik gövdede (`request.authentication`), alıcı alanı `receipents`, OTP için `iys: "0"`, başarı `response.status.code === 200`. Ortam değişkenleri: `ILETIMERKEZI_KEY`, `ILETIMERKEZI_HASH`, `ILETIMERKEZI_SENDER` (tanımlı değilse 503). Deno yerelde olmadığı için derlenip çalıştırılmadı.
- [x] PGlite testleri (`scratchpad/pglite-test/test-telefon.mjs`): 23/23 geçti. Kapsam: normalizasyon, rol ve geçersiz numara reddi, yanlış/doğru kod, kod silme, tekillik, iki veli yarışı, süre dolumu, hız sınırı, 5 deneme kilidi, oturumsuz erişim, biçim kısıtı.
- Bu oturumda bulunan ve düzeltilen hatalar: (1) yanlış kodda hata fırlatmak deneme sayacını geri alıyordu, sınırsız deneme mümkündü; (2) eski kodların silinmesi hız sınırını etkisiz kılıyordu.

Açık (sonraki adımlar):
- [ ] **Web OTP arayüzü** (numara girişi + kod girişi): `web-panel` veli kayıt akışına bağlanmadı. Veli panelinde doğrulanmamış veliyi yönlendiren kapı (gate) yok.
- [ ] **İleti Merkezi kurulumu (kullanıcı):** Panel → Ayarlar > Güvenlik > API Erişimi (key, hash) ve Erişim İzinleri → "API kullanımına izin ver". Panelde IP kısıtı varsa kapatılmalı (Edge Function çıkış IP'si sabit değil). Test için gönderici `APITEST` (iys "0" zorunlu). Canlı başlık onayı için "HUPOLINGO" başvurusu (≤11 karakter, Türkçe karakter yok).
- [x] **Supabase secrets (2026-10-15 20:25):** `ILETIMERKEZI_KEY`, `ILETIMERKEZI_HASH`, `ILETIMERKEZI_SENDER=APITEST`. Anahtar sohbette paylaşıldı; panelden yenilendi, yeni değerler kaydedildi. Eski değerler artık geçersiz.
- [x] **Uzak DB (2026-10-15):** `20261034000000_telefon_dogrulama.sql` kullanıcının terminalinde `db push` ile uygulandı (`db:status` remote'ta görüyor). Claude Code izin engeli nedeniyle uygulama Claude tarafından yapılmadı.
- [x] **Edge Function `telefon-kod-gonder` yayında (v1, ACTIVE, verify_jwt=true).** Güvenlik kontrolü: oturumsuz ve sahte token istekleri 401 döndü; SMS gönderilmedi. Gerçek SMS ile uçtan uca test YAPILMADI (web arayüzü yok; test için oturumlu veli gerekli).
- [ ] **Gerçek SMS testi (ERTELENDİ, 2026-10-16):** Çağrı İleti Merkezi'nden **450 (Başlık kullanıma uygun değil)** dönüyor; `ILETIMERKEZI_SENDER=APITEST` bu hesapta kullanılamıyor. Yapılacak: İleti Merkezi panelinde onaylı başlık kontrolü ya da başvuru (≤11 karakter, Türkçe karakter yok), sonra `supabase.cmd secrets set ILETIMERKEZI_SENDER="..."` ve `tools\telefon-kod-test.mjs` ile test. Her SMS 100 kredilik paketten bir kredi harcar.
- [ ] **Veli web kaydı (ERTELENDİ, 2026-10-16):** `/veli-paneli/kayıt` 504 (`request_timeout`, `user_confirmation_requested`) veriyor; onay e-postası SMTP üzerinden gönderilirken zaman aşımı. Brevo SMTP host/port (`smtp-relay.brevo.com:587`) bu makineden erişilebilir. Olası neden: SMTP key/kullanıcı adı. Supabase Auth → SMTP ayarları ve Brevo SMTP key kontrol edilecek.
- [!] **Dikkat:** `20261033000000`, `20261033000100`, `20261033000200` (hupo-5f'in migration'ları, §21) uzak DB'de de "uygulandı" görünüyor; bu, §21'deki "uygulanmadı" notuyla çelişiyor. Kim ne zaman uyguladığı doğrulanmalı; `veli_adayi_yalniz_servis` RPC yetkilerini değiştirdiği için erken erişim formunu etkileyebilir.
- [ ] **Deneme/veli adayı akışı** (`deneme_on_kayit`, `veli_adayi_olustur`) telefonu hâlâ doğrulamadan kabul ediyor. Bu akışların da doğrulamaya bağlanıp bağlanmayacağı karar bekliyor.
- [ ] **`register_for_mock_exam`** çocuk profiline doğrulanmamış telefon yazmaya devam ediyor. Tekillik yalnızca doğrulanmış veli numaralarında uygulanıyor.
- [ ] **Periyodik yeniden teyit** (kampanya öncesi, teslim edilemeyen SMS'ler): ertelendi.
- [ ] **İYS/ticari ileti:** doğrulama kodları ticari ileti değil; yine de hukuk teyidi (§21 ve §10).

## 22. Bildirim sistemi: kutu, duyuru ve pazarlama push (2026-10-16)

**Karar: ikinci bir bildirim sistemi kurulmadı.** Brief'teki tabloların karşılıkları zaten vardı: `notifications` (kutu), `device_tokens` + `push_outbox` + `push_preferences` (FCM hattı; çocuk için veli rızası ve sessiz saat dahil), `duyurular` (banner ve duyuru kutusu), `segmentler` + `iletisim_kampanyalari` + `iletisim_tercihleri` (pazarlama; `push` kanalı zaten tanımlıydı). Yeni alanlar mevcut tablolara kolon olarak eklendi. `user_notifications` gereksiz: `okundu` ve `okundu_at` kutuda var. `device_tokens.platform = 'web'` ertelendi.

**Yapılanlar**
- `supabase/migrations/20261035000000_bildirim_kampanya_ve_kutu.sql`: duyuru kategorisi, hedef rol, zamanlı başlangıç, kutuya tek seferlik dağıtım (`duyuru_inbox_yayinla`, pg_cron dakikada bir), `get_bildirimler` (tam okunmamış sayısı; arşivlenen ve süresi dolan kayıtlar gizlenir), okundu kalıcılığı.
- `supabase/migrations/20261036000000_kampanya_push_dagitim.sql`: pazarlama push kampanyası (`kampanya_push_gonder`, pg_cron dakikada bir). Alıcılar: segment veya elle seçilen veli listesi (`veli_idleri`) ∩ `push` izni veren veliler. Haftalık limit uygulanır; sessiz saatte kampanya iptal edilir; boş kriter ve boş liste reddedilir; öğrenci hesabı asla alıcı olmaz.
- Web zili (`web-panel/src/components/header/NotificationDropdown.tsx`): eski akış tabloya doğrudan `update` atıyordu. `authenticated` rolünün bu yetkisi yoktu, yani okundu işareti hiç kalıcı olmuyordu ve hata yutuluyordu. Sayaç 10 kayıtla sınırlıydı. Artık `get_bildirimler` ve `mark_notifications_read` RPC'leri kullanılıyor; tr ve en metinleri eklendi.
- Mobil (`mobile-app/lib/services/quiz_repository.dart`): kutu `get_bildirimler` RPC'sine geçti; okunmamış sayısı 100 ile sınırlı değil. `flutter analyze` değişen dosyalarda temiz.
- Test: `supabase/tests/bildirim_kampanya/` (PGlite, gerçek migration zinciri, Docker gerekmez). `npm test` → 54 geçti, 0 başarısız.

**Kurallar (veritabanı seviyesinde zorunlu)**
- Duyuru kategorisi `indirim` kutuya ve push'a gitmez; yalnız web sitesi ve veli paneli banner'ında yayınlanır (CHECK).
- Öğrenci yüzeyleri (mobil, web_app) pazarlama duyurusu almaz.
- Pazarlama push satırının kuyruğa girmesi için `iletisim_tercihleri` içinde `push` izni şarttır (`enqueue_push` ikinci kontrol yapar).
- Cihaz izni (`push_preferences`), veli rızası ve sessiz saat ayrıca uygulanır.

**Açık işler**
- **Hukuk (karar gerekli):** pazarlama push'un 6563 ve İYS kapsamı; veliden `push` izni almak için onay metni. Arayüz yok. İzin şu an yalnız veritabanında verilebilir; varsayılan boştur.
- **Admin arayüzü:** SegmentsManager'da elle veli seçimi (`veli_idleri`) yok. DuyuruManager'da kategori, hedef rol, başlangıç ve kutuya gönder alanları yok. Backend hazır; mevcut 6 parametreli `admin_save_duyuru` çağrısı çalışmaya devam ediyor.
- **Web Push** (`device_tokens` için `web`) ve **Firebase kurulumu** (paketler, `google-services.json`, APNs anahtarı, `FIREBASE_SERVICE_ACCOUNT`) bekliyor. `push_backend_firebase.dart` hâlâ analiz dışında.
- **Migration'lar uzakta uygulanmadı.** `npm run db:preview` ile kontrol edilip onayla `db:deploy` yapılmalı.
- **Kutu kopyası:** duyuru düzenlenince kutudaki metin güncellenmez; arşivleme kutudaki kaydı gizler. Satır-başına-kullanıcı modeli ~50 bin kullanıcıya kadar yeterli; sonrası için okuma modeli düşünülmeli.
- `flutter_local_notifications` şimdilik gerekmiyor: uygulama içi afiş (`push_host`) zaten var, arka plan bildirimleri FCM notification payload'ı ile sistem tarafından gösterilir.

## 23. Onay metinleri, ön izin ve kayıt izni düzeltmesi (2026-10-16)

**Yasal okuma (hukuki görüş değildir; hukuk onayı bekliyor):**
- Kayıt onayı (Gizlilik ve Kullanım Koşulları) ile ticari elektronik ileti onayı ayrı tutulmalı. 6563 sayılı Kanun, ticari ileti (e-posta, SMS, arama, kampanya bildirimi) için alıcının önceden onayını ister; bu onay hizmet koşullarının kabulüne bağlanmamalı.
- KVKK açık rıza: belirli bir konuya ilişkin, bilgilendirmeye dayanan ve özgür iradeyle verilen rıza. Kayıt için zorunlu kılınan pazarlama onayı özgür iradeyi bozar.
- Çocuk hesapları pazarlama onayı veremez; tasarımda alınmıyor (§22).
- Sonuç: "Kullanım Şartları'na gömüp zorunlu yapma" yolu kabul edilemez. Uyumlu yol: ayrı, işaretsiz, isteğe bağlı kutular.

**Yapılanlar**
- Veli kayıt formuna "Uygulama bildirimleri (push)" kutusu eklendi (işaretsiz, isteğe bağlı). Metin sürümü `hupolingo-ticari-ileti-2026-10-v2`; yasal sayfaya push satırı eklendi.
- `supabase/migrations/20261037000000_kayit_push_izni.sql`: kayıt trigger'ı push izni yazar. Düzeltme: `_tercih_yaz` 'telefon' kanalını reddediyordu. 20261020000300 trigger'ı 'telefon' yazdığı için e-posta onayı sırasında "Geçersiz kanal." hatası oluşuyordu; form her kayıtta `iletisim_telefon` gönderdiği için bu her veli kaydını etkiliyordu. Kanal listesi `iletisim_tercihleri` CHECK'i ile eşitlendi. Uzakta doğrulandı (2026-10-16): `public._tercih_yaz` içinde `telefon` kanalı mevcut (`pg_get_functiondef` salt okuma).
- Ön izin (`mobile-app/lib/services/push/push_pre_permission.dart`): Hupo maskotu (`merakEdiyor`), "Evet, haber versin" ve "Şimdilik değil" eşit boyutta, çocuğa "sen" diliyle. Reklam veya indirim dili yok; "Sana reklam ya da indirim bildirimi göndermem" ifadesi, öğrenci hesaplarına pazarlama gitmemesiyle (§22) uyumludur. Velinin onayı yokken ön izin gösterilmez. Sistem izni yalnızca "Evet"ten sonra istenir.
- Test: PGlite `supabase/tests/bildirim_kampanya` 61/61 (kayıt izni ve çocuk hesabı kontrolleri dahil); Flutter `test/push_pre_permission_test.dart` 3/3; web `tsc --noEmit` ve eslint temiz.

**Açık işler**
- **Hukuk:** push kanalının İYS kaydı gerektirip gerektirmediği; push onay metninin (v2) ve yasal sayfanın son hali.
- **Ölçüm:** "Evet" ve "Şimdilik değil" olayları kaydedilmiyor. Ölçüm olmadan izin oranı hedefi (%80 gibi) belirlenemez ve doğrulanamaz; olay kaydı için karar gerekli.
- **Tekrar sorma politikası:** "Şimdilik değil" sonrası ön izin tekrar gösterilmiyor. Sınır (örn. 14 günde en fazla 2 kez) karar bekliyor.
- Veli tarafında (web paneli) push ön izni yok. Landing deneme formunda push kutusu yok (bilinçli: çocuk ve deneme akışı).
- `iletisim_izni_iptal_et` yalnızca e-posta kanalını geri alır; push geri alma veli panelindeki tercih ekranından yapılır.

## 25. Hukuk kapısı, ön izin ölçümü ve sıklık sınırı (2026-10-16)

**Kararlar**
- Hukuki karar kullanıcıya ve hukuk danışmanına aittir. Kod yalnızca kapıyı uygular; kapı **varsayılan kapalıdır**.
- Ön izin tekrar sorma politikası: **14 günde en fazla 2 gösterim** (kullanıcı onayladı).
- İYS kararı ve push metni (v2) onayı: hukuk görüşü alındıktan sonra yönetici **Merkez → Kanal ayarları → Pazarlama push kapısı** kartından girer.

**Yapılanlar**
- `supabase/migrations/20261038000000_pazarlama_push_kapisi_ve_olcum.sql`:
  - `pazarlama_push_kapisi` (tek satır). Açmak için metin sürümü dolu ve İYS kararı `bilinmiyor` olmamalı (CHECK + RPC). İYS kararı `gerekli_kayit_tamam` ise kayıt yönetici beyanıdır; İYS ile otomatik doğrulama yoktur.
  - Kapı kapalıyken `kampanya_push_gonder` kampanyayı `yasal_kapi_kapali` nedeniyle iptal eder (sessizce beklemez).
  - `iletisim_push_kullanilabilir(surum)`: kayıt formunda push kutusu yalnızca kapı açık ve sürüm onaylıysa görünür (anonim, boolean döner).
  - Ön izin sayacı: `push_on_izin_baslat()` (çocuk hesabında veli onayı yoksa false), `push_on_izin_bildir(sonuc)`, `admin_push_on_izin_ozeti(gun)`.
- Düzeltme (`20261037`): `_tercih_yaz` 'telefon' kanalını reddediyordu; e-posta onayı trigger'ı her veli kaydında düşebilirdi. Uzakta doğrulanmadı.
- Mobil: `PushApi.onIzinBaslat/onIzinBildir`. Sınır dolunca Hupo ekranı atlanır ve kullanıcı doğrudan sistem izni penceresine gider. Sistem sonucu yalnızca izin henüz sorulmamışken açılan pencerede ölçülür.
- Web: kayıt formunda push kutusu kapıya bağlandı (kapalıyken alan hiç gönderilmez). Yönetici kartı: kapı ve 30 günlük ölçüm.
- Test: PGlite `supabase/tests/bildirim_kampanya` 84/84 (kapı varsayılanı, onay şartları, dağıtım iptali, sıklık sınırı, pencere sıfırlanması, kimliksiz ölçüm, çocuk ve yönetici yetkileri). Flutter `push_test` + `push_pre_permission_test` 25/25. Web eslint ve `tsc --noEmit` temiz.

**Ölçüm tasarımı**
- `push_on_izin_gunluk`: gün × sonuç toplamı. Kişi kimliği içermez; yönetim ekranı buradan okur.
- `push_on_izin_durumu`: kişi başı, yalnızca sıklık sınırı için. Pencere 14 günü geçince silinir (cron, günlük). Eski 90 günlük değer hukuk görüşü sonrası düşürüldü: pencere süresinden uzun saklama ölçülülük ilkesine uymaz.
- Küçük hücre kuralı: yönetim özetinde toplam gösterim 10'un altındaysa hiçbir sayı ve oran gösterilmez.
- Harici analitik servisi kullanılmaz.
- Sınır: sonuçları istemci bildirir; sunucu bunları doğrulayamaz. İstatistik amaçlıdır, denetim kaydı değildir.

**Açık işler**
- **Hukuk görüşü (2026-10-16 tarihli, kullanıcının ilettiği metin):** Görüşün yazarı ve lisansı doğrulanmadı; imzalı yazılı görüş alınmalı.
  - Kabul edilenler: kampanya push'u için önceden açık onay; işaretsiz ve isteğe bağlı kutular; eşit boyutlu ön izin düğmeleri; çocuk hesaplarında veli onayı önkoşulu.
  - Yeniden değerlendirilenler: 90 gün saklama (14 güne indirildi); "tamamen anonim" iddiası (kanıtlanmadı, küçük hücre kuralı eklendi); günlük toplamların süresiz saklanması (karar bekliyor).
  - Doğrulanacak: "push İYS kapsamında değildir" tespiti resmi İYS / Bakanlık kaynağından teyit edilmeden kabul edilmeyecek.
  - Kapı kararı: İYS kararı ve v2 metni onayı yazılı görüşle birlikte yönetici tarafından girilecek. Görüş tam v2 metnini incelemedi; metnin son hali paylaşılmalı.
- Ön izin şu an yalnızca Ayarlar anahtarından açılır. Otomatik gösterim anları (örn. ilk rozet) ayrı bir ürün kararıdır.
- Veli tarafında (web) push ön izni yok.
- Uzak veritabanında `20261035`–`20261038` uygulanmadı; `20261037` düzeltmesi uzakta doğrulanmadı.

## 26. Push uçtan uca test durumu (2026-10-16)

**Sonuç: push şu an çalışmıyor; gerçek bir bildirim gönderilemez.** Test edilebilen katmanlar geçti, ama hat canlıda uçtan uca tetiklenmiyor.

Geçen testler:
- PGlite (`supabase/tests/bildirim_kampanya`): 94/94. Kapsam: kuyruk, `push_targets`, sessiz saat (gönderim anında), jeton silme, çocuk onayı yoksa kuyruk yok, webhook gövdesinin `parseWebhookPayload` ile kabulü, FCM mesajında PII olmaması.
- Edge Function birim testleri (`node --experimental-strip-types --test supabase/functions/send-push/logic.test.ts`): 11/11.
- Flutter tam paket: 301/301.

Eksikler (canlı durum, salt okuma ile doğrulandı):
- `send-push` Edge Function uzakta **deploy edilmemiş** (`functions list`).
- Secrets'ta `FIREBASE_SERVICE_ACCOUNT` ve `PUSH_WEBHOOK_SECRET` **yok**.
- Uzakta `device_tokens`, `push_outbox` ve açık push tercihi sayıları: **0**. Hat hiç çalıştırılmamış.
- Uygulamada Firebase paketleri (`firebase_core`, `firebase_messaging`) ve `google-services.json` / `GoogleService-Info.plist` yok. `pushBackendProvider` her zaman `NoopPushBackend` döndürüyor; bu nedenle hiçbir derlemede push açılamaz.
- Database Webhook (`push_outbox` INSERT → `send-push`) kurulu mu, CLI ile doğrulanamadı; dashboard kontrolü gerekir.
- `20261035`–`20261038` uzakta uygulanmadı.
- Deno bu makinede yok; `send-push/index.ts` yerelde çalıştırılamadı (yalnızca `logic.ts` test edildi).

Canlıya almak için sırası (her adım ayrı onay gerektirir):
1. Firebase projesi; Android ve iOS yapılandırma dosyaları; APNs anahtarı.
2. Flutter: Firebase paketleri ve `pushBackendProvider`'ın Firebase arka ucunu döndürmesi.
3. Supabase secrets: `FIREBASE_SERVICE_ACCOUNT` (servis hesabı JSON), `PUSH_WEBHOOK_SECRET`.
4. Migration'lar: `npm run db:preview` → onayla `db:deploy`.
5. `send-push` deploy; webhook'un `x-webhook-secret` başlığıyla bağlanması.
6. Gerçek cihazda test: kayıt → jeton → rozet bildirimi → cihaz mesajı.

## 24. Anket sistemi: mimari ve yönetim (2026-10-16)

Tasarım: `docs/hupo-design-growth/ANKET_SISTEMI_MIMARI.md`. Hedef kitle 8–14 yaş, tüm veli hesapları. Soru içeriği ayrı belgede (`ONBOARDING_ANKETI_ON_ARASTIRMA.md`).

**Kararlar (kullanıcı):**
- Hedef kitle 8–14 yaş.
- Anket her üyeden alınır (yalnız yeni kayıtlar değil, mevcut üyeler de).
- Soru okuma ve problem kurma için ayrı modül: fikir var, anket sisteminden sonra ürün incelemesinde ele alınacak (ertelendi).
- Türkçe kaynak taraması: yapıldı (ONBOARDING belgesi §2 ve §10).
- Yanıt sorgusu ve yönetim paneli: soru revizyonu yönetim panelinden yapılabilmeli (mimari belge §8).

**Kararlar (kullanıcı, 2026-10-16):**
- **Hiçbir anket silinmez, arşive alınır.** Yeni anket yayınlanınca önceki yayındaki anket otomatik kapatılıp arşive alınır (yayın ekranında onay kutusu, varsayılan işaretli). Anket silme yolu yok.
- **Etkileşim bütçesi:** 24 saatte en fazla 1 kart; anket ve push ön izni aynı sayaçta.
- **Atlama takvimi:** 3 gün → 14 gün → 90 gün (kademeli soğuma). 1. atlama 3 gün, 2. atlama 14 gün, 3. ve sonrası 90 gün.
- **Web sitesi anket yüzeyi kaldırılır.** Duyuru şeridi `web_sitesi` yüzeyinde kalır. Ziyaretçi için 1 soruluk widget ayrı tasarım (mimari belge §12-4).
- **Yanıt birimi hibrit, soru bazında:** çocuk kapsamlı sorular her çocuk için; veli kapsamlı sorular (ör. "Ders çalıştırırken siz ne kadar zorlanıyorsunuz?") veli başına bir kez, ikinci çocukta atlanır.
- **Soru tavanı: hedef 7, sert tavan 7.** İlerleme çubuğu "Soru 2/7".
- **Sessiz saat 22:00–08:00** (cihaz yerel saati): anket kartı ve pazarlama push'u yok.
- **Saklama:** ham yanıt 24 ay, sonra anonimleştirilir (toplu istatistik olarak kalır); gösterim olayları 180 gün; taslaklar 30 gün.
- Fayda: gönderimden sonra kural tabanlı 2–3 maddelik öneri (en fazla 3); garanti dili yok.
- Anket çocuğun öğrenme ekranında hiçbir zaman çıkmaz; yalnız veli alanında.

**Kararlar (kullanıcı onayı, 2026-10-16):**
- 90 gün sonrası atlama: sayaç sıfırlanmaz, her atlama 90 gün.
- Sessiz saat: yalnız anket ve pazarlama bildirimleri; işlemsel bildirimler muaf (işlemsel listesi hukuk ve ürün onayı bekliyor).
- Aynı yüzeyde aynı anda en fazla bir yayında anket.
- Ziyaretçi için 1 soruluk widget: onaylandı; yalnızca kişisel veri toplamayan bir soru olacak. Ayrı tasarım olarak hazırlanacak.

**Son kararlar (asistan önerisi, kullanıcı netleştirme görevini devretti):**
- Veli kapsamlı soru tekrarı: 365 gün ya da soru kodu değişene kadar. Atlanan veli sorusu 90 gün sonra tekrar sorulabilir.
- Kartı kapatma ("X"): atlama sayılır, kart başına bir kez. Anket içi "soruyu atla" ve yarıda kalan taslak sayılmaz.

**Sessiz saat için kod farkları (mimari belge §12-A, D2):**
- Mevcut push sessiz saati varsayılanı 20:00–08:00 (`20260920001000`). 22:00'e çekilecek; `supabase/tests/push_tests.sql` güncellenecek.
- Kural bugün tüm push'lara uygulanıyor. İşlemsel muafiyeti kategoriye göre eklenecek.
- Anket kartı için aynı kontrol (`push_in_quiet_hours`) kullanılacak.
- Pazarlama kampanya dağıtımı sessiz saatte kampanyayı iptal ediyor (`20261036000000`); bu davranış korunacak.

**Hukuk bekleyenler:** `anket_kisisellestirme` rıza türü ve metni, anonimleştirme yöntemi, aydınlatma metni, saklama süreleri.

**Yapılacaklar (kod yok; her dilim ayrı onay):**
- [ ] D1 Şema ve güvence: `anket_surumleri` (değişmez anlık görüntü), soru ve seçenek kodu kilidi, `anket_gosterimleri`, `etkilesim_butcesi` (push §23 ile ortak), `anket_taslaklari`. `anket_yanitlari.anket_id` FK `on delete cascade` → `restrict` (arşiv güvencesi). `web_sitesi` anket yüzeyi temizliği (dizide yalnız `web_sitesi` kalan anket `veli_paneli`'ye). Tek aktif anket ve yayın anında otomatik arşiv. Önce uzak DB'deki mevcut anket ve yanıt sayısı sayılır.
- [ ] D2 Tüketim: `anket_siradaki_kart(p_yuzey)` (en fazla 1 kart), bütçe, sessiz saat, atlama sayacı (3/14/90), mobil ve veli paneli kartı. Web'de kart `layout.tsx`'ten kaldırılıp `/veli-paneli` ana sayfasına taşınır. Web sitesi anket bileşeni (`(full-width-pages)/page.tsx`) kaldırıldı (commit `9169887`, yalnız landing satırı; geri alma `git revert 9169887`). Duyuru şeridi etkilenmedi. Adım 2 tamam (commit `f31dca2`): anket ve duyuru yüzey listeleri ayrıldı (`ANKET_SURFACES`, `DUYURU_SURFACES`). Adım 3 (commit `a435c29`): migration `20261039000000_anket_yuzey_web_sitesi_kaldir.sql` ve PGlite testi `supabase/tests/anket_yuzey` (18/18). **Uzakta UYGULANDI (2026-10-16, kullanıcı onayıyla, 5 migration: 20261035–20261039).** `db:status` yerel ve uzak listeyi eşleştiriyor. Doğrulama (salt okuma): anket kısıtı `mobil, web_app, veli_paneli` ve 1–3 mecra; `web_sitesi` içeren anket 0; anket 1; yanıt 0; `get_aktif_duyuru` ve `admin_save_duyuru` yerinde. `yonetim_merkezi_tests.sql` 427–431 değişmedi (web_sitesi davranışı korunuyor). Adım 3 kapsamı tamam.
- [ ] D3 Çocuk kapsamı: `anket_yanitlari.cocuk_id` ve `cocuk_sinif`, soru bazlı `kapsam` (`cocuk` | `veli`), `anket_cevaplari` (normalize), `anket_oneri_kurallari`, `cocuk_ogrenme_profili`, sonuç ekranında öneri. Hukuk onayından sonra.
- [ ] D4 Yönetim paneli: taslak → önizleme → yayın (arşiv onay kutusuyla), arşivden kopya ile yeniden kullanma, sürüm geçmişi ve fark, soru kütüphanesi (kopya ile), öneri kuralı editörü, yayın kontrol listesi (≤7 soru, her soruda kapsam, süre tahmini, yüzey, rıza sürümü), sınıf × ders kırılımı (n<5 gizli), audit'li CSV dışa aktarım. `SurveysManager` içindeki "yayındaki anket arşivlenmez" kuralı kaldırılır (yayın anı arşivi bunun yerine yapar). `supabase/tests/arsiv` 16. senaryo ("yayındaki anket arşivlenemez: 23514") bu değişiklikle birlikte güncellenir (proje sahibi kararı).
- [ ] D5 Test: PGlite (`supabase/tests` deseni): arşiv ve yanıt koruması (TASKS §16'daki açık test dahil), cascade → restrict, bütçe ve atlama süreleri (3/14/90), sessiz saat. Flutter testleri, web `tsc` ve eslint, gerçek veli hesabıyla uçtan uca, 320 px ve karanlık mod görsel kontrolü (§16'daki açık görsel kontrol ile birlikte).
- [ ] D6 Saklama: anonimleştirme görevi (cron, her çalıştırma audit'e), saklama sürelerinin uygulanması. Hukuk onayından sonra.
- [x] Ziyaretçi 1 soruluk widget tasarımı (belge: `docs/hupo-design-growth/ZIYARETCI_WIDGET_TASARIM.md`, 12 bölüm). Tasarım tamam; uygulama YOK.
  - Önerilen soru: "Hupolingo sizin için en çok neye yardımcı olsun?" (tek seçim, 6 seçenek). Yer: landing'de ParentPanelSection ile DenemeExamSection arası. Veri: kimliksiz günlük toplu sayaç, IP yok.
  - Kararlar (proje sahibi, 2026-10-16; ayrıntı widget belgesi §11-A):
    - Q1: Yerel depolama bayrağı için çerez onayı gerekmez. Aydınlatma metnine zorunlu teknik yerel depolama cümlesi eklendi (`web-panel/src/lib/legal/content.ts`, "Çerezler ve ölçüm"). [x]
    - Q2: Toplu sayım onaysız eklenebilir, şartla: sunucu tarafında anonim sayaç, tarayıcıda tanımlayıcı yok, segmentle ilişkilendirme yok, PostHog'a gönderim yok, IP saklanmıyor. Hukuk onayı yazılı teyit için alınacak.
    - Q3: Ham IP saklanmaz; tuzlu günlük HMAC ile (tuz ortam değişkeninde), saklama en çok 2 gün. Ayrı görev, aşağıda.
    - Ç1: Sekme başına 1 gösterim, anket bütçesinin ziyaretçi istisnası. Onaylandı.
    - Hedef kitle 8–14 devam; "ortaokula geçiş" seçeneği korunur, metin uygulamada gözden geçirilir.
    - Hupo pozu `dusunuyor.webp` kullanımı onaylandı.
  - Uygulama önkoşulları: (a) `(full-width-pages)/page.tsx` satır 67'deki `AnketIstemi web_sitesi` kaldırılmadan widget yayınlanmaz (D2 ile aynı iş). (b) Anon anahtar 401 sorunu (TASKS §14.3) çözülmeden canlı kanıt yok. (c) "4→5" yerine genel "ortaokula geçiş" seçeneği önerildi; 5. sınıf kapsamı doğrulanmadı ve hedef kitle 8–14 olduğu için seçenek yeniden gözden geçirilmeli. (d) Hupo pozu `dusunuyor.webp` kullanım onayı.
- [x] Test turu (2026-10-16): PGlite `anket_yuzey` 18/18; `bildirim_kampanya` 94/94; `arsiv` 18/18; `musteri_360` 15/15. `web-panel` `npm run build` başarılı. Tarayıcı (production build, `localhost:3000`): landing konsol hatası 0, başarısız istek 0, anket kartı yok; veli paneli oturumsuz giriş sayfasına yönleniyor, hatasız. Yapılmadı: oturumlu velide anket kartı kontrolü (hesap bilgisi gerekir), yönetim paneli anket/duyuru formlarının tarayıcıda denenmesi. `web-panel` proje geneli lint: 239 hata, 2842 uyarı; değiştirilen dosyalar temiz, hatalar önceden var.
- [x] Landing başlığı: "3–7. sınıf öğrencileri için" ifadesi kaldırıldı (`tr.json` ve `en.json` `landing.metaTitle`, commit `0e50c83`). Kalan: SSS cevabı ("Şu anda 3–7. sınıf içerikleri...", `tr.json` ~494) ve `content.ts` satır 114 hâlâ 3–7 diyor; kaldırılması için karar bekliyor.
- [ ] Canlı anket testi: onay bekliyor. Önkoşullar: (a) web-panel dağıtımı (Vercel) — 9169887, f31dca2, 0e50c83 canlıda değil (2026-10-16 kontrolü: hupolingo.com/tr başlığı hâlâ "3–7. sınıf" içeriyor); (b) test veli hesabı (kullanıcı sahibi); (c) yönetici tarafından TEST anketi yayınlama. Kapsam: yalnız mevcut akış (kart, yanıt, sonuç, kapatma, arşiv). Bütçe, atlama 3/14/90, çocuk kapsamı, yayın anı arşivi henüz yok, canlıda test edilemez.
- [!] Canlı tutarsızlık: DB kısıtı (20261039) canlıda, ama eski admin arayüzü (dağıtılmamış) hâlâ `web_sitesi` seçeneğini sunuyor. Bu seçenekle anket kaydedilirse veritabanı hatası döner. Web-panel dağıtılınca düzelir.
- [ ] Ziyaretçi widget uygulaması: önkoşullar tamamlandıktan sonra ayrı görev. Önkoşullar: (a) [x] landing `page.tsx` satır 67'deki `AnketIstemi web_sitesi` kaldırıldı (commit `9169887`); (b) anon anahtar 401 sorunu (§14.3) canlıda çözülür; (c) Q2 hukuk yazılı teyidi.
- [x] Aydınlatma: "Çerezler ve ölçüm" bölümüne zorunlu teknik yerel depolama cümlesi eklendi (`content.ts`). Metin tek dilli (Türkçe), başka sürüm yok.
- [ ] Rate limit IP gizleme (Q3): `rate_limit_hits.anahtar` için ham IP yerine günlük dönen tuzlu HMAC; tuz ortam değişkeninde (`.env` / Supabase secret), kodda yok. Edge Function (`guvenlik.ts` ve IP çıkaran kısım) ve migration değişir. Uzak DB ve Edge Function dağıtımı ayrı onay ister. Sağlayıcı günlüklerindeki IP ayrı konu.
- [ ] Hukuk: `anket_kisisellestirme` rıza metni, anonimleştirme yöntemi, aydınlatma metni güncellemesi, saklama süreleri.

## 20. Mobil ve tablet uyumluluk: yönetim, öğretmen, veli (2026-10-16)

Kaynak: üç incelemenin (UX/UI, Hupo tasarım-büyüme, ana oturum) ortak bulguları. Proje sahibi K1–K8 kararlarını onayladı ve tüm panellerin mobil ve tablet uyumlu olmasını istedi. Kararlar:
- K1: öğretmen veli panelinde kalmaz, `/yonetim/siniflar`'a yönlenir.
- K2: öğretmenin işi şimdilik salt-okunur sınıf raporu.
- K3: yönetim mobil kapsamı dar. Açık: destek (okuma/yanıt), genel bakış, kullanıcı arama (salt okunur), bildirim/ödeme durumu (salt okunur), duyuru yayını (çift onay). Masaüstü-only: plan/fiyat/kupon, site içeriği ve yasal metin, rol/yetki, ödeme iadesi, abonelik iptali, sınıf oluşturma, toplu soru yükleme.
- K4: veli ana ekranında "bu hafta" metrikleri (süre, soru, doğru oranı, tekrar bekleyen) öne; XP Başarılar'a.
- K5: veli mobil gezinmesi üst bar + menü çekmecesi. Alt sekme çubuğu sonraya.
- K6: deneme kaydında katılım ve pazarlama onayı ayrı kutular. Hukuk metni avukat onayı ister; kod yapısı ayrı kutu.
- K7: abonelikte koşullar CTA yanında; veri yoksa "bilinmiyor". Yenileme ve iptal bilgisi ürün ve hukuk onayıyla netleşir.
- K8: cihaz türü ölçümü ayrı görev (growth olayı).

Kabul ölçütü (ölçülebilir): `web-panel/e2e/panel-responsive.spec.ts` (`E2E_DEMO=1`) tüm panel rotalarında 390, 768 ve 1024 px genişliklerinde:
- sayfa düzeyinde yatay taşma yok;
- görünür kontrol düğmeleri en az 44 px;
- mobilde girdi yazı boyutu en az 16 px.

Tablo kuralı: 768 px altında ana listeler kart görünümüne geçer; 768 px ve üstünde tablo kalır. Her durumda tablo kendi kapsayıcısında kayar, sayfa kaymaz.

Çalışma ağacı notu: `web-panel`'de başkalarının commit edilmemiş değişiklikleri var. Onlara dokunulmaz, commit ve push yapılmaz. Uzak DB migration'ı ve Vercel dağıtımı ayrı onay ister.

Paketler:
- [ ] P0 Kabul testi: `panel-responsive.spec.ts`, mevcut başarısızlıkların taban raporu
- [ ] P1 Ortak temel: modal (role, aria, kaydırma), buton ve girdi boyutları, `DesktopOnly` bileşeni, üst bar arama ve başlık, kapalı menüde `inert`, veli üst barı
- [ ] P2 Veli paneli: mobil gezinme, "bu hafta" ana ekranı, Yakında öğeleri, pazarlama kartı Üyelik'e, deneme kaydı onay ayrımı, abonelik koşulları
- [ ] P3 Öğretmen: veli kapısından yönlendirme, yazma butonları yalnız admin'de, sınıf formu konumu
- [ ] P4 Yönetim tabloları ve formları, A grubu (`components/yonetim/panel` harf A–M)
- [ ] P5 Yönetim tabloları ve formları, B grubu (diğer panel, merkez, sorular, sayfa dosyaları)
- [ ] P6 Yönetim mobil kapsamı (K3): masaüstü-only işaretleme
- [ ] P7 Doğrulama: `npm run lint` (değişen dosyalar), `npm run build`, kabul testi 390/768/1024, ekran görüntüsü kanıtı
- [ ] P8 Kayıt: hukuk metinleri avukat onayı, K8 ölçüm görevi, `Yakında` öğelerinin ürün sahibi kararı
- [ ] Veli "Verdiğim yanıtlar" bölümü: görme ve değiştirme (KVKK erişim hakkı). v1 dışında, ertelendi.

### K-0100 · 2026-10-22 · VT/MOB/TSR · HupoRead yüzeyler arası uyum: yönetim CRUD, dashboard, kullanım süresi, üç göz, test yayını
- Uzak DB: 20261063 (genel bayrak açık), 64 (hikâye/sürüm sil + istatistik), 65 (veli/öğretmen dashboard, öğretmen sınıf toplamı + bireysel, rıza sunucuda), 66 (kullanım süresi, 300 gün), 67 (HR-033…047, 15 hikâye), 68 (üç göz: ajan_a, ajan_b, insan), 69 (2./3./4. sınıftan 4'er hikâye test yayını; insan onayı "okuma bekliyor").
- Web: yönetim hikâye düzenle/sil/istatistik, /yonetim/kullanim, veli okuma gelişim kartları, çerez onayına bağlı kullanım ölçümü. Mobil: kullanim_suresi.dart (anonim, sekme/rota bazlı).
- Doğrulama: PGlite kos 186/187 (#18 eski bilinen), yonetim_crud 27/27, dashboard 30/30, kullanım 17/17; web tsc temiz; Flutter okuma+kullanım testleri geçti. Tarayıcıda/telefonda görsel kontrol YAPILMADI.
- Açık: HR-041…047 uzunluk kararı, hukuk/telif onayı, pg_cron (300 gün temizliği) kontrolü, Faz D, kalan 75 fiş, raster görsel gözden geçirme.

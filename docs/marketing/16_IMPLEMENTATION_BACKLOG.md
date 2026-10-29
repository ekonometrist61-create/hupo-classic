# 16 Uygulama Backlog'u (kod/DB/migration ÖNERİLERİ; hiçbiri uygulanmadı)

Durum: Taslak · Tarih: 2026-10-29 · Rol: Pazarlama Otomasyon Mimarı · Bağımlı: 06, 12, 13, 19, 20 · Kural: Çalışma ağacındaki commit'siz değişikliklere dokunulmadı. Migration/deploy/bayrak ana oturum ve kullanıcı onayı.

| ID | İş | Tür | Gerekçe | Öncelik | Efor | Bağımlılık |
|---|---|---|---|---|---|---|
| B-1 (Y1) | Footer mağaza rozetlerini kaldır/"Yakında" | Kod (landing, tr/en.json) | STRATEJI Y1 | P0 (satış öncesi) | S | Mağaza kararı |
| B-2 (Y2) | Pricing güven rozetleri + "En Çok Tercih Edilen" + kanıtsız kapsam listesini (Aile 6 üye vb.) plan kaydına bağla | Kod | Y2 + 06 E2 | P0 | M | Plan kaydı, hukuk |
| B-3 (Y3) | robots/sitemap/OG/canonical/JSON-LD (Organization, FAQPage), ortam bazlı robots | Kod (Next.js metadata) | 06 §7, 20 #12/#13 | P0 (lansman günü) | M | Lansman kararı |
| B-4 (Y4) | Footer sosyal bağlantıları doğrulama | Kod | Y4 | P1 | S | Hesaplar |
| B-5 (Y5) | `cta.subtitle` "Ücretsiz hesap oluştur" kaldır/yaz | Kod | Y5 | P1 | S | — |
| B-6 | Hane/kaynak kaydı (UTM → `growth_identity_links`/hane kaynak alanı) | Migration + RPC | CAC kanal bazlı için kaynak alanı ≥%80 | P1 | L | Ana oturum kararı (decisions 2026-10-29) |
| B-7 | `veli_kaynak_bildirdi` (kayıtta isteğe bağlı kategorik "nereden duydunuz") + taksonomi | Kod + olay | Öz-bildirim atıf | P2 | M | Taksonomi güncelleme |
| B-8 | Demo sonu CTA'sını tek eylem yap, `ornek_rapor_goruntulendi`, `sss_madde_acildi` olayları | Kod | 06 T3 | P2 | M | — |
| B-9 | Hesapsız "çalışma planı oluşturucu" mini araç (veri kaydetmez, çocuk adı istemez) | Kod | 20 #11 | P2 | M | Tasarım onayı |
| B-10 | Smart App Banner / mağaza deep link | Kod | 20 #11 | P3 | S | Mağaza yayını |
| B-11 | Veli akışında tek sefer puan/yorum isteği (Android: Play In-App Review, buton tetiklemesiz, "sevdin mi?" ön sorusu yok; iOS: sistem istemi) | Mobil/Web kod | 20 #15 | P3 | M | Mağaza yayını, çocuk ekranında yok |
| B-12 | `sosyal_taslak_yazari` ajanı (`ajan.py` 4. ajan), sosyal_lint taşıma | Python | 12 | P2 | M | `automation/` MVP |
| B-13 | `growth_sosyal_gonderi` / `growth_sosyal_metrik` tabloları (yalnız dosya tabanlı yetmezse) | Migration | KANAL §5.3 | P3 | L | Onay |
| B-14 | Büyüme Özeti'ne sosyal bölümü / rapor taslağı genişletme | Kod | 12 G | P3 | M | B-13 |
| B-15 | Eşleştirme sonrası ilk oturum olayı doğrulama + aktivasyon tanımı kilidi | Ölçüm | 13 | P1 | S | Taksonomi |
| B-16 | `yearlyNote` ve kullanılmayan i18n anahtarlarını temizle (`trustBadges`, `whyParents` "seviyor") | Kod | STRATEJI notu | P2 | S | — |
| B-17 | Karakter bölümü/footer sloganı veli dili (06 E3, E7) | Kod/metin | CRO | P2 | S | Onay |
| B-18 | Kartsız self-serve deneme + `plans.deneme_gun` + kampanya "deneme" dili kapısı | Ürün | GIE §34 | P1 | L | Hukuk |
| B-19 | E1–E7 iletişim yürütme katmanı (e-posta cron, sıklık/sessiz saat, mesaj günlüğü) | Edge fn + migration | `ILETISIM_EKSIKLERI_PLANI` | P1 (e-posta için ön koşul) | L | Hukuk, sağlayıcı seçimi |
| B-20 | Ödeme E2E sandbox testi + 20261124 ön bilgilendirme uygulama | Test/migration | GÖR-078/082 | P0 | M | Onay |
| **R-1** | Rakip araştırması ikinci tur (fiyat, mağaza puanı, yorum temaları, sosyal hesap) | Araştırma | 02 boşluğu | P1 | M | Kullanıcı tarayıcısı / Ahrefs-Similarweb yetkisi |
| R-2 | Meta/Google çocuk ve eğitim reklam politikaları + Play Families / Apple Kids kuralları doğrulama | Hukuk/politika | 17 | P1 | S | — |
| R-3 | Instagram/YouTube/LinkedIn API izinleri güncel belgeyle doğrulama (otomasyon genişlerse) | Araştırma | 12 §1 | P3 | S | — |
| R-4 | MEB 2026–27 resmî takvim (okul bitiş, ortak yazılı, LGS) | Araştırma | 08 | P1 | S | — |

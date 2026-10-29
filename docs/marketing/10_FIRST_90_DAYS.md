# 10 İlk 90 Gün Eylem Planı

Durum: Taslak · Tarih: 2026-10-29 · Rol: CMO · Bağımlı: 03, 07, 08, 13, 16, 19 · Gün-gün CSV: `calendar/first_30_days.csv`

Gün 1 = onay günü (D1). Takvim tarihi yok; tarih ilişkilendirmesi onay gününe göre yapılır. "Y" = ilk sosyal yayın günü (T0 koşullarının sonrası). Çocuk akışına dokunan iş yok; kod işleri ana oturuma `16`'dan gider.

## 1. İlk 7 günde mutlaka yapılacak 10 iş
| # | İş | Sahibi | Çıktı | Başarı |
|---|---|---|---|---|
| 1 | Karar paketini onayla (19 "Onay Bekleyen") | Proje sahibi | İşaretli kararlar | 12 karardan ≥8'i yanıtlı |
| 2 | Hukuk: 4 belge onay sırası (ön bilgilendirme, KVKK aydınlatma, ticari ileti izni, çerez) | Proje sahibi + avukat | Takvimli onay | Tarih veriliyor |
| 3 | Y1, Y2, Y5 kod düzeltmelerini planla (mağaza rozeti, güven rozetleri, ücretsiz metni) | Ana oturum | İş kaydı | Kapı tanımlı |
| 4 | Hesap isimleri kontrol (Instagram/YouTube/LinkedIn) | Proje sahibi | Boş/dolu raporu | 3 kanalda aynı ad |
| 5 | Gerçek ekran kaydı çekimi planı (demo + uygulama 5 akış) | Proje sahibi | 5 kayıt (≥30 sn) | Dosya hazır |
| 6 | Görüşme davetleri (8 veli) | Proje sahibi | Takvim | ≥5 randevu |
| 7 | `olgular.json` + sosyal lint betiği taslağı onayı | MAR-OTO-AI → onay | Dosya | Lint testi geçer |
| 8 | UTM canlı doğrulama (PostHog'da `utm_*` görünüyor mu) | Ana oturum | Ekran görüntüsü | Doğrulandı/başarısız |
| 9 | 10 Reel/Instagram gönderi taslağı onayı (`11_SAMPLE_CONTENT`) | Proje sahibi | Onay listesi | ≥6 onaylı |
| 10 | Rakip araştırması R-1 (tarayıcı ile fiyat/yorum) | Proje sahibi / MAR-OTO-AI | Tablo | 6 rakip dolu |

## 2. Haftalık iş paketleri (13 hafta)
Efor: S = <2 sa, M = 2–6 sa, L = 6–15 sa. Maliyet: ek bütçe yoksa 0.

| Hafta | Paket | Çıktı | Öncelik | Bağımlılık | Efor | Maliyet | Başarı kriteri | Otomasyon |
|---|---|---|---|---|---|---|---|---|
| 1 | Karar + zemin (yukarıdaki 10 iş) | — | P0 | — | L | 0 | 10 işin 8'i | taslak lint |
| 2 | Veli görüşmeleri 1–4; kullanılabilirlik 1–2; hesap açılış adım 1–5 | Not + kod listesi | P0 | Randevu | L | 0 | 4 görüşme | transkript kodlama (insan) |
| 3 | Görüşmeler 5–8; itiraz sıralaması; hero seçimi; ekran kaydı montajı | 05 v2 | P0 | W2 | L | 0 | itiraz listesi | — |
| 4 | Y1/Y2/Y5 kod düzeltmesi (ana oturum); sitemap/robots hazırlığı (Y3 lansman günü) | PR | P0 | Karar | M | 0 | `rg` kontrolleri boş | — |
| 5 | Hesaplar açılır, T0 (§10 1–8) | Profiller | P1 | Hesap kontrolü | M | 0 | 8 adım tamam | — |
| 6 | İlk iki hafta paket onayı (G01–G10) + ek M-paketi; zamanlayıcı | Zamanlanmış | P1 | T0, Y1–Y5 | M | 0 | %100 onaylı | durum makinesi |
| 7 | Y1: yayın; haftalık ölçüm şablonu | Rapor 1 | P1 | W6 | M | 0 | 4–5 yayın | metrik CSV içe aktarma |
| 8 | Yayın 2. hafta; yorum/DM moderasyonu; veli rehberi blog 1–2 | — | P1 | — | M | 0 | ölçüm doldu | — |
| 9 | Pilot hane daveti (20–30; admin deneme; izinli) | Pilot listesi | P1 | Hukuk + ürün | M | 0 | ≥10 hane | — |
| 10 | 4 haftalık inceleme (Faz 3) | Karar notu | P1 | W7–W9 | M | 0 | 3 karar | rapor taslağı |
| 11 | Blog 3–5; YouTube video 1; e-posta serisi taslak onayı (gönderim yok) | İçerik | P2 | — | L | 0 | yayın/onay | — |
| 12 | Deney tanımı: T1 ön kayıt (trafik varsa) veya niteliksel test | Spec | P2 | Trafik | M | 0 | spec onaylı | A/B motoru kayıt |
| 13 | 90 gün raporu; 90 gün sonrası plan; 19 güncelleme | Rapor | P0 | Tüm | M | 0 | rapor yayında | rapor üretici |

## 3. İlk 30 gün (gün bazlı) özet
Ayrıntı: `calendar/first_30_days.csv` (30 satır: gün, iş, kanal, sahibi, kapı). Mantık: gün 1–7 yukarıdaki 10 iş; gün 8–14 görüşme + ekran kaydı + hesap; gün 15–21 kod düzeltmeleri + lint + otomasyon MVP kurulumu; gün 22–30 T0 hazırlık, ilk gönderilerin onayı, UTM bio linki testi, kapı gözden geçirme.

## 4. 90 günün başarı ölçütleri (rakam değil, durum/öğrenme)
| Ölçüt | Başarı | Kanıt |
|---|---|---|
| Yayın öncesi liste Y1–Y5 | Kapalı | `rg` çıktıları, ekran görüntüsü |
| Hukuk metinleri | En az ön bilgilendirme + aydınlatma metni onaylı veya takvimli | Avukat yazısı |
| Veli görüşmesi | ≥8 yapıldı, kodlandı | 05 v2 |
| Ölçüm | UTM→PostHog→hane kaynak alanı yolu çalışıyor (hane kaynak migration kararı verilmişse) | Test çıktısı |
| Sosyal | 4 hafta kesintisiz yayın (onaylı), moderasyon olayı=0 politika ihlali | Takvim |
| Pilot | ≥10 hane aktif ilk oturum | Büyüme Özeti |
| Deney | Ön kayıtlı 1 deney tanımı veya niteliksel test raporu | 14 |
| Öğrenme | Kanal kararı (sürdür/küçült/ekle) + hero kararı | 19 |
**Eşik değerler baseline olmadığı için bilerek konmadı;** 90. gün sonunda baseline'lar oluşur ve hedefler o zaman yazılır.

## 4b. Taktik havuzu bağlantısı (kullanıcının eklediği kaynak)
`20_TAKTIK_HAVUZU_ILK_1000.md` (omersaidakcin.com/ilk-1000-kullanici, erişim 2026-10-29) 90 güne şöyle bağlanır: hafta 1–4 #12/#13 (Y3 indeks paketi hazırlığı), #20 (pilot hane görüşmesi); hafta 5–8 #19 (Shorts), #7 (şeffaflık günlüğü), #10 (veli/öğretmen toplulukları, **yönetici onaylı**, ≥1 onaylı topluluk tanıtımı); hafta 9–13 #11 (hesapsız mini araç kod isteği), #17 (karşılıklı tanıtım adayları). Mağaza taktikleri (#1–#4, #15) yayın kararına kadar bekler. İlk hafta 7 adımlık plan 20 §5'te Hupo'ya uyarlandı. Kanal odak kararı 4. haftada (makalenin 2 haftası Hupo hacmi için yetersiz).

## 5. Yapılmayacaklar (90 gün)
Ücretli reklam, e-posta/SMS gönderimi, mağaza "indir" iddiası, A/B yürütme (trafik yoksa), çocuk akışına deney, yeni kanal açma (TikTok), kurumsal/okul satışı.

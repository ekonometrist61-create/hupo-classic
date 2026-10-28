# Bu sohbetten öğrenilenler (2026-10-24) — ÖNERİ, kullanıcı onayı bekler

Kaynak: soru üretim hattı (Türkçe 5–8, DÖP teyidi, benzerlik, kör denetim, veritabanı yazımı). Bu dosya kural değildir; kullanıcı onayladığında `ogrenme-gunlugu.md` içinde ONAYLI olarak taşınır.

## 1. Kapsam kuralı (tüm sınıflar)
- Kapsam: metinle tek soruda ölçülebilen **okuma ve yazma ürün** kazanımları.
- Kapsam dışı: dinleme/izleme (T.D), konuşma (T.K), görsel (T.O.x.6/7 türü), süreç ve değerlendirme (T.O.x.1–3, son kodlar; T.Y.x.1–3, süreç), yaratıcı yazı, çoklu ortam, yorum/eleştiri/tartışma (T.O ve T.Y), **özetleme** (T.O.x.21 ve T.Y.x.10).
- Karar (K-0115): 6. sınıf `T.O.6.21` kapsam dışı; eski `tr6-o-018` T.O.6.14 olarak yeniden kuruldu. 5/7/8'de kapsam dışı listesi aynı ölçüte göre tutarlı.

## 2. DÖP metnini çıkarma ve karşılaştırma
- Resmî PDF'i yerelde aç (PyMuPDF `fitz`, betik `python -I`), sayfa metnini düz metne çevir. WebFetch PDF'in sıkıştırılmış akışını okuyamaz.
- Kod–metin karşılaştırması **ana kazanım cümlesi** üzerinden yapılmalı. Alt maddeler (a), b)) ve "‹ | ›" ayırıcıları önce kesilmeli; yoksa alt maddedeki ortak ifade eşleşme sayar (yanlış pozitif yaşandı: T.Y.6.14).
- Pilot kazanım dosyalarında bozuk metinler vardı (6. sınıf: T.Y.6.18/19, T.O.6.5/20/25 gibi). Bu dosyalardan veritabanına metin yazılmadan önce DÖP ile karşılaştır.
- Kazanım kodu tek başına doğrulamadır; kod varsa ama metin farklıysa kod-soru eşleşmesi tekrar gözden geçirilir.

## 3. Benzerlik kontrolü (REHBER §6)
- 6-gram, `ortak ≥ 2` veya `jaccard ≥ 0,15` → bayrak.
- Romen rakamları (I., II., III.) ve tek harfli kalıplar çıkarılmalı; yoksa yapısal gürültü bayrak üretir.
- Aynı kimlikli eski pilot taslağı kendi benzerliği sayılmamalı.
- Karşılaştırma kaynağı yalnızca paket dosyaları değil, pilot `uretim_*` dosyaları da olmalı; yine de veritabanının tamamı değildir. Bunu kayda yaz.
- Ortak şablon kökleri (ör. "Bu amaca göre aşağıdaki cümlelerden hangisini…") bayrak üretir; kök değiştirilmeli.

## 4. Kapı betiği ve şema uyumu
- `tools/soru-uretim/kapi.cjs` paket şemasını değil, kendi şemasını bekler: `ipucu` (metin), `celdirici_gerekce` (sözlük), `soru_tipi`. Paket şemasından (`ipuclari` dizi, `yanlis_sik_geri_bildirimi`) uyarlama gerekir.
- Kapı uyarıları (`dogru_sik_en_uzun`, uzunluk oranı) bilgilendiricidir; red sebebi değildir.

## 5. Kör denetim (REHBER §4.7)
- Çözücü ve kalite ayrı girdi dosyasıyla çalışmalı: yalnız soru metni ve şıklar; anahtar ayrı bir dizinde; denetçiye "anahtar_gizli" dizinini açmamasını yaz.
- Kalite denetçisi doğru şıkkı kendisi belirlemeli; ardından anahtarla karşılaştırılır. Uyuşmazlık = yeniden denetim (bu turda tr8-013 için denetçi B yazdı, metin A; ikinci turda doğru okundu).
- Kalite önerileri gerçekten uygulanmalı ve değişen sorular yeniden denetlenmeli.
- Kalite önerisindeki "uyak" eleştirisi: aynı ek (-ar) uyak sayılmaz; soru dize sayısı gibi uyaktan bağımsız bir ölçüte çevrildi.
- Sonnet kalite denetçisi kendi GEÇER kararıyla çelişen doğru şık yazabilir; kararla doğru şık birlikte okunmalı.

## 6. Veritabanı yazımı
- Yönetici içe aktarma fonksiyonu (`admin_import_questions_v2`) `require_admin()` ister; CLI oturumu bunu sağlamaz. Doğrudan SQL'de önce sistemin doğrulayıcısı `_soru_paket_hatasi(row, '[]')` ile tüm satırlar kontrol edilmeli; hata varsa yazılmaz.
- Yazım tek transaction (`begin…commit`); `supabase db query --linked -f dosya.sql`.
- Var olan satırlar `dis_soru_id` ile güncellenir; yeni satır eklenir. Parti kimliği (`uretim_partisi`) her parti için ayrı yazılır.
- Ajan onayı yayın değildir: `insan_onayi_kim` yalnızca kullanıcı kararı varsa `kullanici` olur.

## 7. Yazar ve model kaydı
- REHBER yazar olarak Sonnet öngörür. Bu turda parçaları Haiku yazdı; `model` alanı gerçek yazarı göstermeli, sapma günlüğe yazılmalı.

## 8. Açık konular
- 6. sınıf: 8 uyumsuz kodlu soru düzeltildi; pilot kazanım dosyasındaki bozuk metinler hâlâ duruyor (dogrulama notu eklendi, liste düzeltilmedi).
- Veritabanı tamamı, paket ve pilot dışında kalan onaylı sorular için benzerlik kontrolü yapılmadı.
- 8. sınıf: 24 kod kapsamda, parti 1–2 (24 soru) yazıldı; kör denetim geçti. Yayın kararı kullanıcıda.

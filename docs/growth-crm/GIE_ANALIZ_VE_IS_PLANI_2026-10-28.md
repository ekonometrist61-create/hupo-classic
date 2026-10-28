# Growth Intelligence Engine (H-GIE) — analiz ve iş planı (2026-10-28)

Kaynak: kullanıcının ChatGPT çıktıları (4 ekran görüntüsü) ve "H-GIE V1.0 Claude Code talimatı". Bu belge talimatın `GROWTH_ARCHITECTURE_AUDIT.md` adımının yerini tutar; repo ve sunucu salt okunur incelendi, **hiçbir şey değiştirilmedi ve kurulmadı**.

## 1. Kısa sonuç

Fikrin yönü doğru (önce analitik, sonra otomasyon ve ML, en son LLM). Ama talimat, Hupo'da **zaten var olan** şeyleri sıfırdan istiyor ve **henüz var olmayan** şeylerin (Customer-Lab, HupoMentor) olduğunu varsayıyor. Önerim: ayrı bir Python/FastAPI servisi ile başlamak yerine, mevcut Supabase `growth_*` katmanını bitirmek; Oracle'ı yalnız ağır/bağımsız işler için kullanmak.

## 2. Denetim: talimat varsayımı ↔ gerçek durum

| Talimat varsayımı | Gerçek durum (doğrulandı) | Sonuç |
|---|---|---|
| Oracle 2 OCPU / 12 GB | **4 çekirdek ARM, 23 GB RAM** (boşta ~20 GB, yük 0,09). **Disk 45 GB, 4,4 GB boş (%91)** | RAM yeter; **asıl sınır disk** |
| Olay izleme yok, kurulacak | `growth_events`, `kullanim_olaylari`, `growth_web_olaylari`, PostHog (çerez onaylı), `OLAY_TAKSONOMISI.md` var | Yeniden yazma; sözleşmeyi genişlet |
| Segment, huni, yaşam döngüsü yok | `growth_yasam_dongusu`, `growth_analitik_huni`, journey motoru, öneri üreticisi, KVKK/birleştirme, saklama migration'ları var (13'ü 2026-10-28'de canlıya uygulandı, motorlar KAPALI) | V1'in büyük kısmı yazılı; **bitirme + doğrulama** kaldı |
| Yeni admin paneli / Cockpit | Admin'de `growth` nav grubu, Müşteri 360, Gönderim Günlüğü var | Yeni panel yok; mevcut gruba 4–5 sayfa |
| n8n kurulacak | n8n sunucuda 3 haftadır çalışıyor (Coolify) | Kurulum yok; kullanım ve yetki denetimi var |
| Ollama / yerel LLM | Ollama + gemma4:e4b (6,6 GB) kurulu; ARM CPU'da yavaş. Gemini API anahtarı zaten kullanılıyor | LLM opsiyonel; yerel model şart değil |
| Customer-Lab mevcut | **Repoda kod yok** (arama: yalnız belge anmaları) | Sıfırdan; en sona |
| HupoMentor mevcut | **Repoda kod yok** | Entegrasyon yok; şimdilik kapsam dışı |
| HupoRead veri akışı | Okuma entegrasyonu var (`docs/okuma-entegrasyon/`) | Yalnız toplulaştırılmış metrik |
| Etiketli veri yeterli (Model A–F) | Ürün erken; ücretli abone ve iptal geçmişi çok az | **ML şimdi anlamsız** (talimatın kendi kuralı: veri yoksa eğitme) |

## 3. Ne uygun, ne uygun değil

**Uygun, alınır**
- Sıra: Growth Analytics V1 → otomasyon → ML → LLM stratejist. (Ekran 4'teki sıra.)
- Veli segmentleri, D1/D7/D30 elde tutma, abonelik dönüşümü, "ölçülemeyen metrik = henüz yok" ilkesi.
- LLM'i arayüzle soyutlama; çekirdek LLM'siz çalışsın; LLM çıktısı KPI üretemez.
- Onaysız mesaj/harcama/fiyat değişikliği yok; dry-run; insan onayı; denetim günlüğü.
- **Content Quality Engine** (ekran 3): 120+ hikâye için tekrar, metin benzerliği, kelime yoğunluğu, seviye uygunluğu, metadata tutarlılığı. Kişisel veri içermez, Oracle'a uygundur, mevcut "benzerlik kontrolü" yayın kapısını güçlendirir. MEB/Maarif uyumu otomatik skorla kesinleşmez; mevcut iki denetçi + insan onayı kuralı geçerli.

**Uygun değil / ertelenmeli**
- **Ayrı FastAPI + SQLAlchemy + Alembic + ikinci veritabanı** (şimdi): veri tek yerde (Supabase), şema sahibi tek (migration hattı). İkinci şema sahibi çakışma ve KVKK yüzeyi demek. Python yalnız batch/ML worker olarak, salt okunur görünümlerden beslenerek.
- **LightGBM Modelleri A–F** (şimdi): etiket yok. Eşik koşulları aşağıda (Faz 4).
- **MLflow, Prometheus, SHAP, HDBSCAN** (şimdi): fazla altyapı. Model kaydı için bir tablo (`growth_model_runs`) ve mevcut health/Sentry yeter.
- **8 AI ajanı**: 3'e indir (Growth Strategist, Content Planner, Quality Auditor). Gerisi aynı istemlerin farklı şablonu.
- **13 sayfalık Cockpit**: 5 sayfaya indir (Genel Bakış+Huni, Elde Tutma/Kohort, Segmentler, Otomasyon+Öneri onay kuyruğu, Veri Kalitesi/İzin). Model Performance ve Experiment Lab ancak veri olunca.
- **Customer-Lab sonuçlarıyla fiyat kararı**: sentetik veli ≠ gerçek veli. Yalnız hipotez üretir; gerçek karar kontrollü A/B ile. "Sahte sosyal kanıt yok" kuralı sentetik çıktının pazarlamada kullanılmasını da yasaklar.
- **Referral/tavsiye segmenti**: tavsiye akışı üründe yok; akış çıkınca.
- **LLM ile hikâye üretimi/yeniden yazımı**: 2026 MEB hikâye yarışması AI kullanımını yasaklıyor; LLM yalnız denetim/analizde, üretimde değil.

## 4. Talimata eklenmesi / değiştirilmesi gerekenler

1. **Veri sınırı**: Oracle'a ham kişisel veri gitmez. Worker'a yalnız takma adlı/toplulaştırılmış görünümler (view) ve **ayrı salt okunur DB rolü** verilir; `service_role` anahtarı sunucuya konmaz. Çocuk öğrenme verisi (yanlış cevap, zayıf konu) growth'a hiç girmez.
2. **Küçük grup eşiği**: toplulaştırılmış her metrikte n < 10 ise gösterilmez (yeniden tanımlama riski).
3. **Maliyet verisi**: reklam harcaması kaynağı yok → admin'de manuel harcama tablosu; CAC/LTV/CAC yalnız veri girilince, aksi halde "henüz yok". Komisyonlar: iyzico + mağaza (varsa).
4. **Aktivasyon tanımı** (W2'de açık): "aktive oldu" tek cümleyle tanımlanmadan segment/huni/ML anlamsız. İlk iş bu tanım.
5. **Atıf sınırı**: UTM + son tıklama; mobil kurulum atfı (store) ölçülemez, raporda yazılır.
6. **Aktif kullanıcı tanımı**: bugün "aktif 7 gün" XP/streak tabanlı; öğrenme metriğiyle karıştırılmaz (proje kuralı). Pazarlama "aktif" ile ürün "öğrenme" ayrı tanımlanır.
7. **Hukuk/izin**: PostHog kararı (günlükte çelişkili), saklama süreleri (109), çerez metni, İYS (SMS/WhatsApp) kullanıcıda; plan bunları beklemeden ilerlemez, kodlamaz.
8. **n8n**: Community lisansı iç kullanımda uygundur; velilere/öğrencilere editör açılmaz. Arayüzün Traefik üzerinden dışarıya açık olup olmadığı ve kimlik doğrulaması **kontrol edilecek** (şimdi doğrulanmadı).
9. **Model kartı yerine model tablosu**: eğitim tarihi, veri aralığı, metrikler `growth_model_runs`.

## 5. Mimari (önerilen)

```
Flutter / Web ──olay──▶ Supabase (growth_*, kullanim_olaylari)  ← tek doğruluk kaynağı
                           │  salt okunur görünümler (takma adlı, toplulaştırılmış)
                           ▼
              Oracle: h-gie-worker (Python, batch, cron)   ← Faz 3+; içerik kalitesi Faz 1'de
                           │  sonuç tabloları (growth_*) geri yazılır, RPC ile
                           ▼
              Admin (Next.js): Growth sayfaları + onay kuyruğu
                           ▲
              n8n (Oracle): zamanlanmış rapor → TASLAK → admin onayı → gönderim
```

Oracle kaynak bütçesi (23 GB, 4 çekirdek): n8n + Coolify + vs-render ~ 4–5 GB; worker ≤ 2 GB RAM / 1 çekirdek, eğitim yalnız gece batch. **Disk bütçesi** aşağıda.

## 6. İş planı

### Faz 0 — Zemin (1–2 gün)
- [ ] Oracle disk kararı (bkz. §7); 4,4 GB boşla Python imajı (~0,5 GB) sığar ama güvenli değil.
- [ ] "Aktive oldu" ve "aktif kullanıcı" tanımlarını yaz (OLAY_TAKSONOMISI'ne ekle).
- [ ] TAMAMLAMA_PLANI W1–W10'un hangisi gerçekten bitti, hangisi commit'siz: durum tablosu.
- Kabul: tanımlar onaylı, disk ≥ 12 GB boş, W durumu belgeli.

### Faz 1 — Growth Analytics V1 (Supabase-native, Oracle gerekmez) · 1,5–2 hafta
- [ ] W2/W3/W7–W10'un kalanı: yaşam döngüsü, huni (ziyaret→kayıt→çocuk bağlama→ilk oturum→deneme→ücretli), D1/D7/D30 kohort görünümü, UTM raporu, DAU/WAU.
- [ ] 9 segmentten veriyle hesaplanabilen kural tabanlı olanlar (yeni kayıt, aktivasyonu tamamlamayan, düzenli, ücretsiz aktif, premium, yenilemeyen, kullanımı azalan); referral hariç.
- [ ] Admin: 5 sayfa (§3). Her sayfada hedef/ana eylem/durum/kabul kriteri; tarayıcıda gerçek görüntü kontrolü.
- [ ] Migrasyonlar: preview → içerik okuma → deploy (108/109 hâlâ ön koşullu).
- Kabul: sentetik + canlı veride huni/kohort rakamları elle SQL ile çapraz doğrulanır; boş veri "henüz yok" gösterir; PGlite testleri yeşil; ekran görseli alınmış.

### Faz 1b — Content Quality Engine (paralel, Oracle'da) · ~1 hafta
- [ ] Python batch: 120+ hikâye için tekrar/benzerlik (n-gram, TF-IDF), kelime yoğunluğu, okunabilirlik, seviye tutarlılığı, metadata eksikleri. Çıktı: CSV/JSON raporu (admin'de içerik kalite sekmesi sonradan).
- [ ] Yerel Docker imajı Oracle'da derlenir (kural: >2 dk iş Oracle'a); kişisel veri yok.
- Kabul: bilinen bir tekrar çifti ve bilinen bir kusurlu metin raporda yakalanır; rapor "uzman incelemesi gerekir" notunu taşır; hiçbir `published` değeri değişmez.

### Faz 2 — Onaylı otomasyon (n8n) · 1 hafta
- [ ] Haftalık büyüme raporu: RPC'den metrik → **taslak** → admin onay kuyruğu → e-posta/iç bildirim. Dry-run, tekrar deneme, idempotency anahtarı, denetim günlüğü (`admin_audit_log`).
- [ ] `growth_iletisim_uygun_mu` kapısı olmadan kullanıcıya hiçbir şey gitmez; motor bayrakları açılış kararı kullanıcıda.
- [ ] n8n erişim/yetki denetimi (§4.8).
- Kabul: dry-run'da gönderim 0; onaysız taslak gönderilemez (test); hata bildirimi çalışır.

### Faz 3 — Öğrenme analitiği (toplulaştırılmış) · 1 hafta
- [ ] Sınıf/konu/içerik bazında toplu kullanım (n ≥ 10); kişi bazlı kayıt yok; growth tabloları ile ayrı şema/yetki.
- Kabul: hiçbir growth görünümünde öğrenci kimliği veya yanlış-cevap düzeyi alan yok (test).

### Faz 4 — ML (yalnız eşik sağlanırsa)
Eşikler (öneri, sezgisel): Model B (dönüşüm) ≥ ~500 pozitif etiket; Model C (iptal) en az 2 yenileme döngüsü ve ≥ ~200 iptal; LTV en az 6 aylık gelir geçmişi. Sağlanana dek **kural tabanlı skor** (W2'de var). Sağlanırsa: zaman bazlı ayrım, sızıntı testi, ROC/PR-AUC + kalibrasyon, sonuç `growth_model_runs`'a, tahmin "olasılık" olarak etiketli.

### Faz 5 — LLM ajanları (3 adet) · 1 hafta
- [ ] Sağlayıcı arayüzü (Gemini API varsayılan; Ollama opsiyonel). Çıktı yalnız taslak metin; KPI'yı modelden değil SQL'den alır; veritabanından okunan metin güvenilmeyen girdi; LLM'e SQL/şema yetkisi yok.
- Kabul: LLM kapalıyken tüm rapor/dashboard çalışır; enjeksiyon içeren örnek kayıt çıktıyı değiştirmez (test).

### Faz 6 — Deney ve Customer-Lab (veri ve trafik olunca)
A/B motoru (randomizasyon, guardrail, çoklu karşılaştırma düzeltmesi). Customer-Lab sıfırdan, ayrı `sentetik_*` şema; gerçek ölçümle karışmaz.

## 7. Oracle sunucu: temizlik analizi

Ölçüm (salt okunur): Docker 20 GB — Ollama imajı 7,05 GB + model 6,6 GB, Open WebUI imajı 5,86 GB, n8n 1,75 GB, vs-render 2,39 GB, Coolify ~1 GB; volume'ler 7,8 GB; build cache 2,4 GB. Journal 80 MB, apt 12 KB, `/root/.npm` 110 MB (önemsiz).

Sormadan silinebilecek gerçek çöp neredeyse yok (dangling imaj 0, apt/journal küçük). Disk, adı "sormadan silinmez" listesindeki servislerde:
| Aday | Kazanç | Gerekçe | Risk |
|---|---|---|---|
| Open WebUI (imaj + veri) | ~7 GB | Ollama için sohbet arayüzü; growth planında gerekmez | Biri kullanıyorsa sohbet geçmişi gider |
| Ollama + gemma4:e4b | ~13,6 GB | ARM CPU'da yavaş; Gemini API var; planda yerel LLM opsiyonel | Yerel LLM isteği olursa 6,6 GB tekrar indirilir |
| Eski build cache | ≤ 2,4 GB | Yalnız yeniden derleme yavaşlar | Yok |

Öneri: Open WebUI'yi kaldır (+ gerekirse Ollama). Karar §8'de.

## 8. Kullanıcıdan gereken kararlar

1. **Oracle diski**: Open WebUI ve/veya Ollama kaldırılsın mı? (Önerim: ikisi de; ihtiyaç olursa yeniden kurulur.)
2. **Kişisel veri Oracle'a**: varsayılan HAYIR — yalnız toplulaştırılmış/takma adlı görünüm. Bunu onaylıyor musun?
3. **PostHog**: kalacak mı (günlükteki çelişki)?
4. **Migrasyon 108/109** ve motor bayraklarını açma zamanı.
5. **Reklam harcaması**: manuel giriş tablosu uygun mu, yoksa bir reklam hesabı bağlanacak mı?
6. **HupoMentor / Customer-Lab**: gerçekten başka yerde mi var? Varsa yol; yoksa kapsam dışı.

## 9. Doğrulanmayanlar
- n8n arayüzünün dışarıya açıklığı ve kimlik doğrulaması bakılmadı.
- Hangi migrasyon/ekranın canlıda tarayıcıyla görüldüğü: K-0163–K-0165'e göre görülmedi.
- Faz süreleri tahmindir; Faz 4 eşikleri sezgiseldir, gerçek olay sayıları sorgulanmadı.

## 10. Karar güncellemesi (2026-10-28, kullanıcı yanıtı)

Bu bölüm §2 (Customer-Lab/HupoMentor satırı), §6 Faz 6, §7 ve §8'in yerine geçer.

### Uygulananlar
- **Oracle temizliği yapıldı:** Open WebUI ve Ollama kapsayıcıları, `zidws1rr2a2i2idejms2tuit_openwebui` (1,1 GB) ve `_ollama` (6,6 GB) volume'ları, `open-webui:main` ve `ollama:latest` imajları kaldırıldı. n8n, Coolify, vs-render ve `~/hupo-motion` dokunulmadı. Disk %91 → %48, 24 GB boş. Coolify arayüzünde bu iki servise ait eski kayıt kalmış olabilir; sunucuda çalışmıyorlar. Yerel LLM seçeneği düştü; Faz 5 Gemini API ile ilerler.
- **Kişisel veri Oracle'a gönderilmez:** onaylandı (§4.1 ve §8.2).

### Kararlar
1. **PostHog kalır.** EU bölgesi; yalnız web (landing ve veli paneli), yalnız çerez onayından sonra. Autocapture kapalı, `identified_only`, oturum kaydı kapalı. Çocuk verisi ve mobil uygulama PostHog'a gönderilmez; mobil ölçüm `kullanim_olaylari` üzerinden gider. Açık şart: çerez ve gizlilik metninin hukuk onayı, yayına geçmeden önce. Bu karar günlükteki eski çelişkili notları geçersiz kılar.
2. **Migration 108 (anon kapatma) şimdi uygulanmaz.** Koşullar: (a) `kullanim-izle` edge fonksiyonu deploy edilmiş, (b) web ve mobil yeni sürümleri yayında, (c) eski sürüm kullanım oranı en az 2 hafta izlenmiş ve düşük. Gerekçe: anon yazım kapanınca eski uygulama sürümleri olay yazamaz; veri kaybı olur (K-0164 uyarısı).
3. **Migration 109 (saklama) hukuk onayı olmadan uygulanmaz.** Saklama süreleri hukukçudan gelir; bu belge süre önermez.
4. **Motor bayrakları (journey, öneri) şimdi KAPALI kalır.** Açılış sırası, tarih değil koşul bazlı:
   - a. Secret'lar (`OLAY_WORKER_SECRET`, `BREVO_API_KEY` veya `RESEND_API_KEY`, `EPOSTA_GONDEREN_ADRES`) ve `eposta-gonder` deploy: kullanıcı.
   - b. Dry-run: motor açık, e-posta gönderimi kapalı, 7 gün `growth_mesaj_gunlugu` incelenir (`izin_yok` ve `kanal_kapali` oranları beklenenden farklı mı).
   - c. İlk gerçek journey: yalnız "hoş geldin", yalnız e-posta, yalnız izinli kullanıcılar; 1 hafta izlenir.
   - d. Sıra: aktivasyon hatırlatması. Öneri üreticisi, admin onay kuyruğu ekranı olmadan açılmaz.
   - SMS ve WhatsApp kapalı kalır (GÖR-018/019).
5. **Manuel reklam harcaması tablosu: evet.** `growth_harcama` (tarih, kanal, tutar, para birimi, not, giren yönetici). Yalnız admin okur ve yazar; reklam hesabı bağlanmaz (OAuth ve veri sorumluluğu getirmez). Kural: harcama girilmemiş dönemde CAC "henüz yok" gösterilir. Uygulama Faz 1'de.
6. **HupoMentor ve Customer-Lab henüz inşa edilmedi; yapılacak.** H-GIE'nin parçası değil, ayrı ürün işleri.
   - **Customer-Lab:** Faz 6'dan sonra, kendi spec dosyasıyla. Sentetik veri yalnız `sentetik_*` şemasında; gerçek metriklere yazılmaz; çıktı yalnız hipotez, pazarlamada "kanıt" diye kullanılmaz.
   - **HupoMentor:** çocuğa dönük yapay zekâ özel ders öğretmeni. Growth'tan önce pedagoji, içerik güvenliği (prompt injection dahil), KVKK ve veli onayı gerekir. Growth'a yalnız toplulaştırılmış kullanım metriği gelir; sohbet içeriği, yanlış cevap ve zayıf konu hiçbir zaman growth'a girmez.
   - İkisi için de önce spec yazılır (`docs/`), sonra kod. Spec olmadan growth tarafında entegrasyon işi açılmaz.

## 11. Uygulama durumu (2026-10-28)

| Faz / iş | Durum | Kanıt |
|---|---|---|
| Faz 0: aktivasyon ve aktif tanımları | **Yapıldı** | `OLAY_TAKSONOMISI.md` §8 |
| Faz 0: W durum tablosu | Commit `f36e8f3` ile W2, W3 (huni), W4 (KVKK, birleştirme), W7 (giriş olayları), W8a/b (anon kapatma ve saklama dosyaları), W9 (seed), W10 (sonraki adım) kod olarak var. **W1, W5, W6 ve W3 admin ekranı durumu doğrulanmadı.** | `git show --stat f36e8f3` |
| Faz 1: `growth_harcama` (manuel harcama) | **Yapıldı, yerelde test edildi:** migration `20261113000000`, test 27/27 | `supabase/tests/growth_harcama/` |
| Faz 1: 5 admin sayfası | **Yapılmadı** | — |
| Faz 1: uzak DB'ye uygulama (`db:preview` → içerik okuma → `db:deploy`) | **Yapılmadı.** `20261113` ekli dosya, `20261112` ve sonrası uzakta uygulanmadı. | `K-0165` ve bu belge §10 |
| 108 ve 109 migration'ları | Bekliyor (§10 koşulları) | §10 |
| Motor bayrakları | KAPALI | §10 |
| Commit | Yapılmadı (TAMAMLAMA_PLANI ortak kuralı) | — |

## 12. Güncelleme (2026-10-28): deploy ve harcama ekranı

- **Deploy:** `20261113000000_growth_harcama` uzak DB'ye uygulandı (`db:deploy`). `20261108` ve `20261109` bilerek uygulanmadı: geçici olarak dışarı alındı, deploy sonrası aynı yerine geri konuldu. Uzak durum: 20261113 uygulandı; 108 ve 109 bekliyor.
- **Uyarı:** CLI, 108 ve 109 uzak son migration'dan önce kaldığı için `db:deploy` komutunu her seferinde reddedecek. `--include-all` kullanılırsa bu iki migration da uygulanır; kullanılmamalı. 108 ve 109 kararları verilene kadar her deploy aynı dışarı alma adımını gerektirir.
- **Admin ekranı:** `/yonetim/harcama` (Reklam Harcaması). Ekle, kanal toplamları (para birimi ayrı), kayıt listesi, sil. Nav'da "Growth Analitik"in altında. `tsc` ve `eslint` temiz. Tarayıcıda görsel kontrol yapılmadı.
- **Mevcut ekranlar:** Growth Analitik (huni, UTM, aktiflik, lifecycle, prospect), Müşteri 360, Segmentler, Journey, Gönderim Günlüğü, AI Öneriler zaten var. Faz 1'in "5 sayfası" büyük ölçüde mevcut; eksik kalanlar aşağıda.
- **Eksik:** D1/D7/D30 kohort görünümü (RPC yok); CAC hesabı (harcama + yeni hane); Veri kalitesi ve izin ekranı. Kohort ve CAC RPC'leri yeni migration olarak yazılıp PGlite testiyle doğrulanmalı.

## 13. Güncelleme (2026-10-28): kohort ve CAC (yerel, deploy onayı bekliyor)

- **Migration:** `20261114000000_growth_kohort_cac.sql`. `admin_growth_kohort(p_gun)` (D1/D7/D30, özet ve haftalık kohort) ve `admin_growth_cac(p_gun)` (para birimi başına harcama / kayıtlı hane). Gizlilik eşiği 5, mevcut `_growth_gizle` ve `_growth_yuzde` ile.
- **Kayıtlı hane:** lifecycle `visitor` ve `lead` dışında kalan haneler. Lead varsayılan başlangıçtır; kayıt olmayan aday paydaya girmez.
- **Test:** `supabase/tests/growth_kohort_cac` 22/22 geçti (PGlite). Test sırasında yakalanan hatalar: yetki modeli stub'ı (`profiles.role`), `auth.uid()` okuma biçimi (`request.jwt.claims`), kohort örnek büyüklüğünün eşikten küçük kalması ve test fikstürünün `veli` profili ile fazladan hane üretmesi. Hepsi düzeltildi.
- **Ekranlar:** `/yonetim/harcama` içine CAC kartı (`HarcamaManager`). Yeni `/yonetim/elde-tutma` sayfası (`EldeTutmaManager`): üç özet kartı ve haftalık kohort tablosu. Nav girişi ve tr/en çeviriler eklendi. `tsc` ve `eslint` temiz. Tarayıcıda görsel kontrol yapılmadı.
- **Kanal bazlı CAC yok:** hane kanal atfı (UTM) harcama kanalı ile eşleşmiyor. Yalnız toplam CAC gösterilir.
- **Uzak DB:** `20261114` uygulanmadı; deploy onayı bekleniyor. 108 ve 109 yine bekliyor.
- **Çeviri dosyası onarımı:** `yonetim-panel.tr.json` ve `.en.json` ilk yamada bozulmuştu (here-string sonu yeni satır eksikliği). Dosyalar git HEAD'inden yeniden üretildi, yalnız eklemeler içeriyor (+73, silme yok), JSON doğrulandı.

## 14. Güncelleme (2026-10-28): deploy ve veri kalitesi ekranı

- **Deploy:** `20261114000000_growth_kohort_cac` uzakta uygulandı (onayla). 108 ve 109 yine dışarıda; dosyalar geri konuldu. Uzak: 20261113 ve 20261114 uygulandı.
- **Veri kalitesi ve izin:** `20261115000000_growth_veri_kalitesi.sql` (`admin_growth_veri_kalitesi`). Kontroller: e-postası boş hane, aktive ama tarihsiz hane. İzin özeti: kanal başına açık, kapalı, kayıt yok (yalnız veli profilleri). Sayılar 5'in altındaysa gizli.
- **Test:** `supabase/tests/growth_veri_kalitesi` 13/13 (PGlite). `growth_households.email` NOT NULL ve benzersiz olduğundan "eksik e-posta" boş veya boşluk metnini sayar.
- **Ekran:** `/yonetim/veri-kalitesi`, nav girişi, tr/en çeviriler. `tsc` ve `eslint` temiz.
- **Uzak:** `20261115` uygulanmadı; deploy onayı bekliyor.
- **Faz 1 ekranları (yerel):** Huni ve genel (Growth Analitik, mevcut), Elde tutma (kohort, yeni), Segmentler (mevcut), Otomasyon ve öneri (Journey, Gönderim Günlüğü, AI Öneriler; mevcut), Veri kalitesi ve izin (yeni). Beş sayfa tamam; tarayıcı kontrolü yapılmadı.
- **W durumu:** W1 abonelik tarihleri RPC ile UI arasında camelCase olarak eşleşiyor. W5 CRM aksiyonları (ekip, görev, destek, sahip, KVKK, birleştirme) mevcut. W6 `next` yönlendirmesi güvenli (`guvenliYonlendirme`). Birim testleri bu turda doğrulanmadı.

## 15. Güncelleme (2026-10-28): veri kalitesi deploy, tarayıcı kontrolü, n8n bulgusu, Faz 2 dilim 1

- **Deploy:** `20261115000000_growth_veri_kalitesi` uzakta uygulandı (onayla). Önizleme sırasında bağlantı kimlik hatası verdi; ikinci denemede başarılı, bu sırada uzak durum kontrol edildi (uygulanmamış). 108 ve 109 dışarıda, geri konuldu.
- **Tarayıcı kontrolü (kısmi):** `next dev` localhost:3010'da çalışıyor. Dört yeni rota (`harcama`, `elde-tutma`, `veri-kalitesi`, `growth-analitik`) yetkisiz erişimde 307 ile yönlendiriliyor. Render'ı görmek için yönetici girişi gerekiyor; projede test hesabı yok. Yönetici girişiyle tam görsel kontrol yapılacak.
- **n8n (plan §4.8 kapatıldı):** Konteyner 3 hafta çalışıyor; `N8N_HOST=n8n.144.24.177.156.nip.io`, port `0.0.0.0:5678`. Dışarıdan PC'den istekler zaman aşımına uğradı; sunucu güvenlik duvarında 5678 yok. Sunucu içinden `127.0.0.1:5678` yanıt vermedi. Ayrıca Ollama için kalan `11434` kuralı hâlâ açık. Güvenlik duvarı/port değişikliği onay gerektirdiği için yapılmadı.
- **Faz 2 dilim 1 (yerel):** `20261116000000_growth_rapor_taslak` (taslak tablo, idempotent ISO hafta üretimi, tek seferlik onay/red, denetim kaydı). Gönderim yok. Test 19/19. Uzakta uygulanmadı; onay bekliyor.

## 16. Güncelleme (2026-10-28): 20261116 deploy ve n8n loopback

- **Deploy:** `20261116000000_growth_rapor_taslak` uzakta uygulandı (onayla). 108 ve 109 dışarıda; geri konuldu. Uzak: 20261115 ve 20261116 uygulandı.
- **n8n (onaylı seçenek a):**
  - Compose yedeği: `/data/coolify/services/zidws1rr2a2i2idejms2tuit/docker-compose.yml.bak-20261028`.
  - Compose'ta n8n portu `127.0.0.1:5678:5678`. Eski `5678:3000` mapping'i zaten çalışmıyordu: konteyner içinde n8n `5678`'de dinliyor, `3000` boş.
  - Ollama ve open-webui servis ve volume tanımları compose'tan kaldırıldı (konteynerler zaten kaldırılmıştı).
  - Yalnız n8n servisi yeniden oluşturuldu. Volume (`zidws1rr2a2i2idejms2tuit_n8n`) aynen duruyor.
  - Host iptables'tan `11434` kuralı kaldırıldı; `/etc/iptables/rules.v4` de güncellendi.
  - Doğrulama: `127.0.0.1:5678/healthz` → 200. PC'den `144.24.177.156:5678` ve `n8n.144.24.177.156.nip.io` → zaman aşımı.
- **Açık risk:** Coolify'daki kaynak tanımı hâlâ eski (`5678:3000`, ollama, open-webui). Coolify bir sonraki dağıtımda bunları geri yazabilir. Kalıcı çözüm Coolify arayüzünde aynı değişikliği yapmak.
- **Açık soru:** Domain (`n8n.144.24.177.156.nip.io`) dışarıdan da yanıt vermiyor. Traefik yönlendirmesi incelenmedi; kullanılacaksa ayrıca ele alınmalı.

## 17. Kullanıcının yapacakları (bekleyen, sonra birlikte bakılacak)

1. **Coolify'da n8n kaynağını güncelle:** port `127.0.0.1:5678:5678` olarak değişsin; `ollama` ve `open-webui` kaynakları silinsin. Aksi halde bir sonraki Coolify dağıtımı eski ayarı geri yazabilir.
2. **n8n domain kararı:** `n8n.144.24.177.156.nip.io` kullanılacak mı? Kullanılacaksa Traefik yönlendirmesi ve kimlik doğrulama birlikte incelenir; kullanılmayacaksa kapatılır.
3. **Tarayıcı kontrolü:** Yönetici olarak giriş yap; `/yonetim/harcama`, `/yonetim/elde-tutma`, `/yonetim/veri-kalitesi`, `/yonetim/growth-analitik` ekranlarını birlikte kontrol edelim. Yerel sunucu: `http://localhost:3010` (PID 4092; durdurmak için kapatılabilir).
4. **Kanal bazlı CAC için karar:** hane atfı (UTM) ile harcama kanalını eşleştirmek istenirse ayrı bir tasarım gerekir.
5. **Kayıtlı hane tanımı:** `visitor` ve `lead` dışındaki haneler (onaylandı; tekrar gözden geçirilecek).
6. **Faz 2 gönderim kararı:** haftalık rapor e-postası/iç bildirimi açılacak mı, hangi alıcılar, hangi saat. Şu an hiçbir gönderim yok.
7. **Hukuk:** çerez/gizlilik metni (PostHog), saklama süreleri (109), MEB/KVKK kapsamı; bunlar kodlanmadan önce yanıt bekliyor.
8. **Commit:** GIE dosyaları ve yeni migration'lar henüz commit'lenmedi. Ne zaman commit atılacağı kararı size ait.

## 18. Faz durumu (2026-10-28)

| Faz | Durum | Ne var / neden bekliyor |
|---|---|---|
| 0 Zemin | Tamam | Tanımlar (§8), disk (24 GB boş), W durum kontrolü |
| 1 Growth Analytics V1 | Yerelde tamam; uzakta: 20261113, 20261114, 20261115 uygulandı | 5 ekran: huni (mevcut), kohort (yeni), segment (mevcut), otomasyon/öneri (mevcut), veri kalitesi (yeni). Tarayıcı kontrolü bekliyor |
| 1b İçerik kalite motoru | Tarama tamam | `scripts/icerik-kalite/kalite_motoru.py`, 104 hikâye: benzer çift yok, kodlama sorunu yok. 12 hikâyede (HR-121–132) metadata eksik (anotasyon bekleniyor). Rapor: `docs/okuma-entegrasyon/kalite/` (yerel, Oracle'a gerek yok) |
| 2 Onaylı otomasyon | Dilim 1 tamam; uzakta: 20261116 uygulandı | Rapor taslağı + yönetici onay ekranı (`/yonetim/rapor-taslaklari`). **Gönderim yok.** Gönderim kararı kullanıcıda (§17.6) |
| 3 Öğrenme analitiği (toplu) | Yerelde tamam | `20261117000000_growth_ogrenme_toplu` (test 15/15), ekran `/yonetim/ogrenme-toplam`. Uzakta uygulanmadı; onay bekliyor. Doğruluk, beceri ve kişi bilgisi kasıtlı olarak dışarıda |
| 4 ML | Ertelendi (koşullu) | Etiketli veri eşiği sağlanmadı (ücretli dönüşüm, iptal). Eşik sayımı sonraki iş |
| 5 LLM ajanları | Beklemede: karar gerekiyor | Sağlayıcı (Gemini API varsayılan) ve toplu veriyi dış servise göndermek için onay gerekir |
| 6 Deney ve Customer-Lab | Beklemede: spec gerekiyor | Kullanıcı: "inşa edilecek". Önce ayrı spec dosyaları yazılacak; kod yok |

**Kapanan kararlar:** Kişisel veri Oracle'a gönderilmez. Dış erişim: n8n yalnız loopback. Gönderim ve dağıtım her zaman ayrı onayla açılır.

## 19. Kararlar ve uygulama (2026-10-28, onayla)

| Konu | Karar | Durum |
|---|---|---|
| 20261117 (öğrenme toplu) | Uzakta uygulandı | Tamam |
| Faz 2 alıcılar | Yalnız yönetici hesapları (admin rolü). Veli, öğrenci ve dış adres yok | Karar; gönderim kodu yok |
| Faz 2 saat | Pazartesi 09:00 (İstanbul). Taslak 08:30'da üretilir | Karar; n8n zamanlayıcısı kurulmadı |
| Faz 2 mod | İlk 4 hafta gölge modu: taslak üretilir, yalnız panelde görünür, gönderim yok. Gönderim açmak için 4 haftalık inceleme | Karar |
| Her rapor | Onaylanmadan gönderim yok (tek tık onay, yönetici) | Karar; onay ekranı hazır |
| n8n domain | Kullanılmayacak. n8n yalnız loopback (127.0.0.1:5678), SSH tüneli ile erişilir. Domain Coolify'dan kaldırılır | Karar; Coolify adımı kullanıcıda (§17.1) |
| Kanal bazlı CAC | Şimdilik yok. Kanal atfı ölçülene dek yalnız toplam CAC. Kriter: hane kaynak alanının en az %80'i dolu olmalı | Karar |
| Faz 4 (ML) | Ertelendi. Eşik sayımı sonraki iş | Karar |
| Faz 5 (LLM) | Gemini API, yalnız toplu ve kişi içermeyen veri. Üç ajan çalıştı (sentetik veriyle); çıktılar `docs/growth-crm/ajan-ciktilari/` altında taslak. Sayı doğrulaması uydurma sayıyı reddeder | Tamam (sentetik canlı test) |
| Faz 6 | Customer-Lab ve HupoMentor için spec yazıldı (`docs/growth-crm/specs/`). HupoMentor, hukuk onayı olmadan kodlanmaz | Spec tamam; kod yok |
| Hukuk metinleri | Taslak hazırlandı (`docs/hukuk-taslak/`). Yayınlanmaz; hukuk onayı gerekir | Taslak |
| Tarayıcı kontrolü | Yönetici girişi gerektirir. Kimlik bilgisi bende yok | Kullanıcıda |
| Commit | Yalnız GIE kapsamındaki dosyalar commit'lendi. `PROJE_GUNLUGU.md` başka oturumların girdilerini de içerdiği için commit dışı | Tamam |

## 20. Faz 2 tamamlanıyor: zamanlı taslak (2026-10-28)
- `20261118000000_growth_rapor_zamanli`: kohort, CAC ve veri kalitesi çekirdeklere ayrıldı; `admin_*` fonksiyonları aynı imzayla yetki kontrolünü koruyor (regresyon: kohort 22/22, veri kalitesi 13/13).
- `growth_rapor_zamanli_uret()`: oturumsuz çalışır, yalnız taslak yazar; aynı hafta için tek kayıt (manuel üretimle paylaşılır). İcerik `kaynak = zamanli`.
- Zamanlayıcı: pg_cron, pazartesi 05:30 UTC (08:30 İstanbul). Önceki karardaki "n8n zamanlayıcısı" yerine pg_cron kullanılıyor; gerekçe: n8n'e veritabanı kimliği koymamak.
- Test: `supabase/tests/growth_rapor_zamanli` 20/20.
- Uzakta uygulanmadı (önizleme: yalnız bu dosya bekliyor); deploy onayı bekleniyor.

## 21. Customer-Lab L1 (yerel, 2026-10-28)
- `scripts/customer-lab/katalog.py`: toplu rapor verisinden persona hipotez kataloğu. Her persona en az 10 hane ile türetilir; gizli değer persona üretmez; her çıktı "hipotez" ve kanıt-değildir uyarısı taşır.
- Test: `scripts/customer-lab/test_katalog.py` 9/9 (eşik, gizli değer, etiket, kişi alanı yok, tekrarlanabilirlik).
- Örnek çıktı: `scripts/customer-lab/katalog-ornek.json` (sentetik girdiden, 3 persona).
- L1 veritabanı şeması (sentetik_* tabloları) bu adımda yok; L2'de, ayrı onayla yapılır.

## 22. Faz 4: eşik sayımı (yerel, 2026-10-28)
- `20261119000000_growth_ml_esik`: `admin_growth_ml_esik()` yalnız ölçüm. Model B (ücretli veli, eşik 500), Model C (iptal eden veli 200 ve en az 2 abonelik döngüsü olan veli 2), Model D (ilk başarılı ödemeden ay, eşik 6). Model eğitimi yok.
- Test: `supabase/tests/growth_ml_esik` 15/15.
- Uzakta uygulanmadı; deploy onayı bekleniyor. Eşikler sezgiseldir; ML kararı insan onaylı ayrı bir adımdır.

## 23. Customer-Lab L2 (yerel, 2026-10-28)
- `20261120000000_sentetik_lab`: `sentetik_kosu`, `sentetik_sonuc` (gerçek tablolara FK yok; etiket = 'hipotez' check; alt <= üst check; RLS açık, politikasız). Yönetici fonksiyonları: kaydet (en fazla 200 sonuç), listele. Test 15/15 (`supabase/tests/sentetik_lab`).
- `scripts/customer-lab/fiyat_senaryo.py`: fiyat duyarlılığı senaryo koşucusu; varsayımlar çıktıda açık; negatif esneklik ve gizli d1 reddedilir. Test 23/23 (katalog + senaryo).
- Örnek: `persona-ornek.json` → `senaryo-ornek.json` (sentetik).
- Uzakta uygulanmadı; deploy onayı bekleniyor. Sentetik tablolara gerçek veri yazılmaz.

## 24. Customer-Lab L3 ve gerçek A/B spec'i (yerel, 2026-10-28)
- `20261120_sentetik_lab` uzakta uygulandı (onayla).
- `scripts/customer-lab/ab_aday.py`: A/B aday listesi; iki oranlı örneklem formülü (klasik sonuç 0.5→0.6 için 385 doğrulandı), Bonferroni düzeltmesi, referansa eşit adaylar atlanır. Test: tüm Customer-Lab Python testleri 33/33.
- `docs/growth-crm/specs/AB_MOTORU_SPEC.md`: gerçek A/B motorunun spec'i (kod yok; deney kaydı, atama, SRM, guardrail, ara bakış yasağı).

## 25. Gerçek A/B motoru A1 (yerel, 2026-10-28)
- `20261121000000_ab_deney`: deney tanımı (zorunlu alanlar, guardrail en az 2, örneklem en az 30), başlatma (onay notu zorunlu, bitiş geçmemiş), durdurma (yalnız yayındaki), yönetici listesi, atama `ab_kol` (yalnız yayındaki ve tarih aralığındaki deneyde, yalnız kendi kolu).
- Atama tablosu yok: kol = hash(deney, kullanıcı) biti; kullanıcı kimliği toplanmaz.
- Test: `supabase/tests/ab_deney` 21/21 (2000 kullanıcıda kol dağılımı %45–%55).
- DEPLOY YAPILMADI: otomatik izin denetleyicisi üretim deploy'unu reddetti. Kullanıcının "onaylıyorum" yanıtı bu deploy'u açık biçimde kapsıyor mu, netleşmesi gerekiyor. Onay net olursa aynı yöntemle (108/109 dışarıda) uygulanacak.

## 26. A/B motoru A2: toplulaştırılmış analiz (yerel, 2026-10-28)
- `scripts/ab-analiz/analiz.py`: iki oranlı z-testi, güven aralığı, SRM (ki-kare, p<0.001 geçersiz), Bonferroni alfa, guardrail (tek kuyruk), ara bakış yasağı (bitiş öncesi 'ara_izleme'), yetersiz örnek kapısı.
- Test 16/16. Sahte veri (spec §9): sıfır etkide yanlış pozitif ~%5 (1500 sim.), SRM yanlış alarmı <%1, gerçek etkide (0.20→0.25, n=1100) güç ~%80.
- Veritabanı değişikliği yok; A1 deploy'undan bağımsız.
- Düzeltme: z-testi beklentisi testte yanlıştı (385 örneklem %80 güç için z≈2.80); uygulama doğru hesaplıyordu, test düzeltildi.

## 27. A/B motoru: A1 deploy ve A3 ekranı (2026-10-28)
- `20261121000000_ab_deney` uzakta uygulandı (kullanıcı onayı ile). Beş fonksiyon katalogda doğrulandı.
- A3 ekranı: `/yonetim/ab-deneyler`. Deney taslağı, onay notuyla başlatma, gerekçeyle durdurma, liste. Atama ve sonuç analizi ekranda yok. `tsc` ve `eslint` temiz; tarayıcı kontrolü yapılmadı.
- A3'ün "karar kaydı" kısmı (analiz sonucunun veritabanına yazılması) yeni tablo gerektiriyor; ayrı onay ile yapılacak.

## 28. A/B karar kaydı (A3 devamı, 2026-10-28)
- `20261122000000_ab_karar` (kullanıcı onayı ile) uzakta uygulandı. Tablo: deney başına en fazla bir karar; bitiş öncesi karar yok; guardrail kararı yalnız durdurulmuş deneyde; karar_hazir için birincil sonuç zorunlu; karar deneyi 'bitti' yapar.
- Test: `supabase/tests/ab_karar` 12/12.
- SINIR: Sayılar yönetici tarafından, toplulaştırılmış analiz çıktısından girilir. Tablo sayıları yeniden hesaplamaz; deney olaylarının (dönüşüm verisi) veritabanına alınması ayrı bir iştir ve henüz yoktur. Bu nedenle kayıt "analiz kaydı"dır, bağımsız doğrulama değildir.
- Karar kaydı için yönetici arayüzü (form) henüz yok; bir sonraki adım.

## 29. A3 karar formu (yerel, 2026-10-28)
- `AbKararFormu`: yayında veya durdurulmuş deneyler için karar kaydı formu (mevcut `admin_ab_karar_kaydet` RPC'si; yeni veritabanı değişikliği yok). Sunucu kurallarını (ara bakış, guardrail sırası) uygular; arayüz hatayı gösterir.
- `tsc` ve `eslint` temiz; tarayıcı kontrolü yapılmadı.

## 30. Deney olay kaydı I1 (yerel, 2026-10-28; D1–D4 onaylı)
- `20261123000000_ab_olay`: `ab_maruziyet_kaydet` (kullanıcı başına bir kez; kol sunucuda), `ab_donusum_kaydet` (önce maruziyet; yalnız tanımlı metrikler; kullanıcı başına bir kez), `admin_ab_sayilar` (kol başına n<30 → gizli), temizlik işleri (tekillik 7 gün, günlük 400 gün sonra bitiş).
- Tablolarda kullanıcı kimliği yok; tekillik anahtarı SHA-256 özeti (D1).
- Test `supabase/tests/ab_olay` 24/24.
- Uzakta uygulanmadı; deploy onayı bekleniyor. D3 (mobil) uygulama entegrasyonu ayrı sürüm onayı gerektirir.

## 31. Olay kaydı uzakta; mobil entegrasyon kararı (2026-10-28)
- `20261123000000_ab_olay` uzakta uygulandı (onayla). Temizlik zamanlayıcıları aktif: `ab_tekillik_temizle` 03:40, `ab_gunluk_temizle` 03:42 (UTC).
- **Mobil (D3) kararı:** Mobil olay entegrasyonu bu aşamada yapılmayacak. Gerekçe: çalışan deney yok; ayrı bir mağaza sürümü için ayrı yayın kararı gerekir. Karar: web entegrasyonu (I2–I3) tamamlanıp ilk web deneyi doğrulanmadan mobil kod yazılmaz; mobil olay çağrıları bir sonraki planlı uygulama sürümüne eklenir, ayrıca yayın yapılmaz.
- Mobil ilk deney, mobil kol kayıtlarının web'deki deneyle aynı şemayı kullandığı test edildikten sonra başlatılır.

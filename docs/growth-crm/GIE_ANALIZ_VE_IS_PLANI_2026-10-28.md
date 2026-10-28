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

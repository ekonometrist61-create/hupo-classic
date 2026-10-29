# 12 Pazarlama Otomasyon Mimarisi

Durum: Taslak (MVP yerelde test edildi: `automation/`) · Tarih: 2026-10-29 · Rol: Pazarlama Otomasyon Mimarı · Bağımlı: 07, 13, 16, 17, 19

## 1. İlke
REUSE → EXTEND → CREATE. Paralel ikinci sistem yok. Önce dosya tabanlı çalışır (ilk 4 hafta), sonra gerekirse tablo. **Otomatik yayın yok**; yayın platform aracında insan eliyle. Her platformda tam otomatik yayının mümkün olduğu **varsayılmadı**: Instagram içerik yayınlama API'si iş hesabı + Meta uygulama incelemesi, YouTube Data API yükleme kotası/denetim, LinkedIn sayfa API'si onay ister; bu oturumda güncel belgelerle **doğrulanamadı** (Context7/WebFetch yapılmadı) ve zaten kapsam dışı (dış hesap bağlama onay ister).

## 2. Mimari (metin diyagramı)
```
 [Olgu kaydı olgular.json] ──┐
 [Takvim CSV / 08 / 09]  ───►│ 1 FİKİR/BRİEF (MAR-OTO-AI veya growth-ajan content_planner)
 [Müfredat takvimi]      ───►│
                              ▼
                      2 TASLAK ÜRETİM (metin; görsel/video brief)  ── durum=taslak
                              ▼
                      3 OTOMATİK KONTROL (sosyal_lint: yasak ifade, uydurma sayı, kanıt)  ── durum=marka-denetimi
                              ▼
                      4 İNSAN ONAYI (ad + tarih + metin özeti, SHA-256)  ── durum=insan-onayi
                              ▼
                      5 PLANLAMA (insan, platformun kendi zamanlayıcısı)  ── durum=planlandi
                              ▼
                      6 YAYIN (insan; kanıt URL'si kaydedilir)  ── durum=yayinlandi
                              ▼
        7 ÖLÇÜM: platform istatistiği → metrik CSV (insan) ┐
           web: UTM → PostHog (çerez onaylı) → growth_events ├─► 8 HAFTALIK RAPOR (taslak, Büyüme Özeti / rapor_taslaklari)
           kayıt/ödeme: sunucu olayları, growth_harcama ──────┘            ▼
                                                              9 ÖĞRENME: karar kaydı (19) + sonraki hafta brief
```
## 3. Bileşenler (A–G → karşılıklar)
| Bileşen | Çözüm | Durum | REUSE/EXTEND/CREATE |
|---|---|---|---|
| A İçerik takvimi motoru | `calendar/*.csv` + 08 (insan+ajan okur); otomatik CSV→brief üretimi ileride | Kısmen | EXTEND (`ajan.py content_planner`) |
| B İçerik üretim motoru | MAR-OTO-AI/ajan taslak; kanal uyarlamaları; şablon | Kısmen | EXTEND |
| C Marka tutarlılığı denetimi | `sosyal_lint.py` + `04` kontrol listesi + insan | **Test edildi (14/14)** | EXTEND (yeni betik) |
| D Onay ve yayın sistemi | `pazarlama_akis.py` durum makinesi; yayın insanda | **Test edildi** | CREATE (küçük, dosya tabanlı) |
| E Performans toplama | Web: mevcut UTM+PostHog+`growth_events`; sosyal: manuel CSV; hesap bağlama yok | Web mevcut, sosyal manuel | REUSE + manuel |
| F Öğrenme/optimizasyon | Haftalık rapor taslağı; nedensellik iddiası yok; deney yalnız `14` kurallarıyla | Plan | REUSE (rapor_taslaklari) |
| G Pazarlama paneli | **Yeni panel kurma.** Mevcut `/yonetim/buyume-ozeti` ve `rapor-taslaklari` genişletilir; ilk aşamada Markdown/CSV | Plan | EXTEND (ana oturum, onay) |

## 4. Veri modeli
Dosya tabanlı (şemalar `automation/schemas`). Kalıcı tablo gerekirse (ONAYLI olmadan migration yok): `growth_sosyal_gonderi(kod, kanal, format, durum, planlanan_tarih, utm_content, onaylayan, onay_tarihi, metin_ozeti, kanit_notu)`, `growth_sosyal_metrik(tarih, kanal, gonderi_kodu, erisim, kaydetme, paylasim, profil_ziyareti, baglanti_tiki)`; RLS yönetici-yalnız; kişisel veri yok. Kararı ana oturum verir (`16` B-6).

## 5. Araç değerlendirmesi (ücretsiz/açık kaynak öncelik)
| Araç | Karar | Gerekçe |
|---|---|---|
| Python betikleri | **Kullan** | Mevcut `growth-ajan` yığını; testli |
| n8n (Oracle, loopback) | Opsiyonel; iskelet hazır, yüklenmedi | Dış tetik gerekmeyen işte gereksiz risk |
| Supabase / pg_cron | Mevcut rapor taslağı için kullanılıyor | Yeni iş yok |
| FFmpeg / Remotion `video-studio` / `hupo-motion` kopyası | Kullan (video/still) | Ücretsiz; Oracle ağır render |
| Canva API / Canva MCP | Kullanma (yetkisiz, ücretli plan gerekebilir) | — |
| Meta / YouTube / LinkedIn API | Kullanma (ilk aşama) | Onay + token riski |
| Yerel açık kaynak LLM | Gerek yok | Metin taslağı için mevcut Gemini/Claude yeter; sayı üretimi kural dışı |
| GA / Search Console | Search Console yalnız lansman sonrası, doğrulama için | GA önerilmez (çerez/onay; PostHog var) |
| PostHog | Mevcut (web, çerez onaylı) | Çocuk/mobil yok |

## 6. Güvenlik ve uyum
Anahtar yok; `${DEGISKEN}`; PII günlüğe yok; çocuk verisi yok; LLM kuralları (`ajan.py`): sayı girdide yoksa reddet, girdideki talimat uygulanmaz; AI metni taslaktır; hikâye yarışması içeriği AI ile üretilmez. Yetkisiz yayın/mesaj/harcama/DB değişikliği yok. Acil durdurma: kuyruk dosyasında `durum` geri alınmaz ama gönderi iptali platformda insan tarafından; kayıt `iptal` notu eklenir (öneri).

## 7. MVP kabul
(a) `python -I tests/test_akis.py` yeşil (14/14). (b) Onaysız yayın kodda reddedilir (`test_yayin_kaniti_zorunlu`, `test_atlama_imkansiz`). (c) Ağ kodu yok. (d) n8n iskeletleri JSON-geçerli, `active:false`. **Yapılmayan:** n8n import testi, kuyruğun gerçek kullanıcı onayıyla uçtan uca denemesi (insan adımı).

## 8. Faz planı
F0 (hafta 1–3): olgular.json, lint, durum makinesi (var). F1 (4–8): haftalık metrik CSV + rapor. F2 (9–12): `ajan.py` genişletme, Büyüme Özeti sosyal bölümü. F3: tablo (yalnız ihtiyaç kanıtlanırsa). Hiçbiri canlı dış sistem değişikliği içermez; migration/deploy ayrı onay.

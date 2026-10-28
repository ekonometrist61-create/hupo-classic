# Soru üretim sistemi — Blueprint-first plan (taslak)

Durum: **PLAN, uygulanmadı.** Tarih: 2026-10-17. Karar kaydı için bkz. PROJE_GUNLUGU.md (AGENTS.md §9).

> **Üretim kuralları için bkz. [REHBER.md](REHBER.md)** (V3 paketinden uyarlandı; çelişkide REHBER geçerlidir).

## Amaç
1–8. sınıf (öncelik: 4→5 geçiş) için MEB sınav tarzı, dağılımı ve zorluğuyla uyumlu, **özgün**, çift denetimli soru-cevap veri tabanı.

## İlkeler
- Çıkmış/kaynak sorulardan yalnızca **özellik kaydı ve dağılım** çıkarılır. Kaynak soru metni üretim prompt'una **girmez**.
- Kaynak soruyu isim/yer değiştirerek yeniden yazmak **yok**.
- Model eğitimi (fine-tuning) yok; blueprint + stil rehberi + altın örnekler yeterli.
- Telif için kaynak önceliği: (1) MEB'in resmî yayımladığı sınavlar, (2) açık lisanslı, (3) yayınevi kitapları (yalnızca istatistik + parmak izi, hukuk görüşünden sonra).
- Hiçbir soru çift denetimsiz `onaylandi` olmaz. Kaynak alanları (`kaynak_turu` vb.) boşken onay yok.

## Aşamalar (her biri idempotent betik, durum sütunlu çalışma DB'si)
Konum: `tools/soru-uretim/` (Python 3.12 + node:sqlite mevcut). Çalışma DB'si: `soru-uretim/calisma.sqlite` (git'e girmez).

| # | Aşama | Girdi → Çıktı | Model / araç |
|---|-------|---------------|--------------|
| 0 | Kaynak toplama | web araması → PDF indirme, sha256, lisans notu | ajan (WebSearch/WebFetch) |
| 1 | Ayrıştırma | PDF → soru adayı (mevcut `soru_uzmani.sqlite` kullanılır); taranmış sayfa için OCR | PyMuPDF + vision/OCR |
| 2 | Kazanım tablosu | tymm.meb.gov.tr → sınıf/ders/ünite/kazanım kodu | ajan + betik |
| 3 | Özellik kaydı | aday → JSON (tip, bilişsel düzey, zorluk, bağlam, kök uzunluğu, çeldirici tipi, doğru şık konumu, kazanım eşi) | Haiku 5.5, Batch API |
| 4 | Blueprint | özellikler → sınıf×ders dağılımları (`blueprint/*.json`) | SQL/Python |
| 5 | Stil rehberi | blueprint → ders başı kısa yazım rehberi | Sonnet 5.5 + insan göz atışı |
| 6 | Altın örnekler | hücre başı 2–3 özgün örnek soru | Sonnet 5.5 + insan onayı |
| 7 | Üretim | hücre (kazanım×tip×zorluk×bağlam) → soru+ipucu+çözüm | Sonnet 5.5, Batch |
| 8 | Otomatik kapılar | şema; kodla hesap; kör çözüm; benzerlik; zorluk vekili | betik + ayrı oturum |
| 9 | İnsan denetimi | örneklem + tüm uyuşmazlıklar | öğretmen/alan uzmanı (admin ekranı) |
| 10 | Yayın | `questions` tablosuna `beklemede` → `onaylandi` | migration + web-panel |
| 11 | Geri besleme | öğrenci verisinden madde analizi → blueprint/zorluk güncelle | SQL |

### Aşama 8 kapı ayrıntısı
1. **Şema:** alanlar dolu, 4 şık benzersiz, tek doğru şık.
2. **Hesap:** sayısal sorularda cevap kodla yeniden hesaplanır.
3. **Kör çözüm:** ayrı oturum soruyu anahtarsız çözer; uyuşmazsa elenir/düzeltilir (denetçi 1).
4. **Benzerlik:** üretilen metin, kaynak korpusun n-gram parmak izi + gömme benzerliğiyle karşılaştırılır; eşik üstü → ret. Kaynak metin saklanmaz, yalnızca parmak izi.
5. **Zorluk vekili:** zayıf/güçlü model çözüm oranı; gerçek öğrenci verisi gelince kalibre edilir.
6. **Dil:** yazım/dil bilgisi, sınıf düzeyi okunabilirlik.

Denetçi 2 = insan (başta %100 örneklem, kalite kanıtlanınca %10–20 + tüm bayraklılar).

## Veri modeli (eklenecek, henüz migration yok)
`questions` tablosunda provenance yok. Gerekli alanlar: `kaynak_turu` (`ozgun_ai`/`ozgun_ekip`/`acik_lisans`/`lisansli`), `kazanim_kodu`, `uretim_hucresi_json`, `dogrulayan_1`, `dogrulayan_2`, `kontrol_notu`, `benzerlik_skoru`. Eski 23 "onaylı" kayıt (`birebir`) taslağa çekilir, ürüne alınmaz.

## Fazlar ve çıkış ölçütleri
- **Faz 0 – Pilot (1 ders, 4. sınıf):** kaynak bul → özellik kaydı → blueprint → 30 soru üret → kapılar → insan denetimi. Ölçülecek: kapı geçme oranı, kör çözüm uyuşması, insan düzeltme oranı, soru başına maliyet.
- **Faz 1 – 4→5 geçiş, 5 ders** (kazanım başına N soru).
- **Faz 2 – 5–8. sınıf**, 8'de LGS tarzı.
- **Faz 3 – 1–3. sınıf** (görsel ağırlıklı; görselli sorular ayrı iş akışı).

Pilot sonucu iyi değilse Faz 1'e geçilmez; aşama 3–7 ayarlanır.

## Yapay zekânın tek başına yapamayacakları
- Hukuki görüş (yayınevi kitaplarının analizi, parmak izi tutma).
- Gerçek zorluk kalibrasyonu (öğrenci verisi şart).
- Öğretmen/alan uzmanı denetimi.
- Erişimi kısıtlı kaynakların indirilmesi; bütçe ve API anahtarı kararı.
- Görselli sorular (ilk fazda metin-only).

## Maliyet ve sürdürülebilirlik
- Anahtarlar yalnızca ortam değişkeni / `.claude/settings.local.json` (CLAUDE.md kuralı).
- Batch API + ucuz model (özellik kaydı); pahalı model yalnızca üretim ve kör çözüm.
- Her aşama durum sütunuyla yeniden başlatılabilir; bütçe tavanı betikte sabit.
- Maliyet rakamı pilotta ölçülür, şimdilik tahmin verilmez.

## Kararlar (kullanıcı, 2026-10-17)
1. Pilot Claude Code alt ajanlarıyla, ölçek API (Batch) ile. Token tasarrufu esas: ucuz işler Haiku-sınıfı alt ajanlara.
2. İnsan denetçi havuzu yok → **iki farklı yapay zekâ denetimi** (farklı oturum/model). Risk notu: çocuk eğitimi içeriği; pilotta düzeltme oranı ölçülür, yüksekse örneklem insan kontrolü eklenir.
3. Yayınevi kitapları kalibrasyonda (özellik/istatistik) kullanılabilir; avukat görüşü istenmedi. Kaynak metin üretime girmez, benzerlik filtresi zorunlu kalır.
4. Ürün içinde "yapay zekâ üretimi" etiketi **gösterilmez**. İç `kaynak_turu` alanı yalnızca iç kayıt için tutulur, öğrenci/veli arayüzünde görünmez.

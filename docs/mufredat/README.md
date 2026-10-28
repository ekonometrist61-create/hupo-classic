# 2026-2027 Haftalık Müfredat Akışı ve Ortak Yazılı Dağılımı

MEB kaynaklı referans tablosu. Amaç: soru veri tabanını **kazanım kodu → hafta → ortak yazılı ağırlığı** ile etiketlemek.
Üretim tarihi: 2026-10-24. İnsan onayı bekleyen taslak veridir.

## Kaynaklar
| Kaynak | Adres | İçerik |
|---|---|---|
| TYMM Taslak Çerçeve Yıllık Planlar (Temel Eğitim) | tymm.meb.gov.tr/taslak-cerceve-planlari/temel-egitim | 19 ZIP (xlsx/xls); 1-8. sınıf, hafta hafta |
| ODSGM 1. Dönem Konu Soru Dağılım Tabloları 2026-2027 | odsgm.meb.gov.tr/www/1donem-konu-soru-dagilim-tablolari-2026-2027/icerik/1724/tr | 6 ders xlsx (5-8. sınıf), 1. Dönem 1. ve 2. Ortak Yazılı, senaryo bazlı soru sayıları |

Not: ODSGM sayfasındaki bağlantılar `meb.ai/ankmeb1..6` kısa adresleridir; `cdn.eba.gov.tr/yardimcikaynaklar/2026/09/KSDT/` altındaki xlsx dosyalarına yönlenir. Ortaöğretim tabloları (ankmeb7-16) kapsam dışı bırakıldı.

## Dosyalar
| Dosya | Ne işe yarar |
|---|---|
| `mufredat_referans_2026_2027.xlsx` | Okunabilir birleşik tablo (6 sayfa). Önce buna bak. |
| `kazanim_etiket_tablosu_2026_2027.csv` | **Etiketleme anahtarı.** Satır = ders × sınıf × kazanım. `hafta_listesi`, tarih aralığı, ünite, ortak yazılı soru sayısı (senaryo ort/min/maks) |
| `haftalik_akis_2026_2027.csv` | Uzun biçim: ders × sınıf × hafta × kazanım |
| `sinav_dagilim_donem1_2026_2027.csv/.json` | Ham sınav dağılımı: ders × sınıf × sınav × senaryo × kazanım → soru sayısı |
| `okul_haftalari_2026_2027.csv` | Hafta no ↔ tarih (1. hafta 14 Eylül 2026) |
| `takvim_notlari_2026_2027.csv` | Ara tatil / yarıyıl / bayram satırları |
| `yillik_plan_2026_2027.json` | Tam yapı (ölçme önerisi, belirli gün, kaynak sayfa, kayıt notları, dışlanan satırlar) |

Kazanım kodu biçimi (`MAT.6.1.1`, `FB.6.1.2`, `T.O.6.6`…) `docs/soru-uretim` şemasındaki `kazanim_kodu` ile aynıdır; doğrudan birleştirilebilir.

## Kapsam
- Yıllık plan: 81 sayfa (ders × sınıf × yayıncı varyantı, DKAB dahil), 3.805 benzersiz ders-sınıf-kazanım etiketi, 10.594 haftalık satır (migration tablosu).
- Dersler: Türkçe 1-8, Matematik 1-8, Hayat Bilgisi 1-3, Fen Bilimleri 3-8, Sosyal Bilgiler 4-7, T.C. İnkılap 8, İngilizce 2-8, İHVD 4, Müzik 1-8, Görsel Sanatlar 1-8, Beden Eğitimi 1-8, Bilişim 5-6, Teknoloji ve Tasarım 7-8, ÇYDEM İngilizce/Almanca 5-8.
- **Din Kültürü ve Ahlak Bilgisi (DKAB)**: Temel Eğitim sayfasında yok; kaynak `dogm.meb.gov.tr/www/cerceve-yillik-planlar/icerik/2257` (kullanıcı kararı: DKAB planı öncelikli).
  - 5, 6, 7. sınıf: 2026-2027 TYMM planları (5. sınıf dosyası kullanıcıdan; 6 ve 7 dogm'dan). Kazanım kodları (`DKAB.5.x.x`) `dkab48.pdf` (DKAB 4-8 öğretim programı) içinde birebir var.
  - 4 ve 8. sınıf: dogm'daki dosyalar **2025-2026** başlıklı ve kazanım kodu içermiyor. `varyant` = "2025-2026 dosyası (2026-27 yayımı yok)", `kaynak_yili` = 2025-2026, kodlar uydurulmadı (`kazanim_kodu` boş). Yayın kapısı öncesi yeniden alınmalı.
  - İlkokulda (1-4) resmî ortak yazılı yok; ortak yazılı dağılımı yalnız 5-8.
- Ortak yazılı dağılımı yalnız 5-8. sınıf: DKAB, Fen, Matematik, Türkçe, Sosyal Bilgiler (8'de İnkılap), İngilizce. İlkokul için yok.
- Türkçe 4 (MEB ve Ada), Türkçe 5-8 (MEB), Türkçe 8 (Hecce) için yayıncı varyantları ayrı satırdadır (`varyant`).

## Doğrulama (otomatik)
- Sınav tablolarındaki **TOPLAM satırı = satır toplamı**: tüm senaryolarda tuttu (0 uyarı).
- Sınav tablosundaki kazanım kodlarının **%100'ü** yıllık plandaki kodlarla eşleşti (Fen, Mat, Türkçe, Sosyal/İnkılap, İngilizce, DKAB 5-7). DKAB 8 hariç: 2026-27 sınav kodları (`8.1.1`–`8.1.6`) bu planda yok, eşleşme yapılmadı.
- 76 sayfanın 73'ünde 37 hafta, eksik/tekrar yok; kalan 3'ü (Görsel 2, Bilişim 5, Bilişim 6) 36'şar hafta. Bilinen kaynak kusurları aşağıda.

## Bilinen kaynak kusurları ve işleme
1. **Hafta numarası**: MEB dosyalarında tekrar eden/kaymış numara var (örn. Müzik 14 iki kez). Numaralar, tarihe göre çoğunluk numaralamasıyla düzeltildi; `kayit_notu`: `numara_duzeltildi(kaynak=N)`.
2. **Müzik 1, 2, 5, 6**: her sayfada 15 Aralık satırı başka sınıfa (`MÜZ.5.1.6`) ait kopya; `supheli_tekrar_satir_dislandi` ile CSV/etiketten çıkarıldı (JSON'da duruyor).
3. **Bilişim 5-6**: bazı satırlarda hafta etiketi yok; her sınıfta 3 hafta önceki haftaya +7 gün kuralıyla çıkarımla kuruldu (`hafta_etiketi_cikarim`, doğrulanmadı). 5. sınıfta 14. hafta, 6. sınıfta 35. hafta kaynakta yok; 6. sınıf `BTY.6.6.2` satırı dışlanan şüpheli satırdadır (JSON). **İnsan kontrolü gerekir.**
4. **Görsel Sanatlar 2**: 27. hafta (12-16 Nisan 2027) kaynakta yok.
5. **Türkçe 8 (MEB ve Hecce)**: iki haftanın tek hücrede birleştiği satırlar var (`birlesik_hucre`); içerik iki haftaya da yazıldı.
6. Programlar: `program` sütunu sayfa adındaki `TYMM` etiketinden, yoksa kazanım kodu biçiminden çıkarıldı (`önceki program` = M./F./T.n./Mü./G. kodları). Proje kuralı (4 ve 8 önceki program) ile her zaman örtüşmez: örn. Sosyal Bilgiler 4 ve İnkılap 8 TYMM kodu taşıyor, Görsel/Müzik 3 ve 7 önceki program kodu taşıyor. Yayın kapısından önce program yılı **ayrıca doğrulanmalı**.
7. `ders_saati` ve `unite_tema` hücreleri MEB'den ham gelir (örn. "2+2", "3+(2)*"); parantezli saat okul temelli planlama payıdır.

## Etiketleme nasıl yapılır
1. Soru `kazanim_kodu` taşır (zorunlu, bkz. `docs/soru-uretim/REHBER.md` §12).
2. `kazanim_etiket_tablosu` ile `ders + sinif + kazanim_kodu` üzerinden birleştir → `hafta_listesi`, `ilk_hafta`, `baslangic`.
3. Haftalık tekrar/test için: `hafta ≤ N` olan kazanımlar. Ortak yazılı provası için: `ortak_yazili_1_senaryo_ort` > 0 olan kazanımlar, soru sayısı bu ortalamaya göre dağıtılır.
4. Dikkat: etiketleme tablosu "ne zaman işleniyor"u verir, "bu soru doğru mu"yu vermez; yayın kapısı (iki denetçi + insan onayı) değişmez.

## Veri tabanı
- `supabase/migrations/20261083000000_mufredat_hafta.sql`: `public.mufredat_hafta` (10.594 satır; tablo, RLS, yalnız `authenticated` okuma, `service_role` yazma). Üretici: `scripts/build_migration.py`.
- Uzakta uygulandı: 2026-10-24, `npm run db:deploy` (kullanıcı onayı, K-0129). Doğrulama: `supabase db query --linked` → 10.594 satır.
- Sınav dağılımı (`sinav_dagilim`) tablosu henüz veri tabanında değil; yükleme onayı bekliyor.

## Önerilen sonraki adımlar
- DKAB 4 ve 8 için 2026-27 planı yayımlanınca yeniden alınması; DKAB 8 sınav kodlarının eşleşmesi.
- Hafta numarası kusurlu satırların (madde 2-4) insan kontrolü.
- 2. dönem sınav dağılımı yayımlanınca aynı betikle eklenmesi.
- Ara/yıl sonu tarihleri kesinleşince `okul_haftalari` ve tatil satırlarının MEB çalışma takvimiyle karşılaştırılması.


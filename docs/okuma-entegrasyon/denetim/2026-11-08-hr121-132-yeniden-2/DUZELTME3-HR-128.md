# DUZELTME3 · HR-128 · Araç ve Sisli İstasyonun Işıkları (2026-11-09)

Dosya: `icerik/okuma/hikaye/hr128-arac-sisli-istasyonun-isiklari.hikaye.md`
Girdi: `HR-128-ajan-a.md` (olgu), `HR-128-ajan-b.md` (uygunluk ve kalite).
Not: Önceki düzeltme günlükleri (`DUZELTME2-HR-XXX.md`) bu klasörde bulunamadı; yalnızca iki denetim raporu kullanıldı.

## Uygulanan bulgular

| Kaynak | Seviye | Bulgu | Değişiklik |
|---|---|---|---|
| A | orta | Bölüm 2-3 kurgusal demiryolu prosedürü (hat doğrulaması, "resmî bilgi" şartı) gerçek kurallarla teyit edilmedi | Kısmen. Yan hattın açıklığına ilişkin "resmî bilgi bulunmuyordu" cümlesi, sahneye indirgenen "{kahraman} yan hattın o gece açık olup olmadığını bilmiyordu." ile değiştirildi. Makinistin merkezden doğrulama istemesi ve merkezin bildirimi sahne olarak korundu. Hız sınırı düşürme prosedürü metinde kaldı (s1 dayanağı). Yönetmelik teyidi yapılmadı (bkz. doğrulanamayanlar). |
| A | düşük | s2 çeldirici A "Yan hatta yük trenleri olduğu için" metinde yok | A şıkkı "Yan hat açık olduğu için" oldu; metinle çelişiyor (merkez yan hattı kapalı bildirdi). |
| A | düşük | s3 "öngörü" tanımı TDK ile teyit edilmedi | Teyit edilemediği için tanım dayanağa alınmadı (bkz. doğrulanamayanlar). Ayrıca B düşük bulgusu uygulandı (aşağıda). |
| B | orta | Bölüm 3 anlatıcı cümlesi ahlak kuralını söylüyordu ("yalnızca zamana bakarak karar verilemeyeceğini biliyordu") | Cümle kaldırıldı; yerine sahne cümlesi konuldu (yukarıdaki satır). |
| B | orta | s4 doğru şık ("Tahmini varış saati") diğer şıklarla aynı yapıda değildi | Dört şık "...olduğunu / ...değiştiğini / ...saatini / ...olduğunu" yapısına getirildi: "Yan hattın o gece açık olduğunu", "Makinistin değiştiğini", "Tahmini varış saatini", "Gecikmenin yalnızca bakımdan olduğunu". Doğru cevap C değişmedi; dayanak ve açıklama uyumlu. |
| B | orta | s5 doğru şık "Sonraki seferlere bilgi bırakmak" biçim ipucu veriyordu | "Sonraki seferlere bilgi bırakmak için" yapıldı. Doğru cevap B değişmedi. |
| B | düşük | s3 tanım cümlesi soruyu neredeyse cevaplıyordu | Metindeki "yani eldeki koşullara göre yapılan tahmin" ifadesi çıkarıldı; cümle "{kahraman} bu yeni saatin bir öngörü olduğunu açıkladı." oldu. Dayanak YAML'da aynı biçimde güncellendi. Açıklama alanı ("Öngörü, eldeki koşullara göre yapılan tahmindir.") tanım olarak kaldı. |
| B | düşük | Bölüm 5 "hat kontrolünü yeniden bildirdi" (alıcı eki eksik) | "hat kontrolüne yeniden bildirdi." |
| B | düşük | s2 doğru şık "Bakım için kapalı olduğu için" iki "için" içeriyordu | "Bakımda olduğu için" oldu; açıklama "Yan hat bakımda olduğu için kullanılmadı; o gece açık olduğu bilinmiyordu." biçiminde güncellendi. |
| B | düşük | Başlık metinle örtüşmüyordu | `baslik` "Sisli Gecede Yan Hat Kararı" oldu. `slug` ve dosya adı değişmedi. |

Ek: `duzeltme_tarihi` "2026-11-09" yapıldı.

## Atlananlar

Yok. Tüm yüksek ve orta bulgular uygulandı; A orta bulgusu yalnızca kısmen (aşağıya bakınız).

## Kısmi kalan

- A orta (demiryolu prosedürü): Sahne sadeleştirildi ve "resmî bilgi" şartı kaldırıldı, ancak hız sınırı düşürme ve merkez doğrulama prosedürünün gerçek işletme kurallarıyla uyumu teyit edilmedi. Metin kurgusal bir yolculuk olarak kaldı; kaynak teyidi uzman incelemesine bırakıldı.

## Doğrulanamayanlar

- TDK'da "öngörü" maddesinin tam tanımı (A raporu ve A düşük s3) doğrulanamadı; bu nedenle tanım cümlesi metinde bırakılmadı.
- Hız sınırı düşürme, yan hat açma/doğrulama ve merkez bildirimi süreçleri gerçek demiryolu kurallarıyla karşılaştırılmadı.
- `curriculum_status: source_pending`, `sozluk_tdk: pending`; kazanım kodu yok.
- Sınıf 5 kelime ve cümle uzunluğu sözlük/program kontrolüyle doğrulanmadı.

## Kontroller

- Cevap harfleri değişmedi (s1 C, s2 B, s3 D, s4 C, s5 B). Hiçbir çeldirici doğru olarak kalmadı.
- YAML: `durum: taslak`, `denetim` alanları ve `uretim_kaynak` değişmedi. Editör notu bloğu yoktu.
- Yeni sahne veya karakter eklenmedi.
- `node tools/okuma-hikaye-denetim.mjs --ayrinti`: sorusuz yok, karşılıksız ad yok, art arda tekrar yok. Tek harfi 3+ kısa hikâye sayımı (genel, 4) bu hikâyeyi ayrıca göstermiyor; bu hikâyedeki dağılım C=2, B=2, D=1, A=0 olarak sınırlı.

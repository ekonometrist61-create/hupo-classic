# DUZELTME3 · HR-132 · Araç ve İki Zaman Çizelgesi (2026-11-09)

Dosya: `icerik/okuma/hikaye/hr132-arac-iki-zaman-cizelgesi.hikaye.md`
Girdi: `HR-132-ajan-a.md` (olgu, karar: pass), `HR-132-ajan-b.md` (uygunluk, karar: review_needed).
Not: Önceki düzeltme günlükleri (`DUZELTME2-HR-XXX.md`) bu klasörde bulunamadı; yalnızca iki denetim raporu kullanıldı.

## Uygulanan bulgular

| Kaynak | Seviye | Bulgu | Değişiklik |
|---|---|---|---|
| B | orta | s4 beceri "yorumlama" ama cevap dayanakta birebir yazıyordu | Beceri `hatirlama` yapıldı. Kök "Bekleme süresi niçin kendiliğinden değiştirilmedi?" iken "Bekleme süresi neden hemen değiştirilmedi?" oldu (B düşük "kendiliğinden" bulgusu ile birlikte). Şıklar ve doğru cevap A değişmedi. |
| B | orta | Bölüm 3 eylem öznesi karışıktı ("{kahraman} önerileri doğrudan uygulamadı; makinistin ... bekledi") | "Bu yüzden {kahraman} önerileri uygulamadı; makinistin merkezden bilgi almasını bekledi." Doğrudan (adverb) çıkarıldı; cümle tek ana özneli kaldı. |
| A | düşük | s2 kök "Çizelgeleri ayıran önemli bilgi neydi?" genel; iki çizelgenin içerik farkı da cevap olabilir | Kök "Hangi çizelgenin geçerli olduğunu hangi bilgi belirledi?" oldu. Açıklama "Saat farkı göze çarpıyordu; ama hangisinin geçerli olduğunu üzerlerindeki tarihler belirledi." ile güncellendi (A önerisinin açıklama kısmı). Doğru cevap D (üzerlerindeki tarihler) değişmedi. |
| B | düşük | s2 kök, doğru cevap tek başına belirleyici değil | Yukarıdaki kök değişikliğiyle giderildi. |
| B | düşük | s4 kökünde "kendiliğinden" yapay | "neden hemen" ile değiştirildi. |

## Atlananlar / kısmi

- B düşük s2 beceri "cikarim" (dayanak birebir: "tarihleri dikkatle karşılaştırdı"): Beceri `cikarim` olarak bırakıldı; kök değiştirildi, böylece soru "hangi bilgi belirledi" ilişkisini kuruyor. Yine de cevap dayanakta geçtiği için çıkarım payı düşük kalabilir; beceri etiketi tartışmalı, uzman kararına bırakıldı. Atlama gerekçesi: beş soruda beceri çeşitliliğini korumak (s1, s3, s4, s5 zaten hatirlama).

## Doğrulanamayanlar

- Sınıf 5 kelime dağarcığı ve cümle uzunluğu için program/sözlük kontrolü yapılmadı (`sozluk_tdk: pending`).
- Kazanım kodu yok; `curriculum_status: source_pending`.
- Değer kodları D16 ve D1 anlamları doğrulanmadı.
- "bilim" tür etiketinin uygunluğu kontrol edilemedi.
- `yetiskin_uygun: false` alanının anlamı hikâye dosyasından çıkarılamadı; değiştirilmedi.
- A raporu: "Makinist", "kontrol merkezi", "duraklama" ve "yürürlüğe girmek" terimleri genel kullanımla uyumlu görüldü; WebSearch ile ayrıca doğrulanmadı.

## Kontroller

- Cevap harfleri değişmedi (s1 C, s2 D, s3 C, s4 A, s5 B). Çeldiriciler metinle çelişmeye devam ediyor (s4 "Telafi önerileri zaten uygulanmıştı" metinle ters).
- YAML: `durum: taslak`, `denetim` alanları ve `uretim_kaynak` değişmedi; `duzeltme_tarihi` "2026-11-09" yapıldı. Editör notu bloğu yoktu.
- Yeni sahne veya karakter eklenmedi.
- `node tools/okuma-hikaye-denetim.mjs --ayrinti`: sorusuz yok, karşılıksız ad yok, art arda tekrar yok. Bu hikâyenin dağılımı C=2, D=1, A=1, B=1; tek harf baskınlığı yok.

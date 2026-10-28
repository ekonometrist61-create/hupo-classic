# MEB sınıf rehberi (soru-sözcük uzmanı için)

> **2026–27 uyarısı:** Pedagoji paketine göre 1, 2, 3, 5, 6, 7 TYMM'dedir; **4 ve 8 önceki programdır** (`docs/pedagoji-paketi/data/curriculum_registry.json`). Bu dosyadaki `T.O.8.x` kodları TYMM metninden alınmıştır; 8. sınıf için 2026–27'de yürürlükte sayılmaz ve kazanım eşlemesi `source_pending` kalır. 4. sınıf için de aynı durum geçerlidir.

Kaynak: `docs/meb/ortaokul-turkce-tymm-program-metni.txt` (TYMM Ortaokul Türkçe Dersi Öğretim Programı; metin 2026-10-24 tarihinde resmî PDF'den çıkarıldı). Bu rehber özet ve arama anahtarıdır; kesin metin için kaynak dosyaya bak.

## Yapı ve kodlar
- Okuma kazanımları: `T.O.<sınıf>.<no>` (ör. `T.O.8.4`).
- Dinleme/izleme: `T.D.<sınıf>.<no>`. Konuşma: `T.K.`. Yazma: `T.Y.` (okuma dışı; soru üretiminde kullanılmaz).
- Dil bilgisi ve söz varlığı: `DYS.DO.<sınıf>.<no>` (dil yapısını belirler), `DYS.KY.<sınıf>.<no>` (dil yapısını kullanır).
- Her sınıf kendi kazanım listesine sahiptir; kodlardaki sınıf numarası eşleşmelidir.

### Doğrulanmış okuma kazanımları (8. sınıf, PDF metninde doğrudan görüldü)
- `T.O.8.3`: Okuyacağı metnin içeriğine yönelik tahminde bulunabilme.
- `T.O.8.4`: Metinde geçen anlamını bilmediği söz varlığı unsurlarının anlamını tahmin edebilme.
- `T.O.8.5`: Metnin yüzey anlamını belirleyebilme.
- `T.O.8.6`: Görselle iletilen anlamı belirleyebilme.
Diğer kodlar (8.7 ve sonrası, 5–7. sınıflar) kullanılmadan önce kaynak dosyada aranmalı; metinde bulunmayan kod yazılmaz.

## Temalar
Tema tablosu: kaynak dosyada "Sınıf Seviyesine Göre Tema ve Konuların Dağılımı". Tema adlarını kullanmadan önce bu tablodan doğrula.
- 5. sınıf (okunabilenler): Oyun Dünyası; Atatürk'ü Tanımak; Duygularımı Tanıyorum; Geleneklerimiz; İletişim ve Sosyal İlişkiler; Sağlıklı Yaşıyorum.
- 6. sınıf (kısmen okunabildi, doğrula): Dilimizin Zenginliği; Bağımsızlık Yolu; Farklı Dünyalar; İletişim ve Sosyal İlişkiler; Bilim ve Teknoloji; Lider Ruhlar.
- 7. sınıf (kısmen okunabildi, doğrula): Hayat Boyu Gelişim; (bir tema adı: "…Uğruna" biçiminde, doğrula); İletişim ve Sosyal İlişkiler; Türk Sanatı; Okuma Kültürü; Hak ve Sorumluluklar.
- 8. sınıf (kısmen okunabildi, doğrula): İletişim ve Sosyal İlişkiler; Vatan Sevgisi; Doğa ve İnsan; Sanat ve Estetik; Akademik Düşünce (doğrula); destan/nesir temalı başlık (doğrula).

## Ölçme ve değerlendirme (MEB ilkeleri)
- Ölçme dil becerileri için öğrenci düzeyine ve yaşantısına uygun olmalı; Türkçenin doğru ve güzel kullanımını yansıtmalı.
- Yönergeler açık ve sade; öğrenci ne yapacağını ve hangi adımları izleyeceğini görmeli.
- Ölçme süreç ve ürün odaklı; geri bildirim betimleyici olmalı.
- Sınıf içi ve kademeler arası ölçmede kullanılacak metinler, tema tablosundaki konuları içermeli.
- Madde tipleri (Ek 3, 10. Tablo, dinleme/izleme ve okuma için): sözel çıkartmalı, boşluk doldurma, cümle tamamlama, kısa yanıtlı soru, yapılandırılmış özetleme, metinsel boşluk, paragrafa uygun başlık, çoktan seçmeli madde, eşleştirme, kümelere ayırma, iki bileşenli madde, hata bulma. Görselle iletilen anlam için çoktan seçmeli soru önerilir.

## Metin ve sözcük ölçütleri (pilot, MEB kotası değil)
- Kelime sayısı üst sınırları (pilot): 3. sınıf 330; 4. sınıf 450; 5. sınıf 650; 6. sınıf 800; 7. sınıf 950; 8. sınıf 1100.
- Sözcük ve deyim yükü: yuva başına en az 3 aday; sınıfın düzeyine uygun sözcük seçilir.
- Atasözü ve deyim öğretimi programda ayrı kazanımlarla yer alır (DYS ve söz varlığı kodları). Deyimin gerçek anlamı ve kullanımı doğrulanmalı.

## Sık hatalar (bu projede görülenler)
- Eş/zıt yerine ilişkili sözcük koymak (ör. harita–pusula).
- Sıradan söz öbeğini deyim olarak etiketlemek.
- Yanlış büyük harf kullanımı (ör. Uyum, Simetri gibi sözcükler).
- Kahraman/yol arkadaşı adına "-yla/-le" eki eklemek (derleyici çözemiyor).
- Metin okunmadan kazanım eşlemek (toplu A).
- Kaynakta olmayan kazanım kodu yazmak.

# PROJE OKULLARI 5. SINIFA GEÇİŞ KABUL SINAVLARI SORU HAVUZU

Bu dizin, 4. sınıftan 5. sınıfa geçiş sınavları için hazırlanmış soru havuzudur. **Kaynağı, sınav yılı ve okul adı doğrulanmamış maddeler çıkmış soru olarak işaretlenemez.** Bu nedenle her madde, doğrulama tamamlanana kadar `taslak` statüsünde tutulur. Telifli sınav kitapçıklarının tamamı kopyalanmaz; yalnızca izin verilen veya resmî olarak yayımlanan içerikler kaynak gösterilerek işlenir.

## Soru Standart Formatı (.md)

Her soru için 3 rollü pedagojik boru hattı uygulanır. Alt ajan desteği bu depoda bulunmadığı için bu roller ayrı doğrulama adımları olarak yürütülür:

1. **Araştırmacı / Soru Tasarımcısı:** Soru metni, MEB kazanımı, 4 seçenek (A, B, C, D) ve doğru cevap.
2. **Denetçi / Doğrulayıcı:** Matematiksel ve mantıksal doğruluk kontrolü, çeldirici analizi, tek bir doğru şıkkın teyidi.
3. **Pedagojik İpucu ve Öğretici İzah:**
   - **İpucu (1. Yanlış Cevapta):** Çocuğa cevabı doğrudan söylemeden, düşünme yolunu açan hatırlatıcı ipucu (Scaffolding).
   - **Öğretici İzah / Çözüm Adımları (2. Yanlış Cevapta):** Konunun özünü kavratan, adım adım açık ve net çözüm.

## Veri Tabanı Eşleşmesi (Supabase `public.questions` Tablosu)

- `okul`: `'ortaokul'`
- `sinif`: 5 (Kabul / Hazırlık)
- `ders`: 'Matematik' | 'Türkçe' | 'Fen Bilimleri' | 'Sosyal Bilgiler' | 'Din Kültürü' | 'İngilizce'
- `onay_durumu`: Kaynak ve içerik denetimi tamamlanmadan `'beklemede'`; yalnızca doğrulanmış maddelerde `'onaylandi'`
- `zorluk`: 1 (Temel/Kolay), 2 (Kazanım/Orta), 3 (Proje Okulu Seçici/Zor)
- `siklar`: `{"A": "...", "B": "...", "C": "...", "D": "..."}`
- `cozum_adimlari`: `["İpucu: ...", "Adım 1: ...", "Adım 2: ...", "Sonuç: ..."]`
- `kaynak_url`, `kaynak_baslik`, `sinav_yili`, `okul_adi`, `kaynak_durumu`: Markdown kayıtlarında zorunlu provenance alanlarıdır. Mevcut veritabanı şemasına aktarım için ayrıca metadata migration'ı gerekir.

-- Düzeltme: 4. sınıf Türkçe, 2026-2027, 4. hafta (ÇOCUKLUĞUM BİTTİ Mİ?) satırlarında
-- 6. sınıf kodu (T.6.1.x) görünüyordu. 4. sınıf kodları T.4.x biçimindedir.
-- Eşleme metin karşılaştırmasıyla yapıldı; aynı metinler aynı yayında T.4.x kodlarıyla mevcut:
--   T.6.1.1 -> T.4.1.2   (gelişimi ve sonucu hakkında tahminde bulunur)
--   T.6.1.2 -> T.4.1.4   (bilmediği kelimelerin anlamını tahmin eder)
--   T.6.1.4 -> T.4.1.7   (sorulara cevap verir)
--   T.6.1.7 -> T.4.1.8   (farklı başlıklar önerir)
-- Kaynak PDF ile birebir doğrulanmadı; kayıt: PROJE_GUNLUGU.md (K-0141).
update public.mufredat_hafta
   set kazanim_kodu = case kazanim_kodu
         when 'T.6.1.1' then 'T.4.1.2'
         when 'T.6.1.2' then 'T.4.1.4'
         when 'T.6.1.4' then 'T.4.1.7'
         when 'T.6.1.7' then 'T.4.1.8'
       end
 where ders = 'Türkçe'
   and sinif = 4
   and kaynak_yili = '2026-2027'
   and kazanim_kodu in ('T.6.1.1', 'T.6.1.2', 'T.6.1.4', 'T.6.1.7');

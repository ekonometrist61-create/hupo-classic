-- =====================================================================
-- Örnek sorular (deneme amaçlı), adım adım çözümleriyle.
-- Tablo boş değilse hiçbir şey eklemez (tekrar çalıştırmak güvenlidir).
-- 20260920000400_solution_steps_and_timeout.sql'den SONRA çalıştırılmalı.
-- =====================================================================

set client_encoding = 'UTF8';

do $seed$
begin
  if exists (select 1 from public.questions limit 1) then
    raise notice 'questions tablosu dolu, örnek sorular eklenmedi.';
    return;
  end if;

  insert into public.questions
    (okul, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik, onay_durumu, cozum_adimlari)
  values
  -- Matematik
  ('ortaokul', 'Matematik', 'Kesirler', 'Toplama', 1,
   '1/2 + 1/4 işleminin sonucu kaçtır?',
   '{"A":"1/6","B":"2/6","C":"3/4","D":"1"}', 'C', 'onaylandi',
   '["Paydaları eşitle: 1/2 = 2/4.","Payları topla: 2/4 + 1/4 = 3/4.","Sonuç 3/4 olur, doğru şık C."]'),
  ('ortaokul', 'Matematik', 'Kesirler', 'Çıkarma', 2,
   '5/6 − 1/3 işleminin sonucu kaçtır?',
   '{"A":"1/2","B":"4/3","C":"2/3","D":"1/3"}', 'A', 'onaylandi',
   '["Paydaları eşitle: 1/3 = 2/6.","Payları çıkar: 5/6 − 2/6 = 3/6.","3/6 sadeleşince 1/2 olur, doğru şık A."]'),
  ('ortaokul', 'Matematik', 'Yüzdeler', null, 2,
   '200 sayısının %15''i kaçtır?',
   '{"A":"15","B":"20","C":"30","D":"35"}', 'C', 'onaylandi',
   '["%15, 15/100 demektir.","200 × 15/100 = 30.","Doğru şık C."]'),
  ('ortaokul', 'Matematik', 'Denklemler', 'Birinci derece', 3,
   '3x − 7 = 11 denkleminde x kaçtır?',
   '{"A":"4","B":"5","C":"6","D":"18"}', 'C', 'onaylandi',
   '["Her iki tarafa 7 ekle: 3x = 18.","Her iki tarafı 3''e böl: x = 6.","Doğru şık C."]'),

  -- Türkçe
  ('ortaokul', 'Türkçe', 'Sözcükte Anlam', 'Eş anlamlı sözcükler', 1,
   '"Güzel" sözcüğünün eş anlamlısı aşağıdakilerden hangisidir?',
   '{"A":"Çirkin","B":"Hoş","C":"Büyük","D":"Hızlı"}', 'B', 'onaylandi',
   '["Eş anlamlı sözcükler aynı anlama gelen sözcüklerdir.","''Güzel'' ile aynı anlama gelen sözcük ''hoş''tur.","''Çirkin'' zıt anlamlıdır. Doğru şık B."]'),
  ('ortaokul', 'Türkçe', 'Yazım Kuralları', 'Büyük harf', 1,
   'Aşağıdaki cümlelerin hangisinde büyük harf kullanımı yanlıştır?',
   '{"A":"Yarın Ankara''ya gideceğiz.","B":"Ali okula erken geldi.","C":"annem bana kitap aldı.","D":"Dicle Nehri çok uzundur."}', 'C', 'onaylandi',
   '["Cümleler büyük harfle başlar; özel adlar da büyük harfle yazılır.","C şıkkı ''annem'' ile başlıyor, oysa ''Annem'' olmalıydı.","Doğru şık C."]'),
  ('ortaokul', 'Türkçe', 'Cümlede Anlam', 'Neden-sonuç', 2,
   '"Yağmur yağdığı için maç ertelendi." cümlesinde sonuç hangisidir?',
   '{"A":"Yağmurun yağması","B":"Maçın ertelenmesi","C":"Havanın bozulması","D":"Seyircilerin gitmesi"}', 'B', 'onaylandi',
   '["Neden, bir olayın sebebidir: yağmurun yağması.","Sonuç, o sebebin doğurduğu olaydır: maçın ertelenmesi.","Doğru şık B."]'),
  ('ortaokul', 'Türkçe', 'Noktalama', 'Virgül', 3,
   'Aşağıdakilerin hangisinde virgül yanlış kullanılmıştır?',
   '{"A":"Elma, armut, muz aldım.","B":"Ali, gel buraya.","C":"Dün, akşam eve geldim.","D":"Kitabı, masanın üstüne bıraktım."}', 'C', 'onaylandi',
   '["Virgül; sıralı sözcükleri ve seslenmeleri ayırmak için kullanılır.","C şıkkında ''dün'' ile ''akşam'' arasında böyle bir gerek yoktur.","Doğru şık C."]'),

  -- Fen Bilimleri
  ('ortaokul', 'Fen Bilimleri', 'Güneş Sistemi', null, 1,
   'Güneş Sistemi''nde Güneş''e en yakın gezegen hangisidir?',
   '{"A":"Venüs","B":"Dünya","C":"Merkür","D":"Mars"}', 'C', 'onaylandi',
   '["Güneş''e yakınlık sırası: Merkür, Venüs, Dünya, Mars.","İlk sırada Merkür bulunur.","Doğru şık C."]'),
  ('ortaokul', 'Fen Bilimleri', 'Madde ve Değişim', 'Hal değişimi', 2,
   'Suyun gaz hâlinden sıvı hâle geçmesine ne denir?',
   '{"A":"Buharlaşma","B":"Erime","C":"Yoğuşma","D":"Donma"}', 'C', 'onaylandi',
   '["Sıvıdan gaza geçiş buharlaşma, gazdan sıvıya geçiş yoğuşmadır.","Soru gazdan sıvıya geçişi soruyor.","Doğru şık C."]'),
  ('ortaokul', 'Fen Bilimleri', 'Kuvvet ve Hareket', 'Sürat', 2,
   '120 km yolu 2 saatte giden aracın ortalama sürati kaç km/sa''tir?',
   '{"A":"40","B":"60","C":"80","D":"240"}', 'B', 'onaylandi',
   '["Sürat = yol ÷ zaman.","120 km ÷ 2 saat = 60 km/sa.","Doğru şık B."]'),
  ('ortaokul', 'Fen Bilimleri', 'Hücre', 'Organeller', 3,
   'Hücrede enerji üretiminden sorumlu organel hangisidir?',
   '{"A":"Ribozom","B":"Mitokondri","C":"Golgi cisimciği","D":"Koful"}', 'B', 'onaylandi',
   '["Besinlerden enerji üretimi mitokondride gerçekleşir.","Bu yüzden mitokondriye ''hücrenin enerji santrali'' denir.","Doğru şık B."]');
end
$seed$;

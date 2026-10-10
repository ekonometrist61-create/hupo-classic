-- Ustalar sınıfındaki "Fırtına Ustası" (ustalar_firtina) → "Yıldırım Akıncısı"
-- Fırtına sınıfındaki "Fırtına Ustası" (firtina_ustasi) değişmez.
-- Bozkır sınıfındaki reisi "Bozkır Reisi" olarak kalır (zaten doğru).

set client_encoding = 'UTF8';

update public.character_definitions
set ad = 'Yıldırım Akıncısı',
    aciklama = 'İki dünyanın gücünü taşıyorsun — yay ve yıldırım bir arada.'
where kod = 'ustalar_firtina';

-- =====================================================================
-- HİKÂYE FİŞLERİ TEST SENARYOLARI (PGlite harness: kos.mjs)
-- Kapsam: 20261057000000 migration'ı — yetki, kuru çalıştırma, gerçek yazma, idempotency,
--   batch atomikliği, bilinmeyen alan (metin/durum sızıntısı), sınıf-bant uyumu,
--   içerik koruması (brief_draft dışı), 120 fişlik gerçek katalog.
-- Sonuçlar pg_temp.sonuc tablosuna pg_temp.k ile yazılır (testler.sql ile aynı tablo).
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.fis_testleri(p_katalog jsonb)
returns void
language plpgsql as $fn$
declare
  v_adm  uuid := gen_random_uuid();
  v_veli uuid := gen_random_uuid();
  v_r    jsonb;
  v_say  integer;
  v_iyi  jsonb;
  v_kotu jsonb;
  v_hata text;
begin
  insert into auth.users (id, email) values (v_adm, 'fis-adm@example.test'), (v_veli, 'fis-veli@example.test');
  insert into public.profiles (id, role, full_name) values (v_adm, 'admin', 'Fis Yonetici'), (v_veli, 'veli', 'Fis Veli');

  v_iyi := '[
    {"fis_kodu":"HR-901","baslik":"Deneme Fişi Bir","sinif":2,"sinif_bandi":"2-4","tur":"Macera",
     "kurgu_cekirdegi":"Bir çocuk kaybolan küçük bir çanı bulmak için mahalleyi dolaşır.",
     "ikon_onerileri":["çan","kulak"],"telif_sinifi":"O","kaynak_sinifi":"HupoRead özgün"},
    {"fis_kodu":"HR-902","baslik":"Deneme Fişi İki","sinif":7,"sinif_bandi":"7-8","tur":"Bilim kurgu",
     "kurgu_cekirdegi":"Bir öğrenci kapalı bir laboratuvarın gizli haritasını çözer.",
     "telif_sinifi":"A","kaynak_sinifi":"Geleneksel anlatı çekirdeği","telif_notu":"hukuk onayı bekliyor"}
  ]'::jsonb;

  -- 1) Yetki: veli içe aktaramaz ve listeleyemez.
  begin
    perform pg_temp.c(v_veli, format('public.okuma_fis_ice_aktar(%L::jsonb, true)', v_iyi));
    perform pg_temp.k('veli fiş içe aktaramaz', false, 'hata yok');
  exception when others then
    perform pg_temp.k('veli fiş içe aktaramaz', sqlstate = '42501', sqlerrm);
  end;

  -- 2) Kuru çalıştırma: sayım döner, hiçbir şey yazılmaz.
  v_r := pg_temp.c(v_adm, format('public.okuma_fis_ice_aktar(%L::jsonb, true)', v_iyi));
  select count(*) into v_say from public.okuma_hikaye_fisleri;
  perform pg_temp.k('kuru çalıştırma: eklenecek sayımı döner, yazmaz',
    (v_r ->> 'ok')::boolean and (v_r ->> 'eklenen')::int = 2 and v_say = 0, v_r::text);

  -- 3) Gerçek yazma.
  v_r := pg_temp.c(v_adm, format('public.okuma_fis_ice_aktar(%L::jsonb, false)', v_iyi));
  select count(*) into v_say from public.okuma_hikaye_fisleri;
  perform pg_temp.k('gerçek yazma: 2 fiş eklenir, durum brief_draft',
    (v_r ->> 'eklenen')::int = 2 and v_say = 2
    and (select count(*) from public.okuma_hikaye_fisleri where durum = 'brief_draft') = 2, v_r::text);

  -- 4) İdempotency: aynı batch tekrar kayıt çoğaltmaz, güncelleyerek sayar.
  v_r := pg_temp.c(v_adm, format('public.okuma_fis_ice_aktar(%L::jsonb, false)', v_iyi));
  select count(*) into v_say from public.okuma_hikaye_fisleri;
  perform pg_temp.k('tekrar içe aktarma: kayıt çoğalmaz, guncellenen=2',
    (v_r ->> 'eklenen')::int = 0 and (v_r ->> 'guncellenen')::int = 2 and v_say = 2, v_r::text);

  -- 5) Bilinmeyen alan (durum/hikaye_slug gibi serbest veya yetkili alanlar) reddedilir, yazılmaz.
  v_kotu := '[{"fis_kodu":"HR-903","baslik":"Kötü Fiş","sinif":3,"sinif_bandi":"2-4","tur":"Mizah",
     "kurgu_cekirdegi":"Bu fişte yetkisiz bir durum alanı var.","telif_sinifi":"O","kaynak_sinifi":"HupoRead özgün",
     "durum":"yayinda"}]'::jsonb;
  v_r := pg_temp.c(v_adm, format('public.okuma_fis_ice_aktar(%L::jsonb, false)', v_kotu));
  select count(*) into v_say from public.okuma_hikaye_fisleri;
  perform pg_temp.k('bilinmeyen alan (durum) reddedilir ve yazılmaz',
    (v_r ->> 'ok')::boolean = false and v_say = 2
    and (v_r -> 'hatalar' -> 0 ->> 'hata') like 'bilinmeyen alan: durum%', v_r::text);

  -- 6) Sınıf-bant uyumsuzluğu reddedilir.
  v_kotu := '[{"fis_kodu":"HR-904","baslik":"Bant Hatası","sinif":5,"sinif_bandi":"2-4","tur":"Mizah",
     "kurgu_cekirdegi":"Sınıf beşte ama bant ikiye dört yazılmış bir fiş.","telif_sinifi":"O","kaynak_sinifi":"HupoRead özgün"}]'::jsonb;
  v_r := pg_temp.c(v_adm, format('public.okuma_fis_ice_aktar(%L::jsonb, false)', v_kotu));
  perform pg_temp.k('sinif_bandi sınıfla uyuşmazsa reddedilir',
    (v_r ->> 'ok')::boolean = false and (v_r -> 'hatalar' -> 0 ->> 'hata') = 'sinif_bandi sınıfla uyuşmuyor', v_r::text);

  -- 7) Atomiklik: batch'te bir hatalı fiş varsa geçerli olanlar da yazılmaz.
  v_kotu := '[{"fis_kodu":"HR-905","baslik":"Geçerli Ama Yalnız","sinif":4,"sinif_bandi":"2-4","tur":"Macera",
     "kurgu_cekirdegi":"Bu fiş tek başına geçerlidir ama batch içinde hatalı fiş var.","telif_sinifi":"O","kaynak_sinifi":"HupoRead özgün"},
    {"fis_kodu":"BOZUK","baslik":"Hatalı","sinif":4,"sinif_bandi":"2-4","tur":"Macera",
     "kurgu_cekirdegi":"Fiş kodu bozuk olduğu için bu fiş reddedilir.","telif_sinifi":"O","kaynak_sinifi":"HupoRead özgün"}]'::jsonb;
  v_r := pg_temp.c(v_adm, format('public.okuma_fis_ice_aktar(%L::jsonb, false)', v_kotu));
  select count(*) into v_say from public.okuma_hikaye_fisleri;
  perform pg_temp.k('batch atomik: hatalı fiş varsa hiçbiri yazılmaz',
    (v_r ->> 'ok')::boolean = false and v_say = 2 and (v_r -> 'hatalar' -> 0 ->> 'sira')::int = 2, v_r::text);

  -- 8) İçerik koruması: incelemeye alınmış fiş içe aktarmayla değişmez.
  update public.okuma_hikaye_fisleri set durum = 'metin_taslak' where fis_kodu = 'HR-901';
  v_iyi := '[{"fis_kodu":"HR-901","baslik":"Değiştirilmeye Çalışıldı","sinif":2,"sinif_bandi":"2-4","tur":"Macera",
     "kurgu_cekirdegi":"Bu değişiklik metin_taslak durumundaki fişe uygulanmamalı.","telif_sinifi":"O","kaynak_sinifi":"HupoRead özgün"}]'::jsonb;
  v_r := pg_temp.c(v_adm, format('public.okuma_fis_ice_aktar(%L::jsonb, false)', v_iyi));
  perform pg_temp.k('brief_draft dışı fiş içe aktarmayla değişmez',
    (v_r ->> 'atlanan')::int = 1 and (select baslik from public.okuma_hikaye_fisleri where fis_kodu = 'HR-901') = 'Deneme Fişi Bir', v_r::text);

  -- 9) Metin alanı yok: tablonun hiçbir sütunu tam metin taşımaz (sızıntı önlemi).
  perform pg_temp.k('tabloda metin sütunu yok',
    not exists (select 1 from information_schema.columns
                where table_schema = 'public' and table_name = 'okuma_hikaye_fisleri'
                  and column_name in ('metin', 'icerik', 'sayfalar', 'paket', 'hikaye_metni')),
    'sütunlar kontrol edildi');

  -- 10) Listeleme: yönetici görür, veli görmez.
  v_r := pg_temp.c(v_adm, 'public.okuma_fis_listele(null, null)');
  perform pg_temp.k('yönetici fiş listesini görür (2 kayıt)', jsonb_array_length(v_r) = 2, v_r::text);
  begin
    perform pg_temp.c(v_veli, 'public.okuma_fis_listele(null, null)');
    perform pg_temp.k('veli fiş listesini göremez', false, 'hata yok');
  exception when others then
    perform pg_temp.k('veli fiş listesini göremez', sqlstate = '42501', sqlerrm);
  end;

  -- 11) Gerçek 120 fişlik katalog: kuru doğrulama, sonra yazma, sonra idempotent tekrar.
  v_r := pg_temp.c(v_adm, format('public.okuma_fis_ice_aktar(%L::jsonb, true)', p_katalog));
  perform pg_temp.k('120 fiş kuru doğrulamadan geçer',
    (v_r ->> 'ok')::boolean and (v_r ->> 'eklenen')::int = 120, coalesce(v_r::text, ''));

  v_r := pg_temp.c(v_adm, format('public.okuma_fis_ice_aktar(%L::jsonb, false)', p_katalog));
  select count(*) into v_say from public.okuma_hikaye_fisleri where fis_kodu between 'HR-001' and 'HR-120';
  perform pg_temp.k('120 fiş yazılır, kimlikler HR-001…HR-120',
    (v_r ->> 'eklenen')::int = 120 and v_say = 120, v_r::text);

  v_r := pg_temp.c(v_adm, format('public.okuma_fis_ice_aktar(%L::jsonb, false)', p_katalog));
  select count(*) into v_say from public.okuma_hikaye_fisleri;
  perform pg_temp.k('120 fişin tekrar içe aktarılması kayıt çoğaltmaz',
    (v_r ->> 'eklenen')::int = 0 and (v_r ->> 'guncellenen')::int = 120 and v_say = 122, v_r::text);

  perform pg_temp.k('telif dağılımı katalogla eşleşir (O 93, A 18, K 9)',
    (select count(*) from public.okuma_hikaye_fisleri where fis_kodu between 'HR-001' and 'HR-120' and telif_sinifi = 'O') = 93
    and (select count(*) from public.okuma_hikaye_fisleri where fis_kodu between 'HR-001' and 'HR-120' and telif_sinifi = 'A') = 18
    and (select count(*) from public.okuma_hikaye_fisleri where fis_kodu between 'HR-001' and 'HR-120' and telif_sinifi = 'K') = 9,
    'O/A/K sayımı');

  perform pg_temp.k('tüm 120 fiş hak ve müfredat onaysız başlar',
    (select count(*) from public.okuma_hikaye_fisleri where fis_kodu between 'HR-001' and 'HR-120' and (hak_onayi or mufredat_onayi)) = 0,
    'onay bayrakları');
end
$fn$;


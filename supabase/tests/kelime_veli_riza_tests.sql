-- GÖR-046 davranış testi: kelime_veli_ozeti rıza kapısı (migration 20261045000000).
-- Önkoşul: kelime_veli_riza_stub.sql ve 20261013000000_veli_riza_kapisi.sql önce uygulanmış olmalı.
-- pglite-kos.mjs bu fonksiyonu çağırır; her kontrol başarısızsa exception fırlatır.
create or replace function pg_temp.kelime_evreni_testleri()
returns table(no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $$
declare
  v_veli  uuid := '11111111-1111-1111-1111-111111111111';
  v_baska uuid := '22222222-2222-2222-2222-222222222222';
  v_cocuk uuid := '33333333-3333-3333-3333-333333333333';
  v_sonuc jsonb;
begin
  insert into auth.users (id, email) values (v_veli, 'veli@test'), (v_baska, 'baska@test'), (v_cocuk, 'cocuk@test');
  insert into public.profiles (id, role, full_name) values (v_veli, 'veli', 'Veli Test'), (v_baska, 'veli', 'Baska Test');
  insert into public.profiles (id, role, parent_id, full_name, sinif) values (v_cocuk, 'ogrenci', v_veli, 'Cocuk Test', 4);

  -- 1) Rıza kaydı yok: özet hesaplanmaz, alanlar null
  perform set_config('request.jwt.claims', json_build_object('sub', v_veli)::text, true);
  v_sonuc := public.kelime_veli_ozeti(v_cocuk);
  if v_sonuc->>'riza' <> 'yok' or v_sonuc->'deneme_sayisi' <> 'null'::jsonb then
    raise exception 'TEST1 başarısız: %', v_sonuc;
  end if;

  -- 2) Açık rıza verildi: özet döner (deneme yok, sayı 0)
  insert into public.consents (cocuk_id, tur, created_at) values (v_cocuk, 'veli_acik_riza', '2026-10-01 10:00+00');
  v_sonuc := public.kelime_veli_ozeti(v_cocuk);
  if v_sonuc->>'riza' <> 'verildi' or v_sonuc->'deneme_sayisi' <> '0'::jsonb then
    raise exception 'TEST2 başarısız: %', v_sonuc;
  end if;

  -- 3) Rıza geri çekildi (daha yeni kayıt): özet kapanır
  insert into public.consents (cocuk_id, tur, created_at) values (v_cocuk, 'veli_riza_geri_cekildi', '2026-10-02 10:00+00');
  v_sonuc := public.kelime_veli_ozeti(v_cocuk);
  if v_sonuc->>'riza' <> 'geri_cekildi' or v_sonuc->'zorlanilan' <> '[]'::jsonb then
    raise exception 'TEST3 başarısız: %', v_sonuc;
  end if;

  -- 4) Bağlı olmayan veli erişemez (42501)
  perform set_config('request.jwt.claims', json_build_object('sub', v_baska)::text, true);
  begin
    perform public.kelime_veli_ozeti(v_cocuk);
    raise exception 'TEST4 başarısız: bağlı olmayan veli erişti';
  exception when sqlstate '42501' then
    null;
  end;

  return query select 1, 'GÖR-046 rıza kapısı: rıza yok / verildi / geri çekildi / yetkisiz veli'::text, true, null::text;
end;
$$;

-- =====================================================================
-- DUYURU VE ANKET ARŞİV TESTLERİ
-- Kapsam: 20261032000000_duyuru_anket_arsiv_ve_sil.sql
--   * Yetkiler: anon çağıramaz; veli çağıramaz; tek imza (aşırı yükleme yok)
--   * Duyuru: taslak silinir, yayınlanmış silinemez, arşiv gizler, arşivden çıkarma
--             pasif bırakır, arşivli duyuru yayına alınamaz, get_aktif_duyuru gizler
--   * Anket: taslak arşivlenir, yayındaki arşivlenemez, kapalı arşivlenir, silme yok
--
-- Çalıştırma: arsiv/run.mjs (PGlite). Test verisi kalıcı değildir.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.arsiv_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm uuid := gen_random_uuid();   -- yönetici
  vel uuid := gen_random_uuid();   -- veli (yönetici değil)
  d1  uuid;                        -- yayınlanıp arşivlenen duyuru
  d2  uuid;                        -- taslak duyuru
  a1  uuid;                        -- taslak anket
  a2  uuid;                        -- kapatılıp arşivlenen anket
  n   integer;
  b   boolean;
  t   text;
  j   jsonb;
  sorular jsonb := '[{"id":"q1","tur":"nps","baslik":"Tavsiye"}]'::jsonb;
begin
  no := 0;

  insert into auth.users (id, email) values (adm, 'arsiv.adm@example.test'), (vel, 'arsiv.veli@example.test');
  insert into public.profiles (id, role, full_name) values (adm, 'admin', 'Yönetici'), (vel, 'veli', 'Veli');

  -- ------------------------------------------------------------------
  no := no + 1; senaryo := 'Tek imza: admin_list_duyurular ve admin_anket_listele birer kez tanımlı';
  select count(*) into n from pg_proc where proname in ('admin_list_duyurular', 'admin_anket_listele');
  gecti := n = 2; detay := 'tanım sayısı=' || n; return next;

  no := no + 1; senaryo := 'anon arşiv ve silme RPC''lerini çağıramaz';
  b := not has_function_privilege('anon', 'public.admin_duyuru_sil(uuid)', 'EXECUTE')
       and not has_function_privilege('anon', 'public.admin_duyuru_arsivle(uuid,boolean)', 'EXECUTE')
       and not has_function_privilege('anon', 'public.admin_list_duyurular(boolean)', 'EXECUTE')
       and not has_function_privilege('anon', 'public.admin_anket_listele(boolean)', 'EXECUTE')
       and not has_function_privilege('anon', 'public.admin_anket_arsivle(uuid,boolean)', 'EXECUTE');
  gecti := b; detay := 'anon yetkisi kapalı=' || b; return next;

  no := no + 1; senaryo := 'veli (yönetici değil) duyuru silemez: 42501';
  perform set_config('request.jwt.claims', json_build_object('sub', vel, 'role', 'authenticated')::text, false);
  perform set_config('role', 'authenticated', false);
  begin
    perform public.admin_duyuru_sil(gen_random_uuid());
    t := 'ok';
  exception when others then
    t := sqlstate;
  end;
  perform set_config('role', 'none', false);
  perform set_config('request.jwt.claims', '', false);
  gecti := t = '42501'; detay := 'sqlstate=' || t; return next;

  -- Yönetici oturumu: yalnızca JWT claim'i (is_admin/auth.uid() buradan okur).
  -- Rol süperkullanıcı kalır ki doğrudan tablo okumaları (yetki dışı) test kodunu bozmasın.
  perform set_config('request.jwt.claims', json_build_object('sub', adm, 'role', 'authenticated')::text, false);

  -- ------------------------------------------------------------------
  no := no + 1; senaryo := 'taslak duyuru (aktif=false) yayinlandi_at boş kalır';
  d2 := public.admin_save_duyuru(null, 'Taslak', 'Taslak metin', false, null, array['web_sitesi']);
  select yayinlandi_at is null into b from public.duyurular where id = d2;
  gecti := b; detay := 'yayinlandi_at boş=' || coalesce(b::text, 'satır yok'); return next;

  no := no + 1; senaryo := 'yanıtsız taslak duyuru silinir';
  perform public.admin_duyuru_sil(d2);
  select count(*) into n from public.duyurular where id = d2;
  gecti := n = 0; detay := 'kalan satır=' || n; return next;

  -- ------------------------------------------------------------------
  no := no + 1; senaryo := 'yayınlanan duyuruda yayinlandi_at dolar';
  d1 := public.admin_save_duyuru(null, 'Yayın', 'Yayınlanan metin', true, null, array['web_sitesi', 'veli_paneli']);
  select yayinlandi_at is not null into b from public.duyurular where id = d1;
  gecti := b; detay := 'yayinlandi_at dolu=' || coalesce(b::text, 'satır yok'); return next;

  no := no + 1; senaryo := 'yayınlanmış duyuru silinemez: 23514';
  begin
    perform public.admin_duyuru_sil(d1);
    t := 'ok';
  exception when others then
    t := sqlstate;
  end;
  gecti := t = '23514'; detay := 'sqlstate=' || t; return next;

  no := no + 1; senaryo := 'pasife alınan ama yayınlanmış duyuru da silinemez';
  perform public.admin_save_duyuru(d1, 'Yayın', 'Yayınlanan metin', false, null, array['web_sitesi', 'veli_paneli']);
  begin
    perform public.admin_duyuru_sil(d1);
    t := 'ok';
  exception when others then
    t := sqlstate;
  end;
  gecti := t = '23514'; detay := 'sqlstate=' || t; return next;

  -- ------------------------------------------------------------------
  no := no + 1; senaryo := 'arşivleme duyuruyu pasife alır ve arsivlendi_at doldurur';
  perform public.admin_duyuru_arsivle(d1, true);
  select arsivlendi_at is not null and aktif = false into b from public.duyurular where id = d1;
  gecti := b; detay := 'arşivli ve pasif=' || coalesce(b::text, 'satır yok'); return next;

  no := no + 1; senaryo := 'arşivli duyuru aktif listede yok, arşiv listesinde var';
  select (select count(*) from jsonb_array_elements(public.admin_list_duyurular(false)) e
           where (e ->> 'id')::uuid = d1),
         (select count(*) from jsonb_array_elements(public.admin_list_duyurular(true)) e
           where (e ->> 'id')::uuid = d1)
    into n, b;
  gecti := n = 0 and exists (select 1 from jsonb_array_elements(public.admin_list_duyurular(true)) e
                              where (e ->> 'id')::uuid = d1);
  detay := 'aktif listede=' || n; return next;

  no := no + 1; senaryo := 'arşivli duyuru ziyaretçiye gösterilmez (get_aktif_duyuru null)';
  j := public.get_aktif_duyuru('web_sitesi');
  gecti := j is null; detay := 'dönen=' || coalesce(j::text, 'null'); return next;

  no := no + 1; senaryo := 'arşivli duyuru aktif=true ile kaydedilemez: 23514';
  begin
    perform public.admin_save_duyuru(d1, 'Yayın', 'Yayınlanan metin', true, null, array['web_sitesi']);
    t := 'ok';
  exception when others then
    t := sqlstate;
  end;
  gecti := t = '23514'; detay := 'sqlstate=' || t; return next;

  no := no + 1; senaryo := 'arşivden çıkarma duyuruyu pasif bırakır (kendiliğinden yayınlanmaz)';
  perform public.admin_duyuru_arsivle(d1, false);
  select arsivlendi_at is null and aktif = false into b from public.duyurular where id = d1;
  gecti := b; detay := 'arşivden çıkmış ve pasif=' || coalesce(b::text, 'satır yok'); return next;

  no := no + 1; senaryo := 'arşivden çıkarılan duyuru tekrar yayına alınabilir';
  perform public.admin_save_duyuru(d1, 'Yayın', 'Yayınlanan metin', true, null, array['web_sitesi']);
  select aktif into b from public.duyurular where id = d1;
  gecti := b = true; detay := 'aktif=' || coalesce(b::text, 'satır yok'); return next;

  -- ------------------------------------------------------------------
  no := no + 1; senaryo := 'taslak anket oluşturulur ve arşivlenir';
  a1 := public.admin_anket_kaydet(null, 'Taslak Anket', false, sorular, 30, array['veli_paneli']);
  perform public.admin_anket_arsivle(a1, true);
  select (select count(*) from jsonb_array_elements(public.admin_anket_listele(true)) e
           where (e ->> 'id')::uuid = a1) = 1
     and (select count(*) from jsonb_array_elements(public.admin_anket_listele(false)) e
           where (e ->> 'id')::uuid = a1) = 0
    into b;
  gecti := b; detay := 'arşiv listesinde ve aktif listede değil=' || coalesce(b::text, 'null'); return next;

  no := no + 1; senaryo := 'yayındaki anket arşivlenemez: 23514';
  perform public.admin_anket_arsivle(a1, false);
  a2 := public.admin_anket_kaydet(null, 'Yayın Anketi', false, sorular, 30, array['veli_paneli']);
  perform public.admin_anket_durum(a2, 'yayinda');
  begin
    perform public.admin_anket_arsivle(a2, true);
    t := 'ok';
  exception when others then
    t := sqlstate;
  end;
  gecti := t = '23514'; detay := 'sqlstate=' || t; return next;

  no := no + 1; senaryo := 'kapatılan anket arşivlenir, arşivden çıkınca aktif listeye döner';
  perform public.admin_anket_durum(a2, 'kapali');
  perform public.admin_anket_arsivle(a2, true);
  select arsivlendi_at is not null into b from public.anketler where id = a2;
  perform public.admin_anket_arsivle(a2, false);
  select b and (select count(*) from jsonb_array_elements(public.admin_anket_listele(false)) e
                 where (e ->> 'id')::uuid = a2) = 1
    into b;
  gecti := b; detay := 'arşiv→geri dönüş=' || coalesce(b::text, 'null'); return next;

  no := no + 1; senaryo := 'anket silme RPC''si yoktur (yanıtlar korunur)';
  select count(*) into n from pg_proc where proname like 'admin_anket_sil%';
  gecti := n = 0; detay := 'admin_anket_sil* sayısı=' || n; return next;

  -- Oturumu sıfırla
  perform set_config('role', 'none', false);
  perform set_config('request.jwt.claims', '', false);
end;
$fn$;

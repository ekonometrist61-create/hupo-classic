-- =====================================================================
--  Admin tam yetki: öğrenci uygulamasında kısıtsız gezinme
--  Tarih : 2026-10-25
--
--  SORUN: Öğrenci RPC'leri "current_user_role() is distinct from 'ogrenci'"
--  ile admin'i reddediyor; set_my_grade() ayrıca 30 gün / 24 saat bekleme
--  kuralı uyguluyor, _sinif_yaz() desteklenen sınıf listesiyle sınırlıyor.
--
--  ÇÖZÜM (tek yerden, davranışı admin dışında DEĞİŞTİRMEZ):
--    1) public içindeki fonksiyon gövdelerinde
--         current_user_role() is distinct from 'ogrenci'  ->  (... and not public.is_admin())
--         current_user_role() = 'ogrenci'                 ->  (... or public.is_admin())
--    2) set_my_grade(): admin için bekleme pencereleri uygulanmaz.
--    3) _sinif_yaz(): admin desteklenen_siniflar listesiyle sınırlanmaz (1-12).
--  Fonksiyon tanımları pg_get_functiondef ile okunup yeniden oluşturulur;
--  yetkiler (GRANT/REVOKE) CREATE OR REPLACE ile korunur.
-- =====================================================================

do $$
declare
  f        record;
  v_def    text;
  v_yeni   text;
  v_adet   integer := 0;
begin
  for f in
    select p.oid
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
       and p.prokind = 'f'
       and (p.prosrc like '%current_user_role() is distinct from ''ogrenci''%'
         or p.prosrc like '%current_user_role() = ''ogrenci''%')
  loop
    v_def := pg_get_functiondef(f.oid);
    v_yeni := replace(v_def,
      'public.current_user_role() is distinct from ''ogrenci''',
      '(public.current_user_role() is distinct from ''ogrenci'' and not public.is_admin())');
    v_yeni := replace(v_yeni,
      'public.current_user_role() = ''ogrenci''',
      '(public.current_user_role() = ''ogrenci'' or public.is_admin())');
    if v_yeni is distinct from v_def then
      execute v_yeni;
      v_adet := v_adet + 1;
    end if;
  end loop;
  raise notice 'admin ogrenci-kapisi gevsetilen fonksiyon sayisi: %', v_adet;
end
$$;

-- set_my_grade: admin için 30 gün / 24 saat penceresi yok
do $$
declare
  v_oid oid := 'public.set_my_grade(integer)'::regprocedure;
  v_def text := pg_get_functiondef(v_oid);
  v_yeni text;
begin
  v_yeni := replace(v_def, 'if v_sinif is not null then',
                           'if v_sinif is not null and not public.is_admin() then');
  if v_yeni is not distinct from v_def then
    raise exception 'set_my_grade gövdesinde beklenen kalıp bulunamadı';
  end if;
  execute v_yeni;
end
$$;

-- _sinif_yaz: admin her sınıfa (1-12) geçebilir
do $$
declare
  v_oid oid := 'public._sinif_yaz(uuid,integer,text)'::regprocedure;
  v_def text := pg_get_functiondef(v_oid);
  v_yeni text;
begin
  v_yeni := replace(v_def,
    'if p_sinif is null or not (p_sinif = any (public._desteklenen_siniflar())) then',
    'if p_sinif is null or not (p_sinif between 1 and 12) '
    || 'or (not (p_sinif = any (public._desteklenen_siniflar())) and not public.is_admin()) then');
  if v_yeni is not distinct from v_def then
    raise exception '_sinif_yaz gövdesinde beklenen kalıp bulunamadı';
  end if;
  execute v_yeni;
end
$$;

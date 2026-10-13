-- =====================================================================
-- ÇARPIM ŞİFRELERİ / SORU BİLDİRME / SINIF RPC'LERİ: CANLI DÖKÜMÜ (TASKS.md §11.7)
--
-- Bu RPC'ler canlı veritabanında zaten vardı; repo migration zincirinde yoktu
-- (commit 7543fd5: "SQL Editor'den zaten uygulanmış" gerekçesiyle kaldırılmıştı).
-- Gövdeler canlı pg_get_functiondef çıktısından birebir alındı (2026-10-10).
-- Yetkiler canlı proacl ile eşleşir: PUBLIC ve anon YOK; authenticated + service_role.
-- Uygulandığında canlıda davranış değişmez (create or replace, aynı gövde).
-- =====================================================================

CREATE OR REPLACE FUNCTION public.complete_cipher_stage(p_sifre_id uuid, p_asama text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid          uuid := (select auth.uid());
  v_s            public.carpim_sifreleri%rowtype;
  v_before       text[];
  v_after        text[];
  v_yeni         text[];
  v_yildiz       int;
  v_test_sayisi  int;
  v_dolu         boolean;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler bu işlemi yapabilir' using errcode = '42501';
  end if;

  if p_asama not in ('acik', 'kapali') then
    raise exception 'Geçersiz aşama: %', p_asama using errcode = '22023';
  end if;

  select * into v_s from public.carpim_sifreleri where id = p_sifre_id;
  if not found then
    raise exception 'Şifre bulunamadı' using errcode = 'P0002';
  end if;

  select coalesce(array_agg(badge_code), array[]::text[]) into v_before
    from public.user_badges where student_id = v_uid;

  insert into public.carpim_ilerleme (user_id, sifre_id, acik_bitti, kapali_bitti)
  values (v_uid, p_sifre_id, p_asama = 'acik', p_asama = 'kapali')
  on conflict (user_id, sifre_id) do update
    set acik_bitti   = public.carpim_ilerleme.acik_bitti   or excluded.acik_bitti,
        kapali_bitti = public.carpim_ilerleme.kapali_bitti or excluded.kapali_bitti,
        updated_at   = now();

  if p_asama = 'kapali' then
    select kapali_yildiz into v_yildiz
      from public.carpim_ilerleme where user_id = v_uid and sifre_id = p_sifre_id;
    v_test_sayisi := jsonb_array_length(v_s.test);
    v_dolu := (coalesce(v_yildiz, 0) = v_test_sayisi and v_test_sayisi > 0);

    update public.carpim_ilerleme
       set kapali_ilk_denemede_doldu = v_dolu
     where user_id = v_uid and sifre_id = p_sifre_id;

    perform public.evaluate_badges(v_uid);
  end if;

  select coalesce(array_agg(badge_code), array[]::text[]) into v_after
    from public.user_badges where student_id = v_uid;

  select coalesce(array_agg(x), array[]::text[]) into v_yeni
    from unnest(v_after) x
   where x <> all (v_before);

  return jsonb_build_object('yeni_rozetler', to_jsonb(v_yeni));
end;
$function$;

CREATE OR REPLACE FUNCTION public.get_carpim_sifre_detay(p_sifre_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid  uuid := (select auth.uid());
  v_s    public.carpim_sifreleri%rowtype;
  v_p    public.carpim_ilerleme%rowtype;
  v_test jsonb;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler erişebilir' using errcode = '42501';
  end if;

  select * into v_s from public.carpim_sifreleri where id = p_sifre_id;
  if not found then
    raise exception 'Şifre bulunamadı' using errcode = 'P0002';
  end if;

  select * into v_p from public.carpim_ilerleme where user_id = v_uid and sifre_id = p_sifre_id;

  select coalesce(jsonb_agg(jsonb_build_object('soru', item ->> 'soru') order by ord), '[]'::jsonb)
    into v_test
    from jsonb_array_elements(v_s.test) with ordinality as t(item, ord);

  return jsonb_build_object(
    'id',        v_s.id,
    'sira',      v_s.sira,
    'anahtar',   v_s.anahtar,
    'isim',      v_s.isim,
    'ikon',      v_s.ikon,
    'renk',      v_s.renk,
    'kapsam',    v_s.kapsam,
    'kesif',     v_s.kesif,
    'tanim',     v_s.tanim,
    'formul',    v_s.formul,
    'ornek',     v_s.ornek,
    'alistirma', v_s.alistirma,
    'test',      v_test,
    'progress',  jsonb_build_object(
                   'acik_bitti',    coalesce(v_p.acik_bitti, false),
                   'kapali_bitti',  coalesce(v_p.kapali_bitti, false),
                   'kapali_yildiz', coalesce(v_p.kapali_yildiz, 0),
                   'ogretti',       coalesce(v_p.ogretti, false)
                 )
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.get_carpim_sifreleri()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler erişebilir' using errcode = '42501';
  end if;

  return coalesce((
    select jsonb_agg(
             jsonb_build_object(
               'id',               s.id,
               'sira',             s.sira,
               'anahtar',          s.anahtar,
               'isim',             s.isim,
               'ikon',             s.ikon,
               'renk',             s.renk,
               'kapsam',           s.kapsam,
               'kesif',            s.kesif,
               'tanim',            s.tanim,
               'formul',           s.formul,
               'ornek',            s.ornek,
               'alistirma_sayisi', jsonb_array_length(s.alistirma),
               'test_sayisi',      jsonb_array_length(s.test),
               'durum', case
                          when p.sifre_id is null    then 'acildi'
                          when p.kapali_bitti        then 'tamamlandi'
                          when p.acik_bitti          then 'alistirma_tamam'
                          else 'acildi'
                        end,
               'yildiz',  coalesce(p.kapali_yildiz, 0),
               'ogretti', coalesce(p.ogretti, false)
             )
             order by s.sira)
      from public.carpim_sifreleri s
      left join public.carpim_ilerleme p
             on p.sifre_id = s.id and p.user_id = v_uid
  ), '[]'::jsonb);
end;
$function$;

CREATE OR REPLACE FUNCTION public.get_supported_grades()
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select jsonb_build_object('siniflar', to_jsonb(public._desteklenen_siniflar()));
$function$;

CREATE OR REPLACE FUNCTION public.report_question(p_question_id uuid, p_neden text, p_not text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid  uuid := (select auth.uid());
  v_rol  text;
  v_not  text;
  v_id   uuid;
begin
  if v_uid is null then
    raise exception 'giris_gerekli' using errcode = '42501';
  end if;
  v_rol := public.current_user_role();
  if v_rol is null or v_rol not in ('ogrenci', 'veli') then
    raise exception 'yetkisiz_rol' using errcode = '42501';
  end if;
  if p_neden is null or p_neden not in ('yanlis_cevap', 'anlasilmiyor', 'yazim', 'diger') then
    raise exception 'gecersiz_neden' using errcode = '22023';
  end if;
  if not exists (select 1 from public.questions where id = p_question_id and onay_durumu = 'onaylandi') then
    raise exception 'soru_bulunamadi' using errcode = 'P0002';
  end if;

  -- Not: baştaki/sondaki boşluk ve kontrol karakterleri temizlenir, 200 karaktere kısaltılır
  v_not := nullif(left(trim(regexp_replace(coalesce(p_not, ''), '[[:cntrl:]]+', ' ', 'g')), 200), '');

  if exists (select 1 from public.question_reports
              where question_id = p_question_id and reporter_id = v_uid
                and durum in ('acik', 'inceleniyor')) then
    raise exception 'rapor_zaten_var' using errcode = '23505';
  end if;

  if (select count(*) from public.question_reports
       where reporter_id = v_uid and created_at > now() - interval '1 day') >= 20 then
    raise exception 'rapor_limiti_asildi' using errcode = '54000';
  end if;

  begin
    insert into public.question_reports (question_id, reporter_id, neden, not_metni)
    values (p_question_id, v_uid, p_neden, v_not)
    returning id into v_id;
  exception when unique_violation then
    raise exception 'rapor_zaten_var' using errcode = '23505';
  end;

  perform public._refresh_question_flag(p_question_id);
  return jsonb_build_object('id', v_id);
end;
$function$;

CREATE OR REPLACE FUNCTION public.report_taught_friend(p_sifre_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid    uuid := (select auth.uid());
  v_before text[];
  v_after  text[];
  v_yeni   text[];
  v_had    boolean;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler bu işlemi yapabilir' using errcode = '42501';
  end if;

  if not exists (select 1 from public.carpim_sifreleri where id = p_sifre_id) then
    raise exception 'Şifre bulunamadı' using errcode = 'P0002';
  end if;

  select exists(
    select 1 from public.carpim_ilerleme where user_id = v_uid and ogretti
  ) into v_had;

  select coalesce(array_agg(badge_code), array[]::text[]) into v_before
    from public.user_badges where student_id = v_uid;

  insert into public.carpim_ilerleme (user_id, sifre_id, ogretti)
  values (v_uid, p_sifre_id, true)
  on conflict (user_id, sifre_id) do update
    set ogretti = true, updated_at = now();

  if not v_had then
    perform public.evaluate_badges(v_uid);
  end if;

  select coalesce(array_agg(badge_code), array[]::text[]) into v_after
    from public.user_badges where student_id = v_uid;

  select coalesce(array_agg(x), array[]::text[]) into v_yeni
    from unnest(v_after) x
   where x <> all (v_before);

  return jsonb_build_object('yeni_rozetler', to_jsonb(v_yeni));
end;
$function$;

CREATE OR REPLACE FUNCTION public.set_my_grade(p_sinif integer)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_sinif          smallint;
  v_pencere_basi   timestamptz;
  v_son_degisiklik timestamptz;
begin
  if (select auth.uid()) is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Bu işlem yalnızca öğrenciler içindir' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = (select auth.uid());

  -- profiles.sinif NULL ise bu ilk seçimdir: her zaman serbest (aynı zamanda
  -- pencereyi başlatan kayıt olur).
  if v_sinif is not null then
    select min(created_at) into v_pencere_basi
      from public.grade_changes
     where user_id = (select auth.uid());

    if v_pencere_basi is not null and now() > v_pencere_basi + interval '30 days' then
      raise exception 'Sınıf değiştirme süren doldu. Sınıfını değiştirmek için velinden yardım almalısın.'
        using errcode = '22023';
    end if;

    select created_at into v_son_degisiklik
      from public.grade_changes
     where user_id = (select auth.uid())
       and kaynak = 'ogrenci'
       and eski_sinif is not null
     order by created_at desc
     limit 1;

    if v_son_degisiklik is not null and v_son_degisiklik > now() - interval '24 hours' then
      raise exception 'Sınıfını son 24 saat içinde değiştirdin. Biraz sonra tekrar deneyebilirsin.'
        using errcode = '22023';
    end if;
  end if;

  return public._sinif_yaz((select auth.uid()), p_sinif, 'ogrenci');
end;
$function$;

CREATE OR REPLACE FUNCTION public.submit_cipher_answer(p_sifre_id uuid, p_asama text, p_soru_index integer, p_cevap integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid        uuid := (select auth.uid());
  v_s          public.carpim_sifreleri%rowtype;
  v_items      jsonb;
  v_item       jsonb;
  v_count      int;
  v_dogru      boolean;
  v_cozum      jsonb;
  v_ilk        boolean;
  v_yildiz     boolean := false;
  v_hatirlatma jsonb := null;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'Yalnızca öğrenciler cevap gönderebilir' using errcode = '42501';
  end if;

  if p_asama not in ('acik', 'kapali') then
    raise exception 'Geçersiz aşama: %', p_asama using errcode = '22023';
  end if;

  select * into v_s from public.carpim_sifreleri where id = p_sifre_id;
  if not found then
    raise exception 'Şifre bulunamadı' using errcode = 'P0002';
  end if;

  v_items := case p_asama when 'acik' then v_s.alistirma else v_s.test end;
  v_count := jsonb_array_length(v_items);
  if p_soru_index is null or p_soru_index < 0 or p_soru_index >= v_count then
    raise exception 'Geçersiz soru indeksi: %', p_soru_index using errcode = '22023';
  end if;

  v_item  := v_items -> p_soru_index;
  v_dogru := (p_cevap = (v_item ->> 'cevap')::int);
  v_cozum := coalesce(v_item -> 'cozum', '[]'::jsonb);

  -- Aynı (kullanıcı, şifre, aşama, soru) için yalnızca İLK sonuç kaydedilir (idempotent).
  insert into public.carpim_deneme_log (user_id, sifre_id, asama, soru_index, ilk_sonuc)
  values (v_uid, p_sifre_id, p_asama, p_soru_index, v_dogru)
  on conflict (user_id, sifre_id, asama, soru_index) do nothing;

  v_ilk := found;

  if p_asama = 'kapali' then
    if v_dogru then
      if v_ilk then
        v_yildiz := true;
        insert into public.carpim_ilerleme (user_id, sifre_id, kapali_yildiz)
        values (v_uid, p_sifre_id, 1)
        on conflict (user_id, sifre_id) do update
          set kapali_yildiz = public.carpim_ilerleme.kapali_yildiz + 1,
              updated_at    = now();
      end if;
    else
      v_hatirlatma := jsonb_build_object('isim', v_s.isim, 'tanim', v_s.tanim);
    end if;
  end if;

  return jsonb_build_object(
    'dogru',            v_dogru,
    'cozum',             v_cozum,
    'sifre_hatirlatma',  v_hatirlatma,
    'ilk_deneme',        v_ilk,
    'yildiz_kazanildi',  v_yildiz
  );
end;
$function$;

-- Yetkiler (canlı proacl ile birebir)
revoke execute on function public.complete_cipher_stage(p_sifre_id uuid, p_asama text) from public, anon;
grant  execute on function public.complete_cipher_stage(p_sifre_id uuid, p_asama text) to authenticated, service_role;
revoke execute on function public.get_carpim_sifre_detay(p_sifre_id uuid) from public, anon;
grant  execute on function public.get_carpim_sifre_detay(p_sifre_id uuid) to authenticated, service_role;
revoke execute on function public.get_carpim_sifreleri() from public, anon;
grant  execute on function public.get_carpim_sifreleri() to authenticated, service_role;
revoke execute on function public.get_supported_grades() from public, anon;
grant  execute on function public.get_supported_grades() to authenticated, service_role;
revoke execute on function public.report_question(p_question_id uuid, p_neden text, p_not text) from public, anon;
grant  execute on function public.report_question(p_question_id uuid, p_neden text, p_not text) to authenticated, service_role;
revoke execute on function public.report_taught_friend(p_sifre_id uuid) from public, anon;
grant  execute on function public.report_taught_friend(p_sifre_id uuid) to authenticated, service_role;
revoke execute on function public.set_my_grade(p_sinif integer) from public, anon;
grant  execute on function public.set_my_grade(p_sinif integer) to authenticated, service_role;
revoke execute on function public.submit_cipher_answer(p_sifre_id uuid, p_asama text, p_soru_index integer, p_cevap integer) from public, anon;
grant  execute on function public.submit_cipher_answer(p_sifre_id uuid, p_asama text, p_soru_index integer, p_cevap integer) to authenticated, service_role;

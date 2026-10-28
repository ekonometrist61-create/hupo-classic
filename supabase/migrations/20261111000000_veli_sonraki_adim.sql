-- =====================================================================
--  VELİ SONRAKİ ADIM (W10)
--  Veli ana sayfasındaki "Sonraki adım" kartının sunucu okuması.
--
--  Adımlar (sabit sıra):
--    cocuk_ekle        → veli bir eşleştirme kodu üretmiş ya da en az bir çocuğu bağlı
--    eslestir          → en az bir çocuk veli hesabına bağlı
--    ilk_ders          → bağlı çocuklardan en az birinin bir cevap kaydı var
--    deneme_veya_plan  → aktif (süresi dolmamış) abonelik ya da başlatılmış deneme
--
--  Dönüş: { "adimlar": [{kod, durum}, ...], "siradaki": kod | null }
--    durum: tamam | siradaki | bekliyor   (tüm adımlar tamamsa siradaki = null)
--
--  Güvenlik: parametre almaz; yalnızca auth.uid() velisinin verisini okur.
--  Başka velinin hanesi ya da çocuğu sonuca girmez. Yalnızca 'veli' rolü çağırabilir.
-- =====================================================================

create or replace function public.veli_sonraki_adim()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := auth.uid();
  v_role       text;
  v_cocuk_var  boolean;
  v_kod_var    boolean;
  v_cevap_var  boolean;
  v_plan_var   boolean;
  v_kodlar     text[] := array['cocuk_ekle', 'eslestir', 'ilk_ders', 'deneme_veya_plan'];
  v_tamam      boolean[];
  v_adimlar    jsonb := '[]'::jsonb;
  v_siradaki   text := null;
  i            integer;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı' using errcode = '42501';
  end if;

  select p.role into v_role from public.profiles p where p.id = v_uid;
  if v_role is distinct from 'veli' then
    raise exception 'Bu bilgi yalnızca veli hesaplarında gösterilir' using errcode = '42501';
  end if;

  -- Veli → çocuk bağı (yalnızca bu velinin çocukları)
  v_cocuk_var := exists (
    select 1 from public.profiles c
     where c.parent_id = v_uid and c.role = 'ogrenci'
  );

  -- Eşleştirme kodu: veli bu hesapta en az bir kod üretmiş mi
  v_kod_var := exists (
    select 1 from public.parent_link_codes k where k.veli_id = v_uid
  );

  -- Çocuğun ilk cevabı: yalnızca bu velinin çocuklarının user_answers kayıtları
  v_cevap_var := exists (
    select 1 from public.user_answers ua
     where ua.student_id in (
       select c.id from public.profiles c
        where c.parent_id = v_uid and c.role = 'ogrenci'
     )
  );

  -- Abonelik / deneme: süresi dolmamış aktif abonelik ya da başlatılmış deneme
  v_plan_var := exists (
    select 1 from public.subscriptions s
     where s.veli_id = v_uid and s.durum = 'aktif' and s.bitis > now()
  ) or exists (
    select 1 from public.growth_households h
     where h.core_parent_user_id = v_uid and h.trial_started_at is not null
  );

  v_tamam := array[
    (v_cocuk_var or v_kod_var),
    v_cocuk_var,
    v_cevap_var,
    v_plan_var
  ];

  -- İlk tamamlanmamış adım "siradaki", sonrakiler "bekliyor"
  for i in 1 .. array_length(v_kodlar, 1) loop
    if v_tamam[i] then
      v_adimlar := v_adimlar || jsonb_build_object('kod', v_kodlar[i], 'durum', 'tamam');
    elsif v_siradaki is null then
      v_siradaki := v_kodlar[i];
      v_adimlar := v_adimlar || jsonb_build_object('kod', v_kodlar[i], 'durum', 'siradaki');
    else
      v_adimlar := v_adimlar || jsonb_build_object('kod', v_kodlar[i], 'durum', 'bekliyor');
    end if;
  end loop;

  return jsonb_build_object('adimlar', v_adimlar, 'siradaki', v_siradaki);
end;
$$;

revoke execute on function public.veli_sonraki_adim() from public, anon;
grant  execute on function public.veli_sonraki_adim() to authenticated;

-- =====================================================================
--  KURTARMA: sınıf sorgulama ve VELİ tarafından sınıf değiştirme RPC'leri
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  KAYNAK (canlı gövdeler, BİREBİR):
--    kurtarilan/cikti-kalan.csv → kurtarilan/parcalar/my_sinif.sql
--                                kurtarilan/parcalar/set_child_grade.sql
--  Yetkiler (aynı dökümün "-- secdef" satırları):
--    my_sinif        : secdef true | anon: false | auth: true | servis: true
--    set_child_grade : secdef true | anon: false | auth: true | servis: true
--
--  NEDEN GEREKLİ:
--    * my_sinif()  → uygulama "hangi sınıftayım?" bilgisini bununla okur.
--    * set_child_grade() → VELİ, çocuğunun sınıfını değiştirir. Kural:
--      ilk değişiklik serbest, sonraki veli değişikliği için 24 saat bekleme
--      (öğrencinin kendi değişikliği 30 gün; o kural 20260927000020'deki
--      set_my_grade() içinde duruyor ve bu dosya onu DEĞİŞTİRMEZ).
--    Her ikisi de diskte yoktu; set_child_grade olmadan veli panelindeki
--    "sınıfı güncelle" akışı çalışma zamanında 404 alıyordu.
--
--  BAĞIMLILIKLAR (diskte VAR ✓):
--    public.is_parent_of(uuid)        → 20260920000000
--    public.grade_changes             → 20260920000200 (kaynak: 'veli'/'ogrenci'/'sistem')
--    public._sinif_yaz(uuid,int,text) → 20260927000030  (app.grade_rpc bayrağını set eder)
--    public._desteklenen_siniflar()   → 20260927000030
--    public.profiles.sinif            → 20260920000000
-- =====================================================================

-- Öğrencinin kendi sınıfı (uygulama açılışta okur)
create or replace function public.my_sinif()
returns smallint
language sql
stable security definer
set search_path = ''
as $function$
  select sinif from public.profiles where id = (select auth.uid());
$function$;

comment on function public.my_sinif() is
  'Oturumdaki kullanıcının sınıfı. Giriş yoksa NULL döner.';

-- VELİ: çocuğunun sınıfını değiştirir (24 saatte bir)
create or replace function public.set_child_grade(p_child_id uuid, p_sinif integer)
returns integer
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_son_veli timestamptz;
begin
  if (select auth.uid()) is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if p_child_id is null or not public.is_parent_of(p_child_id) then
    raise exception 'Yalnızca kendi çocuğunuzun sınıfını değiştirebilirsiniz' using errcode = '42501';
  end if;

  select created_at into v_son_veli
    from public.grade_changes
   where user_id = p_child_id and kaynak = 'veli'
   order by created_at desc
   limit 1;

  -- İlk veli değişikliğinde (kayıt yok) bekleme uygulanmaz.
  if v_son_veli is not null and v_son_veli > now() - interval '24 hours' then
    raise exception 'Çocuğunun sınıfını son 24 saatte zaten değiştirdin. Lütfen biraz sonra tekrar dene.'
      using errcode = '22023';
  end if;

  return public._sinif_yaz(p_child_id, p_sinif, 'veli');
end;
$function$;

comment on function public.set_child_grade(uuid, integer) is
  'Veli, kendi çocuğunun sınıfını değiştirir. İlk değişiklik serbest; sonraki veli değişikliği 24 saat bekler.';

-- Yetkiler
revoke execute on function public.my_sinif() from public, anon;
grant  execute on function public.my_sinif() to authenticated;

revoke execute on function public.set_child_grade(uuid, integer) from public, anon;
grant  execute on function public.set_child_grade(uuid, integer) to authenticated;

set client_encoding = 'UTF8';

-- =====================================================================
--  Growth veri kalitesi ve izin özeti (H-GIE Faz 1, son ekran)
--  Ön koşul: 20261014000000_growth_crm_core.sql      (growth_households, lifecycle)
--            20261104000000_growth_yasam_dongusu.sql  (growth_households.activated_at)
--            20261007000010_crm_profil_tercihler_ve_denetim.sql (iletisim_tercihleri)
--            20261105000000_growth_analitik_huni.sql  (_growth_gizle)
--
--  KONTROLLER
--    * eposta_eksik    : e-postası boş olan hane. Hane kartında e-posta yoksa ölçüm ve bildirim yapılamaz.
--    * aktif_tarihsiz  : aktive ve sonrası aşamada olup activated_at boş olan hane (yaşam döngüsü hatası).
--
--  İZİN ÖZETİ (kanal başına, yalnız veli profilleri)
--    * acik       : izin = true kaydı olan veli
--    * kapali     : izin = false kaydı olan veli
--    * kayit_yok  : bu kanal için hiç tercih kaydı olmayan veli (varsayılan: izin verilmemiş sayılır)
--
--  KARARLAR
--    * Her sayı 5'in altındaysa null (gizli). Sıfır da 5'in altındadır; "sorun yok" gösterimi
--      bu yüzden "gizli" olarak görünür. Bu bilinçli bir tercihtir (küçük sayılarla kişi çıkarımı yok).
--    * Kişi listesi döndürülmez; yalnız sayılar.
--
--  GÜVENLİK
--    * SECURITY DEFINER + set search_path = '' ve İLK ifadesi require_admin().
-- =====================================================================

create or replace function public.admin_growth_veri_kalitesi()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_veli       bigint;
  v_eposta     bigint;
  v_tarihsiz   bigint;
  v_izin       jsonb;
begin
  perform public.require_admin();

  select count(*) into v_veli
    from public.profiles p
   where p.role = 'veli';

  select count(*) filter (where h.email is null or btrim(h.email) = ''),
         count(*) filter (where h.lifecycle in ('activated', 'engaged', 'paid', 'at_risk', 'winback')
                            and h.activated_at is null)
    into v_eposta, v_tarihsiz
    from public.growth_households h;

  select coalesce(jsonb_agg(jsonb_build_object(
           'kanal', c.kanal,
           'acik', public._growth_gizle(coalesce(g.acik, 0)),
           'kapali', public._growth_gizle(coalesce(g.kapali, 0)),
           'kayit_yok', public._growth_gizle(greatest(v_veli - coalesce(g.toplam, 0), 0))
         ) order by c.sira), '[]'::jsonb)
    into v_izin
    from (values ('eposta', 1), ('push', 2), ('sms', 3), ('uygulama_ici', 4)) as c(kanal, sira)
    left join (
      select t.kanal,
             count(*) filter (where t.izin)     as acik,
             count(*) filter (where not t.izin) as kapali,
             count(*)                           as toplam
        from public.iletisim_tercihleri t
        join public.profiles p on p.id = t.veli_id and p.role = 'veli'
       group by t.kanal
    ) g on g.kanal = c.kanal;

  return jsonb_build_object(
    'veli_toplam', public._growth_gizle(v_veli),
    'kalite', jsonb_build_array(
      jsonb_build_object('kod', 'eposta_eksik',   'sayi', public._growth_gizle(v_eposta)),
      jsonb_build_object('kod', 'aktif_tarihsiz', 'sayi', public._growth_gizle(v_tarihsiz))
    ),
    'izin', v_izin
  );
end;
$function$;

revoke execute on function public.admin_growth_veri_kalitesi() from public, anon;
grant  execute on function public.admin_growth_veri_kalitesi() to authenticated, service_role;

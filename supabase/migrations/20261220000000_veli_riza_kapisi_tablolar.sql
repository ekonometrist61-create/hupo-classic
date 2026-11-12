-- =====================================================================
--  Veli okuma kapısı: rıza "verildi" değilse veli çocuğun ham verisini okuyamaz
--  Tarih : 2026-11-12
--  Karar : K-0257 / GÖR-113 (ajan kararı, kullanıcı "kararları en uygun şekilde ver" dedi)
--  Bulgu : GÖR-107 IDOR testi. Rızası geri çekilmiş çocuğun verisi (user_answers 40,
--          answer_events 160, user_badges 3, student_stats 1 satır) veliye doğrudan tablo
--          okumasıyla açıktı. Panel gizliyordu, veritabanı izni açıktı. get_student_dashboard,
--          get_student_badges, okuma_veli_ozeti, kelime_veli_ozeti ve veli_kazanim_haritasi
--          zaten rıza "verildi" şartı arıyor; bu migration kalan yolları aynı kurala bağlar.
--
--  NE YAPIYOR?
--    1. public.veli_okuyabilir(p_student_id): is_parent_of ve _veli_riza_durumu = 'verildi'.
--    2. SELECT politikaları: user_answers, answer_events, user_badges, student_stats,
--       xp_events, quest_claims, kelime_denemeleri, kelime_ustaliklari. Öğrencinin kendi
--       satırı etkilenmez (student_id/ogrenci_id = auth.uid()).
--    3. get_profile_overview, get_daily_goal, get_child_topic_progress, get_league_status:
--       is_parent_of yerine veli_okuyabilir (koşul dışı veli 42501 alır). Gövdeler canlıdan
--       alındı, yalnız bu koşul değişti.
--    consents tablosu BİLEREK muaf: veli rıza geçmişini görebilmeli. Yazma yolları
--    (set_daily_goal vb.) değişmedi: veli rızasız da hedef belirleyebilir.
--
--  Canlı etki (2026-11-12): bağlı 4 çocuktan 3'ü "verildi" (etkilenmez), 1'i "geri_cekildi"
--  (veli artık okuyamaz). Rıza kaydı hiç olmayan çocuk yok; yeni kayıtlar rıza ister.
--  Not: veli panelinin içerik bileşenleri (ChildScope) zaten riza = "verildi" şartıyla açılır.
--  Geri alma: politikaları is_parent_of'a, 4 fonksiyonu önceki gövdelerine döndür.
-- =====================================================================

create or replace function public.veli_okuyabilir(p_student_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.is_parent_of(p_student_id)
     and public._veli_riza_durumu(p_student_id) = 'verildi';
$$;

revoke all on function public.veli_okuyabilir(uuid) from public, anon;
grant execute on function public.veli_okuyabilir(uuid) to authenticated;
drop policy if exists user_answers_select on public.user_answers;
create policy user_answers_select on public.user_answers for select to authenticated
  using (student_id = (select auth.uid()) or (select public.veli_okuyabilir(student_id)));

drop policy if exists answer_events_select on public.answer_events;
create policy answer_events_select on public.answer_events for select to authenticated
  using (student_id = (select auth.uid()) or (select public.veli_okuyabilir(student_id)));

drop policy if exists user_badges_select on public.user_badges;
create policy user_badges_select on public.user_badges for select to authenticated
  using (student_id = (select auth.uid()) or (select public.veli_okuyabilir(student_id)));

drop policy if exists student_stats_select on public.student_stats;
create policy student_stats_select on public.student_stats for select to authenticated
  using (student_id = (select auth.uid()) or (select public.veli_okuyabilir(student_id)));

drop policy if exists xp_events_select on public.xp_events;
create policy xp_events_select on public.xp_events for select to authenticated
  using (student_id = (select auth.uid()) or (select public.veli_okuyabilir(student_id)));

drop policy if exists quest_claims_select on public.quest_claims;
create policy quest_claims_select on public.quest_claims for select to authenticated
  using (student_id = (select auth.uid()) or (select public.veli_okuyabilir(student_id)));

drop policy if exists "kelime denemeleri ogrenci ve veli okur" on public.kelime_denemeleri;
create policy "kelime denemeleri ogrenci ve veli okur" on public.kelime_denemeleri for select to authenticated
  using (ogrenci_id = (select auth.uid()) or (select public.veli_okuyabilir(ogrenci_id)));

drop policy if exists "kelime ustaliklari ogrenci ve veli okur" on public.kelime_ustaliklari;
create policy "kelime ustaliklari ogrenci ve veli okur" on public.kelime_ustaliklari for select to authenticated
  using (ogrenci_id = (select auth.uid()) or (select public.veli_okuyabilir(ogrenci_id)));

-- get_profile_overview
CREATE OR REPLACE FUNCTION public.get_profile_overview(p_student_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null
     or not (v_uid = p_student_id or public.veli_okuyabilir(p_student_id)) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  return jsonb_build_object(
    'uye_tarihi', (select created_at from public.profiles where id = p_student_id),
    'toplam_soru', (
      select count(*)::integer from public.user_answers where student_id = p_student_id),
    'dogruluk', (
      select round(100.0 * sum(dogru_sayisi) / nullif(sum(deneme_sayisi), 0))::integer
        from public.user_answers where student_id = p_student_id),
    'en_uzun_seri', coalesce((
      select en_uzun_seri from public.student_stats where student_id = p_student_id), 0),
    'ders_ilerleme', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.ders)
        from (
          select q.ders,
                 count(ua.id)::integer as cozulen,
                 count(*)::integer     as toplam,
                 coalesce(round(100.0 * sum(ua.dogru_sayisi)
                                / nullif(sum(ua.deneme_sayisi), 0)), 0)::integer as basari
            from public.questions q
            left join public.user_answers ua
                   on ua.question_id = q.id and ua.student_id = p_student_id
           where q.onay_durumu = 'onaylandi'
           group by q.ders
        ) x
    ), '[]'::jsonb)
  );
end;
$function$
;

-- get_daily_goal
CREATE OR REPLACE FUNCTION public.get_daily_goal(p_student_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid    uuid := (select auth.uid());
  v_bugun  date := (now() at time zone 'Europe/Istanbul')::date;
  v_hedef  integer;
  v_kalkan integer;
  v_sayi   integer;
begin
  if v_uid is null
     or not (v_uid = p_student_id or public.veli_okuyabilir(p_student_id)) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  select gunluk_hedef, seri_kalkani into v_hedef, v_kalkan
    from public.student_stats where student_id = p_student_id;

  select count(*)::integer into v_sayi
    from public.answer_events
   where student_id = p_student_id
     and (created_at at time zone 'Europe/Istanbul')::date = v_bugun;

  return jsonb_build_object(
    'hedef',         coalesce(v_hedef, 10),
    'bugun',         v_sayi,
    'tamamlandi',    v_sayi >= coalesce(v_hedef, 10),
    'seri_kalkani',  coalesce(v_kalkan, 0)
  );
end;
$function$
;

-- get_child_topic_progress
CREATE OR REPLACE FUNCTION public.get_child_topic_progress(p_student_id uuid, p_ders text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null
     or not (v_uid = p_student_id or public.veli_okuyabilir(p_student_id)) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.konu)
      from (
        select q.konu,
               count(*)::integer                                                      as toplam,
               sum(ua.dogru_sayisi)::integer                                          as dogru,
               round(100.0 * sum(ua.dogru_sayisi)
                     / nullif(sum(ua.deneme_sayisi), 0))::integer                     as oran,
               count(*) filter (where ua.dogru_mu = false)::integer                  as yanlis,
               count(*) filter (where ua.sonraki_tekrar_tarihi <= now())::integer     as bekleyen,
               max(ua.son_cevap_tarihi)                                               as son_cevap
          from public.user_answers ua
          join public.questions q on q.id = ua.question_id
         where ua.student_id = p_student_id
           and q.ders = p_ders
         group by q.konu
      ) x
  ), '[]'::jsonb);
end;
$function$
;

-- get_league_status
CREATE OR REPLACE FUNCTION public.get_league_status(p_student_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid       uuid := (select auth.uid());
  v_bu_hafta  date := public.hafta_baslangic();
  v_xp        integer;
  l           record;
  v_sira      integer;
  v_toplam    integer;
  v_bitis     timestamptz;
  v_sonraki   text;
begin
  if v_uid is null
     or not (v_uid = p_student_id or public.veli_okuyabilir(p_student_id)) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  insert into public.student_stats (student_id) values (p_student_id)
  on conflict (student_id) do nothing;
  perform public.resolve_league_week(p_student_id);

  select l1.kod, l1.ad, l1.sira, l1.yukselme_xp, l1.renk, l1.ikon
    into l
    from public.student_stats s
    join public.leagues l1 on l1.kod = s.lig
   where s.student_id = p_student_id;

  select coalesce(sum(xp), 0) into v_xp
    from public.xp_events
   where student_id = p_student_id
     and (created_at at time zone 'Europe/Istanbul')::date >= v_bu_hafta;

  -- Anonim sıralama: aynı ligdeki öğrenciler arasında bu haftaki XP'ye göre
  with hafta as (
    select s.student_id,
           coalesce(sum(e.xp) filter (
             where (e.created_at at time zone 'Europe/Istanbul')::date >= v_bu_hafta), 0) as xp
      from public.student_stats s
      left join public.xp_events e on e.student_id = s.student_id
     where s.lig = l.kod
     group by s.student_id
  )
  select count(*)::integer,
         (count(*) filter (where hafta.xp > v_xp) + 1)::integer
    into v_toplam, v_sira
    from hafta;

  v_bitis := ((v_bu_hafta + 7)::timestamp) at time zone 'Europe/Istanbul';

  select ad into v_sonraki from public.leagues where sira = l.sira + 1;

  return jsonb_build_object(
    'kod',            l.kod,
    'ad',             l.ad,
    'sira_no',        l.sira,
    'renk',           l.renk,
    'ikon',           l.ikon,
    'sonraki_lig',    v_sonraki,
    'yukselme_xp',    l.yukselme_xp,
    'haftalik_xp',    v_xp,
    'sira',           v_sira,
    'toplam',         v_toplam,
    'kalan_saniye',   greatest(0, floor(extract(epoch from (v_bitis - now())))::integer)
  );
end;
$function$
;


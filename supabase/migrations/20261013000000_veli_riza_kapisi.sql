-- =====================================================================
-- Veli rıza kapısı (AGENTS.md §5.3): öğrenci verisi veli onayı olmadan
-- veliye gösterilmez. Kapı sunucuda uygulanır; web paneli yalnızca arayüzde gizler.
--
--   - Öğrencinin kendi çağrıları (v_uid = p_student_id) etkilenmez: mobil uygulama
--     bu RPC'leri öğrencinin kendi hesabıyla kullanır.
--   - Veli çağrısında riza = 'verildi' değilse:
--       get_student_dashboard → öğrenci verisi boş döner, yalnızca 'riza' alanı gelir
--       get_student_badges    → boş liste döner
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Yardımcı: çocuğun güncel veli rıza durumu
--    get_consent_status ile aynı eşleme: yok | verildi | geri_cekildi
-- ---------------------------------------------------------------------
create or replace function public._veli_riza_durumu(p_cocuk_id uuid)
returns text
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_tur text;
begin
  select c.tur into v_tur
    from public.consents c
   where c.cocuk_id = p_cocuk_id
     and c.tur in ('veli_acik_riza', 'veli_riza_geri_cekildi')
   order by c.created_at desc, c.id desc
   limit 1;

  return case
           when v_tur is null then 'yok'
           when v_tur = 'veli_acik_riza' then 'verildi'
           else 'geri_cekildi'
         end;
end;
$$;

revoke execute on function public._veli_riza_durumu(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. get_student_dashboard: veli onayı yoksa öğrenci verisi dönmez
-- ---------------------------------------------------------------------
create or replace function public.get_student_dashboard(
  p_student_id  uuid,
  p_gun         integer default 7
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := (select auth.uid());
  v_today  date := (now() at time zone 'Europe/Istanbul')::date;
  v_gun    integer := least(greatest(coalesce(p_gun, 7), 1), 31);
  v_riza   text;
begin
  if v_uid is null
     or not (v_uid = p_student_id or public.is_parent_of(p_student_id)) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  v_riza := public._veli_riza_durumu(p_student_id);

  -- Veli onay vermediyse (veya geri çektiyse) öğrenci verisi dönmez.
  if v_uid <> p_student_id and v_riza <> 'verildi' then
    return jsonb_build_object(
      'riza', v_riza,
      'ozet', null,
      'ders_basari', '[]'::jsonb,
      'haftalik', '[]'::jsonb,
      'tekrar_konulari', '[]'::jsonb
    );
  end if;

  return jsonb_build_object(
    'riza', v_riza,

    -- XP, seviye, seri
    'ozet', (
      select jsonb_build_object(
               'xp', s.xp,
               'level', s.level,
               'streak_count', s.streak_count,
               'last_active_date', s.last_active_date)
        from public.student_stats s
       where s.student_id = p_student_id
    ),

    -- Ders bazlı başarı oranı (%)
    'ders_basari', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.ders)
        from (
          select q.ders,
                 sum(ua.dogru_sayisi)::integer  as dogru,
                 sum(ua.deneme_sayisi)::integer as toplam,
                 round(100.0 * sum(ua.dogru_sayisi) / nullif(sum(ua.deneme_sayisi), 0))::integer as oran
            from public.user_answers ua
            join public.questions q on q.id = ua.question_id
           where ua.student_id = p_student_id
           group by q.ders
        ) x
    ), '[]'::jsonb),

    -- Son p_gun gün: günlük çalışma süresi (dk) ve çözülen soru sayısı
    'haftalik', coalesce((
      select jsonb_agg(to_jsonb(h) order by h.gun)
        from (
          select g::date as gun,
                 coalesce(round(sum(least(e.sure_ms, 300000)) / 60000.0, 1), 0) as sure_dk,
                 count(e.id)::integer as soru_sayisi
            from generate_series(
                   (v_today - (v_gun - 1))::timestamp,
                   v_today::timestamp,
                   interval '1 day'
                 ) as g
            left join public.answer_events e
              on e.student_id = p_student_id
             and (e.created_at at time zone 'Europe/Istanbul')::date = g::date
           group by g
        ) h
    ), '[]'::jsonb),

    -- Tekrar çalışması gereken konular: yanlış cevaplananlar ve tekrar zamanı gelenler
    'tekrar_konulari', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.yanlis desc, t.bekleyen desc, t.konu)
        from (
          select q.ders,
                 q.konu,
                 count(*) filter (where ua.dogru_mu = false)::integer as yanlis,
                 count(*) filter (where ua.sonraki_tekrar_tarihi <= now())::integer as bekleyen,
                 count(*)::integer as toplam,
                 round(100.0 * sum(ua.dogru_sayisi) / nullif(sum(ua.deneme_sayisi), 0))::integer as oran
            from public.user_answers ua
            join public.questions q on q.id = ua.question_id
           where ua.student_id = p_student_id
           group by q.ders, q.konu
          having count(*) filter (where ua.dogru_mu = false) > 0
              or count(*) filter (where ua.sonraki_tekrar_tarihi <= now()) > 0
           order by count(*) filter (where ua.dogru_mu = false) desc,
                    count(*) filter (where ua.sonraki_tekrar_tarihi <= now()) desc
           limit 10
        ) t
    ), '[]'::jsonb)
  );
end;
$$;

revoke execute on function public.get_student_dashboard(uuid, integer) from public, anon;
grant  execute on function public.get_student_dashboard(uuid, integer) to authenticated;

-- ---------------------------------------------------------------------
-- 3. get_student_badges: veli onayı yoksa rozet listesi boş döner
-- ---------------------------------------------------------------------
create or replace function public.get_student_badges(p_student_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null
     or not (v_uid = p_student_id or public.is_parent_of(p_student_id)) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  if v_uid <> p_student_id
     and public._veli_riza_durumu(p_student_id) <> 'verildi' then
    return '[]'::jsonb;
  end if;

  return coalesce((
    select jsonb_agg(
             jsonb_build_object(
               'kod', d.kod,
               'ad', d.ad,
               'aciklama', d.aciklama,
               'ikon', d.ikon,
               'kosul_turu', d.kosul_turu,
               'esik', d.esik,
               'ders', d.ders,
               'min_deneme', d.min_deneme,
               'kazanildi', ub.id is not null,
               'kazanma_tarihi', ub.earned_at,
               'ilerleme', p.ilerleme,
               'deneme', p.deneme
             )
             order by d.sira, d.kod)
      from public.badge_definitions d
      join public.badge_progress(p_student_id) p on p.badge_code = d.kod
      left join public.user_badges ub
             on ub.student_id = p_student_id and ub.badge_code = d.kod
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.get_student_badges(uuid) from public, anon;
grant  execute on function public.get_student_badges(uuid) to authenticated;

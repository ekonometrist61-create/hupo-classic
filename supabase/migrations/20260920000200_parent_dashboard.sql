-- =====================================================================
-- Veli paneli: cevap geçmişi (answer_events) + get_student_dashboard()
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. answer_events: her cevabın geçmişi (haftalık çalışma süresi için)
--    user_answers soru başına tek satır tuttuğundan geçmiş orada kaybolur.
-- ---------------------------------------------------------------------
create table public.answer_events (
  id           uuid primary key default gen_random_uuid(),
  student_id   uuid not null references public.profiles (id) on delete cascade,
  question_id  uuid not null references public.questions (id) on delete cascade,
  dogru_mu     boolean not null,
  sure_ms      integer check (sure_ms is null or sure_ms >= 0),
  created_at   timestamptz not null default now()
);

create index answer_events_student_time_idx
  on public.answer_events (student_id, created_at desc);

-- Mevcut cevapları geçmişe aktar (tek seferlik)
insert into public.answer_events (student_id, question_id, dogru_mu, sure_ms, created_at)
select student_id, question_id, dogru_mu, son_sure_ms, son_cevap_tarihi
  from public.user_answers;

-- user_answers her yazıldığında geçmişe satır ekle
create or replace function public.log_answer_event()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.answer_events (student_id, question_id, dogru_mu, sure_ms, created_at)
  values (new.student_id, new.question_id, new.dogru_mu, new.son_sure_ms, new.son_cevap_tarihi);
  return new;
end;
$$;

create trigger user_answers_log_event
  after insert or update of son_cevap_tarihi on public.user_answers
  for each row execute function public.log_answer_event();

revoke execute on function public.log_answer_event() from public, anon, authenticated;

alter table public.answer_events enable row level security;

create policy "answer_events_select"
  on public.answer_events for select to authenticated
  using (student_id = (select auth.uid()) or public.is_parent_of(student_id));

revoke all on public.answer_events from anon;
revoke insert, update, delete on public.answer_events from authenticated;

-- ---------------------------------------------------------------------
-- 2. get_student_dashboard: veli panelinin tek veri kaynağı
--    Yalnızca öğrencinin kendisi veya velisi çağırabilir.
--    Çalışma süresi: cevap başına en fazla 5 dk sayılır (açık unutulan
--    ekranların süreyi şişirmesini engeller). Günler Europe/Istanbul'a göre.
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
begin
  if v_uid is null
     or not (v_uid = p_student_id or public.is_parent_of(p_student_id)) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  return jsonb_build_object(
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

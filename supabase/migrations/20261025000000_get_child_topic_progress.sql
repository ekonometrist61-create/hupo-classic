-- Veli paneli: ders bazında konu ilerleme raporu
-- SubjectsView'da seçilen dersin tüm konularını döner (yalnızca tekrar listesi değil).

set client_encoding = 'UTF8';

create or replace function public.get_child_topic_progress(
  p_student_id uuid,
  p_ders       text
)
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
$$;

revoke execute on function public.get_child_topic_progress(uuid, text) from public, anon;
grant  execute on function public.get_child_topic_progress(uuid, text) to authenticated;

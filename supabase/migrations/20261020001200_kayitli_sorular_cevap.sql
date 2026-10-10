-- =====================================================================
-- Kayıtlı sorular: cevap ve çözüm adımları da döner.
-- Deneme sınavında kullanılmış sorularda doğru şık ve çözüm GÖNDERİLMEZ
-- (sınav bütünlüğü); bu sorular yalnızca metin ve şıklarla listelenir.
-- =====================================================================

drop function if exists public.list_bookmarks();

create function public.list_bookmarks()
returns table (
  question_id    uuid,
  ders           text,
  konu           text,
  alt_konu       text,
  zorluk         smallint,
  soru_metni     text,
  siklar         jsonb,
  dogru_sik      text,
  cozum_adimlari jsonb,
  created_at     timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select q.id, q.ders, q.konu, q.alt_konu, q.zorluk, q.soru_metni, q.siklar,
         case when exists (
           select 1 from public.deneme_sinavi_sorulari dss where dss.question_id = q.id
         ) then null else q.dogru_sik end,
         case when exists (
           select 1 from public.deneme_sinavi_sorulari dss where dss.question_id = q.id
         ) then null else q.cozum_adimlari end,
         b.created_at
    from public.question_bookmarks b
    join public.questions q on q.id = b.question_id
   where b.user_id = (select auth.uid())
     and q.onay_durumu = 'onaylandi'
   order by b.created_at desc
   limit 200;
$$;

revoke execute on function public.list_bookmarks() from public, anon;
grant  execute on function public.list_bookmarks() to authenticated;

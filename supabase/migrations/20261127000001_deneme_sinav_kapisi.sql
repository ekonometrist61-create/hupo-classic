-- =====================================================================
--  Deneme sınavları: ücretsiz deneme bitince ve plan ücretli değilse kapalı
--  Tarih : 2026-10-29
--
--  Karar (mar-oto-ai, proje sahibi onayı): deneme sınavları premium maddesidir.
--  Deneme süresinde (deneme_donemleri aktif) ya da premium hanede kayıt açılır;
--  diğer durumlarda deneme_sinavi_katilimlari insert'i P0403 ile reddedilir.
--
--  Yalnız oturumlu (istemci) yazımları kapatılır; servis/sunucu yazımları etkilenmez.
--  AFTER INSERT: ON CONFLICT ile yapılan güncellemeler insert tetikleyicisini ateşlemez.
-- =====================================================================

create or replace function public.deneme_sinav_kapisi()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    return new;
  end if;
  if public.is_premium(new.student_id) or public._deneme_aktif(new.student_id) then
    return new;
  end if;
  raise exception 'Deneme sınavları ücretsiz planda yer almıyor. Premium planla katılabilirsin.'
    using errcode = 'P0403';
end;
$$;

comment on function public.deneme_sinav_kapisi() is
  'Deneme sınavı kaydını yalnız deneme süresinde veya premium hanede açar (P0403).';

revoke execute on function public.deneme_sinav_kapisi() from public, anon, authenticated;

drop trigger if exists trg_deneme_sinav_kapisi on public.deneme_sinavi_katilimlari;
create trigger trg_deneme_sinav_kapisi
  after insert on public.deneme_sinavi_katilimlari
  for each row execute function public.deneme_sinav_kapisi();

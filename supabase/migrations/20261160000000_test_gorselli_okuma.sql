-- Görselli paket telefon testi (2026-11-08): beklemede görselli soruları yalnızca E2E çocuk test hesabına gösterir.
--  * Yalnızca e2e-cocuk@hupolingo-test.invalid hesabı çağırabilir; diğer herkes yetki hatası alır.
--  * Yayın durumunu değiştirmez (onay_durumu olduğu gibi kalır); submit_answer yalnızca onaylı soruları kabul eder,
--    yani bu sorular test hesabında görüntülenir ama cevaplanamaz.
--  * gorsel_spec ve dogru_sik döndürülmez.
-- Uygulama: 'supabase db query --linked -f' (idempotent).

create or replace function public.ogrenci_test_gorselli_sorular(p_ders text default null)
returns table (
  id              uuid,
  ders            text,
  konu            text,
  alt_konu        text,
  zorluk          smallint,
  soru_metni      text,
  siklar          jsonb,
  gorsel_svg      text,
  gorsel_alt_metin text,
  gorsel_tip      text,
  highlights      jsonb
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_test_uid uuid;
begin
  select u.id into v_test_uid
    from auth.users u
   where u.email = 'e2e-cocuk@hupolingo-test.invalid';

  if v_uid is null or v_test_uid is null or v_uid <> v_test_uid then
    raise exception 'Bu işlem yalnızca test hesabına açıktır' using errcode = '42501';
  end if;

  return query
    select q.id, q.ders, q.konu, q.alt_konu, q.zorluk, q.soru_metni, q.siklar,
           q.gorsel_svg, q.gorsel_alt_metin, q.gorsel_tip, q.highlights
      from public.questions q
     where q.gorsel_svg is not null
       and q.gorsel_gerekli
       and q.onay_durumu = 'beklemede'
       and (p_ders is null or q.ders = p_ders)
     order by q.ders, q.konu, q.id;
end;
$$;

revoke execute on function public.ogrenci_test_gorselli_sorular(text) from public, anon;
grant execute on function public.ogrenci_test_gorselli_sorular(text) to authenticated;

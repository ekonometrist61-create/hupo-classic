-- =====================================================================
--  Duyuru listesi: 200 kayıt sınırı kalkar (sayfalama)
--  Proje : Hupo / Yönetim Merkezi
--  Tarih : 2026-11-08
--  Ön koşul: 20261032000000 (admin_list_duyurular)
--  Kaynak: PROJE_GUNLUGU.md GÖR-024 ("duyuru listesi 200 kayıt sınırı")
--
--  NE DEĞİŞİYOR?
--    * admin_list_duyurular(p_arsiv, p_limit, p_offset): varsayılan p_limit=200 (eski davranış),
--      en çok 1000; p_offset ile sayfalanır. Dönüş biçimi (jsonb dizi) AYNI; satırlar duyurular
--      tablosunun tüm sütunlarını taşır (20261035 alanları dahil: kategori, hedef_rol, ...).
--    * admin_duyuru_sayisi(p_arsiv): toplam kayıt (arayüz "Daha fazla" için).
--    Eski tek parametreli imza düşer (aşırı yükleme belirsizliği olmasın); p_arsiv adlı
--    çağrılar (web paneli) değişmeden çalışır.
-- =====================================================================

set client_encoding = 'UTF8';

drop function if exists public.admin_list_duyurular(boolean);

create or replace function public.admin_list_duyurular(
  p_arsiv  boolean default false,
  p_limit  integer default 200,
  p_offset integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 200), 1), 1000);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
begin
  perform public.require_admin();

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id)
      from (
        select d.*
          from public.duyurular d
         where (d.arsivlendi_at is not null) = coalesce(p_arsiv, false)
         order by d.created_at desc, d.id
         limit v_limit offset v_offset
      ) x
  ), '[]'::jsonb);
end;
$function$;

comment on function public.admin_list_duyurular(boolean, integer, integer) is
  'Yönetici duyuru listesi: p_arsiv=false aktif, true arşiv. Sayfalı (varsayılan 200, en çok 1000). Yalnızca yönetici.';

create or replace function public.admin_duyuru_sayisi(p_arsiv boolean default false)
returns integer
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  return (select count(*)::integer from public.duyurular d
           where (d.arsivlendi_at is not null) = coalesce(p_arsiv, false));
end;
$function$;

revoke execute on function public.admin_list_duyurular(boolean, integer, integer) from public, anon;
revoke execute on function public.admin_duyuru_sayisi(boolean)                    from public, anon;
grant  execute on function public.admin_list_duyurular(boolean, integer, integer) to authenticated;
grant  execute on function public.admin_duyuru_sayisi(boolean)                    to authenticated;

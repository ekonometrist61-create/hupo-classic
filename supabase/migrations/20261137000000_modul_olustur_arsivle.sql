-- =====================================================================
--  YENİ MODÜL OLUŞTUR / ARŞİVLE (yönetici)
--  Tarih : 2026-10-29
--  Tasarım: docs/paketler/ESNEK_PAKET_VE_ODEME_MIMARISI.md §3 (adım 1: "Yeni modül ekle → taslak")
--  Ön koşul: 20261130 (moduller), 20261131 (karar kuralı), require_admin, log_admin_action
--
--  NE DEĞİŞİYOR? (YALNIZ EKLEME)
--    1) admin_modul_olustur(kod, ad, aciklama): modülü 'taslak' olarak ekler. Taslak modül hiçbir
--       pakete erişim vermez; yayın için P2 kuralı (her etkin pakette karar) geçerlidir.
--    2) admin_modul_arsivle(kod): modülü 'arsiv' yapar (erişim kapanır; kayıt ve kararlar silinmez).
--
--  Güvenlik: yalnız yönetici (require_admin); SECURITY DEFINER + search_path=''.
--  Rollback: fonksiyonlar düşürülür; oluşturulan taslak modüller elle silinebilir (yayınlanmadıysa).
-- =====================================================================

create or replace function public.admin_modul_olustur(
  p_kod      text,
  p_ad       text,
  p_aciklama text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_sira integer;
begin
  perform public.require_admin();

  if exists (select 1 from public.moduller where kod = p_kod) then
    raise exception 'Bu modül kodu zaten var: %', p_kod using errcode = '23505';
  end if;

  select coalesce(max(sira), 0) + 1 into v_sira from public.moduller;

  -- Biçim kısıtları (kod deseni, ad uzunluğu) tablo CHECK'lerinden gelir.
  insert into public.moduller (kod, ad, aciklama, durum, sira)
  values (p_kod, btrim(p_ad), nullif(btrim(coalesce(p_aciklama, '')), ''), 'taslak', v_sira);

  perform public.log_admin_action('modul_olusturuldu',
    jsonb_build_object('modul', p_kod));

  return jsonb_build_object('kod', p_kod, 'durum', 'taslak', 'sira', v_sira);
end;
$$;

create or replace function public.admin_modul_arsivle(p_kod text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();

  if not exists (select 1 from public.moduller where kod = p_kod) then
    raise exception 'Modül bulunamadı: %', p_kod using errcode = 'P0002';
  end if;

  update public.moduller set durum = 'arsiv' where kod = p_kod;

  perform public.log_admin_action('modul_arsivlendi',
    jsonb_build_object('modul', p_kod));

  return jsonb_build_object('kod', p_kod, 'durum', 'arsiv');
end;
$$;

revoke execute on function public.admin_modul_olustur(text, text, text),
  public.admin_modul_arsivle(text) from public, anon;
grant  execute on function public.admin_modul_olustur(text, text, text),
  public.admin_modul_arsivle(text) to authenticated;

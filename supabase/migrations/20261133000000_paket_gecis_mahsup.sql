-- =====================================================================
--  P7 · PAKET GEÇİŞİ: orantılı mahsup teklifi (salt okuma)
--  Tarih : 2026-10-29
--  Tasarım: docs/paketler/ESNEK_PAKET_VE_ODEME_MIMARISI.md §2 (paket_gecis.mahsup=orantili), §6
--
--  KURAL (orantili)
--    * Veli, aktif aboneliğinin KALAN süresinin değerini yeni planın tutarından düşer.
--    * Kalan değer = mevcut planın fiyatı × kalan_gün / plan_süresi_gün (aşağı yuvarlanır).
--    * Ödenecek = max(hedef_fiyat − mahsup, 0). Mahsup hedefi aşarsa fazla iade edilmez (kural).
--    * Fiyatlar admin tablosu `plans`ten okunur; kodda sabit fiyat yoktur.
--
--  NE DEĞİŞİYOR? Yalnız bir okuma RPC'si. Ödeme, abonelik yazımı YOK (P5/P6'da).
--  Güvenlik: yalnız giriş yapmış veli; yalnız kendi aboneliği. Çocuk hesabı kendi velisinin
--  aboneliğini değil, kendi (boş) aboneliğini görür: teklif çocuk ekranında üretilmez (UI kararı).
-- =====================================================================

create or replace function public.my_gecis_mahsubu(p_hedef_plan_kod text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_hedef   integer;
  r         record;
  v_kalan_g integer;
  v_mahsup  bigint;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;

  select pl.fiyat_kurus into v_hedef
    from public.plans pl
   where pl.kod = p_hedef_plan_kod and pl.aktif;
  if v_hedef is null then
    raise exception 'Plan bulunamadı: %', p_hedef_plan_kod using errcode = 'P0002';
  end if;

  select s.plan_kod, s.bitis, pl.fiyat_kurus, pl.sure_gun
    into r
    from public.subscriptions s
    join public.plans pl on pl.kod = s.plan_kod
   where s.veli_id = v_uid and s.durum = 'aktif' and s.bitis > now()
   order by s.bitis desc
   limit 1;

  if not found or r.sure_gun is null or r.sure_gun <= 0 then
    return jsonb_build_object(
      'kaynak', 'yok',
      'mahsup_kurus', 0,
      'hedef_plan', p_hedef_plan_kod,
      'hedef_kurus', v_hedef,
      'odenecek_kurus', v_hedef);
  end if;

  v_kalan_g := least(
    ceil(extract(epoch from (r.bitis - now())) / 86400.0)::integer,
    r.sure_gun);
  v_mahsup := floor(r.fiyat_kurus::numeric * v_kalan_g / r.sure_gun);

  return jsonb_build_object(
    'kaynak', 'abonelik',
    'mevcut_plan', r.plan_kod,
    'kalan_gun', v_kalan_g,
    'mahsup_kurus', v_mahsup,
    'hedef_plan', p_hedef_plan_kod,
    'hedef_kurus', v_hedef,
    'odenecek_kurus', greatest(v_hedef - v_mahsup, 0));
end;
$$;

revoke execute on function public.my_gecis_mahsubu(text) from public, anon;
grant  execute on function public.my_gecis_mahsubu(text) to authenticated;

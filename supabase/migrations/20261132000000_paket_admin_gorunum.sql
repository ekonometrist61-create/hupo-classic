-- =====================================================================
--  P3 · PAKET YÖNETİM GÖRÜNÜMÜ: matris, kararlar, etki önizlemesi
--  Tarih : 2026-10-29
--  Tasarım: docs/paketler/ESNEK_PAKET_VE_ODEME_MIMARISI.md §3, §4
--  Ön koşul: 20261130 (P1), 20261131 (P2)
--
--  NE DEĞİŞİYOR? (YALNIZ EKLEME; yazma yolu yok, salt okuma RPC'leri)
--    1) admin_paket_matris()          : modüller × paketler matrisi (erişim, kota, karar, sürüm)
--    2) admin_modul_etki_onizleme(m)  : yayınlamadan önce "ne olacak?" raporu:
--         - her etkin paket için karar var mı, hangi karar
--         - etkilenen AKTİF abone sayısı (kapsam seçilirse yeni sürüme geçecek olanlar)
--         - yayın engeli var mı (eksik karar listesi)
--    Yazma işlemleri zaten P2'de (admin_modul_karar_kaydet, admin_modul_yayinla).
--  Güvenlik: iki RPC de require_admin ile korunur; anon/authenticated'a grant yok, yalnız
--  authenticated (içeride require_admin zaten yetkisiz çağrıyı 42501 ile reddeder).
-- =====================================================================

create or replace function public.admin_paket_matris()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();
  return jsonb_build_object(
    'moduller', coalesce((
      select jsonb_agg(jsonb_build_object(
               'kod', m.kod, 'ad', m.ad, 'durum', m.durum, 'sira', m.sira) order by m.sira, m.kod)
        from public.moduller m
    ), '[]'::jsonb),
    'paketler', coalesce((
      select jsonb_agg(jsonb_build_object(
               'kod', p.kod, 'ad', p.ad, 'tur', p.tur, 'cocuk_siniri', p.cocuk_siniri,
               'rapor_kapsami', p.rapor_kapsami, 'durum', p.durum, 'surum', p.surum,
               'aktif_abone', (
                 select count(*)::int from public.subscriptions s
                   join public.plans pl on pl.kod = s.plan_kod
                  where pl.paket_kod = p.kod and s.durum = 'aktif' and s.bitis > now())
             ) order by p.sira, p.kod)
        from public.paketler p
    ), '[]'::jsonb),
    'hucreler', coalesce((
      select jsonb_agg(jsonb_build_object(
               'paket', pm.paket_kod, 'modul', pm.modul_kod,
               'erisim', pm.erisim, 'gunluk_kota', pm.gunluk_kota))
        from public.paket_modul pm
    ), '[]'::jsonb),
    'kararlar', coalesce((
      select jsonb_agg(jsonb_build_object(
               'modul', k.modul_kod, 'paket', k.paket_kod, 'karar', k.karar,
               'gunluk_kota', k.gunluk_kota, 'mevcut_aboneleri_kapsar', k.mevcut_aboneleri_kapsar,
               'gerekce', k.gerekce, 'karar_tarihi', k.karar_tarihi))
        from public.modul_paket_karar k
    ), '[]'::jsonb)
  );
end;
$$;

create or replace function public.admin_modul_etki_onizleme(p_modul text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_durum    text;
  v_eksik    text[];
  v_paketler jsonb;
begin
  perform public.require_admin();

  select m.durum into v_durum from public.moduller m where m.kod = p_modul;
  if v_durum is null then
    raise exception 'Modül bulunamadı: %', p_modul using errcode = 'P0002';
  end if;

  select array_agg(p.kod order by p.sira, p.kod) into v_eksik
    from public.paketler p
   where p.durum <> 'arsiv'
     and not exists (select 1 from public.modul_paket_karar k
                      where k.modul_kod = p_modul and k.paket_kod = p.kod);

  select coalesce(jsonb_agg(jsonb_build_object(
           'paket', p.kod,
           'ad', p.ad,
           'karar', k.karar,
           'erisim', k.erisim,
           'gunluk_kota', k.gunluk_kota,
           'mevcut_aboneleri_kapsar', coalesce(k.mevcut_aboneleri_kapsar, false),
           'aktif_abone', (
             select count(*)::int from public.subscriptions s
               join public.plans pl on pl.kod = s.plan_kod
              where pl.paket_kod = p.kod and s.durum = 'aktif' and s.bitis > now()),
           'etkilenen_abone', case when coalesce(k.mevcut_aboneleri_kapsar, false) then (
             select count(*)::int from public.subscriptions s
               join public.plans pl on pl.kod = s.plan_kod
              where pl.paket_kod = p.kod and s.durum = 'aktif' and s.bitis > now())
             else 0 end
         ) order by p.sira, p.kod), '[]'::jsonb)
    into v_paketler
    from public.paketler p
    left join public.modul_paket_karar k
           on k.modul_kod = p_modul and k.paket_kod = p.kod
   where p.durum <> 'arsiv';

  return jsonb_build_object(
    'modul', p_modul,
    'modul_durum', v_durum,
    'yayinlanabilir', v_eksik is null,
    'eksik_kararlar', coalesce(to_jsonb(v_eksik), '[]'::jsonb),
    'paketler', v_paketler
  );
end;
$$;

revoke execute on function public.admin_paket_matris(), public.admin_modul_etki_onizleme(text)
  from public, anon;
grant  execute on function public.admin_paket_matris(), public.admin_modul_etki_onizleme(text)
  to authenticated;

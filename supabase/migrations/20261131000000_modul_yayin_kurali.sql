-- =====================================================================
--  P2 · YENİ MODÜL KURALI: karar olmadan yayın yok
--  Tarih : 2026-10-29
--  Tasarım: docs/paketler/ESNEK_PAKET_VE_ODEME_MIMARISI.md §3
--  Ön koşul: 20261130000000 (moduller, paketler, paket_modul, paket_surum, _paket_yayinla_ic)
--
--  KURAL
--    * Bir modül yalnız, her etkin paket (durum <> 'arsiv') için bir karar kaydı varsa yayınlanır.
--      Eksik karar varsa P0422 ile hangi paketlerin eksik olduğu döner.
--    * Karar: dahil | sinirli | haric | yeni_paket
--        dahil     → paket_modul'de erisim 'tam' (kota isteğe bağlı)
--        sinirli   → erisim 'sinirli' (kota zorunlu)
--        haric     → paket_modul satırı yok (erişim yok)
--        yeni_paket→ kayıt tutulur, matrise eklenmez; "ayrı paket olacak" notu. Yayın bloke etmez.
--    * mevcut_aboneleri_kapsar = false (varsayılan): yeni sürüm yalnız yeni satın almalara.
--      true: o paketin AKTİF aboneleri de yeni sürüme taşınır (açık seçim).
--    * Yayın, etkilenen paketlerin sürümünü yeniden üretir (_paket_yayinla_ic).
--    * Taslak olmayan (yayında) modülün kararını değiştirmek için de aynı RPC kullanılır;
--      değişiklik ancak yeniden yayınlanınca etkili olur (sürüm kuralı).
--  Rollback: karar tablosu ve RPC'ler düşürülür; moduller.durum elle eski değere çekilir.
-- =====================================================================

create table if not exists public.modul_paket_karar (
  modul_kod              text not null references public.moduller (kod) on update cascade on delete cascade,
  paket_kod              text not null references public.paketler (kod) on update cascade on delete cascade,
  karar                  text not null,
  erisim                 text,
  gunluk_kota            integer,
  mevcut_aboneleri_kapsar boolean not null default false,
  gerekce                text,
  karar_veren            uuid,
  karar_tarihi           timestamptz not null default now(),
  primary key (modul_kod, paket_kod),
  constraint modul_paket_karar_karar check (karar in ('dahil', 'sinirli', 'haric', 'yeni_paket')),
  constraint modul_paket_karar_erisim check (
    (karar = 'dahil'   and erisim = 'tam'   and (gunluk_kota is null or gunluk_kota >= 0))
 or (karar = 'sinirli' and erisim = 'sinirli' and gunluk_kota is not null and gunluk_kota >= 0)
 or (karar in ('haric', 'yeni_paket') and erisim is null and gunluk_kota is null))
);

alter table public.modul_paket_karar enable row level security;
revoke all on public.modul_paket_karar from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Karar kaydet (yalnız yönetici). Matrisi de günceller; yayın ayrıca gerekir.
-- ---------------------------------------------------------------------
create or replace function public.admin_modul_karar_kaydet(
  p_modul                 text,
  p_paket                 text,
  p_karar                 text,
  p_gunluk_kota           integer default null,
  p_mevcut_aboneleri      boolean default false,
  p_gerekce               text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_erisim text;
begin
  perform public.require_admin();

  if not exists (select 1 from public.moduller where kod = p_modul) then
    raise exception 'Modül bulunamadı: %', p_modul using errcode = 'P0002';
  end if;
  if not exists (select 1 from public.paketler where kod = p_paket) then
    raise exception 'Paket bulunamadı: %', p_paket using errcode = 'P0002';
  end if;

  v_erisim := case p_karar when 'dahil' then 'tam' when 'sinirli' then 'sinirli' else null end;

  insert into public.modul_paket_karar
    (modul_kod, paket_kod, karar, erisim, gunluk_kota, mevcut_aboneleri_kapsar, gerekce, karar_veren, karar_tarihi)
  values
    (p_modul, p_paket, p_karar, v_erisim,
     case when p_karar in ('dahil', 'sinirli') then p_gunluk_kota else null end,
     p_mevcut_aboneleri, p_gerekce, v_uid, now())
  on conflict (modul_kod, paket_kod) do update set
    karar = excluded.karar,
    erisim = excluded.erisim,
    gunluk_kota = excluded.gunluk_kota,
    mevcut_aboneleri_kapsar = excluded.mevcut_aboneleri_kapsar,
    gerekce = excluded.gerekce,
    karar_veren = excluded.karar_veren,
    karar_tarihi = excluded.karar_tarihi;

  -- Matris: dahil/sinirli → satır; haric/yeni_paket → satır yok
  if p_karar in ('dahil', 'sinirli') then
    insert into public.paket_modul (paket_kod, modul_kod, erisim, gunluk_kota)
    values (p_paket, p_modul, v_erisim, case when p_karar = 'sinirli' then p_gunluk_kota else null end)
    on conflict (paket_kod, modul_kod) do update set
      erisim = excluded.erisim, gunluk_kota = excluded.gunluk_kota;
  else
    delete from public.paket_modul where paket_kod = p_paket and modul_kod = p_modul;
  end if;

  perform public.log_admin_action('modul_karar_kaydedildi',
    jsonb_build_object('modul', p_modul, 'paket', p_paket, 'karar', p_karar,
                       'mevcut_aboneleri', p_mevcut_aboneleri));
end;
$$;

-- ---------------------------------------------------------------------
-- Yayınla: eksik karar varsa reddet; varsa modülü yayınla, etkili paketleri yeniden üret.
-- ---------------------------------------------------------------------
create or replace function public.admin_modul_yayinla(p_modul text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_eksik  text[];
  v_paket  record;
  v_yeni   integer;
  v_etk    text[] := '{}';
  v_kapsa  integer := 0;
begin
  perform public.require_admin();

  if not exists (select 1 from public.moduller where kod = p_modul) then
    raise exception 'Modül bulunamadı: %', p_modul using errcode = 'P0002';
  end if;

  -- Eksik karar kontrolü: etkin her paket için karar olmalı
  select array_agg(p.kod order by p.sira, p.kod) into v_eksik
    from public.paketler p
   where p.durum <> 'arsiv'
     and not exists (select 1 from public.modul_paket_karar k
                      where k.modul_kod = p_modul and k.paket_kod = p.kod);
  if v_eksik is not null then
    raise exception 'Modül yayınlanamaz: şu paketler için karar yok: %', array_to_string(v_eksik, ', ')
      using errcode = 'P0422';
  end if;

  update public.moduller
     set durum = 'yayinda', yayin_tarihi = coalesce(yayin_tarihi, now())
   where kod = p_modul;

  -- Karar verilen her paketi yeniden üret (matris değişmiş olabilir)
  for v_paket in
    select k.paket_kod, k.mevcut_aboneleri_kapsar
      from public.modul_paket_karar k
      join public.paketler p on p.kod = k.paket_kod
     where k.modul_kod = p_modul and p.durum <> 'arsiv' and k.karar in ('dahil', 'sinirli', 'haric')
  loop
    v_yeni := public._paket_yayinla_ic(v_paket.paket_kod);
    v_etk := array_append(v_etk, v_paket.paket_kod || '@' || v_yeni);

    -- Açık seçim: aktif aboneler yeni sürüme taşınır
    if v_paket.mevcut_aboneleri_kapsar then
      update public.subscriptions s
         set paket_surum = v_yeni
        from public.plans pl
       where pl.kod = s.plan_kod
         and pl.paket_kod = v_paket.paket_kod
         and s.durum = 'aktif' and s.bitis > now();
      get diagnostics v_kapsa = row_count;
    end if;
  end loop;

  perform public.log_admin_action('modul_yayinlandi',
    jsonb_build_object('modul', p_modul, 'etkilenen', v_etk));

  return jsonb_build_object('modul', p_modul, 'durum', 'yayinda', 'etkilenen_paketler', v_etk);
end;
$$;

revoke execute on function public.admin_modul_karar_kaydet(text, text, text, integer, boolean, text),
  public.admin_modul_yayinla(text) from public, anon;
grant  execute on function public.admin_modul_karar_kaydet(text, text, text, integer, boolean, text),
  public.admin_modul_yayinla(text) to authenticated;

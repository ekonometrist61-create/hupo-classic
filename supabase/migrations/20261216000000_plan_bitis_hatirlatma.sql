-- =====================================================================
--  Web planı bitiş hatırlatması (30 / 7 / 1 gün kala)
--  Tarih : 2026-11-12
--  Karar : K-0256 (ONAYLI) — web planları tek seferlik, kendiliğinden yenilenmez;
--          bitişten 30, 7 ve 1 gün önce veliye indirim içermeyen hatırlatma.
--  Hukuk : docs/hukuk/paket-2026-11/07_ILETISIM_POLITIKASI_IC_KURAL.md §1 (K sınıfı:
--          satın alınan hizmetin kullanımı, 6563 m.6/1). Pazarlama izni ARANMAZ, bu yüzden
--          metne indirim, fiyat, kampanya veya aciliyet dili EKLENMEZ (eklenirse ileti
--          ticari olur ve izin + İYS gerekir). Metinler: mar-oto-ai, 2026-11-12.
--
--  NE EKLİYOR?
--    tablo    : public.plan_bitis_hatirlatmalari (abonelik + gün başına tek kayıt; idempotent)
--    fonksiyon: public.plan_bitis_hatirlatmalarini_gonder(p_simdi) -> integer (gönderilen sayısı)
--    cron     : 'plan-bitis-hatirlatma' her gün 07:00 UTC (10:00 TR); pg_cron yoksa atlanır
--
--  KAPSAM
--    * Yalnız aktif, ücretli (plans.fiyat_kurus > 0) ve web/manuel kaynaklı abonelikler
--      (saglayici: iyzico, paytr, param, manuel). Mağaza abonelikleri (Apple/Google)
--      kendiliğinden yenilendiği için kapsam dışı.
--    * Hatırlatma, kalan süre (gun-1, gun] gün aralığındayken bir kez gider.
--    * Kısa planlarda erken hatırlatma atlanır: abonelik süresi < 2 × gun ise o gün gönderilmez
--      (ör. 30 günlük planda 30 gün hatırlatması satın alma günü gitmesin).
--    * Velinin, bu aboneliğin bitişinden sonra da süren başka bir aktif/beklemede aboneliği
--      varsa (yenilemiş) hatırlatma gitmez.
--    * Gönderim public.bildirim_gonder üzerinden: uygulama kutusu + push (notifications
--      trigger'ı) + e-posta (eposta_outbox).
-- =====================================================================

create table if not exists public.plan_bitis_hatirlatmalari (
  subscription_id uuid not null references public.subscriptions (id) on delete cascade,
  gun             integer not null check (gun in (30, 7, 1)),
  created_at      timestamptz not null default now(),
  primary key (subscription_id, gun)
);

alter table public.plan_bitis_hatirlatmalari enable row level security;
revoke all on public.plan_bitis_hatirlatmalari from public, anon, authenticated;

-- Türkçe tarih ("12 Aralık 2026"); lc_time'a bağlı kalmamak için ay adları elle.
create or replace function public._tr_tarih(p_zaman timestamptz)
returns text
language sql
immutable
set search_path = ''
as $$
  select extract(day from (p_zaman at time zone 'Europe/Istanbul'))::int::text || ' ' ||
         (array['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran','Temmuz','Ağustos',
                'Eylül','Ekim','Kasım','Aralık'])[extract(month from (p_zaman at time zone 'Europe/Istanbul'))::int]
         || ' ' || extract(year from (p_zaman at time zone 'Europe/Istanbul'))::int::text;
$$;

create or replace function public.plan_bitis_hatirlatmalarini_gonder(p_simdi timestamptz default now())
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  r       record;
  v_tarih text;
  v_bas   text;
  v_mesaj text;
  v_say   integer := 0;
begin
  for r in
    select s.id, s.veli_id, s.bitis, p.ad as plan_adi, g.gun
      from public.subscriptions s
      join public.plans p on p.kod = s.plan_kod
     cross join (values (30), (7), (1)) as g(gun)
     where s.durum = 'aktif'
       and p.fiyat_kurus > 0
       and coalesce(s.saglayici, 'manuel') in ('iyzico', 'paytr', 'param', 'manuel')
       and s.bitis >  p_simdi + make_interval(days => g.gun - 1)
       and s.bitis <= p_simdi + make_interval(days => g.gun)
       and s.bitis - s.baslangic >= make_interval(days => g.gun * 2)
       and not exists (
             select 1 from public.subscriptions s2
              where s2.veli_id = s.veli_id
                and s2.id <> s.id
                and s2.durum in ('aktif', 'beklemede')
                and s2.bitis > s.bitis)
       and not exists (
             select 1 from public.plan_bitis_hatirlatmalari h
              where h.subscription_id = s.id and h.gun = g.gun)
  loop
    -- Önce kayıt: aynı anda iki çalıştırma olursa yalnız biri gönderir.
    insert into public.plan_bitis_hatirlatmalari (subscription_id, gun)
    values (r.id, r.gun)
    on conflict do nothing;
    if not found then
      continue;
    end if;

    v_tarih := public._tr_tarih(r.bitis);
    if r.gun = 30 then
      v_bas   := 'Planınız ' || v_tarih || ' tarihinde bitiyor';
      v_mesaj := r.plan_adi || ' planınız ' || v_tarih || ' tarihinde sona erecek. '
              || 'Kendiliğinden yenilenmez, otomatik ücret alınmaz. '
              || 'Devam etmek isterseniz veli panelinden yapabilirsiniz. '
              || 'Ardından ücretsiz plan başlar; ilerleme korunur.';
    elsif r.gun = 7 then
      v_bas   := 'Planınız 7 gün sonra, ' || v_tarih || ' tarihinde bitiyor';
      v_mesaj := r.plan_adi || ' planınız ' || v_tarih || ' tarihinde sona erecek. '
              || 'Kendiliğinden yenilenmez, otomatik ücret alınmaz. '
              || 'Devam için veli panelini kullanabilirsiniz. '
              || 'Ardından ücretsiz plan başlar; ilerleme korunur.';
    else
      v_bas   := 'Planınız yarın, ' || v_tarih || ' tarihinde bitiyor';
      v_mesaj := r.plan_adi || ' planınız yarın (' || v_tarih || ') sona eriyor. '
              || 'Kendiliğinden yenilenmez, otomatik ücret alınmaz. '
              || 'Dilerseniz veli panelinden devam edebilirsiniz. '
              || 'Sonra ücretsiz plana geçilir; ilerleme korunur.';
    end if;

    perform public.bildirim_gonder(r.veli_id, v_bas, v_mesaj, true);
    v_say := v_say + 1;
  end loop;

  return v_say;
end;
$$;

revoke execute on function public._tr_tarih(timestamptz) from public, anon, authenticated;
revoke execute on function public.plan_bitis_hatirlatmalarini_gonder(timestamptz) from public, anon, authenticated;

-- Günlük zamanlayıcı (pg_cron yoksa — ör. yerel PGlite testi — atlanır).
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    if not exists (select 1 from cron.job where jobname = 'plan-bitis-hatirlatma') then
      perform cron.schedule(
        'plan-bitis-hatirlatma',
        '0 7 * * *',
        $job$ select public.plan_bitis_hatirlatmalarini_gonder(); $job$
      );
    end if;
  end if;
end
$$;

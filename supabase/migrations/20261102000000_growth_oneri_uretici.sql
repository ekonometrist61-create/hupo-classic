set client_encoding = 'UTF8';

-- =====================================================================
--  Growth kural tabanlı öneri üreticisi (P5 / E5) — LLM YOK
--  Tarih : 2026-10-27
--  Plan  : docs/growth-crm/ILETISIM_EKSIKLERI_PLANI_2026-10-27.md (P5)
--  Ön koşul: 20261014000000_growth_crm_core.sql   (growth_households, growth_events,
--            growth_ai_recommendations, growth_message_log, growth_financial_transactions,
--            growth_subscription_projection)
--            20261027000000_musteri_360_veri_toplama.sql (growth_consent_bridge birleşik hâli)
--            subscriptions, plans, deneme_donemleri (core)
--
--  NE EKLİYOR?
--    growth_oneri_ayar    : tek satırlık bayrak tablosu (aktif varsayılan KAPALI)
--    growth_oneri_uret(p) : dört kuralı çalıştırır, yeni önerileri growth_ai_recommendations'a yazar
--    pg_cron              : her gün 06:00 UTC (bayrak kapalıysa fonksiyon 0 döner)
--
--  KURALLAR (her öneri açıklanabilir 'reason' metni taşır)
--    deneme_bitiyor : 14 günlük denemenin bitişine <= 3 gün kaldı
--                     (core deneme_donemleri, yoksa core ücretsiz aktif abonelik, yoksa CRM projeksiyonu)
--    pasif_aile     : core hesaplı hane, son etkinlik >= 7 gün önce
--                     (etkinlik = hesap son görülme, veli paneli, çocuğun son öğrenme günü,
--                      web/uygulama olayları; sunucu olayları sayılmaz)
--    odeme_sorunu   : son 30 günde başarısız ödeme ve sonrasında başarılı ödeme yok
--                     VEYA son 30 günde biten ücretli abonelik (yeni ücretli abonelik yoksa)
--    ilk_temas      : en az bir kanalda iletişim izni var, hesap aktif, hiç gönderilmiş mesaj yok
--
--  GÜVENLİK ve KURALLAR
--    * Yalnız service_role çağırır. security definer + set search_path = ''.
--    * Öneri yalnız KAYITTIR: mesaj göndermez, growth_message_log'a yazmaz.
--    * Gerekçe metni çocuk kimlik bilgisi (ad, konum, fotoğraf), e-posta veya telefon içermez.
--    * Açık (pending) öneri olan hane+tür için yeni öneri üretilmez (idempotent).
--    * p_limit: her kural için bir çalıştırmada en fazla bu kadar YENİ öneri (1-1000).
--    * Kapsam dışı: LLM, puan/sınav garantisi, sosyal kanıt metni.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Bayrak (tek satır). Varsayılan KAPALI: açmak için yalnız service_role
--    tarafında: update public.growth_oneri_ayar set aktif = true where id;
-- ---------------------------------------------------------------------
create table if not exists public.growth_oneri_ayar (
  id           boolean primary key default true check (id),
  aktif        boolean not null default false,
  guncelleme   timestamptz not null default now(),
  guncelleyen  text
);

insert into public.growth_oneri_ayar (id, aktif) values (true, false)
on conflict (id) do nothing;

alter table public.growth_oneri_ayar enable row level security;
revoke all on table public.growth_oneri_ayar from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Açık öneri benzersizliği: aynı hane + tür için yalnız bir bekleyen öneri.
--    (Önce tekrar eden bekleyen satır varsa indeks oluşturulamaz; yeni tabloda yazar yoktu.)
-- ---------------------------------------------------------------------
create unique index if not exists growth_ai_oneri_acik_uq
  on public.growth_ai_recommendations (household_id, recommendation_type)
  where status = 'pending';

-- ---------------------------------------------------------------------
-- 3. Üretici
-- ---------------------------------------------------------------------
create or replace function public.growth_oneri_uret(p_limit int default 200)
returns int
language plpgsql
security definer
set search_path = ''
as $f$
declare
  v_limit int := least(greatest(coalesce(p_limit, 200), 1), 1000);
  v_aktif boolean;
  v_n     int;
begin
  -- Bayrak kapalıysa hiçbir şey üretilmez.
  select a.aktif into v_aktif from public.growth_oneri_ayar a where a.id;
  if not coalesce(v_aktif, false) then
    return 0;
  end if;

  with s as (
    select
      h.id,
      h.core_parent_user_id as veli_id,
      h.account_status,
      h.plan in ('premium', 'family') as ucretli,
      -- Deneme bitişi: core deneme kaydı -> core ücretsiz (fiyat 0) aktif abonelik -> CRM projeksiyonu
      coalesce(
        (select max(d.bitis) from public.deneme_donemleri d
          where d.veli_id = h.core_parent_user_id and d.bitis > now()),
        (select max(sb.bitis) from public.subscriptions sb
           join public.plans pl on pl.kod = sb.plan_kod
          where sb.veli_id = h.core_parent_user_id and sb.durum = 'aktif'
            and pl.fiyat_kurus = 0 and sb.bitis > now()),
        (select max(sp.trial_ends_at) from public.growth_subscription_projection sp
          where sp.household_id = h.id and sp.status = 'trial' and sp.trial_ends_at > now())
      ) as deneme_bitis,
      -- Son etkinlik: hesap son görülme, veli paneli, çocuğun son öğrenme günü
      -- (student_stats.last_active_date; XP/seri kaydı tarafından yazılır), web/uygulama olayları.
      -- Sunucu olayları (hesap oluşturma vb.) etkinlik sayılmaz.
      greatest(
        h.last_seen_at,
        h.last_parent_dashboard_at,
        (select max(ss.last_active_date)::timestamp at time zone 'Europe/Istanbul'
           from public.student_stats ss
           join public.profiles p on p.id = ss.student_id
          where p.parent_id = h.core_parent_user_id and p.role = 'ogrenci'),
        (select max(e.occurred_at) from public.growth_events e
          where e.household_id = h.id and e.source in ('web', 'app'))
      ) as son_etkinlik,
      -- Son 30 günde başarısız ödemeler; sonrasında başarılı ödeme yoksa
      (select count(*)::int from public.growth_financial_transactions t
        where t.household_id = h.id and t.status = 'failed'
          and t.occurred_at >= now() - interval '30 days'
          and not exists (select 1 from public.growth_financial_transactions ok
                           where ok.household_id = h.id and ok.status = 'paid'
                             and ok.occurred_at > t.occurred_at)) as basarisiz_odeme,
      -- Yeni ücretli aktif abonelik yoksa, son 30 günde biten ücretli abonelik bitiş tarihi
      case when exists (select 1 from public.subscriptions sb
                          join public.plans pl on pl.kod = sb.plan_kod
                         where sb.veli_id = h.core_parent_user_id and sb.durum = 'aktif'
                           and pl.fiyat_kurus > 0 and sb.bitis > now())
           then null
           else coalesce(
             (select max(sb.bitis) from public.subscriptions sb
                join public.plans pl on pl.kod = sb.plan_kod
               where sb.veli_id = h.core_parent_user_id and sb.durum in ('aktif', 'suresi_doldu')
                 and pl.fiyat_kurus > 0 and sb.bitis <= now() and sb.bitis >= now() - interval '30 days'),
             (select max(sp.ends_at) from public.growth_subscription_projection sp
               where sp.household_id = h.id and sp.status = 'expired'
                 and sp.plan in ('premium', 'family')
                 and sp.ends_at <= now() and sp.ends_at >= now() - interval '30 days'))
      end as abonelik_bitis,
      -- İzin verilmiş kanallar (growth_consent_bridge: core iletişim tercihleri + CRM izin tablosu)
      (select count(distinct b.channel)::int from public.growth_consent_bridge b
        where b.household_id = h.id and b.granted
          and b.channel in ('email', 'sms', 'phone', 'push', 'in_app')) as izinli_kanal_sayisi,
      (select coalesce(string_agg(k.ad, ', ' order by k.sira), '') from (
          select distinct b.channel,
                 case b.channel when 'email' then 'e-posta' when 'sms' then 'SMS'
                   when 'phone' then 'telefon' when 'push' then 'push bildirimi'
                   when 'in_app' then 'uygulama içi' end as ad,
                 case b.channel when 'email' then 1 when 'sms' then 2 when 'phone' then 3
                   when 'push' then 4 else 5 end as sira
            from public.growth_consent_bridge b
           where b.household_id = h.id and b.granted
             and b.channel in ('email', 'sms', 'phone', 'push', 'in_app')
        ) k) as izinli_kanallar,
      -- Gönderilmiş mesaj sayısı (growth_message_log yazıcısı P3'te; burada yalnız okunur)
      (select count(*)::int from public.growth_message_log m
        where m.household_id = h.id and m.sent_at is not null) as gonderilen_mesaj
    from public.growth_households h
    where h.account_status is distinct from 'blocked'
  )
  insert into public.growth_ai_recommendations
    (household_id, agent_name, recommendation_type, title, reason, proposed_action, risk_level, requires_approval, status)
  select u.* from (
    -- Kural 1: deneme bitimine <= 3 gün
    (select s.id, 'kural_motoru', 'deneme_bitiyor', 'Deneme süresi bitmek üzere',
            'Deneme süresinin bitmesine '
              || greatest(1, ceil(extract(epoch from (s.deneme_bitis - now())) / 86400))::int
              || ' gün kaldı (bitiş: ' || to_char(s.deneme_bitis at time zone 'Europe/Istanbul', 'DD.MM.YYYY')
              || '). Plan seçeneklerini anlatmak için uygun bir zaman.',
            jsonb_build_object('kural', 'deneme_bitiyor', 'eylem', 'incele', 'mesaj_gonderilir', false),
            'medium', true, 'pending'
       from s
      where s.deneme_bitis is not null
        and s.deneme_bitis > now() and s.deneme_bitis <= now() + interval '3 days'
        and not s.ucretli
        and not exists (select 1 from public.growth_ai_recommendations r
                         where r.household_id = s.id and r.recommendation_type = 'deneme_bitiyor'
                           and r.status = 'pending')
      order by s.id
      limit v_limit)
    union all
    -- Kural 2: core hesap, 7+ gün etkinlik yok
    (select s.id, 'kural_motoru', 'pasif_aile', 'Uzun süredir etkinlik yok',
            'Son ' || floor(extract(epoch from (now() - s.son_etkinlik)) / 86400)::int
              || ' gündür çocuğun öğrenme veya hesap etkinliği kaydı yok (son etkinlik: '
              || to_char(s.son_etkinlik at time zone 'Europe/Istanbul', 'DD.MM.YYYY') || ').',
            jsonb_build_object('kural', 'pasif_aile', 'eylem', 'incele', 'mesaj_gonderilir', false),
            'low', true, 'pending'
       from s
      where s.veli_id is not null
        and s.son_etkinlik <= now() - interval '7 days'
        and not exists (select 1 from public.growth_ai_recommendations r
                         where r.household_id = s.id and r.recommendation_type = 'pasif_aile'
                           and r.status = 'pending')
      order by s.id
      limit v_limit)
    union all
    -- Kural 3: başarısız ödeme veya yeni tarihte biten ücretli abonelik
    (select s.id, 'kural_motoru', 'odeme_sorunu', 'Ödeme veya abonelik sorunu',
            concat_ws(' ',
              case when s.basarisiz_odeme > 0
                   then 'Son 30 günde ' || s.basarisiz_odeme
                        || ' başarısız ödeme var ve bunlardan sonra başarılı bir ödeme kaydı yok.' end,
              case when s.abonelik_bitis is not null
                   then 'Ücretli abonelik ' || to_char(s.abonelik_bitis at time zone 'Europe/Istanbul', 'DD.MM.YYYY')
                        || ' tarihinde sona erdi.' end),
            jsonb_build_object('kural', 'odeme_sorunu', 'eylem', 'incele', 'mesaj_gonderilir', false),
            'medium', true, 'pending'
       from s
      where (s.basarisiz_odeme > 0 or s.abonelik_bitis is not null)
        and not exists (select 1 from public.growth_ai_recommendations r
                         where r.household_id = s.id and r.recommendation_type = 'odeme_sorunu'
                           and r.status = 'pending')
      order by s.id
      limit v_limit)
    union all
    -- Kural 4: izin var, hesap aktif, hiç gönderilmiş mesaj yok
    (select s.id, 'kural_motoru', 'ilk_temas', 'İlk iletişim bekleniyor',
            s.izinli_kanal_sayisi || ' kanalda (' || s.izinli_kanallar
              || ') iletişim izni var; bu aileye kayıtlı bir mesaj gönderimi yok.',
            jsonb_build_object('kural', 'ilk_temas', 'eylem', 'incele', 'mesaj_gonderilir', false),
            'low', true, 'pending'
       from s
      where s.account_status = 'active'
        and s.izinli_kanal_sayisi > 0
        and s.gonderilen_mesaj = 0
        and not exists (select 1 from public.growth_ai_recommendations r
                         where r.household_id = s.id and r.recommendation_type = 'ilk_temas'
                           and r.status = 'pending')
      order by s.id
      limit v_limit)
  ) u
  on conflict (household_id, recommendation_type) where status = 'pending' do nothing;

  get diagnostics v_n = row_count;
  return v_n;
end;
$f$;

-- ---------------------------------------------------------------------
-- 4. Yetkiler: yalnız service_role
-- ---------------------------------------------------------------------
revoke execute on function public.growth_oneri_uret(int) from public, anon, authenticated;
grant  execute on function public.growth_oneri_uret(int) to service_role;

-- ---------------------------------------------------------------------
-- 5. Zamanlayıcı: her gün 06:00 UTC (pg_cron; bayrak kapalıysa 0 döner)
-- ---------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from cron.job where jobname = 'growth-oneri-uret') then
    perform cron.schedule('growth-oneri-uret', '0 6 * * *', 'select public.growth_oneri_uret(200)');
  end if;
end
$$;

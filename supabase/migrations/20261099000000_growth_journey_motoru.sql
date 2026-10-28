set client_encoding = 'UTF8';

-- =====================================================================
--  Growth journey motoru (P2 / W9 entegrasyonu)
--  Tarih : 2026-10-27
--  Ön koşul: 20261014000000_growth_crm_core.sql      (growth_journey*, growth_message_log,
--                                                     growth_consent_bridge, growth_events)
--            20261015000000_iletisim_izni_kayit_ve_iptal.sql (ticari_iletisim_engelli_mi)
--            20261101000000_growth_iletisim_uygunluk.sql     (growth_iletisim_uygun_mu)
--            20261100000000_growth_mesaj_gunlugu.sql         (status 'engellendi')
--            20261042000000_veli_cocuk_bildirim.sql          (eposta_outbox)
--            20261110000000_growth_entegrasyon_seed.sql      (seed + gönderim RPC'leri)
--
--  NE EKLİYOR?
--    şema     : growth_journey_enrollments.error, growth_message_log.journey_step_id,
--               growth_journeys.giris_kosulu (otomatik giriş kuralı),
--               eposta_outbox: alici_id boş olabilir; growth_household_id, growth_message_id,
--               sablon_anahtar (growth kökenli satırlar; adres gönderimde hane kaydından okunur)
--    tablo    : growth_motor_ayarlari (bayraklar; varsayılan KAPALI)
--    RPC      : growth_journey_giris_al(journey, hane)  -- elle giriş (service_role)
--               growth_journey_ilerlet(p_limit)         -- cron (service_role)
--    iç       : _growth_otomatik_giris, _growth_cikis_nedeni, _growth_mesaj_engelle
--    cron     : growth-journey-ilerlet, her 5 dakika (otomatik giriş + adım işleyici)
--
--  KURALLAR
--    * Bayrak growth_journey_motoru_acik kapalıyken ne giriş ne adım işlenir; hiçbir satır yazılmaz.
--    * İzin tek tanımdır: pazarlama kapısı growth_iletisim_uygun_mu (20261101) -> _growth_izin_var_mi.
--      E-posta adımı önce bu kapıdan geçer:
--        uygun              -> growth_message_log 'kuyrukta' + eposta_outbox satırı (sablon anahtarı).
--                              Metin gönderimde growth_templates'ten render edilir (eposta-gonder).
--        neden sessiz_saat  -> adım aynı kalır; kayıt 'waiting', next_run_at = sonraki uygun an.
--                              Günlük satırı yazılmaz (mesaj henüz ertelendi, gönderilmedi).
--        neden izin_yok veya siklik_siniri -> growth_message_log 'engellendi' (error = neden kodu);
--                              adım ilerler (yeniden denenmez).
--    * SMS ve WhatsApp: 'engellendi' + 'kanal_kapali' (hukuk kararı GÖR-018/019).
--      Push ve uygulama içi: 'engellendi' + 'kanal_desteklenmiyor' (bu kanalların tüketicisi yok).
--    * Çıkış koşulları (journey.exit_conditions) her adımdan önce değerlendirilir; biri sağlanırsa
--      kayıt 'exited' olur ve metadata.cikis_nedeni yazılır.
--    * Motor doğrudan mesaj göndermez; gönderim eposta-gonder (edge) tarafındadır.
--    * Yetki: tüm fonksiyonlar security definer + set search_path = ''. Yalnız service_role.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Şema eklemeleri (additive; mevcut satırlar bozulmaz)
-- ---------------------------------------------------------------------
alter table public.growth_journey_enrollments
  add column if not exists error text;

alter table public.growth_message_log
  add column if not exists journey_step_id uuid references public.growth_journey_steps (id) on delete set null;

alter table public.growth_journeys
  add column if not exists giris_kosulu jsonb not null default '{}'::jsonb;

-- Aynı journey + hane için en fazla bir aktif kayıt (eşzamanlı girişe karşı da).
create unique index if not exists growth_journey_aktif_kayit_uq
  on public.growth_journey_enrollments (journey_id, household_id)
  where status in ('active', 'waiting');

-- E-posta kuyruğu: growth kökenli satırlar. Adres hane kaydından okunur (alici_id yok).
alter table public.eposta_outbox
  alter column alici_id drop not null;

alter table public.eposta_outbox
  add column if not exists growth_household_id uuid references public.growth_households (id) on delete set null,
  add column if not exists growth_message_id   uuid references public.growth_message_log (id) on delete set null,
  add column if not exists sablon_anahtar      text;

do $$
begin
  if not exists (
    select 1 from pg_constraint
     where conname = 'eposta_outbox_alici_kaynak_chk'
       and conrelid = 'public.eposta_outbox'::regclass
  ) then
    alter table public.eposta_outbox
      add constraint eposta_outbox_alici_kaynak_chk
      check (alici_id is not null or growth_household_id is not null);
  end if;
end $$;

-- Eski yardımcı kaldırılır: izin tek tanımda (_growth_izin_var_mi, 20261101) okunur.
drop function if exists public._growth_mesaj_izni(uuid, text);

-- ---------------------------------------------------------------------
-- 1. Motor bayrakları
-- ---------------------------------------------------------------------
create table if not exists public.growth_motor_ayarlari (
  anahtar    text primary key,
  deger      boolean not null default false,
  updated_by uuid references public.profiles (id) on delete set null,
  updated_at timestamptz not null default now()
);

-- on conflict do nothing: yeniden çalıştırma açılmış bir bayrağı kapatmaz.
insert into public.growth_motor_ayarlari (anahtar, deger)
values ('growth_journey_motoru_acik', false)
on conflict (anahtar) do nothing;

alter table public.growth_motor_ayarlari enable row level security;
revoke all on table public.growth_motor_ayarlari from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Engel kaydı: 'engellendi' günlük satırı (iç kullanım)
-- ---------------------------------------------------------------------
create or replace function public._growth_mesaj_engelle(
  p_household uuid,
  p_journey   uuid,
  p_step      uuid,
  p_channel   text,
  p_neden     text,
  p_snapshot  jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id uuid;
begin
  insert into public.growth_message_log
    (household_id, journey_id, journey_step_id, channel, status, consent_snapshot, error)
  values
    (p_household, p_journey, p_step, p_channel, 'engellendi',
     coalesce(p_snapshot, '{}'::jsonb), left(p_neden, 500))
  returning id into v_id;
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. Kayıt: hane bir journey'e girer (service_role; elle)
--    * Journey 'active' olmalı; hane 'blocked' olmamalı.
--    * Aynı journey için aktif (active/waiting) kayıt varsa mevcut id döner, yenisi açılmaz.
--    * İlk adım varsa current_step_id ona, next_run_at şimdiye ayarlanır.
-- ---------------------------------------------------------------------
create or replace function public.growth_journey_giris_al(p_journey_id uuid, p_household_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_durum     public.growth_journey_status;
  v_hane_durm text;
  v_mevcut    uuid;
  v_ilk_adim  uuid;
  v_id        uuid;
begin
  if p_journey_id is null or p_household_id is null then
    raise exception 'Journey ve hane kimliği zorunlu.' using errcode = '22023';
  end if;

  select j.status into v_durum
    from public.growth_journeys j
   where j.id = p_journey_id;
  if v_durum is distinct from 'active' then
    raise exception 'Journey aktif değil.' using errcode = '22023';
  end if;

  select h.account_status into v_hane_durm
    from public.growth_households h
   where h.id = p_household_id;
  if not found or v_hane_durm is not distinct from 'blocked' then
    raise exception 'Hane bu journey için uygun değil.' using errcode = '22023';
  end if;

  select e.id into v_mevcut
    from public.growth_journey_enrollments e
   where e.journey_id = p_journey_id
     and e.household_id = p_household_id
     and e.status in ('active', 'waiting')
   limit 1;
  if v_mevcut is not null then
    return v_mevcut;
  end if;

  select s.id into v_ilk_adim
    from public.growth_journey_steps s
   where s.journey_id = p_journey_id
   order by s.position
   limit 1;

  insert into public.growth_journey_enrollments
    (journey_id, household_id, current_step_id, status, next_run_at)
  values
    (p_journey_id, p_household_id, v_ilk_adim, 'active', now())
  returning id into v_id;

  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. Çıkış koşulu: hangi koşul sağlandıysa neden kodu, yoksa null
--    Anahtarlar (journey.exit_conditions; hepsi isteğe bağlı true):
--      satin_alma   : hane ücretli plana geçti (plan premium/family)
--      izin_iptal   : e-posta izni kaldırıldı veya adres bastırıldı
--      cocuk_bagli  : veli hesabına öğrenci (çocuk) bağlandı
--      dogrulandi   : veli e-posta adresini doğruladı
--      geri_dondu   : kayıt girişinden sonra hane etkinlik gösterdi
-- ---------------------------------------------------------------------
create or replace function public._growth_cikis_nedeni(
  p_household_id uuid,
  p_entered_at   timestamptz,
  p_kosul        jsonb
)
returns text
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  h        public.growth_households%rowtype;
  v_kosul  jsonb := coalesce(p_kosul, '{}'::jsonb);
begin
  select * into h from public.growth_households where id = p_household_id;
  if not found then
    return null;
  end if;

  if coalesce((v_kosul ->> 'satin_alma')::boolean, false) and h.plan in ('premium', 'family') then
    return 'satin_alma';
  end if;

  if coalesce((v_kosul ->> 'izin_iptal')::boolean, false) and (
       exists (select 1 from public.growth_consent_bridge b
                where b.household_id = h.id and b.channel = 'email' and not b.granted)
    or coalesce(public.ticari_iletisim_engelli_mi(h.email), false)
  ) then
    return 'izin_iptal';
  end if;

  if coalesce((v_kosul ->> 'cocuk_bagli')::boolean, false)
     and h.core_parent_user_id is not null
     and exists (select 1 from public.profiles p
                  where p.parent_id = h.core_parent_user_id and p.role = 'ogrenci') then
    return 'cocuk_bagli';
  end if;

  if coalesce((v_kosul ->> 'dogrulandi')::boolean, false)
     and h.core_parent_user_id is not null
     and exists (select 1 from auth.users u
                  where u.id = h.core_parent_user_id and u.email_confirmed_at is not null) then
    return 'dogrulandi';
  end if;

  if coalesce((v_kosul ->> 'geri_dondu')::boolean, false)
     and greatest(h.last_seen_at, h.last_parent_dashboard_at) > p_entered_at then
    return 'geri_dondu';
  end if;

  return null;
end;
$function$;

-- ---------------------------------------------------------------------
-- 5. Otomatik giriş: journey.giris_kosulu ile eşleşen ve bu journey'e HİÇ girmemiş
--    haneleri kaydeder (tek seferlik: çıkan/biten kayıt sonrası yeniden giriş yok).
--    Tipler:
--      olay         : growth_events'te son N saatte {olay} kaydı (ör. hesap_olusturuldu)
--      deneme_bitis : CRM projeksiyonunda trial; bitişe kalan_gun gün veya daha az
--      dogrulanmamis: veli hesabı e-postasını doğrulamamış; hesap min_saat..max_saat yaşında
--      pasif        : son etkinlik min_gun..max_gun gün önce (core hesabı olan haneler)
-- ---------------------------------------------------------------------
create or replace function public._growth_otomatik_giris(p_limit int)
returns int
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_j     record;
  v_h     record;
  v_k     jsonb;
  v_tip   text;
  v_ilk   uuid;
  v_say   int := 0;
begin
  for v_j in
    select j.id, j.giris_kosulu
      from public.growth_journeys j
     where j.status = 'active'
       and j.giris_kosulu <> '{}'::jsonb
     order by j.created_at, j.id
  loop
    exit when v_say >= p_limit;

    v_k   := v_j.giris_kosulu;
    v_tip := v_k ->> 'tip';

    select s.id into v_ilk
      from public.growth_journey_steps s
     where s.journey_id = v_j.id
     order by s.position
     limit 1;
    continue when v_ilk is null;

    for v_h in
      select h.id
        from public.growth_households h
       where h.account_status is distinct from 'blocked'
         and not exists (select 1 from public.growth_journey_enrollments e
                          where e.journey_id = v_j.id and e.household_id = h.id)
         and (
              (v_tip = 'olay' and exists (
                 select 1 from public.growth_events ev
                  where ev.household_id = h.id
                    and ev.event_name = v_k ->> 'olay'
                    and ev.occurred_at >= now() - make_interval(hours => coalesce((v_k ->> 'son_saat')::int, 24))))
           or (v_tip = 'deneme_bitis' and exists (
                 select 1 from public.growth_subscription_projection sp
                  where sp.household_id = h.id and sp.status = 'trial'
                    and sp.trial_ends_at > now()
                    and sp.trial_ends_at <= now() + make_interval(days => coalesce((v_k ->> 'kalan_gun')::int, 3))))
           or (v_tip = 'dogrulanmamis'
                 and h.core_parent_user_id is not null
                 and exists (select 1 from auth.users u
                              where u.id = h.core_parent_user_id and u.email_confirmed_at is null)
                 and h.created_at <= now() - make_interval(hours => coalesce((v_k ->> 'min_saat')::int, 24))
                 and h.created_at >  now() - make_interval(hours => coalesce((v_k ->> 'max_saat')::int, 72)))
           or (v_tip = 'pasif'
                 and h.core_parent_user_id is not null
                 and greatest(h.last_seen_at, h.last_parent_dashboard_at)
                       <= now() - make_interval(days => coalesce((v_k ->> 'min_gun')::int, 7))
                 and greatest(h.last_seen_at, h.last_parent_dashboard_at)
                       >  now() - make_interval(days => coalesce((v_k ->> 'max_gun')::int, 30)))
         )
       order by h.created_at, h.id
       limit (p_limit - v_say)
    loop
      insert into public.growth_journey_enrollments
        (journey_id, household_id, current_step_id, status, next_run_at)
      values
        (v_j.id, v_h.id, v_ilk, 'active', now());
      v_say := v_say + 1;
    end loop;
  end loop;

  return v_say;
end;
$function$;

-- ---------------------------------------------------------------------
-- 6. İlerletici: vadesi gelen kayıtların mevcut adımını işler (service_role, pg_cron)
--    Adım tipleri:
--      trigger          : geçiş, iş yok
--      delay            : config.saat kadar bekler (status 'waiting')
--      email            : pazarlama kapısı -> kuyrukta | ertele (sessiz saat) | engellendi
--      sms/whatsapp     : 'engellendi' + kanal_kapali
--      push/in_app      : 'engellendi' + kanal_desteklenmiyor
--      diğerleri        : kayıt 'failed', error alanı nedeni tutar
--    Her çalıştırmada kayıt başına bir adım işlenir. Hata bir kaydı 'failed' yapar;
--    diğer kayıtlar etkilenmez (kayıt başına savepoint).
-- ---------------------------------------------------------------------
create or replace function public.growth_journey_ilerlet(p_limit int default 50)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_limit      int := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_kayit      record;
  v_adim       public.growth_journey_steps%rowtype;
  v_sonraki    public.growth_journey_steps%rowtype;
  v_gate       jsonb;
  v_neden      text;
  v_cikis      text;
  v_saat       numeric;
  v_sablon     text;
  v_konu       text;
  v_govde      text;
  v_msg_id     uuid;
  v_yeni_adim  uuid;
  v_yeni_durum text;
  v_yeni_at    timestamptz;
  v_giris      int;
  v_islenen    int := 0;
  v_cikis_say  int := 0;
  v_kuyruk     int := 0;
  v_engel      int := 0;
  v_ertele     int := 0;
  v_bekleme    int := 0;
  v_tamam      int := 0;
  v_hata       int := 0;
begin
  -- Bayrak kapalıysa hiçbir satıra dokunulmaz (giriş dahil).
  if not coalesce((select a.deger
                     from public.growth_motor_ayarlari a
                    where a.anahtar = 'growth_journey_motoru_acik'), false) then
    return jsonb_build_object('motor', 'kapali', 'islenen', 0);
  end if;

  v_giris := public._growth_otomatik_giris(v_limit);

  for v_kayit in
    select e.id, e.journey_id, e.household_id, e.current_step_id, e.entered_at,
           j.exit_conditions as kosul
      from public.growth_journey_enrollments e
      join public.growth_journeys j on j.id = e.journey_id
     where e.status in ('active', 'waiting')
       and j.status = 'active'
       and e.next_run_at <= now()
     order by e.next_run_at, e.id
     limit v_limit
       for update of e skip locked
  loop
    v_islenen := v_islenen + 1;
    begin
      select s.* into v_adim
        from public.growth_journey_steps s
       where s.id = v_kayit.current_step_id;

      -- Çıkış koşulu sağlandıysa kayıt biter; adım işlenmez.
      v_cikis := public._growth_cikis_nedeni(v_kayit.household_id, v_kayit.entered_at, v_kayit.kosul);
      if v_cikis is not null then
        update public.growth_journey_enrollments e
           set status       = 'exited',
               next_run_at  = null,
               completed_at = now(),
               error        = null,
               metadata     = e.metadata || jsonb_build_object('cikis_nedeni', v_cikis)
         where e.id = v_kayit.id;
        v_cikis_say := v_cikis_say + 1;
        continue;
      end if;

      -- Adım yoksa (son adım geçildi) kayıt tamamlanır.
      v_yeni_adim  := null;
      v_yeni_durum := 'completed';
      v_yeni_at    := null;

      if v_adim.id is not null then
        select s.* into v_sonraki
          from public.growth_journey_steps s
         where s.journey_id = v_kayit.journey_id
           and s.position > v_adim.position
         order by s.position
         limit 1;

        v_yeni_adim  := v_sonraki.id;
        v_yeni_durum := case when v_sonraki.id is null then 'completed' else 'active' end;
        v_yeni_at    := now();

        if v_adim.step_type = 'trigger' then
          null;

        elsif v_adim.step_type = 'delay' then
          v_saat := nullif(v_adim.config ->> 'saat', '')::numeric;
          if v_saat is null or v_saat < 0 or v_saat > 8760 then
            raise exception 'Bekleme adımı geçersiz: saat 0-8760 arası olmalı.' using errcode = '22023';
          end if;
          v_bekleme := v_bekleme + 1;
          if v_sonraki.id is not null then
            v_yeni_durum := 'waiting';
            v_yeni_at    := now() + make_interval(mins => round(v_saat * 60)::int);
          end if;

        elsif v_adim.step_type = 'email' then
          v_sablon := nullif(btrim(coalesce(v_adim.config ->> 'sablon', '')), '');
          if v_sablon is null then
            raise exception 'E-posta adımında şablon anahtarı yok.' using errcode = '22023';
          end if;

          -- Pazarlama kapısı: izin + bastırma + sessiz saat + sıklık (tek tanım, 20261101).
          v_gate := public.growth_iletisim_uygun_mu(v_kayit.household_id, 'email', now());

          if coalesce((v_gate ->> 'uygun')::boolean, false) then
            select t.subject, t.body into v_konu, v_govde
              from public.growth_templates t
             where t.name = v_sablon
               and t.channel = 'email'
             order by t.version desc, t.created_at desc
             limit 1;
            if not found then
              raise exception 'E-posta şablonu bulunamadı: %', v_sablon using errcode = '22023';
            end if;

            insert into public.growth_message_log
              (household_id, journey_id, journey_step_id, channel, status, consent_snapshot)
            values
              (v_kayit.household_id, v_kayit.journey_id, v_adim.id, 'email', 'kuyrukta',
               jsonb_build_object('email', true, 'kontrol_at', now()))
            returning id into v_msg_id;

            -- Konu/gövde yalnız bilgi amaçlı ham kopyadır; gerçek metin gönderimde render edilir.
            insert into public.eposta_outbox
              (alici_id, konu, govde, growth_household_id, growth_message_id, sablon_anahtar)
            values
              (null,
               left(coalesce(v_konu, v_sablon), 200),
               left(coalesce(v_govde, v_sablon), 4000),
               v_kayit.household_id, v_msg_id, v_sablon);
            v_kuyruk := v_kuyruk + 1;

          elsif coalesce(v_gate ->> 'neden', '') = 'sessiz_saat' then
            -- Ertele: aynı adım, sonraki uygun an. Günlük satırı yazılmaz.
            v_yeni_adim  := v_adim.id;
            v_yeni_durum := 'waiting';
            v_yeni_at    := coalesce((v_gate ->> 'sonraki_uygun')::timestamptz, now() + interval '1 hour');
            v_ertele := v_ertele + 1;

          else
            -- izin_yok veya siklik_siniri: engellendi, adım ilerler.
            v_neden := coalesce(v_gate ->> 'neden', 'izin_yok');
            perform public._growth_mesaj_engelle(
              v_kayit.household_id, v_kayit.journey_id, v_adim.id, 'email', v_neden,
              jsonb_build_object('email', v_neden <> 'izin_yok', 'kontrol_at', now()));
            v_engel := v_engel + 1;
          end if;

        elsif v_adim.step_type in ('sms', 'whatsapp') then
          perform public._growth_mesaj_engelle(
            v_kayit.household_id, v_kayit.journey_id, v_adim.id, v_adim.step_type,
            'kanal_kapali', '{}'::jsonb);
          v_engel := v_engel + 1;

        elsif v_adim.step_type in ('push', 'in_app') then
          perform public._growth_mesaj_engelle(
            v_kayit.household_id, v_kayit.journey_id, v_adim.id, v_adim.step_type,
            'kanal_desteklenmiyor', '{}'::jsonb);
          v_engel := v_engel + 1;

        else
          raise exception 'Adım tipi desteklenmiyor: %', v_adim.step_type;
        end if;
      end if;

      if v_yeni_durum = 'completed' then
        v_yeni_at := null;
        v_tamam := v_tamam + 1;
      end if;

      update public.growth_journey_enrollments e
         set current_step_id = v_yeni_adim,
             status          = v_yeni_durum,
             next_run_at     = v_yeni_at,
             completed_at    = case when v_yeni_durum = 'completed' then now() else null end,
             error           = null
       where e.id = v_kayit.id;

    exception when others then
      update public.growth_journey_enrollments e
         set status      = 'failed',
             error       = left(sqlerrm, 500),
             next_run_at = null
       where e.id = v_kayit.id;
      v_hata := v_hata + 1;
    end;
  end loop;

  return jsonb_build_object(
    'motor',          'acik',
    'giris',          v_giris,
    'islenen',        v_islenen,
    'cikis',          v_cikis_say,
    'kuyruga_alindi', v_kuyruk,
    'ertelendi',      v_ertele,
    'engellendi',     v_engel,
    'bekleme',        v_bekleme,
    'tamamlandi',     v_tamam,
    'hata',           v_hata
  );
end;
$function$;

-- ---------------------------------------------------------------------
-- 7. Yetkiler: yalnız service_role
-- ---------------------------------------------------------------------
revoke execute on function public._growth_mesaj_engelle(uuid, uuid, uuid, text, text, jsonb)
  from public, anon, authenticated;
revoke execute on function public._growth_cikis_nedeni(uuid, timestamptz, jsonb)
  from public, anon, authenticated;
revoke execute on function public._growth_otomatik_giris(int)
  from public, anon, authenticated;

revoke execute on function public.growth_journey_giris_al(uuid, uuid)           from public, anon, authenticated;
grant  execute on function public.growth_journey_giris_al(uuid, uuid)           to service_role;

revoke execute on function public.growth_journey_ilerlet(int)                   from public, anon, authenticated;
grant  execute on function public.growth_journey_ilerlet(int)                   to service_role;

-- ---------------------------------------------------------------------
-- 8. Zamanlayıcı: 5 dakikada bir. Kapalılık bayrakla sağlanır (varsayılan KAPALI).
-- ---------------------------------------------------------------------
create extension if not exists pg_cron with schema pg_catalog;

do $$
begin
  if not exists (select 1 from cron.job where jobname = 'growth-journey-ilerlet') then
    perform cron.schedule('growth-journey-ilerlet', '*/5 * * * *', 'select public.growth_journey_ilerlet(50);');
  end if;
  if not exists (select 1 from cron.job where jobname = 'growth-journey-ilerlet') then
    raise exception 'growth-journey-ilerlet zamanlayıcısı kurulamadı';
  end if;
end $$;

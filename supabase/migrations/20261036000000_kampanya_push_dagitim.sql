-- =====================================================================
--  Pazarlama push kampanyaları: segment veya elle seçilen velilere dağıtım
--  Tarih : 2026-10-16
--  Ön koşul: 20261007000010 (iletisim_tercihleri), 20261007000020 (segmentler,
--            iletisim_kampanyalari, _segment_veliler, _sessiz_saat_mi),
--            20260920001000 (push), 20261035000000 (notifications kategori)
--
--  NE DEĞİŞİYOR?
--    * _segment_veliler : kriterlere "veli_idleri" (elle seçilen veli listesi) eklenir.
--                         Boş liste reddedilir; "herkese" anlamına GELMEZ.
--    * iletisim_kampanyalari.durum : 'gonderildi' eklenir.
--    * notifications    : pazarlama, kaynak_kampanya_id; kategori 'kampanya' eklenir.
--    * kampanya_push_gonder() : planlanan push kampanyasını, yalnızca hedef velilerin
--                         "push" iznine göre, kutuya + push kuyruğuna yazar. pg_cron her dakika.
--    * enqueue_push     : pazarlama satırı için ikinci onay kontrolü (iletisim izni 'push').
--
--  KURALLAR
--    * Alıcı yalnızca veli olur (_segment_veliler role='veli'). Öğrenci hesabına pazarlama gitmez.
--    * Alıcı, iletisim_tercihleri'nde kanal='push' için izin vermiş olmalıdır (kanal bazlı, varsayılan boş).
--    * Cihaz izni (push_preferences), veli rızası ve sessiz saat ayrıca uygulanır (push_allowed_now).
--    * Haftalık limit (iletisim_ayarlari.haftalik_limit) pazarlama kutusu kayıtlarına uygulanır.
--    * Boş kriterli segment pazarlama push'una gönderilmez (kampanya iptal edilir).
--    * Sessiz saatte dağıtım yapılmaz; kampanya iptal edilir (push kuralıyla aynı: ertelenmez).
--    * Kampanya dağıtımı tek seferliktir (kaynak_kampanya_id + alici_id benzersiz).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Veri kolonları ve kısıtlar
-- ---------------------------------------------------------------------
alter table public.iletisim_kampanyalari drop constraint if exists iletisim_kampanyalari_durum;
alter table public.iletisim_kampanyalari add constraint iletisim_kampanyalari_durum
  check (durum in ('taslak', 'kontrol_edildi', 'planlandi', 'gonderildi', 'iptal'));

alter table public.notifications
  add column if not exists pazarlama          boolean not null default false,
  add column if not exists kaynak_kampanya_id uuid references public.iletisim_kampanyalari (id) on delete set null;

alter table public.notifications drop constraint if exists notifications_kategori_check;
alter table public.notifications add constraint notifications_kategori_check
  check (kategori in ('sistem', 'akademik', 'duyuru', 'indirim', 'kampanya'));

create unique index if not exists notifications_iletisim_kampanyasi_tekil
  on public.notifications (kaynak_kampanya_id, alici_id)
  where kaynak_kampanya_id is not null;

-- ---------------------------------------------------------------------
-- 2. _segment_veliler: "veli_idleri" kriteri (elle seçilen liste)
--    Gövde 20261007000020 ile aynı; yalnızca bu kriter eklendi.
-- ---------------------------------------------------------------------
create or replace function public._segment_veliler(p_kriterler jsonb, p_kanal text default 'eposta')
returns table (r_veli_id uuid, r_ad text, r_izinli boolean)
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  k          jsonb := coalesce(p_kriterler, '{}'::jsonb);
  v_plan     text[];
  v_sinif    smallint[];
  v_idler    uuid[];
  v_aktiflik text := nullif(k ->> 'aktiflik', '');
  v_ilk      boolean := coalesce((k ->> 'ilk_gorev_bekleyen')::boolean, false);
  v_yen      boolean := coalesce((k ->> 'yenileme_yaklasan')::boolean, false);
begin
  if p_kanal not in ('eposta', 'push', 'sms', 'uygulama_ici') then
    raise exception 'Geçersiz kanal.' using errcode = '22023';
  end if;
  if jsonb_typeof(k) is distinct from 'object' then
    raise exception 'Kriterler nesne olmalı.' using errcode = '22023';
  end if;
  if exists (select 1 from jsonb_object_keys(k) kk
              where kk not in ('plan', 'sinif', 'aktiflik', 'ilk_gorev_bekleyen', 'yenileme_yaklasan', 'veli_idleri')) then
    raise exception 'Bilinmeyen segment kriteri.' using errcode = '22023';
  end if;
  if v_aktiflik is not null and v_aktiflik not in ('aktif_7', 'pasif_7', 'pasif_30') then
    raise exception 'Geçersiz aktiflik kriteri.' using errcode = '22023';
  end if;
  if (k ? 'plan' and jsonb_typeof(k -> 'plan') is distinct from 'array')
     or (k ? 'sinif' and jsonb_typeof(k -> 'sinif') is distinct from 'array')
     or (k ? 'veli_idleri' and jsonb_typeof(k -> 'veli_idleri') is distinct from 'array')
     or (k ? 'ilk_gorev_bekleyen' and jsonb_typeof(k -> 'ilk_gorev_bekleyen') is distinct from 'boolean')
     or (k ? 'yenileme_yaklasan' and jsonb_typeof(k -> 'yenileme_yaklasan') is distinct from 'boolean') then
    raise exception 'Segment kriteri tipleri geçersiz.' using errcode = '22023';
  end if;
  if jsonb_typeof(k -> 'plan') = 'array' then
    v_plan := array(select jsonb_array_elements_text(k -> 'plan'));
    if cardinality(v_plan) = 0 then v_plan := null; end if;
  end if;
  if jsonb_typeof(k -> 'sinif') = 'array' then
    if exists (select 1 from jsonb_array_elements_text(k -> 'sinif') e where e !~ '^(1[0-2]|[1-9])$') then
      raise exception 'Sınıf 1-12 arasında olmalı.' using errcode = '22023';
    end if;
    v_sinif := array(select (jsonb_array_elements_text(k -> 'sinif'))::smallint);
    if cardinality(v_sinif) = 0 then v_sinif := null; end if;
  end if;
  -- Elle seçilen liste: boş liste "herkes" değil, hata. Aşırı büyük liste de reddedilir.
  if jsonb_typeof(k -> 'veli_idleri') = 'array' then
    if jsonb_array_length(k -> 'veli_idleri') = 0 then
      raise exception 'Seçilen veli listesi boş olamaz.' using errcode = '22023';
    end if;
    if jsonb_array_length(k -> 'veli_idleri') > 1000 then
      raise exception 'Elle seçilen veli listesi en fazla 1000 kişi olabilir.' using errcode = '22023';
    end if;
    v_idler := array(select (jsonb_array_elements_text(k -> 'veli_idleri'))::uuid);
  end if;

  return query
  select p.id, p.full_name,
         exists (select 1 from public.iletisim_tercihleri t
                  where t.veli_id = p.id and t.kanal = p_kanal and t.izin)
    from public.profiles p
   where p.role = 'veli'
     and (v_idler is null or p.id = any (v_idler))
     and (v_plan is null
          or coalesce((select sb.plan_kod from public.subscriptions sb
                        where sb.veli_id = p.id and sb.durum = 'aktif' and sb.bitis > now()
                        order by sb.bitis desc limit 1), 'free') = any (v_plan))
     and (v_sinif is null
          or exists (select 1 from public.profiles c
                      where c.parent_id = p.id and c.sinif = any (v_sinif)))
     and (v_aktiflik is null
          or case v_aktiflik
               when 'aktif_7' then exists (
                 select 1 from public.profiles c join public.student_stats s on s.student_id = c.id
                  where c.parent_id = p.id and s.last_active_date >= current_date - 7)
               when 'pasif_7' then
                 exists (select 1 from public.profiles c where c.parent_id = p.id)
                 and not exists (
                   select 1 from public.profiles c join public.student_stats s on s.student_id = c.id
                    where c.parent_id = p.id and s.last_active_date >= current_date - 7)
               else
                 exists (select 1 from public.profiles c where c.parent_id = p.id)
                 and not exists (
                   select 1 from public.profiles c join public.student_stats s on s.student_id = c.id
                    where c.parent_id = p.id and s.last_active_date >= current_date - 30)
             end)
     and (not v_ilk
          or exists (select 1 from public.profiles c
                      where c.parent_id = p.id
                        and not exists (select 1 from public.user_answers ua where ua.student_id = c.id)))
     and (not v_yen
          or exists (select 1 from public.subscriptions sb
                      where sb.veli_id = p.id and sb.durum = 'aktif'
                        and sb.bitis between now() and now() + interval '7 days'));
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. enqueue_push: pazarlama satırı yalnızca "push" izni varsa kuyruğa girer
--    (20260920001000 gövdesi + bu koşul)
-- ---------------------------------------------------------------------
create or replace function public.enqueue_push()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if public.push_allowed_now(new.alici_id)
     and (
       not new.pazarlama
       or exists (
            select 1 from public.iletisim_tercihleri t
             where t.veli_id = new.alici_id and t.kanal = 'push' and t.izin)
     ) then
    insert into public.push_outbox (notification_id, user_id) values (new.id, new.alici_id);
  end if;
  return new;
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. Dağıtım: planlanmış push kampanyası → alıcıların kutusu + push kuyruğu
--    pg_cron her dakika çalıştırır. Döner: eklenen kutu kaydı sayısı.
-- ---------------------------------------------------------------------
create or replace function public.kampanya_push_gonder()
returns integer
language plpgsql
security definer
set search_path = ''
as $function$
declare
  c         public.iletisim_kampanyalari%rowtype;
  s         public.segmentler%rowtype;
  a         public.iletisim_ayarlari%rowtype;
  v_adet    integer := 0;
  v_satir   integer;
begin
  select * into a from public.iletisim_ayarlari where id;

  for c in
    select *
      from public.iletisim_kampanyalari
     where durum = 'planlandi'
       and kanal = 'push'
       and planlanan_at <= now()
     order by planlanan_at, id
       for update skip locked
  loop
    -- Tek kampanyanın hatası (ör. geçersiz kriter) diğerlerini durdurmaz; kampanya iptal edilir.
    begin
    select * into s from public.segmentler where id = c.segment_id and not arsiv;

    -- Boş kriter "herkes" demektir; pazarlama push'unda bu kabul edilmez.
    if not found or s.kriterler = '{}'::jsonb then
      update public.iletisim_kampanyalari
         set durum = 'iptal',
             onkontrol = coalesce(onkontrol, '{}'::jsonb)
                         || jsonb_build_object('iptal_nedeni', 'segment_bos_veya_yok'),
             updated_at = now()
       where id = c.id;
      continue;
    end if;

    -- Sessiz saatte dağıtım yapılmaz; push kuralıyla aynı: ertelenmez, kampanya iptal edilir.
    if public._sessiz_saat_mi(now()) then
      update public.iletisim_kampanyalari
         set durum = 'iptal',
             onkontrol = coalesce(onkontrol, '{}'::jsonb)
                         || jsonb_build_object('iptal_nedeni', 'sessiz_saat'),
             updated_at = now()
       where id = c.id;
      continue;
    end if;

    -- Hedef: segment (veya elle seçilen liste) ∩ "push" izni olanlar ∩ haftalık limit altında olanlar.
    insert into public.notifications (alici_id, tur, baslik, mesaj, ikon, kategori, pazarlama, kaynak_kampanya_id)
    select r.r_veli_id, 'bilgi', c.baslik, c.mesaj, 'bell', 'kampanya', true, c.id
      from public._segment_veliler(s.kriterler, 'push') r
     where r.r_izinli
       and (
         select count(*) from public.notifications x
          where x.alici_id = r.r_veli_id
            and x.pazarlama
            and x.created_at > now() - interval '7 days'
       ) < a.haftalik_limit
    on conflict (kaynak_kampanya_id, alici_id) where kaynak_kampanya_id is not null do nothing;

    get diagnostics v_satir = row_count;
    v_adet := v_adet + v_satir;

    update public.iletisim_kampanyalari
       set durum = 'gonderildi',
           onkontrol = coalesce(onkontrol, '{}'::jsonb)
                       || jsonb_build_object('alici_sayisi', v_satir, 'gonderim_zamani', now()),
           updated_at = now()
     where id = c.id;
    exception when others then
      update public.iletisim_kampanyalari
         set durum = 'iptal',
             onkontrol = coalesce(onkontrol, '{}'::jsonb)
                         || jsonb_build_object('iptal_nedeni', 'dagitim_hatasi', 'hata', left(sqlerrm, 200)),
             updated_at = now()
       where id = c.id;
    end;
  end loop;

  return v_adet;
end;
$function$;

comment on function public.kampanya_push_gonder() is
  'Planlanmış push kampanyasını hedef velilerin kutusuna ve push kuyruğuna yazar (yalnızca push izni olanlar). pg_cron çağırır; istemciye kapalıdır.';

revoke execute on function public.kampanya_push_gonder() from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 5. admin_list_notifications: kampanya kopyaları da listelenmez
--    (20261035 gövdesi + kaynak_kampanya_id koşulu)
-- ---------------------------------------------------------------------
create or replace function public.admin_list_notifications(
  p_limit  integer default 50,
  p_offset integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $function$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();

  select count(*)::integer into v_toplam
    from public.notifications
   where tur = 'bilgi'
     and kaynak_duyuru_id is null
     and kaynak_kampanya_id is null;

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb) into v_satir
    from (
      select
        n.id,
        n.baslik,
        n.mesaj,
        n.ikon,
        n.okundu,
        n.created_at,
        p.full_name as alici_ad,
        p.role      as alici_rol
      from public.notifications n
      join public.profiles p on p.id = n.alici_id
      where n.tur = 'bilgi'
        and n.kaynak_duyuru_id is null
        and n.kaynak_kampanya_id is null
      order by n.created_at desc, n.id
      limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$function$;

revoke execute on function public.admin_list_notifications(integer, integer) from public, anon;
grant  execute on function public.admin_list_notifications(integer, integer) to authenticated;

do $$
begin
  if not exists (select 1 from cron.job where jobname = 'kampanya-push-gonder') then
    perform cron.schedule(
      'kampanya-push-gonder',
      '* * * * *',
      'select public.kampanya_push_gonder()'
    );
  end if;
end
$$;

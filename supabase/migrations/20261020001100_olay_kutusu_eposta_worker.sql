-- =====================================================================
-- olay_kutusu gönderici worker'ı için veritabanı tarafı (deneme_sonuc_bildirimi)
--   * olay_kutusu_talep_et : bekleyen olayları kilitler (lease) ve deneme sayacını artırır
--   * olay_kutusu_sonuc_yaz: başarıyı işaretler veya bir sonraki deneme zamanını üstlenir
--   * deneme_bildirim_alici: olayın veli e-postası ve sonuç özetini döner (service_role)
--   * 5 denemeden sonra olay "ölü" kalır; son_hata alanında nedeni tutulur.
--   * pg_cron 5 dakikada bir Edge Function'ı pg_net ile çağırır. Paylaşılan gizli metin
--     Supabase Vault'ta 'olay_worker_secret' adıyla tutulur (repoya yazılmaz).
-- =====================================================================

alter table public.olay_kutusu
  add column if not exists son_hata text,
  add column if not exists sonraki_deneme_at timestamptz;

create or replace function public.olay_kutusu_talep_et(p_tur text, p_limit integer default 20)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_satirlar jsonb;
begin
  with secilen as (
    select k.id
      from public.olay_kutusu k
     where k.tur = p_tur
       and k.islendi_at is null
       and k.deneme < 5
       and (k.sonraki_deneme_at is null or k.sonraki_deneme_at <= now())
     order by k.created_at
     limit least(greatest(p_limit, 1), 50)
       for update skip locked
  ), kilitli as (
    update public.olay_kutusu k
       set sonraki_deneme_at = now() + interval '10 minutes',
           deneme = k.deneme + 1
      from secilen s
     where k.id = s.id
    returning k.id, k.payload, k.deneme
  )
  select coalesce(
    jsonb_agg(jsonb_build_object('id', id, 'payload', payload, 'deneme', deneme)),
    '[]'::jsonb
  )
    into v_satirlar
    from kilitli;

  return v_satirlar;
end;
$$;

revoke execute on function public.olay_kutusu_talep_et(text, integer) from public, anon, authenticated, service_role;
grant  execute on function public.olay_kutusu_talep_et(text, integer) to service_role;

create or replace function public.olay_kutusu_sonuc_yaz(p_id uuid, p_basarili boolean, p_hata text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_basarili then
    update public.olay_kutusu
       set islendi_at = now(),
           sonraki_deneme_at = null,
           son_hata = left(p_hata, 300)
     where id = p_id;
  else
    update public.olay_kutusu
       set son_hata = left(p_hata, 300),
           sonraki_deneme_at = now() + make_interval(mins => (5 * (2 ^ deneme))::integer)
     where id = p_id;
  end if;

  if not found then
    raise exception 'Olay bulunamadı' using errcode = 'P0002';
  end if;
end;
$$;

revoke execute on function public.olay_kutusu_sonuc_yaz(uuid, boolean, text) from public, anon, authenticated, service_role;
grant  execute on function public.olay_kutusu_sonuc_yaz(uuid, boolean, text) to service_role;

create or replace function public.deneme_bildirim_alici(p_exam_id uuid, p_student_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_r record;
begin
  select p.full_name as cocuk_ad,
         p.username  as cocuk_kullanici,
         e.ad        as sinav_ad,
         d.puan,
         d.sinif,
         d.teslim_turu,
         u.email     as veli_eposta,
         v.full_name as veli_ad
    into v_r
    from public.deneme_sinavi_denemeleri d
    join public.deneme_sinavlari e on e.id = d.exam_id
    join public.profiles p on p.id = d.student_id
    join public.profiles v on v.id = p.parent_id
    join auth.users u on u.id = v.id
   where d.exam_id = p_exam_id
     and d.student_id = p_student_id
     and d.bitis_zamani is not null;

  if not found or v_r.veli_eposta is null then
    return null;
  end if;

  return jsonb_build_object(
    'veli_eposta', v_r.veli_eposta,
    'veli_ad',     v_r.veli_ad,
    'cocuk_ad',    coalesce(v_r.cocuk_ad, v_r.cocuk_kullanici, 'Çocuğunuz'),
    'sinav_ad',    v_r.sinav_ad,
    'puan',        v_r.puan,
    'teslim_turu', v_r.teslim_turu,
    'sira', (
      select count(*) + 1
        from public.deneme_sinavi_denemeleri d2
       where d2.exam_id = p_exam_id
         and d2.sinif = v_r.sinif
         and d2.bitis_zamani is not null
         and d2.puan > v_r.puan
    ),
    'katilimci', (
      select count(*)
        from public.deneme_sinavi_denemeleri d3
       where d3.exam_id = p_exam_id
         and d3.sinif = v_r.sinif
         and d3.bitis_zamani is not null
    )
  );
end;
$$;

revoke execute on function public.deneme_bildirim_alici(uuid, uuid) from public, anon, authenticated, service_role;
grant  execute on function public.deneme_bildirim_alici(uuid, uuid) to service_role;

create extension if not exists pg_net;

do $$
begin
  if not exists (select 1 from cron.job where jobname = 'olay-kutusu-eposta-gonder') then
    perform cron.schedule(
      'olay-kutusu-eposta-gonder',
      '*/5 * * * *',
      $job$
      select net.http_post(
        url := 'https://ccozfrpnvyrnktpffkwo.supabase.co/functions/v1/olay-kutusu-gonder',
        headers := jsonb_build_object(
          'content-type', 'application/json',
          'x-webhook-secret', coalesce(
            (select ds.decrypted_secret from vault.decrypted_secrets ds where ds.name = 'olay_worker_secret' limit 1),
            ''
          )
        ),
        body := '{}'::jsonb
      );
      $job$
    );
  end if;
end
$$;

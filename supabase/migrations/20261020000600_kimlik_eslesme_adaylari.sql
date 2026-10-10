-- Migration: 20261020000600
-- Aile kimlik tekillestirme (Faz 4)
-- Ayni cocugun farkli veli hesaplarindan girilen kaydini tespit eder;
-- admin birlestirir veya "farkli" isareti koyar.

create table if not exists public.identity_merge_candidates (
  id              uuid primary key default gen_random_uuid(),
  student_a_id    uuid not null references public.profiles(id) on delete cascade,
  student_b_id    uuid not null references public.profiles(id) on delete cascade,
  match_reason    text not null,  -- 'same_name_grade', 'same_household'
  confidence      numeric(3,2) not null check (confidence between 0 and 1),
  resolved        boolean not null default false,
  resolved_action text check (resolved_action in ('merged', 'distinct', 'ignored')),
  resolved_by     uuid references public.profiles(id),
  resolved_at     timestamptz,
  created_at      timestamptz not null default now(),
  unique (student_a_id, student_b_id)
);

comment on table public.identity_merge_candidates is
  'Aynı çocuğun farklı veli hesaplarından kaydedilmiş olabileceği durumları tutar.';

-- Tablo gizli: direkt erişim yok
alter table public.identity_merge_candidates enable row level security;
-- RLS: admin service_role ile erişir, uygulama RPC üzerinden

-- ─────────────────────────────────────────────────────────────────────────────
-- Tespit: aynı ad + sınıf, farklı veli hesabı olan kayıtları bul
-- admin_detect_identity_duplicates() — servis rolü çalıştırır (cron/job)
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.admin_detect_identity_duplicates()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_inserted integer := 0;
begin
  -- Ad normalizasyonu (küçük harf + boşluk sıkıştırma)
  insert into public.identity_merge_candidates
    (student_a_id, student_b_id, match_reason, confidence)
  select
    least(a.id, b.id),
    greatest(a.id, b.id),
    'same_name_grade',
    0.85
  from public.profiles a
  cross join public.profiles b
  where a.role = 'ogrenci'
    and b.role = 'ogrenci'
    and a.id < b.id
    and a.sinif = b.sinif
    and a.sinif is not null
    -- Ad benzerliği: trim + lowercase + yalnızca harf karşılaştırma
    and lower(regexp_replace(trim(coalesce(a.full_name, '')), '\s+', ' ', 'g'))
      = lower(regexp_replace(trim(coalesce(b.full_name, '')), '\s+', ' ', 'g'))
    and trim(coalesce(a.full_name, '')) <> ''
    -- Farklı veli
    and a.veli_id is distinct from b.veli_id
    -- Henüz kayıtta yok
    and not exists (
      select 1 from public.identity_merge_candidates c
       where c.student_a_id = least(a.id, b.id)
         and c.student_b_id = greatest(a.id, b.id)
    )
  on conflict (student_a_id, student_b_id) do nothing;

  get diagnostics v_inserted = row_count;
  return v_inserted;
end;
$$;

revoke execute on function public.admin_detect_identity_duplicates() from public, anon, authenticated;
grant  execute on function public.admin_detect_identity_duplicates() to service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- Admin: bekleyen birleştirme adaylarını listele
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.admin_list_merge_candidates()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  -- Admin rolü kontrolü
  if not exists (
    select 1 from public.profiles where id = v_uid and role = 'admin'
  ) then
    raise exception 'Yalnızca yöneticiler erişebilir' using errcode = '42501';
  end if;

  return coalesce((
    select jsonb_agg(row_data order by row_data->>'created_at' desc)
      from (
        select jsonb_build_object(
          'id',         mc.id,
          'reason',     mc.match_reason,
          'confidence', mc.confidence,
          'created_at', mc.created_at,
          'ogrenci_a', jsonb_build_object(
            'id', pa.id, 'ad', pa.full_name, 'sinif', pa.sinif, 'username', pa.username
          ),
          'ogrenci_b', jsonb_build_object(
            'id', pb.id, 'ad', pb.full_name, 'sinif', pb.sinif, 'username', pb.username
          )
        ) as row_data
          from public.identity_merge_candidates mc
          join public.profiles pa on pa.id = mc.student_a_id
          join public.profiles pb on pb.id = mc.student_b_id
         where not mc.resolved
      ) t
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.admin_list_merge_candidates() from public, anon, authenticated, service_role;
grant  execute on function public.admin_list_merge_candidates() to authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- Admin: birleştirme kararı kaydet (merged / distinct / ignored)
-- Gerçek profil birleştirme mantığı ayrı geliştirme fazında — şimdi
-- yalnızca karar kaydedilir, admin elle Supabase'den veri birleştirir.
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.admin_resolve_merge_candidate(
  p_candidate_id uuid,
  p_action text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.profiles where id = v_uid and role = 'admin'
  ) then
    raise exception 'Yalnızca yöneticiler erişebilir' using errcode = '42501';
  end if;
  if p_action not in ('merged', 'distinct', 'ignored') then
    raise exception 'Geçersiz karar: merged, distinct veya ignored olmalı' using errcode = '22023';
  end if;

  update public.identity_merge_candidates
     set resolved = true,
         resolved_action = p_action,
         resolved_by = v_uid,
         resolved_at = now()
   where id = p_candidate_id and not resolved;

  if not found then
    raise exception 'Aday bulunamadı veya zaten çözümlenmiş' using errcode = 'P0002';
  end if;
end;
$$;

revoke execute on function public.admin_resolve_merge_candidate(uuid, text) from public, anon, authenticated, service_role;
grant  execute on function public.admin_resolve_merge_candidate(uuid, text) to authenticated;

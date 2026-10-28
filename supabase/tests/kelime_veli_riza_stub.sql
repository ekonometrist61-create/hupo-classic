-- Test yardımcısı: consents tablosunun asgari hali (gerçek tanım 20260920000800).
-- Yalnızca kelime_veli_ozeti rıza kapısı testi için kullanılır.
create table if not exists public.consents (
  id uuid primary key default gen_random_uuid(),
  cocuk_id uuid,
  tur text not null,
  created_at timestamptz not null default now()
);

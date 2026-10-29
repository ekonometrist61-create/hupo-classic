-- =====================================================================
-- Ödeme öncesi ön bilgilendirme ve cayma istisnası onayı kanıtı (veli aboneliği)
--
-- Her ödeme girişimi için, ödeme sayfası açılmadan önce alınan iki onay kutusunun kaydı:
--   kabul          : ön bilgilendirme formu ve mesafeli satış sözleşmesi kabulü
--   cayma_istisna  : hizmetin cayma süresi dolmadan başlamasına ilişkin ayrı onay
-- Kayıtları yalnızca service_role yazar (payments-checkout). İstemci erişemez; politika yoktur.
--
-- FOREIGN KEY bilerek yok: hesap silme (delete_my_account) ve ödeme temizliği bu kanıt
-- kaydını engellemesin. Saklama süresi gizlilik metninde yazılıdır.
-- =====================================================================

create table if not exists public.odeme_on_bilgi_onaylari (
  id             uuid primary key default gen_random_uuid(),
  payment_id     uuid not null unique,
  veli_id        uuid not null,
  surum          text not null,
  kabul          boolean not null check (kabul),
  cayma_istisna  boolean not null check (cayma_istisna),
  ip             text,
  onay_zamani    timestamptz not null default now()
);

comment on table public.odeme_on_bilgi_onaylari is
  'Ödeme öncesi ön bilgilendirme ve cayma istisnası onayı kanıtı (mesafeli satış, KVKK ispat).';

alter table public.odeme_on_bilgi_onaylari enable row level security;

revoke all on public.odeme_on_bilgi_onaylari from public, anon, authenticated;
grant select, insert on public.odeme_on_bilgi_onaylari to service_role;

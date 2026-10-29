-- =====================================================================
--  F3 · Destek Planı "yaptık" işareti (docs/veli-ogretmen-paneli/AR-GE_VE_PLAN_2026-10-29.md §6 D, §7)
--  Velinin haftalık destek önerisini yaptığını işaretlemesi. Velinin katılımını ölçmenin tek yolu.
--    * Yalnız çocuğun velisi yazar/okur; veli rızası 'verildi' değilse yazılmaz.
--    * Kayıt hafta (Pazartesi, Europe/Istanbul) + öneri kodu başına tek satır; kişisel veri yok.
--    * Tabloya doğrudan erişim yok; yalnız aşağıdaki RPC'ler.
--  Sürüm 20261140 -> 20261145 (başka oturumun 20261140_soru_vurgu_metadata dosyasıyla çakışma).
-- =====================================================================

set client_encoding = 'UTF8';

create table if not exists public.veli_destek_isaretleri (
  veli_id    uuid not null references public.profiles (id) on delete cascade,
  cocuk_id   uuid not null references public.profiles (id) on delete cascade,
  hafta      date not null,
  oneri_kod  text not null check (oneri_kod ~ '^[a-z0-9_.:-]{3,80}$'),
  created_at timestamptz not null default now(),
  primary key (veli_id, cocuk_id, hafta, oneri_kod)
);

comment on table public.veli_destek_isaretleri is
  'Velinin haftalık destek önerisini yaptım işareti. Kişisel veri içermez; yalnız RPC ile erişilir.';

alter table public.veli_destek_isaretleri enable row level security;
revoke all on public.veli_destek_isaretleri from public, anon, authenticated;

create or replace function public._istanbul_hafta_basi(p_an timestamptz default now())
returns date
language sql
immutable
set search_path = ''
as $$ select date_trunc('week', p_an at time zone 'Europe/Istanbul')::date $$;

revoke execute on function public._istanbul_hafta_basi(timestamptz) from public, anon, authenticated;

create or replace function public.veli_destek_isaret_degistir(p_cocuk_id uuid, p_oneri_kod text, p_yapildi boolean)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := (select auth.uid());
  v_hafta date := public._istanbul_hafta_basi();
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;
  if public._veli_riza_durumu(p_cocuk_id) <> 'verildi' then
    raise exception 'Veli rızası gerekli' using errcode = '42501';
  end if;
  if p_oneri_kod is null or p_oneri_kod !~ '^[a-z0-9_.:-]{3,80}$' then
    raise exception 'Geçersiz öneri kodu' using errcode = '22023';
  end if;

  if coalesce(p_yapildi, true) then
    insert into public.veli_destek_isaretleri (veli_id, cocuk_id, hafta, oneri_kod)
    values (v_uid, p_cocuk_id, v_hafta, p_oneri_kod)
    on conflict do nothing;
  else
    delete from public.veli_destek_isaretleri
     where veli_id = v_uid and cocuk_id = p_cocuk_id and hafta = v_hafta and oneri_kod = p_oneri_kod;
  end if;

  return jsonb_build_object('hafta', v_hafta, 'oneri_kod', p_oneri_kod, 'yapildi', coalesce(p_yapildi, true));
end;
$$;

create or replace function public.veli_destek_isaretleri_listele(p_cocuk_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := (select auth.uid());
  v_hafta date := public._istanbul_hafta_basi();
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  -- Rıza yoksa veya geri çekildiyse geçmiş işaretler de dönmez.
  if public._veli_riza_durumu(p_cocuk_id) <> 'verildi' then
    return jsonb_build_object('hafta', v_hafta, 'yapilanlar', '[]'::jsonb, 'son_4_hafta', 0);
  end if;

  return jsonb_build_object(
    'hafta', v_hafta,
    'yapilanlar', coalesce((
      select jsonb_agg(i.oneri_kod order by i.created_at)
        from public.veli_destek_isaretleri i
       where i.veli_id = v_uid and i.cocuk_id = p_cocuk_id and i.hafta = v_hafta
    ), '[]'::jsonb),
    'son_4_hafta', (
      select count(distinct i.hafta)::int
        from public.veli_destek_isaretleri i
       where i.veli_id = v_uid and i.cocuk_id = p_cocuk_id and i.hafta >= v_hafta - 21
    )
  );
end;
$$;

revoke execute on function public.veli_destek_isaret_degistir(uuid, text, boolean) from public, anon;
revoke execute on function public.veli_destek_isaretleri_listele(uuid) from public, anon;
grant  execute on function public.veli_destek_isaret_degistir(uuid, text, boolean) to authenticated;
grant  execute on function public.veli_destek_isaretleri_listele(uuid) to authenticated;

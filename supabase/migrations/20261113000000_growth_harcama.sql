-- =====================================================================
-- Growth manuel reklam harcaması (H-GIE Faz 1)
--
--   Amaç: CAC ve kanal kârlılığı için harcama rakamı. Reklam hesabı
--   bağlanmaz (OAuth ve veri sorumluluğu getirmez); yönetici girer.
--   Harcama girilmemiş dönemde CAC "henüz yok" gösterilir; sayı uydurulmaz.
--
--   Erişim: yalnız admin (require_admin). anon ve authenticated tabloya
--   doğrudan erişemez; RLS açık ve politika yok.
--   Kişisel veri yazılmaz: not alanında e-posta benzeri metin reddedilir.
-- =====================================================================

set client_encoding = 'UTF8';

create table if not exists public.growth_harcama (
  id            uuid primary key default gen_random_uuid(),
  tarih         date not null,
  kanal         text not null
    check (kanal in ('meta', 'google_ads', 'tiktok', 'youtube', 'instagram', 'diger')),
  tutar         numeric(12, 2) not null check (tutar > 0 and tutar <= 100000000),
  para_birimi   text not null default 'TRY' check (para_birimi in ('TRY', 'USD', 'EUR')),
  not_metni     text check (char_length(not_metni) <= 200),
  olusturan     uuid,
  created_at    timestamptz not null default now()
);

create index if not exists growth_harcama_tarih_idx on public.growth_harcama (tarih desc);

alter table public.growth_harcama enable row level security;
revoke all on public.growth_harcama from public, anon, authenticated;

comment on table public.growth_harcama is
  'Manuel reklam harcaması (CAC için). Yalnız admin RPC''leri üzerinden. Kişisel veri yazılmaz.';

-- ---------------------------------------------------------------------
-- Ekle
-- ---------------------------------------------------------------------
create or replace function public.admin_harcama_ekle(
  p_tarih       date,
  p_kanal       text,
  p_tutar       numeric,
  p_para_birimi text default 'TRY',
  p_not         text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id uuid;
  v_not text := nullif(btrim(coalesce(p_not, '')), '');
begin
  perform public.require_admin();

  if p_tarih is null or p_tarih > current_date or p_tarih < current_date - 1095 then
    raise exception 'Tarih geçersiz: bugünden ileri olamaz, 3 yıldan eski olamaz' using errcode = '22023';
  end if;

  if v_not is not null and v_not ~* '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' then
    raise exception 'Not alanına e-posta yazılamaz (kişisel veri)' using errcode = '22023';
  end if;

  insert into public.growth_harcama (tarih, kanal, tutar, para_birimi, not_metni, olusturan)
  values (p_tarih, p_kanal, p_tutar, coalesce(p_para_birimi, 'TRY'), v_not, auth.uid())
  returning id into v_id;

  perform public.log_admin_action('growth_harcama_ekle',
    jsonb_build_object('id', v_id, 'kanal', p_kanal, 'tutar', p_tutar, 'para_birimi', coalesce(p_para_birimi, 'TRY')));

  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- Listele (son p_gun gün, kanal bazlı toplam)
-- ---------------------------------------------------------------------
create or replace function public.admin_harcama_listele(p_gun int default 90)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gun int := least(greatest(coalesce(p_gun, 90), 1), 1095);
  v_satirlar jsonb;
  v_toplam jsonb;
begin
  perform public.require_admin();

  select coalesce(jsonb_agg(jsonb_build_object(
           'id', h.id, 'tarih', h.tarih, 'kanal', h.kanal,
           'tutar', h.tutar, 'para_birimi', h.para_birimi, 'not', h.not_metni)
           order by h.tarih desc, h.created_at desc), '[]'::jsonb)
    into v_satirlar
    from public.growth_harcama h
   where h.tarih >= current_date - v_gun;

  -- Para birimleri ayrı toplanır; TL ile dolar karıştırılmaz.
  select coalesce(jsonb_agg(jsonb_build_object(
           'kanal', t.kanal, 'para_birimi', t.para_birimi, 'toplam', t.toplam)
           order by t.kanal, t.para_birimi), '[]'::jsonb)
    into v_toplam
    from (
      select h.kanal, h.para_birimi, sum(h.tutar) as toplam
        from public.growth_harcama h
       where h.tarih >= current_date - v_gun
       group by h.kanal, h.para_birimi
    ) t;

  return jsonb_build_object(
    'gun', v_gun,
    'satirlar', v_satirlar,
    'kanal_toplamlari', v_toplam
  );
end;
$function$;

-- ---------------------------------------------------------------------
-- Sil (hatalı giriş düzeltmesi; denetim kaydı tutulur)
-- ---------------------------------------------------------------------
create or replace function public.admin_harcama_sil(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_silinen int;
begin
  perform public.require_admin();

  delete from public.growth_harcama where id = p_id;
  get diagnostics v_silinen = row_count;

  if v_silinen = 0 then
    raise exception 'Kayıt bulunamadı' using errcode = 'P0002';
  end if;

  perform public.log_admin_action('growth_harcama_sil', jsonb_build_object('id', p_id));
end;
$function$;

revoke execute on function public.admin_harcama_ekle(date, text, numeric, text, text) from public, anon;
revoke execute on function public.admin_harcama_listele(int) from public, anon;
revoke execute on function public.admin_harcama_sil(uuid) from public, anon;
grant execute on function public.admin_harcama_ekle(date, text, numeric, text, text) to authenticated, service_role;
grant execute on function public.admin_harcama_listele(int) to authenticated, service_role;
grant execute on function public.admin_harcama_sil(uuid) to authenticated, service_role;

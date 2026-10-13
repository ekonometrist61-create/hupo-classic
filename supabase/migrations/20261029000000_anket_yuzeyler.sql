-- =====================================================================
--  Anket yayın yüzeyleri: anket hangi mecralarda gösterilecek?
--  Proje : Hupo / Yönetim Merkezi
--  Tarih : 2026-10-13
--  Ön koşul: 20261007000030 (anketler, anket_yanitlari, anket_*_RPC'leri)
--
--  NE DEĞİŞİYOR?
--    * anketler.yuzeyler text[]      : 'mobil' | 'web_app' | 'web_sitesi' | 'veli_paneli'
--                                      (varsayılan yalnız 'veli_paneli'; en az 1 yüzey)
--    * anket_yanitlari.yuzey text    : yanıtın geldiği mecra (kimlik içermez)
--    * admin_anket_listele           : yuzeyler döner
--    * admin_anket_kaydet            : p_yuzeyler eklendi (NULL → mevcut değer korunur)
--    * anket_aktif_listem(p_yuzey)   : yalnız o yüzeyde yayınlanan anketler
--    * anket_yanit_gonder(.., p_yuzey): anket o yüzeyde yayında değilse reddedilir
--
--  KURALLAR (değişmedi)
--    * Yanıtlayan her zaman GİRİŞ YAPMIŞ VELİ hesabıdır; ziyaretçi (anonim oturum)
--      yanıtı bu migration'da yoktur. Katılım veli başına tutulur: bir mecrada
--      yanıtlayan veli, tekrar gösterim süresince diğer mecralarda da görmez.
--    * Anketin soruları/sürümü yüzey değişince değişmez (yüzey içerik değildir).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Kolonlar
-- ---------------------------------------------------------------------
alter table public.anketler
  add column if not exists yuzeyler text[] not null default array['veli_paneli']::text[];

alter table public.anketler drop constraint if exists anketler_yuzeyler;
alter table public.anketler add constraint anketler_yuzeyler check (
  cardinality(yuzeyler) between 1 and 4
  and yuzeyler <@ array['mobil', 'web_app', 'web_sitesi', 'veli_paneli']::text[]
);

alter table public.anket_yanitlari add column if not exists yuzey text;
alter table public.anket_yanitlari drop constraint if exists anket_yanitlari_yuzey;
alter table public.anket_yanitlari add constraint anket_yanitlari_yuzey check (
  yuzey is null or yuzey in ('mobil', 'web_app', 'web_sitesi', 'veli_paneli')
);

-- ---------------------------------------------------------------------
-- 2. Eski imzalar kalkar (aşırı yükleme belirsizliği olmasın)
-- ---------------------------------------------------------------------
drop function if exists public.admin_anket_kaydet(uuid, text, boolean, jsonb, integer);
drop function if exists public.anket_aktif_listem();
drop function if exists public.anket_yanit_gonder(uuid, jsonb);

-- ---------------------------------------------------------------------
-- 3. Admin RPC
-- ---------------------------------------------------------------------
create or replace function public.admin_anket_listele()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_res jsonb;
begin
  perform public.require_admin();
  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc), '[]'::jsonb) into v_res
    from (
      select a.id, a.ad, a.anonim, a.durum, a.sorular, a.surum, a.tekrar_gosterim_gun, a.yuzeyler, a.created_at,
             (select count(*)::integer from public.anket_yanitlari y where y.anket_id = a.id) as yanit_sayisi
        from public.anketler a
    ) x;
  return v_res;
end;
$function$;

create or replace function public.admin_anket_kaydet(
  p_id         uuid,
  p_ad         text,
  p_anonim     boolean,
  p_sorular    jsonb,
  p_tekrar_gun integer default 30,
  p_yuzeyler   text[] default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id      uuid := p_id;
  v_hata    text;
  v_yuzey   text[];
  a         public.anketler%rowtype;
begin
  perform public.require_admin();
  v_hata := public._anket_sorulari_hatasi(p_sorular);
  if v_hata is not null then
    raise exception 'Anket soruları geçersiz: %', v_hata using errcode = '22023';
  end if;
  if p_anonim is null then
    raise exception 'Anonimlik seçilmeli.' using errcode = '22023';
  end if;

  -- Yüzeyler: tekrarsız, doğrulanmış; NULL ise ekleme için varsayılan / güncellemede mevcut değer.
  if p_yuzeyler is not null then
    select coalesce(array_agg(distinct y order by y), '{}'::text[]) into v_yuzey
      from unnest(p_yuzeyler) as y;
    if cardinality(v_yuzey) = 0
       or not (v_yuzey <@ array['mobil', 'web_app', 'web_sitesi', 'veli_paneli']::text[]) then
      raise exception 'En az bir geçerli yayın yüzeyi seçilmeli.' using errcode = '22023';
    end if;
  end if;

  if v_id is null then
    insert into public.anketler (ad, anonim, sorular, tekrar_gosterim_gun, yuzeyler, created_by)
    values (btrim(coalesce(p_ad, '')), p_anonim, p_sorular, coalesce(p_tekrar_gun, 30),
            coalesce(v_yuzey, array['veli_paneli']::text[]), (select auth.uid()))
    returning id into v_id;
  else
    select * into a from public.anketler where id = v_id for update;
    if not found then
      raise exception 'Anket bulunamadı' using errcode = 'P0002';
    end if;
    if a.durum = 'kapali' then
      raise exception 'Kapalı anket düzenlenemez.' using errcode = '23514';
    end if;
    if a.anonim is distinct from p_anonim
       and exists (select 1 from public.anket_yanitlari where anket_id = v_id) then
      raise exception 'Yanıt alındıktan sonra anonimlik değiştirilemez.' using errcode = '23514';
    end if;
    update public.anketler
       set ad = btrim(coalesce(p_ad, '')), anonim = p_anonim, sorular = p_sorular,
           tekrar_gosterim_gun = coalesce(p_tekrar_gun, 30),
           yuzeyler = coalesce(v_yuzey, a.yuzeyler),
           -- Yayındaki anketin SORULARI değişirse yeni sürüm; yüzey değişikliği sürümü etkilemez.
           surum = case when a.durum = 'yayinda' and a.sorular is distinct from p_sorular
                        then a.surum + 1 else a.surum end,
           updated_at = now()
     where id = v_id;
  end if;

  perform public.log_admin_action('anket_kaydedildi',
    jsonb_build_object('anket_id', v_id, 'yuzeyler', coalesce(v_yuzey, a.yuzeyler, array['veli_paneli']::text[])));
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. Veli RPC
-- ---------------------------------------------------------------------
create or replace function public.anket_aktif_listem(p_yuzey text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_uid uuid := (select auth.uid());
  v_res jsonb;
begin
  if v_uid is null or not exists (select 1 from public.profiles where id = v_uid and role = 'veli') then
    raise exception 'Bu işlem yalnızca veli hesabı içindir.' using errcode = '42501';
  end if;
  if p_yuzey is null or p_yuzey not in ('mobil', 'web_app', 'web_sitesi', 'veli_paneli') then
    raise exception 'Geçersiz yayın yüzeyi.' using errcode = '22023';
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
           'id', a.id, 'ad', a.ad, 'anonim', a.anonim, 'surum', a.surum, 'sorular', a.sorular)
           order by a.created_at), '[]'::jsonb)
    into v_res
    from public.anketler a
   where a.durum = 'yayinda' and a.hedef = 'veli'
     and p_yuzey = any (a.yuzeyler)
     and not exists (select 1 from public.anket_katilimlari k
                      where k.anket_id = a.id and k.veli_id = v_uid
                        and k.son_at > now() - make_interval(days => a.tekrar_gosterim_gun));
  return v_res;
end;
$function$;

create or replace function public.anket_yanit_gonder(p_anket_id uuid, p_yanitlar jsonb, p_yuzey text)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_uid   uuid := (select auth.uid());
  a       public.anketler%rowtype;
  q       jsonb;
  v_id    text;
  v_val   jsonb;
  v_ref   jsonb;
  v_nps   smallint;
  v_yanit uuid;
begin
  if v_uid is null or not exists (select 1 from public.profiles where id = v_uid and role = 'veli') then
    raise exception 'Bu işlem yalnızca veli hesabı içindir.' using errcode = '42501';
  end if;
  if p_yanitlar is null or jsonb_typeof(p_yanitlar) <> 'object' then
    raise exception 'Yanıtlar nesne olmalı.' using errcode = '22023';
  end if;
  if p_yuzey is null or p_yuzey not in ('mobil', 'web_app', 'web_sitesi', 'veli_paneli') then
    raise exception 'Geçersiz yayın yüzeyi.' using errcode = '22023';
  end if;

  select * into a from public.anketler
   where id = p_anket_id and durum = 'yayinda' and hedef = 'veli' and p_yuzey = any (yuzeyler);
  if not found then
    raise exception 'Anket bulunamadı veya bu mecrada yayında değil.' using errcode = 'P0002';
  end if;
  -- Yalnızca tanımlı sorulara, türüne uygun değerlerle yanıt kabul edilir.
  if exists (select 1 from jsonb_object_keys(p_yanitlar) k
              where not exists (select 1 from jsonb_array_elements(a.sorular) s where s ->> 'id' = k)) then
    raise exception 'Tanımsız soru yanıtı.' using errcode = '22023';
  end if;

  for q in select * from jsonb_array_elements(a.sorular) loop
    v_id  := q ->> 'id';
    v_val := p_yanitlar -> v_id;
    continue when v_val is null or jsonb_typeof(v_val) = 'null';
    -- Koşullu soru: bağlı olduğu sorunun yanıtı koşulu sağlamıyorsa bu soruya yanıt kabul edilmez.
    if q -> 'kosul' is not null and jsonb_typeof(q -> 'kosul') = 'object' then
      v_ref := p_yanitlar -> (q -> 'kosul' ->> 'soru_id');
      if v_ref is null or jsonb_typeof(v_ref) <> 'number'
         or not (case q -> 'kosul' ->> 'op'
                   when 'lte' then (v_ref #>> '{}')::numeric <= (q -> 'kosul' ->> 'deger')::numeric
                   when 'gte' then (v_ref #>> '{}')::numeric >= (q -> 'kosul' ->> 'deger')::numeric
                   else (v_ref #>> '{}')::numeric = (q -> 'kosul' ->> 'deger')::numeric
                 end) then
        raise exception 'Koşulu sağlanmayan soruya yanıt verilemez.' using errcode = '22023';
      end if;
    end if;
    case q ->> 'tur'
      when 'nps' then
        if jsonb_typeof(v_val) <> 'number' or (v_val #>> '{}')::numeric not between 0 and 10
           or (v_val #>> '{}')::numeric <> trunc((v_val #>> '{}')::numeric) then
          raise exception 'NPS 0-10 arası tam sayı olmalı.' using errcode = '22023';
        end if;
        if v_nps is null then v_nps := (v_val #>> '{}')::numeric::smallint; end if;
      when 'csat' then
        if jsonb_typeof(v_val) <> 'number' or (v_val #>> '{}')::numeric not between 1 and 5 then
          raise exception 'Memnuniyet 1-5 arası olmalı.' using errcode = '22023';
        end if;
      when 'onay' then
        if jsonb_typeof(v_val) <> 'boolean' then
          raise exception 'Onay evet/hayır olmalı.' using errcode = '22023';
        end if;
      when 'tek_secim' then
        if jsonb_typeof(v_val) <> 'string'
           or not coalesce((q -> 'secenekler') @> to_jsonb(v_val #>> '{}'), false) then
          raise exception 'Seçenek geçersiz.' using errcode = '22023';
        end if;
      else
        if jsonb_typeof(v_val) <> 'string' or char_length(v_val #>> '{}') > 2000 then
          raise exception 'Metin yanıtı en fazla 2000 karakter olmalı.' using errcode = '22023';
        end if;
    end case;
  end loop;

  -- Katılım ATOMİK alınır: aynı anda iki istek gelirse yalnızca biri geçer (çifte NPS yok).
  insert into public.anket_katilimlari (anket_id, veli_id, son_at)
  values (a.id, v_uid, case when a.anonim then date_trunc('day', now()) else now() end)
  on conflict (anket_id, veli_id) do update
    set son_at = case when a.anonim then date_trunc('day', now()) else now() end
    where public.anket_katilimlari.son_at <= now() - make_interval(days => a.tekrar_gosterim_gun);
  if not found then
    raise exception 'Bu ankete yakın zamanda katıldınız.' using errcode = '23505';
  end if;

  insert into public.anket_yanitlari (anket_id, surum, veli_id, yanitlar, nps, yuzey, created_at)
  values (a.id, a.surum,
          case when a.anonim then null else v_uid end,
          p_yanitlar, v_nps, p_yuzey,
          case when a.anonim then date_trunc('day', now()) else now() end)
  returning id into v_yanit;

  -- Kimlikli ve düşük skor → yalnızca destek İNCELEME görevi (indirim/teklif/izin yok).
  if not a.anonim and v_nps is not null and v_nps <= 6
     and not exists (select 1 from public.destek_gorevleri
                      where veli_id = v_uid and kaynak = 'anket_dusuk_nps' and durum = 'acik') then
    insert into public.destek_gorevleri (veli_id, kaynak, anket_yanit_id)
    values (v_uid, 'anket_dusuk_nps', v_yanit);
  end if;
end;
$function$;

-- ---------------------------------------------------------------------
-- 5. Yetkiler
-- ---------------------------------------------------------------------
revoke execute on function public.admin_anket_kaydet(uuid, text, boolean, jsonb, integer, text[]) from public, anon;
revoke execute on function public.anket_aktif_listem(text)                                         from public, anon;
revoke execute on function public.anket_yanit_gonder(uuid, jsonb, text)                            from public, anon;

grant execute on function public.admin_anket_kaydet(uuid, text, boolean, jsonb, integer, text[]) to authenticated;
grant execute on function public.anket_aktif_listem(text)                                         to authenticated;
grant execute on function public.anket_yanit_gonder(uuid, jsonb, text)                            to authenticated;

-- =====================================================================
--  Anket D4: yönetim paneli RPC'leri (taslak -> yayın, kopya, sürüm geçmişi,
--  soru kütüphanesi, yayın kontrol listesi, audit'li dışa aktarım)
--  Proje : Hupo / Yönetim Merkezi
--  Tarih : 2026-11-08
--  Ön koşul: 20261032000000, 20261158000000 (D1: anket_surumleri, anket_taslaklari)
--  Kaynak: PROJE_GUNLUGU.md §24 D4 (GÖR-024)
--
--  NE DEĞİŞİYOR?
--    * admin_anket_yayin_kontrol(id)   : yayın kontrol listesi (zorunlu + bilgi maddeleri)
--    * admin_anket_yayinla(id, bool)   : kontrol listesi + yayın; önceki yayın otomatik arşivlenir
--                                        (p_onceki_arsivle=false ise önceki yalnız kapanır)
--    * admin_anket_kopyala(id)         : arşivden/kapalıdan/yayından yeni TASLAK kopya
--    * admin_anket_surum_gecmisi(id)   : sürüm listesi + bir önceki sürüme göre fark
--    * admin_anket_soru_kutuphanesi()  : yayımlanmış sorular (kopya ile yeniden kullanım)
--    * admin_anket_disa_aktar(id)      : kimliksiz satırlar, n<5 gizli, audit'li
--    * admin_anket_taslak_*            : D1 anket_taslaklari (gevşek taslak) kaydet/listele/sil/oluştur
--    * trigger: yayında anket en fazla 7 soru (sert tavan)
--
--  KURALLAR
--    * Hiçbir anket silinmez. Taslak (anket_taslaklari) satırı silinebilir: yanıtı yoktur.
--    * Dışa aktarımda veli kimliği YOKTUR; tarih gün hassasiyetindedir.
--    * Kapsam (çocuk/veli), öneri kuralı editörü ve sınıf x ders kırılımı D3'e (hukuk) bağlıdır;
--      bu dosyada YOKTUR. Rıza sürümü maddesi kontrol listesinde "hukuk bekliyor" bilgisidir.
--    * admin_anket_arsivle'deki "yayındaki anket arşivlenemez" sunucu kuralı AYNEN kalır
--      (yayındaki anketi arşivlemek onu yayında bırakırdı); yayın anı arşivi bu dosyadaki
--      yayinla RPC'si ve D1 trigger'ı ile yapılır.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Sert tavan: yayındaki anket en fazla 7 soru
-- ---------------------------------------------------------------------
create or replace function public._anketler_soru_tavani()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if new.durum = 'yayinda' and jsonb_array_length(new.sorular) > 7 then
    raise exception 'Yayındaki anket en fazla 7 soru içerebilir.' using errcode = '23514';
  end if;
  return new;
end;
$function$;

drop trigger if exists anketler_soru_tavani on public.anketler;
create trigger anketler_soru_tavani
  before insert or update of durum, sorular on public.anketler
  for each row execute function public._anketler_soru_tavani();

-- ---------------------------------------------------------------------
-- 2. Yayın kontrol listesi
-- ---------------------------------------------------------------------
create or replace function public.admin_anket_yayin_kontrol(p_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  a        public.anketler%rowtype;
  v_n      integer;
  v_hata   text;
  v_mad    jsonb := '[]'::jsonb;
  v_hazir  boolean;
begin
  perform public.require_admin();
  select * into a from public.anketler where id = p_id;
  if not found then
    raise exception 'Anket bulunamadı' using errcode = 'P0002';
  end if;

  v_n := jsonb_array_length(a.sorular);
  v_hata := public._anket_sorulari_hatasi(a.sorular);

  v_mad := v_mad || jsonb_build_array(
    jsonb_build_object('kod', 'durum', 'zorunlu', true,
      'tamam', a.durum = 'taslak' and a.arsivlendi_at is null,
      'mesaj', 'Anket taslak durumunda ve arşivde olmamalı.'),
    jsonb_build_object('kod', 'soru_var', 'zorunlu', true, 'tamam', v_n >= 1,
      'mesaj', 'En az 1 soru olmalı.'),
    jsonb_build_object('kod', 'soru_tavani', 'zorunlu', true, 'tamam', v_n <= 7,
      'mesaj', 'En fazla 7 soru olabilir (sert tavan).'),
    jsonb_build_object('kod', 'soru_gecerli', 'zorunlu', true, 'tamam', v_hata is null,
      'mesaj', coalesce(v_hata, 'Sorular geçerli.')),
    jsonb_build_object('kod', 'yuzey', 'zorunlu', true,
      'tamam', cardinality(a.yuzeyler) between 1 and 3,
      'mesaj', 'En az bir yayın yüzeyi seçilmeli.'),
    jsonb_build_object('kod', 'sure_tahmini', 'zorunlu', false, 'tamam', v_n between 1 and 7,
      'mesaj', 'Tahmini süre: ' || greatest(1, ceil(v_n * 15 / 60.0))::integer || ' dk',
      'sure_dk', greatest(1, ceil(v_n * 15 / 60.0))::integer),
    jsonb_build_object('kod', 'riza_surumu', 'zorunlu', false, 'tamam', null,
      'mesaj', 'Kişiselleştirme rıza sürümü hukuk onayı bekliyor (D3).')
  );

  select coalesce(bool_and((m ->> 'tamam')::boolean), true) into v_hazir
    from jsonb_array_elements(v_mad) m
   where (m ->> 'zorunlu')::boolean;

  return jsonb_build_object('anket_id', a.id, 'hazir', v_hazir, 'soru_sayisi', v_n, 'maddeler', v_mad);
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. Yayınla (arşiv onay kutusuyla)
-- ---------------------------------------------------------------------
create or replace function public.admin_anket_yayinla(p_id uuid, p_onceki_arsivle boolean default true)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  a         public.anketler%rowtype;
  v_kontrol jsonb;
  v_onceki  uuid;
begin
  perform public.require_admin();
  select * into a from public.anketler where id = p_id for update;
  if not found then
    raise exception 'Anket bulunamadı' using errcode = 'P0002';
  end if;

  v_kontrol := public.admin_anket_yayin_kontrol(p_id);
  if not (v_kontrol ->> 'hazir')::boolean then
    raise exception 'Yayın kontrol listesi tamamlanmadı: %',
      (select string_agg(m ->> 'mesaj', ' | ')
         from jsonb_array_elements(v_kontrol -> 'maddeler') m
        where (m ->> 'zorunlu')::boolean and not (m ->> 'tamam')::boolean)
      using errcode = '23514';
  end if;

  select id into v_onceki from public.anketler where durum = 'yayinda' and id <> p_id;

  update public.anketler set durum = 'yayinda', updated_at = now() where id = p_id;

  -- D1 trigger önceki yayını kapatıp arşivler; onay kutusu işaretli değilse arşiv geri alınır.
  if v_onceki is not null and not coalesce(p_onceki_arsivle, true) then
    update public.anketler set arsivlendi_at = null where id = v_onceki;
  end if;

  perform public.log_admin_action('anket_yayinlandi', jsonb_build_object(
    'anket_id', p_id, 'onceki_anket_id', v_onceki, 'onceki_arsivlendi', coalesce(p_onceki_arsivle, true)));
  return jsonb_build_object('anket_id', p_id, 'kapanan_anket_id', v_onceki);
end;
$function$;

-- ---------------------------------------------------------------------
-- 4. Kopya (yeniden kullanım): her durumdaki anketten yeni taslak
-- ---------------------------------------------------------------------
create or replace function public.admin_anket_kopyala(p_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  a    public.anketler%rowtype;
  v_id uuid;
begin
  perform public.require_admin();
  select * into a from public.anketler where id = p_id;
  if not found then
    raise exception 'Anket bulunamadı' using errcode = 'P0002';
  end if;

  insert into public.anketler (ad, anonim, sorular, tekrar_gosterim_gun, yuzeyler, created_by)
  values (left(a.ad, 107) || ' (kopya)', a.anonim, a.sorular, a.tekrar_gosterim_gun, a.yuzeyler, (select auth.uid()))
  returning id into v_id;

  perform public.log_admin_action('anket_kopyalandi', jsonb_build_object('kaynak_id', p_id, 'yeni_id', v_id));
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 5. Sürüm geçmişi ve fark
-- ---------------------------------------------------------------------
create or replace function public.admin_anket_surum_gecmisi(p_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  if not exists (select 1 from public.anketler where id = p_id) then
    raise exception 'Anket bulunamadı' using errcode = 'P0002';
  end if;

  return coalesce((
    select jsonb_agg(jsonb_build_object(
             'surum', s.surum, 'ad', s.ad, 'yayinlandi_at', s.yayinlandi_at,
             'soru_sayisi', jsonb_array_length(s.sorular),
             'eklenen', coalesce((
               select jsonb_agg(q ->> 'id' order by q ->> 'id')
                 from jsonb_array_elements(s.sorular) q
                where s.onceki_sorular is not null
                  and not exists (select 1 from jsonb_array_elements(s.onceki_sorular) o where o ->> 'id' = q ->> 'id')
             ), '[]'::jsonb),
             'kaldirilan', coalesce((
               select jsonb_agg(o ->> 'id' order by o ->> 'id')
                 from jsonb_array_elements(coalesce(s.onceki_sorular, '[]'::jsonb)) o
                where not exists (select 1 from jsonb_array_elements(s.sorular) q where q ->> 'id' = o ->> 'id')
             ), '[]'::jsonb),
             'degisen', coalesce((
               select jsonb_agg(q ->> 'id' order by q ->> 'id')
                 from jsonb_array_elements(s.sorular) q
                 join jsonb_array_elements(coalesce(s.onceki_sorular, '[]'::jsonb)) o on o ->> 'id' = q ->> 'id'
                where q is distinct from o
             ), '[]'::jsonb)
           ) order by s.surum desc)
      from (
        select v.*, lag(v.sorular) over (order by v.surum) as onceki_sorular
          from public.anket_surumleri v
         where v.anket_id = p_id
      ) s
  ), '[]'::jsonb);
end;
$function$;

-- ---------------------------------------------------------------------
-- 6. Soru kütüphanesi (yayımlanmış sorular; kopyalama istemcide)
-- ---------------------------------------------------------------------
create or replace function public.admin_anket_soru_kutuphanesi()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  return coalesce((
    select jsonb_agg(jsonb_build_object(
             'anket_id', x.anket_id, 'anket_ad', x.ad, 'surum', x.surum, 'soru', x.soru)
           order by x.yayinlandi_at desc, x.anket_id)
      from (
        select distinct on (v.anket_id, q.value ->> 'id')
               v.anket_id, v.ad, v.surum, v.yayinlandi_at, q.value as soru
          from public.anket_surumleri v
          cross join lateral jsonb_array_elements(v.sorular) as q(value)
         order by v.anket_id, q.value ->> 'id', v.surum desc
         limit 300
      ) x
  ), '[]'::jsonb);
end;
$function$;

-- ---------------------------------------------------------------------
-- 7. Dışa aktarım (kimliksiz, n<5 gizli, audit'li)
-- ---------------------------------------------------------------------
create or replace function public.admin_anket_disa_aktar(p_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  a      public.anketler%rowtype;
  v_n    integer;
  v_sat  jsonb;
begin
  perform public.require_admin();
  select * into a from public.anketler where id = p_id;
  if not found then
    raise exception 'Anket bulunamadı' using errcode = 'P0002';
  end if;

  select count(*)::integer into v_n from public.anket_yanitlari where anket_id = p_id;

  if v_n < 5 then
    perform public.log_admin_action('anket_disa_aktarildi',
      jsonb_build_object('anket_id', p_id, 'satir', 0, 'gizli', true));
    return jsonb_build_object('anket_id', a.id, 'ad', a.ad, 'yanit_sayisi', v_n, 'gizli', true,
                              'sorular', '[]'::jsonb, 'satirlar', '[]'::jsonb);
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
           'tarih', (date_trunc('day', y.created_at))::date, 'surum', y.surum,
           'yuzey', y.yuzey, 'nps', y.nps, 'yanitlar', y.yanitlar)
         order by y.created_at, y.id), '[]'::jsonb)
    into v_sat
    from (select * from public.anket_yanitlari where anket_id = p_id order by created_at, id limit 5000) y;

  perform public.log_admin_action('anket_disa_aktarildi',
    jsonb_build_object('anket_id', p_id, 'satir', least(v_n, 5000), 'gizli', false));

  return jsonb_build_object(
    'anket_id', a.id, 'ad', a.ad, 'yanit_sayisi', v_n, 'gizli', false,
    'kesildi', v_n > 5000,
    'sorular', (select coalesce(jsonb_agg(jsonb_build_object('id', q ->> 'id', 'baslik', q ->> 'baslik', 'tur', q ->> 'tur')), '[]'::jsonb)
                  from jsonb_array_elements(a.sorular) q),
    'satirlar', v_sat);
end;
$function$;

-- ---------------------------------------------------------------------
-- 8. Gevşek taslaklar (anket_taslaklari): kaydet, listele, sil, ankete dönüştür
-- ---------------------------------------------------------------------
create or replace function public.admin_anket_taslak_kaydet(
  p_id uuid, p_ad text, p_anonim boolean, p_sorular jsonb,
  p_tekrar_gun integer default 30, p_yuzeyler text[] default null, p_kaynak_anket_id uuid default null)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id    uuid := p_id;
  v_yuzey text[];
begin
  perform public.require_admin();
  if p_sorular is null or jsonb_typeof(p_sorular) <> 'array' or jsonb_array_length(p_sorular) > 30 then
    raise exception 'Taslak soruları en çok 30 maddelik dizi olmalı.' using errcode = '22023';
  end if;
  if coalesce(p_tekrar_gun, 30) not between 1 and 365 then
    raise exception 'Tekrar gösterim 1-365 gün olmalı.' using errcode = '22023';
  end if;
  if p_yuzeyler is not null then
    select coalesce(array_agg(distinct y order by y), '{}'::text[]) into v_yuzey from unnest(p_yuzeyler) y;
    if cardinality(v_yuzey) not between 1 and 3 or not (v_yuzey <@ array['mobil', 'web_app', 'veli_paneli']::text[]) then
      raise exception 'En az bir geçerli yayın yüzeyi seçilmeli.' using errcode = '22023';
    end if;
  end if;

  if v_id is null then
    insert into public.anket_taslaklari (kaynak_anket_id, ad, anonim, sorular, tekrar_gosterim_gun, yuzeyler, olusturan_id)
    values (p_kaynak_anket_id, left(btrim(coalesce(p_ad, '')), 120), coalesce(p_anonim, false), p_sorular,
            coalesce(p_tekrar_gun, 30), coalesce(v_yuzey, array['veli_paneli']::text[]), (select auth.uid()))
    returning id into v_id;
  else
    update public.anket_taslaklari
       set ad = left(btrim(coalesce(p_ad, '')), 120), anonim = coalesce(p_anonim, false), sorular = p_sorular,
           tekrar_gosterim_gun = coalesce(p_tekrar_gun, 30), yuzeyler = coalesce(v_yuzey, yuzeyler),
           updated_at = now()
     where id = v_id
    returning id into v_id;
    if v_id is null then
      raise exception 'Taslak bulunamadı' using errcode = 'P0002';
    end if;
  end if;
  return v_id;
end;
$function$;

create or replace function public.admin_anket_taslak_listele()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();
  return coalesce((
    select jsonb_agg(to_jsonb(t) order by t.updated_at desc)
      from (select id, kaynak_anket_id, ad, anonim, sorular, tekrar_gosterim_gun, yuzeyler, created_at, updated_at
              from public.anket_taslaklari order by updated_at desc limit 100) t
  ), '[]'::jsonb);
end;
$function$;

create or replace function public.admin_anket_taslak_sil(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id uuid;
begin
  perform public.require_admin();
  delete from public.anket_taslaklari where id = p_id returning id into v_id;
  if v_id is null then
    raise exception 'Taslak bulunamadı' using errcode = 'P0002';
  end if;
end;
$function$;

-- Taslak doğrulanır, anketler tablosuna TASLAK anket olarak yazılır, gevşek taslak silinir.
create or replace function public.admin_anket_taslaktan_olustur(p_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  t      public.anket_taslaklari%rowtype;
  v_hata text;
  v_id   uuid;
begin
  perform public.require_admin();
  select * into t from public.anket_taslaklari where id = p_id for update;
  if not found then
    raise exception 'Taslak bulunamadı' using errcode = 'P0002';
  end if;
  v_hata := public._anket_sorulari_hatasi(t.sorular);
  if v_hata is not null then
    raise exception 'Anket soruları geçersiz: %', v_hata using errcode = '22023';
  end if;
  if char_length(btrim(t.ad)) < 2 then
    raise exception 'Anket adı en az 2 karakter olmalı.' using errcode = '22023';
  end if;

  insert into public.anketler (ad, anonim, sorular, tekrar_gosterim_gun, yuzeyler, created_by)
  values (btrim(t.ad), t.anonim, t.sorular, t.tekrar_gosterim_gun, t.yuzeyler, (select auth.uid()))
  returning id into v_id;
  delete from public.anket_taslaklari where id = p_id;

  perform public.log_admin_action('anket_taslaktan_olusturuldu', jsonb_build_object('anket_id', v_id));
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 9. Yetkiler
-- ---------------------------------------------------------------------
revoke execute on function public._anketler_soru_tavani() from public, anon, authenticated;

revoke execute on function public.admin_anket_yayin_kontrol(uuid)         from public, anon;
revoke execute on function public.admin_anket_yayinla(uuid, boolean)      from public, anon;
revoke execute on function public.admin_anket_kopyala(uuid)               from public, anon;
revoke execute on function public.admin_anket_surum_gecmisi(uuid)         from public, anon;
revoke execute on function public.admin_anket_soru_kutuphanesi()          from public, anon;
revoke execute on function public.admin_anket_disa_aktar(uuid)            from public, anon;
revoke execute on function public.admin_anket_taslak_kaydet(uuid, text, boolean, jsonb, integer, text[], uuid) from public, anon;
revoke execute on function public.admin_anket_taslak_listele()            from public, anon;
revoke execute on function public.admin_anket_taslak_sil(uuid)            from public, anon;
revoke execute on function public.admin_anket_taslaktan_olustur(uuid)     from public, anon;

grant execute on function public.admin_anket_yayin_kontrol(uuid)          to authenticated;
grant execute on function public.admin_anket_yayinla(uuid, boolean)       to authenticated;
grant execute on function public.admin_anket_kopyala(uuid)                to authenticated;
grant execute on function public.admin_anket_surum_gecmisi(uuid)          to authenticated;
grant execute on function public.admin_anket_soru_kutuphanesi()           to authenticated;
grant execute on function public.admin_anket_disa_aktar(uuid)             to authenticated;
grant execute on function public.admin_anket_taslak_kaydet(uuid, text, boolean, jsonb, integer, text[], uuid) to authenticated;
grant execute on function public.admin_anket_taslak_listele()             to authenticated;
grant execute on function public.admin_anket_taslak_sil(uuid)             to authenticated;
grant execute on function public.admin_anket_taslaktan_olustur(uuid)      to authenticated;

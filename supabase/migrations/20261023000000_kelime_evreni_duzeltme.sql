-- =====================================================================
-- KELİME EVRENİ — düzeltme migration'ı (20261022000000 ve 20261022000001 zaten uzakta uygulanmış)
--
-- Neden: uzak veritabanına önceki sürüm uygulanmıştı: zorluk kolonu ve yeni XP kuralı yok,
-- başlangıç içeriği 92 anlam / 50 ilişki / 0 soru idi. Uygulanmış migration'lar değiştirilmez;
-- bu dosya durumu güncel sürüme getirir. Sıfırdan kurulumda da (önceki migration'lardan sonra)
-- aynı sonucu verir; tüm adımlar yeniden çalıştırmaya dayanıklıdır.
--
-- Veri kaybı: yok. Silinenler yalnızca seed'in fazlalık kayıtlarıdır (088-092 anlamları,
-- 147-150 ilişkileri); bunlara bağlı kullanıcı verisi (deneme, ustalık, kaydedilen, soru) yoktur.
-- =====================================================================

set client_encoding = 'UTF8';

-- 1. Soru zorluğu (XP 10/20/30) ve deneme XP sınırı
alter table public.kelime_sorulari
  add column if not exists zorluk smallint not null default 1 check (zorluk between 1 and 3);

alter table public.kelime_denemeleri drop constraint if exists kelime_denemeleri_kazanilan_xp_check;
alter table public.kelime_denemeleri
  add constraint kelime_denemeleri_kazanilan_xp_check check (kazanilan_xp between 0 and 30);

-- 2. Fonksiyonlar (güncel gövdeler)
drop function if exists public.kelime_soru_kaydet(uuid, uuid, text, integer, text, text, jsonb, integer, uuid, text, text);
create or replace function public.kelime_cevap_gonder(
  p_soru_id           uuid,
  p_secilen_indeks    integer,
  p_ipucu_kullanildi  boolean,
  p_deneme_anahtari   text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid         uuid := (select auth.uid());
  v_sinif       smallint;
  v_soru        public.kelime_sorulari%rowtype;
  v_onceki      public.kelime_denemeleri%rowtype;
  v_ipucu       boolean := coalesce(p_ipucu_kullanildi, false);
  v_dogru       boolean;
  v_xp_ver      boolean;
  v_ust         public.kelime_ustaliklari%rowtype;
  v_xp          integer := 0;
  v_award       jsonb;
  v_onceki_seviye smallint := 0;
  v_yeni_seviye smallint;
  v_gun         integer;
begin
  if v_uid is null or public.current_user_role() is distinct from 'ogrenci' then
    raise exception 'STUDENT_ONLY' using errcode = '42501';
  end if;

  -- Aynı kullanıcının eşzamanlı istekleri sırayla işlenir
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_uid::text, 0));

  if p_deneme_anahtari is null or length(p_deneme_anahtari) not between 8 and 100 then
    raise exception 'INVALID_ATTEMPT_KEY' using errcode = '22023';
  end if;
  if p_secilen_indeks is null or p_secilen_indeks < 0 then
    raise exception 'BAD_OPTION' using errcode = '22023';
  end if;

  -- Ağ yeniden denemesi: kayıtlı sonucu dön, XP/ustalık tekrar işlenmesin
  select * into v_onceki
    from public.kelime_denemeleri
   where ogrenci_id = v_uid and deneme_anahtari = p_deneme_anahtari;
  if found then
    if v_onceki.soru_id <> p_soru_id
       or v_onceki.secilen_indeks <> p_secilen_indeks
       or v_onceki.ipucu_kullanildi <> v_ipucu then
      raise exception 'IDEMPOTENCY_CONFLICT' using errcode = '22023';
    end if;
    select * into v_soru from public.kelime_sorulari where id = p_soru_id;
    return jsonb_build_object(
      'dogru', v_onceki.dogru_mu,
      'dogru_indeks', v_soru.dogru_indeks,
      'aciklama', v_soru.aciklama,
      'kazanilan_xp', v_onceki.kazanilan_xp,
      'tekrar', true
    );
  end if;

  select p.sinif into v_sinif from public.profiles p where p.id = v_uid;

  -- Yalnızca yayındaki ve öğrencinin sınıfındaki sorular cevaplanabilir
  select * into v_soru
    from public.kelime_sorulari
   where id = p_soru_id and durum = 'yayinda' and sinif = v_sinif;
  if not found then
    raise exception 'SORU_BULUNAMADI' using errcode = 'P0002';
  end if;

  if p_secilen_indeks >= jsonb_array_length(v_soru.secenekler) then
    raise exception 'BAD_OPTION' using errcode = '22023';
  end if;

  if (select count(*) from public.kelime_denemeleri d
       where d.ogrenci_id = v_uid and d.created_at > now() - interval '1 minute') >= 30 then
    raise exception 'RATE_LIMIT' using errcode = '53400';
  end if;

  v_dogru := p_secilen_indeks = v_soru.dogru_indeks;

  -- Mevcut submit_answer kuralı: XP yalnızca tekrar zamanı gelmiş (vadesi gelmiş) doğru cevapta verilir.
  -- Kelimede tekrar birimi anlamdır (kelime_ustaliklari). Henüz kaydı olmayan anlam vadesi gelmiş sayılır.
  select * into v_ust
    from public.kelime_ustaliklari u
   where u.ogrenci_id = v_uid and u.anlam_id = v_soru.anlam_id and u.beceri = 'taninma';
  -- İpucu mevcut sistemde olmayan bir yardımdır; ipucuyla doğru cevap XP vermez.
  v_xp_ver := v_dogru and not v_ipucu and ((not found) or v_ust.sonraki_tekrar_tarihi <= now());

  if v_dogru then
    -- Tek XP yazım yolu: award_xp_and_streak. XP zorluğa göre (1/2/3 = 10/20/30); seri her doğru cevapta sayılır.
    v_award := public.award_xp_and_streak(v_uid, v_soru.zorluk, v_xp_ver);
    v_xp := coalesce((v_award ->> 'kazanilan_xp')::integer, 0);
  end if;

  insert into public.kelime_denemeleri (
    ogrenci_id, soru_id, anlam_id, deneme_anahtari, secilen_indeks, dogru_mu, ipucu_kullanildi, kazanilan_xp
  ) values (
    v_uid, v_soru.id, v_soru.anlam_id, p_deneme_anahtari, p_secilen_indeks, v_dogru, v_ipucu, v_xp
  );

  v_onceki_seviye := coalesce(v_ust.basari_seviyesi, 0);

  if not v_dogru then
    v_yeni_seviye := 0;
    v_gun := 1;
  elsif v_ipucu then
    v_yeni_seviye := v_onceki_seviye;
    v_gun := 1;
  else
    v_yeni_seviye := least(v_onceki_seviye + 1, 3);
    v_gun := case v_yeni_seviye when 1 then 1 when 2 then 3 else 7 end;
  end if;

  insert into public.kelime_ustaliklari as k (
    ogrenci_id, anlam_id, beceri, basari_seviyesi, sonraki_tekrar_tarihi, son_cevap_tarihi, guncellendi
  ) values (
    v_uid, v_soru.anlam_id, 'taninma', v_yeni_seviye, now() + make_interval(days => v_gun), now(), now()
  )
  on conflict (ogrenci_id, anlam_id, beceri) do update
    set basari_seviyesi       = excluded.basari_seviyesi,
        sonraki_tekrar_tarihi = excluded.sonraki_tekrar_tarihi,
        son_cevap_tarihi      = excluded.son_cevap_tarihi,
        guncellendi           = excluded.guncellendi;

  return jsonb_build_object(
    'dogru', v_dogru,
    'dogru_indeks', v_soru.dogru_indeks,
    'aciklama', v_soru.aciklama,
    'kazanilan_xp', v_xp,
    'tekrar', false,
    'ustalik', jsonb_build_object(
      'beceri', 'taninma',
      'seviye', v_yeni_seviye,
      'sonraki_tekrar_tarihi', now() + make_interval(days => v_gun)
    )
  );
end;
$$;

revoke all on function public.kelime_cevap_gonder(uuid, integer, boolean, text) from public, anon;
grant execute on function public.kelime_cevap_gonder(uuid, integer, boolean, text) to authenticated;

create or replace function public.kelime_yonetim_liste(
  p_durum      text default null,
  p_sinif      smallint default null,
  p_iliski_turu text default null,
  p_limit      integer default 200
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_limit   integer := least(greatest(coalesce(p_limit, 200), 1), 500);
  v_toplam  integer;
  v_satirlar jsonb;
begin
  perform public.kelime_yonetici_kontrol();

  select count(*) into v_toplam
    from public.kelime_sorulari s
   where (p_durum is null or s.durum = p_durum)
     and (p_sinif is null or s.sinif = p_sinif)
     and (p_iliski_turu is null or s.iliski_turu = p_iliski_turu);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.guncellendi desc), '[]'::jsonb) into v_satirlar
    from (
      select s.id, a.kelime, a.anlam, s.anlam_id, s.iliski_turu, s.sinif, s.zorluk, s.kazanim_kodu,
             s.soru_metni, s.secenekler, s.dogru_indeks, s.dogru_anlam_id, s.ipucu, s.aciklama,
             s.durum, s.olusturan_id, s.inceleyen_id, s.yayin_tarihi,
             s.updated_at as guncellendi
        from public.kelime_sorulari s
        join public.kelime_anlamlari a on a.id = s.anlam_id
       where (p_durum is null or s.durum = p_durum)
         and (p_sinif is null or s.sinif = p_sinif)
         and (p_iliski_turu is null or s.iliski_turu = p_iliski_turu)
       order by s.updated_at desc
       limit v_limit
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satirlar);
end;
$$;

revoke all on function public.kelime_yonetim_liste(text, smallint, text, integer) from public, anon;
grant execute on function public.kelime_yonetim_liste(text, smallint, text, integer) to authenticated;

create or replace function public.kelime_soru_kaydet(
  p_id              uuid,
  p_anlam_id        uuid,
  p_iliski_turu     text,
  p_sinif           integer,
  p_kazanim_kodu    text,
  p_soru_metni      text,
  p_secenekler      jsonb,
  p_dogru_indeks    integer,
  p_dogru_anlam_id  uuid,
  p_ipucu           text,
  p_aciklama        text,
  p_zorluk          integer default 1
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_sec jsonb;
  v_id  uuid;
begin
  perform public.kelime_yonetici_kontrol();

  if p_iliski_turu not in ('es_anlamli', 'zit_anlamli', 'es_sesli') then
    raise exception 'BAD_RELATION' using errcode = '22023';
  end if;
  if p_sinif is null or p_sinif not between 1 and 12 then
    raise exception 'BAD_SINIF' using errcode = '22023';
  end if;
  if length(btrim(coalesce(p_soru_metni, ''))) not between 5 and 400 then
    raise exception 'BAD_SORU_METNI' using errcode = '22023';
  end if;
  if length(btrim(coalesce(p_aciklama, ''))) not between 5 and 500 then
    raise exception 'BAD_ACIKLAMA' using errcode = '22023';
  end if;
  if p_ipucu is not null and length(btrim(p_ipucu)) > 200 then
    raise exception 'BAD_IPUCU' using errcode = '22023';
  end if;
  if p_zorluk is null or p_zorluk not between 1 and 3 then
    raise exception 'BAD_ZORLUK' using errcode = '22023';
  end if;

  -- Şıklar: 2-4 adet, boş olmayan metin, tekrarsız (büyük/küçük harf ve boşluk farkı yok sayılır)
  if jsonb_typeof(p_secenekler) is distinct from 'array' then
    raise exception 'BAD_SECENEK_SAYISI' using errcode = '22023';
  end if;
  if jsonb_array_length(p_secenekler) not between 2 and 4 then
    raise exception 'BAD_SECENEK_SAYISI' using errcode = '22023';
  end if;
  if exists (
       select 1 from jsonb_array_elements(p_secenekler) e
        where jsonb_typeof(e.value) <> 'string'
           or length(btrim(e.value #>> '{}')) not between 1 and 120
     ) then
    raise exception 'BAD_SECENEK' using errcode = '22023';
  end if;
  select coalesce(jsonb_agg(to_jsonb(btrim(e.value #>> '{}')) order by e.ord), '[]'::jsonb)
    into v_sec
    from jsonb_array_elements(p_secenekler) with ordinality as e(value, ord);
  if (select count(distinct lower(e.value #>> '{}')) from jsonb_array_elements(v_sec) e)
     <> jsonb_array_length(v_sec) then
    raise exception 'SECENEK_TEKRARI' using errcode = '22023';
  end if;

  if p_dogru_indeks is null or p_dogru_indeks < 0 or p_dogru_indeks >= jsonb_array_length(v_sec) then
    raise exception 'BAD_DOGRU_INDEKS' using errcode = '22023';
  end if;

  if not exists (select 1 from public.kelime_anlamlari where id = p_anlam_id) then
    raise exception 'ANLAM_BULUNAMADI' using errcode = 'P0002';
  end if;

  -- Doğru şık bir anlamsa, bu anlam ile soru anlamı arasında ONAYLI ilişki olmalı
  if p_dogru_anlam_id is not null
     and not public.kelime_iliski_onayli_mi(p_anlam_id, p_dogru_anlam_id, p_iliski_turu) then
    raise exception 'ILISKI_ONAYSIZ' using errcode = '22023';
  end if;

  if p_id is null then
    insert into public.kelime_sorulari (
      anlam_id, iliski_turu, sinif, kazanim_kodu, zorluk, soru_metni, secenekler, dogru_indeks,
      dogru_anlam_id, ipucu, aciklama, durum, olusturan_id
    ) values (
      p_anlam_id, p_iliski_turu, p_sinif, nullif(btrim(p_kazanim_kodu), ''), p_zorluk, btrim(p_soru_metni), v_sec, p_dogru_indeks,
      p_dogru_anlam_id, nullif(btrim(p_ipucu), ''), btrim(p_aciklama), 'taslak', v_uid
    )
    returning id into v_id;
  else
    update public.kelime_sorulari
       set anlam_id = p_anlam_id,
           iliski_turu = p_iliski_turu,
           sinif = p_sinif,
           zorluk = p_zorluk,
           kazanim_kodu = nullif(btrim(p_kazanim_kodu), ''),
           soru_metni = btrim(p_soru_metni),
           secenekler = v_sec,
           dogru_indeks = p_dogru_indeks,
           dogru_anlam_id = p_dogru_anlam_id,
           ipucu = nullif(btrim(p_ipucu), ''),
           aciklama = btrim(p_aciklama),
           durum = 'taslak',
           inceleyen_id = null,
           yayin_tarihi = null
     where id = p_id and durum in ('taslak', 'incelemede')
    returning id into v_id;

    if v_id is null then
      if exists (select 1 from public.kelime_sorulari where id = p_id) then
        raise exception 'DUZENLENEMEZ' using errcode = '22023';
      end if;
      raise exception 'SORU_BULUNAMADI' using errcode = 'P0002';
    end if;
  end if;

  perform public.log_admin_action('kelime_soru_kaydet', jsonb_build_object('soru_id', v_id));
  return v_id;
end;
$$;

revoke all on function public.kelime_soru_kaydet(uuid, uuid, text, integer, text, text, jsonb, integer, uuid, text, text, integer) from public, anon;
grant execute on function public.kelime_soru_kaydet(uuid, uuid, text, integer, text, text, jsonb, integer, uuid, text, text, integer) to authenticated;


-- 3. Seed'in fazlalık kayıtları (kullanıcı verisi yok; doğrulandı)
delete from public.kelime_iliskileri
 where id in ('00000000-0000-4000-8000-000000000147','00000000-0000-4000-8000-000000000148',
              '00000000-0000-4000-8000-000000000149','00000000-0000-4000-8000-000000000150');
delete from public.kelime_anlamlari
 where id in ('00000000-0000-4000-8000-000000000088','00000000-0000-4000-8000-000000000089',
              '00000000-0000-4000-8000-000000000090','00000000-0000-4000-8000-000000000091',
              '00000000-0000-4000-8000-000000000092');
update public.kelime_anlamlari
   set kelime = 'belirsizlik', anlam = 'Kesin olmayan durum, kuşku'
 where id = '00000000-0000-4000-8000-000000000078' and kelime = 'olasılık';

-- 4. İçerik (yeniden çalışabilir: mevcut kimlikler atlanır)

insert into public.kelime_anlamlari (id, kelime, anlam, sozcuk_turu) values
  ('00000000-0000-4000-8000-000000000001', 'mutlu', 'Sevinç duyan, neşeli', 'sifat'),
  ('00000000-0000-4000-8000-000000000002', 'sevinçli', 'Sevinç duyan, mutlu', 'sifat'),
  ('00000000-0000-4000-8000-000000000003', 'akıllı', 'Zeki, aklı başında', 'sifat'),
  ('00000000-0000-4000-8000-000000000004', 'zeki', 'Hızlı düşünen, anlayışlı', 'sifat'),
  ('00000000-0000-4000-8000-000000000005', 'hızlı', 'Çabuk hareket eden', 'sifat'),
  ('00000000-0000-4000-8000-000000000006', 'çabuk', 'Hızlı, kısa sürede gerçekleşen', 'sifat'),
  ('00000000-0000-4000-8000-000000000007', 'yavaş', 'Hızlı olmayan, geç hareket eden', 'sifat'),
  ('00000000-0000-4000-8000-000000000008', 'güzel', 'Hoş, gözü ve kulağı okşayan', 'sifat'),
  ('00000000-0000-4000-8000-000000000009', 'hoş', 'Sevilen, güzel, tatlı', 'sifat'),
  ('00000000-0000-4000-8000-000000000010', 'ünlü', 'Meşhur, adı herkesçe bilinen', 'sifat'),
  ('00000000-0000-4000-8000-000000000011', 'meşhur', 'Ünlü, tanınmış', 'sifat'),
  ('00000000-0000-4000-8000-000000000012', 'özlem', 'Hasret, kavuşamama duygusu', 'isim'),
  ('00000000-0000-4000-8000-000000000013', 'hasret', 'Özlem, kavuşamama acısı', 'isim'),
  ('00000000-0000-4000-8000-000000000014', 'katı', 'Sert, yumuşak olmayan', 'sifat'),
  ('00000000-0000-4000-8000-000000000015', 'sert', 'Katı, güçlü, acımasız', 'sifat'),
  ('00000000-0000-4000-8000-000000000016', 'doygun', 'Tok, yeterince beslenmiş', 'sifat'),
  ('00000000-0000-4000-8000-000000000017', 'tok', 'Doygun, aç olmayan', 'sifat'),
  ('00000000-0000-4000-8000-000000000018', 'kusur', 'Hata, yanlışlık', 'isim'),
  ('00000000-0000-4000-8000-000000000019', 'hata', 'Kusur, yanlışlık', 'isim'),
  ('00000000-0000-4000-8000-000000000020', 'gizli', 'Saklı, örtülü, bilinmeyen', 'sifat'),
  ('00000000-0000-4000-8000-000000000021', 'saklı', 'Gizli, örtülü', 'sifat'),
  ('00000000-0000-4000-8000-000000000022', 'öğretmen', 'Ders veren, öğrencileri yetiştiren kişi', 'isim'),
  ('00000000-0000-4000-8000-000000000023', 'muallim', 'Öğretmen (eskiden kullanılan sözcük)', 'isim'),
  ('00000000-0000-4000-8000-000000000024', 'zarar', 'Hasar, kayıp, bozulma', 'isim'),
  ('00000000-0000-4000-8000-000000000025', 'hasar', 'Zarar, bozulma, yıpranma', 'isim'),
  ('00000000-0000-4000-8000-000000000026', 'cesaret', 'Yürek, korkusuzluk', 'isim'),
  ('00000000-0000-4000-8000-000000000027', 'yürek', 'Cesaret, korkusuzluk', 'isim'),
  ('00000000-0000-4000-8000-000000000028', 'eleştiri', 'Tenkit, iyi ve kötü yanları inceleyip değerlendirme', 'isim'),
  ('00000000-0000-4000-8000-000000000029', 'tenkit', 'Eleştiri, inceleyip değerlendirme', 'isim'),
  ('00000000-0000-4000-8000-000000000030', 'eski', 'Yeni olmayan, eskiden beri var olan', 'sifat'),
  ('00000000-0000-4000-8000-000000000031', 'kadim', 'Çok eski, eskiden beri var olan', 'sifat'),
  ('00000000-0000-4000-8000-000000000032', 'sabır', 'Tahammül, zorluk karşısında dayanma', 'isim'),
  ('00000000-0000-4000-8000-000000000033', 'tahammül', 'Sabır, katlanma', 'isim'),
  ('00000000-0000-4000-8000-000000000034', 'şifa', 'Deva, iyileşme, sağlığına kavuşma', 'isim'),
  ('00000000-0000-4000-8000-000000000035', 'deva', 'Şifa, iyileştirici şey', 'isim'),
  ('00000000-0000-4000-8000-000000000036', 'yoksul', 'Fakir, az geliri olan', 'sifat'),
  ('00000000-0000-4000-8000-000000000037', 'fakir', 'Yoksul, az geliri olan', 'sifat'),
  ('00000000-0000-4000-8000-000000000038', 'vatan', 'Yurt, doğulan ve yaşanan ülke', 'isim'),
  ('00000000-0000-4000-8000-000000000039', 'yurt', 'Vatan, doğulan ve yaşanan topraklar', 'isim'),
  ('00000000-0000-4000-8000-000000000040', 'yanıt', 'Cevap, bir soruya verilen karşılık', 'isim'),
  ('00000000-0000-4000-8000-000000000041', 'cevap', 'Yanıt, bir soruya verilen karşılık', 'isim'),
  ('00000000-0000-4000-8000-000000000042', 'sıcak', 'Isısı yüksek, ısınmış', 'sifat'),
  ('00000000-0000-4000-8000-000000000043', 'soğuk', 'Isısı düşük, ısınmamış', 'sifat'),
  ('00000000-0000-4000-8000-000000000044', 'uzun', 'Boyu veya süresi fazla olan', 'sifat'),
  ('00000000-0000-4000-8000-000000000045', 'kısa', 'Boyu veya süresi az olan', 'sifat'),
  ('00000000-0000-4000-8000-000000000046', 'büyük', 'Boyca ya da nicelikçe fazla olan', 'sifat'),
  ('00000000-0000-4000-8000-000000000047', 'küçük', 'Boyca ya da nicelikçe az olan', 'sifat'),
  ('00000000-0000-4000-8000-000000000048', 'iyi', 'Kötü olmayan, olumlu', 'sifat'),
  ('00000000-0000-4000-8000-000000000049', 'kötü', 'İyi olmayan, olumsuz', 'sifat'),
  ('00000000-0000-4000-8000-000000000050', 'açık', 'Kapalı olmayan, serbest', 'sifat'),
  ('00000000-0000-4000-8000-000000000051', 'kapalı', 'Açık olmayan, kapatılmış', 'sifat'),
  ('00000000-0000-4000-8000-000000000052', 'dolu', 'İçi bir şeyle kaplı, boş olmayan', 'sifat'),
  ('00000000-0000-4000-8000-000000000053', 'boş', 'Dolu olmayan, içi boş', 'sifat'),
  ('00000000-0000-4000-8000-000000000054', 'zengin', 'Varlıklı, yoksul olmayan', 'sifat'),
  ('00000000-0000-4000-8000-000000000055', 'kolay', 'Zor olmayan, zahmetsiz', 'sifat'),
  ('00000000-0000-4000-8000-000000000056', 'zor', 'Kolay olmayan, zahmetli', 'sifat'),
  ('00000000-0000-4000-8000-000000000057', 'yüksek', 'Alçak olmayan, yukarıda olan', 'sifat'),
  ('00000000-0000-4000-8000-000000000058', 'alçak', 'Yüksek olmayan, aşağıda olan', 'sifat'),
  ('00000000-0000-4000-8000-000000000059', 'cesur', 'Yürekli, korkak olmayan', 'sifat'),
  ('00000000-0000-4000-8000-000000000060', 'korkak', 'Cesur olmayan, korkudan duran', 'sifat'),
  ('00000000-0000-4000-8000-000000000061', 'düz', 'Eğri olmayan, bükük olmayan', 'sifat'),
  ('00000000-0000-4000-8000-000000000062', 'eğri', 'Düz olmayan, bükük', 'sifat'),
  ('00000000-0000-4000-8000-000000000063', 'gürültülü', 'Çok sesli, rahatsız edici ses veren', 'sifat'),
  ('00000000-0000-4000-8000-000000000064', 'sessiz', 'Gürültüsüz, sesi olmayan', 'sifat'),
  ('00000000-0000-4000-8000-000000000065', 'kibar', 'Nazik, kaba olmayan', 'sifat'),
  ('00000000-0000-4000-8000-000000000066', 'kaba', 'Kibar olmayan, inceliksiz', 'sifat'),
  ('00000000-0000-4000-8000-000000000067', 'çalışkan', 'Tembel olmayan, işini özenle yapan', 'sifat'),
  ('00000000-0000-4000-8000-000000000068', 'tembel', 'Çalışkan olmayan, gevşek', 'sifat'),
  ('00000000-0000-4000-8000-000000000069', 'masum', 'Suçsuz, temiz', 'sifat'),
  ('00000000-0000-4000-8000-000000000070', 'suçlu', 'Masum olmayan, suç işleyen', 'sifat'),
  ('00000000-0000-4000-8000-000000000071', 'üretim', 'Mal ya da hizmet oluşturma', 'isim'),
  ('00000000-0000-4000-8000-000000000072', 'tüketim', 'Üretileni kullanıp bitirme', 'isim'),
  ('00000000-0000-4000-8000-000000000073', 'çoğaltmak', 'Sayısını artırmak, kopyalamak', 'fiil'),
  ('00000000-0000-4000-8000-000000000074', 'azaltmak', 'Sayısını düşürmek, eksiltmek', 'fiil'),
  ('00000000-0000-4000-8000-000000000075', 'çekici', 'Albenili, ilgi çeken', 'sifat'),
  ('00000000-0000-4000-8000-000000000076', 'itici', 'Sevimsiz, uzaklaştıran', 'sifat'),
  ('00000000-0000-4000-8000-000000000077', 'kesinlik', 'Belirsizlik olmayan, kuşkusuz olma', 'isim'),
  ('00000000-0000-4000-8000-000000000078', 'belirsizlik', 'Kesin olmayan durum, kuşku', 'isim'),
  ('00000000-0000-4000-8000-000000000079', 'yaz', 'Yılın en sıcak mevsimi (Haziran-Temmuz-Ağustos)', 'isim'),
  ('00000000-0000-4000-8000-000000000080', 'yaz', 'Yazmak; harflerle iz bırakmak', 'fiil'),
  ('00000000-0000-4000-8000-000000000081', 'gül', 'Hoş kokulu, dikenli bir çiçek türü', 'isim'),
  ('00000000-0000-4000-8000-000000000082', 'gül', 'Gülmek; neşeyle ses çıkarmak', 'fiil'),
  ('00000000-0000-4000-8000-000000000083', 'yüz', 'Başın ön bölümü; göz, burun ve ağız bölgesi', 'isim'),
  ('00000000-0000-4000-8000-000000000084', 'yüz', 'Doksan dokuzun bir fazlası; 100 sayısı', 'isim'),
  ('00000000-0000-4000-8000-000000000085', 'yüz', 'Yüzmek; suda ilerlemek', 'fiil'),
  ('00000000-0000-4000-8000-000000000086', 'çekiç', 'Çiviyi çakmaya yarayan ağır başlı araç', 'isim'),
  ('00000000-0000-4000-8000-000000000087', 'çekiç', 'Başı çekiç biçiminde olan bir deniz balığı', 'isim'),
  ('00000000-0000-4000-8000-000000000093', 'dil', 'Ağız içinde tat alan ve konuşmayı sağlayan organ', 'isim'),
  ('00000000-0000-4000-8000-000000000094', 'dil', 'Bir toplumun konuşup anlaştığı sözcük sistemi', 'isim'),
  ('00000000-0000-4000-8000-000000000095', 'al', 'Kırmızı renkte olan', 'sifat'),
  ('00000000-0000-4000-8000-000000000096', 'al', 'Bir şeyi eline geçirmek, almak', 'fiil'),
  ('00000000-0000-4000-8000-000000000097', 'göz', 'Görmeye yarayan organ', 'isim'),
  ('00000000-0000-4000-8000-000000000098', 'göz', 'Yerin altından su çıkan kaynak', 'isim') on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 2. İlişkiler (49 kayıt, hepsi ONAYSIZ)
-- ---------------------------------------------------------------------
insert into public.kelime_iliskileri (id, kaynak_anlam_id, hedef_anlam_id, iliski_turu) values
  ('00000000-0000-4000-8000-000000000101', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000002', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000102', '00000000-0000-4000-8000-000000000003', '00000000-0000-4000-8000-000000000004', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000103', '00000000-0000-4000-8000-000000000005', '00000000-0000-4000-8000-000000000006', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000104', '00000000-0000-4000-8000-000000000008', '00000000-0000-4000-8000-000000000009', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000105', '00000000-0000-4000-8000-000000000010', '00000000-0000-4000-8000-000000000011', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000106', '00000000-0000-4000-8000-000000000012', '00000000-0000-4000-8000-000000000013', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000107', '00000000-0000-4000-8000-000000000014', '00000000-0000-4000-8000-000000000015', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000108', '00000000-0000-4000-8000-000000000016', '00000000-0000-4000-8000-000000000017', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000109', '00000000-0000-4000-8000-000000000018', '00000000-0000-4000-8000-000000000019', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000110', '00000000-0000-4000-8000-000000000020', '00000000-0000-4000-8000-000000000021', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000111', '00000000-0000-4000-8000-000000000022', '00000000-0000-4000-8000-000000000023', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000112', '00000000-0000-4000-8000-000000000024', '00000000-0000-4000-8000-000000000025', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000113', '00000000-0000-4000-8000-000000000026', '00000000-0000-4000-8000-000000000027', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000114', '00000000-0000-4000-8000-000000000028', '00000000-0000-4000-8000-000000000029', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000115', '00000000-0000-4000-8000-000000000030', '00000000-0000-4000-8000-000000000031', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000116', '00000000-0000-4000-8000-000000000032', '00000000-0000-4000-8000-000000000033', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000117', '00000000-0000-4000-8000-000000000034', '00000000-0000-4000-8000-000000000035', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000118', '00000000-0000-4000-8000-000000000036', '00000000-0000-4000-8000-000000000037', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000119', '00000000-0000-4000-8000-000000000038', '00000000-0000-4000-8000-000000000039', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000120', '00000000-0000-4000-8000-000000000040', '00000000-0000-4000-8000-000000000041', 'es_anlamli'),
  ('00000000-0000-4000-8000-000000000121', '00000000-0000-4000-8000-000000000042', '00000000-0000-4000-8000-000000000043', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000122', '00000000-0000-4000-8000-000000000044', '00000000-0000-4000-8000-000000000045', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000123', '00000000-0000-4000-8000-000000000046', '00000000-0000-4000-8000-000000000047', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000124', '00000000-0000-4000-8000-000000000005', '00000000-0000-4000-8000-000000000007', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000125', '00000000-0000-4000-8000-000000000048', '00000000-0000-4000-8000-000000000049', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000126', '00000000-0000-4000-8000-000000000050', '00000000-0000-4000-8000-000000000051', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000127', '00000000-0000-4000-8000-000000000052', '00000000-0000-4000-8000-000000000053', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000128', '00000000-0000-4000-8000-000000000054', '00000000-0000-4000-8000-000000000036', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000129', '00000000-0000-4000-8000-000000000055', '00000000-0000-4000-8000-000000000056', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000130', '00000000-0000-4000-8000-000000000057', '00000000-0000-4000-8000-000000000058', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000131', '00000000-0000-4000-8000-000000000059', '00000000-0000-4000-8000-000000000060', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000132', '00000000-0000-4000-8000-000000000061', '00000000-0000-4000-8000-000000000062', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000133', '00000000-0000-4000-8000-000000000063', '00000000-0000-4000-8000-000000000064', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000134', '00000000-0000-4000-8000-000000000065', '00000000-0000-4000-8000-000000000066', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000135', '00000000-0000-4000-8000-000000000067', '00000000-0000-4000-8000-000000000068', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000136', '00000000-0000-4000-8000-000000000069', '00000000-0000-4000-8000-000000000070', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000137', '00000000-0000-4000-8000-000000000071', '00000000-0000-4000-8000-000000000072', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000138', '00000000-0000-4000-8000-000000000073', '00000000-0000-4000-8000-000000000074', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000139', '00000000-0000-4000-8000-000000000075', '00000000-0000-4000-8000-000000000076', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000140', '00000000-0000-4000-8000-000000000077', '00000000-0000-4000-8000-000000000078', 'zit_anlamli'),
  ('00000000-0000-4000-8000-000000000141', '00000000-0000-4000-8000-000000000079', '00000000-0000-4000-8000-000000000080', 'es_sesli'),
  ('00000000-0000-4000-8000-000000000142', '00000000-0000-4000-8000-000000000081', '00000000-0000-4000-8000-000000000082', 'es_sesli'),
  ('00000000-0000-4000-8000-000000000143', '00000000-0000-4000-8000-000000000083', '00000000-0000-4000-8000-000000000084', 'es_sesli'),
  ('00000000-0000-4000-8000-000000000144', '00000000-0000-4000-8000-000000000083', '00000000-0000-4000-8000-000000000085', 'es_sesli'),
  ('00000000-0000-4000-8000-000000000145', '00000000-0000-4000-8000-000000000084', '00000000-0000-4000-8000-000000000085', 'es_sesli'),
  ('00000000-0000-4000-8000-000000000146', '00000000-0000-4000-8000-000000000086', '00000000-0000-4000-8000-000000000087', 'es_sesli'),
  ('00000000-0000-4000-8000-000000000151', '00000000-0000-4000-8000-000000000093', '00000000-0000-4000-8000-000000000094', 'es_sesli'),
  ('00000000-0000-4000-8000-000000000152', '00000000-0000-4000-8000-000000000095', '00000000-0000-4000-8000-000000000096', 'es_sesli'),
  ('00000000-0000-4000-8000-000000000153', '00000000-0000-4000-8000-000000000097', '00000000-0000-4000-8000-000000000098', 'es_sesli') on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 3. Sorular: kelime_sorulari (48 kayıt, hepsi TASLAK)
-- ---------------------------------------------------------------------
insert into public.kelime_sorulari (
  id, anlam_id, iliski_turu, sinif, zorluk, soru_metni, secenekler, dogru_indeks,
  dogru_anlam_id, ipucu, aciklama, durum
) values
  ('00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000001', 'es_anlamli', 3, 1, 'Mutlu kelimesinin eş anlamlısı hangisidir?',
   '["Sevinçli","Üzgün","Sessiz"]'::jsonb, 0, '00000000-0000-4000-8000-000000000002', 'Sevinç duygusunu düşün.', 'Mutlu ve sevinçli, sevinç duyan anlamında eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000202', '00000000-0000-4000-8000-000000000003', 'es_anlamli', 4, 1, 'Akıllı kelimesinin eş anlamlısı hangisidir?',
   '["Yorgun","Zeki","Aç"]'::jsonb, 1, '00000000-0000-4000-8000-000000000004', 'Düşünme ve öğrenme gücüne bak.', 'Akıllı ve zeki, zihni çabuk çalışan kişiyi anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000203', '00000000-0000-4000-8000-000000000005', 'es_anlamli', 2, 1, 'Hızlı kelimesinin eş anlamlısı hangisidir?',
   '["Yavaş","Kısa","Çabuk"]'::jsonb, 2, '00000000-0000-4000-8000-000000000006', 'Bir hareketin ne kadar sürede olduğuna bak.', 'Hızlı ve çabuk, bir işin kısa sürede yapıldığını ya da hareketin çabuk olduğunu anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000204', '00000000-0000-4000-8000-000000000008', 'es_anlamli', 4, 1, 'Güzel kelimesinin eş anlamlısı hangisidir?',
   '["Hoş","Çirkin","Büyük"]'::jsonb, 0, '00000000-0000-4000-8000-000000000009', 'Gözü okşayan bir şeyi düşün.', 'Güzel ve hoş, beğenilen ve hoşa giden şeyleri anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000205', '00000000-0000-4000-8000-000000000010', 'es_anlamli', 6, 2, 'Ünlü kelimesinin eş anlamlısı hangisidir?',
   '["Bilinmeyen","Meşhur","Yalnız"]'::jsonb, 1, '00000000-0000-4000-8000-000000000011', 'Herkesin tanıdığı birini düşün.', 'Ünlü ve meşhur, adı çok bilinen kişiyi anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000206', '00000000-0000-4000-8000-000000000012', 'es_anlamli', 6, 2, 'Özlem kelimesinin eş anlamlısı hangisidir?',
   '["Sevinç","Öfke","Hasret"]'::jsonb, 2, '00000000-0000-4000-8000-000000000013', 'Birine kavuşamadığında hissettiğin duyguyu düşün.', 'Özlem ve hasret, bir kişiye ya da yere kavuşamamanın verdiği duyguyu anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000207', '00000000-0000-4000-8000-000000000014', 'es_anlamli', 5, 2, 'Katı kelimesinin eş anlamlısı hangisidir?',
   '["Sert","Yumuşak","Sıcak"]'::jsonb, 0, '00000000-0000-4000-8000-000000000015', 'Kolay eğilmeyen bir maddeyi düşün.', 'Katı ve sert, kolay eğilmeyen ve şekil değiştirmeyen şeyleri anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000208', '00000000-0000-4000-8000-000000000016', 'es_anlamli', 5, 2, 'Doygun kelimesinin eş anlamlısı hangisidir?',
   '["Aç","Tok","Susuz"]'::jsonb, 1, '00000000-0000-4000-8000-000000000017', 'Karnı yeterince dolmuş birini düşün.', 'Doygun ve tok, yeterince yemek yiyip karnı doymuş olmayı anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000209', '00000000-0000-4000-8000-000000000018', 'es_anlamli', 7, 3, 'Kusur kelimesinin eş anlamlısı hangisidir?',
   '["Erdem","Başarı","Hata"]'::jsonb, 2, '00000000-0000-4000-8000-000000000019', 'Bir işte yapılan yanlışı düşün.', 'Kusur ve hata, yapılan yanlışı ya da eksikliği anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000210', '00000000-0000-4000-8000-000000000020', 'es_anlamli', 5, 2, 'Gizli kelimesinin eş anlamlısı hangisidir?',
   '["Saklı","Açık","Belli"]'::jsonb, 0, '00000000-0000-4000-8000-000000000021', 'Göze görünmeyen, örtülü bir şeyi düşün.', 'Gizli ve saklı, göze görünmeyen ya da örtülü olan şeyleri anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000211', '00000000-0000-4000-8000-000000000022', 'es_anlamli', 7, 3, 'Öğretmen kelimesinin eş anlamlısı hangisidir?',
   '["Doktor","Muallim","Berber"]'::jsonb, 1, '00000000-0000-4000-8000-000000000023', 'Derste öğrencilere bilgi veren kişiyi düşün.', 'Öğretmen ve muallim, öğrencileri yetiştiren kişiyi anlatan eş anlamlı kelimelerdir. Muallim eski bir kullanımdır.', 'taslak'),
  ('00000000-0000-4000-8000-000000000212', '00000000-0000-4000-8000-000000000024', 'es_anlamli', 7, 3, 'Zarar kelimesinin eş anlamlısı hangisidir?',
   '["Fayda","Kazanç","Hasar"]'::jsonb, 2, '00000000-0000-4000-8000-000000000025', 'Bir şeyin bozulup değer kaybetmesini düşün.', 'Zarar ve hasar, bir şeyin bozulmasına ya da kayıp yaşanmasına neden olan durumu anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000213', '00000000-0000-4000-8000-000000000026', 'es_anlamli', 6, 2, 'Cesaret kelimesinin eş anlamlısı hangisidir?',
   '["Yürek","Korku","Üzüntü"]'::jsonb, 0, '00000000-0000-4000-8000-000000000027', 'Korkuya karşı duran iç gücünü düşün.', 'Cesaret ve yürek, korkmadan bir şeyle yüzleşme gücünü anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000214', '00000000-0000-4000-8000-000000000028', 'es_anlamli', 8, 3, 'Eleştiri kelimesinin eş anlamlısı hangisidir?',
   '["Övgü","Tenkit","Kutlama"]'::jsonb, 1, '00000000-0000-4000-8000-000000000029', 'Bir şeyin iyi ve kötü yanlarını değerlendirmeyi düşün.', 'Eleştiri ve tenkit, bir eseri ya da davranışı inceleyip değerlendirme anlamında eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000215', '00000000-0000-4000-8000-000000000030', 'es_anlamli', 6, 2, 'Eski kelimesinin eş anlamlısı hangisidir?',
   '["Yeni","Genç","Kadim"]'::jsonb, 2, '00000000-0000-4000-8000-000000000031', 'Çok uzun zamandır var olan bir şeyi düşün.', 'Eski ve kadim, uzun zamandan beri var olan ya da zamanı geçmiş şeyleri anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000216', '00000000-0000-4000-8000-000000000032', 'es_anlamli', 7, 3, 'Sabır kelimesinin eş anlamlısı hangisidir?',
   '["Tahammül","Acele","Öfke"]'::jsonb, 0, '00000000-0000-4000-8000-000000000033', 'Zor bir durumda beklemeyi ve dayanmayı düşün.', 'Sabır ve tahammül, zorluklara karşı dayanma gücünü anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000217', '00000000-0000-4000-8000-000000000034', 'es_anlamli', 8, 3, 'Şifa kelimesinin eş anlamlısı hangisidir?',
   '["Hastalık","Deva","Acı"]'::jsonb, 1, '00000000-0000-4000-8000-000000000035', 'Hastayı iyileştiren şeyi düşün.', 'Şifa ve deva, hastalıktan kurtarma ya da iyileştirme anlamında eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000218', '00000000-0000-4000-8000-000000000036', 'es_anlamli', 6, 2, 'Yoksul kelimesinin eş anlamlısı hangisidir?',
   '["Zengin","Varlıklı","Fakir"]'::jsonb, 2, '00000000-0000-4000-8000-000000000037', 'Geliri az olan bir kişiyi düşün.', 'Yoksul ve fakir, geliri az ve maddi olanakları sınırlı kişileri anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000219', '00000000-0000-4000-8000-000000000038', 'es_anlamli', 5, 2, 'Vatan kelimesinin eş anlamlısı hangisidir?',
   '["Yurt","Dağ","Deniz"]'::jsonb, 0, '00000000-0000-4000-8000-000000000039', 'İnsanın doğup yaşadığı ülkeyi düşün.', 'Vatan ve yurt, insanın doğup yaşadığı ülkeyi anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000220', '00000000-0000-4000-8000-000000000040', 'es_anlamli', 4, 1, 'Yanıt kelimesinin eş anlamlısı hangisidir?',
   '["Soru","Cevap","Kalem"]'::jsonb, 1, '00000000-0000-4000-8000-000000000041', 'Bir soruya verilen karşılığı düşün.', 'Yanıt ve cevap, bir soruya verilen karşılığı anlatan eş anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000221', '00000000-0000-4000-8000-000000000042', 'zit_anlamli', 2, 1, 'Sıcak kelimesinin zıt anlamlısı hangisidir?',
   '["Kuru","Yaş","Soğuk"]'::jsonb, 2, '00000000-0000-4000-8000-000000000043', 'Buzdolabındaki yiyeceklerin durumunu düşün.', 'Sıcak ve soğuk, ısıları birbirinin tersi olan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000222', '00000000-0000-4000-8000-000000000044', 'zit_anlamli', 2, 1, 'Uzun kelimesinin zıt anlamlısı hangisidir?',
   '["Kısa","Geniş","Dar"]'::jsonb, 0, '00000000-0000-4000-8000-000000000045', 'Bir ipin boyuna bak.', 'Uzun ve kısa, boyu ya da süresi birbirinin tersi olan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000223', '00000000-0000-4000-8000-000000000046', 'zit_anlamli', 2, 1, 'Büyük kelimesinin zıt anlamlısı hangisidir?',
   '["Ağır","Küçük","Hafif"]'::jsonb, 1, '00000000-0000-4000-8000-000000000047', 'Bir fil ile bir karıncayı düşün.', 'Büyük ve küçük, boyca ya da miktarca birbirinin zıddı olan kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000224', '00000000-0000-4000-8000-000000000005', 'zit_anlamli', 3, 1, 'Hızlı kelimesinin zıt anlamlısı hangisidir?',
   '["Sessiz","Kısa","Yavaş"]'::jsonb, 2, '00000000-0000-4000-8000-000000000007', 'Hareketin hızının karşıtını düşün.', 'Hızlı ve yavaş, hareketin hızını birbirinin tersi anlamda anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000225', '00000000-0000-4000-8000-000000000048', 'zit_anlamli', 3, 1, 'İyi kelimesinin zıt anlamlısı hangisidir?',
   '["Kötü","Uzun","Büyük"]'::jsonb, 0, '00000000-0000-4000-8000-000000000049', 'Olumlu bir davranışın karşısını düşün.', 'İyi ve kötü, olumlu ile olumsuz anlamları taşıyan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000226', '00000000-0000-4000-8000-000000000050', 'zit_anlamli', 2, 1, 'Açık kelimesinin zıt anlamlısı hangisidir?',
   '["Dolu","Kapalı","Sıcak"]'::jsonb, 1, '00000000-0000-4000-8000-000000000051', 'Bir kapının durumuna bak.', 'Açık ve kapalı, bir şeyin kapalı olmayan ya da kapatılmış hâlini anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000227', '00000000-0000-4000-8000-000000000052', 'zit_anlamli', 3, 1, 'Dolu kelimesinin zıt anlamlısı hangisidir?',
   '["Yüksek","Ağır","Boş"]'::jsonb, 2, '00000000-0000-4000-8000-000000000053', 'Bir bardağın içine bak.', 'Dolu ve boş, içinde bir şey olan ile hiçbir şey olmayan durumu anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000228', '00000000-0000-4000-8000-000000000054', 'zit_anlamli', 5, 2, 'Zengin kelimesinin zıt anlamlısı hangisidir?',
   '["Yoksul","Mutlu","Akıllı"]'::jsonb, 0, '00000000-0000-4000-8000-000000000036', 'Maddi durumu iyi olmayan birini düşün.', 'Zengin ve yoksul, maddi durumu iyi ve kötü olan kişileri anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000229', '00000000-0000-4000-8000-000000000055', 'zit_anlamli', 3, 1, 'Kolay kelimesinin zıt anlamlısı hangisidir?',
   '["Hızlı","Zor","Güzel"]'::jsonb, 1, '00000000-0000-4000-8000-000000000056', 'Zahmetsiz bir işin tersini düşün.', 'Kolay ve zor, bir işin zahmetli olup olmadığını anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000230', '00000000-0000-4000-8000-000000000057', 'zit_anlamli', 4, 1, 'Yüksek kelimesinin zıt anlamlısı hangisidir?',
   '["Derin","Uzun","Alçak"]'::jsonb, 2, '00000000-0000-4000-8000-000000000058', 'Yerden ne kadar uzakta olduğunu düşün.', 'Yüksek ve alçak, bir şeyin yerden uzaklığını anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000231', '00000000-0000-4000-8000-000000000059', 'zit_anlamli', 6, 2, 'Cesur kelimesinin zıt anlamlısı hangisidir?',
   '["Korkak","Dürüst","Yorgun"]'::jsonb, 0, '00000000-0000-4000-8000-000000000060', 'Tehlikeye korkmadan atılan birini düşün.', 'Cesur ve korkak, korku karşısındaki tutumları birbirine zıt olan kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000232', '00000000-0000-4000-8000-000000000061', 'zit_anlamli', 4, 1, 'Düz kelimesinin zıt anlamlısı hangisidir?',
   '["Yatay","Eğri","Ağır"]'::jsonb, 1, '00000000-0000-4000-8000-000000000062', 'Bir cetvelin şekline bak.', 'Düz ve eğri, bir çizginin ya da yüzeyin bükük olup olmadığını anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000233', '00000000-0000-4000-8000-000000000063', 'zit_anlamli', 4, 1, 'Gürültülü kelimesinin zıt anlamlısı hangisidir?',
   '["Kalabalık","Sıcak","Sessiz"]'::jsonb, 2, '00000000-0000-4000-8000-000000000064', 'Çok ses çıkan bir ortamı düşün.', 'Gürültülü ve sessiz, ses düzeyi yüksek ile düşük olan ortamları anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000234', '00000000-0000-4000-8000-000000000065', 'zit_anlamli', 5, 2, 'Kibar kelimesinin zıt anlamlısı hangisidir?',
   '["Kaba","Neşeli","Yaşlı"]'::jsonb, 0, '00000000-0000-4000-8000-000000000066', 'Konuşurken saygılı davranan birini düşün.', 'Kibar ve kaba, davranışta nezaket ile nezaketsizliği anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000235', '00000000-0000-4000-8000-000000000067', 'zit_anlamli', 4, 1, 'Çalışkan kelimesinin zıt anlamlısı hangisidir?',
   '["Kısa","Tembel","Neşeli"]'::jsonb, 1, '00000000-0000-4000-8000-000000000068', 'İşini özenle yapan birinin zıttını düşün.', 'Çalışkan ve tembel, bir işi isteyerek ve özenle yapma tutumunu anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000236', '00000000-0000-4000-8000-000000000069', 'zit_anlamli', 7, 3, 'Masum kelimesinin zıt anlamlısı hangisidir?',
   '["Dürüst","Yaramaz","Suçlu"]'::jsonb, 2, '00000000-0000-4000-8000-000000000070', 'Bir suç işleyip işlemediğine bak.', 'Masum ve suçlu, bir suç işleyip işlemediğini anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000237', '00000000-0000-4000-8000-000000000071', 'zit_anlamli', 7, 3, 'Üretim kelimesinin zıt anlamlısı hangisidir?',
   '["Tüketim","Satış","Yaşam"]'::jsonb, 0, '00000000-0000-4000-8000-000000000072', 'Bir fabrikanın ne yaptığını düşün.', 'Üretim ve tüketim, mal ya da hizmet oluşturmak ile bunları kullanıp bitirmek anlamında zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000238', '00000000-0000-4000-8000-000000000073', 'zit_anlamli', 6, 2, 'Çoğaltmak kelimesinin zıt anlamlısı hangisidir?',
   '["Yapmak","Azaltmak","Koşmak"]'::jsonb, 1, '00000000-0000-4000-8000-000000000074', 'Bir şeyin sayısının artmasını düşün.', 'Çoğaltmak ve azaltmak, bir şeyin sayısını artırma ile düşürme anlamında zıt anlamlı fiillerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000239', '00000000-0000-4000-8000-000000000075', 'zit_anlamli', 7, 3, 'Çekici kelimesinin zıt anlamlısı hangisidir?',
   '["Yorucu","Uzun","İtici"]'::jsonb, 2, '00000000-0000-4000-8000-000000000076', 'Albeni yapan bir şeyin karşıtını düşün.', 'Çekici ve itici, insanı kendine çeken ile uzaklaştıran anlamındaki zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000240', '00000000-0000-4000-8000-000000000077', 'zit_anlamli', 8, 3, 'Kesinlik kelimesinin zıt anlamlısı hangisidir?',
   '["Belirsizlik","Yorgunluk","Hız"]'::jsonb, 0, '00000000-0000-4000-8000-000000000078', 'Bir durumun ne kadar emin olunabildiğini düşün.', 'Kesinlik ve belirsizlik, bir durumun ne kadar emin olunabildiğini anlatan zıt anlamlı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000241', '00000000-0000-4000-8000-000000000079', 'es_sesli', 2, 1, 'Yaz kelimesinin mevsim dışında aldığı, aynı yazılışlı bir anlam hangisidir?',
   '["Yazmak: harflerle iz bırakmak","Kış: en soğuk mevsim","Bahar: çiçeklerin açtığı mevsim"]'::jsonb, 0, '00000000-0000-4000-8000-000000000080', 'Bu kelimeyle yapılan bir işi düşün.', 'Yaz hem mevsimi hem de yazmak eylemini anlatır; aynı yazılışlı, anlamları farklı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000242', '00000000-0000-4000-8000-000000000081', 'es_sesli', 3, 1, 'Gül kelimesinin çiçek dışında aldığı, aynı yazılışlı bir anlam hangisidir?',
   '["Ağlamak: gözyaşı dökmek","Gülmek: neşeyle ses çıkarmak","Düşmek: yerden kalkamamak"]'::jsonb, 1, '00000000-0000-4000-8000-000000000082', 'Sevinçli bir yüz ifadesini düşün.', 'Gül hem hoş kokulu bir çiçeği hem de gülmek eylemini anlatır; aynı yazılışlı, anlamları farklı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000243', '00000000-0000-4000-8000-000000000083', 'es_sesli', 3, 1, 'Yüz kelimesinin insan yüzü dışında aldığı, aynı yazılışlı bir anlam hangisidir?',
   '["Kırmızı renk","Denizde yaşayan bir balık","Doksan dokuzun bir fazlası"]'::jsonb, 2, '00000000-0000-4000-8000-000000000084', 'Sayılardan birini düşün.', 'Yüz hem insanın yüzünü hem de 100 sayısını anlatır; aynı yazılışlı, anlamları farklı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000244', '00000000-0000-4000-8000-000000000083', 'es_sesli', 4, 1, 'Yüz kelimesinin insan yüzü dışında aldığı, aynı yazılışlı bir anlam hangisidir?',
   '["Yüzmek: suda ilerlemek","Kırmızı renk","Sıcak su"]'::jsonb, 0, '00000000-0000-4000-8000-000000000085', 'Suyla ilgili bir eylemi düşün.', 'Yüz hem insan yüzünü hem de yüzmek eylemini anlatır; aynı yazılışlı, anlamları farklı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000245', '00000000-0000-4000-8000-000000000086', 'es_sesli', 5, 2, 'Çekiç kelimesinin alet dışında aldığı, aynı yazılışlı bir anlam hangisidir?',
   '["Ağaçtan yapılmış bir kapı","Başı çekiç biçiminde olan bir deniz balığı","Kalın bir ip"]'::jsonb, 1, '00000000-0000-4000-8000-000000000087', 'Denizde yaşayan canlılara bak.', 'Çekiç hem çiviyi çakmaya yarayan aleti hem de bir deniz balığını anlatır; aynı yazılışlı, anlamları farklı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000246', '00000000-0000-4000-8000-000000000093', 'es_sesli', 3, 1, 'Dil kelimesinin ağız içindeki organ dışında aldığı, aynı yazılışlı bir anlam hangisidir?',
   '["Kulak: duyma organı","Gözlük: göz için bir araç","Bir toplumun konuşup anlaştığı sözcük sistemi"]'::jsonb, 2, '00000000-0000-4000-8000-000000000094', 'İnsanların birbirleriyle konuşmasını düşün.', 'Dil hem ağız içindeki bir organı hem de bir toplumun konuştuğu sözcük sistemini anlatır; aynı yazılışlı, anlamları farklı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000247', '00000000-0000-4000-8000-000000000095', 'es_sesli', 4, 1, 'Al kelimesinin kırmızı renk dışında aldığı, aynı yazılışlı bir anlam hangisidir?',
   '["Bir şeyi eline geçirmek, almak","Yeşil renk","Mavi renk"]'::jsonb, 0, '00000000-0000-4000-8000-000000000096', 'Bir eylemle ilgili bir anlamına bak.', 'Al hem kırmızı rengi hem de almak eylemini anlatır; aynı yazılışlı, anlamları farklı kelimelerdir.', 'taslak'),
  ('00000000-0000-4000-8000-000000000248', '00000000-0000-4000-8000-000000000097', 'es_sesli', 5, 2, 'Göz kelimesinin görme organı dışında aldığı, aynı yazılışlı bir anlam hangisidir?',
   '["Kulak: duyma organı","Yerin altından su çıkan kaynak","Burun: koku organı"]'::jsonb, 1, '00000000-0000-4000-8000-000000000098', 'Doğada bir su kaynağına bak.', 'Göz hem görmeye yarayan organı hem de yerden su çıkan kaynağı anlatır; aynı yazılışlı, anlamları farklı kelimelerdir.', 'taslak') on conflict (id) do nothing;

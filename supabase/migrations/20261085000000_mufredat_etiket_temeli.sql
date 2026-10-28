-- =====================================================================
--  Müfredat etiket temeli (WP1) — docs/mufredat/PLAN_HAFTA_ETIKETLEME.md §4.1, §5
--  Proje : Hupo · 2026-10-24
--  Kapsam:
--    1) mufredat_ders_eslesme  : questions.ders → mufredat_hafta.ders eşlemesi
--    2) mufredat_takvim        : 2026-27 okul haftaları (37) + tatiller (101–104)
--    3) mufredat_bugun_hafta() : verilen tarihin okul haftası (Europe/Istanbul)
--    4) mufredat_kazanim_ozet  : kazanım başına ilk/son hafta (security_invoker)
--    5) questions indeksi      : (sinif, kazanim_kodu)
--  Kaynaklar:
--    docs/mufredat/okul_haftalari_2026_2027.csv  (44 satır → 37 hafta; ayıklama notu aşağıda)
--    docs/mufredat/takvim_notlari_2026_2027.csv  (tatil metinleri)
--  Ayıklama notu (okul_haftalari CSV'si): 7 satır atıldı; her hafta için
--  Pazartesi ile başlayan satır seçildi (Salı/Perşembe başlayan kopyalar atıldı):
--    hafta 3 (2026-09-22), 14 (2026-12-15), 23 (2027-03-02), 29 (2027-04-20),
--    32 (2027-05-11 ve 2027-05-20), 37 (2027-06-22).
--  Tatiller (takvim_notlari ile birlikte): 1. dönem ara 16–20 Kas 2026;
--    yarıyıl 25 Oca–5 Şub 2027; 2. dönem ara 8–12 Mar 2027; Kurban Bayramı 16–19 May 2027
--    (notlarda 15–18 / 17–18 varyantları var; PLAN'daki 16–19 kullanıldı).
--  Uzak veritabanına uygulanmadan önce Sonnet kontrolü gerekir.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Ders eşleme (soru dersi → müfredat dersi)
-- ---------------------------------------------------------------------
create table if not exists public.mufredat_ders_eslesme (
  soru_ders     text primary key,
  mufredat_ders text not null
);

comment on table public.mufredat_ders_eslesme is
  'questions.ders (serbest metin) → mufredat_hafta.ders eşlemesi. Eşleşmeyen ders burada YOKTUR (tahmin edilmez).';

alter table public.mufredat_ders_eslesme enable row level security;

drop policy if exists mufredat_ders_eslesme_okuma on public.mufredat_ders_eslesme;
create policy mufredat_ders_eslesme_okuma on public.mufredat_ders_eslesme
  for select to authenticated using (true);

revoke all on public.mufredat_ders_eslesme from public, anon, authenticated;
grant select on public.mufredat_ders_eslesme to authenticated;
grant select, insert, update, delete on public.mufredat_ders_eslesme to service_role;

insert into public.mufredat_ders_eslesme (soru_ders, mufredat_ders) values
  ('Fen Bilimleri',                    'Fen Bilimleri'),
  ('Hayat Bilgisi',                    'Hayat Bilgisi'),
  ('İngilizce',                        'İngilizce'),
  ('Matematik',                        'Matematik'),
  ('Sosyal Bilgiler',                  'Sosyal Bilgiler'),
  ('Türkçe',                           'Türkçe'),
  ('Din Kültürü ve Ahlak Bilgisi',     'Din Kültürü ve Ahlak Bilgisi')
on conflict (soru_ders) do nothing;

-- ---------------------------------------------------------------------
-- 2. 2026-27 okul takvimi
--    hafta 1–37: okul haftası (tatil_mi = false)
--    hafta 101–104: tatiller (tatil_mi = true); baslangic/bitis tatil aralığı
-- ---------------------------------------------------------------------
create table if not exists public.mufredat_takvim (
  hafta      smallint primary key,
  baslangic  date not null,
  bitis      date not null,
  tatil_mi   boolean not null default false,
  aciklama   text,
  constraint mufredat_takvim_aralik check (bitis >= baslangic),
  constraint mufredat_takvim_numara check (
    (tatil_mi = false and hafta between 1 and 99)
    or (tatil_mi = true and hafta between 101 and 199)
  )
);

comment on table public.mufredat_takvim is
  '2026-27 okul takvimi. Okul haftaları 1–37; tatiller 101+ (tatil_mi = true). Salt okunur referans.';

alter table public.mufredat_takvim enable row level security;

drop policy if exists mufredat_takvim_okuma on public.mufredat_takvim;
create policy mufredat_takvim_okuma on public.mufredat_takvim
  for select to authenticated using (true);

revoke all on public.mufredat_takvim from public, anon, authenticated;
grant select on public.mufredat_takvim to authenticated;
grant select, insert, update, delete on public.mufredat_takvim to service_role;

insert into public.mufredat_takvim (hafta, baslangic, bitis, tatil_mi, aciklama) values
  (1,  '2026-09-14', '2026-09-18', false, null),
  (2,  '2026-09-21', '2026-09-25', false, null),
  (3,  '2026-09-28', '2026-10-02', false, null),
  (4,  '2026-10-05', '2026-10-09', false, null),
  (5,  '2026-10-12', '2026-10-16', false, null),
  (6,  '2026-10-19', '2026-10-23', false, null),
  (7,  '2026-10-26', '2026-10-30', false, null),
  (8,  '2026-11-02', '2026-11-06', false, null),
  (9,  '2026-11-09', '2026-11-13', false, null),
  (10, '2026-11-23', '2026-11-27', false, null),
  (11, '2026-11-30', '2026-12-04', false, null),
  (12, '2026-12-07', '2026-12-11', false, null),
  (13, '2026-12-14', '2026-12-18', false, null),
  (14, '2026-12-21', '2026-12-25', false, null),
  (15, '2026-12-28', '2027-01-01', false, null),
  (16, '2027-01-04', '2027-01-08', false, null),
  (17, '2027-01-11', '2027-01-15', false, null),
  (18, '2027-01-18', '2027-01-22', false, null),
  (19, '2027-02-08', '2027-02-12', false, null),
  (20, '2027-02-15', '2027-02-19', false, null),
  (21, '2027-02-22', '2027-02-26', false, null),
  (22, '2027-03-01', '2027-03-05', false, null),
  (23, '2027-03-15', '2027-03-19', false, null),
  (24, '2027-03-22', '2027-03-26', false, null),
  (25, '2027-03-29', '2027-04-02', false, null),
  (26, '2027-04-05', '2027-04-09', false, null),
  (27, '2027-04-12', '2027-04-16', false, null),
  (28, '2027-04-19', '2027-04-23', false, null),
  (29, '2027-04-26', '2027-04-30', false, null),
  (30, '2027-05-03', '2027-05-07', false, null),
  (31, '2027-05-10', '2027-05-14', false, null),
  (32, '2027-05-17', '2027-05-21', false, null),
  (33, '2027-05-24', '2027-05-28', false, null),
  (34, '2027-05-31', '2027-06-04', false, null),
  (35, '2027-06-07', '2027-06-11', false, null),
  (36, '2027-06-14', '2027-06-18', false, null),
  (37, '2027-06-21', '2027-06-25', false, null),
  (101, '2026-11-16', '2026-11-20', true, '1. dönem ara tatili'),
  (102, '2027-01-25', '2027-02-05', true, 'Yarıyıl tatili'),
  (103, '2027-03-08', '2027-03-12', true, '2. dönem ara tatili'),
  (104, '2027-05-16', '2027-05-19', true, 'Kurban Bayramı tatili')
on conflict (hafta) do nothing;

-- ---------------------------------------------------------------------
-- 3. Bugünkü (verilen tarihin) okul haftası
--    - tatil günü: tatilden önceki son okul haftası
--    - okul haftası aralığı [baslangic, bitis+2]: o hafta
--    - aralık dışı: en son başlamış okul haftası; hiç başlamadıysa 1
--    Tarih null ise Europe/Istanbul'a göre bugün.
-- ---------------------------------------------------------------------
create or replace function public.mufredat_bugun_hafta(p_tarih date default null)
returns smallint
language plpgsql
stable
set search_path = ''
as $$
declare
  v_tarih           date := coalesce(p_tarih, (now() at time zone 'Europe/Istanbul')::date);
  v_tatil_baslangic date;
  v_hafta           smallint;
begin
  select t.baslangic into v_tatil_baslangic
    from public.mufredat_takvim t
   where t.tatil_mi and v_tarih between t.baslangic and t.bitis
   order by t.baslangic
   limit 1;

  if found then
    select max(s.hafta) into v_hafta
      from public.mufredat_takvim s
     where not s.tatil_mi and s.baslangic < v_tatil_baslangic;
    return coalesce(v_hafta, 1);
  end if;

  select s.hafta into v_hafta
    from public.mufredat_takvim s
   where not s.tatil_mi and v_tarih between s.baslangic and s.bitis + 2
   order by s.hafta
   limit 1;

  if found then
    return v_hafta;
  end if;

  select max(s.hafta) into v_hafta
    from public.mufredat_takvim s
   where not s.tatil_mi and s.baslangic <= v_tarih;

  return coalesce(v_hafta, 1);
end;
$$;

revoke execute on function public.mufredat_bugun_hafta(date) from public, anon;
grant  execute on function public.mufredat_bugun_hafta(date) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Kazanım özeti (2026-27; DKAB 4 ve 8 yalnız 2025-2026 kaynağında olduğu için dışarıda)
--    security_invoker = true: mufredat_hafta RLS'i çağıran kullanıcıya uygulanır.
-- ---------------------------------------------------------------------
create or replace view public.mufredat_kazanim_ozet
with (security_invoker = true) as
select h.ders,
       h.sinif,
       h.kazanim_kodu,
       min(h.hafta)                                          as ilk_hafta,
       max(h.hafta)                                          as son_hafta,
       array_agg(distinct h.hafta order by h.hafta)          as haftalar,
       min(h.kazanim_metni)                                  as kazanim_metni,
       string_agg(distinct h.unite_tema, ' / ' order by h.unite_tema) as unite_tema,
       string_agg(distinct h.konu, ' / ' order by h.konu)    as konu
  from public.mufredat_hafta h
 where h.kaynak_yili = '2026-2027'
   and h.kazanim_kodu <> ''
 group by h.ders, h.sinif, h.kazanim_kodu;

comment on view public.mufredat_kazanim_ozet is
  'Kazanım başına ilk/son işlenme haftası (2026-27). Etiketleme ve "bugüne kadar" filtresinin anahtarı.';

revoke all on public.mufredat_kazanim_ozet from public, anon, authenticated;
grant select on public.mufredat_kazanim_ozet to authenticated;

-- ---------------------------------------------------------------------
-- 5. Soru sorguları için indeks (sınıf + kazanım)
-- ---------------------------------------------------------------------
create index if not exists questions_sinif_kazanim_idx
  on public.questions (sinif, kazanim_kodu)
  where kazanim_kodu is not null;

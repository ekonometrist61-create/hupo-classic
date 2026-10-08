-- W8: Arkadaşa Meydan Oku / VS
-- Çocuk güvenliği: sohbet yok, isim yok, kod ile katılım, puanlama sunucuda.
-- dogru_sik istemciye gönderilmez.

-- =====================================================================
-- Tablolar
-- =====================================================================

create table if not exists public.meydan_okumalar (
  id              uuid primary key default gen_random_uuid(),
  kod             text unique not null,
  davet_eden      uuid not null references public.student_stats(student_id) on delete cascade,
  davet_edilen    uuid          references public.student_stats(student_id) on delete cascade,
  sorular         jsonb not null default '[]',
  sure_dakika     int  not null default 5,
  durum           text not null default 'bekliyor'
                      check (durum in ('bekliyor', 'aktif', 'bitti')),
  olusturulma     timestamptz not null default now()
);

create table if not exists public.meydan_okuma_cevaplar (
  id               uuid primary key default gen_random_uuid(),
  meydan_okuma_id  uuid not null references public.meydan_okumalar(id) on delete cascade,
  student_id       uuid not null references public.student_stats(student_id) on delete cascade,
  cevaplar         jsonb not null default '{}',
  dogru_sayisi     int  not null default 0,
  yanlis_sayisi    int  not null default 0,
  puan             numeric(6,2) not null default 0,
  bitis_zamani     timestamptz,
  unique (meydan_okuma_id, student_id)
);

alter table public.meydan_okumalar  enable row level security;
alter table public.meydan_okuma_cevaplar enable row level security;

-- Oturum açmış öğrenci kendi meydan okumalarını okuyabilir
create policy "okuma_kendi" on public.meydan_okumalar
  for select using (
    auth.uid() = davet_eden or auth.uid() = davet_edilen
  );

create policy "okuma_kendi_cevap" on public.meydan_okuma_cevaplar
  for select using (
    student_id = auth.uid()
    or meydan_okuma_id in (
      select id from public.meydan_okumalar
      where davet_eden = auth.uid() or davet_edilen = auth.uid()
    )
  );

-- Tüm erişim RPC üzerinden; direkt DML kapalı.
revoke all on public.meydan_okumalar          from public, anon, authenticated;
revoke all on public.meydan_okuma_cevaplar    from public, anon, authenticated;
grant  select on public.meydan_okumalar       to authenticated;
grant  select on public.meydan_okuma_cevaplar to authenticated;

-- =====================================================================
-- Yardımcı: 6 haneli alfanumerik kod üretir
-- =====================================================================
create or replace function _uret_meydan_kod()
returns text
language sql
security invoker
set search_path = ''
as $$
  select upper(substring(md5(gen_random_uuid()::text) from 1 for 6))
$$;

-- =====================================================================
-- create_challenge: yeni VS oluşturur, kod + sorular döner
-- =====================================================================
create or replace function public.create_challenge()
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid        uuid := auth.uid();
  v_sinif      int;
  v_kod        text;
  v_sorular    jsonb;
  v_id         uuid;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı';
  end if;

  select sinif into v_sinif from public.profiles where id = v_uid;

  -- Benzersiz kod üret (en fazla 5 deneme)
  for i in 1..5 loop
    v_kod := _uret_meydan_kod();
    exit when not exists (select 1 from public.meydan_okumalar where kod = v_kod);
  end loop;

  -- 10 sınıfa uygun soru (dogru_sik HARİÇ)
  select jsonb_agg(
    jsonb_build_object(
      'id',         q.id,
      'soru_metni', q.soru_metni,
      'siklar',     q.siklar,
      'konu',       q.konu,
      'zorluk',     q.zorluk
    )
  )
  into v_sorular
  from (
    select id, soru_metni, siklar, konu, zorluk
    from   public.questions
    where  onay_durumu = 'onaylandi'
      and  (sinif = v_sinif or sinif is null)
    order by random()
    limit 10
  ) q;

  if v_sorular is null then
    -- Sınıf kısıtı olmadan dene
    select jsonb_agg(
      jsonb_build_object(
        'id', q.id, 'soru_metni', q.soru_metni,
        'siklar', q.siklar, 'konu', q.konu, 'zorluk', q.zorluk
      )
    ) into v_sorular
    from (
      select id, soru_metni, siklar, konu, zorluk
      from public.questions
      where onay_durumu = 'onaylandi'
      order by random()
      limit 10
    ) q;
  end if;

  if v_sorular is null or jsonb_array_length(v_sorular) < 3 then
    raise exception 'Yeterli soru bulunamadı';
  end if;

  insert into public.meydan_okumalar (kod, davet_eden, sorular)
  values (v_kod, v_uid, v_sorular)
  returning id into v_id;

  return jsonb_build_object(
    'id',           v_id,
    'kod',          v_kod,
    'sorular',      v_sorular,
    'sure_dakika',  5,
    'durum',        'bekliyor'
  );
end;
$$;

revoke execute on function public.create_challenge() from public, anon;
grant  execute on function public.create_challenge() to authenticated;

-- =====================================================================
-- join_challenge: koda göre katılır, durum aktif olur
-- =====================================================================
create or replace function public.join_challenge(p_kod text)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid  uuid := auth.uid();
  v_row  public.meydan_okumalar;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı';
  end if;

  select * into v_row from public.meydan_okumalar
  where kod = upper(trim(p_kod));

  if not found then
    raise exception 'Kod bulunamadı';
  end if;
  if v_row.durum <> 'bekliyor' then
    raise exception 'Bu meydan okuma artık aktif değil';
  end if;
  if v_row.davet_eden = v_uid then
    raise exception 'Kendi meydan okumanına katılamazsın';
  end if;

  update public.meydan_okumalar
  set davet_edilen = v_uid, durum = 'aktif'
  where id = v_row.id;

  return jsonb_build_object(
    'id',          v_row.id,
    'kod',         v_row.kod,
    'sorular',     v_row.sorular,
    'sure_dakika', v_row.sure_dakika,
    'durum',       'aktif'
  );
end;
$$;

revoke execute on function public.join_challenge(text) from public, anon;
grant  execute on function public.join_challenge(text) to authenticated;

-- =====================================================================
-- submit_challenge: cevapları puanlar, bitti olarak işaretler
-- Puanlama: dogru×4 - yanlis×1 (YKS stili), min 0
-- =====================================================================
create or replace function public.submit_challenge(
  p_meydan_id uuid,
  p_cevaplar  jsonb   -- [{question_id: uuid, secilen_sik: text|null}]
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid        uuid := auth.uid();
  v_row        public.meydan_okumalar;
  v_dogru      int := 0;
  v_yanlis     int := 0;
  v_puan       numeric;
  v_cevap      jsonb;
  v_dogru_sik  text;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı';
  end if;

  select * into v_row from public.meydan_okumalar where id = p_meydan_id;

  if not found then
    raise exception 'Meydan okuma bulunamadı';
  end if;
  if v_uid <> v_row.davet_eden and v_uid <> v_row.davet_edilen then
    raise exception 'Bu meydan okumaya erişim yok';
  end if;
  if v_row.durum = 'bekliyor' then
    raise exception 'Meydan okuma henüz başlamadı';
  end if;

  -- Zaten gönderilmişse idempotent dön
  if exists (
    select 1 from public.meydan_okuma_cevaplar
    where meydan_okuma_id = p_meydan_id and student_id = v_uid
      and bitis_zamani is not null
  ) then
    select jsonb_build_object(
      'dogru_sayisi', dogru_sayisi,
      'yanlis_sayisi', yanlis_sayisi,
      'puan', puan
    ) into v_cevap
    from public.meydan_okuma_cevaplar
    where meydan_okuma_id = p_meydan_id and student_id = v_uid;
    return v_cevap;
  end if;

  -- Puanlama: DB'den dogru_sik oku
  for v_cevap in select * from jsonb_array_elements(p_cevaplar) loop
    select dogru_sik into v_dogru_sik
    from public.questions
    where id = (v_cevap->>'question_id')::uuid;

    if (v_cevap->>'secilen_sik') is not null then
      if (v_cevap->>'secilen_sik') = v_dogru_sik then
        v_dogru := v_dogru + 1;
      else
        v_yanlis := v_yanlis + 1;
      end if;
    end if;
  end loop;

  v_puan := greatest(0, v_dogru * 4 - v_yanlis);

  insert into public.meydan_okuma_cevaplar
    (meydan_okuma_id, student_id, cevaplar, dogru_sayisi, yanlis_sayisi, puan, bitis_zamani)
  values
    (p_meydan_id, v_uid, p_cevaplar, v_dogru, v_yanlis, v_puan, now())
  on conflict (meydan_okuma_id, student_id)
  do update set
    cevaplar     = excluded.cevaplar,
    dogru_sayisi = excluded.dogru_sayisi,
    yanlis_sayisi = excluded.yanlis_sayisi,
    puan         = excluded.puan,
    bitis_zamani = excluded.bitis_zamani;

  -- Her iki oyuncu da bitirdiyse meydan okumayı kapat
  if (
    select count(*) from public.meydan_okuma_cevaplar
    where meydan_okuma_id = p_meydan_id and bitis_zamani is not null
  ) >= 2 then
    update public.meydan_okumalar set durum = 'bitti' where id = p_meydan_id;
  end if;

  return jsonb_build_object(
    'dogru_sayisi',  v_dogru,
    'yanlis_sayisi', v_yanlis,
    'puan',          v_puan
  );
end;
$$;

revoke execute on function public.submit_challenge(uuid, jsonb) from public, anon;
grant  execute on function public.submit_challenge(uuid, jsonb) to authenticated;

-- =====================================================================
-- get_challenge_result: sonuçları döner (her iki oyuncunun puanı)
-- Rakip adı gösterilmez — sadece "sen" vs "rakibin"
-- =====================================================================
create or replace function public.get_challenge_result(p_meydan_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid  uuid := auth.uid();
  v_row  public.meydan_okumalar;
  v_ben  jsonb;
  v_rakip jsonb;
begin
  if v_uid is null then
    raise exception 'Oturum bulunamadı';
  end if;

  select * into v_row from public.meydan_okumalar where id = p_meydan_id;

  if not found then
    raise exception 'Meydan okuma bulunamadı';
  end if;
  if v_uid <> v_row.davet_eden and v_uid <> v_row.davet_edilen then
    raise exception 'Bu meydan okumaya erişim yok';
  end if;

  select jsonb_build_object(
    'dogru', dogru_sayisi, 'yanlis', yanlis_sayisi, 'puan', puan, 'bitti', bitis_zamani is not null
  ) into v_ben
  from public.meydan_okuma_cevaplar
  where meydan_okuma_id = p_meydan_id and student_id = v_uid;

  select jsonb_build_object(
    'dogru', dogru_sayisi, 'yanlis', yanlis_sayisi, 'puan', puan, 'bitti', bitis_zamani is not null
  ) into v_rakip
  from public.meydan_okuma_cevaplar
  where meydan_okuma_id = p_meydan_id and student_id <> v_uid;

  return jsonb_build_object(
    'id',     p_meydan_id,
    'durum',  v_row.durum,
    'kod',    v_row.kod,
    'ben',    coalesce(v_ben, 'null'::jsonb),
    'rakip',  coalesce(v_rakip, 'null'::jsonb)
  );
end;
$$;

revoke execute on function public.get_challenge_result(uuid) from public, anon;
grant  execute on function public.get_challenge_result(uuid) to authenticated;

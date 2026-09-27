-- =====================================================================
-- Günlük hedef, seri kalkanı ve gizlilik (KVKK) altyapısı
--
--  * Günlük hedef: günde 5/10/15/20 soru. Seriden BAĞIMSIZDIR; öğrenci veya velisi belirler.
--  * Seri kalkanı: yalnızca ÇALIŞARAK kazanılır (her 7. seri gününde +1, en fazla 2).
--    Bir gün ara verilirse otomatik kullanılır ve seri korunur. Satılmaz, alınmaz.
--  * Gizlilik: aydınlatma okundu kaydı, veli açık rızası (verme/geri çekme),
--    verileri dışa aktarma ve hesabı silme.
--
--  NOT: Aydınlatma/açık rıza METİNLERİ ve hangi yaşta hangi rızanın gerektiği
--  hukuki değerlendirme gerektirir; bu dosya yalnızca kayıt ve hak kullanımı altyapısıdır.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. student_stats: günlük hedef + seri kalkanı
-- ---------------------------------------------------------------------
alter table public.student_stats
  add column if not exists gunluk_hedef integer not null default 10
    check (gunluk_hedef in (5, 10, 15, 20)),
  add column if not exists seri_kalkani integer not null default 0
    check (seri_kalkani between 0 and 2);

-- ---------------------------------------------------------------------
-- 2. XP / seri fonksiyonu: seri kalkanı mantığı
-- ---------------------------------------------------------------------
create or replace function public.award_xp_and_streak(
  p_student_id  uuid,
  p_zorluk      smallint,
  p_xp_ver      boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_today      date := (now() at time zone 'Europe/Istanbul')::date;
  v_xp         integer;
  s            record;
  v_yeni_seri  integer;
  v_kalkan     integer;
  v_kullanildi boolean := false;
  v_kazanildi  boolean := false;
  v_stats      public.student_stats%rowtype;
begin
  v_xp := case p_zorluk when 1 then 10 when 2 then 20 when 3 then 30 end;
  if v_xp is null then
    raise exception 'Geçersiz zorluk: % (1, 2 veya 3 olmalı)', p_zorluk using errcode = '22023';
  end if;
  if not p_xp_ver then
    v_xp := 0;
  end if;

  insert into public.student_stats (student_id) values (p_student_id)
  on conflict (student_id) do nothing;

  -- Yeni haftaya geçildiyse önce geçen haftanın ligini sonuçlandır
  perform public.resolve_league_week(p_student_id);

  if v_xp > 0 then
    insert into public.xp_events (student_id, xp) values (p_student_id, v_xp);
  end if;

  select streak_count, last_active_date, seri_kalkani
    into s
    from public.student_stats
   where student_id = p_student_id
   for update;

  -- Seri: bugün zaten aktifse aynı; dünse +1; tam bir gün ara verilmişse ve kalkan varsa
  -- kalkan kullanılıp +1; aksi halde yeniden 1'den başlar.
  v_kalkan := s.seri_kalkani;
  if s.last_active_date = v_today then
    v_yeni_seri := greatest(s.streak_count, 1);
  elsif s.last_active_date = v_today - 1 then
    v_yeni_seri := s.streak_count + 1;
  elsif s.last_active_date = v_today - 2 and s.seri_kalkani > 0 then
    v_yeni_seri := s.streak_count + 1;
    v_kalkan := v_kalkan - 1;
    v_kullanildi := true;
  else
    v_yeni_seri := 1;
  end if;

  -- Her 7. seri gününde (seri bugün arttıysa) yeni kalkan, en fazla 2
  if s.last_active_date is distinct from v_today
     and v_yeni_seri % 7 = 0
     and v_kalkan < 2 then
    v_kalkan := v_kalkan + 1;
    v_kazanildi := true;
  end if;

  update public.student_stats
     set xp = xp + v_xp,
         level = ((xp + v_xp) / 100) + 1,           -- 100 XP = 1 seviye
         streak_count = v_yeni_seri,
         last_active_date = v_today,
         seri_kalkani = v_kalkan,
         en_uzun_seri = greatest(en_uzun_seri, v_yeni_seri)
   where student_id = p_student_id
  returning * into v_stats;

  if v_kullanildi then
    insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
    values (p_student_id, 'bilgi', 'Seri kalkanın devreye girdi!',
            'Dün ara verdin ama kalkanın serini korudu. Böyle devam!', 'shield');
  end if;
  if v_kazanildi then
    insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
    values (p_student_id, 'bilgi', 'Seri kalkanı kazandın!',
            format('%s günlük serin sayesinde bir kalkan kazandın. Bir gün ara verirsen serin kaybolmaz.', v_yeni_seri),
            'shield');
  end if;

  return jsonb_build_object(
    'kazanilan_xp',     v_xp,
    'xp',               v_stats.xp,
    'level',            v_stats.level,
    'streak_count',     v_stats.streak_count,
    'last_active_date', v_stats.last_active_date,
    'seri_kalkani',     v_stats.seri_kalkani
  );
end;
$$;

revoke execute on function public.award_xp_and_streak(uuid, smallint, boolean)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. Günlük hedef
-- ---------------------------------------------------------------------

-- Hedefi belirle: p_student_id boşsa kendi hedefi; doluysa (veli) çocuğunun hedefi.
create or replace function public.set_daily_goal(
  p_hedef       integer,
  p_student_id  uuid default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := (select auth.uid());
  v_hedef  uuid := coalesce(p_student_id, (select auth.uid()));
begin
  if v_uid is null or not (v_hedef = v_uid or public.is_parent_of(v_hedef)) then
    raise exception 'Bu öğrencinin hedefini değiştirme yetkiniz yok' using errcode = '42501';
  end if;
  if p_hedef is null or p_hedef not in (5, 10, 15, 20) then
    raise exception 'Günlük hedef 5, 10, 15 veya 20 olmalı' using errcode = '22023';
  end if;

  insert into public.student_stats (student_id, gunluk_hedef) values (v_hedef, p_hedef)
  on conflict (student_id) do update set gunluk_hedef = excluded.gunluk_hedef;
end;
$$;

-- Bugünkü ilerleme
create or replace function public.get_daily_goal(p_student_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := (select auth.uid());
  v_bugun  date := (now() at time zone 'Europe/Istanbul')::date;
  v_hedef  integer;
  v_kalkan integer;
  v_sayi   integer;
begin
  if v_uid is null
     or not (v_uid = p_student_id or public.is_parent_of(p_student_id)) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  select gunluk_hedef, seri_kalkani into v_hedef, v_kalkan
    from public.student_stats where student_id = p_student_id;

  select count(*)::integer into v_sayi
    from public.answer_events
   where student_id = p_student_id
     and (created_at at time zone 'Europe/Istanbul')::date = v_bugun;

  return jsonb_build_object(
    'hedef',         coalesce(v_hedef, 10),
    'bugun',         v_sayi,
    'tamamlandi',    v_sayi >= coalesce(v_hedef, 10),
    'seri_kalkani',  coalesce(v_kalkan, 0)
  );
end;
$$;

-- Hedefe ulaşılınca (gün içinde tam bir kez) bildirim
create or replace function public.notify_daily_goal()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_hedef integer;
  v_sayi  integer;
begin
  select gunluk_hedef into v_hedef from public.student_stats where student_id = new.student_id;
  if not found then
    return new;
  end if;

  select count(*)::integer into v_sayi
    from public.answer_events
   where student_id = new.student_id
     and (created_at at time zone 'Europe/Istanbul')::date
         = (new.created_at at time zone 'Europe/Istanbul')::date;

  if v_sayi = v_hedef then
    insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
    values (new.student_id, 'bilgi', 'Günlük hedefini tamamladın!',
            format('Bugün %s soru çözdün. Harika bir iş çıkardın!', v_hedef), 'flag');
  end if;
  return new;
end;
$$;

create trigger answer_events_notify_goal
  after insert on public.answer_events
  for each row execute function public.notify_daily_goal();

revoke execute on function public.notify_daily_goal() from public, anon, authenticated;
revoke execute on function public.set_daily_goal(integer, uuid) from public, anon;
revoke execute on function public.get_daily_goal(uuid) from public, anon;
grant  execute on function public.set_daily_goal(integer, uuid) to authenticated;
grant  execute on function public.get_daily_goal(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 3b. Koruma düzeltmesi: veli hesabı silinirken çocuğun parent_id'si otomatik boşalır
--     (FK ON DELETE SET NULL, silen kullanıcının oturumuyla çalışır). Bu güncellemenin
--     engellenmemesi için: veli, KENDİ çocuğunun parent_id değerini NULL yapabilir.
--     Başka birine bağlamak, rol ve id değiştirmek ve sosyal ayarlar yine yasaktır.
-- ---------------------------------------------------------------------
create or replace function public.profiles_guard_immutable()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if auth.uid() is not null then
    if new.id <> old.id or new.role <> old.role then
      raise exception 'role istemci tarafından değiştirilemez' using errcode = '42501';
    end if;

    if new.parent_id is distinct from old.parent_id
       and not (new.parent_id is null and old.parent_id = auth.uid()) then
      raise exception 'parent_id istemci tarafından değiştirilemez' using errcode = '42501';
    end if;

    if (new.sosyal_ozellikler_acik is distinct from old.sosyal_ozellikler_acik
        or new.arkadas_ekleme_acik is distinct from old.arkadas_ekleme_acik)
       and old.parent_id is distinct from auth.uid() then
      raise exception 'Sosyal özellik ayarlarını yalnızca çocuğun velisi değiştirebilir'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------
-- 4. Gizlilik: onay kayıtları
-- ---------------------------------------------------------------------
create table public.consents (
  id          uuid primary key default gen_random_uuid(),
  cocuk_id    uuid not null references public.profiles (id) on delete cascade,
  veli_id     uuid references public.profiles (id) on delete set null,
  tur         text not null
                check (tur in ('aydinlatma_okundu', 'veli_acik_riza', 'veli_riza_geri_cekildi')),
  surum       text not null,
  created_at  timestamptz not null default clock_timestamp()  -- aynı işlemde bile sıralanabilir
);

create index consents_cocuk_time_idx on public.consents (cocuk_id, created_at desc);

alter table public.consents enable row level security;

create policy "consents_select"
  on public.consents for select to authenticated
  using (cocuk_id = (select auth.uid()) or public.is_parent_of(cocuk_id));

revoke all on public.consents from anon;
revoke insert, update, delete on public.consents from authenticated;

-- Çocuk/öğrenci aydınlatma metnini okudu (aynı sürüm için tek kayıt)
create or replace function public.record_notice_read(p_surum text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;
  if p_surum is null or length(trim(p_surum)) = 0 then
    raise exception 'Sürüm gerekli' using errcode = '22023';
  end if;

  if not exists (
    select 1 from public.consents
     where cocuk_id = v_uid and tur = 'aydinlatma_okundu' and surum = p_surum
  ) then
    insert into public.consents (cocuk_id, tur, surum) values (v_uid, 'aydinlatma_okundu', p_surum);
  end if;
end;
$$;

-- Veli, çocuğu için açık rıza verir / geri çeker (geri çekmek vermek kadar kolaydır)
create or replace function public.set_parental_consent(
  p_cocuk_id  uuid,
  p_surum     text,
  p_veriyor   boolean
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi rıza kaydı oluşturabilir' using errcode = '42501';
  end if;
  if p_surum is null or length(trim(p_surum)) = 0 then
    raise exception 'Sürüm gerekli' using errcode = '22023';
  end if;

  insert into public.consents (cocuk_id, veli_id, tur, surum)
  values (p_cocuk_id, v_uid,
          case when p_veriyor then 'veli_acik_riza' else 'veli_riza_geri_cekildi' end,
          p_surum);
end;
$$;

-- Durum: aydınlatma okundu mu (verilen sürüm için) + en son veli rızası
create or replace function public.get_consent_status(p_cocuk_id uuid, p_surum text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := (select auth.uid());
  r      record;
begin
  if v_uid is null
     or not (v_uid = p_cocuk_id or public.is_parent_of(p_cocuk_id)) then
    raise exception 'Bu öğrencinin verilerine erişim yetkiniz yok' using errcode = '42501';
  end if;

  select tur, surum, created_at into r
    from public.consents
   where cocuk_id = p_cocuk_id and tur in ('veli_acik_riza', 'veli_riza_geri_cekildi')
   order by created_at desc, id desc
   limit 1;

  return jsonb_build_object(
    'aydinlatma_okundu', exists (
      select 1 from public.consents
       where cocuk_id = p_cocuk_id and tur = 'aydinlatma_okundu' and surum = p_surum),
    'veli_riza', case
                   when r.tur is null then 'yok'
                   when r.tur = 'veli_acik_riza' then 'verildi'
                   else 'geri_cekildi'
                 end,
    'veli_riza_surum', r.surum,
    'veli_riza_tarih', r.created_at
  );
end;
$$;

-- ---------------------------------------------------------------------
-- 5. Veri hakları: dışa aktarma ve hesabı silme (yalnızca kendi verisi)
-- ---------------------------------------------------------------------
create or replace function public.export_my_data()
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
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;

  return jsonb_build_object(
    'olusturulma_tarihi', now(),
    'profil', (
      select jsonb_build_object(
               'id', p.id, 'rol', p.role, 'ad_soyad', p.full_name,
               'kullanici_adi', p.username, 'sinif', p.sinif, 'okul', p.okul,
               'veli_id', p.parent_id, 'uyelik_tarihi', p.created_at,
               'sosyal_ozellikler_acik', p.sosyal_ozellikler_acik,
               'arkadas_ekleme_acik', p.arkadas_ekleme_acik)
        from public.profiles p where p.id = v_uid),
    'istatistikler', (
      select to_jsonb(s) - 'student_id' from public.student_stats s where s.student_id = v_uid),
    'cevaplar', coalesce((
      select jsonb_agg(jsonb_build_object(
               'soru_id', ua.question_id, 'secilen_sik', ua.secilen_sik,
               'dogru_mu', ua.dogru_mu, 'deneme_sayisi', ua.deneme_sayisi,
               'dogru_sayisi', ua.dogru_sayisi, 'son_cevap_tarihi', ua.son_cevap_tarihi)
             order by ua.son_cevap_tarihi)
        from public.user_answers ua where ua.student_id = v_uid), '[]'::jsonb),
    'rozetler', coalesce((
      select jsonb_agg(jsonb_build_object('rozet', b.badge_code, 'tarih', b.earned_at))
        from public.user_badges b where b.student_id = v_uid), '[]'::jsonb),
    'bildirimler', coalesce((
      select jsonb_agg(jsonb_build_object(
               'tur', n.tur, 'baslik', n.baslik, 'mesaj', n.mesaj, 'tarih', n.created_at)
             order by n.created_at)
        from public.notifications n where n.alici_id = v_uid), '[]'::jsonb),
    'xp_gecmisi', coalesce((
      select jsonb_agg(jsonb_build_object('xp', x.xp, 'tarih', x.created_at) order by x.created_at)
        from public.xp_events x where x.student_id = v_uid), '[]'::jsonb),
    'onaylar', coalesce((
      select jsonb_agg(jsonb_build_object('tur', c.tur, 'surum', c.surum, 'tarih', c.created_at)
             order by c.created_at)
        from public.consents c where c.cocuk_id = v_uid), '[]'::jsonb)
  );
end;
$$;

-- Hesabı ve bağlı tüm verileri siler (geri alınamaz). Profil ve ilişkili tablolar
-- auth.users'a bağlı ON DELETE CASCADE ile temizlenir. Veli hesabı silinirse çocukların
-- parent_id değeri boşalır, çocuk hesapları silinmez.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;
  delete from auth.users where id = v_uid;
end;
$$;

revoke execute on function public.record_notice_read(text)                 from public, anon;
revoke execute on function public.set_parental_consent(uuid, text, boolean) from public, anon;
revoke execute on function public.get_consent_status(uuid, text)           from public, anon;
revoke execute on function public.export_my_data()                         from public, anon;
revoke execute on function public.delete_my_account()                      from public, anon;
grant  execute on function public.record_notice_read(text)                 to authenticated;
grant  execute on function public.set_parental_consent(uuid, text, boolean) to authenticated;
grant  execute on function public.get_consent_status(uuid, text)           to authenticated;
grant  execute on function public.export_my_data()                         to authenticated;
grant  execute on function public.delete_my_account()                      to authenticated;

-- =====================================================================
-- Faz 4: gerçek profil birleştirme
--
-- Admin bir adayı 'merged' olarak onayladığında:
--   * Ana profil = daha önce oluşturulan hesap (created_at, eşitlikte id).
--   * Kaynak profilin deneme ve katılım kayıtları ana profile taşınır.
--     Aynı sınavda iki kayıt varsa tamamlanmış olan (ve yüksek puanlı) kalır.
--   * Her birleştirme identity_merge_log'a yazılır (denetim izi).
--   * Kaynak profil silinmez. Yeni sınav işlemleri ana profil üzerinden yürür.
--
-- Bu migration'ın KAPSAMI DIŞINDA kalanlar (ayrı karar gerekir):
--   XP/seviye/rozet/görev/karakter/growth verileri ve veli onay (consents) kayıtları
--   kaynak profilde kalır.
-- =====================================================================

create table if not exists public.identity_merge_log (
  id              bigint generated always as identity primary key,
  candidate_id    uuid references public.identity_merge_candidates (id) on delete set null,
  kaynak_id       uuid not null unique references public.profiles (id) on delete cascade,
  hedef_id        uuid not null references public.profiles (id) on delete cascade,
  tasinan_deneme  integer not null default 0,
  silinen_deneme  integer not null default 0,
  tasinan_katilim integer not null default 0,
  silinen_katilim integer not null default 0,
  islem_yapan     uuid references public.profiles (id) on delete set null,
  created_at      timestamptz not null default now(),

  constraint identity_merge_log_farkli check (kaynak_id <> hedef_id)
);

comment on table public.identity_merge_log is
  'Profil birleştirme denetim kaydı. Yalnızca birleştirme RPC''leri yazar; istemci erişemez.';

alter table public.identity_merge_log enable row level security;
revoke all on table public.identity_merge_log from public, anon, authenticated;

create or replace function public.deneme_ana_profil(p_ogrenci uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select l.hedef_id from public.identity_merge_log l where l.kaynak_id = p_ogrenci),
    p_ogrenci
  );
$$;

revoke execute on function public.deneme_ana_profil(uuid) from public, anon, authenticated, service_role;

create or replace function public._kimlik_birlestir(p_candidate_id uuid, p_islem_yapan uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_cand    public.identity_merge_candidates%rowtype;
  v_hedef   uuid;
  v_kaynak  uuid;
  v_r       record;
  v_hedef_d public.deneme_sinavi_denemeleri%rowtype;
  v_tas_d   integer := 0;
  v_sil_d   integer := 0;
  v_tas_k   integer := 0;
  v_sil_k   integer := 0;
begin
  select * into v_cand from public.identity_merge_candidates where id = p_candidate_id;
  if not found then
    raise exception 'Aday bulunamadı' using errcode = 'P0002';
  end if;

  if exists (
    select 1 from public.identity_merge_log
     where kaynak_id in (v_cand.student_a_id, v_cand.student_b_id)
  ) then
    raise exception 'Bu profillerden biri zaten birleştirilmiş' using errcode = '22023';
  end if;

  select p.id into v_hedef
    from public.profiles p
   where p.id in (v_cand.student_a_id, v_cand.student_b_id)
   order by p.created_at asc, p.id asc
   limit 1;
  v_kaynak := case when v_hedef = v_cand.student_a_id then v_cand.student_b_id else v_cand.student_a_id end;

  for v_r in select d.* from public.deneme_sinavi_denemeleri d where d.student_id = v_kaynak loop
    select * into v_hedef_d
      from public.deneme_sinavi_denemeleri
     where exam_id = v_r.exam_id and student_id = v_hedef;

    if not found then
      update public.deneme_sinavi_denemeleri set student_id = v_hedef where id = v_r.id;
      v_tas_d := v_tas_d + 1;
    elsif v_r.bitis_zamani is not null
      and (v_hedef_d.bitis_zamani is null or v_r.puan > v_hedef_d.puan) then
      delete from public.deneme_sinavi_denemeleri where id = v_hedef_d.id;
      update public.deneme_sinavi_denemeleri set student_id = v_hedef where id = v_r.id;
      v_tas_d := v_tas_d + 1;
      v_sil_d := v_sil_d + 1;
    else
      delete from public.deneme_sinavi_denemeleri where id = v_r.id;
      v_sil_d := v_sil_d + 1;
    end if;
  end loop;

  for v_r in select k.* from public.deneme_sinavi_katilimlari k where k.student_id = v_kaynak loop
    if exists (
      select 1 from public.deneme_sinavi_katilimlari
       where exam_id = v_r.exam_id and student_id = v_hedef
    ) then
      delete from public.deneme_sinavi_katilimlari where id = v_r.id;
      v_sil_k := v_sil_k + 1;
    else
      update public.deneme_sinavi_katilimlari set student_id = v_hedef where id = v_r.id;
      v_tas_k := v_tas_k + 1;
    end if;
  end loop;

  insert into public.identity_merge_log (
    candidate_id, kaynak_id, hedef_id,
    tasinan_deneme, silinen_deneme, tasinan_katilim, silinen_katilim, islem_yapan
  ) values (
    p_candidate_id, v_kaynak, v_hedef,
    v_tas_d, v_sil_d, v_tas_k, v_sil_k, p_islem_yapan
  );
end;
$$;

revoke execute on function public._kimlik_birlestir(uuid, uuid) from public, anon, authenticated, service_role;

create or replace function public.admin_resolve_merge_candidate(
  p_candidate_id uuid,
  p_action text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.profiles where id = v_uid and role = 'admin'
  ) then
    raise exception 'Yalnızca yöneticiler erişebilir' using errcode = '42501';
  end if;
  if p_action not in ('merged', 'distinct', 'ignored') then
    raise exception 'Geçersiz karar: merged, distinct veya ignored olmalı' using errcode = '22023';
  end if;

  update public.identity_merge_candidates
     set resolved = true,
         resolved_action = p_action,
         resolved_by = v_uid,
         resolved_at = now()
   where id = p_candidate_id and not resolved;

  if not found then
    raise exception 'Aday bulunamadı veya zaten çözümlenmiş' using errcode = 'P0002';
  end if;

  if p_action = 'merged' then
    perform public._kimlik_birlestir(p_candidate_id, v_uid);
  end if;
end;
$$;

revoke execute on function public.admin_resolve_merge_candidate(uuid, text) from public, anon, authenticated, service_role;
grant  execute on function public.admin_resolve_merge_candidate(uuid, text) to authenticated;

create or replace function public.admin_list_merge_candidates()
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
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.profiles where id = v_uid and role = 'admin'
  ) then
    raise exception 'Yalnızca yöneticiler erişebilir' using errcode = '42501';
  end if;

  return coalesce((
    select jsonb_agg(row_data order by row_data->>'created_at' desc)
      from (
        select jsonb_build_object(
          'id',         mc.id,
          'reason',     mc.match_reason,
          'confidence', mc.confidence,
          'created_at', mc.created_at,
          'ogrenci_a', jsonb_build_object(
            'id', pa.id, 'ad', pa.full_name, 'sinif', pa.sinif, 'username', pa.username
          ),
          'ogrenci_b', jsonb_build_object(
            'id', pb.id, 'ad', pb.full_name, 'sinif', pb.sinif, 'username', pb.username
          )
        ) as row_data
          from public.identity_merge_candidates mc
          join public.profiles pa on pa.id = mc.student_a_id
          join public.profiles pb on pb.id = mc.student_b_id
         where not mc.resolved
           and not exists (
             select 1 from public.identity_merge_log l
              where l.kaynak_id in (mc.student_a_id, mc.student_b_id)
           )
      ) t
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.admin_list_merge_candidates() from public, anon, authenticated, service_role;
grant  execute on function public.admin_list_merge_candidates() to authenticated;

create or replace function public.start_mock_exam_attempt(p_exam_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid       uuid := (select auth.uid());
  v_exam      public.deneme_sinavlari%rowtype;
  v_sinif     smallint;
  v_bitis     timestamptz;
  v_deneme_id uuid;
  v_sorular   jsonb;
begin
  if v_uid is null then
    raise exception 'Giriş gerekli' using errcode = '42501';
  end if;
  if exists (select 1 from public.identity_merge_log where kaynak_id = v_uid) then
    raise exception 'Bu hesap başka bir hesapla birleştirildi; sınava ana hesabınızla girin' using errcode = '42501';
  end if;

  select * into v_exam from public.deneme_sinavlari where id = p_exam_id;
  if not found or not v_exam.aktif then
    raise exception 'Sınav bulunamadı' using errcode = 'P0002';
  end if;

  v_bitis := public._deneme_bitis_zamani(v_exam);
  if now() < v_exam.baslangic_zamani then
    raise exception 'Bu sınav henüz başlamadı' using errcode = '42501';
  end if;
  if now() >= v_bitis then
    raise exception 'Bu sınavın süresi doldu' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = v_uid;
  if v_sinif is null or v_sinif <> all (v_exam.siniflar) then
    raise exception 'Bu sınav sizin sınıfınız için açık değil' using errcode = '22023';
  end if;

  if not exists (
    select 1 from public.deneme_sinavi_katilimlari where exam_id = p_exam_id and student_id = v_uid
  ) then
    raise exception 'Önce veli panelinden bu sınava kaydolmalısınız' using errcode = '42501';
  end if;

  if exists (
    select 1 from public.deneme_sinavi_denemeleri where exam_id = p_exam_id and student_id = v_uid
  ) then
    raise exception 'Bu sınava zaten başladınız, tekrar giremezsiniz' using errcode = '42501';
  end if;

  insert into public.deneme_sinavi_denemeleri (exam_id, student_id, sinif, started_at)
  values (p_exam_id, v_uid, v_sinif, now())
  returning id into v_deneme_id;

  select coalesce(jsonb_agg(to_jsonb(x) order by x.sira), '[]'::jsonb) into v_sorular
    from (
      select s.sira, q.id, q.ders, q.konu, q.zorluk, q.soru_metni, q.siklar
        from public.deneme_sinavi_sorulari s
        join public.questions q on q.id = s.question_id
       where s.exam_id = p_exam_id and s.sinif = v_sinif
    ) x;

  return jsonb_build_object(
    'deneme_id',    v_deneme_id,
    'bitis_zamani', v_bitis,
    'sure_dakika',  v_exam.sure_dakika,
    'sorular',      v_sorular
  );
end;
$$;

revoke execute on function public.start_mock_exam_attempt(uuid) from public, anon, authenticated, service_role;
grant  execute on function public.start_mock_exam_attempt(uuid) to authenticated;
grant  execute on function public.start_mock_exam_attempt(uuid) to service_role;

create or replace function public.register_for_mock_exam(p_exam_id uuid, p_cocuk_id uuid, p_telefon text, p_surum text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := (select auth.uid());
  v_exam public.deneme_sinavlari%rowtype;
  v_sinif smallint;
  v_ana  uuid := public.deneme_ana_profil(p_cocuk_id);
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi kayıt yapabilir' using errcode = '42501';
  end if;
  if p_telefon is null or length(trim(p_telefon)) < 7 or length(trim(p_telefon)) > 20 then
    raise exception 'Geçerli bir telefon numarası girin' using errcode = '22023';
  end if;

  select * into v_exam from public.deneme_sinavlari where id = p_exam_id;
  if not found or not v_exam.aktif then
    raise exception 'Sınav bulunamadı' using errcode = 'P0002';
  end if;
  if now() >= v_exam.baslangic_zamani then
    raise exception 'Bu sınav için kayıtlar kapandı' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = p_cocuk_id;
  if v_sinif is null or v_sinif <> all (v_exam.siniflar) then
    raise exception 'Bu sınav öğrencinin sınıfı için açık değil' using errcode = '22023';
  end if;

  if not exists (
    select 1 from public.consents
     where cocuk_id = p_cocuk_id and tur = 'sinav_pazarlama_izni' and surum = p_surum
  ) then
    raise exception 'Önce pazarlama/KVKK onayı verilmeli' using errcode = '42501';
  end if;

  insert into public.deneme_sinavi_katilimlari (exam_id, student_id, veli_id, telefon)
  values (p_exam_id, v_ana, v_uid, trim(p_telefon))
  on conflict (exam_id, student_id) do update set telefon = excluded.telefon;

  update public.profiles set telefon = trim(p_telefon) where id = v_ana;
end;
$$;

revoke execute on function public.register_for_mock_exam(uuid, uuid, text, text) from public, anon, authenticated, service_role;
grant  execute on function public.register_for_mock_exam(uuid, uuid, text, text) to authenticated;
grant  execute on function public.register_for_mock_exam(uuid, uuid, text, text) to service_role;

create or replace function public.get_upcoming_mock_exams_for_child(p_cocuk_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := (select auth.uid());
  v_sinif smallint;
  v_ana  uuid := public.deneme_ana_profil(p_cocuk_id);
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi görüntüleyebilir' using errcode = '42501';
  end if;

  select sinif into v_sinif from public.profiles where id = p_cocuk_id;

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.baslangic_zamani)
      from (
        select e.id, e.ad, e.baslangic_zamani, e.sure_dakika,
               (k.id is not null) as kayitli,
               coalesce(k.telefon, p.telefon, '') as telefon
          from public.deneme_sinavlari e
          left join public.deneme_sinavi_katilimlari k
                 on k.exam_id = e.id and k.student_id = v_ana
          left join public.profiles p on p.id = v_ana
         where e.aktif
           and e.baslangic_zamani > now()
           and v_sinif = any (e.siniflar)
      ) x
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.get_upcoming_mock_exams_for_child(uuid) from public, anon, authenticated, service_role;
grant  execute on function public.get_upcoming_mock_exams_for_child(uuid) to authenticated;
grant  execute on function public.get_upcoming_mock_exams_for_child(uuid) to service_role;

create or replace function public.get_child_exam_history(p_cocuk_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_ana uuid := public.deneme_ana_profil(p_cocuk_id);
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi görüntüleyebilir' using errcode = '42501';
  end if;

  return coalesce((
    select jsonb_agg(row_data order by (row_data->>'tarih') desc)
      from (
        select jsonb_build_object(
          'sinav_id',        e.id,
          'sinav_ad',        e.ad,
          'tarih',           e.baslangic_zamani,
          'bitis_zamani',    d.bitis_zamani,
          'sinif',           d.sinif,
          'puan',            d.puan,
          'dogru',           d.dogru_sayisi,
          'yanlis',          d.yanlis_sayisi,
          'bos',             d.bos_sayisi,
          'teslim_turu',     d.teslim_turu,
          'sira', (
            select count(*) + 1
              from public.deneme_sinavi_denemeleri d2
             where d2.exam_id = d.exam_id
               and d2.sinif = d.sinif
               and d2.bitis_zamani is not null
               and d2.puan > d.puan
          ),
          'sinif_katilimci', (
            select count(*)
              from public.deneme_sinavi_denemeleri d3
             where d3.exam_id = d.exam_id
               and d3.sinif = d.sinif
               and d3.bitis_zamani is not null
          )
        ) as row_data
          from public.deneme_sinavi_denemeleri d
          join public.deneme_sinavlari e on e.id = d.exam_id
         where d.student_id = v_ana
           and d.bitis_zamani is not null
      ) t
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.get_child_exam_history(uuid) from public, anon, authenticated, service_role;
grant  execute on function public.get_child_exam_history(uuid) to authenticated;
grant  execute on function public.get_child_exam_history(uuid) to service_role;

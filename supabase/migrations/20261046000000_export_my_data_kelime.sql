-- GÖR-046 ikinci parça (K-0027): veri dışa aktarma Kelime Evreni tablolarını kapsar.
-- Mevcut export_my_data gövdesi korunur; yalnızca 'kelime' anahtarı eklenir.
-- Yalnızca kullanıcının kendi satırları okunur (auth.uid()). Kelime kayıtları yalnız id'lerle
-- ve kelime/anlam metni olmadan dönülür; veri yapısı mevcut alanlarla uyumlu kalır.

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
        from public.consents c where c.cocuk_id = v_uid), '[]'::jsonb),
    'kelime', jsonb_build_object(
      'denemeler', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'soru_id', d.soru_id, 'anlam_id', d.anlam_id,
                 'secilen_indeks', d.secilen_indeks, 'dogru_mu', d.dogru_mu,
                 'ipucu_kullanildi', d.ipucu_kullanildi, 'kazanilan_xp', d.kazanilan_xp,
                 'tarih', d.created_at)
               order by d.created_at)
          from public.kelime_denemeleri d where d.ogrenci_id = v_uid), '[]'::jsonb),
      'ustaliklar', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'anlam_id', u.anlam_id, 'beceri', u.beceri,
                 'basari_seviyesi', u.basari_seviyesi,
                 'sonraki_tekrar_tarihi', u.sonraki_tekrar_tarihi,
                 'son_cevap_tarihi', u.son_cevap_tarihi)
               order by u.guncellendi)
          from public.kelime_ustaliklari u where u.ogrenci_id = v_uid), '[]'::jsonb),
      'kaydedilenler', coalesce((
        select jsonb_agg(jsonb_build_object('anlam_id', k.anlam_id, 'tarih', k.created_at)
                         order by k.created_at)
          from public.kelime_kaydedilenler k where k.ogrenci_id = v_uid), '[]'::jsonb)
    )
  );
end;
$$;

revoke execute on function public.export_my_data() from public, anon;
grant  execute on function public.export_my_data() to authenticated;

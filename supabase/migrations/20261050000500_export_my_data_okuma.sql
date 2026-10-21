-- Okuma Dünyası: veri dışa aktarma 'okuma' anahtarıyla genişler (önceki tanım: 20261046000000).
-- Mevcut tüm anahtarlar ve güvenlik kalıbı (security definer, sabit search_path, revoke/grant) aynen korunur;
-- yalnızca çağıranın kendi okuma verisi eklenir.

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
    ),
    'okuma', jsonb_build_object(
      -- Yalnızca çağıranın kendi satırları. Soru anahtarı (doğru şık / açıklama) ve iç anahtarlar
      -- (istemci_anahtari, sürüm kimliği, XP bayrakları, veli kimliği) dışarı çıkmaz;
      -- cevapta yalnızca çocuğun seçtiği şık ve sonucu ('dogru_mu') bulunur.
      'oturumlari', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'oturum_id', o.id, 'hikaye', h.slug, 'kahraman_turu', o.kahraman_turu,
                 'yoldas_var', o.yoldas_var, 'okuma_modu', o.okuma_modu, 'sinif', o.sinif, 'gun', o.gun,
                 'baslangic', o.baslangic_at, 'son_sayfa', o.son_sayfa, 'tamamlandi', o.tamamlandi_at,
                 'soru_sayisi', o.soru_sayisi, 'dogru_sayisi', o.dogru_sayisi,
                 'beceri_sonuclari', o.beceri_sonuclari, 'dokunulan_hedefler', o.dokunulan_hedefler,
                 'kazanilan_xp', o.kazanilan_xp)
               order by o.baslangic_at)
          from public.okuma_oturumlari o
          join public.okuma_hikayeleri h on h.id = o.hikaye_id
         where o.ogrenci_id = v_uid), '[]'::jsonb),
      'cevaplari', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'oturum_id', c.oturum_id, 'soru_id', c.soru_id, 'secilen_sik', c.secenek_id,
                 'dogru_mu', c.dogru, 'beceri', c.beceri, 'hedef_id', c.hedef_id,
                 'olcme_turu', c.olcme_turu, 'tarih', c.created_at)
               order by c.created_at, c.soru_id)
          from public.okuma_cevaplari c
          join public.okuma_oturumlari o on o.id = c.oturum_id
         where o.ogrenci_id = v_uid), '[]'::jsonb),
      'geri_bildirimleri', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'oturum_id', g.oturum_id, 'yildiz', g.yildiz, 'iyilestirme_kodlari', g.iyilestirme_kodlari,
                 'baska_kahraman', g.baska_kahraman, 'ayni_turden', g.ayni_turden,
                 'sorun_kodlari', g.sorun_kodlari, 'tarih', g.created_at)
               order by g.created_at)
          from public.okuma_geri_bildirimleri g
          join public.okuma_oturumlari o on o.id = g.oturum_id
         where o.ogrenci_id = v_uid), '[]'::jsonb),
      'ogrenci_hedef_durumu', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'hedef_id', d.hedef_id, 'durum', d.durum, 'ilk_gorulme', d.ilk_gorulme_at,
                 'son_dogru', d.son_dogru_at, 'tekrar', d.tekrar_at, 'hata_turu', d.hata_turu)
               order by d.ilk_gorulme_at, d.hedef_id)
          from public.okuma_ogrenci_hedef_durumu d where d.ogrenci_id = v_uid), '[]'::jsonb),
      'pdf_kullanimlari', coalesce((
        select jsonb_agg(jsonb_build_object('hikaye', h.slug, 'ay', u.ay, 'tarih', u.created_at)
                         order by u.created_at)
          from public.okuma_pdf_kullanimlari u
          join public.okuma_hikayeleri h on h.id = u.hikaye_id
         where u.kullanici_id = v_uid), '[]'::jsonb),
      'cocuk_tercihleri', (
        select jsonb_build_object('degerler', t.degerler, 'guncellendi', t.guncellendi_at)
          from public.okuma_cocuk_tercihleri t where t.cocuk_id = v_uid)
    )
  );
end;
$$;

revoke execute on function public.export_my_data() from public, anon;
grant  execute on function public.export_my_data() to authenticated;

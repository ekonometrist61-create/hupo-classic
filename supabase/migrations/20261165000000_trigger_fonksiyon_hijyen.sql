-- Migration: 20261165000000
-- GÖR-095 karar (4): trigger fonksiyonlarının EXECUTE yetkisi kapatılıyor.
--
-- NEDEN?
--   Trigger fonksiyonları doğrudan çağrılamaz ("trigger functions can only be
--   called as triggers"). Trigger'lar çalışırken EXECUTE yetkisi aranmaz; yetki
--   yalnızca CREATE TRIGGER anında kontrol edilir. Bu yüzden revoke, trigger
--   davranışını değiştirmez. Ama PUBLIC'e açık kalması gereksiz bir yüzeydir.
--
-- KAPSAM DIŞI (bilerek):
--   * set_updated_at, tr_normalize, hafta_baslangic: GÖR-095 drift maddesi.
--     Canlı yetki durumu repoyla uyuşmuyor, kaynak bulunamadı. Kaynak
--     netleşmeden dokunulmaz (tr_normalize anon'dan kapanırsa kayıt akışı kırılabilir).
--     Repoda zaten 20260927000120 ile revoke edilmişler.
--   * _anket_katilim_gosterim (20261161) ve _anketler_soru_tavani (20261162):
--     migrasyonları sahibi belirsiz. Bu migrasyonlar sahipleri netleşmeden
--     uygulanmadığı için bu fonksiyonlar da hijyen kapsamına alınmadı.
--
-- Not: PUBLIC, anon ve authenticated'den kaldırılır; service_role ve owner dokunulmaz.
-- Trigger tetiklemesi bundan etkilenmez.

revoke execute on function public._abonelik_paket_surum()                from public, anon, authenticated;
revoke execute on function public._anket_surum_degismez()                from public, anon, authenticated;
revoke execute on function public._anketler_kod_kilidi()                 from public, anon, authenticated;
revoke execute on function public._anketler_surum_kaydi()                from public, anon, authenticated;
revoke execute on function public._anketler_yayin_oncesi()               from public, anon, authenticated;
revoke execute on function public._growth_mesaj_sayac()                  from public, anon, authenticated;
revoke execute on function public._growth_tetik_abonelik()               from public, anon, authenticated;
revoke execute on function public._growth_tetik_abonelik_iptal()         from public, anon, authenticated;
revoke execute on function public._growth_tetik_aday()                   from public, anon, authenticated;
revoke execute on function public._growth_tetik_cevap_guncelle()         from public, anon, authenticated;
revoke execute on function public._growth_tetik_cevap_ilk()              from public, anon, authenticated;
revoke execute on function public._growth_tetik_eslestirme_kodu()        from public, anon, authenticated;
revoke execute on function public._growth_tetik_odeme()                  from public, anon, authenticated;
revoke execute on function public._growth_tetik_on_kayit()               from public, anon, authenticated;
revoke execute on function public._growth_tetik_profil()                 from public, anon, authenticated;
revoke execute on function public._kayit_iletisim_izni()                 from public, anon, authenticated;
revoke execute on function public._okuma_surum_koru()                    from public, anon, authenticated;
revoke execute on function public._tercih_gecmisi_degistirilemez()       from public, anon, authenticated;
revoke execute on function public.badges_after_change()                  from public, anon, authenticated;
revoke execute on function public.characters_after_change()              from public, anon, authenticated;
revoke execute on function public.create_student_stats()                 from public, anon, authenticated;
revoke execute on function public.deneme_sinav_kapisi()                  from public, anon, authenticated;
revoke execute on function public.deneme_sinir_tetik()                   from public, anon, authenticated;
revoke execute on function public.deneme_veli_profili_ekle()             from public, anon, authenticated;
revoke execute on function public.enforce_quiz_quota()                   from public, anon, authenticated;
revoke execute on function public.enqueue_push()                         from public, anon, authenticated;
revoke execute on function public.handle_new_user()                      from public, anon, authenticated;
revoke execute on function public.log_answer_event()                     from public, anon, authenticated;
revoke execute on function public.notify_badge_earned()                  from public, anon, authenticated;
revoke execute on function public.notify_daily_goal()                    from public, anon, authenticated;
revoke execute on function public.notify_level_up()                      from public, anon, authenticated;
revoke execute on function public.profiles_guard_immutable()             from public, anon, authenticated;
revoke execute on function public.profiles_validate_parent()             from public, anon, authenticated;
revoke execute on function public.push_disable_on_consent_withdrawn()    from public, anon, authenticated;
revoke execute on function public.questions_ajan_kapisi()                from public, anon, authenticated;
revoke execute on function public.questions_highlights_aralik_kontrol()  from public, anon, authenticated;
revoke execute on function public.questions_highlights_metin_degisti()   from public, anon, authenticated;

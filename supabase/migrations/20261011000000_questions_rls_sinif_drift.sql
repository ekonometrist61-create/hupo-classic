-- =====================================================================
--  CANLI DRIFT KAPATMA: questions RLS politikasına sınıf şartı
--
--  NEDEN GEREKLİ:
--    Canlı veritabanında (ccozfrpnvyrnktpffkwo) `questions` üzerindeki
--    `questions_select_approved` politikası, yerel ilk şemada yazıldığından
--    FARKLI olarak şu şartı içeriyor:
--
--        using (onay_durumu = 'onaylandi' AND sinif = public.my_sinif())
--
--    Yani öğrenci yalnızca KENDİ sınıfına kayıtlı soruları görebiliyor.
--    Bu şart diskteki hiçbir migration'da bulunmuyordu (canlıda elle/Navicat
--    ile eklenmiş görünüyor). Bu dosya, canlı tanımı yerel zincire birebir
--    alarak `supabase db reset` sonrası yerel ile canlının aynı davranmasını
--    sağlar.
--
--  BAĞIMLILIK:
--    public.my_sinif()  → 20260927000080_sinif_sorgu_ve_veli_degisikligi.sql
--    public.questions   → 20260920000000_initial_schema.sql
--
--  BİRİBİRLİK:
--    Aşağıdaki politika gövdesi canlıdan `pg_get_expr(polqual, polrelid)`
--    ile alınmıştır:
--      ((onay_durumu = 'onaylandi'::text) AND (sinif = ( SELECT my_sinif() AS my_sinif)))
--    Roller: {authenticated} | polcmd: SELECT (r) | permissive: true
-- =====================================================================
-- Canlıdaki tanımla birebir aynı politikayı yeniden oluştur.
drop policy if exists "questions_select_approved" on public.questions;
create policy "questions_select_approved" on public.questions for
select to authenticated using (
    onay_durumu = 'onaylandi'
    and sinif = public.my_sinif()
  );
comment on policy "questions_select_approved" on public.questions is 'Öğrenci yalnızca onaylı VE kendi sınıfına (profiles.sinif) kayıtlı soruları okur.';
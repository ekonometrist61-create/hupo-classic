-- Migration: 20261166000000
-- GÖR-095 drift onarımı: set_updated_at(), tr_normalize(text), hafta_baslangic()
-- yetkileri.
--
-- DURUM (uygulanmadı; kullanıcı onayı ve db:deploy bekliyor):
--   Repodaki 20260927000120_yardimci_fonksiyon_yetkileri.sql bu üç fonksiyonun
--   EXECUTE yetkilerini kapatmak için yazıldı. 2026-11-08 salt okuma kontrolünde
--   canlıda anon hâlâ EXECUTE'a sahipti. Uzak migration kaydında 20260927000120
--   işlenmiş görünüyor, ama kayıtlı komut
--   metni repodakiyle aynı değil (K-0231: set_updated_at revoke'u yok).
--   Kontrolde üç fonksiyonda da anon ve PUBLIC EXECUTE açık görüldü (GÖR-095).
--
-- KÖK NEDEN (doğrulanacak, kesin değil):
--   Kayıt ile canlı durum uyuşmuyor. Repo dosyası e530704'ten beri değişmedi;
--   uzakta çalışan metnin kaynağı bulunamadı. Bu migration kökü açıklamaz; yalnızca
--   yetkiyi repodaki hedef duruma getirir. Kökün kullanıcı tarafından doğrulanması
--   gerekir (hangi araç/elle SQL ile uygulandığı).
--
-- NEDEN GÜVENLİ? (repo taraması, 2026-11-12)
--   * set_updated_at(): RETURNS trigger. Doğrudan çağrılamaz; trigger tetiklemesi
--     EXECUTE denetimi yapmaz. Revoke yalnızca gereksiz yüzeyi kapatır.
--   * tr_normalize(text): Çağıran tüm fonksiyonlar (admin_list_questions,
--     admin_list_users, admin_import_questions*, admin_find_duplicates,
--     admin_export_aileler, handle_new_user) SECURITY DEFINER; iç çağrı sahibin
--     yetkisiyle yapılır, dolayısıyla anon'ın EXECUTE'u bu çağrıları etkilemez.
--     SECURITY INVOKER çağıran yok. Tablo üretilen sütunu (questions.arama_vektoru)
--     anon'ın yazma yolu değil (anon'a INSERT/UPDATE yok, RLS yalnız authenticated
--     select). RLS politikası tr_normalize çağırmıyor.
--   * hafta_baslangic(): LANGUAGE sql, INVOKER. Çağıranları resolve_league_week,
--     get_league_status (SECURITY DEFINER). anon'dan doğrudan çağrı kapanır.
--
-- UYGULAMA:
--   * Uzak DB'ye yalnızca kullanıcı onayı ve `npm run db:preview` çıktısı
--     incelendikten sonra `npm run db:deploy` ile uygulanır. Bu dosya bunu kendiliğinden
--     yapmaz. Deploy, bekleyen diğer migrasyonları da gönderebilir; önce bekleyen
--     liste kontrol edilmeli.
--   * Uygulama sonrası doğrulama bloğu (aşağıda) anon/PUBLIC EXECUTE kalırsa
--     migration'ı hata ile durdurur.
--
-- Not: service_role ve fonksiyon sahibi (owner) yetkileri değiştirilmez.

set client_encoding = 'UTF8';

-- updated_at trigger'ı: yalnızca trigger olarak çalışır, doğrudan çağrı mümkün değil.
revoke execute on function public.set_updated_at() from public, anon, authenticated;

-- Türkçe normalizasyon: anon'a kapalı, authenticated'a açık (repo hedef durumu).
revoke execute on function public.tr_normalize(text) from public, anon;
grant  execute on function public.tr_normalize(text) to authenticated;

-- Hafta başlangıcı: anon'a kapalı, authenticated'a açık (repo hedef durumu).
revoke execute on function public.hafta_baslangic() from public, anon;
grant  execute on function public.hafta_baslangic() to authenticated;

-- Doğrulama: anon ve PUBLIC artık EXECUTE'a sahip olmamalı.
do $$
declare
  f text;
begin
  foreach f in array array['public.set_updated_at()', 'public.tr_normalize(text)', 'public.hafta_baslangic()'] loop
    if has_function_privilege('anon', f::regprocedure, 'EXECUTE') then
      raise exception '20261166: anon hâlâ % üzerinde EXECUTE yetkisine sahip', f;
    end if;
    if exists (
      select 1
        from pg_proc p
        cross join lateral aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a
       where p.oid = f::regprocedure
         and a.grantee = 0
         and a.privilege_type = 'EXECUTE'
    ) then
      raise exception '20261166: PUBLIC hâlâ % üzerinde EXECUTE yetkisine sahip', f;
    end if;
  end loop;
end $$;

-- =====================================================================
--  KURTARMA (GÜVENLİK): sınıf değişikliği kuralının tetikleyici koruması
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  SORUN:
--    Sınıf değişikliği kuralları yalnızca RPC'lerin İÇİNDE duruyor:
--      * set_my_grade()    → 30 günde bir (20260927000020)
--      * set_child_grade() → veli için 24 saatte bir (20260927000080)
--    public.profiles üzerindeki UPDATE politikası istemciye kendi satırını
--    güncelleme hakkı veriyor. İstemci, RPC'yi atlayıp
--      supabase.from('profiles').update({ sinif: 12 })
--    çağırırsa bekleme kuralını tamamen atlatabilir.
--
--  ÇÖZÜM:
--    public._sinif_yaz(uid, sinif, kaynak) — meşru tek sınıf yazma yolu —
--    işlemin başında app.grade_rpc bayrağını 'on' yapar:
--       kurtarilan/parcalar/_sinif_yaz.sql  (kanıt satırı: cikti-kalan.csv:54)
--       perform set_config('app.grade_rpc', 'on', true)
--    Aşağıdaki tetikleyici, sınıf değiştiğinde bu bayrağın açık olmasını
--    şart koşar. Bayrak işlem-yereldir (is_local = true), yani işlem
--    bittiğinde kendiliğinden silinir; istemci onu REST üzerinden
--    açamaz (PostgREST yalnızca tanımlı RPC'leri çalıştırır).
--
--  TAHMİN UYARISI (AGENTS.md §7.5):
--    Canlıdaki tetikleyici tanımı dökümde YOK (cikti-kalan.csv yalnızca
--    fonksiyon gövdelerini içeriyor). Buradaki bayrak okuma biçimi ve hata
--    metni kurtarma sırasında YAZILDI. Kanıt: _sinif_yaz() bayrağı açıyor,
--    dolayısıyla bayrağı okuyan bir koruma canlıda var olmalı — aksi halde
--    bu satır tamamen işlevsiz kalırdı.
--    Canlı tanım alınınca (supabase db pull) bu blok birebir onunla
--    değiştirilmelidir.
--
--  KORUNAN DAVRANIŞ: profiles_guard_immutable()'ın mevcut üç kuralı
--    (id/role, parent_id, sosyal özellikler) AYNEN korunur; yalnızca
--    sınıf kuralı EKLENİR. Tetikleyici 20260920000000:125'te bağlıdır:
--      create trigger profiles_guard_immutable
--        before update on public.profiles ...
-- =====================================================================

create or replace function public.profiles_guard_immutable()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if auth.uid() is not null and not public.is_admin() then
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

    -- KURTARMA EKİ: sınıf yalnızca _sinif_yaz() üzerinden değişebilir
    -- (30 gün / 24 saat kurallarını atlatmayı engeller).
    if new.sinif is distinct from old.sinif
       and coalesce(current_setting('app.grade_rpc', true), '') <> 'on' then
      raise exception 'Sınıf yalnızca sınıf değiştirme ekranından güncellenebilir'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

comment on function public.profiles_guard_immutable() is
  'profiles tablosunda id/role/parent_id/sosyal ayarlar ve sinif alanlarını istemciye karşı korur. '
  'sinif yalnızca _sinif_yaz() (app.grade_rpc bayrağı) üzerinden değiştirilebilir.';

-- Trigger fonksiyonu doğrudan çağrılamaz (20260920000000:542 ile aynı kural;
-- CREATE OR REPLACE var olan yetkileri korur, açıkça tekrarlanır).
revoke execute on function public.profiles_guard_immutable() from public, anon, authenticated;

-- =====================================================================
-- VELİ ADAYI: YANIT SADELEŞTİRME (TASKS.md §11.3)
--
-- veli_adayi_olustur() önceden { ok, yeni } döndürüyordu. "yeni" alanı,
-- bir e-postanın veli adayı listesinde olup olmadığını anonim çağırana
-- söyleyebiliyordu (e-posta varlığı sızıntısı). Yanıt artık yalnızca
-- { ok: true } döner. Kayıt davranışı (upsert, outbox olayı, doğrulamalar)
-- değişmedi; olay türü hâlâ içeride "olusturuldu" / "guncellendi" olarak yazılır.
--
-- Karar (2026-10-10, kullanıcı): mevcut adayın ADI ve TELEFONU anonim çağrıyla
-- değiştirilmez (kayıt zehirlenmesini önler). Yalnızca pazarlama onayı açık
-- yönde yükseltilebilir; onay geri alınmaz.
-- =====================================================================

create or replace function public.veli_adayi_olustur(
  p_email          text,
  p_ad             text,
  p_telefon        text    default null,
  p_kaynak         text    default 'web_form',
  p_pazarlama_izni boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_email   text := lower(btrim(coalesce(p_email, '')));
  v_ad      text := btrim(coalesce(p_ad, ''));
  v_tel     text := nullif(btrim(coalesce(p_telefon, '')), '');
  v_kaynak  text := nullif(btrim(coalesce(p_kaynak, '')), '');
  v_izin    boolean := coalesce(p_pazarlama_izni, false);
  v_id      uuid;
  v_yeni    boolean;
begin
  if v_email = '' or v_email !~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'Geçerli bir e-posta gir.' using errcode = '22023';
  end if;
  if char_length(v_ad) < 2 or char_length(v_ad) > 80 then
    raise exception 'Adını 2-80 karakter arasında gir.' using errcode = '22023';
  end if;
  if v_tel is not null and v_tel !~ '^[0-9+()\s-]{7,20}$' then
    raise exception 'Telefon numarası geçersiz.' using errcode = '22023';
  end if;
  v_kaynak := coalesce(v_kaynak, 'web_form');
  if char_length(v_kaynak) > 40 then
    v_kaynak := substr(v_kaynak, 1, 40);
  end if;

  -- Tekilleştir: aynı e-posta tekrar gelirse ad/telefon KORUNUR (üzerine yazılmaz);
  -- onay yalnızca "açık" yönde güncellenir (verilen onay geri alınmaz).
  insert into public.veli_adaylari (email, ad, telefon, kaynak, pazarlama_izni, izin_at)
  values (v_email, v_ad, v_tel, v_kaynak, v_izin, case when v_izin then now() end)
  on conflict (email) do update
    set pazarlama_izni = public.veli_adaylari.pazarlama_izni or excluded.pazarlama_izni,
        izin_at        = case
                           when (public.veli_adaylari.pazarlama_izni or excluded.pazarlama_izni)
                             then coalesce(public.veli_adaylari.izin_at, now())
                           else null
                         end,
        updated_at     = now()
  returning id, (xmax::text = '0') into v_id, v_yeni;

  -- Outbox olayı: PII YOK, yalnızca referans + PII olmayan alanlar.
  insert into public.olay_kutusu (tur, payload)
  values (
    case when v_yeni then 'veli_adayi_olusturuldu' else 'veli_adayi_guncellendi' end,
    jsonb_build_object('veli_adayi_id', v_id, 'kaynak', v_kaynak, 'pazarlama_izni', v_izin)
  );

  -- Yanıt sabit: e-posta listede var mı bilgisini vermez.
  return jsonb_build_object('ok', true);
end;
$function$;

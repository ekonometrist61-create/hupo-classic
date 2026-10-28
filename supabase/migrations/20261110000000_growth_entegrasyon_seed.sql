set client_encoding = 'UTF8';

-- =====================================================================
--  Growth entegrasyonu: journey seed'leri, e-posta şablonları ve gönderim yardımcıları (W9)
--  Tarih : 2026-10-27
--  Plan  : docs/growth-crm/TAMAMLAMA_PLANI_2026-10-27.md (W9),
--          docs/growth-crm/ILETISIM_EKSIKLERI_PLANI_2026-10-27.md (P2–P4 entegrasyonu)
--  Ön koşul: 20261014000000 (growth_templates, growth_journeys, growth_households),
--            20261014000200 (growth_templates.status),
--            20261099000000 (giris_kosulu, exit_conditions, eposta_outbox growth kolonları),
--            20261100000000 (growth_mesaj_durum_guncelle),
--            20261101000000 (_growth_izin_var_mi)
--
--  NE EKLİYOR?
--    seed : 6 e-posta şablonu   (growth_templates, status='draft', approved=false)
--           6 journey           (growth_journeys, status='draft', giris_kosulu, exit_conditions)
--           journey adımları    (growth_journey_steps)
--    RPC  : growth_pazarlama_izni_var_mi(hane, kanal)      -- gönderim anı izin kontrolü (service_role)
--           growth_gonderim_sonucu_yaz(mesaj, durum, hata) -- günlük durumu + hata nedeni (service_role)
--
--  KURALLAR
--    * Hiçbir seed etkin değil: journey 'draft' (giriş yapılmaz), şablon 'draft' (gönderilmez).
--      Etkinleştirme admin kararıdır (requires_human_approval = true).
--    * Şablon değişkenleri YALNIZ veli_adi ve iptal_baglantisi. Çocuğun adı, konumu, fotoğrafı
--      hiçbir şablonda ve hiçbir değişkende yoktur (eposta-gonder yalnız bu ikisini üretir).
--    * Her e-posta şablonunda iptal bağlantısı bulunur.
--    * Puan/sınav garantisi ve sahte sosyal kanıt yoktur.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Gönderim anı izin kontrolü (eposta-gonder, kuyruğa alındıktan sonra, gönderimden hemen önce)
--    Sıklık sınırı burada UYGULANMAZ: kuyruğa alınmış kendi satırı sayılırdı.
--    Yalnız izin, bastırma ve hane durumu yeniden okunur (tek tanım: _growth_izin_var_mi).
-- ---------------------------------------------------------------------
create or replace function public.growth_pazarlama_izni_var_mi(p_household_id uuid, p_channel text)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_kanal  text := lower(btrim(coalesce(p_channel, '')));
  v_durum  text;
begin
  if v_kanal not in ('email', 'eposta') then
    raise exception 'Gönderim anı kontrolü yalnız e-posta için.' using errcode = '22023';
  end if;

  select h.account_status into v_durum
    from public.growth_households h
   where h.id = p_household_id;
  if not found or v_durum is not distinct from 'blocked' then
    return false;
  end if;

  return public._growth_izin_var_mi(p_household_id, 'email');
end;
$function$;

-- ---------------------------------------------------------------------
-- 2. Gönderim sonucu: durum (P3 yazıcısı üzerinden) + hata nedeni
--    gonderildi / basarisiz / engellendi. Hata metni kısa neden kodudur (PII içermez).
-- ---------------------------------------------------------------------
create or replace function public.growth_gonderim_sonucu_yaz(
  p_id     uuid,
  p_status text,
  p_error  text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if p_status is null or p_status not in ('gonderildi', 'basarisiz', 'engellendi') then
    raise exception 'Geçersiz gönderim sonucu.' using errcode = '22023';
  end if;

  perform public.growth_mesaj_durum_guncelle(p_id, p_status);

  update public.growth_message_log m
     set error = nullif(left(btrim(coalesce(p_error, '')), 500), '')
   where m.id = p_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. Seed: e-posta şablonları (taslak; render eposta-gonder tarafında)
-- ---------------------------------------------------------------------
insert into public.growth_templates
  (id, name, channel, lifecycle_use_case, subject, body, variables, version, approved, status)
values
  ('b1000000-0000-4000-8000-000000000001', 'hos_geldin', 'email', 'hos_geldin',
   $s$Hupolingo'ya hoş geldin$s$,
   $b$Merhaba {{veli_adi}},

Hupolingo hesabın hazır. Çocuğunu hesabına bağladığında veli panelinden çocuğunun çalışmalarını ve ilerlemesini tek yerden takip edebilirsin.

Sıradaki adım: veli panelinde eşleştirme kodunu oluştur ve çocuğunla paylaş. Küçük adımlarla başlamak yeterli.

Her yeni öğrenme adımı cesaret ister; bu yolda yanınızdayız.

Hupolingo

Bu bir ticari elektronik iletidir. Bu e-postaları almak istemiyorsan iptal bağlantısını kullanabilirsin: {{iptal_baglantisi}}$b$,
   '{veli_adi,iptal_baglantisi}', 1, false, 'draft'),

  ('b1000000-0000-4000-8000-000000000002', 'eslestirme_hatirlatma', 'email', 'eslestirme',
   $s$Çocuğunu hesabına bağlamak için küçük bir adım$s$,
   $b$Merhaba {{veli_adi}},

Çocuğunu henüz hesabına bağlamadın. Bağlandığında çocuğunun çalışmalarını veli panelinden görebilirsin.

Veli panelinde eşleştirme kodunu oluşturup çocuğunla paylaşman yeterli. Küçük adımlarla başlamak en kolay yol.

Hupolingo

Bu bir ticari elektronik iletidir. Bu e-postaları almak istemiyorsan iptal bağlantısını kullanabilirsin: {{iptal_baglantisi}}$b$,
   '{veli_adi,iptal_baglantisi}', 1, false, 'draft'),

  ('b1000000-0000-4000-8000-000000000003', 'dogrulama_hatirlatma', 'email', 'terk_kayit',
   $s$Hesabını etkinleştirmek için e-postanı doğrula$s$,
   $b$Merhaba {{veli_adi}},

Hupolingo hesabın oluşturuldu ancak e-posta adresin henüz doğrulanmadı. Kayıt sırasında gönderdiğimiz bağlantıyı kullanarak hesabını etkinleştirebilirsin. Bağlantıyı bulamazsan spam klasörüne bakmayı unutma.

Hesabın etkinleşince veli panelini kullanıp çocuğunu bağlayabilirsin.

Hupolingo

Bu bir ticari elektronik iletidir. Bu e-postaları almak istemiyorsan iptal bağlantısını kullanabilirsin: {{iptal_baglantisi}}$b$,
   '{veli_adi,iptal_baglantisi}', 1, false, 'draft'),

  ('b1000000-0000-4000-8000-000000000004', 'deneme_bitis_uyarisi', 'email', 'deneme_bitis',
   $s$Deneme sürenin bitmesine 3 gün kaldı$s$,
   $b$Merhaba {{veli_adi}},

Hupolingo deneme sürenin bitmesine 3 gün kaldı. Bu sürede çocuğunun çalışma düzenine bakabilir, ailene uygun seçeneği veli panelinden inceleyebilirsin.

Acele etmen gerekmiyor; karar tamamen senin.

Hupolingo

Bu bir ticari elektronik iletidir. Bu e-postaları almak istemiyorsan iptal bağlantısını kullanabilirsin: {{iptal_baglantisi}}$b$,
   '{veli_adi,iptal_baglantisi}', 1, false, 'draft'),

  ('b1000000-0000-4000-8000-000000000005', 'pasiflik_7_gun', 'email', 'pasiflik',
   $s$Kaldığın yerden devam edebilirsin$s$,
   $b$Merhaba {{veli_adi}},

Bir süredir Hupolingo'da görünmüyorsun. Sorun değil; öğrenme ara verdikten sonra da kolayca devam edebilir.

Kısa bir çalışma bile yeniden başlamak için yeterli. Veli panelinden çocuğunun son çalışmalarına bakıp kaldığınız yerden devam edebilirsiniz.

Hupolingo

Bu bir ticari elektronik iletidir. Bu e-postaları almak istemiyorsan iptal bağlantısını kullanabilirsin: {{iptal_baglantisi}}$b$,
   '{veli_adi,iptal_baglantisi}', 1, false, 'draft'),

  ('b1000000-0000-4000-8000-000000000006', 'winback_30_gun', 'email', 'winback',
   $s$Seni yeniden aramızda görmek isteriz$s$,
   $b$Merhaba {{veli_adi}},

Bir aydan uzun süredir Hupolingo'da değilsin. Kısa ve düzenli çalışmalar, yeniden başlamak için iyi bir yol olabilir.

İstediğin zaman veli panelinden yeniden başlayabilirsin. Ne zaman hazır olduğuna sen karar ver.

Hupolingo

Bu bir ticari elektronik iletidir. Bu e-postaları almak istemiyorsan iptal bağlantısını kullanabilirsin: {{iptal_baglantisi}}$b$,
   '{veli_adi,iptal_baglantisi}', 1, false, 'draft')
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 4. Seed: journey'ler (taslak) ve adımları
--    giris_kosulu: otomatik giriş (20261099 _growth_otomatik_giris)
--    exit_conditions: çıkış koşulları (20261099 _growth_cikis_nedeni)
-- ---------------------------------------------------------------------
insert into public.growth_journeys
  (id, name, goal, status, exit_conditions, giris_kosulu, requires_human_approval)
values
  ('a1000000-0000-4000-8000-000000000001', 'Hoş geldin', 'Yeni veli hesabına ilk yönlendirme',
   'draft',
   '{"izin_iptal": true}',
   '{"tip": "olay", "olay": "hesap_olusturuldu", "son_saat": 24}', true),

  ('a1000000-0000-4000-8000-000000000002', 'Eşleştirme hatırlatma', 'Kayıttan 2 gün sonra çocuğu bağlamaya davet',
   'draft',
   '{"cocuk_bagli": true, "izin_iptal": true}',
   '{"tip": "olay", "olay": "hesap_olusturuldu", "son_saat": 24}', true),

  ('a1000000-0000-4000-8000-000000000003', 'Terk edilmiş kayıt', 'E-posta doğrulanmamış hesaba bir hatırlatma',
   'draft',
   '{"dogrulandi": true, "izin_iptal": true}',
   '{"tip": "dogrulanmamis", "min_saat": 24, "max_saat": 72}', true),

  ('a1000000-0000-4000-8000-000000000004', 'Deneme bitiş uyarısı', 'Deneme bitmeden 3 gün kala bilgi',
   'draft',
   '{"satin_alma": true, "izin_iptal": true}',
   '{"tip": "deneme_bitis", "kalan_gun": 3}', true),

  ('a1000000-0000-4000-8000-000000000005', '7 gün pasiflik', 'Bir hafta etkinlik olmayan veliye hatırlatma',
   'draft',
   '{"geri_dondu": true, "satin_alma": true, "izin_iptal": true}',
   '{"tip": "pasif", "min_gun": 7, "max_gun": 30}', true),

  ('a1000000-0000-4000-8000-000000000006', '30 gün pasiflik (win-back)', 'Bir ay ve üzeri pasif veliye geri dönüş daveti',
   'draft',
   '{"geri_dondu": true, "satin_alma": true, "izin_iptal": true}',
   '{"tip": "pasif", "min_gun": 30, "max_gun": 90}', true)
on conflict (id) do nothing;

insert into public.growth_journey_steps
  (id, journey_id, position, step_type, label, config)
values
  -- Hoş geldin: hemen e-posta
  ('c1000000-0000-4000-8000-000000000011', 'a1000000-0000-4000-8000-000000000001', 1, 'email',
   'Hoş geldin e-postası', '{"sablon": "hos_geldin"}'),

  -- Eşleştirme hatırlatma: 48 saat sonra e-posta (kayıt + 2 gün)
  ('c1000000-0000-4000-8000-000000000021', 'a1000000-0000-4000-8000-000000000002', 1, 'delay',
   '48 saat bekle', '{"saat": 48}'),
  ('c1000000-0000-4000-8000-000000000022', 'a1000000-0000-4000-8000-000000000002', 2, 'email',
   'Eşleştirme hatırlatma e-postası', '{"sablon": "eslestirme_hatirlatma"}'),

  -- Terk edilmiş kayıt: giriş anında e-posta (giriş zaten 24-72 saat yaşta hesaplara yapılır)
  ('c1000000-0000-4000-8000-000000000031', 'a1000000-0000-4000-8000-000000000003', 1, 'email',
   'Doğrulama hatırlatma e-postası', '{"sablon": "dogrulama_hatirlatma"}'),

  -- Deneme bitiş uyarısı
  ('c1000000-0000-4000-8000-000000000041', 'a1000000-0000-4000-8000-000000000004', 1, 'email',
   'Deneme bitiş uyarısı e-postası', '{"sablon": "deneme_bitis_uyarisi"}'),

  -- 7 gün pasiflik
  ('c1000000-0000-4000-8000-000000000051', 'a1000000-0000-4000-8000-000000000005', 1, 'email',
   '7 gün pasiflik e-postası', '{"sablon": "pasiflik_7_gun"}'),

  -- 30 gün pasiflik (win-back)
  ('c1000000-0000-4000-8000-000000000061', 'a1000000-0000-4000-8000-000000000006', 1, 'email',
   'Win-back e-postası', '{"sablon": "winback_30_gun"}')
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 5. Yetkiler: yeni RPC'ler yalnız service_role
-- ---------------------------------------------------------------------
revoke execute on function public.growth_pazarlama_izni_var_mi(uuid, text)
  from public, anon, authenticated;
grant  execute on function public.growth_pazarlama_izni_var_mi(uuid, text)
  to service_role;

revoke execute on function public.growth_gonderim_sonucu_yaz(uuid, text, text)
  from public, anon, authenticated;
grant  execute on function public.growth_gonderim_sonucu_yaz(uuid, text, text)
  to service_role;

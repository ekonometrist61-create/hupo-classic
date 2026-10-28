begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kabul etmek', 'Bir teklifi ya da isteği uygun bulmak.', 'kelime', 'fiil', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 7, null, '“Teklifi kabul etti.” cümlesindeki “kabul etti” sözünün zıt anlamlısı hangisidir?', '["bildirdi","düşündü","duydu","reddetti"]'::jsonb, 3, null, null, 'Kabul etmenin zıddı reddetmektir; diğerleri bu anlamın karşıtı değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('birleştirmek', 'Ayrı parçaları bir araya getirmek.', 'kelime', 'fiil', 7, 7, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 7, null, '“Usta, kırık iki parçayı özenle birleştirdi.” cümlesindeki “birleştirdi” sözünün zıt anlamlısı hangisidir?', '["ayırdı","taşıdı","boyadı","ölçtü"]'::jsonb, 0, null, null, 'Birleştirmenin zıddı ayırmaktır; taşımak, boyamak ve ölçmek parçaları bir araya getirmenin karşıtı değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yüceltmek', 'Bir kişiyi ya da şeyi çok değerli göstermek.', 'kelime', 'fiil', 7, 7, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'zit_anlamli', 7, null, '“Yazar, hikâyesinde kahramanı yüceltti.” cümlesindeki “yüceltti” sözünün zıt anlamlısı hangisidir?', '["övdü","kıskandı","alçalttı","korudu"]'::jsonb, 2, null, null, 'Yüceltmenin zıddı alçaltmaktır; övmek yakın anlamlıdır, kıskanmak ve korumak ise karşıt değildir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
end
$olcek$;
commit;
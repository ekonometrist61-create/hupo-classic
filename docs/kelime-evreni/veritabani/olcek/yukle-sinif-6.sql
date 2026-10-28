begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kaygı', 'Kötü bir şey olacak diye içte duyulan tedirginlik.', 'kelime', 'isim', 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_anlamli', 6, null, '“Sınav öncesi içimi büyük bir kaygı kapladı.” cümlesindeki “kaygı” sözcüğüyle eş anlamlı olan hangisidir?', '["endişe","sevinç","öfke","merak"]'::jsonb, 0, null, null, 'Kaygı ile endişe, kötü bir şey olacak diye duyulan tedirginliği anlatır. Sevinç, öfke ve merak bu duyguyla eş anlamlı değildir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('dal', 'Ağacın gövdesinden çıkan ince kol.', 'kelime', 'isim', 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 6, null, 'Aşağıdakilerden hangisinde “dal” sözcüğü ağaç kolu anlamında kullanılmıştır?', '["Derin havuza korkmadan atla ve suya dal.","Rüzgârda sallanan ince dal yere düştü.","Mercanları görmek için maskeni takıp denize dal.","Gözlüğünü tak, hadi şimdi sen de havuza dal."]'::jsonb, 1, null, null, 'İkinci cümlede dal, ağacın koludur. Diğer cümlelerde dal, suya dalmak eyleminin emir biçimidir.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('yat', 'Gezinti ve yarış için kullanılan şık tekne.', 'kelime', 'isim', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 6, null, 'Aşağıdakilerden hangisinde “yat” sözcüğü tekne anlamında kullanılmıştır?', '["Sabah erken kalkmak için akşam erken yat.","Çok yorulduysan hemen odana gidip rahatça yat.","Limanda beyaz bir yat sabaha kadar bekledi.","Hastaysan evde kal ve doktorun söylediği gibi yat."]'::jsonb, 2, null, null, 'Üçüncü cümlede yat, bir tekne türüdür. Diğer cümlelerde yat, yatmak eyleminin emir biçimidir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('kaz', 'Su kenarında yaşayan, iri bir evcil kuş.', 'kelime', 'isim', 6, 6, 1)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'es_sesli', 6, null, 'Aşağıdakilerden hangisinde “kaz” sözcüğü kuş anlamında kullanılmıştır?', '["Bahçede fidan dikmek için önce toprağı kaz.","Hazinenin yerini bulmak istiyorsan şuraya derin bir çukur kaz.","Kum havuzunda küçük bir hendek kaz, suyu akıtalım.","Çiftlikteki beyaz kaz yavrularını gözetiyordu."]'::jsonb, 3, null, null, 'Dördüncü cümlede kaz, bir kuştur. Diğer cümlelerde kaz, kazmak eyleminin emir biçimidir.', 1);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('içi içine sığmamak', 'Heyecan ya da sabırsızlıktan yerinde duramamak.', 'deyim', null, 6, 6, 2)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'deyim', 6, null, '“Sınav sonucunu beklerken içim içime sığmıyordu.” cümlesindeki “içi içine sığmamak” deyimi ne anlama gelir?', '["yorgunluktan uyumak","heyecandan yerinde duramamak","rahat ve sakin olmak","korkudan saklanmak"]'::jsonb, 1, null, null, 'İçi içine sığmamak, heyecan ve sabırsızlıktan rahat duramamaktır. Diğer şıklar bu anlamı taşımaz.', 2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mahzun', 'Üzüntülü, kederli.', 'kelime', 'sifat', 6, 6, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 6, null, '“Sahibini kaybeden köpeğin bakışı mahzundu; başı öne eğikti, gözleri dolu doluydu.” cümlesindeki “mahzun” sözcüğü ne anlama gelir?', '["öfkeli","meraklı","uykulu","üzgün"]'::jsonb, 3, null, null, 'Başın öne eğik, gözlerin dolu olması mahzunun üzgün anlamında olduğunu gösterir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values ('mütevazı', 'Gösterişten uzak, sade.', 'kelime', 'sifat', 6, 6, 3)
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, 'baglamda_anlam', 6, null, '“Kasabanın mütevazı evlerinde süslü eşya yoktu; duvarlar çıplak, mobilyalar azdı.” cümlesindeki “mütevazı” sözcüğü ne anlama gelir?', '["geniş ve ferah","eski ve yıkık","sade ve gösterişsiz","renkli ve neşeli"]'::jsonb, 2, null, null, 'Süslü eşyanın olmaması, duvarların çıplak ve mobilyanın az olması evlerin sade olduğunu gösterir.', 3);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'gemini-3.8-flash', 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, 'claude-opus (bağımsız alt ajan, kör)', 'claude', 'pass', null);
end
$olcek$;
commit;
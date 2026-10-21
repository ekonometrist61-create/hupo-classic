-- =====================================================================
-- Okuma Dünyası — 3. ve 4. sınıf pilot (15 hikâye): sözlükler, 15 fiş ve taslak paketler.
--   * YÃ¶netici olarak Ã§alÄ±ÅŸan ilk admin profilinin kimliÄŸiyle iÃ§e aktarÄ±r (require_admin).
--   * HikÃ¢yeler taslak girer (denetim pending); yayÄ±n ayrÄ± bir karardÄ±r.
--   * Her adÄ±m sonuÃ§ kontrolÃ¼ yapar; bir hata olursa iÅŸlemin tamamÄ± geri alÄ±nÄ±r.
-- =====================================================================

set client_encoding = 'UTF8';

do $pilot$
declare
  v_admin uuid;
  v_r     jsonb;
begin
  select id into v_admin from public.profiles where role = 'admin' order by id limit 1;
  if v_admin is null then
    raise exception 'iÃ§e aktarma: yÃ¶netici profil bulunamadÄ±';
  end if;
  perform set_config('request.jwt.claims', json_build_object('sub', v_admin, 'role', 'authenticated')::text, true);

  v_r := public.okuma_sozluk_ice_aktar($z01${
    "sozluk_surumu":  1,
    "girdiler":  [
                     {
                         "id":  "pa_filiz",
                         "tur":  "kelime",
                         "yazim":  "filiz",
                         "anlam":  "Tohumdan yeni çıkan ince, küçük bitki.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_kosul",
                         "tur":  "kelime",
                         "yazim":  "koşul",
                         "anlam":  "Bir işin ya da deneyin olması için gerekli olan durum.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_gozlem",
                         "tur":  "kelime",
                         "yazim":  "gözlem",
                         "anlam":  "Bir şeye dikkatle bakıp onu anlamaya çalışma.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_fener",
                         "tur":  "kelime",
                         "yazim":  "fener",
                         "anlam":  "Karanlıkta yol göstermek için ışık yayan yüksek yapı veya araç.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_sinyal",
                         "tur":  "kelime",
                         "yazim":  "sinyal",
                         "anlam":  "Bir şeyi haber vermek için gönderilen ışık, ses ya da işaret.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_ariza",
                         "tur":  "kelime",
                         "yazim":  "arıza",
                         "anlam":  "Bir şeyin çalışmasını bozan sorun.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_iz",
                         "tur":  "kelime",
                         "yazim":  "iz",
                         "anlam":  "Bir şeyin ya da birinin geçtiği yerde bıraktığı belirti.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_katman",
                         "tur":  "kelime",
                         "yazim":  "katman",
                         "anlam":  "Üst üste duran tabakalardan her biri.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_tahmin",
                         "tur":  "kelime",
                         "yazim":  "tahmin",
                         "anlam":  "Kesin bilmeden, ipuçlarına bakarak düşünülen sonuç.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_sifre",
                         "tur":  "kelime",
                         "yazim":  "şifre",
                         "anlam":  "Çözülünce bir şeyi açan gizli işaret ya da söz.",
                         "sinif_alt":  4,
                         "sinif_ust":  4,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_hatira",
                         "tur":  "kelime",
                         "yazim":  "hatıra",
                         "anlam":  "Geçmişten akılda kalan, unutulmak istenmeyen anı.",
                         "sinif_alt":  4,
                         "sinif_ust":  4,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_yelkovan",
                         "tur":  "kelime",
                         "yazim":  "yelkovan",
                         "anlam":  "Saatte dakikayı gösteren uzun ibre.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_bakim",
                         "tur":  "kelime",
                         "yazim":  "bakım",
                         "anlam":  "Bir şeyin iyi çalışması için düzenli olarak kontrol edilip onarılması.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_olcum",
                         "tur":  "kelime",
                         "yazim":  "ölçüm",
                         "anlam":  "Bir şeyin boyunu, ağırlığını ya da zamanını bulmak için yapılan işlem.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_misafir",
                         "tur":  "kelime",
                         "yazim":  "misafir",
                         "anlam":  "Bir eve ya da yere konuk olarak giden kişi.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_israr",
                         "tur":  "kelime",
                         "yazim":  "ısrar",
                         "anlam":  "Bir şeyi kabul ettirmek için üstelemek.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_bilmece",
                         "tur":  "kelime",
                         "yazim":  "bilmece",
                         "anlam":  "Cevabı düşünerek bulunan kısa soru ya da söz oyunu.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_adres",
                         "tur":  "kelime",
                         "yazim":  "adres",
                         "anlam":  "Bir yerin ya da kişinin bulunduğu yeri gösteren bilgi.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_pusula",
                         "tur":  "kelime",
                         "yazim":  "pusula",
                         "anlam":  "Yönleri bulmaya yarayan araç.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_yon",
                         "tur":  "kelime",
                         "yazim":  "yön",
                         "anlam":  "Bir şeyin gittiği ya da bakılan taraf; kuzey, güney gibi.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_ritim",
                         "tur":  "kelime",
                         "yazim":  "ritim",
                         "anlam":  "Seslerin ya da vuruşların düzenli tekrar eden akışı.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_ezgi",
                         "tur":  "kelime",
                         "yazim":  "ezgi",
                         "anlam":  "Birbirini izleyen seslerle oluşan müzik; melodi.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_uyum",
                         "tur":  "kelime",
                         "yazim":  "uyum",
                         "anlam":  "Farklı şeylerin birbirine karışmadan güzel bir bütün oluşturması.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_ata_sabir",
                         "tur":  "atasozu",
                         "yazim":  "Sabreden derviş muradına ermiş",
                         "anlam":  "Sabırla bekleyen kişi sonunda istediğine ulaşır.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "pa_ata_acele",
                         "tur":  "atasozu",
                         "yazim":  "Acele işe şeytan karışır",
                         "anlam":  "Telaşla yapılan işlerde hata yapmak kolaylaşır.",
                         "sinif_alt":  3,
                         "sinif_ust":  3,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     }
                 ],
    "kavramlar":  [

                  ],
    "yuvalar":  [
                    {
                        "ad":  "pa_filiz",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_filiz"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_kosul",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_kosul"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_gozlem",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_gozlem"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_fener",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_fener"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_sinyal",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_sinyal"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_ariza",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_ariza"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_iz",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_iz"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_katman",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_katman"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_tahmin",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_tahmin"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_sifre",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_sifre"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_hatira",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_hatira"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_yelkovan",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_yelkovan"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_bakim",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_bakim"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_olcum",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_olcum"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_misafir",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_misafir"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_israr",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_israr"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_bilmece",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_bilmece"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_adres",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_adres"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_pusula",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_pusula"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_yon",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_yon"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_ritim",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_ritim"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_ezgi",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_ezgi"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_uyum",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_uyum"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_ata_sabir",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_ata_sabir"
                                        }
                                    ]
                    },
                    {
                        "ad":  "pa_ata_acele",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "pa_ata_acele"
                                        }
                                    ]
                    }
                ]
}$z01$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'sozluk 1: %', v_r; end if;

  v_r := public.okuma_sozluk_ice_aktar($z02${
  "sozluk_surumu": 1,
  "girdiler": [
    {
      "id": "pb_gul",
      "tur": "kelime",
      "yazim": "gül",
      "anlam": "Güzel kokulu, dikenli bir çiçek; aynı yazılan gül sözcüğü gülmek eyleminin emir biçimi de olabilir.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_yuz",
      "tur": "kelime",
      "yazim": "yüz",
      "anlam": "Doksan dokuzdan sonra gelen sayı; aynı zamanda insanın gözlerinin, burnunun ve ağzının bulunduğu yer.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_yaz",
      "tur": "kelime",
      "yazim": "yaz",
      "anlam": "Yılın en sıcak mevsimi; aynı yazılan yaz sözcüğü kalemle yazı yazmak anlamına da gelir.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_golge",
      "tur": "kelime",
      "yazim": "gölge",
      "anlam": "Işığın önüne bir şey girince arkasında oluşan karanlık görüntü.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_perde",
      "tur": "kelime",
      "yazim": "perde",
      "anlam": "Gölge oyununda görüntülerin üzerine düştüğü beyaz örtü; pencereyi örten kumaş da perdedir.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_mecaz",
      "tur": "kelime",
      "yazim": "mecaz",
      "anlam": "Bir sözün gerçek anlamından ayrılıp benzetmeyle kullanılan anlamı.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_takim",
      "tur": "kelime",
      "yazim": "takım",
      "anlam": "Bir işi ya da oyunu birlikte yapan insan topluluğu.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_sira",
      "tur": "kelime",
      "yazim": "sıra",
      "anlam": "Birbiri ardından gelen şeylerin dizilişi; önce ve sonra düzeni.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_farkli",
      "tur": "kelime",
      "yazim": "farklı",
      "anlam": "Başkasına benzemeyen, ayrı özellikte olan.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_termometre",
      "tur": "kelime",
      "yazim": "termometre",
      "anlam": "Sıcaklığı ölçmeye yarayan alet.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_enerji",
      "tur": "kelime",
      "yazim": "enerji",
      "anlam": "Isıtmak, ışık vermek ya da hareket ettirmek gibi işleri yapabilen güç.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_olcum",
      "tur": "kelime",
      "yazim": "ölçüm",
      "anlam": "Bir şeyin boyunu, sıcaklığını ya da ağırlığını bir araçla öğrenme işi.",
      "sinif_alt": 3,
      "sinif_ust": 3,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_kroki",
      "tur": "kelime",
      "yazim": "kroki",
      "anlam": "Bir yerin yolunu göstermek için elle çizilen basit harita.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_olcek",
      "tur": "kelime",
      "yazim": "ölçek",
      "anlam": "Haritadaki yerlerin gerçekte ne kadar küçültülerek çizildiğini gösteren oran.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_guzergah",
      "tur": "kelime",
      "yazim": "güzergâh",
      "anlam": "Bir yere giderken izlenen yol.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_sensor",
      "tur": "kelime",
      "yazim": "sensör",
      "anlam": "Hareket, sıcaklık ya da ışık gibi değişimleri algılayan küçük cihaz.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_kanit",
      "tur": "kelime",
      "yazim": "kanıt",
      "anlam": "Bir düşüncenin doğru olduğunu gösteren bilgi ya da belge.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_varsayim",
      "tur": "kelime",
      "yazim": "varsayım",
      "anlam": "Henüz kanıtlanmamış, doğru olabileceği düşünülen düşünce.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_terazi",
      "tur": "kelime",
      "yazim": "terazi",
      "anlam": "Bir şeyin ağırlığını ölçmek için kullanılan, iki kefeli ya da dijital alet.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_denetim",
      "tur": "kelime",
      "yazim": "denetim",
      "anlam": "Bir şeyin doğru ve kurallara uygun olup olmadığına bakma.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pb_olcu",
      "tur": "kelime",
      "yazim": "ölçü",
      "anlam": "Bir şeyin ağırlığını, boyunu ya da miktarını belirleyen değer.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    }
  ],
  "kavramlar": [],
  "yuvalar": [
    {
      "ad": "pb_gul",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_gul"
        }
      ]
    },
    {
      "ad": "pb_yuz",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_yuz"
        }
      ]
    },
    {
      "ad": "pb_yaz",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_yaz"
        }
      ]
    },
    {
      "ad": "pb_golge",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_golge"
        }
      ]
    },
    {
      "ad": "pb_perde",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_perde"
        }
      ]
    },
    {
      "ad": "pb_mecaz",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_mecaz"
        }
      ]
    },
    {
      "ad": "pb_takim",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_takim"
        }
      ]
    },
    {
      "ad": "pb_sira",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_sira"
        }
      ]
    },
    {
      "ad": "pb_farkli",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_farkli"
        }
      ]
    },
    {
      "ad": "pb_termometre",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_termometre"
        }
      ]
    },
    {
      "ad": "pb_enerji",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_enerji"
        }
      ]
    },
    {
      "ad": "pb_olcum",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_olcum"
        }
      ]
    },
    {
      "ad": "pb_kroki",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_kroki"
        }
      ]
    },
    {
      "ad": "pb_olcek",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_olcek"
        }
      ]
    },
    {
      "ad": "pb_guzergah",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_guzergah"
        }
      ]
    },
    {
      "ad": "pb_sensor",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_sensor"
        }
      ]
    },
    {
      "ad": "pb_kanit",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_kanit"
        }
      ]
    },
    {
      "ad": "pb_varsayim",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_varsayim"
        }
      ]
    },
    {
      "ad": "pb_terazi",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_terazi"
        }
      ]
    },
    {
      "ad": "pb_denetim",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_denetim"
        }
      ]
    },
    {
      "ad": "pb_olcu",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pb_olcu"
        }
      ]
    }
  ]
}$z02$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'sozluk 2: %', v_r; end if;

  v_r := public.okuma_fis_ice_aktar($fis$[
    {
        "fis_kodu":  "HR-015",
        "baslik":  "Tohumun Küçük Sırrı",
        "sinif":  3,
        "sinif_bandi":  "2-4",
        "tur":  "Bilim/Doğa",
        "kurgu_cekirdegi":  "Ekin aynı tohumlardan birini karanlığa diğerini ışığa koyar; büyümelerinin farkını gözleyip koşulları karşılaştırır.",
        "soz_varligi":  "büyümek-küçülmek; gözlem",
        "bilgi_beceri_deger":  "Bitkinin gelişimi; adil karşılaştırma",
        "ikon_onerileri":  [
                               "tohum",
                               "filiz",
                               "güneş"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-018",
        "baslik":  "Deniz Fenerindeki Sinyal",
        "sinif":  3,
        "sinif_bandi":  "2-4",
        "tur":  "Macera",
        "kurgu_cekirdegi":  "Kıyıda ışık sönünce iki arkadaş güvenli noktadan yardım çağırır; fenerin bakım defteriyle doğru ekibe ulaşırlar.",
        "soz_varligi":  "ışık-karanlık; neden-sonuç",
        "bilgi_beceri_deger":  "Deniz güvenliği; iş birliği",
        "ikon_onerileri":  [
                               "fener",
                               "dalga",
                               "telsiz"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-019",
        "baslik":  "Mağaranın Üç İşareti",
        "sinif":  3,
        "sinif_bandi":  "2-4",
        "tur":  "Macera",
        "kurgu_cekirdegi":  "Doğa gezisindeki rehber üç kaya işaretini gösterir; çocuklar mağaraya girmeden haritanın anlattığı tarihi çözer.",
        "soz_varligi":  "işaret, iz; sıralama",
        "bilgi_beceri_deger":  "Jeolojiye giriş; güvenli keşif",
        "ikon_onerileri":  [
                               "kaya",
                               "harita",
                               "büyüteç"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-021",
        "baslik":  "Kayıp Sandığın Şifresi",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Macera",
        "kurgu_cekirdegi":  "Sandığın dört sembolü eksiktir; dört arkadaş ipuçlarını birleştirerek içindeki sınıf hatıralarına ulaşır.",
        "soz_varligi":  "eşleştirme; tahmin",
        "bilgi_beceri_deger":  "Mantık, ekip çalışması",
        "ikon_onerileri":  [
                               "sandık",
                               "şifre",
                               "fotoğraf"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-022",
        "baslik":  "Saat Kulesi Neden Durdu?",
        "sinif":  3,
        "sinif_bandi":  "2-4",
        "tur":  "Gizem",
        "kurgu_cekirdegi":  "Meydandaki saat aynı dakikada durur; çocuklar bakım görevlisine gözlemlerini aktararak sorunu çözer.",
        "soz_varligi":  "zaman ifadeleri; önce-sonra",
        "bilgi_beceri_deger":  "Saat okuma; kamu sorumluluğu",
        "ikon_onerileri":  [
                               "saat",
                               "çark",
                               "not"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-023",
        "baslik":  "Hoca ve Görünmeyen Misafir",
        "sinif":  3,
        "sinif_bandi":  "2-4",
        "tur":  "Gizem",
        "kurgu_cekirdegi":  "Bir sofrada boş yere ayrılan tabak komik bir yanlış anlamaya yol açar; Hoca asıl meselenin misafirperverlik olduğunu açıklar.",
        "soz_varligi":  "gerçek-mecaz; misafirperverlik",
        "bilgi_beceri_deger":  "İletişim; nezaket",
        "ikon_onerileri":  [
                               "tabak",
                               "sofra",
                               "kapı"
                           ],
        "telif_sinifi":  "A",
        "kaynak_sinifi":  "Nasreddin Hoca fıkra geleneği",
        "telif_notu":  "Geleneksel/anonim anlatı çekirdeğinden yeniden kurgu"
    },
    {
        "fis_kodu":  "HR-024",
        "baslik":  "Bulut Postacısının Son Mektubu",
        "sinif":  3,
        "sinif_bandi":  "2-4",
        "tur":  "Fantastik",
        "kurgu_cekirdegi":  "Bulutlar arasındaki postacı yanlış adrese giden mektubu bulmak için yönleri öğrenir; mektup sahibine kavuşur.",
        "soz_varligi":  "kuzey-güney, adres",
        "bilgi_beceri_deger":  "Yön bulma; sorumluluk",
        "ikon_onerileri":  [
                               "bulut",
                               "zarf",
                               "pusula"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-025",
        "baslik":  "Bremen Yolcularının Yeni Şarkısı",
        "sinif":  3,
        "sinif_bandi":  "2-4",
        "tur":  "Hayvanlar",
        "kurgu_cekirdegi":  "Dört hayvan ortak seslerinden uyumlu bir müzik çıkarır; birlikte hareket ederek yolculuklarını güvenle sürdürür.",
        "soz_varligi":  "ses, uyum; iş birliği",
        "bilgi_beceri_deger":  "Müzik ve dayanışma",
        "ikon_onerileri":  [
                               "eşek",
                               "kedi",
                               "nota"
                           ],
        "telif_sinifi":  "K",
        "kaynak_sinifi":  "Grimm Kardeşlerin kamu malı masal çekirdeği",
        "telif_notu":  "Kamu malı klasik metin temel alınarak özgün uyarlama adayı"
    },
    {
        "fis_kodu":  "HR-026",
        "baslik":  "Kelime Makinesinin Karışıklığı",
        "sinif":  3,
        "sinif_bandi":  "2-4",
        "tur":  "Mizah",
        "kurgu_cekirdegi":  "Bir icat sesteş kelimeleri karıştırır; gülünç cümleler kurulunca çocuklar bağlamın anlamı belirlediğini keşfeder.",
        "soz_varligi":  "sesteş: yüz, gül, çay",
        "bilgi_beceri_deger":  "Bağlam ve dil farkındalığı",
        "ikon_onerileri":  [
                               "robot",
                               "sözlük",
                               "konuşma"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-027",
        "baslik":  "Karagöz\u0027ün Kayıp Gölgesi",
        "sinif":  3,
        "sinif_bandi":  "2-4",
        "tur":  "Mizah",
        "kurgu_cekirdegi":  "Karagöz gölgesinin kaybolduğunu sanır; Hacivat ışığın açısına bakmasını sağlayıp meseleyi komik biçimde çözer.",
        "soz_varligi":  "deyim: gölgede kalmak; gerçek-mecaz",
        "bilgi_beceri_deger":  "Işık; söz sanatları",
        "ikon_onerileri":  [
                               "gölge",
                               "perde",
                               "fener"
                           ],
        "telif_sinifi":  "A",
        "kaynak_sinifi":  "Karagöz-Hacivat geleneksel tipleri",
        "telif_notu":  "Geleneksel/anonim anlatı çekirdeğinden yeniden kurgu"
    },
    {
        "fis_kodu":  "HR-028",
        "baslik":  "Üç Renkli Takım",
        "sinif":  3,
        "sinif_bandi":  "2-4",
        "tur":  "Arkadaşlık",
        "kurgu_cekirdegi":  "Farklı oyunları seven üç çocuk bir yarış için tek takım olmak zorunda kalır; herkesin becerisi birleşince oyun zenginleşir.",
        "soz_varligi":  "aynı-farklı; karşılaştırma",
        "bilgi_beceri_deger":  "Takım çalışması; saygı",
        "ikon_onerileri":  [
                               "üç renk",
                               "top",
                               "el"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-029",
        "baslik":  "Minik Mucit ve Güneş Fırını",
        "sinif":  3,
        "sinif_bandi":  "2-4",
        "tur":  "Bilim/Doğa",
        "kurgu_cekirdegi":  "Bir çocuk karton kutuyla basit güneş ısıtıcısı modeller; öğretmeni eşliğinde güvenli denemeler yapar.",
        "soz_varligi":  "ısı, sıcak-soğuk",
        "bilgi_beceri_deger":  "Enerji ve güvenli deney",
        "ikon_onerileri":  [
                               "güneş",
                               "kutu",
                               "termometre"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-030",
        "baslik":  "Ormanın Kaybolan Patikası",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Macera",
        "kurgu_cekirdegi":  "Eski patika yağmurla kapanır; ekip işaret levhaları hazırlayıp yürüyüşçüler için güvenli alternatif rota önerir.",
        "soz_varligi":  "rota, yön; çözüm önerisi",
        "bilgi_beceri_deger":  "Harita ölçeğine giriş; doğayı koruma",
        "ikon_onerileri":  [
                               "orman",
                               "pusula",
                               "levha"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-031",
        "baslik":  "Müzede Sessiz Alarm",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Gizem",
        "kurgu_cekirdegi":  "Müzedeki bir vitrinin alarmı yanlış zamanda çalar; çocuklar görevliye sırayla gözlem aktarıp hassas sensörü bulur.",
        "soz_varligi":  "kanıt, varsayım; neden-sonuç",
        "bilgi_beceri_deger":  "Müze kültürü; teknoloji",
        "ikon_onerileri":  [
                               "müze",
                               "alarm",
                               "mercek"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-032",
        "baslik":  "Keloğlan ve Akıllı Terazi",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Tarih/Kültür",
        "kurgu_cekirdegi":  "Keloğlan pazarda eksik tartılan ürünleri fark eder; kimseyi incitmeden adil ölçmenin yolunu gösterir.",
        "soz_varligi":  "adil-haksız; deyim: ölçüp biçmek",
        "bilgi_beceri_deger":  "Ölçme, dürüstlük",
        "ikon_onerileri":  [
                               "terazi",
                               "pazar",
                               "sepet"
                           ],
        "telif_sinifi":  "A",
        "kaynak_sinifi":  "Keloğlan halk masalı motifi",
        "telif_notu":  "Geleneksel/anonim anlatı çekirdeğinden yeniden kurgu"
    }
]$fis$::jsonb, false);
  if (v_r ->> 'ok') is distinct from 'true' then raise exception 'fis: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p01${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr015-tohumun-kucuk-sirri",
    "baslik": "Tohumun Küçük Sırrı",
    "tur": "bilim",
    "konu": "bitki",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas"
    ],
    "deger_anahtarlari": [
      "D12",
      "D3"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "bilim_teknoloji",
        "doga",
        "sabir_emek"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D12",
        "yardimci_deger": "D3"
      },
      "ogrenme_hedefleri": [
        {
          "id": "filiz_hr015",
          "tur": "lexeme",
          "etiket": "filiz",
          "yuva": "pa_filiz",
          "islev": "first_hint"
        },
        {
          "id": "kosul_hr015",
          "tur": "lexeme",
          "etiket": "koşul",
          "yuva": "pa_kosul",
          "islev": "application"
        },
        {
          "id": "gozlem_hr015",
          "tur": "lexeme",
          "etiket": "gözlem",
          "yuva": "pa_gozlem",
          "islev": "application"
        },
        {
          "id": "kavram_hr015",
          "tur": "concept",
          "etiket": "Bitki gelişimi ve kontrollü karşılaştırma",
          "islev": "application"
        },
        {
          "id": "atasoz_hr015",
          "tur": "proverb",
          "etiket": "Sabreden derviş muradına ermiş",
          "yuva": "pa_ata_sabir",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 393,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 8,
        "soru_sayisi": 5,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 5,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Aynı paketten çıkan iki fasulyeden biri neden cılız kaldı? Küçük bir deney büyük bir sırrı arıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-015"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sınıfın pencere kenarında duran iki saksıya bakıp kaşlarını çattı. Aynı gün ektiği fasulyelerden biri yeşermiş, diğeri ise incecik, soluk bir "
        },
        {
          "t": "kelime",
          "yuva": "pa_filiz"
        },
        {
          "t": "metin",
          "v": " çıkarmıştı. Üstelik ikisi de aynı tohum paketindendi. \"Belki karanlığı daha çok seviyordur,\" dedi arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını salladı. \"Olabilir. Ama tahminle yetinmeyelim.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğretmenleri deney defterlerini açmalarını istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir sayfayı ikiye böldü. Bir başlığa "
        },
        {
          "t": "vurgu",
          "v": "pencere"
        },
        {
          "t": "metin",
          "v": ", diğerine "
        },
        {
          "t": "vurgu",
          "v": "dolap"
        },
        {
          "t": "metin",
          "v": " yazdı. İki saksıya da aynı miktarda su verdiklerini kaydetti. İkinci saksı, sınıftaki kapaklı dolabın içinde duruyordu. Sonra defterine şunu not düştü: \"Farklı olan "
        },
        {
          "t": "kelime",
          "yuva": "pa_kosul"
        },
        {
          "t": "metin",
          "v": ": ışık.\" "
        },
        {
          "t": "isaret",
          "kod": "gunes"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Üç gün boyunca her sabah önce ellerini yıkadı, sonra filizlere dokunmadan cetvelle boylarını ölçtü. Pencere kenarındaki bitkinin yaprakları genişleyip koyu yeşile döndü. Dolaptakinin gövdesi uzadı ama yaprakları küçük ve sarımsı kaldı. \"Bak, dolaptaki daha uzun!\" dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". \"Demek ki daha iyi büyümüş.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterdeki iki çizimi yan yana getirdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "O gün "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", filizin bir yaprağını parmağıyla düzeltmek istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onu nazikçe durdurdu. \"Dokunursak gözlemlediğimiz şeyi değiştirebiliriz,\" dedi. Öğretmenleri, tohumun karanlıkta da ilk filizini çıkarabildiğini, ancak sağlıklı gelişebilmesi için ışığın önemli olduğunu anlattı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " düşüncelere daldı. \"Öyleyse yalnızca ilk filizin çıkmasına bakıp karar vermek yanlış.\" İkisi de deftere bu yeni bilgiyi yazdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sonraki gün ölçüm yaparken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başka bir sorunla karşılaştı. Dolaptaki saksının toprağı daha ıslak görünüyordu. Acaba gerçekten aynı miktarda su mu vermişlerdi? İki günün kayıtlarını kontrol edip sulama kaplarının üzerindeki çizgileri karşılaştırdılar. Hata yapmadıklarını gördüler; yine de bir deneyde bütün koşulları dikkatle izlemek gerektiğini anladılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " cetvelin yanına küçük bir su kabı resmi çizdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "\"Uzun olması güçlü olduğu anlamına gelir mi? Yapraklarına da bakalım,\" dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Öğretmenleri açıklama yapmadan önce çocuklardan "
        },
        {
          "t": "kelime",
          "yuva": "pa_gozlem"
        },
        {
          "t": "metin",
          "v": " sonuçlarını anlatmalarını istedi. \"Bitkiler ışığa ihtiyaç duyuyor olabilir,\" dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". \"Ama bir bitkinin gelişimini yalnızca boyuna bakarak anlayamayız.\" O gün dolaptaki saksıyı da pencere kenarına taşıdılar. \"Şimdi ikisine de aynı bakımı yapalım,\" diye önerdi. Sarımsı filizi atmak istemiyordu; ona yeni bir fırsat vermek istiyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir hafta sonra yapraklarda yeşillenme görüldü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", \"Tohumun sırrını çözdük mü?\" diye sordu. \"Bir kısmını,\" dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". \"Su, ışık ve uygun ortam önemli. Ama bütün bitkiler aynı mı, onu da araştırmalıyız.\" Bir hafta boyunca sabırla beklemişti. Aklına şu söz geldi: \""
        },
        {
          "t": "atasozu",
          "yuva": "pa_ata_sabir"
        },
        {
          "t": "metin",
          "v": "\"."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterinin sonuna bir soru daha yazdı: \"Kaktüsle fasulye aynı miktarda su ister mi?\" Bu sorunun cevabını henüz bilmiyordu. Bilmediğini söylemek onu üzmedi; aksine ertesi gün için heyecanlandırdı. Çünkü küçük bir tohum, kocaman bir merak başlatmıştı. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 2,
      "metin": "İki saksı arasında hangi koşul farklıydı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Verilen su miktarı"
        },
        {
          "id": "B",
          "metin": "Aldıkları ışık"
        },
        {
          "id": "C",
          "metin": "Tohum paketinin türü"
        }
      ],
      "dogru": "B",
      "aciklama": "Bir saksı pencere kenarında, diğeri kapaklı dolabın içindeydi; aradaki fark ışıktı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Öğretmenin anlattıklarından hangisi çıkarılabilir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Tohum karanlıkta filiz verebilir ama sağlıklı büyümesi için ışık önemlidir."
        },
        {
          "id": "B",
          "metin": "Tohumlar yalnızca karanlıkta büyür."
        },
        {
          "id": "C",
          "metin": "Bitkiler için su hiç gerekli değildir."
        }
      ],
      "dogru": "A",
      "aciklama": "Öğretmen, tohumun karanlıkta da ilk filizini çıkarabildiğini ama sağlıklı gelişmesi için ışığın önemli olduğunu söyledi."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Çocuğun sarımsı filizi atmayıp pencere kenarına taşıması neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Deneyi bırakmak istediğini"
        },
        {
          "id": "B",
          "metin": "Saksıyı sevmediğini"
        },
        {
          "id": "C",
          "metin": "Filizin ışıkla düzelebileceğini denemek istediğini"
        }
      ],
      "dogru": "C",
      "aciklama": "Çocuk sarımsı filize yeni bir fırsat vermek istedi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 1,
      "metin": "Metinde geçen filiz sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Tohumdan yeni çıkan ince, küçük bitki"
        },
        {
          "id": "B",
          "metin": "Sulama için kullanılan kap"
        },
        {
          "id": "C",
          "metin": "Uzunluk ölçmeye yarayan araç"
        }
      ],
      "dogru": "A",
      "aciklama": "Fasulye tohumundan çıkan incecik, soluk bitkiye filiz denir."
    },
    {
      "id": "s5",
      "beceri": "hatirlama",
      "dayanak_sayfa": 5,
      "metin": "Çocuklar su miktarının eşit olup olmadığını nasıl kontrol etti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Saksıların yerlerini değiştirerek"
        },
        {
          "id": "B",
          "metin": "Kayıtlara ve sulama kaplarındaki çizgilere bakarak"
        },
        {
          "id": "C",
          "metin": "Toprağı tadarak"
        }
      ],
      "dogru": "B",
      "aciklama": "İki günün kayıtlarını kontrol edip sulama kaplarındaki çizgileri karşılaştırdılar."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p01$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr015-tohumun-kucuk-sirri: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p02${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr018-deniz-fenerindeki-sinyal",
    "baslik": "Deniz Fenerindeki Sinyal",
    "tur": "macera",
    "konu": "deniz",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas"
    ],
    "deger_anahtarlari": [
      "D16",
      "D20"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "guvenlik",
        "dayanisma",
        "dostluk"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D16",
        "yardimci_deger": "D20"
      },
      "ogrenme_hedefleri": [
        {
          "id": "fener_hr018",
          "tur": "lexeme",
          "etiket": "fener",
          "yuva": "pa_fener",
          "islev": "first_hint"
        },
        {
          "id": "sinyal_hr018",
          "tur": "lexeme",
          "etiket": "sinyal",
          "yuva": "pa_sinyal",
          "islev": "application"
        },
        {
          "id": "ariza_hr018",
          "tur": "lexeme",
          "etiket": "arıza",
          "yuva": "pa_ariza",
          "islev": "application"
        },
        {
          "id": "kavram_hr018",
          "tur": "concept",
          "etiket": "Deniz güvenliği ve sorumlu bildirim",
          "islev": "application"
        },
        {
          "id": "atasoz_hr018",
          "tur": "proverb",
          "etiket": "Acele işe şeytan karışır",
          "yuva": "pa_ata_acele",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 386,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 7,
        "soru_sayisi": 5,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 8,
        "simge_sayisi": 1
      }
    },
    "tanitim": "Her akşam yanan deniz feneri bu gece karanlık. Açıktaki tekne için kimi, nasıl uyarmak gerekir?",
    "durum": "taslak",
    "fis_kodu": "HR-018"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kıyıdaki deniz feneri her akşam yanardı. O gece ise güneş ufukta kaybolurken "
        },
        {
          "t": "kelime",
          "yuva": "pa_fener"
        },
        {
          "t": "metin",
          "v": " karanlık kaldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", babasıyla yürüdüğü güvenli seyir terasında durup denize baktı. Açıkta bir teknenin ışıkları görünüyordu. \"Fener neden yanmıyor?\" diye sordu. Yanındaki arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", fener binasına koşmayı önerdi. "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " babası hemen durdurdu: \"İçeri girmek bizim işimiz değil. Görevli ekibe haber vermeliyiz.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Terasta, liman işletmesinin acil iletişim numarasını gösteren bir pano vardı. Telefon çekiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " panodaki numarayı okudu, babası liman görevlisini aradı. Görevli, fenerin hangi tarafta ve ne zamandır karanlık olduğunu sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce \"Az önce,\" diyecekti, sonra düşündü. \"Güneş battığından beri,\" dedi. \"Teknenin ışığını da görüyoruz ama fenerin ışığı yok.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "\"İstersen kuleye kadar gidip kapısına bakalım,\" diye yineledi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", ama bu kez kendisi de duraksadı. Terasın aşağısında deniz kabarıyor, dalgalar taşlara çarpıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Bizim gördüğümüzü anlatmamız yeterli,\" dedi. Babası görevliye telefonla konumlarını tarif ederken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " fenerin üst kısmındaki ışık yuvasını işaret etti. Böylece hangi fenerden söz ettiklerini kesinleştirdiler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Telefon görüşmesi bittikten sonra "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", denizdeki teknenin hâlâ ilerlediğini fark etti. \"Görmüyorlar mı karanlığı?\" diye kaygılandı. Babası, denizcilere yardım etmenin yetkili ekiplerin görevi olduğunu ve teknelerin başka seyir araçları da kullandığını açıkladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", aceleyle bağırıp yanlış "
        },
        {
          "t": "kelime",
          "yuva": "pa_sinyal"
        },
        {
          "t": "metin",
          "v": " vermenin işi karıştırabileceğini anladı. "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " babası sakin bir sesle, \""
        },
        {
          "t": "atasozu",
          "yuva": "pa_ata_acele"
        },
        {
          "t": "metin",
          "v": "\" dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " duvara asılı eski bir bakım fotoğrafını fark etti. Fotoğrafın altında "
        },
        {
          "t": "vurgu",
          "v": "her ay kontrol"
        },
        {
          "t": "metin",
          "v": " yazıyordu. İkisi, liman görevlisinin telefon görüşmesinde söylediği bakım defterini merak etti. Görevli, daha sonra çocuklara defterin nasıl tutulduğunu göstermeyi kabul etti. Bir süre sonra limanın servis aracı geldi. Görevliler fenerin elektrik sistemini güvenli biçimde kontrol etmeye başladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ve "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " terastan ayrılmadı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Rüzgâr güçlenirken denizdeki tekne liman yetkililerinden yönlendirme aldı. Nihayet yüksek kulede beyaz bir ışık döndü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " sevinçle, \"Yanıyor!\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise rahat bir nefes aldı. O sırada görevli yanlarına geldi: \"Bu "
        },
        {
          "t": "kelime",
          "yuva": "pa_ariza"
        },
        {
          "t": "metin",
          "v": " konusunda bize erken haber verdiniz. Yapılması gerekeni doğru yaptınız.\" "
        },
        {
          "t": "isaret",
          "kod": "deniz"
        },
        {
          "t": "metin",
          "v": " Ertesi gün görevli, bakım defterinin bir kopyasını gösterdi. Tarih, saat, gözlenen sorun ve yapılan işlem ayrı sütunlarda yazılıydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterdeki kaydı okudu: \"Akşam kontrolünde ışık devresi arızası giderildi.\" \"Demek bir sinyal bazen yalnız ışık değildir,\" dedi. \"Doğru bilgiyi doğru kişiye ulaştırmak da bir işaret olabilir.\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bu sözü çok sevdi. Deniz fenerinin resmini çizdi; altına üç kelime yazdı: "
        },
        {
          "t": "vurgu",
          "v": "gözle, bildir, güvende kal"
        },
        {
          "t": "metin",
          "v": ". Bir sonraki akşam fener yanarken iki arkadaş ışığa değil, birlikte yaptıkları doğru işe bakıp gülümsedi."
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 2,
      "metin": "Çocuk, görevliye fenerin ne zamandır karanlık olduğunu nasıl anlattı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Dün geceden beri"
        },
        {
          "id": "B",
          "metin": "Az önce başladığını"
        },
        {
          "id": "C",
          "metin": "Güneş battığından beri"
        }
      ],
      "dogru": "C",
      "aciklama": "Çocuk önce \"Az önce\" demek istedi, sonra düşünüp \"Güneş battığından beri\" dedi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 1,
      "metin": "Çocuğun babası neden fener binasına girmelerine izin vermedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bunun yetkili ekibin işi olduğunu düşündüğü için"
        },
        {
          "id": "B",
          "metin": "Telefonu çalışmadığı için"
        },
        {
          "id": "C",
          "metin": "Karanlıktan korktuğu için"
        }
      ],
      "dogru": "A",
      "aciklama": "Baba, içeri girmenin onların işi olmadığını, görevli ekibe haber vermeleri gerektiğini söyledi."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 7,
      "metin": "\"Bir sinyal bazen yalnız ışık değildir\" sözüyle çocuk neyi anlatmak istedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Işığın hiç önemli olmadığını"
        },
        {
          "id": "B",
          "metin": "Doğru bilgiyi doğru kişiye ulaştırmanın da bir işaret olabileceğini"
        },
        {
          "id": "C",
          "metin": "Teknelerin feneri kullanmaması gerektiğini"
        }
      ],
      "dogru": "B",
      "aciklama": "Çocuk, arızayı doğru kişiye bildirmenin de bir işaret olduğunu söyledi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 6,
      "metin": "Metinde geçen arıza sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir yerin boyanması"
        },
        {
          "id": "B",
          "metin": "Bir şeyin yenilenmesi"
        },
        {
          "id": "C",
          "metin": "Bir şeyin çalışmasını bozan sorun"
        }
      ],
      "dogru": "C",
      "aciklama": "Fenerin ışığının yanmaması bir arızaydı; ekip bu sorunu giderdi."
    },
    {
      "id": "s5",
      "beceri": "hatirlama",
      "dayanak_sayfa": 5,
      "metin": "Servis aracı gelince görevliler ne yaptı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Tekneyi limana çekti"
        },
        {
          "id": "B",
          "metin": "Fenerin elektrik sistemini güvenli biçimde kontrol etti"
        },
        {
          "id": "C",
          "metin": "Fener kulesini boyadı"
        }
      ],
      "dogru": "B",
      "aciklama": "Görevliler fenerin elektrik sistemini güvenli biçimde kontrol etmeye başladı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p02$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr018-deniz-fenerindeki-sinyal: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p03${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr019-magaranin-uc-isareti",
    "baslik": "Mağaranın Üç İşareti",
    "tur": "macera",
    "konu": "magara",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas"
    ],
    "deger_anahtarlari": [
      "D5",
      "D14"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kesif",
        "doga",
        "gizem"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D5",
        "yardimci_deger": "D14"
      },
      "ogrenme_hedefleri": [
        {
          "id": "iz_hr019",
          "tur": "lexeme",
          "etiket": "iz",
          "yuva": "pa_iz",
          "islev": "first_hint"
        },
        {
          "id": "katman_hr019",
          "tur": "lexeme",
          "etiket": "katman",
          "yuva": "pa_katman",
          "islev": "application"
        },
        {
          "id": "tahmin_hr019",
          "tur": "lexeme",
          "etiket": "tahmin",
          "yuva": "pa_tahmin",
          "islev": "application"
        },
        {
          "id": "kavram_hr019",
          "tur": "concept",
          "etiket": "Varsayım ve kanıt",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 357,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 7,
        "soru_sayisi": 5,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1
        },
        "yoldas_yer_sayisi": 7,
        "simge_sayisi": 1
      }
    },
    "tanitim": "Mağara girişindeki üç gizemli işaret hazineyi mi gösteriyor? İzleri doğru okumak sanıldığından zor.",
    "durum": "taslak",
    "fis_kodu": "HR-019"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Rehber Zeynep Hanım, gezi grubunu mağaranın önünde durdurdu. Girişte serin bir hava hissediliyor, kayalıkların üzerinde üç eski işaret görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"İçeri girsek ne güzel olur!\" dedi. Rehber başını salladı: \"Burası koruma altında. Bugün mağaraya girmeden çevresindeki izleri okuyacağız.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk işaret, dalgaya benzeyen kıvrımlı bir çizgiydi. Çocuklar bunun bir nehir resmi olduğunu düşündü. Zeynep Hanım, çizginin yanında üst üste duran taş katmanlarını gösterdi. \"Sizce bu kayalar bir günde mi oluştu?\" diye sordu. \"Hayır,\" dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". \"Belki çok uzun zamanda.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkinci işaret, üçgen biçimindeydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun hazineyi gösterdiğini iddia etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise rehberin dağıttığı haritada aynı üçgenin bir tepeyi gösterdiğini fark etti. İkisi haritayı çevirdi; çevredeki tepelerin yerini işaretlediler. Üçüncü işaret en küçüğüydü: Yan yana iki daire. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun iki göz olduğunu söyledi. Rehber büyüteci "
        },
        {
          "t": "yoldas",
          "hal": "yonelme",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " uzattı. Dairelerin aslında kayanın içindeki doğal yuvarlak boşluklar olduğunu gördüler. \"Her "
        },
        {
          "t": "kelime",
          "yuva": "pa_iz"
        },
        {
          "t": "metin",
          "v": " bir insanın bıraktığı işaret değildir,\" dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": "."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Grup, mağaranın önüne konan bilgi levhasını okudu. Burada geçmişte suyun kayaları aşındırdığı, bazı boşlukların böyle oluştuğu anlatılıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " biraz utandı. \"Hazine var sandım,\" diye mırıldandı. Zeynep Hanım gülümsedi. \""
        },
        {
          "t": "kelime",
          "yuva": "pa_tahmin"
        },
        {
          "t": "metin",
          "v": " etmek kötü değil. Önemli olan yeni bilgi geldiğinde düşüncemizi değiştirebilmek.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Rehber çocuklara taş katmanlarının fotoğraflarını gösterdi. En üstte açık renkli ince bir "
        },
        {
          "t": "kelime",
          "yuva": "pa_katman"
        },
        {
          "t": "metin",
          "v": ", altında koyu renkli daha kalın bir katman vardı. \"Pastanın katları gibi,\" dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Zeynep Hanım benzetmeyi sevdi ama ekledi: \"Kayaların nasıl oluştuğunu anlamak için bilim insanları daha çok gözlem yapar. Tek fotoğrafla bütün geçmişi bilemeyiz.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " taşların yüzeyindeki küçük delikleri merak etti. Rehber, bazılarını suyun ve zamanla gerçekleşen aşınmanın oluşturabileceğini anlattı; başka nedenlerin de olabileceğini söyledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", \"Öyleyse her deliğe eski insan işareti dememeliyiz,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk tahminine yeniden baktı. Hazine beklerken kayaların kendi öyküsünü dinlemek ona daha ilginç gelmeye başlamıştı. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar üç işareti defterlerine sırayla çizdi: kıvrımlı katman, tepe simgesi ve doğal boşluk. Sonra defterleri karıştırıp birbirlerine ne anlama geldiklerini sordular. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Ben en çok üçüncüsünde yanıldım,\" dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise \"İlk işaretin de tam anlamını araştırmamız gerek,\" diye ekledi. Dönüş yolunda "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir çakıl taşı buldu. Onu cebine koymak yerine ait olduğu yerde bıraktı. \"Hatıra olarak fotoğraf ve çizimlerimiz yeter,\" dedi. Mağaranın karanlığı ardında kalmıştı; fakat çocukların aklında açılan sorular daha da aydınlıktı."
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 3,
      "metin": "Üçüncü işaretin gerçekte ne olduğu anlaşıldı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir çift göz resmi"
        },
        {
          "id": "B",
          "metin": "Kayanın içindeki doğal yuvarlak boşluklar"
        },
        {
          "id": "C",
          "metin": "Hazinenin yerini gösteren daireler"
        }
      ],
      "dogru": "B",
      "aciklama": "Büyüteçle bakınca dairelerin kayanın içindeki doğal boşluklar olduğunu gördüler."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Çocuk bilgi levhasını okuyunca neden utandı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Mağaraya girmek istediği için"
        },
        {
          "id": "B",
          "metin": "Rehberi dinlemediği için"
        },
        {
          "id": "C",
          "metin": "Hazine olduğunu sanmış, ama boşlukların suyla oluştuğunu öğrenmişti"
        }
      ],
      "dogru": "C",
      "aciklama": "Levhada boşlukların suyun kayaları aşındırmasıyla oluştuğu yazıyordu; çocuk hazine sandığı için utandı."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Rehberin \"Önemli olan yeni bilgi geldiğinde düşüncemizi değiştirebilmek\" sözü neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yeni şeyler öğrendikçe fikrimizi gözden geçirmemiz gerektiğini"
        },
        {
          "id": "B",
          "metin": "İlk tahminimizde hep ısrar etmemiz gerektiğini"
        },
        {
          "id": "C",
          "metin": "Rehberlerin hiç yanılmadığını"
        }
      ],
      "dogru": "A",
      "aciklama": "Rehber, tahmin etmenin kötü olmadığını, önemli olanın yeni bilgiyle düşünceyi değiştirmek olduğunu söyledi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 5,
      "metin": "Metinde geçen katman sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir tür harita"
        },
        {
          "id": "B",
          "metin": "Kayanın içindeki boşluk"
        },
        {
          "id": "C",
          "metin": "Üst üste duran tabakalardan her biri"
        }
      ],
      "dogru": "C",
      "aciklama": "Taş katmanları üst üste duran açık ve koyu renkli tabakalardı."
    },
    {
      "id": "s5",
      "beceri": "hatirlama",
      "dayanak_sayfa": 7,
      "metin": "Çocuk dönüş yolunda bulduğu çakıl taşını ne yaptı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Cebine koydu"
        },
        {
          "id": "B",
          "metin": "Ait olduğu yerde bıraktı"
        },
        {
          "id": "C",
          "metin": "Defterine yapıştırdı"
        }
      ],
      "dogru": "B",
      "aciklama": "Taşı almadı; hatıra olarak fotoğraf ve çizimlerin yeteceğini söyledi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p03$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr019-magaranin-uc-isareti: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p04${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr021-kayip-sandigin-sifresi",
    "baslik": "Kayıp Sandığın Şifresi",
    "tur": "macera",
    "konu": "kutuphane",
    "sinif_alt": 4,
    "sinif_ust": 4,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas"
    ],
    "deger_anahtarlari": [
      "D4",
      "D16"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "gizem",
        "dostluk",
        "okul",
        "kultur_miras"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D4",
        "yardimci_deger": "D16"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sifre_hr021",
          "tur": "lexeme",
          "etiket": "şifre",
          "yuva": "pa_sifre",
          "islev": "first_hint"
        },
        {
          "id": "hatira_hr021",
          "tur": "lexeme",
          "etiket": "hatıra",
          "yuva": "pa_hatira",
          "islev": "application"
        },
        {
          "id": "kavram_hr021",
          "tur": "concept",
          "etiket": "Mantıksal sıralama ve ortak hafıza",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (4. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 455,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 9,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 2,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1
        },
        "yoldas_yer_sayisi": 3,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Dört boş yuva, dört gizemli cümle: Tozlu sandığı zorlamadan açmanın bir yolu var mı?",
    "durum": "taslak",
    "fis_kodu": "HR-021"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kütüphanenin taşınacağı gün, dört arkadaş tozlu bir sandık buldu. Üzerinde güneş, yaprak, dalga ve yıldız şekilleri vardı. Fakat şekillerin bulunduğu dört küçük yuva boştu. Sandığın yanında, yıllar önce hazırlanmış bir not duruyordu: \"Bu sandık, bir sınıfın unutmadığı şeylerle açılır.\" \"İçinde ne olabilir?\" diye fısıldadı Ömer. \"Eski haritalar!\" dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". \"Belki de gizli bir kulübün defteri.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kütüphane görevlisi sandığın okula ait olduğunu, önce içindekileri kayıt altına almaları gerektiğini söyledi. Kilidi zorlamamalarını da hatırlattı. Çocuklar notu dikkatle inceledi. Altında dört cümle daha vardı: \"Bizi ısıtan; büyümemizi sağlayan; uzakları yakın eden; gece yol gösteren.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk cümleyi okuyunca güneşi düşündü. Ancak güneşin yerine hangi şeklin konacağını bilmiyorlardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Okulun eski fotoğraf albümünde aynı dört simgenin bulunduğu bir sayfa keşfettiler. Sayfanın altında \"Dördüncü Sınıf "
        },
        {
          "t": "kelime",
          "yuva": "pa_hatira"
        },
        {
          "t": "metin",
          "v": " Projesi\" yazıyordu. Albümde, öğrencilerin güneşli bir günde fidan diktiği, dere kıyısında temizlik yaptığı, yıldızları gözlediği ve uzaktaki bir sınıfa mektup gönderdiği fotoğraflar vardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Albümün kenarında ayrıca dört farklı el yazısı vardı. Güneş fotoğrafının yanına \"Birlikte ısındık\", fidanların altına \"Birlikte büyüttük\", dere temizliğine \"Birlikte koruduk\", yıldız gözlemine \"Birlikte merak ettik\" yazılmıştı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bu cümleleri yüksek sesle okuduğunda "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sandığın notuyla aynı sözcüklerin tekrarlandığını fark etti. \"Sanki biri hatırlamamızı istemiş,\" dedi. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ömer sandığı açmak için sabırsızlanıyordu. \"Bir denesek ne olur? Belki doğru şekil kendiliğinden oturur.\" Görevli, parçaları zorlamanın eski kartonları kırabileceğini hatırlattı. Dört arkadaş masanın üzerinde kâğıttan bir sandık resmi çizdi, şekilleri önce oraya yerleştirdi. Bir şeyin cevabını bulmak için her zaman asıl nesneyi kurcalamak gerekmediğini keşfettiler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kerem, dört cümleyi fotoğraflarla eşleştirmek istedi. \"Bizi ısıtan güneş. Büyümemizi sağlayan yaprak,\" dedi. Ömer sözünü kesti: \"Peki 'uzakları yakın eden' neden dalga olsun?\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir fotoğrafı gösterdi. Dere kıyısındaki çalışmanın ardından çocuklar, temiz suyun uzak yerlerdeki canlılar için de önemli olduğunu anlatan bir mektup hazırlamışlardı. Ama dalganın doğrudan uzakları yakın ettiği kesin değildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Belki notu yanlış yorumluyoruz,\" diye düşündü. Yeniden albüme döndüler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Son sayfada küçük bir şiir vardı: \"Güneş sabahı getirir, yaprak yaşamı büyütür, dalga sesimizi taşır, yıldız geceyi süsler.\" Çocuklar bunun bir "
        },
        {
          "t": "kelime",
          "yuva": "pa_sifre"
        },
        {
          "t": "metin",
          "v": " değil, sınıfın dört etkinliğini hatırlatan bir sıra olduğunu anladı. Sandığın yanındaki çekmecede kartondan yapılmış dört şekil bulundu. Şekilleri albümdeki sıraya göre yerleştirdiklerinde sandığın mekanik mandalı tık etti. Görevli kapağı kendisi açtı. "
        },
        {
          "t": "isaret",
          "kod": "anahtar"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İçeriden altın çıkmadı. Dört küçük defter, öğrencilerin çekilmiş fotoğrafları ve bir paket kuru tohum çıktı. Defterlerin birinde şu cümle yazılıydı: \"Yıllar sonra açacak olanlara: Biz bu okulu yalnızca derslerimizle değil, birlikte yaptıklarımızla hatırlıyoruz.\" Ömer önce biraz hayal kırıklığına uğradı. Sonra tohum paketini eline aldı. \"Bunları dikebilir miyiz?\" diye sordu. Görevli, tohumların eski olduğu için filizlenmeyebileceğini, yine de denemelerini önerdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar sandığın içindekileri düzenleyip okul arşivine teslim etti. Çekmecedeki dört şeklin kopyalarını da yeni hatıra panosuna yerleştirdiler. Bir hafta sonra sınıflarına ait bir fotoğraf çektiler. Fotoğrafın arkasına herkes bir cümle yazdı. "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " cümlesi şuydu: \"Bir sandığın en değerli şifresi, insanların birlikte biriktirdiği anılardır.\""
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 8,
      "metin": "Sandığın içinden ne çıktı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Altın sikkeler"
        },
        {
          "id": "B",
          "metin": "Eski haritalar"
        },
        {
          "id": "C",
          "metin": "Defterler, fotoğraflar ve bir paket kuru tohum"
        },
        {
          "id": "D",
          "metin": "Gizli bir kulübün üyelik kartları"
        }
      ],
      "dogru": "C",
      "aciklama": "İçeriden altın çıkmadı; dört küçük defter, fotoğraflar ve kuru tohum paketi çıktı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 7,
      "metin": "Çocuklar şekilleri hangi sıraya göre yerleştireceklerini nereden anladı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Albümün son sayfasındaki şiirden"
        },
        {
          "id": "B",
          "metin": "Görevlinin söylediği sıradan"
        },
        {
          "id": "C",
          "metin": "Sandığın kilidinin üzerindeki numaralardan"
        },
        {
          "id": "D",
          "metin": "Notun ilk cümlesinden"
        }
      ],
      "dogru": "A",
      "aciklama": "Son sayfadaki şiir, dört etkinliği sırayla hatırlatıyordu; şekilleri bu sıraya göre yerleştirdiler."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Albümdeki \"Birlikte ısındık\", \"Birlikte büyüttük\" gibi yazılar sınıfın neyi önemsediğini gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yarışmayı kazanmayı"
        },
        {
          "id": "B",
          "metin": "Ortak yaşantıları ve iş birliğini"
        },
        {
          "id": "C",
          "metin": "Tek başına çalışmayı"
        },
        {
          "id": "D",
          "metin": "Hediye almayı"
        }
      ],
      "dogru": "B",
      "aciklama": "Her yazıda \"Birlikte\" sözcüğü vardı; sınıf yaptıklarını birlikte yapmayı önemsiyordu."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 7,
      "metin": "Metinde geçen şifre sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Eski bir fotoğraf"
        },
        {
          "id": "B",
          "metin": "Sandığın kilidi"
        },
        {
          "id": "C",
          "metin": "Okulun adı"
        },
        {
          "id": "D",
          "metin": "Çözülünce bir şeyi açan gizli işaret ya da söz"
        }
      ],
      "dogru": "D",
      "aciklama": "Şifre, doğru çözülünce sandığı açan gizli düzendir; çocuklar bunu şiirdeki sıra olarak buldu."
    },
    {
      "id": "s5",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "Metinde geçen hatıra sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Geçmişten akılda kalan, unutulmak istenmeyen anı"
        },
        {
          "id": "B",
          "metin": "Yeni alınan bir eşya"
        },
        {
          "id": "C",
          "metin": "Okulun kapısı"
        },
        {
          "id": "D",
          "metin": "Bir tür bilmece"
        }
      ],
      "dogru": "A",
      "aciklama": "Hatıra projesi, sınıfın unutmak istemediği anıları saklamak içindi."
    },
    {
      "id": "s6",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 5,
      "metin": "Çocukların şekilleri sandığa zorlamak yerine önce kâğıt üzerinde denemesi hakkında ne söylenebilir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Gereksiz bir zaman kaybıydı."
        },
        {
          "id": "B",
          "metin": "Görevliyi memnun etmek için yapıldı."
        },
        {
          "id": "C",
          "metin": "Eşyaya zarar vermeden çözüm aramanın akıllıca bir yoluydu."
        },
        {
          "id": "D",
          "metin": "Sandık zaten açık olduğu için yapıldı."
        }
      ],
      "dogru": "C",
      "aciklama": "Zorlamak eski kartonları kırabilirdi; çocuklar nesneye zarar vermeden denedi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p04$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr021-kayip-sandigin-sifresi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p05${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr022-saat-kulesi-neden-durdu",
    "baslik": "Saat Kulesi Neden Durdu?",
    "tur": "gizem",
    "konu": "saat",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas"
    ],
    "deger_anahtarlari": [
      "D16",
      "D5"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "gizem",
        "guvenlik",
        "kesif"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D16",
        "yardimci_deger": "D5"
      },
      "ogrenme_hedefleri": [
        {
          "id": "yelkovan_hr022",
          "tur": "lexeme",
          "etiket": "yelkovan",
          "yuva": "pa_yelkovan",
          "islev": "first_hint"
        },
        {
          "id": "bakim_hr022",
          "tur": "lexeme",
          "etiket": "bakım",
          "yuva": "pa_bakim",
          "islev": "application"
        },
        {
          "id": "olcum_hr022",
          "tur": "lexeme",
          "etiket": "ölçüm",
          "yuva": "pa_olcum",
          "islev": "application"
        },
        {
          "id": "kavram_hr022",
          "tur": "concept",
          "etiket": "Zaman sıralaması ve ölçme",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 380,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 7,
        "soru_sayisi": 5,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1
        },
        "yoldas_yer_sayisi": 6,
        "simge_sayisi": 1
      }
    },
    "tanitim": "Meydanın saat kulesi öğlen çalmadı ve ibreler yanlış yerde. Zamanı kim şaşırttı?",
    "durum": "taslak",
    "fis_kodu": "HR-022"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Meydandaki saat kulesi her öğlen on ikide çalardı. O gün çalmadı. Üstelik akrep on biri, "
        },
        {
          "t": "kelime",
          "yuva": "pa_yelkovan"
        },
        {
          "t": "metin",
          "v": " da altıyı gösteriyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Saat on bir buçukta kalmış!\" dedi. Arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " saatine baktı: \"Ama şimdi on iki on. Kule kırk dakikadır geride.\" İkisi saat kulesine yaklaşmak istedi, fakat çevresinde bakım için ayrılmış bir alan vardı. Bunun yerine belediyenin bilgi noktasına gittiler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Görevli, sorunun sabah bildirildiğini söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hemen \"Demek ki arıza öğlende başlamamış,\" diye düşündü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " defterine üç zamanı yazdı: \"On bir otuz, on iki, on iki on.\" \"Birinci zaman kulenin durduğu saat. İkinci zaman çalması gereken saat. Üçüncü zaman bizim baktığımız saat,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sıralamayı dikkatle kontrol etti. \"Eğer bir saat durmuşsa gerçek zamanı ondan öğrenemeyiz,\" diye ekledi. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "O sırada meydanın karşısındaki çiçekçi, kuleden gelen sesleri özlediğini söyledi. \"Her gün tam öğlen dükkânın önünde kısa bir mola verirdim. Bugün saati şaşırdım,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", duvardaki başka bir saati gösterdi; çiçekçinin telefonu da doğru saati gösteriyordu. İkisi birlikte saatleri karşılaştırınca farklı araçların aynı işi yapabildiğini konuştular."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", \"Peki kule her zaman on iki kez mi çalar?\" diye sordu. Çiçekçi başını iki yana salladı. \"Hayır, saat başında bulunduğu saati bildiren farklı düzenler var. Bizim kulemiz de kendi kurallarına göre çalışır.\" Çocuklar daha önce dikkat etmedikleri bu ayrıntıyı öğrenmiş oldu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bilmediği kısmı defterinde boş bıraktı; uydurmak yerine sonra soracaktı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir süre sonra bakım ustası Fatma Hanım geldi. Çocuklar, kuleye girmeden ona gördüklerini anlattılar. Usta bir güvenlik kapısından geçip içerideki mekanizmayı inceledi. Çarkların arasında küçük bir parça gevşemişti. Parçayı uygun aletlerle sağlamlaştırdı, sonra saati doğru zamana ayarladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", \"Kule neden durmuş?\" diye sordu. Fatma Hanım, \"Bazen büyük makineleri küçük parçalar durdurur,\" dedi. \"Bu yüzden düzenli "
        },
        {
          "t": "kelime",
          "yuva": "pa_bakim"
        },
        {
          "t": "metin",
          "v": " gerekir.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " meydandaki iki farklı saatin bir an için aynı zamanı göstermediğini fark etti. \"Hangisine güveneceğiz?\" diye sordu. \"Doğru çalışan ve güncellenen kaynakları karşılaştıracağız,\" dedi usta. \"Bir "
        },
        {
          "t": "kelime",
          "yuva": "pa_olcum"
        },
        {
          "t": "metin",
          "v": " yanlış olabilir; onu başka bilgilerle kontrol ederiz.\" O akşam kule yeniden çaldı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ilk sesi duyduğunda sevinçten zıplayacaktı ama etraftaki güvercinler ürkmesin diye durdu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterine son bir satır ekledi: \"Önce gözlemledik, sonra bildirdik, en sonunda nedeni öğrendik.\" Eve dönerken "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " şakalaştı: \"Saat kulede durmuş, bizim merakımız hiç durmamış!\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülerek, \"Zaten soruları sormasaydık çarkın ne işe yaradığını öğrenemezdik,\" dedi. Meydan her zamanki gibi kalabalıktı. Bu kez kulağa sıradan gelen saat sesi, ikisine küçük bir keşfi hatırlatıyordu."
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 1,
      "metin": "Saat kulesi hangi saatte durmuştu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "On iki"
        },
        {
          "id": "B",
          "metin": "On iki on"
        },
        {
          "id": "C",
          "metin": "On bir buçuk"
        }
      ],
      "dogru": "C",
      "aciklama": "Kulenin akrebi on biri, yelkovanı altıyı gösteriyordu; saat on bir buçukta kalmıştı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Görevli sorunun sabah bildirildiğini söyleyince çocuk hangi sonuca vardı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Arızanın öğlende başlamadığı sonucuna"
        },
        {
          "id": "B",
          "metin": "Kulenin hiç bozulmadığı sonucuna"
        },
        {
          "id": "C",
          "metin": "Saatin ileri gittiği sonucuna"
        }
      ],
      "dogru": "A",
      "aciklama": "Sorun sabah bildirildiği için arıza öğlende başlamış olamazdı."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Ustanın \"Bir ölçüm yanlış olabilir; onu başka bilgilerle kontrol ederiz\" sözü neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hiçbir saate güvenilmemesi gerektiğini"
        },
        {
          "id": "B",
          "metin": "Tek bir kaynağa bakmak yerine başka kaynaklarla karşılaştırmanın iyi olduğunu"
        },
        {
          "id": "C",
          "metin": "Ölçüm yapmanın gereksiz olduğunu"
        }
      ],
      "dogru": "B",
      "aciklama": "Usta, doğru bilgiye ulaşmak için kaynakların karşılaştırılacağını söyledi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 5,
      "metin": "Metinde geçen bakım sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir şeyi yıkıp yenisini yapmak"
        },
        {
          "id": "B",
          "metin": "Bir şeyin yerini değiştirmek"
        },
        {
          "id": "C",
          "metin": "Bir şeyin iyi çalışması için düzenli olarak kontrol edip onarmak"
        }
      ],
      "dogru": "C",
      "aciklama": "Usta, büyük makineleri küçük parçalar durdurabildiği için düzenli bakım gerektiğini söyledi."
    },
    {
      "id": "s5",
      "beceri": "hatirlama",
      "dayanak_sayfa": 5,
      "metin": "Kule neden durmuştu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çarkların arasındaki küçük bir parça gevşediği için"
        },
        {
          "id": "B",
          "metin": "Güvercinler çarklara girdiği için"
        },
        {
          "id": "C",
          "metin": "Kulenin kapısı kilitli olduğu için"
        }
      ],
      "dogru": "A",
      "aciklama": "Bakım ustası çarkların arasında gevşemiş küçük bir parça buldu."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p05$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr022-saat-kulesi-neden-durdu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p06${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr023-hoca-ve-gorunmeyen-misafir",
    "baslik": "Hoca ve Görünmeyen Misafir",
    "tur": "mizah",
    "konu": "misafirlik",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas"
    ],
    "deger_anahtarlari": [
      "D14",
      "D20"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "mizah",
        "aile",
        "kultur_miras"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D14",
        "yardimci_deger": "D20"
      },
      "ogrenme_hedefleri": [
        {
          "id": "misafir_hr023",
          "tur": "lexeme",
          "etiket": "misafir",
          "yuva": "pa_misafir",
          "islev": "first_hint"
        },
        {
          "id": "israr_hr023",
          "tur": "lexeme",
          "etiket": "ısrar",
          "yuva": "pa_israr",
          "islev": "application"
        },
        {
          "id": "bilmece_hr023",
          "tur": "lexeme",
          "etiket": "bilmece",
          "yuva": "pa_bilmece",
          "islev": "application"
        },
        {
          "id": "kavram_hr023",
          "tur": "concept",
          "etiket": "Misafirperverlik ve kişisel sınırlara saygı",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 367,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 7,
        "soru_sayisi": 5,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 1
      }
    },
    "tanitim": "Nasreddin Hoca'nın sofrasında dördüncü tabak neden boş? Görünmeyen misafirin sırrı bir soruyla çözülüyor.",
    "durum": "taslak",
    "fis_kodu": "HR-023"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Nasreddin Hoca'nın evinde akşam için üç tabak hazırlanmıştı. Hoca, eşi ve küçük komşuları "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sofraya oturacaktı. Fakat masada dördüncü bir tabak daha vardı. Üstelik tabağın önünde kimse oturmuyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " şaşkınlıkla sordu: \"Hocam, görünmeyen bir misafiriniz mi var?\" Hoca gözlerini büyüttü. \"Varsa bile çok usluymuş. Ayakkabılarını kapıda görmedim!\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülünce Hoca'nın eşi de gülümsedi. \"O tabak, bugün gelemeyeceğini haber veren bir konuğumuz içindi,\" dedi. \"Toplamayı unutmuşum.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tabağı bir süre daha inceledi; yanında "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da merakla bakıyordu. Üstünde bir kaşık, yanında katlanmış bir peçete vardı. Ona göre "
        },
        {
          "t": "kelime",
          "yuva": "pa_misafir"
        },
        {
          "t": "metin",
          "v": " gerçekten görünmezse kaşığı nasıl tutacağını kimse bilemezdi. \"Belki bir hayalet gelir,\" diye şaka yaptı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hoca ise \"Önce evde görünür işleri tamamlayalım: Kapıyı biri çalarsa açacağız, sofrayı da sıcak tutacağız,\" dedi. Hoca'nın eşi, biraz önce gelemeyen misafirin haber göndermesini hatırlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", haber vermenin neden önemli olduğunu sordu. \"Çünkü biz de ona göre hazırlanırız,\" dedi. \"Küçük bir cümle büyük bir yanlış anlamayı önleyebilir.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", okuldan geç döneceği gün ailesine haber vermeyi düşündü. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Tam o sırada kapı çalındı. "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " karşı komşusu Hasan amca içeriye baktı. Elinde bir sepet vardı. \"Size bahçemden elma getirdim. Ama oyalanmayayım,\" dedi. Hoca, boş tabağı işaret etti. \"Bakınız, tabak sizden önce gelmiş!\" Hasan amca şaşırdı. \"Beni beklediğinizi bilmiyordum.\" \"Biz de bilmiyorduk,\" dedi Hoca. \"Bazen yer hazır olur, misafir sonradan belli olur.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hasan amca oturmak istemedi. Evinin kapısı açıktı ve kedisi içeride yalnız kalmıştı. Hoca bu kez "
        },
        {
          "t": "kelime",
          "yuva": "pa_israr"
        },
        {
          "t": "metin",
          "v": " etmedi. \"Öyleyse elmalarınızı aldığımız gibi size de yol arkadaşı olalım,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ve Hoca komşuyu evine kadar geçirmek için ona eşlik etti. Dönüşte "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir soru sordu: \"Misafirperverlik, herkesi mutlaka sofraya oturtmak mıdır?\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hoca başını iki yana salladı. \"Misafirin ihtiyacını anlamak da önemlidir. Kimi oturup dinlenmek ister, kimi yalnızca kapıda selam verir.\" Eve geldiklerinde dördüncü tabağı yerine kaldırdılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Demek görünmeyen misafirimiz aslında bir yanlış anlamaymış,\" dedi. \"Öyle,\" dedi Hoca. \"Ama yanlış anlamak, doğru soru sorunca hemen görünür olur.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yemekte elmalardan birini paylaştılar. Hoca, "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " bir "
        },
        {
          "t": "kelime",
          "yuva": "pa_bilmece"
        },
        {
          "t": "metin",
          "v": " sordu: \"Dört tabağımız vardı; üç kişi oturduk; sonra misafir kapıya geldi. Kaç kişi sofrada yemek yedi?\" \"Üç,\" dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". \"Çünkü Hasan amca oturmadı.\" Hoca gülümsedi. \"Aferin! Görmediğimiz birini sayarken önce ne olduğunu anlamak gerekir.\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de başıyla onayladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " artık sofradaki boş yerlere bakıp hemen korkunç bir hikâye düşünmemeye karar verdi."
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 2,
      "metin": "Dördüncü tabak neden masadaydı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Görünmeyen bir misafir için konmuştu"
        },
        {
          "id": "B",
          "metin": "Gelemeyeceğini haber veren bir konuk içindi ve toplanmamıştı"
        },
        {
          "id": "C",
          "metin": "Hasan amca için hazırlanmıştı"
        }
      ],
      "dogru": "B",
      "aciklama": "Hoca'nın eşi, tabağın gelemeyeceğini haber veren bir konuk için olduğunu ve toplamayı unuttuğunu söyledi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 5,
      "metin": "Hasan amca neden sofraya oturmak istemedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Elmaları beğenmediği için"
        },
        {
          "id": "B",
          "metin": "Yemek yemek istemediği için"
        },
        {
          "id": "C",
          "metin": "Evinin kapısı açıktı ve kedisi içeride yalnız kalmıştı"
        }
      ],
      "dogru": "C",
      "aciklama": "Hasan amca, evinin kapısı açık olduğu ve kedisi içeride yalnız kaldığı için oturmak istemedi."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Hoca'nın \"Misafirin ihtiyacını anlamak da önemlidir\" sözü ne anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Misafirin ne istediğine dikkat etmenin, herkesi aynı biçimde ağırlamaktan önemli olduğunu"
        },
        {
          "id": "B",
          "metin": "Misafirin her zaman sofrada oturması gerektiğini"
        },
        {
          "id": "C",
          "metin": "Misafire hiç soru sorulmaması gerektiğini"
        }
      ],
      "dogru": "A",
      "aciklama": "Hoca, kimi misafirin dinlenmek, kimininse yalnızca selam vermek istediğini söyledi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 5,
      "metin": "Metinde geçen ısrar etmek ifadesi ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir şeyi hemen unutmak"
        },
        {
          "id": "B",
          "metin": "Bir şeyi kabul ettirmek için üstelemek"
        },
        {
          "id": "C",
          "metin": "Bir yerden uzaklaşmak"
        }
      ],
      "dogru": "B",
      "aciklama": "Hasan amca oturmak istemeyince Hoca onu üstelemedi, ısrar etmedi."
    },
    {
      "id": "s5",
      "beceri": "hatirlama",
      "dayanak_sayfa": 7,
      "metin": "Hoca'nın sorduğu bilmecenin cevabı neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Dört"
        },
        {
          "id": "B",
          "metin": "İki"
        },
        {
          "id": "C",
          "metin": "Üç"
        }
      ],
      "dogru": "C",
      "aciklama": "Sofraya üç kişi oturdu; Hasan amca oturmadığı için cevap üçtü."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p06$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr023-hoca-ve-gorunmeyen-misafir: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p07${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr024-bulut-postacisinin-son-mektubu",
    "baslik": "Bulut Postacısının Son Mektubu",
    "tur": "fantastik",
    "konu": "bulutlar",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 2,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D16",
      "D15"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kesif",
        "dostluk"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D16",
        "yardimci_deger": "D15"
      },
      "ogrenme_hedefleri": [
        {
          "id": "adres_hr024",
          "tur": "lexeme",
          "etiket": "adres",
          "yuva": "pa_adres",
          "islev": "first_hint"
        },
        {
          "id": "pusula_hr024",
          "tur": "lexeme",
          "etiket": "pusula",
          "yuva": "pa_pusula",
          "islev": "application"
        },
        {
          "id": "yon_hr024",
          "tur": "lexeme",
          "etiket": "yön",
          "yuva": "pa_yon",
          "islev": "application"
        },
        {
          "id": "kavram_hr024",
          "tur": "concept",
          "etiket": "Yönler ve adres bilgisi",
          "islev": "application"
        },
        {
          "id": "atasoz_hr024",
          "tur": "proverb",
          "etiket": "Acele işe şeytan karışır",
          "yuva": "pa_ata_acele",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 380,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 7,
        "soru_sayisi": 5,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Postacı Pofuduk kuzeye uçtuğunu sanıyor ama altında çöl var. Çantadaki son mektup yerine ulaşabilecek mi?",
    "durum": "taslak",
    "fis_kodu": "HR-024"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bulutlar Şehri'nde herkesin bir görevi vardı. Yağmur Bulutu bahçeleri sular, Rüzgâr Bulutu yelkenlere yardım eder, Postacı Pofuduk ise mektupları götürürdü. O sabah Pofuduk'un çantasında yalnızca bir zarf kalmıştı. Üzerinde şu "
        },
        {
          "t": "kelime",
          "yuva": "pa_adres"
        },
        {
          "t": "metin",
          "v": " yazıyordu: \"Kuzey Tepesi, Mavi Pencereli Ev.\" "
        },
        {
          "t": "isaret",
          "kod": "bulut"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Pofuduk kuzeye uçtuğunu sanıyordu. Fakat birkaç dakika sonra altındaki deniz yerine kocaman bir çöl gördü. \"Bu işte bir terslik var,\" diye mırıldandı. Yanında uçan yol arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da şaşırmıştı. Çantasında bir "
        },
        {
          "t": "kelime",
          "yuva": "pa_pusula"
        },
        {
          "t": "metin",
          "v": " vardı; onu çıkarıp baktı. İbre kuzeyi gösterirken kendisi güneye ilerliyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Rüzgâr Bulutu yanına sokuldu. \"Ben seni sürükledim, özür dilerim.\" \"Önemli değil,\" dedi Pofuduk. \"Ama mektup sahibini bekletmeyelim.\" İkisi birlikte yönlerini düzeltti. Derken birbirine benzeyen iki tepe gördüler. Birinde kırmızı çatılı, diğerinde mavi pencereli ev vardı. Pofuduk hemen aşağı inecekti ki bir ayrıntıyı fark etti: Mavi pencere güneş ışığından mı mavi görünüyordu, yoksa gerçekten maviye mi boyanmıştı?"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " aşağıdaki kuş sürüsüne seslendi. Kuşların lideri, mavi pencereli evin kuzeydeki ikinci tepede olduğunu söyledi. Pofuduk teşekkür etti; adresin yalnızca renk değil, "
        },
        {
          "t": "kelime",
          "yuva": "pa_yon"
        },
        {
          "t": "metin",
          "v": " bilgisi de verdiğini anladı. Evin çatısına konmadan önce çantasını kontrol etti. Yağmur Bulutu biraz önce yanından geçmişti; zarfın ıslanmaması için onu dikkatle saklamıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Zarfın köşesindeki pulun üzerinde küçük bir yıldız vardı. Postacı, yıldızın yön göstermediğini, yalnız süs olduğunu fark etti. Bir resim, her zaman haritadaki bir işaret değildi. Tam mektubu bırakacağı sırada evin penceresi açıldı. İçeriden gelen ses, \"Mavi pencereyi mi arıyorsun?\" diye sordu. Pofuduk adresi bir kez daha okudu ve tepeyi teyit etti. Yanlış bir eve gidip başkasının haberini paylaşmak istemiyordu. Zarfın üzerindeki ismi ve kapıdaki ismi karşılaştırdı. İkisi de aynıydı. Ancak ondan sonra yaklaşarak mektubu verdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Evde yaşlı bir teyze yaşıyordu. Zarfı açınca gözleri parladı. Uzakta okuyan torunu, kendi yaptığı çizimin fotoğrafını göndermişti. Mektupta \"Büyüyünce bulut ressamı olacağım\" yazıyordu. Pofuduk teyzenin gülümsemesini görünce yorgunluğunu unuttu. \"Bir mektup bu kadar önemli olabilir mi?\" diye sordu. \"Elbette,\" dedi teyze. \"Bazen bir haber, uzağı yakın eder.\" "
        },
        {
          "t": "isaret",
          "kod": "kalp"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Pofuduk dönüş yolunda çantasını boş buldu ama kendisini eksik hissetmedi. O gün bir zarfın yalnız kâğıt değil, sevincin taşıyıcısı olduğunu öğrenmişti. Yeni bir mektup geldiğinde adresin yönünü iki kez kontrol edecekti. Bulutlar Şehri'ne döndüğünde pusulasını girişteki panoya astı. Altına küçük bir not ekledi: \"Bir yere yetişmek kadar, doğru yere varmak da önemlidir.\" Rüzgâr Bulutu notu okuyup güldü. \"Bir dahaki sefere önce birlikte haritaya bakalım!\" dedi. Pofuduk gülümsedi ve \""
        },
        {
          "t": "atasozu",
          "yuva": "pa_ata_acele"
        },
        {
          "t": "metin",
          "v": "\" diye mırıldandı."
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 2,
      "metin": "Postacı kuzeye uçtuğunu sanırken aslında hangi yöne gidiyordu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kuzeye"
        },
        {
          "id": "B",
          "metin": "Doğuya"
        },
        {
          "id": "C",
          "metin": "Güneye"
        }
      ],
      "dogru": "C",
      "aciklama": "Pusulanın ibresi kuzeyi gösterirken postacı güneye ilerliyordu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Postacı mavi pencereli evin hangi tepede olduğunu nasıl anladı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kuşların liderinin verdiği yön bilgisinden"
        },
        {
          "id": "B",
          "metin": "Rüzgâr Bulutu'nun söylediklerinden"
        },
        {
          "id": "C",
          "metin": "Pulun üzerindeki yıldızdan"
        }
      ],
      "dogru": "A",
      "aciklama": "Kuşların lideri, mavi pencereli evin kuzeydeki ikinci tepede olduğunu söyledi."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 7,
      "metin": "\"Bir yere yetişmek kadar, doğru yere varmak da önemlidir\" sözü ne anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hızlı gitmenin her şeyden önemli olduğunu"
        },
        {
          "id": "B",
          "metin": "Acele etmek kadar doğru yere ulaşmanın da değerli olduğunu"
        },
        {
          "id": "C",
          "metin": "Mektupların hiç gecikmemesi gerektiğini"
        }
      ],
      "dogru": "B",
      "aciklama": "Postacı, hızlı olmanın yanında mektubu doğru adrese götürmenin de önemli olduğunu öğrendi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "Metinde geçen pusula sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Mektup zarfı"
        },
        {
          "id": "B",
          "metin": "Şehir haritası"
        },
        {
          "id": "C",
          "metin": "Yönleri bulmaya yarayan araç"
        }
      ],
      "dogru": "C",
      "aciklama": "Pusulanın ibresi kuzeyi gösterir; postacı yönünü bununla kontrol etti."
    },
    {
      "id": "s5",
      "beceri": "hatirlama",
      "dayanak_sayfa": 6,
      "metin": "Teyzenin torunu mektupta ne yazmıştı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Büyüyünce bulut ressamı olacağım"
        },
        {
          "id": "B",
          "metin": "Yarın eve geliyorum"
        },
        {
          "id": "C",
          "metin": "Seni çok özledim"
        }
      ],
      "dogru": "A",
      "aciklama": "Torun kendi çizimini göndermiş ve bulut ressamı olmak istediğini yazmıştı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p07$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr024-bulut-postacisinin-son-mektubu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p08${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr025-bremen-yolcularinin-yeni-sarkisi",
    "baslik": "Bremen Yolcularının Yeni Şarkısı",
    "tur": "hayvanlar",
    "konu": "muzik",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 2,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayvan"
    ],
    "deger_anahtarlari": [
      "D14",
      "D4"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "hayvanlar",
        "dostluk",
        "sanat_yaraticilik"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D14",
        "yardimci_deger": "D4"
      },
      "ogrenme_hedefleri": [
        {
          "id": "ritim_hr025",
          "tur": "lexeme",
          "etiket": "ritim",
          "yuva": "pa_ritim",
          "islev": "first_hint"
        },
        {
          "id": "ezgi_hr025",
          "tur": "lexeme",
          "etiket": "ezgi",
          "yuva": "pa_ezgi",
          "islev": "application"
        },
        {
          "id": "uyum_hr025",
          "tur": "lexeme",
          "etiket": "uyum",
          "yuva": "pa_uyum",
          "islev": "application"
        },
        {
          "id": "kavram_hr025",
          "tur": "concept",
          "etiket": "Ses, ritim ve uyum",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 377,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 8,
        "soru_sayisi": 5,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Eşek, köpek, kedi ve horoz eski değirmende şarkı söylemek istiyor ama herkes aynı anda bağırıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-025"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eşek, köpek, kedi ve horoz küçük bir orman yolunda yürüyordu. Yol arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de yanlarındaydı. Bremen'e giden uzun yolun ortasında yağmur başladı. Hepsi eski bir değirmene sığındı. Çatının altından düşen damlalar, taşlara farklı seslerle vuruyordu: tak, tik, tuk."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Horoz kanatlarını çırptı. \"Harika bir konser salonu bulduk!\" dedi. Eşek yüksek sesle anırdı. Köpek havladı, kedi miyavladı. Fakat hepsi aynı anda bağırınca ortaya anlaşılmaz bir gürültü çıktı. Kedi kulaklarını kapattı. \"Hepimiz duyulmak istiyoruz ama kimse kimseyi dinlemiyor.\" Eşek biraz alındı. \"Benim sesim zaten böyle güçlü. Sessiz mi olayım?\" \"Hayır,\" dedi köpek. \"Gücünü doğru zamanda kullansan yeter.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Önce horoz "
        },
        {
          "t": "kelime",
          "yuva": "pa_ritim"
        },
        {
          "t": "metin",
          "v": " tuttu. \"Bir, iki, üç, dört.\" Kedi ince sesini ikinci vuruşa, köpek kalın sesini üçüncüye koydu. Eşek dördüncü vuruşta öyle güzel anırdı ki değirmenin içi neşeyle doldu. Sonra yer değiştirdiler. Birinin sesi ötekini bastırdığında durup yeniden başladılar."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir süre sonra eşek ritmi kaçırdı. Çünkü çatıdan damlayan suyun sesi hızlanmıştı. \"Ben yanlış mı söylüyorum?\" diye sordu. Horoz, \"Belki de herkes aynı ritmi duymuyor,\" dedi. Köpek önce dört eşit adım attı, sonra ayak izlerini yerde gösterdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de vuruşları saymalarına yardım etti. Dört sesin arasına küçük bir sessizlik koyduklarında şarkı daha anlaşılır oldu. Kedi, \"Bazen susmak da müziğin parçası,\" diyerek gülümsedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eşek bir daha anırmadan önce arkadaşlarına baktı. Onlardan işaret alınca sesini yükseltti. Kendi sesinin kıymetini kaybetmemiş, yalnız diğerlerine yer açmıştı. Değirmenin damlaları da sanki onlara eşlik ediyordu. Yağmurun sesi azaldıkça yeni bir "
        },
        {
          "t": "kelime",
          "yuva": "pa_ezgi"
        },
        {
          "t": "metin",
          "v": " kurdular. "
        },
        {
          "t": "isaret",
          "kod": "kus"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Dışarıda yağmur hafifledi. Yol kenarında bir grup çocuk vardı. Çocuklar değirmenin içinden gelen müziği merak etmişti. Hayvanlar kapıya çıktı ve kısa şarkılarını söylediler. Çocukların biri ellerini çırparak eşlik etti. Bir başkası yağmur damlalarının sesini taklit etti. Böylece şarkıya yeni bir ritim eklendi. Horoz gururla kabardı. \"Artık hepimiz aynı sesle mi şarkı söyleyeceğiz?\" diye sordu. \"Hayır,\" dedi kedi. \"Güzel olan zaten farklı seslerimiz.\" "
        },
        {
          "t": "isaret",
          "kod": "kedi"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kedi, değirmenin duvarına kulak verdi. Sesler artık birbirine karışmıyordu. \"Bence yolculuğumuzun bir şarkısı oldu,\" dedi. Horoz da bunu her molada yeniden söylemeyi önerdi. Yağmur tamamen dinince yola devam ettiler. Köpek, değirmende öğrendikleri ritmi unutmamak için adımlarını saydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eşek, su birikintilerinden geçerken adımlarını yavaşlattı. Horoz zaman zaman hızlanmak istediğinde arkadaşları ona yetişmeleri için biraz durmasını söyledi. Akşama doğru uzaktan Bremen'in çanları duyuldu. Dört arkadaş birbirine baktı. Çanların sesini kendi şarkılarına eklemeyi düşündüler. Şehre daha varmadan öğrendikleri şey açıktı: "
        },
        {
          "t": "kelime",
          "yuva": "pa_uyum"
        },
        {
          "t": "metin",
          "v": ", herkesin aynı olması değil, birbirine kulak vermesiydi."
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 2,
      "metin": "Hayvanlar aynı anda bağırınca ne oldu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Anlaşılmaz bir gürültü çıktı"
        },
        {
          "id": "B",
          "metin": "Güzel bir şarkı çıktı"
        },
        {
          "id": "C",
          "metin": "Değirmen yıkıldı"
        }
      ],
      "dogru": "A",
      "aciklama": "Hepsi aynı anda bağırınca ortaya anlaşılmaz bir gürültü çıktı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Eşek ritmi neden kaçırdı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Şarkıyı bilmediği için"
        },
        {
          "id": "B",
          "metin": "Çok yorulduğu için"
        },
        {
          "id": "C",
          "metin": "Çatıdan damlayan suyun sesi hızlandığı için"
        }
      ],
      "dogru": "C",
      "aciklama": "Damlaların sesi hızlanınca eşek ritmi kaçırdı."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Kedinin \"Güzel olan zaten farklı seslerimiz\" sözü neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Herkesin aynı sesle söylemesi gerektiğini"
        },
        {
          "id": "B",
          "metin": "Farklı seslerin birlikte güzel bir uyum oluşturabileceğini"
        },
        {
          "id": "C",
          "metin": "Kimsenin şarkı söylememesi gerektiğini"
        }
      ],
      "dogru": "B",
      "aciklama": "Hayvanlar farklı seslerini birbirine kulak vererek birleştirince şarkı güzelleşti."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "Metinde geçen ritim sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Seslerin ya da vuruşların düzenli tekrar eden akışı"
        },
        {
          "id": "B",
          "metin": "Bir hayvanın yürüyüşü"
        },
        {
          "id": "C",
          "metin": "Bir şehrin adı"
        }
      ],
      "dogru": "A",
      "aciklama": "Horoz \"bir, iki, üç, dört\" diyerek düzenli vuruşlarla ritim tuttu."
    },
    {
      "id": "s5",
      "beceri": "hatirlama",
      "dayanak_sayfa": 8,
      "metin": "Hikâyenin sonunda hayvanlar uyum hakkında neyi öğrendi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Herkesin aynı sesle söylemesi gerektiğini"
        },
        {
          "id": "B",
          "metin": "Sesi en güçlü olanın önde olması gerektiğini"
        },
        {
          "id": "C",
          "metin": "Uyumun, herkesin aynı olması değil birbirine kulak vermesi olduğunu"
        }
      ],
      "dogru": "C",
      "aciklama": "Metnin sonunda uyumun herkesin aynı olması değil, birbirine kulak vermesi olduğu söyleniyor."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p08$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr025-bremen-yolcularinin-yeni-sarkisi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p09${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr026-kelime-makinesinin-karisikligi",
    "baslik": "Kelime Makinesinin Karışıklığı",
    "tur": "mizah",
    "konu": "kelime_makinesi",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "kardes",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D3",
      "D2"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "mizah",
        "bilim_teknoloji",
        "okuma_kitap",
        "aile"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D3",
        "yardimci_deger": "D2"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_gul_hr026",
          "tur": "lexeme",
          "etiket": "gül",
          "yuva": "pb_gul",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_yuz_hr026",
          "tur": "lexeme",
          "etiket": "yüz",
          "yuva": "pb_yuz",
          "islev": "application"
        },
        {
          "id": "sozcuk_yaz_hr026",
          "tur": "lexeme",
          "etiket": "yaz",
          "yuva": "pb_yaz",
          "islev": "application"
        },
        {
          "id": "kavram_hr026",
          "tur": "concept",
          "etiket": "Bağlam ve çok anlamlılık (sesteş sözcükler)",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 352,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 7,
        "soru_sayisi": 5,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 2
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1
        },
        "yoldas_yer_sayisi": 6,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Dedenin kelime makinesi ‘gül’ ve ‘yüz’ karşısında şaşırıyor. Makine mi yanlış anlıyor, biz mi?",
    "durum": "taslak",
    "fis_kodu": "HR-026"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " dedesi, kelimelerle oynayan küçük bir makine yapmıştı. Makinenin üstünde üç düğme vardı: Oku, Düşün, Söyle. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk düğmeye bastığında ekranda şu cümle belirdi: "
        },
        {
          "t": "vurgu",
          "v": "Bahçedeki {kelime:pb_gul} bana güldü."
        },
        {
          "t": "metin",
          "v": " “Çiçek mi kahkaha attı?” diye sordu kardeşi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": "."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Makine cümleyi yorumlamak yerine masaya kırmızı bir gül resmi çizdi ve yanına kahkaha işareti koydu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “İkisi de "
        },
        {
          "t": "kelime",
          "yuva": "pb_gul"
        },
        {
          "t": "metin",
          "v": " diye yazılıyor ama aynı anlama gelmiyor,” dedi. Dede gülümsedi. “Demek ki bir kelimenin nerede kullanıldığını anlamak gerekiyor.” "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yeni cümleyi söyledi: “Dedem "
        },
        {
          "t": "kelime",
          "yuva": "pb_yuz"
        },
        {
          "t": "metin",
          "v": " sayfasını okudu.” Makine masaya yüz tane yüz resmi çizdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gülmekten iki büklüm oldu. “Ben sayıyı söyledim!” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterine örnekleri yazdı. Bir tarafta yüz sayısı, diğer tarafta yüz sözcüğünün insanın suratı anlamı vardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sonra kardeşinden yeni bir örnek istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " hemen, “Yaz geldi, sen de "
        },
        {
          "t": "kelime",
          "yuva": "pb_yaz"
        },
        {
          "t": "metin",
          "v": "!” dedi. Makine ekrana güneş resmi ve bir kalem çizdi. Bu kez doğruya yaklaşmıştı. Dede masaya iki kart daha koydu. Birinde “Kışın kar yağdı”, diğerinde “Bize kâr kaldı” yazıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " harfleri dikkatle inceledi. “Bunlar aynı yazılmıyor; sesleri de tam aynı değil,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Dede onayladı: “Her benzer kelimeyi aynı gruba koyamayız.” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de yeni bir kart istedi. “O zaman yalnız gerçekten aynı yazılan ve farklı anlamlara gelen örneklerle başlayalım.” Makine bu uyarıyı duyunca ekrana büyük bir soru işareti çıkardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Sorular bazen cevaptan daha işe yarar,” diye düşündü. Makinenin hatasını bulmak, düğmelerine rastgele basmaktan daha çok zaman almış ama daha eğlenceli olmuştu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bütün cümlelerin küçük bir ipucu taşıdığını fark etti. “Yaz geldi” derken mevsimden söz ediyorlardı. “Sen de yaz” derken ise kalemle bir şeyler yazmayı istiyorlardı. Kelimenin yanındaki başka sözcükler anlamı bulmalarını sağlıyordu. Dede, “Peki makinenin hatasını nasıl azaltacağız?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir kural kartı hazırladı: Önce tüm cümleyi oku; sonra kelimenin anlamını seç. Kartı makinenin yanına koydular. "
        },
        {
          "t": "isaret",
          "kod": "kitap"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Son denemede "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Çay kıyısında çay içtik,” dedi. Makine bu kez su akan bir dere ile iki fincan çizdi. İki kardeş sevinçle alkışladı. Ancak makine beklenmedik bir soru sordu: “Peki kelimelerin iki anlamı varsa, insanların da bazen birden fazla duygusu olur mu?” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " biraz düşündü. “Olur,” dedi. “Hem heyecanlı hem çekingen olabilirim.” Dede ona bakıp gülümsedi. Bir kelime oyunu, o gün yeni bir konuşmanın kapısını açmıştı."
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 2,
      "metin": "Makine ‘Bahçedeki gül bana güldü’ cümlesi için masaya ne çizdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kırmızı bir gül resmi ve kahkaha işareti"
        },
        {
          "id": "B",
          "metin": "Bir bahçe ve bir kapı"
        },
        {
          "id": "C",
          "metin": "Güneş ve bir kalem"
        }
      ],
      "dogru": "A",
      "aciklama": "Makine masaya kırmızı bir gül resmi çizdi ve yanına kahkaha işareti koydu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Makine ‘Dedem yüz sayfasını okudu’ cümlesinde neden yüz tane yüz resmi çizdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü cümleyi hiç duymadı"
        },
        {
          "id": "B",
          "metin": "Çünkü kitapta yüz tane yüz vardı"
        },
        {
          "id": "C",
          "metin": "Çünkü yüz sözcüğünün sayı mı, suratın adı mı olduğunu ayıramadı"
        }
      ],
      "dogru": "C",
      "aciklama": "Makine yüz sözcüğünün iki anlamını karıştırdı; çocuk ise sayıyı söylemişti."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Kural kartında ‘Önce tüm cümleyi oku’ yazması neden önemlidir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü cümle ne kadar kısaysa o kadar iyidir"
        },
        {
          "id": "B",
          "metin": "Çünkü sözcüğün anlamını yanındaki sözcükler belli eder"
        },
        {
          "id": "C",
          "metin": "Çünkü makine yalnızca ilk sözcüğü okur"
        }
      ],
      "dogru": "B",
      "aciklama": "Çocuk, kelimenin yanındaki sözcüklerin anlamı bulmayı sağladığını fark etmişti."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "‘Yaz geldi, sen de yaz!’ cümlesindeki ikinci yaz sözcüğü ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kalemle bir şeyler yazmak"
        },
        {
          "id": "B",
          "metin": "Yılın sıcak mevsimi"
        },
        {
          "id": "C",
          "metin": "Denizde yüzmek"
        }
      ],
      "dogru": "A",
      "aciklama": "‘Sen de yaz’ derken kalemle yazı yazmak kastediliyordu; ilk yaz ise mevsimdi."
    },
    {
      "id": "s5",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "Makine ‘gül’ sözcüğünde hangi iki anlamı karıştırdı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir çiçek ile bir yiyecek"
        },
        {
          "id": "B",
          "metin": "Bir renk ile bir mevsim"
        },
        {
          "id": "C",
          "metin": "Bir çiçek ile gülme eylemi"
        }
      ],
      "dogru": "C",
      "aciklama": "Cümlede hem gül çiçeği hem gülmek eylemi vardı; makine ikisini birleştirdi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p09$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr026-kelime-makinesinin-karisikligi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p10${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr027-karagozun-kayip-golgesi",
    "baslik": "Karagöz'ün Kayıp Gölgesi",
    "tur": "mizah",
    "konu": "golge_oyunu",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 2,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D14",
      "D7"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "mizah",
        "kultur_miras",
        "bilim_teknoloji"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D14",
        "yardimci_deger": "D7"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_golge_hr027",
          "tur": "lexeme",
          "etiket": "gölge",
          "yuva": "pb_golge",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_perde_hr027",
          "tur": "lexeme",
          "etiket": "perde",
          "yuva": "pb_perde",
          "islev": "application"
        },
        {
          "id": "sozcuk_mecaz_hr027",
          "tur": "lexeme",
          "etiket": "mecaz",
          "yuva": "pb_mecaz",
          "islev": "application"
        },
        {
          "id": "kavram_hr027",
          "tur": "concept",
          "etiket": "Işık ve gölge; gerçek ve mecaz anlam",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 350,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 8,
        "soru_sayisi": 5,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Karagöz'ün gölgesi kayboldu! Işık, fener ve bir kaşıkla gölgenin sırrı çözülüyor.",
    "durum": "taslak",
    "fis_kodu": "HR-027"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Karagöz sabah perdeyi kurmak için sahneye geldiğinde telaşla bağırdı: “Hacivat! Gölge yok! Gölge kayboldu!” Hacivat içeri girdi. “Canım Karagöz'üm, gölgen nereye gidebilir?” “Belki benden sıkıldı da tatile çıktı!” dedi Karagöz. Oysa sahnenin arkasındaki lamba henüz yanmıyordu. Perde bembeyazdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hacivat lambayı açtı. Bir anda Karagöz'ün gölgesi perdenin üzerine düştü. Karagöz sevinçle zıpladı. Fakat zıplayınca gölgesi de zıpladı. “Demek geri geldi. Bir de benimle alay ediyor!”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hacivat gülerek lambayı biraz sağa kaydırdı. Karagöz'ün gölgesi sola uzadı. Lambayı yaklaştırınca gölge büyüdü, uzaklaştırınca küçüldü. “Görüyor musun?” dedi. “Işığın yeri değişince gölgenin görünüşü de değişiyor.” Karagöz kaşlarını çattı. “O zaman ben büyüdüm mü küçüldüm mü?” “Sen aynı Karagöz'sün. Yalnız gölgen değişiyor.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hacivat küçük bir deney daha yaptı. Masanın üzerine oyuncak bir ev koyup feneri farklı yönlerden tuttu. Evin bacası bazen uzun, bazen kısa bir gölge bırakıyordu. Karagöz bunu görünce, “Bacanın boyunu kim değiştiriyor?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " henüz gelmemişti ama perdeyi hazırlayan "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Işığın yeri,” diye cevap verdi. Karagöz bir süre düşündü, ardından kendi gölgesine selam verdi. “Öyleyse kendimi büyümüş sanmayayım!” "
        },
        {
          "t": "isaret",
          "kod": "gunes"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hacivat fenerin önüne ikinci bir oyuncak koydu. İki gölge üst üste gelince Karagöz hangisinin kendisine ait olduğunu ayırt edemedi. Hacivat nesneleri ayrı ayrı hareket ettirdiğinde sorun çözüldü. “Bir şeyi anlamak için bazen parçaları tek tek incelemek gerekir,” dedi. Az sonra seyirci çocuklar geldi. Hacivat iki ayrı fener hazırladı. Biri güçlü, diğeri daha zayıf ışık veriyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hacivat çocuklardan güvenli mesafeden perdeyi izlemelerini istedi. Karagöz elindeki tahta kaşığı fenerin önünde tuttu. Kaşığın gölgesi perdeye uzadı. Sonra kaşığı biraz çevirdi; gölgenin şekli değişti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Demek "
        },
        {
          "t": "kelime",
          "yuva": "pb_golge"
        },
        {
          "t": "metin",
          "v": " gerçek nesneyle aynı olmak zorunda değil,” dedi. Hacivat bunu duyunca sevindi. Karagöz ise kaşığı perdenin arkasına sakladı. “Gölgeyi bırakıp kendisini kaybetmeyelim!” diye şaka yaptı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Oyun bitince küçük "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", Hacivat'a bir deyim sordu: “Gölgede kalmak ne demek?” Hacivat cevap verdi: “Bazen biri, başka birinin yanında fark edilmez. Buna gölgede kalmak deriz. Ama gerçek "
        },
        {
          "t": "kelime",
          "yuva": "pb_golge"
        },
        {
          "t": "metin",
          "v": " ile aynı şey değildir.” Karagöz hemen öne atıldı. “Ben hiç gölgede kalmam! Perdeye çıkınca zaten "
        },
        {
          "t": "kelime",
          "yuva": "pb_golge"
        },
        {
          "t": "metin",
          "v": " oluyorum!”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Herkes güldü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterine iki cümle yazdı: Ağacın gölgesinde dinlendim. Kardeşimin başarısının gölgesinde kalmak istemiyorum. Birinde ışık, ötekinde "
        },
        {
          "t": "kelime",
          "yuva": "pb_mecaz"
        },
        {
          "t": "metin",
          "v": " vardı. O gün "
        },
        {
          "t": "kelime",
          "yuva": "pb_perde"
        },
        {
          "t": "metin",
          "v": ", hem kahkaha hem kelime öğretmişti. "
        },
        {
          "t": "isaret",
          "kod": "kitap"
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 1,
      "metin": "Karagöz sabah sahneye geldiğinde neden telaşlandı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Perdeyi kaybetmişti"
        },
        {
          "id": "B",
          "metin": "Gölgesini göremiyordu"
        },
        {
          "id": "C",
          "metin": "Hacivat gelmemişti"
        }
      ],
      "dogru": "B",
      "aciklama": "Karagöz ‘Gölge yok! Gölge kayboldu!’ diye bağırmıştı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 1,
      "metin": "Karagöz'ün gölgesi başlangıçta perdede neden görünmüyordu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sahnenin arkasındaki lamba henüz yanmıyordu"
        },
        {
          "id": "B",
          "metin": "Gölge Karagöz'den sıkılıp gitmişti"
        },
        {
          "id": "C",
          "metin": "Perde çok küçüktü"
        }
      ],
      "dogru": "A",
      "aciklama": "Lamba yanmayınca perdede gölge oluşmuyordu; perde bembeyazdı."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 8,
      "metin": "Çocuğun defterine yazdığı iki cümlenin farkı nedir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "İkisi de gerçek bir ağaçtan söz eder"
        },
        {
          "id": "B",
          "metin": "İkisi de gölgenin ışıkla ilgisini anlatır"
        },
        {
          "id": "C",
          "metin": "Birinde gerçek gölge, ötekinde mecaz anlam vardır"
        }
      ],
      "dogru": "C",
      "aciklama": "Ağacın gölgesi gerçek gölgedir; başarının gölgesinde kalmak ise mecazdır."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 8,
      "metin": "Metinde geçen mecaz sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir gölge oyunu"
        },
        {
          "id": "B",
          "metin": "Bir sözün gerçek anlamından farklı, benzetmeli anlamı"
        },
        {
          "id": "C",
          "metin": "Işığı yakan bir lamba"
        }
      ],
      "dogru": "B",
      "aciklama": "‘Gölgede kalmak’ gerçek gölgeyi değil, fark edilmemeyi anlatır; bu bir mecazdır."
    },
    {
      "id": "s5",
      "beceri": "hatirlama",
      "dayanak_sayfa": 3,
      "metin": "Hacivat lambayı yaklaştırınca Karagöz'ün gölgesine ne oldu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Büyüdü"
        },
        {
          "id": "B",
          "metin": "Kayboldu"
        },
        {
          "id": "C",
          "metin": "Küçüldü"
        }
      ],
      "dogru": "A",
      "aciklama": "Lamba yaklaşınca gölge büyüdü, uzaklaşınca küçüldü."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p10$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr027-karagozun-kayip-golgesi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p11${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr028-uc-renkli-takim",
    "baslik": "Üç Renkli Takım",
    "tur": "arkadaslik",
    "konu": "takim_oyunu",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D4",
      "D14"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "dostluk",
        "okul",
        "dayanisma"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D4",
        "yardimci_deger": "D14"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_takim_hr028",
          "tur": "lexeme",
          "etiket": "takım",
          "yuva": "pb_takim",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_sira_hr028",
          "tur": "lexeme",
          "etiket": "sıra",
          "yuva": "pb_sira",
          "islev": "application"
        },
        {
          "id": "sozcuk_farkli_hr028",
          "tur": "lexeme",
          "etiket": "farklı",
          "yuva": "pb_farkli",
          "islev": "application"
        },
        {
          "id": "kavram_hr028",
          "tur": "concept",
          "etiket": "Takım çalışması ve bireysel güçlü yönler",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 372,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 9,
        "soru_sayisi": 5,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 2,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1
        },
        "yoldas_yer_sayisi": 8,
        "simge_sayisi": 1
      }
    },
    "tanitim": "Biri ip atlar, biri top sürer, biri bulmaca çözer. Aynı oyunu sevmeyen üç arkadaş aynı takımda!",
    "durum": "taslak",
    "fis_kodu": "HR-028"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Okul bahçesinde “Üç Renkli Oyun” yapılacaktı. Ada ip atlamayı, "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " top sürmeyi, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise bulmaca çözmeyi seviyordu. Takımlar üç kişiydi. Üçü aynı takıma seçilince "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " homurdandı: “Biz hiç aynı oyunu sevmiyoruz.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğretmenleri kuralları açıkladı. İlk durakta ip engellerinden geçilecek, ikinci durakta top hedefe atılacak, son durakta renkli kartların şifresi çözülecekti. Takımın başarısı için üç görev de gerekliydi. Başlama işareti verilince "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " öne fırladı. Fakat ilk ip engelinde takıldı. Ada ona yavaşça gösterdi: “Önce sağ ayak, sonra sol. Acele etme.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " denedi ve geçti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Top durağında Ada topu iki kez kaçırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kızmak üzereydi, sonra ilk durakta aldığı yardımı hatırladı. “Topu sert değil, kontrollü gönder,” dedi. Ada bu kez hedefi buldu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " alkışladı. "
        },
        {
          "t": "isaret",
          "kod": "yildiz"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Son durakta masaya üç kart koyulmuştu: kırmızı, mavi ve sarı. Yanlarındaki notta şöyle yazıyordu: Kırmızı, maviden önce; sarı, kırmızıdan sonra; mavi ise en sonda. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kartları dizdi. Fakat öğretmen ilk dizilişi onaylamadı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " dikkatle düşündü. “Sarı, kırmızıdan sonra olabilir; ama maviden önce olmak zorunda mı?” diye sordu. Ada, “Mavi en son,” dedi. “Öyleyse "
        },
        {
          "t": "kelime",
          "yuva": "pb_sira"
        },
        {
          "t": "metin",
          "v": " kırmızı, sarı, mavi!”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Tam son kartı yerleştirirken bir rüzgâr çıktı ve mavi kart uçtu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " arkasından koşmaya kalktı, fakat öğretmen bahçe sınırını gösterdi. Ada, görevliden yedek kart istedi. Yarış biraz gecikti ama kurallara uydular."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yarışın sonlarına doğru başka bir takımın kartlarından biri de yere düştü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onu görünce bir an tereddüt etti. Kartı geri vermek için durursa kendi "
        },
        {
          "t": "kelime",
          "yuva": "pb_takim"
        },
        {
          "t": "metin",
          "v": " daha da yavaşlayacaktı. Ada gözleriyle ne yapacağını sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kartı alıp görevliye teslim etti. “Onlar da oyunu bitirebilsin,” dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " hafifçe gülümsedi; "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " en hızlı olduğu şeyin yalnız koşmak olmadığını düşündü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Son kartları dizdikten sonra üç arkadaş ellerini üst üste koydu. Ada ip atlamayı bilmeyenlere yeniden göstermeyi, "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " topu korkmadan deneyenlere cesaret vermeyi, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise zor bilmecelerin ipuçlarını paylaşmayı teklif etti. Kimse ötekinin bütün işlerini yapmak zorunda değildi. Herkes kendi güçlü yanını sunabilirdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sonuçlar açıklandığında birinci olamadılar. Üçüncülük kurdelesini alırken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " üzülmüştü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise her arkadaşının bir görevde takımı ilerlettiğini söyledi. Ada üç kurdeleyi yan yana tuttu: “"
        },
        {
          "t": "kelime",
          "yuva": "pb_farkli"
        },
        {
          "t": "metin",
          "v": " renkler birlikte daha güzel görünmüyor mu?”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi gün "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir öneriyle geldi: “Bu kez herkesin sevdiği bir oyunu birlikte deneyelim.” Önce ip atladılar, sonra top oynadılar, en sonda "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bilmecelerini çözdüler. Üçü de bütün oyunları aynı derecede sevmedi. Yine de artık farklı olmanın birlikte eğlenmelerine engel olmadığını biliyorlardı."
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 2,
      "metin": "Oyunda üç durak hangi sırayla geçilecekti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bulmaca, top, ip"
        },
        {
          "id": "B",
          "metin": "İp engelleri, top atışı, kart şifresi"
        },
        {
          "id": "C",
          "metin": "Top atışı, kart şifresi, ip engelleri"
        }
      ],
      "dogru": "B",
      "aciklama": "İlk durakta ip engelleri, ikinci durakta top atışı, son durakta kart şifresi vardı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Ada topu kaçırınca çocuk neden kızmak yerine ona yardım etti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü ip engelinde kendisi de yardım almıştı"
        },
        {
          "id": "B",
          "metin": "Çünkü öğretmen bunu emretmişti"
        },
        {
          "id": "C",
          "metin": "Çünkü top çok ağırdı"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuk, ilk durakta Ada'dan aldığı yardımı hatırladı ve ona kontrollü atmayı önerdi."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Çocuğun, düşen başka takımın kartını teslim etmesi neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yarışı kaybetmeyi istediğini"
        },
        {
          "id": "B",
          "metin": "Kuralları bilmediğini"
        },
        {
          "id": "C",
          "metin": "Kazanmaktan çok dürüst ve adil olmayı önemsediğini"
        }
      ],
      "dogru": "C",
      "aciklama": "Çocuk kendi takımı yavaşlayacak olsa da kartı geri vererek diğer takımın da oyunu bitirmesine yardım etti."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "‘Öyleyse sıra kırmızı, sarı, mavi!’ cümlesinde sıra sözcüğü ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Okulda oturulan uzun mobilya"
        },
        {
          "id": "B",
          "metin": "Öne ve arkaya göre dizilişi"
        },
        {
          "id": "C",
          "metin": "Bir yarışın kazananı"
        }
      ],
      "dogru": "B",
      "aciklama": "Kartların önce–sonra düzenini, yani dizilişini anlatır."
    },
    {
      "id": "s5",
      "beceri": "cikarim",
      "dayanak_sayfa": 9,
      "metin": "Birinci olamadıkları hâlde ertesi gün çocuklar neden yeni bir oyun denedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü herkesin sevdiği oyunu birlikte denemek istediler"
        },
        {
          "id": "B",
          "metin": "Çünkü öğretmen yeniden yarış yaptırdı"
        },
        {
          "id": "C",
          "metin": "Çünkü kurdeleleri kaybettiler"
        }
      ],
      "dogru": "A",
      "aciklama": "Bora bu kez herkesin sevdiği oyunu birlikte denemeyi önerdi; farklı olmak eğlenmelerine engel değildi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p11$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr028-uc-renkli-takim: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p12${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr029-minik-mucit-ve-gunes-firini",
    "baslik": "Minik Mucit ve Güneş Fırını",
    "tur": "bilim",
    "konu": "gunes_enerjisi",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D3",
      "D16"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "bilim_teknoloji",
        "kesif",
        "okul"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D3",
        "yardimci_deger": "D16"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_termometre_hr029",
          "tur": "lexeme",
          "etiket": "termometre",
          "yuva": "pb_termometre",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_enerji_hr029",
          "tur": "lexeme",
          "etiket": "enerji",
          "yuva": "pb_enerji",
          "islev": "application"
        },
        {
          "id": "sozcuk_olcum_hr029",
          "tur": "lexeme",
          "etiket": "ölçüm",
          "yuva": "pb_olcum",
          "islev": "application"
        },
        {
          "id": "kavram_hr029",
          "tur": "concept",
          "etiket": "Güneş enerjisi ve ısınma; adil karşılaştırma ve ölçüm",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 372,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 7,
        "soru_sayisi": 5,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1
        },
        "yoldas_yer_sayisi": 5,
        "simge_sayisi": 2
      }
    },
    "tanitim": "İki kutu, iki termometre ve bir bulut: Güneşin ısısını göstermek sanıldığından zor!",
    "durum": "taslak",
    "fis_kodu": "HR-029"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", okulun bilim gününde güneş enerjisini anlatmak istiyordu. Ama güneşi bir kavanoza dolduramayacağına göre, onun ısısını nasıl gösterecekti? Öğretmeniyle birlikte bir kutu modeli hazırlamaya karar verdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğretmen iki eş boy karton kutunun içini aynı koyu renkli kâğıtla kapladı. İkisine de aynı tür saydam kapak yerleştirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ikisinin içine de "
        },
        {
          "t": "kelime",
          "yuva": "pb_termometre"
        },
        {
          "t": "metin",
          "v": " koydu. Hiçbirine yiyecek koymadılar; amaç yalnız sıcaklığı gözlemekti. “Birini güneşte, birini gölgede bekleteceğiz,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Başka koşulları mümkün olduğunca aynı tutmalıyız.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ilk ölçümü deftere yazdı. Her iki termometre de yaklaşık aynı değeri gösteriyordu. On dakika sonra güneşte duran kutunun sıcaklığı daha yüksek çıktı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " hemen bağırdı: “Süper! Kutunun içinde ateş var!” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güldü. “Ateş yok. Ama güneşten gelen "
        },
        {
          "t": "kelime",
          "yuva": "pb_enerji"
        },
        {
          "t": "metin",
          "v": " kutuyu ısıtıyor olabilir.” Öğretmen, saydam kapağın ışığın bir kısmını içeri aldığını ve kutunun ısı kaybını azaltmaya yardımcı olduğunu anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " elini kutuya uzatınca öğretmeni uyardı: “Ölçüm için termometreyi kullanalım. Isınan yüzeylere dokunmak gerekmiyor.” "
        },
        {
          "t": "isaret",
          "kod": "gunes"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Deneyin başında "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " güneşteki kutuyu daha sık açmak istemişti. Öğretmen, kapağın her açılışında içerdeki koşulların değişebileceğini hatırlattı. Bunun üzerine ölçüm zamanlarını önceden belirlediler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çizdiği tabloya saatleri, iki sıcaklığı ve havanın durumunu yazdı. Böylece yalnız “sıcak” veya “soğuk” demek yerine sayıları karşılaştırabildi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkinci ölçümde "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", gölgede duran kutunun da biraz ısındığını görünce şaşırdı. “O kutuya doğrudan güneş gelmedi,” dedi. Öğretmen, havanın sıcaklığının da değişebileceğini söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Öyleyse iki kutunun farkına birlikte bakmalıyız,” diyerek her ikisinin değerini yeniden okudu. Bir deneyde tek bir sonucun her şeyi anlatmayacağını fark etmişti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğleye doğru bulutlar güneşin önünü kapattı. Sonraki ölçüm bekledikleri kadar yüksek çıkmadı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Deney bozuldu,” diye üzüldü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterdeki önceki değerleri gösterdi. “Hayır, yeni bir bilgi öğrendik. Hava durumu da sonucu etkileyebiliyor.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " deney başında yazdığı tahmini okudu. Sonuç tam beklediği gibi değildi; özellikle bulutlu saatte fark azalmıştı. Bu kez defterine bir sonuç cümlesi yerine yeni bir soru yazdı: “Farklı günlerde ölçsek aynı sonuç çıkar mı?”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bilim gününde çocuklar kutuları masaya yerleştirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ziyaretçilere hangi kutunun nerede durduğunu sordu; sonra ölçümleri gösterdi. Küçük bir öğrenci “Bununla yemek pişirebilir miyiz?” diye sorunca "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dikkatli cevap verdi: “Güneş ısısından yararlanan gerçek düzenekler var. Bizim yaptığımız ise öğretmen gözetiminde kullanılan bir "
        },
        {
          "t": "kelime",
          "yuva": "pb_olcum"
        },
        {
          "t": "metin",
          "v": " modeli.” Sergi sonunda öğretmen ona bir yıldız çıkartması verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yıldızı defterine yapıştırmadı; kutuların fotoğrafının yanına koydu. Çünkü en çok, ilk tahminlerini ölçerek karşılaştırabilmiş olmasına seviniyordu. "
        },
        {
          "t": "isaret",
          "kod": "yildiz"
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 2,
      "metin": "Çocuk iki kutuyu nerede bekletmeyi planladı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "İkisini de güneşte"
        },
        {
          "id": "B",
          "metin": "Birini güneşte, birini gölgede"
        },
        {
          "id": "C",
          "metin": "Birini sınıfta, birini bahçede yağmurda"
        }
      ],
      "dogru": "B",
      "aciklama": "Çocuk birini güneşte, birini gölgede bekleteceklerini söyledi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 6,
      "metin": "Bulutlu saatte iki kutu arasındaki fark neden azaldı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü termometreler bozuldu"
        },
        {
          "id": "B",
          "metin": "Çünkü kutular yer değiştirdi"
        },
        {
          "id": "C",
          "metin": "Çünkü bulutlar güneşin önünü kapatıp kutuya gelen enerjiyi azalttı"
        }
      ],
      "dogru": "C",
      "aciklama": "Bulutlar güneşi kapatınca güneşteki kutu daha az ısındı; hava durumu sonucu etkiledi."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Ölçüm zamanlarını önceden belirlemek neden iyi bir fikirdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kapağı sık sık açmak koşulları değiştirebilirdi; plan sonuçları daha güvenilir yaptı"
        },
        {
          "id": "B",
          "metin": "Böylece deney daha çabuk bitti"
        },
        {
          "id": "C",
          "metin": "Böylece kutuyu hiç açmaya gerek kalmadı"
        }
      ],
      "dogru": "A",
      "aciklama": "Kapağın her açılışında içerdeki koşullar değişebileceği için ölçüm saatleri baştan belirlendi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "Metinde geçen enerji sözcüğü bu cümlede neyi anlatır: ‘Güneşten gelen enerji kutuyu ısıtıyor olabilir’?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kutunun içindeki bir ateşi"
        },
        {
          "id": "B",
          "metin": "Isıtma gibi işleri yapabilen güç"
        },
        {
          "id": "C",
          "metin": "Kutunun rengini"
        }
      ],
      "dogru": "B",
      "aciklama": "Güneşten gelen enerji, kutunun ısınmasını sağlayan güçtür; kutuda ateş yoktur."
    },
    {
      "id": "s5",
      "beceri": "hatirlama",
      "dayanak_sayfa": 3,
      "metin": "Öğretmen ısınan kutu yüzeyleri için çocuklara ne yapmalarını söyledi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yüzeye dokunmak yerine termometreyi kullanmalarını"
        },
        {
          "id": "B",
          "metin": "Kutuyu elleriyle yoklamalarını"
        },
        {
          "id": "C",
          "metin": "Kapağı çıkarıp içine bakmalarını"
        }
      ],
      "dogru": "A",
      "aciklama": "Öğretmen, ölçüm için termometreyi kullanmalarını ve ısınan yüzeylere dokunmamalarını söyledi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p12$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr029-minik-mucit-ve-gunes-firini: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p13${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr030-ormanin-kaybolan-patikasi",
    "baslik": "Ormanın Kaybolan Patikası",
    "tur": "macera",
    "konu": "orman_yuruyusu",
    "sinif_alt": 4,
    "sinif_ust": 4,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D16",
      "D5"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kesif",
        "doga",
        "guvenlik"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D16",
        "yardimci_deger": "D5"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_kroki_hr030",
          "tur": "lexeme",
          "etiket": "kroki",
          "yuva": "pb_kroki",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_olcek_hr030",
          "tur": "lexeme",
          "etiket": "ölçek",
          "yuva": "pb_olcek",
          "islev": "application"
        },
        {
          "id": "sozcuk_guzergah_hr030",
          "tur": "lexeme",
          "etiket": "güzergâh",
          "yuva": "pb_guzergah",
          "islev": "application"
        },
        {
          "id": "kavram_hr030",
          "tur": "concept",
          "etiket": "Harita okuma: kroki, ölçek ve güvenli güzergâh",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (4. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 469,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 9,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 2,
          "yorumlama": 1,
          "sozcuk_baglami": 1,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1
        },
        "yoldas_yer_sayisi": 5,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Patika kapalı, levhalar eksik. Üç arkadaş haritayla güvenli bir yol arıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-030"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Orman parkındaki yürüyüşe hazırlanırken öğretmenleri, haritadaki ince yeşil çizgiyi gösterdi. “Bu, gölete ulaşan eski patikamız,” dedi. Ancak park girişindeki görevli onları durdurdu. Geceki şiddetli yağmur yüzünden bazı yerlerde toprak kaymış, patika geçici olarak kapatılmıştı. “Bütün gezi iptal mi?” diye sordu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": "."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Görevli, güvenli ve açık bir başka yol olduğunu, yeni yön levhalarının henüz yerleştirilmediğini söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", arkadaşları "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ve Nisa ile görevliden alternatif yol için bir "
        },
        {
          "t": "kelime",
          "yuva": "pb_kroki"
        },
        {
          "t": "metin",
          "v": " aldı. Öğretmenleri çocukların bir keşif görevi yapmasına izin verdi: Yürüyüş boyunca yalnızca açık "
        },
        {
          "t": "kelime",
          "yuva": "pb_guzergah"
        },
        {
          "t": "metin",
          "v": " üzerinden gidecek, eksik levhaları not edeceklerdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk kavşakta iki yol ayrılıyordu. Haritada sağ taraftaki yolun sonunda piknik alanı, soldaki yolun sonunda gözlem terası görünüyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " sağa dönmek istedi, çünkü oradan kuş sesi geliyordu. Nisa ise haritadaki okları işaret etti. “Kuş sesi yönümüzü göstermiyor. Terasa gitmek için önce sola dönmeliyiz.” "
        },
        {
          "t": "isaret",
          "kod": "orman"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Biraz ileride yerde düşmüş bir levha gördüler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " levhayı kaldırmak istedi, fakat öğretmeni önce çevreye bakmalarını söyledi. Yağmurdan sonra zemin kaygandı. Görevlinin not alması için levhanın yerini haritada işaretlediler; ona dokunmadan yürüdüler. Gözlem terasına vardıklarında gölet uzaktan görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Eski patika haritada daha kısa. Neden orayı kullanmıyoruz?” diye sordu. “Çünkü kısa yol her zaman güvenli yol değildir,” dedi öğretmeni. “Harita, yolun nerede olduğunu gösterir; güncel levhalar ve görevliler ise hangi yolu kullanabileceğimizi bildirir.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Gözlem terasında beklerken Nisa, krokideki küçük karelerin ne işe yaradığını merak etti. Öğretmenleri bunların harita üzerindeki belirli yerleri gösterdiğini anlattı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Kâğıtta iki parmak uzaklıkta olan yerler gerçek hayatta niçin bu kadar uzak?” diye sordu. Öğretmen, haritaların gerçek yerleri küçülterek gösterdiğini söyledi; bu küçültme oranına "
        },
        {
          "t": "kelime",
          "yuva": "pb_olcek"
        },
        {
          "t": "metin",
          "v": " dendiğini ekledi. Çocuklar adımlarını sayarak kısa bir mesafeyi karşılaştırdı ama yaklaşık sonuçları kesin ölçüm sanmamaları gerektiğini de öğrendi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yeni levhaların yalnız doğru yeri göstermesini değil, herkesçe anlaşılmasını istiyordu. Okuma güçlüğü yaşayan küçük çocukların da işaretleri anlayabilmesi için renk ve şeklin yazıyla birlikte kullanılmasını önerdi. Öğretmen öneriyi not etti. Dönüşte park ofisinde görevli, çocukların işaretlediği noktaları inceledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bazı levhalara hayvan resimleri konmasını önerdi. Nisa ise hem simge hem yazı bulunmasının daha anlaşılır olacağını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Bir de kavşaktan önce levha koyarsanız insanlar son anda yön değiştirmek zorunda kalmaz,” diye ekledi. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Park görevlisi önerileri dinlerken Nisa küçük bir ayrıntı daha ekledi. Bazı renkleri ayırt etmekte zorlanan kişiler olabilirdi; bu yüzden yalnız renge güvenmemek gerektiğini söyledi. Levhalara ok, kısa sözcük ve kolay tanınan simgeler koymayı kararlaştırdılar. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da çizdiği kuş resmini yol işaretinden ayırdı: “Güzel bir resim, her zaman açık bir işaret olmayabilir.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir hafta sonra sınıf yeniden parka geldi. Kapatılmış patikanın girişinde hâlâ uyarı vardı, fakat açık yola yeni levhalar yerleştirilmişti. Levhalarda yön oklarının yanında küçük yaprak simgeleri bulunuyordu. Park görevlisi çocuklara teşekkür etti: “Gözlemleriniz, yürüyüşçülerin işini kolaylaştırdı.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eve gidince iki haritayı yan yana koydu: Biri eski patikayı, diğeri güncel ve güvenli güzergâhı gösteriyordu. Aralarındaki farkı renklendirerek çizdi. Defterinin altına şu cümleyi yazdı: İyi bir yol bulmak, yalnızca hedefe varmak değil, oraya güvenle ulaşmaktır."
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 1,
      "metin": "Eski patika neden geçici olarak kapatılmıştı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yeni levhalar yapılacağı için"
        },
        {
          "id": "B",
          "metin": "Geceki şiddetli yağmur toprağı kaydırdığı için"
        },
        {
          "id": "C",
          "metin": "Göletin suyu taştığı için"
        },
        {
          "id": "D",
          "metin": "Park tatil olduğu için"
        }
      ],
      "dogru": "B",
      "aciklama": "Geceki şiddetli yağmur yüzünden bazı yerlerde toprak kaymıştı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Çocuklardan biri neden kuş sesine değil haritadaki oklara güvendi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Harita gidilecek yönü gösterir, kuş sesi yön göstermez"
        },
        {
          "id": "B",
          "metin": "Kuşlar o bölgede hiç yaşamaz"
        },
        {
          "id": "C",
          "metin": "Harita kuş sesinden daha eskidir"
        },
        {
          "id": "D",
          "metin": "Kuş sesi çocukları korkuttuğu için"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuk, kuş sesinin yönü göstermediğini; terasa gitmek için haritaya göre sola dönmeleri gerektiğini söyledi."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "‘Kısa yol her zaman güvenli yol değildir’ sözü bu hikâyede ne anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Uzun yollar her zaman daha güzeldir"
        },
        {
          "id": "B",
          "metin": "Haritalar çoğu zaman yanlıştır"
        },
        {
          "id": "C",
          "metin": "Yolu seçerken yalnız kısalığa değil, güvenli olup olmadığına da bakılmalıdır"
        },
        {
          "id": "D",
          "metin": "Yürüyüşlere hiç çıkılmamalıdır"
        }
      ],
      "dogru": "C",
      "aciklama": "Eski patika kısaydı ama kapalıydı; güncel levha ve görevli güvenli yolu bildiriyordu."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 5,
      "metin": "Metinde geçen ölçek sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Haritadaki yerlerin gerçekte ne kadar küçültülerek gösterildiğini belirten oran"
        },
        {
          "id": "B",
          "metin": "Haritayı süsleyen çizgiler"
        },
        {
          "id": "C",
          "metin": "Yön gösteren bir levha"
        },
        {
          "id": "D",
          "metin": "Bir kuş türü"
        }
      ],
      "dogru": "A",
      "aciklama": "Harita gerçek yerleri küçülterek gösterir; bu küçültme oranına ölçek denir."
    },
    {
      "id": "s5",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 7,
      "metin": "Levhalara yalnız renk koymak yerine ok, kısa yazı ve simge de koymak neden daha iyi bir karardır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü levha daha renkli görünür"
        },
        {
          "id": "B",
          "metin": "Çünkü bazı kişiler renkleri ayırt etmekte zorlanabilir; birden fazla ipucu herkesin anlamasını sağlar"
        },
        {
          "id": "C",
          "metin": "Çünkü yazı olmadan levha yapılamaz"
        },
        {
          "id": "D",
          "metin": "Çünkü simgeler eskiden beri kullanılır"
        }
      ],
      "dogru": "B",
      "aciklama": "Çocuk, bazı renkleri ayırt etmekte zorlanan kişiler olabileceğini düşündü; ok, yazı ve simge birlikte daha açık bir işaret oluşturur."
    },
    {
      "id": "s6",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Düşmüş levhaya dokunmadan yürümelerinin nedeni hangisidir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Levha çok ağırdı"
        },
        {
          "id": "B",
          "metin": "Levha onlara ait değildi"
        },
        {
          "id": "C",
          "metin": "Levhada yazı yoktu"
        },
        {
          "id": "D",
          "metin": "Yağmurdan sonra zemin kaygandı; konumunu işaretleyip görevliye bildirmek daha güvenliydi"
        }
      ],
      "dogru": "D",
      "aciklama": "Öğretmen önce çevreye bakmalarını söyledi; zemin kaygandı ve levhanın yeri haritada işaretlendi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p13$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr030-ormanin-kaybolan-patikasi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p14${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr031-muzede-sessiz-alarm",
    "baslik": "Müzede Sessiz Alarm",
    "tur": "gizem",
    "konu": "muze_alarmi",
    "sinif_alt": 4,
    "sinif_ust": 4,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D6",
      "D14"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "gizem",
        "bilim_teknoloji",
        "kultur_miras"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D6",
        "yardimci_deger": "D14"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_sensor_hr031",
          "tur": "lexeme",
          "etiket": "sensör",
          "yuva": "pb_sensor",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_kanit_hr031",
          "tur": "lexeme",
          "etiket": "kanıt",
          "yuva": "pb_kanit",
          "islev": "application"
        },
        {
          "id": "sozcuk_varsayim_hr031",
          "tur": "lexeme",
          "etiket": "varsayım",
          "yuva": "pb_varsayim",
          "islev": "application"
        },
        {
          "id": "kavram_hr031",
          "tur": "concept",
          "etiket": "Kanıt ile varsayımı ayırmak; acele hüküm vermemek",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (4. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 476,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 9,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 2,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1
        },
        "yoldas_yer_sayisi": 7,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Sessiz müzede alarm öttü. Hırsız mı var, yoksa bir hata mı? Önce kanıt gerek!",
    "durum": "taslak",
    "fis_kodu": "HR-031"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kent müzesinin en sessiz salonundan aniden ince bir ses yükseldi: bip, bip, bip! Ziyaretçiler durdu. Cam vitrindeki tarihî pusula yerli yerindeydi; kimse ona yaklaşmıyordu. Rehber, çocukları güvenli bekleme alanına götürdü. Görevli alarmı kontrol etmeye geldiğinde ses kesildi. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Pusulayı biri mi çalmaya çalıştı?” diye sordu "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Bilmiyoruz,” dedi arkadaşları "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Önce ne olduğunu anlamalıyız.” Bir süre sonra ses yeniden duyuldu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", not defterine saati yazdı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " salondaki kalabalığı gözledi. İlk alarm sırasında bir grup kapının yanında bekliyordu; ikinci alarmda ise salon neredeyse boştu. Bu bilgi, kalabalığın tek başına neden olamayacağını düşündürdü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Rehber, müzede eşyaların korunması için "
        },
        {
          "t": "kelime",
          "yuva": "pb_sensor"
        },
        {
          "t": "metin",
          "v": " adı verilen cihazların kullanıldığını anlattı. “Bu cihazlar hareket, sıcaklık ya da başka değişimleri algılayabilir. Bazen de ayarlarının kontrol edilmesi gerekir,” dedi. Çocuklardan cihazlara ve vitrinlere dokunmamalarını özellikle istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", alarmlar arasında ortak bir ayrıntı fark etti. Her ikisi de havalandırma sisteminin çalışmaya başladığı sırada duyulmuştu. Bunun arızanın nedeni olduğunu kesin söyleyemezdi. “Bu yalnızca bir "
        },
        {
          "t": "kelime",
          "yuva": "pb_varsayim"
        },
        {
          "t": "metin",
          "v": ",” diyerek defterine soru işareti koydu. Rehbere gözlemini aktardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Rehber, alarmın duyulduğu iki saati kontrol odasındaki kayıtlara aktardı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " önce kendi defterindeki saatlerden birini yanlış yazmış olabileceğini düşündü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Zamanları yeniden kontrol edelim,” dedi. Kayıtlar onun notuyla uyuşuyordu. İki farklı kaynağın aynı bilgiyi göstermesi gözlemlerini güçlendirdi ama nedenin ne olduğuna dair henüz kesin bir "
        },
        {
          "t": "kelime",
          "yuva": "pb_kanit"
        },
        {
          "t": "metin",
          "v": " sunmuyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " başka bir olasılık sundu: “Belki alarmı bir telefon sesi tetiklemiştir.” Rehber böyle bir tahmini de not etti; hemen doğru ya da yanlış diye işaretlemedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", hangi düşüncenin kanıtlandığını anlamanın tahmin sayısını çoğaltmaktan daha önemli olduğunu söyledi. O sırada salonda kimseye suçlayıcı gözle bakmamaya özen gösterdiler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Teknik görevli salonun boşaltıldığı güvenli bir anda sistemi denetledi. Vitrinin yakınındaki bir algılayıcının, havalandırmanın oluşturduğu değişime gereğinden fazla duyarlı ayarlandığını belirledi. Yetkili ekip ayarı düzenledi ve alarmı birkaç kez denedi. Artık gereksiz ses duyulmuyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " rahatladı. “Demek kimse pusulayı çalmaya çalışmamış.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dikkatle konuştu: “En azından bu iki alarmın nedeni hırsızlık değilmiş. Başta bunu bilmiyorduk.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Salon yeniden açılmadan önce rehber, ziyaretçilerin neler olduğunu merak ettiğini gördü. Kısa ve sakin bir açıklama yaptı: “Bir koruma sisteminin gereğinden duyarlı ayarı düzeltildi; eserlerimiz güvende.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu açıklamayı beğendi. Hem doğru bilgi veriyor hem de kesinleşmemiş bir suçlama içermiyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", bir sorunun çözülmesinin yalnız aleti onarmak değil, insanlara doğru bilgiyi aktarmak olduğunu düşündü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Gezi devam ettiğinde rehber çocuklara tarihî pusulanın eski yolculuklarda yön bulmaya yardım ettiğini anlattı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " pusulayı izlerken küçük bir çelişki fark etti: “Eskiden insanlar yolda kaybolmamak için pusula kullanıyordu; şimdi de eserleri kaybetmemek için sensör kullanıyoruz.” Sınıfın dönüş otobüsünde herkes en sevdiği eseri söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise defterindeki üç sözcüğü gösterdi: "
        },
        {
          "t": "vurgu",
          "v": "gözlem"
        },
        {
          "t": "metin",
          "v": ", "
        },
        {
          "t": "vurgu",
          "v": "varsayım"
        },
        {
          "t": "metin",
          "v": ", "
        },
        {
          "t": "vurgu",
          "v": "kanıt"
        },
        {
          "t": "metin",
          "v": ". “Bir ses bizi korkutmuştu,” dedi, “ama ne olduğunu anlamak için acele hüküm vermemek gerekiyormuş.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir sonraki hafta müzeden sınıfa teşekkür mesajı geldi. Görevliler, çocukların dikkatli gözlem paylaşımının incelemeyi kolaylaştırdığını yazmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " mesajı okurken gülümsedi; müzedeki en ilginç şeyin yalnız geçmişe ait eşyalar değil, bugün kullanılan bilimsel düşünme biçimi olduğunu fark etti. "
        },
        {
          "t": "isaret",
          "kod": "kitap"
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 6,
      "metin": "Alarmın gereksiz yere çalmasının asıl nedeni neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir ziyaretçi pusulaya dokunmuştu"
        },
        {
          "id": "B",
          "metin": "Müzenin elektriği kesilmişti"
        },
        {
          "id": "C",
          "metin": "Vitrinin yakınındaki algılayıcı, havalandırmanın yarattığı değişime gereğinden fazla duyarlı ayarlanmıştı"
        },
        {
          "id": "D",
          "metin": "Bir telefon sesi alarmı tetiklemişti"
        }
      ],
      "dogru": "C",
      "aciklama": "Teknik görevli, algılayıcının havalandırmanın oluşturduğu değişime fazla duyarlı ayarlandığını belirledi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Çocuklar kalabalığın alarmın tek nedeni olamayacağını neden düşündü?",
      "secenekler": [
        {
          "id": "A",
          "metin": "İlk alarmda kapının yanında bir grup vardı, ikinci alarmda ise salon neredeyse boştu"
        },
        {
          "id": "B",
          "metin": "Müzede hiç ziyaretçi yoktu"
        },
        {
          "id": "C",
          "metin": "Alarm yalnızca geceleri çalardı"
        },
        {
          "id": "D",
          "metin": "Rehber öyle söylemişti"
        }
      ],
      "dogru": "A",
      "aciklama": "Kalabalık ikinci alarmda yoktu; bu yüzden kalabalık tek başına neden olamazdı."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Kayıtlardaki saatlerin çocuğun notuyla uyuşması neyi gösterdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Alarmın nedenini kesin olarak kanıtladı"
        },
        {
          "id": "B",
          "metin": "Gözlemlerin güvenilir olduğunu güçlendirdi ama nedeni henüz kanıtlamadı"
        },
        {
          "id": "C",
          "metin": "Rehberin yanıldığını"
        },
        {
          "id": "D",
          "metin": "Alarmın aslında hiç çalmadığını"
        }
      ],
      "dogru": "B",
      "aciklama": "İki kaynak aynı bilgiyi gösterince gözlemler güçlendi; ancak nedenin ne olduğu hâlâ belli değildi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "‘Bu yalnızca bir varsayım’ cümlesinde varsayım ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kesin olarak kanıtlanmış bilgi"
        },
        {
          "id": "B",
          "metin": "Henüz kanıtlanmamış, doğru olabileceği düşünülen düşünce"
        },
        {
          "id": "C",
          "metin": "Kimsenin duymadığı bir ses"
        },
        {
          "id": "D",
          "metin": "Müzedeki bir eser"
        }
      ],
      "dogru": "B",
      "aciklama": "Çocuk, havalandırmanın neden olduğunu kesin söyleyemediği için bunu varsayım diye işaretledi."
    },
    {
      "id": "s5",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 7,
      "metin": "Rehberin ziyaretçilere yaptığı açıklama neden iyi bir açıklamadır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü çok uzundu"
        },
        {
          "id": "B",
          "metin": "Çünkü sorunu gizledi"
        },
        {
          "id": "C",
          "metin": "Çünkü hırsızın kim olduğunu söyledi"
        },
        {
          "id": "D",
          "metin": "Çünkü kimseyi suçlamadan doğru ve sakin bilgi verdi"
        }
      ],
      "dogru": "D",
      "aciklama": "Açıklama doğru bilgi veriyordu ve kesinleşmemiş bir suçlama içermiyordu."
    },
    {
      "id": "s6",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "Metne göre sensör ne işe yarar?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Müzenin kapısını açan bir anahtardır"
        },
        {
          "id": "B",
          "metin": "Eski eserleri temizleyen bir fırçadır"
        },
        {
          "id": "C",
          "metin": "Hareket, sıcaklık gibi değişimleri algılayan bir cihazdır"
        },
        {
          "id": "D",
          "metin": "Ziyaretçileri sayan bir defterdir"
        }
      ],
      "dogru": "C",
      "aciklama": "Rehber, sensörlerin hareket, sıcaklık ya da başka değişimleri algılayabildiğini anlattı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p14$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr031-muzede-sessiz-alarm: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p15${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr032-keloglan-ve-akilli-terazi",
    "baslik": "Keloğlan ve Akıllı Terazi",
    "tur": "tarih_kultur",
    "konu": "pazar_terazisi",
    "sinif_alt": 4,
    "sinif_ust": 4,
    "okuma_bandi": 3,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D1",
      "D6"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kultur_miras",
        "dayanisma",
        "guvenlik"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D1",
        "yardimci_deger": "D6"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_terazi_hr032",
          "tur": "lexeme",
          "etiket": "terazi",
          "yuva": "pb_terazi",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_denetim_hr032",
          "tur": "lexeme",
          "etiket": "denetim",
          "yuva": "pb_denetim",
          "islev": "application"
        },
        {
          "id": "sozcuk_olcu_hr032",
          "tur": "lexeme",
          "etiket": "ölçü",
          "yuva": "pb_olcu",
          "islev": "application"
        },
        {
          "id": "kavram_hr032",
          "tur": "concept",
          "etiket": "Adil ölçme, doğru tartı ve onarıcı sorumluluk",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (4. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 459,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 9,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 2,
          "yorumlama": 1,
          "sozcuk_baglami": 1,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1
        },
        "yoldas_yer_sayisi": 4,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Pazarda terazinin bir kefesi neden aşağıda kalıyor? Keloğlan, kimseyi küçük düşürmeden doğrusunu buluyor.",
    "durum": "taslak",
    "fis_kodu": "HR-032"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", kasabanın pazarına annesi için bulgur almaya gitti. Sepetinde birkaç bakır para ve düzgünce katlanmış bir alışveriş listesi vardı. İlk tezgâhta satıcı, bir kese bulguru teraziye koydu. Terazinin bir kefesi aşağı indi, öteki hafifçe havada kaldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " keseye, sonra satıcının kullandığı ağırlığa baktı. “Usta, bunun tam bir "
        },
        {
          "t": "kelime",
          "yuva": "pb_olcu"
        },
        {
          "t": "metin",
          "v": " olduğundan emin miyiz?” diye sordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Satıcı kaşlarını kaldırdı. “Bunca yıldır tartıyorum. Sen mi öğreteceksin?” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tartışmak istemedi. “Ben de öğrenmeye çalışıyorum,” dedi. “Aynı ağırlığı başka terazide ölçebilir miyiz?” Yan tezgâhta çalışan "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", herkesin kullanabildiği denetim ağırlıklarını gösterdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", pazardaki belediye görevlisinden de yardım istedi. Görevli önce terazinin dengeli bir zemine oturup oturmadığını kontrol etti. Ardından standart ağırlıkla bir deneme yaptı. İlk terazinin ayarının bozulduğu ortaya çıktı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Satıcının yüzü kızardı. “Demek müşterilere eksik vermiş olabilirim,” dedi. “Kasten yapmadım, ama yine de sorun var.” Pazar görevlisi, ölçme aracının bakım için ayrılması gerektiğini anlattı. Satıcı, o gün satış yaptığı müşterilere durumu duyurmayı ve gerekli düzeltmeleri yapmayı kabul etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " da kimseyi küçük düşürmeden sorunu çözebildikleri için sevindi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " "
        },
        {
          "t": "kelime",
          "yuva": "pb_denetim"
        },
        {
          "t": "metin",
          "v": " işlemini dikkatle izlerken pazara iki müşteri daha geldi. Biri satıcıya sertçe çıkışmak istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " araya girip, “Önce sorunu anlayalım; yanlış teraziyi kullanmayı durdurmak herkes için iyi,” dedi. Satıcı da özür dileyerek terazisini düzelttireceğini yineledi. Pazarda yüksek sesle tartışmak yerine açık konuşmanın daha çok işe yaradığını gördüler. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Görevli, doğru tartımın yalnız alıcıya değil satıcıya da güven sağladığını açıkladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterine ağırlık birimlerini yazdı. Bir kilogramın bin gram ettiğini hatırladı; ancak bir torbanın ağır mı hafif mi olduğunu görünüşüne bakıp söyleyemiyordu. İçindeki tanelerin boyutu, torbanın ağırlığını tek başına göstermiyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ona iki torba gösterdi. Birinde iri taneli, diğerinde ince taneli bulgur vardı. “İkisi de aynı ağırlıkta olabilir mi?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " torbaları elinde tartar gibi yaptı, sonra vazgeçti. “Görünüşe bakıp karar veremem. Teraziye ihtiyacım var.” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “İşte buna ölçüp biçmek derler,” diye gülümsedi. “Bir işe girişmeden önce düşünmek, kontrol etmek.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir müşteri, “Benim aldığım ürünler için de aynı kontrol yapılacak mı?” diye sordu. Satıcı adlarını ve alışveriş saatlerini not ederek geri dönenlerin ölçümünü yeniden yapacağını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " işin burasında kendi payını düşündü: “Bir yanlışlığı görmek yetmez; düzeltilmesine de yardım etmek gerekir.” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " onayladı. Güven, söylenen güzel sözlerle değil, yapılan doğru işlerle yeniden kuruluyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " doğru ayarlanmış terazide ihtiyacı kadar bulguru aldı. Eve döndüğünde annesi keseyi açıp sordu: “Pazarda neden bu kadar geç kaldın?” “Bulgur aldım, bir de akıl,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “İkisini de ölçerek aldım.” Annesi gülerek, “Akıl terazide tartılır mı hiç?” diye karşılık verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sepetini bıraktı. “Tartılmaz ama doğru ölçüyle iş yapmak akıllıca olur.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi pazar satıcı, tezgâhına yeni denetlenmiş bir "
        },
        {
          "t": "kelime",
          "yuva": "pb_terazi"
        },
        {
          "t": "metin",
          "v": " koymuştu. Yanına da küçük bir yazı asmıştı: Ölçüde doğruluk, alışverişte güven. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu yazıyı görünce başıyla selam verdi. Satıcı da ona teşekkür etti. Kasabada o gün belki büyük bir hazine bulunmamıştı; ama herkesin hakkını koruyan küçük bir adım atılmıştı. "
        },
        {
          "t": "isaret",
          "kod": "yildiz"
        }
      ]
    }
  ],
  "deger_sahneleri": {},
  "hareket_sahneleri": {},
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 2,
      "metin": "İlk terazinin ayarının bozuk olduğu nasıl ortaya çıktı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Satıcı kendisi itiraf etti"
        },
        {
          "id": "B",
          "metin": "Görevli dengeli zeminde standart ağırlıkla bir deneme yaptı"
        },
        {
          "id": "C",
          "metin": "Teraziyi çocuklar söküp inceledi"
        },
        {
          "id": "D",
          "metin": "Annesi pazara gelip kontrol etti"
        }
      ],
      "dogru": "B",
      "aciklama": "Pazar görevlisi önce zemini kontrol etti, sonra standart ağırlıkla deneme yaptı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Satıcı ‘Kasten yapmadım, ama yine de sorun var’ derken neyi kabul etmiş olur?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Müşterileri kandırmak istediğini"
        },
        {
          "id": "B",
          "metin": "Teraziyi hiç kullanmadığını"
        },
        {
          "id": "C",
          "metin": "Niyeti kötü olmasa da eksik tartmanın müşterilere zarar vermiş olabileceğini"
        },
        {
          "id": "D",
          "metin": "Pazarın kapatılması gerektiğini"
        }
      ],
      "dogru": "C",
      "aciklama": "Satıcı, bilerek yapmasa da eksik tartı olasılığının bir sorun olduğunu kabul etti."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 7,
      "metin": "‘Güven, söylenen güzel sözlerle değil, yapılan doğru işlerle yeniden kuruluyordu’ cümlesi ne anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Güzel söz söylemek yasaktır"
        },
        {
          "id": "B",
          "metin": "Hata yapıldığında özür ve düzeltme, güveni geri getiren asıl şeydir"
        },
        {
          "id": "C",
          "metin": "Satıcı yeni bir terazi almak zorundaydı"
        },
        {
          "id": "D",
          "metin": "Güven yalnızca zengin satıcılarda olur"
        }
      ],
      "dogru": "B",
      "aciklama": "Satıcı özür dilemiş, müşterilere duyuru yapmayı ve düzeltmeyi kabul etmişti; güven bu davranışlarla geri geliyordu."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "‘Denetim işlemi’ ifadesindeki denetim sözcüğü ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir şeyin doğru ve kurallara uygun olup olmadığını kontrol etme"
        },
        {
          "id": "B",
          "metin": "Pazarda ürün satma"
        },
        {
          "id": "C",
          "metin": "Bir hediyeyi paketleme"
        },
        {
          "id": "D",
          "metin": "Yüksek sesle tartışma"
        }
      ],
      "dogru": "A",
      "aciklama": "Görevli, terazinin doğru çalışıp çalışmadığını kontrol ediyordu."
    },
    {
      "id": "s5",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 4,
      "metin": "Keloğlan'ın pazarda araya girip ‘Önce sorunu anlayalım’ demesi neden iyi bir davranıştır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü satıcıdan intikam alır"
        },
        {
          "id": "B",
          "metin": "Çünkü sorun kendiliğinden kaybolur"
        },
        {
          "id": "C",
          "metin": "Çünkü bağırmak yerine sorunun çözülmesine ve doğrunun bulunmasına yardım eder"
        },
        {
          "id": "D",
          "metin": "Çünkü pazarda kimse konuşmaz"
        }
      ],
      "dogru": "C",
      "aciklama": "Keloğlan sert çıkışmak yerine sakin kalıp sorunu anlamaya çalıştı; böylece kimse küçük düşürülmedi."
    },
    {
      "id": "s6",
      "beceri": "cikarim",
      "dayanak_sayfa": 6,
      "metin": "Çocuk iki bulgur torbasının hangisinin ağır olduğuna neden bakarak karar veremedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Torbalar birbirinin aynısıydı"
        },
        {
          "id": "B",
          "metin": "Taneler iriyse torba kesin hafiftir"
        },
        {
          "id": "C",
          "metin": "Torbalar çok uzaktaydı"
        },
        {
          "id": "D",
          "metin": "Görünüş ağırlığı tek başına göstermez; tartmak gerekir"
        }
      ],
      "dogru": "D",
      "aciklama": "Tanelerin boyutu torbanın ağırlığını tek başına göstermiyordu; bu yüzden teraziye ihtiyaç vardı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-21"
  }
}$p15$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr032-keloglan-ve-akilli-terazi: %', v_r; end if;

  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr015-tohumun-kucuk-sirri' where fis_kodu = 'HR-015';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr018-deniz-fenerindeki-sinyal' where fis_kodu = 'HR-018';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr019-magaranin-uc-isareti' where fis_kodu = 'HR-019';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr021-kayip-sandigin-sifresi' where fis_kodu = 'HR-021';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr022-saat-kulesi-neden-durdu' where fis_kodu = 'HR-022';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr023-hoca-ve-gorunmeyen-misafir' where fis_kodu = 'HR-023';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr024-bulut-postacisinin-son-mektubu' where fis_kodu = 'HR-024';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr025-bremen-yolcularinin-yeni-sarkisi' where fis_kodu = 'HR-025';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr026-kelime-makinesinin-karisikligi' where fis_kodu = 'HR-026';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr027-karagozun-kayip-golgesi' where fis_kodu = 'HR-027';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr028-uc-renkli-takim' where fis_kodu = 'HR-028';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr029-minik-mucit-ve-gunes-firini' where fis_kodu = 'HR-029';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr030-ormanin-kaybolan-patikasi' where fis_kodu = 'HR-030';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr031-muzede-sessiz-alarm' where fis_kodu = 'HR-031';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr032-keloglan-ve-akilli-terazi' where fis_kodu = 'HR-032';
end
$pilot$;

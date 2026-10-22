-- =====================================================================
-- Okuma Dünyası — 4., 5. ve 6. sınıf (HR-033…HR-047): sözlükler, 15 fiş ve taslak paketler.
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
  "sozluk_surumu": 1,
  "girdiler": [
    {
      "id": "pc_ikram",
      "tur": "kelime",
      "yazim": "ikram",
      "anlam": "Konuğa yemek, içecek gibi bir şey sunma.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_gosterisli",
      "tur": "kelime",
      "yazim": "gösterişli",
      "anlam": "Dikkat çekecek kadar süslü ve pahalı görünen.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_itiraf",
      "tur": "kelime",
      "yazim": "itiraf",
      "anlam": "Yaptığı bir şeyi ya da düşündüğünü açıkça söyleme.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_ata_parlayan",
      "tur": "atasozu",
      "yazim": "Her parlayan altın değildir",
      "anlam": "Dışarıdan güzel ya da değerli görünen her şey gerçekten değerli olmayabilir.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_ipucu",
      "tur": "kelime",
      "yazim": "ipucu",
      "anlam": "Bir sorunu çözmeye yardım eden küçük bilgi.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_yontem",
      "tur": "kelime",
      "yazim": "yöntem",
      "anlam": "Bir işi yapmak için izlenen yol.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_danismanlik",
      "tur": "kelime",
      "yazim": "danışmanlık",
      "anlam": "Bir konuda bilgili birinin öneri vererek yol göstermesi.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_ata_emek",
      "tur": "atasozu",
      "yazim": "Emek olmadan yemek olmaz",
      "anlam": "Bir şeyin sonucunu görmek için önce çalışmak gerekir.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_gecikme",
      "tur": "kelime",
      "yazim": "gecikme",
      "anlam": "Bir şeyin beklenenden geç olması.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_uydu",
      "tur": "kelime",
      "yazim": "uydu",
      "anlam": "Dünya'nın çevresinde dönen ve haberleşme gibi işler için uzaya gönderilen araç.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_dogrulama",
      "tur": "kelime",
      "yazim": "doğrulama",
      "anlam": "Bir şeyin doğru olduğunu kontrol edip onaylama.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_ata_sabreden",
      "tur": "atasozu",
      "yazim": "Sabreden derviş muradına ermiş",
      "anlam": "Sabırla bekleyen kişi, istediğine sonunda ulaşır.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_cesaret",
      "tur": "kelime",
      "yazim": "cesaret",
      "anlam": "Korkulan bir durumda bile doğru olanı yapabilme gücü.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_destek",
      "tur": "kelime",
      "yazim": "destek",
      "anlam": "Birine yardım ederek ona güç verme.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_prova",
      "tur": "kelime",
      "yazim": "prova",
      "anlam": "Bir işi başkalarının karşısında yapmadan önce deneme.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_ata_el",
      "tur": "atasozu",
      "yazim": "Bir elin nesi var iki elin sesi var",
      "anlam": "İnsanlar işi birlikte yapınca daha güçlü ve başarılı olur.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_pas",
      "tur": "kelime",
      "yazim": "pas",
      "anlam": "Futbol gibi oyunlarda topu takım arkadaşına gönderme.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_taktik",
      "tur": "kelime",
      "yazim": "taktik",
      "anlam": "Bir oyunu ya da işi kazanmak için önceden yapılan plan.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_savunma",
      "tur": "kelime",
      "yazim": "savunma",
      "anlam": "Rakibin gol atmasını engellemeye çalışan oyuncular ya da bu çaba.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_ata_birlik",
      "tur": "atasozu",
      "yazim": "Birlikten kuvvet doğar",
      "anlam": "Birlikte çalışan insanlar tek başına olduklarından daha güçlü olur.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_nota",
      "tur": "kelime",
      "yazim": "nota",
      "anlam": "Müzikte bir sesi göstermek için kullanılan işaret ya da o ses.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_duraklama",
      "tur": "kelime",
      "yazim": "duraklama",
      "anlam": "Bir işin ya da sesin kısa bir süre durması.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_armagan",
      "tur": "kelime",
      "yazim": "armağan",
      "anlam": "Sevgi ya da saygı göstermek için birine verilen hediye.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_ata_acele",
      "tur": "atasozu",
      "yazim": "Acele işe şeytan karışır",
      "anlam": "Aceleyle yapılan işte hata yapma olasılığı artar.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_goc",
      "tur": "kelime",
      "yazim": "göç",
      "anlam": "Canlıların daha uygun yaşam koşulları için bir yerden başka bir yere gitmesi.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_efsanevi",
      "tur": "kelime",
      "yazim": "efsanevi",
      "anlam": "Efsanelerde anlatılan, gerçek olmayan ya da çok eski masallara ait olan.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_gozlem",
      "tur": "kelime",
      "yazim": "gözlem",
      "anlam": "Bir şeyi dikkatle bakarak inceleme.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_ata_sormak",
      "tur": "atasozu",
      "yazim": "Sormakla yol bulunur",
      "anlam": "Bilmediğin bir şeyi sorarsan çözümü bulabilirsin.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_yoresel",
      "tur": "kelime",
      "yazim": "yöresel",
      "anlam": "Yalnızca belli bir yöreye ait olan.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_miras",
      "tur": "kelime",
      "yazim": "miras",
      "anlam": "Geçmişten bugüne kalan değerli bilgi, eşya ya da gelenekler.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_durak",
      "tur": "kelime",
      "yazim": "durak",
      "anlam": "Bir aracın yolculuk sırasında durduğu yer.",
      "sinif_alt": 4,
      "sinif_ust": 4,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pc_ata_misafir",
      "tur": "atasozu",
      "yazim": "Misafir kısmetiyle gelir",
      "anlam": "Eve gelen konuk, kendi nasibiyle gelir; ağırlamak bereket getirir.",
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
      "ad": "pc_ikram",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_ikram"
        }
      ]
    },
    {
      "ad": "pc_gosterisli",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_gosterisli"
        }
      ]
    },
    {
      "ad": "pc_itiraf",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_itiraf"
        }
      ]
    },
    {
      "ad": "pc_ata_parlayan",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pc_ata_parlayan"
        }
      ]
    },
    {
      "ad": "pc_ipucu",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_ipucu"
        }
      ]
    },
    {
      "ad": "pc_yontem",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_yontem"
        }
      ]
    },
    {
      "ad": "pc_danismanlik",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_danismanlik"
        }
      ]
    },
    {
      "ad": "pc_ata_emek",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pc_ata_emek"
        }
      ]
    },
    {
      "ad": "pc_gecikme",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_gecikme"
        }
      ]
    },
    {
      "ad": "pc_uydu",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_uydu"
        }
      ]
    },
    {
      "ad": "pc_dogrulama",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_dogrulama"
        }
      ]
    },
    {
      "ad": "pc_ata_sabreden",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pc_ata_sabreden"
        }
      ]
    },
    {
      "ad": "pc_cesaret",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_cesaret"
        }
      ]
    },
    {
      "ad": "pc_destek",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_destek"
        }
      ]
    },
    {
      "ad": "pc_prova",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_prova"
        }
      ]
    },
    {
      "ad": "pc_ata_el",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pc_ata_el"
        }
      ]
    },
    {
      "ad": "pc_pas",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_pas"
        }
      ]
    },
    {
      "ad": "pc_taktik",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_taktik"
        }
      ]
    },
    {
      "ad": "pc_savunma",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_savunma"
        }
      ]
    },
    {
      "ad": "pc_ata_birlik",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pc_ata_birlik"
        }
      ]
    },
    {
      "ad": "pc_nota",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_nota"
        }
      ]
    },
    {
      "ad": "pc_duraklama",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_duraklama"
        }
      ]
    },
    {
      "ad": "pc_armagan",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_armagan"
        }
      ]
    },
    {
      "ad": "pc_ata_acele",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pc_ata_acele"
        }
      ]
    },
    {
      "ad": "pc_goc",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_goc"
        }
      ]
    },
    {
      "ad": "pc_efsanevi",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_efsanevi"
        }
      ]
    },
    {
      "ad": "pc_gozlem",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_gozlem"
        }
      ]
    },
    {
      "ad": "pc_ata_sormak",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pc_ata_sormak"
        }
      ]
    },
    {
      "ad": "pc_yoresel",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_yoresel"
        }
      ]
    },
    {
      "ad": "pc_miras",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_miras"
        }
      ]
    },
    {
      "ad": "pc_durak",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pc_durak"
        }
      ]
    },
    {
      "ad": "pc_ata_misafir",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pc_ata_misafir"
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
      "id": "pd_varsayim",
      "tur": "kelime",
      "yazim": "varsayım",
      "anlam": "Henüz kanıtlanmamış, doğru olabileceği düşünülen fikir.",
      "sinif_alt": 6,
      "sinif_ust": 6,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_lagun",
      "tur": "kelime",
      "yazim": "lagün",
      "anlam": "Denizden kum yığınlarıyla ayrılmış, sığ ve durgun su alanı.",
      "sinif_alt": 6,
      "sinif_ust": 6,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_olcek",
      "tur": "kelime",
      "yazim": "ölçek",
      "anlam": "Haritadaki uzunluğun gerçek arazide kaç uzunluğa karşılık geldiğini gösteren oran.",
      "sinif_alt": 6,
      "sinif_ust": 6,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_oyuk",
      "tur": "kelime",
      "yazim": "oyuk",
      "anlam": "Bir yüzeyin, özellikle kayanın içeri doğru çökük bölümü.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_kroki",
      "tur": "kelime",
      "yazim": "kroki",
      "anlam": "Bir yerin ayrıntılara girmeden, el ile çizilmiş basit planı.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_asinma",
      "tur": "kelime",
      "yazim": "aşınma",
      "anlam": "Kayaların rüzgâr ve suyun etkisiyle zamanla yavaş yavaş yıpranması.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_tahmin",
      "tur": "kelime",
      "yazim": "tahmin",
      "anlam": "Eldeki verilere dayanarak henüz olmamış bir durum hakkında yapılan değerlendirme.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_olasilik",
      "tur": "kelime",
      "yazim": "olasılık",
      "anlam": "Bir olayın olabilme ihtimali; olabilir ama kesin değildir.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_uyari",
      "tur": "kelime",
      "yazim": "uyarı",
      "anlam": "Dikkat edilmesi gereken bir durumu önceden bildiren haber.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_pusula",
      "tur": "kelime",
      "yazim": "pusula",
      "anlam": "İğnesi hep aynı yönü göstererek yön bulmaya yardım eden araç.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_kuzey",
      "tur": "kelime",
      "yazim": "kuzey",
      "anlam": "Pusulanın gösterdiği, dört ana yönden biri.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_rota",
      "tur": "kelime",
      "yazim": "rota",
      "anlam": "Bir yolculukta ya da yürüyüşte izlenecek yol.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_emanet",
      "tur": "kelime",
      "yazim": "emanet",
      "anlam": "Bir kişiye geçici olarak bırakılan ve korunması beklenen şey.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_bagis",
      "tur": "kelime",
      "yazim": "bağış",
      "anlam": "Karşılık beklemeden verilen kitap, eşya ya da para.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_arsiv",
      "tur": "kelime",
      "yazim": "arşiv",
      "anlam": "Eski belge ve kayıtların düzenli olarak saklandığı yer ya da bu belgelerin tamamı.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_kanit",
      "tur": "kelime",
      "yazim": "kanıt",
      "anlam": "Bir iddianın doğru ya da yanlış olduğunu gösteren belge veya bilgi.",
      "sinif_alt": 6,
      "sinif_ust": 6,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_damga",
      "tur": "kelime",
      "yazim": "damga",
      "anlam": "Bir zarfın ya da belgenin üstüne basılan, yer ve tarih gibi bilgileri gösteren işaret.",
      "sinif_alt": 6,
      "sinif_ust": 6,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_tarihleme",
      "tur": "kelime",
      "yazim": "tarihleme",
      "anlam": "Bir belgenin ya da nesnenin ne zaman yapıldığını belirlemeye çalışma.",
      "sinif_alt": 6,
      "sinif_ust": 6,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_oruntu",
      "tur": "kelime",
      "yazim": "örüntü",
      "anlam": "Bir kuralı olan, kendini düzenli biçimde tekrar eden dizi ya da düzen.",
      "sinif_alt": 6,
      "sinif_ust": 6,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_baglam",
      "tur": "kelime",
      "yazim": "bağlam",
      "anlam": "Bir sözün ya da sayının anlamını belirleyen çevresindeki bilgiler ve durum.",
      "sinif_alt": 6,
      "sinif_ust": 6,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_ata_acele",
      "tur": "atasozu",
      "yazim": "Acele işe şeytan karışır",
      "anlam": "Bir işi çok hızlı yapmaya çalışınca hata yapılır; sakin ve düşünerek davranmak gerekir.",
      "sinif_alt": 6,
      "sinif_ust": 6,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_ata_damlaya",
      "tur": "atasozu",
      "yazim": "Damlaya damlaya göl olur",
      "anlam": "Küçük şeyler birikerek zamanla büyük bir sonuç oluşturur.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_ata_sormakla",
      "tur": "atasozu",
      "yazim": "Sormakla yol bulunur",
      "anlam": "Bilmediğimiz bir şeyi doğru kişilere sorarak öğrenebiliriz.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_ata_birlikten",
      "tur": "atasozu",
      "yazim": "Birlikten kuvvet doğar",
      "anlam": "İnsanlar bir araya gelip birlikte çalışınca daha güçlü olur.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_ata_iyilik",
      "tur": "atasozu",
      "yazim": "İyilik eden iyilik bulur",
      "anlam": "Başkalarına iyilik yapan kişi, zamanı gelince kendi de iyilikle karşılaşır.",
      "sinif_alt": 5,
      "sinif_ust": 5,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    },
    {
      "id": "pd_ata_sabreden",
      "tur": "atasozu",
      "yazim": "Sabreden derviş muradına ermiş",
      "anlam": "Sabırla bekleyen ve çabalamayı bırakmayan kişi sonunda istediğine ulaşır.",
      "sinif_alt": 6,
      "sinif_ust": 6,
      "kaynak_turu": "editor_onerisi",
      "kazanim_kodu": null,
      "durum": "taslak"
    }
  ],
  "kavramlar": [],
  "yuvalar": [
    {
      "ad": "pd_varsayim",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_varsayim"
        }
      ]
    },
    {
      "ad": "pd_lagun",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_lagun"
        }
      ]
    },
    {
      "ad": "pd_olcek",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_olcek"
        }
      ]
    },
    {
      "ad": "pd_oyuk",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_oyuk"
        }
      ]
    },
    {
      "ad": "pd_kroki",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_kroki"
        }
      ]
    },
    {
      "ad": "pd_asinma",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_asinma"
        }
      ]
    },
    {
      "ad": "pd_tahmin",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_tahmin"
        }
      ]
    },
    {
      "ad": "pd_olasilik",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_olasilik"
        }
      ]
    },
    {
      "ad": "pd_uyari",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_uyari"
        }
      ]
    },
    {
      "ad": "pd_pusula",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_pusula"
        }
      ]
    },
    {
      "ad": "pd_kuzey",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_kuzey"
        }
      ]
    },
    {
      "ad": "pd_rota",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_rota"
        }
      ]
    },
    {
      "ad": "pd_emanet",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_emanet"
        }
      ]
    },
    {
      "ad": "pd_bagis",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_bagis"
        }
      ]
    },
    {
      "ad": "pd_arsiv",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_arsiv"
        }
      ]
    },
    {
      "ad": "pd_kanit",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_kanit"
        }
      ]
    },
    {
      "ad": "pd_damga",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_damga"
        }
      ]
    },
    {
      "ad": "pd_tarihleme",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_tarihleme"
        }
      ]
    },
    {
      "ad": "pd_oruntu",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_oruntu"
        }
      ]
    },
    {
      "ad": "pd_baglam",
      "tur": "kelime",
      "adaylar": [
        {
          "girdi": "pd_baglam"
        }
      ]
    },
    {
      "ad": "pd_ata_acele",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pd_ata_acele"
        }
      ]
    },
    {
      "ad": "pd_ata_damlaya",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pd_ata_damlaya"
        }
      ]
    },
    {
      "ad": "pd_ata_sormakla",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pd_ata_sormakla"
        }
      ]
    },
    {
      "ad": "pd_ata_birlikten",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pd_ata_birlikten"
        }
      ]
    },
    {
      "ad": "pd_ata_iyilik",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pd_ata_iyilik"
        }
      ]
    },
    {
      "ad": "pd_ata_sabreden",
      "tur": "atasozu",
      "adaylar": [
        {
          "girdi": "pd_ata_sabreden"
        }
      ]
    }
  ]
}$z02$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'sozluk 2: %', v_r; end if;

  v_r := public.okuma_fis_ice_aktar($fis$[
    {
        "fis_kodu":  "HR-033",
        "baslik":  "Ye Kürküm Ye, Peki Neden?",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Tarih/Kültür",
        "kurgu_cekirdegi":  "Hoca davette giysisine göre değişen davranışları gösterir; çocuklar görünüşe göre yargılamayı tartışır.",
        "soz_varligi":  "görünüş, değer; mecaz",
        "bilgi_beceri_deger":  "Önyargı ve saygı",
        "ikon_onerileri":  [
                               "kürk",
                               "sofra",
                               "ayna"
                           ],
        "telif_sinifi":  "A",
        "kaynak_sinifi":  "Nasreddin Hoca fıkra geleneği",
        "telif_notu":  "Geleneksel/anonim anlatı çekirdeğinden yeniden kurgu"
    },
    {
        "fis_kodu":  "HR-034",
        "baslik":  "2040\u0027ın Konuşan Okul Çantası",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Mizah",
        "kurgu_cekirdegi":  "Akıllı çanta her şeyi öğrencinin yerine yapar; çocuk kontrolü geri alarak teknolojiyi dengeli kullanmayı öğrenir.",
        "soz_varligi":  "yardım-bağımlılık; ana fikir",
        "bilgi_beceri_deger":  "Dijital denge; öz yönetim",
        "ikon_onerileri":  [
                               "çanta",
                               "ekran",
                               "düğme"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-035",
        "baslik":  "Ay\u0027a Giden İlk Posta",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Bilim kurgu",
        "kurgu_cekirdegi":  "Ay üssüne ulaşması gereken mektup veri kesintisine takılır; iki çocuk iletişim için farklı yöntemler dener.",
        "soz_varligi":  "iletişim, kod; problem çözme",
        "bilgi_beceri_deger":  "Uzay ve iletişim",
        "ikon_onerileri":  [
                               "ay",
                               "roket",
                               "zarf"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-036",
        "baslik":  "Yedi Renkli Köprünün Koruyucusu",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Arkadaşlık",
        "kurgu_cekirdegi":  "Her renk bir duyguyu temsil eder; kahraman korkusunu adlandırınca köprünün eksik rengini geri getirir.",
        "soz_varligi":  "duygular; mecazlı renk anlatımı",
        "bilgi_beceri_deger":  "Öz farkındalık; cesaret",
        "ikon_onerileri":  [
                               "gökkuşağı",
                               "köprü",
                               "kalp"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-037",
        "baslik":  "Son Pasın Hikâyesi",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Spor",
        "kurgu_cekirdegi":  "Maçın son saniyesinde gol fırsatı bulan çocuk takım arkadaşını görür; doğru pasla ortak başarı kazanılır.",
        "soz_varligi":  "pas, takım; deyim: gözden kaçırmak",
        "bilgi_beceri_deger":  "Adalet ve takım ruhu",
        "ikon_onerileri":  [
                               "top",
                               "düdük",
                               "kale"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-038",
        "baslik":  "Müzik Kutusunun Şifresi",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Gizem",
        "kurgu_cekirdegi":  "Büyükannenin eski müzik kutusu yalnız belirli notalarda açılır; çocuklar ritmi çözerek içindeki aile hatırasını bulur.",
        "soz_varligi":  "ritim, tekrar; çıkarım",
        "bilgi_beceri_deger":  "Müzik, aile belleği",
        "ikon_onerileri":  [
                               "müzik kutusu",
                               "nota",
                               "anahtar"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-039",
        "baslik":  "Anka\u0027nın Kaybolan Tüyü",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Fantastik",
        "kurgu_cekirdegi":  "Anka kuşunun parıltılı tüyünü arayan çocuk, doğayı dinleyince tüyün göçmen kuşlara yol gösterdiğini anlar.",
        "soz_varligi":  "deyim: kanat germek; mecaz",
        "bilgi_beceri_deger":  "Göç, umut ve koruma",
        "ikon_onerileri":  [
                               "anka",
                               "tüy",
                               "göç yolu"
                           ],
        "telif_sinifi":  "A",
        "kaynak_sinifi":  "Anka kuşu anlatı motifi",
        "telif_notu":  "Geleneksel/anonim anlatı çekirdeğinden yeniden kurgu"
    },
    {
        "fis_kodu":  "HR-040",
        "baslik":  "Trenin Penceresindeki Türkiye",
        "sinif":  4,
        "sinif_bandi":  "2-4",
        "tur":  "Gezi/Kültür",
        "kurgu_cekirdegi":  "Tren yolculuğunda üç durakta üç farklı sofra ve gelenek tanınır; çocuk farklılıkların ortak hikâyesini deftere yazar.",
        "soz_varligi":  "yer adları, benzer-farklı",
        "bilgi_beceri_deger":  "Kültürel çeşitlilik, harita",
        "ikon_onerileri":  [
                               "tren",
                               "lokomotif",
                               "harita"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-041",
        "baslik":  "Yedi Adımda Kayıp Ada",
        "sinif":  6,
        "sinif_bandi":  "5-6",
        "tur":  "Macera",
        "kurgu_cekirdegi":  "Okul kampında bulunan eski harita adaya değil kıyıdaki koruma alanına çıkar; ekip gizemi çözüp bölgeyi korur.",
        "soz_varligi":  "ipucu, yön; deyim: iz sürmek",
        "bilgi_beceri_deger":  "Harita okuryazarlığı, çevre sorumluluğu",
        "ikon_onerileri":  [
                               "pusula",
                               "kıyı",
                               "yedi işaret"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-042",
        "baslik":  "Kapadokya\u0027nın Gizli Geçidi",
        "sinif":  5,
        "sinif_bandi":  "5-6",
        "tur":  "Macera",
        "kurgu_cekirdegi":  "Vadideki doğal kaya oluşumları çocukları şaşırtır; rehberle güvenli gezi yaparken eski bir su izini belgelerler.",
        "soz_varligi":  "yer altı, oyuk; neden-sonuç",
        "bilgi_beceri_deger":  "Jeolojik oluşumlar, kültürel miras",
        "ikon_onerileri":  [
                               "peribacası",
                               "fener",
                               "fotoğraf"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-043",
        "baslik":  "Kuledeki Son Işık",
        "sinif":  5,
        "sinif_bandi":  "5-6",
        "tur":  "Macera",
        "kurgu_cekirdegi":  "Terk edilmiş sanılan gözlem kulesinden gelen işaretlerin meteoroloji uyarısı olduğu anlaşılır; öğrenciler doğru kişilere haber verir.",
        "soz_varligi":  "uyarı, tahmin; koşul cümleleri",
        "bilgi_beceri_deger":  "Hava olayları; güvenlik",
        "ikon_onerileri":  [
                               "kule",
                               "bulut",
                               "telsiz"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-044",
        "baslik":  "Buz Gölünün Haritası",
        "sinif":  5,
        "sinif_bandi":  "5-6",
        "tur":  "Spor",
        "kurgu_cekirdegi":  "Dağ yürüyüşünde ekip göl kıyısında yolunu şaşırır; önceden belirlenen güvenlik planını izleyerek geri döner.",
        "soz_varligi":  "risk, güvenlik; olay örgüsü",
        "bilgi_beceri_deger":  "Hava koşulları; planlama",
        "ikon_onerileri":  [
                               "buz",
                               "harita",
                               "çadır"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-045",
        "baslik":  "Kütüphanenin On Üçüncü Rafı",
        "sinif":  5,
        "sinif_bandi":  "5-6",
        "tur":  "Gizem",
        "kurgu_cekirdegi":  "Raf numaraları arasında bir boşluk bulan Nil, katalog kayıtlarını karşılaştırarak unutulmuş bir bağış defteri keşfeder.",
        "soz_varligi":  "ipucu, kayıt, kanıt",
        "bilgi_beceri_deger":  "Kaynak sorgulama; dürüstlük",
        "ikon_onerileri":  [
                               "raf",
                               "katalog",
                               "büyüteç"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-046",
        "baslik":  "Bilinmeyen Posta Pulu",
        "sinif":  6,
        "sinif_bandi":  "5-6",
        "tur":  "Gizem",
        "kurgu_cekirdegi":  "Eski bir zarftaki pul, yanlış tarihlenmiş bir okul fotoğrafının izini taşır; çocuklar farklı belgeleri karşılaştırır.",
        "soz_varligi":  "kanıt-varsayım; karşılaştırma",
        "bilgi_beceri_deger":  "Tarihleme, belge okuryazarlığı",
        "ikon_onerileri":  [
                               "pul",
                               "tarih",
                               "zarf"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-047",
        "baslik":  "Kırmızı Defterin Şifresi",
        "sinif":  6,
        "sinif_bandi":  "5-6",
        "tur":  "Gizem",
        "kurgu_cekirdegi":  "Defterdeki sayılar bir oyun puanı sanılır; diziyi inceleyen arkadaşlar bunun okul kütüphanesi kitap kodu olduğunu bulur.",
        "soz_varligi":  "örüüntü, şifre; bağlam",
        "bilgi_beceri_deger":  "Matematiksel örüntü",
        "ikon_onerileri":  [
                               "defter",
                               "rakam",
                               "kilit"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    }
]$fis$::jsonb, false);
  if (v_r ->> 'ok') is distinct from 'true' then raise exception 'fis: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p01${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr033-ye-kurkum-ye-peki-neden",
    "baslik": "Ye Kürküm Ye, Peki Neden?",
    "tur": "tarih_kultur",
    "konu": "gorunus_ve_saygi",
    "sinif_alt": 4,
    "sinif_ust": 4,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D14",
      "D1"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kultur_miras",
        "mizah"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D14",
        "yardimci_deger": "D1"
      },
      "ogrenme_hedefleri": [
        {
          "id": "ikram_hr033",
          "tur": "lexeme",
          "etiket": "ikram",
          "yuva": "pc_ikram",
          "islev": "first_hint"
        },
        {
          "id": "gosterisli_hr033",
          "tur": "lexeme",
          "etiket": "gösterişli",
          "yuva": "pc_gosterisli",
          "islev": "application"
        },
        {
          "id": "itiraf_hr033",
          "tur": "lexeme",
          "etiket": "itiraf",
          "yuva": "pc_itiraf",
          "islev": "application"
        },
        {
          "id": "kavram_hr033",
          "tur": "concept",
          "etiket": "Görünüş ile değer; önyargı ve saygı",
          "islev": "application"
        },
        {
          "id": "atasoz_hr033",
          "tur": "proverb",
          "etiket": "Her parlayan altın değildir",
          "yuva": "pc_ata_parlayan",
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
        "kelime_sayisi": 475,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 8,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 1
      }
    },
    "tanitim": "Hoca eski cübbesiyle kapıda bekletildi. Kürkünü giyince herkes koştu. Çorbayı kim içmeliydi?",
    "durum": "taslak",
    "fis_kodu": "HR-033"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kasabanın meydanında o sabah her zamankinden büyük bir telaş vardı. Değirmenci Hasan, yeni değirmeninin açılışı için herkesi yemeğe çağırmıştı. Kapıya rengârenk fenerler asılmış, avluda uzun bir sofra kurulmuştu. Nasreddin Hoca, pazardan dönerken daveti hatırladı. Üzerinde günlük, eski cübbesi vardı. Eve uğramadan avluya girdi. Masaların yanından geçerken kimse ona yer göstermedi. Bir görevli, önündeki tabakları toplamakla meşguldü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hoca, \"Kolay gelsin evladım, boş bir yer var mı?\" diye sordu. Görevli başını kaldırmadan, \"Biraz bekleyin,\" dedi. Avlunun öbür ucunda, yeni ve "
        },
        {
          "t": "kelime",
          "yuva": "pc_gosterisli"
        },
        {
          "t": "metin",
          "v": " giysili bir misafiri iki kişi kapıya kadar karşılamıştı. Hoca olanları izledi. Hasan'ın onu fark etmemiş olabileceğini düşünerek hemen alınmadı. Yine de insanların birbirine giysisine göre davranması içine sinmedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Avludan ayrılırken yolda eski ayakkabılarıyla koşturan bir çocuk gördü. Çocuğun elinde, değirmenin açılışında şarkı söyleyecek topluluğun notaları vardı. Sayfalar rüzgârda uçuşunca Hoca eğilip yardımcı oldu. Çocuk, \"Beni kimse fark etmez sanmıştım,\" dedi. Hoca gülümsedi: \"İnsan bazen dikkat edilmediğini hisseder. Ama yardım etmek için kimsenin bizi tanıması gerekmez.\" Bu küçük karşılaşma, Hoca'nın aklındaki soruyu daha da büyüttü: Bir davette insanları görünür kılan şey gerçekten neydi?"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sessizce evine gitti. Dolabından işlemeli, temiz kürkünü aldı ve yeniden davete döndü. Bu kez kapıdaki görevli doğruldu. \"Hoş geldiniz efendim! Şöyle buyurun. En güzel yer sizin.\" Hoca, önüne getirilen çorbanın kaşığını kaldırmadı. Kürkünün kolunu kâseye doğru uzatıp, \"Ye kürküm ye!\" dedi. Yan masadaki çocuklardan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülmeye başladı. Fakat ardından kaşlarını çattı. \"Hocam, kürk çorba içebilir mi?\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "\"İçemez elbette. Peki sizce neden çorba önce bana değil de kürküme "
        },
        {
          "t": "kelime",
          "yuva": "pc_ikram"
        },
        {
          "t": "metin",
          "v": " edildi?\" "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " arkadaşı Efe cevap verdi: \"Çünkü kürkü görünce sizi önemli sandılar.\" \"Benim değerim, eve gidip kürk giyince mi arttı?\" diye sordu Hoca. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce cevap vermekte zorlandı. Sabah pazarda taşıdığı sepet ağır olduğu için onu evine kadar götüren komşuyu hatırladı. Komşunun giysileri de eskiydi ama içten davranışı gün boyu "
        },
        {
          "t": "kahraman",
          "hal": "belirtme"
        },
        {
          "t": "metin",
          "v": " mutlu etmişti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "\"Biri bana yardım ettiğinde üstündeki giysiyi hiç düşünmüyorum,\" dedi. Efe ise geçen hafta yeni ayakkabıları olduğu için arkadaşının eskileriyle alay ettiğini anımsadı. O an yüzü kızardı. \"Ben de bazen dış görünüşe bakıyorum,\" diye "
        },
        {
          "t": "kelime",
          "yuva": "pc_itiraf"
        },
        {
          "t": "metin",
          "v": " etti. Hoca, \"Farkına varmak, değiştirmek için "
        },
        {
          "t": "vurgu",
          "v": "ilk adımdır"
        },
        {
          "t": "metin",
          "v": ",\" dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar ve "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir süre düşündü. Hasan da konuşmaları duyup yanlarına geldi. Hocanın sabahki gelişini öğrenince görevliyi çağırdı. Onu herkesin önünde azarlamadı; birlikte daha iyi bir karşılama düzeni kurabileceklerini söyledi. Çocuklar da kapıda sırayla konukları karşılamayı önerdi. Öğleden sonra küçük bir misafir geldi. Üzerinde yamalı bir yelek, elinde çiçek vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hemen koştu, ona sandalye çekti; "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de bir tabak getirdi. Çocuk, çiçeği masanın ortasına koyarken gülümsedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hoca fısıldadı: \"İşte şimdi soframız gerçekten zenginleşti.\" Dönüş yolunda Efe, \"Bugün bir deyimi de öğrendim,\" dedi. \"Dış görünüşe aldanmak, insanı tanımadan karar vermekmiş.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını salladı. \"Birini tanımak için ne giydiğine değil, nasıl davrandığına bakmalı.\" Efe gülümsedi: \""
        },
        {
          "t": "atasozu",
          "yuva": "pc_ata_parlayan"
        },
        {
          "t": "metin",
          "v": "\" Hoca, çocukların elindeki çiçeğe baktı. \"Üstelik bazen en güzel hediyeyi en gösterişsiz misafir getirir,\" diye ekledi. Artık avlu yalnızca yemek kokusuyla değil, herkesin eşit karşılandığı bir neşeyle doluydu. "
        },
        {
          "t": "isaret",
          "kod": "kalp"
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
      "metin": "Hoca davete ilk geldiğinde görevli ona ne dedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "En güzel yeri gösterdi"
        },
        {
          "id": "B",
          "metin": "Başını kaldırmadan \"Biraz bekleyin\" dedi"
        },
        {
          "id": "C",
          "metin": "Hemen önüne çorba getirdi"
        },
        {
          "id": "D",
          "metin": "Davetin bittiğini söyledi"
        }
      ],
      "dogru": "B",
      "aciklama": "Görevli tabakları toplamakla meşguldü ve Hoca'ya başını kaldırmadan \"Biraz bekleyin\" dedi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Hoca çorbayı neden kürkünün koluna doğru uzattı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Gerçekten acıktığı için"
        },
        {
          "id": "B",
          "metin": "Kürkünü ıslatmak istediği için"
        },
        {
          "id": "C",
          "metin": "Çorbayı beğenmediği için"
        },
        {
          "id": "D",
          "metin": "Gösterilen saygının kendisine değil, giysisine olduğunu göstermek için"
        }
      ],
      "dogru": "D",
      "aciklama": "Hoca eski cübbesiyle kapıda bekletilmiş, kürkle ise baş köşeye oturtulmuştu; bunu çocuklara göstermek istedi."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 5,
      "metin": "Metinde geçen ikram sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Birine kızma"
        },
        {
          "id": "B",
          "metin": "Bir şeyi satın alma"
        },
        {
          "id": "C",
          "metin": "Konuğa yemek ya da içecek sunma"
        },
        {
          "id": "D",
          "metin": "Bir yerden uzaklaşma"
        }
      ],
      "dogru": "C",
      "aciklama": "Çorba önce kürke ikram edilmişti; yani konuğa sunulmuştu."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Efe'nin \"Ben de bazen dış görünüşe bakıyorum\" demesi neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hocayı hiç tanımadığını"
        },
        {
          "id": "B",
          "metin": "Yaptığı yanlışı fark edip açıkça kabul ettiğini"
        },
        {
          "id": "C",
          "metin": "Arkadaşıyla yarıştığını"
        },
        {
          "id": "D",
          "metin": "Yeni ayakkabılarıyla övünmek istediğini"
        }
      ],
      "dogru": "B",
      "aciklama": "Efe arkadaşının eski ayakkabılarıyla alay ettiğini anımsadı, yüzü kızardı ve hatasını itiraf etti."
    },
    {
      "id": "s5",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 7,
      "metin": "Hasan, görevliyi herkesin önünde azarlamadı. Bu davranış neden yerindedir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hatayı birlikte çözmeyi seçmek, hem görevliye saygıyı korur hem de düzeni düzeltir"
        },
        {
          "id": "B",
          "metin": "Görevlinin hiç hata yapmadığını gösterir"
        },
        {
          "id": "C",
          "metin": "Böylece kimse hatadan haberdar olmaz"
        },
        {
          "id": "D",
          "metin": "Hasan'ın yemeğe gelen konuklarla ilgilenmediğini gösterir"
        }
      ],
      "dogru": "A",
      "aciklama": "Hasan görevliyi azarlamak yerine daha iyi bir karşılama düzenini birlikte kurmayı önerdi."
    },
    {
      "id": "s6",
      "beceri": "hatirlama",
      "dayanak_sayfa": 7,
      "metin": "Yamalı yelekli küçük misafir masanın ortasına ne koydu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir tabak çorba"
        },
        {
          "id": "B",
          "metin": "Şarkı notaları"
        },
        {
          "id": "C",
          "metin": "Bir kürk"
        },
        {
          "id": "D",
          "metin": "Bir çiçek"
        }
      ],
      "dogru": "D",
      "aciklama": "Küçük misafir elindeki çiçeği masanın ortasına koydu."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p01$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr033-ye-kurkum-ye-peki-neden: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p02${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr034-2040-konusan-okul-cantasi",
    "baslik": "2040'ın Konuşan Okul Çantası",
    "tur": "mizah",
    "konu": "akilli_canta",
    "sinif_alt": 4,
    "sinif_ust": 4,
    "okuma_bandi": 3,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D16",
      "D3"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "bilim_teknoloji",
        "okul",
        "sabir_emek"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D16",
        "yardimci_deger": "D3"
      },
      "ogrenme_hedefleri": [
        {
          "id": "ipucu_hr034",
          "tur": "lexeme",
          "etiket": "ipucu",
          "yuva": "pc_ipucu",
          "islev": "first_hint"
        },
        {
          "id": "yontem_hr034",
          "tur": "lexeme",
          "etiket": "yöntem",
          "yuva": "pc_yontem",
          "islev": "application"
        },
        {
          "id": "danismanlik_hr034",
          "tur": "lexeme",
          "etiket": "danışmanlık",
          "yuva": "pc_danismanlik",
          "islev": "application"
        },
        {
          "id": "kavram_hr034",
          "tur": "concept",
          "etiket": "Dijital denge ve öz yönetim",
          "islev": "application"
        },
        {
          "id": "atasoz_hr034",
          "tur": "proverb",
          "etiket": "Emek olmadan yemek olmaz",
          "yuva": "pc_ata_emek",
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
        "kelime_sayisi": 471,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 9,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 4,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Çanta ödevi yapmış, kahvaltıyı hazırlamış, hatta dişleri fırçalamayı önermiş. Peki çocuk ne yapacak?",
    "durum": "taslak",
    "fis_kodu": "HR-034"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "2040 yılının pazartesi sabahı "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " okul çantası aniden konuştu: \"Günaydın! Çorapların eşleşti. Kahvaltın hazır. Matematik ödevini de yaptım!\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yorganın altından başını çıkardı. \"Ödevi mi yaptın? Ben daha soruları görmedim!\" \"Ben akıllı çantayım,\" diye cevap verdi çanta. \"İstersen dişlerini de senin yerine fırçalamayı deneyebilirim.\""
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
          "v": " güldü. Fakat okula gidince işler karıştı. Öğretmeni problem çözmesini istediğinde çanta hemen masasından seslendi: \"Cevap kırk sekiz! Açıklaması için bir tuşa basınız!\" Sınıf gülüşmeye başladı. Öğretmen, \""
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", cevabı sen nasıl buldun?\" diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " cevap veremedi. Çünkü işlemi hiç denememişti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Teneffüste arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ona bir kâğıt uzattı. Üzerinde iki farklı yol gösteren bir matematik problemi vardı. \"Çantan çok hızlı,\" dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", \"ama onun ne yaptığını anlamıyorsan hızının sana ne yararı var?\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " düşündü. Akşam çantanın ayarlarını açtı. Ekranda üç seçenek vardı: *Benim yerime yap*, *Birlikte yap*, *Yalnızca hatırlat*."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "\"Birlikte yap,\" dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Çanta şaşırmış gibi küçük bir ışık yaktı. \"Emin misin? Tek başıma daha kısa sürüyor.\" \"Kısa sürmesi her zaman daha iyi olduğu anlamına gelmez.\" Sabah okula gelirken akıllı çanta, yağmur ihtimali olduğunu hatırlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " şemsiyesini almayı unutmadı. Böylece çantanın gerçekten yararlı olduğu bir iş de ortaya çıktı. "
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
          "v": "Sınıfa girince "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " "
        },
        {
          "t": "yoldas",
          "hal": "yonelme",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", \"Benim yerime düşünmesini istemiyorum ama dikkat etmem gereken şeyleri hatırlatabilir,\" dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de kendi küçük ajandasını gösterdi: \"Ben de bunları deftere yazıyorum. Hangi araçla yaparsan yap, önemli olan kararın sende kalması.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu sözleri aklında tuttu. Ertesi gün çanta matematik problemini okumaya başladı: \"Bir bahçede dört sıra ağaç var...\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onu durdurdu. \"Önce ben çözeceğim. Takılırsam "
        },
        {
          "t": "kelime",
          "yuva": "pc_ipucu"
        },
        {
          "t": "metin",
          "v": " ver.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çanta sessiz kaldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dört sırayı çizdi, her sıraya altı ağaç koydu. Saydı, sonra çarpma işlemini yazdı. \"Yirmi dört!\" diye bağırdı. \"Doğru,\" dedi çanta. \"Aferin... Pardon, tebrik ederim.\" "
        },
        {
          "t": "isaret",
          "kod": "yildiz"
        },
        {
          "t": "metin",
          "v": " O gün sınıfta teknoloji sergisi vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", çantasına yeni bir görev verdi: kaybolan defterlerin hangi rafta olduğunu hatırlatmak. Çanta herkese yardım etti, fakat kimsenin yerine ödev yapmadı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sergide başka bir çocuk, çantanın her soruya doğru yanıt verdiğini görünce hemen aynısından istemişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ona iki farklı kâğıt gösterdi. Birinde çantanın hazırladığı kusursuz cevaplar, diğerinde kendi silgileriyle düzelttiği işlemler vardı. \"İlkine bakınca hiçbir şey hatırlamıyorum,\" dedi. \"İkincisini yaparken iki kez yanıldım. Ama nerede yanıldığımı gördüğüm için artık bir "
        },
        {
          "t": "kelime",
          "yuva": "pc_yontem"
        },
        {
          "t": "metin",
          "v": " biliyorum.\" Arkadaşı, \"Demek hata yapmak bazen işe yarıyor,\" deyince öğretmen başını sallayıp \""
        },
        {
          "t": "atasozu",
          "yuva": "pc_ata_emek"
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
          "t": "metin",
          "v": "Gösteri bitince öğretmeni "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": ", \"Bugün çantana sen mi yardım ettin, çantan mı sana?\" diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülerek cevap verdi: \"İkimiz de birbirimize. O hatırlattı, ben düşündüm.\" Tam çıkacaklardı ki çanta yeniden konuştu: \"Akşam yemeğinde üç brokoli öneriyorum.\" \"Ona ben karar vereceğim!\" dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Çanta bir süre sustu. Sonra ciddi bir sesle ekledi: \"Anlaşıldı. Brokoli "
        },
        {
          "t": "kelime",
          "yuva": "pc_danismanlik"
        },
        {
          "t": "metin",
          "v": " hizmetim şimdilik kapatıldı.\""
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
          "v": " gülerken çantanın üstüne küçük bir etiket yapıştırdı: *Önce kendim denerim*. Ertesi sabah çanta yalnızca \"Ödev çantanda mı?\" diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterini gösterdi. \"Bu soruyu sorman çok iyi,\" dedi. \"Cevabı kendim verebildiğim sürece yardımını seviyorum.\""
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
      "metin": "Öğretmen problem çözmelerini isteyince akıllı çanta ne yaptı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sessiz kaldı"
        },
        {
          "id": "B",
          "metin": "Çocuğa ipucu verdi"
        },
        {
          "id": "C",
          "metin": "Masasından \"Cevap kırk sekiz!\" diye seslendi"
        },
        {
          "id": "D",
          "metin": "Öğretmenin sorusunu tahtaya yazdı"
        }
      ],
      "dogru": "C",
      "aciklama": "Çanta hemen masasından seslenip cevabı söyledi ve sınıf gülüşmeye başladı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Çocuk öğretmenin sorusuna neden cevap veremedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sınıfta çok gürültü olduğu için"
        },
        {
          "id": "B",
          "metin": "Ödevi çantaya bıraktığı için işlemi kendisi hiç denememişti"
        },
        {
          "id": "C",
          "metin": "Soruyu duymadığı için"
        },
        {
          "id": "D",
          "metin": "Matematiği sevmediği için"
        }
      ],
      "dogru": "B",
      "aciklama": "Metinde çocuğun işlemi hiç denemediği yazıyor; çünkü ödevi çanta yapmıştı."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 5,
      "metin": "Metinde geçen ipucu sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sorunun tam çözümü"
        },
        {
          "id": "B",
          "metin": "Ödevin teslim günü"
        },
        {
          "id": "C",
          "metin": "Bir sınıf eşyası"
        },
        {
          "id": "D",
          "metin": "Bir sorunu çözmeye yardım eden küçük bilgi"
        }
      ],
      "dogru": "D",
      "aciklama": "Çocuk çözümü değil, takılırsa yardım edecek küçük bir bilgi istedi."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 7,
      "metin": "Çocuk iki kâğıdı göstererek arkadaşına neyi anlatmak istedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hatalarını görerek kendi çözdüğü işin daha kalıcı öğrenme sağladığını"
        },
        {
          "id": "B",
          "metin": "Çantanın cevaplarının hep yanlış olduğunu"
        },
        {
          "id": "C",
          "metin": "Silgi kullanmanın yasak olduğunu"
        },
        {
          "id": "D",
          "metin": "Kusursuz cevapların ödev için yeterli olduğunu"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuk kusursuz cevaplardan hiçbir şey hatırlamadığını, kendi hatalarından ise yöntemi öğrendiğini söyledi."
    },
    {
      "id": "s5",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 3,
      "metin": "Çocuğun ayarlarda \"Birlikte yap\" seçeneğini seçmesi neden yerinde bir karardır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü iş daha kısa sürer"
        },
        {
          "id": "B",
          "metin": "Çünkü düşünme ve karar verme işi kendisinde kalır, çanta da yardımcı olur"
        },
        {
          "id": "C",
          "metin": "Çünkü çanta artık hiç konuşmaz"
        },
        {
          "id": "D",
          "metin": "Çünkü ödevi çanta yapar"
        }
      ],
      "dogru": "B",
      "aciklama": "\"Birlikte yap\" seçeneğinde çocuk öğrenmeye devam eder, çanta da yalnızca destek verir."
    },
    {
      "id": "s6",
      "beceri": "hatirlama",
      "dayanak_sayfa": 6,
      "metin": "Teknoloji sergisinde çocuk çantaya hangi görevi verdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Herkesin ödevini yapmayı"
        },
        {
          "id": "B",
          "metin": "Öğretmene cevap vermeyi"
        },
        {
          "id": "C",
          "metin": "Kaybolan defterlerin hangi rafta olduğunu hatırlatmayı"
        },
        {
          "id": "D",
          "metin": "Sergiyi fotoğraflamayı"
        }
      ],
      "dogru": "C",
      "aciklama": "Çocuk çantaya kaybolan defterlerin rafını hatırlatma görevini verdi; çanta kimsenin yerine ödev yapmadı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p02$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr034-2040-konusan-okul-cantasi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p03${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr035-aya-giden-ilk-posta",
    "baslik": "Ay'a Giden İlk Posta",
    "tur": "bilim_kurgu",
    "konu": "ay_postasi",
    "sinif_alt": 4,
    "sinif_ust": 4,
    "okuma_bandi": 3,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D15",
      "D16"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "bilim_teknoloji",
        "aile",
        "kesif"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D15",
        "yardimci_deger": "D16"
      },
      "ogrenme_hedefleri": [
        {
          "id": "gecikme_hr035",
          "tur": "lexeme",
          "etiket": "gecikme",
          "yuva": "pc_gecikme",
          "islev": "first_hint"
        },
        {
          "id": "uydu_hr035",
          "tur": "lexeme",
          "etiket": "uydu",
          "yuva": "pc_uydu",
          "islev": "application"
        },
        {
          "id": "dogrulama_hr035",
          "tur": "lexeme",
          "etiket": "doğrulama",
          "yuva": "pc_dogrulama",
          "islev": "application"
        },
        {
          "id": "kavram_hr035",
          "tur": "concept",
          "etiket": "Veri aktarımı ve iletişim gecikmesi",
          "islev": "application"
        },
        {
          "id": "atasoz_hr035",
          "tur": "proverb",
          "etiket": "Sabreden derviş muradına ermiş",
          "yuva": "pc_ata_sabreden",
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
        "kelime_sayisi": 483,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 9,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 6,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Bir mektup Ay'a nasıl gider? Bağlantı kopunca iki kardeş, mesajı kurtarmanın yolunu arar.",
    "durum": "taslak",
    "fis_kodu": "HR-035"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ay Üssü'ne gidecek ilk özel mektubu yazma hakkını iki kardeş kazanmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", Dünya'daki sınıfının resmini çizmiş; Can ise altına yalnızca bir cümle yazmıştı: \"Burada sizi merak eden arkadaşlarınız var.\" Mektup Ay'da çalışan teyzeleri Selin'e gönderilecekti. Yeni posta sistemi önce kâğıdı görüntüye dönüştürüyor, ardından uzaya veri olarak iletiyordu. Teyzeleri Ay Üssü'ndeki yazıcıdan aynı mektubu alacaktı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Posta merkezinde tavandan Dünya ve Ay'ın maketleri sarkıyordu. Can aralarındaki boşluğa baktı. \"Ay şu kadar yakınsa mektup çabucak gider,\" dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " iki maketi daha uzağa taşıdı. \"Bunlar gerçeğe göre küçültülmüş. Uzaydaki uzaklıkları maketle göstermek çok zor,\" diye açıkladı. "
        },
        {
          "t": "isaret",
          "kod": "ay"
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
          "v": ", mesajın nasıl ilerlediğini daha iyi anlamak için kabloları, anteni ve uydunun görevini çizdi. Her ok bir aşamayı gösteriyordu. Çocuklar, iletişimin yalnızca bir tuşa dokunmaktan ibaret olmadığını fark etmeye başlamıştı. Başlangıçta her şey yolundaydı. Fakat posta merkezinin ekranı birden kırmızıya döndü: *Bağlantı kesildi.*"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "\"Mektubumuz kayboldu mu?\" diye sordu Can. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", \"Hayır,\" dedi. \"Mesajın kopyası burada güvende. Ancak şimdi göndermiyoruz. Önce bağlantının yeniden kurulması gerek.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " üzülmüştü. Selin teyzesinin doğum gününe yalnızca bir gün kalmıştı. Can bir çözüm önerdi: \"Mektubu aynı anda başka bir kanaldan göndersek?\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gülümsedi. \"İyi düşünce. Fakat bütün kanallar aynı anda çalışmayabilir. Önce hangisinin güvenilir olduğuna bakmalıyız.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar merkezin panosunda çizilmiş küçük bir şemayı inceledi. Bir çizgi Dünya istasyonundan yörüngedeki uyduya uzanıyor, ikinci çizgi uydudan Ay Üssü'ne gidiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Mesajı küçük parçalara ayırsak?\" diye sordu. \"Bağlantı dönünce eksik kısmı tamamlarız.\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", \"Bu da veri aktarımında kullanılan yöntemlerden biridir,\" dedi. Ardından çocuklara mesajın birden fazla parçasının nasıl kontrol edildiğini gösterdi. Kısa bir bekleyişten sonra "
        },
        {
          "t": "kelime",
          "yuva": "pc_uydu"
        },
        {
          "t": "metin",
          "v": " bağlantısı tekrar açıldı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ekrana *İleti ulaştı* yazısı düşünce Can zıpladı. Fakat hemen bir soru sordu: \"Ay'daki teyze cevap verirse onu anında duyar mıyız?\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " başını salladı. \"Hayır, sinyaller ışık hızında ilerlese de Dünya ile Ay arasındaki uzaklık yüzünden küçük bir "
        },
        {
          "t": "kelime",
          "yuva": "pc_gecikme"
        },
        {
          "t": "metin",
          "v": " olur.\""
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
          "v": " çocuklara gönderimden önce yaptıkları iki kontrolü de anlatmıştı: alıcının kimliği doğru muydu ve mesaj gerçekten bütünüyle gelmiş miydi? Can kendi mektubuna bakıp \"Ya çizimimizin yarısı gitseydi?\" diye sordu. "
        },
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
          "yuva": "pc_dogrulama"
        },
        {
          "t": "metin",
          "v": " işaretini gösterdi. \"O zaman karşı taraf eksik parçayı isterdi.\" Mesajın güvenli iletimi artık ikisinin de zihninde bir bilmecenin çözümü gibiydi. Eve dönünce mektubun ilk taslağını sakladılar; günün sonunda öğrenilenlerin de bir hatıra olmasını istediler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi akşam evde bir görüntü geldi. Selin teyze, elinde basılmış mektubu tutuyordu. \"Sınıfınızın resmini duvarıma astım,\" dedi. \"Ay'ın gökyüzünde Dünya çok güzel görünüyor. Ama sizin yazdıklarınız daha güzel.\" Can, \"Biz de buradan seni görüyoruz!\" diye seslendi. Cevap hemen gelmedi. İki kardeş gülümseyerek bekledi. Can fısıldadı: \""
        },
        {
          "t": "atasozu",
          "yuva": "pc_ata_sabreden"
        },
        {
          "t": "metin",
          "v": "\" O küçük gecikme artık onları şaşırtmıyordu."
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
          "v": ", postanın yalnızca zarf ve pul olmadığını anladı. Bazen sevgi bir kâğıtta, bazen de uzaklara giden küçük veri parçalarında yolculuk ediyordu. Yine de en önemli şey, karşıdaki insanı hatırlamaktı. Can ertesi gün sınıfta öğrendiklerini arkadaşlarına anlattı. Sınıfça bir mesaj göndermeden önce adını, alıcısını ve içeriğini kontrol etmeye karar verdiler. Çünkü uzaklık ne kadar büyük olursa olsun, dikkatli iletişim küçük ama önemli adımlarla başlıyordu. "
        },
        {
          "t": "isaret",
          "kod": "roket"
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
      "metin": "Posta merkezinin ekranı birden kırmızıya dönünce ne yazdı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "İleti ulaştı"
        },
        {
          "id": "B",
          "metin": "Bağlantı kesildi"
        },
        {
          "id": "C",
          "metin": "Mektup kayboldu"
        },
        {
          "id": "D",
          "metin": "Gönderim tamamlandı"
        }
      ],
      "dogru": "B",
      "aciklama": "Her şey yolundayken ekran kırmızıya döndü ve \"Bağlantı kesildi\" yazdı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Görevli, \"Bütün kanallar aynı anda çalışmayabilir\" derken neyi anlatmak istedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Mektubun kesinlikle kaybolduğunu"
        },
        {
          "id": "B",
          "metin": "Posta merkezinin kapatılacağını"
        },
        {
          "id": "C",
          "metin": "Ay Üssü'nde kimsenin olmadığını"
        },
        {
          "id": "D",
          "metin": "Başka bir kanala geçmeden önce hangisinin güvenilir olduğunu kontrol etmek gerektiğini"
        }
      ],
      "dogru": "D",
      "aciklama": "Görevli, çocukların önerisini kabul etti ama önce güvenilir kanalın belirlenmesi gerektiğini söyledi."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 6,
      "metin": "Metinde geçen gecikme sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir şeyin beklenenden geç olması"
        },
        {
          "id": "B",
          "metin": "Bir şeyin çok hızlı olması"
        },
        {
          "id": "C",
          "metin": "Bir mektubun kaybolması"
        },
        {
          "id": "D",
          "metin": "Bir şeyin yok edilmesi"
        }
      ],
      "dogru": "A",
      "aciklama": "Sinyaller ışık hızında ilerlese de uzaklık yüzünden cevap birazdan, yani geç gelir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 9,
      "metin": "Sınıfın bir mesaj göndermeden önce adı, alıcıyı ve içeriği kontrol etmeye karar vermesi neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Mesajların hiç gönderilmemesi gerektiğini"
        },
        {
          "id": "B",
          "metin": "Uzak mesafelerde mesaj göndermenin imkânsız olduğunu"
        },
        {
          "id": "C",
          "metin": "Dikkatli iletişimin küçük ama önemli kontrollerle başladığını"
        },
        {
          "id": "D",
          "metin": "Hızın her zaman en önemli şey olduğunu"
        }
      ],
      "dogru": "C",
      "aciklama": "Metin, uzaklık ne kadar büyük olursa olsun dikkatli iletişimin küçük adımlarla başladığını söylüyor."
    },
    {
      "id": "s5",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 5,
      "metin": "Mesajı küçük parçalara ayırma fikri neden iyi bir çözümdür?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Mesaj daha uzun görünür"
        },
        {
          "id": "B",
          "metin": "Bağlantı yeniden kurulunca yalnızca eksik kısım tamamlanabilir"
        },
        {
          "id": "C",
          "metin": "Teyze mesajı hiç okuyamaz"
        },
        {
          "id": "D",
          "metin": "Mesaj Ay'a daha uzun bir yoldan gider"
        }
      ],
      "dogru": "B",
      "aciklama": "Bağlantı dönünce eksik parça tekrar gönderilip tamamlanabilir; görevli de bunun veri aktarımında kullanılan bir yöntem olduğunu söyledi."
    },
    {
      "id": "s6",
      "beceri": "hatirlama",
      "dayanak_sayfa": 8,
      "metin": "Ay'daki teyze mektupla ne yaptı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sınıfın resmini duvarına astı"
        },
        {
          "id": "B",
          "metin": "Mektubu geri gönderdi"
        },
        {
          "id": "C",
          "metin": "Mektubu saklamak için kutuya koydu"
        },
        {
          "id": "D",
          "metin": "Mektubu hiç okumadı"
        }
      ],
      "dogru": "A",
      "aciklama": "Teyze basılmış mektubu tutuyordu ve sınıfın resmini duvarına astığını söyledi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p03$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr035-aya-giden-ilk-posta: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p04${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr036-yedi-renkli-koprunun-koruyucusu",
    "baslik": "Yedi Renkli Köprünün Koruyucusu",
    "tur": "fantastik",
    "konu": "yedi_renkli_kopru",
    "sinif_alt": 4,
    "sinif_ust": 4,
    "okuma_bandi": 3,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D5",
      "D2"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "dostluk",
        "aile",
        "dayanisma"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D5",
        "yardimci_deger": "D2"
      },
      "ogrenme_hedefleri": [
        {
          "id": "cesaret_hr036",
          "tur": "lexeme",
          "etiket": "cesaret",
          "yuva": "pc_cesaret",
          "islev": "first_hint"
        },
        {
          "id": "destek_hr036",
          "tur": "lexeme",
          "etiket": "destek",
          "yuva": "pc_destek",
          "islev": "application"
        },
        {
          "id": "prova_hr036",
          "tur": "lexeme",
          "etiket": "prova",
          "yuva": "pc_prova",
          "islev": "application"
        },
        {
          "id": "kavram_hr036",
          "tur": "concept",
          "etiket": "Öz farkındalık ve cesaret",
          "islev": "application"
        },
        {
          "id": "atasoz_hr036",
          "tur": "proverb",
          "etiket": "Bir elin nesi var iki elin sesi var",
          "yuva": "pc_ata_el",
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
        "kelime_sayisi": 463,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 9,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 3,
        "simge_sayisi": 1
      }
    },
    "tanitim": "Köprünün mor ışığı söndü. Işığı geri getirebilecek tek şey, kimseye söylenmemiş bir korkuydu.",
    "durum": "taslak",
    "fis_kodu": "HR-036"
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
          "v": " kasabasındaki eski taş köprü her akşam yedi farklı renkte parlardı. Kasabalılar bu ışığın nereden geldiğini bilmiyordu. Köprünün başında yaşayan bekçi ise yalnızca şunu söylerdi: \"Renkler, insanların unuttuğu duyguları hatırlatır.\" O gece "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tuhaf bir rüya görmüştü. Köprünün taşlarının üzerinde yürürken her biri ona bir anısını fısıldıyordu: ilk bisiklet sürüşündeki sevinç, kaybolan kedisini ararken duyduğu üzüntü, arkadaşına kızdığı günün öfkesi. "
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
          "v": "Uyandığında bunların hepsinin kendi duyguları olduğunu hatırladı. Yine de korku taşına gelince rüyadaki ses kesilmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun nedenini merak etti. Birkaç gün sonra köprünün mor ışığı kayboldu. Ardından sarı, mavi ve yeşil ışıklar da sönükleşti. Nehrin karşı kıyısındaki çocukların okula gitmesi zorlaştı; sis çöktüğünde köprü neredeyse görünmez oluyordu."
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
          "v": " çözüm bulmak için bekçiye koştu. Bekçi ona yedi taş gösterdi: sevinç, üzüntü, öfke, şaşkınlık, sevgi, umut ve korku. \"Korku taşının rengi solmuş,\" dedi bekçi. \"Onu yeniden parlatacak olan, korkmadığını söyleyen değil, korkusunu tanıyandır.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hemen, \"Ben hiçbir şeyden korkmam!\" dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "O sırada köprünün öbür ucundan küçük kardeşi Mert'in sesi geldi. \"Sis başladı!\" diye bağırıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " kalbi hızlandı. Aslında yükseklikten korkuyordu. Köprü güvenliydi ama aşağıdaki suyu görünce elleri terliyordu. Yıllardır bu korkusunu arkadaşlarından saklamıştı. Bekçi acele etmedi. \"Korkmak utanılacak bir şey değil,\" dedi. \"Bir şeyi nasıl güvenle yapacağını düşünmene yardım edebilir.\""
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
          "v": " derin bir nefes aldı. \"Evet, yüksekten korkuyorum,\" dedi. \"Ama kardeşimin yanına da gitmek istiyorum.\" Bekçiyle birlikte korkulukları kontrol ettiler. Sis hafifleyene kadar beklediler. Sonra "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", köprünün ortasına kadar yürüdü. Mert de bulunduğu yerde güvenle bekliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " adımlarını saydı. Bir, iki, üç... Ortaya geldiğinde nehrin uğultusunu duydu ama geri dönmedi. Bekçi yanındaydı. Birlikte Mert'e ulaştılar."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "O anda köprünün mor taşı parladı. Ardından diğer renkler de usulca yerine döndü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Demek "
        },
        {
          "t": "kelime",
          "yuva": "pc_cesaret"
        },
        {
          "t": "metin",
          "v": " korkmamak değilmiş,\" dedi. Bekçi gülümsedi. \"Cesaret bazen yardım istemektir. Bazen de tehlikeyi fark edip doğru zamanı beklemek.\" Mert akşam "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": ", \"Beni almaya geldiğin için teşekkür ederim,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise onu beklediği yerde kalmayı başardığı için kutladı. \"Sen de korkmuş olabilirsin,\" dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Mert başını salladı. \"Korktum ama rastgele koşarsam kayabilirdim. O yüzden seni bekledim.\" İki kardeş birbirlerine sarıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " anladı ki cesaret gösteren yalnızca kendisi değildi; güvenli biçimde beklemek de bazen cesur bir karardı. Ertesi gün "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", okulda korkusunu arkadaşlarına anlattı. Kimse onunla alay etmedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hatta "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " karanlıktan, Arda ise kalabalık önünde konuşmaktan çekindiğini söyledi. Çocuklar birbirlerine "
        },
        {
          "t": "kelime",
          "yuva": "pc_destek"
        },
        {
          "t": "metin",
          "v": " olmak için küçük bir söz verdiler: \""
        },
        {
          "t": "atasozu",
          "yuva": "pc_ata_el"
        },
        {
          "t": "metin",
          "v": "\" Köprü o gece yine yedi renkte parladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ne zaman mor ışığı görse kendine aynı cümleyi hatırlattı: \"Korkumu adlandırınca onu daha iyi anlayabiliyorum.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Birkaç hafta sonra "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " sınıf önünde şiir okumak için çekindi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yanına oturup \"İstersen önce bana oku,\" dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " küçük bir "
        },
        {
          "t": "kelime",
          "yuva": "pc_prova"
        },
        {
          "t": "metin",
          "v": " yaptı; sonra arkadaşlarının karşısına çıktı. Her kelimesi kusursuz değildi ama sonunda gülümsedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " o an köprüde öğrendiği şeyin yalnızca kendisine ait olmadığını fark etti: İnsanlar birbirlerinin korkularına saygı duyduğunda, dünyada görünmez köprüler de kuruluyordu."
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
      "metin": "Bekçiye göre hangi taşın rengi solmuştu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sevinç taşının"
        },
        {
          "id": "B",
          "metin": "Öfke taşının"
        },
        {
          "id": "C",
          "metin": "Korku taşının"
        },
        {
          "id": "D",
          "metin": "Umut taşının"
        }
      ],
      "dogru": "C",
      "aciklama": "Bekçi, korku taşının renginin solduğunu söyledi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Çocuk \"Ben hiçbir şeyden korkmam!\" derken gerçekte neyi yapıyor olabilir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bekçiyi güldürmeye çalışıyor"
        },
        {
          "id": "B",
          "metin": "Yüksekten korktuğunu kabul etmekten çekiniyor"
        },
        {
          "id": "C",
          "metin": "Köprüden hiç geçmemiş olduğunu söylüyor"
        },
        {
          "id": "D",
          "metin": "Kardeşine kızgın olduğunu belirtiyor"
        }
      ],
      "dogru": "B",
      "aciklama": "Çocuk yıllardır yükseklik korkusunu arkadaşlarından saklıyordu; bunu kabul etmek istemedi."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 6,
      "metin": "Metinde geçen cesaret sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hiçbir şeyden korkmama"
        },
        {
          "id": "B",
          "metin": "Başkalarına kızma"
        },
        {
          "id": "C",
          "metin": "Hızlı koşabilme"
        },
        {
          "id": "D",
          "metin": "Korktuğu hâlde doğru olanı yapabilme gücü"
        }
      ],
      "dogru": "D",
      "aciklama": "Metinde cesaret, korkmamak değil; korkuyu tanıyıp güvenli ve doğru olanı yapmak olarak anlatılıyor."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Bekçi \"Cesaret bazen yardım istemektir\" derken neyi anlatmak istedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yardım istemenin de güçlü ve akıllıca bir davranış olabileceğini"
        },
        {
          "id": "B",
          "metin": "Kimsenin kimseye yardım etmemesi gerektiğini"
        },
        {
          "id": "C",
          "metin": "Köprüde hiç beklememek gerektiğini"
        },
        {
          "id": "D",
          "metin": "Korkunun hiç olmadığını"
        }
      ],
      "dogru": "A",
      "aciklama": "Bekçi cesaretin yalnızca atılgan olmak olmadığını, yardım istemenin ve doğru zamanı beklemenin de cesaret olduğunu söyledi."
    },
    {
      "id": "s5",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 7,
      "metin": "Mert sis varken rastgele koşmak yerine beklemeyi seçti. Bu karar için ne söylenebilir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yanlıştı, çünkü hemen koşmalıydı"
        },
        {
          "id": "B",
          "metin": "Önemsizdi, çünkü köprü zaten güvenliydi"
        },
        {
          "id": "C",
          "metin": "Akıllıcaydı, çünkü rastgele koşmak kaymasına neden olabilirdi"
        },
        {
          "id": "D",
          "metin": "Gereksizdi, çünkü kimse onu almaya gelmeyecekti"
        }
      ],
      "dogru": "C",
      "aciklama": "Mert, rastgele koşarsa kayabileceğini bildiği için olduğu yerde güvenle bekledi."
    },
    {
      "id": "s6",
      "beceri": "hatirlama",
      "dayanak_sayfa": 9,
      "metin": "Sınıf önünde şiir okumaktan çekinen arkadaşına çocuk ne önerdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Şiiri hiç okumamasını"
        },
        {
          "id": "B",
          "metin": "Önce kendisine okumasını"
        },
        {
          "id": "C",
          "metin": "Şiiri öğretmene vermesini"
        },
        {
          "id": "D",
          "metin": "Başka bir şiir seçmesini"
        }
      ],
      "dogru": "B",
      "aciklama": "Çocuk, \"İstersen önce bana oku\" diyerek arkadaşına destek oldu."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p04$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr036-yedi-renkli-koprunun-koruyucusu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p05${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr037-son-pasin-hikayesi",
    "baslik": "Son Pasın Hikâyesi",
    "tur": "spor",
    "konu": "futbol_turnuvasi",
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
      "D14"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "dostluk",
        "dayanisma",
        "saglikli_yasam"
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
          "id": "pas_hr037",
          "tur": "lexeme",
          "etiket": "pas",
          "yuva": "pc_pas",
          "islev": "first_hint"
        },
        {
          "id": "taktik_hr037",
          "tur": "lexeme",
          "etiket": "taktik",
          "yuva": "pc_taktik",
          "islev": "application"
        },
        {
          "id": "savunma_hr037",
          "tur": "lexeme",
          "etiket": "savunma",
          "yuva": "pc_savunma",
          "islev": "application"
        },
        {
          "id": "kavram_hr037",
          "tur": "concept",
          "etiket": "İş birliği ve ortak başarı",
          "islev": "application"
        },
        {
          "id": "atasoz_hr037",
          "tur": "proverb",
          "etiket": "Birlikten kuvvet doğar",
          "yuva": "pc_ata_birlik",
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
        "kelime_sayisi": 502,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 8,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 6,
        "simge_sayisi": 1
      }
    },
    "tanitim": "Son dakikada kaleye tek başına koşmak mı, boştaki arkadaşa pas vermek mi? Karar saniyeler içinde.",
    "durum": "taslak",
    "fis_kodu": "HR-037"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Okullar arası futbol turnuvasının son maçı başlamadan önce "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", ayakkabısının bağcıklarını üçüncü kez bağladı. Bu karşılaşmada bir gol atmayı öyle çok istiyordu ki takım arkadaşlarının konuşmalarını duymuyordu bile. Kaptan "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", \"Hep birlikte oynarsak kazanabiliriz,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını salladı ama içinden, *Kazandıran gol benim olmalı*, diye geçirdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Maçtan bir gün önce "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bahçede tek başına şut çalışmıştı. Her golün ardından ellerini havaya kaldırıyor, hayalinde arkadaşlarının kendisini alkışladığını görüyordu. Babası kenardan seslenmişti: \"Futbol tek kişinin oynadığı bir oyun değil.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Biliyorum,\" demiş ama nedenini tam düşünmemişti. Şimdi tribüne bakarken bu konuşma aklına geldi. Kazanmak istiyordu; bir yandan da arkadaşlarının kendisine güvenmesini. Fakat yalnızca kendi golünü düşünürse onların güvenini nasıl kazanacaktı?"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk yarıda "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " topu iki kez kaleye taşıdı. Birinde şutunu "
        },
        {
          "t": "kelime",
          "yuva": "pc_savunma"
        },
        {
          "t": "metin",
          "v": " engelledi, ötekinde kalecinin üzerine vurdu. Yan tarafta boş bekleyen Emre'yi gözden kaçırmıştı. Devre arasında takım gerideydi. Öğretmenleri "
        },
        {
          "t": "kelime",
          "yuva": "pc_taktik"
        },
        {
          "t": "metin",
          "v": " tahtasını açtı. \"Şut çekmek cesaret ister,\" dedi, \"ama iyi bir oyuncu sahadaki arkadaşlarını da görür.\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", \"Emre bugün çok iyi koşular yapıyor,\" diye ekledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Biliyorum, ama gol atma fırsatını kaçırmaktan korkuyorum,\" dedi. \"Bazen fırsat topu paylaşınca büyür,\" diye cevap verdi "
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
          "v": "Öğretmen, tahta üzerinde üç küçük nokta çizerek topun gidebileceği yolları göstermişti. Bir çizgi doğrudan kaleye gidiyordu ama önünde iki savunmacı vardı. Diğer çizgi, boş alandaki arkadaşına uzanıyordu. \"İyi karar vermek, seçeneği görmekle başlar,\" demişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çizimleri aklında tutmaya çalıştı. Sahaya dönünce seyircinin sesini değil, arkadaşlarının konumlarını dinledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ona boş alanı eliyle gösterince ilk kez ne yapacağını önceden planladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkinci yarıda takım daha dikkatli oynadı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " topu "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " aktardı; "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu kez hemen şut çekmek yerine etrafına baktı. Emre'ye "
        },
        {
          "t": "kelime",
          "yuva": "pc_pas"
        },
        {
          "t": "metin",
          "v": " verdi. Emre topu geri gönderince savunmanın arkasında boşluk açıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " golü attı. Skor eşitlendi. Son bir dakika kalmıştı. Rakip takımın savunması "
        },
        {
          "t": "kahraman",
          "hal": "belirtme"
        },
        {
          "t": "metin",
          "v": " iki oyuncuyla karşıladı. O yine kaleye yöneldi; tribünden adını duyuyordu. Tam vuracakken Emre'yi gördü. Kaleye daha yakındı ve önünde kimse yoktu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir an içinde iki düşünce yarıştı: *Golü kendim atabilirim.* *Pas verirsem takım daha iyi bir fırsat yakalar.* "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ayağını çevirdi, topu Emre'ye gönderdi. Emre düzgün bir vuruşla golü attı. Hakemin son düdüğüyle çocuklar sevinç içinde birbirlerine sarıldı. Takım kupayı alırken Emre, \"Golü ben attım ama fırsatı sen hazırladın,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülümsedi. \"Ben de yalnızca topa bakarsam arkadaşlarımı gözden kaçırdığımı anladım.\" "
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
          "v": "Rakip takımın kalecisi de maç sonunda yanlarına geldi. \"İyi oynadınız,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onun elini sıktı. \"Sen de zor şutları kurtardın,\" diye karşılık verdi. Öğretmen, kazanmanın rakibe saygıyı azaltmaması gerektiğini hatırlattı. Çocuklar kupayı sırayla tutarak fotoğraf çektirdiler. Emre ilk fotoğrafta kenarda kalmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onu ortalarına çağırdı. Çünkü o gün en çok öğrendiği şeylerden biri, sahadaki kimsenin görünmez olmaması gerektiğiydi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Soyunma odasında "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ona bir fotoğraf gösterdi. Karede bütün takım aynı anda zıplıyordu. Hiç kimsenin yüzünde kimin gol attığına dair bir hesap yoktu. Öğretmenleri, \"İşte takım olmak bu,\" dedi. \"Bir kişinin parlaması değil, herkesin birbirinin ışığını artırması. Atalarımız boşuna söylememiş: "
        },
        {
          "t": "atasozu",
          "yuva": "pc_ata_birlik"
        },
        {
          "t": "metin",
          "v": "\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " fotoğrafı çantasına koydu. Eve giderken bir şeyi daha düşündü: Arkadaşını görebilmek için bazen topa değil, bütün sahaya bakmak gerekiyordu. Bu yalnızca futbolda değil, birlikte yapılan her işte önemliydi."
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
      "metin": "İlk yarıda çocuk hangi arkadaşını gözden kaçırmıştı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kaptanı"
        },
        {
          "id": "B",
          "metin": "Emre'yi"
        },
        {
          "id": "C",
          "metin": "Kaleciyi"
        },
        {
          "id": "D",
          "metin": "Babasını"
        }
      ],
      "dogru": "B",
      "aciklama": "İlk yarıda yan tarafta boş bekleyen Emre gözden kaçmıştı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Çocuğun babasının sözü, tribüne bakarken neden aklına geldi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yalnızca kendi golünü düşünmenin takımın güvenini kazandırmayacağını fark etmeye başladığı için"
        },
        {
          "id": "B",
          "metin": "Babasının tribünde olmadığını görüp üzüldüğü için"
        },
        {
          "id": "C",
          "metin": "Bahçedeki şutlarını unuttuğu için"
        },
        {
          "id": "D",
          "metin": "Maçı kazanmak istemediği için"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuk hem kazanmak hem de arkadaşlarının güvenini kazanmak istiyordu; bu ikisinin yalnız gol düşünerek olmayacağını anlamaya başladı."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 5,
      "metin": "Metinde geçen pas sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kaleye atılan şut"
        },
        {
          "id": "B",
          "metin": "Oyundan çıkma"
        },
        {
          "id": "C",
          "metin": "Topu takım arkadaşına gönderme"
        },
        {
          "id": "D",
          "metin": "Maçın bittiğini duyurma"
        }
      ],
      "dogru": "C",
      "aciklama": "Çocuk topu Emre'ye gönderdi; futbolda buna pas denir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Emre'nin \"Golü ben attım ama fırsatı sen hazırladın\" demesi neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Golün aslında hiç sayılmadığını"
        },
        {
          "id": "B",
          "metin": "Kendisinin hiç çalışmadığını"
        },
        {
          "id": "C",
          "metin": "Kaptanın hata yaptığını"
        },
        {
          "id": "D",
          "metin": "Başarının tek kişiye değil, birlikte hazırlanan harekete ait olduğunu"
        }
      ],
      "dogru": "D",
      "aciklama": "Emre golü attı ama fırsatı çocuk hazırlamıştı; başarıda herkesin payı vardı."
    },
    {
      "id": "s5",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 6,
      "metin": "Çocuğun son dakikada golü kendisi atmak yerine pas vermesi için ne söylenebilir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Cesaretsiz bir davranıştı"
        },
        {
          "id": "B",
          "metin": "Takımın kazanma şansını artıran, bencil olmayan bir karardı"
        },
        {
          "id": "C",
          "metin": "Kurallara aykırı bir davranıştı"
        },
        {
          "id": "D",
          "metin": "Emre'yi bilerek zor durumda bıraktı"
        }
      ],
      "dogru": "B",
      "aciklama": "Emre kaleye daha yakındı ve önünde kimse yoktu; pas vermek takım için daha iyi bir fırsat yarattı."
    },
    {
      "id": "s6",
      "beceri": "hatirlama",
      "dayanak_sayfa": 7,
      "metin": "Kupa fotoğrafında Emre kenarda kalınca çocuk ne yaptı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Fotoğrafı iptal etti"
        },
        {
          "id": "B",
          "metin": "Emre'yi görmezden geldi"
        },
        {
          "id": "C",
          "metin": "Onu ortalarına çağırdı"
        },
        {
          "id": "D",
          "metin": "Kupayı Emre'den aldı"
        }
      ],
      "dogru": "C",
      "aciklama": "Çocuk Emre'yi ortalarına çağırdı, çünkü sahadaki kimsenin görünmez olmaması gerektiğini öğrenmişti."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p05$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr037-son-pasin-hikayesi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p06${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr038-muzik-kutusunun-sifresi",
    "baslik": "Müzik Kutusunun Şifresi",
    "tur": "gizem",
    "konu": "muzik_kutusu",
    "sinif_alt": 4,
    "sinif_ust": 4,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D2",
      "D5"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "aile",
        "gizem",
        "sanat_yaraticilik"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D2",
        "yardimci_deger": "D5"
      },
      "ogrenme_hedefleri": [
        {
          "id": "nota_hr038",
          "tur": "lexeme",
          "etiket": "nota",
          "yuva": "pc_nota",
          "islev": "first_hint"
        },
        {
          "id": "duraklama_hr038",
          "tur": "lexeme",
          "etiket": "duraklama",
          "yuva": "pc_duraklama",
          "islev": "application"
        },
        {
          "id": "armagan_hr038",
          "tur": "lexeme",
          "etiket": "armağan",
          "yuva": "pc_armagan",
          "islev": "application"
        },
        {
          "id": "kavram_hr038",
          "tur": "concept",
          "etiket": "Ritim, çıkarım ve aile belleği",
          "islev": "application"
        },
        {
          "id": "atasoz_hr038",
          "tur": "proverb",
          "etiket": "Acele işe şeytan karışır",
          "yuva": "pc_ata_acele",
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
        "kelime_sayisi": 521,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 8,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1,
          "degerlendirme": 1
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
    "tanitim": "Kilidi anahtarsız bir müzik kutusu. Şifre dört notada saklı mı, yoksa başka bir yerde mi?",
    "durum": "taslak",
    "fis_kodu": "HR-038"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Büyükanne Zeliha, eski ceviz sandığını açtığında içinden avuç içi kadar bir müzik kutusu çıktı. Kapağındaki küçük kuşun kanadı kırılmıştı; altındaki kilit ise anahtarsızdı. \"Bu kutu eskiden şarkı söylerdi,\" dedi Zeliha. \"Ama nasıl açıldığını unuttum.\" Torunları "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ve Aras kutuyu incelemeye başladılar. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de not almak için küçük bir kâğıt çıkardı. Kutunun üzerinde dört küçük düğme vardı. Her düğmeye basınca başka bir "
        },
        {
          "t": "kelime",
          "yuva": "pc_nota"
        },
        {
          "t": "metin",
          "v": " duyuluyordu: do, re, mi, sol."
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
          "v": " daha önce okulun müzik dersinde seslerin yüksekliğiyle süresinin aynı şey olmadığını öğrenmişti. İnce ve kalın sesler bir özelliği, kısa ve uzun süreler başka bir özelliği anlatıyordu. Aras, \"Ben en yüksek sesi bulmamız gerektiğini sanmıştım,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Belki notalar doğru ama çalma biçimimiz yanlış,\" diye cevap verdi. Bu yüzden acele etmek yerine duyduklarını küçük işaretlerle yazmaya karar verdiler. Zeliha gülümseyerek, \""
        },
        {
          "t": "atasozu",
          "yuva": "pc_ata_acele"
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
          "t": "metin",
          "v": "Aras düğmelere rastgele bastı. Kutu küçük bir tık sesi çıkardı ama açılmadı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", kapağın kenarındaki işaretleri gösterdi: iki kısa çizgi, bir uzun çizgi ve küçük bir nokta. \"Bunlar seslerin süresini anlatıyor olabilir,\" dedi. Çocuklar masaya dört renkli kâğıt koydu. Her notaya bir renk verdiler ve duydukları sesleri sırayla yazdılar. İlk deneme başarısızdı. İkinci denemede müzik kutusu dört nota çaldı ama yine kapalı kaldı. \"Belki sırayı doğru, ritmi yanlış çalıyoruz,\" diye düşündü "
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
          "v": "Büyükanne pencerenin yanından eski bir fotoğraf getirdi. Fotoğrafta küçük Zeliha, bir arkadaşıyla birlikte piyano başındaydı. Kenarına şu cümle yazılmıştı: *Önce iki kısa, sonra bir uzun. Sonunda hep birlikte sus.* Aras heyecanlandı. \"Sonunda bir ses daha yok. Bir "
        },
        {
          "t": "kelime",
          "yuva": "pc_duraklama"
        },
        {
          "t": "metin",
          "v": " var!\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " notaları doğru sırayla çaldı; son düğmeden sonra bir an bekledi. Kapağın içinden yumuşak bir çıtırtı duyuldu. Kilit açılmıştı. "
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
          "v": "Aras, kapağı açmadan hemen önce bir kez daha durdu. \"Büyükanne, ya içindeki şey kırılacak kadar hassassa?\" diye sordu. Zeliha bir bez getirdi ve masanın üzerine serdi. Çocuklar kutuyu onun üstüne koyup kapağını yavaşça kaldırdılar. Sır çözmek onları heyecanlandırıyordu fakat eski eşyalara dikkatle davranmak da önemliydi. Sonradan fark ettiler ki kapakta küçük bir çizik vardı; onu zorlayarak açmaya kalksalardı hatıraya zarar verebilirlerdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kutunun içinde altın ya da mücevher yoktu. Küçük bir kart, sararmış bir fotoğraf ve sarı kurdeleli bir mektup vardı. Mektupta, Zeliha'nın çocukluk arkadaşının uzak bir kente taşınmadan önce bu melodiyi armağan ettiği yazıyordu. \"Çocukken birlikte oyun oynardık,\" diye anlattı Zeliha. \"Bir gün bu küçük melodiyi her buluşmamızda çalmaya söz verdik. Sonra taşındılar. Aradan yıllar geçti ama bir melodiyi duyunca sanki arkadaşım yanımdaymış gibi olur.\""
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
          "v": ", müziğin yalnızca notalardan oluşmadığını düşündü. Bir şarkı, insanın belleğinde uzak bir güne açılan kapı da olabilirdi. Aras ise fotoğraftaki iki çocuğun yüzlerini dikkatle inceledi; şimdi büyükannesi olan küçük kızın gülüşünü hemen tanıdı. Büyükanne mektubu okuyunca gözleri doldu. \"Bu melodiyi birlikte bestelemiştik,\" dedi. \"Yıllardır nerede sakladığımı düşünürdüm.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Demek kutunun şifresi yalnızca nota değil, bir hatıraymış,\" dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Aras kutuyu yeniden çaldı. Bu kez duraklamayı unutmadı. Büyükanne de müziğe hafifçe eşlik etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de sessizce dinledi. O akşam aile albümünden başka fotoğraflar çıkardılar. Aras her fotoğrafın arkasına kimlerin bulunduğunu yazmayı önerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise büyükanneye anılarını kaydedecek küçük bir defter "
        },
        {
          "t": "kelime",
          "yuva": "pc_armagan"
        },
        {
          "t": "metin",
          "v": " etti. Çünkü bir gün başkalarının da bu hikâyeleri öğrenmesini istiyorlardı. Müzik kutusunun kanadı hâlâ kırıktı. Ama artık onun için önemli olan kusursuz görünüşü değil, içinde sakladığı seslerdi. "
        },
        {
          "t": "isaret",
          "kod": "kalp"
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
      "metin": "Müzik kutusunun üzerinde kaç küçük düğme vardı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "İki"
        },
        {
          "id": "B",
          "metin": "Üç"
        },
        {
          "id": "C",
          "metin": "Dört"
        },
        {
          "id": "D",
          "metin": "Beş"
        }
      ],
      "dogru": "C",
      "aciklama": "Kutunun üzerinde dört küçük düğme vardı; her biri başka bir nota çalıyordu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Fotoğrafın kenarındaki \"Sonunda hep birlikte sus\" cümlesinden ne anlaşılır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kutunun hiç çalınmaması gerektiği"
        },
        {
          "id": "B",
          "metin": "Son düğmeden sonra bir an sessiz beklemek gerektiği"
        },
        {
          "id": "C",
          "metin": "Bütün düğmelere aynı anda basılması gerektiği"
        },
        {
          "id": "D",
          "metin": "Kutunun yalnızca geceleri açılacağı"
        }
      ],
      "dogru": "B",
      "aciklama": "Çocuklar son işaretin bir ses değil, duraklama olduğunu anladı ve kilit açıldı."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "Metinde geçen duraklama sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çok yüksek ses"
        },
        {
          "id": "B",
          "metin": "Müziği hızlandırma"
        },
        {
          "id": "C",
          "metin": "Bir çalgıyı kırma"
        },
        {
          "id": "D",
          "metin": "Seslerin arasında kısa bir süre susup beklemek"
        }
      ],
      "dogru": "D",
      "aciklama": "Çocuk son düğmeden sonra bir an bekledi; kilit bu sessizlikten sonra açıldı."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 7,
      "metin": "Çocuk \"Kutunun şifresi yalnızca nota değil, bir hatıraymış\" derken neyi anlatmak istedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kutuyu açan şeyin yalnız sesler değil, geçmişten gelen bir anı ve bir dostluk olduğunu"
        },
        {
          "id": "B",
          "metin": "Kutunun içinde altın bulunduğunu"
        },
        {
          "id": "C",
          "metin": "Notaların hiç önemli olmadığını"
        },
        {
          "id": "D",
          "metin": "Kutunun artık çalışmayacağını"
        }
      ],
      "dogru": "A",
      "aciklama": "Kutuyu açan melodi, büyükannenin çocukluk arkadaşıyla paylaştığı bir hatıraydı."
    },
    {
      "id": "s5",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 5,
      "metin": "Çocukların kapağı açmadan önce bir bez serip kutuyu yavaşça kaldırması neden yerindedir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kutu çok ağır olduğu için"
        },
        {
          "id": "B",
          "metin": "Eski eşyalara dikkatle davranmak, hatıraya zarar vermemek için önemlidir"
        },
        {
          "id": "C",
          "metin": "Kapak kendiliğinden açılacağı için"
        },
        {
          "id": "D",
          "metin": "Bez kutuyu parlak gösterdiği için"
        }
      ],
      "dogru": "B",
      "aciklama": "Metne göre kapakta küçük bir çizik vardı; zorlayarak açmak hatıraya zarar verebilirdi."
    },
    {
      "id": "s6",
      "beceri": "hatirlama",
      "dayanak_sayfa": 6,
      "metin": "Kutunun içinden neler çıktı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Altın ve mücevher"
        },
        {
          "id": "B",
          "metin": "Bir harita ve bir anahtar"
        },
        {
          "id": "C",
          "metin": "Küçük bir kart, sararmış bir fotoğraf ve sarı kurdeleli bir mektup"
        },
        {
          "id": "D",
          "metin": "Yeni bir müzik kutusu"
        }
      ],
      "dogru": "C",
      "aciklama": "Kutunun içinde altın ya da mücevher yoktu; kart, fotoğraf ve mektup vardı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p06$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr038-muzik-kutusunun-sifresi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p07${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr039-ankanin-kaybolan-tuyu",
    "baslik": "Anka'nın Kaybolan Tüyü",
    "tur": "fantastik",
    "konu": "anka_kusu",
    "sinif_alt": 4,
    "sinif_ust": 4,
    "okuma_bandi": 3,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D5",
      "D9"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "doga",
        "hayvanlar",
        "kesif"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D5",
        "yardimci_deger": "D9"
      },
      "ogrenme_hedefleri": [
        {
          "id": "goc_hr039",
          "tur": "lexeme",
          "etiket": "göç",
          "yuva": "pc_goc",
          "islev": "first_hint"
        },
        {
          "id": "efsanevi_hr039",
          "tur": "lexeme",
          "etiket": "efsanevi",
          "yuva": "pc_efsanevi",
          "islev": "application"
        },
        {
          "id": "gozlem_hr039",
          "tur": "lexeme",
          "etiket": "gözlem",
          "yuva": "pc_gozlem",
          "islev": "application"
        },
        {
          "id": "kavram_hr039",
          "tur": "concept",
          "etiket": "Kuş göçü ve canlıları koruma",
          "islev": "application"
        },
        {
          "id": "atasoz_hr039",
          "tur": "proverb",
          "etiket": "Sormakla yol bulunur",
          "yuva": "pc_ata_sormak",
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
        "kelime_sayisi": 497,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 8,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1,
          "degerlendirme": 1
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
    "tanitim": "Orman yolunda parlayan bir tüy, sahibine ulaşmak için bir çocuktan yardım istiyor.",
    "durum": "taslak",
    "fis_kodu": "HR-039"
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
          "v": ", tepelerin ardındaki ormanda altın gibi parlayan bir tüy buldu. Tüy rüzgârda savrulmuyor, sanki kendi yolunu seçiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onu eline alınca ince bir ses duydu: \"Beni geldiğim yere götür.\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de tüye merakla baktı. Sesin nereden geldiğini anlamadılar. Tam o sırada gökyüzünde kocaman bir gölge belirdi. Yaşlı orman bekçisi gülümseyerek, \"Anka kuşunun tüyü olabilir,\" dedi. \"O, masalların uzak dağlarında yaşayan "
        },
        {
          "t": "kelime",
          "yuva": "pc_efsanevi"
        },
        {
          "t": "metin",
          "v": " kuştur.\" "
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
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " şaşırdı. \"Masaldaki kuş neden burada?\" Bekçi, \"Belki birine yardım ediyordur,\" diye cevap verdi. Patika ikiye ayrıldığında "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " durdu. Soldaki yol kısa görünüyordu ama üzerinde \"Yaban Hayatı Koruma Alanı\" yazan bir levha vardı; ziyaretçilerin girmemesi gerekiyordu. Sağdaki işaretli yol daha uzundu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Tüy soldan gitmemizi istiyor gibi,\" dedi. Bekçi, \"Masallarda bile canlıların yaşam alanına saygı gerekir,\" diye cevap verdi. İkisi güvenli patikayı seçti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk kez bir macerada en hızlı yolun her zaman doğru yol olmadığını düşündü."
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
          "v": ", tüyün parıltısını izleyerek yürümeye başladı. Yoldaki ağaçların arasında minik kuşlar uçuşuyordu. Bir çalıya takılmış yuvayı görünce durdu. Yuvada iki yavru vardı, anne kuş ise korkuyla ötüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yuvaya dokunmadı; orman bekçisini çağırdı. Bekçi yuvanın güvenli biçimde korunması için gerekli adımları attı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yavruları korkutmamak için sessizce geri çekildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", yavruların yeniden sakinleşmesini izledi. "
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
          "v": "Tüy o sırada daha parlak oldu. Sonra kuzeye doğru hafifçe uzandı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ile bekçi, ormandaki işaretli patikadan yürüdü. Büyük bir ağacın tepesinde göçmen kuşların toplandığını gördüler. \"Bu kuşlar neden bu kadar kalabalık?\" diye sordu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". \"Yılın belli zamanlarında daha uygun iklim ve besin bulmak için "
        },
        {
          "t": "kelime",
          "yuva": "pc_goc"
        },
        {
          "t": "metin",
          "v": " ederler,\" dedi bekçi. \"Yolculukları uzun ve zorludur.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Tüyün ışığı kuşların uçacağı yöne uzanan küçük bir şerit gibi parladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onun kaybolmuş olmadığını, görevinin bir kısmını yapmak için yere indiğini düşündü. Tam o sırada Anka, sislerin arasından ortaya çıktı. Kanatları gün batımı gibi kızıldı. Yere konmadan "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " başının üstünde dönerek konuştu: \"Tüyümü koruduğun için teşekkür ederim.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tüyü yukarı kaldırdı. \"Ben yalnızca geri götürmek istedim.\" \"Yolda başka canlıları da gözetmişsin,\" dedi Anka. \"Gerçek yardım bazen birine kanat germektir.\""
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
          "v": ", bunun bir deyim olduğunu hatırladı. Kanat germek, birini koruyup kollamak demekti. Anka tüyünü alınca göçmen kuşların önünde uçmaya başladı; kuşlar da onu izledi. Anka gitmeden önce "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " son kez dönmüştü. \"Tüyümün ışığı sence herkese aynı şeyi mi anlatır?\" diye sormuştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını sallamıştı. \"Göç eden kuşlara yol, bana yardım etmenin anlamını gösterdi.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Anka, \"Öyleyse gördüğün mucizenin bir kısmı senin düşünmende,\" demişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu sözleri unutmadı. Efsanelerin insanı sorular sormaya yöneltebildiğini, cevapların bir bölümünün ise doğayı gözlemleyerek bulunacağını fark etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " akşam defterine gördüklerini yazdı. Gerçek dünyada kuşların göç ederken güneşten, yıldızlardan ve Dünya'nın manyetik alanından yararlanabildiğini öğrenince daha da meraklandı. Masalın büyüsü onu bilimsel bir soruya götürmüştü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "O gece annesine tüyün sesini anlattı. Annesi inanıp inanmamak yerine, \"Bu deneyim sende hangi soruları uyandırdı?\" diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Kuşların göç yollarını kim koruyor?\" dedi. Annesi gülümsedi: \""
        },
        {
          "t": "atasozu",
          "yuva": "pc_ata_sormak"
        },
        {
          "t": "metin",
          "v": "\" Ertesi hafta sınıflarıyla kuş "
        },
        {
          "t": "kelime",
          "yuva": "pc_gozlem"
        },
        {
          "t": "metin",
          "v": " etkinliğine katılmak için öğretmenine danıştı. Ertesi gün pencerenin önüne bir kuş gözlem çizelgesi astı. Artık gökyüzüne her baktığında yalnızca Anka'yı değil, yolculuğa çıkan gerçek kuşları da düşünüyordu."
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
      "metin": "Çocuk çalıya takılmış yuvayı görünce ne yaptı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yavruları eline aldı"
        },
        {
          "id": "B",
          "metin": "Yuvaya dokunmadı, orman bekçisini çağırdı"
        },
        {
          "id": "C",
          "metin": "Yuvayı başka bir ağaca taşıdı"
        },
        {
          "id": "D",
          "metin": "Yuvayı görmezden gelip yürümeye devam etti"
        }
      ],
      "dogru": "B",
      "aciklama": "Çocuk yuvaya dokunmadı ve bekçiyi çağırdı; bekçi yuvanın güvenli biçimde korunması için gerekenleri yaptı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Bekçi ile çocuk neden kısa yolu bırakıp güvenli patikayı seçti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kısa yol çok kalabalık olduğu için"
        },
        {
          "id": "B",
          "metin": "Tüy onlara başka bir şey söylediği için"
        },
        {
          "id": "C",
          "metin": "Uzun yol daha eğlenceli olduğu için"
        },
        {
          "id": "D",
          "metin": "Kısa yoldaki levha, yaban hayatı koruma alanına girilmemesi gerektiğini gösterdiği için"
        }
      ],
      "dogru": "D",
      "aciklama": "Kısa yolun başında ziyaretçilerin girmemesi gereken bir koruma alanı levhası vardı; bekçi canlıların yaşam alanına saygı gerektiğini söyledi."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "Metinde geçen göç sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Daha uygun iklim ve besin için bir yerden başka bir yere gitme"
        },
        {
          "id": "B",
          "metin": "Yuvada uyuma"
        },
        {
          "id": "C",
          "metin": "Tüy dökme"
        },
        {
          "id": "D",
          "metin": "Ormanda saklanma"
        }
      ],
      "dogru": "A",
      "aciklama": "Bekçi, kuşların uygun iklim ve besin bulmak için yılın belli zamanlarında göç ettiğini anlattı."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 5,
      "metin": "Anka'nın \"Gerçek yardım bazen birine kanat germektir\" demesi ne anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yardım etmek için uçmayı öğrenmek gerektiğini"
        },
        {
          "id": "B",
          "metin": "Yalnızca kanatlı hayvanlara yardım edilebileceğini"
        },
        {
          "id": "C",
          "metin": "Yardımın, bir canlıyı korumak ve kollamak anlamına da gelebileceğini"
        },
        {
          "id": "D",
          "metin": "Masallardaki kuşların gerçek olduğunu"
        }
      ],
      "dogru": "C",
      "aciklama": "Metinde kanat germek, birini koruyup kollamak olarak açıklanıyor."
    },
    {
      "id": "s5",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 8,
      "metin": "Annesinin \"Bu deneyim sende hangi soruları uyandırdı?\" diye sorması neden yararlıdır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çocuğu susturduğu için"
        },
        {
          "id": "B",
          "metin": "Çocuğun merakını düşünmeye ve araştırmaya yönlendirdiği için"
        },
        {
          "id": "C",
          "metin": "Çocuğun hikâyesini yalanladığı için"
        },
        {
          "id": "D",
          "metin": "Çocuğa ödev verdiği için"
        }
      ],
      "dogru": "B",
      "aciklama": "Annesi inanıp inanmamak yerine soru sordu; çocuk da kuşların göç yollarını araştırmaya yöneldi."
    },
    {
      "id": "s6",
      "beceri": "hatirlama",
      "dayanak_sayfa": 7,
      "metin": "Gerçek dünyada kuşlar göç ederken yön bulmak için nelerden yararlanabilir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yalnızca rüzgârdan"
        },
        {
          "id": "B",
          "metin": "Yalnızca ağaçlardan"
        },
        {
          "id": "C",
          "metin": "Yalnızca insanların işaretlerinden"
        },
        {
          "id": "D",
          "metin": "Güneşten, yıldızlardan ve Dünya'nın manyetik alanından"
        }
      ],
      "dogru": "D",
      "aciklama": "Çocuk akşam defterine, kuşların güneşten, yıldızlardan ve Dünya'nın manyetik alanından yararlanabildiğini yazdı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p07$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr039-ankanin-kaybolan-tuyu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p08${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr040-trenin-penceresindeki-turkiye",
    "baslik": "Trenin Penceresindeki Türkiye",
    "tur": "gezi_kultur",
    "konu": "tren_yolculugu",
    "sinif_alt": 4,
    "sinif_ust": 4,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D14",
      "D19"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 4,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kultur_miras",
        "kesif",
        "aile"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D14",
        "yardimci_deger": "D19"
      },
      "ogrenme_hedefleri": [
        {
          "id": "yoresel_hr040",
          "tur": "lexeme",
          "etiket": "yöresel",
          "yuva": "pc_yoresel",
          "islev": "first_hint"
        },
        {
          "id": "miras_hr040",
          "tur": "lexeme",
          "etiket": "miras",
          "yuva": "pc_miras",
          "islev": "application"
        },
        {
          "id": "durak_hr040",
          "tur": "lexeme",
          "etiket": "durak",
          "yuva": "pc_durak",
          "islev": "application"
        },
        {
          "id": "kavram_hr040",
          "tur": "concept",
          "etiket": "Kültürel çeşitlilik ve harita",
          "islev": "application"
        },
        {
          "id": "atasoz_hr040",
          "tur": "proverb",
          "etiket": "Misafir kısmetiyle gelir",
          "yuva": "pc_ata_misafir",
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
        "kelime_sayisi": 496,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 9,
        "soru_sayisi": 6,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 3,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Üç şehir, üç sofra ve bir defter. Farklı yerlerin ortak yanı ne olabilir?",
    "durum": "taslak",
    "fis_kodu": "HR-040"
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
          "v": " ilk uzun tren yolculuğuna çıkacağı sabah erkenden uyandı. Annesiyle birlikte üç şehirde duracak, her durakta farklı bir aile dostunu ziyaret edeceklerdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da yolculukta not tutmaya hazırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yolculuktan önce atlasını açmış, uğrayacakları şehirleri renkli kalemlerle işaretlemişti. \"İstasyona varınca doğuya mı gitmiş olacağız?\" diye sordu. Annesi güzergâhı gösterdi. \"Her durakta haritayı yeniden inceleyelim,\" dedi."
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
          "v": " böylece pencerenin dışındaki manzarayla kâğıttaki çizgiler arasında bağlantı kurabilecekti. Aklında bir oyun da vardı: Her şehirden duyduğu yeni bir kelimeyi not edecek, sonra benzerlerini arayacaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " küçük defterinin ilk sayfasına şunu yazdı: *Aynı ülkede kaç farklı sofra kurulabilir?* "
        },
        {
          "t": "isaret",
          "kod": "kitap"
        },
        {
          "t": "metin",
          "v": " Tren hareket edince pencereden tarlalar, dereler ve küçük istasyonlar akmaya başladı. İlk "
        },
        {
          "t": "kelime",
          "yuva": "pc_durak"
        },
        {
          "t": "metin",
          "v": " Eskişehir'di."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Banu teyze onları evinde karşılayıp \""
        },
        {
          "t": "atasozu",
          "yuva": "pc_ata_misafir"
        },
        {
          "t": "metin",
          "v": "\" dedi. Sonra sofraya çibörek koydu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Bizim evdeki böreğe benziyor ama şekli farklı,\" dedi. Banu teyze, \"Yemeklerin yolu da insanların yolu gibi. Bir yerden başka yere taşınırken değişebilir,\" diye anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterine iki sütun çizdi: *Benzerlikler* ve *Farklılıklar*. İlk sütuna \"hamur ve paylaşmak\", ikinciye \"şekil ve hazırlanışı\" yazdı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de tabaktaki yemeğin adını defterine geçirdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eskişehir'den ayrılırken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " pazarda çalışan bir kadına "
        },
        {
          "t": "kelime",
          "yuva": "pc_yoresel"
        },
        {
          "t": "metin",
          "v": " bir sözcüğün anlamını sormuştu. Kadın, onun merakını görünce gülümseyerek açıklamış, sonra başka şehirlerde de farklı söyleyişler duyabileceğini anlatmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " aynı nesnenin farklı yerlerde bazen farklı adlarla anılmasına şaşırdı. \"Demek kelimeler de yolculuk ediyor,\" dedi. Annesi, \"Evet, insanlarla birlikte taşınıyor ve değişiyor,\" diye cevap verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterinde sözcüklere yeni bir sayfa ayırdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkinci gün Konya'ya vardılar. Mehmet amca onları tarihi bir sokakta gezdirdi. Taş binaları, eski kapıları ve avluları gösterdi. Öğle yemeğinde etli ekmek vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu kez yemeğin yanında anlatılan aile hikâyeleriyle de ilgilendi. Mehmet amca, \"Eskiden akşam yemekleri ailece uzun sürerdi,\" dedi. \"Herkes gününü anlatırdı.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Biz de bazen telefonu bir kenara koyup konuşuyoruz,\" diye cevap verdi. \"Demek bazı gelenekler bugün de devam ediyor.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Trenin üçüncü durağı Gaziantep'ti. Burada teyzesi Ayla, onlara renkli bir pazar gezdirdi. Baharatların kokusu birbirine karışıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tezgâhlardaki ürünlerin adlarını not etti. Bir dükkânda bakır işleyen ustayı izledi. \"Bu desenleri yapmayı kim öğretti?\" diye sordu. Usta, \"Önce babamdan öğrendim, sonra kendi desenlerimi geliştirdim,\" dedi. \"Her yeni usta eski bilgiyi başka biçimde sürdürür.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Üçüncü günün öğleden sonrasında pazarın yanındaki küçük müzeyi de görmüşlerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", camın arkasındaki eski bir bakır tabağın üstünde ustanın desenlerine benzeyen çizgiler buldu. \"Bugünküyle dünkü arasında bir bağ var,\" dedi. Ayla teyze, \"Kültürel "
        },
        {
          "t": "kelime",
          "yuva": "pc_miras"
        },
        {
          "t": "metin",
          "v": " böyle yaşar; insanlar öğrendiklerini yalnızca saklamaz, kullanır ve geliştirir,\" diye açıkladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dönüş treninde gördüğü desenlerin küçük resimlerini yan yana çizdi ve altlarına ortak yanlarını yazdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Akşam "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterini açınca sayfaların yemek adlarıyla dolduğunu gördü. Ama yalnızca yemeklerden söz etmek istemedi. Her durakta insanların onları aynı sıcaklıkla karşıladığını da yazdı. Annesi, \"Peki sorunun cevabını buldun mu?\" diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülümsedi. \"Sayamadığım kadar farklı sofra var. Ama sofralarda ortak olan bir şey de var: Misafire yer açmak.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yolculuğun son sayfasına küçük bir Türkiye haritası çizdi. Üzerine uğradıkları şehirleri işaretledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " haritanın kenarına küçük bir tren çizdi. Haritanın altına da tek bir cümle yazdı: *Farklılıkları öğrenmek, birbirimize yaklaşmanın başka bir yolu.* "
        },
        {
          "t": "isaret",
          "kod": "kalp"
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
      "metin": "Eskişehir'de Banu teyze sofraya ne koydu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Etli ekmek"
        },
        {
          "id": "B",
          "metin": "Çibörek"
        },
        {
          "id": "C",
          "metin": "Baklava"
        },
        {
          "id": "D",
          "metin": "Mantı"
        }
      ],
      "dogru": "B",
      "aciklama": "Banu teyze onları evinde karşıladı ve sofraya çibörek koydu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Pazardaki kadının başka şehirlerde de farklı söyleyişler duyulabileceğini anlatması neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sözcüklerin hiç değişmediğini"
        },
        {
          "id": "B",
          "metin": "Yalnızca Eskişehir'de farklı konuşulduğunu"
        },
        {
          "id": "C",
          "metin": "Aynı ülkede bile sözcüklerin yöreden yöreye değişebileceğini"
        },
        {
          "id": "D",
          "metin": "Kimsenin birbirini anlamadığını"
        }
      ],
      "dogru": "C",
      "aciklama": "Aynı nesne farklı yerlerde farklı adlarla anılabiliyordu; çocuk da kelimelerin insanlarla birlikte yolculuk ettiğini fark etti."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "Metinde geçen yöresel sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çok eski"
        },
        {
          "id": "B",
          "metin": "Yabancı dilden gelen"
        },
        {
          "id": "C",
          "metin": "Çok gürültülü"
        },
        {
          "id": "D",
          "metin": "Belli bir yöreye ait olan"
        }
      ],
      "dogru": "D",
      "aciklama": "Pazardaki kadın, başka şehirlerde de farklı söyleyişler olabileceğini anlattı; yani sözcük o yöreye aitti."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 7,
      "metin": "Ayla teyzenin \"Kültürel miras böyle yaşar\" demesi ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Geçmişten gelen bilgiler yalnızca saklanmaz, kullanılıp geliştirilerek sürdürülür"
        },
        {
          "id": "B",
          "metin": "Eski eşyalar müzede kalmalıdır"
        },
        {
          "id": "C",
          "metin": "Desenler hiç değişmemelidir"
        },
        {
          "id": "D",
          "metin": "Yeni şeyler öğrenmek gereksizdir"
        }
      ],
      "dogru": "A",
      "aciklama": "Müzedeki eski tabaktaki çizgilerle ustanın bugünkü desenleri arasında bağ vardı; bilgi kullanılarak ve geliştirilerek yaşıyordu."
    },
    {
      "id": "s5",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 8,
      "metin": "Çocuğun \"Farklılıkları öğrenmek, birbirimize yaklaşmanın başka bir yolu\" sonucuna varması neden yerindedir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü her yerde yemekler aynıdır"
        },
        {
          "id": "B",
          "metin": "Çünkü her durakta farklılıklar görse de insanların onu aynı sıcaklıkla karşıladığını fark etmiştir"
        },
        {
          "id": "C",
          "metin": "Çünkü yolculuk çok kısa sürmüştür"
        },
        {
          "id": "D",
          "metin": "Çünkü hiç soru sormamıştır"
        }
      ],
      "dogru": "B",
      "aciklama": "Çocuk, farklı sofralar ve gelenekler gördü; ama her yerde misafire yer açıldığını ve sıcak karşılandığını fark etti."
    },
    {
      "id": "s6",
      "beceri": "hatirlama",
      "dayanak_sayfa": 6,
      "metin": "Gaziantep'teki bakır ustası desenleri yapmayı kimden öğrendi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir kitaptan"
        },
        {
          "id": "B",
          "metin": "Müzedeki bir görevliden"
        },
        {
          "id": "C",
          "metin": "Babasından"
        },
        {
          "id": "D",
          "metin": "Okulundaki öğretmeninden"
        }
      ],
      "dogru": "C",
      "aciklama": "Usta, desenleri önce babasından öğrendiğini, sonra kendi desenlerini geliştirdiğini söyledi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p08$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr040-trenin-penceresindeki-turkiye: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p09${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr041-yedi-adimda-kayip-ada",
    "baslik": "Yedi Adımda Kayıp Ada",
    "tur": "macera",
    "konu": "kayip_ada_kiyi_haritasi",
    "sinif_alt": 6,
    "sinif_ust": 6,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D5",
      "D16"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 6,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "doga",
        "kesif",
        "hayvanlar"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D5",
        "yardimci_deger": "D16"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_varsayim_hr041",
          "tur": "lexeme",
          "etiket": "varsayım",
          "yuva": "pd_varsayim",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_olcek_hr041",
          "tur": "lexeme",
          "etiket": "ölçek",
          "yuva": "pd_olcek",
          "islev": "application"
        },
        {
          "id": "sozcuk_lagun_hr041",
          "tur": "lexeme",
          "etiket": "lagün",
          "yuva": "pd_lagun",
          "islev": "application"
        },
        {
          "id": "kavram_hr041",
          "tur": "concept",
          "etiket": "Varsayım ile kanıtı ayırmak; kıyının zamanla değiştiğini ve korunan alanlara saygı gösterilmesi gerektiğini anlamak",
          "islev": "application"
        },
        {
          "id": "atasoz_hr041",
          "tur": "proverb",
          "etiket": "Acele işe şeytan karışır",
          "yuva": "pd_ata_acele",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 3073,
        "tahmini_sure_dk": 27,
        "sayfa_sayisi": 9,
        "soru_sayisi": 8,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 2,
          "yorumlama": 1,
          "sozcuk_baglami": 2,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 24,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Eski haritada bir ada var ama kıyı değişmiş. Hazine mi, yoksa başka bir sır mı?",
    "durum": "taslak",
    "fis_kodu": "HR-041"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Altıncı sınıfların doğa kampı, Karadeniz kıyısındaki Çamlıburun Araştırma Merkezi'nde yapılıyordu. Kamp merkezine vardıklarında girişte bir fotoğraf sergisi açılmıştı. Bir fotoğrafta deniz, neredeyse kıyıdaki taşa kadar uzanıyor; başka birinde aynı taş geniş bir kumluğun ortasında kalıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " fotoğraflara dikkatle bakmadan yürüdü. Selin ise her birinin altında yazan tarihi defterine geçirdi. O an ikisi de bu fotoğrafların sonraki günlerde ne kadar işe yarayacağını bilmiyordu. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        },
        {
          "t": "metin",
          "v": "\n\nKampın ilk akşamı, rehberleri Suna Hanım çocuklara bir harita gösterdi. Haritada patikalar, gözlem noktaları, dere yatakları ve koruma sınırları vardı. Ancak haritanın bir köşesi öyle çok silinmişti ki koyun ortasındaki küçük kara parçası bir ada gibi görünüyordu.\n\n“Burası Kayıp Ada mı?” diye sordu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Kamp başlamadan önce internette gördüğü bir paylaşımda, bölgedeki kayıp adaya ait olduğu söylenen eski bir hazine haritası vardı. Suna Hanım gülümsedi.\n\n“Haritalar bazen yanlış sorular sormamıza neden olur. Bu gördüğünüz çizimde suyun nerede başladığını bile kesin bilmiyoruz. Önce güvenilir bilgiyi bulmalıyız.”\n\nSınıfın gözlem ekibinde dört arkadaş vardı: haritalara meraklı Selin, sabırsız ama cesur "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", kuşların seslerini ayırt eden "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ve gördüklerini deftere geçirmeyi seven Asya. Birlikte çalışacaklardı. Her grubun görevi, merkezdeki eski haritayı güncel haritayla karşılaştırmak ve gözlem izinleri verilen noktalara ilişkin bir rapor hazırlamaktı.\n\nSelin, eski haritanın altındaki notu fark etti: “Yedi adım, tek yol; suyun anlattığına kulak ver.” Bir köşede çok küçük bir tarih yazıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Kesin hazine!” diye fısıldadı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise tarihe bakıp “Bu harita kırk yıl önce çizilmiş. Kıyı aynı kalmış olabilir mi?” dedi.\n\nSuna Hanım onlara cevap vermek yerine yeni bir soru sordu: “Bir haritanın yaşı neden önemlidir?”\n\nÇocuklar denizlerin, rüzgârın ve akarsuların kıyıları zamanla değiştirebildiğini hatırladılar. Gruptaki herkes farklı bir "
        },
        {
          "t": "kelime",
          "yuva": "pd_varsayim"
        },
        {
          "t": "metin",
          "v": " ortaya attı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eski bir geçit bulunacağını, Asya unutulmuş bir iskele kalıntısı görüleceğini, Selin ada diye çizilen yerin belki de sazlık olduğunu düşündü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise kuşların oraya neden toplandığını öğrenmek istiyordu.\n\nKamptaki ilk görev aslında eski bir fotoğrafla başlamıştı. Fotoğrafta aynı tepe, aynı gökyüzü ve birbirinden farklı iki su çizgisi vardı. Selin ikisinin aynı yer olduğunu söylemiş, "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " buna inanmamıştı. Suna Hanım iki görüntünün çekildiği yılları okuduğunda "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " ağzı açık kaldı. “Bir yer nasıl böyle değişebilir?” diye sordu. Rehber, akarsuların taşıdığı malzemeden ve dalgaların kıyıda yaptığı değişikliklerden söz etti. Asya bu açıklamayı defterine not etti ama öğretmeni ona önemli bir ayrımı hatırlattı: “Bu genel bilgi. Bizim burada tam olarak ne olduğunu anlamak için gözlem yapmalıyız.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " o andan sonra eski fotoğraftaki kara parçasını yalnızca bir gizem olarak değil, cevap bekleyen bir araştırma sorusu olarak görmeye başladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Akşam çadırlarına dönmeden önce rapor defterlerinin ilk sayfasına bir kural yazdılar: “Varsayım kanıt değildir.” Altına ikinci bir kural eklediler: “İzinli güzergâhın dışına çıkılmayacak.” Böylece maceranın ilk adımı, bir gizem kadar bir sorumluluk da taşıyordu.\n\nErtesi sabah Suna Hanım, ekipleri gözlem alanına götürdü. Önce herkes haritanın yönünü pusulaya göre ayarladı. Selin kâğıdı o kadar dikkatli çevirdi ki kuzey oku gerçek yönü gösterdiğinde bir an durup gülümsedi. Daha önce yönleri yalnızca ders kitabında çizilmiş oklar olarak görmüştü; şimdi rüzgârın yönü, denizin konumu ve tepenin gölgesiyle ilişkilendiriyordu.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Kâğıttan bakınca patika çok kısa,” dedi. “Şuradan yürürsek beş dakikada ulaşırız.”\n\nSuna Hanım onu durdurdu. Haritanın altındaki "
        },
        {
          "t": "kelime",
          "yuva": "pd_olcek"
        },
        {
          "t": "metin",
          "v": " çizgisini gösterdi. Kâğıttaki bir santimetre, arazide çok daha uzun bir mesafeye karşılık geliyordu. Çocuklar önce cetvelle ölçtüler, ardından izinli yürüyüş yolunun ne kadar sürdüğünü tahmin ettiler. "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " önerdiği kestirme ise sulak alanın sınırından geçiyordu.\n\n“Kestirme orası olsa bile kullanamayız,” dedi Asya. “Hem kuşların yuvalama alanı hem de geçiş yasak.”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kaşlarını kaldırdı. “Ben sadece daha çabuk varmak istemiştim.”\n\n“Hızlı gitmek, doğru gitmek demek değil,” diye karşılık verdi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". Bu söz "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " aklında kaldı. Suna Hanım eski bir atasözünü hatırlattı: “"
        },
        {
          "t": "atasozu",
          "yuva": "pd_ata_acele"
        },
        {
          "t": "metin",
          "v": ".”\n\nYol ayrımındaki levha yeni boyanmıştı. Ancak hemen arkasındaki eski taşın üzerinde silinmiş kırmızı bir işaret görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bunun haritadaki simgelerden biri olduğunu düşündü. Suna Hanım, işaretin geçmişte kullanılmış yürüyüş rotasına ait olabileceğini söyledi. Öğrenciler levhanın fotoğrafını çektiler ve yeni rotayla eski işareti karşılaştırdılar. Selin defterine “Bir işaretin anlamı zamanla değişebilir” yazdı. Asya aynı sözün yalnızca haritalar için değil, günlük hayatta duydukları bazı sözcükler için de geçerli olabileceğini fark etti. Örneğin “ada” kelimesi, çevresi tamamen suyla kuşatılan yeri anlatıyordu; eski haritadaki şeklin bu tanıma hâlâ uyup uymadığı bilinmiyordu.\n\nPatikada ilerlerken taşların arasında beyaz, yassı kabuklar gördüler. Suna Hanım bunların bazılarını toplayıp incelemelerine izin vermedi; koruma alanında canlı veya cansız doğal malzemelerin yerinde bırakılması gerektiğini açıkladı. Bunun yerine çocuklar fotoğraf çekti, konum işaretledi ve çizim yaptı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Haritadaki birinci işaret, eski bir ahşap gözlem platformuydu. Gözlem kulesinin tahtaları yenilenmiş, yanına bilgilendirici levhalar konmuştu. Levhada kıyıya vuran kumun yıl içinde yer değiştirebildiği anlatılıyordu. Selin, haritanın kenarına bir not düştü: “Kıyı çizgisi sabit değildir.”\n\nİkinci işaret küçük bir tatlı su gözlem kuyusuydu. Kuyuya dokunmadılar; rehberleri, ölçüm cihazıyla tuzluluk ve su seviyesi hakkında bilgi verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " birden anladı: “Belki haritadaki çizgi denizin değil, suyun değiştiği bir yerin işareti.”\n\nSuna Hanım, “Bunu söylemek için artık bir gerekçen var,” dedi. “Ama tek kanıtla karar vermeyelim.”\n\nÖğleden sonra rüzgâr hafifledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kayıt cihazını çıkarıp ötüşleri dinledi. Sabah duydukları martı seslerinin arasında ince bir ötüş vardı. Rehber, bu kuş türünün göç sırasında sulak alanlarda mola verdiğini anlattı. Öğrenciler, sazlıkların yalnızca su ve bitkiden oluşmadığını; göç eden canlılar için beslenme ve dinlenme alanı da olabileceğini öğrendi.\n\nFakat eski haritada adanın bulunduğu yerde tuhaf bir sessizlik vardı. Kuş sesleri uzaktan geliyordu; sazlıkların yakınında ise iri, paslı bir levha duruyordu. Levhada yıllar önce kapanmış bir tekne iskelesinin adı yazıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " heyecanlandı.\n\n“İşte! Kayıp Ada'nın iskelesi!”\n\nAsya hemen fotoğraf çekti. “Levha eskiden burada bir iskele olduğunu gösteriyor,” dedi. “Ama adaya çıkılabildiğini değil.”\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", kıyıda birkaç eski halat parçası ve kırık tahta olduğunu fark etti. Onların arasından geçmedi; görevliye gösterdi. Suna Hanım, atıkların uzman ekip tarafından güvenli biçimde kaldırılması gerektiğini söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “O zaman gizem bir hazine değil, temizlenmesi gereken bir yer olabilir,” dedi.\n\nGözlem platformunda öğle yemeği molası verdiler. Selin defterine üç sütun çizdi: “Gördüklerimiz, düşündüklerimiz, hâlâ bilmediklerimiz.” Gördüklerine eski iskele levhasını, ölçüm kuyusunu ve değişen kıyı çizgisini yazdı. Düşündüklerine ise “Ada sanılan yer eski bir kum seti olabilir” notunu ekledi. Son sütunda üç soru vardı: Bu kum seti şimdi neredeydi? Kuşlar neden burada dinleniyordu? Haritada neden yedi işaret bulunuyordu?\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " son soruya takıldı. “Yedinci işaret bir sandığı gösteriyor olabilir.”\n\nAsya gözlerini devirdi. “Her şeyi sandığa bağlama.”\n\n“Belki sandık kuşlara yem doludur,” diye şaka yaptı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". Dördü birden güldü. Sonra "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ciddi bir sesle ekledi: “Ama yedi adımın her biri başka bir gözlem noktasını gösteriyorsa, hepsini bir araya getirmeden sonuca ulaşamayız.”"
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
          "v": ", platformdan duydukları ince ötüşün kaydını sınıfın kuş gözlem panosunda dinletti. Bir öğrenci bunun serçe sesi olduğunu düşündü. Başka biri göçmen bir kıyı kuşunun sesi olabileceğini söyledi. Suna Hanım kesin bir tür adı vermedi; güvenilir ses kayıtlarıyla karşılaştırmadan emin olamayacaklarını açıkladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " biraz şaşırdı. Teknolojinin her soruya anında cevap vermesine alışmıştı. Fakat bu kez cihaz yalnızca ses topluyordu; yorum yapmak kendilerine düşüyordu. Asya bunu raporun kenarına ekledi: “Kayıt, gözlemin bir parçasıdır. Doğru yorum için başka kaynaklar da gerekir.”\n\nGünün sonunda çocuklar kamp merkezine döndü. Akşamki paylaşım toplantısında başka ekiplerin bulgularını da dinlediler. Bir grubun fotoğrafında eski haritadakine benzer bir kıyı şekli görülüyordu; bir diğeri kumulların rüzgârla hareket ettiğini anlatmıştı. Selin bu bilgileri kendi haritalarına ekledi.\n\nGece boyunca çadırların üzerinde yağmur sesi duyulmuştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sabah uyandığında kıyının sis içinde kaybolduğunu gördü. İlk anda yağmuru maceraya engel saydı. Ardından çadırın hemen dışındaki yağmur ölçer dikkatini çekti. Öğretmenleri ölçüm miktarını deftere yazıyor ve bir önceki günle karşılaştırıyordu. Selin, “Demek yürüyüş yapamasak da veri toplayabiliyoruz,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gönülsüzce defterini açtı. Hava durumu tahminiyle gerçekleşen hava olayının her zaman birebir aynı olmayabileceğini de not etti. Böylece iptal edilen gezi, başka bir gözlem çalışmasına dönüşmüş oldu.\n\nKampın ikinci günü hava kapalıydı. Rehber, rüzgârın hızlanabileceği uyarısıyla açık kıyı yürüyüşünü iptal etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hayal kırıklığını saklayamadı. “Tam sonuca yaklaşmıştık.”\n\nSuna Hanım, “Araştırma bazen durmayı da gerektirir,” dedi. “Bugün arşive bakacağız.”\n\nMerkezin küçük kütüphanesinde yıllara göre hazırlanmış haritalar, eski hava fotoğrafları ve kıyı raporları vardı. Asya, kırk yıl önce çekilmiş bir fotoğrafı buldu. Fotoğraftaki ada, aslında denizden ayrı duran küçük bir kara parçası gibi görünüyordu. Ancak altındaki açıklama, kış aylarında suların yükseldiğini; yazın bazı yerlerde kum setlerinin belirginleştiğini söylüyordu.\n\n“Demek ada bazen görünüyormuş,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ".\n\nSelin dikkatle baktı. “Görünür olmak başka, sürekli ada olmak başka.”\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " daha yeni bir fotoğraf getirdi. Eski iskele artık kullanılmıyordu. Koruma sınırları da değişmişti. Bir zamanlar deniz kenarında ziyaretçi kabul eden bölüm, bugün göçmen kuşların hassas alanı sayılıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "O an "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " yüzü düştü. “Hazine arama oyunu yerine dosya okuyoruz.”\n\nAsya ona eski defterdeki sözlerini hatırlattı: “Varsayım kanıt değildir. Sen bizi maceraya çağırdın ama asıl macera gerçeği öğrenmek olabilir.”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce itiraz edecekti. Sonra fotoğrafların farklı yıllarda çekildiğini fark etti. Aynı yeri karşılaştırmadan bir şey söylemek gerçekten zordu. “Peki,” dedi. “Hazineyi bir süreliğine unutuyorum.”\n\nÖğretmenler harita üzerinde dört yeni nokta işaretledi. Bunlar eski kumul çizgisi, yeni sazlık sınırı, ölçüm istasyonu ve mevcut gözlem platformuydu. Böylece toplam yedi durak tamamlandı. Suna Hanım, adaların ve kıyı şekillerinin değişimini anlamak için bu noktaların birlikte incelenmesi gerektiğini açıkladı.\n\nAkşam "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterine uzun bir cümle yazdı: “Bir ipucunu sevmek, onun doğru olduğunu kanıtlamaz.” Altına da küçük bir sandık resmi çizdi; üstünü çizmedi. “Hayal kurmak da önemli,” dedi. “Sadece hayalle gerçeği karıştırmamak lazım.”\n\nGecenin ilerleyen saatlerinde "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", dışarıdan gelen rüzgâr sesine uyandı. “Kıyı orada duruyor, biz burada uyuyoruz,” diye düşündü. Sandığı bir gün bulabileceğine ilişkin hayalinden vazgeçmek istemiyordu. Çadırın küçük penceresinden görünen yıldızlara baktı ve ilk defa bir maceranın sonunda hiçbir şey almadan dönmenin de değerli olabileceğini düşündü. Ertesi sabah kahvaltıda düşüncesini arkadaşlarıyla paylaştı. Selin, “Bilgi almak, eşya almak gibi değil,” dedi. “Bir yeri öğrenince onu bitirmiyoruz.” Asya ise kendilerine gösterilen eski fotoğrafları hatırlattı. “Daha önce gözlem yapanlar olmasa bugün neler değiştiğini anlayamazdık. Belki bizim kayıtlarımız da yıllar sonra işe yarar.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kahvaltısını bitirirken sandık aramak kadar kayıt tutmanın da heyecanlı olabileceğine şaşırdı. Bu düşünce, biraz sonra görecekleri manzarayı daha dikkatli incelemesini sağlayacaktı.\n\nO sabah "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " aklında yeni bir soru vardı: “Koruma alanına kim karar veriyor?” Suna Hanım, bu tür kararların ilgili kurumlarca bilimsel çalışmalar ve mevzuat çerçevesinde alındığını anlattı. Çocuklar bir bölgenin herkese açık olmamasının, kimsenin onu sevmediği anlamına gelmediğini düşündü. Bazen bir alanı ziyaret etmekten vazgeçmek onu korumanın parçasıydı. Selin, “Bize yasak olan yer, kuşların evi olabilir,” dedi. Bu cümle "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " sandık hayalini biraz geriye itti. Çünkü bir evin kapısını, sahibine sormadan açmayı doğru bulmuyordu.\n\nÜçüncü gün hava açınca izinli gezi yeniden başladı. Grup, görevliler eşliğinde son gözlem platformuna yürüdü. Platformdan açık deniz, kumullar ve dar bir "
        },
        {
          "t": "kelime",
          "yuva": "pd_lagun"
        },
        {
          "t": "metin",
          "v": " görülüyordu. Selin haritayı açıp yedi noktayı teker teker işaretledi. Çizgileri birleştirince tuhaf bir şekil çıktı: Eski haritadaki 'adanın' çevresini çiziyorlardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Yani gizli yol bir yere gitmiyor,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Bir sınırı gösteriyor.”\n\nSuna Hanım başını salladı. “Bu, çok önemli bir çıkarım. Ama hangi sınır?”\n\nÇocuklar, güncel koruma haritasıyla kendi çizimlerini yan yana koydu. Sınırlar tam olarak aynı değildi. Eski haritanın çizgisi bir zamanlar suyla çevrili olan kum setini, yeni haritanın çizgisi ise bugün korunması gereken sazlık ve lagünü gösteriyordu. Aynı alan, iki farklı zamanda iki farklı görünüm kazanmıştı.\n\nAsya, sahada sessiz durma işaretini gösterdi. İnsan seslerinin kuşları rahatsız edebileceğini ve gözlemi zorlaştırabileceğini öğrenmişlerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce sabırsızlandı; arkadaşlarına gördüğü her şeyi yüksek sesle anlatmak istiyordu. Sonra yalnızca defterine küçük bir çizim yaptı. Bir kuşun sığ suda yürüyerek beslendiğini, bir diğerinin ise daha uzak bir taşın üzerinde dinlendiğini gördü. Aynı alanı kullanan canlıların ihtiyaçlarının farklı olabileceğini anladı. Bu sessiz bekleyiş, birkaç dakika öncesine kadar boşa harcanan zaman gibi gelmişti. Şimdi gözlemin kendisi yolculuğun en heyecanlı bölümüne dönüşüyordu.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gözlerini kısıp dürbünle baktı. Kıyıda bir grup kuş vardı. İki tanesi suya dalıyor, diğerleri birbirini takip ederek kumsalda yürüyordu. “Ben burayı bulup üzerine çıkabileceğimizi sanmıştım,” dedi. “Oysa önemli olan uzaktan görüp korumakmış.”\n\nTam o sırada "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kayıt cihazında sabahki ince ötüşü duydu. Kuşların dinlendiği yerin yakınında küçük bir plastik atık birikintisi de görünüyordu. Asya dürbünle bakıp yerini haritaya işaretledi. Yetişkin görevlilerden biri, atıkların temizlenmesi için koruma ekibine bildirim yapılacağını söyledi.\n\n“Kayıp Ada'nın hazinesi kuşlar mı?” diye sordu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ".\n\nSelin, “Kuşlar, su, bitkiler ve hepsinin yaşadığı yer,” diye cevap verdi.\n\nÖğretmenleri çocukların yanına gelip notlarını inceledi. “Bugün çok iyi bir şey yaptınız,” dedi. “Bir yerin değerini yalnızca orada ne bulabileceğinize göre değil, orada nelerin yaşadığına göre değerlendirdiniz.”\n\nAsya son fotoğrafı çekti. Bu kez kadrajda hazine sandığı yoktu. Bir yanda su, öbür yanda sazlık, ortada güneş ışığında dinlenen kuşlar vardı. Fotoğrafın altına şu açıklamayı yazdı: “Kayıp Ada değil, korunması gereken yaşayan kıyı.”\n\nPlatformdan dönerken yürüyüş grubuna yakın bir okulun öğrencileri rastladı. Onlardan biri koruma alanını neden göremediklerini sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hemen “Çünkü orada kuşlar yaşıyor,” dedi. Ardından açıklamasının eksik olduğunu fark etti. Bir alanın bazı bölümleri gözleme açık, bazıları ise hassas dönemlerde kapalı olabilirdi. Suna Hanım, ziyaret kurallarının resmî levhalardan öğrenilmesi gerektiğini gösterdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", günün başında aceleyle kullandığı cümleyi düzeltti: “Bazı bölgelere izin verilmiyor. Orada kuşlar besleniyor ve dinleniyor. Biz buradan gözlem yapabiliyoruz.” Çocuklar neden-sonuç ilişkisini anlatırken dikkatli olmanın önemini konuştu. Selin daha sonra rapora yalnızca yasakları değil, izinli ziyaret seçeneklerini de yazdı. Çünkü insanlara bir yeri korumayı anlatmak, doğayla bağlarını tümüyle kesmek anlamına gelmiyordu. Doğru bilgiyle ve doğru mesafeden tanımak mümkündü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kampa döndüklerinde işlerinin bittiğini sandılar. Ancak Suna Hanım, “Gözlem yaptınız, şimdi bilgiyi başkalarının anlayacağı hâle getirin,” dedi. Her ekip kendi bulgularını sunacaktı. Selin haritaları büyüttü; "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kuş seslerinden kısa bir kayıt hazırladı; Asya fotoğrafları sıraya koydu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise sunumun girişini yazmayı üstlendi.\n\nHazırlık sırasında küçük bir anlaşmazlık çıktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sunumun en heyecanlı kısmını anlatmak istiyor, Selin ise yanlış anlaşılmaktan çekiniyordu. “Başlığa hazine dersek herkes gelir,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Selin, “Gelirler ama yanlış bir şey beklerler,” diye cevap verdi. Asya iki farklı başlık yazıp gruba gösterdi. Birincisi abartılıydı, ikincisi yalnızca “Kıyı Raporu” diyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " üçüncü bir seçenek önerdi: “Gerçek soru, kayıp adanın nerede olduğuydu. Cevabın da merak uyandırmasını sağlayabiliriz.” Böylece dinleyiciyi kandırmadan ilgi çekmenin mümkün olduğunu gördüler. Herkes kendi fikrinden bir parça vazgeçti ve ortaya daha iyi bir metin çıktı.\n\nİlk taslağı şöyleydi: “Kırk yıllık hazine bilmecesini çözdük!” Asya başını iki yana salladı.\n\n“Gerçekte olmayan bir hazineyi çözdüğümüzü söyleyemeyiz.”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kalemi bıraktı. “Ama kimse sıkıcı bir rapor dinlemek istemez.”\n\nSelin yeni bir başlık önerdi: “Haritada Kaybolan Ada Gerçekte Nereye Gitti?”\n\n“Bu hem merak uyandırıyor hem de yanlış bir iddia kurmuyor,” dedi.\n\nSunum günü, sınıflar merkezin küçük salonunda toplandı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce eski haritayı gösterdi, sonra aynı yerin yeni fotoğrafını açtı. İzleyiciler farkı hemen göremedi. O da bir sonraki ekranda kumulun değişen şeklini renkli çizgilerle işaretledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kaydedilen kuş seslerini dinletti. Asya atıkların yerini ve görevlilere yapılan bildirimi anlattı.\n\nSorular başladığında bir öğrenci, “Madem ada yok, eski haritayı çöpe atmak gerekmez mi?” diye sordu.\n\nSelin, “Hayır,” diye cevap verdi. “Eski harita bize geçmişteki durumu gösteriyor. Yanlış bilgi vermiyor; yalnızca başka bir zamanın bilgisini veriyor.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Suna Hanım öğrencilerin bu ayrımı fark etmesinden memnun oldu. Sonra gruba bir teklif sundu: Çalışmalarını merkezin ziyaretçi panosunda sergileyebilirlerdi. Ancak önce koruma görevlilerinin bilimsel bilgileri kontrol etmesi gerekiyordu. Çocuklar kabul etti.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", raporu tamamlamakla ünlü bir hazine bulmuş gibi hissetmedi. Daha güzel bir şey hissetti: Söylediklerinin başkaları için yararlı olabileceğini düşündü. Kendi fikirlerinin kontrol edilmesine de kızmıyordu. Çünkü doğruluğun alkıştan daha değerli olduğunu öğrenmişti.\n\nRapor panoya asılmadan önce koruma görevlisi küçük bir düzeltme yapmıştı. Çocuklar kuşların beslenme alanını yalnızca “yuva” olarak adlandırmışlardı. Görevli, her göçmen kuşun o bölgede yuva yapmayabileceğini, bazılarının yalnızca dinlenip beslenmek için geldiğini anlattı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " başta yaptığı hataya üzüldü. Sonra bu ayrımın neden önemli olduğunu düşündü: Yanlış bir kelime, doğru bir gözlemi bile yanlış anlaşılır hâle getirebilirdi. Selin rapordaki ifadeyi değiştirdi, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ses kaydının yanına gözlemin tarihini yazdı. Asya da çektiği kuş fotoğrafının altına kesin tanımlayamadıkları tür adı koymadı. Hep birlikte daha az iddialı ama daha güvenilir bir sergi hazırlamışlardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Bunu görmek için yedi adımdan fazlası gerekiyormuş,” diye şaka yaptı.\n\nVeda toplantısında her öğrenci kampın ona öğrettiği tek şeyi söyleyecekti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Doğanın sesini kaydetmek, onu gerçekten dinlemekle aynı şey değil,” dedi. Asya, “Fotoğrafın tarihi, fotoğraf kadar önemli,” diye ekledi. Selin, “Haritada küçük bir çizgi büyük bir fark gösterebilir,” dedi. Sıra "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " gelince hiç beklenmeyen bir cevap verdi: “Yanlış çıkmak sandığım kadar kötü değil. Çünkü yanlış olduğumu anladığımda yeni bir şey öğreniyorum.” Suna Hanım bu cümleyi duyunca gülümsedi. Çocukların ezberledikleri bilgiden çok, düşünme biçimlerinin değişmesi onu sevindirmişti.\n\nSon sabah çocuklar eşyalarını toplarken "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir kuş tüyü gördü. Onu alıp hatıra olarak saklamak istedi. Sonra kampın ilk kuralını hatırladı: Doğadaki nesneler mümkün olduğunca yerinde kalmalıydı. Tüyün fotoğrafını çekti, olduğu yerde bıraktı.\n\nOtobüsün penceresinden son kez kıyıya bakarken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", kumullardan oluşmuş şekillerin ertesi yıl yine değişebileceğini düşündü. Belki başka bir sınıf kendi çizdikleri haritayı inceleyecek ve onların soramadığı bir soruyu soracaktı. Asya raporun bir kopyasını kamp merkezine bıraktıklarını hatırlattı. “Yaptığımız işin devamını başkaları getirebilir,” dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", kuşların göç sırasında aynı yere dönüp dönmediğini merak ediyordu. Suna Hanım, bazı türlerin belirli durakları tekrar kullanabildiğini ama bunun türlere ve koşullara göre değiştiğini anlattı. Selin, “O zaman gelecek yılların gözlemleriyle bizim notlarımızı karşılaştırmak ilginç olur,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu fikri daha önce bulmayı hayal ettiği sandıktan çok sevdi. Çünkü sandık bir kez açılırdı; sorular ise yeni gözlemlerle büyürdü."
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
          "v": ", “Ben olsam başta cebime koyardım,” dedi.\n\n“Ben de,” diye güldü "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Ama fotoğraf da hatıra olur.”\n\nOtobüse binmeden önce dört arkadaş, eski haritanın kopyasına son kez baktı. Selin yedi gözlem noktasını numaralandırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk gün yazdığı hazine tahmininin yanına bir not ekledi: “En değerli şeyi almak değil, ona zarar vermeden tanımak.” Asya, bu cümlenin raporun sonunda kullanılmasını önerdi.\n\nOtobüs yola çıktığında kamp geride kaldı. Kıyı boyunca uzanan sazlıklar küçüldü. Bir süre kimse konuşmadı. Sonra "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Yine de bir gün gerçek bir hazine haritası bulsak fena olmaz,” dedi.\n\nSelin güldü. “Önce haritanın tarihini kontrol ederiz.”\n\n“Ölçeğini de,” diye ekledi Asya.\n\n“Güzergâh izinlerini de,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ".\n\nKamp defterini çantasına yerleştirirken ilk sayfadaki aceleyle çizdiği sandığı gördü. Yanındaki son sayfada ise kuş sesleri, kıyı haritası ve kaynak listesi vardı. Defterin nasıl değiştiğine şaşırdı.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ellerini kaldırdı. “Tamam, tamam! Artık hazine avcılığı daha zor işmiş.”\n\nOkula döndüklerinde öğretmenleri raporu sınıf panosuna astı. Kayan kıyılar, göçmen kuşlar ve koruma sınırları hakkında başka öğrenciler de sorular sormaya başladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", haritadaki yedi adımın aslında tek bir yere gitmediğini düşündü. Her adım, onu biraz daha dikkatli bir araştırmacıya dönüştürmüştü.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " son kez eski kıyı fotoğrafına baktı. Artık kumun değişimini de koruma alanının değerini de görebiliyordu.\n\nOtobüsün arka koltuğunda "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kayıt cihazını açıp ilk günün seslerini yeniden dinledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu kayıtların kampın başlangıcındaki hâllerini de hatırlattığını fark etti: O sırada herkes aynı kelimelere farklı anlamlar yüklüyordu. Ada dedikleri yer, son gün artık yalnızca bir kara parçası değildi. Bu yolculukta hiçbir sır bir anda çözülmemiş, her küçük gözlem onları başka bir soruya götürmüştü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterine eklediği kaynakları da düşündü. Artık bir bilgiyi duyduğunda kimin söylediğini ve nereden öğrenildiğini sormayı unutmayacaktı.\n\nDefterinin son sayfasına yeni bir başlık yazdı: “Sekizinci Adım: Öğrendiklerimi Paylaşmak.” Altını çizdi. Çünkü bir keşif, yalnızca bulununca değil, doğru anlatılınca da büyüyordu. "
        },
        {
          "t": "isaret",
          "kod": "kus"
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
      "metin": "Çocuklar, bir arkadaşlarının önerdiği kestirme yolu neden kullanmadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kestirme yol, haritada hiç gösterilmemişti"
        },
        {
          "id": "B",
          "metin": "Kestirme yol sulak alanın sınırından geçiyordu ve orası kuşların yuvalama alanı olduğu için geçiş yasaktı"
        },
        {
          "id": "C",
          "metin": "Kestirme yol kâğıttaki ölçekten çok daha uzundu"
        },
        {
          "id": "D",
          "metin": "O gün hava çok kapalıydı"
        }
      ],
      "dogru": "B",
      "aciklama": "Asya, sulak alanın hem kuşların yuvalama alanı olduğunu hem de geçişe yasak olduğunu söyledi."
    },
    {
      "id": "s2",
      "beceri": "hatirlama",
      "dayanak_sayfa": 4,
      "metin": "Kampın ikinci günü açık kıyı yürüyüşü neden iptal edildi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kamptaki çocukların çoğu hastalanmıştı"
        },
        {
          "id": "B",
          "metin": "Kuşlar o gün göç etmişti"
        },
        {
          "id": "C",
          "metin": "Rehber, rüzgârın hızlanabileceği uyarısı nedeniyle yürüyüşü iptal etti"
        },
        {
          "id": "D",
          "metin": "Harita kaybolmuştu"
        }
      ],
      "dogru": "C",
      "aciklama": "Hava kapalıydı ve rehber rüzgârın hızlanabileceği uyarısıyla açık kıyı yürüyüşünü iptal etti."
    },
    {
      "id": "s3",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Selin “Görünür olmak başka, sürekli ada olmak başka” derken ne anlatmak istedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kum seti bazı mevsimlerde görünse de oranın her zaman suyla çevrili bir ada olduğu söylenemez"
        },
        {
          "id": "B",
          "metin": "Eski fotoğraftaki ada gerçekte hiç var olmamıştır"
        },
        {
          "id": "C",
          "metin": "Adalar yalnızca kışın oluşur"
        },
        {
          "id": "D",
          "metin": "Haritalarda adalar hep yanlış çizilir"
        }
      ],
      "dogru": "A",
      "aciklama": "Arşivdeki açıklamaya göre kış aylarında sular yükseliyor, yazın kum setleri belirginleşiyordu; yani ada her zaman görünmüyordu."
    },
    {
      "id": "s4",
      "beceri": "cikarim",
      "dayanak_sayfa": 5,
      "metin": "Çocuklar yedi noktayı haritada birleştirince ne ortaya çıktı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir hazine sandığının yeri"
        },
        {
          "id": "B",
          "metin": "Yeni bir yürüyüş rotası"
        },
        {
          "id": "C",
          "metin": "Kuşların göç yolu"
        },
        {
          "id": "D",
          "metin": "Eski haritadaki adanın çevresini gösteren bir sınır"
        }
      ],
      "dogru": "D",
      "aciklama": "Çizgiler eski haritadaki adanın çevresini çiziyordu; gruptan biri de gizli yolun bir yere değil, bir sınıra gittiğini söyledi."
    },
    {
      "id": "s5",
      "beceri": "yorumlama",
      "dayanak_sayfa": 7,
      "metin": "Selin, eski haritanın çöpe atılması gerekmediğini neden söyledi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü eski harita çok değerli bir eşyaydı"
        },
        {
          "id": "B",
          "metin": "Çünkü eski harita yanlış değil, geçmişteki başka bir zamanın bilgisini veriyordu"
        },
        {
          "id": "C",
          "metin": "Çünkü yeni harita henüz hazır değildi"
        },
        {
          "id": "D",
          "metin": "Çünkü eski harita hâlâ doğru adayı gösteriyordu"
        }
      ],
      "dogru": "B",
      "aciklama": "Selin, eski haritanın yanlış bilgi vermediğini, yalnızca başka bir zamanın bilgisini verdiğini söyledi."
    },
    {
      "id": "s6",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "Metne göre haritadaki ölçek ne işe yarar?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kâğıttaki uzunluğun arazide ne kadar bir mesafeye karşılık geldiğini gösterir"
        },
        {
          "id": "B",
          "metin": "Kuzeyin hangi yönde olduğunu gösterir"
        },
        {
          "id": "C",
          "metin": "Haritanın ne zaman çizildiğini gösterir"
        },
        {
          "id": "D",
          "metin": "Korunan alanın sınırlarını gösterir"
        }
      ],
      "dogru": "A",
      "aciklama": "Suna Hanım ölçek çizgisini göstererek kâğıttaki bir santimetrenin arazide çok daha uzun bir mesafeye karşılık geldiğini anlattı."
    },
    {
      "id": "s7",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 1,
      "metin": "Metinde ‘herkes farklı bir varsayım ortaya attı’ denir. Varsayım ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kesin olarak kanıtlanmış bilgi"
        },
        {
          "id": "B",
          "metin": "Bir haritadaki işaret"
        },
        {
          "id": "C",
          "metin": "Rehberin verdiği bir görev"
        },
        {
          "id": "D",
          "metin": "Henüz kanıtlanmamış, doğru olabileceği düşünülen fikir"
        }
      ],
      "dogru": "D",
      "aciklama": "Çocuklar adanın ne olduğuna dair farklı tahminler yürüttü; defterlerine de ‘Varsayım kanıt değildir’ yazdılar."
    },
    {
      "id": "s8",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 7,
      "metin": "Selin’in önerdiği rapor başlığı neden “Kırk yıllık hazine bilmecesini çözdük!” başlığından daha uygundur?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü daha kısa bir başlıktır"
        },
        {
          "id": "B",
          "metin": "Çünkü hazine kelimesini hiç kullanmaz"
        },
        {
          "id": "C",
          "metin": "Çünkü hem merak uyandırır hem de gerçekte olmayan bir hazine iddiası kurmaz"
        },
        {
          "id": "D",
          "metin": "Çünkü rapor yazan çocuklar başlığı çok beğenmiştir"
        }
      ],
      "dogru": "C",
      "aciklama": "Selin’in başlığı dinleyiciyi kandırmadan ilgi çekiyordu; ilk başlık ise olmayan bir hazineyi çözmüş gibi davranıyordu."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p09$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr041-yedi-adimda-kayip-ada: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p10${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr042-kapadokyanin-gizli-gecidi",
    "baslik": "Kapadokya'nın Gizli Geçidi",
    "tur": "macera",
    "konu": "kapadokya_su_izi",
    "sinif_alt": 5,
    "sinif_ust": 5,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "kardes",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D14",
      "D6"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 5,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kesif",
        "kultur_miras",
        "doga"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D14",
        "yardimci_deger": "D6"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_oyuk_hr042",
          "tur": "lexeme",
          "etiket": "oyuk",
          "yuva": "pd_oyuk",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_kroki_hr042",
          "tur": "lexeme",
          "etiket": "kroki",
          "yuva": "pd_kroki",
          "islev": "application"
        },
        {
          "id": "sozcuk_asinma_hr042",
          "tur": "lexeme",
          "etiket": "aşınma",
          "yuva": "pd_asinma",
          "islev": "application"
        },
        {
          "id": "kavram_hr042",
          "tur": "concept",
          "etiket": "Gözlem ile yorumu ayırmak; tarihî izlere dokunmadan, saygıyla incelemek",
          "islev": "application"
        },
        {
          "id": "atasoz_hr042",
          "tur": "proverb",
          "etiket": "Damlaya damlaya göl olur",
          "yuva": "pd_ata_damlaya",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 2066,
        "tahmini_sure_dk": 20,
        "sayfa_sayisi": 7,
        "soru_sayisi": 7,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 2,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 18,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Kayada bir su damlası işareti var. Gizli bir geçidin ipucu mu, yoksa başka bir hikâye mi?",
    "durum": "taslak",
    "fis_kodu": "HR-042"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kapadokya'daki ilk sabahlarında "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", otelin terasından yükselen balonları sayıyordu. Yedinci balon kızıl bir kayanın arkasında gözden kaybolunca kardeşi Bora elindeki gezi defterini açtı. “Bugün yer altı şehirlerini görecek miyiz?” diye sordu. "
        },
        {
          "t": "isaret",
          "kod": "gunes"
        },
        {
          "t": "metin",
          "v": "\n\nAnneleri, önce açık hava müzesini ve izinli bir yürüyüş parkurunu gezeceklerini söyledi. Gezi rehberleri Eren Bey otobüste bölgenin coğrafyasını anlattı: Volkanlardan çıkan kül ve başka malzemeler zamanla kayaçlara dönüşmüş, rüzgâr ve su bazı yerleri daha hızlı aşındırmıştı. Sert ve yumuşak katmanların farklı biçimlerde aşınması, bölgenin ilginç kaya şekillerinin ortaya çıkmasına katkıda bulunmuştu.\n\n“Peribacaları bir gecede mi oluştu?” diye sordu Bora.\n\n“Hayır,” dedi Eren Bey. “Doğadaki büyük değişimler çoğu zaman çok uzun zamanlarda gerçekleşir. Bir damla suyun bile zamanla iz bırakabileceğini düşünün. Atasözümüz der ki: ‘"
        },
        {
          "t": "atasozu",
          "yuva": "pd_ata_damlaya"
        },
        {
          "t": "metin",
          "v": ".’”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " gözü yol kenarındaki levhalardan birine takıldı. Levhada tepe, vadi ve oyuğun basit çizimleri vardı. Bir ok ise fotoğraftaki kayaya benzemeyen küçük bir kanala yöneliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Bu kanal ne?” diye sordu. Rehber, bunun tarihî su sistemleriyle ilgili bir rota işareti olabileceğini ama levhayı incelemeden kesin konuşamayacağını söyledi.\n\nYolun ilk bölümünde Eren Bey çocuklara üç fotoğraf gösterdi. Hepsinde farklı boylarda peribacaları vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bazı kaya başlıklarının alttaki bölümü yağmurdan ve rüzgârdan kısmen koruduğunu öğrendi. Bora ise iki fotoğrafın neredeyse aynı görünmesine rağmen yıllar arasında çekildiğini fark etti. “Bunlar sanki durmuş gibi,” dedi. Rehber, “Yavaş gerçekleşen değişimleri bir günde görmek zordur,” diye açıkladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " örnek bir deneyi hatırladı: Suyun farklı malzemeleri değişik hızlarda aşındırabildiğini göstermek için sınıfta yapılan gözlem. “Ama bir sınıf deneyiyle yüzlerce yılın bütün koşullarını açıklayamayız,” dedi. Mert fotoğraf çekerken ışığı farklı açılardan denedi. Aynı kayalık bir açıdan tek kuleye, başka açıdan yan yana durmuş iki sütuna benziyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", gördüğü her şeyin tek bir bakış açısına bağlı kalamayacağını fark etti.\n\nÖğleden sonra yürüyüşe çıktıklarında kaya yüzeyinde birbirine paralel iki "
        },
        {
          "t": "kelime",
          "yuva": "pd_oyuk"
        },
        {
          "t": "metin",
          "v": " buldular. Parkurdan ayrılmadan, uzaktan bakabildiler. Bora hemen “Gizli geçit!” diye bağırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onu durdurdu. “Her oyuk kapı değildir,” dedi. Yine de ikisinin de kalbi hızlanmıştı. Çünkü kayanın üstünde bir su damlasına benzeyen eski bir işaret vardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Gezi grubunda "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " arkadaşları "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ve Mert de vardı. Mert manzara fotoğrafı çekmeye meraklıydı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise müzelerde eserlerin yanındaki açıklamaları okumayı severdi. Kaya üzerindeki işareti görünce birlikte fotoğraf çektiler; konumunu izinli güzergâh haritasına işaretlediler.\n\n“Bu işareti birileri yakın zamanda yapmış olabilir,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Eski olduğunu yalnızca renginden anlayamayız.”\n\nEren Bey çocukların dikkatine şaşırmıştı. Bir süre sonra onlara yakınlardaki ziyaretçi merkezindeki sergiye bakmayı önerdi. Merkezde kaya oyma mekânların, güvercinliklerin ve eski su yollarının fotoğrafları vardı. Bir panoda “su kanalı” sözcüğü geçiyordu. Kimi yerlerde yağmur suyu toplanıyor, uygun yerlere ulaştırılıyordu.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kendi defterini karıştırırken gezi öncesi kütüphaneden aldığı küçük bir broşürün arasından bir kâğıt düştü. Kâğıtta, geçmişte yaşamış bir öğrencinin hazırladığı çizime benzeyen bir "
        },
        {
          "t": "kelime",
          "yuva": "pd_kroki"
        },
        {
          "t": "metin",
          "v": " vardı. Üstte şu cümle yazıyordu: “Köyün çeşmesi susarsa suyun izini takip et.”\n\nBora, “İşte macera başladı!” dedi.\n\n“Bir dakika,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Bu çizimi kim yapmış, ne zaman yapmış?”\n\nBroşürün arkasında yörede yapılan bir okul araştırmasının adı yazıyordu. Kroki, tarihî bir belgenin aslı değil, eski su yollarını anlatmak için öğrencilerce hazırlanmış bir eğitim görseliydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " biraz hayal kırıklığına uğradı. “Demek şifre değilmiş,” dedi.\n\nEren Bey, “Şifre olmaması değersiz olduğu anlamına gelmez. Belki size çok iyi bir araştırma sorusu verdi,” diye karşılık verdi. “Üstelik tarihî yerlerde izinsiz bir kapı aramak yerine, bilgiyi güvenli biçimde inceleyebilirsiniz.”\n\nGece Bora, gezi defterindeki su damlası simgesinin kopyasını birkaç kâğıda çizmişti. “Belki bunu her gördüğümüzde bir puan kazanırız,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " oyunu kabul etti ama yeni bir kural koydu: Her işaretin yanında neden o simge olduğunu düşündüklerini yazacaklardı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Bütün damlalar eski su yolu demek değildir,” diye ekledi. Sabah kahvaltısında bir çiftçiyle tanıştılar. Çiftçi eskiden yağışın az olduğu dönemlerde suyu dikkatli kullanmak gerektiğini, bugün de aynı özenin önemli olduğunu anlattı. Bir gün önce Mert'in fotoğraf makinesinin pili tükenmişti. Ona hemen yenisini almak yerine yedek güç kaynağını kullanmasını öğreten "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " olmuştu. Mert bu küçük aksilik yüzünden en güzel manzarayı kaçırdığını sanmıştı. Ancak durup bakınca çizim yapmayı denedi; fotoğraf çekemediği kayanın gölgelerini kalemiyle daha dikkatli inceleyebildi. Bu deneyim, "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " araştırma yaparken tek araca güvenmenin neden sorun olabileceğini gösterdi. Her araç başka ayrıntıyı yakalıyordu; bazı sorulara yanıt için birden fazla yönteme ihtiyaç vardı."
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
          "v": " büyük bir kaya oyuntusunun yanında bitmiş su kabını görmüştü; önce onu tarihî bir buluntu sandı, sonra bunun yakın zamanda bırakılmış bir atık olduğunu anladı. Bora, “Demek bir şeyi anlamanın ilk yolu ona isim vermek değil, ne olduğuna dikkatle bakmak,” dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bu cümleyi not aldı; oyunun en değerli puanı ona göre doğru ayrımı yapmaktı.\n\nErtesi sabah grup, eski bir çeşmenin bulunduğu köy meydanına gitti. Meydandaki çeşmeden hâlâ su akıyordu. Yakınındaki açıklama panosunda bazı eski su toplama yöntemleri anlatılıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", birinci gün gördüğü damla işaretine benzeyen bir simge buldu. Fakat fotoğraftaki işaretin yönü farklıydı.\n\n“İkisi aynı şey mi?” diye sordu.\n\n“Benziyorlar ama eş olmak zorunda değiller,” dedi rehber. “Bir şeklin anlamını kullanıldığı yere göre değerlendiririz.”\n\nMert iki fotoğrafı tabletinde yan yana açtı. Kayadaki iz daha yuvarlaktı, çeşmenin üzerindeki ise üç köşeliydi. Bora farklılıkları saydı. Saadet Hanım çocuklara bir de çeşmenin eski bir fotoğrafını gösterdi. Fotoğrafta musluğun arkasındaki duvar bugünkünden farklıydı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun nedenini sorunca, yapının yıllar içinde onarım gördüğünü öğrendiler. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Onarım kötü mü?” dedi. “Hayır,” diye cevap verdi Saadet Hanım. “Önemli olan yapının korunması ve yapılan işlemlerin uzmanlarca kayıt altına alınması.” Bora eski fotoğraftaki taşları saydı, güncel fotoğrafla karşılaştırdı. Üç taşın farklı göründüğünü buldu. Böylece çevredeki bir ayrıntının değişmesini her zaman gizli bir kapıyla açıklamanın yanlış olduğunu gördü. Bazen cevap, dikkatli bir bakım çalışmasında saklıydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk defa bir sırrı çözmek için hızlı davranmak yerine ayrıntıları incelemekten zevk alıyordu.\n\nKöy meydanında emekli bir öğretmen olan Saadet Hanım ile tanıştılar. Eren Bey onların sorusunu iletti. Saadet Hanım, eskiden köy çevresinde yağmurun nasıl toplandığını anlatan bir yerel araştırma hazırladıklarını söyledi. Fakat çocukların gördüğü işaretin tam olarak neyi gösterdiğinden emin değildi. “Belge bulursanız beraber bakarız,” dedi.\n\n“Siz bilmiyorsanız kim bilir?” diye sordu Bora.\n\n“Bilmemek ayıp değil,” dedi Saadet Hanım. “Bilmediğini öğrenmek istememek üzücü olabilir.”\n\nBu cevap "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " hoşuna gitti. Saadet Hanım çocukları belediyenin herkesin ziyaret edebildiği küçük yerel tarih sergisine yönlendirdi. Orada eski su kapları, ölçüm aletleri ve geçmiş yıllardaki kuraklığa ilişkin gazete kupürleri vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", başlıklardan birini defterine geçirdi: “Suyu bulmak kadar korumak da önemlidir.”\n\nSöyleşiden önce müze salonundaki bir maket dikkatlerini çekti. Makette yağmur, tepelerin yamaçlarından aşağıya akıyor; kimi yerlerde küçük kanallar boyunca birikiyor, kimi yerlerde ise toprağa sızıyordu. Görevli, maketin gerçek bir köyün bütün ayrıntılarını göstermediğini, öğrenmeye yardımcı bir model olduğunu özellikle söyledi. Çocuklardan biri maketteki suyu artırdığında bir kanalın taşıyamayıp taştığı görüldü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Her kanalın bir sınırı var,” dedi. Görevli başını salladı. “Su sistemlerini anlamak için yalnızca suyun nereden geldiğine değil, ne kadar olduğuna ve nereye gittiğine de bakarız.” Bora ikinci denemede kanalların önüne küçük engeller koydu. Su birikti. “Bazen tıkanıklık da sorun yaratıyor,” dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " sınıfta fen dersinde öğrendikleri akış sözcüğünün burada ne anlama geldiğini yazdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise bir model üzerinde yaptıkları değişikliklerin gerçek tarihî yapıya uygulanmaması gerektiğini düşündü. Geçmişten kalan izler, öğrenmek için incelenirdi; oyun oynamak için bozulmazdı.\n\nÖğle sonrası müze görevlisi ile kısa bir söyleşi yaptılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " özellikle “yer altı şehri” sözünü merak etmişti. Müze görevlisi, insanların farklı dönemlerde kayaları oyarak çeşitli amaçlarla mekânlar oluşturduğunu anlattı. Bunların bir kısmının yaşam, depolama ve korunma gibi işlevleri olabiliyordu. Bora hemen “Bütün odalar birbirine gizli geçitle bağlanır mı?” diye sordu. Görevli gülümsedi. “Bunu her yapı için söyleyemeyiz. Yer altı mekânlarını incelemek uzmanların işidir. Bazı alanlar ziyaretçiye açıktır, bazıları değildir.” Çocuklar sonra izinli bir sergi bölümünde yer altı yapılarının kesit çizimlerini gördü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bir kesit çiziminin duvarın arkasını hayal etmelerine yardım ettiğini fark etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Görevli, eski yerleşimlerde suya ulaşmanın büyük önem taşıdığını, ancak her oyuk veya tünelin su için yapılmadığını anlattı. Çocuklar hazırladıkları soruları sırayla yöneltti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " “Bir kanalın yaşını nasıl anlarsınız?” diye sordu. Görevli, uzmanların malzeme, yapım tekniği, tarihî kayıtlar ve gerektiğinde bilimsel yöntemleri birlikte değerlendirdiğini söyledi.\n\nMert, “Yalnızca fotoğrafla kesin sonuca varamaz mıyız?” diye sordu.\n\n“Çoğu zaman fotoğraf bir başlangıçtır,” dedi görevli. “Tek başına bütün soruları cevaplamaz.”\n\nGezi tamamlanırken parkur yakınından su sesi geldi. Bora hemen arkasını döndü. Kayaların arasındaki küçük bir oluğun içinden ince bir akıntı ilerliyordu. Eren Bey bunun son yağışlardan sonra görülebilen yüzey akışı olabileceğini anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " olukla eski broşürdeki çizginin benzerliğini fark etti ama ikisini aynı yapı sanmadı.\n\n“Bazen bir doğa izi, insan yapımı bir kanala benzeyebilir,” dedi.\n\nEren Bey, “İşte bu yüzden gözlem, karşılaştırma ve kaynak kontrolü yapıyoruz,” diye karşılık verdi.\n\nBir süre sonra suyun bir kısmının küçük bir çukurda biriktiğini gördüler. Çukurun çevresindeki bitkiler daha canlı görünüyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Su bitkileri de etkiliyor,” dedi. Mert o an güzel bir fotoğraf çekti: ön planda yeşil yapraklar, arkada güneş altında uzanan sarı kayalar. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bu kez küçük bir araştırma tablosu çizdi: Bir satırda su, ötekinde rüzgâr, üçüncüsünde insan emeği vardı. Kapadokya'nın görünüşünü anlamak için yalnızca bir nedeni bilmenin yeterli olmadığını birlikte gördüler.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", Kapadokya'nın yalnızca peri bacalarından ibaret olmadığını anladı. Toprağı, suyu, insanları ve hikâyeleri bir aradaydı.\n\nÖğretmenleriyle yapılan kısa değerlendirme toplantısında "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir soru sordu: “Bir kaya üzerindeki iz yüzlerce yıllıksa, ona yanlışlıkla zarar verebileceğimizi nasıl anlarız?” Eren Bey, ziyaretçi olarak en güvenli yaklaşımın işaretlenmiş rotalarda kalmak, tarihi yapılara dokunmamak ve şüpheli bir bulguyu görevlilere bildirmek olduğunu söyledi. Mert, “Fotoğraf çekmek bazen dokunmaktan daha çok şey anlatıyor,” dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " fotoğrafın yanına çizim de eklemenin yararını anlattı. Bora her şeyi bulmak isteyen ilk hâlini hatırladı. Şimdi iyi bir kâşifin bazen bir kapıyı açmayan kişi olabileceğini düşünüyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Günün sonunda dört arkadaş çizimleri karşılaştırdı. Bora damla işaretini birbirine benzeten dört fotoğraf seçmişti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bunlardan ikisinin bambaşka yerlerdeki bilgilendirme levhalarına ait olduğunu fark etti. “Bunları aynı kanıt gibi sunamayız,” dedi. Mert çektiği fotoğrafların saatlerini gösterdi; sabah güneşiyle öğleden sonraki gölgenin kaya üzerindeki çizgiyi farklı belirginleştirdiğini anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " herkesin gözlemini tek bir sayfaya topladı. Başlangıçta tam bir cevap beklemişlerdi. Şimdi farklı bilgi kaynakları arasında bağlantı kurmanın daha değerli olduğunu düşünüyorlardı. Rehberleri Eren Bey deftere bakınca gülümsedi. “Araştırma, yalnızca bulduğunu değil, bulamadığını da dürüstçe yazmaktır,” dedi. Çocuklar son sayfaya küçük bir kutu çizip “Kesinleşmeyen sorular” başlığı açtılar. Altına kaya yüzeyindeki su damlası işaretinin kökenini yazdılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bu sorunun bir sonraki uzman araştırmasına bırakılmasından rahatsız olmadı. Çünkü artık her gizemin bir akşamda çözülmek zorunda olmadığını biliyordu.\n\nAkşam otelde herkes gezi defterini tamamladı. Bora ilk sayfaya büyük harflerle “Gizli Geçidi Bulduk!” yazmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Ama bir geçide girmedik. Bunu yazarsan okuyanlar yanlış anlayabilir,” dedi.\n\n“Bütün heyecanı söndürüyorsun,” diye söylendi Bora.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " araya girdi. “Başlığı değiştirmeden hikâyenin sonunda neyi keşfettiğimizi anlatabiliriz. Belki gizli geçit, bizi sorulara götüren yoldu.”\n\nBora düşündü. “O zaman “Kapadokya'nın Gizli Geçidi” başlık olur. Ama içeride hayal ile gerçek ayrılır.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu fikri sevdi. Defterini açıp ilk günün haritasını, çeşme fotoğrafını ve su oluğunu yan yana yerleştirdi. Her birinin altına “Kesin bilgi”, “Gözlem” veya “Araştırılması gereken” notunu ekledi.\n\nErtesi sabah dönüş yolunda otobüs bir seyir noktasında durdu. Balonlar yine gökyüzündeydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu kez onları saymak yerine vadiler arasındaki yolları izledi. İnsanlar yüzlerce yıl boyunca bu coğrafyanın sunduğu imkânları kullanmış, zor koşullara çözümler bulmuştu. Onların izlerine saygı duymak, yalnızca güzel fotoğraflar çekmekten fazlasını gerektiriyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Otobüste Eren Bey çocukların defterlerini sırayla inceledi. Herkesin en az bir kesin bilgi, bir gözlem ve bir yeni soru yazmasını istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " çeşmenin geçmişiyle ilgili öğrendiği bilgiyi seçti. Mert kayaların ışıkla değişen görünümünü gözlem olarak yazdı. Bora en başta çizdiği hayalî gizli geçidin yanına şimdi bir soru işareti koymuştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ona dönüp “Bu resmi silmeyecek misin?” dedi. Bora başını salladı. “Hayır. Hikâyenin başladığı yer orası. Bilgiyle hayal arasındaki farkı bana hatırlatacak.”\n\nBora yanına oturdu. “Bir daha gelirsek yine gizem arayalım mı?”\n\n“Arayalım,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Ama bu defa yanımızda daha çok soru, daha az tahmin olsun.”\n\n“Hiç tahmin olmasın mı?”\n\n“O kadar da değil. Tahmin bizi yola çıkarır. Kanıt nereye gideceğimizi söyler.”\n\nDefterdeki son tabloyu birlikte doldurdular. Birinci sütunda gezi sırasında duydukları yeni kelimeler, ikinci sütunda anlamları, üçüncü sütunda ise kullandıkları örnek cümleler vardı. Bora “oyuk” kelimesinin yanına kayanın içeri doğru çökük bölümünü gösteren küçük bir çizim ekledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " “"
        },
        {
          "t": "kelime",
          "yuva": "pd_asinma"
        },
        {
          "t": "metin",
          "v": "” sözcüğünü yazdı ve rüzgârla suyun etkisini açıkladı. Mert “kültürel miras” sözcüğüne eski yapıları ve onları koruma sorumluluğunu ekledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", en çok “kanıt” kelimesinin anlamını değiştirdiğini düşündü. Çünkü onun için kanıt artık yalnızca gizli bir işaret değil, doğru soruyla incelenen bilgi demekti.\n\nOtobüs hareket etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", defterin son sayfasına araştırmada tanıştıkları insanların adlarını da yazdı; bir keşifte yalnız olmamak güzeldi.\n\nO su damlası resmine her baktığında Kapadokya'daki kayaların yalnızca güzel görüntüler değil, uzun bir zamanın izleri olduğunu hatırlayacaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " de sonraki gezilerinde aynı dikkatle gözlem yapmaya söz verdi.\n\nBora defterinin kapağına küçücük bir su damlası çizdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " de yanına ok ekledi. Artık o işaret, yalnızca gizemli bir kapıyı değil, araştırmanın yönünü gösteriyordu. "
        },
        {
          "t": "isaret",
          "kod": "anahtar"
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
      "metin": "Broşürün arasından düşen krokinin gerçekte ne olduğu anlaşıldı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Tarihî bir hazine haritasının aslı"
        },
        {
          "id": "B",
          "metin": "Eski bir müzenin planı"
        },
        {
          "id": "C",
          "metin": "Eski su yollarını anlatmak için öğrencilerce hazırlanmış bir eğitim görseli"
        },
        {
          "id": "D",
          "metin": "Rehberin çizdiği bir yürüyüş rotası"
        }
      ],
      "dogru": "C",
      "aciklama": "Broşürün arkasındaki bilgi, krokinin bir okul araştırması için hazırlanmış eğitim görseli olduğunu gösterdi."
    },
    {
      "id": "s2",
      "beceri": "hatirlama",
      "dayanak_sayfa": 3,
      "metin": "Kayadaki işaretle çeşmedeki simge arasında hangi fark fark edildi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kayadaki iz daha yuvarlaktı, çeşmedeki ise üç köşeliydi"
        },
        {
          "id": "B",
          "metin": "Kayadaki iz çok daha büyüktü"
        },
        {
          "id": "C",
          "metin": "Çeşmedeki simge hiç su damlasına benzemiyordu"
        },
        {
          "id": "D",
          "metin": "İkisi de tıpatıp aynıydı"
        }
      ],
      "dogru": "A",
      "aciklama": "Mert iki fotoğrafı yan yana açınca kayadaki izin daha yuvarlak, çeşmedekinin üç köşeli olduğu görüldü."
    },
    {
      "id": "s3",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Rehber, benzer görünen iki işareti neden hemen aynı kabul etmedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü işaretlerin renkleri farklıydı"
        },
        {
          "id": "B",
          "metin": "Çünkü fotoğrafları kimse çekmemişti"
        },
        {
          "id": "C",
          "metin": "Çünkü işaretleri artık görmek mümkün değildi"
        },
        {
          "id": "D",
          "metin": "Çünkü bir şeklin anlamı, kullanıldığı yere göre değerlendirilir; benzemek aynı olmak demek değildir"
        }
      ],
      "dogru": "D",
      "aciklama": "Rehber, işaretlerin benzeyebileceğini ama eş olmak zorunda olmadığını, anlamın kullanıldığı yere göre değerlendirildiğini söyledi."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Çocukların son sayfaya “Kesinleşmeyen sorular” kutusu çizmesi neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Araştırmayı yarıda bıraktıklarını"
        },
        {
          "id": "B",
          "metin": "Bilmediklerini de dürüstçe yazmanın araştırmanın bir parçası olduğunu anladıklarını"
        },
        {
          "id": "C",
          "metin": "Rehberin kendilerini cezalandırdığını"
        },
        {
          "id": "D",
          "metin": "Bütün soruların cevabını bulduklarını"
        }
      ],
      "dogru": "B",
      "aciklama": "Rehber, araştırmanın bulamadığını da dürüstçe yazmak olduğunu söyledi; çocuklar da açık kalan soruyu not etti."
    },
    {
      "id": "s5",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 7,
      "metin": "Bora, defterde ‘oyuk’ sözcüğünün yanına küçük bir çizim ekledi. Bu çizim neyi gösteriyordu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kayanın üstünde duran bir bayrak"
        },
        {
          "id": "B",
          "metin": "Kayadaki bir resim"
        },
        {
          "id": "C",
          "metin": "Kayanın içeri doğru çökük bölümü"
        },
        {
          "id": "D",
          "metin": "Kayanın tepesindeki sivri parça"
        }
      ],
      "dogru": "C",
      "aciklama": "Bora, oyuk sözcüğünün yanına kayanın içeri doğru çökük bölümünü gösteren bir çizim ekledi."
    },
    {
      "id": "s6",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 7,
      "metin": "Metne göre aşınma ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kayaların rüzgâr ve suyun etkisiyle zamanla yavaş yavaş yıpranması"
        },
        {
          "id": "B",
          "metin": "Kayaların bir gecede yerinden oynaması"
        },
        {
          "id": "C",
          "metin": "Eski yapıların onarılması"
        },
        {
          "id": "D",
          "metin": "Kaya üzerine işaret çizilmesi"
        }
      ],
      "dogru": "A",
      "aciklama": "Gezi boyunca rüzgâr ve suyun kayaçları zamanla aşındırdığı anlatılmış, aşınma sözcüğü de bu etkiyle açıklanmıştı."
    },
    {
      "id": "s7",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 6,
      "metin": "Ece, Bora’nın defterine yazdığı “Gizli Geçidi Bulduk!” başlığına neden itiraz etti? Bu itiraz yerinde midir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yerinde değil; çünkü heyecan her şeyden önemlidir"
        },
        {
          "id": "B",
          "metin": "Yerinde değil; çünkü başlık çok uzundur"
        },
        {
          "id": "C",
          "metin": "Yerinde; çünkü gerçekte bir geçide girmemişlerdi ve başlık okuyanları yanıltabilirdi"
        },
        {
          "id": "D",
          "metin": "Yerinde; çünkü Bora yazı yazmayı bilmiyordu"
        }
      ],
      "dogru": "C",
      "aciklama": "Bir geçide girmemişlerdi; bu yüzden böyle bir başlık okuyanlar için yanlış anlaşılmaya yol açabilirdi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p10$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr042-kapadokyanin-gizli-gecidi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p11${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr043-kuledeki-son-isik",
    "baslik": "Kuledeki Son Işık",
    "tur": "gizem",
    "konu": "kule_isigi_hava_gozlemi",
    "sinif_alt": 5,
    "sinif_ust": 5,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D6",
      "D16"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 5,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "gizem",
        "bilim_teknoloji",
        "guvenlik"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D6",
        "yardimci_deger": "D16"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_tahmin_hr043",
          "tur": "lexeme",
          "etiket": "tahmin",
          "yuva": "pd_tahmin",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_olasilik_hr043",
          "tur": "lexeme",
          "etiket": "olasılık",
          "yuva": "pd_olasilik",
          "islev": "application"
        },
        {
          "id": "sozcuk_uyari_hr043",
          "tur": "lexeme",
          "etiket": "uyarı",
          "yuva": "pd_uyari",
          "islev": "application"
        },
        {
          "id": "kavram_hr043",
          "tur": "concept",
          "etiket": "Gözlem ile varsayımı ayırmak; resmî hava uyarılarını doğru kaynaktan takip etmek",
          "islev": "application"
        },
        {
          "id": "atasoz_hr043",
          "tur": "proverb",
          "etiket": "Sormakla yol bulunur",
          "yuva": "pd_ata_sormakla",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 2071,
        "tahmini_sure_dk": 20,
        "sayfa_sayisi": 7,
        "soru_sayisi": 7,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 3,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 20,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Yıllardır boş denen kulede gece bir ışık yandı. Gizli bir mesaj mı, yoksa hava gözleminin parçası mı?",
    "durum": "taslak",
    "fis_kodu": "HR-043"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yağmurdan sonraki serin akşamda, kasabanın üzerindeki eski gözlem kulesinin penceresinde üç kez ışık göründü. Beşinci sınıf öğrencisi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", balkonlarında otururken ışığın önce kısa, sonra uzun aralıklarla yandığını fark etti. Herkes kulenin yıllardır kullanılmadığını söylüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise geçen ay aynı tepede yenilenen bir anten görmüştü. "
        },
        {
          "t": "isaret",
          "kod": "ay"
        },
        {
          "t": "metin",
          "v": "\n\n“Anne, kulede biri olabilir mi?” diye sordu.\n\nAnnesi perdeyi açıp baktı. “Olabilir. Ama gece tek başımıza oraya gitmek doğru olmaz. Yarın belediyenin bilgi hattına sorabiliriz.”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ertesi sabah okulda gördüklerini en yakın arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yonelme",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " anlattı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " doğa olaylarıyla ilgili videolar izlemeyi severdi. “Belki gizli bir haberleşme sistemi,” dedi heyecanla.\n\nÜçüncü arkadaşları Defne ise hemen karşı çıktı. “Ya bakım lambasıysa? Önce gözlemimizi yazalım.”\n\nÖğretmenleri Meryem Hanım bir bilim gözlem etkinliği planlıyordu. Çocukların notlarını görünce kulenin bulunduğu tepeyi gösteren eski bir fotoğraf çıkardı. Fotoğrafta kulenin yanında rüzgâr yönünü gösteren bir ok vardı. “Bu yer eskiden hava gözlemleri için kullanılmış,” dedi. “Bugünkü işlevini bilmiyoruz. Birlikte araştırabiliriz.”\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " çantasından çizgili defterini çıkarıp kuleye ait bir resim çizdi. Üzerine üç ışık işareti koydu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dikkatle baktı. “Ben üç ışık gördüm ama aralarında eşit süre var mıydı, bilmiyorum,” dedi. Defne “O zaman aralıklara eşit çizgi koymayalım,” diye önerdi. Çizimin altına “yaklaşık gözlem” yazdılar. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", bu küçük kelimenin neden önemli olduğunu o an kavradı. Kesin olmayan bir şeyi kesinmiş gibi göstermek, resme bakacak herkesi yanlış yönlendirebilirdi. Bir sonraki gözlem için saat tutmayı, rüzgâr ve hava durumunu da not etmeyi planladılar. Her birinin ayrı görevi olacaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " görsel kaydı, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " zamanlamayı, Defne notları kontrol edecekti. Böylece aynı olayı üç kişinin farklı bakışla inceleyebileceğini düşündüler.\n\nİlk görevleri, kuleye yaklaşmadan güvenilir bilgi bulmaktı. Belediye sayfasındaki duyuruları incelediler. Kulede bazı meteoroloji sensörlerinin yenilendiğini öğrenince "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gizli haberleşme fikri zayıfladı. Yine de geceki ışığın ne anlama geldiği açıklanmamıştı.\n\nBir gün önce "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " küçük kardeşi rüzgâr gülünü döndürmekte zorlanmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ona, “Rüzgâr yoksa dönmez,” demişti. Kardeşi üfleyerek çarkı döndürünce ikisi gülmüştü. Okuldaki gözlem köşesinde "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu anıyı anlattı. Öğretmenleri hava hareketinin farklı hızlarda olabileceğini, ölçüm araçlarının doğru kullanılmasının önemini açıklarken çocuklardan gözlemlerini basit cümlelerle yazmalarını istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " başlangıçta “çok rüzgârlı” diye not aldı. Defne ona “Ne kadar?” diye sordu. Sınıftaki rüzgâr ölçerin değerini ve saati eklediler. Bu küçük değişiklik, bir gözlemden daha karşılaştırılabilir bir kayda geçmelerini sağladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Meryem Hanım, öğrencileri okulun küçük hava köşesine götürdü. Termometre, yağmur ölçer ve rüzgâr yönünü gösteren basit bir düzenek vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sabah sıcaklığını deftere yazdı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gökyüzündeki bulutların şeklini çizdi. Defne ise rüzgârın aniden yön değiştirdiğini fark etti.\n\n“Hava tahmini yalnızca bulutlara bakmak mıdır?” diye sordu "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ".\n\n“Hayır,” dedi öğretmenleri. “Sıcaklık, basınç, nem, rüzgâr ve daha birçok veri birlikte değerlendirilir. Üstelik tahminin kesinlik derecesi vardır.”\n\nOkuldaki hava köşesinin termometresi güneş altında kaldığında daha yüksek değer gösterebiliyordu. Defne, farklı yere taşındığında ölçümün niçin değiştiğini merak etti. Öğretmenleri, ölçümlerin karşılaştırılabilir olması için araçların doğru yere konması ve aynı yöntemle kullanılması gerektiğini anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", evlerinin balkonunda tuttuğu sıcaklık notlarıyla okul kayıtlarının neden farklı olduğunu anladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yağmur ölçerin boşaltılması gerektiğini unuttuğu bir günü hatırladı. “Demek sayı kadar sayının nasıl elde edildiği de önemli,” dedi. Meryem Hanım, “Bunu raporunuzun en üstüne yazın,” diye önerdi. Çocuklar artık meteorolojiyle ilgili bir sözcük öğrendiklerinde onu doğrudan örneklerle ilişkilendirebiliyordu: nem, yağış, basınç ve rüzgâr yalnızca kitapta gördükleri kelimeler değildi.\n\nO gün okulun küçük bahçe şenliğinin duyurusu yapılacaktı. Sınıf süslemeleri hazırlıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hava tahmini sitesinde akşam için gök gürültülü sağanak olasılığı gördü. Arkadaşı Tuna, “Burada güneş var, yağmur gelmez,” dedi. Defne buna itiraz etti: “Bir yerde güneş olması, birkaç saat sonra başka bir hava olayı yaşanmayacağını göstermez.”\n\nÇocuklar öğretmenlerinden resmi tahmin ve uyarıların nereden takip edildiğini öğrendi. Başka kaynaklarda farklı ifadeler görünce de tek bir videoya bakarak karar vermemeleri gerektiğini anladılar. O akşam "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " notlarını gözden geçirirken “hava durumu” ile “hava tahmini” sözcüklerini aynıymış gibi kullanmış olduğunu gördü. Öğretmeninin anlattıklarını hatırladı: Biri belirli bir zamanda gözlenen durumu, diğeri geleceğe ilişkin değerlendirmeyi anlatıyordu. Defterindeki iki cümleyi düzeltti. Bu küçük ayrım, sonraki günün sorularını daha açık sormasına yardım edecekti."
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
          "v": " akşamki kule ışıklarının havayla ilişkili olabileceğini düşünmeye başladı.\n\nÖğle arasında duyuru panosuna küçük bir çizelge astılar: “Gözlem, tahmin, gerçekleşen hava”. Sınıftaki diğer öğrenciler de kendi gözlemlerini ekledi. Kimileri bulutları resmetti, kimileri rüzgârı hissettiğini yazdı. Çizelge giderek bir dedektif panosuna benziyordu. Fakat bu kez dedektiflerin peşinde bir insan değil, değişen hava vardı.\n\nMeryem Hanım, meteoroloji bölge müdürlüğündeki eski öğrencisi Burcu Hanım'ı çevrim içi görüşmeye davet etti. Burcu Hanım bir hava uzmanıydı. Öğrenciler sırayla sorularını yöneltti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kuledeki yanıp sönen ışığın gizli bir mesaj olup olmadığını sordu.\n\n“Kulede ekipman kontrolü için kullanılan ışıklar olabilir,” dedi uzman. “Ama görüntüye bakarak görevini kesin söyleyemem. Hangi sistem olduğunu kurumdan doğrulamamız gerekir.”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Bir hava istasyonu tehlikeyi nasıl bildirir?” diye sordu.\n\nBurcu Hanım, otomatik istasyonların ölçümleri elektronik yollarla iletebildiğini anlattı. Gözlem verileri uzmanlarca incelenir, uygun görülürse resmî uyarılar yayımlanırdı. Kuledeki ışık tek başına halka yönelik bir alarm anlamına gelmiyordu.\n\nBurcu Hanım çevrim içi görüşmede bir örnek de gösterdi. İki haritada aynı bölgenin farklı zamanlardaki hava durumunu simgelerle işaretlemişti. Bir haritada yağmur olasılığı görünürken ötekinde yağışın gerçekleştiği alan gösteriliyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " iki haritayı ilk anda aynı sandı. Burcu Hanım, “Biri "
        },
        {
          "t": "kelime",
          "yuva": "pd_tahmin"
        },
        {
          "t": "metin",
          "v": ", biri gözlem,” dedi. “Birbirine benzeyebilirler ama görevleri farklıdır.” Çocuklar bir tahmini değerlendirirken ne zaman yayımlandığına ve hangi süreyi kapsadığına dikkat etmeleri gerektiğini öğrendi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu çok yararlı buldu; çünkü internette dolaşan eski bir uyarıyı güncel sanmanın da yanlış kararlar doğurabileceğini fark etti. Defne, sınıf panosuna tarihi olmayan hiçbir uyarı resmi asmayacaklarına karar verdi.\n\nGörüşme bittikten sonra Meryem Hanım önemli bir soru sordu: “Bir ipucu gördüğünüzde hikâyeyi kim tamamlıyor?”"
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
          "v": " elini kaldırdı. “Bazen biz tamamlıyoruz. Ama kafamızdan.” Sınıf güldü.\n\n“O hâlde bilmediğimiz kısmı araştırmadan kesin konuşmayacağız,” dedi öğretmenleri. Sonra tahtaya eski bir atasözü yazdı: “"
        },
        {
          "t": "atasozu",
          "yuva": "pd_ata_sormakla"
        },
        {
          "t": "metin",
          "v": ".”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yine de kulenin ışığını unutamıyordu. Ertesi akşam balkondan baktığında ışık bir kez daha yandı. Bu kez saatini not etti ve annesiyle birlikte görüntünün kısa bir videosunu çekti. Videoda uzaktaki kule görünüyordu ama ışığın niçin yandığı belli değildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kameranın sınırlarını da fark etti: Bir görüntü, her sorunun cevabı değildi.\n\nŞenlikten bir gün önce sınıf içinde küçük bir tartışma yaşanmıştı. Tuna, hava tahmininin bazen tutmadığını söyleyerek uyarılara hiç güvenmemeyi savunuyordu. Defne ise bir tahminin "
        },
        {
          "t": "kelime",
          "yuva": "pd_olasilik"
        },
        {
          "t": "metin",
          "v": " bildirdiğini, bu yüzden gerçekleşmeyen bir olayın bütün tahmin yöntemlerini geçersiz kılmayacağını anlattı. Meryem Hanım çocuklardan iki cümleyi karşılaştırmalarını istedi: “Mutlaka yağmur yağacak” ve “Sağanak olasılığı bulunuyor.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ikinci cümlenin daha doğru olduğunu söyledi; kesinlik bildiren sözcükler farklı kararlar doğurabilirdi. Öğretmenleri bunun üzerine kısa bir etkinlik yaptırdı. Çocuklar meteoroloji bültenlerindeki “olası”, “bekleniyor”, “yerel” gibi sözcükleri işaretledi. Tuna sonunda “Demek hava tahmini kehanet değil,” dedi. Sınıf güldü. Meryem Hanım, “Evet, bilimsel verilere dayalı bir değerlendirme,” diye tamamladı.\n\nCuma sabahı hava açık başladı. Okul bahçesindeki masalara kitaplar dizildi, öğrencilerin yaptığı afişler asıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " görevlilerden biriydi. Ancak öğleye doğru rüzgâr kuvvetlendi. Hafif afişler sallanıyor, bazı bulutlar kısa sürede çoğalıyordu. Meryem Hanım, okul idaresiyle birlikte güncel hava uyarılarını kontrol etti.\n\nŞenliğin açık hava bölümü ertelendi. Bazı öğrenciler üzüldü. Tuna, “Belki yağmur yağmayacak. Boşuna hazırlanmış olduk,” dedi.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Belki yağmaz,” diye cevap verdi, “ama "
        },
        {
          "t": "kelime",
          "yuva": "pd_uyari"
        },
        {
          "t": "metin",
          "v": " varsa önlem almak doğru. Bütün masaları içeri taşıyabiliriz.”\n\nMasalardan birinin üzerinde, geçen yılki öğrencilerin hazırladığı çizim kitabı duruyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onu almak için geri dönecekti ama öğretmeni bahçedeki görevin sona erdiğini söyledi. Bir görevli kitabı güvenle içeri getirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce kendi başına çıkabileceğini düşünmüştü. Sonra kararın neden yetişkinler tarafından verildiğini hatırladı; sert hava koşullarında kontrolsüz hareket etmek yeni riskler oluşturabilirdi. İçeri girdiklerinde başka bir sınıfın üzgün öğrencileriyle karşılaştılar. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Şenlik iptal olmadı, sadece yer değiştirdi,” dedi. Tuna ve arkadaşları masaları yeniden kurdu; kitapların yanına bulut çizimleri asıp salonu küçük bir bilim müzesine çevirdiler. Böylece herkesin emeği değerlendi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar öğretmenlerin yönlendirmesiyle kitapları kapalı salona taşıdı. İçeri taşınan masaların biri diğerlerine göre ağırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce onu tek başına kaldırmayı denedi, sonra öğretmeninden yardım istedi. Birlikte taşırken “Bugün yalnızca hava değil, ekip çalışması da öğrendik,” diye şaka yaptı. Tuna kütüphane kitaplarının ıslanmadığını görünce rahatladı. Çünkü bir ay boyunca resimledikleri öyküleri ilk kez ziyaretçilere gösterecekti.\n\nKısa süre sonra yağmur başladı. Pencereden dışarı bakarken sert damlaların bahçedeki boş masalara vurduğunu gördüler. Eşyalar zarar görmemiş, öğrenciler içeride güvendeydi.\n\nTuna "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " dönüp “Ben yalnızca şimdiki güneşe baktım,” dedi. “Sen sonraki saatleri de düşündün.”\n\nTuna o gün "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ile birlikte salonun penceresinden bahçeyi izledi. Yağmurdan sonra rüzgâr hafifledi, bulutların bir kısmı dağıldı. Tuna “Şimdi dışarı çıkabiliriz,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", etkinliğin yeniden dışarı taşınıp taşınmayacağına öğretmenlerinin karar vereceğini hatırlattı. Çünkü hava yalnızca o anda pencereden görünen manzaradan ibaret değildi. Okul yönetimi etkinliği içeride sürdürmeyi uygun buldu. Bu karar ilk başta bazılarına gereksiz göründü ama içerideki program da çok güzel geçti. Çocuklar çizimlerini korumuş, misafirler rahatça kitapları incelemişti. Tuna, bir günün başarılı olması için bütün planların ilk biçimiyle gerçekleşmesinin gerekmediğini anladı.\n\n“Aslında bunu öğretmenimiz ve uzmanların uyarısı sayesinde yaptık,” diye karşılık verdi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ".\n\nMeryem Hanım çocuklardan günün sonunda bir karşılaştırma yapmalarını istedi. Sabah planlanan şenlikle gerçekleşen şenlik arasında hangi farklar vardı? "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " masaların yerinin değiştiğini, Tuna bazı oyunların içeride oynanabildiğini, Defne ise kimi süslemelerin kaldırıldığını yazdı. Fakat ortak amaç değişmemişti: Öğrencilerin hazırladığı kitapları ve çizimleri paylaşmak. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bir planı uyarlamanın vazgeçmek anlamına gelmediğini fark etti. Sınıfın küçük gazetesi için yeni bir başlık buldu: “Yağmurlu Günün Kitap Şenliği.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Şenlik içeride devam etti. Çocuklar kitaplarını anlattı, hazırladıkları hava gözlem tablosunu misafirlere gösterdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " masaya, “Hava bir sır saklamaz; sadece onu anlamak için veri gerekir,” yazılı küçük bir kart koydu.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " belediyeye soruyu yöneltirken annesinin yardımını almıştı. Başvuruda kişisel bir şikâyet değil, gözlemlenen ışığın hangi amaçla kullanıldığını öğrenmek istediklerini açıklamıştı. Yanıt kısa ama anlaşılırdı; ilgili birim, tesisin bakım kontrolleri hakkında genel bilgi vermişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " metni sınıf panosuna olduğu gibi asmak yerine öğretmeniyle birlikte özetledi. Kurum adını, yanıtın tarihini ve sorulan soruyu da eklediler. Böylece arkadaşları bilgiyi nereden öğrendiklerini görebilecekti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Keşke ışığın mors alfabesiyle mesaj verdiği doğru çıksaydı,” diye şaka yaptı. Defne, “O zaman da bunu kanıtlamak gerekirdi,” dedi.\n\nHafta sonunda belediyeden yanıt geldi. Yenilenen kuledeki ışık, bakım sırasında belirli aralıklarla yapılan bir ekipman kontrolünün parçasıydı. Kule, hava verilerini ölçen sistemlerden birini barındırıyordu. Işık, "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " düşündüğü gibi insanları doğrudan uyaran bir mesaj değildi. Yine de kule, hava gözlemi için önemliydi.\n\n“Aslında çocukken ben de bulutların her şeklini bir işaret sanırdım,” dedi öğretmenleri. “Hayal kurmak güzeldir. Bilim yaparken ise hayalimizin hangi bölümünün kanıtlandığını bilmemiz gerekir.” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bu sözlere sevindi. Gizemli öyküler yazmaktan vazgeçmeyecekti. Sadece bilim gözlemleriyle kurmaca hikâyeleri birbirine karıştırmamayı öğrenecekti.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " biraz utanarak, “Ben onu gizli bir istasyon sandım,” dedi.\n\nDefne gülümsedi. “Aslında istasyon kısmını doğru tahmin etmişsin. Gizli kısmını kanıtlamamıştık.”\n\nÖğretmenleri raporlarını üç bölüme ayırmalarını istedi: “Ne gördük? Ne düşündük? Ne öğrendik?” Defne yazıyı yüksek sesle okuyunca bir cümlede tarih eksik olduğunu fark ettiler. Hemen eklediler; çünkü bir gözlemin ne zaman yapıldığı, ne görüldüğü kadar önemliydi.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk bölümde gece görülen ışığı, ikinci bölümde olası açıklamaları, üçüncü bölümde ise doğrulanmış bilgiyi yazdı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", kanıtlanmayan fikrini silmek yerine yanına “ilk varsayım” notu düştü.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " okul gazetesine bir yazı hazırladı. İlk başlığı “Kulede Gizli Alarm!” olmuştu. Defne bunun gerçekte bulunmayan bir tehlike duygusu yaratacağını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başlığı “Eski Kulenin Yeni Görevi” olarak değiştirdi. Yazısına ışık hakkında öğrendiklerini, resmî hava uyarılarına nasıl ulaşabileceklerini ve alınan önlemlerin önemini ekledi. Yazı yayımlandığında en çok sorulan soru “Kuleye nasıl gireriz?” değil, “Hava tahmini ne kadar önce hazırlanır?” olmuştu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sonraki hafta kule yine ışık verdiğinde "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", ışığı gördüğü ilk gün gözlemini kaydetmeseydi hangi ayrıntıları hatırlayıp hangilerini unutacağını düşündü. Küçük notların büyük yanlış anlamaları önleyebildiğini fark etti. Bundan sonra şaşırdığı her şeyi önce dikkatle gözlemlemeye karar verdi.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " artık korkmadı. Ama bu kez yalnızca kuleye bakmadı; telefonundaki resmî hava tahminlerini ve gökyüzündeki bulutları da karşılaştırdı. İnsanların hava hakkında sorular sormasının, geçmişteki basit gözlemlerden bugünkü gelişmiş ölçümlere kadar uzanan büyük bir öğrenme yolculuğu olduğunu düşündü.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eve döndüğünde balkonundan kuleyi yeniden gördü. Artık ışığa bakınca aklına yalnızca gizem gelmiyordu; orada çalışan görevlilerin emeğini de düşünüyordu. Bir veri işlenmeden, kontrol edilmeden ve doğru zamanda paylaşılmadan insanların karar vermesine yardım etmeyebilirdi. Bu farkındalıkla sınıf panosunda kendi adının çok büyük yazıldığını fark etti ve yanına "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ile Defne'nin adlarının da aynı boyda yazılmasını istedi. Çünkü bütün araştırmayı birlikte yürütmüşlerdi. Hatta kulenin işlevini öğrenmelerini sağlayan uzmanların adını da kaynak bölümüne eklediler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bilimi tek başına parlak bir fikir bulmak değil, farklı insanların ortak dikkati olarak görmeye başladı.\n\nSon kez kuleye bakan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", ilk günkü korkusunu hatırladı. Bir ışığın neden yandığını bilmemek, onu hemen tehlike saymayı gerektirmiyordu. Doğru kaynakları araştırmak, hem merakı koruyor hem de gereksiz korkuyu azaltıyordu. Sınıf arkadaşlarının da bunu anlamasını istiyordu.\n\nDefterinin son sayfasına şunu yazdı: “Her ışık bir mesaj olabilir; ama hangi mesaj olduğunu ancak doğru kaynaklarla anlayabiliriz.” Altına bir kule, bir bulut ve küçük bir soru işareti çizdi. Çünkü ona göre iyi bir araştırmacının çantasında üç şey bulunmalıydı: dikkatli gözler, sabırlı bir akıl ve yeni sorular. "
        },
        {
          "t": "isaret",
          "kod": "bulut"
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
      "metin": "Belediyeden gelen yanıta göre kuledeki ışık neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kasabaya gönderilen gizli bir mesajdı"
        },
        {
          "id": "B",
          "metin": "Bakım sırasında belirli aralıklarla yapılan bir ekipman kontrolünün parçasıydı"
        },
        {
          "id": "C",
          "metin": "Halka yönelik bir fırtına alarmıydı"
        },
        {
          "id": "D",
          "metin": "Kuleye giren birinin fenerinin ışığıydı"
        }
      ],
      "dogru": "B",
      "aciklama": "Belediyenin yanıtı, ışığın bakım sırasında yapılan ekipman kontrolünün parçası olduğunu bildiriyordu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Hava uzmanı Burcu Hanım, kuledeki ışığın görevini neden kesin söyleyemedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü ışığı hiç görmek istemiyordu"
        },
        {
          "id": "B",
          "metin": "Çünkü kule artık yıkılmıştı"
        },
        {
          "id": "C",
          "metin": "Çünkü çocukların sorusu çok kolaydı"
        },
        {
          "id": "D",
          "metin": "Çünkü yalnızca görüntüye bakarak karar verilemezdi; hangi sistem olduğunun kurumdan doğrulanması gerekiyordu"
        }
      ],
      "dogru": "D",
      "aciklama": "Uzman, görüntüye bakarak görevi kesin söyleyemeyeceğini; sistemin kurumdan doğrulanması gerektiğini belirtti."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Tuna’nın “Demek hava tahmini kehanet değil” demesi neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hava tahmini bilimsel verilere dayanan bir değerlendirmedir; kesinlik değil olasılık bildirir"
        },
        {
          "id": "B",
          "metin": "Hava tahminleri her zaman tamamen doğru çıkar"
        },
        {
          "id": "C",
          "metin": "Hava tahminlerine hiç güvenmemek gerekir"
        },
        {
          "id": "D",
          "metin": "Hava tahmini yalnızca bulutlara bakarak yapılır"
        }
      ],
      "dogru": "A",
      "aciklama": "Meryem Hanım da tahminin bilimsel verilere dayalı bir değerlendirme olduğunu söyleyerek bu sonucu onayladı."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "Hava uzmanı “Biri tahmin, biri gözlem” derken tahmin sözcüğüyle ne anlatmak istedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Geçmişte yaşanmış bir olayın kaydını"
        },
        {
          "id": "B",
          "metin": "O anda yapılan bir ölçümün sonucunu"
        },
        {
          "id": "C",
          "metin": "Eldeki verilere dayanarak gelecekte olabilecekler hakkında yapılan değerlendirmeyi"
        },
        {
          "id": "D",
          "metin": "Bir haritanın başlığını"
        }
      ],
      "dogru": "C",
      "aciklama": "Haritalardan biri yağmur olasılığını gösteren tahmin, diğeri gerçekleşen yağışı gösteren gözlemdi."
    },
    {
      "id": "s5",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "Defne, bir tahminin olasılık bildirdiğini söyledi. Burada olasılık ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir olayın olması mümkün olsa da kesin olmadığını gösteren durum"
        },
        {
          "id": "B",
          "metin": "Bir olayın kesinlikle olacağını gösteren durum"
        },
        {
          "id": "C",
          "metin": "Bir olayın hiç olmayacağını gösteren durum"
        },
        {
          "id": "D",
          "metin": "Bir olayın çoktan bittiğini gösteren durum"
        }
      ],
      "dogru": "A",
      "aciklama": "“Sağanak olasılığı bulunuyor” cümlesi sağanağın olabileceğini söyler ama kesin olduğunu söylemez."
    },
    {
      "id": "s6",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "“Uyarı varsa önlem almak doğru” cümlesinde uyarı ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Eğlenceli bir etkinlik duyurusu"
        },
        {
          "id": "B",
          "metin": "Dikkat edilmesi gereken olası bir durumu önceden bildiren haber"
        },
        {
          "id": "C",
          "metin": "Okul bahçesindeki bir masa"
        },
        {
          "id": "D",
          "metin": "Bir kitabın adı"
        }
      ],
      "dogru": "B",
      "aciklama": "Güncel hava uyarısı görülünce açık hava etkinliği ertelendi ve masalar içeri taşındı."
    },
    {
      "id": "s7",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 6,
      "metin": "Okul gazetesinde “Kulede Gizli Alarm!” başlığının “Eski Kulenin Yeni Görevi” olarak değiştirilmesi neden daha doğrudur?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü yeni başlık daha uzundur"
        },
        {
          "id": "B",
          "metin": "Çünkü ilk başlık gerçekte olmayan bir tehlike duygusu yaratırdı"
        },
        {
          "id": "C",
          "metin": "Çünkü gazetede başlık kullanılmaz"
        },
        {
          "id": "D",
          "metin": "Çünkü kule artık hiç ışık vermiyordu"
        }
      ],
      "dogru": "B",
      "aciklama": "Işığın bir alarm olmadığı öğrenilmişti; abartılı başlık kanıtlanmamış bir korku yaratacaktı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p11$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr043-kuledeki-son-isik: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p12${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr044-buz-golunun-haritasi",
    "baslik": "Buz Gölünün Haritası",
    "tur": "macera",
    "konu": "kis_yuruyusu_rota",
    "sinif_alt": 5,
    "sinif_ust": 5,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D16",
      "D20"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 5,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kesif",
        "guvenlik",
        "doga",
        "dayanisma"
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
          "id": "sozcuk_pusula_hr044",
          "tur": "lexeme",
          "etiket": "pusula",
          "yuva": "pd_pusula",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_rota_hr044",
          "tur": "lexeme",
          "etiket": "rota",
          "yuva": "pd_rota",
          "islev": "application"
        },
        {
          "id": "sozcuk_kuzey_hr044",
          "tur": "lexeme",
          "etiket": "kuzey",
          "yuva": "pd_kuzey",
          "islev": "application"
        },
        {
          "id": "kavram_hr044",
          "tur": "concept",
          "etiket": "Güvenlik için planı uygulamak ve gerektiğinde geri dönmeyi başarı saymak",
          "islev": "application"
        },
        {
          "id": "atasoz_hr044",
          "tur": "proverb",
          "etiket": "Birlikten kuvvet doğar",
          "yuva": "pd_ata_birlikten",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 2068,
        "tahmini_sure_dk": 20,
        "sayfa_sayisi": 7,
        "soru_sayisi": 7,
        "soru_beceri_dagilimi": {
          "hatirlama": 2,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 2,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 37,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Donmuş gölü görmek için çıkılan yürüyüşte hava değişti. Doğru karar ilerlemek mi, geri dönmek mi?",
    "durum": "taslak",
    "fis_kodu": "HR-044"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kış yürüyüşü başlamadan önce herkes çantasını iki kez kontrol etti. Beşinci sınıftan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", yedek eldivenlerini, suyunu ve küçük not defterini yerleştirdi. Arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise kamp lideri Ceren Hanım'ın verdiği "
        },
        {
          "t": "kelime",
          "yuva": "pd_rota"
        },
        {
          "t": "metin",
          "v": " kartını cebine koydu. Yürüyüş, dağdaki bir millî parkın izinli ve işaretli parkurunda yapılacaktı. "
        },
        {
          "t": "isaret",
          "kod": "orman"
        },
        {
          "t": "metin",
          "v": "\n\n"
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " babası yola çıkmadan önce ona küçük bir "
        },
        {
          "t": "kelime",
          "yuva": "pd_pusula"
        },
        {
          "t": "metin",
          "v": " vermişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " pusulaya bakınca iğnenin sürekli aynı yönü gösterdiğini fark etti; ama babası pusulanın tek başına rota planlamak için yeterli olmadığını anlatmıştı. Üzerinde bulundukları haritada "
        },
        {
          "t": "kelime",
          "yuva": "pd_kuzey"
        },
        {
          "t": "metin",
          "v": " oku da vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " iki bilgiyi birlikte kullanmayı denemek istiyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise eldivenleri kalın olduğu için haritayı açmakta zorlandı. “Dağda küçük işler neden bu kadar güçleşiyor?” diye söylendi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", hava koşullarının yalnızca yürüyüş hızını değil, basit hareketleri de etkileyebileceğini düşündü.\n\n“Gerçekten gölü görecek miyiz?” diye sordu "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ".\n\nCeren Hanım, “Hava ve yol şartları uygun kalırsa belirlenen seyir noktasından göreceğiz,” dedi. “Ama gölün üzerine çıkmak yok. Buzun güvenli olduğunu yalnızca görünüşünden anlayamayız.”\n\nYola çıkmadan önce Ceren Hanım küçük bir oyun hazırladı. Masaya eldiven, çikolata, oyuncak dürbün, termos, pusula ve parlak bir madalya koydu. “Hepsini taşımaya gerek yok,” dedi. “Bu yürüyüşte hangileri yararlı, hangileri yalnızca güzel görünüyor?” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " madalyayı seçince herkes güldü. “Beni hızlı yürütür,” dedi şaka yaparak. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", termosun ve uygun giysilerin daha önemli olduğunu düşündü. Liderleri, yiyecek ve suyun da yürüyüş süresi ile hava koşullarına göre planlanması gerektiğini açıkladı. Sonra acil durumda buluşacakları yeri gösterdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun gereksiz olduğunu sanmıştı; haritada başlangıç noktasına geri dönmenin kolay göründüğünü düşünüyordu. Ceren Hanım, “Bazen planı yalnızca işler yolunda giderken değil, değiştiğinde de kullanırız,” dedi.\n\nÇocuklar soğuk havada nefeslerinin beyaz buhar gibi göründüğünü fark ettiler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun su buharının soğuk havada küçük damlacıklar oluşturmasıyla ilgili olduğunu öğrenmişti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise termometredeki değeri okudu ve “Hava eksi dört!” dedi. Ceren Hanım sıcaklıkla rüzgârın birlikte nasıl hissedildiğine dikkat çekti.\n\nGrup ilk kilometrede bir gözlem yapacaktı. Karın üzerine düşen gölgeleri saymak ve güneş açısının görünüşü nasıl etkilediğini not etmek. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " başlangıçta bunun çocuk oyunu olduğunu düşündü. Sonra karın bir kısmının güneşte parladığını, ağaç gölgesindeki kısmın ise daha mat göründüğünü fark etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gözlemleri defterine çizdi. Ceren Hanım, “Karın yüzeyi her yerde aynı görünmeyebilir,” dedi. “Ama görünüş bize onun üzerinde güvenle yürüyebileceğimizi söylemez.” Grup, yalnızca işaretli ve güvenli yoldaki sıkıştırılmış kar bölümünü kullandı. Bu basit etkinlik, farkında olmadan çocuklara gözlemin sınırlarını da anlatmıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Parkurun başlangıcında iki harita vardı. Biri kısa, kolay güzergâhı; diğeri daha uzun bir gözlem yolunu gösteriyordu. Grup kısa rotayı seçecekti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Haritadaki mavi işaretler ne demek?” diye sordu. Ceren Hanım bunların su kenarlarını, kırmızı çizginin ise yürüyüş yolunu gösterdiğini anlattı.\n\nİzinli patikanın kenarında görevli, çocuklara küçük hayvan ayak izleri gösterdi. Hangi canlıya ait olduklarını hemen söylemedi; izlerin boyutunu ve biçimini karşılaştırmalarını istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " birini köpek izi sandı, "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise emin olmadığını belirtti. Ceren Hanım, izlerin yalnızca fotoğraf üzerinden kesin tanınamayabileceğini, koruma görevlilerinin bölgedeki canlıları daha iyi bildiğini söyledi. Çocuklar gördüklerini not aldı ama izleri takip etmek için patikadan ayrılmadı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " küçük bir izin peşinden gitmenin ne kadar çekici olduğunu hissetti; sonra herkesin neden belli kurallar içinde gözlem yaptığını yeniden anladı.\n\nYürürken uzakta göl göründü. Buzun bazı yerleri bembeyaz, bazı yerleri ise koyu maviydi. Işığın yansıması suyun ve buzun görünüşünü değiştiriyordu. Gölü gördüğü anda bütün yorgunluğu unutmuş gibi oldu. Ama iki dakika sonra yüzüne vuran soğuk rüzgârı hissetti. “Bir fotoğraf daha çekip hemen dönelim,” dedi. Ceren Hanım bunun yürüyüş grubunun planına göre yapılacağını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gölün bazı yerlerinin koyu, bazılarının açık görünmesine bakıp “Renk farkının nedenini yalnızca fotoğraftan söyleyemeyiz,” dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", önce koyu yerin daha kalın buz olduğunu düşünmüştü. Şimdi gözün her şeyi anlatmadığını kabul ediyordu.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " heyecanla dürbününü çıkardı. “Sanki haritanın içine girmişiz,” dedi."
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
          "v": " yürüyüş boyunca küçük bir yürüyüş günlüğü tuttu. İlk satırda “Başlangıç, hafif rüzgâr”, ikinci satırda “Çamlık, açık gökyüzü”, üçüncü satırda ise “Seyir noktası, bulutlu” yazıyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Bunları neden yazıyorsun?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Dönüşte havanın ne zaman değiştiğini hatırlamak için,” dedi. Kayıt tutmayı sıradan bir ödev gibi görmüyordu; gördüklerini sonradan doğru hatırlamaya yardım eden bir araç olarak düşünüyordu. Ceren Hanım onların notlarını görünce zamanı da eklemelerini önerdi. “İki olayın sırasını bilmek, neden–sonuç kurarken işinizi kolaylaştırır,” dedi.\n\nÖğleye doğru bulutlar çoğaldı. Ceren Hanım grubun mola vereceği noktayı belirledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", uzaktaki küçük ahşap tabelanın yanında fotoğraf çekmek istedi. Grup hâlâ izinli yolun üzerindeydi fakat "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " öne doğru birkaç adım atınca tabelanın arkasındaki dar yolun kapatıldığını gördü. Hemen geri döndü.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " elindeki eski harita çıktısı, bir yıl önceki okul etkinliğinden kalmıştı. Evde hazırlanırken tarihini kontrol etmemişti. Ceren Hanım bir yılın bazı yerler için küçük bir zaman olabileceğini, açık hava rotalarında ise güncel bilgi gerektiğini anlattı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " eski kâğıdın üstüne büyük harflerle “GÜNCEL DEĞİL” yazdı. “Bunu hatıra olarak saklarım,” dedi. “Ama yol bulmak için kullanmam.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu ayrımı beğendi. Bir bilgi geçmişi anlatmakta yararlı olabilir, bugün karar verirken ise yetersiz kalabilirdi.\n\n“Bu yol geçen yıl açıkmış,” dedi. “Neden şimdi kapalı?”\n\nRehber, bazen bakım, hava koşulları veya doğal alanların korunması nedeniyle rotaların değişebileceğini anlattı. Eski bir harita her zaman güncel olmayabilirdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " cebindeki rota kartına baktı. Kartın tarihi bu yıla aitti ve kapalı yol zaten işaretlenmişti.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Demek yalnızca yönümüzü değil, haritanın tarihini de kontrol etmeliyiz,” dedi.\n\nBir süre sonra hafif kar başladı. Ceren Hanım grubun geri dönmesine karar verdi. Dönüşte rüzgâr arttı ve uzaktaki ağaçlar beyaz bir perde arkasında silikleşti. Çocuklar liderlerine yakın yürüdüler. Parkurun işaretleri görünüyordu ama yürüyüşün başlangıcındaki manzara artık farklıydı.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kalbinin daha hızlı attığını duyuyordu. Bir an önce varmak için acele etmek istedi. Sonra Ceren Hanım'ın az önce söylediği “Dur, düşün, planı kontrol et” sözünü hatırladı. Grubun gerisindeki bir arkadaşının yürüyüş temposunu düşürdüğünü fark etti. Öğretmenleri onun yanına geçti, gerekirse dinlenme planının uygulanacağını söyledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Hepimiz beraber gidersek yavaş kalırız,” diye söylendi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ona bakıp “Birlikte başlayan bir ekip birlikte güvende dönmeli,” dedi. Ceren Hanım gülümseyerek ekledi: “"
        },
        {
          "t": "atasozu",
          "yuva": "pd_ata_birlikten"
        },
        {
          "t": "metin",
          "v": ".” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " cevap vermedi ama öne atılmak yerine grubun yanında kaldı. Bir süre sonra arkadaşları dinlenmişti; herkes aynı tempoda yürümeye devam etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Sanki geldiğimiz yol kayboldu,” diye fısıldadı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ".\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " de tedirgin olmuştu. Yine de Ceren Hanım'ın sesini duyunca rahatladı: “Duruyoruz, grubu sayıyoruz ve planımıza bakıyoruz. Kimse tek başına ilerlemiyor.”\n\nHaberleşme bitince rehberleri çocuklara bilgi verdi: “Bulunduğumuz noktayı merkeze bildirdim, hava değiştiği için planlı dönüşe devam edeceğiz.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", yetişkinlerin sakin konuşmasının kendisini ne kadar rahatlattığını fark etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da cebindeki haritayı açtı ama hemen bir yol önermedi. Bunun yerine gördüğü dönüş kavşağını işaretledi. Birkaç dakika sonra kırmızı rota levhası ortaya çıktığında ikisi de doğru yolda olduklarını anladı. Rüzgâr bazen yüzlerine vuruyordu fakat artık ne yapacakları belliydi.\n\nCeren Hanım rota kartıyla konumlarını kontrol etti, merkezle haberleşti. Yardım istemeye gerek olmadığını, yalnızca hava değişimi nedeniyle planlı geri dönüş yaptıklarını bildirdi. Böylece herkes nerede olduklarını biliyordu.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gruba dağıtılan haritada dört önemli işaret bulunduğunu fark etti: başlangıç noktası, seyir terası, mola alanı ve güvenli dönüş kavşağı. “Bende en çok başlangıç işareti kaldı,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Çünkü oraya geri dönmeyi bilmek de önemli.” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " haritayı ters tuttuğunda ilk bakışta dönüş kavşağını seçemedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kağıdı pusuladaki yöne uygun çevirmesini hatırlattı. İkisi yön işaretleriyle bulunduğu yeri ilişkilendirirken Ceren Hanım onları izledi. Bir haritayı yalnızca ezberlemek yerine kullanmayı denemek, öğrenmeyi daha kalıcı kılıyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", yolu kendi başına seçmek istemedi; bulduğu işareti rehberlerine göstererek doğruladı.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Ben yalnızca göl işaretine bakmıştım,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Ben de başta öyle. Ama bir harita hedefi gösterdiği kadar yolu da anlatıyor,” diye karşılık verdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Dönüş sırasında küçük bir ahşap köprüden geçtiler. Köprünün üzerinde birikmiş kar görevli tarafından temizlenmişti. Yavaş, sırayla yürüdüler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", başka bir grubun patika dışında kısa yoldan yürüdüğünü gördü ve bunu rehbere söyledi. Ceren Hanım ilgili görevliye haber verdi; böylece alandaki diğer ziyaretçiler de bilgilendirildi.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Onlar daha önce varabilir,” dedi.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kısa yoldan gitmenin doğru olmadığını söyleyince "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " başlangıçta karşı çıktı. “Yine de daha hızlı olabilirdik,” dedi. Ceren Hanım adımları saymalarını istedi: Hızlandıkları zaman kontrolsüz nefes alıyor, yavaşladıklarında rahatça konuşabiliyorlardı. Grup için uygun hızın, en hızlı yürüyebilen kişinin temposu olmadığını fark ettiler. Hızlı olmak sporda değerliydi ama doğa yürüyüşünde dayanıklılık, birlikte hareket etme ve karar verme de önemliydi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bunu duyunca geçen yaz bir bisiklet yarışında arkadaşını geride bırakıp yol ayrımını kaçırdığı günü hatırladı. Daha erken varacağını sanarken yanlış yola sapmıştı. Şimdi haritayı ve grubu takip etmenin neden önemli olduğunu anlıyordu.\n\n“Ama bizim amacımız bir yarış kazanmak değil,” diye yanıtladı "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Güvenle dönmek.”\n\nGrubun en arkasında yürüyen öğretmen, her öğrencinin yakınında arkadaşını görebilmesini sağlıyordu. Küçük ekip farklı hızlarda yürüdüğü için yol boyunca kısa molalar planlanmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " en başta bunları gereksiz bulmuş, enerjisi varken hızlanmak istemişti. Fakat kar yağışı ve rüzgâr arttıkça her molanın herkesi yeniden toparlamaya yardım ettiğini gördü. Gruptaki çocuklar birbirlerine nefeslerini ve adımlarını ayarlamak için zaman tanıyordu. Böylece kimse yarışın gerisinde kalmış gibi hissetmiyordu.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dönüş yolunda arkadaşlarından Ayşe'nin sessizleştiğini fark etti. “İyi misin?” diye sordu. Ayşe üşüdüğünü söyleyince durumu hemen rehberlerine iletti. Rehber uygun mola düzenini uyguladı ve herkesin giysilerini kontrol etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", yardım istemenin grubu yavaşlatmak değil, daha güvenli kılmak olduğunu gördü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da çantasındaki yedek boyunluğu Ayşe'ye önerdi; rehber uygun bulunca Ayşe rahatladı.\n\nÇocuklar dönüş kavşağındaki sarı işarete ulaştıklarında rüzgâr hafifledi. Hava yine bulutluydu. İleride başlangıç binasının çatısı göründü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " rahat bir nefes aldı. Yol boyunca soğuk hissettiğinde katmanlı giysilerini ayarlamanın, susamayı beklemeden su içmenin ve grubun temposuna uymanın yararını görmüştü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ceren Hanım dönüşte küçük bir toplantı yaptı. “Bugün hedeflediğimiz uzun parkuru bitiremedik. Sizce iyi bir gün mü geçirdik?” diye sordu. Bazı çocuklar kararsız kaldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", gölü güvenli seyir noktasından gördüklerini ve dönüşte planı uyguladıklarını söyledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise “Önce başarısız olduğumuzu sandım,” dedi. “Ama hava değişince karar değiştirebildik.” Liderleri, açık hava etkinliklerinde güvenliğin rotanın sonuna ulaşmaktan önce geldiğini açıkladı. Ceren Hanım çantalarından çıkan küçük taş, kozalak veya yaprakların hiçbirini götürmediklerini görünce teşekkür etti. Her öğrenci gördüğü bir şeyi çizmiş ya da fotoğraflamıştı. Böylece anılarının doğadaki nesneleri yerinden almadan da saklanabileceğini fark ettiler. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " defterine gölün mavi bölümünü çizdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise onu çevreleyen dağları. İki farklı resim aynı yürüyüşün başka yanlarını anlatıyordu.\n\nÇocuklar, alınan bir kararın sonucunu değerlendirirken yalnızca “vardık mı?” sorusuna bakmanın yeterli olmadığını düşündü.\n\nMerkez binasına dönünce sıcak çorbalarını içtiler. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " telefonundaki göl fotoğraflarını gösterdi. İlk fotoğrafta güneş parlıyordu, ikinci fotoğrafta aynı gölün üstünde bulutlar vardı. “İkisi de bugün çekildi,” dedi. “Ama biri yaz gibi, öbürü kış fırtınası gibi görünüyor.”\n\nCeren Hanım, hava ve ışık değiştikçe aynı manzaranın farklı algılanabileceğini anlattı. Sonra herkese küçük bir görev verdi: Yolculuğun fotoğraf albümünün yanına “gerçek rota defteri” hazırlamak. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dönüş kavşağını çizdi; "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yürüyüş saatlerini ekledi. Birlikte, hava değiştiği için planın hangi noktada değiştirildiğini işaretlediler.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " defterin kapağına “Buz Gölü Macerası” yazdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " altına başka bir cümle ekledi: “Güvenli bir macera, iyi bir planla başlar.”\n\nAnnesi gezi fotoğraflarına bakarken “En çok hangi anı hatırlayacaksın?” diye sordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yalnızca gölü göstermedi. Rüzgâr kuvvetlendiğinde birlikte durdukları kavşağın fotoğrafını da açtı. “Burada doğru karar verdik,” dedi. “Manzara kadar bunu da hatırlayacağım.”\n\nO akşam "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ailesine, gölün üzerinde yürüyemedikleri için üzülmediğini söyledi. “Yukarıdan gördüğüm manzara yeterince güzeldi,” dedi. “Hem buzun kalınlığını gözümüzle anlayamayacağımızı öğrendim.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eve döndüğünde "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " küçük kardeşi, “Dağın tepesine çıktınız mı?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çıkmadıklarını söyleyince kardeşi şaşırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " haritasını açtı, rotanın nerede değiştiğini gösterdi. “Bak, şu noktaya geldik. Sonra hava değişti. Geri dönerken öğrendiklerimiz, devam etseydik göreceğimiz bir manzaradan daha önemli olabilir,” dedi. Kardeşi haritadaki okları takip etti. “Ben de büyüyünce güvenli rota çizmeyi öğrenmek istiyorum,” diye cevap verdi.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da haritayı bir kez daha masaya serip dönüş kavşağını gösterdi. “Başlangıçta bu işareti gereksiz sandım,” dedi. “Şimdi neden haritada olduğunu çok iyi biliyorum.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onun yeni öğrendiği bu dikkatli tavrı görünce sevindi.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise en çok dönüş kararını hatırlıyordu. Rehberleri hava değişince hedeflerinden vazgeçmişti. Önce bunu başarısızlık sanmış, sonra anlamıştı: Bazen hedefe varamamak değil, doğru zamanda geri dönmek en iyi karardı.\n\nAfişi hazırlarken başka sınıflardan gelen sorular onları şaşırttı. Bir öğrenci, “Buz kalın görünüyorsa üzerine çıkabilir miyiz?” diye sordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Hayır,” dedi. “Kalınlığını gözümüzle güvenilir biçimde anlayamayız. Yetişkinlerin ve yetkililerin uyarılarına uymalıyız.” Başka bir öğrenci de benzer bir şey sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülümseyip başını salladı; haritanın önemli olduğunu ama güvenlik için tek başına yeterli sayılamayacağını tekrar söyledi. Çocuklar afişte “Yanında yetişkin rehber ve güncel rota bilgisi olsun” cümlesine de yer verdi.\n\n“Harita yanımızdaysa tek başımıza yürüyebilir miyiz?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", haritanın tek başına güvenlik sağlamadığını, uygun rota, rehberlik, hava değerlendirmesi ve haberleşmenin de önemli olduğunu anlattı. Öğretmenleri çocukların bu sorulara hazırlıklı olmasına sevindi.\n\nErtesi hafta sınıfta bir güvenli yürüyüş afişi hazırladılar. Sınıf arkadaşları onların afişine bakarken güvenli kararların bir ödev kuralından ibaret olmadığını fark etti. Hep birlikte basit bir doğa yürüyüşü kontrol listesi hazırladılar.\n\nAfişin üstünde dört işaretli rota ve büyük harflerle tek bir cümle vardı: “Doğayı seviyorsan onu tanı, kurallarına uy ve birlikte hareket et.” "
        },
        {
          "t": "isaret",
          "kod": "kalp"
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
      "metin": "Kamp lideri Ceren Hanım, gölün üzerine neden çıkılmayacağını söyledi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Göl çok uzak olduğu için"
        },
        {
          "id": "B",
          "metin": "Göl herkese kapalı bir özel alan olduğu için"
        },
        {
          "id": "C",
          "metin": "Çocukların ayakkabıları uygun olmadığı için"
        },
        {
          "id": "D",
          "metin": "Buzun güvenli olup olmadığı yalnızca görünüşünden anlaşılamayacağı için"
        }
      ],
      "dogru": "D",
      "aciklama": "Ceren Hanım, buzun güvenli olduğunu yalnızca görünüşünden anlayamayacaklarını söyledi."
    },
    {
      "id": "s2",
      "beceri": "hatirlama",
      "dayanak_sayfa": 3,
      "metin": "Bir çocuğun elindeki eski harita çıktısı neden yol bulmak için kullanılmadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü harita yırtılmıştı"
        },
        {
          "id": "B",
          "metin": "Çünkü bir yıl öncesinden kalmıştı; açık hava rotalarında güncel bilgi gerekiyordu"
        },
        {
          "id": "C",
          "metin": "Çünkü hiç kuzey oku yoktu"
        },
        {
          "id": "D",
          "metin": "Çünkü başka bir ülkenin haritasıydı"
        }
      ],
      "dogru": "B",
      "aciklama": "Çıktı bir yıl önceki etkinlikten kalmıştı; Ceren Hanım açık hava rotalarında güncel bilgi gerektiğini anlattı."
    },
    {
      "id": "s3",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Ceren Hanım yürüyüşü bitirmeden geri dönme kararını neden aldı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hava değişip kar ve rüzgâr arttığı için güvenliği her şeyin önünde tuttu"
        },
        {
          "id": "B",
          "metin": "Çocuklar yürümek istemediği için"
        },
        {
          "id": "C",
          "metin": "Harita tamamen kaybolduğu için"
        },
        {
          "id": "D",
          "metin": "Göl fotoğrafları yeterince güzel çıkmadığı için"
        }
      ],
      "dogru": "A",
      "aciklama": "Hafif kar başlayıp rüzgâr artınca geri dönüş kararı verildi; güvenlik rotanın sonuna ulaşmaktan önce geliyordu."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 7,
      "metin": "“Bazen hedefe varamamak değil, doğru zamanda geri dönmek en iyi karardır” sözü ne anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hedefe ulaşmak hiçbir zaman önemli değildir"
        },
        {
          "id": "B",
          "metin": "Yürüyüşlerde hiç hedef koymamak gerekir"
        },
        {
          "id": "C",
          "metin": "Koşullar tehlikeli hâle geldiğinde hedeften vazgeçip güvenle dönmek de bir başarıdır"
        },
        {
          "id": "D",
          "metin": "Geri dönenler her zaman yarışı kaybetmiş olur"
        }
      ],
      "dogru": "C",
      "aciklama": "Gruptaki çocuklar, hava değişince planın değiştirilmesini başarısızlık değil, doğru bir karar olarak değerlendirdi."
    },
    {
      "id": "s5",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 1,
      "metin": "Metne göre pusula ne işe yarar?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hava sıcaklığını ölçer"
        },
        {
          "id": "B",
          "metin": "İğnesi sürekli aynı yönü göstererek yön bulmaya yardım eder"
        },
        {
          "id": "C",
          "metin": "Karın kalınlığını ölçer"
        },
        {
          "id": "D",
          "metin": "Hayvan izlerini tanıtır"
        }
      ],
      "dogru": "B",
      "aciklama": "Pusulaya bakınca iğnenin sürekli aynı yönü gösterdiği görülür; ancak pusula tek başına rota planlamaya yetmez."
    },
    {
      "id": "s6",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 1,
      "metin": "Metindeki “rota kartı” ifadesinde rota ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir kampın yemek listesi"
        },
        {
          "id": "B",
          "metin": "Grubun çantasındaki eşyaların listesi"
        },
        {
          "id": "C",
          "metin": "Bir hayvanın yaşadığı yer"
        },
        {
          "id": "D",
          "metin": "Yürüyüşte izlenecek yol"
        }
      ],
      "dogru": "D",
      "aciklama": "Rota kartı, yürüyüşte izlenecek yolu ve işaretleri gösteriyordu; kapalı yol da bu kartta işaretlenmişti."
    },
    {
      "id": "s7",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 7,
      "metin": "Çocukların afişe “Yanında yetişkin rehber ve güncel rota bilgisi olsun” cümlesini eklemesi neden yerindedir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü harita güvenlik için tek başına yeterli değildir; rehberlik ve güncel bilgi de gerekir"
        },
        {
          "id": "B",
          "metin": "Çünkü haritalar hiçbir işe yaramaz"
        },
        {
          "id": "C",
          "metin": "Çünkü yetişkinler yürüyüşe katılmak ister"
        },
        {
          "id": "D",
          "metin": "Çünkü afişin boş yerini doldurmak gerekir"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuklar haritanın önemli olduğunu ama tek başına güvenlik sağlamadığını, rehberlik ve güncel bilginin de gerektiğini anlattı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p12$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr044-buz-golunun-haritasi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p13${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr045-kutuphanenin-on-ucuncu-rafi",
    "baslik": "Kütüphanenin On Üçüncü Rafı",
    "tur": "gizem",
    "konu": "kutuphane_kayip_raf",
    "sinif_alt": 5,
    "sinif_ust": 5,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D6",
      "D8"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 5,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "gizem",
        "okuma_kitap",
        "kultur_miras"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D6",
        "yardimci_deger": "D8"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_emanet_hr045",
          "tur": "lexeme",
          "etiket": "emanet",
          "yuva": "pd_emanet",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_bagis_hr045",
          "tur": "lexeme",
          "etiket": "bağış",
          "yuva": "pd_bagis",
          "islev": "application"
        },
        {
          "id": "sozcuk_arsiv_hr045",
          "tur": "lexeme",
          "etiket": "arşiv",
          "yuva": "pd_arsiv",
          "islev": "application"
        },
        {
          "id": "kavram_hr045",
          "tur": "concept",
          "etiket": "Kayıtları karşılaştırarak kanıt aramak; eski belgelerdeki kişisel bilgileri korumak",
          "islev": "application"
        },
        {
          "id": "atasoz_hr045",
          "tur": "proverb",
          "etiket": "İyilik eden iyilik bulur",
          "yuva": "pd_ata_iyilik",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 2066,
        "tahmini_sure_dk": 20,
        "sayfa_sayisi": 7,
        "soru_sayisi": 7,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 3,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 39,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Rafların numarası 12'den 14'e atlıyor. On üçüncü raf nerede? Cevap eski kayıtlarda saklı.",
    "durum": "taslak",
    "fis_kodu": "HR-045"
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
          "v": ", okul kütüphanesinin yeni düzenleneceğini duyunca ilk gönüllülerden biri oldu. Kitapları taşımak yerine etiketlerini kontrol etmeyi seviyordu. Çünkü bir kitabın nerede durduğunu bilmek, bazen içindekileri okumak kadar ilginçti. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        },
        {
          "t": "metin",
          "v": "\n\nKütüphane görevlisi Sevim Hanım, rafların yenileneceğini, eski kayıtların bilgisayara aktarılacağını anlattı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bu görevi önce sıkıcı bulmuştu. Okul gazetesinde gizemli olaylar hakkında yazdığı için kendisine daha heyecanlı bir iş verilmesini bekliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise katalogların da şaşırtıcı sorular doğurabileceğini düşünüyordu. “Bir kitap yanlış raftaysa onu arayan biri bulamaz,” dedi. “Bazen doğru hikâyeye ulaşmak, doğru etiketten geçer.” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gülerek “Peki bugün bir sır çıkarsa haber ver,” diye karşılık verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onun bu sözünü gün boyunca hatırlayacaktı.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ve arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " işi, kitapların sırtındaki numaraları raf listesindeki yerleriyle karşılaştırmaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk on iki rafı hızla kontrol etti. Ancak listenin sonraki sayfasında tuhaf bir boşluk vardı: Raf 12'nin ardından Raf 14 geliyordu.\n\n“On üçüncü raf nerede?” diye sordu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ".\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " omuz silkti. “Belki uğursuz saydıkları için atlamışlardır.”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülümsemedi. Bir okul kütüphanesinin böyle bir nedenle raf atlamasını mantıklı bulmuyordu. Sevim Hanım da şaşırdı. “Eskiden burada ahşap dolaplar vardı,” dedi. “Yeni sistem kurulurken numaralar değişmiş olabilir. Eski defterlere bakalım.”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eski defterin ilk sayfasında bir tarih aradı. Dış kapağın üzerinde yıl yazmıyordu; ama son sayfada mürekkebi biraz solmuş bir mühür vardı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " büyüteci getirince rakamlar daha kolay okunur oldu. “Demek bu kayıtlar en azından o tarihte kullanılıyormuş,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Sonra planın üzerine güncel kütüphane çizimini yerleştirdi. İki planın giriş kapıları aynı yerdeydi fakat masa ve dolapların konumları farklıydı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “On üçüncü rafın yerinde şimdi koltuk var,” diye şaşırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Bir odanın değişmesi, içindeki hikâyelerin de değiştiği anlamına gelmez,” dedi. Bu cümleyi tam olarak niçin söylediğini kendisi de bilmiyordu. Belki yıllardır aynı odada başka başka çocukların kitap okuduğunu düşündüğü içindi.\n\nİlk defterde rafların el çizimi bir planı vardı. Planın ortasında küçük bir dolap görünüyordu. Yanına yalnızca “Emanet” yazılmıştı. Dolabın numarası ise silinmişti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Bütün gizem bu kelimede,” diye fısıldadı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise hemen sonuç çıkarmadı. Emanet, birine geçici olarak bırakılan şey demekti; ancak burada neyin emanet edildiği belli değildi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi gün iki arkadaş dijital katalogla eski kayıtları karşılaştırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir kitap başlığının iki defterde farklı biçimde yazıldığını fark etti. Birinde “Yolun Rengi”, diğerinde “Yolların Rengi” vardı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " aynı kitap sanıp numarayı işaretleyecekti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onu durdurdu. “Yazar adı aynı mı? Baskı yılı aynı mı?” diye sordu.\n\nİncelediklerinde bunların farklı kitaplar olduğunu öğrendiler. Küçük bir harf farkı bile kayıtların karışmasına yol açabiliyordu. Bu kez "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " dikkatli çalışmaya başladı. Bir kitabın yalnızca kapağına değil, künyesine de baktı.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kayıt defterinin üstünde bir silinti gördü. Hemen biri bilgi saklamış olabilir diye düşündü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " silinen yere dikkatle baktı, sonra eski kayıtlarda mürekkeplerin zamanla solabileceğini hatırladı. Sevim Hanım, belge uzmanlığı olmadan bunun nedenini kesinleştiremeyeceklerini söyledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " iddiasını geri çekti. “Gizemi seviyorum diye kötü bir olay uydurmamalıyım,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " için bu cümle araştırmalarının yönünü belirleyen küçük bir dönüm noktasıydı.\n\nÜçüncü defterin arasında eski bir makbuz kopyası buldular. Üzerinde otuz kitaplık bir bağıştan söz ediliyordu. Fakat bağışın kayıt numaraları tam değildi. O akşam "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " evde aile kitaplığının fotoğrafını çekip "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " gönderdi. Fotoğrafta bazı kitaplar boylarına göre dizilmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " “Siz kitapları yazarlarına göre mi ayırıyorsunuz?” diye sordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", hiç düşünmediğini söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " de bütün evlerin aynı düzende olmak zorunda olmadığını fark etti. Ama okul kütüphanesi ortak kullanım içindi; bir öğrenci kitabı aldığı yerde bulabilmeliydi. Bunun için kuralların herkes tarafından anlaşılması gerekiyordu.\n\nSevim Hanım, bazı yıllarda el yazısıyla tutulan kayıtların bilgisayara eksik aktarılabildiğini söyledi.\n\n“O zaman on üçüncü raf gerçekten kaybolmuş olabilir,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ".\n\n“Raf kaybolmaz,” diye karşılık verdi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Belki sadece adı değişmiştir.”\n\nTabloyu hazırlarken "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir başka ayrıntı buldu. Bazı numaraların yanına küçük yıldızlar çizilmişti. Önce bunları özel kitapların işareti sandılar. Sevim Hanım, eski görev çizelgesini getirip bu yıldızların o gün sayımı yapılan kitapları gösterdiğini anlattı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir an durup “Biz de bu defteri okuyan başka çocuklar için açıklama hazırlamalıyız,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " buna sevindi. Çünkü bir gün defteri başkası açtığında aynı soruları sormak zorunda kalmayabilirdi. İkili basit bir işaret açıklaması sayfası oluşturdu. Emin olduklarını açık yazdılar; emin olamadıklarının yanına soru işareti koydular."
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
          "v": " ve "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", sıradan görünen bir sembolün yalnızca kayıt sistemini bilince anlam kazandığını fark etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Bir kitaba yıldız koyunca değerli, başka kitaba koymayınca değersiz olmuyor,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Tabii ki. İşaret, onu kullanan kişinin ne anlatmak istediğine bağlı,” diye cevap verdi. Böylece tablolarına “işaretin olası anlamı” sütununu da eklediler.\n\nİki arkadaş sorularını bir tabloda topladı. İlk sütunda kitap numaraları, ikinci sütunda kayıt tarihleri, üçüncü sütunda bulunduğu yer yazıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çizelgeyi renklendirdiğinde birbirine benzeyen kayıtların aslında farklı dönemlere ait olduğunu gördü. En eski kayıtlar, binanın tadilatından önceki döneme uzanıyordu.\n\nSevim Hanım, okulun "
        },
        {
          "t": "kelime",
          "yuva": "pd_arsiv"
        },
        {
          "t": "metin",
          "v": " sorumlusundan eski bina planını istedi. Plan geldiğinde üçü birlikte masaya açtı. On üçüncü rafın bulunduğu yerde bugün küçük bir okuma köşesi vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", eski plandaki koltuğun bulunduğu yere yürüdü. Çocukların bugün sessizce kitap okuduğu köşe bir zamanlar farklı bir amaçla kullanılmıştı. Bir mekânın geçmişini bilmek, ona daha dikkatli bakmasını sağladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de köşedeki küçük lambaya baktı. “Kayıp raf yerine okuma koltuğu gelmiş,” dedi. “Aslında burası hâlâ kitaplara hizmet ediyor.” İkisi aynı odayı şimdi daha farklı görüyordu.\n\nEski ahşap dolap ise yıllar önce başka bir odaya taşınmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hayalindeki gizli koridoru bulamamıştı ama yine de heyecanlandı. Çünkü aradıkları şeyin nereye götürüldüğünü öğrenmişlerdi.\n\nDepo okulun içinde, görevli eşliğinde girilen düzenli bir alandı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kapıda biraz durdu; eski eşyaların üstünde toz olduğunu görünce hapşırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", dolabı hemen açmak istiyordu ama Sevim Hanım önce uygun eldiven ve temiz çalışma yüzeyi hazırladı. “Eski belgeler bazen kırılgan olur,” dedi. “Bulduğumuz şeyi koruyamazsak bilgiyi de kaybedebiliriz.” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", araştırmacıların neden acele etmemesi gerektiğini bu kez daha iyi anladı. Meraklarının hızlı koşmasına izin verebilirlerdi ama elleri sakin davranmalıydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Okul yönetiminin izniyle depodaki eski dolap incelendi. Dolapta birkaç boş çekmece, kullanılmayan kitap destekleri ve üstünde “Bağışlar” yazan kalın bir defter vardı. Sevim Hanım defteri dikkatle açtı. Sayfalar sararmıştı ama kayıtların çoğu okunuyordu.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Büyük hazineyi bulduk!” dedi.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defteri eline almadan önce durdu. “Burada insanların isimleri olabilir. Her şeyi fotoğraflayıp paylaşmamalıyız,” dedi. Sevim Hanım onu onayladı. Eski kayıtların da kişisel bilgiler içerebileceğini, kullanılacak bilgilerin dikkatle seçilmesi gerektiğini anlattı.\n\nSayfaları çevirirken kitap türlerinin zamanla nasıl değiştiğini gördüler. En eski kayıtlarda masal ve ansiklopedi çoktu. Daha sonraki yıllarda bilim dergileri, çizgi romanlar ve çocuk romanları artmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir kitap türünü diğerinden üstün saymadı. Farklı zamanlarda, farklı çocukların farklı merakları olabileceğini düşündü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Büyükbabamın sevdiği hikâyeyle benim sevdiğim aynı olmak zorunda değil,” dedi. Sevim Hanım başını salladı. “Önemli olan doğru kitapla doğru okurun buluşması.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu sözleri küçük bir kartın üzerine yazdı; kütüphane düzenlenince görünür bir yere asmak istiyordu.\n\nDefterde, yıllar önce mahallede yaşayan insanların okul kütüphanesine kitap gönderdiği yazıyordu. Bazı bağışlar tek kitaptı; bazıları ise bir sınıf dolusu. Bir sayfanın kenarına şu not düşülmüştü: “Bu kitapları okuyacak çocuklarla hiç tanışmayacağım. Yine de hepsine iyi yolculuklar dilerim.” Sevim Hanım usulca bir atasözü söyledi: “"
        },
        {
          "t": "atasozu",
          "yuva": "pd_ata_iyilik"
        },
        {
          "t": "metin",
          "v": ".”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ertesi akşam kütüphanedeki gönüllü çalışmalarını anlatırken annesi ona kendi çocukluğunda okuduğu bir kitabın adını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kitabı aradığında yeni raflarda bulamadı. Sevim Hanım'a danışınca kitabın başka bir kütüphanede bulunabileceğini öğrendi. O an her kitabın tek bir rafta bulunmayacağını, kütüphanelerin birbirine bilgi sağlayabileceğini düşündü. Araştırması onu yalnızca geçmişe değil, farklı okuma yollarına da götürmüştü."
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
          "v": " notu okuyunca gözleri doldu. Bir kitabı hiç tanımadığı başka bir çocuğa gönderen kişinin ne kadar umutlu olması gerektiğini düşündü. On üçüncü rafın gizemi, ona bir odadan daha büyük bir şey göstermişti: Okulun zaman içinde büyüyen ortak hafızasını.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " akşam evde kardeşine araştırmalarını anlatırken “Emanet” kelimesini kullandı. Kardeşi, “Bana emanet ettiğin oyuncağı geri verdiğimde de aynı kelimeyi söylüyorsun,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güldü. “Evet, çünkü "
        },
        {
          "t": "kelime",
          "yuva": "pd_emanet"
        },
        {
          "t": "metin",
          "v": " alınan şeyi dikkatle korumamız gerekir.” Sonra kütüphanedeki eski kitapları düşündü. Kitaplar, onları daha sonra okuyacak çocuklara kadar uzanan bir emanet gibiydi. Evinin rafındaki kitabı yerine koyarken yıpranmış bir sayfanın köşesini düzeltti. Bu küçük hareket, ertesi gün kütüphanede yapacağı işin anlamını değiştirmişti. Artık yalnızca bir gizemi çözmüyor, kitapları gelecek okurlar için koruyordu.\n\nKayıtları incelerken "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yeni bir sorun fark etti. Bağış defterindeki bir kitap, dijital katalogda hiç görünmüyordu. Acaba kayıp mıydı? "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kitabın adını yeniden kontrol etti, yazarı ve sayfa sayısını not aldı. Sonra arama sonuçlarında farklı bir yazımla benzer bir kayıt buldu. Kitap vardı; yalnızca başlığı sisteme yanlış geçirilmişti.\n\n“Bu durumda kimse onu aradığında bulamaz,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ".\n\nSevim Hanım, eski ve yeni bilgileri karşılaştırarak düzeltme yapılabileceğini söyledi. Çocuklar kitabı rafında buldu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sırtını düzeltti, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kaydın doğru kitapla eşleştiğini işaretledi.\n\nAfişi tasarlamak da kolay olmamıştı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ilk taslağa “Kayıp Hazine Bulundu!” başlığını atmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun eğlenceli fakat yanıltıcı olduğunu söyledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " önce “Kimse sıradan bağış defterini okumaz,” diye itiraz etti. Sonra Sevim Hanım onlara eski defterdeki güzel dileği yeniden gösterdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Bence asıl ilginç olan bu,” dedi. İkili sonunda afişe “On Üçüncü Rafın Unutulan İyiliği” adını verdi. Böylece dikkat çekici bir başlığın gerçekleri değiştirmeden de yazılabileceğini gördüler.\n\nO gün pek çok çocuk kütüphaneye geldiğinde yeni bir afiş gördü: “Bir kitabın yolculuğunu merak ettiniz mi?” Afişte kişisel bilgi bulunmuyordu. Yalnızca okul kütüphanesine yıllar boyunca yapılan bağışların sayısı, kitap türleri ve okuma köşesinin geçmişi anlatılıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Birinci sınıftan bir öğrenci afişin önünde durup sordu: “Bütün bu kitapları kim getirmiş?”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Çok farklı insanlar,” diye cevap verdi. “Bazıları kendi adını bırakmış, bazıları yalnızca kitaplarını. Ama hepsi bir gün birinin okumasını istemiş.”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yeni düzende bir başka yenilik önerdi: Her rafta yalnızca numara değil, türün adı da yazılacaktı. Böylece özellikle küçük öğrenciler aradıkları kitapları daha kolay bulabilecekti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " renkli etiketlerin tasarımını yaptı. Sevim Hanım deneme için üç küçük öğrenciyi davet etti. Çocuklar en sevdikleri masal türünü birkaç dakika içinde bulabildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Araştırmamız başka okurların işini de kolaylaştırdı,” diye sevindi. On üçüncü rafın hikâyesi yeni düzenlemenin arkasında gizli kalmamış, kütüphaneyi daha kullanışlı kılmıştı.\n\nHaftanın sonunda yeni raf numaraları yerleştirildi. Bu kez hiçbir boşluk yoktu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " eski on üçüncü rafın yerine küçük bir işaret hazırladı: “Bir zamanlar burada bağış kitaplarının emanet dolabı bulunuyordu.” Sevim Hanım işareti okuma köşesine astı.\n\nSevim Hanım küçük bir kütüphane etkinliği düzenlemelerini istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ile "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", öğrencilere eski raf planını gösterip güncel planla karşılaştırmalarını önerdi. Küçük bir grup boş olan on üçüncü numarayı hemen fark etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " soruya doğrudan cevap vermek yerine “Sizce neden boş?” diye sordu. Çocuklar farklı fikirler üretti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", eski dolabın fotoğrafını gösterince hep birlikte bu değişimin nedenini konuştular. Oyun sonunda öğrenciler bir kütüphanedeki düzenin de zamanla gelişebileceğini fark etti.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " eski raf planının bir kopyasını yeni planla yan yana astı. Böylece gelen ziyaretçiler iki farklı dönemi karşılaştırabiliyordu. Bir öğrenci “Peki sonraki yıllarda bu köşe yine değişir mi?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Değişebilir,” dedi. “Önemli olan değişirken geçmişi de anlamak.” Sevim Hanım onların hazırladığı açıklama kartlarını görünce her ikisine de teşekkür etti. Çocukların merakı kütüphanenin yalnızca geçmişini değil, bugünkü kullanımını da güzelleştirmişti.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", gizemi çözdükleri için sevinçliydi ama buldukları defterin korunmasına daha çok önem veriyordu. Kaybolmuş bir kayıt, eski bir eşyanın yok olması anlamına gelmiyordu. Bazen doğru soruyu sormak, insanlara geçmişin izlerini yeniden görme fırsatı veriyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sevim Hanım onları kapıdan uğurlarken iki küçük teşekkür kartı verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kartta “Titizliğiniz sayesinde eski kayıtlar daha anlaşılır oldu” yazısını gördü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Kitapların içinde sır ararken işimizin bu kadar işe yarayacağını düşünmemiştim,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " de aynı duygudaydı. Sır çözmek güzel bir başlangıçtı; ortaya çıkan bilgiyi başkalarıyla paylaşmak ise hikâyeyi tamamlıyordu.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " çıkışta, “Bir gün başka kayıp raf bulursak birlikte araştıralım mı?” diye sordu.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güldü. “Önce gerçekten kayıp mı diye kontrol ederiz.”\n\n“Peki kayıp değilse?”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kütüphaneyi artık yalnızca macera aradığı bir yer değil, başkalarıyla paylaşabileceği bir çalışma alanı olarak gördüğünü fark etti. İki arkadaş gelecek hafta küçük öğrencilere kitap seçmede yardımcı olmaya söz verdi.\n\n“O zaman da neden öyle göründüğünü öğreniriz.”\n\nBir sonraki hafta kütüphaneye gelen çocukların sayısı biraz arttı. Özellikle "
        },
        {
          "t": "kelime",
          "yuva": "pd_bagis"
        },
        {
          "t": "metin",
          "v": " defteriyle ilgili afiş, okuma köşesine yeni ziyaretçiler çekiyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bunu okul gazetesi için bir habere dönüştürdü. Haberde kimin hangi kitabı bağışladığını değil, eski rafın nasıl bulunduğunu ve kayıtların neden korunduğunu anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yazıyı okuduğunda hoşuna giden bir cümle vardı: “Kütüphaneler yalnızca kitapları değil, okurların birbirlerine bıraktığı yolları da saklar.” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " artık gizem bulmak kadar onu doğru anlatmaktan da zevk alıyordu.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " artık kitap iade tarihi geldiğinde bunu bir yük olarak görmeyecekti. Kitabı zamanında geri getirirse başka bir okur onu beklediği yerde bulabilecekti.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bir kitabın üzerine yazılmış eski numaranın bile ona ait bir yolculuğu anlatabileceğini düşünüyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ile birlikte buldukları defter, onu kitaplara daha yakından bakmaya davet etmişti. Artık kütüphaneye girdiğinde yalnızca yeni hikâye değil, eski bir iz de görebiliyordu.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " o gün eve giderken çantasındaki kitabı biraz daha dikkatli taşıdı. Bir kitabın yalnızca içindeki hikâyeyi değil, onu yazanın, bağışlayanın, koruyanın ve okuyanın yolculuklarını da taşıyabileceğini anlamıştı. "
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
      "dayanak_sayfa": 3,
      "metin": "Eski kayıtlara göre “Emanet” yazılı dolap sonunda nerede bulundu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Okul bahçesindeki bir kulübede"
        },
        {
          "id": "B",
          "metin": "Yıllar önce okulun içinde başka bir odaya, depoya taşınmıştı"
        },
        {
          "id": "C",
          "metin": "Başka bir okulun kütüphanesinde"
        },
        {
          "id": "D",
          "metin": "Hiçbir zaman bulunamadı"
        }
      ],
      "dogru": "B",
      "aciklama": "Eski ahşap dolap yıllar önce başka bir odaya taşınmıştı; depoda görevli eşliğinde incelendi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Sevim Hanım, bağış defterindeki her sayfanın fotoğraflanıp paylaşılmasının doğru olmadığını neden onayladı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü defter çok eskiydi ve fotoğraflanamazdı"
        },
        {
          "id": "B",
          "metin": "Çünkü eski kayıtlarda kişisel bilgiler, örneğin insanların isimleri olabilirdi"
        },
        {
          "id": "C",
          "metin": "Çünkü defterin sayfaları boştu"
        },
        {
          "id": "D",
          "metin": "Çünkü kimse fotoğraf makinesi getirmemişti"
        }
      ],
      "dogru": "B",
      "aciklama": "Defterde insanların isimleri olabileceği için eski kayıtlardaki kişisel bilgilerin dikkatle seçilmesi gerekiyordu."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Defterin kenarındaki “Bu kitapları okuyacak çocuklarla hiç tanışmayacağım. Yine de hepsine iyi yolculuklar dilerim” notu neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bağışçının kitapları geri istediğini"
        },
        {
          "id": "B",
          "metin": "Bağışçının kütüphaneyi hiç sevmediğini"
        },
        {
          "id": "C",
          "metin": "Bağışçının defteri yanlışlıkla bıraktığını"
        },
        {
          "id": "D",
          "metin": "Bağışçının, tanımadığı okurlar için de iyilik düşündüğünü"
        }
      ],
      "dogru": "D",
      "aciklama": "Bağışçı okurlarla hiç tanışmayacağını bilse de onlara iyi yolculuklar dilemişti."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 5,
      "metin": "“Emanet alınan şeyi dikkatle korumamız gerekir” cümlesinde emanet ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Birine geçici olarak bırakılan ve korunması beklenen şey"
        },
        {
          "id": "B",
          "metin": "Kimsenin istemediği eski eşya"
        },
        {
          "id": "C",
          "metin": "Kütüphanede satılan kitap"
        },
        {
          "id": "D",
          "metin": "Çöpe atılan kâğıt"
        }
      ],
      "dogru": "A",
      "aciklama": "Kardeşin oyuncağı geri verirken kullanılan ‘emanet’ sözcüğü, korunması gereken geçici bırakılan şey anlamındadır."
    },
    {
      "id": "s5",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 7,
      "metin": "“Bağış defteriyle ilgili afiş” ifadesinde bağış ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir kitabı ödünç alıp geri getirmek"
        },
        {
          "id": "B",
          "metin": "Bir kitabı yırtmak"
        },
        {
          "id": "C",
          "metin": "Karşılık beklemeden kitap ya da eşya vermek"
        },
        {
          "id": "D",
          "metin": "Bir kitabı satın almak"
        }
      ],
      "dogru": "C",
      "aciklama": "Mahalledeki insanlar kütüphaneye karşılık beklemeden kitap göndermişti; defterde bu bağışlar kayıtlıydı."
    },
    {
      "id": "s6",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "Metindeki arşiv sorumlusu ne işle ilgilenir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Eski belge ve kayıtların düzenli biçimde saklandığı yerle"
        },
        {
          "id": "B",
          "metin": "Okulun bahçesindeki ağaçlarla"
        },
        {
          "id": "C",
          "metin": "Okulun yemek listesiyle"
        },
        {
          "id": "D",
          "metin": "Okulun spor müsabakalarıyla"
        }
      ],
      "dogru": "A",
      "aciklama": "Sevim Hanım, eski bina planını okulun arşiv sorumlusundan istedi; arşiv eski belgelerin saklandığı yerdir."
    },
    {
      "id": "s7",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 5,
      "metin": "Afişe “Kayıp Hazine Bulundu!” yerine “On Üçüncü Rafın Unutulan İyiliği” başlığının konması neden daha doğrudur?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü ilk başlık çok kısaydı"
        },
        {
          "id": "B",
          "metin": "Çünkü afişlerde başlık olmaması gerekir"
        },
        {
          "id": "C",
          "metin": "Çünkü hazine gerçekten bulunmuştu"
        },
        {
          "id": "D",
          "metin": "Çünkü yeni başlık gerçekleri değiştirmeden de dikkat çekiyordu; ilki ise yanıltıcıydı"
        }
      ],
      "dogru": "D",
      "aciklama": "Ortada bir hazine yoktu; dikkat çekici ama doğru bir başlıkla gerçekler değiştirilmeden anlatıldı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p13$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr045-kutuphanenin-on-ucuncu-rafi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p14${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr046-bilinmeyen-posta-pulu",
    "baslik": "Bilinmeyen Posta Pulu",
    "tur": "gizem",
    "konu": "fotograf_tarihleme",
    "sinif_alt": 6,
    "sinif_ust": 6,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D6",
      "D8"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 6,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "gizem",
        "kultur_miras",
        "okul"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D6",
        "yardimci_deger": "D8"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_kanit_hr046",
          "tur": "lexeme",
          "etiket": "kanıt",
          "yuva": "pd_kanit",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_damga_hr046",
          "tur": "lexeme",
          "etiket": "damga",
          "yuva": "pd_damga",
          "islev": "application"
        },
        {
          "id": "sozcuk_tarihleme_hr046",
          "tur": "lexeme",
          "etiket": "tarihleme",
          "yuva": "pd_tarihleme",
          "islev": "application"
        },
        {
          "id": "kavram_hr046",
          "tur": "concept",
          "etiket": "Kanıt ile varsayımı ayırmak; bilinmeyeni açıkça belirtmek ve kişisel bilgileri korumak",
          "islev": "application"
        },
        {
          "id": "atasoz_hr046",
          "tur": "proverb",
          "etiket": "Acele işe şeytan karışır",
          "yuva": "pd_ata_acele",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 3042,
        "tahmini_sure_dk": 27,
        "sayfa_sayisi": 9,
        "soru_sayisi": 8,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 2,
          "yorumlama": 1,
          "sozcuk_baglami": 3,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 44,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Duvardaki fotoğrafın altında yazan yıl doğru mu? Bir pul, bir zarf ve eski kayıtlar ipucu veriyor.",
    "durum": "taslak",
    "fis_kodu": "HR-046"
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
          "v": " yanında çalışan "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " çok az konuşan bir öğrenciydi. Büyük kalabalıklarda düşüncelerini söylemeden önce uzun süre beklerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise aklına geleni hemen seslendirirdi. Araştırma masasında birlikte oldukları ilk gün "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " sözünü iki kez kesmişti. İkincisinde "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " defterini kapatıp uzaklaştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " nedenini akşam evde düşündü. Ertesi gün “Ben acele ettim, senin fikrini dinlemedim,” dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gülümsedi ve fotoğrafın kenarında fark ettiği ayrıntıyı gösterdi. İkisi farklı çalışıyordu, ama ikisinin de dikkatine ihtiyaç vardı. Bundan sonra sırayla konuşup her ipucunu birlikte değerlendirmeye karar verdiler. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        },
        {
          "t": "metin",
          "v": "\n\nSerginin hazırlıkları üç haftadır sürüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", fotoğrafları asan ekibe yardım ederken birbirine benzeyen karelerin ne kadar farklı hikâyeler anlatabileceğini fark etmişti. Bazılarında tören kıyafetleri, bazılarında sıradan okul günleri vardı. Bir fotoğrafta tek bir kişinin adı bilinirken, diğerinde koca bir sınıfın yalnızca yılı yazıyordu. Sibel Hanım her fotoğrafın altına “Bu bilgiyi nereden biliyoruz?” sorusunu yazmalarını istemişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce bunu gereksiz buldu. Ona göre eski fotoğraf kendi başına yeterince gerçekti. Fakat etiketteki tarihi sorgulamaya başladığında bir fotoğrafın gerçekten var olmasının, altında yazan her bilginin doğru olduğu anlamına gelmediğini gördü.\n\nOkulun kuruluş yıldönümü sergisinde en çok konuşulan şey yeni spor salonu değil, duvardaki eski bir fotoğraftı. Fotoğrafın altında “1984'te İlk Mezunlarımız” yazıyordu. Fakat fotoğraftaki çocukların önünde duran postane binası, bugünkü yerine taşınmadan önceki eski binaya benziyordu. Altıncı sınıftan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu fark etti çünkü dedesi ona kasabanın eski fotoğraflarını göstermişti.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", tartışmanın başladığı ilk gün fotoğrafa çok yakın durup arka plandaki küçük ayrıntıları kaçırmıştı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ondan birkaç adım geriye gelmesini istedi. Böylece kadrajın tamamını görebildi. Ön planda öğrenciler vardı, arkada ise iki farklı bina seçiliyordu. “Bazen ayrıntı için yaklaşmak, bütünü görmek için uzaklaşmak gerekir,” dedi "
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
          "v": " bu cümleyi beğendi; araştırmalarında da aynı yaklaşımın işe yarayabileceğini düşünmeye başladı.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", fotoğrafın önünde arkadaşlarıyla konuşurken "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " başka bir ayrıntı fark etti. Binanın önünde bekleyen bisikletin modeli eskiydi ama hangi yıllarda kullanıldığını bilmiyorlardı. “Bu ipucuyla yıllar arasında tahmin yapabilir miyiz?” diye sordu. Sibel Hanım, farklı ipuçlarını birlikte değerlendirebileceklerini söyledi; ancak bir bisiklet modelinin satıldığı yılın fotoğrafın kesin çekim yılı sayılamayacağını da ekledi. Çünkü insanlar bir eşyayı uzun yıllar kullanabilirdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " fotoğrafın kenarına görünmez bir soru işareti koymuş gibi hissetti. Tek bir resim, beklediğinden daha fazla bilgi ve daha fazla belirsizlik taşıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sergiyi hazırlayan öğretmenleri Sibel Hanım, “Bu fotoğraf arşivden böyle gelmiş,” dedi. “Yanlış olduğunu düşünüyorsanız "
        },
        {
          "t": "kelime",
          "yuva": "pd_kanit"
        },
        {
          "t": "metin",
          "v": " bulabiliriz.”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " masanın ortasına fotoğrafın renkli bir kopyasını koydu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kenarına boş bir kâğıt yerleştirdi; ilerledikçe buldukları kanıtları aynı yerde tutacaklardı. İkisi farklı kalem renkleri kullandı: maviyle gördüklerini, turuncuyla tahminlerini yazdılar. Bu düzen, daha sonra bir tahminin nasıl yanlışlıkla kesin bilgiye dönüşebileceğini fark etmelerine yardım edecekti.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ile arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " araştırma masası kurdu. İlk bakışta fotoğrafın tarihini değiştirmek kolay görünüyordu: “Dedem öyle dedi,” yazmaları yeterli sanmışlardı. Fakat Sibel Hanım birinin hatırladığı şeyin değerli bir ipucu olabileceğini, tek başına kesin kanıt sayılmayacağını anlattı.\n\nDede Ali, torununun heyecanını görünce çocukluğunu anlatmaya başladı. İlkokula giderken okul yolunun iki yanında kavak ağaçları olduğunu, postanenin yanından geçerken her gün aynı saatlerde bisikletli bir dağıtıcı gördüğünü hatırlıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hikâyeyi dinlerken notlar aldı. Sonra dedesinin iki kez durup “Yoksa o ağaçlar başka sokakta mıydı?” dediğini duydu. Büyüklerin anılarının bazen birbirine karışabileceğini ilk kez bu kadar açık gördü. Dedesi bundan utanmadı; tam tersine, eski adres defterini bularak hatırladıklarını kontrol etmek istedi. "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " araştırması artık geçmişte olanları tahmin etmekten çok, farklı hatıraları belgelerle karşılaştırma işine dönüşüyordu.\n\nO gün "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eve gittiğinde dedesine fotoğrafı gösterdi. Dede uzun süre baktı. “Bu bina eski postane,” dedi. “Ama ne zaman taşındığını tam hatırlamıyorum. Benim belleğim de yanıltabilir.” Sonra eski bir kutudan sararmış zarflar çıkardı. Birinin üzerinde renkli, bilinmeyen bir posta pulu vardı. Zarfın arkasında okulun eski adresi yazıyordu. Pulun kenarındaki "
        },
        {
          "t": "kelime",
          "yuva": "pd_damga"
        },
        {
          "t": "metin",
          "v": " ise yarım basılmıştı.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " heyecanı arttı. “Belki fotoğrafın tarihini bu pul söyleyecek!”\n\nDedesi zarfı ona vermeden önce uyardı: “Bu eski bir aile belgesi. İzin almadan paylaşmayacaksın. Bir de dikkat et, pulun basıldığı yıl mektubun gönderildiği yılla aynı olmayabilir.”\n\nDede Ali gece yatmadan önce "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " bir hikâye daha anlattı. Gençken mektupları postaya vermek için kasabanın diğer ucuna yürüdüğünü, bazen de cevabı haftalarca beklediğini söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bugün bir mesaj gönderdikten sonra birkaç saniye içinde karşılık beklemeye alışmıştı. “O kadar beklemek zor değil miydi?” diye sordu. Dedesi, “Bazen zordu, ama her haber geldiğinde zarfı dikkatle açardık,” dedi. Sonra eski zarfa işaret etti. “Bu da birinin yolculuğundan kalan iz.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk kez pulun yalnızca tarihle ilgili bir bulmaca değil, insanların birbiriyle haberleşme ihtiyacının parçası olduğunu düşündü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ailesi eski kartpostallar topluyordu. Bu yüzden "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", zarflarda bazen iki farklı tarih bulunabildiğini biliyordu: mektubun yazıldığı tarih ve postaya verildiği tarih. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " şaşırdı. “Aynı gün olmayabilir mi?” diye sordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", birinin mektubu evde bekletip sonra gönderebileceğini anlattı. Üstelik posta damgası da her zaman açık okunmazdı. Altlarına aynı kalemle yazmak yerine farklı renkler seçtiler. Böylece tarihleri karıştırmaları zorlaşacaktı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir örnek hazırladı: Bir pul daha önceki bir yılda basılmış, yıllar sonra postaya verilmiş olabilirdi. Fotoğrafın çekim yılı ise zarftaki tarihten bütünüyle ayrı bir soruydu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önceden bu üç zamanı tek bir sayı olarak düşündüğünü fark etti. Artık defterin sayfasındaki renkli çizgiler ona daha mantıklı görünüyordu.\n\nÇocuklar araştırma defterine “pulun basım dönemi”, “zarfın gönderim tarihi” ve “fotoğrafın çekim tarihi” diye üç ayrı başlık açtı. Bu küçük ayrım olmasaydı, birini ötekinin yerine kullanıp yanlış sonuç çıkarabilirlerdi.\n\nErtesi sabah "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", pulu büyüteç altında incelemek için kütüphane sorumlusundan yardım istedi. Pulun üzerinde bir kuş, altında iki küçük rakam ve silik bir yazı vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk bakışta yıl sandığı rakamların aslında pulun parasal değeri olabileceğini fark etti.\n\n“Yani pulun üstündeki her sayı tarih değildir,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ".\n\nİkili posta tarihçesiyle ilgili güvenilir bir katalog aradı. Kütüphanedeki eski bir kitapta benzer kuş resimli pullar vardı ancak desenlerin rengi farklıydı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", pulu ilk benzer resimle eşleştirmeye çalıştı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " itiraz etti: “Benziyor diye aynı demeyelim. Bak, kanat çizgisinde fark var.”\n\nMüze kataloğundaki resimlerden birinin altında bir koleksiyonerin notu vardı: “Benzer motifler, farklı baskılar.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk başta bu farkların önemsiz olduğunu düşündü. Sonra pulun kenarındaki küçük çizgilerin, katalogdaki örneklerden biriyle tam uyuşmadığını gördü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", resimleri büyütüp karşılaştırdı. Birinde kuşun kanadı yukarı bakarken ötekinde hafif yana açılıyordu. Bu fark, bir baskı değişikliğinden de görüntü kalitesinden de kaynaklanabilirdi. “Bilmiyoruz,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Ama farkı gördüğümüzü yazabiliriz.” Böylece çocuklar araştırma notlarında gözlemle yorumu ayrı satırlara yazmayı alışkanlık hâline getirdi."
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
          "v": " bir başka katalog sayfasında aynı kuşun farklı resim teknikleriyle gösterildiğini gördü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk anda bunların hepsini tek seri sandı. Sonra pul üzerindeki yazıların, desenin ve boyutların birlikte değerlendirilmesi gerektiğini öğrendiler. Bir resmi tanımakla onu doğru sınıflandırmanın aynı şey olmadığı ortaya çıkıyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir karşılaştırma listesi hazırladı: Kuşun duruşu, rengin tonu, kenar çizgisi, üzerindeki yazı ve damga. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu listeyi görünce yalnızca bir ayrıntıya takılmak yerine bütünü değerlendirebildi. “Demek bu küçük pulda bile birçok ipucu var,” dedi.\n\nKatalogdaki açıklama, bazı pul serilerinin farklı yıllarda ve değişik renklerde basıldığını söylüyordu. Çocuklar pulun olası serisini belirlediler ama yılı kesinleştiremediler. Sibel Hanım, ilçe müzesindeki posta tarihi köşesi için randevu aldı.\n\nMüzenin girişinde "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", üzerlerinde kasabanın eski sokaklarının resimleri bulunan zarflar gördü. Bazı zarfların köşesi yıpranmış, bazıları ise oldukça iyi korunmuştu. Emine Hanım, eski belgeleri doğrudan güneş ışığından korumanın ve gerektiğinde uygun koşullarda saklamanın önemini anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " elindeki belgeyi sürekli bir çantadan diğerine taşımanın iyi fikir olmayabileceğini düşündü. Bu nedenle dedesinin zarfını evde bırakmış, müzeye yalnızca yüksek çözünürlüklü görüntüsünü getirmişti. Uzman bunun yerinde bir başlangıç olduğunu söyledi; fotoğrafın belgeyi tamamen incelemeye yetmeyebileceğini de hatırlattı. Çocuklar hangi bilginin görselden, hangisinin asıl belgeden öğrenilebileceğine dikkat etmeye başladı.\n\nMüzede görevli Emine Hanım, pulu fotoğraf üzerinden inceledi. “Burada asıl önemli ipucu zarfın damgası olabilir,” dedi. “Posta damgasında tarih bulunur. Fakat silinmiş kısmı tahmin etmeyin.”\n\nKâğıttaki çizim ilk denemede çok belirsiz olmuştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yeniden bakınca çizgilerden birini yanlış tamamladığını fark etti. Emine Hanım, eksik parçayı tahmin ederek çizmelerinin araştırma sonuçlarını etkileyebileceğini söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ikinci çizimde yalnızca gerçekten gördüğü çizgileri aktardı; kalan kısmı boş bıraktı. Bu küçük değişiklik, doğru bir kayıt tutmanın cesaret gerektirebildiğini ona gösterdi. Çünkü herkes tamamlanmış bir şekil görmek isterdi, oysa bazen dürüst olan boşluk bırakmaktı.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yarım damgayı kâğıda çizdi. Görünen rakamları işaretledi, görünmeyen yerlere soru işareti koydu. Daha önce böyle yapmaktan hoşlanmazdı; eksik bilgi onu sabırsızlandırırdı. Şimdi soru işaretlerinin araştırmanın dürüst bir parçası olduğunu anlamaya başlamıştı.\n\n"
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
          "v": " fotoğrafı sergi duvarından indirirken izin alarak eldiven kullandılar. Çerçevenin arkasına bakınca sonradan takılmış bir etiket gördüler. Etiketteki yazı, öndeki açıklama kadar eski görünmüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hemen “Demek tarihi sonra uydurdular,” dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " başını salladı. “Sonradan yazılmış olması, kasten uydurulduğu anlamına gelmez.” Sibel Hanım iki çocuğu da dikkatle dinledi. Bir kayıt yanlış olabilir, eksik olabilir veya başka bir fotoğrafa ait bilgi yanlışlıkla aktarılmış olabilirdi. Sebebi kanıtlamadan birini suçlamak adil değildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " fotoğrafın tarihini araştırırken kişilere ilişkin sözlerinin de ölçülü olması gerektiğini anladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Arşive girebilmek için önce küçük bir araştırma planı hazırladılar. Sibel Hanım, hangi belgelere bakacaklarını ve neden baktıklarını yazmalarını istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " “Eski her şeyi inceleyeceğiz,” diye yazmıştı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bunun çok geniş bir hedef olduğunu söyledi. Planı “Fotoğrafın çekilmiş olabileceği yıllara ait okul yıllıkları ve bina kayıtları” diye daralttılar. Böylece saatlerce rastgele dosya açmak yerine belirli soruların peşine düşebildiler. Arşiv görevlisi de hangi klasörlerin uygun olduğunu gösterdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " plan yapmanın keşfi yavaşlatmadığını; tam tersine, zamanı daha iyi kullanmalarını sağladığını anladı.\n\nSibel Hanım'ın okul arşivinde yaptığı araştırma yeni bir ipucu getirdi. Aynı fotoğrafın ikinci bir kopyası bulundu. İlk kopyanın altında 1984 yazarken ikincisinin arkasında el yazısıyla farklı bir tarih bulunuyordu. Bu iki tarih birbirini tutmuyordu.\n\n“Demek biri yanlış,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ".\n\n“Belki de ikisi de daha sonra yazılmış,” diye karşılık verdi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Önce fotoğrafın kendisine bakalım.”\n\nFotoğraftaki okul binasının girişine asılmış bir afiş vardı. Afişte, o yıl düzenlenen bir bilim sergisinin adı okunuyordu. Çocuklar okulun eski yıllıklarını incelediler. Aynı bilim sergisinin bir başka fotoğrafını buldular. Orada tarih daha açık yazılmıştı.\n\nYıllıkların birinde sınıf fotoğraflarının altında tarih, diğerinde yalnızca öğretmen adı vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce tarihsiz sayfaları bir kenara bırakmak istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bunların başka bilgiler taşıyabileceğini söyledi. Örneğin okul binasının duvarındaki süsleme, yıllıkların birinde açıkça görünüyordu. İkili bu işareti sergi fotoğrafındaki duvarla karşılaştırdı. Tam eşleşme bulamadılar fakat yeni sorulara ulaştılar: Fotoğraf bir ders günü mü, özel bir tören sırasında mı çekilmişti? Hangi öğretmenler o dönemde okulda çalışıyordu? "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", belgelerde eksik olan bir bilginin başka belgedeki ayrıntılarla araştırılabileceğini öğreniyordu.\n\nAncak yeni kanıt da tek başına yeterli değildi. Bilim sergisi birkaç yıl üst üste düzenlenmiş olabilirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu düşününce biraz öfkelendi. “Her ipucu başka bir soruya dönüşüyor!”\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gülümsedi. “Belki araştırma böyle bir şeydir. Yanlış cevabı hemen bulmaktansa doğru cevaba yaklaşmak.”"
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
          "v": " ise sınıftaki masaların biçimine dikkat etmişti. Bu masalar hangi yıllarda kullanılmıştı? Okulun eski fotoğraflarında benzerlerini aradılar. Aynı tür masaların uzun süre kullanıldığını görünce bunlarla kesin yıl belirleyemeyeceklerini anladılar. Yine de araştırma boşa gitmedi; okulun eşya düzeninin zaman içinde nasıl değiştiğine ilişkin küçük bir karşılaştırma tablosu oluştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", yanıt vermeyen bir ipucunun bile başka bir öğrenme fırsatı yaratabildiğini düşündü.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " fotoğraftaki gölgelerin yönüne de dikkat çekti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", gölgeye bakarak günü bile tahmin edebileceklerini düşündü. Sibel Hanım, güneşin konumunun saat ve mevsimle ilişkili olduğunu ama fotoğrafın kesin tarihini böyle belirlemenin kolay olmadığını söyledi. Binaların duruşunu, çekim açısını ve başka koşulları bilmeden iddialı sonuçlara gidilemezdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yine de bu öneriden bir şey öğrendi: Aynı nesneye farklı derslerde kazanılan bilgilerle bakılabilirdi. Matematik, tarih, fen ve Türkçe, bir araştırma masasında birbirine yaklaşabiliyordu.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " fotoğraftaki kişilerin giydiği kıyafetlere bakmayı önerdi. Sibel Hanım bunun da tek başına güvenilir "
        },
        {
          "t": "kelime",
          "yuva": "pd_tarihleme"
        },
        {
          "t": "metin",
          "v": " yöntemi olmadığını söyledi. Aynı kıyafetler yıllarca giyilebilirdi. Çocuklar fikirlerini küçümsemek yerine her kanıtın gücünü değerlendirmeyi öğrendi.\n\nErtesi hafta dede, "
        },
        {
          "t": "kahraman",
          "hal": "belirtme"
        },
        {
          "t": "metin",
          "v": " eski posta binasının bulunduğu sokağa götürdü. Bina artık başka bir amaçla kullanılıyordu; yine de dış cephesindeki iki pencere eski fotoğrafı hatırlatıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yürürken her köşeyi fotoğraflamaya kalkıştı. Dedesi onu durdurdu: “Bir de bakarak gez. Bütün anıları ekrandan görmek zorunda değilsin.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " telefonu cebine koydu. Yıllardır aynı sokakta yaşayan insanların binaları farklı isimlerle anabileceğini, yerlerin işlevinin zamanla değişebileceğini düşündü. Sokaktaki tabelalar ona bir yerin adıyla tarihinin de farklı kavramlar olduğunu hissettirdi. Eve dönünce bu gözlemi araştırma notlarına ekledi.\n\nDede Ali daha sonra evdeki küçük masa çekmecesinden bir davetiye buldu. Davetiyede eski okul binasının bir etkinliğine ilişkin tarih vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sevinerek “Buldum!” dedi. Ama "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " telefonda ona önemli bir şey sordu: “Davetiyenin tarihi, fotoğrafın tarihi mi?” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " birden sustu. Davetiye yalnızca o binada o tarihte etkinlik düzenlendiğini gösteriyordu. Fotoğrafın aynı etkinliğe ait olduğuna ilişkin henüz kanıt yoktu. Dede, torununun aceleyle duyurduğu sonucu geri çekmesine üzülmedi. “Bir şeyi yeniden düşünmek, yanlış yapmanın cezası değil,” dedi. “İyi düşünmenin parçası. Eskiler boşuna dememiş: ‘"
        },
        {
          "t": "atasozu",
          "yuva": "pd_ata_acele"
        },
        {
          "t": "metin",
          "v": ".’”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Dede, zarftaki adresin yalnızca okulun eski mahallesini göstermediğini, okulun o dönemde kullandığı kapı numarasını da verdiğini hatırladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu bilgiyi belediyenin erişime açık tarihî adres kayıtlarıyla karşılaştırmak için öğretmenine danıştı. Kayıtlarda okulun bir dönem geçici bir binada eğitim verdiği görülüyordu.\n\nBu bilgi, fotoğraftaki arka planda neden beklenmeyen binaların göründüğünü açıklıyordu. Çocukların önünde duran yapının gerçekten eski postane olması mümkündü; fotoğraf okulun geçici binasının önünde çekilmiş olabilirdi. Yine de kesin tarih bilinmiyordu.\n\nBu arada okulda farklı tahminler yayılmaya başladı. Bazıları fotoğrafta tanınan bir öğretmenden söz ediyor, bazıları da sergide yazan tarihin zaten doğru olduğunu savunuyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk kez bunun sadece kendi merakı olmadığını gördü. Yanlış bir tarih, insanların aile hikâyelerini de etkileyebilirdi. Sibel Hanım bu yüzden açıklamayı değiştirmeden önce okul yönetimine kısa bir kaynak özeti sunmalarını istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " “Kesin bilmediğimiz şeyi de yazalım mı?” diye sordu. “Özellikle onu yazacağız,” dedi öğretmen. “Belirsizliği gizlemek, başkalarının doğru bir karar vermesini zorlaştırır.”\n\nMüze görevlisi Emine Hanım, yeniden iletişime geçti. Pulun belirli bir dönemde kullanılan bir seriye benzediğini, ancak damganın fotoğrafından kesin yıl okunamadığını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": ", pulu uzman görmeden “kesin şu yıla ait” etiketi koymamalarını önerdi.\n\n“Peki sergide ne yazacağız?” diye sordu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ".\n\nSibel Hanım, “Bildiğimizi yazacağız. Bilmediğimizi de açıkça belirteceğiz,” dedi.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " buna önce şaşırdı. Bir müzedeki açıklamanın soru işaretiyle bitebileceğini düşünmemişti. Fakat araştırmanın asıl değerinin kesin konuşmak değil, kanıtları dürüstçe kullanmak olduğunu yavaş yavaş kavradı.\n\nEtiketi hazırlamadan önce "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ile "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " küçük bir sunum provası yaptı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", sergi ziyaretçisi rolüne girip zor sorular sordu: “Fotoğrafın hangi yıl çekildiğini kesin biliyor musunuz?”, “Peki ilk etikette neden 1984 yazıyordu?”, “Sergi yanlış bilgi mi vermiş oldu?” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk soruya aceleyle “Hayır” dedi, sonra devamını getiremedi. Bir süre durup “Mevcut kaynaklarda çelişki var; bu yüzden yılı araştırıyoruz” diye yeniden cevapladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " onun ne demek istediğini artık daha kolay anlıyordu. Sibel Hanım bu provayı görünce sevinçle “Bilmediğinizi açıkça söyleyebilmeniz güven verir,” dedi.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", etiketin ilk taslağını "
        },
        {
          "t": "yoldas",
          "hal": "yonelme",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " okudu. Bir cümlede “Bu fotoğraf kesinlikle yanlış tarihlenmiş” yazıyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", ellerindeki kanıtların buna izin vermediğini söyledi. İkili cümleyi “Mevcut tarihleme konusunda çelişkili kayıtlar bulunuyor” olarak değiştirdi. Bu ifade kulağa daha az heyecanlı geliyordu ama daha doğruydu. Sibel Hanım, araştırmacıların bazen en önemli işinin kesin olmayan sözleri yumuşatmak olduğunu anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başta güçlü konuşmayı çok seviyordu. Şimdi doğru bir çekingenliğin de güven verici olabileceğini görüyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sergi açılışından bir gün önce yeni etiket hazırlandı. Üstte şöyle yazıyordu: “Okulun eski dönemlerinden bir grup öğrenci. Kesin çekim yılı araştırılıyor.” Altında, fotoğrafın farklı kopyalarındaki tarihlerin neden uyuşmadığı, hangi belgelerin incelendiği ve hangi soruların açık kaldığı anlatılıyordu.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " son satıra kendi adını yazmak istemedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da aynı fikirdeydi; çalışmanın öğretmenler, arşiv görevlileri, dede ve müze uzmanıyla birlikte yapıldığını düşünüyorlardı. Sonunda hepsine teşekkür eden kısa bir not eklediler.\n\nİki öğrenci etiketteki “araştırılıyor” sözcüğünü görünce merakla yanlarına geldi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce bütün çalışmayı anlatmak istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ona yalnızca üç önemli noktayı söylemelerini önerdi: Farklı tarihler var, belgeler karşılaştırıldı ve kesin sonuç henüz bulunmadı. Ziyaretçiler bu kısa açıklamayı daha kolay anladı. Ayrıntı isteyenlere ise hazırladıkları kaynak dosyasını gösterdiler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", anlatımın uzunluğunu dinleyenin ihtiyacına göre ayarlamanın da araştırmanın bir parçası olduğunu fark etti.\n\nSergi günü ziyaretçiler fotoğrafın önünde daha uzun süre durdu. Bazıları kendi aile albümlerindeki eski okul fotoğraflarını hatırladı. Bir veli, “Bu fotoğraf bende de olabilir,” dedi. Okul yönetimi, isterse görüntüyü aileden izin alarak karşılaştırabileceklerini söyledi.\n\nSergiye gelen bir başka ziyaretçi, eski fotoğraftaki çocuklardan birinin kendi akrabası olabileceğini söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hemen adını yazmak istemedi. Önce kişinin söylediklerinin ailesindeki bir fotoğrafla desteklenip desteklenemeyeceğini sordu. Ziyaretçi bunun zaman alacağını ama araştırmaya katılmaktan mutluluk duyacağını belirtti. Sibel Hanım, okulun kişisel bilgileri koruyan bir iletişim yolu kullanacağını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " böylece bir gizemi çözmek uğruna insanların adlarını, fotoğraflarını ve hatıralarını gelişigüzel paylaşmamaları gerektiğini de öğrendi.\n\nDede sergiye geldiğinde "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " yanında durdu. “Biliyor musun,” dedi, “ben de başta eski postaneyi görünce tarihi kesin sandım. Senin soruların bana hatırlamakla kanıtlamanın farkını öğretti.”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güldü. “Ben de senin zarfın sayesinde araştırmaya başladım.”\n\nSergi bittikten sonra öğretmenleri öğrencilere bir soru daha yöneltti: “Bir araştırmayı ne zaman tamamlanmış sayarsınız?” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", amaçlarının her ayrıntıyı kesinleştirmek değil, eldeki bilgiyi olabildiğince doğru sunmak olduğunu söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " de bir belgenin yeni bilgiler ortaya çıktığında yeniden değerlendirilebileceğini düşündü. Fotoğrafın tarihine ilişkin sorular hâlâ açıktı; ama şimdi bu belirsizliği nasıl ifade edeceklerini biliyorlardı. İkisi, sonraki araştırmacıların işine yarayacak bir kaynak listesi hazırladı ve klasörün önüne ekledi. Böylece kendi çalışmalarının sonu, başka birinin başlangıcı olabilecekti."
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
          "v": ", pulun fotoğrafını açıklama panosuna ekledi. Ancak üstüne büyük harflerle “Fotoğrafın tarihini tek başına kanıtlamaz” yazdı. Bu cümle, sergideki en önemli bilgilerden biriydi.\n\nSerginin sonunda bir grup öğrenci "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " fotoğrafı neden hiç değiştirmediklerini sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", asıl fotoğrafın geçmişten gelen bir belge olduğunu; değişen şeyin ona eklenen açıklama olduğunu söyledi. Fotoğrafı silmek veya değiştirmek yerine doğru bilgiyi aramak daha anlamlıydı. Çocuklar bir süre birlikte kareye baktılar. Bazısı pencereleri, bazısı öğrencilerin ellerindeki defterleri fark etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onları dikkatle dinledi. Aynı kareye bakan insanların farklı ayrıntılar görmesi hoşuna gitti, çünkü hiçbiri diğerinin gördüğünü yok etmiyordu. Araştırmayı paylaşmak yeni sorulara kapı aralıyordu.\n\nYıldönümü töreninden sonra "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " arşiv defterini kapatırken zarfın bir kopyasına yeniden baktı. Kuş resimli pul artık ona eski bir eşya gibi görünmüyordu. O pul, yıllar önce birinin bir başkasına gönderdiği haberin küçük bir parçasıydı. Üzerindeki silik damga belki bir gün okunabilecekti, belki de hiçbir zaman kesinleşmeyecekti.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Keşke bütün sırları çözebilseydik,” dedi.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını salladı. “Ben de isterdim. Ama artık çözemediğimiz kısmı uydurmamamız gerektiğini biliyorum.”\n\nBirlikte arşive yeni bir dosya açtılar. Dosyanın başlığı “Doğrulananlar ve Açık Sorular” oldu. İçine fotoğrafları, kaynak listelerini ve araştırma notlarını koydular. Zarfın aslı ailesinde güvenle saklandı; okulda yalnızca izinli bir kopyası kullanıldı.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ertesi gün sınıfa eski tarihli bir posta kartının kopyasını getirdi. Kartın önünde kasabanın meydanı, arkasında birkaç satır iyi dilek vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce resimdeki saate baktı. Ardından "
        },
        {
          "t": "yoldas",
          "hal": "yonelme",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " “Saati görünce günü bilebilir miyiz?” diye sordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gülümsedi. “Ancak o saatin neden orada olduğunu ve resmin ne zaman çekildiğini araştırırsak biraz daha yaklaşırız.” Çocuklar artık her eski nesneyi bir tarih makinesi sanmıyordu. Ama her nesnenin yeni bir soru doğurabileceğini biliyorlardı.\n\nO akşam "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterinin son sayfasına küçük bir posta pulu çizdi. Kuşun kanadının yanına şöyle yazdı: “Geçmişten gelen her işaret bir kapı açabilir. Ama o kapıdan geçerken kanıtı da yanımıza almalıyız.” "
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
      "dayanak_sayfa": 5,
      "metin": "Okul arşivinde bulunan, aynı fotoğrafın ikinci kopyasında hangi ayrıntı vardı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Üzerinde hiçbir yazı yoktu"
        },
        {
          "id": "B",
          "metin": "Arkasında el yazısıyla ilk kopyadakinden farklı bir tarih yazıyordu"
        },
        {
          "id": "C",
          "metin": "Fotoğraftaki bina tamamen farklıydı"
        },
        {
          "id": "D",
          "metin": "Aynı 1984 tarihi kalın harflerle yazılmıştı"
        }
      ],
      "dogru": "B",
      "aciklama": "İlk kopyanın altında 1984 yazarken ikinci kopyanın arkasında farklı bir tarih bulunuyor ve iki tarih birbirini tutmuyordu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 6,
      "metin": "Davetiyedeki tarih neden fotoğrafın çekildiği tarih sayılamadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü davetiye yırtılmıştı"
        },
        {
          "id": "B",
          "metin": "Çünkü davetiyeyi kimse okuyamıyordu"
        },
        {
          "id": "C",
          "metin": "Çünkü davetiyede hiç tarih yoktu"
        },
        {
          "id": "D",
          "metin": "Çünkü davetiye yalnızca o binada o tarihte bir etkinlik olduğunu gösteriyordu; fotoğrafın o etkinliğe ait olduğuna dair kanıt yoktu"
        }
      ],
      "dogru": "D",
      "aciklama": "Davetiyedeki tarih ile fotoğraf arasındaki bağ henüz kanıtlanmamıştı."
    },
    {
      "id": "s3",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Pulun üzerindeki küçük rakamlar neden hemen bir yıl olarak kabul edilmedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü rakamlar pulun parasal değeri olabilirdi; pulun üstündeki her sayı tarih değildir"
        },
        {
          "id": "B",
          "metin": "Çünkü rakamlar hiç okunamıyordu"
        },
        {
          "id": "C",
          "metin": "Çünkü pulda hiç rakam yoktu"
        },
        {
          "id": "D",
          "metin": "Çünkü rakamları yalnızca müze görevlisi okuyabilirdi"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuklar yıl sandıkları rakamların pulun parasal değeri olabileceğini fark etti."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 8,
      "metin": "Yeni etikete “Kesin çekim yılı araştırılıyor” yazılması neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Fotoğrafın hiç çekilmediğini"
        },
        {
          "id": "B",
          "metin": "Çocukların araştırmayı bıraktığını"
        },
        {
          "id": "C",
          "metin": "Elde kesin bir sonuç olmadığının ve bunun dürüstçe belirtildiğini"
        },
        {
          "id": "D",
          "metin": "Eski etiketin tamamen doğru olduğunu"
        }
      ],
      "dogru": "C",
      "aciklama": "Etikette bilinenler ve açık kalan sorular yazıldı; kesin olmayan bilgi kesinmiş gibi sunulmadı."
    },
    {
      "id": "s5",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "Sibel Hanım’ın “Yanlış olduğunu düşünüyorsanız kanıt bulabiliriz” cümlesinde kanıt ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir kişinin tahmini"
        },
        {
          "id": "B",
          "metin": "Bir iddianın doğru ya da yanlış olduğunu gösteren belge veya bilgi"
        },
        {
          "id": "C",
          "metin": "Eski bir eşya"
        },
        {
          "id": "D",
          "metin": "Bir sergi afişi"
        }
      ],
      "dogru": "B",
      "aciklama": "Öğretmen, yanlış tarih iddiasının tahminle değil belgelerle gösterilmesi gerektiğini söylüyordu."
    },
    {
      "id": "s6",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "Metne göre posta damgası hangi bilgiyi taşır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Mektubu yazan kişinin adını"
        },
        {
          "id": "B",
          "metin": "Pulun fiyatını"
        },
        {
          "id": "C",
          "metin": "Zarfın rengini"
        },
        {
          "id": "D",
          "metin": "Mektubun postalandığı tarihi"
        }
      ],
      "dogru": "D",
      "aciklama": "Müze görevlisi posta damgasında tarih bulunduğunu, ancak silinmiş kısmın tahmin edilmemesi gerektiğini söyledi."
    },
    {
      "id": "s7",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 6,
      "metin": "“Kıyafetler tek başına güvenilir bir tarihleme yöntemi değildir” cümlesinde tarihleme ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir belgenin ya da fotoğrafın ne zaman yapıldığını belirlemeye çalışmak"
        },
        {
          "id": "B",
          "metin": "Bir fotoğrafı çerçeveye koymak"
        },
        {
          "id": "C",
          "metin": "Bir kıyafeti dikmek"
        },
        {
          "id": "D",
          "metin": "Bir zarfı postaya vermek"
        }
      ],
      "dogru": "A",
      "aciklama": "Aynı kıyafetler yıllarca giyilebildiği için, giysilere bakmak fotoğrafın tarihini belirlemede tek başına yeterli değildi."
    },
    {
      "id": "s8",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 7,
      "metin": "Sibel Hanım’ın “Bildiğimizi yazacağız. Bilmediğimizi de açıkça belirteceğiz” yaklaşımı neden iyidir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü sergi daha kısa olur"
        },
        {
          "id": "B",
          "metin": "Çünkü hiç kimse soru sormaz"
        },
        {
          "id": "C",
          "metin": "Çünkü belirsizliği saklamak, başkalarının doğru karar vermesini zorlaştırır"
        },
        {
          "id": "D",
          "metin": "Çünkü fotoğrafın tarihi artık değiştirilemez"
        }
      ],
      "dogru": "C",
      "aciklama": "Öğretmen, belirsizliği gizlemenin başkalarının doğru bir karar vermesini zorlaştırdığını söyledi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p14$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr046-bilinmeyen-posta-pulu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p15${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr047-kirmizi-defterin-sifresi",
    "baslik": "Kırmızı Defterin Şifresi",
    "tur": "gizem",
    "konu": "kirmizi_defter_oruntu",
    "sinif_alt": 6,
    "sinif_ust": 6,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D12",
      "D6"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 6,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "gizem",
        "okuma_kitap",
        "sabir_emek"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D12",
        "yardimci_deger": "D6"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk_oruntu_hr047",
          "tur": "lexeme",
          "etiket": "örüntü",
          "yuva": "pd_oruntu",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk_baglam_hr047",
          "tur": "lexeme",
          "etiket": "bağlam",
          "yuva": "pd_baglam",
          "islev": "application"
        },
        {
          "id": "sozcuk_varsayim_hr047",
          "tur": "lexeme",
          "etiket": "varsayım",
          "yuva": "pd_varsayim",
          "islev": "application"
        },
        {
          "id": "kavram_hr047",
          "tur": "concept",
          "etiket": "Sayı örüntüsünü bulmak ile belgenin anlamını bağlamıyla doğrulamak aynı şey değildir",
          "islev": "application"
        },
        {
          "id": "atasoz_hr047",
          "tur": "proverb",
          "etiket": "Sabreden derviş muradına ermiş",
          "yuva": "pd_ata_sabreden",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 3051,
        "tahmini_sure_dk": 27,
        "sayfa_sayisi": 9,
        "soru_sayisi": 8,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 2,
          "yorumlama": 1,
          "sozcuk_baglami": 3,
          "degerlendirme": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 3,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 45,
        "simge_sayisi": 2
      }
    },
    "tanitim": "Eski bir defterde garip sayı dizileri var. Oyun puanı mı, gizli şifre mi, yoksa başka bir şey mi?",
    "durum": "taslak",
    "fis_kodu": "HR-047"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Okulun satranç kulübü, boş bir sınıfta eski bir kırmızı defter buldu. Defterin kapağında yalnızca “Nöbet Devir Teslimi” yazıyordu. İçinde küçük tablolar, okunması zor notlar ve uzun sayı dizileri vardı. Altıncı sınıftan "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " satranç oyunlarından öğrendiği bir alışkanlık vardı: Bir hamle yapmadan önce karşı tarafın ne yapabileceğini düşünmek. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu çoğu zaman yavaşlık sanırdı. Kırmızı defterdeyse "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " sabrı işe yaradı; ilk sayfada görülen sayıların arkasında başka bir düzen olabileceğini ondan önce fark etmişti. İrem gülümseyip eski bir atasözünü hatırlattı: “"
        },
        {
          "t": "atasozu",
          "yuva": "pd_ata_sabreden"
        },
        {
          "t": "metin",
          "v": ".” İrem iki arkadaşın yöntemlerini birleştirmelerini önerdi. “"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hızlı örüntü buluyor, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ayrıntıyı kontrol ediyor. İkiniz de gerekli bir iş yapıyorsunuz,” dedi. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        },
        {
          "t": "metin",
          "v": "\n\n"
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " bu maceraya özel bir nedeni daha vardı. Geçen dönem satranç turnuvasında bütün hamlelerini hesapladığını düşünmüş, son oyunda acele bir karar verip yenilmişti. Herkes ona “Biraz düşünseydin” demişti. O günden beri rakamlarla ilgili bir yarış gördüğünde kendini ispatlamak istiyordu. Kırmızı defter de ona böyle bir fırsat gibi görünmüştü. Fakat İrem'in sakinliği ve "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " farklı soruları, araştırmanın turnuvadan farklı bir şey olduğunu hatırlatacaktı. Bu kez kazanılacak tek bir madalya yoktu. Bir belgenin ne anlattığını birlikte anlamaları gerekiyordu.\n\nDefteri ilk fark eden "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " olmuştu. Satranç tahtalarının kaldırıldığı dolabın en altında, tahta kutuların arasına sıkışmıştı. Kırmızı kapak yıpranmıştı ama köşesine yapıştırılan küçük beyaz etiket hâlâ duruyordu. İrem defteri bulduklarında hemen açmamalarını önerdi. Kulüp odası okulun ortak alanıydı; bulunan eşya başka bir birime ait olabilirdi. Öğretmenlerine haber verdikten sonra defterin okulun eski kütüphane deposundan taşınan malzemelerden biri olduğu anlaşıldı. Bu açıklama, sayıların oyun puanı olabileceği fikrini zayıflatmadı; çünkü eski yıllarda kütüphane kulüpleri de yarışmalar düzenlemiş olabilirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " iki seçeneği de not etti. Daha araştırmaya başlamadan farklı açıklamaların mümkün olduğunu görmüştü.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sayılarla çalışmayı severdi, fakat başkalarının zihninden daha hızlı işlem yapabildiğini sanması bazen sorun yaratıyordu. Satranç kulübünde hamlesini hemen yapar, arkadaşlarının uzun düşünmesini sıkıcı bulurdu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise dikkatliydi; bazen bir hamlenin sonucunu görmek için birkaç dakika susabilirdi. Bu ikisinin anlaşması kolay değildi. Kırmızı defter onların birlikte çözeceği ilk ciddi araştırmaydı. İrem, “Burada yarışmıyoruz,” dedi. “Önemli olan kimin önce bildiği değil, nasıl bildiğimiz.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " itiraz etmek üzereydi ama defterin kapağındaki eski etikete bakınca susmayı seçti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İrem kırmızı defteri açtığında ilk olarak sayfa numaralarını kontrol etti. Bazı sayfalarda küçük lekeler vardı ama yazıların çoğu okunabiliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sayılar üzerinde çalışmak için sabırsızlanırken "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kapağın içindeki eski okul mührünü fark etti. Mühür, defterin hangi kuruma ait olabileceğine ilişkin önemli bir ipucuydu. İrem, “Önce belgenin kimliğini anlayalım,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu kez onun sözünü kesmedi. Çünkü mühür olmasa defterdeki sayıların okul kütüphanesiyle ilişkisini çok daha geç kuracaklardı.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk sayfaya baktığında şaşırdı: 104, 107, 110, 113... Her yeni sayı bir öncekinden üç büyüktü.\n\n“Bu bir oyun skoru olabilir,” dedi takım arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Belki kazananlara üç puan vermişler.”\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " itiraz etmedi. Ama hemen yanındaki listede 502, 504, 506 gibi başka bir dizi vardı. Puanların neden bir sayfada üçer, başka sayfada ikişer arttığını anlamıyordu. Defteri bulan kulüp başkanı İrem, kapakta “Nöbet” yazdığına dikkat çekti.\n\n“Önce defterin ne için tutulduğunu öğrenmeliyiz,” dedi. “Başkasının eşyasını izinsiz karıştırmak da doğru değil.”\n\nÖğretmenleri Arif Bey'e danıştılar. Öğretmen, defterin yıllar önce okul kütüphanesinde görevli olan öğrenciler tarafından tutulmuş olabileceğini söyledi. Defter okulun eski evrakları arasından çıkmıştı; içindekilerin incelenmesi için kütüphane sorumlusuyla görüşeceklerdi.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sayıların bir dil gibi olduğunu düşünmeye başlamıştı. Eğer dili çözebilirlerse kimin, ne zaman, neyi kaydettiğini öğrenebileceklerdi. Fakat şifrenin anlamını bulmak için daha fazla ipucu gerekiyordu.\n\nİlk araştırma oturumunda Münevver Hanım öğrencilere renkli küçük kâğıtlar verdi. Her kâğıda bir "
        },
        {
          "t": "kelime",
          "yuva": "pd_varsayim"
        },
        {
          "t": "metin",
          "v": " yazmalarını istedi: “Oyun puanı”, “Kitap kodu”, “Sıra numarası” ve “Başka bir kayıt”. Ardından her varsayımın altına onu destekleyen veya zayıflatan bilgileri koyacaklardı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ilk kâğıda sımsıkı sarıldı; çünkü fikri onundu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise kitap kodu seçeneğini ortaya atmış olmanın gururunu yaşıyordu. İrem, “Sevdiğimiz fikri korumaya değil, doğru olanı bulmaya çalışıyoruz,” dedi. İki arkadaş önce itiraz etti, sonra bu yöntemle soruları daha kolay sıraya koyabildiklerini gördü.\n\nMünevver Hanım masanın üzerine temiz bir örtü serdi. Eski defteri doğrudan güneş ışığı almayan bir yerde açmalarını istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", kayıtlı sayıların hepsini fotoğraflamak için telefonuna uzandı. Münevver Hanım, “Önce hangi sayfalara bakabileceğinizi belirleyelim,” dedi. Bazı sayfalarda eski öğrencilere ait kişisel bilgiler olabilirdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ve İrem de buna hak verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", eskiden tarihî belge sandığı her şeyi paylaşmanın iyi bir şey olduğunu düşünürdü. Şimdi bilgiye ulaşabilmekle onu herkese yayabilmenin farklı haklar olduğunu anlamaya başladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi gün kütüphane sorumlusu Münevver Hanım, defteri kontrollü biçimde incelemelerine izin verdi. Bazı sayfalarda öğrenci isimleri olduğu için bunları herkesin göreceği şekilde paylaşmamalarını istedi. Çocuklar yalnızca kitap kodu olabilecek sayıları inceleyeceklerdi.\n\nÖrüntünün ilk kuralını bulunca "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir oyun önerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gözlerini kapatacak, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " dizinin herhangi bir noktasını okuyacaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir önceki ve bir sonraki sayıyı tahmin edecekti. İlk denemelerde zorlanmadı. Fakat "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " 104 yerine 105 ile başlayan bir dizi seçince "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " aynı kuralı hemen uyguladı ve şaşırdı. Yeni dizinin farkı farklıydı. “Kuralı öğrenmek yetmiyor,” dedi. “Hangi diziye uyguladığını da bilmen gerek.” İrem bu sözü defterine yazdı. Matematikte kurallar güçlü araçlardı ama her durumda aynı kural kullanılmazdı.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kâğıda ilk diziyi yazdı: 104, 107, 110, 113. Ardından 116 sayısını ekledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Gördün mü, kural bu!” dedi. İrem ise “Bir "
        },
        {
          "t": "kelime",
          "yuva": "pd_oruntu"
        },
        {
          "t": "metin",
          "v": " bulduk, ama neyi gösterdiğini bilmiyoruz,” diye hatırlattı.\n\nAynı sayfanın altındaki ikinci dizi 502, 504, 506, 508 diye gidiyordu. Üçüncü sayfada ise 211, 311, 411 vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir süre düşündü. Sayılar farklı kurallarla artıyordu. Bu durum oyun puanı açıklamasını zayıflatıyordu.\n\nRafların önünde renkli etiketler vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunların yalnızca dekorasyon olduğunu sanmıştı; oysa her renk farklı türde kitapları bulmayı kolaylaştırıyordu. Münevver Hanım, daha küçük öğrenciler için konu resimleri de eklediklerini anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk anda onlara kitap kodunu söylemeye hazırlanmıştı. Ancak çocuklar henüz kodları öğrenmediklerini söyledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " rafın üzerindeki hayvan resmini göstererek yardımcı oldu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", farklı yaşlarda aynı bilgiye ulaşmak için farklı yollar kullanılabileceğini gördü. Bu deneyim ileride hazırlayacakları oyun etkinliğinin tasarımını da etkiledi.\n\nBirinci sınıftan gelen iki çocuk hayvanlar hakkındaki kitabı arıyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " onları uygun rafa yönlendirdi. Çocuklar kitabı bulunca sevinçle teşekkür etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", kütüphane düzeninin sıradan gibi görünen ayrıntılarının bile okurlara yardımcı olabildiğini fark etti. Eski defterdeki sayıların da zamanında böyle bir işlevi olabilir miydi?\n\nKütüphanenin raflarında dolaşırken "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir kitabın sırtındaki etikete dikkat etti. Etikette harfler ve sayılar vardı. Münevver Hanım, bazı kütüphanelerde kitapların konularına veya kayıt sırasına göre kodlandığını anlattı. Bu okulun eski sistemi ise bugünkünden farklıydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Belki defterdeki diziler de kitaplarla ilgili,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". İrem hemen yeni bir tablo oluşturdu: “Sayı, olası açıklama, kanıt.” İlk satıra “104 — kitap kodu olabilir — henüz doğrulanmadı” yazdı.\n\nAraştırma sırasında "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " aklına eski defterin niçin kırmızı olduğu takıldı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bunun gizli kulüp rengini temsil ettiğini söyledi. Münevver Hanım gülerek cevap verdi: “Belki de o yıllarda kırtasiyede yalnızca kırmızı defter bulunuyordu.” Çocuklar bir nesnenin her özelliğinin özel anlam taşımak zorunda olmadığını fark etti. Yine de kapak rengi onlara güzel bir isim vermişti: Kırmızı Defterin Şifresi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu adı araştırma defterinin başına yazdı ama altına küçük harflerle “Şifre sözcüğü burada merak için kullanılmıştır” notunu ekledi.\n\nİlk kartı incelerken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kitabın adını yanlış okudu. Eski el yazısındaki harfler birbirine benziyordu. İrem daha yavaş okuyup kitabın gerçek adını yazdı. “Ben olsam ilk gördüğüm gibi kaydederdim,” dedi "
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
          "v": " bu kez acele etmedi. “Belki başka kartta daha okunaklıdır,” diye önerdi. Aradılar ve kitabın ikinci bir kaydını buldular. İki kayıt arasındaki farkı belirleyince bir sayının tek başına kaybolmuş bir kitabı göstermediğini, bazen aynı kitap için farklı kayıtlar da bulunduğunu anladılar.\n\nKatalog kartlarının köşeleri farklı renklerle boyanmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun kitapların içerikleriyle ilgili olduğunu düşündü. Münevver Hanım renklerin eski bir raf sistemine bağlı olabileceğini söyledi, ancak elindeki kayıtta açık bir açıklama bulunmadığını ekledi. Çocuklar bunu araştırma listesine yeni bir soru olarak yazdılar.\n\nMünevver Hanım çocuklara eski katalog kartlarından birini gösterdi. Kartta kitap adı, yazar, kayıt numarası ve eski raf yeri yazıyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " eski kartlardan birinde 107 sayısını görünce sevinçle bağırdı: “Şifreyi çözdük!”\n\nİrem onu durdurdu. “Bir tane eşleşme yeterli değil.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ikinci kitabın kartını açtı; burada 110 yazıyordu. Sonra başka bir kartta 113'ü buldular. Üç farklı eşleşme artık tesadüf ihtimalini azaltıyordu.\n\nİrem diziyi bir de yatay satırlar hâlinde okumalarını istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bu kez soruyu "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " yöneltti: “Bir tabloyu yanlış sırayla okursan doğru sayılar seni yanlış sonuca götürür mü?” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Evet,” dedi. “Rakamlar değişmez ama aralarındaki ilişkiyi yanlış anlayabiliriz.” Bunun üzerine üç arkadaş, küçük sınıfların kullanabileceği çizimli bir tablo hazırladı. İçinde meyve sepetleri vardı ve sayılar her sütunda farklı biçimde ilerliyordu. Böylece soyut buldukları ilişkiyi anlaşılır bir örnekle göstermiş oldular. Münevver Hanım bu etkinliği daha sonra kulüp saatinde kullanabileceklerini söyledi."
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
          "v": " kâğıda üç sütun çizdi. Birinci sütuna 104, 107, 110; ikinciye 105, 108, 111; üçüncüye 106, 109, 112 yazdı. Sayfayı dikey okuyunca her sütun üçer artıyordu. Yatay okuyunca sayılar birer birer ilerliyordu. "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yüzü aydınlandı. “Aynı sayılar, okuma yönüne göre farklı bir dizi gibi görünmüş!” dedi. İrem, “Demek tablo biçimini bilmeden yalnızca rakamlara bakmak yetmez,” diye ekledi. Bu küçük keşif, çocuklara basit bir satır-sütun düzeninin ne kadar önemli olduğunu gösterdi.\n\nFakat dizi neden üçer artıyordu? Kütüphane sorumlusu, eski sistemde bazı raf listelerinin birden fazla sütun hâlinde tutulduğunu söyledi. Defterdeki sayılar üçer artarken başka sütunlardaki kayıtlar aradaki numaraları tamamlıyor olabilirdi. Çocuklar defteri dikkatlice inceleyince yan sayfada 105, 108, 111 sayılarını buldular.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " heyecanla yeni bir kâğıt aldı ve tabloyu kendi başına yeniden kurdu. İlk sütunu doğru yazdı ama ikinci sütunun son sayısını unuttu. İrem eksik kısmı kendisinin tamamlaması yerine "
        },
        {
          "t": "yoldas",
          "hal": "yonelme",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yatay satırları kontrol etmesini önerdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", sayının nerede kaybolduğunu kendi bulunca sevindi. Bu küçük an, yardım etmenin bazen cevabı söylemek yerine yöntemi hatırlatmak olduğunu gösterdi.\n\n“Demek bu bir tek sıra değil,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Aynı tablodaki farklı sütunları ayrı ayrı okumuşuz.”\n\nO anda "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yanlış rafta duran bir kitap fark etti. Sırtında eski bir kod vardı ama raftaki yeni etiketle uyuşmuyordu. Münevver Hanım kitabı alıp güncel katalogdan kontrol etti. Gerçekten de yanlış rafa konmuştu. Defterin sayıları, yıllar önceki kayıtların nasıl tutulduğunu anlamalarına yardım ediyordu.\n\nKırmızı çizginin yanında küçük bir yıldız da vardı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bunun kayıp kitabı işaretlediğine neredeyse emindi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu kez hemen kabul etmedi. Sorumluya danışınca yıldızın o gün kontrol edilen kayıtları belirtmek için kullanılmış olabileceğini öğrendiler. Fakat bunu doğrulayacak açıklama defterde yoktu. İrem “Kesinlikle yıldız bunu gösteriyor” yazmadı; “Olası açıklama, doğrulanmadı” diye not etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " önce hayal kırıklığına uğradı. Sonra bir araştırmacının bütün sorulara aynı anda yanıt bulmasının gerekmeyebileceğini anladı.\n\nO sabah okulun kütüphanesinde küçük bir kitap değiştirme etkinliği vardı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", araştırmaya katılmak yerine arkadaşlarıyla kitap seçmek istiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bundan rahatsız oldu. “Tam sonuca yaklaşmışken gidiyorsun,” dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Bir saat sonra devam ederiz. Kütüphane yalnızca kayıt çözmek için değil, kitap okumak için de var,” diye karşılık verdi. İrem ikisinin de haklı yanlarını gördü. Birlikte zaman planı yaptılar: önce etkinliğe katılacak, sonra araştırma masasına döneceklerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", iyi bir ekip çalışmasının yalnızca tek bir kişinin merakına göre ilerleyemeyeceğini fark etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Araştırmanın üçüncü günü "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kırmızı bir kalemle işaretlenmiş sayfayı gördü. Sayfanın tepesine “Tamamlanmadı” yazılmıştı. Altında beş kitap adı vardı. Üçünün yanında onay, ikisinin yanında boş kare bulunuyordu.\n\n“Acaba bu kitaplar kayıp mı?” diye sordu "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ".\n\nMünevver Hanım, bunun kesin olmadığını söyledi. “Belki o tarihte sayım tamamlanmadı, belki kitaplar başka bir bölümdeydi. Önce kayıtları karşılaştıralım.”\n\nArama sırasında aynı başlığı taşıyan iki farklı kitap gördüler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilkini seçmeye hazırlanırken İrem yayım bilgilerini karşılaştırdı. Bir kitapta yazar adı farklıydı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da aradıkları kitabın sayfa sayısının eski kayıttakine benzemediğini fark etti. İkili birbirlerini uyarınca "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " doğru sonuca ulaştı. Defterdeki kodun yalnızca bir kapı anahtarı olmadığını, başka kayıtlarla birlikte kullanıldığında anlam kazandığını gördü. Öğretmenlerine hazırladıkları tabloda “eşleşti” ve “kontrol edilecek” sütunlarını ayrı tuttular.\n\nÇocuklar kitabın adını, yazarını ve eski kodunu kullanarak tarama yaptı. İki kitabın farklı bir sınıf kitaplığına aktarılmış olduğunu gösteren belge bulundu. Böylece “kayıp” sözcüğünü kullanmadan önce neden dikkatli olunması gerektiğini anladılar.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", sayı dizilerine bakıp bir anda bütün şifreleri çözebildiğini sanmıştı. Şimdi her rakamın, yanında yazan kelimeye ve kullanıldığı zamana göre anlam kazandığını görüyordu. Matematikte örüntüyü bulmak önemliydi; gerçek bir belgeyi anlamak için örüntünün bağlamını da bilmek gerekiyordu.\n\nSunum hazırlıkları sırasında küçük bir tartışma çıktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", sayıların nasıl çözüldüğünü anlatan uzun bir metin yazmıştı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", bunun dinleyenleri sıkacağını söyledi. İrem ikisini de dinledi ve metni üç parçaya ayırmayı önerdi: önce merak sorusu, sonra ipuçları, en sonunda çözüm. Böylece hem "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " ayrıntıları korunacak hem de dinleyiciler yolu takip edebilecekti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " metninin bir kısmını kısaltmayı istemiyordu. Fakat provasını yaptıklarında arkadaşları hangi sayıların neyi gösterdiğini karıştırdı. İkinci denemede daha açık cümleler kullandılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " o gün bilgiyi bulmanın kadar anlaşılır anlatmanın da emek istediğini gördü.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu sunumu yalnızca öğretmenine göstermek istemişti. Münevver Hanım küçük öğrencilerin de katılacağını söyleyince biraz endişelendi. “Ya sayı tabloları onlara zor gelirse?” dedi. İrem, örnekleri renkli kâğıtlarla gösterebileceklerini önerdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da kitap etiketlerinin fotoğraflarını hazırladı. Böylece soyut görünen sayı ilişkilerini gerçek nesnelere bağladılar."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Araştırmaları bitince Münevver Hanım, çocuklardan elde ettikleri bilgileri herkesin anlayacağı kısa bir sunuma dönüştürmelerini istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sayı dizilerini anlattı, İrem kanıt tablosunu gösterdi, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " eski katalog kartlarının nasıl kullanıldığını açıkladı.\n\nMünevver Hanım öğrencilerin sunumunu dinlerken eski kütüphanede kullanılan sisteme ilişkin kendi hatıralarını da anlattı. Ancak bazı yılları tam hatırlamadığı için öğrencilerden notlarına “sözlü bilgi” etiketi koymalarını istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını salladı. Belgeler ve anılar birbirini tamamlayabilirdi ama aynı türde kanıt değildi. İrem hazırladığı tabloyu son kez kontrol etti; hangi sayıyı hangi karttan aldıkları görünür hâle gelmişti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise yanlış puan varsayımının üzerini çizmek yerine küçük bir açıklama eklemeyi önerdi. Böylece araştırmanın nasıl ilerlediği de anlaşılacaktı.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " defteri ilk bulduğu sabah kurduğu hazine hayalini hatırladı. Başta bir kapının açılacağını, arkasından eski madalyalar çıkacağını düşünmüştü. Şimdi sıradan kitap kodlarının daha ilginç bir şeye dönüştüğünü görüyordu: Okulun yıllar önce bilgi düzenlemek için geliştirdiği bir yönteme. “Bazen gerçek hikâye hayal ettiğinden daha sessizdir,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " buna karşı çıktı: “Ama daha çok kişiye dokunabilir.” Çünkü kodlar doğru okunursa birçok öğrenci doğru kitabı daha kolay bulabilirdi.\n\nSunumun sonunda "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gülerek, “Demek bu gizli bir oyun değilmiş,” dedi.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Ama bundan iyi bir oyun çıkarabiliriz,” diye karşılık verdi. Çocuklar bir sınıf etkinliği tasarladı. Her grubun önüne uydurma kitap kodlarından oluşan üç dizi koydular. Öğrencilerin görevi yalnızca diziyi devam ettirmek değil, farklı açıklamalar arasından hangisinin kanıtlarla uyuştuğunu seçmekti.\n\nEtkinlikte en çok tartışılan soru, verilen dizinin devamındaki sayının ne olacağı değildi. “Bu dizinin kitap kodu olduğunu nasıl anlarsınız?” sorusuydu. Bazı öğrenciler eski katalog kartlarını inceledi, bazıları başlıkların benzerliğine baktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bir grubun bütün sayıları doğru devam ettirdiği hâlde yanlış kitap seçtiğini gördü. Böylece örüntü kuralının doğru olmasıyla belgenin açıklamasının doğru olmasının farklı şeyler olduğunu daha iyi anladı. İrem, oyunun sonunda çocuklardan yalnızca cevabı değil, kullandıkları kanıtı da yazmalarını istedi.\n\nİlk gruptaki çocuklar sayıları çözdü ama yanlış sonuca vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onları hemen düzeltmedi. “Hangi bilgiye dayanıyorsunuz?” diye sordu. Çocuklar kartları yeniden inceledi ve kendi hatalarını buldu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " öğretmeni gibi davranmaktan hoşlanmıştı; daha çok, bir ipucunu paylaşmanın sevincini yaşıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Arşive kaldırılmadan önce "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " son kez kapaktaki yıpranmış etikete baktı. İlk gün ona tuhaf gelen “Nöbet Devir Teslimi” sözünün ne anlattığını şimdi daha iyi anlıyordu. Öğrenciler bir zamanlar kitapların düzenli bulunması için birbirlerine görev devretmişti. Bu küçük sorumluluk, yıllar sonra başka öğrencilerin araştırmasına konu olmuştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun şaşırtıcı bir bağlantı olduğunu düşündü: Birinin özenle tuttuğu kayıt, başka birinin doğruyu bulmasına yardım edebilirdi.\n\nKırmızı defter okul arşivine güvenle kaldırıldı. Kapak sayfasına, öğrencilere ait kişisel bilgiler paylaşılmadan hazırlanmış kısa bir açıklama eklendi. Münevver Hanım ayrıca buldukları eski katalog kartlarını sınıfta kullanılacak örneklerle karıştırmamalarını istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun nedenini sorunca, araştırma için hazırladıkları kopyalarla gerçek arşiv belgelerinin ayrı tutulmasının önemini anladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kopyaların üstüne “Etkinlik örneği” yazdı. İrem gerçek kartların nerede korunduğunu dosyaya ekledi. Sonradan defteri inceleyen herkes böylece hangi belgenin asıl, hangisinin öğrenme amaçlı hazırlanmış örnek olduğunu ayırt edebilecekti.\n\nBöylece defterin geçmişte ne işe yaradığı ve neden korunduğu bilinecekti.\n\nİrem ile "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kütüphanedeki raf düzeni hakkında küçük bir anket de yapmıştı. Bazı öğrenciler kitapları başlığa göre, bazıları türe göre aramayı tercih ediyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başlangıçta “Bir yöntem seçelim, herkes ona uysun,” demişti. Münevver Hanım, farklı okurların ihtiyaçlarını dikkate almanın kütüphaneyi daha kullanışlı kılabileceğini anlattı. Çocuklar basit bir arama yönlendirmesi hazırladı: Aradığın kitabın adını biliyorsan katalogdan, konu arıyorsan raf etiketlerinden başla. Bu küçük öneri, çözülmüş bir sayı dizisinin gerçek hayatta nasıl işe yarayabileceğini gösterdi.\n\nDönem sonu geldiğinde satranç kulübü yeni üyelerini karşılamak için tanışma günü düzenledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", eski hâli gibi hemen en iyi hamleyi göstermedi. Yeni üye sonunda bir hamle yaptı ve kendi düşünme yolunu açıkladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başlangıçta başka bir hamleyi tercih edecekti. Fakat arkadaşının gerekçesini dinleyince konumu farklı açıdan görmeye başladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " “Kırmızı defter sana satrançta da işe yaradı,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülümsedi. “Önce hamlenin nereden geldiğini anlamak gerekiyor,” diye karşılık verdi. Sayıların bağlamı olduğu gibi kararların da bağlamı vardı.\n\nYeni gelen bir öğrenci düşünürken sabırla bekledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bunu fark edip gülümsedi. “Kırmızı defter sana da bir şey öğretmiş,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " omuz silkti. “Evet. Bazen doğru cevabı ilk bulan kişi olmak en önemli şey değilmiş.” İrem onların konuşmasını duydu. Kütüphanede öğrendikleri sabır, artık satranç masasında da işe yarıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir hafta sonra İrem, "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " sırasına küçük bir not bıraktı: “7, 12, 17, 22, ?” Altına “Bugün yeni bir bilmece var,” yazmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülümsedi. “Yirmi yedi,” diye cevap verdi.\n\n"
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yanlarından geçerken “Peki bu sayı neyi gösteriyor?” diye sordu.\n\nArtık kızgın ya da acele hissettiğinde de aynı soruyu kendisine yöneltiyordu: “Bunu nereden biliyorum?” Bu, her kararını mükemmel yapmıyordu. Ama düşünmeden konuştuğu anları daha kolay fark etmesine yardım ediyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ve İrem de yeni bir bulmaca gördüklerinde önce kanıt arıyorlardı.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " daha önce satranç maçlarında yenilince hemen yeni bir oyun oynamak isterdi. Bu kez kaybetmenin ardından aynı konuma bakmayı, yanlış hamlenin neden yanlış olduğunu anlamayı denedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ona kırmızı defterdeki ilk varsayımlarını hatırlattı. “Biz de puan sandık, sonra kontrol ettik,” dedi. İrem, hatanın kaynağını anlamanın yalnızca matematikte değil birçok konuda işe yaradığını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eski sayı tablosuna baktı. Sayıların ardında görmediği düzeni fark etmesi için yalnızca işlem yapması yetmemişti; defterin kim tarafından ve ne amaçla tutulduğunu da anlaması gerekmişti. Artık yeni bir bilmeceyle karşılaştığında ilk hamlesi tahmin yürütmek değil, soruyu dikkatle okumak olacaktı.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kalemi bıraktı. İlk gün olsaydı sayının bir puan, şifre veya gizli kapı olduğunu hemen söyleyebilirdi. Şimdi İrem'e döndü: “Önce bunun ne için yazıldığını sorayım.”\n\nİrem güldü. “Haklısın. Bu sefer yalnızca bir örüntü oyunu.”\n\nBir gün babası "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " evdeki alışveriş listesini gösterdi. Her ürünün yanında farklı sayılar vardı: miktar, fiyat ve tarih. “Bunların hepsini aynı kurala göre mi okursun?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güldü. “Hayır. Üç yumurta yazıyorsa yanındaki üç sayı puan değil; miktar!” Babası, “İşte "
        },
        {
          "t": "kelime",
          "yuva": "pd_baglam"
        },
        {
          "t": "metin",
          "v": ",” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " okul kütüphanesinde öğrendiklerinin markette bile karşısına çıkmasına şaşırdı. Matematiğin yalnızca kâğıttaki işlemlerden ibaret olmadığını, doğru anlamanın günlük yaşamla bağlantılı olduğunu düşündü.\n\n"
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " aklına kırmızı defterin kapağı geldi. İçinde çok sayıda rakam vardı ama hiçbiri tek başına gizemli değildi. Gizemi oluşturan, sayıların nerede, ne zaman ve ne amaçla kullanıldığıydı. Bazı sırlar bir kapının arkasında değil, sıradan bir kaydın doğru okunmasında saklı olabiliyordu. "
        },
        {
          "t": "isaret",
          "kod": "anahtar"
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
      "dayanak_sayfa": 5,
      "metin": "Çocuklar 104, 107, 110 ve benzeri sayıları üç sütunlu bir tabloya yazınca ne gördü?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sütunlar rastgele değişiyordu"
        },
        {
          "id": "B",
          "metin": "Tüm sayılar tek bir sütuna sığıyordu"
        },
        {
          "id": "C",
          "metin": "Sayfayı dikey okuyunca her sütun üçer artıyor, yatay okuyunca sayılar birer birer ilerliyordu"
        },
        {
          "id": "D",
          "metin": "Sayılar hiçbir düzen göstermiyordu"
        }
      ],
      "dogru": "C",
      "aciklama": "Aynı sayılar okuma yönüne göre farklı bir dizi gibi görünüyordu; bu yüzden tablo biçimini bilmek önemliydi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Kulüp başkanı, “Şifreyi çözdük!” diye bağıran arkadaşını neden durdurdu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir tek kartta eşleşme bulmak yeterli değildi; tesadüf olma ihtimali vardı"
        },
        {
          "id": "B",
          "metin": "Çünkü defterin sahibinin izni yoktu"
        },
        {
          "id": "C",
          "metin": "Çünkü şifrenin çözülmesini istemiyordu"
        },
        {
          "id": "D",
          "metin": "Çünkü katalog kartları kaybolmuştu"
        }
      ],
      "dogru": "A",
      "aciklama": "İlk eşleşmeden sonra iki kart daha bulununca tesadüf ihtimali azaldı; bir tek eşleşme kanıt için yeterli görülmedi."
    },
    {
      "id": "s3",
      "beceri": "cikarim",
      "dayanak_sayfa": 7,
      "metin": "Kulüp etkinliğinde bir grup bütün sayıları doğru devam ettirdiği hâlde neden yanlış kitabı seçti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü grup sayıları hiç saymadı"
        },
        {
          "id": "B",
          "metin": "Çünkü katalog kartları tamamen boştu"
        },
        {
          "id": "C",
          "metin": "Çünkü etkinlikte kitap seçilmiyordu"
        },
        {
          "id": "D",
          "metin": "Çünkü örüntü kuralının doğru olması, belgenin açıklamasının doğru olduğunu göstermez"
        }
      ],
      "dogru": "D",
      "aciklama": "Grup kuralı doğru uyguladı ama sayıların neyi gösterdiğini kanıtlarla kontrol etmedi."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 5,
      "metin": "Kulüp başkanının yıldız işareti için “Kesinlikle yıldız bunu gösteriyor” yazmayıp “Olası açıklama, doğrulanmadı” notunu düşmesi neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yıldızın hiçbir anlamı olmadığını"
        },
        {
          "id": "B",
          "metin": "Kanıtla desteklenmeyen bir açıklamayı kesin bilgi gibi yazmamak gerektiğini"
        },
        {
          "id": "C",
          "metin": "Defterin sayfalarının eksik olduğunu"
        },
        {
          "id": "D",
          "metin": "Başkalarının fikirlerinin hep yanlış olduğunu"
        }
      ],
      "dogru": "B",
      "aciklama": "Yıldızın anlamını doğrulayacak bir açıklama defterde yoktu; bu yüzden not ‘olası açıklama’ olarak düşüldü."
    },
    {
      "id": "s5",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Bir örüntü bulduk ama neyi gösterdiğini bilmiyoruz” cümlesinde örüntü ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir kuralı olan, kendini tekrar eden düzen"
        },
        {
          "id": "B",
          "metin": "Defterin kırmızı kapağı"
        },
        {
          "id": "C",
          "metin": "Bir kütüphane görevlisinin adı"
        },
        {
          "id": "D",
          "metin": "Bir satranç hamlesinin adı"
        }
      ],
      "dogru": "A",
      "aciklama": "104, 107, 110, 113 dizisinde her sayı bir öncekinden üç fazlaydı; bu bir kuraldı, yani örüntüydü."
    },
    {
      "id": "s6",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 9,
      "metin": "Babanın “İşte bağlam” sözü, sayıların anlamı hakkında ne anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sayılar her yerde aynı şeyi anlatır"
        },
        {
          "id": "B",
          "metin": "Sayıların anlamı yalnızca matematik kitabında bulunur"
        },
        {
          "id": "C",
          "metin": "Bir sayının ne anlama geldiği, nerede ve hangi amaçla kullanıldığına bağlıdır"
        },
        {
          "id": "D",
          "metin": "Sayılar hiçbir zaman bir şey anlatmaz"
        }
      ],
      "dogru": "C",
      "aciklama": "Alışveriş listesinde ‘üç’ yazan sayı puan değil miktardı; anlamı kullanıldığı yer belirledi."
    },
    {
      "id": "s7",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "Kâğıtlara yazılan “Oyun puanı”, “Kitap kodu” gibi varsayımlar ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kanıtlanmış ve kesin bilgiler"
        },
        {
          "id": "B",
          "metin": "Defterden kesin olarak okunan cümleler"
        },
        {
          "id": "C",
          "metin": "Yarışma kuralları"
        },
        {
          "id": "D",
          "metin": "Henüz doğrulanmamış, doğru olabileceği düşünülen açıklamalar"
        }
      ],
      "dogru": "D",
      "aciklama": "Her varsayımın altına onu destekleyen ya da zayıflatan bilgiler eklendi; sevilen fikri değil doğru olanı bulmak amaçlandı."
    },
    {
      "id": "s8",
      "beceri": "degerlendirme",
      "dayanak_sayfa": 6,
      "metin": "Sunum hazırlığında metni “önce merak sorusu, sonra ipuçları, en sonunda çözüm” biçiminde üç parçaya ayırma önerisi neden iyidir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çünkü sunumu kısaltmak için ayrıntıların hepsi silinir"
        },
        {
          "id": "B",
          "metin": "Çünkü dinleyiciler yolu takip edebilir, anlatılan bilgilerin ayrıntıları da korunur"
        },
        {
          "id": "C",
          "metin": "Çünkü kimse soru sormaz"
        },
        {
          "id": "D",
          "metin": "Çünkü sayılar artık önemsizdir"
        }
      ],
      "dogru": "B",
      "aciklama": "Bu düzen hem ayrıntıları korudu hem de dinleyicilerin hangi sayının neyi gösterdiğini karıştırmasını önledi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  }
}$p15$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr047-kirmizi-defterin-sifresi: %', v_r; end if;

  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr033-ye-kurkum-ye-peki-neden' where fis_kodu = 'HR-033';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr034-2040-konusan-okul-cantasi' where fis_kodu = 'HR-034';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr035-aya-giden-ilk-posta' where fis_kodu = 'HR-035';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr036-yedi-renkli-koprunun-koruyucusu' where fis_kodu = 'HR-036';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr037-son-pasin-hikayesi' where fis_kodu = 'HR-037';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr038-muzik-kutusunun-sifresi' where fis_kodu = 'HR-038';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr039-ankanin-kaybolan-tuyu' where fis_kodu = 'HR-039';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr040-trenin-penceresindeki-turkiye' where fis_kodu = 'HR-040';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr041-yedi-adimda-kayip-ada' where fis_kodu = 'HR-041';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr042-kapadokyanin-gizli-gecidi' where fis_kodu = 'HR-042';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr043-kuledeki-son-isik' where fis_kodu = 'HR-043';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr044-buz-golunun-haritasi' where fis_kodu = 'HR-044';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr045-kutuphanenin-on-ucuncu-rafi' where fis_kodu = 'HR-045';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr046-bilinmeyen-posta-pulu' where fis_kodu = 'HR-046';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr047-kirmizi-defterin-sifresi' where fis_kodu = 'HR-047';
end
$pilot$;

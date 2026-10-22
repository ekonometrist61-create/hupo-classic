-- =====================================================================
-- Hikâyelerin yeni sürümleri (taslak): kavram-ikon eşleşmeleri (ikonlar metnin içinde) ve hikâyeye özgü
-- sözlük (kelime/atasözü anlamları) paketin içinde. 45 hikâyeye yeni TASLAK sürüm girer.
--   * Yayın bu migration'da YOKTUR. Yayına alma, insan okuması onayından sonra yönetim panelinden yapılır.
--   * Yönetici olarak çalışan ilk admin profilinin kimliğiyle içe aktarır (require_admin).
--   * Her adım sonuç kontrolü yapar; bir hata olursa işlemin tamamı geri alınır.
-- =====================================================================

set client_encoding = 'UTF8';

do $ikon$
declare
  v_admin uuid;
  v_r     jsonb;
begin
  select id into v_admin from public.profiles where role = 'admin' order by id limit 1;
  if v_admin is null then
    raise exception 'içe aktarma: yönetici profil bulunamadı';
  end if;
  perform set_config('request.jwt.claims', json_build_object('sub', v_admin, 'role', 'authenticated')::text, true);
  v_r := public.okuma_paket_ice_aktar($p01${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr001-kayip-canin-izinde",
    "baslik": "Kayıp Çanın İzinde",
    "tur": "macera",
    "konu": "bahce",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "kardes",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D20"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "okul",
        "kesif"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D20"
      },
      "ogrenme_hedefleri": [
        {
          "id": "dikkatle",
          "tur": "lexeme",
          "etiket": "dikkatle",
          "yuva": "s2_dikkatle",
          "islev": "first_hint"
        },
        {
          "id": "uzak",
          "tur": "lexeme",
          "etiket": "uzak",
          "yuva": "s2_uzak",
          "islev": "application"
        },
        {
          "id": "kavram_hr001",
          "tur": "concept",
          "etiket": "Sesin kaynağı",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 206,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 7,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1
        },
        "yoldas_yer_sayisi": 4,
        "simge_sayisi": 8
      }
    },
    "tanitim": "Okul bahçesindeki küçük çan kayboldu. Sesini dinleyerek onu bulabilir miyiz?",
    "durum": "taslak",
    "fis_kodu": "HR-001"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bahçedeki küçük çanın yerinde yalnızca bir ip sallanıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sabah"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " zilini beklerken şaşırdı. \"Çan"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " nereye gitti?\" diye sordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kulağını kaldırdı. Yaprakların arasından "
        },
        {
          "t": "kelime",
          "yuva": "s2_uzak"
        },
        {
          "t": "metin",
          "v": " bir çın sesi geldi. "
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
          "v": "Önce oyun kulübesine baktılar. Kulübe sessizdi. Sonra çeşmenin yanına yürüdüler. Ses biraz daha yakın duyuluyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ağaca koşmak istedi. Ama "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " durdurdu: \"Önce "
        },
        {
          "t": "kelime",
          "yuva": "s2_dikkatle"
        },
        {
          "t": "metin",
          "v": " bakalım.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Tam o sırada okulun bahçesinde bir kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " öttü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını çevirdi. Kuşun sesi çanın sesine karışmıştı. Bir süre konuşmadan beklediler. Teneffüs bitip kalabalık sınıfa girince çın sesi yeniden duyuldu."
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
          "v": " gözlerini kapadı. Ses sol taraftan geliyordu. Önlerinde üç ağaç"
        },
        {
          "t": "ikon",
          "v": "tree"
        },
        {
          "t": "metin",
          "v": " vardı. İlk ağacın dallarında yalnızca yapraklar sallanıyordu. İkinci ağacın altında bir kedi"
        },
        {
          "t": "ikon",
          "v": "cat"
        },
        {
          "t": "metin",
          "v": " uyuyordu. Üçüncü ağacın en alt dalında ise bir ip parçası sarkıyordu."
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
          "v": " hemen yukarı uzanmak istedi. Ancak yerde kaygan taşlar vardı. \"Dur,\" dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". \"Önce bahçe görevlisine haber verelim.\" Çocuklar gördüklerini anlattı. Cemil amca uzun saplı güvenli bir araçla çanı aşağı indirdi."
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
          "v": " çanı eline alınca gülümsedi. \"Sesin yakın mı uzak mı olduğunu dinleyerek anlayabiliyoruz,\" dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " başını salladı. Çan"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " yeniden yerine asıldı. O gün ders zili her zamankinden güzel çaldı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi sabah"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sessizce bahçeyi dinledi. Kuşların ötüşünü, hafif rüzgârı ve çanın sesini birbirinden ayırabildi. Arkadaşı \"Bütün sesler aynı mı?\" diye sorduğunda gülümsedi. \"Hayır,\" dedi, \"dinleyince her birinin yerini bulabiliyoruz.\""
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
      "metin": "Çanın yerinde ne vardı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sallanan bir ip"
        },
        {
          "id": "B",
          "metin": "Uyuyan bir kedi"
        },
        {
          "id": "C",
          "metin": "Açık bir kapı"
        }
      ],
      "dogru": "A",
      "aciklama": "Çanın yerinde yalnızca bir ip sallanıyordu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Çocuk çanın sesini neden bir süre duyamadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kuşun sesi çanın sesine karıştığı için"
        },
        {
          "id": "B",
          "metin": "Çan bahçeden çok uzaklaştığı için"
        },
        {
          "id": "C",
          "metin": "Kulaklarını kapattıkları için"
        }
      ],
      "dogru": "A",
      "aciklama": "Bir kuş öttü ve çanın sesi kuşun sesine karıştı."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Hikâyenin sonunda çocuk neyi öğrenmiştir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bütün seslerin birbirinin aynısı olduğunu"
        },
        {
          "id": "B",
          "metin": "Dinleyerek seslerin yerini bulabileceğini"
        },
        {
          "id": "C",
          "metin": "Çanın artık hiç çalmayacağını"
        }
      ],
      "dogru": "B",
      "aciklama": "Çocuk, dinleyince her sesin yerini bulabildiğini söyledi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "Metinde geçen dikkatle sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Özen göstererek"
        },
        {
          "id": "B",
          "metin": "Çok hızlı"
        },
        {
          "id": "C",
          "metin": "Yüksek sesle"
        }
      ],
      "dogru": "A",
      "aciklama": "Hupo, önce özenle bakmalarını söyledi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_dikkatle",
        "tur": "kelime",
        "yazim": "dikkatle",
        "anlam": "Özen göstererek, işini iyi yaparak.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_uzak",
        "tur": "kelime",
        "yazim": "uzak",
        "anlam": "Yakın olmayan, bir yere çok ileride olan.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_dikkatle",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_dikkatle"
          }
        ]
      },
      {
        "ad": "s2_uzak",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_uzak"
          }
        ]
      }
    ]
  }
}$p01$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr001-kayip-canin-izinde: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p02${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr002-renkli-ucurtma",
    "baslik": "Renkli Uçurtmanın Peşinde",
    "tur": "macera",
    "konu": "mahalle",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "kardes",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D20"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kesif",
        "dayanisma"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D20"
      },
      "ogrenme_hedefleri": [
        {
          "id": "yukari",
          "tur": "lexeme",
          "etiket": "yukarı",
          "yuva": "s2_yukari",
          "islev": "first_hint"
        },
        {
          "id": "harita",
          "tur": "lexeme",
          "etiket": "harita",
          "yuva": "s2_harita",
          "islev": "application"
        },
        {
          "id": "kavram_hr002",
          "tur": "concept",
          "etiket": "Yönler",
          "islev": "application"
        },
        {
          "id": "atasoz_hr002",
          "tur": "proverb",
          "etiket": "Komşu komşunun külüne muhtaçtır",
          "yuva": "ata_komsu",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 225,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 6,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 10
      }
    },
    "tanitim": "Rüzgâr uçurtmayı sokaklara taşıdı. Bir harita çizen çocuk onu bulabilir mi?",
    "durum": "taslak",
    "fis_kodu": "HR-002"
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
          "v": " kırmızı, sarı ve mavi parçalarla bir uçurtma yapmıştı. Uçurtma birden "
        },
        {
          "t": "kelime",
          "yuva": "s2_yukari"
        },
        {
          "t": "metin",
          "v": " yükseldi. İpi elinden kayınca sokak boyunca uçup gitti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " arkasından koşacaktı ki "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kanadını açtı. \"Koşmadan önce nereye gittiğini görelim.\" "
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
          "v": "Uçurtma önce fırının üstünden geçti. Sonra sola kıvrıldı ve saatli dükkânın arkasına kayboldu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " cebindeki küçük deftere bir çizgi çizdi. Fırını, dükkânı ve büyük dut ağacını işaretledi. Böylece deftere küçük bir "
        },
        {
          "t": "kelime",
          "yuva": "s2_harita"
        },
        {
          "t": "metin",
          "v": " çizilmiş oldu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Fırının önünde ekmek"
        },
        {
          "t": "ikon",
          "v": "seed"
        },
        {
          "t": "metin",
          "v": " kokusu vardı. Fırıncı dışarı çıktı. \"Biraz önce renkli bir şey geçti,\" dedi. \"Rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " onu batıya sürükledi.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterinin köşesine küçük bir ok çizdi. İlk kez bir harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " yapmanın işe yaradığını düşündü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sokağın sonunda iki yol ayrılıyordu. Biri yokuş yukarı çıkıyor, diğeri parka iniyordu. Hangi yolu seçeceğini bilemeyen "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yerdeki kurdeleye baktı. Bir süre sonra pencerede asılı rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " gülünün kanatlarının parka doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " döndüğünü fark etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " rüzgârın ara sıra yön"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " değiştirdiğini hatırlattı. Yalnızca buna güvenemezlerdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Dut ağacının yanına vardıklarında uçurtma görünmüyordu. Tam dönerken üst kattan bir ses"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " duyuldu: \"Bunu mu arıyorsunuz?\" Yaşlı bir komşu uçurtmayı balkonda bulmuştu. Balkona çıkıp almak yerine kapıyı çalıp yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " istediler. Komşu uçurtmayı güvenle getirdi. Bu yardımla "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " aklına şu söz geldi: \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_komsu"
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
          "v": " haritasına son bir işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " koydu. \"Yukarıda gördüm, aşağıda buldum!\" diye güldü. Bu kez ipi sağlam bağladı. Akşam arkadaşlarına hem uçurtmayı hem de üç sokaklık maceranın haritasını gösterdi. Annesi, onun dikkatine ve yardımlaşmaya sevindi."
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
      "metin": "Uçurtma ilk olarak nerenin üstünden geçti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Fırının"
        },
        {
          "id": "B",
          "metin": "Okulun"
        },
        {
          "id": "C",
          "metin": "Parkın"
        }
      ],
      "dogru": "A",
      "aciklama": "Uçurtma önce fırının üstünden geçti."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Çocuk deftere çizgi ve işaretler neden çizdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Uçurtmanın gittiği yolu hatırlamak için"
        },
        {
          "id": "B",
          "metin": "Defteri süslemek için"
        },
        {
          "id": "C",
          "metin": "Arkadaşlarına resim göstermek için"
        }
      ],
      "dogru": "A",
      "aciklama": "Fırını, dükkânı ve dut ağacını işaretleyerek uçurtmanın yolunu takip etti."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Çocuk uçurtmasını bulunca ipi neden bu kez sağlam bağladı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir daha kaybolmasın diye"
        },
        {
          "id": "B",
          "metin": "Uçurtma çok ağır olduğu için"
        },
        {
          "id": "C",
          "metin": "Komşu ona bunu söylediği için"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuk, sağlam bağlarsa uçurtmanın bir daha uçup gitmeyeceğini öğrenmişti."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "Metinde geçen harita sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yolları ve yerleri gösteren çizim"
        },
        {
          "id": "B",
          "metin": "Uçan bir oyuncak"
        },
        {
          "id": "C",
          "metin": "Büyük bir kapı"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuk defterine yolları ve yerleri gösteren bir çizim yaptı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_yukari",
        "tur": "kelime",
        "yazim": "yukarı",
        "anlam": "Daha yüksek bir yöne doğru.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_harita",
        "tur": "kelime",
        "yazim": "harita",
        "anlam": "Bir yeri, yolları ve önemli yerleri gösteren çizim.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_komsu",
        "tur": "atasozu",
        "yazim": "Komşu komşunun külüne muhtaçtır",
        "anlam": "Komşuya her zaman ihtiyaç duyulur; komşular birbirine yardım eder.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_yukari",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_yukari"
          }
        ]
      },
      {
        "ad": "s2_harita",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_harita"
          }
        ]
      },
      {
        "ad": "ata_komsu",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_komsu"
          }
        ]
      }
    ]
  }
}$p02$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr002-renkli-ucurtma: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p03${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr003-corabini-arayan-robot",
    "baslik": "Çorabını Arayan Robot",
    "tur": "mizah",
    "konu": "ev",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "hayali"
    ],
    "deger_anahtarlari": [
      "D12"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "mizah",
        "okul"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D12"
      },
      "ogrenme_hedefleri": [
        {
          "id": "yuvarlak",
          "tur": "lexeme",
          "etiket": "yuvarlak",
          "yuva": "s2_yuvarlak",
          "islev": "first_hint"
        },
        {
          "id": "kosel",
          "tur": "lexeme",
          "etiket": "köşeli",
          "yuva": "s2_kosel",
          "islev": "application"
        },
        {
          "id": "kavram_hr003",
          "tur": "concept",
          "etiket": "Sınıflandırma",
          "islev": "application"
        },
        {
          "id": "atasoz_hr003",
          "tur": "proverb",
          "etiket": "Her parlayan altın değildir",
          "yuva": "ata_parlayan",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 230,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 6,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 7
      }
    },
    "tanitim": "Ev robotu her mavi nesneyi çorap sanıyor. Doğru olanı nasıl bulacak?",
    "durum": "taslak",
    "fis_kodu": "HR-003"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ev robotu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sabah yüksek sesle bağırdı: \"Mavi çorabımı bulamıyorum!\" Aslında çorabı yoktu. Ama ne zaman mavi bir şey görse onu çorap sanıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Önce mavi kupayı getirdi. \"İşte!\" dedi. Zeynep güldü: \"Kupa "
        },
        {
          "t": "kelime",
          "yuva": "s2_yuvarlak"
        },
        {
          "t": "metin",
          "v": " ve serttir. Çorap yumuşaktır.\" Bu kez mavi defteri getirdi. \"Defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " düz ve "
        },
        {
          "t": "kelime",
          "yuva": "s2_kosel"
        },
        {
          "t": "metin",
          "v": ", çorap değil,\" dedi Zeynep."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Zeynep robotun önüne mavi bir mendil koydu. \"Bu çorap mı?\" diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ışıklarını yakıp söndürdü. \"Mavi. O hâlde çorap olmalı!\" \"Mendil de mavi olabilir. Renk tek başına yetmez,\" dedi Zeynep. Bir atasözü der ki: \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_parlayan"
        },
        {
          "t": "metin",
          "v": "\". Robot"
        },
        {
          "t": "ikon",
          "v": "robot"
        },
        {
          "t": "metin",
          "v": " odanın köşesinden mavi bir oyuncak araba"
        },
        {
          "t": "ikon",
          "v": "car"
        },
        {
          "t": "metin",
          "v": " getirdi. Zeynep gülmekten sandalyeye oturdu. "
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
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yere üç çember çizdi ve üzerlerine \"renk\", \"biçim\" ve \"iş\" yazdı. Zeynep her çembere örnekler çizdi. Çorap yumuşak ve uzundu, kupanın sapı vardı, arabanın tekerlekleri dönüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " nesneleri çemberlere yerleştirmeye başladı. Mavi bir topu önce çorap bölümüne koydu. Sonra topun yuvarlandığını görünce düzeltti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Oyunu biraz zorlaştırdılar. Masaya bir çorap, bir kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " ve bir top"
        },
        {
          "t": "ikon",
          "v": "ball"
        },
        {
          "t": "metin",
          "v": " koydular. \"Yalnız renge değil, biçime ve ne işe yaradığına da bak,\" dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". Kitap okunuyordu, topla oynanıyordu, çorap ayağa giyiliyordu. Sonunda mavi çorabı çamaşır sepetinde buldular."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "\"Peki benim ayağım nerede?\" diye sordu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ciddi bir sesle. Herkes güldü. O günden sonra bir şeyin ne olduğunu anlamadan önce iki kez bakmaya karar verdi. Ertesi gün mutfakta bir limon gördü. \"Sarı top"
        },
        {
          "t": "ikon",
          "v": "ball"
        },
        {
          "t": "metin",
          "v": "!\" diye bağıracaktı ama durup kokladı. \"Hayır, bu limon.\""
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
      "metin": "Robot başta neyi bulamadığını söyledi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Mavi çorabını"
        },
        {
          "id": "B",
          "metin": "Kırmızı topunu"
        },
        {
          "id": "C",
          "metin": "Sarı limonunu"
        }
      ],
      "dogru": "A",
      "aciklama": "Robot sabah mavi çorabını bulamadığını söyledi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Robot mavi mendili neden çorap sandı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Mavi olduğu için"
        },
        {
          "id": "B",
          "metin": "Yumuşak olduğu için"
        },
        {
          "id": "C",
          "metin": "Uzun olduğu için"
        }
      ],
      "dogru": "A",
      "aciklama": "Robot, mavi olan her şeyin çorap olabileceğini düşündü."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Robot son sahnede hangi davranışı kazandı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir şeyi tanımadan önce iki kez bakmayı"
        },
        {
          "id": "B",
          "metin": "Hiç konuşmamayı"
        },
        {
          "id": "C",
          "metin": "Renklere hiç bakmamayı"
        }
      ],
      "dogru": "A",
      "aciklama": "Robot, bir şeyin ne olduğunu anlamadan önce iki kez bakmaya karar verdi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "Metinde geçen yuvarlak sözcüğü hangisini anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Köşesi olmayan, daire gibi olan"
        },
        {
          "id": "B",
          "metin": "Çok büyük olan"
        },
        {
          "id": "C",
          "metin": "Renkli olan"
        }
      ],
      "dogru": "A",
      "aciklama": "Kupa yuvarlaktır; sert ve köşesizdir."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_yuvarlak",
        "tur": "kelime",
        "yazim": "yuvarlak",
        "anlam": "Köşesi olmayan, daire gibi olan.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_kosel",
        "tur": "kelime",
        "yazim": "köşeli",
        "anlam": "Köşesi olan, düz kenarları bulunan.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_parlayan",
        "tur": "atasozu",
        "yazim": "Her parlayan altın değildir",
        "anlam": "Dışarıdan güzel görünen her şey değerli ya da doğru değildir.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_yuvarlak",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_yuvarlak"
          }
        ]
      },
      {
        "ad": "s2_kosel",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_kosel"
          }
        ]
      },
      {
        "ad": "ata_parlayan",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_parlayan"
          }
        ]
      }
    ]
  }
}$p03$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr003-corabini-arayan-robot: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p04${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr004-ters-gun-okulda",
    "baslik": "Ters Gün Okulda",
    "tur": "mizah",
    "konu": "okul",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "kardes",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D14"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "okul",
        "mizah"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D14"
      },
      "ogrenme_hedefleri": [
        {
          "id": "erken",
          "tur": "lexeme",
          "etiket": "erken",
          "yuva": "s2_erken",
          "islev": "first_hint"
        },
        {
          "id": "gec",
          "tur": "lexeme",
          "etiket": "geç",
          "yuva": "s2_gec",
          "islev": "application"
        },
        {
          "id": "kavram_hr004",
          "tur": "concept",
          "etiket": "Kurallar",
          "islev": "application"
        },
        {
          "id": "atasoz_hr004",
          "tur": "proverb",
          "etiket": "Dost acı söyler",
          "yuva": "ata_dost_aci",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 241,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 6,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 10
      }
    },
    "tanitim": "Okulun tabelaları karıştı. Şaka ile gerçek işaretleri nasıl ayıracaklar?",
    "durum": "taslak",
    "fis_kodu": "HR-004"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Okula gelen çocuklar kapıda \"GİRİLMEZ\" yazısını görünce durdu. Oysa öğretmenleri içeride bekliyordu. Sınıfta tabelalar birbirine karışmıştı: pencereye \"KAPALI\", kapıya \"AÇIK\" yazılmıştı. \"Biri ters gün oyunu yapmış!\" dedi "
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
          "v": "Koridorda yerde \"SAĞA DÖN\" yazan bir kart vardı. Ok ise sola bakıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce güldü. Sonra küçük kardeşinin bu okula yeni geldiğini düşündü. Kardeşi bu işareti görse yanlış yere gidebilirdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de bunu kabul etti: şaka herkes için komik olmayabilir. Bir arkadaşın doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " uyarısı için \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_dost_aci"
        },
        {
          "t": "metin",
          "v": "\" denir."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sınıf"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " tahtasına \"BUGÜN YARIN\" yazılmıştı. Öğretmen çocuklardan ters anlamlı sözcükler bulmalarını istedi. Bir çift de "
        },
        {
          "t": "kelime",
          "yuva": "s2_erken"
        },
        {
          "t": "metin",
          "v": " ile "
        },
        {
          "t": "kelime",
          "yuva": "s2_gec"
        },
        {
          "t": "metin",
          "v": " oldu. Zeynep \"Gece"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": " ve gündüz!\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " \"Temiz ve kirli!\" diye ekledi. Her çift için doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " anlamı gösteren küçük bir resim çizdiler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Gerçek yön"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " levhaları yerinde kaldı. Oyun için ayrı bir pano yaptılar ve üstüne \"ŞAKA KÖŞESİ\" yazdılar. Orada \"ÇOK UZUN KISA CETVEL\" gibi komik ifadeler vardı. Herkes bunun bir oyun olduğunu anlayabiliyordu. Melis, şaka için başkalarını zor durumda bırakmaya gerek olmadığını kabul etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " tabelaları ayrı bir köşeye koymayı önerdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir tabela çözülemedi: \"SESSİZ KAHKAHA ALANI.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " elini kaldırdı. \"Kahkaha sesli olur. Sessiz kahkaha nasıl"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " olur?\" Hep birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " ağızlarını açıp ses"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " çıkarmadan gülmeye çalıştılar. Tabelanın sahibi Melis'ti. Özür diledi ve öğretmeninin yardımıyla şaka köşesini düzenledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Günün sonunda Melis duvarın en üstüne küçük bir not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " ekledi: \"Oyun ayrı, gerçek işaretler ayrı.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " karşısına bir gülümseme çizdi. Ertesi gün öteki sınıflardan gelen öğrenciler şaka köşesine uğrayıp kendi zıt anlamlı sözcük çiftlerini ekledi. "
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
      "dayanak_sayfa": 1,
      "metin": "Okulun kapısında hangi yazı vardı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "GİRİLMEZ"
        },
        {
          "id": "B",
          "metin": "HOŞ GELDİN"
        },
        {
          "id": "C",
          "metin": "SESSİZ OL"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuklar kapıda GİRİLMEZ yazısını gördü."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Çocuk sağa dön kartının şaka olduğunu bilmesine rağmen neden endişelendi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Küçük kardeşi kartı görünce yanlış yere gidebilirdi"
        },
        {
          "id": "B",
          "metin": "Kart çok büyük değildi"
        },
        {
          "id": "C",
          "metin": "Öğretmen kızacaktı"
        }
      ],
      "dogru": "A",
      "aciklama": "Yeni gelen küçük çocuk yanlış yere gidebilirdi; şaka herkes için komik olmayabilirdi."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Melis şaka köşesi hakkında ne öğrendi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Şaka yapmak için başkalarını zor durumda bırakmaya gerek olmadığını"
        },
        {
          "id": "B",
          "metin": "Şaka köşesinin okulda yasak olduğunu"
        },
        {
          "id": "C",
          "metin": "Tabela yazmanın hiç gerekmediğini"
        }
      ],
      "dogru": "A",
      "aciklama": "Melis, şakanın başkalarını zor durumda bırakmadan da yapılabileceğini kabul etti."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "Metinde geçen erken sözcüğünün zıt anlamlısı hangisidir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "geç"
        },
        {
          "id": "B",
          "metin": "yeni"
        },
        {
          "id": "C",
          "metin": "uzun"
        }
      ],
      "dogru": "A",
      "aciklama": "Erken, vaktinden önce olmak demektir; geç ise normalden sonra olmaktır."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_erken",
        "tur": "kelime",
        "yazim": "erken",
        "anlam": "Vaktinden önce olan, normalden önce gelen.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_gec",
        "tur": "kelime",
        "yazim": "geç",
        "anlam": "Vakti geçmiş, normalden sonra olan.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_dost_aci",
        "tur": "atasozu",
        "yazim": "Dost acı söyler",
        "anlam": "Gerçek dost, bazen acı da olsa doğruyu söyler.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_erken",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_erken"
          }
        ]
      },
      {
        "ad": "s2_gec",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_gec"
          }
        ]
      },
      {
        "ad": "ata_dost_aci",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_dost_aci"
          }
        ]
      }
    ]
  }
}$p04$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr004-ters-gun-okulda: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p05${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr005-hocanin-golundeki-umut",
    "baslik": "Hoca'nın Gölündeki Umut",
    "tur": "mizah",
    "konu": "goller",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D5"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "doga",
        "okul"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D5"
      },
      "ogrenme_hedefleri": [
        {
          "id": "tahmin",
          "tur": "lexeme",
          "etiket": "tahmin",
          "yuva": "s2_tahmin",
          "islev": "first_hint"
        },
        {
          "id": "gozlem",
          "tur": "lexeme",
          "etiket": "gözlem",
          "yuva": "s2_gozlem",
          "islev": "application"
        },
        {
          "id": "kavram_hr005",
          "tur": "concept",
          "etiket": "Deneme ve gözlem",
          "islev": "application"
        },
        {
          "id": "atasoz_hr005",
          "tur": "proverb",
          "etiket": "Sormakla yol bulunur",
          "yuva": "ata_sormakla",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 212,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 6,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 6
      }
    },
    "tanitim": "Nasreddin Hoca gölde yoğurt olur mu diye soruyor. Çocuklar nasıl sınayacak?",
    "durum": "taslak",
    "fis_kodu": "HR-005"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Nasreddin Hoca gölün kıyısında bir kap yoğurdu karıştırıyordu. Yanında "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de vardı. Köylü çocukları merakla yaklaştı. \"Hocam, göle ne yapıyorsun?\" diye sordular. \"Biraz maya katıyorum,\" dedi Hoca."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklardan biri gözlerini açtı: \"Koca göl yoğurt olur mu?\" Hoca gülümsedi: \"Olmayabilir. Peki bir şeyin olup olmayacağını nasıl"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " anlarız?\" Kimi \"Kesin olmaz,\" dedi, kimi \"Belki,\" diye fısıldadı. Çocuklar birer "
        },
        {
          "t": "kelime",
          "yuva": "s2_tahmin"
        },
        {
          "t": "metin",
          "v": " yürüttü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sazlıkta bir kurbağa suya atlayınca halkalar oluştu. \"Hocam, maya suya yayılırsa kurbağaya bir şey olur mu?\" diye sordu en küçük çocuk. Hoca kabı kenara koydu. \"Bir şeyi merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " ederken doğayı da düşünmeliyiz.\" Çocuklar göle hiçbir şey dökmemeye karar verdi."
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
          "v": " küçük bir kapta süt ve yoğurt ile deneme yapmayı önerdi. Köydeki yoğurt ustası sabırla anlattı: önce süt ısıtılır, sonra uygun koşullarda yoğurt oluşur. Çocuklar güvenli örneği izledi ve her adımı defterine yazdı. Defterine \"Tahmin\", \""
        },
        {
          "t": "kelime",
          "yuva": "s2_gozlem"
        },
        {
          "t": "metin",
          "v": "\" ve \"Sonuç\" başlıklarını koydu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yol boyunca "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " \"Göle maya çalmak kocaman bir hayalmiş,\" dedi. Hoca gülümsedi: \"Hayal kurmak güzel. Ama onu bilgiyle sınamak da gerek.\" Gölün kıyısına döndüklerinde suyun üstünde bir kurbağa gördüler. Göl kirlenmemişti. "
        },
        {
          "t": "isaret",
          "kod": "balik"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar, göle yoğurt dökmenin suyu kirletebileceğini de konuştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eve gidince ailesine gördüklerini anlattı. \"Her tahmin doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " olmayabilir,\" dedi, \"ama sormaktan vazgeçmemeliyiz.\" Annesi gülümsedi: \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_sormakla"
        },
        {
          "t": "metin",
          "v": "\". Babası ona bir defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterin kapağına \"Merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " Kutum\" yazdı."
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
      "metin": "Kurbağa suya atlayınca ne oldu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Suda halkalar oluştu"
        },
        {
          "id": "B",
          "metin": "Göl kurudu"
        },
        {
          "id": "C",
          "metin": "Kap devrildi"
        }
      ],
      "dogru": "A",
      "aciklama": "Kurbağa suya atlayınca etrafında halkalar oluştu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Çocuklar defterlerine neden her adımı not etti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Ne olduğunu gözlemleyip kaydetmek için"
        },
        {
          "id": "B",
          "metin": "Sınav için"
        },
        {
          "id": "C",
          "metin": "Kimseye göstermemek için"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuklar yapılanları izleyip not ederek sonucu anlamaya çalıştı."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Eve dönen çocuğun 'Her tahmin doğru olmayabilir' sözü neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Tahminler yanlış çıksa da sormak önemlidir"
        },
        {
          "id": "B",
          "metin": "Tahmin yapmak zamanın boşa harcanmasıdır"
        },
        {
          "id": "C",
          "metin": "Hiç soru sorulmamalıdır"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuk, yanlış tahminler olsa da merak edip sormaktan vazgeçmemek gerektiğini söyledi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "Metinde geçen tahmin yürütmek ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir şeyin ne olabileceğini düşünmek"
        },
        {
          "id": "B",
          "metin": "Bir şeyi tam olarak bilmek"
        },
        {
          "id": "C",
          "metin": "Hiçbir şey düşünmemek"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuklar olabileceklerini düşünerek fikir yürüttü."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_tahmin",
        "tur": "kelime",
        "yazim": "tahmin",
        "anlam": "Bir şeyin ne olabileceğini düşünerek söyleme.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_gozlem",
        "tur": "kelime",
        "yazim": "gözlem",
        "anlam": "Bir şeyi dikkatle izleyip inceleme.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_sormakla",
        "tur": "atasozu",
        "yazim": "Sormakla yol bulunur",
        "anlam": "Bilmediğimiz şeyi sorarak öğrenir, çözüm buluruz.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_tahmin",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_tahmin"
          }
        ]
      },
      {
        "ad": "s2_gozlem",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_gozlem"
          }
        ]
      },
      {
        "ad": "ata_sormakla",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_sormakla"
          }
        ]
      }
    ]
  }
}$p05$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr005-hocanin-golundeki-umut: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p06${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr006-dudek-kimin-olacak",
    "baslik": "Düdük Kimin Olacak?",
    "tur": "mizah",
    "konu": "pazar",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "kardes",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D16",
      "D1"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "sabir_emek",
        "dayanisma"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D16",
        "yardimci_deger": "D1"
      },
      "ogrenme_hedefleri": [
        {
          "id": "emek",
          "tur": "lexeme",
          "etiket": "emek",
          "yuva": "s2_emek",
          "islev": "first_hint"
        },
        {
          "id": "harclik",
          "tur": "lexeme",
          "etiket": "harçlık",
          "yuva": "s2_harclik",
          "islev": "application"
        },
        {
          "id": "kavram_hr006",
          "tur": "concept",
          "etiket": "Biriktirme",
          "islev": "application"
        },
        {
          "id": "atasoz_hr006",
          "tur": "proverb",
          "etiket": "Emek olmadan yemek olmaz",
          "yuva": "ata_emek",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 224,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 6,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 6
      }
    },
    "tanitim": "Üç çocuk Hoca'dan düdük istedi. Yalnız biri parasını biriktirmişti. Düdükler nasıl paylaşılacak?",
    "durum": "taslak",
    "fis_kodu": "HR-006"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Pazar kurulurken Nasreddin Hoca komşu köye gidiyordu. Üç çocuk peşine takıldı: \"Bize düdük getir!\" Hoca, \"Olur,\" dedi. Çocuklar sevinip koştu. Yalnızca "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " durdu. Her hafta aldığı "
        },
        {
          "t": "kelime",
          "yuva": "s2_harclik"
        },
        {
          "t": "metin",
          "v": " içinden ayırdığı küçük parayı Hoca'ya uzattı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hoca parayı alıp dikkatle baktı. \"Bu parayı neden"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " biriktirdin?\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " her hafta harçlığından küçük bir bölüm ayırdığını söyledi. Bir kez renkli bir şeker almak istemiş ama düdük için beklemeyi seçmişti. \"Bu para bir "
        },
        {
          "t": "kelime",
          "yuva": "s2_emek"
        },
        {
          "t": "metin",
          "v": " karşılığı,\" dedi Hoca. \"Harcamadan önce iyi düşünmek lazım. Hoca bunu şöyle özetledi: \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_emek"
        },
        {
          "t": "metin",
          "v": "\".\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hoca pazarda farklı boyda düdükler gördü ve "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " parasıyla küçük bir tanesini aldı. Akşam döndüğünde çocuklar etrafını sardı. Hoca kesesinden tek bir düdük çıkardı ve "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " verdi. Öteki çocuklar şaşırdı. \"Bizimki nerede?\" diye sordular."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hoca, \"Düdük istediğinizi biliyorum,\" dedi. \"Ama nasıl alınacağını konuşmamıştık. Yarın birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " bir iş bulup biriktirelim.\" Ertesi gün çocuklar evde kullanılmayan düdükleri tamir etti. Mahalledeki büyükler küçük bir şenlik hazırlamalarına yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de tamir işinde elini çabuk tuttu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar mahalle meydanını temizlemeye gönüllü oldu. Büyükler emeklerini küçük hediyelerle destekledi. Bir hafta sonra herkesin kendi düdüğü vardı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " \"Benim param var diye yalnız ben sevinmek istemem,\" dedi ve arkadaşlarına harçlıklarını nasıl planlayacaklarını gösterdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Düdük sesleri mahalleye yayılınca Hoca elini kaldırdı: \"Bir işte hem sabır"
        },
        {
          "t": "ikon",
          "v": "patience"
        },
        {
          "t": "metin",
          "v": " hem düzen önemli.\" Çocuklar sırayla çalabilecekleri küçük bir oyun kurdu. Düdükler artık birbirine karışmıyordu. "
        },
        {
          "t": "isaret",
          "kod": "kalp"
        },
        {
          "t": "metin",
          "v": " "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " o akşam, \"Beklemek"
        },
        {
          "t": "ikon",
          "v": "hourglass"
        },
        {
          "t": "metin",
          "v": " de öğrenmekmiş,\" dedi."
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
      "metin": "Düdük için ilk parayı kim uzattı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yalnız bir çocuk"
        },
        {
          "id": "B",
          "metin": "Bütün çocuklar"
        },
        {
          "id": "C",
          "metin": "Hoca kendisi"
        }
      ],
      "dogru": "A",
      "aciklama": "Üç çocuk peşine takılmıştı ama yalnız biri parasını uzattı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Hoca akşam neden önce tek bir düdük verdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Düdüğü istediklerini ama nasıl alınacağını konuşmadıklarını söylemek için"
        },
        {
          "id": "B",
          "metin": "Ucuz olan düdüğü almak için"
        },
        {
          "id": "C",
          "metin": "Diğer çocuklara kızdığı için"
        }
      ],
      "dogru": "A",
      "aciklama": "Hoca, nasıl alınacağının konuşulmadığını ve birlikte bir iş bulup biriktirmeleri gerektiğini söyledi."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Hikâyenin sonunda çocuklar neyi öğrenmiştir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Beklemenin ve sırayla davranmanın önemini"
        },
        {
          "id": "B",
          "metin": "Hiç para harcamamayı"
        },
        {
          "id": "C",
          "metin": "Yüksek sesle çalmanın daha güzel olduğunu"
        }
      ],
      "dogru": "A",
      "aciklama": "Yusuf, beklemenin de öğrenmek olduğunu söyledi; çocuklar sırayla çalmayı öğrendi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "Metinde geçen emek sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir iş için harcanan çaba ve zaman"
        },
        {
          "id": "B",
          "metin": "Büyük bir ağaç"
        },
        {
          "id": "C",
          "metin": "Yüksek bir ses"
        }
      ],
      "dogru": "A",
      "aciklama": "Hoca, düdüğün bir emek ürünü olduğunu ve harcamadan önce düşünmek gerektiğini söyledi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_emek",
        "tur": "kelime",
        "yazim": "emek",
        "anlam": "Bir iş için harcanan çaba ve zaman.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_harclik",
        "tur": "kelime",
        "yazim": "harçlık",
        "anlam": "Çocuğa verilen küçük miktarda para.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_emek",
        "tur": "atasozu",
        "yazim": "Emek olmadan yemek olmaz",
        "anlam": "Bir şeyi elde etmek için çalışmak gerekir.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_emek",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_emek"
          }
        ]
      },
      {
        "ad": "s2_harclik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_harclik"
          }
        ]
      },
      {
        "ad": "ata_emek",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_emek"
          }
        ]
      }
    ]
  }
}$p06$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr006-dudek-kimin-olacak: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p07${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr007-kaplumbaga-ve-tavsan",
    "baslik": "Kaplumbağa ile Tavşanın Yeni Yarışı",
    "tur": "hayvanlar",
    "konu": "orman",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "hayvan",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D12",
      "D14"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "hayvanlar",
        "sabir_emek"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D12",
        "yardimci_deger": "D14"
      },
      "ogrenme_hedefleri": [
        {
          "id": "hizli",
          "tur": "lexeme",
          "etiket": "hızlı",
          "yuva": "s2_hizli",
          "islev": "first_hint"
        },
        {
          "id": "yavas",
          "tur": "lexeme",
          "etiket": "yavaş",
          "yuva": "s2_yavas",
          "islev": "application"
        },
        {
          "id": "kavram_hr007",
          "tur": "concept",
          "etiket": "Düzenli çaba",
          "islev": "application"
        },
        {
          "id": "atasoz_hr007",
          "tur": "proverb",
          "etiket": "Sabreden derviş muradına ermiş",
          "yuva": "ata_sabir",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 239,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 7,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 12
      }
    },
    "tanitim": "Tavşan yine hızlı koşmak istiyor. Yarışta sabır mı, hız mı kazanacak?",
    "durum": "taslak",
    "fis_kodu": "HR-007"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Tavşan, ormanın koşu yarışına yine ilk yazılan oldu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise adını görünce biraz düşündü. Geçen yarıştan sonra herkes hızını konuşuyordu. Oysa "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yolun tadını çıkararak yürümeyi seviyordu. Ormanda herkes \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_sabir"
        },
        {
          "t": "metin",
          "v": "\" derdi. Yarışı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de izliyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yarıştan önce orman"
        },
        {
          "t": "ikon",
          "v": "forest"
        },
        {
          "t": "ikon",
          "v": "tree"
        },
        {
          "t": "metin",
          "v": " hayvanları yeni bir kural koydu: Kimse öteki yarışmacıyla alay etmeyecekti. Tavşan kuralı duyunca biraz utandı. Karşısına geçip \"Bugün elimden geleni yapacağım,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " da \"Ben de,\" diye cevap verdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bu kez parkur farklıydı: bir dere kenarı, küçük bir yokuş ve işaretli bir düzlük vardı. Yarış başlayınca Tavşan "
        },
        {
          "t": "kelime",
          "yuva": "s2_hizli"
        },
        {
          "t": "metin",
          "v": " koştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise "
        },
        {
          "t": "kelime",
          "yuva": "s2_yavas"
        },
        {
          "t": "metin",
          "v": " ama düzenli adımlarla ilerledi. Tavşan biraz ileride bir kirpinin yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " istediğini duyunca durdu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Derenin yanına gelince taşlar ıslaktı. Tavşan büyük bir sıçrayış yapmak istedi ama durdu ve güvenli patikaya geçti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " acele etmeden sağlam taşları seçti. İki yarışmacı da farklı hızlarda doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " kararlar veriyordu. "
        },
        {
          "t": "isaret",
          "kod": "deniz"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yolun ortasında Kirpi bir yaprağı yuvasına taşıyordu. Yaprak"
        },
        {
          "t": "ikon",
          "v": "leaf"
        },
        {
          "t": "metin",
          "v": " bir kayanın altına sıkışmıştı. Tavşan tek başına çekmeyi denedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " \"Önce yaprağın kenarını kaldıralım,\" dedi. Biri yaprağı tuttu, öteki yavaşça çekti. Kirpi teşekkür etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Finişe yan yana geldiler. Orman"
        },
        {
          "t": "ikon",
          "v": "forest"
        },
        {
          "t": "ikon",
          "v": "tree"
        },
        {
          "t": "metin",
          "v": " bekçisi kazananı hemen söylemedi: \"Bugün iki farklı başarı"
        },
        {
          "t": "ikon",
          "v": "star"
        },
        {
          "t": "metin",
          "v": " gördüm. Biri hızını iyi kullandı, diğeri düzenli ilerledi. Üstelik yarış sırasında yardımı unutmadınız.\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gülümseyerek alkışladı. Tavşan güldü: \"Ben de hızlı koşmayı öğretirim.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkisi, farklı hızlarda yürümenin arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " olmaya engel olmadığını anladı. Orman"
        },
        {
          "t": "ikon",
          "v": "tree"
        },
        {
          "t": "metin",
          "v": " bekçisi herkese su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " ikram etti. Tavşan, "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " ayak izlerine baktı. Onunki küçük ama düzenliydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " da Tavşan'ın hızlı adımlarına hayran kaldı."
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
      "metin": "Yarıştan önce orman hayvanları hangi kuralı koydu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kimse öteki yarışmacıyla alay etmeyecek"
        },
        {
          "id": "B",
          "metin": "Yarış yalnızca tavşan için yapılacak"
        },
        {
          "id": "C",
          "metin": "Kimse yarışa katılmayacak"
        }
      ],
      "dogru": "A",
      "aciklama": "Orman hayvanları, kimsenin öteki yarışmacıyla alay etmemesi kuralını koydu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Tavşan büyük bir sıçrayış yapmak isteyip neden durdu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Taşlar ıslak ve kaygandı"
        },
        {
          "id": "B",
          "metin": "Dere çok darydı"
        },
        {
          "id": "C",
          "metin": "Yarış bitmişti"
        }
      ],
      "dogru": "A",
      "aciklama": "Derenin yanındaki taşlar ıslaktı; tavşan düşmemek için güvenli patikaya geçti."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Orman bekçisinin 'iki farklı başarı' sözü neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hızın da düzenli ilerlemenin de değerli olduğunu"
        },
        {
          "id": "B",
          "metin": "Tavşanın kazandığını"
        },
        {
          "id": "C",
          "metin": "Kaplumbağanın yarışa hiç katılmadığını"
        }
      ],
      "dogru": "A",
      "aciklama": "Bekçi, hem hızlı koşmanın hem düzenli ilerlemenin bir başarı olduğunu söyledi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "Metinde geçen yavaş sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hızı az olan, ağır ağır giden"
        },
        {
          "id": "B",
          "metin": "Çok sessiz olan"
        },
        {
          "id": "C",
          "metin": "Renkli olan"
        }
      ],
      "dogru": "A",
      "aciklama": "Kaplumbağa ağır ama düzenli adımlarla ilerledi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_hizli",
        "tur": "kelime",
        "yazim": "hızlı",
        "anlam": "Çabuk hareket eden, kısa sürede giden.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_yavas",
        "tur": "kelime",
        "yazim": "yavaş",
        "anlam": "Hızı az olan, ağır ağır giden.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_sabir",
        "tur": "atasozu",
        "yazim": "Sabreden derviş muradına ermiş",
        "anlam": "Sabırla bekleyen, istediğine sonunda kavuşur.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_hizli",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_hizli"
          }
        ]
      },
      {
        "ad": "s2_yavas",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_yavas"
          }
        ]
      },
      {
        "ad": "ata_sabir",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_sabir"
          }
        ]
      }
    ]
  }
}$p07$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr007-kaplumbaga-ve-tavsan: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p08${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr008-aslan-ve-fare",
    "baslik": "Aslan ile Farenin Yardımı",
    "tur": "hayvanlar",
    "konu": "orman",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "hayvan",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D9",
      "D20"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "hayvanlar",
        "dostluk"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D9",
        "yardimci_deger": "D20"
      },
      "ogrenme_hedefleri": [
        {
          "id": "guclu",
          "tur": "lexeme",
          "etiket": "güçlü",
          "yuva": "s2_guclu",
          "islev": "first_hint"
        },
        {
          "id": "kucuk",
          "tur": "lexeme",
          "etiket": "küçük",
          "yuva": "s2_kucuk",
          "islev": "application"
        },
        {
          "id": "kavram_hr008",
          "tur": "concept",
          "etiket": "Empati",
          "islev": "application"
        },
        {
          "id": "atasoz_hr008",
          "tur": "proverb",
          "etiket": "İyilik eden iyilik bulur",
          "yuva": "ata_iyilik",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 203,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 6,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 7
      }
    },
    "tanitim": "Küçük bir fare uyuyan aslanı uyandırdı. Aslan bir gün ona ihtiyaç duyacak mı?",
    "durum": "taslak",
    "fis_kodu": "HR-008"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Küçük fare "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", aslanın uyuduğu kayanın yanından geçerken kuru bir dalı kırdı. Aslan uyandı. \"Kim var orada?\" diye kükredi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " titredi ama kaçmadı. \"Benim. Seni uyandırdığım için üzgünüm.\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bu dürüstlüğü hayranlıkla izledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Aslan farenin dürüstlüğüne şaşırdı. \"Bir daha dikkatli ol,\" deyip onu bıraktı. Birkaç gün sonra "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ormanda yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " isteyen bir ses"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " duydu. Aslan, avcıların bıraktığı eski bir ağa takılmıştı. Ağın iplerini çekse de kurtulamıyordu."
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
          "v": " arkadaşlarına korktuğunu saklamadan anlattı: \"Korktum. Yine de doğruyu söylemek istedim.\" Sonra sesin geldiği yere gitti. Ağın kalın iplerine baktı. Aslanın pençeleri ağın aralıklarına sığmıyordu. \"Ben "
        },
        {
          "t": "kelime",
          "yuva": "s2_kucuk"
        },
        {
          "t": "metin",
          "v": " bir fareyim ama dar yerlere girebilirim,\" dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Aslan sabırsızlandı ama "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " acele etmedi. \"Yavaş"
        },
        {
          "t": "ikon",
          "v": "turtle"
        },
        {
          "t": "metin",
          "v": " yapabilirim,\" dedi, \"ama dikkatli olacağım.\" Önce düğümlerin yerini buldu, sonra en gevşek ipten başladı. Dişleriyle gevşemiş ipleri kemirdi. Aslan pençelerini oynatmadan bekledi. "
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
          "v": "Ağ açıldı ve aslan dikkatle dışarı çıktı. \"Ben "
        },
        {
          "t": "kelime",
          "yuva": "s2_guclu"
        },
        {
          "t": "metin",
          "v": " olduğum için her şeyi yapabileceğimi sanırdım,\" dedi. Fare gülümsedi: \"Ben de küçük olduğum için yapamayacağım şeyler olduğunu sanırdım.\" İkisi su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " kenarında oturup dinlendi. Aslan, \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_iyilik"
        },
        {
          "t": "metin",
          "v": "\" sözünü hatırladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " onların birbirini anlamasına sevindi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Aslan, "
        },
        {
          "t": "kahraman",
          "hal": "belirtme"
        },
        {
          "t": "metin",
          "v": " yorgun görünce serin bir yaprakla gölge yaptı. İkisi birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " dereye doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " yürüdü. O gün ormanda güçten başka önemli bir şey konuşuldu: birinin ihtiyacını anlayabilmek."
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
      "metin": "Fare aslanı neden uyandırdı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kuru bir dalı kırdığı için"
        },
        {
          "id": "B",
          "metin": "Ona seslendiği için"
        },
        {
          "id": "C",
          "metin": "Yardım istediği için"
        }
      ],
      "dogru": "A",
      "aciklama": "Fare kayanın yanından geçerken kuru bir dalı kırdı ve aslan uyandı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Aslan ağdan neden kendi başına kurtulamadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Pençeleri ağın aralıklarına sığmadığı için"
        },
        {
          "id": "B",
          "metin": "Ağ çok küçük olduğu için"
        },
        {
          "id": "C",
          "metin": "Yardım gelmediği için"
        }
      ],
      "dogru": "A",
      "aciklama": "Aslanın büyük pençeleri ağın aralıklarına sığmıyordu."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Aslan ve fare sonunda neyi öğrenmiştir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Birinin ihtiyacını anlayabilmeyi"
        },
        {
          "id": "B",
          "metin": "Ormanda yalnız yaşamayı"
        },
        {
          "id": "C",
          "metin": "Kuru dal kırmanın iyi olduğunu"
        }
      ],
      "dogru": "A",
      "aciklama": "Aslan, güçten başka önemli bir şeyin birinin ihtiyacını anlamak olduğunu fark etti."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 5,
      "metin": "Metinde geçen güçlü sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kuvvetli, çok güç harcayabilen"
        },
        {
          "id": "B",
          "metin": "Çok korkak"
        },
        {
          "id": "C",
          "metin": "Sessiz"
        }
      ],
      "dogru": "A",
      "aciklama": "Aslan, güçlü olduğu için her şeyi yapabileceğini düşünüyordu."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_guclu",
        "tur": "kelime",
        "yazim": "güçlü",
        "anlam": "Kuvvetli, çok güç harcayabilen.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_kucuk",
        "tur": "kelime",
        "yazim": "küçük",
        "anlam": "Boyutu ya da miktarı az olan.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_iyilik",
        "tur": "atasozu",
        "yazim": "İyilik eden iyilik bulur",
        "anlam": "İyilik yapan kişi, bir gün karşılığını bulur.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_guclu",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_guclu"
          }
        ]
      },
      {
        "ad": "s2_kucuk",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_kucuk"
          }
        ]
      },
      {
        "ad": "ata_iyilik",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_iyilik"
          }
        ]
      }
    ]
  }
}$p08$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr008-aslan-ve-fare: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p09${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr009-konusan-kalem-kutusu",
    "baslik": "Konuşan Kalem Kutusu",
    "tur": "arkadaslik",
    "konu": "okul",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "ben",
      "kardes",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D16"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "okul",
        "mizah"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D16"
      },
      "ogrenme_hedefleri": [
        {
          "id": "dar",
          "tur": "lexeme",
          "etiket": "dar",
          "yuva": "s2_dar",
          "islev": "first_hint"
        },
        {
          "id": "genis",
          "tur": "lexeme",
          "etiket": "geniş",
          "yuva": "s2_genis",
          "islev": "application"
        },
        {
          "id": "kavram_hr009",
          "tur": "concept",
          "etiket": "Düzenleme",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 209,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 6,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 5
      }
    },
    "tanitim": "Kalem kutusundan sesler geliyor. Herkesin bir yeri olabilir mi?",
    "durum": "taslak",
    "fis_kodu": "HR-009"
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
          "v": " çantasını açınca kalem"
        },
        {
          "t": "ikon",
          "v": "pencil"
        },
        {
          "t": "metin",
          "v": " kutusundan sesler geldi. \"Bana yer kalmadı!\" diye bağırıyordu silgi. Cetvel ise \"Hepiniz yamuk duruyorsunuz,\" diye söyleniyordu. Kurşun kalem sivri ucunu koruyamamaktan yakınıyordu."
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
          "v": " şaşkınlıkla etrafa baktı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " göz kırptı: \"Belki eşyaların da biraz düzene ihtiyacı vardır.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kutuyu boşalttı. Uzun cetveli yan bölmeye, küçük silgiyi dar bölmeye, kalemleri lastikli sıraya koydu. Ama boya kalemleri yine sığmadı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kutu çok "
        },
        {
          "t": "kelime",
          "yuva": "s2_dar"
        },
        {
          "t": "metin",
          "v": " bir yerdi. Silgi \"Ben küçüğüm, o yüzden hep alta düşüyorum,\" dedi. Cetvel \"Beni eğerseniz düzgün çizgi çizemem,\" diye karşılık verdi. Mavi kalem"
        },
        {
          "t": "ikon",
          "v": "pencil"
        },
        {
          "t": "metin",
          "v": " ise kapağı açık kaldığı için kurumuştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hepsini dinledi ve ne yapacağını düşündü."
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
          "v": " masanın üzerine bir kâğıt açtı: \"Önce plan yapalım.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kutunun resmini çizdi. Büyük eşyaları içeri, küçükleri sonraya yerleştirdi. Cetveli çapraz koyunca kapağın kapanmadığını gördü. Bu yüzden eski bir kartonu ikiye katlayıp ayırıcı olarak yerleştirdi. İlk seferde devrildi. Bir köşesini uzatınca yerinde durdu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kalemler yan yana dizildi, silgi kendi bölümüne yerleşti. Kutu "
        },
        {
          "t": "kelime",
          "yuva": "s2_genis"
        },
        {
          "t": "metin",
          "v": " değildi ama her eşyanın bir yeri vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eşyalarının yerini bilmenin bir sorumluluk olduğunu düşündü. Ertesi gün aradığı eşyayı hemen buldu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Son olarak kalemtıraş seslendi: \"Beni unutmadın, değil mi?\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güldü ve onu da ön göze yerleştirdi. Kalem"
        },
        {
          "t": "ikon",
          "v": "pencil"
        },
        {
          "t": "metin",
          "v": " kutusundan artık ses"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " gelmiyordu. "
        },
        {
          "t": "isaret",
          "kod": "yildiz"
        },
        {
          "t": "metin",
          "v": " Arkadaşı Zeynep'e de kutuyu gösterdi. İkisi yan yana oturup kendi kutularını düzenlemek için bir plan yaptı."
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
      "metin": "Silgi kalem kutusunda neden şikâyet etti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kendisine yer kalmadığı için"
        },
        {
          "id": "B",
          "metin": "Kurşun kalem yüzünden"
        },
        {
          "id": "C",
          "metin": "Cetvel yüzünden"
        }
      ],
      "dogru": "A",
      "aciklama": "Silgi, 'Bana yer kalmadı!' diye bağırıyordu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Cetveli çapraz koyunca ne oldu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kapak kapanmadı"
        },
        {
          "id": "B",
          "metin": "Silgi kayboldu"
        },
        {
          "id": "C",
          "metin": "Kalemler kırıldı"
        }
      ],
      "dogru": "A",
      "aciklama": "Cetveli çapraz koyunca kapağın kapanmadığını gördü."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 5,
      "metin": "Kutuyu düzenleyen çocuğun davranışı neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Eşyalarına bakmanın bir sorumluluk olduğunu"
        },
        {
          "id": "B",
          "metin": "Eşyaları atmanın daha kolay olduğunu"
        },
        {
          "id": "C",
          "metin": "Kalemlerin konuşamayacağını"
        }
      ],
      "dogru": "A",
      "aciklama": "Her eşyanın bir yeri olduğunu bilmek ve buna uymak bir sorumluluktur."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "Metinde geçen dar sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Genişliği az olan, sıkışık"
        },
        {
          "id": "B",
          "metin": "Çok büyük olan"
        },
        {
          "id": "C",
          "metin": "Renkli olan"
        }
      ],
      "dogru": "A",
      "aciklama": "Kutu, eşyaların sıkıştığı çok dar bir yerdi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_dar",
        "tur": "kelime",
        "yazim": "dar",
        "anlam": "Genişliği az olan, sıkışık.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_genis",
        "tur": "kelime",
        "yazim": "geniş",
        "anlam": "Genişliği çok olan, rahat.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_dar",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_dar"
          }
        ]
      },
      {
        "ad": "s2_genis",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_genis"
          }
        ]
      }
    ]
  }
}$p09$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr009-konusan-kalem-kutusu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p10${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr010-kelogan-ve-konusan-tas",
    "baslik": "Keloğlan ve Konuşan Taş",
    "tur": "macera",
    "konu": "yol",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D20"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "dayanisma",
        "kesif"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D20"
      },
      "ogrenme_hedefleri": [
        {
          "id": "bilmece",
          "tur": "lexeme",
          "etiket": "bilmece",
          "yuva": "s2_bilmece",
          "islev": "first_hint"
        },
        {
          "id": "cevap",
          "tur": "lexeme",
          "etiket": "cevap",
          "yuva": "s2_cevap",
          "islev": "application"
        },
        {
          "id": "kavram_hr010",
          "tur": "concept",
          "etiket": "Akıl yürütme",
          "islev": "application"
        },
        {
          "id": "atasoz_hr010",
          "tur": "proverb",
          "etiket": "İyilik yap denize at, balık bilmezse Halik bilir",
          "yuva": "ata_iyilik_yap",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 242,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 7,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 8
      }
    },
    "tanitim": "Yolda konuşan bir taş bilmece soruyor. Cevabı bulmak için ne yapmak gerekir?",
    "durum": "taslak",
    "fis_kodu": "HR-010"
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
          "v": " köyden şehre giden yolda yuvarlak bir taş gördü. Taşın üzerinde üç çizgi vardı. Tam yanından geçecekken \"Dur!\" diye bir ses duyuldu. Ses taşın içinden geliyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "\"Bir "
        },
        {
          "t": "kelime",
          "yuva": "s2_bilmece"
        },
        {
          "t": "metin",
          "v": " çözersen sana yolu göstereceğim,\" dedi taş. \"Ne kadar çok paylaşırsan o kadar çoğalır?\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce ekmek"
        },
        {
          "t": "ikon",
          "v": "seed"
        },
        {
          "t": "metin",
          "v": " düşündü. Ama ekmek paylaşıldıkça azalırdı. Sonra suyu düşündü. Su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " da azalıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "\"Soruma hemen cevap vermek zorunda değilsin,\" dedi taş. \"Önce düşün.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " elini çenesine koydu. Bir kişi şarkı"
        },
        {
          "t": "ikon",
          "v": "music"
        },
        {
          "t": "metin",
          "v": " söylemeye başlayınca başkaları da katılabilirdi. \"Belki neşedir,\" dedi. Taş sessiz kaldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başka bir "
        },
        {
          "t": "kelime",
          "yuva": "s2_cevap"
        },
        {
          "t": "metin",
          "v": " aramaya karar verdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Tam o sırada yaşlı bir kadının sepetinden bir elma yuvarlandı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " elmayı yerden aldı. Kadın, çarşıya giden yolu unuttuğunu söyledi. Sepet çok ağırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sepetin bir sapından tuttu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da kısa yolu hatırladı ve yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yol boyunca sepette armutlar, ekmekler ve bir demet nane vardı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " sepeti taşımaya devam etti. Kadın rahatlayınca yüzü aydınlandı. Çarşıya vardıklarında kadın teşekkür etti ve gideceği yeri tarif etti. Yaşlı kadın gülümseyerek şunu söyledi: \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_iyilik_yap"
        },
        {
          "t": "metin",
          "v": "\". "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " geri dönerken taş yeniden konuştu: \"Cevabı buldun mu?\""
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
          "v": " birden güldü. \"Sevinç"
        },
        {
          "t": "ikon",
          "v": "joy"
        },
        {
          "t": "metin",
          "v": "!\" dedi. \"Birine yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " edince onun sevinci bana da geçiyor. Paylaşınca çoğalıyor.\" Taştaki çizgiler parladı. Taş, toprağa yan yatmış eski bir yol levhasının üstündeydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " levhayı yerine dikti. Köylüler artık yolda daha kolay yön"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " buldu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yol işaretini gören bir çocuk "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " teşekkür etti. \"Artık hangi yoldan gideceğimizi biliyoruz,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " taşa son bir kez baktı. Taş susuyordu; belki de cevabı çoktan vermişti. "
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
      "metin": "Taş ne karşılığında yolu göstereceğini söyledi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir bilmeceyi çözmek"
        },
        {
          "id": "B",
          "metin": "Taşı kaldırmak"
        },
        {
          "id": "C",
          "metin": "Su getirmek"
        }
      ],
      "dogru": "A",
      "aciklama": "Taş, bir bilmece çözülürse yolu göstereceğini söyledi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Ekmek ve su bilmecenin cevabı olamaz, çünkü:",
      "secenekler": [
        {
          "id": "A",
          "metin": "Paylaşıldıkça azalıyorlar"
        },
        {
          "id": "B",
          "metin": "Çok pahalılar"
        },
        {
          "id": "C",
          "metin": "Taşa yakın değiller"
        }
      ],
      "dogru": "A",
      "aciklama": "Ekmek ve su paylaşıldıkça azalır; bilmecenin cevabı çoğalan bir şey olmalıdır."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Cevap olarak söylenen sevinç neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yardım etmenin hem verene hem alana iyi geldiğini"
        },
        {
          "id": "B",
          "metin": "Taşın çok neşeli olduğunu"
        },
        {
          "id": "C",
          "metin": "Sepetin hafif olduğunu"
        }
      ],
      "dogru": "A",
      "aciklama": "Birine yardım edince sevinç paylaşılır ve çoğalır."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "Metinde geçen bilmece sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir sorunun cevabını bulmaya dayanan kısa soru"
        },
        {
          "id": "B",
          "metin": "Uzun bir hikâye"
        },
        {
          "id": "C",
          "metin": "Bir yemek türü"
        }
      ],
      "dogru": "A",
      "aciklama": "Taş, kısa bir soru sorarak cevap istedi."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_bilmece",
        "tur": "kelime",
        "yazim": "bilmece",
        "anlam": "Bir sorunun cevabını bulmaya dayanan kısa soru.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_cevap",
        "tur": "kelime",
        "yazim": "cevap",
        "anlam": "Bir soruya verilen karşılık.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_iyilik_yap",
        "tur": "atasozu",
        "yazim": "İyilik yap denize at, balık bilmezse Halik bilir",
        "anlam": "İyiliği karşılık beklemeden yapmak gerekir; kimse görmese de değeri kaybolmaz.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_bilmece",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_bilmece"
          }
        ]
      },
      {
        "ad": "s2_cevap",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_cevap"
          }
        ]
      },
      {
        "ad": "ata_iyilik_yap",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_iyilik_yap"
          }
        ]
      }
    ]
  }
}$p10$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr010-kelogan-ve-konusan-tas: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p11${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr012-yeni-arkadasin-gizli-yetenegi",
    "baslik": "Yeni Arkadaşın Gizli Yeteneği",
    "tur": "arkadaslik",
    "konu": "sinif",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "kardes",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D14"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "dostluk",
        "okul"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D14"
      },
      "ogrenme_hedefleri": [
        {
          "id": "cekingen",
          "tur": "lexeme",
          "etiket": "çekingen",
          "yuva": "s2_cekingen",
          "islev": "first_hint"
        },
        {
          "id": "cesur",
          "tur": "lexeme",
          "etiket": "cesur",
          "yuva": "s2_cesur",
          "islev": "application"
        },
        {
          "id": "kavram_hr012",
          "tur": "concept",
          "etiket": "Kapsayıcılık",
          "islev": "application"
        },
        {
          "id": "atasoz_hr012",
          "tur": "proverb",
          "etiket": "Derin su sessiz akar",
          "yuva": "ata_derin_su",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 211,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 6,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 5
      }
    },
    "tanitim": "Sessiz yeni bir arkadaş var. Grup çalışmasında onun gizli yeteneğini kim fark edecek?",
    "durum": "taslak",
    "fis_kodu": "HR-012"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sınıfa yeni gelen "
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
          "yuva": "s2_cekingen"
        },
        {
          "t": "metin",
          "v": " biriydi. Teneffüslerde pencere kenarında oturuyor, arkadaşları oyuna çağırdığında kibarca başını sallıyordu. Ece onun kimseyi sevmediğini düşündü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Grup çalışması başlarken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tek başına kalacak gibiydi. Ece yanına yaklaştı: \"Bizimle çalışmak ister misin?\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını salladı ama ilk dakikalarda pek konuşmadı. Kâğıdın kenarına küçük işaretler koyuyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de bu işaretlerin ne olduğunu merakla bekliyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ece işaretlerin bir haritaya benzediğini fark edip sordu: \"Bunlar ne?\" \"Evden okula gelirken geçtiğim yerler,\" dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Kâğıda yollar çizdi: \"Burada kitapçı var, burada iki ağaç"
        },
        {
          "t": "ikon",
          "v": "tree"
        },
        {
          "t": "metin",
          "v": ", burada küçük bir meydan.\" Arkadaşları dinledikçe haritalar gerçekçileşti. "
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
          "v": "Bahçenin ağaçlarını, çeşmesini ve giriş kapısını çizdi. Sonra güvenli yürüyüş yolunu renkli kalemle işaretledi. Grupta bir sorun çıktı: çizilen park okuldan daha büyük görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " silgiyi alıp her şeyi silmek istemedi. \"Önce büyük ve küçük yerleri karşılaştıralım,\" dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ece \"Bunu nasıl"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " bu kadar güzel yaptın?\" diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " omuz silkti: \"Eski mahallemde de haritalar çizerdim.\" Ece, konuşmadığı zamanlarda çevresini dikkatle izlediğini fark etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " sonraki hafta yeni bir harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " görevi verdi. Bu kez "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " arkadaşlarına "
        },
        {
          "t": "kelime",
          "yuva": "s2_cesur"
        },
        {
          "t": "metin",
          "v": " bir öneri yaptı: \"Yol için yeni bir çizgi deneyelim.\" Grup haritayı sınıfta sundu. Öğretmen katkıları sorduğunda Ece \"Yolumuzu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " buldu,\" dedi. Öğretmen gülümsedi: \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_derin_su"
        },
        {
          "t": "metin",
          "v": "\". "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de alkışladı. Ece, sessiz birinin fikri olmadığını sandığı için yanıldığını anladı."
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
      "metin": "Yeni gelen çocuk teneffüslerde nerede oturuyordu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Pencere kenarında"
        },
        {
          "id": "B",
          "metin": "Bahçede"
        },
        {
          "id": "C",
          "metin": "Kantinde"
        }
      ],
      "dogru": "A",
      "aciklama": "Yeni çocuk teneffüslerde pencere kenarında oturuyordu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Çocuk işaretleri neden çizdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Evden okula giderken geçtiği yerleri göstermek için"
        },
        {
          "id": "B",
          "metin": "Yeni bir oyun icat etmek için"
        },
        {
          "id": "C",
          "metin": "Öğretmenine kızmak için"
        }
      ],
      "dogru": "A",
      "aciklama": "Çizdiği işaretler, evden okula gelirken geçtiği yerlerdi."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Ece'nin ilk gün yaptığı hata neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sessiz birinin fikri olmadığını sanmak"
        },
        {
          "id": "B",
          "metin": "Haritayı yanlış çizmek"
        },
        {
          "id": "C",
          "metin": "Arkadaşlarını oyuna çağırmamak"
        }
      ],
      "dogru": "A",
      "aciklama": "Ece, sessiz birinin fikri olmadığını sandığı için yanıldığını anladı."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 1,
      "metin": "Metinde geçen çekingen sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Utangaç, kendini hemen göstermeyen"
        },
        {
          "id": "B",
          "metin": "Çok neşeli"
        },
        {
          "id": "C",
          "metin": "Çok hızlı konuşan"
        }
      ],
      "dogru": "A",
      "aciklama": "Yeni çocuk, arkadaşlarının davetine kibarca karşılık veriyor ama çok konuşmuyordu."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_cekingen",
        "tur": "kelime",
        "yazim": "çekingen",
        "anlam": "Utangaç, kendini hemen göstermeyen.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_cesur",
        "tur": "kelime",
        "yazim": "cesur",
        "anlam": "Korkmadan iş yapabilen.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_derin_su",
        "tur": "atasozu",
        "yazim": "Derin su sessiz akar",
        "anlam": "Bilgili ve olgun insanlar çoğu zaman az konuşur, gösteriş yapmaz.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_cekingen",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_cekingen"
          }
        ]
      },
      {
        "ad": "s2_cesur",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_cesur"
          }
        ]
      },
      {
        "ad": "ata_derin_su",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_derin_su"
          }
        ]
      }
    ]
  }
}$p11$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr012-yeni-arkadasin-gizli-yetenegi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p12${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr013-kirilan-oyuncak-kopru",
    "baslik": "Kırılan Oyuncak Köprü",
    "tur": "arkadaslik",
    "konu": "bahce",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "kardes"
    ],
    "deger_anahtarlari": [
      "D16"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "okul",
        "sabir_emek"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D16"
      },
      "ogrenme_hedefleri": [
        {
          "id": "saglam",
          "tur": "lexeme",
          "etiket": "sağlam",
          "yuva": "s2_saglam",
          "islev": "first_hint"
        },
        {
          "id": "onarim",
          "tur": "lexeme",
          "etiket": "onarım",
          "yuva": "s2_onarim",
          "islev": "application"
        },
        {
          "id": "kavram_hr013",
          "tur": "concept",
          "etiket": "Basit yapı tasarımı",
          "islev": "application"
        },
        {
          "id": "atasoz_hr013",
          "tur": "proverb",
          "etiket": "Birlikten kuvvet doğar",
          "yuva": "ata_birlik",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 239,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 7,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 12
      }
    },
    "tanitim": "Kartondan yapılan köprü yarıştan önce çöktü. Suçlu kim, nasıl onarılır?",
    "durum": "taslak",
    "fis_kodu": "HR-013"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Oyun köprüsü tam yarış başlayacakken çöktü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kartondan yapılan köprünün üstüne büyük kamyon oyuncağını koymuştu. \"Sen bozdun!\" diye bağırdı Mert. Gözleri dolan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sessiz kaldı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğretmenleri yanlarına geldi. \"Önce sorunu anlayalım,\" dedi. Köprünün ayakları ince kâğıttandı, oyuncak ise ağırdı. Mert yanlışlıkla suçladığını fark etti. \"Ben de köprüyü sağlam yapmadım,\" dedi."
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
          "v": " kırılan parçalara bakarken çok üzgündü; dün akşam onu yapmak için uğraşmıştı. Mert ise uzun süre bir köprü"
        },
        {
          "t": "ikon",
          "v": "bridge"
        },
        {
          "t": "metin",
          "v": " hayali kurduğunu anlattı. Öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " \"Şimdi birbirinizi dinleyin,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ağır kamyonu dikkatsizce koyduğunu kabul etti. Mert de köprüyü denemeden bitmiş saydığını söyledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Masada farklı kalınlıkta kartonlar vardı. Bir şerit düz tutulunca eğildi; ikiye katlanınca daha zor eğildi. \"Demek aynı karton biçim değişince daha "
        },
        {
          "t": "kelime",
          "yuva": "s2_saglam"
        },
        {
          "t": "metin",
          "v": " olabilir,\" dedi Mert. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " küçük bir köprü"
        },
        {
          "t": "ikon",
          "v": "bridge"
        },
        {
          "t": "metin",
          "v": " resmi çizerek fikirlerini göstermelerine yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yeni köprüyü kurmadan önce küçük bir ayak parçasını denediler. Tek başına devrilen parça iki yan destek eklenince durdu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " her denemeyi bir çizelgeye işaretledi. Birbirlerini suçlamadıklarında daha çabuk çözüm"
        },
        {
          "t": "ikon",
          "v": "puzzle"
        },
        {
          "t": "metin",
          "v": " bulduklarını fark ettiler. Kalın kartondan dört ayak yaptılar ve üstüne iki kat yol koydular."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Köprü"
        },
        {
          "t": "ikon",
          "v": "bridge"
        },
        {
          "t": "metin",
          "v": ", en büyük kamyon konunca hafifçe eğildi ama yıkılmadı. \"Bu kez oldu!\" diye sevindiler. Öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": ", sorun çıktığında suçlu aramak yerine nedenini araştırmalarına sevindi. Bu "
        },
        {
          "t": "kelime",
          "yuva": "s2_onarim"
        },
        {
          "t": "metin",
          "v": " işini birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " yaptılar. Mert gülerek \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_birlik"
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
          "v": " gülümsedi. Yarış başladığında oyuncak kamyon köprünün üstünden yavaşça geçti. Köprü"
        },
        {
          "t": "ikon",
          "v": "bridge"
        },
        {
          "t": "metin",
          "v": " sallanmadı. "
        },
        {
          "t": "isaret",
          "kod": "yildiz"
        },
        {
          "t": "metin",
          "v": " Mert küçük bir bayrak kaldırdı. İkisi birbirine bakıp güldü. Bu kez yalnızca köprüyü değil, birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " çözüm"
        },
        {
          "t": "ikon",
          "v": "puzzle"
        },
        {
          "t": "metin",
          "v": " bulmayı da başarmışlardı."
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
      "metin": "Köprü yarış öncesinde neden çöktü?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Üstüne ağır bir kamyon konduğu için"
        },
        {
          "id": "B",
          "metin": "Yağmur yağdığı için"
        },
        {
          "id": "C",
          "metin": "Çocuklar üstüne bastığı için"
        }
      ],
      "dogru": "A",
      "aciklama": "Köprünün üstüne büyük bir kamyon oyuncağı konmuştu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Kartonu ikiye katlayınca ne oldu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Daha zor eğildiği için daha dayanıklı oldu"
        },
        {
          "id": "B",
          "metin": "Rengi değişti"
        },
        {
          "id": "C",
          "metin": "Daha hafif oldu"
        }
      ],
      "dogru": "A",
      "aciklama": "İki kat karton daha zor eğildi; bu da onu daha sağlam yaptı."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Öğretmen sorun çıkınca neye sevindi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Nedenini birlikte araştırmalarına"
        },
        {
          "id": "B",
          "metin": "Kimin suçlu olduğunu bulmalarına"
        },
        {
          "id": "C",
          "metin": "Köprünün hemen yıkılmasına"
        }
      ],
      "dogru": "A",
      "aciklama": "Öğretmen, suçlu aramak yerine nedenini araştırmalarına sevindi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "Metinde geçen sağlam sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kolay bozulmayan, dayanıklı"
        },
        {
          "id": "B",
          "metin": "Çok hafif"
        },
        {
          "id": "C",
          "metin": "Renkli"
        }
      ],
      "dogru": "A",
      "aciklama": "İki kat karton, daha kolay bozulmayan bir yapı oluşturdu."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_saglam",
        "tur": "kelime",
        "yazim": "sağlam",
        "anlam": "Kolay bozulmayan, dayanıklı.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_onarim",
        "tur": "kelime",
        "yazim": "onarım",
        "anlam": "Bozulmuş bir şeyi yeniden düzeltme.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_birlik",
        "tur": "atasozu",
        "yazim": "Birlikten kuvvet doğar",
        "anlam": "Birlikte çalışan insanlar daha çok iş başarır.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_saglam",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_saglam"
          }
        ]
      },
      {
        "ad": "s2_onarim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_onarim"
          }
        ]
      },
      {
        "ad": "ata_birlik",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_birlik"
          }
        ]
      }
    ]
  }
}$p12$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr013-kirilan-oyuncak-kopru: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p13${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr014-yagmur-damlasinin-yolculugu",
    "baslik": "Yağmur Damlasının Yolculuğu",
    "tur": "bilim",
    "konu": "gokyuzu",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "hayali"
    ],
    "deger_anahtarlari": [
      "D17"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 2,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "doga",
        "bilim_teknoloji"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D17"
      },
      "ogrenme_hedefleri": [
        {
          "id": "buhar",
          "tur": "lexeme",
          "etiket": "buhar",
          "yuva": "s2_buhar",
          "islev": "first_hint"
        },
        {
          "id": "damla",
          "tur": "lexeme",
          "etiket": "damla",
          "yuva": "s2_damla",
          "islev": "application"
        },
        {
          "id": "kavram_hr014",
          "tur": "concept",
          "etiket": "Su döngüsü",
          "islev": "application"
        },
        {
          "id": "atasoz_hr014",
          "tur": "proverb",
          "etiket": "Damlaya damlaya göl olur",
          "yuva": "ata_damla",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 205,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 6,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 12
      }
    },
    "tanitim": "Bir damla bulutan göle, buharlaşıp yeniden bulutlara uzanan bir yolculuk yapıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-014"
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
          "v": " bir sabah pencereye vuran yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " damlasını gördü. \"Acaba bu damla nereden geldi?\" diye sordu. Damla sanki onu duymuş gibi camdan aşağı kaydı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de yanında merakla bakıyordu."
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
          "v": " damlanın bir bulutun içinde olduğunu hayal etti. Çevrede pek çok damlacık vardı. Rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " bulutu sürükleyince hepsi sallandı. Bazı damlacıklar birleşip ağırlaştı ve aşağı düşmeye başladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Damla önce bir yaprağa çarptı, sonra toprağa kaydı. Toprak suyu emdi; bir kısmı küçük bir su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " yoluna karıştı. Su yolu başka sularla birleşip dereye dönüştü. Dar bir yerde su daha hızlı, geniş bir yerde daha yavaş"
        },
        {
          "t": "ikon",
          "v": "turtle"
        },
        {
          "t": "metin",
          "v": " akıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " çıkınca göl parladı. Damla buharlaşıp görünmez bir "
        },
        {
          "t": "kelime",
          "yuva": "s2_buhar"
        },
        {
          "t": "metin",
          "v": " olarak havaya yükseldi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu öğrenince çok şaşırdı. \"Demek yolculuk bitmedi,\" dedi. Serin havada yeniden oluşan damlacıklar buluta karışacaktı. "
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
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " defterine üç sözcük yazdı: yağış, buharlaşma, yoğunlaşma. Her birinin yanına küçük resimler çizdiler. Bulut"
        },
        {
          "t": "ikon",
          "v": "cloud"
        },
        {
          "t": "metin",
          "v": ", dere, göl ve güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " arasına oklar koydular. Öğretmen bunun su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " döngüsü olduğunu söyledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi gün öğretmen soğuk bir kabın yüzeyinde su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " damlaları gösterdi. Havadaki su buharı soğuk yüzeyde yoğunlaşmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " küçük bir not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " kâğıdına bir "
        },
        {
          "t": "kelime",
          "yuva": "s2_damla"
        },
        {
          "t": "metin",
          "v": " çizdi ve ona \"Yolcu\" adını verdi. \"Yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " hiç bitiyor mu?\" diye sordu. Öğretmen, suyun döngüde sürekli dolaştığını anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülerek \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_damla"
        },
        {
          "t": "metin",
          "v": "\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " musluğu açık bırakmamaya karar verdi."
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
      "metin": "Dar bir yerde su nasıl akıyordu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Daha hızlı"
        },
        {
          "id": "B",
          "metin": "Daha yavaş"
        },
        {
          "id": "C",
          "metin": "Hiç akmıyordu"
        }
      ],
      "dogru": "A",
      "aciklama": "Dar bir yerde su daha hızlı akıyordu."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Güneş çıkınca damla ne oldu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Buharlaşıp havaya yükseldi"
        },
        {
          "id": "B",
          "metin": "Donup taş oldu"
        },
        {
          "id": "C",
          "metin": "Toprakta kaldı"
        }
      ],
      "dogru": "A",
      "aciklama": "Damla buharlaşıp görünmez bir buhar olarak havaya yükseldi."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Musluğu açık bırakmama kararı neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Suya ve onun döngüsüne değer verildiğini"
        },
        {
          "id": "B",
          "metin": "Suyun kendiliğinden bittiğini"
        },
        {
          "id": "C",
          "metin": "Yağmurun hiç yağmayacağını"
        }
      ],
      "dogru": "A",
      "aciklama": "Su döngüsünü öğrenen çocuk, suyu boşa harcamamaya karar verdi."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "Metinde geçen buhar sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Isınınca havaya karışan, görünmez su hâli"
        },
        {
          "id": "B",
          "metin": "Bir tür bulut"
        },
        {
          "id": "C",
          "metin": "Çok soğuk bir rüzgâr"
        }
      ],
      "dogru": "A",
      "aciklama": "Damla, güneşle ısınınca buhar olarak havaya karıştı."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_buhar",
        "tur": "kelime",
        "yazim": "buhar",
        "anlam": "Isınınca havaya karışan, görünmeyen su hâli.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_damla",
        "tur": "kelime",
        "yazim": "damla",
        "anlam": "Çok küçük, yuvarlak bir su tanesi.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_damla",
        "tur": "atasozu",
        "yazim": "Damlaya damlaya göl olur",
        "anlam": "Küçük birikimler zamanla büyük bir şey olur.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_buhar",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_buhar"
          }
        ]
      },
      {
        "ad": "s2_damla",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_damla"
          }
        ]
      },
      {
        "ad": "ata_damla",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_damla"
          }
        ]
      }
    ]
  }
}$p13$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr014-yagmur-damlasinin-yolculugu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p14${
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
        "simge_sayisi": 12
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
          "v": " sınıfta duran iki saksıya bakıp kaşlarını çattı. Aynı gün ektiği fasulyelerden biri yeşermiş, diğeri ise incecik, soluk bir "
        },
        {
          "t": "kelime",
          "yuva": "pa_filiz"
        },
        {
          "t": "metin",
          "v": " çıkarmıştı. Üstelik ikisi de aynı tohum"
        },
        {
          "t": "ikon",
          "v": "seed"
        },
        {
          "t": "metin",
          "v": " paketindendi. \"Belki karanlığı daha çok seviyordur,\" dedi arkadaşı "
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
          "v": "Öğretmenleri deney"
        },
        {
          "t": "ikon",
          "v": "microscope"
        },
        {
          "t": "metin",
          "v": " defterlerini açmalarını istedi. "
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
          "v": " yazdı. İki saksıya da aynı miktarda su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " verdiklerini kaydetti. İkinci saksı, sınıftaki kapaklı dolabın içinde duruyordu. Sonra defterine şunu not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " düştü: \"Farklı olan "
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
          "v": "Üç gün boyunca her sabah"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " önce ellerini yıkadı, sonra filizlere dokunmadan cetvelle boylarını ölçtü. Pencere kenarındaki bitkinin yaprakları genişleyip koyu yeşile döndü. Dolaptakinin gövdesi uzadı ama yaprakları küçük ve sarımsı kaldı. \"Bak, dolaptaki daha uzun!\" dedi "
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
          "v": " başka bir sorunla karşılaştı. Dolaptaki saksının toprağı daha ıslak görünüyordu. Acaba gerçekten aynı miktarda su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " mu vermişlerdi? İki günün kayıtlarını kontrol edip sulama kaplarının üzerindeki çizgileri karşılaştırdılar. Hata yapmadıklarını gördüler; yine de bir deneyde bütün koşulları dikkatle izlemek gerektiğini anladılar. "
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
          "v": ". \"Su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": ", ışık ve uygun ortam önemli. Ama bütün bitkiler aynı mı, onu da araştırmalıyız.\" Bir hafta boyunca sabırla beklemişti. Aklına şu söz geldi: \""
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
          "v": " defterinin sonuna bir soru daha yazdı: \"Kaktüsle fasulye aynı miktarda su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " ister mi?\" Bu sorunun cevabını henüz bilmiyordu. Bilmediğini söylemek onu üzmedi; aksine ertesi gün için heyecanlandırdı. Çünkü küçük bir tohum"
        },
        {
          "t": "ikon",
          "v": "seed"
        },
        {
          "t": "metin",
          "v": ", kocaman bir merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " başlatmıştı. "
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pa_filiz",
        "tur": "kelime",
        "yazim": "filiz",
        "anlam": "Tohumdan yeni çıkan ince, küçük bitki.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_kosul",
        "tur": "kelime",
        "yazim": "koşul",
        "anlam": "Bir işin ya da deneyin olması için gerekli olan durum.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_gozlem",
        "tur": "kelime",
        "yazim": "gözlem",
        "anlam": "Bir şeye dikkatle bakıp onu anlamaya çalışma.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_ata_sabir",
        "tur": "atasozu",
        "yazim": "Sabreden derviş muradına ermiş",
        "anlam": "Sabırla bekleyen kişi sonunda istediğine ulaşır.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "pa_filiz",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_filiz"
          }
        ]
      },
      {
        "ad": "pa_kosul",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_kosul"
          }
        ]
      },
      {
        "ad": "pa_gozlem",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_gozlem"
          }
        ]
      },
      {
        "ad": "pa_ata_sabir",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "pa_ata_sabir"
          }
        ]
      }
    ]
  }
}$p14$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr015-tohumun-kucuk-sirri: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p15${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr016-golgeyi-kim-buyuttu",
    "baslik": "Gölgeyi Kim Büyüttü?",
    "tur": "bilim",
    "konu": "bahce",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "kardes"
    ],
    "deger_anahtarlari": [
      "D12"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 2,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "bilim_teknoloji",
        "sabir_emek"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D12"
      },
      "ogrenme_hedefleri": [
        {
          "id": "uzun",
          "tur": "lexeme",
          "etiket": "uzun",
          "yuva": "s2_uzun",
          "islev": "first_hint"
        },
        {
          "id": "kisa",
          "tur": "lexeme",
          "etiket": "kısa",
          "yuva": "s2_kisa",
          "islev": "application"
        },
        {
          "id": "kavram_hr016",
          "tur": "concept",
          "etiket": "Işık ve gölge",
          "islev": "application"
        },
        {
          "id": "atasoz_hr016",
          "tur": "proverb",
          "etiket": "Acele işe şeytan karışır",
          "yuva": "ata_acele",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 190,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 6,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 3,
        "simge_sayisi": 11
      }
    },
    "tanitim": "Gölge sabah uzun, öğle kısa. Bunun nedenini nasıl bulabiliriz?",
    "durum": "taslak",
    "fis_kodu": "HR-016"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sabah"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " okula giderken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gölgesinin çok "
        },
        {
          "t": "kelime",
          "yuva": "s2_uzun"
        },
        {
          "t": "metin",
          "v": " olduğunu fark etti. Gölge neredeyse yanındaki duvara kadar uzanıyordu. Öğle vakti aynı yere geldiğinde gölgesi "
        },
        {
          "t": "kelime",
          "yuva": "s2_kisa"
        },
        {
          "t": "metin",
          "v": " olmuştu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "\"Gölgeyi kim küçülttü?\" diye sordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kanadıyla yerdeki gölgeyi gösterdi. \"Belki de güneşin gökyüzündeki yeri değişmiştir.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yerde tebeşirle iki farklı gölge uzunluğunu işaretledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi gün kapının önünde gölgesini inceledi. Bir adım"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": " sağa geçince gölge de onunla birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " yer değiştirdi. \"Sanki bana yapışmış,\" dedi gülerek. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir tebeşir daha getirdi; ikinci işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " gölgenin bittiği yere konuldu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğle vakti iki işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " farklıydı. Önce gölgenin kendiliğinden küçüldüğünü sandı. Sonra gölgesinin düştüğü yere baktı: gölge sabahki yerde değildi, demek ki güneşin yeri değişmişti. "
        },
        {
          "t": "isaret",
          "kod": "gunes"
        },
        {
          "t": "metin",
          "v": " Bir arkadaşı el feneri getirdi. Işığı oyuncak ağacın yanına indirince gölge uzadı; yükseltince kısaldı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "\"Gölge bir canlı değil,\" dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". \"Işığın geldiği yön"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " değişince biçimi de değişiyor.\" Acele etmemek gerekiyordu: \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_acele"
        },
        {
          "t": "metin",
          "v": "\". "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " güvenli deney"
        },
        {
          "t": "ikon",
          "v": "microscope"
        },
        {
          "t": "metin",
          "v": " kuralını hatırlattı: Işık kaynağına doğrudan bakılmaz ve deneyler büyüklerin yanında yapılır."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": ", \"Gölge, ışığın ulaşamadığı yerde oluşur,\" dedi. Sabah"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": ", öğle ve akşam gölgenin boyunu yan yana gösteren resimler yaptılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " artık gölgesinden korkmuyordu. \"Bir sorunun cevabını bulmak"
        },
        {
          "t": "ikon",
          "v": "idea"
        },
        {
          "t": "metin",
          "v": " için birkaç kez bakmak gerekiyormuş,\" dedi."
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
      "metin": "Öğle vakti gölge nasıl olmuştu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kısa"
        },
        {
          "id": "B",
          "metin": "Çok uzun"
        },
        {
          "id": "C",
          "metin": "Hiç yoktu"
        }
      ],
      "dogru": "A",
      "aciklama": "Öğle vakti gölge, sabah olduğundan çok daha kısaydı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Işığı yükseltince gölge neden kısaldı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Işığın geliş yönü değişti"
        },
        {
          "id": "B",
          "metin": "Gölge kendiliğinden küçüldü"
        },
        {
          "id": "C",
          "metin": "Işık sönmüştü"
        }
      ],
      "dogru": "A",
      "aciklama": "Işığın geldiği yön değişince gölgenin biçimi de değişiyordu."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Çocuğun gölgeyi birkaç kez incelemesinin anlamı nedir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir sorunun cevabını bulmak için gözlemi tekrarlamanın gerekli olduğu"
        },
        {
          "id": "B",
          "metin": "Gölgenin sürekli değiştiği"
        },
        {
          "id": "C",
          "metin": "Güneşin hiç doğmayacağı"
        }
      ],
      "dogru": "A",
      "aciklama": "Çocuk, aynı soruyu farklı saatlerde gözlemleyerek cevabı buldu."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 1,
      "metin": "Metinde geçen uzun sözcüğünün zıt anlamlısı hangisidir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "kısa"
        },
        {
          "id": "B",
          "metin": "yeni"
        },
        {
          "id": "C",
          "metin": "eski"
        }
      ],
      "dogru": "A",
      "aciklama": "Uzun, boyu çok olan; kısa ise boyu az olandır."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_uzun",
        "tur": "kelime",
        "yazim": "uzun",
        "anlam": "Boyu ya da süresi çok olan.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_kisa",
        "tur": "kelime",
        "yazim": "kısa",
        "anlam": "Boyu ya da süresi az olan.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_acele",
        "tur": "atasozu",
        "yazim": "Acele işe şeytan karışır",
        "anlam": "Aceleyle yapılan iş genellikle hataya açıktır.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_uzun",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_uzun"
          }
        ]
      },
      {
        "ad": "s2_kisa",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_kisa"
          }
        ]
      },
      {
        "ad": "ata_acele",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_acele"
          }
        ]
      }
    ]
  }
}$p15$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr016-golgeyi-kim-buyuttu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p16${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr017-mahallenin-en-hizli-bisikleti",
    "baslik": "Mahallenin En Hızlı Bisikleti",
    "tur": "spor",
    "konu": "mahalle",
    "sinif_alt": 2,
    "sinif_ust": 2,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "ben",
      "arkadas",
      "kardes"
    ],
    "deger_anahtarlari": [
      "D3",
      "D20"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 2,
      "okuma_zorlugu": 1,
      "kavram_zorlugu": 1,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "dayanisma",
        "sabir_emek"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D3",
        "yardimci_deger": "D20"
      },
      "ogrenme_hedefleri": [
        {
          "id": "eski",
          "tur": "lexeme",
          "etiket": "eski",
          "yuva": "s2_eski",
          "islev": "first_hint"
        },
        {
          "id": "yeni",
          "tur": "lexeme",
          "etiket": "yeni",
          "yuva": "s2_yeni",
          "islev": "application"
        },
        {
          "id": "kavram_hr017",
          "tur": "concept",
          "etiket": "Denge",
          "islev": "application"
        },
        {
          "id": "atasoz_hr017",
          "tur": "proverb",
          "etiket": "Bir elin nesi var, iki elin sesi var",
          "yuva": "ata_elin_nesi",
          "islev": "application"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (2. sınıf; okuma evresi insan editörce kontrol edilecek)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 214,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 7,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "yorumlama": 1,
          "sozcuk_baglami": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 2,
          "concept": 1,
          "proverb": 1
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 6
      }
    },
    "tanitim": "Eski bir bisikletle mahalle yarışına katılmak kolay mı? Bir arkadaşın yardımı ne kazandırır?",
    "durum": "taslak",
    "fis_kodu": "HR-017"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bisikletin boyası yer yer dökülmüştü. Arkadaşlarınınkiler parlaktı ama "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kendi "
        },
        {
          "t": "kelime",
          "yuva": "s2_eski"
        },
        {
          "t": "metin",
          "v": " bisikletini çok seviyordu. Mahalle yarışına katılmaya karar verdiğinde babası önce kaskını ve frenleri kontrol etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yarış afişini görünce "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gidonu sıkıca tuttu. Mert'in bisikleti "
        },
        {
          "t": "kelime",
          "yuva": "s2_yeni"
        },
        {
          "t": "metin",
          "v": " ve parlaktı. \"Önce bisikletin nasıl"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " göründüğüne değil, güvenli olup olmadığına bakalım,\" dedi babası. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de frenleri denemeye yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etti. Kaskın tam oturduğundan emin oldular."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Antrenman için okulun yanındaki boş alana gittiler. İlk gün küçük dönüşlerde yavaşladı, ikinci gün daha dengeli sürdü. Bir hafta sonra bir çizginin üzerinden dikkatle geçebiliyordu. Mert ara sıra ona eşlik etti: \"Hızlı olmak zorunda değilsin. Önemli olan kontrolü kaybetmemek.\""
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yarış sabahı start çizgisinde bisikletler yan yana duruyordu. Tam o sırada Mert'in bisikletinin zinciri çıktı. Yüzü asıldı: \"Her şey bitti.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başlama işaretini kaçırmaktan korktu. Ama arkadaşının üzgün hâlini görünce elini kaldırıp görevliye seslendi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Görevli zincirin düzeltilmesine yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " babasıyla birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " kenarda beklerken Mert son anda yarışa yetişti. İkisi yan yana başladı. Mahallede \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_elin_nesi"
        },
        {
          "t": "metin",
          "v": "\" derlerdi."
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
          "v": " birinci olmadı. Finişte Mert ona sarıldı: \"Sen olmasaydın hiç başlayamazdım.\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de bu sözü duyunca gülümsedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eski bisikletinin gidonuna küçük bir yıldız"
        },
        {
          "t": "ikon",
          "v": "star"
        },
        {
          "t": "metin",
          "v": " çıkartması yapıştırdı. O yıldız ona hızdan çok arkadaşlığı hatırlatıyordu. "
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
          "v": "Akşam "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kaskını rafına koydu. Bisikletin boyası yine aynıydı. Ama artık her bakışında yarış gününü değil, emeği ve dostluğu hatırlıyordu."
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
      "metin": "Metinde bisikletin boyası nasıldı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yer yer dökülmüştü"
        },
        {
          "id": "B",
          "metin": "Tamamen yeniydi"
        },
        {
          "id": "C",
          "metin": "Hiç boyası yoktu"
        }
      ],
      "dogru": "A",
      "aciklama": "Bisikletin boyası yer yer dökülmüştü."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 4,
      "metin": "Yarışta birinci olamamasının nedeni neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Arkadaşının zincirine yardım etmek için geç başlamak"
        },
        {
          "id": "B",
          "metin": "Bisikletinin çok eski olması"
        },
        {
          "id": "C",
          "metin": "Frenlerinin çalışmaması"
        }
      ],
      "dogru": "A",
      "aciklama": "Arkadaşının bisikleti için yardım çağırdı ve yarışa geç yetişti."
    },
    {
      "id": "s3",
      "beceri": "yorumlama",
      "dayanak_sayfa": 6,
      "metin": "Yıldız çıkartması kahramana neyi hatırlatıyordu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Hızdan çok arkadaşlığı"
        },
        {
          "id": "B",
          "metin": "Kazanılan bir madalyayı"
        },
        {
          "id": "C",
          "metin": "Yeni bir bisiklet alacağını"
        }
      ],
      "dogru": "A",
      "aciklama": "Yıldız, ona hızdan çok arkadaşlığı hatırlatıyordu."
    },
    {
      "id": "s4",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 1,
      "metin": "Metinde geçen eski sözcüğü hangi anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çok önce yapılmış ya da kullanılmış olan"
        },
        {
          "id": "B",
          "metin": "Çok hızlı olan"
        },
        {
          "id": "C",
          "metin": "Renkli olan"
        }
      ],
      "dogru": "A",
      "aciklama": "Eski bisiklet, uzun süredir kullanılan bisikletti."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "s2_eski",
        "tur": "kelime",
        "yazim": "eski",
        "anlam": "Çok önce yapılmış ya da kullanılmış olan.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "s2_yeni",
        "tur": "kelime",
        "yazim": "yeni",
        "anlam": "Yakın zamanda yapılmış, az kullanılmış olan.",
        "sinif_alt": 2,
        "sinif_ust": 2
      },
      {
        "id": "ata_elin_nesi",
        "tur": "atasozu",
        "yazim": "Bir elin nesi var, iki elin sesi var",
        "anlam": "Tek kişinin gücü sınırlıdır; birlikte daha çok şey yapılır.",
        "sinif_alt": 2,
        "sinif_ust": 2
      }
    ],
    "yuvalar": [
      {
        "ad": "s2_eski",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_eski"
          }
        ]
      },
      {
        "ad": "s2_yeni",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "s2_yeni"
          }
        ]
      },
      {
        "ad": "ata_elin_nesi",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "ata_elin_nesi"
          }
        ]
      }
    ]
  }
}$p16$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr017-mahallenin-en-hizli-bisikleti: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p17${
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
        "kelime_sayisi": 394,
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
        "simge_sayisi": 17
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
          "v": "Kıyıdaki deniz"
        },
        {
          "t": "ikon",
          "v": "wave"
        },
        {
          "t": "metin",
          "v": " feneri her akşam yanardı. O gece ise güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " ufukta kaybolurken "
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
          "v": ", babasıyla yürüdüğü güvenli seyir terasında durup denize baktı. Açıkta bir teknenin ışıkları görünüyordu. \"Fener"
        },
        {
          "t": "ikon",
          "v": "lighthouse"
        },
        {
          "t": "metin",
          "v": " neden yanmıyor?\" diye sordu. Yanındaki arkadaşı "
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
          "v": " önce \"Az önce,\" diyecekti, sonra düşündü. \"Güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " battığından beri,\" dedi. \"Teknenin ışığını da görüyoruz ama fenerin ışığı yok.\" Görevli, durumu bakım defterine not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " alacağını söyledi."
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
          "v": ", ama bu kez kendisi de duraksadı. Terasın aşağısında deniz"
        },
        {
          "t": "ikon",
          "v": "wave"
        },
        {
          "t": "metin",
          "v": " kabarıyor, dalgalar taşlara çarpıyordu. "
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
          "v": " fenerin üst kısmındaki ışık yuvasını işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " etti. Böylece hangi fenerden söz ettiklerini kesinleştirdiler."
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
          "v": ", denizdeki teknenin hâlâ ilerlediğini fark etti. \"Görmüyorlar mı karanlığı?\" diye kaygılandı. Babası, denizcilere yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etmenin yetkili ekiplerin görevi olduğunu ve teknelerin başka seyir araçları da kullandığını açıkladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", acele edip yanlış "
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
          "v": " yazıyordu. İkisi, liman görevlisinin telefonda sözünü ettiği bakım defterini merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " etti. Görevli, daha sonra çocuklara defterin nasıl"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " tutulduğunu göstermeyi kabul etti. Bir süre sonra limanın servis aracı geldi. Görevliler fenerin elektrik sistemini güvenli biçimde kontrol etmeye başladılar. "
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
          "v": " terastan ayrılmadılar."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " güçlenirken denizdeki tekne"
        },
        {
          "t": "ikon",
          "v": "boat"
        },
        {
          "t": "metin",
          "v": " liman yetkililerinden yönlendirme aldı. Nihayet yüksek kulede beyaz bir ışık döndü. "
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
          "v": " Ertesi gün görevli, bakım defterinin bir kopyasını gösterdi. Tarih, saat"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": ", gözlenen sorun ve yapılan işlem ayrı sütunlarda yazılıydı."
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
          "v": " bu sözü çok sevdi. Deniz"
        },
        {
          "t": "ikon",
          "v": "wave"
        },
        {
          "t": "metin",
          "v": " fenerinin resmini çizdi; altına üç kelime yazdı: "
        },
        {
          "t": "vurgu",
          "v": "gözle, bildir, güvende kal"
        },
        {
          "t": "metin",
          "v": ". Bir sonraki akşam fener"
        },
        {
          "t": "ikon",
          "v": "lighthouse"
        },
        {
          "t": "metin",
          "v": " yanarken iki arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " ışığa değil, birlikte yaptıkları doğru işe bakıp gülümsediler."
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pa_fener",
        "tur": "kelime",
        "yazim": "fener",
        "anlam": "Karanlıkta yol göstermek için ışık yayan yüksek yapı veya araç.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_sinyal",
        "tur": "kelime",
        "yazim": "sinyal",
        "anlam": "Bir şeyi haber vermek için gönderilen ışık, ses ya da işaret.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_ariza",
        "tur": "kelime",
        "yazim": "arıza",
        "anlam": "Bir şeyin çalışmasını bozan sorun.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_ata_acele",
        "tur": "atasozu",
        "yazim": "Acele işe şeytan karışır",
        "anlam": "Telaşla yapılan işlerde hata yapmak kolaylaşır.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "pa_fener",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_fener"
          }
        ]
      },
      {
        "ad": "pa_sinyal",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_sinyal"
          }
        ]
      },
      {
        "ad": "pa_ariza",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_ariza"
          }
        ]
      },
      {
        "ad": "pa_ata_acele",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "pa_ata_acele"
          }
        ]
      }
    ]
  }
}$p17$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr018-deniz-fenerindeki-sinyal: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p18${
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
        "kelime_sayisi": 359,
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
        "simge_sayisi": 11
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
          "v": "Rehber Zeynep Hanım, gezi grubunu mağaranın önünde durdurdu. Girişte serin bir hava hissediliyor, kayalıkların üzerinde üç eski işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " görünüyordu. "
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
          "v": "İlk işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": ", dalgaya benzeyen kıvrımlı bir çizgiydi. Çocuklar bunun bir nehir resmi olduğunu düşündü. Zeynep Hanım, çizginin yanında üst üste duran taş katmanlarını gösterdi. \"Sizce bu kayalar bir günde mi oluştu?\" diye sordu. \"Hayır,\" dedi "
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
          "v": "İkinci işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": ", üçgen biçimindeydi. "
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
          "v": " biraz utandı. \"Hazine"
        },
        {
          "t": "ikon",
          "v": "chest"
        },
        {
          "t": "metin",
          "v": " var sandım,\" diye mırıldandı. Zeynep Hanım gülümsedi. \""
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
          "v": ". Zeynep Hanım benzetmeyi sevdi ama ekledi: \"Kayaların nasıl"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " oluştuğunu anlamak"
        },
        {
          "t": "ikon",
          "v": "lightning-idea"
        },
        {
          "t": "metin",
          "v": " için bilim"
        },
        {
          "t": "ikon",
          "v": "microscope"
        },
        {
          "t": "metin",
          "v": " insanları daha çok gözlem yapar. Tek fotoğrafla bütün geçmişi bilemeyiz.\""
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
          "v": " taşların yüzeyindeki küçük delikleri merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " etti. Rehber, bazılarını suyun ve zamanla gerçekleşen aşınmanın oluşturabileceğini anlattı; başka nedenlerin de olabileceğini söyledi. "
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
          "v": " ilk tahminine yeniden baktı. Hazine"
        },
        {
          "t": "ikon",
          "v": "chest"
        },
        {
          "t": "metin",
          "v": " beklerken kayaların kendi öyküsünü dinlemek ona daha ilginç gelmeye başlamıştı. "
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
          "v": "Çocuklar üç işareti defterlerine sırayla çizdi: kıvrımlı katman, tepe"
        },
        {
          "t": "ikon",
          "v": "mountain"
        },
        {
          "t": "metin",
          "v": " simgesi ve doğal boşluk. Sonra defterleri karıştırıp birbirlerine ne anlama geldiklerini sordular. "
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pa_iz",
        "tur": "kelime",
        "yazim": "iz",
        "anlam": "Bir şeyin ya da birinin geçtiği yerde bıraktığı belirti.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_katman",
        "tur": "kelime",
        "yazim": "katman",
        "anlam": "Üst üste duran tabakalardan her biri.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_tahmin",
        "tur": "kelime",
        "yazim": "tahmin",
        "anlam": "Kesin bilmeden, ipuçlarına bakarak düşünülen sonuç.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "pa_iz",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_iz"
          }
        ]
      },
      {
        "ad": "pa_katman",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_katman"
          }
        ]
      },
      {
        "ad": "pa_tahmin",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_tahmin"
          }
        ]
      }
    ]
  }
}$p18$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr019-magaranin-uc-isareti: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p19${
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
        "kelime_sayisi": 463,
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
        "yoldas_yer_sayisi": 4,
        "simge_sayisi": 22
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
          "v": "Kütüphanenin taşınacağı gün, dört arkadaş tozlu bir sandık buldu. Üzerinde güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": ", yaprak, dalga"
        },
        {
          "t": "ikon",
          "v": "wave"
        },
        {
          "t": "metin",
          "v": " ve yıldız"
        },
        {
          "t": "ikon",
          "v": "star"
        },
        {
          "t": "metin",
          "v": " şekilleri vardı. Fakat şekillerin bulunduğu dört küçük yuva boştu. Sandığın yanında, yıllar önce hazırlanmış bir not duruyordu: \"Bu sandık, bir sınıfın unutmadığı şeylerle açılır.\" \"İçinde ne olabilir?\" diye fısıldadı Ömer. \"Eski haritalar!\" dedi "
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
          "v": "Kütüphane görevlisi sandığın okula ait olduğunu, önce içindekileri kayıt altına almaları gerektiğini söyledi. Kilidi zorlamamalarını da hatırlattı. Çocuklar notu dikkatle inceledi. Altında dört cümle daha vardı: \"Bizi ısıtan; büyümemizi sağlayan; temiz suyu koruyan; gece"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": " yol gösteren.\" "
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
          "v": "Okulun eski fotoğraf albümünde aynı dört simgenin bulunduğu bir sayfa"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " keşfettiler. Sayfanın altında \"Dördüncü Sınıf "
        },
        {
          "t": "kelime",
          "yuva": "pa_hatira"
        },
        {
          "t": "metin",
          "v": " Projesi\" yazıyordu. Albümde, öğrencilerin güneşli bir günde fidan diktiği, dere kıyısında temizlik yaptığı, geceleri yıldızları gözlediği fotoğraflar vardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Albümün kenarında ayrıca dört farklı el yazısı vardı. Güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " fotoğrafının yanına \"Birlikte ısındık\", fidanların altına \"Birlikte büyüttük\", dere temizliğine \"Birlikte koruduk\", yıldız"
        },
        {
          "t": "ikon",
          "v": "star"
        },
        {
          "t": "metin",
          "v": " gözlemine \"Birlikte merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " ettik\" yazılmıştı. "
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
          "v": "Ömer sandığı açmak için sabırsızlanıyordu. \"Bir denesek ne olur? Belki doğru şekil kendiliğinden oturur.\" Görevli, parçaları zorlamanın eski kartonları kırabileceğini hatırlattı. Dört arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " masanın üzerinde kâğıttan bir sandık"
        },
        {
          "t": "ikon",
          "v": "chest"
        },
        {
          "t": "metin",
          "v": " resmi çizdi, şekilleri önce oraya yerleştirdi. Bir şeyin cevabını bulmak için her zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " asıl nesneyi kurcalamak gerekmediğini keşfettiler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kerem, dört cümleyi fotoğraflarla eşleştirmek istedi. \"Bizi ısıtan güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": ". Büyümemizi sağlayan yaprak"
        },
        {
          "t": "ikon",
          "v": "leaf"
        },
        {
          "t": "metin",
          "v": ",\" dedi. Ömer sözünü kesti: \"Peki 'temiz suyu koruyan' neden dalga"
        },
        {
          "t": "ikon",
          "v": "wave"
        },
        {
          "t": "metin",
          "v": " olsun?\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir fotoğrafı gösterdi. Dere temizliğinin fotoğrafında, köşeye çizilmiş küçük bir dalga simgesi vardı. \"Su dalgayla gösterilmiş,\" dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". \"Demek ki temiz suyu koruyan, dalga.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Her ipucunu fotoğraflarla sınadık, şimdi sıra bunları sıraya koymakta,\" diye düşündü. Yeniden albüme döndüler ve son sayfaya baktılar."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Son sayfada küçük bir şiir vardı: \"Güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " bizi ısıtır, yaprak bizi büyütür, dalga"
        },
        {
          "t": "ikon",
          "v": "wave"
        },
        {
          "t": "metin",
          "v": " temiz suyu korur, yıldız"
        },
        {
          "t": "ikon",
          "v": "star"
        },
        {
          "t": "metin",
          "v": " geceye yol gösterir.\" Çocuklar bunun yalnızca bir şiir olmadığını, dört etkinliği sıralayan gizli düzen, yani "
        },
        {
          "t": "kelime",
          "yuva": "pa_sifre"
        },
        {
          "t": "metin",
          "v": " olduğunu anladılar. Sandığın yanındaki çekmecede kartondan yapılmış dört şekil bulundu. Şekilleri şiirdeki sıraya göre yerleştirdiklerinde sandığın mekanik mandalı tık etti. Görevli kapağı kendisi açtı. "
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
          "v": "İçeriden altın çıkmadı. Dört küçük defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": ", öğrencilerin çekilmiş fotoğrafları ve bir paket kuru tohum"
        },
        {
          "t": "ikon",
          "v": "seed"
        },
        {
          "t": "metin",
          "v": " çıktı. Defterlerin birinde şu cümle yazılıydı: \"Yıllar sonra açacak olanlara: Biz bu okulu yalnızca derslerimizle değil, birlikte yaptıklarımızla hatırlıyoruz.\" Ömer önce biraz hayal kırıklığına uğradı. Sonra tohum paketini eline aldı. \"Bunları dikebilir miyiz?\" diye sordu. Görevli, tohumların eski olduğu için filizlenmeyebileceğini, yine de denemelerini önerdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar sandığın içindekileri düzenleyip okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " arşivine teslim etti. Çekmecedeki dört şeklin kopyalarını da yeni hatıra panosuna yerleştirdiler. Bir hafta sonra sınıflarına ait bir fotoğraf çektiler. Fotoğrafın arkasına herkes bir cümle yazdı. "
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pa_sifre",
        "tur": "kelime",
        "yazim": "şifre",
        "anlam": "Çözülünce bir şeyi açan gizli işaret ya da söz.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pa_hatira",
        "tur": "kelime",
        "yazim": "hatıra",
        "anlam": "Geçmişten akılda kalan, unutulmak istenmeyen anı.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
    "yuvalar": [
      {
        "ad": "pa_sifre",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_sifre"
          }
        ]
      },
      {
        "ad": "pa_hatira",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_hatira"
          }
        ]
      }
    ]
  }
}$p19$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr021-kayip-sandigin-sifresi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p20${
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
        "kelime_sayisi": 369,
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
        "yoldas_yer_sayisi": 6,
        "simge_sayisi": 9
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
          "v": "Meydandaki saat"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " kulesi her öğlen on ikide çalardı. O gün çalmadı. Üstelik akrep on bir ile on iki arasındaydı, "
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
          "v": "Görevli, kulenin durduğu haberinin öğleden önce, on bir buçuk sularında geldiğini söyledi. "
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
          "v": " defterine üç zamanı yazdı: \"On bir otuz, on iki, on iki on.\" \"Birinci zaman kulenin durduğu saat"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": ". İkinci zaman çalması gereken saat. Üçüncü zaman bizim baktığımız saat,\" dedi. "
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
          "v": ", duvardaki başka bir saati gösterdi; çiçekçinin telefonu da doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " saati gösteriyordu. İkisi birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " saatleri karşılaştırınca farklı araçların aynı işi yapabildiğini konuştular."
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
          "v": ", \"Kule öğlenden başka zamanlarda da çalar mı?\" diye sordu. Çiçekçi omuz silkti. \"Ben hep öğlen duydum, gerisini bilmem.\" "
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
          "v": "Bir süre sonra bakım ustası Fatma Hanım geldi. Çocuklar, kuleye girmeden ona gördüklerini anlattılar. Usta bir güvenlik kapısından geçip içerideki mekanizmayı inceledi. Çarkların arasında küçük bir parça gevşemişti. Parçayı uygun aletlerle sağlamlaştırdı, sonra saati doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " zamana ayarladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", \"Kule neden"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " durmuş?\" diye sordu. Fatma Hanım, \"Bazen büyük makineleri küçük parçalar durdurur,\" dedi. \"Bu yüzden düzenli "
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
          "v": " meydandaki iki farklı saatin bir an için aynı zamanı göstermediğini fark etti. \"Hangisine güveneceğiz?\" diye sordu. \"Doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " çalışan ve güncellenen kaynakları karşılaştıracağız,\" dedi usta. \"Bir "
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
          "v": " şakalaştı: \"Saat"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " kulede durmuş, bizim merakımız hiç durmamış!\" "
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
      "aciklama": "Kulenin akrebi on bir ile on iki arasında, yelkovanı altıyı gösteriyordu; saat on bir buçukta kalmıştı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Görevli haberin öğleden önce geldiğini söyleyince çocuk hangi sonuca vardı?",
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
      "aciklama": "Haber öğleden önce geldiği için arıza öğlende başlamış olamazdı."
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pa_yelkovan",
        "tur": "kelime",
        "yazim": "yelkovan",
        "anlam": "Saatte dakikayı gösteren uzun ibre.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_bakim",
        "tur": "kelime",
        "yazim": "bakım",
        "anlam": "Bir şeyin iyi çalışması için düzenli olarak kontrol edilip onarılması.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_olcum",
        "tur": "kelime",
        "yazim": "ölçüm",
        "anlam": "Bir şeyin boyunu, ağırlığını ya da zamanını bulmak için yapılan işlem.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "pa_yelkovan",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_yelkovan"
          }
        ]
      },
      {
        "ad": "pa_bakim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_bakim"
          }
        ]
      },
      {
        "ad": "pa_olcum",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_olcum"
          }
        ]
      }
    ]
  }
}$p20$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr022-saat-kulesi-neden-durdu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p21${
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
        "simge_sayisi": 9
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
          "v": " karşı komşusu Hasan amca içeriye baktı. Elinde bir sepet vardı. \"Size bahçemden elma getirdim. Ama oyalanmayayım,\" dedi. Hoca, boş tabağı işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " etti. \"Bakınız, tabak sizden önce gelmiş!\" Hasan amca şaşırdı. \"Beni beklediğinizi bilmiyordum.\" \"Biz de bilmiyorduk,\" dedi Hoca. \"Bazen yer hazır olur, misafir sonradan belli olur.\""
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
          "v": " bir soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " sordu: \"Misafirperverlik, herkesi mutlaka sofraya oturtmak mıdır?\""
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
          "v": ", \"Demek görünmeyen misafirimiz aslında bir yanlış anlamaymış,\" dedi. \"Öyle,\" dedi Hoca. \"Ama yanlış anlamak, doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " sorunca hemen görünür olur.\""
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
          "v": ". \"Çünkü Hasan amca oturmadı.\" Hoca gülümsedi. \"Aferin! Görmediğimiz birini sayarken önce ne olduğunu anlamak"
        },
        {
          "t": "ikon",
          "v": "lightning-idea"
        },
        {
          "t": "metin",
          "v": " gerekir.\" "
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
          "v": " artık sofradaki boş yerlere bakıp hemen korkunç bir hikâye"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " düşünmemeye karar verdi."
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pa_misafir",
        "tur": "kelime",
        "yazim": "misafir",
        "anlam": "Bir eve ya da yere konuk olarak giden kişi.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_israr",
        "tur": "kelime",
        "yazim": "ısrar",
        "anlam": "Bir şeyi kabul ettirmek için üstelemek.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_bilmece",
        "tur": "kelime",
        "yazim": "bilmece",
        "anlam": "Cevabı düşünerek bulunan kısa soru ya da söz oyunu.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "pa_misafir",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_misafir"
          }
        ]
      },
      {
        "ad": "pa_israr",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_israr"
          }
        ]
      },
      {
        "ad": "pa_bilmece",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_bilmece"
          }
        ]
      }
    ]
  }
}$p21$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr023-hoca-ve-gorunmeyen-misafir: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p22${
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
        "kelime_sayisi": 381,
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
        "simge_sayisi": 20
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
          "v": "Bulutlar Şehri'nde herkesin bir görevi vardı. Yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " Bulutu bahçeleri sular, Rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " Bulutu yelkenlere yardım eder, Postacı Pofuduk ise mektupları götürürdü. O sabah Pofuduk'un çantasında yalnızca bir zarf kalmıştı. Üzerinde şu "
        },
        {
          "t": "kelime",
          "yuva": "pa_adres"
        },
        {
          "t": "metin",
          "v": " yazıyordu: \"Kuzey Tepesi, Mavi Pencereli Ev"
        },
        {
          "t": "ikon",
          "v": "house"
        },
        {
          "t": "metin",
          "v": ".\" "
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
          "v": "Pofuduk kuzeye uçtuğunu sanıyordu. Fakat birkaç dakika sonra altındaki deniz"
        },
        {
          "t": "ikon",
          "v": "wave"
        },
        {
          "t": "metin",
          "v": " yerine kocaman bir çöl"
        },
        {
          "t": "ikon",
          "v": "desert"
        },
        {
          "t": "metin",
          "v": " gördü. \"Bu işte bir terslik var,\" diye mırıldandı. Yanında uçan yol arkadaşı "
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
          "v": "Rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " Bulutu yanına sokuldu. \"Ben seni sürükledim, özür dilerim.\" \"Önemli değil,\" dedi Pofuduk. \"Ama mektup"
        },
        {
          "t": "ikon",
          "v": "scroll"
        },
        {
          "t": "metin",
          "v": " sahibini bekletmeyelim.\" İkisi birlikte yönlerini düzeltti. Derken birbirine benzeyen iki tepe gördüler. Birinde kırmızı çatılı, diğerinde mavi pencereli ev vardı. Pofuduk hemen aşağı inecekti ki bir ayrıntıyı fark etti: Mavi pencere güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " ışığından mı mavi görünüyordu, yoksa gerçekten maviye mi boyanmıştı?"
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
          "v": " aşağıdaki kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " sürüsüne seslendi. Kuşların lideri, mavi pencereli evin kuzeydeki ikinci tepede olduğunu söyledi. Pofuduk teşekkür etti; adresin yalnızca renk değil, "
        },
        {
          "t": "kelime",
          "yuva": "pa_yon"
        },
        {
          "t": "metin",
          "v": " bilgisi de verdiğini anladı. Evin çatısına konmadan önce çantasını kontrol etti. Yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " Bulutu biraz önce yanından geçmişti; zarfın ıslanmaması için onu dikkatle saklamıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Zarfın köşesindeki pulun üzerinde küçük bir yıldız"
        },
        {
          "t": "ikon",
          "v": "star"
        },
        {
          "t": "metin",
          "v": " vardı. Postacı, yıldızın yön"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " göstermediğini, yalnız süs olduğunu fark etti. Bir resim, her zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " haritadaki bir işaret değildi. Tam mektubu bırakacağı sırada evin penceresi açıldı. İçeriden gelen ses, \"Mavi pencereyi mi arıyorsun?\" diye sordu. Pofuduk adresi bir kez daha okudu ve tepeyi teyit etti. Yanlış bir eve gidip başkasının haberini paylaşmak istemiyordu. Zarfın üzerindeki ismi ve kapıdaki ismi karşılaştırdı. İkisi de aynıydı. Ancak ondan sonra yaklaşarak mektubu verdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Evde yaşlı bir teyze yaşıyordu. Zarfı açınca gözleri parladı. Uzakta okuyan torunu, kendi yaptığı çizimin fotoğrafını göndermişti. Mektupta \"Büyüyünce bulut"
        },
        {
          "t": "ikon",
          "v": "cloud"
        },
        {
          "t": "metin",
          "v": " ressamı olacağım\" yazıyordu. Pofuduk teyzenin gülümsemesini görünce yorgunluğunu unuttu. \"Bir mektup"
        },
        {
          "t": "ikon",
          "v": "scroll"
        },
        {
          "t": "metin",
          "v": " bu kadar önemli olabilir mi?\" diye sordu. \"Elbette,\" dedi teyze. \"Bazen bir haber, uzağı yakın eder.\" "
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
          "v": "Pofuduk dönüş yolunda çantasını boş buldu ama kendisini eksik hissetmedi. O gün bir zarfın yalnız kâğıt değil, sevincin taşıyıcısı olduğunu öğrenmişti. Yeni bir mektup"
        },
        {
          "t": "ikon",
          "v": "scroll"
        },
        {
          "t": "metin",
          "v": " geldiğinde adresin yönünü iki kez kontrol edecekti. Bulutlar Şehri'ne döndüğünde pusulasını girişteki panoya astı. Altına küçük bir not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " ekledi: \"Bir yere yetişmek kadar, doğru yere varmak da önemlidir.\" Rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " Bulutu notu okuyup güldü. \"Bir dahaki sefere önce birlikte haritaya bakalım!\" dedi. Pofuduk gülümsedi ve \""
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pa_adres",
        "tur": "kelime",
        "yazim": "adres",
        "anlam": "Bir yerin ya da kişinin bulunduğu yeri gösteren bilgi.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_pusula",
        "tur": "kelime",
        "yazim": "pusula",
        "anlam": "Yönleri bulmaya yarayan araç.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_yon",
        "tur": "kelime",
        "yazim": "yön",
        "anlam": "Bir şeyin gittiği ya da bakılan taraf; kuzey, güney gibi.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_ata_acele",
        "tur": "atasozu",
        "yazim": "Acele işe şeytan karışır",
        "anlam": "Telaşla yapılan işlerde hata yapmak kolaylaşır.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "pa_adres",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_adres"
          }
        ]
      },
      {
        "ad": "pa_pusula",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_pusula"
          }
        ]
      },
      {
        "ad": "pa_yon",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_yon"
          }
        ]
      },
      {
        "ad": "pa_ata_acele",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "pa_ata_acele"
          }
        ]
      }
    ]
  }
}$p22$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr024-bulut-postacisinin-son-mektubu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p23${
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
        "kelime_sayisi": 382,
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
        "simge_sayisi": 23
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
          "v": "Eşek, köpek"
        },
        {
          "t": "ikon",
          "v": "dog"
        },
        {
          "t": "metin",
          "v": ", kedi"
        },
        {
          "t": "ikon",
          "v": "cat"
        },
        {
          "t": "metin",
          "v": " ve horoz küçük bir orman yolunda yürüyordu. Yol arkadaşı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de yanlarındaydı. Bremen'e giden uzun yolun ortasında yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " başladı. Hepsi eski bir değirmene sığındı. Çatının altından düşen damlalar, taşlara farklı seslerle vuruyordu: tak, tik, tuk."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Horoz kanatlarını çırptı. \"Harika bir konser salonu bulduk!\" dedi. Eşek yüksek sesle anırdı. Köpek"
        },
        {
          "t": "ikon",
          "v": "dog"
        },
        {
          "t": "metin",
          "v": " havladı, kedi"
        },
        {
          "t": "ikon",
          "v": "cat"
        },
        {
          "t": "metin",
          "v": " miyavladı. Fakat hepsi aynı anda bağırınca ortaya anlaşılmaz bir gürültü çıktı. Kedi kulaklarını kapattı. \"Hepimiz duyulmak istiyoruz ama kimse kimseyi dinlemiyor.\" Eşek biraz alındı. \"Benim sesim zaten böyle güçlü. Sessiz mi olayım?\" \"Hayır,\" dedi köpek. \"Gücünü doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " zamanda kullansan yeter.\""
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
          "v": " tuttu. \"Bir, iki, üç, dört.\" Kedi"
        },
        {
          "t": "ikon",
          "v": "cat"
        },
        {
          "t": "metin",
          "v": " ince sesini ikinci vuruşa, köpek"
        },
        {
          "t": "ikon",
          "v": "dog"
        },
        {
          "t": "metin",
          "v": " kalın sesini üçüncüye koydu. Eşek dördüncü vuruşta öyle güzel anırdı ki değirmenin içi neşeyle doldu. Sonra yer değiştirdiler. Birinin sesi ötekini bastırdığında durup yeniden başladılar."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir süre sonra eşek ritmi kaçırdı. Çünkü çatıdan damlayan suyun sesi hızlanmıştı. \"Ben yanlış mı söylüyorum?\" diye sordu. Horoz, \"Belki de herkes aynı ritmi duymuyor,\" dedi. Köpek"
        },
        {
          "t": "ikon",
          "v": "dog"
        },
        {
          "t": "metin",
          "v": " önce dört eşit adım"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": " attı, sonra ayak izlerini yerde gösterdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de vuruşları saymalarına yardım etti. Dört sesin arasına küçük bir sessizlik koyduklarında şarkı daha anlaşılır oldu. Kedi"
        },
        {
          "t": "ikon",
          "v": "cat"
        },
        {
          "t": "metin",
          "v": ", \"Bazen susmak da müziğin parçası,\" diyerek gülümsedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eşek bir daha anırmadan önce arkadaşlarına baktı. Onlardan işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " alınca sesini yükseltti. Kendi sesinin kıymetini kaybetmemiş, yalnız diğerlerine yer açmıştı. Değirmenin damlaları da sanki onlara eşlik ediyordu. Yağmurun sesi azaldıkça yeni bir "
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
          "v": "Dışarıda yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " hafifledi. Yol kenarında bir grup çocuk vardı. Çocuklar değirmenin içinden gelen müziği merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " etmişti. Hayvanlar kapıya çıktı ve kısa şarkılarını söylediler. Çocukların biri ellerini çırparak eşlik etti. Bir başkası yağmur damlalarının sesini taklit etti. Böylece şarkıya yeni bir ritim eklendi. Horoz gururla kabardı. \"Artık hepimiz aynı sesle mi şarkı söyleyeceğiz?\" diye sordu. \"Hayır,\" dedi kedi"
        },
        {
          "t": "ikon",
          "v": "cat"
        },
        {
          "t": "metin",
          "v": ". \"Güzel olan zaten farklı seslerimiz.\" "
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
          "v": "Kedi"
        },
        {
          "t": "ikon",
          "v": "cat"
        },
        {
          "t": "metin",
          "v": ", değirmenin duvarına kulak verdi. Sesler artık birbirine karışmıyordu. \"Bence yolculuğumuzun bir şarkısı oldu,\" dedi. Horoz da bunu her molada yeniden söylemeyi önerdi. Yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " tamamen dinince yola devam ettiler. Köpek"
        },
        {
          "t": "ikon",
          "v": "dog"
        },
        {
          "t": "metin",
          "v": ", değirmende öğrendikleri ritmi unutmamak için adımlarını saydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eşek, su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " birikintilerinden geçerken adımlarını yavaşlattı. Horoz zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " zaman hızlanmak istediğinde arkadaşları ona yetişmeleri için biraz durmasını söyledi. Akşama doğru uzaktan Bremen'in çanları duyuldu. Dört arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " birbirine baktı. Çanların sesini kendi şarkılarına eklemeyi düşündüler. Şehre daha varmadan öğrendikleri şey açıktı: "
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pa_ritim",
        "tur": "kelime",
        "yazim": "ritim",
        "anlam": "Seslerin ya da vuruşların düzenli tekrar eden akışı.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_ezgi",
        "tur": "kelime",
        "yazim": "ezgi",
        "anlam": "Birbirini izleyen seslerle oluşan müzik; melodi.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pa_uyum",
        "tur": "kelime",
        "yazim": "uyum",
        "anlam": "Farklı şeylerin birbirine karışmadan güzel bir bütün oluşturması.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "pa_ritim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_ritim"
          }
        ]
      },
      {
        "ad": "pa_ezgi",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_ezgi"
          }
        ]
      },
      {
        "ad": "pa_uyum",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "pa_uyum"
          }
        ]
      }
    ]
  }
}$p23$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr025-bremen-yolcularinin-yeni-sarkisi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p24${
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
        "kelime_sayisi": 353,
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
        "simge_sayisi": 12
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
          "v": " diye yazılıyor ama aynı anlama gelmiyor,” dedi. Dede gülümsedi. “Demek ki bir kelimenin nerede kullanıldığını anlamak"
        },
        {
          "t": "ikon",
          "v": "lightning-idea"
        },
        {
          "t": "metin",
          "v": " gerekiyor.” "
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
          "v": "!” dedi. Makine ekrana güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " resmi ve bir kalem"
        },
        {
          "t": "ikon",
          "v": "pencil"
        },
        {
          "t": "metin",
          "v": " çizdi. Bu kez doğruya yaklaşmıştı. Dede masaya iki kart daha koydu. Birinde “Kışın kar"
        },
        {
          "t": "ikon",
          "v": "snow"
        },
        {
          "t": "metin",
          "v": " yağdı”, diğerinde “Bize kâr kaldı” yazıyordu. "
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
          "v": " de yeni bir kart istedi. “O zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " yalnız gerçekten aynı yazılan ve farklı anlamlara gelen örneklerle başlayalım.” Makine bu uyarıyı duyunca ekrana büyük bir soru"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " işareti çıkardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Sorular bazen cevaptan daha işe yarar,” diye düşündü. Makinenin hatasını bulmak"
        },
        {
          "t": "ikon",
          "v": "idea"
        },
        {
          "t": "metin",
          "v": ", düğmelerine rastgele basmaktan daha çok zaman almış ama daha eğlenceli olmuştu."
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
          "v": ", “Çay kıyısında çay içtik,” dedi. Makine bu kez su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " akan bir dere ile iki fincan çizdi. İki kardeş sevinçle alkışladı. Ancak makine beklenmedik bir soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " sordu: “Peki kelimelerin iki anlamı varsa, insanların da bazen birden fazla duygusu olur mu?” "
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pb_gul",
        "tur": "kelime",
        "yazim": "gül",
        "anlam": "Güzel kokulu, dikenli bir çiçek; aynı yazılan gül sözcüğü gülmek eyleminin emir biçimi de olabilir.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pb_yuz",
        "tur": "kelime",
        "yazim": "yüz",
        "anlam": "Doksan dokuzdan sonra gelen sayı; aynı zamanda insanın gözlerinin, burnunun ve ağzının bulunduğu yer.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pb_yaz",
        "tur": "kelime",
        "yazim": "yaz",
        "anlam": "Yılın en sıcak mevsimi; aynı yazılan yaz sözcüğü kalemle yazı yazmak anlamına da gelir.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
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
      }
    ]
  }
}$p24$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr026-kelime-makinesinin-karisikligi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p25${
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
        "simge_sayisi": 7
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
          "v": "Hacivat gülerek lambayı biraz sağa kaydırdı. Karagöz'ün gölgesi sola uzadı. Lambayı yaklaştırınca gölge büyüdü, uzaklaştırınca küçüldü. “Görüyor musun?” dedi. “Işığın yeri değişince gölgenin görünüşü de değişiyor.” Karagöz kaşlarını çattı. “O zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " ben büyüdüm mü küçüldüm mü?” “Sen aynı Karagöz'sün. Yalnız gölgen değişiyor.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hacivat küçük bir deney"
        },
        {
          "t": "ikon",
          "v": "microscope"
        },
        {
          "t": "metin",
          "v": " daha yaptı. Masanın üzerine oyuncak bir ev"
        },
        {
          "t": "ikon",
          "v": "house"
        },
        {
          "t": "metin",
          "v": " koyup feneri farklı yönlerden tuttu. Evin bacası bazen uzun, bazen kısa bir gölge bırakıyordu. Karagöz bunu görünce, “Bacanın boyunu kim değiştiriyor?” diye sordu. "
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
          "v": "Hacivat fenerin önüne ikinci bir oyuncak koydu. İki gölge üst üste gelince Karagöz hangisinin kendisine ait olduğunu ayırt edemedi. Hacivat nesneleri ayrı ayrı hareket ettirdiğinde sorun çözüldü. “Bir şeyi anlamak"
        },
        {
          "t": "ikon",
          "v": "lightning-idea"
        },
        {
          "t": "metin",
          "v": " için bazen parçaları tek tek incelemek gerekir,” dedi. Az sonra seyirci çocuklar geldi. Hacivat iki ayrı fener"
        },
        {
          "t": "ikon",
          "v": "lighthouse"
        },
        {
          "t": "metin",
          "v": " hazırladı. Biri güçlü, diğeri daha zayıf ışık veriyordu."
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pb_golge",
        "tur": "kelime",
        "yazim": "gölge",
        "anlam": "Işığın önüne bir şey girince arkasında oluşan karanlık görüntü.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pb_perde",
        "tur": "kelime",
        "yazim": "perde",
        "anlam": "Gölge oyununda görüntülerin üzerine düştüğü beyaz örtü; pencereyi örten kumaş da perdedir.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pb_mecaz",
        "tur": "kelime",
        "yazim": "mecaz",
        "anlam": "Bir sözün gerçek anlamından ayrılıp benzetmeyle kullanılan anlamı.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
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
      }
    ]
  }
}$p25$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr027-karagozun-kayip-golgesi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p26${
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
        "simge_sayisi": 13
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
          "v": " top"
        },
        {
          "t": "ikon",
          "v": "ball"
        },
        {
          "t": "metin",
          "v": " sürmeyi, "
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
          "v": "Öğretmenleri kuralları açıkladı. İlk durakta ip engellerinden geçilecek, ikinci durakta top"
        },
        {
          "t": "ikon",
          "v": "ball"
        },
        {
          "t": "metin",
          "v": " hedefe atılacak, son durakta renkli kartların şifresi çözülecekti. Takımın başarısı için üç görev"
        },
        {
          "t": "ikon",
          "v": "quest"
        },
        {
          "t": "metin",
          "v": " de gerekliydi. Başlama işareti verilince "
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
          "v": "Top"
        },
        {
          "t": "ikon",
          "v": "ball"
        },
        {
          "t": "metin",
          "v": " durağında Ada topu iki kez kaçırdı. "
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
          "v": " kartları dizdi. Fakat öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " ilk dizilişi onaylamadı. "
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
          "v": "Tam son kartı yerleştirirken bir rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " çıktı ve mavi kart uçtu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " arkasından koşmaya kalktı, fakat öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " bahçe sınırını gösterdi. Ada, görevliden yedek kart istedi. Yarış biraz gecikti ama kurallara uydular."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yarışın sonlarına doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " başka bir takımın kartlarından biri de yere düştü. "
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
          "v": "Son kartları dizdikten sonra üç arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " ellerini üst üste koydu. Ada ip atlamayı bilmeyenlere yeniden göstermeyi, "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " topu korkmadan deneyenlere cesaret"
        },
        {
          "t": "ikon",
          "v": "courage"
        },
        {
          "t": "metin",
          "v": " vermeyi, "
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
          "v": " renkler"
        },
        {
          "t": "ikon",
          "v": "rainbow"
        },
        {
          "t": "metin",
          "v": " birlikte daha güzel görünmüyor mu?”"
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
          "v": " bir öneriyle geldi: “Bu kez herkesin sevdiği bir oyunu birlikte deneyelim.” Önce ip atladılar, sonra top"
        },
        {
          "t": "ikon",
          "v": "ball"
        },
        {
          "t": "metin",
          "v": " oynadılar, en sonda "
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pb_takim",
        "tur": "kelime",
        "yazim": "takım",
        "anlam": "Bir işi ya da oyunu birlikte yapan insan topluluğu.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pb_sira",
        "tur": "kelime",
        "yazim": "sıra",
        "anlam": "Birbiri ardından gelen şeylerin dizilişi; önce ve sonra düzeni.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pb_farkli",
        "tur": "kelime",
        "yazim": "farklı",
        "anlam": "Başkasına benzemeyen, ayrı özellikte olan.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
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
      }
    ]
  }
}$p26$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr028-uc-renkli-takim: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p27${
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
        "kelime_sayisi": 375,
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
        "simge_sayisi": 18
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
          "v": ", okulun bilim gününde güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " enerjisini anlatmak istiyordu. Ama güneşi bir kavanoza dolduramayacağına göre, onun ısısını nasıl gösterecekti? Öğretmeniyle birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " bir kutu modeli hazırlamaya karar verdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " iki eş boy karton kutunun içini aynı koyu renkli kâğıtla kapladı. İkisine de aynı tür saydam kapak yerleştirdi. "
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
          "v": " ilk ölçümü deftere yazdı. Her iki termometre de yaklaşık aynı değeri gösteriyordu. On dakika"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " sonra güneşte duran kutunun sıcaklığı daha yüksek çıktı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " hemen bağırdı: “Süper! Kutunun içinde ateş"
        },
        {
          "t": "ikon",
          "v": "fire"
        },
        {
          "t": "metin",
          "v": " var!” "
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
          "v": " kutuyu ısıtıyor olabilir.” Öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": ", saydam kapağın ışığın bir kısmını içeri aldığını ve kutunun ısı kaybını azaltmaya yardımcı olduğunu anlattı. "
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
          "v": " güneşteki kutuyu daha sık açmak istemişti. Öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": ", kapağın her açılışında içerdeki koşulların değişebileceğini hatırlattı. Bunun üzerine ölçüm zamanlarını önceden belirlediler. "
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
          "v": ", gölgede duran kutunun da biraz ısındığını görünce şaşırdı. “O kutuya doğrudan güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " gelmedi,” dedi. Öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": ", havanın sıcaklığının da değişebileceğini söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Öyleyse iki kutunun farkına birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " bakmalıyız,” diyerek her ikisinin değerini yeniden okudu. Bir deneyde tek bir sonucun her şeyi anlatmayacağını fark etmişti."
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
          "v": ", “Deney"
        },
        {
          "t": "ikon",
          "v": "microscope"
        },
        {
          "t": "metin",
          "v": " bozuldu,” diye üzüldü. "
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
          "v": " deney başında yazdığı tahmini okudu. Sonuç tam beklediği gibi değildi; özellikle bulutlu saatte fark azalmıştı. Bu kez defterine bir sonuç cümlesi yerine yeni bir soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " yazdı: “Farklı günlerde ölçsek aynı sonuç çıkar mı?”"
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
          "v": " dikkatli cevap verdi: “Güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " ısısından yararlanan gerçek düzenekler var. Bizim yaptığımız ise öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " gözetiminde kullanılan bir "
        },
        {
          "t": "kelime",
          "yuva": "pb_olcum"
        },
        {
          "t": "metin",
          "v": " modeli.” Sergi sonunda öğretmen ona bir yıldız"
        },
        {
          "t": "ikon",
          "v": "star"
        },
        {
          "t": "metin",
          "v": " çıkartması verdi. "
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pb_termometre",
        "tur": "kelime",
        "yazim": "termometre",
        "anlam": "Sıcaklığı ölçmeye yarayan alet.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pb_enerji",
        "tur": "kelime",
        "yazim": "enerji",
        "anlam": "Isıtmak, ışık vermek ya da hareket ettirmek gibi işleri yapabilen güç.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "pb_olcum",
        "tur": "kelime",
        "yazim": "ölçüm",
        "anlam": "Bir şeyin boyunu, sıcaklığını ya da ağırlığını bir araçla öğrenme işi.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
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
      }
    ]
  }
}$p27$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr029-minik-mucit-ve-gunes-firini: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p28${
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
        "kelime_sayisi": 471,
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
        "simge_sayisi": 21
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
          "v": "Görevli, güvenli ve açık bir başka yol olduğunu, yeni yön"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " levhalarının henüz yerleştirilmediğini söyledi. "
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
          "v": " üzerinden gidecek, eksik levhaları not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " edeceklerdi."
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
          "v": " sağa dönmek istedi, çünkü oradan kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " sesi geliyordu. Nisa ise haritadaki okları işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " etti. “Kuş sesi yönümüzü göstermiyor. Terasa gitmek için önce sola dönmeliyiz.” "
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
          "v": " levhayı kaldırmak istedi, fakat öğretmeni önce çevreye bakmalarını söyledi. Yağmurdan sonra zemin kaygandı. Görevlinin not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " alması için levhanın yerini haritada işaretlediler; ona dokunmadan yürüdüler. Gözlem terasına vardıklarında gölet uzaktan görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Eski patika haritada daha kısa. Neden orayı kullanmıyoruz?” diye sordu. “Çünkü kısa yol her zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " güvenli yol değildir,” dedi öğretmeni. “Harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": ", yolun nerede olduğunu gösterir; güncel levhalar ve görevliler ise hangi yolu kullanabileceğimizi bildirir.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Gözlem terasında beklerken Nisa, krokideki küçük karelerin ne işe yaradığını merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " etti. Öğretmenleri bunların harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " üzerindeki belirli yerleri gösterdiğini anlattı. "
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
          "v": " dendiğini ekledi. Çocuklar adımlarını sayarak kısa bir mesafeyi karşılaştırdı ama yaklaşık sonuçları kesin ölçüm sanmamaları gerektiğini de öğrendiler."
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
          "v": " yeni levhaların yalnız doğru yeri göstermesini değil, herkesçe anlaşılmasını istiyordu. Okuma güçlüğü yaşayan küçük çocukların da işaretleri anlayabilmesi için renk ve şeklin yazıyla birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " kullanılmasını önerdi. Öğretmen öneriyi not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " etti. Dönüşte park ofisinde görevli, çocukların işaretlediği noktaları inceledi. "
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
          "v": ", “Bir de kavşaktan önce levha koyarsanız insanlar son anda yön"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " değiştirmek zorunda kalmaz,” diye ekledi. "
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
          "v": " da çizdiği kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " resmini yol işaretinden ayırdı: “Güzel bir resim, her zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " açık bir işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " olmayabilir.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir hafta sonra sınıf yeniden parka geldi. Kapatılmış patikanın girişinde hâlâ uyarı"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " vardı, fakat açık yola yeni levhalar yerleştirilmişti. Levhalarda yön"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " oklarının yanında küçük yaprak"
        },
        {
          "t": "ikon",
          "v": "leaf"
        },
        {
          "t": "metin",
          "v": " simgeleri bulunuyordu. Park görevlisi çocuklara teşekkür etti: “Gözlemleriniz, yürüyüşçülerin işini kolaylaştırdı.”"
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
          "v": " eve gidince iki haritayı yan yana koydu: Biri eski patikayı, diğeri güncel ve güvenli güzergâhı gösteriyordu. Aralarındaki farkı renklendirerek çizdi. Defterinin altına şu cümleyi yazdı: İyi bir yol bulmak"
        },
        {
          "t": "ikon",
          "v": "idea"
        },
        {
          "t": "metin",
          "v": ", yalnızca hedefe varmak değil, oraya güvenle ulaşmaktır."
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pb_kroki",
        "tur": "kelime",
        "yazim": "kroki",
        "anlam": "Bir yerin yolunu göstermek için elle çizilen basit harita.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pb_olcek",
        "tur": "kelime",
        "yazim": "ölçek",
        "anlam": "Haritadaki yerlerin gerçekte ne kadar küçültülerek çizildiğini gösteren oran.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pb_guzergah",
        "tur": "kelime",
        "yazim": "güzergâh",
        "anlam": "Bir yere giderken izlenen yol.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
    "yuvalar": [
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
      }
    ]
  }
}$p28$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr030-ormanin-kaybolan-patikasi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p29${
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
        "simge_sayisi": 15
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
          "v": "Kent müzesinin en sessiz salonundan aniden ince bir ses"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " yükseldi: bip, bip, bip! Ziyaretçiler durdu. Cam vitrindeki tarihî pusula"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " yerli yerindeydi; kimse ona yaklaşmıyordu. Rehber, çocukları güvenli bekleme alanına götürdü. Görevli alarmı kontrol etmeye geldiğinde ses kesildi. "
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
          "v": ". “Bilmiyoruz,” dedi arkadaşı "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Önce ne olduğunu anlamalıyız.” Bir süre sonra ses"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " yeniden duyuldu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " defterine saati yazdı. "
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
          "v": ",” diyerek defterine soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " işareti koydu. Rehbere gözlemini aktardı."
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
          "v": " başka bir olasılık sundu: “Belki alarmı bir telefon sesi tetiklemiştir.” Rehber böyle bir tahmini de not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " etti; hemen doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " ya da yanlış diye işaretlemedi. "
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
          "v": "Teknik görevli salonun boşaltıldığı güvenli bir anda sistemi denetledi. Vitrinin yakınındaki bir algılayıcının, havalandırmanın oluşturduğu değişime gereğinden fazla duyarlı ayarlandığını belirledi. Yetkili ekip ayarı düzenledi ve alarmı birkaç kez denedi. Artık gereksiz ses"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " duyulmuyordu. "
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
          "v": "Salon yeniden açılmadan önce rehber, ziyaretçilerin neler olduğunu merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " ettiğini gördü. Kısa ve sakin bir açıklama yaptı: “Bir koruma sisteminin gereğinden duyarlı ayarı düzeltildi; eserlerimiz güvende.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu açıklamayı beğendi. Hem doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " bilgi veriyor hem de kesinleşmemiş bir suçlama içermiyordu. "
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
          "v": "Gezi devam ettiğinde rehber çocuklara tarihî pusulanın eski yolculuklarda yön bulmaya yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " ettiğini anlattı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " pusulayı izlerken ilginç bir benzerlik fark etti: “Eskiden insanlar yolda kaybolmamak için pusula"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " kullanıyordu; şimdi de eserleri kaybetmemek için sensör kullanıyoruz.” Sınıfın dönüş otobüsünde herkes en sevdiği eseri söyledi. "
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
          "v": ". “Bir ses"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " bizi korkutmuştu,” dedi, “ama ne olduğunu anlamak için acele hüküm vermemek gerekiyormuş.”"
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pb_sensor",
        "tur": "kelime",
        "yazim": "sensör",
        "anlam": "Hareket, sıcaklık ya da ışık gibi değişimleri algılayan küçük cihaz.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pb_kanit",
        "tur": "kelime",
        "yazim": "kanıt",
        "anlam": "Bir düşüncenin doğru olduğunu gösteren bilgi ya da belge.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pb_varsayim",
        "tur": "kelime",
        "yazim": "varsayım",
        "anlam": "Henüz kanıtlanmamış, doğru olabileceği düşünülen düşünce.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
    "yuvalar": [
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
      }
    ]
  }
}$p29$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr031-muzede-sessiz-alarm: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p30${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr032-keloglan-ve-akilli-terazi",
    "baslik": "Pazardaki Akıllı Terazi",
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
        "kelime_sayisi": 461,
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
        "simge_sayisi": 13
      }
    },
    "tanitim": "Pazarda terazinin bir kefesi neden aşağıda kalıyor? Kimseyi küçük düşürmeden doğrusu nasıl bulunur?",
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
          "v": ", pazardaki belediye görevlisinden de yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " istedi. Görevli önce terazinin dengeli bir zemine oturup oturmadığını kontrol etti. Ardından standart ağırlıkla bir deneme yaptı. İlk terazinin ayarının bozulduğu ortaya çıktı."
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
          "v": "Görevli, doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " tartımın yalnız alıcıya değil satıcıya da güven"
        },
        {
          "t": "ikon",
          "v": "shield"
        },
        {
          "t": "metin",
          "v": " sağladığını açıkladı. "
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
          "v": "Bir müşteri, “Benim aldığım ürünler için de aynı kontrol yapılacak mı?” diye sordu. Satıcı adlarını ve alışveriş saatlerini not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " ederek geri dönenlerin ölçümünü yeniden yapacağını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " işin burasında kendi payını düşündü: “Bir yanlışlığı görmek yetmez; düzeltilmesine de yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etmek gerekir.” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " onayladı. Güven"
        },
        {
          "t": "ikon",
          "v": "shield"
        },
        {
          "t": "metin",
          "v": ", söylenen güzel sözlerle değil, yapılan doğru işlerle yeniden kuruluyordu."
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
          "v": " doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " ayarlanmış terazide ihtiyacı kadar bulguru aldı. Eve döndüğünde annesi keseyi açıp sordu: “Pazarda neden"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " bu kadar geç kaldın?” “Bulgur aldım, bir de akıl,” dedi "
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
          "v": " koymuştu. Yanına da küçük bir yazı asmıştı: Ölçüde doğruluk, alışverişte güven"
        },
        {
          "t": "ikon",
          "v": "shield"
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
          "v": " bu yazıyı görünce başıyla selam verdi. Satıcı da ona teşekkür etti. Kasabada o gün belki büyük bir hazine"
        },
        {
          "t": "ikon",
          "v": "chest"
        },
        {
          "t": "metin",
          "v": " bulunmamıştı; ama herkesin hakkını koruyan küçük bir adım"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": " atılmıştı. "
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
      "metin": "Çocuğun pazarda araya girip ‘Önce sorunu anlayalım’ demesi neden iyi bir davranıştır?",
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
      "aciklama": "Çocuk sert çıkışmak yerine sakin kalıp sorunu anlamaya çalıştı; böylece kimse küçük düşürülmedi."
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
    "tarih": "2026-10-22"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pb_terazi",
        "tur": "kelime",
        "yazim": "terazi",
        "anlam": "Bir şeyin ağırlığını ölçmek için kullanılan, iki kefeli ya da dijital alet.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pb_denetim",
        "tur": "kelime",
        "yazim": "denetim",
        "anlam": "Bir şeyin doğru ve kurallara uygun olup olmadığına bakma.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pb_olcu",
        "tur": "kelime",
        "yazim": "ölçü",
        "anlam": "Bir şeyin ağırlığını, boyunu ya da miktarını belirleyen değer.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
    "yuvalar": [
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
  }
}$p30$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr032-keloglan-ve-akilli-terazi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p31${
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
        "simge_sayisi": 10
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
          "v": "Kasabanın meydanında o sabah"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " her zamankinden büyük bir telaş vardı. Değirmenci Hasan, yeni değirmeninin açılışı için herkesi yemeğe çağırmıştı. Kapıya rengârenk fenerler asılmış, avluda uzun bir sofra kurulmuştu. Nasreddin Hoca, pazardan dönerken daveti hatırladı. Üzerinde günlük, eski cübbesi vardı. Eve uğramadan avluya girdi. Masaların yanından geçerken kimse ona yer göstermedi. Bir görevli, önündeki tabakları toplamakla meşguldü."
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
          "v": "Avludan ayrılırken yolda eski ayakkabılarıyla koşturan bir çocuk gördü. Çocuğun elinde, değirmenin açılışında şarkı"
        },
        {
          "t": "ikon",
          "v": "music"
        },
        {
          "t": "metin",
          "v": " söyleyecek topluluğun notaları vardı. Sayfalar rüzgârda uçuşunca Hoca eğilip yardımcı oldu. Çocuk, \"Beni kimse fark etmez sanmıştım,\" dedi. Hoca gülümsedi: \"İnsan bazen dikkat edilmediğini hisseder. Ama yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etmek için kimsenin bizi tanıması gerekmez.\" Bu küçük karşılaşma, Hoca'nın aklındaki soruyu daha da büyüttü: Bir davette insanları görünür kılan şey gerçekten neydi?"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sessizce evine gitti. Dolabından işlemeli, temiz kürkünü aldı ve yeniden davete döndü. Bu kez kapıdaki görevli doğruldu. \"Hoş geldiniz efendim! Şöyle buyurun. En güzel yer sizin.\" Hoca, önüne getirilen çorbanın kaşığını kaldırmadı. Kürkünün kolunu kâseye doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " uzatıp, \"Ye kürküm ye!\" dedi. Yan masadaki çocuklardan "
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
          "v": "\"İçemez elbette. Peki sizce neden"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " çorba önce bana değil de kürküme "
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
          "v": " önce cevap vermekte zorlandı. Sabah"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " pazarda taşıdığı sepet ağır olduğu için onu evine kadar götüren komşuyu hatırladı. Komşunun giysileri de eskiydi ama içten davranışı gün boyu "
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
          "v": "\"Biri bana yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " ettiğinde üstündeki giysiyi hiç düşünmüyorum,\" dedi. Efe ise geçen hafta yeni ayakkabıları olduğu için arkadaşının eskileriyle alay ettiğini anımsadı. O an yüzü kızardı. \"Ben de bazen dış görünüşe bakıyorum,\" diye "
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
          "v": " bir süre düşündü. Hasan da konuşmaları duyup yanlarına geldi. Hocanın sabahki gelişini öğrenince görevliyi çağırdı. Onu herkesin önünde azarlamadı; birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " daha iyi bir karşılama düzeni kurabileceklerini söyledi. Çocuklar da kapıda sırayla konukları karşılamayı önerdi. Öğleden sonra küçük bir misafir geldi. Üzerinde yamalı bir yelek, elinde çiçek"
        },
        {
          "t": "ikon",
          "v": "flower"
        },
        {
          "t": "metin",
          "v": " vardı. "
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pc_ikram",
        "tur": "kelime",
        "yazim": "ikram",
        "anlam": "Konuğa yemek, içecek gibi bir şey sunma.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_gosterisli",
        "tur": "kelime",
        "yazim": "gösterişli",
        "anlam": "Dikkat çekecek kadar süslü ve pahalı görünen.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_itiraf",
        "tur": "kelime",
        "yazim": "itiraf",
        "anlam": "Yaptığı bir şeyi ya da düşündüğünü açıkça söyleme.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_ata_parlayan",
        "tur": "atasozu",
        "yazim": "Her parlayan altın değildir",
        "anlam": "Dışarıdan güzel ya da değerli görünen her şey gerçekten değerli olmayabilir.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
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
      }
    ]
  }
}$p31$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr033-ye-kurkum-ye-peki-neden: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p32${
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
        "simge_sayisi": 18
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
          "v": " okul çantası aniden konuştu: \"Günaydın! Çorapların eşleşti. Kahvaltın hazır. Matematik"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " ödevini de yaptım!\" "
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
          "v": " güldü. Fakat okula gidince işler karıştı. Öğretmeni problem çözmesini istediğinde çanta hemen masasından seslendi: \"Cevap kırk sekiz! Açıklaması için bir tuşa basınız!\" Sınıf"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " gülüşmeye başladı. Öğretmen, \""
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", cevabı sen nasıl"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " buldun?\" diye sordu. "
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
          "v": " ona bir kâğıt uzattı. Üzerinde iki farklı yol gösteren bir matematik"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " problemi vardı. \"Çantan çok hızlı,\" dedi "
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
          "v": " düşündü. Akşam çantanın ayarlarını açtı. Ekranda üç seçenek vardı: *Benim yerime yap*, *Birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " yap*, *Yalnızca hatırlat*."
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
          "v": ". Çanta şaşırmış gibi küçük bir ışık yaktı. \"Emin misin? Tek başıma daha kısa sürüyor.\" \"Kısa sürmesi her zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " daha iyi olduğu anlamına gelmez.\" Sabah"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " okula gelirken akıllı çanta, yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " ihtimali olduğunu hatırlattı. "
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
          "v": " bu sözleri aklında tuttu. Ertesi gün çanta matematik"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " problemini okumaya başladı: \"Bir bahçede dört sıra ağaç"
        },
        {
          "t": "ikon",
          "v": "tree"
        },
        {
          "t": "metin",
          "v": " var...\" "
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
          "v": " dört sırayı çizdi, her sıraya altı ağaç"
        },
        {
          "t": "ikon",
          "v": "tree"
        },
        {
          "t": "metin",
          "v": " koydu. Saydı, sonra çarpma işlemini yazdı. \"Yirmi dört!\" diye bağırdı. \"Doğru,\" dedi çanta. \"Aferin... Pardon, tebrik ederim.\" "
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
          "v": ", çantasına yeni bir görev"
        },
        {
          "t": "ikon",
          "v": "quest"
        },
        {
          "t": "metin",
          "v": " verdi: kaybolan defterlerin hangi rafta olduğunu hatırlatmak. Çanta herkese yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etti, fakat kimsenin yerine ödev yapmadı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sergide başka bir çocuk, çantanın her soruya doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " yanıt verdiğini görünce hemen aynısından istemişti. "
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
          "v": ", \"Bugün çantana sen mi yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " ettin, çantan mı sana?\" diye sordu. "
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
          "v": " gülerken çantanın üstüne küçük bir etiket yapıştırdı: *Önce kendim denerim*. Ertesi sabah"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " çanta yalnızca \"Ödev çantanda mı?\" diye sordu. "
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pc_ipucu",
        "tur": "kelime",
        "yazim": "ipucu",
        "anlam": "Bir sorunu çözmeye yardım eden küçük bilgi.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_yontem",
        "tur": "kelime",
        "yazim": "yöntem",
        "anlam": "Bir işi yapmak için izlenen yol.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_danismanlik",
        "tur": "kelime",
        "yazim": "danışmanlık",
        "anlam": "Bir konuda bilgili birinin öneri vererek yol göstermesi.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_ata_emek",
        "tur": "atasozu",
        "yazim": "Emek olmadan yemek olmaz",
        "anlam": "Bir şeyin sonucunu görmek için önce çalışmak gerekir.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
    "yuvalar": [
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
      }
    ]
  }
}$p32$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr034-2040-konusan-okul-cantasi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p33${
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
        "kelime_sayisi": 487,
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
        "simge_sayisi": 20
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
          "v": "Ay"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": " Üssü'ne gidecek ilk özel mektubu yazma hakkını iki kardeş kazanmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", Dünya"
        },
        {
          "t": "ikon",
          "v": "globe"
        },
        {
          "t": "metin",
          "v": "'daki sınıfının resmini çizmiş; Can ise altına yalnızca bir cümle yazmıştı: \"Burada sizi merak eden arkadaşlarınız var.\" Mektup"
        },
        {
          "t": "ikon",
          "v": "scroll"
        },
        {
          "t": "metin",
          "v": " Ay'da çalışan teyzeleri Selin'e gönderilecekti. Yeni posta sistemi önce kâğıdı görüntüye dönüştürüyor, ardından uzaya veri olarak iletiyordu. Teyzeleri Ay Üssü'ndeki yazıcıdan aynı mektubu alacaktı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Posta merkezinde tavandan Dünya"
        },
        {
          "t": "ikon",
          "v": "globe"
        },
        {
          "t": "metin",
          "v": " ve Ay"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": "'ın maketleri sarkıyordu. Can aralarındaki boşluğa baktı. \"Ay şu kadar yakınsa mektup"
        },
        {
          "t": "ikon",
          "v": "scroll"
        },
        {
          "t": "metin",
          "v": " çabucak gider,\" dedi. "
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
          "v": ", mesajın nasıl ilerlediğini daha iyi anlamak"
        },
        {
          "t": "ikon",
          "v": "lightning-idea"
        },
        {
          "t": "metin",
          "v": " için kabloları, anteni ve uydunun görevini çizdi. Her ok bir aşamayı gösteriyordu. Çocuklar, iletişimin yalnızca bir tuşa dokunmaktan ibaret olmadığını fark etmeye başlamıştı. Başlangıçta her şey yolundaydı. Fakat posta merkezinin ekranı birden kırmızıya döndü: *Bağlantı kesildi.*"
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
          "v": " üzülmüştü. Selin teyzesinin doğum gününe yalnızca bir gün kalmıştı. Can bir çözüm"
        },
        {
          "t": "ikon",
          "v": "puzzle"
        },
        {
          "t": "metin",
          "v": " önerdi: \"Mektubu aynı anda başka bir kanaldan göndersek?\" "
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
          "v": "Çocuklar merkezin panosunda çizilmiş küçük bir şemayı inceledi. Bir çizgi Dünya"
        },
        {
          "t": "ikon",
          "v": "globe"
        },
        {
          "t": "metin",
          "v": " istasyonundan yörüngedeki uyduya uzanıyor, ikinci çizgi uydudan Ay"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": " Üssü'ne gidiyordu. "
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
          "v": "Ekrana *İleti ulaştı* yazısı düşünce Can zıpladı. Fakat hemen bir soru"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " sordu: \"Ay"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": "'daki teyze cevap verirse onu anında duyar mıyız?\" "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " başını salladı. \"Hayır, sinyaller ışık hızında ilerlese de Dünya"
        },
        {
          "t": "ikon",
          "v": "globe"
        },
        {
          "t": "metin",
          "v": " ile Ay arasındaki uzaklık yüzünden küçük bir "
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
          "v": " çocuklara gönderimden önce yaptıkları iki kontrolü de anlatmıştı: alıcının kimliği doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " muydu ve mesaj gerçekten bütünüyle gelmiş miydi? Can kendi mektubuna bakıp \"Ya çizimimizin yarısı gitseydi?\" diye sordu. "
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
          "v": " işaretini gösterdi. \"O zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " karşı taraf eksik parçayı isterdi.\" Mesajın güvenli iletimi artık ikisinin de zihninde bir bilmecenin çözümü gibiydi. Eve dönünce mektubun ilk taslağını sakladılar; günün sonunda öğrenilenlerin de bir hatıra olmasını istediler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi akşam evde bir görüntü geldi. Selin teyze, elinde basılmış mektubu tutuyordu. \"Sınıfınızın resmini duvarıma astım,\" dedi. \"Ay"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": "'ın gökyüzünde Dünya"
        },
        {
          "t": "ikon",
          "v": "globe"
        },
        {
          "t": "metin",
          "v": " çok güzel görünüyor. Ama sizin yazdıklarınız daha güzel.\" Can, \"Biz de buradan seni görüyoruz!\" diye seslendi. Cevap hemen gelmedi. İki kardeş gülümseyerek bekledi. Can fısıldadı: \""
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
          "v": ", postanın yalnızca zarf ve pul olmadığını anladı. Bazen sevgi"
        },
        {
          "t": "ikon",
          "v": "heart"
        },
        {
          "t": "metin",
          "v": " bir kâğıtta, bazen de uzaklara giden küçük veri parçalarında yolculuk ediyordu. Yine de en önemli şey, karşıdaki insanı hatırlamaktı. Can ertesi gün sınıfta öğrendiklerini arkadaşlarına anlattı. Sınıfça bir mesaj göndermeden önce adını, alıcısını ve içeriğini kontrol etmeye karar verdiler. Çünkü uzaklık ne kadar büyük olursa olsun, dikkatli iletişim küçük ama önemli adımlarla başlıyordu. "
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pc_gecikme",
        "tur": "kelime",
        "yazim": "gecikme",
        "anlam": "Bir şeyin beklenenden geç olması.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_uydu",
        "tur": "kelime",
        "yazim": "uydu",
        "anlam": "Dünya'nın çevresinde dönen ve haberleşme gibi işler için uzaya gönderilen araç.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_dogrulama",
        "tur": "kelime",
        "yazim": "doğrulama",
        "anlam": "Bir şeyin doğru olduğunu kontrol edip onaylama.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_ata_sabreden",
        "tur": "atasozu",
        "yazim": "Sabreden derviş muradına ermiş",
        "anlam": "Sabırla bekleyen kişi, istediğine sonunda ulaşır.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
    "yuvalar": [
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
      }
    ]
  }
}$p33$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr035-aya-giden-ilk-posta: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p34${
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
        "kelime_sayisi": 468,
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
        "simge_sayisi": 25
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
          "v": " kasabasındaki eski taş köprü"
        },
        {
          "t": "ikon",
          "v": "bridge"
        },
        {
          "t": "metin",
          "v": " her akşam yedi farklı renkte parlardı. Kasabalılar bu ışığın nereden geldiğini bilmiyordu. Köprünün başında yaşayan bekçi ise yalnızca şunu söylerdi: \"Renkler"
        },
        {
          "t": "ikon",
          "v": "rainbow"
        },
        {
          "t": "metin",
          "v": ", insanların unuttuğu duyguları hatırlatır.\" O gece"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": " "
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
          "v": "Uyandığında bunların hepsinin kendi duyguları olduğunu hatırladı. Yine de korku"
        },
        {
          "t": "ikon",
          "v": "fear"
        },
        {
          "t": "metin",
          "v": " taşına gelince rüyadaki ses kesilmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun nedenini merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " etti. Birkaç gün sonra köprünün mor ışığı kayboldu. Ardından sarı, mavi ve yeşil ışıklar da sönükleşti. Nehrin karşı kıyısındaki çocukların okula gitmesi zorlaştı; sis çöktüğünde köprü"
        },
        {
          "t": "ikon",
          "v": "bridge"
        },
        {
          "t": "metin",
          "v": " neredeyse görünmez oluyordu."
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
          "v": " çözüm bulmak için bekçiye koştu. Bekçi ona yedi taş gösterdi: sevinç"
        },
        {
          "t": "ikon",
          "v": "joy"
        },
        {
          "t": "metin",
          "v": ", üzüntü, öfke, şaşkınlık, sevgi"
        },
        {
          "t": "ikon",
          "v": "heart"
        },
        {
          "t": "metin",
          "v": ", umut ve korku"
        },
        {
          "t": "ikon",
          "v": "fear"
        },
        {
          "t": "metin",
          "v": ". \"Korku taşının rengi solmuş,\" dedi bekçi. \"Onu yeniden parlatacak olan, korkmadığını söyleyen değil, korkusunu tanıyandır.\" "
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
          "v": " kalbi hızlandı. Aslında yükseklikten korkuyordu. Köprü"
        },
        {
          "t": "ikon",
          "v": "bridge"
        },
        {
          "t": "metin",
          "v": " güvenliydi ama aşağıdaki suyu görünce elleri terliyordu. Yıllardır bu korkusunu arkadaşlarından saklamıştı. Bekçi acele etmedi. \"Korkmak utanılacak bir şey değil,\" dedi. \"Bir şeyi nasıl"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " güvenle yapacağını düşünmene yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " edebilir.\""
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
          "v": " derin bir nefes aldı. \"Evet, yüksekten korkuyorum,\" dedi. \"Ama kardeşimin yanına da gitmek istiyorum.\" Bekçiyle birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " korkulukları kontrol ettiler. Sis hafifleyene kadar beklediler. Sonra "
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
          "v": "O anda köprünün mor taşı parladı. Ardından diğer renkler"
        },
        {
          "t": "ikon",
          "v": "rainbow"
        },
        {
          "t": "metin",
          "v": " de usulca yerine döndü. "
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
          "v": " korkmamak değilmiş,\" dedi. Bekçi gülümsedi. \"Cesaret"
        },
        {
          "t": "ikon",
          "v": "courage"
        },
        {
          "t": "metin",
          "v": " bazen yardım istemektir. Bazen de tehlikeyi fark edip doğru zamanı beklemek"
        },
        {
          "t": "ikon",
          "v": "hourglass"
        },
        {
          "t": "metin",
          "v": ".\" Mert akşam "
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
          "v": " anladı ki cesaret"
        },
        {
          "t": "ikon",
          "v": "courage"
        },
        {
          "t": "metin",
          "v": " gösteren yalnızca kendisi değildi; güvenli biçimde beklemek"
        },
        {
          "t": "ikon",
          "v": "patience"
        },
        {
          "t": "ikon",
          "v": "hourglass"
        },
        {
          "t": "metin",
          "v": " de bazen cesur bir karardı. Ertesi gün "
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
          "v": "\" Köprü"
        },
        {
          "t": "ikon",
          "v": "bridge"
        },
        {
          "t": "metin",
          "v": " o gece"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": " yine yedi renkte parladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ne zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " mor ışığı görse kendine aynı cümleyi hatırlattı: \"Korkumu adlandırınca onu daha iyi anlayabiliyorum.\""
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
          "v": " sınıf"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " önünde şiir okumak"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " için çekindi. "
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pc_cesaret",
        "tur": "kelime",
        "yazim": "cesaret",
        "anlam": "Korkulan bir durumda bile doğru olanı yapabilme gücü.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_destek",
        "tur": "kelime",
        "yazim": "destek",
        "anlam": "Birine yardım ederek ona güç verme.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_prova",
        "tur": "kelime",
        "yazim": "prova",
        "anlam": "Bir işi başkalarının karşısında yapmadan önce deneme.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_ata_el",
        "tur": "atasozu",
        "yazim": "Bir elin nesi var iki elin sesi var",
        "anlam": "İnsanlar işi birlikte yapınca daha güçlü ve başarılı olur.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
    "yuvalar": [
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
      }
    ]
  }
}$p34$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr036-yedi-renkli-koprunun-koruyucusu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p35${
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
        "kelime_sayisi": 504,
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
        "simge_sayisi": 13
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
          "v": "Okullar arası futbol"
        },
        {
          "t": "ikon",
          "v": "ball"
        },
        {
          "t": "metin",
          "v": " turnuvasının son maçı başlamadan önce "
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
          "v": ", \"Hep birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " oynarsak kazanabiliriz,\" dedi. "
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
          "v": ", bahçede tek başına şut çalışmıştı. Her golün ardından ellerini havaya kaldırıyor, hayalinde arkadaşlarının kendisini alkışladığını görüyordu. Babası kenardan seslenmişti: \"Futbol"
        },
        {
          "t": "ikon",
          "v": "ball"
        },
        {
          "t": "metin",
          "v": " tek kişinin oynadığı bir oyun değil.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Biliyorum,\" demiş ama nedenini tam düşünmemişti. Şimdi tribüne bakarken bu konuşma"
        },
        {
          "t": "ikon",
          "v": "speech"
        },
        {
          "t": "metin",
          "v": " aklına geldi. Kazanmak istiyordu; bir yandan da arkadaşlarının kendisine güvenmesini. Fakat yalnızca kendi golünü düşünürse onların güvenini nasıl"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " kazanacaktı?"
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
          "v": " tahtasını açtı. \"Şut çekmek cesaret"
        },
        {
          "t": "ikon",
          "v": "courage"
        },
        {
          "t": "metin",
          "v": " ister,\" dedi, \"ama iyi bir oyuncu sahadaki arkadaşlarını da görür.\" "
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
          "v": "Öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": ", tahta üzerinde üç küçük nokta çizerek topun gidebileceği yolları göstermişti. Bir çizgi doğrudan kaleye gidiyordu ama önünde iki savunmacı vardı. Diğer çizgi, boş alandaki arkadaşına uzanıyordu. \"İyi karar vermek, seçeneği görmekle başlar,\" demişti. "
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
          "v": " golü attı. Skor eşitlendi. Son bir dakika"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " kalmıştı. Rakip takımın savunması "
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
          "v": " ayağını çevirdi, topu Emre'ye gönderdi. Emre düzgün bir vuruşla golü attı. Hakemin son düdüğüyle çocuklar sevinç"
        },
        {
          "t": "ikon",
          "v": "joy"
        },
        {
          "t": "metin",
          "v": " içinde birbirlerine sarıldı. Takım kupayı alırken Emre, \"Golü ben attım ama fırsatı sen hazırladın,\" dedi. "
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
          "v": " onun elini sıktı. \"Sen de zor şutları kurtardın,\" diye karşılık verdi. Öğretmen"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": ", kazanmanın rakibe saygıyı azaltmaması gerektiğini hatırlattı. Çocuklar kupayı sırayla tutarak fotoğraf çektirdiler. Emre ilk fotoğrafta kenarda kalmıştı. "
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
          "v": " ona bir fotoğraf gösterdi. Karede bütün takım aynı anda zıplıyordu. Hiç kimsenin yüzünde kimin gol attığına dair bir hesap"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " yoktu. Öğretmenleri, \"İşte takım olmak bu,\" dedi. \"Bir kişinin parlaması değil, herkesin birbirinin ışığını artırması. Atalarımız boşuna söylememiş: "
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
          "v": " fotoğrafı çantasına koydu. Eve giderken bir şeyi daha düşündü: Arkadaşını görebilmek için bazen topa değil, bütün sahaya bakmak gerekiyordu. Bu yalnızca futbolda değil, birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " yapılan her işte önemliydi."
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pc_pas",
        "tur": "kelime",
        "yazim": "pas",
        "anlam": "Futbol gibi oyunlarda topu takım arkadaşına gönderme.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_taktik",
        "tur": "kelime",
        "yazim": "taktik",
        "anlam": "Bir oyunu ya da işi kazanmak için önceden yapılan plan.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_savunma",
        "tur": "kelime",
        "yazim": "savunma",
        "anlam": "Rakibin gol atmasını engellemeye çalışan oyuncular ya da bu çaba.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_ata_birlik",
        "tur": "atasozu",
        "yazim": "Birlikten kuvvet doğar",
        "anlam": "Birlikte çalışan insanlar tek başına olduklarından daha güçlü olur.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
    "yuvalar": [
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
      }
    ]
  }
}$p35$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr037-son-pasin-hikayesi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p36${
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
        "kelime_sayisi": 522,
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
        "simge_sayisi": 19
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
          "v": "Büyükanne Zeliha, eski ceviz sandığını açtığında içinden avuç içi kadar bir müzik"
        },
        {
          "t": "ikon",
          "v": "music"
        },
        {
          "t": "metin",
          "v": " kutusu çıktı. Kapağındaki küçük kuşun kanadı kırılmıştı; altındaki kilit"
        },
        {
          "t": "ikon",
          "v": "lock"
        },
        {
          "t": "metin",
          "v": " ise anahtarsızdı. \"Bu kutu eskiden şarkı söylerdi,\" dedi Zeliha. \"Ama nasıl açıldığını unuttum.\" Torunları "
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
          "v": " daha önce okulun müzik"
        },
        {
          "t": "ikon",
          "v": "music"
        },
        {
          "t": "metin",
          "v": " dersinde seslerin yüksekliğiyle süresinin aynı şey olmadığını öğrenmişti. İnce ve kalın sesler bir özelliği, kısa ve uzun süreler başka bir özelliği anlatıyordu. Aras, \"Ben en yüksek sesi bulmamız gerektiğini sanmıştım,\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", \"Belki notalar doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " ama çalma biçimimiz yanlış,\" diye cevap verdi. Bu yüzden acele etmek yerine duyduklarını küçük işaretlerle yazmaya karar verdiler. Zeliha gülümseyerek, \""
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
          "v": ", kapağın kenarındaki işaretleri gösterdi: iki kısa çizgi, bir uzun çizgi ve küçük bir nokta. \"Bunlar seslerin süresini anlatıyor olabilir,\" dedi. Çocuklar masaya dört renkli kâğıt koydu. Her notaya bir renk verdiler ve duydukları sesleri sırayla yazdılar. İlk deneme başarısızdı. İkinci denemede müzik"
        },
        {
          "t": "ikon",
          "v": "music"
        },
        {
          "t": "metin",
          "v": " kutusu dört nota çaldı ama yine kapalı kaldı. \"Belki sırayı doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": ", ritmi yanlış çalıyoruz,\" diye düşündü "
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
          "v": "Büyükanne pencerenin yanından eski bir fotoğraf getirdi. Fotoğrafta küçük Zeliha, bir arkadaşıyla birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " piyano başındaydı. Kenarına şu cümle yazılmıştı: *Önce iki kısa, sonra bir uzun. Sonunda hep birlikte sus.* Aras heyecanlandı. \"Sonunda bir ses"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " daha yok. Bir "
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
          "v": " notaları doğru sırayla çaldı; son düğmeden sonra bir an bekledi. Kapağın içinden yumuşak bir çıtırtı duyuldu. Kilit"
        },
        {
          "t": "ikon",
          "v": "lock"
        },
        {
          "t": "metin",
          "v": " açılmıştı. "
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
          "v": "Aras, kapağı açmadan hemen önce bir kez daha durdu. \"Büyükanne, ya içindeki şey kırılacak kadar hassassa?\" diye sordu. Zeliha bir bez getirdi ve masanın üzerine serdi. Çocuklar kutuyu onun üstüne koyup kapağını yavaşça kaldırdılar. Sır çözmek"
        },
        {
          "t": "ikon",
          "v": "lightning-idea"
        },
        {
          "t": "metin",
          "v": " onları heyecanlandırıyordu fakat eski eşyalara dikkatle davranmak da önemliydi. Sonradan fark ettiler ki kapakta küçük bir çizik vardı; onu zorlayarak açmaya kalksalardı hatıraya zarar verebilirlerdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kutunun içinde altın ya da mücevher yoktu. Küçük bir kart, sararmış bir fotoğraf ve sarı kurdeleli bir mektup"
        },
        {
          "t": "ikon",
          "v": "scroll"
        },
        {
          "t": "metin",
          "v": " vardı. Mektupta, Zeliha'nın çocukluk arkadaşının uzak bir kente taşınmadan önce bu melodiyi armağan"
        },
        {
          "t": "ikon",
          "v": "gift"
        },
        {
          "t": "metin",
          "v": " ettiği yazıyordu. \"Çocukken birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " oyun oynardık,\" diye anlattı Zeliha. \"Bir gün bu küçük melodiyi her buluşmamızda çalmaya söz verdik. Sonra taşındılar. Aradan yıllar geçti ama bir melodiyi duyunca sanki arkadaşım yanımdaymış gibi olur.\""
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
          "v": ", müziğin yalnızca notalardan oluşmadığını düşündü. Bir şarkı, insanın belleğinde uzak bir güne açılan kapı da olabilirdi. Aras ise fotoğraftaki iki çocuğun yüzlerini dikkatle inceledi; şimdi büyükannesi olan küçük kızın gülüşünü hemen tanıdı. Büyükanne mektubu okuyunca gözleri doldu. \"Bu melodiyi birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " bestelemiştik,\" dedi. \"Yıllardır nerede sakladığımı düşünürdüm.\" "
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
          "v": " de sessizce dinledi. O akşam aile"
        },
        {
          "t": "ikon",
          "v": "house"
        },
        {
          "t": "metin",
          "v": " albümünden başka fotoğraflar çıkardılar. Aras her fotoğrafın arkasına kimlerin bulunduğunu yazmayı önerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise büyükanneye anılarını kaydedecek küçük bir defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " "
        },
        {
          "t": "kelime",
          "yuva": "pc_armagan"
        },
        {
          "t": "metin",
          "v": " etti. Çünkü bir gün başkalarının da bu hikâyeleri öğrenmesini istiyorlardı. Müzik"
        },
        {
          "t": "ikon",
          "v": "music"
        },
        {
          "t": "metin",
          "v": " kutusunun kanadı hâlâ kırıktı. Ama artık onun için önemli olan kusursuz görünüşü değil, içinde sakladığı seslerdi. "
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pc_nota",
        "tur": "kelime",
        "yazim": "nota",
        "anlam": "Müzikte bir sesi göstermek için kullanılan işaret ya da o ses.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_duraklama",
        "tur": "kelime",
        "yazim": "duraklama",
        "anlam": "Bir işin ya da sesin kısa bir süre durması.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_armagan",
        "tur": "kelime",
        "yazim": "armağan",
        "anlam": "Sevgi ya da saygı göstermek için birine verilen hediye.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_ata_acele",
        "tur": "atasozu",
        "yazim": "Acele işe şeytan karışır",
        "anlam": "Aceleyle yapılan işte hata yapma olasılığı artar.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
    "yuvalar": [
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
      }
    ]
  }
}$p36$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr038-muzik-kutusunun-sifresi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p37${
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
        "kelime_sayisi": 498,
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
        "simge_sayisi": 19
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
          "v": ", tepelerin ardındaki ormanda altın gibi parlayan bir tüy"
        },
        {
          "t": "ikon",
          "v": "feather"
        },
        {
          "t": "metin",
          "v": " buldu. Tüy rüzgârda savrulmuyor, sanki kendi yolunu seçiyordu. "
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
          "v": " de tüye merakla baktı. Sesin nereden geldiğini anlamadılar. Tam o sırada gökyüzünde kocaman bir gölge belirdi. Yaşlı orman"
        },
        {
          "t": "ikon",
          "v": "forest"
        },
        {
          "t": "ikon",
          "v": "tree"
        },
        {
          "t": "metin",
          "v": " bekçisi gülümseyerek, \"Anka kuşunun tüyü olabilir,\" dedi. \"O, masalların uzak dağlarında yaşayan "
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
          "v": " şaşırdı. \"Masaldaki kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " neden burada?\" Bekçi, \"Belki birine yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " ediyordur,\" diye cevap verdi. Patika ikiye ayrıldığında "
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
          "v": " ilk kez bir macerada en hızlı yolun her zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " doğru yol olmadığını düşündü."
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
          "v": ", tüyün parıltısını izleyerek yürümeye başladı. Yoldaki ağaçların arasında minik kuşlar uçuşuyordu. Bir çalıya takılmış yuvayı görünce durdu. Yuvada iki yavru vardı, anne kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " ise korkuyla ötüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yuvaya dokunmadı; orman"
        },
        {
          "t": "ikon",
          "v": "forest"
        },
        {
          "t": "ikon",
          "v": "tree"
        },
        {
          "t": "metin",
          "v": " bekçisini çağırdı. Bekçi yuvanın güvenli biçimde korunması için gerekli adımları attı. "
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
          "v": "Tüy o sırada daha parlak oldu. Sonra kuzeye doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " hafifçe uzandı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ile bekçi, ormandaki işaretli patikadan yürüdü. Büyük bir ağacın tepesinde göçmen kuşların toplandığını gördüler. \"Bu kuşlar neden"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " bu kadar kalabalık?\" diye sordu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". \"Yılın belli zamanlarında daha uygun iklim ve besin bulmak"
        },
        {
          "t": "ikon",
          "v": "idea"
        },
        {
          "t": "metin",
          "v": " için "
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
          "v": " tüyü yukarı kaldırdı. \"Ben yalnızca geri götürmek istedim.\" \"Yolda başka canlıları da gözetmişsin,\" dedi Anka. \"Gerçek yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " bazen birine kanat germektir.\""
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
          "v": " başını sallamıştı. \"Göç eden kuşlara yol, bana yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etmenin anlamını gösterdi.\""
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
          "v": " akşam defterine gördüklerini yazdı. Gerçek dünyada kuşların göç ederken güneşten, yıldızlardan ve Dünya"
        },
        {
          "t": "ikon",
          "v": "globe"
        },
        {
          "t": "metin",
          "v": "'nın manyetik alanından yararlanabildiğini öğrenince daha da meraklandı. Masalın büyüsü onu bilimsel bir soruya götürmüştü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "O gece"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": " annesine tüyün sesini anlattı. Annesi inanıp inanmamak yerine, \"Bu deneyim sende hangi soruları uyandırdı?\" diye sordu. "
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
          "v": "\" Ertesi hafta sınıflarıyla kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " "
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pc_goc",
        "tur": "kelime",
        "yazim": "göç",
        "anlam": "Canlıların daha uygun yaşam koşulları için bir yerden başka bir yere gitmesi.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_efsanevi",
        "tur": "kelime",
        "yazim": "efsanevi",
        "anlam": "Efsanelerde anlatılan, gerçek olmayan ya da çok eski masallara ait olan.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_gozlem",
        "tur": "kelime",
        "yazim": "gözlem",
        "anlam": "Bir şeyi dikkatle bakarak inceleme.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_ata_sormak",
        "tur": "atasozu",
        "yazim": "Sormakla yol bulunur",
        "anlam": "Bilmediğin bir şeyi sorarsan çözümü bulabilirsin.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
    "yuvalar": [
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
      }
    ]
  }
}$p37$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr039-ankanin-kaybolan-tuyu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p38${
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
        "simge_sayisi": 13
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
          "v": " ilk uzun tren yolculuğuna çıkacağı sabah erkenden uyandı. Annesiyle birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " üç şehirde duracak, her durakta farklı bir aile"
        },
        {
          "t": "ikon",
          "v": "house"
        },
        {
          "t": "metin",
          "v": " dostunu ziyaret edeceklerdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da yolculukta not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " tutmaya hazırdı. "
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
          "v": " böylece pencerenin dışındaki manzarayla kâğıttaki çizgiler arasında bağlantı kurabilecekti. Aklında bir oyun da vardı: Her şehirden duyduğu yeni bir kelimeyi not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " edecek, sonra benzerlerini arayacaktı. "
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
          "v": " Tren"
        },
        {
          "t": "ikon",
          "v": "train"
        },
        {
          "t": "metin",
          "v": " hareket edince pencereden tarlalar, dereler ve küçük istasyonlar akmaya başladı. İlk "
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
          "v": " aynı nesnenin farklı yerlerde bazen farklı adlarla anılmasına şaşırdı. \"Demek kelimeler de yolculuk ediyor,\" dedi. Annesi, \"Evet, insanlarla birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " taşınıyor ve değişiyor,\" diye cevap verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterinde sözcüklere yeni bir sayfa"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " ayırdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkinci gün Konya'ya vardılar. Mehmet amca onları tarihi bir sokakta gezdirdi. Taş binaları, eski kapıları ve avluları gösterdi. Öğle yemeğinde etli ekmek"
        },
        {
          "t": "ikon",
          "v": "seed"
        },
        {
          "t": "metin",
          "v": " vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu kez yemeğin yanında anlatılan aile"
        },
        {
          "t": "ikon",
          "v": "house"
        },
        {
          "t": "metin",
          "v": " hikâyeleriyle de ilgilendi. Mehmet amca, \"Eskiden akşam yemekleri ailece uzun sürerdi,\" dedi. \"Herkes gününü anlatırdı.\" "
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
          "v": " tezgâhlardaki ürünlerin adlarını not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " etti. Bir dükkânda bakır işleyen ustayı izledi. \"Bu desenleri yapmayı kim öğretti?\" diye sordu. Usta, \"Önce babamdan öğrendim, sonra kendi desenlerimi geliştirdim,\" dedi. \"Her yeni usta eski bilgiyi başka biçimde sürdürür.\""
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
          "v": " haritanın kenarına küçük bir tren"
        },
        {
          "t": "ikon",
          "v": "train"
        },
        {
          "t": "metin",
          "v": " çizdi. Haritanın altına da tek bir cümle yazdı: *Farklılıkları öğrenmek, birbirimize yaklaşmanın başka bir yolu.* "
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pc_yoresel",
        "tur": "kelime",
        "yazim": "yöresel",
        "anlam": "Yalnızca belli bir yöreye ait olan.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_miras",
        "tur": "kelime",
        "yazim": "miras",
        "anlam": "Geçmişten bugüne kalan değerli bilgi, eşya ya da gelenekler.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_durak",
        "tur": "kelime",
        "yazim": "durak",
        "anlam": "Bir aracın yolculuk sırasında durduğu yer.",
        "sinif_alt": 4,
        "sinif_ust": 4
      },
      {
        "id": "pc_ata_misafir",
        "tur": "atasozu",
        "yazim": "Misafir kısmetiyle gelir",
        "anlam": "Eve gelen konuk, kendi nasibiyle gelir; ağırlamak bereket getirir.",
        "sinif_alt": 4,
        "sinif_ust": 4
      }
    ],
    "yuvalar": [
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
  }
}$p38$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr040-trenin-penceresindeki-turkiye: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p39${
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
        "kelime_sayisi": 3085,
        "tahmini_sure_dk": 27,
        "sayfa_sayisi": 35,
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
        "simge_sayisi": 71
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
          "v": "Altıncı sınıfların doğa kampı, Karadeniz kıyısındaki Çamlıburun Araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " Merkezi'nde yapılıyordu. Kamp merkezine vardıklarında girişte bir fotoğraf sergisi açılmıştı. Bir fotoğrafta deniz"
        },
        {
          "t": "ikon",
          "v": "wave"
        },
        {
          "t": "metin",
          "v": ", neredeyse kıyıdaki taşa kadar uzanıyor; başka birinde aynı taş geniş bir kumluğun ortasında kalıyordu. "
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
          "v": " Kampın ilk akşamı, rehberleri Suna Hanım çocuklara bir harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " gösterdi. Haritada patikalar, gözlem noktaları, dere yatakları ve koruma sınırları vardı. Ancak haritanın bir köşesi öyle çok silinmişti ki koyun ortasındaki küçük kara parçası bir ada gibi görünüyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Burası Kayıp Ada mı?” diye sordu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Kamp başlamadan önce internette gördüğü bir paylaşımda, bölgedeki kayıp adaya ait olduğu söylenen eski bir hazine haritası vardı. Suna Hanım gülümsedi. “Haritalar bazen yanlış sorular sormamıza neden olur. Bu gördüğünüz çizimde suyun nerede başladığını bile kesin bilmiyoruz. Önce güvenilir bilgiyi bulmalıyız.” Sınıfın gözlem ekibinde dört arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " vardı: haritalara meraklı Selin, sabırsız ama cesur "
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
          "v": " ve gördüklerini deftere geçirmeyi seven Asya. Birlikte çalışacaklardı. Her grubun görevi, merkezdeki eski haritayı güncel haritayla karşılaştırmak ve gözlem izinleri verilen noktalara ilişkin bir rapor hazırlamaktı. Selin, eski haritanın altındaki notu fark etti: “Yedi adım"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": ", tek yol; suyun anlattığına kulak ver.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir köşede çok küçük bir tarih yazıyordu. "
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
          "v": " ise tarihe bakıp “Bu harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " kırk yıl önce çizilmiş. Kıyı aynı kalmış olabilir mi?” dedi. Suna Hanım onlara cevap vermek yerine yeni bir soru sordu: “Bir haritanın yaşı neden önemlidir?” Çocuklar denizlerin, rüzgârın ve akarsuların kıyıları zamanla değiştirebildiğini hatırladılar. Gruptaki herkes farklı bir "
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
          "v": " eski bir geçit"
        },
        {
          "t": "ikon",
          "v": "bridge"
        },
        {
          "t": "metin",
          "v": " bulunacağını, Asya unutulmuş bir iskele kalıntısı görüleceğini, Selin ada diye çizilen yerin belki de sazlık olduğunu düşündü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise kuşların oraya neden toplandığını öğrenmek istiyordu. Kamptaki ilk görev"
        },
        {
          "t": "ikon",
          "v": "quest"
        },
        {
          "t": "metin",
          "v": " aslında eski bir fotoğrafla başlamıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Fotoğrafta aynı tepe"
        },
        {
          "t": "ikon",
          "v": "mountain"
        },
        {
          "t": "metin",
          "v": ", aynı gökyüzü"
        },
        {
          "t": "ikon",
          "v": "cloud"
        },
        {
          "t": "metin",
          "v": " ve birbirinden farklı iki su çizgisi vardı. Selin ikisinin aynı yer olduğunu söylemiş, "
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
          "v": " ağzı açık kaldı. “Bir yer nasıl böyle değişebilir?” diye sordu. Rehber, akarsuların taşıdığı malzemeden ve dalgaların kıyıda yaptığı değişikliklerden söz etti. Asya bu açıklamayı defterine not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " etti ama öğretmeni ona önemli bir ayrımı hatırlattı: “Bu genel bilgi. Bizim burada tam olarak ne olduğunu anlamak için gözlem yapmalıyız.” "
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
          "v": "Akşam çadırlarına dönmeden önce rapor defterlerinin ilk sayfasına bir kural yazdılar: “Varsayım kanıt değildir.” Altına ikinci bir kural eklediler: “İzinli güzergâhın dışına çıkılmayacak.” Böylece maceranın ilk adımı, bir gizem kadar bir sorumluluk da taşıyordu. Ertesi sabah Suna Hanım, ekipleri gözlem alanına götürdü. Önce herkes haritanın yönünü pusulaya göre ayarladı. Selin kâğıdı o kadar dikkatli çevirdi ki kuzey"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " oku gerçek yönü gösterdiğinde bir an durup gülümsedi. Daha önce yönleri yalnızca ders kitabında çizilmiş oklar olarak görmüştü; şimdi rüzgârın yönü, denizin konumu ve tepenin gölgesiyle ilişkilendiriyordu."
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
          "v": ", “Kâğıttan bakınca patika çok kısa,” dedi. “Şuradan yürürsek beş dakikada ulaşırız.” Suna Hanım onu durdurdu. Haritanın altındaki "
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
          "v": " önerdiği kestirme ise sulak alanın sınırından geçiyordu. “Kestirme orası olsa bile kullanamayız,” dedi Asya. “Hem kuşların yuvalama alanı hem de geçiş yasak.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kaşlarını kaldırdı. “Ben sadece daha çabuk varmak istemiştim.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Hızlı gitmek, doğru gitmek demek değil,” diye karşılık verdi "
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
          "v": ".” Yol ayrımındaki levha yeni boyanmıştı. Ancak hemen arkasındaki eski taşın üzerinde silinmiş kırmızı bir işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bunun haritadaki simgelerden biri olduğunu düşündü. Suna Hanım, işaretin geçmişte kullanılmış yürüyüş rotasına ait olabileceğini söyledi. Öğrenciler levhanın fotoğrafını çektiler ve yeni rotayla eski işareti karşılaştırdılar. Selin defterine “Bir işaretin anlamı zamanla değişebilir” yazdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Asya aynı sözün yalnızca haritalar için değil, günlük hayatta duydukları bazı sözcükler için de geçerli olabileceğini fark etti. Örneğin “ada” kelimesi, çevresi tamamen suyla kuşatılan yeri anlatıyordu; eski haritadaki şeklin bu tanıma hâlâ uyup uymadığı bilinmiyordu. Patikada ilerlerken taşların arasında beyaz, yassı kabuklar gördüler. Suna Hanım bunların bazılarını toplayıp incelemelerine izin vermedi; koruma alanında canlı veya cansız doğal malzemelerin yerinde bırakılması gerektiğini açıkladı. Bunun yerine çocuklar fotoğraf çekti, konum işaretledi ve çizim yaptı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Haritadaki birinci işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": ", eski bir ahşap gözlem platformuydu. Gözlem kulesinin tahtaları yenilenmiş, yanına bilgilendirici levhalar konmuştu. Levhada kıyıya vuran kumun yıl içinde yer değiştirebildiği anlatılıyordu. Selin, haritanın kenarına bir not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " düştü: “Kıyı çizgisi sabit değildir.” İkinci işaret küçük bir tatlı su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " gözlem kuyusuydu. Kuyuya dokunmadılar; rehberleri, ölçüm cihazıyla tuzluluk ve su seviyesi hakkında bilgi verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " birden anladı: “Belki haritadaki çizgi denizin değil, suyun değiştiği bir yerin işareti.” Suna Hanım, “Bunu söylemek için artık bir gerekçen var,” dedi. “Ama tek kanıtla karar vermeyelim.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğleden sonra rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " hafifledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kayıt cihazını çıkarıp ötüşleri dinledi. Sabah duydukları martı seslerinin arasında ince bir ötüş vardı. Rehber, bu kuş türünün göç sırasında sulak alanlarda mola verdiğini anlattı. Öğrenciler, sazlıkların yalnızca su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " ve bitkiden oluşmadığını; göç eden canlılar için beslenme ve dinlenme alanı da olabileceğini öğrendi. Fakat eski haritada adanın bulunduğu yerde tuhaf bir sessizlik vardı. Kuş sesleri uzaktan geliyordu; sazlıkların yakınında ise iri, paslı bir levha duruyordu. Levhada yıllar önce kapanmış bir tekne"
        },
        {
          "t": "ikon",
          "v": "boat"
        },
        {
          "t": "metin",
          "v": " iskelesinin adı yazıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " heyecanlandı. “İşte!"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kayıp Ada'nın iskelesi!” Asya hemen fotoğraf çekti. “Levha eskiden burada bir iskele olduğunu gösteriyor,” dedi. “Ama adaya çıkılabildiğini değil.” "
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
          "v": ", “O zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " gizem bir hazine değil, temizlenmesi gereken bir yer olabilir,” dedi. Gözlem platformunda öğle yemeği molası verdiler. Selin defterine üç sütun çizdi: “Gördüklerimiz, düşündüklerimiz, hâlâ bilmediklerimiz.” Gördüklerine eski iskele levhasını, ölçüm kuyusunu ve değişen kıyı çizgisini yazdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Düşündüklerine ise “Ada sanılan yer eski bir kum seti olabilir” notunu ekledi. Son sütunda üç soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " vardı: Bu kum seti şimdi neredeydi? Kuşlar neden burada dinleniyordu? Haritada neden yedi işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " bulunuyordu? "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " son soruya takıldı. “Yedinci işaret bir sandığı gösteriyor olabilir.” Asya gözlerini devirdi. “Her şeyi sandığa bağlama.” “Belki sandık"
        },
        {
          "t": "ikon",
          "v": "chest"
        },
        {
          "t": "metin",
          "v": " kuşlara yem doludur,” diye şaka yaptı "
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
          "v": ", platformdan duydukları ince ötüşün kaydını sınıfın kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " gözlem panosunda dinletti. Bir öğrenci bunun serçe sesi olduğunu düşündü. Başka biri göçmen bir kıyı kuşunun sesi olabileceğini söyledi. Suna Hanım kesin bir tür adı vermedi; güvenilir ses"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " kayıtlarıyla karşılaştırmadan emin olamayacaklarını açıkladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " biraz şaşırdı. Teknolojinin her soruya anında cevap vermesine alışmıştı. Fakat bu kez cihaz yalnızca ses topluyordu; yorum yapmak kendilerine düşüyordu. Asya bunu raporun kenarına ekledi: “Kayıt, gözlemin bir parçasıdır. Doğru yorum için başka kaynaklar da gerekir.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Günün sonunda çocuklar kamp merkezine döndü. Akşamki paylaşım toplantısında başka ekiplerin bulgularını da dinlediler. Bir grubun fotoğrafında eski haritadakine benzer bir kıyı şekli görülüyordu; bir diğeri kumulların rüzgârla hareket ettiğini anlatmıştı. Selin bu bilgileri kendi haritalarına ekledi. Gece"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": " boyunca çadırların üzerinde yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " sesi duyulmuştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sabah uyandığında kıyının sis içinde kaybolduğunu gördü. İlk anda yağmuru maceraya engel saydı. Ardından çadırın hemen dışındaki yağmur ölçer dikkatini çekti. Öğretmenleri ölçüm miktarını deftere yazıyor ve bir önceki günle karşılaştırıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Selin, “Demek yürüyüş yapamasak da veri toplayabiliyoruz,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gönülsüzce defterini açtı. Hava durumu tahminiyle gerçekleşen hava olayının her zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " birebir aynı olmayabileceğini de not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " etti. Böylece iptal edilen gezi, başka bir gözlem çalışmasına dönüşmüş oldu. Kampın ikinci günü hava kapalıydı. Rehber, rüzgârın hızlanabileceği uyarısıyla açık kıyı yürüyüşünü iptal etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hayal kırıklığını saklayamadı. “Tam sonuca yaklaşmıştık.” Suna Hanım, “Araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " bazen durmayı da gerektirir,” dedi. “Bugün arşive bakacağız.” Merkezin küçük kütüphanesinde yıllara göre hazırlanmış haritalar, eski hava fotoğrafları ve kıyı raporları vardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Asya, kırk yıl önce çekilmiş bir fotoğrafı buldu. Fotoğraftaki ada, aslında denizden ayrı duran küçük bir kara parçası gibi görünüyordu. Ancak altındaki açıklama, kış"
        },
        {
          "t": "ikon",
          "v": "snow"
        },
        {
          "t": "metin",
          "v": " aylarında suların yükseldiğini; yazın bazı yerlerde kum"
        },
        {
          "t": "ikon",
          "v": "desert"
        },
        {
          "t": "metin",
          "v": " setlerinin belirginleştiğini söylüyordu. “Demek ada bazen görünüyormuş,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Selin dikkatle baktı. “Görünür olmak başka, sürekli ada olmak başka.” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " daha yeni bir fotoğraf getirdi. Eski iskele artık kullanılmıyordu. Koruma sınırları da değişmişti. Bir zamanlar deniz"
        },
        {
          "t": "ikon",
          "v": "wave"
        },
        {
          "t": "metin",
          "v": " kenarında ziyaretçi kabul eden bölüm, bugün göçmen kuşların hassas alanı sayılıyordu."
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
          "v": " yüzü düştü. “Hazine arama oyunu yerine dosya okuyoruz.” Asya ona eski defterdeki sözlerini hatırlattı: “Varsayım kanıt değildir. Sen bizi maceraya çağırdın ama asıl macera gerçeği öğrenmek olabilir.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce itiraz edecekti. Sonra fotoğrafların farklı yıllarda çekildiğini fark etti. Aynı yeri karşılaştırmadan bir şey söylemek gerçekten zordu. “Peki,” dedi. “Hazineyi bir süreliğine unutuyorum.” Öğretmenler harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " üzerinde dört yeni nokta işaretledi. Bunlar eski kumul çizgisi, yeni sazlık sınırı, ölçüm istasyonu ve mevcut gözlem platformuydu. Böylece toplam yedi durak tamamlandı. Suna Hanım, adaların ve kıyı şekillerinin değişimini anlamak"
        },
        {
          "t": "ikon",
          "v": "lightning-idea"
        },
        {
          "t": "metin",
          "v": " için bu noktaların birlikte incelenmesi gerektiğini açıkladı."
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
          "v": " defterine uzun bir cümle yazdı: “Bir ipucunu sevmek, onun doğru olduğunu kanıtlamaz.” Altına da küçük bir sandık"
        },
        {
          "t": "ikon",
          "v": "chest"
        },
        {
          "t": "metin",
          "v": " resmi çizdi; üstünü çizmedi. “Hayal kurmak da önemli,” dedi. “Sadece hayalle gerçeği karıştırmamak lazım.” Gecenin ilerleyen saatlerinde "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", dışarıdan gelen rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " sesine uyandı. “Kıyı orada duruyor, biz burada uyuyoruz,” diye düşündü. Sandığı bir gün bulabileceğine ilişkin hayalinden vazgeçmek istemiyordu. Çadırın küçük penceresinden görünen yıldızlara baktı ve ilk defa bir maceranın sonunda hiçbir şey almadan dönmenin de değerli olabileceğini düşündü. Ertesi sabah kahvaltıda düşüncesini arkadaşlarıyla paylaştı. Selin, “Bilgi almak, eşya almak gibi değil,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Bir yeri öğrenince onu bitirmiyoruz.” Asya ise kendilerine gösterilen eski fotoğrafları hatırlattı. “Daha önce gözlem yapanlar olmasa bugün neler değiştiğini anlayamazdık. Belki bizim kayıtlarımız da yıllar sonra işe yarar.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kahvaltısını bitirirken sandık"
        },
        {
          "t": "ikon",
          "v": "chest"
        },
        {
          "t": "metin",
          "v": " aramak kadar kayıt tutmanın da heyecanlı olabileceğine şaşırdı. Bu düşünce, biraz sonra görecekleri manzarayı daha dikkatli incelemesini sağlayacaktı. O sabah "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " aklında yeni bir soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " vardı: “Koruma alanına kim karar veriyor?” Suna Hanım, bu tür kararların ilgili kurumlarca bilimsel çalışmalar ve mevzuat çerçevesinde alındığını anlattı. Çocuklar bir bölgenin herkese açık olmamasının, kimsenin onu sevmediği anlamına gelmediğini düşündü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bazen bir alanı ziyaret etmekten vazgeçmek onu korumanın parçasıydı. Selin, “Bize yasak olan yer, kuşların evi olabilir,” dedi. Bu cümle "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " sandık"
        },
        {
          "t": "ikon",
          "v": "chest"
        },
        {
          "t": "metin",
          "v": " hayalini biraz geriye itti. Çünkü bir evin kapısını, sahibine sormadan açmayı doğru bulmuyordu. Üçüncü gün hava açınca izinli gezi yeniden başladı. Grup, görevliler eşliğinde son gözlem platformuna yürüdü. Platformdan açık deniz"
        },
        {
          "t": "ikon",
          "v": "wave"
        },
        {
          "t": "metin",
          "v": ", kumullar ve dar bir "
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
          "v": ". “Bir sınırı gösteriyor.” Suna Hanım başını salladı. “Bu, çok önemli bir çıkarım. Ama hangi sınır?” Çocuklar, güncel koruma haritasıyla kendi çizimlerini yan yana koydu. Sınırlar tam olarak aynı değildi. Eski haritanın çizgisi bir zamanlar suyla çevrili olan kum"
        },
        {
          "t": "ikon",
          "v": "desert"
        },
        {
          "t": "metin",
          "v": " setini, yeni haritanın çizgisi ise bugün korunması gereken sazlık ve lagünü gösteriyordu. Aynı alan, iki farklı zamanda iki farklı görünüm kazanmıştı. Asya, sahada sessiz durma işaretini gösterdi. İnsan seslerinin kuşları rahatsız edebileceğini ve gözlemi zorlaştırabileceğini öğrenmişlerdi."
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
          "v": " önce sabırsızlandı; arkadaşlarına gördüğü her şeyi yüksek sesle anlatmak istiyordu. Sonra yalnızca defterine küçük bir çizim yaptı. Bir kuşun sığ suda yürüyerek beslendiğini, bir diğerinin ise daha uzak bir taşın üzerinde dinlendiğini gördü. Aynı alanı kullanan canlıların ihtiyaçlarının farklı olabileceğini anladı. Bu sessiz bekleyiş, birkaç dakika öncesine kadar boşa harcanan zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " gibi gelmişti. Şimdi gözlemin kendisi yolculuğun en heyecanlı bölümüne dönüşüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gözlerini kısıp dürbünle baktı. Kıyıda bir grup kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " vardı. İki tanesi suya dalıyor, diğerleri birbirini takip ederek kumsalda yürüyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Ben burayı bulup üzerine çıkabileceğimizi sanmıştım,” dedi. “Oysa önemli olan uzaktan görüp korumakmış.” Tam o sırada "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kayıt cihazında sabahki ince ötüşü duydu. Kuşların dinlendiği yerin yakınında küçük bir plastik atık birikintisi de görünüyordu. Asya dürbünle bakıp yerini haritaya işaretledi. Yetişkin görevlilerden biri, atıkların temizlenmesi için koruma ekibine bildirim yapılacağını söyledi. “Kayıp Ada'nın hazinesi kuşlar mı?” diye sordu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Selin, “Kuşlar, su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": ", bitkiler ve hepsinin yaşadığı yer,” diye cevap verdi. Öğretmenleri çocukların yanına gelip notlarını inceledi. “Bugün çok iyi bir şey yaptınız,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Bir yerin değerini yalnızca orada ne bulabileceğinize göre değil, orada nelerin yaşadığına göre değerlendirdiniz.” Asya son fotoğrafı çekti. Bu kez kadrajda hazine sandığı yoktu. Bir yanda su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": ", öbür yanda sazlık, ortada güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " ışığında dinlenen kuşlar vardı. Fotoğrafın altına şu açıklamayı yazdı: “Kayıp Ada değil, korunması gereken yaşayan kıyı.” Platformdan dönerken yürüyüş grubuna yakın bir okulun öğrencileri rastladı. Onlardan biri koruma alanını neden göremediklerini sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hemen “Çünkü orada kuşlar yaşıyor,” dedi. Ardından açıklamasının eksik olduğunu fark etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir alanın bazı bölümleri gözleme açık, bazıları ise hassas dönemlerde kapalı"
        },
        {
          "t": "ikon",
          "v": "lock"
        },
        {
          "t": "metin",
          "v": " olabilirdi. Suna Hanım, ziyaret kurallarının resmî levhalardan öğrenilmesi gerektiğini gösterdi. "
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
          "v": " kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " seslerinden kısa bir kayıt hazırladı; Asya fotoğrafları sıraya koydu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise sunumun girişini yazmayı üstlendi. Hazırlık sırasında küçük bir anlaşmazlık çıktı. "
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
          "v": ". Selin, “Gelirler ama yanlış bir şey beklerler,” diye cevap verdi. Asya iki farklı başlık yazıp gruba gösterdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Birincisi abartılıydı, ikincisi yalnızca “Kıyı Raporu” diyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " üçüncü bir seçenek önerdi: “Gerçek soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": ", kayıp adanın nerede olduğuydu. Cevabın da merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " uyandırmasını sağlayabiliriz.” Böylece dinleyiciyi kandırmadan ilgi çekmenin mümkün olduğunu gördüler. Herkes kendi fikrinden bir parça vazgeçti ve ortaya daha iyi bir metin çıktı. İlk taslağı şöyleydi: “Kırk yıllık hazine bilmecesini çözdük!” Asya başını iki yana salladı. “Gerçekte olmayan bir hazineyi çözdüğümüzü söyleyemeyiz.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kalemi bıraktı. “Ama kimse sıkıcı bir rapor dinlemek istemez.” Selin yeni bir başlık önerdi: “Haritada Kaybolan Ada Gerçekte Nereye Gitti?”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Bu hem merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " uyandırıyor hem de yanlış bir iddia kurmuyor,” dedi. Sunum günü, sınıflar merkezin küçük salonunda toplandı. "
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
          "v": " kaydedilen kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " seslerini dinletti. Asya atıkların yerini ve görevlilere yapılan bildirimi anlattı. Sorular başladığında bir öğrenci, “Madem ada yok, eski haritayı çöpe atmak gerekmez mi?” diye sordu. Selin, “Hayır,” diye cevap verdi. “Eski harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " bize geçmişteki durumu gösteriyor. Yanlış bilgi vermiyor; yalnızca başka bir zamanın bilgisini veriyor.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Suna Hanım öğrencilerin bu ayrımı fark etmesinden memnun oldu. Sonra gruba bir teklif sundu: Çalışmalarını merkezin ziyaretçi panosunda sergileyebilirlerdi. Ancak önce koruma görevlilerinin bilimsel bilgileri kontrol etmesi gerekiyordu. Çocuklar kabul etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", raporu tamamlamakla ünlü bir hazine bulmuş gibi hissetmedi. Daha güzel bir şey hissetti: Söylediklerinin başkaları için yararlı olabileceğini düşündü. Kendi fikirlerinin kontrol edilmesine de kızmıyordu. Çünkü doğruluğun alkıştan daha değerli olduğunu öğrenmişti. Rapor panoya asılmadan önce koruma görevlisi küçük bir düzeltme yapmıştı. Çocuklar kuşların beslenme alanını yalnızca “yuva"
        },
        {
          "t": "ikon",
          "v": "house"
        },
        {
          "t": "metin",
          "v": "” olarak adlandırmışlardı. Görevli, her göçmen kuşun o bölgede yuva yapmayabileceğini, bazılarının yalnızca dinlenip beslenmek için geldiğini anlattı."
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
          "v": " başta yaptığı hataya üzüldü. Sonra bu ayrımın neden önemli olduğunu düşündü: Yanlış bir kelime, doğru bir gözlemi bile yanlış anlaşılır hâle getirebilirdi. Selin rapordaki ifadeyi değiştirdi, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ses"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " kaydının yanına gözlemin tarihini yazdı. Asya da çektiği kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " fotoğrafının altına kesin tanımlayamadıkları tür adı koymadı. Hep birlikte daha az iddialı ama daha güvenilir bir sergi hazırlamışlardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Bunu görmek"
        },
        {
          "t": "ikon",
          "v": "glasses"
        },
        {
          "t": "metin",
          "v": " için yedi adımdan fazlası gerekiyormuş,” diye şaka yaptı. Veda toplantısında her öğrenci kampın ona öğrettiği tek şeyi söyleyecekti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Doğanın sesini kaydetmek, onu gerçekten dinlemekle aynı şey değil,” dedi. Asya, “Fotoğrafın tarihi, fotoğraf kadar önemli,” diye ekledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Selin, “Haritada küçük bir çizgi büyük bir fark gösterebilir,” dedi. Sıra "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " gelince hiç beklenmeyen bir cevap verdi: “Yanlış çıkmak sandığım kadar kötü değil. Çünkü yanlış olduğumu anladığımda yeni bir şey öğreniyorum.” Suna Hanım bu cümleyi duyunca gülümsedi. Çocukların ezberledikleri bilgiden çok, düşünme biçimlerinin değişmesi onu sevindirmişti. Son sabah çocuklar eşyalarını toplarken "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " tüyü gördü. Onu alıp hatıra olarak saklamak"
        },
        {
          "t": "ikon",
          "v": "bookmark"
        },
        {
          "t": "metin",
          "v": " istedi. Sonra kampın ilk kuralını hatırladı: Doğadaki nesneler mümkün olduğunca yerinde kalmalıydı. Tüyün fotoğrafını çekti, olduğu yerde bıraktı. Otobüsün penceresinden son kez kıyıya bakarken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", kumullardan oluşmuş şekillerin ertesi yıl yine değişebileceğini düşündü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Belki başka bir sınıf kendi çizdikleri haritayı inceleyecek ve onların soramadığı bir soruyu soracaktı. Asya raporun bir kopyasını kamp merkezine bıraktıklarını hatırlattı. “Yaptığımız işin devamını başkaları getirebilir,” dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", kuşların göç sırasında aynı yere dönüp dönmediğini merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " ediyordu. Suna Hanım, bazı türlerin belirli durakları tekrar kullanabildiğini ama bunun türlere ve koşullara göre değiştiğini anlattı. Selin, “O zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " gelecek yılların gözlemleriyle bizim notlarımızı karşılaştırmak ilginç olur,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu fikri daha önce bulmayı hayal ettiği sandıktan çok sevdi. Çünkü sandık"
        },
        {
          "t": "ikon",
          "v": "chest"
        },
        {
          "t": "metin",
          "v": " bir kez açılırdı; sorular ise yeni gözlemlerle büyürdü."
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
          "v": ", “Ben olsam başta cebime koyardım,” dedi. “Ben de,” diye güldü "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Ama fotoğraf da hatıra olur.” Otobüse binmeden önce dört arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": ", eski haritanın kopyasına son kez baktı. Selin yedi gözlem noktasını numaralandırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk gün yazdığı hazine tahmininin yanına bir not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " ekledi: “En değerli şeyi almak değil, ona zarar vermeden tanımak.” Asya, bu cümlenin raporun sonunda kullanılmasını önerdi. Otobüs yola çıktığında kamp geride kaldı. Kıyı boyunca uzanan sazlıklar küçüldü. Bir süre kimse konuşmadı. Sonra "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Yine de bir gün gerçek bir hazine haritası bulsak fena olmaz,” dedi. Selin güldü. “Önce haritanın tarihini kontrol ederiz.” “Ölçeğini de,” diye ekledi Asya."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Güzergâh izinlerini de,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". Kamp defterini çantasına yerleştirirken ilk sayfadaki aceleyle çizdiği sandığı gördü. Yanındaki son sayfada ise kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " sesleri, kıyı haritası ve kaynak listesi vardı. Defterin nasıl değiştiğine şaşırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ellerini kaldırdı. “Tamam, tamam! Artık hazine avcılığı daha zor işmiş.” Okula döndüklerinde öğretmenleri raporu sınıf"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " panosuna astı. Kayan kıyılar, göçmen kuşlar ve koruma sınırları hakkında başka öğrenciler de sorular sormaya başladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", haritadaki yedi adımın aslında tek bir yere gitmediğini düşündü. Her adım"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": ", onu biraz daha dikkatli bir araştırmacıya dönüştürmüştü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " son kez eski kıyı fotoğrafına baktı. Artık kumun değişimini de koruma alanının değerini de görebiliyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Otobüsün arka koltuğunda "
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
          "v": " defterine eklediği kaynakları da düşündü. Artık bir bilgiyi duyduğunda kimin söylediğini ve nereden öğrenildiğini sormayı unutmayacaktı. Defterinin son sayfasına yeni bir başlık yazdı: “Sekizinci Adım"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": ": Öğrendiklerimi Paylaşmak.” Altını çizdi. Çünkü bir keşif, yalnızca bulununca değil, doğru anlatılınca da büyüyordu. "
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
      "dayanak_sayfa": 6,
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
      "dayanak_sayfa": 15,
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
      "dayanak_sayfa": 16,
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
      "dayanak_sayfa": 20,
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
      "dayanak_sayfa": 28,
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
      "dayanak_sayfa": 6,
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
      "dayanak_sayfa": 3,
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
      "dayanak_sayfa": 27,
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pd_varsayim",
        "tur": "kelime",
        "yazim": "varsayım",
        "anlam": "Henüz kanıtlanmamış, doğru olabileceği düşünülen fikir.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "pd_lagun",
        "tur": "kelime",
        "yazim": "lagün",
        "anlam": "Denizden kum yığınlarıyla ayrılmış, sığ ve durgun su alanı.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "pd_olcek",
        "tur": "kelime",
        "yazim": "ölçek",
        "anlam": "Haritadaki uzunluğun gerçek arazide kaç uzunluğa karşılık geldiğini gösteren oran.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "pd_ata_acele",
        "tur": "atasozu",
        "yazim": "Acele işe şeytan karışır",
        "anlam": "Bir işi çok hızlı yapmaya çalışınca hata yapılır; sakin ve düşünerek davranmak gerekir.",
        "sinif_alt": 6,
        "sinif_ust": 6
      }
    ],
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
        "ad": "pd_ata_acele",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "pd_ata_acele"
          }
        ]
      }
    ]
  }
}$p39$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr041-yedi-adimda-kayip-ada: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p40${
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
        "kelime_sayisi": 2073,
        "tahmini_sure_dk": 20,
        "sayfa_sayisi": 24,
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
        "simge_sayisi": 47
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
          "v": " Anneleri, önce açık hava müzesini ve izinli bir yürüyüş parkurunu gezeceklerini söyledi. Gezi rehberleri Eren Bey otobüste bölgenin coğrafyasını anlattı: Volkanlardan çıkan kül ve başka malzemeler zamanla kayaçlara dönüşmüş, rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " ve su bazı yerleri daha hızlı aşındırmıştı. Sert ve yumuşak katmanların farklı biçimlerde aşınması, bölgenin ilginç kaya şekillerinin ortaya çıkmasına katkıda bulunmuştu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Peribacaları bir gecede mi oluştu?” diye sordu Bora. “Hayır,” dedi Eren Bey. “Doğadaki büyük değişimler çoğu zaman çok uzun zamanlarda gerçekleşir. Bir damla suyun bile zamanla iz"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": " bırakabileceğini düşünün. Atasözümüz der ki: ‘"
        },
        {
          "t": "atasozu",
          "yuva": "pd_ata_damlaya"
        },
        {
          "t": "metin",
          "v": ".’” "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " gözü yol kenarındaki levhalardan birine takıldı. Levhada tepe"
        },
        {
          "t": "ikon",
          "v": "mountain"
        },
        {
          "t": "metin",
          "v": ", vadi ve oyuğun basit çizimleri vardı. Bir ok ise fotoğraftaki kayaya benzemeyen küçük bir kanala yöneliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Bu kanal ne?” diye sordu. Rehber, bunun tarihî su sistemleriyle ilgili bir rota"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " işareti olabileceğini ama levhayı incelemeden kesin konuşamayacağını söyledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yolun ilk bölümünde Eren Bey çocuklara üç fotoğraf gösterdi. Hepsinde farklı boylarda peribacaları vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bazı kaya başlıklarının alttaki bölümü yağmurdan ve rüzgârdan kısmen koruduğunu öğrendi. Bora ise iki fotoğrafın neredeyse aynı görünmesine rağmen yıllar arasında çekildiğini fark etti. “Bunlar sanki durmuş gibi,” dedi. Rehber, “Yavaş"
        },
        {
          "t": "ikon",
          "v": "turtle"
        },
        {
          "t": "metin",
          "v": " gerçekleşen değişimleri bir günde görmek"
        },
        {
          "t": "ikon",
          "v": "glasses"
        },
        {
          "t": "metin",
          "v": " zordur,” diye açıkladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " örnek bir deneyi hatırladı: Suyun farklı malzemeleri değişik hızlarda aşındırabildiğini göstermek için sınıfta yapılan gözlem. “Ama bir sınıf deneyiyle yüzlerce yılın bütün koşullarını açıklayamayız,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Mert fotoğraf çekerken ışığı farklı açılardan denedi. Aynı kayalık bir açıdan tek kuleye, başka açıdan yan yana durmuş iki sütuna benziyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", gördüğü her şeyin tek bir bakış açısına bağlı kalamayacağını fark etti. Öğleden sonra yürüyüşe çıktıklarında kaya yüzeyinde birbirine paralel iki "
        },
        {
          "t": "kelime",
          "yuva": "pd_oyuk"
        },
        {
          "t": "metin",
          "v": " buldular. Parkurdan ayrılmadan, uzaktan bakabildiler. Bora hemen “Gizli geçit"
        },
        {
          "t": "ikon",
          "v": "bridge"
        },
        {
          "t": "metin",
          "v": "!” diye bağırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onu durdurdu. “Her oyuk kapı değildir,” dedi. Yine de ikisinin de kalbi hızlanmıştı. Çünkü kayanın üstünde bir su damlasına benzeyen eski bir işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " vardı."
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
          "v": " ise müzelerde eserlerin yanındaki açıklamaları okumayı severdi. Kaya üzerindeki işareti görünce birlikte fotoğraf çektiler; konumunu izinli güzergâh haritasına işaretlediler. “Bu işareti birileri yakın zamanda yapmış olabilir,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Eski olduğunu yalnızca renginden anlayamayız.” Eren Bey çocukların dikkatine şaşırmıştı. Bir süre sonra onlara yakınlardaki ziyaretçi merkezindeki sergiye bakmayı önerdi. Merkezde kaya oyma mekânların, güvercinliklerin ve eski su yollarının fotoğrafları vardı. Bir panoda “su kanalı” sözcüğü geçiyordu. Kimi yerlerde yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " suyu toplanıyor, uygun yerlere ulaştırılıyordu."
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
          "v": " kendi defterini karıştırırken gezi öncesi kütüphaneden aldığı küçük bir broşürün arasından bir kâğıt düştü. Kâğıtta, geçmişte yaşamış bir öğrencinin hazırladığı çizime benzeyen bir "
        },
        {
          "t": "kelime",
          "yuva": "pd_kroki"
        },
        {
          "t": "metin",
          "v": " vardı. Üstte şu cümle yazıyordu: “Köyün çeşmesi susarsa suyun izini takip et.” Bora, “İşte macera başladı!” dedi. “Bir dakika,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Bu çizimi kim yapmış, ne zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " yapmış?” Broşürün arkasında yörede yapılan bir okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " araştırmasının adı yazıyordu. Kroki, tarihî bir belgenin aslı değil, eski su yollarını anlatmak için öğrencilerce hazırlanmış bir eğitim görseliydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " biraz hayal kırıklığına uğradı. “Demek şifre"
        },
        {
          "t": "ikon",
          "v": "lock"
        },
        {
          "t": "metin",
          "v": " değilmiş,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eren Bey, “Şifre olmaması değersiz olduğu anlamına gelmez. Belki size çok iyi bir araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " sorusu verdi,” diye karşılık verdi. “Üstelik tarihî yerlerde izinsiz bir kapı aramak yerine, bilgiyi güvenli biçimde inceleyebilirsiniz.” Gece"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": " Bora, gezi defterindeki su damlası"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " simgesinin kopyasını birkaç kâğıda çizmişti. “Belki bunu her gördüğümüzde bir puan kazanırız,” dedi. "
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
          "v": ", “Bütün damlalar eski su yolu demek değildir,” diye ekledi. Sabah kahvaltısında bir çiftçiyle tanıştılar."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çiftçi eskiden yağışın az olduğu dönemlerde suyu dikkatli kullanmak gerektiğini, bugün de aynı özenin önemli olduğunu anlattı. Bir gün önce Mert'in fotoğraf makinesinin pili tükenmişti. Ona hemen yenisini almak yerine yedek güç kaynağını kullanmasını öğreten "
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
          "v": " araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " yaparken tek araca güvenmenin neden sorun olabileceğini gösterdi. Her araç başka ayrıntıyı yakalıyordu; bazı sorulara yanıt için birden fazla yönteme ihtiyaç vardı."
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
          "v": " bu cümleyi not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " aldı; oyunun en değerli puanı ona göre doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " ayrımı yapmaktı. Ertesi sabah grup, eski bir çeşmenin bulunduğu köy meydanına gitti. Meydandaki çeşmeden hâlâ su akıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yakınındaki açıklama panosunda bazı eski su toplama yöntemleri anlatılıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", birinci gün gördüğü damla işaretine benzeyen bir simge buldu. Fakat fotoğraftaki işaretin yönü farklıydı. “İkisi aynı şey mi?” diye sordu. “Benziyorlar ama eş olmak zorunda değiller,” dedi rehber. “Bir şeklin anlamını kullanıldığı yere göre değerlendiririz.” Mert iki fotoğrafı tabletinde yan yana açtı. Kayadaki iz"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": " daha yuvarlaktı, çeşmenin üzerindeki ise üç köşeliydi. Bora farklılıkları saydı. Saadet Hanım çocuklara bir de çeşmenin eski bir fotoğrafını gösterdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Fotoğrafta musluğun arkasındaki duvar bugünkünden farklıydı. "
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
          "v": ", “Onarım kötü mü?” dedi. “Hayır,” diye cevap verdi Saadet Hanım. “Önemli olan yapının korunması ve yapılan işlemlerin uzmanlarca kayıt altına alınması.” Bora eski fotoğraftaki taşları saydı, güncel fotoğrafla karşılaştırdı. Üç taşın farklı göründüğünü buldu. Böylece çevredeki bir ayrıntının değişmesini her zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " gizli bir kapıyla açıklamanın yanlış olduğunu gördü. Bazen cevap, dikkatli bir bakım çalışmasında saklıydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk defa bir sırrı çözmek"
        },
        {
          "t": "ikon",
          "v": "lightning-idea"
        },
        {
          "t": "metin",
          "v": " için hızlı davranmak yerine ayrıntıları incelemekten zevk alıyordu. Köy meydanında emekli bir öğretmen olan Saadet Hanım ile tanıştılar. Eren Bey onların sorusunu iletti. Saadet Hanım, eskiden köy çevresinde yağmurun nasıl toplandığını anlatan bir yerel araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " hazırladıklarını söyledi. Fakat çocukların gördüğü işaretin tam olarak neyi gösterdiğinden emin değildi. “Belge bulursanız beraber bakarız,” dedi. “Siz bilmiyorsanız kim bilir?” diye sordu Bora. “Bilmemek ayıp değil,” dedi Saadet Hanım. “Bilmediğini öğrenmek istememek üzücü olabilir.” Bu cevap "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " hoşuna gitti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Saadet Hanım çocukları belediyenin herkesin ziyaret edebildiği küçük yerel tarih sergisine yönlendirdi. Orada eski su kapları, ölçüm aletleri ve geçmiş yıllardaki kuraklığa ilişkin gazete kupürleri vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", başlıklardan birini defterine geçirdi: “Suyu bulmak"
        },
        {
          "t": "ikon",
          "v": "idea"
        },
        {
          "t": "metin",
          "v": " kadar korumak"
        },
        {
          "t": "ikon",
          "v": "shield"
        },
        {
          "t": "metin",
          "v": " da önemlidir.” Söyleşiden önce müze salonundaki bir maket dikkatlerini çekti. Makette yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": ", tepelerin yamaçlarından aşağıya akıyor; kimi yerlerde küçük kanallar boyunca birikiyor, kimi yerlerde ise toprağa sızıyordu. Görevli, maketin gerçek bir köyün bütün ayrıntılarını göstermediğini, öğrenmeye yardımcı bir model olduğunu özellikle söyledi. Çocuklardan biri maketteki suyu artırdığında bir kanalın taşıyamayıp taştığı görüldü."
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
          "v": " ise bir model üzerinde yaptıkları değişikliklerin gerçek tarihî yapıya uygulanmaması gerektiğini düşündü. Geçmişten kalan izler, öğrenmek için incelenirdi; oyun oynamak için bozulmazdı. Öğle sonrası müze görevlisi ile kısa bir söyleşi yaptılar."
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
          "v": " özellikle “yer altı şehri” sözünü merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " etmişti. Müze görevlisi, insanların farklı dönemlerde kayaları oyarak çeşitli amaçlarla mekânlar oluşturduğunu anlattı. Bunların bir kısmının yaşam, depolama ve korunma gibi işlevleri olabiliyordu. Bora hemen “Bütün odalar birbirine gizli geçitle bağlanır mı?” diye sordu. Görevli gülümsedi. “Bunu her yapı için söyleyemeyiz. Yer altı mekânlarını incelemek uzmanların işidir. Bazı alanlar ziyaretçiye açıktır, bazıları değildir.” Çocuklar sonra izinli bir sergi bölümünde yer altı yapılarının kesit çizimlerini gördü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bir kesit çiziminin duvarın arkasını hayal etmelerine yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " ettiğini fark etti."
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
          "v": " “Bir kanalın yaşını nasıl anlarsınız?” diye sordu. Görevli, uzmanların malzeme, yapım tekniği, tarihî kayıtlar ve gerektiğinde bilimsel yöntemleri birlikte değerlendirdiğini söyledi. Mert, “Yalnızca fotoğrafla kesin sonuca varamaz mıyız?” diye sordu. “Çoğu zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " fotoğraf bir başlangıçtır,” dedi görevli. “Tek başına bütün soruları cevaplamaz.” Gezi tamamlanırken parkur yakınından su sesi geldi. Bora hemen arkasını döndü. Kayaların arasındaki küçük bir oluğun içinden ince bir akıntı ilerliyordu. Eren Bey bunun son yağışlardan sonra görülebilen yüzey akışı olabileceğini anlattı."
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
          "v": " olukla eski broşürdeki çizginin benzerliğini fark etti ama ikisini aynı yapı sanmadı. “Bazen bir doğa"
        },
        {
          "t": "ikon",
          "v": "leaf"
        },
        {
          "t": "metin",
          "v": " izi, insan yapımı bir kanala benzeyebilir,” dedi. Eren Bey, “İşte bu yüzden gözlem, karşılaştırma ve kaynak kontrolü yapıyoruz,” diye karşılık verdi. Bir süre sonra suyun bir kısmının küçük bir çukurda biriktiğini gördüler. Çukurun çevresindeki bitkiler daha canlı görünüyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Su bitkileri de etkiliyor,” dedi. Mert o an güzel bir fotoğraf çekti: ön planda yeşil yapraklar, arkada güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " altında uzanan sarı kayalar. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bu kez küçük bir araştırma tablosu çizdi: Bir satırda su, ötekinde rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": ", üçüncüsünde insan emeği vardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kapadokya'nın görünüşünü anlamak için yalnızca bir nedeni bilmenin yeterli olmadığını birlikte gördüler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", Kapadokya'nın yalnızca peri bacalarından ibaret olmadığını anladı. Toprağı, suyu, insanları ve hikâyeleri bir aradaydı. Öğretmenleriyle yapılan kısa değerlendirme toplantısında "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " sordu: “Bir kaya üzerindeki iz"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": " yüzlerce yıllıksa, ona yanlışlıkla zarar verebileceğimizi nasıl anlarız?” Eren Bey, ziyaretçi olarak en güvenli yaklaşımın işaretlenmiş rotalarda kalmak, tarihi yapılara dokunmamak ve şüpheli bir bulguyu görevlilere bildirmek olduğunu söyledi. Mert, “Fotoğraf çekmek bazen dokunmaktan daha çok şey anlatıyor,” dedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " fotoğrafın yanına çizim de eklemenin yararını anlattı. Bora her şeyi bulmak"
        },
        {
          "t": "ikon",
          "v": "idea"
        },
        {
          "t": "metin",
          "v": " isteyen ilk hâlini hatırladı. Şimdi iyi bir kâşifin bazen bir kapıyı açmayan kişi olabileceğini düşünüyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Günün sonunda dört arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " çizimleri karşılaştırdı. Bora damla işaretini birbirine benzeten dört fotoğraf seçmişti. "
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
          "v": " herkesin gözlemini tek bir sayfaya topladı. Başlangıçta tam bir cevap beklemişlerdi. Şimdi farklı bilgi kaynakları arasında bağlantı kurmanın daha değerli olduğunu düşünüyorlardı. Rehberleri Eren Bey deftere bakınca gülümsedi. “Araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": ", yalnızca bulduğunu değil, bulamadığını da dürüstçe yazmaktır,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar son sayfaya küçük bir kutu çizip “Kesinleşmeyen sorular” başlığı açtılar. Altına kaya yüzeyindeki su damlası"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " işaretinin kökenini yazdılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bu sorunun bir sonraki uzman araştırmasına bırakılmasından rahatsız olmadı. Çünkü artık her gizemin bir akşamda çözülmek zorunda olmadığını biliyordu. Akşam otelde herkes gezi defterini tamamladı. Bora ilk sayfaya büyük harflerle “Gizli Geçidi Bulduk!” yazmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Ama bir geçide girmedik. Bunu yazarsan okuyanlar yanlış anlayabilir,” dedi. “Bütün heyecanı söndürüyorsun,” diye söylendi Bora. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " araya girdi. “Başlığı değiştirmeden hikâyenin sonunda neyi keşfettiğimizi anlatabiliriz. Belki gizli geçit"
        },
        {
          "t": "ikon",
          "v": "bridge"
        },
        {
          "t": "metin",
          "v": ", bizi sorulara götüren yoldu.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bora düşündü. “O zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " “Kapadokya'nın Gizli Geçidi” başlık olur. Ama içeride hayal ile gerçek ayrılır.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu fikri sevdi. Defterini açıp ilk günün haritasını, çeşme fotoğrafını ve su oluğunu yan yana yerleştirdi. Her birinin altına “Kesin bilgi”, “Gözlem” veya “Araştırılması gereken” notunu ekledi. Ertesi sabah dönüş yolunda otobüs bir seyir noktasında durdu. Balonlar yine gökyüzündeydi. "
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
          "v": "Otobüste Eren Bey çocukların defterlerini sırayla inceledi. Herkesin en az bir kesin bilgi, bir gözlem ve bir yeni soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " yazmasını istedi. "
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
          "v": " ona dönüp “Bu resmi silmeyecek misin?” dedi. Bora başını salladı. “Hayır. Hikâyenin başladığı yer orası. Bilgiyle hayal arasındaki farkı bana hatırlatacak.” Bora yanına oturdu. “Bir daha gelirsek yine gizem arayalım mı?” “Arayalım,” dedi "
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
          "v": "“Ama bu defa yanımızda daha çok soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": ", daha az tahmin olsun.” “Hiç tahmin olmasın mı?” “O kadar da değil. Tahmin bizi yola çıkarır. Kanıt nereye gideceğimizi söyler.” Defterdeki son tabloyu birlikte doldurdular. Birinci sütunda gezi sırasında duydukları yeni kelimeler, ikinci sütunda anlamları, üçüncü sütunda ise kullandıkları örnek cümleler vardı. Bora “oyuk” kelimesinin yanına kayanın içeri doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " çökük bölümünü gösteren küçük bir çizim ekledi. "
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
          "v": ", en çok “kanıt” kelimesinin anlamını değiştirdiğini düşündü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çünkü onun için kanıt artık yalnızca gizli bir işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " değil, doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " soruyla incelenen bilgi demekti. Otobüs hareket etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", defterin son sayfasına araştırmada tanıştıkları insanların adlarını da yazdı; bir keşifte yalnız olmamak güzeldi. O su damlası"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " resmine her baktığında Kapadokya'daki kayaların yalnızca güzel görüntüler değil, uzun bir zamanın izleri olduğunu hatırlayacaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " de sonraki gezilerinde aynı dikkatle gözlem yapmaya söz verdi. Bora defterinin kapağına küçücük bir su damlası çizdi. "
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
      "dayanak_sayfa": 6,
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
      "dayanak_sayfa": 10,
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
      "dayanak_sayfa": 10,
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
      "dayanak_sayfa": 19,
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
      "dayanak_sayfa": 23,
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
      "dayanak_sayfa": 23,
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
      "dayanak_sayfa": 20,
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pd_oyuk",
        "tur": "kelime",
        "yazim": "oyuk",
        "anlam": "Bir yüzeyin, özellikle kayanın içeri doğru çökük bölümü.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_kroki",
        "tur": "kelime",
        "yazim": "kroki",
        "anlam": "Bir yerin ayrıntılara girmeden, el ile çizilmiş basit planı.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_asinma",
        "tur": "kelime",
        "yazim": "aşınma",
        "anlam": "Kayaların rüzgâr ve suyun etkisiyle zamanla yavaş yavaş yıpranması.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_ata_damlaya",
        "tur": "atasozu",
        "yazim": "Damlaya damlaya göl olur",
        "anlam": "Küçük şeyler birikerek zamanla büyük bir sonuç oluşturur.",
        "sinif_alt": 5,
        "sinif_ust": 5
      }
    ],
    "yuvalar": [
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
        "ad": "pd_ata_damlaya",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "pd_ata_damlaya"
          }
        ]
      }
    ]
  }
}$p40$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr042-kapadokyanin-gizli-gecidi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p41${
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
        "sayfa_sayisi": 24,
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
        "simge_sayisi": 57
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
          "v": " ise geçen ay"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": " aynı tepede yenilenen bir anten görmüştü. "
        },
        {
          "t": "isaret",
          "kod": "ay"
        },
        {
          "t": "metin",
          "v": " “Anne, kulede biri olabilir mi?” diye sordu. Annesi perdeyi açıp baktı. “Olabilir. Ama gece tek başımıza oraya gitmek doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " olmaz. Yarın belediyenin bilgi hattına sorabiliriz.” "
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
          "v": " doğa olaylarıyla ilgili videolar izlemeyi severdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Belki gizli bir haberleşme sistemi,” dedi heyecanla. Üçüncü arkadaşları Defne ise hemen karşı çıktı. “Ya bakım lambasıysa? Önce gözlemimizi yazalım.” Öğretmenleri Meryem Hanım bir bilim"
        },
        {
          "t": "ikon",
          "v": "microscope"
        },
        {
          "t": "metin",
          "v": " gözlem etkinliği planlıyordu. Çocukların notlarını görünce kulenin bulunduğu tepeyi gösteren eski bir fotoğraf çıkardı. Fotoğrafta kulenin yanında rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " yönünü gösteren bir ok vardı. “Bu yer eskiden hava gözlemleri için kullanılmış,” dedi. “Bugünkü işlevini bilmiyoruz. Birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " araştırabiliriz.” "
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
          "v": " dikkatle baktı. “Ben üç ışık gördüm ama aralarında eşit süre var mıydı, bilmiyorum,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Defne “O zaman aralıklara eşit çizgi koymayalım,” diye önerdi. Çizimin altına “yaklaşık gözlem” yazdılar. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", bu küçük kelimenin neden önemli olduğunu o an kavradı. Kesin olmayan bir şeyi kesinmiş gibi göstermek, resme bakacak herkesi yanlış yönlendirebilirdi. Bir sonraki gözlem için saat"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " tutmayı, rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " ve hava durumunu da not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " etmeyi planladılar. Her birinin ayrı görevi olacaktı. "
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
          "v": " zamanlamayı, Defne notları kontrol edecekti. Böylece aynı olayı üç kişinin farklı bakışla inceleyebileceğini düşündüler. İlk görevleri, kuleye yaklaşmadan güvenilir bilgi bulmaktı. Belediye sayfasındaki duyuruları incelediler. Kulede bazı meteoroloji sensörlerinin yenilendiğini öğrenince "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gizli haberleşme fikri zayıfladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yine de geceki ışığın ne anlama geldiği açıklanmamıştı. Bir gün önce "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " küçük kardeşi rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " gülünü döndürmekte zorlanmıştı. "
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
          "v": " bu anıyı anlattı. Öğretmenleri hava hareketinin farklı hızlarda olabileceğini, ölçüm araçlarının doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " kullanılmasının önemini açıklarken çocuklardan gözlemlerini basit cümlelerle yazmalarını istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " başlangıçta “çok rüzgârlı” diye not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " aldı. Defne ona “Ne kadar?” diye sordu. Sınıftaki rüzgâr ölçerin değerini ve saati eklediler. Bu küçük değişiklik, bir gözlemden daha karşılaştırılabilir bir kayda geçmelerini sağladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Meryem Hanım, öğrencileri okulun küçük hava köşesine götürdü. Termometre, yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " ölçer ve rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " yönünü gösteren basit bir düzenek vardı. "
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
          "v": " gökyüzündeki bulutların şeklini çizdi. Defne ise rüzgârın aniden yön değiştirdiğini fark etti. “Hava tahmini yalnızca bulutlara bakmak mıdır?” diye sordu "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Hayır,” dedi öğretmenleri. “Sıcaklık, basınç, nem, rüzgâr ve daha birçok veri birlikte değerlendirilir. Üstelik tahminin kesinlik derecesi vardır.” Okuldaki hava köşesinin termometresi güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " altında kaldığında daha yüksek değer gösterebiliyordu. Defne, farklı yere taşındığında ölçümün niçin değiştiğini merak etti. Öğretmenleri, ölçümlerin karşılaştırılabilir olması için araçların doğru yere konması ve aynı yöntemle kullanılması gerektiğini anlattı."
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
          "v": ", evlerinin balkonunda tuttuğu sıcaklık notlarıyla okul kayıtlarının neden farklı olduğunu anladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " ölçerin boşaltılması gerektiğini unuttuğu bir günü hatırladı. “Demek sayı kadar sayının nasıl elde edildiği de önemli,” dedi. Meryem Hanım, “Bunu raporunuzun en üstüne yazın,” diye önerdi. Çocuklar artık meteorolojiyle ilgili bir sözcük öğrendiklerinde onu doğrudan örneklerle ilişkilendirebiliyordu: nem, yağış, basınç ve rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " yalnızca kitapta gördükleri kelimeler değildi. O gün okulun küçük bahçe şenliğinin duyurusu yapılacaktı. Sınıf süslemeleri hazırlıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hava tahmini sitesinde akşam için gök gürültülü sağanak olasılığı gördü. Arkadaşı Tuna, “Burada güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " var, yağmur gelmez,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Defne buna itiraz etti: “Bir yerde güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " olması, birkaç saat"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " sonra başka bir hava olayı yaşanmayacağını göstermez.” Çocuklar öğretmenlerinden resmi tahmin ve uyarıların nereden takip edildiğini öğrendi. Başka kaynaklarda farklı ifadeler görünce de tek bir videoya bakarak karar vermemeleri gerektiğini anladılar. O akşam "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " notlarını gözden geçirirken “hava durumu” ile “hava tahmini” sözcüklerini aynıymış gibi kullanmış olduğunu gördü. Öğretmeninin anlattıklarını hatırladı: Biri belirli bir zamanda gözlenen durumu, diğeri geleceğe ilişkin değerlendirmeyi anlatıyordu. Defterindeki iki cümleyi düzeltti. Bu küçük ayrım, sonraki günün sorularını daha açık sormasına yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " edecekti."
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
          "v": " akşamki kule ışıklarının havayla ilişkili olabileceğini düşünmeye başladı. Öğle arasında duyuru panosuna küçük bir çizelge astılar: “Gözlem, tahmin, gerçekleşen hava”. Sınıftaki diğer öğrenciler de kendi gözlemlerini ekledi. Kimileri bulutları resmetti, kimileri rüzgârı hissettiğini yazdı. Çizelge giderek bir dedektif panosuna benziyordu. Fakat bu kez dedektiflerin peşinde bir insan değil, değişen hava vardı. Meryem Hanım, meteoroloji bölge müdürlüğündeki eski öğrencisi Burcu Hanım'ı çevrim içi görüşmeye davet etti. Burcu Hanım bir hava uzmanıydı. Öğrenciler sırayla sorularını yöneltti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kuledeki yanıp sönen ışığın gizli bir mesaj"
        },
        {
          "t": "ikon",
          "v": "scroll"
        },
        {
          "t": "metin",
          "v": " olup olmadığını sordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Kulede ekipman kontrolü için kullanılan ışıklar olabilir,” dedi uzman. “Ama görüntüye bakarak görevini kesin söyleyemem. Hangi sistem olduğunu kurumdan doğrulamamız gerekir.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Bir hava istasyonu tehlikeyi nasıl bildirir?” diye sordu. Burcu Hanım, otomatik istasyonların ölçümleri elektronik yollarla iletebildiğini anlattı. Gözlem verileri uzmanlarca incelenir, uygun görülürse resmî uyarılar yayımlanırdı. Kuledeki ışık tek başına halka yönelik bir alarm anlamına gelmiyordu. Burcu Hanım çevrim içi görüşmede bir örnek de gösterdi. İki haritada aynı bölgenin farklı zamanlardaki hava durumunu simgelerle işaretlemişti. Bir haritada yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " olasılığı görünürken ötekinde yağışın gerçekleştiği alan gösteriliyordu."
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
          "v": " bunu çok yararlı buldu; çünkü internette dolaşan eski bir uyarıyı güncel sanmanın da yanlış kararlar doğurabileceğini fark etti. Defne, sınıf panosuna tarihi olmayan hiçbir uyarı"
        },
        {
          "t": "ikon",
          "v": "bell"
        },
        {
          "t": "metin",
          "v": " resmi asmayacaklarına karar verdi. Görüşme bittikten sonra Meryem Hanım önemli bir soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " sordu: “Bir ipucu gördüğünüzde hikâyeyi kim tamamlıyor?”"
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
          "v": " elini kaldırdı. “Bazen biz tamamlıyoruz. Ama kafamızdan.” Sınıf güldü. “O hâlde bilmediğimiz kısmı araştırmadan kesin konuşmayacağız,” dedi öğretmenleri. Sonra tahtaya eski bir atasözü yazdı: “"
        },
        {
          "t": "atasozu",
          "yuva": "pd_ata_sormakla"
        },
        {
          "t": "metin",
          "v": ".” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yine de kulenin ışığını unutamıyordu. Ertesi akşam balkondan baktığında ışık bir kez daha yandı. Bu kez saatini not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " etti ve annesiyle birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " görüntünün kısa bir videosunu çekti. Videoda uzaktaki kule görünüyordu ama ışığın niçin yandığı belli değildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kameranın sınırlarını da fark etti: Bir görüntü, her sorunun cevabı değildi. Şenlikten bir gün önce sınıf içinde küçük bir tartışma yaşanmıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Tuna, hava tahmininin bazen tutmadığını söyleyerek uyarılara hiç güvenmemeyi savunuyordu. Defne ise bir tahminin "
        },
        {
          "t": "kelime",
          "yuva": "pd_olasilik"
        },
        {
          "t": "metin",
          "v": " bildirdiğini, bu yüzden gerçekleşmeyen bir olayın bütün tahmin yöntemlerini geçersiz kılmayacağını anlattı. Meryem Hanım çocuklardan iki cümleyi karşılaştırmalarını istedi: “Mutlaka yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " yağacak” ve “Sağanak olasılığı bulunuyor.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ikinci cümlenin daha doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " olduğunu söyledi; kesinlik bildiren sözcükler farklı kararlar doğurabilirdi. Öğretmenleri bunun üzerine kısa bir etkinlik yaptırdı. Çocuklar meteoroloji bültenlerindeki “olası”, “bekleniyor”, “yerel” gibi sözcükleri işaretledi. Tuna sonunda “Demek hava tahmini kehanet değil,” dedi. Sınıf güldü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Meryem Hanım, “Evet, bilimsel verilere dayalı bir değerlendirme,” diye tamamladı. Cuma sabahı hava açık başladı. Okul bahçesindeki masalara kitaplar dizildi, öğrencilerin yaptığı afişler asıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " görevlilerden biriydi. Ancak öğleye doğru rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " kuvvetlendi. Hafif afişler sallanıyor, bazı bulutlar kısa sürede çoğalıyordu. Meryem Hanım, okul idaresiyle birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " güncel hava uyarılarını kontrol etti. Şenliğin açık hava bölümü ertelendi. Bazı öğrenciler üzüldü. Tuna, “Belki yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " yağmayacak. Boşuna hazırlanmış olduk,” dedi. "
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
          "v": " varsa önlem almak doğru. Bütün masaları içeri taşıyabiliriz.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Masalardan birinin üzerinde, geçen yılki öğrencilerin hazırladığı çizim kitabı duruyordu. "
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
          "v": ", “Şenlik iptal olmadı, sadece yer değiştirdi,” dedi. Tuna ve arkadaşları masaları yeniden kurdu; kitapların yanına bulut"
        },
        {
          "t": "ikon",
          "v": "cloud"
        },
        {
          "t": "metin",
          "v": " çizimleri asıp salonu küçük bir bilim"
        },
        {
          "t": "ikon",
          "v": "microscope"
        },
        {
          "t": "metin",
          "v": " müzesine çevirdiler. Böylece herkesin emeği değerlendi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar öğretmenlerin yönlendirmesiyle kitapları kapalı"
        },
        {
          "t": "ikon",
          "v": "lock"
        },
        {
          "t": "metin",
          "v": " salona taşıdı. İçeri taşınan masaların biri diğerlerine göre ağırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce onu tek başına kaldırmayı denedi, sonra öğretmeninden yardım istedi. Birlikte taşırken “Bugün yalnızca hava değil, ekip çalışması da öğrendik,” diye şaka yaptı. Tuna kütüphane kitaplarının ıslanmadığını görünce rahatladı. Çünkü bir ay"
        },
        {
          "t": "ikon",
          "v": "moon"
        },
        {
          "t": "metin",
          "v": " boyunca resimledikleri öyküleri ilk kez ziyaretçilere gösterecekti. Kısa süre sonra yağmur"
        },
        {
          "t": "ikon",
          "v": "rain"
        },
        {
          "t": "metin",
          "v": " başladı. Pencereden dışarı bakarken sert damlaların bahçedeki boş masalara vurduğunu gördüler. Eşyalar zarar görmemiş, öğrenciler içeride güvendeydi. Tuna "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " dönüp “Ben yalnızca şimdiki güneşe baktım,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Sen sonraki saatleri de düşündün.” Tuna o gün "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ile birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " salonun penceresinden bahçeyi izledi. Yağmurdan sonra rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " hafifledi, bulutların bir kısmı dağıldı. Tuna “Şimdi dışarı çıkabiliriz,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", etkinliğin yeniden dışarı taşınıp taşınmayacağına öğretmenlerinin karar vereceğini hatırlattı. Çünkü hava yalnızca o anda pencereden görünen manzaradan ibaret değildi. Okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " yönetimi etkinliği içeride sürdürmeyi uygun buldu. Bu karar ilk başta bazılarına gereksiz göründü ama içerideki program da çok güzel geçti. Çocuklar çizimlerini korumuş, misafirler rahatça kitapları incelemişti. Tuna, bir günün başarılı olması için bütün planların ilk biçimiyle gerçekleşmesinin gerekmediğini anladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Aslında bunu öğretmenimiz ve uzmanların uyarısı sayesinde yaptık,” diye karşılık verdi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Meryem Hanım çocuklardan günün sonunda bir karşılaştırma yapmalarını istedi. Sabah planlanan şenlikle gerçekleşen şenlik arasında hangi farklar vardı? "
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
          "v": ", bir planı uyarlamanın vazgeçmek anlamına gelmediğini fark etti. Sınıfın küçük gazetesi için yeni bir başlık buldu: “Yağmurlu Günün Kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " Şenliği.”"
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
          "v": " masaya, “Hava bir sır saklamaz; sadece onu anlamak"
        },
        {
          "t": "ikon",
          "v": "lightning-idea"
        },
        {
          "t": "metin",
          "v": " için veri gerekir,” yazılı küçük bir kart koydu. "
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
          "v": " metni sınıf panosuna olduğu gibi asmak yerine öğretmeniyle birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " özetledi. Kurum adını, yanıtın tarihini ve sorulan soruyu da eklediler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Böylece arkadaşları bilgiyi nereden öğrendiklerini görebilecekti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Keşke ışığın mors alfabesiyle mesaj"
        },
        {
          "t": "ikon",
          "v": "scroll"
        },
        {
          "t": "metin",
          "v": " verdiği doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " çıksaydı,” diye şaka yaptı. Defne, “O zaman da bunu kanıtlamak gerekirdi,” dedi. Hafta sonunda belediyeden yanıt geldi. Yenilenen kuledeki ışık, bakım sırasında belirli aralıklarla yapılan bir ekipman kontrolünün parçasıydı. Kule, hava verilerini ölçen sistemlerden birini barındırıyordu. Işık, "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " düşündüğü gibi insanları doğrudan uyaran bir mesaj değildi. Yine de kule, hava gözlemi için önemliydi. “Aslında çocukken ben de bulutların her şeklini bir işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " sanırdım,” dedi öğretmenleri. “Hayal kurmak güzeldir."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bilim"
        },
        {
          "t": "ikon",
          "v": "microscope"
        },
        {
          "t": "metin",
          "v": " yaparken ise hayalimizin hangi bölümünün kanıtlandığını bilmemiz gerekir.” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bu sözlere sevindi. Gizemli öyküler yazmaktan vazgeçmeyecekti. Sadece bilim gözlemleriyle kurmaca hikâyeleri birbirine karıştırmamayı öğrenecekti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " biraz utanarak, “Ben onu gizli bir istasyon sandım,” dedi. Defne gülümsedi. “Aslında istasyon kısmını doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " tahmin etmişsin. Gizli kısmını kanıtlamamıştık.” Öğretmenleri raporlarını üç bölüme ayırmalarını istedi: “Ne gördük? Ne düşündük? Ne öğrendik?” Defne yazıyı yüksek sesle okuyunca bir cümlede tarih eksik olduğunu fark ettiler. Hemen eklediler; çünkü bir gözlemin ne zaman yapıldığı, ne görüldüğü kadar önemliydi."
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
          "v": " ilk bölümde gece görülen ışığı, ikinci bölümde olası açıklamaları, üçüncü bölümde ise doğrulanmış bilgiyi yazdı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", kanıtlanmayan fikrini silmek yerine yanına “ilk varsayım” notu düştü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " gazetesine bir yazı hazırladı. İlk başlığı “Kulede Gizli Alarm!” olmuştu. Defne bunun gerçekte bulunmayan bir tehlike duygusu yaratacağını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başlığı “Eski Kulenin Yeni Görevi” olarak değiştirdi. Yazısına ışık hakkında öğrendiklerini, resmî hava uyarılarına nasıl ulaşabileceklerini ve alınan önlemlerin önemini ekledi. Yazı yayımlandığında en çok sorulan soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " “Kuleye nasıl gireriz?” değil, “Hava tahmini ne kadar önce hazırlanır?” olmuştu."
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
          "v": ", ışığı gördüğü ilk gün gözlemini kaydetmeseydi hangi ayrıntıları hatırlayıp hangilerini unutacağını düşündü. Küçük notların büyük yanlış anlamaları önleyebildiğini fark etti. Bundan sonra şaşırdığı her şeyi önce dikkatle gözlemlemeye karar verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " artık korkmadı. Ama bu kez yalnızca kuleye bakmadı; telefonundaki resmî hava tahminlerini ve gökyüzündeki bulutları da karşılaştırdı. İnsanların hava hakkında sorular sormasının, geçmişteki basit gözlemlerden bugünkü gelişmiş ölçümlere kadar uzanan büyük bir öğrenme yolculuğu olduğunu düşündü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eve döndüğünde balkonundan kuleyi yeniden gördü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Artık ışığa bakınca aklına yalnızca gizem gelmiyordu; orada çalışan görevlilerin emeğini de düşünüyordu. Bir veri işlenmeden, kontrol edilmeden ve doğru zamanda paylaşılmadan insanların karar vermesine yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etmeyebilirdi. Bu farkındalıkla sınıf panosunda kendi adının çok büyük yazıldığını fark etti ve yanına "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ile Defne'nin adlarının da aynı boyda yazılmasını istedi. Çünkü bütün araştırmayı birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " yürütmüşlerdi. Hatta kulenin işlevini öğrenmelerini sağlayan uzmanların adını da kaynak bölümüne eklediler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bilimi tek başına parlak bir fikir"
        },
        {
          "t": "ikon",
          "v": "idea"
        },
        {
          "t": "metin",
          "v": " bulmak değil, farklı insanların ortak dikkati olarak görmeye başladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Son kez kuleye bakan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", ilk günkü korkusunu hatırladı. Bir ışığın neden yandığını bilmemek, onu hemen tehlike saymayı gerektirmiyordu. Doğru kaynakları araştırmak, hem merakı koruyor hem de gereksiz korkuyu azaltıyordu. Sınıf arkadaşlarının da bunu anlamasını istiyordu. Defterinin son sayfasına şunu yazdı: “Her ışık bir mesaj"
        },
        {
          "t": "ikon",
          "v": "scroll"
        },
        {
          "t": "metin",
          "v": " olabilir; ama hangi mesaj olduğunu ancak doğru kaynaklarla anlayabiliriz.” Altına bir kule, bir bulut"
        },
        {
          "t": "ikon",
          "v": "cloud"
        },
        {
          "t": "metin",
          "v": " ve küçük bir soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " işareti çizdi. Çünkü ona göre iyi bir araştırmacının çantasında üç şey bulunmalıydı: dikkatli gözler, sabırlı bir akıl ve yeni sorular. "
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
      "dayanak_sayfa": 19,
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
      "dayanak_sayfa": 9,
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
      "dayanak_sayfa": 12,
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
      "dayanak_sayfa": 9,
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
      "dayanak_sayfa": 12,
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
      "dayanak_sayfa": 13,
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
      "dayanak_sayfa": 21,
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pd_tahmin",
        "tur": "kelime",
        "yazim": "tahmin",
        "anlam": "Eldeki verilere dayanarak henüz olmamış bir durum hakkında yapılan değerlendirme.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_olasilik",
        "tur": "kelime",
        "yazim": "olasılık",
        "anlam": "Bir olayın olabilme ihtimali; olabilir ama kesin değildir.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_uyari",
        "tur": "kelime",
        "yazim": "uyarı",
        "anlam": "Dikkat edilmesi gereken bir durumu önceden bildiren haber.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_ata_sormakla",
        "tur": "atasozu",
        "yazim": "Sormakla yol bulunur",
        "anlam": "Bilmediğimiz bir şeyi doğru kişilere sorarak öğrenebiliriz.",
        "sinif_alt": 5,
        "sinif_ust": 5
      }
    ],
    "yuvalar": [
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
        "ad": "pd_ata_sormakla",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "pd_ata_sormakla"
          }
        ]
      }
    ]
  }
}$p41$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr043-kuledeki-son-isik: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p42${
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
        "kelime_sayisi": 2072,
        "tahmini_sure_dk": 20,
        "sayfa_sayisi": 24,
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
        "simge_sayisi": 52
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
          "v": ", yedek eldivenlerini, suyunu ve küçük not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " defterini yerleştirdi. Arkadaşı "
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
          "v": " "
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
          "v": " iki bilgiyi birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " kullanmayı denemek istiyordu."
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
          "v": " ise eldivenleri kalın olduğu için haritayı açmakta zorlandı. “Dağda küçük işler neden"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " bu kadar güçleşiyor?” diye söylendi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", hava koşullarının yalnızca yürüyüş hızını değil, basit hareketleri de etkileyebileceğini düşündü. “Gerçekten gölü görecek miyiz?” diye sordu "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". Ceren Hanım, “Hava ve yol şartları uygun kalırsa belirlenen seyir noktasından göreceğiz,” dedi. “Ama gölün üzerine çıkmak yok. Buzun güvenli olduğunu yalnızca görünüşünden anlayamayız.” Yola çıkmadan önce Ceren Hanım küçük bir oyun hazırladı. Masaya eldiven, çikolata, oyuncak dürbün, termos, pusula"
        },
        {
          "t": "ikon",
          "v": "compass"
        },
        {
          "t": "metin",
          "v": " ve parlak bir madalya koydu. “Hepsini taşımaya gerek yok,” dedi. “Bu yürüyüşte hangileri yararlı, hangileri yalnızca güzel görünüyor?”"
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
          "v": " bunun gereksiz olduğunu sanmıştı; haritada başlangıç noktasına geri dönmenin kolay göründüğünü düşünüyordu. Ceren Hanım, “Bazen planı yalnızca işler yolunda giderken değil, değiştiğinde de kullanırız,” dedi. Çocuklar soğuk havada nefeslerinin beyaz buhar gibi göründüğünü fark ettiler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " buharının soğuk havada küçük damlacıklar oluşturmasıyla ilgili olduğunu öğrenmişti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ise termometredeki değeri okudu ve “Hava eksi dört!” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ceren Hanım sıcaklıkla rüzgârın birlikte nasıl hissedildiğine dikkat çekti. Grup ilk kilometrede bir gözlem yapacaktı. Karın üzerine düşen gölgeleri saymak ve güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " açısının görünüşü nasıl etkilediğini not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " etmek. "
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
          "v": " gözlemleri defterine çizdi. Ceren Hanım, “Karın yüzeyi her yerde aynı görünmeyebilir,” dedi. “Ama görünüş bize onun üzerinde güvenle yürüyebileceğimizi söylemez.” Grup, yalnızca işaretli ve güvenli yoldaki sıkıştırılmış kar"
        },
        {
          "t": "ikon",
          "v": "snow"
        },
        {
          "t": "metin",
          "v": " bölümünü kullandı. Bu basit etkinlik, farkında olmadan çocuklara gözlemin sınırlarını da anlatmıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Parkurun başlangıcında iki harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " vardı. Biri kısa, kolay güzergâhı; diğeri daha uzun bir gözlem yolunu gösteriyordu. Grup kısa rotayı seçecekti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Haritadaki mavi işaretler ne demek?” diye sordu. Ceren Hanım bunların su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " kenarlarını, kırmızı çizginin ise yürüyüş yolunu gösterdiğini anlattı. İzinli patikanın kenarında görevli, çocuklara küçük hayvan ayak izleri gösterdi. Hangi canlıya ait olduklarını hemen söylemedi; izlerin boyutunu ve biçimini karşılaştırmalarını istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " birini köpek"
        },
        {
          "t": "ikon",
          "v": "dog"
        },
        {
          "t": "metin",
          "v": " izi sandı, "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise emin olmadığını belirtti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ceren Hanım, izlerin yalnızca fotoğraf üzerinden kesin tanınamayabileceğini, koruma görevlilerinin bölgedeki canlıları daha iyi bildiğini söyledi. Çocuklar gördüklerini not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " aldı ama izleri takip etmek için patikadan ayrılmadı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " küçük bir izin peşinden gitmenin ne kadar çekici olduğunu hissetti; sonra herkesin neden"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " belli kurallar içinde gözlem yaptığını yeniden anladı. Yürürken uzakta göl göründü. Buzun bazı yerleri bembeyaz, bazı yerleri ise koyu maviydi. Işığın yansıması suyun ve buzun görünüşünü değiştiriyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Gölü gördüğü anda bütün yorgunluğu unutmuş gibi oldu. Ama iki dakika sonra yüzüne vuran soğuk rüzgârı hissetti. “Bir fotoğraf daha çekip hemen dönelim,” dedi. Ceren Hanım bunun yürüyüş grubunun planına göre yapılacağını söyledi. "
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
          "v": ", önce koyu yerin daha kalın buz olduğunu düşünmüştü. Şimdi gözün her şeyi anlatmadığını kabul ediyordu. "
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
          "v": " yürüyüş boyunca küçük bir yürüyüş günlüğü tuttu. İlk satırda “Başlangıç, hafif rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": "”, ikinci satırda “Çamlık, açık gökyüzü"
        },
        {
          "t": "ikon",
          "v": "cloud"
        },
        {
          "t": "metin",
          "v": "”, üçüncü satırda ise “Seyir noktası, bulutlu” yazıyordu. "
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
          "v": ", “Dönüşte havanın ne zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " değiştiğini hatırlamak için,” dedi. Kayıt tutmayı sıradan bir ödev gibi görmüyordu; gördüklerini sonradan doğru hatırlamaya yardım eden bir araç olarak düşünüyordu. Ceren Hanım onların notlarını görünce zamanı da eklemelerini önerdi. “İki olayın sırasını bilmek, neden–sonuç kurarken işinizi kolaylaştırır,” dedi. Öğleye doğru bulutlar çoğaldı. Ceren Hanım grubun mola vereceği noktayı belirledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", uzaktaki küçük ahşap tabelanın yanında fotoğraf çekmek istedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Grup hâlâ izinli yolun üzerindeydi fakat "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " öne doğru birkaç adım"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": " atınca tabelanın arkasındaki dar yolun kapatıldığını gördü. Hemen geri döndü. "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " elindeki eski harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " çıktısı, bir yıl önceki okul etkinliğinden kalmıştı. Evde hazırlanırken tarihini kontrol etmemişti. Ceren Hanım bir yılın bazı yerler için küçük bir zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " olabileceğini, açık hava rotalarında ise güncel bilgi gerektiğini anlattı. "
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
          "v": " bu ayrımı beğendi. Bir bilgi geçmişi anlatmakta yararlı olabilir, bugün karar verirken ise yetersiz kalabilirdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Bu yol geçen yıl açıkmış,” dedi. “Neden şimdi kapalı?” Rehber, bazen bakım, hava koşulları veya doğal alanların korunması nedeniyle rotaların değişebileceğini anlattı. Eski bir harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " her zaman güncel olmayabilirdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " cebindeki rota kartına baktı. Kartın tarihi bu yıla aitti ve kapalı yol zaten işaretlenmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Demek yalnızca yönümüzü değil, haritanın tarihini de kontrol etmeliyiz,” dedi. Bir süre sonra hafif kar"
        },
        {
          "t": "ikon",
          "v": "snow"
        },
        {
          "t": "metin",
          "v": " başladı. Ceren Hanım grubun geri dönmesine karar verdi. Dönüşte rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " arttı ve uzaktaki ağaçlar beyaz bir perde arkasında silikleşti. Çocuklar liderlerine yakın yürüdüler. Parkurun işaretleri görünüyordu ama yürüyüşün başlangıcındaki manzara artık farklıydı."
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
          "v": " kalbinin daha hızlı attığını duyuyordu. Bir an önce varmak için acele etmek istedi. Sonra Ceren Hanım'ın az önce söylediği “Dur, düşün, planı kontrol et” sözünü hatırladı. Grubun gerisindeki bir arkadaşının yürüyüş temposunu düşürdüğünü fark etti. Öğretmenleri onun yanına geçti, gerekirse dinlenme planının uygulanacağını söyledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Hepimiz beraber gidersek yavaş"
        },
        {
          "t": "ikon",
          "v": "turtle"
        },
        {
          "t": "metin",
          "v": " kalırız,” diye söylendi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ona bakıp “Birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " başlayan bir ekip birlikte güvende dönmeli,” dedi. Ceren Hanım gülümseyerek ekledi: “"
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
          "v": ". "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " de tedirgin olmuştu. Yine de Ceren Hanım'ın sesini duyunca rahatladı: “Duruyoruz, grubu sayıyoruz ve planımıza bakıyoruz. Kimse tek başına ilerlemiyor.” Haberleşme bitince rehberleri çocuklara bilgi verdi: “Bulunduğumuz noktayı merkeze bildirdim, hava değiştiği için planlı dönüşe devam edeceğiz.” "
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
          "v": " da cebindeki haritayı açtı ama hemen bir yol önermedi. Bunun yerine gördüğü dönüş kavşağını işaretledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Birkaç dakika sonra kırmızı rota levhası ortaya çıktığında ikisi de doğru yolda olduklarını anladı. Rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " bazen yüzlerine vuruyordu fakat artık ne yapacakları belliydi. Ceren Hanım rota kartıyla konumlarını kontrol etti, merkezle haberleşti. Yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " istemeye gerek olmadığını, yalnızca hava değişimi nedeniyle planlı geri dönüş yaptıklarını bildirdi. Böylece herkes nerede olduklarını biliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gruba dağıtılan haritada dört önemli işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " bulunduğunu fark etti: başlangıç noktası, seyir terası, mola alanı ve güvenli dönüş kavşağı. “Bende en çok başlangıç işareti kaldı,” dedi "
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
          "v": "“Çünkü oraya geri dönmeyi bilmek de önemli.” "
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
          "v": ", yolu kendi başına seçmek istemedi; bulduğu işareti rehberlerine göstererek doğruladı. "
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
          "v": ", “Ben de başta öyle. Ama bir harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " hedefi gösterdiği kadar yolu da anlatıyor,” diye karşılık verdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Dönüş sırasında küçük bir ahşap köprüden geçtiler. Köprünün üzerinde birikmiş kar"
        },
        {
          "t": "ikon",
          "v": "snow"
        },
        {
          "t": "metin",
          "v": " görevli tarafından temizlenmişti. Yavaş"
        },
        {
          "t": "ikon",
          "v": "turtle"
        },
        {
          "t": "metin",
          "v": ", sırayla yürüdüler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", başka bir grubun patika dışında kısa yoldan yürüdüğünü gördü ve bunu rehbere söyledi. Ceren Hanım ilgili görevliye haber verdi; böylece alandaki diğer ziyaretçiler de bilgilendirildi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Onlar daha önce varabilir,” dedi. "
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
          "v": " başlangıçta karşı çıktı. “Yine de daha hızlı olabilirdik,” dedi. Ceren Hanım adımları saymalarını istedi: Hızlandıkları zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " kontrolsüz nefes alıyor, yavaşladıklarında rahatça konuşabiliyorlardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Grup için uygun hızın, en hızlı yürüyebilen kişinin temposu olmadığını fark ettiler. Hızlı olmak sporda değerliydi ama doğa"
        },
        {
          "t": "ikon",
          "v": "leaf"
        },
        {
          "t": "metin",
          "v": " yürüyüşünde dayanıklılık, birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " hareket etme ve karar verme de önemliydi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bunu duyunca geçen yaz bir bisiklet"
        },
        {
          "t": "ikon",
          "v": "bicycle"
        },
        {
          "t": "metin",
          "v": " yarışında arkadaşını geride bırakıp yol ayrımını kaçırdığı günü hatırladı. Daha erken varacağını sanarken yanlış yola sapmıştı. Şimdi haritayı ve grubu takip etmenin neden önemli olduğunu anlıyordu. “Ama bizim amacımız bir yarış kazanmak değil,” diye yanıtladı "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Güvenle dönmek.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Grubun en arkasında yürüyen öğretmen, her öğrencinin yakınında arkadaşını görebilmesini sağlıyordu. Küçük ekip farklı hızlarda yürüdüğü için yol boyunca kısa molalar planlanmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " en başta bunları gereksiz bulmuş, enerjisi varken hızlanmak istemişti. Fakat kar"
        },
        {
          "t": "ikon",
          "v": "snow"
        },
        {
          "t": "metin",
          "v": " yağışı ve rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " arttıkça her molanın herkesi yeniden toparlamaya yardım ettiğini gördü. Gruptaki çocuklar birbirlerine nefeslerini ve adımlarını ayarlamak için zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " tanıyordu. Böylece kimse yarışın gerisinde kalmış gibi hissetmiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dönüş yolunda arkadaşlarından Ayşe'nin sessizleştiğini fark etti. “İyi misin?” diye sordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ayşe üşüdüğünü söyleyince durumu hemen rehberlerine iletti. Rehber uygun mola düzenini uyguladı ve herkesin giysilerini kontrol etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " istemenin grubu yavaşlatmak değil, daha güvenli kılmak olduğunu gördü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da çantasındaki yedek boyunluğu Ayşe'ye önerdi; rehber uygun bulunca Ayşe rahatladı. Çocuklar dönüş kavşağındaki sarı işarete ulaştıklarında rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " hafifledi. Hava yine bulutluydu. İleride başlangıç binasının çatısı göründü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " rahat bir nefes aldı. Yol boyunca soğuk hissettiğinde katmanlı giysilerini ayarlamanın, susamayı beklemeden su"
        },
        {
          "t": "ikon",
          "v": "drop"
        },
        {
          "t": "metin",
          "v": " içmenin ve grubun temposuna uymanın yararını görmüştü."
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
          "v": " ise “Önce başarısız olduğumuzu sandım,” dedi. “Ama hava değişince karar değiştirebildik.” Liderleri, açık hava etkinliklerinde güvenliğin rotanın sonuna ulaşmaktan önce geldiğini açıkladı. Ceren Hanım çantalarından çıkan küçük taş, kozalak veya yaprakların hiçbirini götürmediklerini görünce teşekkür etti. Her öğrenci gördüğü bir şeyi çizmiş ya da fotoğraflamıştı. Böylece anılarının doğadaki nesneleri yerinden almadan da saklanabileceğini fark ettiler."
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
          "v": " defterine gölün mavi bölümünü çizdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise onu çevreleyen dağları. İki farklı resim aynı yürüyüşün başka yanlarını anlatıyordu. Çocuklar, alınan bir kararın sonucunu değerlendirirken yalnızca “vardık mı?” sorusuna bakmanın yeterli olmadığını düşündü. Merkez binasına dönünce sıcak çorbalarını içtiler. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " telefonundaki göl fotoğraflarını gösterdi. İlk fotoğrafta güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " parlıyordu, ikinci fotoğrafta aynı gölün üstünde bulutlar vardı. “İkisi de bugün çekildi,” dedi. “Ama biri yaz gibi, öbürü kış fırtınası gibi görünüyor.” Ceren Hanım, hava ve ışık değiştikçe aynı manzaranın farklı algılanabileceğini anlattı. Sonra herkese küçük bir görev"
        },
        {
          "t": "ikon",
          "v": "quest"
        },
        {
          "t": "metin",
          "v": " verdi: Yolculuğun fotoğraf albümünün yanına “gerçek rota defteri” hazırlamak."
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
          "v": " dönüş kavşağını çizdi; "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yürüyüş saatlerini ekledi. Birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": ", hava değiştiği için planın hangi noktada değiştirildiğini işaretlediler. "
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
          "v": " altına başka bir cümle ekledi: “Güvenli bir macera, iyi bir planla başlar.” Annesi gezi fotoğraflarına bakarken “En çok hangi anı hatırlayacaksın?” diye sordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yalnızca gölü göstermedi. Rüzgâr"
        },
        {
          "t": "ikon",
          "v": "wind"
        },
        {
          "t": "metin",
          "v": " kuvvetlendiğinde birlikte durdukları kavşağın fotoğrafını da açtı. “Burada doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " karar verdik,” dedi. “Manzara kadar bunu da hatırlayacağım.” O akşam "
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
          "v": " haritasını açtı, rotanın nerede değiştiğini gösterdi. “Bak, şu noktaya geldik. Sonra hava değişti. Geri dönerken öğrendiklerimiz, devam etseydik göreceğimiz bir manzaradan daha önemli olabilir,” dedi. Kardeşi haritadaki okları takip etti. “Ben de büyüyünce güvenli rota çizmeyi öğrenmek istiyorum,” diye cevap verdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da haritayı bir kez daha masaya serip dönüş kavşağını gösterdi. “Başlangıçta bu işareti gereksiz sandım,” dedi. “Şimdi neden"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " haritada olduğunu çok iyi biliyorum.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onun yeni öğrendiği bu dikkatli tavrı görünce sevindi."
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
          "v": " ise en çok dönüş kararını hatırlıyordu. Rehberleri hava değişince hedeflerinden vazgeçmişti. Önce bunu başarısızlık sanmış, sonra anlamıştı: Bazen hedefe varamamak değil, doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " zamanda geri dönmek en iyi karardı. Afişi hazırlarken başka sınıflardan gelen sorular onları şaşırttı. Bir öğrenci, “Buz kalın görünüyorsa üzerine çıkabilir miyiz?” diye sordu. "
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
          "v": " gülümseyip başını salladı; haritanın önemli olduğunu ama güvenlik için tek başına yeterli sayılamayacağını tekrar söyledi. Çocuklar afişte “Yanında yetişkin rehber ve güncel rota bilgisi olsun” cümlesine de yer verdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Harita"
        },
        {
          "t": "ikon",
          "v": "map"
        },
        {
          "t": "metin",
          "v": " yanımızdaysa tek başımıza yürüyebilir miyiz?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", haritanın tek başına güvenlik sağlamadığını, uygun rota, rehberlik, hava değerlendirmesi ve haberleşmenin de önemli olduğunu anlattı. Öğretmenleri çocukların bu sorulara hazırlıklı olmasına sevindi. Ertesi hafta sınıfta bir güvenli yürüyüş afişi hazırladılar. Sınıf arkadaşları onların afişine bakarken güvenli kararların bir ödev kuralından ibaret olmadığını fark etti. Hep birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " basit bir doğa"
        },
        {
          "t": "ikon",
          "v": "leaf"
        },
        {
          "t": "metin",
          "v": " yürüyüşü kontrol listesi hazırladılar. Afişin üstünde dört işaretli rota ve büyük harflerle tek bir cümle vardı: “Doğayı seviyorsan onu tanı, kurallarına uy ve birlikte hareket et.” "
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
      "dayanak_sayfa": 9,
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
      "dayanak_sayfa": 10,
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
      "dayanak_sayfa": 23,
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
      "dayanak_sayfa": 23,
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pd_pusula",
        "tur": "kelime",
        "yazim": "pusula",
        "anlam": "İğnesi hep aynı yönü göstererek yön bulmaya yardım eden araç.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_kuzey",
        "tur": "kelime",
        "yazim": "kuzey",
        "anlam": "Pusulanın gösterdiği, dört ana yönden biri.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_rota",
        "tur": "kelime",
        "yazim": "rota",
        "anlam": "Bir yolculukta ya da yürüyüşte izlenecek yol.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_ata_birlikten",
        "tur": "atasozu",
        "yazim": "Birlikten kuvvet doğar",
        "anlam": "İnsanlar bir araya gelip birlikte çalışınca daha güçlü olur.",
        "sinif_alt": 5,
        "sinif_ust": 5
      }
    ],
    "yuvalar": [
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
        "ad": "pd_ata_birlikten",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "pd_ata_birlikten"
          }
        ]
      }
    ]
  }
}$p42$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr044-buz-golunun-haritasi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p43${
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
        "kelime_sayisi": 2068,
        "tahmini_sure_dk": 20,
        "sayfa_sayisi": 24,
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
        "simge_sayisi": 40
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
          "v": ", okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " kütüphanesinin yeni düzenleneceğini duyunca ilk gönüllülerden biri oldu. Kitapları taşımak yerine etiketlerini kontrol etmeyi seviyordu. Çünkü bir kitabın nerede durduğunu bilmek, bazen içindekileri okumak kadar ilginçti. "
        },
        {
          "t": "isaret",
          "kod": "ipucu"
        },
        {
          "t": "metin",
          "v": " Kütüphane görevlisi Sevim Hanım, rafların yenileneceğini, eski kayıtların bilgisayara aktarılacağını anlattı. "
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
          "v": " ise katalogların da şaşırtıcı sorular doğurabileceğini düşünüyordu. “Bir kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " yanlış raftaysa onu arayan biri bulamaz,” dedi. “Bazen doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " hikâyeye ulaşmak, doğru etiketten geçer.”"
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
          "v": " gülerek “Peki bugün bir sır çıkarsa haber ver,” diye karşılık verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onun bu sözünü gün boyunca hatırlayacaktı. "
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
          "v": " ilk on iki rafı hızla kontrol etti. Ancak listenin sonraki sayfasında tuhaf bir boşluk vardı: Raf 12'nin ardından Raf 14 geliyordu. “On üçüncü raf nerede?” diye sordu "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " omuz silkti. “Belki uğursuz saydıkları için atlamışlardır.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülümsemedi. Bir okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " kütüphanesinin böyle bir nedenle raf atlamasını mantıklı bulmuyordu. Sevim Hanım da şaşırdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Eskiden burada ahşap dolaplar vardı,” dedi. “Yeni sistem kurulurken numaralar değişmiş olabilir. Eski defterlere bakalım.” "
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
          "v": ", “On üçüncü rafın yerinde şimdi koltuk var,” diye şaşırdı."
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
          "v": ", “Bir odanın değişmesi, içindeki hikâyelerin de değiştiği anlamına gelmez,” dedi. Bu cümleyi tam olarak niçin söylediğini kendisi de bilmiyordu. Belki yıllardır aynı odada başka başka çocukların kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " okuduğunu düşündüğü içindi. İlk defterde rafların el çizimi bir planı vardı. Planın ortasında küçük bir dolap görünüyordu. Yanına yalnızca “Emanet” yazılmıştı. Dolabın numarası ise silinmişti. "
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
          "v": "Ertesi gün iki arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " dijital katalogla eski kayıtları karşılaştırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " başlığının iki defterde farklı biçimde yazıldığını fark etti. Birinde “Yolun Rengi”, diğerinde “Yolların Rengi” vardı. "
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
          "v": " onu durdurdu. “Yazar adı aynı mı? Baskı yılı aynı mı?” diye sordu. İncelediklerinde bunların farklı kitaplar olduğunu öğrendiler. Küçük bir harf farkı bile kayıtların karışmasına yol açabiliyordu. Bu kez "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " dikkatli çalışmaya başladı. Bir kitabın yalnızca kapağına değil, künyesine de baktı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kayıt defterinin üstünde bir silinti gördü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hemen biri bilgi saklamış olabilir diye düşündü. "
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
          "v": " için bu cümle araştırmalarının yönünü belirleyen küçük bir dönüm noktasıydı. Üçüncü defterin arasında eski bir makbuz kopyası buldular. Üzerinde otuz kitaplık bir bağıştan söz ediliyordu. Fakat bağışın kayıt numaraları tam değildi. O akşam "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " evde aile"
        },
        {
          "t": "ikon",
          "v": "house"
        },
        {
          "t": "metin",
          "v": " kitaplığının fotoğrafını çekip "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " gönderdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Fotoğrafta bazı kitaplar boylarına göre dizilmişti. "
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
          "v": " de bütün evlerin aynı düzende olmak zorunda olmadığını fark etti. Ama okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " kütüphanesi ortak kullanım içindi; bir öğrenci kitabı aldığı yerde bulabilmeliydi. Bunun için kuralların herkes tarafından anlaşılması gerekiyordu. Sevim Hanım, bazı yıllarda el yazısıyla tutulan kayıtların bilgisayara eksik aktarılabildiğini söyledi. “O zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " on üçüncü raf gerçekten kaybolmuş olabilir,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Raf kaybolmaz,” diye karşılık verdi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Belki sadece adı değişmiştir.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Tabloyu hazırlarken "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir başka ayrıntı buldu. Bazı numaraların yanına küçük yıldızlar çizilmişti. Önce bunları özel kitapların işareti sandılar. Sevim Hanım, eski görev"
        },
        {
          "t": "ikon",
          "v": "quest"
        },
        {
          "t": "metin",
          "v": " çizelgesini getirip bu yıldızların o gün sayımı yapılan kitapları gösterdiğini anlattı. "
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
          "v": " buna sevindi. Çünkü bir gün defteri başkası açtığında aynı soruları sormak zorunda kalmayabilirdi. İkili basit bir işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " açıklaması sayfası oluşturdu. Emin olduklarını açık yazdılar; emin olamadıklarının yanına soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " işareti koydular."
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
          "v": ", “Bir kitaba yıldız"
        },
        {
          "t": "ikon",
          "v": "star"
        },
        {
          "t": "metin",
          "v": " koyunca değerli, başka kitaba koymayınca değersiz olmuyor,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Tabii ki. İşaret, onu kullanan kişinin ne anlatmak istediğine bağlı,” diye cevap verdi. Böylece tablolarına “işaretin olası anlamı” sütununu da eklediler. İki arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " sorularını bir tabloda topladı. İlk sütunda kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " numaraları, ikinci sütunda kayıt tarihleri, üçüncü sütunda bulunduğu yer yazıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çizelgeyi renklendirdiğinde birbirine benzeyen kayıtların aslında farklı dönemlere ait olduğunu gördü. En eski kayıtlar, binanın tadilatından önceki döneme uzanıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sevim Hanım, okulun "
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
          "v": ", eski plandaki koltuğun bulunduğu yere yürüdü. Çocukların bugün sessizce kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " okuduğu köşe bir zamanlar farklı bir amaçla kullanılmıştı. Bir mekânın geçmişini bilmek, ona daha dikkatli bakmasını sağladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de köşedeki küçük lambaya baktı. “Kayıp raf yerine okuma koltuğu gelmiş,” dedi. “Aslında burası hâlâ kitaplara hizmet ediyor.” İkisi aynı odayı şimdi daha farklı görüyordu. Eski ahşap dolap ise yıllar önce başka bir odaya taşınmıştı."
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
          "v": " hayalindeki gizli koridoru bulamamıştı ama yine de heyecanlandı. Çünkü aradıkları şeyin nereye götürüldüğünü öğrenmişlerdi. Depo okulun içinde, görevli eşliğinde girilen düzenli bir alandı. "
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
          "v": "Okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " yönetiminin izniyle depodaki eski dolap incelendi. Dolapta birkaç boş çekmece, kullanılmayan kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " destekleri ve üstünde “Bağışlar” yazan kalın bir defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " vardı. Sevim Hanım defteri dikkatle açtı. Sayfalar sararmıştı ama kayıtların çoğu okunuyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Büyük hazineyi bulduk!” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defteri eline almadan önce durdu. “Burada insanların isimleri olabilir. Her şeyi fotoğraflayıp paylaşmamalıyız,” dedi. Sevim Hanım onu onayladı. Eski kayıtların da kişisel bilgiler içerebileceğini, kullanılacak bilgilerin dikkatle seçilmesi gerektiğini anlattı. Sayfaları çevirirken kitap türlerinin zamanla nasıl değiştiğini gördüler. En eski kayıtlarda masal ve ansiklopedi çoktu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Daha sonraki yıllarda bilim"
        },
        {
          "t": "ikon",
          "v": "microscope"
        },
        {
          "t": "metin",
          "v": " dergileri, çizgi romanlar ve çocuk romanları artmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " türünü diğerinden üstün saymadı. Farklı zamanlarda, farklı çocukların farklı merakları olabileceğini düşündü. "
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
          "v": " bu sözleri küçük bir kartın üzerine yazdı; kütüphane düzenlenince görünür bir yere asmak istiyordu. Defterde, yıllar önce mahallede yaşayan insanların okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " kütüphanesine kitap gönderdiği yazıyordu. Bazı bağışlar tek kitaptı; bazıları ise bir sınıf dolusu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir sayfanın kenarına şu not düşülmüştü: “Bu kitapları okuyacak çocuklarla hiç tanışmayacağım. Yine de hepsine iyi yolculuklar dilerim.” Sevim Hanım usulca bir atasözü söyledi: “"
        },
        {
          "t": "atasozu",
          "yuva": "pd_ata_iyilik"
        },
        {
          "t": "metin",
          "v": ".” "
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
          "v": " notu okuyunca gözleri doldu. Bir kitabı hiç tanımadığı başka bir çocuğa gönderen kişinin ne kadar umutlu olması gerektiğini düşündü. On üçüncü rafın gizemi, ona bir odadan daha büyük bir şey göstermişti: Okulun zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " içinde büyüyen ortak hafızasını. "
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
          "v": " alınan şeyi dikkatle korumamız gerekir.” Sonra kütüphanedeki eski kitapları düşündü. Kitaplar, onları daha sonra okuyacak çocuklara kadar uzanan bir emanet gibiydi. Evinin rafındaki kitabı yerine koyarken yıpranmış bir sayfanın köşesini düzeltti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bu küçük hareket, ertesi gün kütüphanede yapacağı işin anlamını değiştirmişti. Artık yalnızca bir gizemi çözmüyor, kitapları gelecek okurlar için koruyordu. Kayıtları incelerken "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yeni bir sorun fark etti. Bağış defterindeki bir kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": ", dijital katalogda hiç görünmüyordu. Acaba kayıp mıydı? "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kitabın adını yeniden kontrol etti, yazarı ve sayfa sayısını not aldı. Sonra arama sonuçlarında farklı bir yazımla benzer bir kayıt buldu. Kitap vardı; yalnızca başlığı sisteme yanlış geçirilmişti. “Bu durumda kimse onu aradığında bulamaz,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". Sevim Hanım, eski ve yeni bilgileri karşılaştırarak düzeltme yapılabileceğini söyledi. Çocuklar kitabı rafında buldu. "
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
          "v": " kaydın doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " kitapla eşleştiğini işaretledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Afişi tasarlamak da kolay olmamıştı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ilk taslağa “Kayıp Hazine"
        },
        {
          "t": "ikon",
          "v": "chest"
        },
        {
          "t": "metin",
          "v": " Bulundu!” başlığını atmıştı. "
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
          "v": ", “Bence asıl ilginç olan bu,” dedi. İkili sonunda afişe “On Üçüncü Rafın Unutulan İyiliği” adını verdi. Böylece dikkat çekici bir başlığın gerçekleri değiştirmeden de yazılabileceğini gördüler. O gün pek çok çocuk kütüphaneye geldiğinde yeni bir afiş gördü: “Bir kitabın yolculuğunu merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " ettiniz mi?” Afişte kişisel bilgi bulunmuyordu. Yalnızca okul kütüphanesine yıllar boyunca yapılan bağışların sayısı, kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " türleri ve okuma köşesinin geçmişi anlatılıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Birinci sınıftan bir öğrenci afişin önünde durup sordu: “Bütün bu kitapları kim getirmiş?” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Çok farklı insanlar,” diye cevap verdi. “Bazıları kendi adını bırakmış, bazıları yalnızca kitaplarını. Ama hepsi bir gün birinin okumasını istemiş.” "
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
          "v": " renkli etiketlerin tasarımını yaptı. Sevim Hanım deneme için üç küçük öğrenciyi davet etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar en sevdikleri masal türünü birkaç dakika içinde bulabildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Araştırmamız başka okurların işini de kolaylaştırdı,” diye sevindi. On üçüncü rafın hikâyesi yeni düzenlemenin arkasında gizli kalmamış, kütüphaneyi daha kullanışlı kılmıştı. Haftanın sonunda yeni raf numaraları yerleştirildi. Bu kez hiçbir boşluk yoktu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " eski on üçüncü rafın yerine küçük bir işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " hazırladı: “Bir zamanlar burada bağış kitaplarının emanet dolabı bulunuyordu.” Sevim Hanım işareti okuma köşesine astı. Sevim Hanım küçük bir kütüphane etkinliği düzenlemelerini istedi."
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
          "v": ", eski dolabın fotoğrafını gösterince hep birlikte bu değişimin nedenini konuştular. Oyun sonunda öğrenciler bir kütüphanedeki düzenin de zamanla gelişebileceğini fark etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " eski raf planının bir kopyasını yeni planla yan yana astı. Böylece gelen ziyaretçiler iki farklı dönemi karşılaştırabiliyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir öğrenci “Peki sonraki yıllarda bu köşe yine değişir mi?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Değişebilir,” dedi. “Önemli olan değişirken geçmişi de anlamak.” Sevim Hanım onların hazırladığı açıklama kartlarını görünce her ikisine de teşekkür etti. Çocukların merakı kütüphanenin yalnızca geçmişini değil, bugünkü kullanımını da güzelleştirmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", gizemi çözdükleri için sevinçliydi ama buldukları defterin korunmasına daha çok önem veriyordu. Kaybolmuş bir kayıt, eski bir eşyanın yok olması anlamına gelmiyordu. Bazen doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " soruyu sormak, insanlara geçmişin izlerini yeniden görme fırsatı veriyordu."
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
          "v": " de aynı duygudaydı. Sır çözmek"
        },
        {
          "t": "ikon",
          "v": "lightning-idea"
        },
        {
          "t": "metin",
          "v": " güzel bir başlangıçtı; ortaya çıkan bilgiyi başkalarıyla paylaşmak ise hikâyeyi tamamlıyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " çıkışta, “Bir gün başka kayıp raf bulursak birlikte araştıralım mı?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güldü. “Önce gerçekten kayıp mı diye kontrol ederiz.” “Peki kayıp değilse?” "
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
          "v": " kütüphaneyi artık yalnızca macera aradığı bir yer değil, başkalarıyla paylaşabileceği bir çalışma alanı olarak gördüğünü fark etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İki arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " gelecek hafta küçük öğrencilere kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " seçmede yardımcı olmaya söz verdi. “O zaman"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " da neden öyle göründüğünü öğreniriz.” Bir sonraki hafta kütüphaneye gelen çocukların sayısı biraz arttı. Özellikle "
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
          "v": " artık gizem bulmak kadar onu doğru anlatmaktan da zevk alıyordu."
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
          "v": " artık kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " iade tarihi geldiğinde bunu bir yük olarak görmeyecekti. Kitabı zamanında geri getirirse başka bir okur onu beklediği yerde bulabilecekti. "
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
          "v": " ile birlikte buldukları defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": ", onu kitaplara daha yakından bakmaya davet etmişti. Artık kütüphaneye girdiğinde yalnızca yeni hikâye değil, eski bir iz"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": " de görebiliyordu. "
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
      "dayanak_sayfa": 10,
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
      "dayanak_sayfa": 12,
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
      "dayanak_sayfa": 14,
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
      "dayanak_sayfa": 15,
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
      "dayanak_sayfa": 23,
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
      "dayanak_sayfa": 10,
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
      "dayanak_sayfa": 17,
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pd_emanet",
        "tur": "kelime",
        "yazim": "emanet",
        "anlam": "Bir kişiye geçici olarak bırakılan ve korunması beklenen şey.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_bagis",
        "tur": "kelime",
        "yazim": "bağış",
        "anlam": "Karşılık beklemeden verilen kitap, eşya ya da para.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_arsiv",
        "tur": "kelime",
        "yazim": "arşiv",
        "anlam": "Eski belge ve kayıtların düzenli olarak saklandığı yer ya da bu belgelerin tamamı.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "pd_ata_iyilik",
        "tur": "atasozu",
        "yazim": "İyilik eden iyilik bulur",
        "anlam": "Başkalarına iyilik yapan kişi, zamanı gelince kendi de iyilikle karşılaşır.",
        "sinif_alt": 5,
        "sinif_ust": 5
      }
    ],
    "yuvalar": [
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
        "ad": "pd_ata_iyilik",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "pd_ata_iyilik"
          }
        ]
      }
    ]
  }
}$p43$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr045-kutuphanenin-on-ucuncu-rafi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p44${
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
        "kelime_sayisi": 3045,
        "tahmini_sure_dk": 27,
        "sayfa_sayisi": 33,
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
        "simge_sayisi": 66
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
          "v": " ise aklına geleni hemen seslendirirdi. Araştırma masasında birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " oldukları ilk gün "
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
          "v": " Serginin hazırlıkları üç haftadır sürüyordu."
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
          "v": ", fotoğrafları asan ekibe yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " ederken birbirine benzeyen karelerin ne kadar farklı hikâyeler anlatabileceğini fark etmişti. Bazılarında tören kıyafetleri, bazılarında sıradan okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " günleri vardı. Bir fotoğrafta tek bir kişinin adı bilinirken, diğerinde koca bir sınıfın yalnızca yılı yazıyordu. Sibel Hanım her fotoğrafın altına “Bu bilgiyi nereden biliyoruz?” sorusunu yazmalarını istemişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce bunu gereksiz buldu. Ona göre eski fotoğraf kendi başına yeterince gerçekti. Fakat etiketteki tarihi sorgulamaya başladığında bir fotoğrafın gerçekten var olmasının, altında yazan her bilginin doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " olduğu anlamına gelmediğini gördü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Okulun kuruluş yıldönümü sergisinde en çok konuşulan şey yeni spor"
        },
        {
          "t": "ikon",
          "v": "ball"
        },
        {
          "t": "metin",
          "v": " salonu değil, duvardaki eski bir fotoğraftı. Fotoğrafın altında “1984'te İlk Mezunlarımız” yazıyordu. Fakat fotoğraftaki çocukların önünde duran postane binası, bugünkü yerine taşınmadan önceki eski binaya benziyordu. Altıncı sınıftan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu fark etti çünkü dedesi ona kasabanın eski fotoğraflarını göstermişti. "
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
          "v": " ondan birkaç adım geriye gelmesini istedi. Böylece kadrajın tamamını görebildi. Ön planda öğrenciler vardı, arkada ise iki farklı bina seçiliyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Bazen ayrıntı için yaklaşmak, bütünü görmek için uzaklaşmak gerekir,” dedi "
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
          "v": " bu cümleyi beğendi; araştırmalarında da aynı yaklaşımın işe yarayabileceğini düşünmeye başladı. "
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
          "v": " başka bir ayrıntı fark etti. Binanın önünde bekleyen bisikletin modeli eskiydi ama hangi yıllarda kullanıldığını bilmiyorlardı. “Bu ipucuyla yıllar arasında tahmin yapabilir miyiz?” diye sordu. Sibel Hanım, farklı ipuçlarını birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " değerlendirebileceklerini söyledi; ancak bir bisiklet"
        },
        {
          "t": "ikon",
          "v": "bicycle"
        },
        {
          "t": "metin",
          "v": " modelinin satıldığı yılın fotoğrafın kesin çekim yılı sayılamayacağını da ekledi. Çünkü insanlar bir eşyayı uzun yıllar kullanabilirdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " fotoğrafın kenarına görünmez bir soru"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " işareti koymuş gibi hissetti. Tek bir resim, beklediğinden daha fazla bilgi ve daha fazla belirsizlik taşıyordu."
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
          "v": " bulabiliriz.” "
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
          "v": " kenarına boş bir kâğıt yerleştirdi; ilerledikçe buldukları kanıtları aynı yerde tutacaklardı. İkisi farklı kalem"
        },
        {
          "t": "ikon",
          "v": "pencil"
        },
        {
          "t": "metin",
          "v": " renkleri kullandı: maviyle gördüklerini, turuncuyla tahminlerini yazdılar. Bu düzen, daha sonra bir tahminin nasıl yanlışlıkla kesin bilgiye dönüşebileceğini fark etmelerine yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " edecekti. "
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
          "v": " araştırma masası kurdu. İlk bakışta fotoğrafın tarihini değiştirmek kolay görünüyordu: “Dedem öyle dedi,” yazmaları yeterli sanmışlardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Fakat Sibel Hanım birinin hatırladığı şeyin değerli bir ipucu olabileceğini, tek başına kesin kanıt sayılmayacağını anlattı. Dede Ali, torununun heyecanını görünce çocukluğunu anlatmaya başladı. İlkokula giderken okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " yolunun iki yanında kavak ağaçları olduğunu, postanenin yanından geçerken her gün aynı saatlerde bisikletli bir dağıtıcı gördüğünü hatırlıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hikâyeyi dinlerken notlar aldı. Sonra dedesinin iki kez durup “Yoksa o ağaçlar başka sokakta mıydı?” dediğini duydu. Büyüklerin anılarının bazen birbirine karışabileceğini ilk kez bu kadar açık gördü. Dedesi bundan utanmadı; tam tersine, eski adres defterini bularak hatırladıklarını kontrol etmek istedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " araştırması artık geçmişte olanları tahmin etmekten çok, farklı hatıraları belgelerle karşılaştırma işine dönüşüyordu. O gün "
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
          "v": " ise yarım basılmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " heyecanı arttı. “Belki fotoğrafın tarihini bu pul söyleyecek!” Dedesi zarfı ona vermeden önce uyardı: “Bu eski bir aile"
        },
        {
          "t": "ikon",
          "v": "house"
        },
        {
          "t": "metin",
          "v": " belgesi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İzin almadan paylaşmayacaksın. Bir de dikkat et, pulun basıldığı yıl mektubun gönderildiği yılla aynı olmayabilir.” Dede Ali gece yatmadan önce "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": " bir hikâye"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " daha anlattı. Gençken mektupları postaya vermek için kasabanın diğer ucuna yürüdüğünü, bazen de cevabı haftalarca beklediğini söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bugün bir mesaj"
        },
        {
          "t": "ikon",
          "v": "scroll"
        },
        {
          "t": "metin",
          "v": " gönderdikten sonra birkaç saniye içinde karşılık beklemeye alışmıştı. “O kadar beklemek zor değil miydi?” diye sordu. Dedesi, “Bazen zordu, ama her haber geldiğinde zarfı dikkatle açardık,” dedi. Sonra eski zarfa işaret etti. “Bu da birinin yolculuğundan kalan iz"
        },
        {
          "t": "ikon",
          "v": "footprint"
        },
        {
          "t": "metin",
          "v": ".” "
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
          "v": ", birinin mektubu evde bekletip sonra gönderebileceğini anlattı. Üstelik posta damgası da her zaman açık okunmazdı. Altlarına aynı kalemle yazmak yerine farklı renkler"
        },
        {
          "t": "ikon",
          "v": "rainbow"
        },
        {
          "t": "metin",
          "v": " seçtiler. Böylece tarihleri karıştırmaları zorlaşacaktı. "
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
          "v": " önceden bu üç zamanı tek bir sayı olarak düşündüğünü fark etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Artık defterin sayfasındaki renkli çizgiler ona daha mantıklı görünüyordu. Çocuklar araştırma defterine “pulun basım dönemi”, “zarfın gönderim tarihi” ve “fotoğrafın çekim tarihi” diye üç ayrı başlık açtı. Bu küçük ayrım olmasaydı, birini ötekinin yerine kullanıp yanlış sonuç çıkarabilirlerdi. Ertesi sabah "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", pulu büyüteç"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " altında incelemek için kütüphane sorumlusundan yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " istedi. Pulun üzerinde bir kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": ", altında iki küçük rakam ve silik bir yazı vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk bakışta yıl sandığı rakamların aslında pulun parasal değeri olabileceğini fark etti. “Yani pulun üstündeki her sayı tarih değildir,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". İkili posta tarihçesiyle ilgili güvenilir bir katalog aradı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kütüphanedeki eski bir kitapta benzer kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " resimli pullar vardı ancak desenlerin rengi farklıydı. "
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
          "v": " itiraz etti: “Benziyor diye aynı demeyelim. Bak, kanat çizgisinde fark var.” Müze kataloğundaki resimlerden birinin altında bir koleksiyonerin notu vardı: “Benzer motifler, farklı baskılar.” "
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
          "v": " ilk anda bunların hepsini tek seri sandı. Sonra pul üzerindeki yazıların, desenin ve boyutların birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " değerlendirilmesi gerektiğini öğrendiler. Bir resmi tanımakla onu doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " sınıflandırmanın aynı şey olmadığı ortaya çıkıyordu. "
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
          "v": " bu listeyi görünce yalnızca bir ayrıntıya takılmak yerine bütünü değerlendirebildi. “Demek bu küçük pulda bile birçok ipucu var,” dedi. Katalogdaki açıklama, bazı pul serilerinin farklı yıllarda ve değişik renklerde basıldığını söylüyordu. Çocuklar pulun olası serisini belirlediler ama yılı kesinleştiremediler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sibel Hanım, ilçe müzesindeki posta tarihi köşesi için randevu aldı. Müzenin girişinde "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", üzerlerinde kasabanın eski sokaklarının resimleri bulunan zarflar gördü. Bazı zarfların köşesi yıpranmış, bazıları ise oldukça iyi korunmuştu. Emine Hanım, eski belgeleri doğrudan güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " ışığından korumanın ve gerektiğinde uygun koşullarda saklamanın önemini anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " elindeki belgeyi sürekli bir çantadan diğerine taşımanın iyi fikir"
        },
        {
          "t": "ikon",
          "v": "idea"
        },
        {
          "t": "metin",
          "v": " olmayabileceğini düşündü. Bu nedenle dedesinin zarfını evde bırakmış, müzeye yalnızca yüksek çözünürlüklü görüntüsünü getirmişti. Uzman bunun yerinde bir başlangıç olduğunu söyledi; fotoğrafın belgeyi tamamen incelemeye yetmeyebileceğini de hatırlattı. Çocuklar hangi bilginin görselden, hangisinin asıl belgeden öğrenilebileceğine dikkat etmeye başladı. Müzede görevli Emine Hanım, pulu fotoğraf üzerinden inceledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Burada asıl önemli ipucu zarfın damgası olabilir,” dedi. “Posta damgasında tarih bulunur. Fakat silinmiş kısmı tahmin etmeyin.” Kâğıttaki çizim ilk denemede çok belirsiz olmuştu. "
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
          "v": " ikinci çizimde yalnızca gerçekten gördüğü çizgileri aktardı; kalan kısmı boş bıraktı. Bu küçük değişiklik, doğru bir kayıt tutmanın cesaret"
        },
        {
          "t": "ikon",
          "v": "courage"
        },
        {
          "t": "metin",
          "v": " gerektirebildiğini ona gösterdi. Çünkü herkes tamamlanmış bir şekil görmek isterdi, oysa bazen dürüst olan boşluk bırakmaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yarım damgayı kâğıda çizdi. Görünen rakamları işaretledi, görünmeyen yerlere soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " işareti koydu. Daha önce böyle yapmaktan hoşlanmazdı; eksik bilgi onu sabırsızlandırırdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Şimdi soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " işaretlerinin araştırmanın dürüst bir parçası olduğunu anlamaya başlamıştı. "
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
          "v": " bunun çok geniş bir hedef olduğunu söyledi. Planı “Fotoğrafın çekilmiş olabileceği yıllara ait okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " yıllıkları ve bina kayıtları” diye daralttılar. Böylece saatlerce rastgele dosya açmak yerine belirli soruların peşine düşebildiler. Arşiv görevlisi de hangi klasörlerin uygun olduğunu gösterdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " plan yapmanın keşfi yavaşlatmadığını; tam tersine, zamanı daha iyi kullanmalarını sağladığını anladı. Sibel Hanım'ın okul arşivinde yaptığı araştırma yeni bir ipucu getirdi. Aynı fotoğrafın ikinci bir kopyası bulundu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk kopyanın altında 1984 yazarken ikincisinin arkasında el yazısıyla farklı bir tarih bulunuyordu. Bu iki tarih birbirini tutmuyordu. “Demek biri yanlış,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Belki de ikisi de daha sonra yazılmış,” diye karşılık verdi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Önce fotoğrafın kendisine bakalım.” Fotoğraftaki okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " binasının girişine asılmış bir afiş vardı. Afişte, o yıl düzenlenen bir bilim"
        },
        {
          "t": "ikon",
          "v": "microscope"
        },
        {
          "t": "metin",
          "v": " sergisinin adı okunuyordu. Çocuklar okulun eski yıllıklarını incelediler. Aynı bilim sergisinin bir başka fotoğrafını buldular. Orada tarih daha açık yazılmıştı. Yıllıkların birinde sınıf fotoğraflarının altında tarih, diğerinde yalnızca öğretmen adı vardı. "
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
          "v": " bunların başka bilgiler taşıyabileceğini söyledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Örneğin okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " binasının duvarındaki süsleme, yıllıkların birinde açıkça görünüyordu. İkili bu işareti sergi fotoğrafındaki duvarla karşılaştırdı. Tam eşleşme bulamadılar fakat yeni sorulara ulaştılar: Fotoğraf bir ders günü mü, özel bir tören sırasında mı çekilmişti? Hangi öğretmenler o dönemde okulda çalışıyordu? "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", belgelerde eksik olan bir bilginin başka belgedeki ayrıntılarla araştırılabileceğini öğreniyordu. Ancak yeni kanıt da tek başına yeterli değildi. Bilim"
        },
        {
          "t": "ikon",
          "v": "microscope"
        },
        {
          "t": "metin",
          "v": " sergisi birkaç yıl üst üste düzenlenmiş olabilirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu düşününce biraz öfkelendi. “Her ipucu başka bir soruya dönüşüyor!” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gülümsedi. “Belki araştırma böyle bir şeydir. Yanlış cevabı hemen bulmaktansa doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " cevaba yaklaşmak.”"
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
          "v": ", yanıt vermeyen bir ipucunun bile başka bir öğrenme fırsatı yaratabildiğini düşündü. "
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
          "v": ", gölgeye bakarak günü bile tahmin edebileceklerini düşündü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sibel Hanım, güneşin konumunun saat"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " ve mevsimle ilişkili olduğunu ama fotoğrafın kesin tarihini böyle belirlemenin kolay olmadığını söyledi. Binaların duruşunu, çekim açısını ve başka koşulları bilmeden iddialı sonuçlara gidilemezdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yine de bu öneriden bir şey öğrendi: Aynı nesneye farklı derslerde kazanılan bilgilerle bakılabilirdi. Matematik"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": ", tarih, fen ve Türkçe, bir araştırma masasında birbirine yaklaşabiliyordu. "
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
          "v": " yöntemi olmadığını söyledi. Aynı kıyafetler yıllarca giyilebilirdi. Çocuklar fikirlerini küçümsemek yerine her kanıtın gücünü değerlendirmeyi öğrendi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi hafta dede, "
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
          "v": " yürürken her köşeyi fotoğraflamaya kalkıştı. Dedesi onu durdurdu: “Bir de bakarak gez. Bütün anıları ekrandan görmek"
        },
        {
          "t": "ikon",
          "v": "glasses"
        },
        {
          "t": "metin",
          "v": " zorunda değilsin.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " telefonu cebine koydu. Yıllardır aynı sokakta yaşayan insanların binaları farklı isimlerle anabileceğini, yerlerin işlevinin zamanla değişebileceğini düşündü. Sokaktaki tabelalar ona bir yerin adıyla tarihinin de farklı kavramlar olduğunu hissettirdi. Eve dönünce bu gözlemi araştırma notlarına ekledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Dede Ali daha sonra evdeki küçük masa çekmecesinden bir davetiye buldu. Davetiyede eski okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " binasının bir etkinliğine ilişkin tarih vardı. "
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
          "v": " bu bilgiyi belediyenin erişime açık tarihî adres kayıtlarıyla karşılaştırmak için öğretmenine danıştı. Kayıtlarda okulun bir dönem geçici bir binada eğitim verdiği görülüyordu. Bu bilgi, fotoğraftaki arka planda neden beklenmeyen binaların göründüğünü açıklıyordu. Çocukların önünde duran yapının gerçekten eski postane olması mümkündü; fotoğraf okulun geçici binasının önünde çekilmiş olabilirdi. Yine de kesin tarih bilinmiyordu. Bu arada okulda farklı tahminler yayılmaya başladı. Bazıları fotoğrafta tanınan bir öğretmenden söz ediyor, bazıları da sergide yazan tarihin zaten doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " olduğunu savunuyordu."
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
          "v": " ilk kez bunun sadece kendi merakı olmadığını gördü. Yanlış bir tarih, insanların aile"
        },
        {
          "t": "ikon",
          "v": "house"
        },
        {
          "t": "metin",
          "v": " hikâyelerini de etkileyebilirdi. Sibel Hanım bu yüzden açıklamayı değiştirmeden önce okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " yönetimine kısa bir kaynak özeti sunmalarını istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " “Kesin bilmediğimiz şeyi de yazalım mı?” diye sordu. “Özellikle onu yazacağız,” dedi öğretmen. “Belirsizliği gizlemek, başkalarının doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " bir karar vermesini zorlaştırır.” Müze görevlisi Emine Hanım, yeniden iletişime geçti. Pulun belirli bir dönemde kullanılan bir seriye benzediğini, ancak damganın fotoğrafından kesin yıl okunamadığını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yonelme"
        },
        {
          "t": "metin",
          "v": ", pulu uzman görmeden “kesin şu yıla ait” etiketi koymamalarını önerdi. “Peki sergide ne yazacağız?” diye sordu "
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
          "v": "Sibel Hanım, “Bildiğimizi yazacağız. Bilmediğimizi de açıkça belirteceğiz,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " buna önce şaşırdı. Bir müzedeki açıklamanın soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " işaretiyle bitebileceğini düşünmemişti. Fakat araştırmanın asıl değerinin kesin konuşmak değil, kanıtları dürüstçe kullanmak olduğunu yavaş"
        },
        {
          "t": "ikon",
          "v": "turtle"
        },
        {
          "t": "metin",
          "v": " yavaş kavradı. Etiketi hazırlamadan önce "
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
          "v": " ilk soruya aceleyle “Hayır” dedi, sonra devamını getiremedi. Bir süre durup “Mevcut kaynaklarda çelişki var; bu yüzden yılı araştırıyoruz” diye yeniden cevapladı."
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
          "v": " onun ne demek istediğini artık daha kolay anlıyordu. Sibel Hanım bu provayı görünce sevinçle “Bilmediğinizi açıkça söyleyebilmeniz güven"
        },
        {
          "t": "ikon",
          "v": "shield"
        },
        {
          "t": "metin",
          "v": " verir,” dedi. "
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
          "v": " başta güçlü konuşmayı çok seviyordu. Şimdi doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " bir çekingenliğin de güven verici olabileceğini görüyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sergi açılışından bir gün önce yeni etiket hazırlandı. Üstte şöyle yazıyordu: “Okulun eski dönemlerinden bir grup öğrenci. Kesin çekim yılı araştırılıyor.” Altında, fotoğrafın farklı kopyalarındaki tarihlerin neden uyuşmadığı, hangi belgelerin incelendiği ve hangi soruların açık kaldığı anlatılıyordu. "
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
          "v": " da aynı fikirdeydi; çalışmanın öğretmenler, arşiv görevlileri, dede ve müze uzmanıyla birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " yapıldığını düşünüyorlardı. Sonunda hepsine teşekkür eden kısa bir not"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " eklediler. İki öğrenci etiketteki “araştırılıyor” sözcüğünü görünce merakla yanlarına geldi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce bütün çalışmayı anlatmak istedi."
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
          "v": " ona yalnızca üç önemli noktayı söylemelerini önerdi: Farklı tarihler var, belgeler karşılaştırıldı ve kesin sonuç henüz bulunmadı. Ziyaretçiler bu kısa açıklamayı daha kolay anladı. Ayrıntı isteyenlere ise hazırladıkları kaynak dosyasını gösterdiler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", anlatımın uzunluğunu dinleyenin ihtiyacına göre ayarlamanın da araştırmanın bir parçası olduğunu fark etti. Sergi günü ziyaretçiler fotoğrafın önünde daha uzun süre durdu. Bazıları kendi aile"
        },
        {
          "t": "ikon",
          "v": "house"
        },
        {
          "t": "metin",
          "v": " albümlerindeki eski okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " fotoğraflarını hatırladı. Bir veli, “Bu fotoğraf bende de olabilir,” dedi. Okul yönetimi, isterse görüntüyü aileden izin alarak karşılaştırabileceklerini söyledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sergiye gelen bir başka ziyaretçi, eski fotoğraftaki çocuklardan birinin kendi akrabası olabileceğini söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hemen adını yazmak istemedi. Önce kişinin söylediklerinin ailesindeki bir fotoğrafla desteklenip desteklenemeyeceğini sordu. Ziyaretçi bunun zaman alacağını ama araştırmaya katılmaktan mutluluk"
        },
        {
          "t": "ikon",
          "v": "joy"
        },
        {
          "t": "metin",
          "v": " duyacağını belirtti. Sibel Hanım, okulun kişisel bilgileri koruyan bir iletişim yolu kullanacağını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " böylece bir gizemi çözmek"
        },
        {
          "t": "ikon",
          "v": "lightning-idea"
        },
        {
          "t": "metin",
          "v": " uğruna insanların adlarını, fotoğraflarını ve hatıralarını gelişigüzel paylaşmamaları gerektiğini de öğrendi. Dede sergiye geldiğinde "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " yanında durdu. “Biliyor musun,” dedi, “ben de başta eski postaneyi görünce tarihi kesin sandım."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Senin soruların bana hatırlamakla kanıtlamanın farkını öğretti.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güldü. “Ben de senin zarfın sayesinde araştırmaya başladım.” Sergi bittikten sonra öğretmenleri öğrencilere bir soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " daha yöneltti: “Bir araştırmayı ne zaman tamamlanmış sayarsınız?” "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", amaçlarının her ayrıntıyı kesinleştirmek değil, eldeki bilgiyi olabildiğince doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " sunmak olduğunu söyledi. "
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
          "v": ", pulun fotoğrafını açıklama panosuna ekledi. Ancak üstüne büyük harflerle “Fotoğrafın tarihini tek başına kanıtlamaz” yazdı. Bu cümle, sergideki en önemli bilgilerden biriydi. Serginin sonunda bir grup öğrenci "
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
          "v": ", asıl fotoğrafın geçmişten gelen bir belge olduğunu; değişen şeyin ona eklenen açıklama olduğunu söyledi. Fotoğrafı silmek veya değiştirmek yerine doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " bilgiyi aramak daha anlamlıydı. Çocuklar bir süre birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " kareye baktılar. Bazısı pencereleri, bazısı öğrencilerin ellerindeki defterleri fark etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onları dikkatle dinledi. Aynı kareye bakan insanların farklı ayrıntılar görmesi hoşuna gitti, çünkü hiçbiri diğerinin gördüğünü yok etmiyordu. Araştırmayı paylaşmak yeni sorulara kapı aralıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yıldönümü töreninden sonra "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " arşiv defterini kapatırken zarfın bir kopyasına yeniden baktı. Kuş"
        },
        {
          "t": "ikon",
          "v": "bird"
        },
        {
          "t": "metin",
          "v": " resimli pul artık ona eski bir eşya gibi görünmüyordu. O pul, yıllar önce birinin bir başkasına gönderdiği haberin küçük bir parçasıydı. Üzerindeki silik damga belki bir gün okunabilecekti, belki de hiçbir zaman kesinleşmeyecekti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ", “Keşke bütün sırları çözebilseydik,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını salladı. “Ben de isterdim. Ama artık çözemediğimiz kısmı uydurmamamız gerektiğini biliyorum.” Birlikte"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " arşive yeni bir dosya açtılar. Dosyanın başlığı “Doğrulananlar ve Açık Sorular” oldu. İçine fotoğrafları, kaynak listelerini ve araştırma notlarını koydular. Zarfın aslı ailesinde güvenle saklandı; okulda yalnızca izinli bir kopyası kullanıldı."
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
          "v": " gülümsedi. “Ancak o saatin neden orada olduğunu ve resmin ne zaman çekildiğini araştırırsak biraz daha yaklaşırız.” Çocuklar artık her eski nesneyi bir tarih makinesi sanmıyordu. Ama her nesnenin yeni bir soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " doğurabileceğini biliyorlardı. O akşam "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterinin son sayfasına küçük bir posta pulu çizdi. Kuşun kanadının yanına şöyle yazdı: “Geçmişten gelen her işaret"
        },
        {
          "t": "ikon",
          "v": "flag"
        },
        {
          "t": "metin",
          "v": " bir kapı açabilir. Ama o kapıdan geçerken kanıtı da yanımıza almalıyız.” "
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
      "dayanak_sayfa": 17,
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
      "dayanak_sayfa": 22,
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
      "dayanak_sayfa": 10,
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
      "dayanak_sayfa": 27,
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
      "dayanak_sayfa": 5,
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
      "dayanak_sayfa": 14,
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
      "dayanak_sayfa": 20,
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
      "dayanak_sayfa": 24,
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pd_kanit",
        "tur": "kelime",
        "yazim": "kanıt",
        "anlam": "Bir iddianın doğru ya da yanlış olduğunu gösteren belge veya bilgi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "pd_damga",
        "tur": "kelime",
        "yazim": "damga",
        "anlam": "Bir zarfın ya da belgenin üstüne basılan, yer ve tarih gibi bilgileri gösteren işaret.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "pd_tarihleme",
        "tur": "kelime",
        "yazim": "tarihleme",
        "anlam": "Bir belgenin ya da nesnenin ne zaman yapıldığını belirlemeye çalışma.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "pd_ata_acele",
        "tur": "atasozu",
        "yazim": "Acele işe şeytan karışır",
        "anlam": "Bir işi çok hızlı yapmaya çalışınca hata yapılır; sakin ve düşünerek davranmak gerekir.",
        "sinif_alt": 6,
        "sinif_ust": 6
      }
    ],
    "yuvalar": [
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
        "ad": "pd_ata_acele",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "pd_ata_acele"
          }
        ]
      }
    ]
  }
}$p44$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr046-bilinmeyen-posta-pulu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p45${
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
        "kelime_sayisi": 3055,
        "tahmini_sure_dk": 27,
        "sayfa_sayisi": 36,
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
        "simge_sayisi": 69
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
          "v": "Okulun satranç kulübü, boş bir sınıfta eski bir kırmızı defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " buldu. Defterin kapağında yalnızca “Nöbet Devir Teslimi” yazıyordu. İçinde küçük tablolar, okunması zor notlar ve uzun sayı"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " dizileri vardı. Altıncı sınıftan "
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
          "v": ".” İrem iki arkadaşın yöntemlerini birleştirmelerini önerdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“"
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
          "v": " "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " bu maceraya özel bir nedeni daha vardı. Geçen dönem satranç turnuvasında bütün hamlelerini hesapladığını düşünmüş, son oyunda acele bir karar verip yenilmişti. Herkes ona “Biraz düşünseydin” demişti. O günden beri rakamlarla ilgili bir yarış gördüğünde kendini ispatlamak istiyordu. Kırmızı defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " de ona böyle bir fırsat gibi görünmüştü. Fakat İrem'in sakinliği ve "
        },
        {
          "t": "yoldas",
          "hal": "ilgi",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " farklı soruları, araştırmanın turnuvadan farklı bir şey olduğunu hatırlatacaktı. Bu kez kazanılacak tek bir madalya yoktu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir belgenin ne anlattığını birlikte anlamaları gerekiyordu. Defteri ilk fark eden "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " olmuştu. Satranç tahtalarının kaldırıldığı dolabın en altında, tahta kutuların arasına sıkışmıştı. Kırmızı kapak yıpranmıştı ama köşesine yapıştırılan küçük beyaz etiket hâlâ duruyordu. İrem defteri bulduklarında hemen açmamalarını önerdi. Kulüp odası okulun ortak alanıydı; bulunan eşya başka bir birime ait olabilirdi. Öğretmenlerine haber verdikten sonra defterin okulun eski kütüphane deposundan taşınan malzemelerden biri olduğu anlaşıldı. Bu açıklama, sayıların oyun puanı olabileceği fikrini zayıflatmadı; çünkü eski yıllarda kütüphane kulüpleri de yarışmalar düzenlemiş olabilirdi."
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
          "v": " iki seçeneği de not etti. Daha araştırmaya başlamadan farklı açıklamaların mümkün olduğunu görmüştü. "
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
          "v": " ise dikkatliydi; bazen bir hamlenin sonucunu görmek"
        },
        {
          "t": "ikon",
          "v": "glasses"
        },
        {
          "t": "metin",
          "v": " için birkaç dakika susabilirdi. Bu ikisinin anlaşması kolay değildi. Kırmızı defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " onların birlikte çözeceği ilk ciddi araştırmaydı. İrem, “Burada yarışmıyoruz,” dedi. “Önemli olan kimin önce bildiği değil, nasıl bildiğimiz.” "
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
          "v": " kapağın içindeki eski okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " mührünü fark etti. Mühür, defterin hangi kuruma ait olabileceğine ilişkin önemli bir ipucuydu. İrem, “Önce belgenin kimliğini anlayalım,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu kez onun sözünü kesmedi. Çünkü mühür olmasa defterdeki sayıların okul kütüphanesiyle ilişkisini çok daha geç kuracaklardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk sayfaya baktığında şaşırdı: 104, 107, 110, 113... Her yeni sayı"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " bir öncekinden üç büyüktü. “Bu bir oyun skoru olabilir,” dedi takım arkadaşı "
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
          "v": "“Belki kazananlara üç puan vermişler.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " itiraz etmedi. Ama hemen yanındaki listede 502, 504, 506 gibi başka bir dizi vardı. Puanların neden bir sayfada üçer, başka sayfada ikişer arttığını anlamıyordu. Defteri bulan kulüp başkanı İrem, kapakta “Nöbet” yazdığına dikkat çekti. “Önce defterin ne için tutulduğunu öğrenmeliyiz,” dedi. “Başkasının eşyasını izinsiz karıştırmak da doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " değil.” Öğretmenleri Arif Bey'e danıştılar. Öğretmen, defterin yıllar önce okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " kütüphanesinde görevli olan öğrenciler tarafından tutulmuş olabileceğini söyledi. Defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " okulun eski evrakları arasından çıkmıştı; içindekilerin incelenmesi için kütüphane sorumlusuyla görüşeceklerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sayıların bir dil gibi olduğunu düşünmeye başlamıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eğer dili çözebilirlerse kimin, ne zaman, neyi kaydettiğini öğrenebileceklerdi. Fakat şifrenin anlamını bulmak"
        },
        {
          "t": "ikon",
          "v": "idea"
        },
        {
          "t": "metin",
          "v": " için daha fazla ipucu gerekiyordu. İlk araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " oturumunda Münevver Hanım öğrencilere renkli küçük kâğıtlar verdi. Her kâğıda bir "
        },
        {
          "t": "kelime",
          "yuva": "pd_varsayim"
        },
        {
          "t": "metin",
          "v": " yazmalarını istedi: “Oyun puanı”, “Kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " kodu”, “Sıra numarası” ve “Başka bir kayıt”. Ardından her varsayımın altına onu destekleyen veya zayıflatan bilgileri koyacaklardı. "
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
          "v": " ise kitap kodu seçeneğini ortaya atmış olmanın gururunu yaşıyordu. İrem, “Sevdiğimiz fikri korumaya değil, doğru olanı bulmaya çalışıyoruz,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İki arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": " önce itiraz etti, sonra bu yöntemle soruları daha kolay sıraya koyabildiklerini gördü. Münevver Hanım masanın üzerine temiz bir örtü serdi. Eski defteri doğrudan güneş"
        },
        {
          "t": "ikon",
          "v": "sun"
        },
        {
          "t": "metin",
          "v": " ışığı almayan bir yerde açmalarını istedi. "
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
          "v": "Ertesi gün kütüphane sorumlusu Münevver Hanım, defteri kontrollü biçimde incelemelerine izin verdi. Bazı sayfalarda öğrenci isimleri olduğu için bunları herkesin göreceği şekilde paylaşmamalarını istedi. Çocuklar yalnızca kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " kodu olabilecek sayıları inceleyeceklerdi. Örüntünün ilk kuralını bulunca "
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
          "v": " aynı kuralı hemen uyguladı ve şaşırdı. Yeni dizinin farkı farklıydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Kuralı öğrenmek yetmiyor,” dedi. “Hangi diziye uyguladığını da bilmen gerek.” İrem bu sözü defterine yazdı. Matematikte kurallar güçlü araçlardı ama her durumda aynı kural kullanılmazdı. "
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
          "v": " bulduk, ama neyi gösterdiğini bilmiyoruz,” diye hatırlattı. Aynı sayfanın altındaki ikinci dizi 502, 504, 506, 508 diye gidiyordu. Üçüncü sayfada ise 211, 311, 411 vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir süre düşündü. Sayılar farklı kurallarla artıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bu durum oyun puanı açıklamasını zayıflatıyordu. Rafların önünde renkli etiketler vardı. "
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
          "v": " ilk anda onlara kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " kodunu söylemeye hazırlanmıştı. Ancak çocuklar henüz kodları öğrenmediklerini söyledi. "
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
          "v": ", farklı yaşlarda aynı bilgiye ulaşmak için farklı yollar kullanılabileceğini gördü. Bu deneyim ileride hazırlayacakları oyun etkinliğinin tasarımını da etkiledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Birinci sınıftan gelen iki çocuk hayvanlar hakkındaki kitabı arıyordu. "
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
          "v": ", kütüphane düzeninin sıradan gibi görünen ayrıntılarının bile okurlara yardımcı olabildiğini fark etti. Eski defterdeki sayıların da zamanında böyle bir işlevi olabilir miydi? Kütüphanenin raflarında dolaşırken "
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
          "v": ". İrem hemen yeni bir tablo oluşturdu: “Sayı, olası açıklama, kanıt.” İlk satıra “104 — kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " kodu olabilir — henüz doğrulanmadı” yazdı. Araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " sırasında "
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
          "v": " bunun gizli kulüp rengini temsil ettiğini söyledi. Münevver Hanım gülerek cevap verdi: “Belki de o yıllarda kırtasiyede yalnızca kırmızı defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " bulunuyordu.” Çocuklar bir nesnenin her özelliğinin özel anlam taşımak zorunda olmadığını fark etti. Yine de kapak rengi onlara güzel bir isim vermişti: Kırmızı Defterin Şifresi."
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
          "v": " bu adı araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " defterinin başına yazdı ama altına küçük harflerle “Şifre sözcüğü burada merak için kullanılmıştır” notunu ekledi. İlk kartı incelerken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kitabın adını yanlış okudu. Eski el yazısındaki harfler birbirine benziyordu. İrem daha yavaş"
        },
        {
          "t": "ikon",
          "v": "turtle"
        },
        {
          "t": "metin",
          "v": " okuyup kitabın gerçek adını yazdı. “Ben olsam ilk gördüğüm gibi kaydederdim,” dedi "
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
          "v": " bu kez acele etmedi. “Belki başka kartta daha okunaklıdır,” diye önerdi. Aradılar ve kitabın ikinci bir kaydını buldular. İki kayıt arasındaki farkı belirleyince bir sayının tek başına kaybolmuş bir kitabı göstermediğini, bazen aynı kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " için farklı kayıtlar da bulunduğunu anladılar."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Katalog kartlarının köşeleri farklı renklerle boyanmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun kitapların içerikleriyle ilgili olduğunu düşündü. Münevver Hanım renklerin eski bir raf sistemine bağlı olabileceğini söyledi, ancak elindeki kayıtta açık bir açıklama bulunmadığını ekledi. Çocuklar bunu araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " listesine yeni bir soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": " olarak yazdılar. Münevver Hanım çocuklara eski katalog kartlarından birini gösterdi. Kartta kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " adı, yazar, kayıt numarası ve eski raf yeri yazıyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " eski kartlardan birinde 107 sayısını görünce sevinçle bağırdı: “Şifreyi çözdük!” İrem onu durdurdu. “Bir tane eşleşme yeterli değil.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ikinci kitabın kartını açtı; burada 110 yazıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sonra başka bir kartta 113'ü buldular. Üç farklı eşleşme artık tesadüf ihtimalini azaltıyordu. İrem diziyi bir de yatay satırlar hâlinde okumalarını istedi. "
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
          "v": " yöneltti: “Bir tabloyu yanlış sırayla okursan doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " sayılar seni yanlış sonuca götürür mü?” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Evet,” dedi. “Rakamlar değişmez ama aralarındaki ilişkiyi yanlış anlayabiliriz.” Bunun üzerine üç arkadaş"
        },
        {
          "t": "ikon",
          "v": "friends"
        },
        {
          "t": "metin",
          "v": ", küçük sınıfların kullanabileceği çizimli bir tablo hazırladı. İçinde meyve sepetleri vardı ve sayılar her sütunda farklı biçimde ilerliyordu. Böylece soyut buldukları ilişkiyi anlaşılır bir örnekle göstermiş oldular. Münevver Hanım bu etkinliği daha sonra kulüp saatinde kullanabileceklerini söyledi."
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
          "v": " yüzü aydınlandı. “Aynı sayılar, okuma yönüne göre farklı bir dizi gibi görünmüş!” dedi. İrem, “Demek tablo biçimini bilmeden yalnızca rakamlara bakmak yetmez,” diye ekledi. Bu küçük keşif, çocuklara basit bir satır-sütun düzeninin ne kadar önemli olduğunu gösterdi. Fakat dizi neden üçer artıyordu? Kütüphane sorumlusu, eski sistemde bazı raf listelerinin birden fazla sütun hâlinde tutulduğunu söyledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Defterdeki sayılar üçer artarken başka sütunlardaki kayıtlar aradaki numaraları tamamlıyor olabilirdi. Çocuklar defteri dikkatlice inceleyince yan sayfada 105, 108, 111 sayılarını buldular. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " heyecanla yeni bir kâğıt aldı ve tabloyu kendi başına yeniden kurdu. İlk sütunu doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " yazdı ama ikinci sütunun son sayısını unuttu. İrem eksik kısmı kendisinin tamamlaması yerine "
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
          "v": ", sayının nerede kaybolduğunu kendi bulunca sevindi. Bu küçük an, yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " etmenin bazen cevabı söylemek yerine yöntemi hatırlatmak olduğunu gösterdi. “Demek bu bir tek sıra değil,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". “Aynı tablodaki farklı sütunları ayrı ayrı okumuşuz.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "O anda "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yanlış rafta duran bir kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " fark etti. Sırtında eski bir kod vardı ama raftaki yeni etiketle uyuşmuyordu. Münevver Hanım kitabı alıp güncel katalogdan kontrol etti. Gerçekten de yanlış rafa konmuştu. Defterin sayıları, yıllar önceki kayıtların nasıl tutulduğunu anlamalarına yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " ediyordu. Kırmızı çizginin yanında küçük bir yıldız"
        },
        {
          "t": "ikon",
          "v": "star"
        },
        {
          "t": "metin",
          "v": " da vardı. "
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
          "v": " bu kez hemen kabul etmedi. Sorumluya danışınca yıldızın o gün kontrol edilen kayıtları belirtmek için kullanılmış olabileceğini öğrendiler. Fakat bunu doğrulayacak açıklama defterde yoktu. İrem “Kesinlikle yıldız bunu gösteriyor” yazmadı; “Olası açıklama, doğrulanmadı” diye not etti."
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
          "v": " önce hayal kırıklığına uğradı. Sonra bir araştırmacının bütün sorulara aynı anda yanıt bulmasının gerekmeyebileceğini anladı. O sabah okulun kütüphanesinde küçük bir kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " değiştirme etkinliği vardı. "
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
          "v": ", “Bir saat"
        },
        {
          "t": "ikon",
          "v": "clock"
        },
        {
          "t": "metin",
          "v": " sonra devam ederiz. Kütüphane yalnızca kayıt çözmek için değil, kitap okumak için de var,” diye karşılık verdi. İrem ikisinin de haklı yanlarını gördü. Birlikte zaman planı yaptılar: önce etkinliğe katılacak, sonra araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " masasına döneceklerdi. "
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
          "v": " kırmızı bir kalemle işaretlenmiş sayfayı gördü. Sayfanın tepesine “Tamamlanmadı” yazılmıştı. Altında beş kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " adı vardı. Üçünün yanında onay, ikisinin yanında boş kare bulunuyordu. “Acaba bu kitaplar kayıp mı?” diye sordu "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". Münevver Hanım, bunun kesin olmadığını söyledi. “Belki o tarihte sayım tamamlanmadı, belki kitaplar başka bir bölümdeydi. Önce kayıtları karşılaştıralım.” Arama sırasında aynı başlığı taşıyan iki farklı kitap gördüler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilkini seçmeye hazırlanırken İrem yayım bilgilerini karşılaştırdı. Bir kitapta yazar adı farklıydı."
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
          "v": " da aradıkları kitabın sayfa sayısının eski kayıttakine benzemediğini fark etti. İkili birbirlerini uyarınca "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " sonuca ulaştı. Defterdeki kodun yalnızca bir kapı anahtarı olmadığını, başka kayıtlarla birlikte kullanıldığında anlam kazandığını gördü. Öğretmenlerine hazırladıkları tabloda “eşleşti” ve “kontrol edilecek” sütunlarını ayrı tuttular. Çocuklar kitabın adını, yazarını ve eski kodunu kullanarak tarama yaptı. İki kitabın farklı bir sınıf kitaplığına aktarılmış olduğunu gösteren belge bulundu. Böylece “kayıp” sözcüğünü kullanmadan önce neden dikkatli olunması gerektiğini anladılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", sayı"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " dizilerine bakıp bir anda bütün şifreleri çözebildiğini sanmıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Şimdi her rakamın, yanında yazan kelimeye ve kullanıldığı zamana göre anlam kazandığını görüyordu. Matematikte örüntüyü bulmak"
        },
        {
          "t": "ikon",
          "v": "idea"
        },
        {
          "t": "metin",
          "v": " önemliydi; gerçek bir belgeyi anlamak için örüntünün bağlamını da bilmek gerekiyordu. Sunum hazırlıkları sırasında küçük bir tartışma çıktı. "
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
          "v": ", bunun dinleyenleri sıkacağını söyledi. İrem ikisini de dinledi ve metni üç parçaya ayırmayı önerdi: önce merak"
        },
        {
          "t": "ikon",
          "v": "curiosity"
        },
        {
          "t": "metin",
          "v": " sorusu, sonra ipuçları, en sonunda çözüm. Böylece hem "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " ayrıntıları korunacak hem de dinleyiciler yolu takip edebilecekti."
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
          "v": " metninin bir kısmını kısaltmayı istemiyordu. Fakat provasını yaptıklarında arkadaşları hangi sayıların neyi gösterdiğini karıştırdı. İkinci denemede daha açık cümleler kullandılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " o gün bilgiyi bulmanın kadar anlaşılır anlatmanın da emek istediğini gördü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu sunumu yalnızca öğretmenine göstermek istemişti. Münevver Hanım küçük öğrencilerin de katılacağını söyleyince biraz endişelendi. “Ya sayı"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " tabloları onlara zor gelirse?” dedi. İrem, örnekleri renkli kâğıtlarla gösterebileceklerini önerdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " etiketlerinin fotoğraflarını hazırladı. Böylece soyut görünen sayı ilişkilerini gerçek nesnelere bağladılar."
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
          "v": " sayı"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " dizilerini anlattı, İrem kanıt tablosunu gösterdi, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " eski katalog kartlarının nasıl kullanıldığını açıkladı. Münevver Hanım öğrencilerin sunumunu dinlerken eski kütüphanede kullanılan sisteme ilişkin kendi hatıralarını da anlattı. Ancak bazı yılları tam hatırlamadığı için öğrencilerden notlarına “sözlü bilgi” etiketi koymalarını istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını salladı. Belgeler ve anılar birbirini tamamlayabilirdi ama aynı türde kanıt değildi. İrem hazırladığı tabloyu son kez kontrol etti; hangi sayıyı hangi karttan aldıkları görünür hâle gelmişti."
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
          "v": " ise yanlış puan varsayımının üzerini çizmek yerine küçük bir açıklama eklemeyi önerdi. Böylece araştırmanın nasıl ilerlediği de anlaşılacaktı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " defteri ilk bulduğu sabah kurduğu hazine hayalini hatırladı. Başta bir kapının açılacağını, arkasından eski madalyalar çıkacağını düşünmüştü. Şimdi sıradan kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " kodlarının daha ilginç bir şeye dönüştüğünü görüyordu: Okulun yıllar önce bilgi düzenlemek için geliştirdiği bir yönteme. “Bazen gerçek hikâye hayal ettiğinden daha sessizdir,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " buna karşı çıktı: “Ama daha çok kişiye dokunabilir.” Çünkü kodlar doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " okunursa birçok öğrenci doğru kitabı daha kolay bulabilirdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sunumun sonunda "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " gülerek, “Demek bu gizli bir oyun değilmiş,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Ama bundan iyi bir oyun çıkarabiliriz,” diye karşılık verdi. Çocuklar bir sınıf etkinliği tasarladı. Her grubun önüne uydurma kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " kodlarından oluşan üç dizi koydular. Öğrencilerin görevi yalnızca diziyi devam ettirmek değil, farklı açıklamalar arasından hangisinin kanıtlarla uyuştuğunu seçmekti. Etkinlikte en çok tartışılan soru"
        },
        {
          "t": "ikon",
          "v": "question"
        },
        {
          "t": "metin",
          "v": ", verilen dizinin devamındaki sayının ne olacağı değildi. “Bu dizinin kitap kodu olduğunu nasıl anlarsınız?” sorusuydu. Bazı öğrenciler eski katalog kartlarını inceledi, bazıları başlıkların benzerliğine baktı."
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
          "v": ", bir grubun bütün sayıları doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " devam ettirdiği hâlde yanlış kitap"
        },
        {
          "t": "ikon",
          "v": "book"
        },
        {
          "t": "metin",
          "v": " seçtiğini gördü. Böylece örüntü kuralının doğru olmasıyla belgenin açıklamasının doğru olmasının farklı şeyler olduğunu daha iyi anladı. İrem, oyunun sonunda çocuklardan yalnızca cevabı değil, kullandıkları kanıtı da yazmalarını istedi. İlk gruptaki çocuklar sayıları çözdü ama yanlış sonuca vardı. "
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
          "v": " son kez kapaktaki yıpranmış etikete baktı. İlk gün ona tuhaf gelen “Nöbet Devir Teslimi” sözünün ne anlattığını şimdi daha iyi anlıyordu. Öğrenciler bir zamanlar kitapların düzenli bulunması için birbirlerine görev"
        },
        {
          "t": "ikon",
          "v": "quest"
        },
        {
          "t": "metin",
          "v": " devretmişti. Bu küçük sorumluluk, yıllar sonra başka öğrencilerin araştırmasına konu olmuştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun şaşırtıcı bir bağlantı olduğunu düşündü: Birinin özenle tuttuğu kayıt, başka birinin doğruyu bulmasına yardım edebilirdi. Kırmızı defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " arşivine güvenle kaldırıldı. Kapak sayfasına, öğrencilere ait kişisel bilgiler paylaşılmadan hazırlanmış kısa bir açıklama eklendi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Münevver Hanım ayrıca buldukları eski katalog kartlarını sınıfta kullanılacak örneklerle karıştırmamalarını istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun nedenini sorunca, araştırma"
        },
        {
          "t": "ikon",
          "v": "magnifier"
        },
        {
          "t": "metin",
          "v": " için hazırladıkları kopyalarla gerçek arşiv belgelerinin ayrı tutulmasının önemini anladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kopyaların üstüne “Etkinlik örneği” yazdı. İrem gerçek kartların nerede korunduğunu dosyaya ekledi. Sonradan defteri inceleyen herkes böylece hangi belgenin asıl, hangisinin öğrenme amaçlı hazırlanmış örnek olduğunu ayırt edebilecekti. Böylece defterin geçmişte ne işe yaradığı ve neden korunduğu bilinecekti. İrem ile "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kütüphanedeki raf düzeni hakkında küçük bir anket de yapmıştı. Bazı öğrenciler kitapları başlığa göre, bazıları türe göre aramayı tercih ediyordu."
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
          "v": " başlangıçta “Bir yöntem seçelim, herkes ona uysun,” demişti. Münevver Hanım, farklı okurların ihtiyaçlarını dikkate almanın kütüphaneyi daha kullanışlı kılabileceğini anlattı. Çocuklar basit bir arama yönlendirmesi hazırladı: Aradığın kitabın adını biliyorsan katalogdan, konu arıyorsan raf etiketlerinden başla. Bu küçük öneri, çözülmüş bir sayı"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " dizisinin gerçek hayatta nasıl işe yarayabileceğini gösterdi. Dönem sonu geldiğinde satranç kulübü yeni üyelerini karşılamak için tanışma günü düzenledi. "
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
          "v": " başlangıçta başka bir hamleyi tercih edecekti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Fakat arkadaşının gerekçesini dinleyince konumu farklı açıdan görmeye başladı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " “Kırmızı defter"
        },
        {
          "t": "ikon",
          "v": "notebook"
        },
        {
          "t": "metin",
          "v": " sana satrançta da işe yaradı,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülümsedi. “Önce hamlenin nereden geldiğini anlamak gerekiyor,” diye karşılık verdi. Sayıların bağlamı olduğu gibi kararların da bağlamı vardı. Yeni gelen bir öğrenci düşünürken sabırla bekledi. "
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
          "v": " omuz silkti. “Evet. Bazen doğru cevabı ilk bulan kişi olmak en önemli şey değilmiş.” İrem onların konuşmasını duydu. Kütüphanede öğrendikleri sabır"
        },
        {
          "t": "ikon",
          "v": "patience"
        },
        {
          "t": "ikon",
          "v": "hourglass"
        },
        {
          "t": "metin",
          "v": ", artık satranç masasında da işe yarıyordu."
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
          "v": " gülümsedi. “Yirmi yedi,” diye cevap verdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yanlarından geçerken “Peki bu sayı"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " neyi gösteriyor?” diye sordu. Artık kızgın ya da acele hissettiğinde de aynı soruyu kendisine yöneltiyordu: “Bunu nereden biliyorum?” Bu, her kararını mükemmel yapmıyordu. Ama düşünmeden konuştuğu anları daha kolay fark etmesine yardım"
        },
        {
          "t": "ikon",
          "v": "hand-help"
        },
        {
          "t": "metin",
          "v": " ediyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ve İrem de yeni bir bulmaca"
        },
        {
          "t": "ikon",
          "v": "puzzle"
        },
        {
          "t": "metin",
          "v": " gördüklerinde önce kanıt arıyorlardı."
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
          "v": " daha önce satranç maçlarında yenilince hemen yeni bir oyun oynamak isterdi. Bu kez kaybetmenin ardından aynı konuma bakmayı, yanlış hamlenin neden yanlış olduğunu anlamayı denedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ona kırmızı defterdeki ilk varsayımlarını hatırlattı. “Biz de puan sandık"
        },
        {
          "t": "ikon",
          "v": "chest"
        },
        {
          "t": "metin",
          "v": ", sonra kontrol ettik,” dedi. İrem, hatanın kaynağını anlamanın yalnızca matematikte değil birçok konuda işe yaradığını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eski sayı"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " tablosuna baktı. Sayıların ardında görmediği düzeni fark etmesi için yalnızca işlem yapması yetmemişti; defterin kim tarafından ve ne amaçla tutulduğunu da anlaması gerekmişti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Artık yeni bir bilmeceyle karşılaştığında ilk hamlesi tahmin yürütmek değil, soruyu dikkatle okumak olacaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kalemi bıraktı. İlk gün olsaydı sayının bir puan, şifre"
        },
        {
          "t": "ikon",
          "v": "lock"
        },
        {
          "t": "metin",
          "v": " veya gizli kapı olduğunu hemen söyleyebilirdi. Şimdi İrem'e döndü: “Önce bunun ne için yazıldığını sorayım.” İrem güldü. “Haklısın. Bu sefer yalnızca bir örüntü oyunu.” Bir gün babası "
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
          "v": " güldü. “Hayır."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Üç yumurta yazıyorsa yanındaki üç sayı"
        },
        {
          "t": "ikon",
          "v": "math"
        },
        {
          "t": "metin",
          "v": " puan değil; miktar!” Babası, “İşte "
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
          "v": " okul"
        },
        {
          "t": "ikon",
          "v": "school"
        },
        {
          "t": "metin",
          "v": " kütüphanesinde öğrendiklerinin markette bile karşısına çıkmasına şaşırdı. Matematiğin yalnızca kâğıttaki işlemlerden ibaret olmadığını, doğru"
        },
        {
          "t": "ikon",
          "v": "check"
        },
        {
          "t": "metin",
          "v": " anlamanın günlük yaşamla bağlantılı olduğunu düşündü. "
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
      "dayanak_sayfa": 17,
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
      "dayanak_sayfa": 15,
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
      "dayanak_sayfa": 28,
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
      "dayanak_sayfa": 19,
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
      "dayanak_sayfa": 10,
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
      "dayanak_sayfa": 36,
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
      "dayanak_sayfa": 7,
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
      "dayanak_sayfa": 23,
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
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "pd_varsayim",
        "tur": "kelime",
        "yazim": "varsayım",
        "anlam": "Henüz kanıtlanmamış, doğru olabileceği düşünülen fikir.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "pd_oruntu",
        "tur": "kelime",
        "yazim": "örüntü",
        "anlam": "Bir kuralı olan, kendini düzenli biçimde tekrar eden dizi ya da düzen.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "pd_baglam",
        "tur": "kelime",
        "yazim": "bağlam",
        "anlam": "Bir sözün ya da sayının anlamını belirleyen çevresindeki bilgiler ve durum.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "pd_ata_sabreden",
        "tur": "atasozu",
        "yazim": "Sabreden derviş muradına ermiş",
        "anlam": "Sabırla bekleyen ve çabalamayı bırakmayan kişi sonunda istediğine ulaşır.",
        "sinif_alt": 6,
        "sinif_ust": 6
      }
    ],
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
        "ad": "pd_ata_sabreden",
        "tur": "atasozu",
        "adaylar": [
          {
            "girdi": "pd_ata_sabreden"
          }
        ]
      }
    ]
  }
}$p45$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr047-kirmizi-defterin-sifresi: %', v_r; end if;

end
$ikon$;

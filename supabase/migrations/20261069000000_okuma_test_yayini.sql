-- =====================================================================
-- Okuma Dünyası — test yayını: 12 hikâye (2., 3., 4. sınıftan 4er), üç göz kuralıyla (Ajan A, Ajan B, insan).
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

  v_r := public.okuma_paket_ice_aktar($p01${
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
        "simge_sayisi": 1
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
          "v": "Fırının önünde ekmek kokusu vardı. Fırıncı dışarı çıktı. \"Biraz önce renkli bir şey geçti,\" dedi. \"Rüzgâr onu batıya sürükledi.\" "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterinin köşesine küçük bir ok çizdi. İlk kez bir harita yapmanın işe yaradığını düşündü."
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
          "v": " yerdeki kurdeleye baktı. Bir süre sonra pencerede asılı rüzgâr gülünün kanatlarının parka doğru döndüğünü fark etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " rüzgârın ara sıra yön değiştirdiğini hatırlattı. Yalnızca buna güvenemezlerdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Dut ağacının yanına vardıklarında uçurtma görünmüyordu. Tam dönerken üst kattan bir ses duyuldu: \"Bunu mu arıyorsunuz?\" Yaşlı bir komşu uçurtmayı balkonda bulmuştu. Balkona çıkıp almak yerine kapıyı çalıp yardım istediler. Komşu uçurtmayı güvenle getirdi. Bu yardımla "
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
          "v": " haritasına son bir işaret koydu. \"Yukarıda gördüm, aşağıda buldum!\" diye güldü. Bu kez ipi sağlam bağladı. Akşam arkadaşlarına hem uçurtmayı hem de üç sokaklık maceranın haritasını gösterdi. Annesi, onun dikkatine ve yardımlaşmaya sevindi."
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
  }
}$p01$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr002-renkli-ucurtma: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p02${
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
        "simge_sayisi": 1
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
          "v": " çantasını açınca kalem kutusundan sesler geldi. \"Bana yer kalmadı!\" diye bağırıyordu silgi. Cetvel ise \"Hepiniz yamuk duruyorsunuz,\" diye söyleniyordu. Kurşun kalem sivri ucunu koruyamamaktan yakınıyordu."
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
          "v": " bir yerdi. Silgi \"Ben küçüğüm, o yüzden hep alta düşüyorum,\" dedi. Cetvel \"Beni eğerseniz düzgün çizgi çizemem,\" diye karşılık verdi. Mavi kalem ise kapağı açık kaldığı için kurumuştu. "
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
          "v": " güldü ve onu da ön göze yerleştirdi. Kalem kutusundan artık ses gelmiyordu. "
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
  }
}$p02$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr009-konusan-kalem-kutusu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p03${
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
        "kelime_sayisi": 188,
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
        "simge_sayisi": 1
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
          "v": "Sabah okula giderken "
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
          "v": "Ertesi gün kapının önünde gölgesini inceledi. Bir adım sağa geçince gölge de onunla birlikte yer değiştirdi. \"Sanki bana yapışmış,\" dedi gülerek. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bir tebeşir daha getirdi; ikinci işaret gölgenin bittiği yere konuldu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğle vakti iki işaret farklıydı. Önce gölgenin kendiliğinden küçüldüğünü sandı. Sonra gölgesinin düştüğü yere baktı: gölge sabahki yerde değildi, demek ki güneşin yeri değişmişti. "
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
          "v": ". \"Işığın geldiği yön değişince biçimi de değişiyor.\" Acele etmemek gerekiyordu: \""
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
          "v": " güvenli deney kuralını hatırlattı: Işık kaynağına doğrudan bakılmaz ve deneyler büyüklerin yanında yapılır."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğretmen, \"Gölge, ışığın ulaşamadığı yerde oluşur,\" dedi. Sabah, öğle ve akşam gölgenin boyunu yan yana gösteren resimler yaptılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " artık gölgesinden korkmuyordu. \"Bir sorunun cevabını bulmak için birkaç kez bakmak gerekiyormuş,\" dedi."
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
  }
}$p03$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr016-golgeyi-kim-buyuttu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p04${
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
        "kelime_sayisi": 391,
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
          "v": " sınıfta duran iki saksıya bakıp kaşlarını çattı. Aynı gün ektiği fasulyelerden biri yeşermiş, diğeri ise incecik, soluk bir "
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
    "tarih": "2026-10-22"
  }
}$p04$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr015-tohumun-kucuk-sirri: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p05${
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
        "kelime_sayisi": 393,
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
          "v": " önce \"Az önce,\" diyecekti, sonra düşündü. \"Güneş battığından beri,\" dedi. \"Teknenin ışığını da görüyoruz ama fenerin ışığı yok.\" Görevli, durumu bakım defterine not alacağını söyledi."
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
          "v": " yazıyordu. İkisi, liman görevlisinin telefonda sözünü ettiği bakım defterini merak etti. Görevli, daha sonra çocuklara defterin nasıl tutulduğunu göstermeyi kabul etti. Bir süre sonra limanın servis aracı geldi. Görevliler fenerin elektrik sistemini güvenli biçimde kontrol etmeye başladılar. "
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
          "v": ". Bir sonraki akşam fener yanarken iki arkadaş ışığa değil, birlikte yaptıkları doğru işe bakıp gülümsediler."
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
  }
}$p05$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr018-deniz-fenerindeki-sinyal: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p06${
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
        "kelime_sayisi": 368,
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
          "v": "Meydandaki saat kulesi her öğlen on ikide çalardı. O gün çalmadı. Üstelik akrep on bir ile on iki arasındaydı, "
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
  }
}$p06$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr022-saat-kulesi-neden-durdu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p07${
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
        "kelime_sayisi": 459,
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
          "v": "Kütüphane görevlisi sandığın okula ait olduğunu, önce içindekileri kayıt altına almaları gerektiğini söyledi. Kilidi zorlamamalarını da hatırlattı. Çocuklar notu dikkatle inceledi. Altında dört cümle daha vardı: \"Bizi ısıtan; büyümemizi sağlayan; temiz suyu koruyan; gece yol gösteren.\" "
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
          "v": " Projesi\" yazıyordu. Albümde, öğrencilerin güneşli bir günde fidan diktiği, dere kıyısında temizlik yaptığı, geceleri yıldızları gözlediği fotoğraflar vardı."
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
          "v": "Kerem, dört cümleyi fotoğraflarla eşleştirmek istedi. \"Bizi ısıtan güneş. Büyümemizi sağlayan yaprak,\" dedi. Ömer sözünü kesti: \"Peki 'temiz suyu koruyan' neden dalga olsun?\" "
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
          "v": "Son sayfada küçük bir şiir vardı: \"Güneş bizi ısıtır, yaprak bizi büyütür, dalga temiz suyu korur, yıldız geceye yol gösterir.\" Çocuklar bunun yalnızca bir şiir olmadığını, dört etkinliği sıralayan gizli düzen, yani "
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
    "tarih": "2026-10-22"
  }
}$p07$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr021-kayip-sandigin-sifresi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p08${
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
    "tarih": "2026-10-22"
  }
}$p08$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr030-ormanin-kaybolan-patikasi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p09${
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
          "v": ". “Bilmiyoruz,” dedi arkadaşı "
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
          "v": " pusulayı izlerken ilginç bir benzerlik fark etti: “Eskiden insanlar yolda kaybolmamak için pusula kullanıyordu; şimdi de eserleri kaybetmemek için sensör kullanıyoruz.” Sınıfın dönüş otobüsünde herkes en sevdiği eseri söyledi. "
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
    "tarih": "2026-10-22"
  }
}$p09$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr031-muzede-sessiz-alarm: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p10${
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
  }
}$p10$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr032-keloglan-ve-akilli-terazi: %', v_r; end if;


  declare
    v_slug text;
    v_sid  uuid;
  begin
    foreach v_slug in array array['hr002-renkli-ucurtma', 'hr009-konusan-kalem-kutusu', 'hr014-yagmur-damlasinin-yolculugu', 'hr016-golgeyi-kim-buyuttu', 'hr015-tohumun-kucuk-sirri', 'hr018-deniz-fenerindeki-sinyal', 'hr022-saat-kulesi-neden-durdu', 'hr025-bremen-yolcularinin-yeni-sarkisi', 'hr021-kayip-sandigin-sifresi', 'hr030-ormanin-kaybolan-patikasi', 'hr031-muzede-sessiz-alarm', 'hr032-keloglan-ve-akilli-terazi'] loop
      select s.id into v_sid from public.okuma_hikaye_surumleri s join public.okuma_hikayeleri h on h.id = s.hikaye_id where h.slug = v_slug order by s.surum_no desc limit 1;
      if v_sid is null then raise exception 'yayin: sürüm bulunamadı %', v_slug; end if;
      perform public.okuma_surum_durum_degistir(v_sid, 'incelemede', '{"ajan_a":"pass","ajan_b":"pass","insan":"approved"}'::jsonb);
      perform public.okuma_surum_durum_degistir(v_sid, 'yayinda', null);
    end loop;
    perform public.log_admin_action('okuma_test_yayini', jsonb_build_object('not', 'Test yayını: kullanıcı kararı (2026-10-22). Ajan A ve Ajan B incelemeleri yapıldı; insan okuması (üçüncü göz) bekliyor.', 'hikaye_sayisi', 12));
  end;
end
$pilot$;

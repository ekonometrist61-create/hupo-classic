// Önizleme verisi (yalnız tool/okuma_onizleme). Kaynak: okuma_motoru test fikstürleri (derleyici çıktısı).
// Web'de dart:io yoktur; bu yüzden JSON dize olarak gömülüdür. Üretim kodu bu dosyayı içe aktarmaz.

const String kOnizlemePaket = r'''
{
  "paket_surumu": 1,
  "hikaye": {
    "slug": "feneri-kim-yakiyor",
    "baslik": "Feneri Kim Yakıyor?",
    "tur": "macera",
    "konu": "deniz",
    "sinif_alt": 4,
    "sinif_ust": 5,
    "okuma_bandi": 2,
    "dunya_tipi": "masalsi",
    "izinli_turler": [
      "hayvan",
      "hayali",
      "ben",
      "baska_biri"
    ],
    "deger_anahtarlari": [
      "D12",
      "D20"
    ],
    "yetiskin_uygun": false,
    "durum": "taslak"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kıyıdaki eski fenerin ışığı bir gece birden söndü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sahilde bunu fark etti. "
        },
        {
          "t": "hareket",
          "anahtar": "gelis"
        },
        {
          "t": "metin",
          "v": " Kapıda yazılı bir not vardı: Işığı birlikte arayın."
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
          "v": " yardım etmek istedi ve "
        },
        {
          "t": "yoldas",
          "hal": "yonelme",
          "yedek": "bir dostuna"
        },
        {
          "t": "metin",
          "v": " seslendi. "
        },
        {
          "t": "deger",
          "anahtar": "karar"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Mekanizmanın içinde "
        },
        {
          "t": "kelime",
          "yuva": "parlak_sifat"
        },
        {
          "t": "metin",
          "v": " bir anahtar buldu. Anahtar yerine oturunca fener yeniden yandı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Denize bakan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bir sözü hatırladı: "
        },
        {
          "t": "atasozu",
          "yuva": "sabir"
        },
        {
          "t": "metin",
          "v": " Işık, sabırla atılan her adımın sonunda yandı."
        }
      ]
    }
  ],
  "deger_sahneleri": {
    "karar": {
      "D20": [
        {
          "t": "metin",
          "v": "Fenerin kırık camını temizleyip ışığın yeniden yanmasına yardım etti."
        }
      ],
      "D12": [
        {
          "t": "metin",
          "v": "Işık yanana kadar sabırla çalıştı."
        }
      ],
      "_default": [
        {
          "t": "metin",
          "v": "Ne yapacağını düşünerek fenerin etrafında dolaşmaya başladı."
        }
      ]
    }
  },
  "hareket_sahneleri": {
    "gelis": {
      "hayvan": [
        {
          "t": "metin",
          "v": "Patileriyle kumu ezerek fenerin kapısına yürüdü."
        }
      ],
      "hayali": [
        {
          "t": "metin",
          "v": "Parlayan izler bırakarak fenerin kapısına süzüldü."
        }
      ],
      "ben": [
        {
          "t": "metin",
          "v": "Merdivenleri koşarak çıktı ve fenerin kapısına vardı."
        }
      ],
      "_default": [
        {
          "t": "metin",
          "v": "Fenerin kapısına doğru yürüdü."
        }
      ]
    }
  },
  "deyim_cumleleri": {},
  "sorular": [
    {
      "id": "s1",
      "beceri": "hatirlama",
      "dayanak_sayfa": 1,
      "metin": "Kapıda kahramanı hangi not karşıladı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bekçiyi çağırın."
        },
        {
          "id": "B",
          "metin": "Fenere girmeyin."
        },
        {
          "id": "C",
          "metin": "Işığı birlikte arayın."
        }
      ],
      "dogru": "C",
      "aciklama": "Kapıdaki notta ışığın birlikte aranması yazıyordu."
    },
    {
      "id": "s2",
      "beceri": "hatirlama",
      "dayanak_sayfa": 3,
      "metin": "Mekanizmanın içinde ne bulundu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir kitap"
        },
        {
          "id": "B",
          "metin": "Bir anahtar"
        },
        {
          "id": "C",
          "metin": "Bir harita"
        }
      ],
      "dogru": "B",
      "aciklama": "Parlak bir anahtar bulundu."
    },
    {
      "id": "s3",
      "beceri": "cikarim",
      "dayanak_sayfa": 3,
      "metin": "Fener neden yeniden yandı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Anahtar yerine oturdu"
        },
        {
          "id": "B",
          "metin": "Bekçi geldi"
        },
        {
          "id": "C",
          "metin": "Gök gürledi"
        }
      ],
      "dogru": "A",
      "aciklama": "Anahtar yerine oturunca ışık yeniden yandı."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Hikâyedeki atasözü ne anlatıyor?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Her zaman en hızlı olmak gerekir"
        },
        {
          "id": "B",
          "metin": "Yalnız kalmak en iyisidir"
        },
        {
          "id": "C",
          "metin": "Sabırla beklenen şey sonunda güzel olur"
        }
      ],
      "dogru": "C",
      "aciklama": "Sabırla koruk helva olur: sabırla yapılan iş sonunda iyi sonuç verir."
    }
  ],
  "uretim": {
    "kaynak": "elle",
    "tarih": "2026-10-17"
  }
}
''';

const String kOnizlemeSozluk = r'''
{
  "sozluk_surumu": 1,
  "girdiler": [
    { "id": "gizemli", "tur": "kelime", "yazim": "gizemli", "anlam": "Ne olduğu tam anlaşılamayan, sır taşıyan.", "sinif_alt": 4, "sinif_ust": 5, "kaynak_turu": "editor_onerisi", "kazanim_kodu": null, "durum": "taslak" },
    { "id": "esrarengiz", "tur": "kelime", "yazim": "esrarengiz", "anlam": "Nedeni bilinmeyen, sırlı.", "sinif_alt": 5, "sinif_ust": 6, "kaynak_turu": "editor_onerisi", "kazanim_kodu": null, "durum": "taslak" },
    { "id": "parlak", "tur": "kelime", "yazim": "parlak", "anlam": "Güçlü ışık saçan, ışıltılı.", "sinif_alt": 4, "sinif_ust": 5, "kaynak_turu": "editor_onerisi", "kazanim_kodu": null, "durum": "taslak" },
    { "id": "isiltili", "tur": "kelime", "yazim": "ışıltılı", "anlam": "Hafif ve sürekli parlayan.", "sinif_alt": 4, "sinif_ust": 5, "kaynak_turu": "editor_onerisi", "kazanim_kodu": null, "durum": "taslak" },
    { "id": "bir_elin_nesi_var", "tur": "atasozu", "yazim": "Bir elin nesi var, iki elin sesi var.", "anlam": "Birlikte çalışmanın gücü; tek başına yapılamayanlar birlikte yapılır.", "sinif_alt": 4, "sinif_ust": 6, "kaynak_turu": "editor_onerisi", "kazanim_kodu": null, "durum": "taslak" },
    { "id": "koruk_helva", "tur": "atasozu", "yazim": "Sabırla koruk helva olur.", "anlam": "Sabırla beklenen şey sonunda güzel olur.", "sinif_alt": 4, "sinif_ust": 6, "kaynak_turu": "editor_onerisi", "kazanim_kodu": null, "durum": "taslak" },
    { "id": "el_ele_vermek", "tur": "deyim", "yazim": "el ele vermek", "anlam": "Birlikte çalışmak, yardımlaşmak.", "sinif_alt": 4, "sinif_ust": 6, "kaynak_turu": "editor_onerisi", "kazanim_kodu": null, "durum": "taslak" }
  ],
  "yuvalar": [
    { "ad": "gizemli_sifat", "tur": "kelime", "adaylar": [{ "girdi": "gizemli" }, { "girdi": "esrarengiz" }] },
    { "ad": "parlak_sifat", "tur": "kelime", "adaylar": [{ "girdi": "parlak" }, { "girdi": "isiltili" }] },
    { "ad": "isbirligi", "tur": "atasozu", "adaylar": [{ "girdi": "bir_elin_nesi_var" }] },
    { "ad": "sabir", "tur": "atasozu", "adaylar": [{ "girdi": "koruk_helva" }] },
    { "ad": "el_ele", "tur": "deyim", "adaylar": [{ "girdi": "el_ele_vermek" }] }
  ]
}

''';

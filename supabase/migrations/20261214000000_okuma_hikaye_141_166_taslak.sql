-- =====================================================================
-- Okuma Dünyası: HR-141–166 (26 hikâye) paketleri yeni TASLAK sürüm olarak içe alınır.
-- Kaynak: icerik/okuma/hikaye/hr141–hr166 (derleyiciden geçmiş paketler, sözlük dosyaları ile).
-- Ajan A/B ve insan kararları pending; yayın kapısı değişmez (yalnız insan onayı yayınlar).
-- Yol arkadaşı adları metinde zaten geçen anonim kişilere verildi; sözlük adayları TDK onayı bekliyor.
-- Katı kip: geçersiz paket varsa migrasyon hata verip durur (sessiz atlama yok). Aynı sha256 varsa atlanır.
-- Not: 20261213000000 (izinli_turler) bu dosyadan önce uygulanmadan bu migrasyon çalıştırılmamalı; sıra gereği önce o gelir.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function public._tmp_okuma_denetim_iceri_al(p_paket jsonb, p_a text, p_b text, p_siki boolean default false)
returns text
language plpgsql
set search_path = ''
as $f$
declare
  v_hatalar jsonb; v_hik jsonb; v_et jsonb; v_slug text; v_sha text; v_hikaye uuid;
  v_no integer; v_surum uuid; v_hedef jsonb; v_paket_den jsonb; v_den jsonb;
begin
  v_hatalar := public._okuma_paket_hatalari(p_paket);
  if jsonb_array_length(v_hatalar) > 0 then
    if p_siki then
      raise exception 'PAKET_RED: % %', (p_paket -> 'hikaye' ->> 'slug'), v_hatalar::text using errcode = '22023';
    end if;
    return 'RED: ' || (p_paket -> 'hikaye' ->> 'slug') || ' ' || v_hatalar::text;
  end if;
  v_hik := p_paket -> 'hikaye';
  v_et := v_hik -> 'etiketler';
  v_slug := v_hik ->> 'slug';
  v_sha := encode(sha256(convert_to(p_paket::text, 'UTF8')), 'hex');
  select id into v_hikaye from public.okuma_hikayeleri where slug = v_slug;
  if v_hikaye is not null then
    if exists (select 1 from public.okuma_hikaye_surumleri where hikaye_id = v_hikaye and sha256 = v_sha) then
      return 'MEVCUT: ' || v_slug;
    end if;
    select coalesce(max(surum_no), 0) + 1 into v_no from public.okuma_hikaye_surumleri where hikaye_id = v_hikaye;
  else
    insert into public.okuma_hikayeleri (slug) values (v_slug) returning id into v_hikaye;
    v_no := 1;
  end if;
  v_paket_den := v_et -> 'denetim';
  v_den := jsonb_build_object('ajan_a', coalesce(p_a, 'pending'), 'ajan_b', coalesce(p_b, 'pending'), 'insan', 'pending');
  insert into public.okuma_hikaye_surumleri (
    hikaye_id, surum_no, durum, icerik, sha256, baslik, tanitim, tur, konu, sinif_alt, sinif_ust, okuma_bandi,
    dunya_tipi, izinli_turler, deger_anahtarlari, yetiskin_uygun, sayfa_sayisi, soru_sayisi,
    olusturan_id, denetim, paket_denetimi)
  values (
    v_hikaye, v_no, 'taslak', p_paket, v_sha, v_hik ->> 'baslik', nullif(v_hik ->> 'tanitim', ''), v_hik ->> 'tur',
    v_hik ->> 'konu', (v_hik ->> 'sinif_alt')::smallint, (v_hik ->> 'sinif_ust')::smallint,
    (v_hik ->> 'okuma_bandi')::smallint, v_hik ->> 'dunya_tipi',
    array(select jsonb_array_elements_text(v_hik -> 'izinli_turler')),
    array(select jsonb_array_elements_text(v_hik -> 'deger_anahtarlari')),
    (v_hik ->> 'yetiskin_uygun')::boolean, jsonb_array_length(p_paket -> 'sayfalar'),
    jsonb_array_length(p_paket -> 'sorular'), null, v_den, v_paket_den)
  returning id into v_surum;
  insert into public.okuma_hikaye_etiketleri (
    surum_id, hikaye_id, ana_sinif, okuma_zorlugu, kavram_zorlugu, ilgi_egilimi, temalar, ders_baglantisi,
    ana_deger, yardimci_deger, cati_degerler, kanit_duzeyi, program_surumu, olculen)
  values (
    v_surum, v_hikaye, (v_et ->> 'ana_sinif')::smallint, (v_et ->> 'okuma_zorlugu')::smallint,
    (v_et ->> 'kavram_zorlugu')::smallint, v_et ->> 'ilgi_egilimi',
    array(select jsonb_array_elements_text(v_et -> 'temalar')),
    array(select jsonb_array_elements_text(v_et -> 'ders_baglantisi')),
    v_et #>> '{maarif,ana_deger}', v_et #>> '{maarif,yardimci_deger}',
    array(select jsonb_array_elements_text(coalesce(v_et #> '{maarif,cati_degerler}', '[]'::jsonb))),
    v_et ->> 'kanit_duzeyi', v_et ->> 'program_surumu', coalesce(v_et -> 'olculen', '{}'::jsonb));
  for v_hedef in select e from jsonb_array_elements(v_et -> 'ogrenme_hedefleri') e loop
    insert into public.okuma_ogrenme_hedefleri (id, tur, etiket, sinif, kanit_duzeyi, onayli, olusturan_id)
    values (v_hedef ->> 'id', v_hedef ->> 'tur', v_hedef ->> 'etiket', (v_et ->> 'ana_sinif')::smallint,
            v_et ->> 'kanit_duzeyi', false, null)
    on conflict (id) do nothing;
    insert into public.okuma_hikaye_hedefleri (surum_id, hedef_id, yuva, islev)
    values (v_surum, v_hedef ->> 'id', v_hedef ->> 'yuva', v_hedef ->> 'islev');
  end loop;
  return 'YAZILDI: ' || v_slug || ' surum_no=' || v_no;
end;
$f$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr141-anne-kucuk-bahcenin-buyuk-sirri",
    "baslik": "Küçük Bahçenin Büyük Sırrı",
    "tur": "doga",
    "konu": "toprak_ve_su",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "anne"
    ],
    "deger_anahtarlari": [
      "D5",
      "D17"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 2,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "doga"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D5",
        "yardimci_deger": "D17"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr141",
          "tur": "lexeme",
          "etiket": "filiz",
          "yuva": "hr141_filiz",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr141",
          "tur": "lexeme",
          "etiket": "nemli",
          "yuva": "hr141_nemli",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr141",
          "tur": "lexeme",
          "etiket": "ölçü",
          "yuva": "hr141_olcu",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr141",
          "tur": "lexeme",
          "etiket": "gölgelik",
          "yuva": "hr141_golgelik",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 269,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Aynı gün sulanan çiçekler neden farklı görünüyor? {kahraman} ölçerek ve gözleyerek hem filizleri hem suyu korumanın yolunu arıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-141"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Mahalle bahçesindeki çiçekler birkaç gündür başlarını öne eğmişti. Bahçıvan olan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " toprağa dokundu. Bir bölüm kupkuruydu, başka bir bölüm ise çok ıslaktı. Oysa bütün çiçekler aynı gün sulanmıştı. Girişteki rüzgâr gülü her zamanki gibi dönüyordu. Bahçeden geçen biri, “Belki çiçekler güneşi sevmiyordur,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu düşünceyi de deftere yazdı ama hemen daha çok su vermedi. Önce farkın nedenini araştıracaktı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi gün küçük bir "
        },
        {
          "t": "kelime",
          "yuva": "hr141_olcu"
        },
        {
          "t": "metin",
          "v": " kabı getirdi ve aynı miktarda suyu iki ayrı yere döktü. Güneşte duran yerde su hızla kayboldu. Ağaç altındaki toprak ise uzun süre "
        },
        {
          "t": "kelime",
          "yuva": "hr141_nemli"
        },
        {
          "t": "metin",
          "v": " kaldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " iki toprağa parmaklarıyla dokunup karşılaştırdı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Deniz"
        },
        {
          "t": "metin",
          "v": ", “Hepsini daha sık sulayalım,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını salladı: “Önce her yerin neye ihtiyacı olduğunu görelim.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çit dibinde yeni bir "
        },
        {
          "t": "kelime",
          "yuva": "hr141_filiz"
        },
        {
          "t": "metin",
          "v": " yükseliyordu. İncecik yaprakları güneşe doğru açılmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " filizin yanına küçük bir taş koydu; böylece kimse yanlışlıkla üzerine basmayacaktı. Sonra bahçenin planını çizdi ve güneşli ile gölgeli yerleri ayrı renklerle boyadı. Komşular da birkaç gün aynı saatlerde toprağa bakıp suyun nerede daha çabuk kuruduğunu yazdı. Notlar birbirini doğruladı."
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
          "v": " güneş gören tarafa ince bir "
        },
        {
          "t": "kelime",
          "yuva": "hr141_golgelik"
        },
        {
          "t": "metin",
          "v": " kurdu. Gölgelik, günün en sıcak saatinde toprağı koruyacaktı. Sonra her bölüme ihtiyacı kadar su verdi. Çok ıslak yere yeni su eklemedi. Sertleşen köşenin toprağını da dikkatle gevşetti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Deniz"
        },
        {
          "t": "metin",
          "v": ", “Bir damla su da mı önemli?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sulama kabını gösterdi: “Bir damlayı önemsersek bir bahçeye yetecek suyu koruruz.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir hafta sonra çiçeklerin yaprakları canlandı, filiz de biraz uzadı. Bahçeden geçenler değişikliği fark etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " herkese tek bir kural vermedi; her köşeyi ayrı ayrı gözlemelerini önerdi, çünkü güneş, gölge ve toprak her yerde aynı değildi. Ölçü kabı bahçedeki küçük kulübede kaldı. Rüzgâr gülü dönerken çiçekler artık başlarını dik tutuyordu."
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
      "metin": "Çiçekler eğik durduğunda {kahraman} toprağa dokununca ilk olarak neyi fark etti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çiçeklerin yapraklarının sarardığını"
        },
        {
          "id": "B",
          "metin": "Toprağın yer yer farklı ıslandığını"
        },
        {
          "id": "C",
          "metin": "Rüzgâr gülünün yön değiştirdiğini"
        }
      ],
      "dogru": "B",
      "aciklama": "Toprağın bir bölümü kupkuru, bir bölümü çok ıslaktı; bu yüzden B doğrudur. Yaprakların sarardığı, ağaç dikildiği ya da rüzgâr gülünün yön değiştirdiği metinde yazmaz."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Aynı miktarda su verilen iki yerden biri çabuk kurudu, öteki uzun süre nemli kaldı. Bu fark neyi düşündürür?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Güneş ve gölge sonucu etkiler"
        },
        {
          "id": "B",
          "metin": "Suyun rengi değişmiş olabilir"
        },
        {
          "id": "C",
          "metin": "Bütün çiçekler birbirinin aynısıdır"
        }
      ],
      "dogru": "A",
      "aciklama": "Su güneşte duran yerde hızla kayboluyor, ağaç altında uzun süre kalıyor; demek ki güneş ve gölge farkı etkilidir. Suyun rengi, çiçek türü ya da kabın büyüklüğü bu farkı açıklamaz."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Çit dibinde yeni bir filiz yükseliyordu.” cümlesindeki “filiz” neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bahçenin ortasındaki taş yolu"
        },
        {
          "id": "B",
          "metin": "Yeni çıkmış minik bir bitkiyi"
        },
        {
          "id": "C",
          "metin": "Çiçeklerin su içtiği küçük kabı"
        }
      ],
      "dogru": "B",
      "aciklama": "Filiz, yeni çıkmış küçük bitkidir; cümlede yaprakları güneşe açılan minik bir bitkiden söz edilir. Kurumuş dal, taş yol ve su kabı bu anlama uymaz."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} çok ıslak yere neden yeni su eklemedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bahçeden uzaklaşmak için"
        },
        {
          "id": "B",
          "metin": "Sulama kabını korumak için"
        },
        {
          "id": "C",
          "metin": "Suyu boşa harcamamak için"
        }
      ],
      "dogru": "C",
      "aciklama": "Zaten çok ıslak olan yere su eklemek suyu boşa harcamak olurdu; her bölüme yalnızca ihtiyacı kadar su verildi. Diğer seçeneklerin metinle ilgisi yoktur."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr141_filiz",
        "tur": "kelime",
        "yazim": "filiz",
        "anlam": "Tohumdan yeni çıkan ilk küçük sürgün.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr141_filiz_b",
        "tur": "kelime",
        "yazim": "sürgün",
        "anlam": "Bitkinin köklerinden ya da gövdesinden yeni çıkan dal.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr141_filiz_c",
        "tur": "kelime",
        "yazim": "dal",
        "anlam": "Ağacın gövdesinden çıkan kol.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr141_nemli",
        "tur": "kelime",
        "yazim": "nemli",
        "anlam": "Su tutan, az ıslak olan.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr141_nemli_b",
        "tur": "kelime",
        "yazim": "kuru",
        "anlam": "Su ya da nem kalmamış olan.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr141_nemli_c",
        "tur": "kelime",
        "yazim": "ıslak",
        "anlam": "Su ile kaplı ya da su dolu olan.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr141_olcu",
        "tur": "kelime",
        "yazim": "ölçü",
        "anlam": "Bir şeyin boyutunu ya da miktarını belirlemeye yarayan birim.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr141_olcu_b",
        "tur": "kelime",
        "yazim": "cetvel",
        "anlam": "Uzunluk ölçmeye yarayan düz, çizgili araç.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr141_olcu_c",
        "tur": "kelime",
        "yazim": "terazi",
        "anlam": "Ağırlık ölçmeye yarayan araç.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr141_golgelik",
        "tur": "kelime",
        "yazim": "gölgelik",
        "anlam": "Güneş ışınlarını engelleyen, gölge yapan örtü.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr141_golgelik_b",
        "tur": "kelime",
        "yazim": "tente",
        "anlam": "Güneşten korunmak için gerilen bez örtü.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr141_golgelik_c",
        "tur": "kelime",
        "yazim": "gölge",
        "anlam": "Bir cismin ışığı engellemesiyle oluşan karanlık alan.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "hr141_filiz",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr141_filiz"
          },
          {
            "girdi": "hr141_filiz_b"
          },
          {
            "girdi": "hr141_filiz_c"
          }
        ]
      },
      {
        "ad": "hr141_nemli",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr141_nemli"
          },
          {
            "girdi": "hr141_nemli_b"
          },
          {
            "girdi": "hr141_nemli_c"
          }
        ]
      },
      {
        "ad": "hr141_olcu",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr141_olcu"
          },
          {
            "girdi": "hr141_olcu_b"
          },
          {
            "girdi": "hr141_olcu_c"
          }
        ]
      },
      {
        "ad": "hr141_golgelik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr141_golgelik"
          },
          {
            "girdi": "hr141_golgelik_b"
          },
          {
            "girdi": "hr141_golgelik_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr142-anne-fenerlerin-renk-haritasi",
    "baslik": "Işığını Arayan Fenerler",
    "tur": "gezi_kultur",
    "konu": "eski_sokagin_aydinlatilmasi",
    "sinif_alt": 5,
    "sinif_ust": 5,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "anne"
    ],
    "deger_anahtarlari": [
      "D7",
      "D16"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 5,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kesif"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D7",
        "yardimci_deger": "D16"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr142",
          "tur": "lexeme",
          "etiket": "parıltı",
          "yuva": "hr142_parilti",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr142",
          "tur": "lexeme",
          "etiket": "taslak",
          "yuva": "hr142_taslak",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr142",
          "tur": "lexeme",
          "etiket": "uyum",
          "yuva": "hr142_uyum",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr142",
          "tur": "lexeme",
          "etiket": "onarım",
          "yuva": "hr142_onarim",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (5. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 468,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Eski bir çarşının fenerleri yeniden ışıldayacak. {kahraman} renklerin arkasındaki geçmişi korurken görünüşle gerçeği buluşturuyor.",
    "durum": "taslak",
    "fis_kodu": "HR-142"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eski çarşının dar sokağında akşamları seramik fenerler yanardı. Restoratör olan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", sokağın girişindeki fenerlerin onarımıyla görevlendirildi. İçlerinden biri ötekilerden daha soluk görünüyordu. Esnaf, tüm fenerlerin parlak sarıya boyanmasını istiyordu; böylece uzaktan daha dikkat çekici olacaklarını düşünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise yardımcısı "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ela"
        },
        {
          "t": "metin",
          "v": " ile önce eski fotoğraflara ve duvardaki izlere baktı. Bir sokak sakininin yıllar önce çektiği fotoğrafta görüntü net değildi ama fenerlerin biçimi seçilebiliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " fotoğrafın ne zaman çekildiğini de not etti, çünkü tek bir görüntü kesin kanıt sayılmazdı. Eski ışık bugünkünden daha yumuşaktı ve taşa vuran yansıması dar sokağı bir resim gibi gösteriyordu. “Hızlıca boyarsak eski ayrıntıları kaybedebiliriz,” dedi. Herkesin anlayabileceği bir "
        },
        {
          "t": "kelime",
          "yuva": "hr142_taslak"
        },
        {
          "t": "metin",
          "v": " hazırlamaya karar verdi."
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
          "t": "kelime",
          "yuva": "hr142_onarim"
        },
        {
          "t": "metin",
          "v": " masasına üç parça seramik koydu. Birinde açık mavi, diğerinde toprak rengi, üçüncüsünde solmuş yeşil izler vardı. Sert fırça kullanmadı; ince bir bezle ve uygun bir temizleme yöntemiyle çalıştı, çünkü çatlaklara dolan kirin altında gerçek renkler saklı olabilirdi. Temizlik ilerledikçe seramiğin altında ince çizgiler göründü. Çizgiler yalnızca süs değildi; parçaların hangi sırayla yerleştirileceğini gösteriyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ela"
        },
        {
          "t": "metin",
          "v": " yanlışlıkla iki parçayı yan yana koyunca desen tamamlanmadı, doğru sırayı bulunca küçük bir bütün ortaya çıktı. Temizlenen yüzeyde aynı desenin üç fenerde de tekrarlandığı ortaya çıktı. Çarşının saatçisi fenerlerin hep tek renk olduğunu sanıyordu; parçalar yan yana gelince fikrini değiştirdi. Artık hangi rengin nereye ait olduğunu gösteren güvenilir bir kayıt vardı."
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
          "v": " fenerlerden birini örnek olarak düzenleyip esnafı akşamüstü sokağa çağırdı. Gün ışığı çekilirken küçük lambalar yandı. Esnaf bir süre hiçbir şey söylemeden taş duvardaki yumuşak ışığa baktı. Yeni düzenleme güçlü bir "
        },
        {
          "t": "kelime",
          "yuva": "hr142_parilti"
        },
        {
          "t": "metin",
          "v": " vermiyordu; taş duvarda sakin bir ışık bırakıyordu. Yalnız bir dükkânın vitrini fazla parlaktı. Işığın nasıl göründüğünü anlamak için kimi sokağın girişinde, kimi dükkânların önünde durdu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yalnızca en güzel fotoğrafı seçmedi, bütün gözlemleri deftere yazdı. Vitrin ışığı azaltılınca fenerlerle çevrenin "
        },
        {
          "t": "kelime",
          "yuva": "hr142_uyum"
        },
        {
          "t": "metin",
          "v": " içinde olduğu anlaşıldı. Esnaf, dükkânlarının daha az görüneceğinden korkmuştu. Oysa geçenler fenerleri fark etmek için yavaşlıyor, vitrinlere de daha dikkatle bakıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sokağın en eski fenerinde küçük bir çatlak belirdi. Bazıları onu tamamen değiştirmeyi önerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", çatlağın taşıyıcı bölüme ulaşmadığını, dikkatli bir onarım ile parçanın korunabileceğini açıkladı. Önce çatlağı fotoğrafladı, sonra uygun bir malzemeyle sağlamlaştırdı. Parçanın altında geçmişte yapılmış başka bir müdahalenin izi çıktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu izi silmedi, kayıt altına aldı; çünkü her iz hata değildi, bazısı eşyanın nasıl kullanıldığını anlatıyordu. Çalışma sırasında fener sokaktan götürülmedi, insanlar süreci görebildi ve her aşama küçük levhalarla anlatıldı. İş bitince esnaf fenerlere nasıl bakım yapılacağını da öğrendi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Birkaç akşam sonra çarşıda küçük bir yürüyüş düzenlendi. Dükkân sahipleri ve ziyaretçiler fenerlerin altından geçerken desenlerdeki farkları aradı. En genç esnaf, önceki parlak sarı önerisini hatırlayıp gülümsedi. “Bir şeyi güzelleştirmek, onu mutlaka değiştirmek değilmiş,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " cevap vermedi, yalnızca fenerlerin şimdi nasıl göründüğüne baktı. Sokağın girişindeki eski fotoğrafın yanına yeni bir fotoğraf asıldı. İki karede de aynı taş yol uzanıyordu; farkı yalnızca yeni karedeki sağlam fener ve yumuşak ışık yaratıyordu. Çarşı yeniden canlıydı ama tanıdık yüzünü kaybetmemişti."
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
      "metin": "Esnaf ilk başta fenerler için ne önerdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Fenerleri sarıya boyamayı"
        },
        {
          "id": "B",
          "metin": "Sokağa yeni bir kapı yapmayı"
        },
        {
          "id": "C",
          "metin": "Bütün lambaları kapatmayı"
        },
        {
          "id": "D",
          "metin": "Fenerleri başka yere taşımayı"
        }
      ],
      "dogru": "A",
      "aciklama": "Esnaf fenerlerin parlak sarıya boyanmasını istiyordu, bu yüzden A doğrudur. Kapı yapmak, lambaları kapatmak ya da fenerleri taşımak metinde önerilmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Temizlik sırasında seramik parçalarda desenlerin ve çizgilerin ortaya çıkması neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Eski fotoğrafların artık önemi yoktur"
        },
        {
          "id": "B",
          "metin": "Yüzeyin altındaki izler bilgi taşır"
        },
        {
          "id": "C",
          "metin": "Bütün seramikler aynı renktedir"
        },
        {
          "id": "D",
          "metin": "Fenerler her yıl değişmelidir"
        }
      ],
      "dogru": "B",
      "aciklama": "Kirin altındaki desen ve çizgiler parçaların sırasını ve renklerini gösteriyordu; yani izler bilgi taşır. Parçaların renkleri farklıydı ve fotoğraflar da kanıt olarak kullanıldı, bu yüzden A ile C yanlıştır."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Uyum” sözcüğü metinde hangi anlamda kullanılmıştır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Seslerin yüksek çıkması"
        },
        {
          "id": "B",
          "metin": "Zamanın yavaş ilerlemesi"
        },
        {
          "id": "C",
          "metin": "Parçaların birbirine yakışması"
        },
        {
          "id": "D",
          "metin": "Nesnelerin başka bir yere taşınması"
        }
      ],
      "dogru": "C",
      "aciklama": "Fenerlerle çevrenin uyum içinde olması, birbirine yakışması demektir. Cümlede ses, zaman ya da taşıma ile ilgili bir anlam yoktur."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Sokağın en eski fenerinde çatlak belirdi ve bazıları feneri değiştirmeyi önerdi. {kahraman} neden hemen değiştirmedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Esnafı meşgul etmek için"
        },
        {
          "id": "B",
          "metin": "Sokağı kapatmak için"
        },
        {
          "id": "C",
          "metin": "Fotoğraf sayısını artırmak için"
        },
        {
          "id": "D",
          "metin": "Özgün parçayı korumak için"
        }
      ],
      "dogru": "D",
      "aciklama": "Çatlak taşıyıcı bölüme ulaşmadığı için onarımla özgün parça korunabilirdi. Esnafı meşgul etmek, sokağı kapatmak ya da fotoğraf çoğaltmak amaç değildi."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr142_parilti",
        "tur": "kelime",
        "yazim": "parıltı",
        "anlam": "Bir yüzeyden yansıyan ya da kendiliğinden çıkan hafif ışık.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr142_parilti_b",
        "tur": "kelime",
        "yazim": "ışıltı",
        "anlam": "Parlayan ve göz kamaştıran ışık.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr142_parilti_c",
        "tur": "kelime",
        "yazim": "aydınlık",
        "anlam": "Işığın yaydığı açıklık.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr142_taslak",
        "tur": "kelime",
        "yazim": "taslak",
        "anlam": "Bir işin ilk, deneme biçimindeki planı.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr142_taslak_b",
        "tur": "kelime",
        "yazim": "tasarı",
        "anlam": "Bir işin yapılmadan önceki ayrıntılı düzeni.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr142_taslak_c",
        "tur": "kelime",
        "yazim": "plan",
        "anlam": "Bir işi yapmadan önce hazırlanan düzen.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr142_uyum",
        "tur": "kelime",
        "yazim": "uyum",
        "anlam": "Parçaların birbirine yakışması, birlikte düzenli olması.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr142_uyum_b",
        "tur": "kelime",
        "yazim": "ahenk",
        "anlam": "Birlikte çıkan seslerin ya da parçaların hoş düzeni.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr142_uyum_c",
        "tur": "kelime",
        "yazim": "denge",
        "anlam": "Parçaların birbirini bozmadan durması.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr142_onarim",
        "tur": "kelime",
        "yazim": "onarım",
        "anlam": "Bozulmuş bir şeyi düzeltme işi.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr142_onarim_b",
        "tur": "kelime",
        "yazim": "tamir",
        "anlam": "Bozulan bir şeyi yeniden çalışır duruma getirme.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr142_onarim_c",
        "tur": "kelime",
        "yazim": "bakım",
        "anlam": "Bir şeyin iyi kalması için yapılan düzenli işlem.",
        "sinif_alt": 5,
        "sinif_ust": 5
      }
    ],
    "yuvalar": [
      {
        "ad": "hr142_parilti",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr142_parilti"
          },
          {
            "girdi": "hr142_parilti_b"
          },
          {
            "girdi": "hr142_parilti_c"
          }
        ]
      },
      {
        "ad": "hr142_taslak",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr142_taslak"
          },
          {
            "girdi": "hr142_taslak_b"
          },
          {
            "girdi": "hr142_taslak_c"
          }
        ]
      },
      {
        "ad": "hr142_uyum",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr142_uyum"
          },
          {
            "girdi": "hr142_uyum_b"
          },
          {
            "girdi": "hr142_uyum_c"
          }
        ]
      },
      {
        "ad": "hr142_onarim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr142_onarim"
          },
          {
            "girdi": "hr142_onarim_b"
          },
          {
            "girdi": "hr142_onarim_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr143-anne-sessiz-koprunun-nabzi",
    "baslik": "Fısıldayan Köprü",
    "tur": "bilim",
    "konu": "kopru_titresim_olcumu",
    "sinif_alt": 6,
    "sinif_ust": 6,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "anne"
    ],
    "deger_anahtarlari": [
      "D6",
      "D3"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 6,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "bilim_teknoloji"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D6",
        "yardimci_deger": "D3"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr143",
          "tur": "lexeme",
          "etiket": "titreşim",
          "yuva": "hr143_titresim",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr143",
          "tur": "lexeme",
          "etiket": "sensör",
          "yuva": "hr143_sensor",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr143",
          "tur": "lexeme",
          "etiket": "veri",
          "yuva": "hr143_veri",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr143",
          "tur": "lexeme",
          "etiket": "karşılaştırma",
          "yuva": "hr143_karsilastirma",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (6. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 527,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Bir yaya köprüsündeki küçük sesin büyük bir araştırmaya dönüşmesini izle. {kahraman} ölçümleri ve güvenliği adım adım değerlendiriyor.",
    "durum": "taslak",
    "fis_kodu": "HR-143"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kentin iki yakasını birleştiren yaya köprüsünde tuhaf bir ses duyuluyordu. Ses, öğleden sonra kalabalık arttığında çıkıyor, sonra kendiliğinden kayboluyordu. Köprünün güvenliğini kontrol etmesi için inşaat mühendisi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çağrıldı. Köprüden geçenleri önce diğer güvenli geçişe yönlendirdi. Kapalı geçişi gören yayalar nedenini merak etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", levhaya teknik terimlerle dolu bir duyuru yazmak yerine kısa ve anlaşılır bir açıklama astırdı. Bakımın ne zaman biteceği bilinmiyordu ama önlemin amacı herkesçe anlaşılıyordu. Köprünün yüzeyinde belirgin bir hasar görünmüyordu. Yine de yalnızca gözle bakmak yeterli değildi; "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bilinenleri bilinmeyenlerden ayırıp ölçüm yapmaya karar verdi. Sorunun kaynağı bulunmadan köprüyü yeniden açmayı doğru bulmuyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Teknik ekip köprünün üç noktasına küçük birer "
        },
        {
          "t": "kelime",
          "yuva": "hr143_sensor"
        },
        {
          "t": "metin",
          "v": " yerleştirdi. Sensör, köprü hareket ederken oluşan titreşimin miktarını kaydeden bir cihazdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " her ölçümden önce cihazların doğru çalışıp çalışmadığını sınadı. İlk "
        },
        {
          "t": "kelime",
          "yuva": "hr143_veri"
        },
        {
          "t": "metin",
          "v": " dizisi sabah saatlerine aitti. Öğleye doğru alınan ikinci dizide bir sensörün kaydı ötekilerden biraz farklı çıktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bunun köprüden mi yoksa cihazın yerleşiminden mi geldiğini ayırmak istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ece"
        },
        {
          "t": "metin",
          "v": " ile sensörün bağlantısını yeniden kontrol ettirdi ve aynı noktada ikinci bir ölçüm aldırdı; tek bir sayı bütün raporu yönlendirmemeliydi. O sırada yakında bir bakım aracının çalıştığı fark edildi. Aracın gürültüsü ve sarsıntısı ölçümü etkilemiş olabilirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yanlış bir sonuca varmak istemedi. Araç durduktan sonra yeni bir ölçüm yapılmasını istedi. Her değişiklik, saat ve hava durumuyla birlikte deftere yazıldı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğleden sonraki kayıtlarda sesin yalnızca belirli adım ritimlerinde arttığı görüldü. Ekip önceki günün kayıtlarıyla bugünküler arasında bir "
        },
        {
          "t": "kelime",
          "yuva": "hr143_karsilastirma"
        },
        {
          "t": "metin",
          "v": " yaptı. Köprüdeki insan sayısı da kaydedilmişti ve kalabalıkla ses arasında bir ilişki var gibi görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bunun tek başına neden-sonuç kanıtı olmadığını söyledi; iki sayının birlikte artması, birinin ötekine yol açtığı anlamına gelmezdi. Koşulları aynı olmayan iki ölçümü doğrudan eşitlemek de yanlış olurdu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ece"
        },
        {
          "t": "metin",
          "v": " sensör kayıtlarını bir tabloya dizip yeniden yorumladı. Köprünün kenarındaki bir bağlantı parçasının gevşek olduğu ve aynı ritimde hafifçe vurduğu anlaşıldı. Bu durum hemen büyük bir tehlike anlamına gelmiyordu ama onarılmadan bırakılması da doğru değildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bulguyu belediye teknik birimine ayrıntılarıyla iletti. Raporda hangi sonucun ölçüldüğü, hangisinin henüz tahmin olduğu ayrı ayrı yazılıydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Onarım ekibi bağlantıyı sökmeden önce koruyucu bir düzenek kurdu. Çıkarılan parçada yüzey aşınması vardı. Eski ve yeni parçanın ölçüleri yan yana konunca görünüşleri birbirine yakındı ama küçük bir aşınma farkı vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu farkın nerede oluştuğunu fotoğrafla belgeledi ve bilgiyi bakım defterine ekletti; benzer bir sorun çıkarsa nereye bakılacağı artık bilinecekti. Yeni parça takıldıktan sonra aynı koşullarda ölçümler tekrarlandı. Ses azalmıştı; buna rağmen "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tek bir sonuçla yetinmedi. Değişik saatlerde, farklı yürüme ritimlerinde ve farklı hava koşullarında deneme yapılmasını istedi. Çünkü bir koşulda doğru çıkan sonuç her koşulda doğru olmayabilirdi. Çalışma birkaç gün sürdü. Köprü kapalıyken karşıya geçmek isteyenlere diğer yolun neden kullanıldığı açıkça anlatıldı. Sabırsızlanan bazı yayalar da bu açıklama sayesinde beklemeyi kabul etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Son testlerde "
        },
        {
          "t": "kelime",
          "yuva": "hr143_titresim"
        },
        {
          "t": "metin",
          "v": " düzeyi teknik değerlendirmeye uygun bulundu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", köprünün yeniden açılmasına ilişkin rapora yalnızca bu ölçümlerin sınırları içindeki sonuçları yazdı. Köprü açıldığında ilk geçenler yavaş adımlarla ilerledi, eski ses duyulmadı. Bazıları yapılan kontrollerin ne anlama geldiğini sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " rapordaki ayrıntıları gizlemeden günlük dille özetledi. Ekip bir sonraki kontrol tarihini belirledi. Yakındaki dükkân sahibi, “Demek sorun küçücük bir bağlantı parçasında saklıymış,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülümsedi: “O parçayı bulmamızı sağlayan şey dikkatli kayıt ve tekrarlanan denemelerdi.” Günün sonunda sensörler toplandı, ölçüm tablosu arşive kaldırıldı."
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
      "metin": "Kontrol başlamadan önce yayalar nereye yönlendirildi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Köprünün ortasındaki bekleme alanına"
        },
        {
          "id": "B",
          "metin": "Yakındaki dükkânların önüne"
        },
        {
          "id": "C",
          "metin": "Başka bir güvenli geçişe"
        },
        {
          "id": "D",
          "metin": "Köprünün altındaki yola"
        }
      ],
      "dogru": "C",
      "aciklama": "Yayalar kontrol başlamadan önce diğer güvenli geçişe yönlendirildi. Köprünün ortası kontrol alanıydı; dükkânlar ve köprünün altındaki yol metinde geçmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Yakındaki bakım aracı çalışırken alınan ölçüm, araç durduktan sonra yeniden alındı. Bu neden önemlidir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Cihazların hangi renkte olduğunu görmek için"
        },
        {
          "id": "B",
          "metin": "Ölçümü etkileyen koşulu ayırmak için"
        },
        {
          "id": "C",
          "metin": "Köprünün boyunu biraz kısaltmak için"
        },
        {
          "id": "D",
          "metin": "Yürüyenlerin sayısını belirlemek için"
        }
      ],
      "dogru": "B",
      "aciklama": "Araç ölçümü etkilemiş olabileceği için ölçüm onsuz tekrarlandı; amaç etkileyen koşulu ayırmaktı. Cihazın rengi, köprünün boyu ve yaya sayısı bu işlemin amacı değildir."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Ekip önceki günün kayıtlarıyla bugünküler arasında bir karşılaştırma yaptı.” cümlesindeki “karşılaştırma” ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "İki kaydın benzerlik ve farklarına bakmak"
        },
        {
          "id": "B",
          "metin": "Köprünün kenar korkuluğunu yeniden boyamak"
        },
        {
          "id": "C",
          "metin": "Bütün ölçüm cihazlarını tek kutuda toplamak"
        },
        {
          "id": "D",
          "metin": "Dükkânların açılış saatlerini yeniden belirlemek"
        }
      ],
      "dogru": "A",
      "aciklama": "İki günün kayıtları yan yana konup benzerlik ve farklara bakıldı; karşılaştırma budur. Boyama, cihazları toplama ve dükkân saatleri cümleyle ilgisizdir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} ses azaldığı hâlde neden yeni testler yaptırdı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Daha fazla cihaz satın alabilmek amacıyla"
        },
        {
          "id": "B",
          "metin": "Köprüyü hiçbir zaman açmamak için"
        },
        {
          "id": "C",
          "metin": "Ekibi başka bir göreve vermek için"
        },
        {
          "id": "D",
          "metin": "Sonucu farklı koşullarda sınamak için"
        }
      ],
      "dogru": "D",
      "aciklama": "Bir koşulda doğru çıkan sonucun her koşulda doğru olmayabileceği için denemeler farklı saat, ritim ve havada yinelendi. Cihaz almak, köprüyü açmamak ya da ekibi değiştirmek amaç değildi."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr143_titresim",
        "tur": "kelime",
        "yazim": "titreşim",
        "anlam": "Bir cismin hızlı ileri geri hareket etmesi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr143_titresim_b",
        "tur": "kelime",
        "yazim": "sarsıntı",
        "anlam": "Bir cismin ani ve düzensiz sallanması.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr143_titresim_c",
        "tur": "kelime",
        "yazim": "salınım",
        "anlam": "Bir şeyin denge noktası etrafında gidip gelmesi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr143_sensor",
        "tur": "kelime",
        "yazim": "sensör",
        "anlam": "Fiziksel bir büyüklüğü ölçüp kayda geçiren cihaz.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr143_sensor_b",
        "tur": "kelime",
        "yazim": "ölçer",
        "anlam": "Bir büyüklüğün miktarını belirleyen araç.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr143_sensor_c",
        "tur": "kelime",
        "yazim": "kayıt cihazı",
        "anlam": "Ölçülen verileri zamana bağlı saklayan alet.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr143_veri",
        "tur": "kelime",
        "yazim": "veri",
        "anlam": "Ölçüm ya da gözlemlerden elde edilen bilgi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr143_veri_b",
        "tur": "kelime",
        "yazim": "kayıt",
        "anlam": "Bir olayın yazılı ya da sayısal tutulan izi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr143_veri_c",
        "tur": "kelime",
        "yazim": "bilgi",
        "anlam": "Bir konu hakkında öğrenilen gerçek.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr143_karsilastirma",
        "tur": "kelime",
        "yazim": "karşılaştırma",
        "anlam": "İki şeyin benzerlik ve farklarına bakma işi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr143_karsilastirma_b",
        "tur": "kelime",
        "yazim": "kıyas",
        "anlam": "Bir şeyi başka bir şeyle yan yana değerlendirme.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr143_karsilastirma_c",
        "tur": "kelime",
        "yazim": "benzetme",
        "anlam": "Bir şeyi başka bir şeye benzeterek anlatma.",
        "sinif_alt": 6,
        "sinif_ust": 6
      }
    ],
    "yuvalar": [
      {
        "ad": "hr143_titresim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr143_titresim"
          },
          {
            "girdi": "hr143_titresim_b"
          },
          {
            "girdi": "hr143_titresim_c"
          }
        ]
      },
      {
        "ad": "hr143_sensor",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr143_sensor"
          },
          {
            "girdi": "hr143_sensor_b"
          },
          {
            "girdi": "hr143_sensor_c"
          }
        ]
      },
      {
        "ad": "hr143_veri",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr143_veri"
          },
          {
            "girdi": "hr143_veri_b"
          },
          {
            "girdi": "hr143_veri_c"
          }
        ]
      },
      {
        "ad": "hr143_karsilastirma",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr143_karsilastirma"
          },
          {
            "girdi": "hr143_karsilastirma_b"
          },
          {
            "girdi": "hr143_karsilastirma_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr144-anne-kutuphanenin-kayip-kokusu",
    "baslik": "Raflardaki Keskin Koku",
    "tur": "tarih_kultur",
    "konu": "eski_kitap_koruma",
    "sinif_alt": 6,
    "sinif_ust": 6,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "anne"
    ],
    "deger_anahtarlari": [
      "D8",
      "D14"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 6,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kultur_miras"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D8",
        "yardimci_deger": "D14"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr144",
          "tur": "lexeme",
          "etiket": "koruma",
          "yuva": "hr144_koruma",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr144",
          "tur": "lexeme",
          "etiket": "havalandırma",
          "yuva": "hr144_havalandirma",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr144",
          "tur": "lexeme",
          "etiket": "lif",
          "yuva": "hr144_lif",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr144",
          "tur": "lexeme",
          "etiket": "kayıt",
          "yuva": "hr144_kayit",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (6. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 520,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Kütüphanenin eski kitap bölümünde beklenmedik bir koku var. {kahraman} kâğıtları, belgeleri ve özel bilgileri birlikte korumanın yolunu arıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-144"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Mahalle kütüphanesinin üst katındaki eski kitap bölümünde keskin bir koku vardı. Kitap "
        },
        {
          "t": "kelime",
          "yuva": "hr144_koruma"
        },
        {
          "t": "metin",
          "v": " uzmanı "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çağrıldığında herkes rafların hemen boşaltılmasını önerdi. Oysa aceleyle taşınan kırılgan sayfalar zarar görebilirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce ortamın nemini ölçtü ve pencerelerin nasıl açıldığını kontrol etti. Girişteki küçük termometre ile nem ölçere görevliler her gün bakıyordu ama sayıları yazmıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir günlük çizelge hazırlattı; böylece tek bir anın ölçümü, uzun süredir devam eden bir sorunla karıştırılmayacaktı. Bu bölüm bir arşivdi: Yalnızca kitaplar değil, geçmişte tutulmuş küçük notlar ve bazı kişisel mektuplar da kutularda duruyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bu belgelerin ziyaretçilerin merakına açılmaması gerektiğini söyledi. Koruma, hem kâğıdı hem de insanların özel alanını gözetmeliydi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Rafların ardındaki duvarda çok küçük bir nem izi bulundu. Havalandırma düzgün çalışmadığı için hava durgun kalmış, koku bir köşede yoğunlaşmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce uzman ekiple güvenli bir "
        },
        {
          "t": "kelime",
          "yuva": "hr144_havalandirma"
        },
        {
          "t": "metin",
          "v": " düzeni hazırladı. Biri, nemlenen kitapları kurutmak için güneşe çıkarmayı önerdi. Kitapları doğrudan güneşe koymak iyi bir çözüm değildi; bazı renkler solabilirdi. Kitaplar ortam düzelene kadar uygun kutularda bekletildi. Kutuların üzerine yalnızca kitap adları yazıldı, kişisel belgelerin içerikleri listelenmedi; genel bir tanım belgeleri bulmak için yeterliydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " görevlilere hangi kaydın herkese açık olacağını, hangisinin koruma bölümünde kalacağını anlattı. Bir sayfanın kenarı kolayca dağılıyordu. Büyüteçle bakınca kâğıdın "
        },
        {
          "t": "kelime",
          "yuva": "hr144_lif"
        },
        {
          "t": "metin",
          "v": " yapısının zayıfladığı görüldü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " o kitaba ayrı bir işaret koydu ve hangi kitabın nerede olduğunu gösteren "
        },
        {
          "t": "kelime",
          "yuva": "hr144_kayit"
        },
        {
          "t": "metin",
          "v": " listesini de güncelledi. Bir görevli bu işaretin ne anlama geldiğini sordu; "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onu rafın yanına asılan kısa bir notla açıkladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Meraklı bir ziyaretçi, kutulardaki mektupları görmek istedi. “Geçmişten kalan her şey herkese açık değil mi?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kutuyu açmadan cevap verdi: “Bir belgenin korunması, içeriğinin herkese gösterilmesi demek değildir.” Ziyaretçiye halka açık katalogdaki eski şehir haritalarını önerdi. Haritaların kopyaları hazırlanırken renklerin gerçeğe yakın görünmesine dikkat edildi. Orijinal çizimdeki küçük lekeler silinip yok sayılmadı; kopyanın açıklamasında bunların eski belgedeki izler olduğu yazıldı. Ziyaretçi gördüğü bilginin kaynağını anlayabilmeliydi. Böylece merakı karşılanırken özel mektupların mahremiyeti de korunmuş oldu. Haritalara bakarken kütüphanenin eskiden bir çeşmenin yanında olduğu da öğrenildi. Ziyaretçi bu cevaba önce şaşırdı, sonra başını salladı. Orijinal belgeler koruyucu kutularında kaldı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir hafta süren çalışmada ekip her rafı tek tek kontrol etti. Duvardaki küçük sızıntı giderildi, havalandırma aralıkları düzenlendi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", zayıflamış sayfanın liflerini onarmak için özel bir destek kâğıdı kullandı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ece"
        },
        {
          "t": "metin",
          "v": " farklı yapıştırıcıları karıştırmayı önerdi ama "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " her malzemenin kâğıtla uyumunun denenmesi gerektiğini söyledi; işe yarar görünen bir müdahale zamanla daha çok zarar verebilirdi. Her işlem tarih ve kullanılan malzemeyle birlikte kayda geçti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ece"
        },
        {
          "t": "metin",
          "v": ", “İnsanlar bu kadar ayrıntıyı neden bilsin?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", ileride aynı kitaba başka uzmanların da bakacağını hatırlattı. Yapılan işlemin nasıl kaydedildiği, sonraki bakım kadar önemliydi. Kimse hangi sayfaya ne uygulandığını tahmin etmek zorunda kalmayacaktı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Üst kat yeniden açıldığında ağır koku kalmamıştı. Raflardaki kitaplar yerlerini almış, yeni açıklama kartları ziyaretçilere rehberlik ediyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çıkarken kapıdaki küçük yazıya baktı: “Bilgi paylaşılır, emanet korunur.” Açılış günü kısa bir tanıtım yürüyüşü yapıldı. Rehber, kitaplara dokunmadan da birçok ayrıntının incelenebileceğini gösterdi: kitap sırtlarındaki işaretler, raf düzeni ve katalog ekranı. Ziyaretçiler şehir haritalarını inceleyebiliyor, özel mektuplar güvenli bölümde saklanıyordu. Görevliler artık nem ölçerin değerlerini her sabah çizelgeye yazıyordu; "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu memnuniyetle izledi. Rafların arasında dolaşan görevli bir kitabı açmadan önce ellerini temizledi, sonra sayfaları dikkatle çevirdi."
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
      "metin": "{kahraman} üst katta ilk olarak neyi kontrol etti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kitapların fiyatını ve basım yılını"
        },
        {
          "id": "B",
          "metin": "Nemi ve pencerelerin durumunu"
        },
        {
          "id": "C",
          "metin": "Ziyaretçilerin giriş kayıtlarını"
        },
        {
          "id": "D",
          "metin": "Rafların boyasını ve yüksekliğini"
        }
      ],
      "dogru": "B",
      "aciklama": "{kahraman} işe ortamın nemini ölçüp pencereleri kontrol ederek başladı. Fiyat, giriş kayıtları ve raf boyası ilk kontrolde geçmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Nemlenen kitapları doğrudan güneşe koymak neden iyi bir çözüm sayılmadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Haritaların boyutu çok büyük olduğu için"
        },
        {
          "id": "B",
          "metin": "Kitapların ağırlığı fazla olduğu için"
        },
        {
          "id": "C",
          "metin": "Bazı renkler solabileceği için"
        },
        {
          "id": "D",
          "metin": "Kutularda boş yer kalmadığı için"
        }
      ],
      "dogru": "C",
      "aciklama": "Metin doğrudan güneşte renklerin solabileceğini söyler. Harita boyutu, ağırlık ve kutu yeri bu kararın nedeni olarak yazılmamıştır."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Özel mektupların mahremiyeti de korunmuş oldu.” cümlesindeki “mahremiyet” hangi düşünceye yakındır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Özel bilgilerin korunmasına"
        },
        {
          "id": "B",
          "metin": "Eski rafların değiştirilmesine"
        },
        {
          "id": "C",
          "metin": "Haritaların büyük basılmasına"
        },
        {
          "id": "D",
          "metin": "Bütün defterlerin atılmasına"
        }
      ],
      "dogru": "A",
      "aciklama": "Mektupların içeriği ziyaretçiye gösterilmediği için özel bilgiler korunmuş olur; mahremiyet bu demektir. Raf değişimi, harita boyutu ve defter atmak metinde yoktur."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} işlemleri neden ayrıntılı kaydetti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çalışmayı olabildiğince uzatmak için"
        },
        {
          "id": "B",
          "metin": "Kitapları başka yere satmak için"
        },
        {
          "id": "C",
          "metin": "Ziyaretçi sayısını bilerek azaltmak için"
        },
        {
          "id": "D",
          "metin": "Sonraki uzmanlara bilgi bırakmak için"
        }
      ],
      "dogru": "D",
      "aciklama": "{kahraman}, ileride aynı kitaba bakacak uzmanların neyin uygulandığını bilmesi için kayıt tuttu. Çalışmayı uzatmak, satış yapmak ya da ziyaretçiyi azaltmak amaç değildi."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr144_koruma",
        "tur": "kelime",
        "yazim": "koruma",
        "anlam": "Bir şeyi zarar görmekten ya da bozulmaktan kollama işi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr144_koruma_b",
        "tur": "kelime",
        "yazim": "muhafaza",
        "anlam": "Bir şeyi olduğu gibi saklama.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr144_koruma_c",
        "tur": "kelime",
        "yazim": "bakım",
        "anlam": "Bir şeyin iyi durumda kalması için yapılan işlem.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr144_havalandirma",
        "tur": "kelime",
        "yazim": "havalandırma",
        "anlam": "Kapalı bir yere temiz hava girmesini sağlama işi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr144_havalandirma_b",
        "tur": "kelime",
        "yazim": "çekiş",
        "anlam": "Bir alandaki havayı dışarı çekme.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr144_havalandirma_c",
        "tur": "kelime",
        "yazim": "dolaşım",
        "anlam": "Havanın bir yerde serbestçe hareket etmesi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr144_lif",
        "tur": "kelime",
        "yazim": "lif",
        "anlam": "Bitkilerden ya da kâğıttan gelen ince, uzun tel parçası.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr144_lif_b",
        "tur": "kelime",
        "yazim": "tel",
        "anlam": "İnce ve uzun bir malzeme parçası.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr144_lif_c",
        "tur": "kelime",
        "yazim": "doku",
        "anlam": "Bir malzemenin iç yapısı.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr144_kayit",
        "tur": "kelime",
        "yazim": "kayıt",
        "anlam": "Bir olayın ya da bilginin yazılı olarak tutulması.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr144_kayit_b",
        "tur": "kelime",
        "yazim": "not",
        "anlam": "Hatırlanması için kısaca yazılan bilgi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr144_kayit_c",
        "tur": "kelime",
        "yazim": "defter",
        "anlam": "Notların ve kayıtların tutulduğu kitap.",
        "sinif_alt": 6,
        "sinif_ust": 6
      }
    ],
    "yuvalar": [
      {
        "ad": "hr144_koruma",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr144_koruma"
          },
          {
            "girdi": "hr144_koruma_b"
          },
          {
            "girdi": "hr144_koruma_c"
          }
        ]
      },
      {
        "ad": "hr144_havalandirma",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr144_havalandirma"
          },
          {
            "girdi": "hr144_havalandirma_b"
          },
          {
            "girdi": "hr144_havalandirma_c"
          }
        ]
      },
      {
        "ad": "hr144_lif",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr144_lif"
          },
          {
            "girdi": "hr144_lif_b"
          },
          {
            "girdi": "hr144_lif_c"
          }
        ]
      },
      {
        "ad": "hr144_kayit",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr144_kayit"
          },
          {
            "girdi": "hr144_kayit_b"
          },
          {
            "girdi": "hr144_kayit_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr145-anne-ruzgarin-degistirdigi-rota",
    "baslik": "Rüzgârın Değiştirdiği Rota",
    "tur": "gezi_kultur",
    "konu": "kirsal_erisilebilir_gezi",
    "sinif_alt": 7,
    "sinif_ust": 7,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "anne"
    ],
    "deger_anahtarlari": [
      "D1",
      "D20"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 7,
      "okuma_zorlugu": 4,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kesif"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D1",
        "yardimci_deger": "D20"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr145",
          "tur": "lexeme",
          "etiket": "güzergâh",
          "yuva": "hr145_guzergah",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr145",
          "tur": "lexeme",
          "etiket": "tutunma",
          "yuva": "hr145_tutunma",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr145",
          "tur": "lexeme",
          "etiket": "alternatif",
          "yuva": "hr145_alternatif",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr145",
          "tur": "lexeme",
          "etiket": "koordinasyon",
          "yuva": "hr145_koordinasyon",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (7. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 623,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Tarihî bir tepeye çıkan yol herkes için uygun değil. {kahraman} farklı ihtiyaçları dinleyerek daha erişilebilir bir güzergâh tasarlıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-145"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Vadinin tepesindeki tarihî seyir alanına uzanan patika her yıl çok sayıda ziyaretçi ağırlıyordu. Yeni bir gezi planlanırken önemli bir sorun ortaya çıktı. Patikanın bazı bölümleri tekerlekli sandalye kullanan ziyaretçiler için uygun değildi. Kent gezi planlamacısı "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", yalnızca en kısa yolu gösteren haritayı kabul etmedi; herkesin manzaraya ulaşabileceği bir "
        },
        {
          "t": "kelime",
          "yuva": "hr145_guzergah"
        },
        {
          "t": "metin",
          "v": " çizmek istedi. Girişteki eski levhada yalnızca yürüyüş süresi yazıyordu. Oysa bir kişi için kısa olan süre başka biri için uzun olabilirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", patikayı tekerlekli sandalyeyle deneyen "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ege"
        },
        {
          "t": "metin",
          "v": " ile birlikte yürüdü; rehberin on beş dakikada çıktığı yamaç gönüllüye çok daha uzun sürdü. Levhada zemin, eğim, dinlenme noktası ve "
        },
        {
          "t": "kelime",
          "yuva": "hr145_alternatif"
        },
        {
          "t": "metin",
          "v": " yol bilgisi birlikte bulunmalıydı. İlk toplantıda rehberlerin çoğu bu ayrıntıları hiç düşünmediğini söyledi. Bazıları uzun bir yolun ziyaretçileri yoracağını savundu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bir yolun uzunluğunun yalnızca metreyle ölçülmediğini, o yolda zorlanan kişinin deneyimine de bağlı olduğunu anlattı. Eğimi, dinlenme noktalarını ve araç girişlerini not ederek ilk incelemeyi tamamladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkinci incelemede ekiple birlikte patikanın girişine gitti. Rüzgâr vadiden sert esiyordu ve dar bir geçitte küçük taşlar birikmişti. Haritadaki ilk alternatif bu geçitten geçiyordu. Rüzgârın savurduğu taşlar yolun gün içinde bile değişebildiğini gösteriyordu; "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", güvenli bir rota çizdikten sonra onu hep aynı saymamak gerektiğini biliyordu. Daha alçak yamaçtan giden yol biraz uzundu fakat zemini düzdü. Üzerinde bir çeşme, iki gölgelik ve geniş bir dinlenme alanı vardı. Ekip üyeleri geçiş genişliğini kendi ölçtü; tekerlekli bir sandalyenin dar köşelerde rahatça dönüp dönemeyeceğine de baktı, yalnızca fotoğrafa bakarak karar vermedi. Görevliler yeni yolun kenarlarını güvenli biçimde düzenledi. “Erişilebilir bir gezi, herkesin aynı kapıdan girebilmesidir,” dedi "
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
          "v": "Sonra ziyaretçi gruplarıyla görüşüldü. Bazı katılımcılar uzun rampaları dinlenmeden çıkmanın zor olduğunu söyledi. Bazıları yol boyunca yeterince açıklayıcı işaret bulunmadığını belirtti. Bir katılımcı yaz sıcağında gölgeliklerin çok önemli olacağını hatırlattı; bu not da çizelgeye girdi. Kimi kuş seslerini dinleyebileceği sessiz bir dinlenme alanı istedi, kimi bilgi levhalarının göz hizasında olmasını. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bütün görüşleri aynı masada topladı ama hepsini tek cümleye sığdırmaya çalışmadı. Uygulanabilir olanları tasarıma işledi, henüz karara bağlanamayanları açıkça belirtti. Gezi rehberleri, bakım görevlileri ve ulaşım ekibi arasında "
        },
        {
          "t": "kelime",
          "yuva": "hr145_koordinasyon"
        },
        {
          "t": "metin",
          "v": " kuruldu. Yeni işaretlerde yalnızca uzaklık değil, eğim ve dinlenme alanları da gösterilecekti. İsteyenler daha kısa ama dik, isteyenler daha uzun ama rahat yolu seçebilecekti. Bu seçenekler ayrıcalık değil, farklı ihtiyaçlara uygun tasarımın parçalarıydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Beklenmedik bir yağmurdan sonra uzun yoldaki küçük bir bölüm çamurla kaplandı. Açılışa az zaman kalmıştı. Bazıları geçici bir levha koyup geziyi başlatmayı önerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " buna karşı çıktı; görünür bir levhanın kaygan zemini ortadan kaldırmayacağını biliyordu. Bakım ekibiyle birlikte suyun biriktiği noktaya bir tahliye oluğu yaptırdı. Suyun patikanın altındaki hassas bitkilere yönelmemesi için ek kontrol yapıldı; sorunu bir yerden alıp başka yere bırakmak çözüm sayılmazdı. Yolun eğimli kenarına "
        },
        {
          "t": "kelime",
          "yuva": "hr145_tutunma"
        },
        {
          "t": "metin",
          "v": " desteği eklendi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", kullanılan malzemelerin ileride onarılabilir olmasına da dikkat etti, çünkü bir bölüm yıpranırsa bütün yolun yeniden yapılması gerekmemeliydi. Farklı ihtiyaçları olan gönüllüler yolu denedi. Biri tutunma desteğini kendi boyuna uygun buldu, bir başkası biraz daha alçak olmasını istedi; destek iki yükseklikte yapıldı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ege"
        },
        {
          "t": "metin",
          "v": " yolun sonunda oturabileceği bir sıra olup olmadığını sordu; son dinlenme alanına bir sıra daha kondu. Bazı yön tabelalarını okumak zor bulundu; bu görüşler çizelgeye eklendi ve eksik görülen son iki tabela yerleştirildi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Açılış gününde ziyaretçiler zor bir patikaya yönelmek zorunda kalmadı; herkes haritadan kendine uygun yolu seçti. Daha uzun güzergâhtan gelen bir ziyaretçi tepedeki manzaranın önünde uzun süre durdu. “Burayı yalnızca fotoğraflarda görüyordum,” dedi. Manzara noktasında farklı yaşlardan ziyaretçiler yan yana duruyordu; kimi yavaş yürüyerek, kimi sık dinlenerek gelmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", açılış fotoğrafı için herkesin sığabileceği geniş bir alan seçti. Girişe bir geri bildirim defteri bırakıldı; ziyaretçilerin yazdıklarıyla harita sonraki haftalarda da düzeltilecekti. Gölgelikte oturan yaşlı bir çift manzarayı uzun uzun izledi. Rehberler bakım notları tutmaya başladı; biri de levhaları yeni bilgiye göre baştan yazmak için not aldı. Yamaçtan esen rüzgâr yeni yön levhalarını hafifçe sallıyordu, "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise kalabalığın arasından sessizce geçip yoluna gitti."
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
      "metin": "Yeni gezi planlanırken ortaya çıkan temel sorun neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Patikanın her gün kapatılıyor olması"
        },
        {
          "id": "B",
          "metin": "Yolun araçlarla tamamen dolmuş olması"
        },
        {
          "id": "C",
          "metin": "Yolun herkes için uygun olmaması"
        },
        {
          "id": "D",
          "metin": "Seyir alanında hiç manzara bulunmaması"
        }
      ],
      "dogru": "C",
      "aciklama": "Patikanın bazı bölümleri tekerlekli sandalye kullananlara uygun değildi; sorun yolun herkese uygun olmamasıydı. Kapalı olması, araç yoğunluğu ve manzara eksikliği metinde yazmaz."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Daha alçak yamaçtan giden, biraz daha uzun yolun tercih edilmesini hangi özellik açıklıyor?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Zemininin daha düz olması"
        },
        {
          "id": "B",
          "metin": "Rüzgârın daha hızlı esmesi"
        },
        {
          "id": "C",
          "metin": "Yol kenarında dükkân bulunması"
        },
        {
          "id": "D",
          "metin": "Haritada daha kalın çizilmesi"
        }
      ],
      "dogru": "A",
      "aciklama": "Yol daha uzundu ama zemini düzdü; erişilebilirlik için bu önemliydi. Rüzgâr, dükkân ve harita çizgisi tercihin nedeni olarak verilmez."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Gezi rehberleri, bakım görevlileri ve ulaşım ekibi arasında koordinasyon kuruldu.” cümlesindeki “koordinasyon” neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yolun taşlarını yeniden boyamayı"
        },
        {
          "id": "B",
          "metin": "Ekiplerin işini uyumlu yürütmeyi"
        },
        {
          "id": "C",
          "metin": "Yalnız başına yürümeyi tercih etmeyi"
        },
        {
          "id": "D",
          "metin": "Eski levhaları depoya kaldırmayı"
        }
      ],
      "dogru": "B",
      "aciklama": "Üç ekibin birbiriyle uyumlu çalışması koordinasyondur. Boyama, yalnız yürüme ve levha saklama cümleyle ilgili değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Çamurlu bölüm için geçici levha önerildi. {kahraman} neden yalnızca uyarı levhasıyla yetinmedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Haritayı daha renkli hâle getirmek için"
        },
        {
          "id": "B",
          "metin": "Yağmuru tamamen durdurmak için"
        },
        {
          "id": "C",
          "metin": "Geziyi tamamen iptal etmek için"
        },
        {
          "id": "D",
          "metin": "Kayganlığı gerçekten gidermek için"
        }
      ],
      "dogru": "D",
      "aciklama": "Levha uyarır ama zemini düzeltmez; {kahraman} kayganlığın kendisini gidermek istedi ve tahliye oluğu yaptırdı. Yağmuru durdurmak mümkün değildir, geziyi iptal etmek de amaç değildi."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr145_guzergah",
        "tur": "kelime",
        "yazim": "güzergâh",
        "anlam": "Bir yere gidilirken izlenen yol ya da rota.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr145_guzergah_b",
        "tur": "kelime",
        "yazim": "rota",
        "anlam": "Bir yolculukta izlenecek yön ve yol planı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr145_guzergah_c",
        "tur": "kelime",
        "yazim": "patika",
        "anlam": "Yaya geçişinin sağlandığı dar yol.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr145_tutunma",
        "tur": "kelime",
        "yazim": "tutunma",
        "anlam": "Bir yere sıkıca tutularak destek alma.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr145_tutunma_b",
        "tur": "kelime",
        "yazim": "destek",
        "anlam": "Bir şeyi ayakta ya da dengede tutan parça.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr145_tutunma_c",
        "tur": "kelime",
        "yazim": "tutamak",
        "anlam": "Tutularak kullanılan kısım.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr145_alternatif",
        "tur": "kelime",
        "yazim": "alternatif",
        "anlam": "Bir seçenek yerine geçebilecek başka yol ya da çözüm.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr145_alternatif_b",
        "tur": "kelime",
        "yazim": "seçenek",
        "anlam": "Birden çok olanaktan biri.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr145_alternatif_c",
        "tur": "kelime",
        "yazim": "yedek",
        "anlam": "Gerektiğinde kullanılmak üzere ayrılan şey.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr145_koordinasyon",
        "tur": "kelime",
        "yazim": "koordinasyon",
        "anlam": "Birden çok ekibin işini uyumlu biçimde yürütmesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr145_koordinasyon_b",
        "tur": "kelime",
        "yazim": "uyum",
        "anlam": "Parçaların birbirine yakışması, birlikte düzenli olması.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr145_koordinasyon_c",
        "tur": "kelime",
        "yazim": "işbirliği",
        "anlam": "Birlikte çalışarak ortak bir amaca ulaşma.",
        "sinif_alt": 7,
        "sinif_ust": 7
      }
    ],
    "yuvalar": [
      {
        "ad": "hr145_guzergah",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr145_guzergah"
          },
          {
            "girdi": "hr145_guzergah_b"
          },
          {
            "girdi": "hr145_guzergah_c"
          }
        ]
      },
      {
        "ad": "hr145_tutunma",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr145_tutunma"
          },
          {
            "girdi": "hr145_tutunma_b"
          },
          {
            "girdi": "hr145_tutunma_c"
          }
        ]
      },
      {
        "ad": "hr145_alternatif",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr145_alternatif"
          },
          {
            "girdi": "hr145_alternatif_b"
          },
          {
            "girdi": "hr145_alternatif_c"
          }
        ]
      },
      {
        "ad": "hr145_koordinasyon",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr145_koordinasyon"
          },
          {
            "girdi": "hr145_koordinasyon_b"
          },
          {
            "girdi": "hr145_koordinasyon_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr146-anne-bir-canin-hafizasi",
    "baslik": "Bir Çanın Hafızası",
    "tur": "tarih_kultur",
    "konu": "ses_mirasi_koruma",
    "sinif_alt": 7,
    "sinif_ust": 7,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "anne"
    ],
    "deger_anahtarlari": [
      "D10",
      "D19"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 7,
      "okuma_zorlugu": 4,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kultur_miras"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D10",
        "yardimci_deger": "D19"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr146",
          "tur": "lexeme",
          "etiket": "akustik",
          "yuva": "hr146_akustik",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr146",
          "tur": "lexeme",
          "etiket": "tını",
          "yuva": "hr146_tini",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr146",
          "tur": "lexeme",
          "etiket": "özgün",
          "yuva": "hr146_ozgun",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr146",
          "tur": "lexeme",
          "etiket": "kayıt",
          "yuva": "hr146_kayit",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (7. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 612,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Meydanın tanıdık çanı artık eskisi gibi çalmıyor. {kahraman} eski sesi doğru ölçümlerle yeniden duyulur kılmaya çalışıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-146"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eski saat meydanındaki küçük çanın sesi yıllardır mahalle halkının günlük yaşamına karışmıştı. Çanın sesi eskisi kadar net çıkmayınca bazıları onu tamamen yenilemeyi önerdi. Ses koruma uzmanı "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise önce bu değişimin nedenini anlamak istedi. Meydanın farklı köşelerinde durup çanı dinledi. Saat kulesinin altında oturan yaşlılar, çanın bir zamanlar daha gür çaldığını anımsıyordu. Çanın yanında uzun yıllar çalışan "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ela"
        },
        {
          "t": "metin",
          "v": ", sesin değiştiğini ilk fark eden kişiydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", onun anılarını dinlemekle kalmadı; değişimin yaklaşık ne zaman başladığını da sordu. Bu tarihi eski "
        },
        {
          "t": "kelime",
          "yuva": "hr146_akustik"
        },
        {
          "t": "metin",
          "v": " kayıtlarla karşılaştıracaktı. Akustik, sesin nasıl oluştuğunu ve çevrede nasıl yayıldığını inceleyen alandı. Geçmişte tutulan her gözlem kesin doğru sayılmadı ama soruların daha iyi sorulmasına yardım etti. Sonra çanın sesini özel bir cihazla kaydetti. Çan, insanlar için yalnızca metal bir nesne değildi; zamanı ve buluşmaları hatırlatan bir işaretti. Yine de bu duygusal bağ, teknik incelemenin yerini tutamazdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk ölçümlerde çanın "
        },
        {
          "t": "kelime",
          "yuva": "hr146_tini"
        },
        {
          "t": "metin",
          "v": " özelliğinin değişmediği görüldü. Tını, aynı yükseklikteki iki sesi birbirinden ayıran niteliktir. Demek ki sorun çanın gövdesinde değil, ona vuran hareketli parçanın düzensiz çalışmasında olabilirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", eski tamir defterlerini incelemek üzere belediye arşivine gitti. Belgelerde çanın daha önce iki kez bakım gördüğü yazıyordu. Defter sayfalarının arasında kısa notlar vardı: Birinde bakımın yağışlı bir günde yapıldığı, ötekinde çanın vuruş düzeninin değiştirildiği yazıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", hangi notun hangi işlemle ilgili olduğunu anlamadan hepsini tek bir hikâyeye bağlamadı. Fakat kullanılan malzemeler ayrıntılı kaydedilmemişti. Bu eksiklik, bugünkü işlemi zorlaştırıyordu. Belgeleme eksik kalınca küçük ayrıntıların sonradan ne kadar önemli olabildiği görülüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bundan sonra her ölçümün ve değişikliğin tarihiyle birlikte yazılmasını istedi. Ekipten biri eski metalin rengini de yenilemeyi önerdi; "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " görünüşten önce işlevi anlamayı seçti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Meydandaki küçük atölyede çanı vuran hareketli parça dikkatle söküldü. Kenarında aşınmış ince bir yüzey vardı. Yeni bir parça üretmek mümkündü ama ölçüler hassas alınmalıydı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eski parçayı örnek alarak bir çizim hazırladı. Malzemenin "
        },
        {
          "t": "kelime",
          "yuva": "hr146_ozgun"
        },
        {
          "t": "metin",
          "v": " görünüşüne zarar vermeyecek yöntemler karşılaştırıldı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ela"
        },
        {
          "t": "metin",
          "v": " en parlak metalin en iyi sonucu vereceğini düşündü. Ölçümler başka bir şey gösterdi: Parlaklık ses kalitesinin güvenilir göstergesi değildi; önemli olan uygun biçim, ağırlık ve temas noktasıydı. Denemelerde iki parça arasındaki fark ilk dinleyişte belirgin değildi; küçük bir kumpasla alınan ölçüler de aradaki farkın çok az olduğunu gösterdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ortamın gürültüsünü azaltıp sesleri aynı koşullarda karşılaştırdı. Bir parça biraz daha yumuşak, öteki biraz daha sert ses veriyordu. Yeni parçanın eski görünüme uyması yeterli değildi; ileride bakım yapılmasını da engellememeliydi, bu yüzden montaj biçimi ayrıca değerlendirildi. Ekip acele etmeden kayıtları dinleyerek karşılaştırma yaptı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yeni düzenek takıldıktan sonra meydanda kısa bir deneme yapıldı. Çanın sesi eskiye göre daha düzenliydi ama "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " son kararı tek başına vermedi. Bakım ekibi, çevrede yaşayanlar ve ses ölçüm uzmanı birlikte değerlendirme yaptı. Meydana yakın oturan yaşlı bir komşu, çanın çok yüksek çalmasının dinlenmeyi güçleştirdiğini söyledi. Çanın herkes için aynı duyguyu uyandırmadığı ortaya çıktı: Kimi sesi seviyor, kimi günün belirli saatlerinde daha sessiz bir ortam istiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu farkı tartışma konusu yapmadı, kullanım planına dâhil etti. Ses düzeyi ölçüldü, yeniden dinlendi ve ortak bir düzen üzerinde uzlaşıldı. Çanın tarihini anlatan kısa pano için "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yalnızca doğrulanmış bilgilerin yazılmasını istedi. Efsane gibi aktarılan bir tarihi ise belgelenmediği için metne eklemedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Meydanın yeniden düzenlendiği gün çan ilk kez saat başında çaldı. Çocuklar çanın altında toplanıp vuruşları saydı. Ses taş sokaklara yayıldı; yakındaki tezgâhlarda çalışanlar başlarını kaldırıp gülümsedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " törenin ortasında durmadı. Bir köşede, "
        },
        {
          "t": "kelime",
          "yuva": "hr146_kayit"
        },
        {
          "t": "metin",
          "v": " cihazındaki son ses grafiğini eski ölçümlerle karşılaştırıyordu. Tören bittiğinde bir ziyaretçi çanın parlak görünmemesine şaşırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", yeni bir şey üretmediklerini, var olan eserin işlevini koruduklarını söyledi. Yüzeydeki her eski iz zarar demek değildi. Dosyadaki fotoğraflar onarılan bölümle dokunulmayan bölümü ayırıyordu; gelecekte çanı inceleyecek biri neyin değiştiğini anlayabilecekti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bakım dosyasını görevliye teslim etti. İçinde çizimler, ölçüm koşulları ve yapılacak sonraki kontroller vardı. Çan yepyeni görünmüyordu ama tanıdık sesi yeniden berrak ve dengeli duyuluyordu."
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
      "metin": "Çanın incelenmesinin nedeni neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Meydanda yerinin değiştirilecek olması"
        },
        {
          "id": "B",
          "metin": "Sesinin eskisi gibi çıkmaması"
        },
        {
          "id": "C",
          "metin": "Meydana yeni bir yol açılması"
        },
        {
          "id": "D",
          "metin": "Meydandaki bütün saatlerin durması"
        }
      ],
      "dogru": "B",
      "aciklama": "Çanın sesi eskisi kadar net çıkmadığı için inceleme başladı. Yer değişikliği, yeni yol ve saatlerin durması metinde geçmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Eski bakım defterlerinde kullanılan malzemenin kaydedilmemiş olması neye yol açmıştır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Onarım yöntemini belirlemeyi zorlaştırmıştır"
        },
        {
          "id": "B",
          "metin": "Çanın tamamen kaybolmasına neden olmuştur"
        },
        {
          "id": "C",
          "metin": "Ses kayıtlarını gereksiz kılmıştır"
        },
        {
          "id": "D",
          "metin": "Meydanın ziyaretçilere kapanmasını gerektirmiştir"
        }
      ],
      "dogru": "A",
      "aciklama": "Malzeme kaydı olmayınca bugünkü işlem zorlaştı; yani doğru yöntemi seçmek güçleşti. Çan kaybolmadı, ses kayıtları gereksiz olmadı, meydan da kapanmadı."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Malzemenin özgün görünüşüne zarar vermeyecek yöntemler karşılaştırıldı.” cümlesindeki “özgün” sözcüğü hangi anlama yakındır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Fiyatı en düşük olan"
        },
        {
          "id": "B",
          "metin": "Ağırlığı en fazla olan"
        },
        {
          "id": "C",
          "metin": "İlk yapısına ait olan"
        },
        {
          "id": "D",
          "metin": "Yüzeyi en parlak olan"
        }
      ],
      "dogru": "C",
      "aciklama": "Özgün görünüş, malzemenin ilk yapısındaki görünüştür. Ucuzluk, ağırlık ve parlaklık metinde korunması istenen şeyler değildir; hatta parlaklığın ses kalitesini göstermediği yazar."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} doğrulanmayan tarihi neden panoya yazmadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Panoyu olabildiğince kısa tutmak için"
        },
        {
          "id": "B",
          "metin": "Tarihi tamamen gizli tutmak için"
        },
        {
          "id": "C",
          "metin": "Çanı daha sessiz çaldırmak için"
        },
        {
          "id": "D",
          "metin": "Güvenilir bilgi vermek için"
        }
      ],
      "dogru": "D",
      "aciklama": "Belgelenmeyen bilgi güvenilir sayılmaz; pano yalnızca doğrulanmış bilgiyi vermek için hazırlandı. Kısalık, gizleme ya da sesi azaltma amaç değildi."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr146_akustik",
        "tur": "kelime",
        "yazim": "akustik",
        "anlam": "Sesin oluşumunu, yayılışını ve algılanışını inceleyen bilim dalı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr146_akustik_b",
        "tur": "kelime",
        "yazim": "ses bilimi",
        "anlam": "Sesin doğasını ve yayılmasını inceleyen bilgi alanı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr146_akustik_c",
        "tur": "kelime",
        "yazim": "titreşim",
        "anlam": "Bir cismin ileri geri hareket etmesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr146_tini",
        "tur": "kelime",
        "yazim": "tını",
        "anlam": "Aynı yükseklikteki iki sesi birbirinden ayıran nitelik.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr146_tini_b",
        "tur": "kelime",
        "yazim": "perde",
        "anlam": "Sesin tizlik ya da pesliğini belirleyen düzey.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr146_tini_c",
        "tur": "kelime",
        "yazim": "yankı",
        "anlam": "Sesin bir yüzeyden yansıyıp geri gelmesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr146_ozgun",
        "tur": "kelime",
        "yazim": "özgün",
        "anlam": "İlk yapısını ve biçimini koruyan, aslına uygun olan.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr146_ozgun_b",
        "tur": "kelime",
        "yazim": "asıl",
        "anlam": "Bir şeyin ilk ve gerçek hâli.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr146_ozgun_c",
        "tur": "kelime",
        "yazim": "orijinal",
        "anlam": "Bir eserin kopya olmayan, ilk hâli.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr146_kayit",
        "tur": "kelime",
        "yazim": "kayıt",
        "anlam": "Bir olayın ya da bilginin yazılı olarak tutulması.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr146_kayit_b",
        "tur": "kelime",
        "yazim": "not",
        "anlam": "Hatırlanması için kısaca yazılan bilgi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr146_kayit_c",
        "tur": "kelime",
        "yazim": "defter",
        "anlam": "Notların ve kayıtların tutulduğu kitap.",
        "sinif_alt": 7,
        "sinif_ust": 7
      }
    ],
    "yuvalar": [
      {
        "ad": "hr146_akustik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr146_akustik"
          },
          {
            "girdi": "hr146_akustik_b"
          },
          {
            "girdi": "hr146_akustik_c"
          }
        ]
      },
      {
        "ad": "hr146_tini",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr146_tini"
          },
          {
            "girdi": "hr146_tini_b"
          },
          {
            "girdi": "hr146_tini_c"
          }
        ]
      },
      {
        "ad": "hr146_ozgun",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr146_ozgun"
          },
          {
            "girdi": "hr146_ozgun_b"
          },
          {
            "girdi": "hr146_ozgun_c"
          }
        ]
      },
      {
        "ad": "hr146_kayit",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr146_kayit"
          },
          {
            "girdi": "hr146_kayit_b"
          },
          {
            "girdi": "hr146_kayit_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr147-baba-suyun-izini-suren-usta",
    "baslik": "Suyun İzini Süren Usta",
    "tur": "bilim",
    "konu": "cesme_sizintisi",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "baba"
    ],
    "deger_anahtarlari": [
      "D17",
      "D16"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 2,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "bilim_teknoloji"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D17",
        "yardimci_deger": "D16"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr147",
          "tur": "lexeme",
          "etiket": "sızıntı",
          "yuva": "hr147_sizinti",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr147",
          "tur": "lexeme",
          "etiket": "bağlantı",
          "yuva": "hr147_baglanti",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr147",
          "tur": "lexeme",
          "etiket": "birikinti",
          "yuva": "hr147_birikinti",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr147",
          "tur": "lexeme",
          "etiket": "kaygan",
          "yuva": "hr147_kaygan",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 269,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Meydan çeşmesi kapalıyken bile damlıyor. {kahraman} küçük bir sızıntının izini sürüp suyun boşa akmasını önlüyor.",
    "durum": "taslak",
    "fis_kodu": "HR-147"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Meydan çeşmesinin altında her gün küçük bir su birikintisi oluşuyordu. Su tesisatçısı "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çeşmeyi incelemeye geldi. Musluk kapalıydı ama taşın üzerinde ince bir iz vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce yere dökülen suyu değil, suyun nereden geldiğini bulmalıydı. Çeşmenin yanında bekleyenler hemen musluğun değiştirilmesini önerdi. Oysa sorun muslukta olmayabilirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir bezle taşı kuruladı, sonra birkaç dakika sessizce bekledi. Taşın arkasında yeni bir damla belirdi."
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
          "v": " suyun gelişini durdurmak için vanayı kapattı. Vana, suyun akışını açıp kapatan parçaydı. Çeşmenin arkasındaki ince boruda küçük bir "
        },
        {
          "t": "kelime",
          "yuva": "hr147_sizinti"
        },
        {
          "t": "metin",
          "v": " vardı; su oradan dışarı çıkıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " boruyu hemen sökmedi. Önce hangi parçanın yıprandığına baktı. Küçük bir "
        },
        {
          "t": "kelime",
          "yuva": "hr147_baglanti"
        },
        {
          "t": "metin",
          "v": " halkası eskimişti. Yeni halkayı almak için alet kutusuna uzandı. İşi izleyen "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Emre"
        },
        {
          "t": "metin",
          "v": ", “Bu minicik parça mı bütün suyu akıtıyor?” diye şaşırdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bağlantı halkası değiştirildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " vanayı yavaşça açıp bekledi. İlk bakışta her şey yolundaydı ama kesin anlamak için bağlantıyı kuru bir bezle tekrar kontrol etti. Bez ıslanmamıştı. Yine de musluğu birkaç kez açıp kapattı. Su yalnızca gerektiğinde akıyor, çeşmenin altına damlamıyordu. Tamir bitmişti ama çevredeki su birikintisi hâlâ duruyordu. "
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
          "yuva": "hr147_kaygan"
        },
        {
          "t": "metin",
          "v": " zeminin temizlenmesini de istedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Komşular birlikte taşları sildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yere küçük bir kâğıt koyup yeni damla oluşup oluşmadığına baktı. Kâğıt kuru kaldı. Çeşmenin başında sıraya girenler temiz su doldurdu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Emre"
        },
        {
          "t": "metin",
          "v": " küçük bir tabelaya “Musluğu kapatmayı unutma” yazmak istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tabelanın herkesin görebileceği yere asılmasını önerdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi gün meydan çeşmesi yine kullanılıyordu. Taşın altında "
        },
        {
          "t": "kelime",
          "yuva": "hr147_birikinti"
        },
        {
          "t": "metin",
          "v": " yoktu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " son kontrol için uğradı; boru kuruydu, musluk sağlamdı. Çeşmenin yanındaki tabelayı gördü. Oradan geçen biri su içtikten sonra musluğu dikkatle kapattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " alet kutusunu alıp sonraki işine yürüdü. Yaptığı iş küçük görünebilirdi; fakat bir damlanın nereden geldiğini bulmak çok sayıda damlayı kurtarmıştı."
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
      "metin": "Çeşmenin altında ne oluşuyordu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Su birikintisi"
        },
        {
          "id": "B",
          "metin": "Küçük bir kum tepesi"
        },
        {
          "id": "C",
          "metin": "Küçük çiçek bahçesi"
        }
      ],
      "dogru": "A",
      "aciklama": "Çeşmenin altında her gün küçük bir su birikintisi oluşuyordu. Yaprak, kum ve çiçek metinde geçmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "{kahraman} onarıma başlamadan önce vanayı kapattı. Bu davranış neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "İşe güvenli hazırlanıldığını"
        },
        {
          "id": "B",
          "metin": "Musluğun renginin değiştiğini"
        },
        {
          "id": "C",
          "metin": "Bütün boruların kırıldığını"
        }
      ],
      "dogru": "A",
      "aciklama": "Su gelişi durdurulmadan boruya dokunmak güvenli olmazdı; vana kapatmak işe güvenli hazırlanmaktır. Çeşmenin kapanması ya da boruların kırılması metinde yoktur, yalnızca küçük bir halka eskimişti."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Tamir bitmişti ama çevredeki su birikintisi hâlâ duruyordu.” cümlesindeki “tamir” sözcüğü ne anlama gelir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yeni bir çeşme resmi çizmek"
        },
        {
          "id": "B",
          "metin": "Meydanın yerine taş döşemek"
        },
        {
          "id": "C",
          "metin": "Bozulan yeri düzeltmek"
        }
      ],
      "dogru": "C",
      "aciklama": "Bağlantı halkası değiştirilerek bozulan yer düzeltildi; tamir budur. Resim çizmek, taş döşemek ya da çeşmeyi taşımak yapılmadı."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 3,
      "metin": "{kahraman} neden su birikintisinin temizlenmesini istedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çeşmeyi gözlerden saklamak için"
        },
        {
          "id": "B",
          "metin": "Komşuları bir süre oyalamak için"
        },
        {
          "id": "C",
          "metin": "Kayganlığı gidermek için"
        }
      ],
      "dogru": "C",
      "aciklama": "Islak taş kaygan olur; temizlik bu tehlikeyi gidermek içindi. Boya, saklama ya da oyalama amacı metinde yoktur."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr147_sizinti",
        "tur": "kelime",
        "yazim": "sızıntı",
        "anlam": "Bir yerden sıvı ya da gazın istenmeden çıkması.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr147_sizinti_b",
        "tur": "kelime",
        "yazim": "kaçak",
        "anlam": "İzin verilmeden bir yerden dışarı sızan su ya da gaz.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr147_sizinti_c",
        "tur": "kelime",
        "yazim": "damlama",
        "anlam": "Bir yerden damla damla sızma.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr147_baglanti",
        "tur": "kelime",
        "yazim": "bağlantı",
        "anlam": "İki parçayı birbirine bağlayan yer ya da eleman.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr147_baglanti_b",
        "tur": "kelime",
        "yazim": "eklem",
        "anlam": "İki parçanın birleştiği yer.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr147_baglanti_c",
        "tur": "kelime",
        "yazim": "halka",
        "anlam": "Bir şeyi başka bir şeye bağlayan kapalı, yuvarlak parça.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr147_birikinti",
        "tur": "kelime",
        "yazim": "birikinti",
        "anlam": "Bir yerde toplanıp kalan su ya da madde.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr147_birikinti_b",
        "tur": "kelime",
        "yazim": "gölcük",
        "anlam": "Küçük bir yerde toplanmış durgun su.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr147_birikinti_c",
        "tur": "kelime",
        "yazim": "yığın",
        "anlam": "Bir yerde üst üste toplanmış şey.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr147_kaygan",
        "tur": "kelime",
        "yazim": "kaygan",
        "anlam": "Üzerinde kolay kayılan, tutunmayı zorlaştıran.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr147_kaygan_b",
        "tur": "kelime",
        "yazim": "ıslak",
        "anlam": "Su ile kaplı, nemli olan.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr147_kaygan_c",
        "tur": "kelime",
        "yazim": "pürüzsüz",
        "anlam": "Yüzeyi düz ve kaygan olan.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "hr147_sizinti",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr147_sizinti"
          },
          {
            "girdi": "hr147_sizinti_b"
          },
          {
            "girdi": "hr147_sizinti_c"
          }
        ]
      },
      {
        "ad": "hr147_baglanti",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr147_baglanti"
          },
          {
            "girdi": "hr147_baglanti_b"
          },
          {
            "girdi": "hr147_baglanti_c"
          }
        ]
      },
      {
        "ad": "hr147_birikinti",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr147_birikinti"
          },
          {
            "girdi": "hr147_birikinti_b"
          },
          {
            "girdi": "hr147_birikinti_c"
          }
        ]
      },
      {
        "ad": "hr147_kaygan",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr147_kaygan"
          },
          {
            "girdi": "hr147_kaygan_b"
          },
          {
            "girdi": "hr147_kaygan_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr148-baba-gorunmez-etiketin-pesinde",
    "baslik": "Görünmez Etiketin Peşinde",
    "tur": "mizah",
    "konu": "gida_etiketi_dogrulama",
    "sinif_alt": 5,
    "sinif_ust": 5,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "baba"
    ],
    "deger_anahtarlari": [
      "D6",
      "D13"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 5,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "mizah"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D6",
        "yardimci_deger": "D13"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr148",
          "tur": "lexeme",
          "etiket": "içerik",
          "yuva": "hr148_icerik",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr148",
          "tur": "lexeme",
          "etiket": "etiket",
          "yuva": "hr148_etiket",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr148",
          "tur": "lexeme",
          "etiket": "numune",
          "yuva": "hr148_numune",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr148",
          "tur": "lexeme",
          "etiket": "karışım",
          "yuva": "hr148_karisim",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (5. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 507,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Gizemli bir reçelin içindekileri kimse tam bilmiyor. {kahraman} eğlenceli bir etiketin aynı zamanda güvenilir olmasını sağlıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-148"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kasabanın küçük meyve atölyesinde kavanozlara komik bir "
        },
        {
          "t": "kelime",
          "yuva": "hr148_etiket"
        },
        {
          "t": "metin",
          "v": " yapıştırılmıştı: “Gizemli Güneş Reçeli.” Atölyenin gıda uzmanı olan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", ismin ilgi çekici olduğunu düşündü ama kavanozun içindekilerin açıkça belirtilmediğini fark etti. Bir müşteri, “Bunun içinde ne var?” diye sorunca herkes aynı anda konuşmaya başladı. Biri kayısı dedi, biri şeftali, biri de portakal. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tahmin yarışına katılmadı. Önce herkesten tahminini kâğıda yazmasını istedi. Aynı kavanoz için üç farklı cevap çıkınca sorunun müşteride olmadığı anlaşıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kâğıtları sakladı; yeni etiket hazır olunca eski ve yeni bilgiyi yan yana göstermek için kullanacaktı. Sonra ürünün üretim kaydını istedi, çünkü bir etiket yalnızca güzel görünmek için değil, doğru bilgi vermek için vardı. Atölye sahibi, “İsmin gizemli olması daha eğlenceli değil mi?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", gizemli bir adla belirsiz içeriğin aynı şey olmadığını söyledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kayıt defterinde reçelin üç meyveden oluşan bir "
        },
        {
          "t": "kelime",
          "yuva": "hr148_karisim"
        },
        {
          "t": "metin",
          "v": " olduğu yazılıydı. Ama partiden partiye meyve oranları değişmişti ve bunu hiçbir kavanoz göstermiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " rastgele bir kavanozu açıp tadına bakmak yerine her partiden uygun bir "
        },
        {
          "t": "kelime",
          "yuva": "hr148_numune"
        },
        {
          "t": "metin",
          "v": " ayırdı. Numune, incelenmek için seçilmiş küçük bir örnekti. Üretim tarihini ve parti bilgisini kayıtlarla karşılaştırdı. Kayıt klasörü o güne kadar rafın arkasında duruyordu; "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", onun herkesin kolay ulaşacağı bir yere konmasını önerdi. Böylece bir soru geldiğinde kimse hafızasına dayanmak zorunda kalmayacaktı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Selin"
        },
        {
          "t": "metin",
          "v": ", hazırlanmış etiketlerin çöpe gitmesine üzüldü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", kullanılabilir kâğıtların arka yüzüne deneme baskısı yapılabileceğini söyledi; hem doğru bilgi hazırlanacak hem de gereksiz malzeme harcanmayacaktı. Çalışma masasındaki renkli çıkartmalar da kutulara ayrıldı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yeni etiket tasarımında komik isim kaldı. Altına meyvelerin adları ve "
        },
        {
          "t": "kelime",
          "yuva": "hr148_icerik"
        },
        {
          "t": "metin",
          "v": " bilgileri açıkça yazıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " özellikle küçük yazıların kolay okunmasını istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Selin"
        },
        {
          "t": "metin",
          "v": " uzun yazıları kavanozun altına koymayı önerdi, bir başkası parlak renklerin her sorunu çözeceğini düşündü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " açık zemin üzerinde koyu yazının nasıl göründüğünü gösterdi. Renkler güzel olabilirdi ama göz yormayan, okunabilen bir tasarım gerekiyordu. Denemeyi farklı uzaklıklardan yaptılar. Müşteri kavanozu ters çevirmeden bilgiye ulaşabilmeliydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " okunaklı ve sade bir yerleşim hazırladı. Alerjisi ya da özel beslenme ihtiyacı olan insanların ürünleri daha dikkatli seçebileceğini de hatırlattı. İlk baskı yapılınca herkes kavanozu elden ele dolaştırıp yazıları okumayı denedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğleden sonra bir ziyaretçi atölyeye geldi. Eski etiketi görünce güldü, yeni etikete bakınca içeriği hemen anladı. “Demek gizemli olan yalnızca adıymış,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", etiketin arkasındaki küçük çizimi gösterdi: Üç meyve el ele tutuşmuş gibi duruyordu. Çalışanlar bu fikri çok sevdi, hatta çizimi ön yüze büyük basmak istediler. Fakat "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çizimin doğru bilgiyi örtmesine izin vermedi. Çizimin yeri bir kez daha değiştirildi; bilgi kaybolmadan eğlenceli görünüm korunmuş oldu. Kavanozların üzerine küçük bir kontrol işareti kondu. İşaret içeriğin denetlendiğini gösteriyordu ama ürünü olduğundan farklı tanıtmıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Akşam pazarına gönderilen kavanozlar raflara dizildi. Bir müşteri iki farklı reçeli karşılaştırıp kendine uygun olanı seçti. Atölye sahibi, önceki etiketin ne çok soru doğurduğunu hatırladı. Pazar kapanırken çalışanlar yeni ürünler için kısa bir kontrol listesi hazırladı: Adı, içeriği, kayıt bilgisi ve okunabilirliği ayrı ayrı gözden geçirilecekti. “Bazen kısa bir cevap vermek için daha doğru bir açıklama gerekiyormuş,” dedi "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ". Bir sonraki ürün başka bir meyveden yapılacaktı; onun etiketi de kendi içeriğini anlatacaktı. Gizemli Güneş Reçeli raflarda kaldı ama kavanozu eline alan kimse artık içindekileri tahmin etmek zorunda değildi."
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
      "metin": "Kavanozların ilk etiketindeki sorun neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Adının gereğinden kısa olması"
        },
        {
          "id": "B",
          "metin": "Kavanozların fazla küçük olması"
        },
        {
          "id": "C",
          "metin": "İçindekilerin yazılmaması"
        },
        {
          "id": "D",
          "metin": "Raflara hiç yerleştirilmemesi"
        }
      ],
      "dogru": "C",
      "aciklama": "İsim ilgi çekiciydi ama içindekiler açıkça yazılmamıştı. Etiketin kısalığı, kavanoz boyutu ya da raf yerleşimi sorun olarak anılmaz."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Atölyede her üretim partisinden numune ayrılması neden daha güvenilir bir kontrol sağlar?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Her üretimin ayrı incelenmesini sağlar"
        },
        {
          "id": "B",
          "metin": "Etiket yazısını kendiliğinden büyütür"
        },
        {
          "id": "C",
          "metin": "Bütün kavanozları birbirinin aynısı yapar"
        },
        {
          "id": "D",
          "metin": "Meyvelerin rengini kalıcı olarak değiştirir"
        }
      ],
      "dogru": "A",
      "aciklama": "Partiler arasında meyve oranı değişebildiği için her partiden numune almak, her üretimi ayrı ayrı incelemeye izin verir. Numune almak yazıyı büyütmez, kavanozları eşitlemez, rengi de değiştirmez."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“{kahraman} okunaklı ve sade bir yerleşim hazırladı.” cümlesindeki “okunaklı” ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Ağırlığı çok olan"
        },
        {
          "id": "B",
          "metin": "Kolay okunabilen"
        },
        {
          "id": "C",
          "metin": "Birden çok kapaklı"
        },
        {
          "id": "D",
          "metin": "Yalnız resimli"
        }
      ],
      "dogru": "B",
      "aciklama": "Küçük yazıların kolay okunması istendiği için okunaklı, kolay okunabilen demektir. Ağırlık, kapak sayısı ya da yalnız resim bu anlamda geçmez."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Çalışanlar çizimi öne çıkarmak isteyince {kahraman} neden bilginin örtülmemesini istedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Resim çizmek çok zor olduğu için"
        },
        {
          "id": "B",
          "metin": "Atölyenin duvarlarını süslemek için"
        },
        {
          "id": "C",
          "metin": "Pazarın zamanında kapanması için"
        },
        {
          "id": "D",
          "metin": "Müşteri doğru seçim yapsın diye"
        }
      ],
      "dogru": "D",
      "aciklama": "Etiketin görevi doğru bilgi vermek; çizim bunu örterse müşteri doğru seçemez. Çizmenin zorluğu, duvar süsü ve pazar saati metinde gerekçe değildir."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr148_icerik",
        "tur": "kelime",
        "yazim": "içerik",
        "anlam": "Bir ürünün ya da metnin içinde bulunan şeyler.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr148_icerik_b",
        "tur": "kelime",
        "yazim": "madde",
        "anlam": "Bir şeyi oluşturan özel nitelikli malzeme.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr148_icerik_c",
        "tur": "kelime",
        "yazim": "bileşen",
        "anlam": "Bir karışımı oluşturan parçalardan her biri.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr148_etiket",
        "tur": "kelime",
        "yazim": "etiket",
        "anlam": "Bir ürün üzerinde bilgi veren yapıştırılmış kâğıt ya da işaret.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr148_etiket_b",
        "tur": "kelime",
        "yazim": "damga",
        "anlam": "Bir şeyin üzerine basılan ayırt edici işaret.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr148_etiket_c",
        "tur": "kelime",
        "yazim": "künye",
        "anlam": "Bir ürünün kimlik ve içerik bilgilerini gösteren kayıt.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr148_numune",
        "tur": "kelime",
        "yazim": "numune",
        "anlam": "İncelemek için seçilmiş küçük örnek.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr148_numune_b",
        "tur": "kelime",
        "yazim": "örnek",
        "anlam": "Bir bütünü temsil eden parça.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr148_numune_c",
        "tur": "kelime",
        "yazim": "deneme",
        "anlam": "Bir şeyi sınamak için yapılan ön uygulama.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr148_karisim",
        "tur": "kelime",
        "yazim": "karışım",
        "anlam": "Birden çok maddenin bir araya getirilmesiyle oluşan şey.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr148_karisim_b",
        "tur": "kelime",
        "yazim": "bileşim",
        "anlam": "Bir şeyi oluşturan öğelerin toplamı.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr148_karisim_c",
        "tur": "kelime",
        "yazim": "harman",
        "anlam": "Farklı şeylerin birlikte karıştırılması.",
        "sinif_alt": 5,
        "sinif_ust": 5
      }
    ],
    "yuvalar": [
      {
        "ad": "hr148_icerik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr148_icerik"
          },
          {
            "girdi": "hr148_icerik_b"
          },
          {
            "girdi": "hr148_icerik_c"
          }
        ]
      },
      {
        "ad": "hr148_etiket",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr148_etiket"
          },
          {
            "girdi": "hr148_etiket_b"
          },
          {
            "girdi": "hr148_etiket_c"
          }
        ]
      },
      {
        "ad": "hr148_numune",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr148_numune"
          },
          {
            "girdi": "hr148_numune_b"
          },
          {
            "girdi": "hr148_numune_c"
          }
        ]
      },
      {
        "ad": "hr148_karisim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr148_karisim"
          },
          {
            "girdi": "hr148_karisim_b"
          },
          {
            "girdi": "hr148_karisim_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr149-baba-dagin-obur-yanina-ses",
    "baslik": "Dağın Öbür Yanına Ses",
    "tur": "bilim",
    "konu": "radyo_iletisim_iyilestirme",
    "sinif_alt": 6,
    "sinif_ust": 6,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "baba"
    ],
    "deger_anahtarlari": [
      "D20",
      "D3"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 6,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "bilim_teknoloji"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D20",
        "yardimci_deger": "D3"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr149",
          "tur": "lexeme",
          "etiket": "verici",
          "yuva": "hr149_verici",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr149",
          "tur": "lexeme",
          "etiket": "sinyal",
          "yuva": "hr149_sinyal",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr149",
          "tur": "lexeme",
          "etiket": "engel",
          "yuva": "hr149_engel",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr149",
          "tur": "lexeme",
          "etiket": "kapsama",
          "yuva": "hr149_kapsama",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (6. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 507,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Dağların arasındaki vadide haberleşme sık sık kesiliyor. {kahraman} ölçümlerle sesin ulaşabileceği güvenli yolu araştırıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-149"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Dağ köyleri arasındaki yol, bazı noktalarda telefon sinyalinin kesildiği uzun bir vadiden geçiyordu. Haberleşme teknikeri "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", buradaki iletişimi iyileştirmek için görevlendirildi. Yol ekipleri özellikle kış aylarında birbirine daha kolay ulaşmak istiyordu. Sis çöktüğünde araçlar vadiden tek tek geçiyor, birbirinden haber almak zorlaşıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk gün yol görevlilerine haberleşmenin en çok hangi saatlerde gerektiğini sordu; sabah ve akşam ihtiyaçları farklıydı. En güçlü cihazı seçmeden önce kullanıcıların ne istediğini öğrenmek gerekiyordu. Sonra vadiye çıkıp farklı yüksekliklerde ölçüm yaptı. Rüzgâr esiyor, tepelerde sis dolaşıyordu; ölçüm cihazını yağmurdan korudu. Bazı noktalarda ses çok netti, bazı noktalarda neredeyse hiç duyulmuyordu. Haritadaki düz bir çizgi arazinin bütün ayrıntılarını göstermiyordu. Bu düzensizliğin nedenini anlamadan yeni bir cihaz kurulmasını önermedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkinci gün tepelerin arkasında kalan alanlar incelendi. Radyo dalgalarının nasıl yayıldığı, hem kullanılan frekansa hem de arazinin biçimine bağlıydı. Frekans, bir dalganın belirli sürede kaç kez tekrarlandığını anlatan ölçüdür. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " teknik ekiple harita üzerinde üç olası yer belirledi. Ekip yürüyüş güzergâhını önceden kontrol etti ve güvenli alanın dışına çıkmadı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " konum seçerken bakım aracının ulaşabileceği yolu da hesaba kattı; cihaz arızalanırsa ona ulaşılabilmeliydi. İlk konum uygun görünüyordu fakat arada yüksek bir kaya "
        },
        {
          "t": "kelime",
          "yuva": "hr149_engel"
        },
        {
          "t": "metin",
          "v": " oluşturuyordu. İkinci konuma ulaşmak zordu, bakım ekibi oraya güvenle gidemeyebilirdi. Üçüncü yer yol ile tepe arasında dengeli bir noktadaydı; bakım aracı oraya rahatça çıkabilirdi. En yüksek tepe her zaman en iyi konum değildi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Üçüncü noktaya geçici bir "
        },
        {
          "t": "kelime",
          "yuva": "hr149_verici"
        },
        {
          "t": "metin",
          "v": " yerleştirildi. Ekip, vadinin karşı tarafında aynı anda ölçüm yaparak "
        },
        {
          "t": "kelime",
          "yuva": "hr149_sinyal"
        },
        {
          "t": "metin",
          "v": " gücünü not etti. Sonuçlar umut vericiydi ama belirli bir virajda iletişim hâlâ kesiliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", yol kenarındaki güvenli bir noktada "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ege"
        },
        {
          "t": "metin",
          "v": " ile birlikte ölçümlere baktı: Vadi boyunca "
        },
        {
          "t": "kelime",
          "yuva": "hr149_kapsama"
        },
        {
          "t": "metin",
          "v": " düzensizdi. Kapsama, haberleşmenin kurulabildiği bölgenin genişliğidir. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " boş kalan küçük alanları haritada işaretledi; ekip yalnızca iyi çeken yerlere bakıp eksikleri unutmamalıydı. Ölçüm sırasında "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ege"
        },
        {
          "t": "metin",
          "v": " vadinin karşı yamacında, öteki virajda duruyor, sonuçları ayrı ayrı yazıyordu. Ölçümlerin saati ve hava koşulları karşılaştırıldı. Sorunun, virajı çevreleyen dik kayalar yüzünden büyüdüğü anlaşıldı. Cihazın gücünü sınırsız artırmak çözüm değildi. Bunun yerine vericinin yerleşimi ve yönü değiştirildi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yeni düzenlemeden sonra test aracı aynı yolu yeniden izledi. Önceden kesilen virajda kısa bir sesli mesaj karşıya ulaştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sevindi ama tek bir denemeyi yeterli bulmadı. Günün farklı saatlerinde yapılan tekrarlar da başarılı oldu. Yol görevlileri kısa bir eğitim aldı: Hangi durumda hangi kanaldan haberleşileceği anlatıldı, örnek mesajlar denendi. Kimi görevliler mesajları gereğinden uzun kuruyordu. Çok uzun bir mesajda önemli bilgi arada kaybolabiliyordu; "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " örnek konuşmaları dinleyip düzeltmeler önerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bakım planını, cihazların kontrol tarihlerini ve olası arıza işaretlerini bir dosyada topladı. Kurulduktan sonra unutulan bir düzen, kısa sürede işe yaramaz hâle gelebilirdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Birkaç gün sonra vadide yoğun sis oluştu. Yol ekipleri gerekli bilgileri birbirine aktarabildi. Sisli günün ardından ekip yeniden bir araya geldi ve kayıtları kontrol etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", son dosyaya hangi alanların henüz tekrar test edilmesi gerektiğini de yazdı; kalan sorular unutulmamalı, görünür kalmalıydı. Ekip, sinyali hâlâ zayıf kalan kısa bir bölümü de bir sonraki ölçüm listesine aldı. Dağların biçimi değişmemişti, yollar yine kıvrılıyordu. Fakat bu kıvrımların arasındaki sessizlik eskisi kadar uzun sürmüyordu. Köyden gelen bir görevli, “Sesin ulaşması insana güven veriyor,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " elindeki haritaya yalnızca bir not ekledi: düzenli bakım."
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
      "metin": "İletişim sorunları en çok nerede görülüyordu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Şehir merkezindeki büyük meydanda"
        },
        {
          "id": "B",
          "metin": "Vadi yolunun bazı noktalarında"
        },
        {
          "id": "C",
          "metin": "Köyün içindeki küçük pazar yerinde"
        },
        {
          "id": "D",
          "metin": "Merkezdeki atölyenin uzun koridorunda"
        }
      ],
      "dogru": "B",
      "aciklama": "Sinyal, köyleri birbirine bağlayan vadi yolunun bazı noktalarında kesiliyordu. Meydan, pazar ve atölye koridoru metinde geçmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Ekip üç olası konumdan ilkini niçin eledi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Konumun bakım kaydı bulunamamıştı"
        },
        {
          "id": "B",
          "metin": "Orada çok sayıda insan toplanmıştı"
        },
        {
          "id": "C",
          "metin": "Kaya dalgaların yolunu kesiyordu"
        },
        {
          "id": "D",
          "metin": "Konumun yol haritası kaybolmuştu"
        }
      ],
      "dogru": "C",
      "aciklama": "İlk konumda yüksek bir kaya engel oluşturuyordu; radyo dalgalarının geçişini keser. Bakım kaydı, kalabalık ve yol haritası eleme nedeni olarak yazılmamıştır."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Ekip, vadinin karşı tarafında aynı anda ölçüm yaparak sinyal gücünü not etti.” cümlesindeki “sinyal” neyi anlatıyor?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Haberleşmeyi taşıyan işareti"
        },
        {
          "id": "B",
          "metin": "Yol kenarında duran büyük ağacı"
        },
        {
          "id": "C",
          "metin": "Araçların depodaki yakıtını"
        },
        {
          "id": "D",
          "metin": "Vadide esen soğuk rüzgârı"
        }
      ],
      "dogru": "A",
      "aciklama": "Ölçülen şey haberleşmeyi taşıyan işaretin gücüdür. Ağaç, yakıt ve rüzgâr bu ölçümle ilgili değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} bakım planını niçin hazırladı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Dağların adını değiştirmek için"
        },
        {
          "id": "B",
          "metin": "Haritayı daha da büyütmek için"
        },
        {
          "id": "C",
          "metin": "Denemeleri herkesten gizlemek için"
        },
        {
          "id": "D",
          "metin": "Sistemin sonra da çalışması için"
        }
      ],
      "dogru": "D",
      "aciklama": "Kontrol tarihleri ve arıza işaretleri düzenin kurulduktan sonra da çalışmasını sağlar. Dağ adı, harita boyutu ya da gizleme planın konusu değildir."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr149_verici",
        "tur": "kelime",
        "yazim": "verici",
        "anlam": "Sinyal ya da dalga yayan cihaz.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr149_verici_b",
        "tur": "kelime",
        "yazim": "anten",
        "anlam": "Radyo dalgalarını gönderen ya da alan düzenek.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr149_verici_c",
        "tur": "kelime",
        "yazim": "yayıcı",
        "anlam": "Bir sinyali uzağa ileten aygıt.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr149_sinyal",
        "tur": "kelime",
        "yazim": "sinyal",
        "anlam": "Bilgi taşıyan, iletilen işaret.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr149_sinyal_b",
        "tur": "kelime",
        "yazim": "işaret",
        "anlam": "Bir şeyi anlatan ya da haber veren belirti.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr149_sinyal_c",
        "tur": "kelime",
        "yazim": "dalga",
        "anlam": "Ortamda yayılan ve enerji taşıyan titreşim.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr149_engel",
        "tur": "kelime",
        "yazim": "engel",
        "anlam": "Bir yerin geçilmesini güçleştiren şey.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr149_engel_b",
        "tur": "kelime",
        "yazim": "kaya",
        "anlam": "Doğal olarak oluşmuş büyük ve sert taş kütlesi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr149_engel_c",
        "tur": "kelime",
        "yazim": "set",
        "anlam": "Suyun ya da hareketin tutulması için yapılan yükselti.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr149_kapsama",
        "tur": "kelime",
        "yazim": "kapsama",
        "anlam": "Bir sinyalin ulaşabildiği alanın genişliği.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr149_kapsama_b",
        "tur": "kelime",
        "yazim": "erişim",
        "anlam": "Bir yere ulaşabilme durumu.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr149_kapsama_c",
        "tur": "kelime",
        "yazim": "menzil",
        "anlam": "Bir cihazın etkili olduğu uzaklık sınırı.",
        "sinif_alt": 6,
        "sinif_ust": 6
      }
    ],
    "yuvalar": [
      {
        "ad": "hr149_verici",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr149_verici"
          },
          {
            "girdi": "hr149_verici_b"
          },
          {
            "girdi": "hr149_verici_c"
          }
        ]
      },
      {
        "ad": "hr149_sinyal",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr149_sinyal"
          },
          {
            "girdi": "hr149_sinyal_b"
          },
          {
            "girdi": "hr149_sinyal_c"
          }
        ]
      },
      {
        "ad": "hr149_engel",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr149_engel"
          },
          {
            "girdi": "hr149_engel_b"
          },
          {
            "girdi": "hr149_engel_c"
          }
        ]
      },
      {
        "ad": "hr149_kapsama",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr149_kapsama"
          },
          {
            "girdi": "hr149_kapsama_b"
          },
          {
            "girdi": "hr149_kapsama_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr150-baba-pazar-yerindeki-sessiz-terazi",
    "baslik": "Elmayı Farklı Tartan Teraziler",
    "tur": "mizah",
    "konu": "olcum_araci_kalibrasyonu",
    "sinif_alt": 6,
    "sinif_ust": 6,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "baba"
    ],
    "deger_anahtarlari": [
      "D1",
      "D6"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 6,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "mizah"
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
          "id": "sozcuk1_hr150",
          "tur": "lexeme",
          "etiket": "kalibrasyon",
          "yuva": "hr150_kalibrasyon",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr150",
          "tur": "lexeme",
          "etiket": "sapma",
          "yuva": "hr150_sapma",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr150",
          "tur": "lexeme",
          "etiket": "standart",
          "yuva": "hr150_standart",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr150",
          "tur": "lexeme",
          "etiket": "ağırlık",
          "yuva": "hr150_agirlik",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (6. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 487,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Pazardaki iki terazi aynı elmayı farklı tartıyor. {kahraman} suçlama yerine ölçüm yaparak karışıklığı çözüyor.",
    "durum": "taslak",
    "fis_kodu": "HR-150"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Pazar yerinde iki satıcının terazisi aynı elma kasası için farklı "
        },
        {
          "t": "kelime",
          "yuva": "hr150_agirlik"
        },
        {
          "t": "metin",
          "v": " gösteriyordu. Kimse kimseyi suçlamak istemiyordu ama aradaki fark müşterileri şaşırtmıştı. Ölçüm uzmanı "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", satıcıların çağrısıyla pazara geldi. Önce elmaların gerçekten aynı kasadan alındığını kontrol etti, aynı elmaların iki terazide de tartılacağından emin oldu. Sonra iki teraziyi aynı masaya koydu. Satıcılar önce kendi terazilerini öne çıkarmaya çalıştı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ferit"
        },
        {
          "t": "metin",
          "v": ", “Benimki hep doğru çıkar,” dedi. Öteki, “Benimki daha yeni,” diye karşılık verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " cihazların yaşına bakarak karar vermedi. Her teraziyi aynı sırayla, herkesin gözü önünde, ağırlıkları bilinen örneklerle denemeyi önerdi. Müşteriler de işlemi uzaktan izleyebiliyordu. Böylece kişilerin sözleri yerine ölçümler konuşacaktı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Masadaki özel ağırlıklar "
        },
        {
          "t": "kelime",
          "yuva": "hr150_standart"
        },
        {
          "t": "metin",
          "v": " olarak kullanıldı. Standart, herkesin aynı sonuca ulaşmasına yardım eden ortak ölçüdür. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " her iki terazide de sıfır ayarını kontrol etti ve her ağırlığı tek tek, boş tablayla başlayarak denedi. Masa eğri bir zeminde duruyordu ve iki terazi de tam oturmuyordu. Birinin ayağı eğri zeminde hafifçe havada kalıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " standart ağırlıkları temizleyip uygun biçimde yerleştirdi ve masanın sallanmadığından emin oldu. Sonuç tablosuna ölçümün nerede ve nasıl yapıldığını da yazdı; koşulları bilinmeyen bir sayıya güvenmek zordu. İlk "
        },
        {
          "t": "kelime",
          "yuva": "hr150_sapma"
        },
        {
          "t": "metin",
          "v": " buradan doğmuş olabilirdi. Terazi düz bir yüzeye alınınca fark küçüldü ama tamamen kaybolmadı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu kez "
        },
        {
          "t": "kelime",
          "yuva": "hr150_kalibrasyon"
        },
        {
          "t": "metin",
          "v": " yaptı; yani terazinin gösterdiği değerleri güvenilir ölçülerle karşılaştırıp ayarını kontrol etti. Satıcılar sonuçları küçük bir tabloya birlikte yazdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğleye doğru pazarda komik bir söylenti yayıldı: “Elmalar sabah hafif, öğlen ağır oluyor!” Bir müşteri bunu duyunca gülmeye başladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ölçüm koşullarını değiştirip yeniden denedi. Terazilerden birinin tablasına sıkışmış küçük bir karton parçası buldu. Karton, tartım sırasında dengeyi bozuyordu. Küçük bir ziyaretçi bir elmayı elinde tartar gibi sallayıp kaşlarını çattı ve elmaların gerçekten ağırlaşıp ağırlaşmadığını sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülerek, önce ölçüm aracında sorun aramadan böyle bir sonuca varılamayacağını anlattı. Temizlik ve ayarın ardından iki terazi aynı standart ağırlık için uyumlu sonuç verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " elma kasalarını yeniden tarttı; sonuçlar birbirine yakındı. Satıcılar sorunun elmada değil alette ve zeminde olduğunu görünce rahatladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Pazar yönetimi bütün tezgâhlarda basit bir kontrol günü düzenlemeye karar verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hangi kontrollerin uzman gerektirdiğini, hangilerinin günlük olarak gözlemlenebileceğini anlattı. Terazinin düz yerde durması, boşken sıfırı göstermesi ve hasar belirtisi olup olmaması herkesin bakabileceği şeylerdi. Resmî ayar ve doğrulamayı ise yetkili kişiler yapmalıydı; satıcılar her şeyi kendi başlarına onarmaya kalkışmamalıydı. Duyuru kısa ve resimli hazırlandı, bütün tezgâhlara dağıtıldı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ferit"
        },
        {
          "t": "metin",
          "v": " tabelasına “Terazim hiç şaşmaz” yazmak istedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun yerine ölçümlerin düzenli kontrol edildiğini belirten doğru bir ifade önerdi. Böylece müşterilere abartılı bir söz değil, güvenilir bir bilgi verilecekti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Akşam kasalar toplanırken iki satıcı birlikte elma tartıyordu. Sonuçlar birbirini doğruluyordu. Sabah şaşıran müşteri tekrar uğradı ve gülerek “Demek elmaların suçu yokmuş,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " standart ağırlıkları tek tek sayıp ölçüm çantasına yerleştirdi ve çantayı kapattı. Pazar kapanırken iki satıcı birbirine elma ikram etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tartışmanın başındaki cümleleri hatırladı: Biri yeniliğe, öteki alışkanlığa güvenmişti. Oysa ikisinin de ihtiyacı olan şey karşılaştırılabilir bir ölçüydü. Satıcılar ertesi gün tezgâhlarını kurarken masanın düz olup olmadığına bakmaya söz verdi. Adalet bazen büyük sözlerle değil, düzgün çalışan küçük araçlarla başlıyordu."
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
      "metin": "Tartışma hangi ürünün tartılmasıyla başladı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Elma kasası"
        },
        {
          "id": "B",
          "metin": "Ekmek sepeti"
        },
        {
          "id": "C",
          "metin": "Pirinç torbası"
        },
        {
          "id": "D",
          "metin": "Üzüm kutusu"
        }
      ],
      "dogru": "A",
      "aciklama": "İki terazi aynı elma kasası için farklı ağırlık gösteriyordu. Ekmek, pirinç ve üzüm metinde geçmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Terazilerden biri düz yüzeye alınınca fark küçüldü. Bunun nedeni ne olabilir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kasadaki elmalar değiştirildiği için"
        },
        {
          "id": "B",
          "metin": "Masa biraz daha yüksek olduğu için"
        },
        {
          "id": "C",
          "metin": "Eğri zemin tartıyı etkilediği için"
        },
        {
          "id": "D",
          "metin": "Terazinin rengi açık olduğu için"
        }
      ],
      "dogru": "C",
      "aciklama": "Bir terazinin ayağı eğri zeminde havada kaldığı için ölçüm bozuluyordu; düz yüzey bunu düzeltti. Elmalar değişmedi, masa yüksekliği ve renk de ölçümle ilgili değildir."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "Karton parçası tartım sırasında dengeyi bozuyordu. Buradaki “denge” neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Meyvenin tatlı ya da ekşi olması"
        },
        {
          "id": "B",
          "metin": "Tartının sallanmadan durması"
        },
        {
          "id": "C",
          "metin": "Pazar yerindeki kalabalığın artması"
        },
        {
          "id": "D",
          "metin": "Satış saatinin uzun sürmesi"
        }
      ],
      "dogru": "B",
      "aciklama": "Karton terazinin tablasına sıkışıp tartıyı sallantılı ve yanlış yapıyordu; denge, tartının düzgün durmasıdır. Tat, kalabalık ve satış saati bu anlama uymaz."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Satıcı tabelasına “Terazim hiç şaşmaz” yazmak isteyince {kahraman} neden başka bir ifade önerdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Tabelanın daha büyük olmasını istediği için"
        },
        {
          "id": "B",
          "metin": "Pazardaki tezgâh sayısını azaltmak için"
        },
        {
          "id": "C",
          "metin": "Elmaların adını değiştirmek için"
        },
        {
          "id": "D",
          "metin": "Doğrulanabilir bilgi vermek istediği için"
        }
      ],
      "dogru": "D",
      "aciklama": "“Hiç şaşmaz” abartılı bir söz; kontrol edildiğini belirten ifade ise doğrulanabilir. Tabela boyutu, tezgâh sayısı ve elma adı konu dışıdır."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr150_kalibrasyon",
        "tur": "kelime",
        "yazim": "kalibrasyon",
        "anlam": "Bir ölçü aletini doğru değerlerle karşılaştırıp ayarlama işi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr150_kalibrasyon_b",
        "tur": "kelime",
        "yazim": "ayar",
        "anlam": "Bir aletin doğru çalışacak biçimde düzenlenmesi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr150_kalibrasyon_c",
        "tur": "kelime",
        "yazim": "doğrulama",
        "anlam": "Bir ölçümün doğru olduğunu sınama işlemi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr150_sapma",
        "tur": "kelime",
        "yazim": "sapma",
        "anlam": "Beklenen değerden ayrılma, farklılık.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr150_sapma_b",
        "tur": "kelime",
        "yazim": "hata",
        "anlam": "Doğru olandan istenmeyen ayrılma.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr150_sapma_c",
        "tur": "kelime",
        "yazim": "fark",
        "anlam": "İki şey arasındaki ayrılık.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr150_standart",
        "tur": "kelime",
        "yazim": "standart",
        "anlam": "Herkesin aynı sonuca ulaşması için kabul edilen ölçü.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr150_standart_b",
        "tur": "kelime",
        "yazim": "ölçü",
        "anlam": "Bir şeyin miktarını belirlemeye yarayan birim.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr150_standart_c",
        "tur": "kelime",
        "yazim": "birim",
        "anlam": "Bir büyüklüğün ölçüldüğü temel değer.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr150_agirlik",
        "tur": "kelime",
        "yazim": "ağırlık",
        "anlam": "Bir cismin çekim etkisiyle ölçülen kütlesi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr150_agirlik_b",
        "tur": "kelime",
        "yazim": "kütle",
        "anlam": "Bir cismin içerdiği madde miktarı.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr150_agirlik_c",
        "tur": "kelime",
        "yazim": "yük",
        "anlam": "Taşınan şeyin ağırlığı.",
        "sinif_alt": 6,
        "sinif_ust": 6
      }
    ],
    "yuvalar": [
      {
        "ad": "hr150_kalibrasyon",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr150_kalibrasyon"
          },
          {
            "girdi": "hr150_kalibrasyon_b"
          },
          {
            "girdi": "hr150_kalibrasyon_c"
          }
        ]
      },
      {
        "ad": "hr150_sapma",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr150_sapma"
          },
          {
            "girdi": "hr150_sapma_b"
          },
          {
            "girdi": "hr150_sapma_c"
          }
        ]
      },
      {
        "ad": "hr150_standart",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr150_standart"
          },
          {
            "girdi": "hr150_standart_b"
          },
          {
            "girdi": "hr150_standart_c"
          }
        ]
      },
      {
        "ad": "hr150_agirlik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr150_agirlik"
          },
          {
            "girdi": "hr150_agirlik_b"
          },
          {
            "girdi": "hr150_agirlik_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr151-baba-avludaki-gunes-saati",
    "baslik": "Avludaki Güneş Saati",
    "tur": "tarih_kultur",
    "konu": "gunes_saati_restorasyonu",
    "sinif_alt": 7,
    "sinif_ust": 7,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "baba"
    ],
    "deger_anahtarlari": [
      "D7",
      "D12"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 7,
      "okuma_zorlugu": 4,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kultur_miras"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D7",
        "yardimci_deger": "D12"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr151",
          "tur": "lexeme",
          "etiket": "gölge",
          "yuva": "hr151_golge",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr151",
          "tur": "lexeme",
          "etiket": "saçak",
          "yuva": "hr151_sacak",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr151",
          "tur": "lexeme",
          "etiket": "referans",
          "yuva": "hr151_referans",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr151",
          "tur": "lexeme",
          "etiket": "tutarlılık",
          "yuva": "hr151_tutarlilik",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (7. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 587,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Bir hanın avlusundaki güneş saati şaşırtıcı sonuçlar veriyor. {kahraman} gölgelerin izini sürerek eski aracı yeniden anlamlandırıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-151"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Taş hanın avlusundaki güneş saati uzun zamandır doğru vakti göstermiyordu. Han, ziyaretçilerin eski ticaret yollarını tanıdığı küçük bir kültür alanına dönüştürülmüştü. Han, sabahtan akşama kadar gezi gruplarına açıktı ve güneş saati her grubun ilk durağıydı. Zaman ölçüm sistemleri üzerinde çalışan "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", saati incelemeye çağrıldı. İlk bakışta metal çubuğun hafifçe eğildiği görülüyordu. Avlunun taş duvarında geçmiş yıllardan kalma küçük çizikler de vardı; ziyaretçiler onları rastgele sanıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", çiziklerin saatle ilgili olup olmadığını incelemeden kesin konuşmadı. Avluya sonradan yapılan yüksek "
        },
        {
          "t": "kelime",
          "yuva": "hr151_sacak"
        },
        {
          "t": "metin",
          "v": ", güneşin gelişini bazı saatlerde engelliyordu. Bu yüzden aynı avlunun farklı saatlerdeki görünüşü fotoğraflandı ve eski fotoğraflar, avlunun yönü ve "
        },
        {
          "t": "kelime",
          "yuva": "hr151_golge"
        },
        {
          "t": "metin",
          "v": " izleriyle birlikte değerlendirildi. Ziyaretçilerden biri saatin rakamlarını yeni bir renkle boyamayı önerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", mekanizma anlaşılmadan görünüşe dokunmanın gereksiz olduğunu söyledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sabah boyunca gölge çizgisi izlendi. Güneşin konumu değiştikçe çubuğun gölgesi de taş zeminde yer değiştiriyordu; sabahın erken saatlerinde uzun, öğleye doğru kısa görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu hareketi belirli aralıklarla işaretleyip çizelgeye yazdı. Güneşli ve bulutlu saatler ayrı işaretlendi. Eski bir çizimde çubuğun açısı açıkça gösterilmişti; bu çizim güvenilir bir "
        },
        {
          "t": "kelime",
          "yuva": "hr151_referans"
        },
        {
          "t": "metin",
          "v": " sağlayabilirdi. Ancak çizimin hangi mevsimde hazırlandığı belli değildi. Gölgenin uzunluğu ve yönü mevsime göre değişirdi, bu yüzden eski kaydı tek başına yeterli saymadı. Bir görevli eski çizimin üzerine yeni çizgiler eklemeyi önerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " orijinal belgeyi değiştirmek yerine kopyası üzerinde çalıştı; eski çizim korunacak, yeni yorumlar da ayrı gösterilecekti. Farklı saatlerdeki ölçümlerle çizim arasında "
        },
        {
          "t": "kelime",
          "yuva": "hr151_tutarlilik"
        },
        {
          "t": "metin",
          "v": " aradı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Kerem"
        },
        {
          "t": "metin",
          "v": " birkaç saatte her şeyin çözüleceğini sanıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yöntemini anlattıkça neden birkaç gün gerektiği daha iyi anlaşıldı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkinci gün "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Kerem"
        },
        {
          "t": "metin",
          "v": " çubuğu elle düzeltmeye kalktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " durmasını rica etti; eski metal zorlanırsa zarar görebilirdi. Önce koruyucu bir destek hazırlanmalı, sonra uygun işlem belirlenmeliydi. Çubuğun destek noktasında eskiden yapılmış bir onarım izi vardı; ekip bu izin işlevi etkileyip etkilemediğini kontrol etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eski parçanın ölçülerini yazarken yalnızca uzunluğuna değil, yönüne ve bağlantı biçimine de baktı. Avlunun bir bölümü ziyaretçilere geçici olarak kapatıldı, güvenli geçişler işaretlendi. Taşlar ısındıkça ekip gölgeye çekilip notlarını düzenledi. Çubuğun eğikliği ile saçağın gölgesi ayrı ayrı incelendi. Bazı saatlerde yanlış görünen değerlerin bir kısmının, güneş saatinin çalışma biçiminin yanlış yorumlanmasından geldiği anlaşıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " açıklama panosuna, güneş saatinin bugünkü saatlerle her an birebir aynı sonucu vermeyebileceğini de yazdı. Gerçeği basitleştirmek başka, yanlış aktarmak başkaydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çubuk, uzman kontrolünde uygun konuma getirildi. Saçağın tamamını değiştirmek gerekmedi; gölgeyi etkileyen küçük bir bölüm yeniden düzenlendi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ertesi gün aynı saatlerde ölçümü tekrarladı; ölçümler farklı günlerde aynı saatte yinelendi ve sonuçlar önceki çizelgeye göre belirgin biçimde düzeldi. Bir gün hava aniden bulutlandı, gölge çizgisi kayboldu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu başarısızlık saymadı: Güneş saati ışık olmadan çalışamazdı, bu sınır aracın doğasındaydı. Ekip o gün diğer kayıtları düzenledi, eksik görülen saatleri listeledi ve uygun hava için yeni gözlem zamanı belirledi. Yine de farklı bir hava koşulunda ölçüm yapmadan işi tamamlanmış saymadı. Bir ziyaretçi, “Bu kadar küçük bir gölge için ne çok uğraştınız,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir çizgiye bakarak zaman okumanın uzun yılların bilgisine dayandığını hatırlattı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Son gün avlunun taş zemini temizlendi, ölçüm notları arşive kaldırıldı. Güneş ışığı çubuğa vurunca dar bir gölge eski çizgiye uzandı. Çevrede toplananlar şaşkınlıkla baktı. Panoya saatin nasıl okunacağını gösteren kısa bir örnek eklendi. Bir ziyaretçi önce kol saatine, sonra taş zemindeki çizgiye baktı; aradaki farkın bozulma anlamına gelmediğini öğrendi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", panodaki açıklamanın yanıltıcı olmaması için son kez kontrol yaptı. Çocuğuyla gezen bir ziyaretçi gölgeyi birlikte izleyebilecekleri bir noktada durdu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çalışmayı anlatan kısa bir kart hazırladı: “Zamanı göstermek için önce doğru bakmak gerekir.” Kartın yanına ölçümlerin tarihleri yazıldı. Akşama doğru avludan geçen bir rehber, panodaki örneği ziyaretçilere yüksek sesle okudu. Hanın sessiz avlusunda hareket eden ince gölge, sabırla biriken bilginin izini taşımaya devam etti."
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
      "metin": "Saatin çalışmasını etkileyen yeni yapı neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Ahşap merdiven"
        },
        {
          "id": "B",
          "metin": "Yüksek saçak"
        },
        {
          "id": "C",
          "metin": "Cam kapı"
        },
        {
          "id": "D",
          "metin": "Bahçe duvarı"
        }
      ],
      "dogru": "B",
      "aciklama": "Sonradan yapılan yüksek saçak güneşi bazı saatlerde engelliyordu. Merdiven, cam kapı ve bahçe duvarı metinde geçmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Eski çizim neden tek başına yeterli görülmedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çizimde hiçbir taş bulunmadığı için"
        },
        {
          "id": "B",
          "metin": "Çizim çok renksiz olduğu için"
        },
        {
          "id": "C",
          "metin": "Mevsimi belli olmadığı için"
        },
        {
          "id": "D",
          "metin": "Gölgeler her zaman aynı olduğu için"
        }
      ],
      "dogru": "C",
      "aciklama": "Gölge mevsime göre değiştiği için çizimin mevsimi bilinmeyince tek başına yeterli sayılmadı. Taş, renk ve gölgelerin hep aynı olması gerekçe değildir; gölgeler değişir."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "“Eski bir çizimde çubuğun açısı açıkça gösterilmişti.” cümlesindeki “açı” neyi anlatıyor?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çubuğun duruşuna ilişkin ölçüyü"
        },
        {
          "id": "B",
          "metin": "Avlunun giriş ücretine ilişkin tutarı"
        },
        {
          "id": "C",
          "metin": "Güneşin parlaklığına ilişkin ölçüyü"
        },
        {
          "id": "D",
          "metin": "Günlük ziyaretçi sayısına ilişkin ölçüyü"
        }
      ],
      "dogru": "A",
      "aciklama": "Çizimde çubuğun nasıl durduğunu gösteren ölçü yer alır; açı budur. Ücret, parlaklık ve ziyaretçi sayısı çubuğun açısı değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} neden farklı koşullarda yeniden ölçtü?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Daha uzun panolar hazırlamak için"
        },
        {
          "id": "B",
          "metin": "Rakamları tamamen silmek için"
        },
        {
          "id": "C",
          "metin": "Saati başka hana taşımak için"
        },
        {
          "id": "D",
          "metin": "Sonucun doğruluğunu sınamak için"
        }
      ],
      "dogru": "D",
      "aciklama": "Tek hava koşulundaki sonuç yetmediği için ölçüm farklı koşulda tekrarlandı; amaç doğruluğu sınamaktı. Pano uzatmak, rakamları silmek ya da saati taşımak amaç değildi."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr151_golge",
        "tur": "kelime",
        "yazim": "gölge",
        "anlam": "Bir cisme ışık engel olunca oluşan karanlık alan.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr151_golge_b",
        "tur": "kelime",
        "yazim": "karanlık",
        "anlam": "Işığın az ya da hiç bulunmadığı durum.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr151_golge_c",
        "tur": "kelime",
        "yazim": "yansıma",
        "anlam": "Bir yüzeyden geri dönen ışık.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr151_sacak",
        "tur": "kelime",
        "yazim": "saçak",
        "anlam": "Bir yapının duvarından dışarı uzanan çatı kenarı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr151_sacak_b",
        "tur": "kelime",
        "yazim": "çatı",
        "anlam": "Bir yapının üstünü örten kısım.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr151_sacak_c",
        "tur": "kelime",
        "yazim": "sundurma",
        "anlam": "Bir yapının bir kenarında gölge veren açık çatı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr151_referans",
        "tur": "kelime",
        "yazim": "referans",
        "anlam": "Bir karşılaştırmada esas alınan güvenilir ölçü ya da kaynak.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr151_referans_b",
        "tur": "kelime",
        "yazim": "kaynak",
        "anlam": "Bilginin alındığı yer ya da belge.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr151_referans_c",
        "tur": "kelime",
        "yazim": "ölçüt",
        "anlam": "Bir değerlendirmede esas alınan ölçü.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr151_tutarlilik",
        "tur": "kelime",
        "yazim": "tutarlılık",
        "anlam": "Birbirini doğrulayan, çelişmeyen durum.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr151_tutarlilik_b",
        "tur": "kelime",
        "yazim": "uyum",
        "anlam": "Parçaların birbirine uygun olması.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr151_tutarlilik_c",
        "tur": "kelime",
        "yazim": "süreklilik",
        "anlam": "Bir şeyin kesintisiz sürmesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      }
    ],
    "yuvalar": [
      {
        "ad": "hr151_golge",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr151_golge"
          },
          {
            "girdi": "hr151_golge_b"
          },
          {
            "girdi": "hr151_golge_c"
          }
        ]
      },
      {
        "ad": "hr151_sacak",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr151_sacak"
          },
          {
            "girdi": "hr151_sacak_b"
          },
          {
            "girdi": "hr151_sacak_c"
          }
        ]
      },
      {
        "ad": "hr151_referans",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr151_referans"
          },
          {
            "girdi": "hr151_referans_b"
          },
          {
            "girdi": "hr151_referans_c"
          }
        ]
      },
      {
        "ad": "hr151_tutarlilik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr151_tutarlilik"
          },
          {
            "girdi": "hr151_tutarlilik_b"
          },
          {
            "girdi": "hr151_tutarlilik_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr152-baba-topragin-sessiz-yolculugu",
    "baslik": "Yağmurla Yola Çıkan Toprak",
    "tur": "bilim",
    "konu": "toprak_erozyon_modeli",
    "sinif_alt": 7,
    "sinif_ust": 7,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "baba"
    ],
    "deger_anahtarlari": [
      "D5",
      "D19"
    ],
    "yetiskin_uygun": true,
    "etiketler": {
      "ana_sinif": 7,
      "okuma_zorlugu": 4,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "bilim_teknoloji"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D5",
        "yardimci_deger": "D19"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr152",
          "tur": "lexeme",
          "etiket": "erozyon",
          "yuva": "hr152_erozyon",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr152",
          "tur": "lexeme",
          "etiket": "örneklem",
          "yuva": "hr152_orneklem",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr152",
          "tur": "lexeme",
          "etiket": "eğim",
          "yuva": "hr152_egim",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr152",
          "tur": "lexeme",
          "etiket": "çökeltme",
          "yuva": "hr152_cokeltme",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (7. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 604,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Yağmur verimli toprağı tarlalardan uzaklaştırıyor. {kahraman} suyun ve toprağın hareketini inceleyerek kalıcı önlemler tasarlıyor.",
    "durum": "taslak",
    "fis_kodu": "HR-152"
  },
  "sayfalar": [
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kırsaldaki bir tepenin eteklerinde yağmurdan sonra bulanık su birikiyordu. Aşağıdaki küçük tarla bundan zarar görmüştü. Toprak bilimi uzmanı "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", suyun neden bu kadar çok toprak taşıdığını anlamak için çağrıldı. Tepeyi dolaşırken bir yerde ince, başka bir yerde kalın toprak tabakası gördü. Herkes toprağın bir yerden başka yere gittiğini anlatıyordu ama hangi yağmurdan sonra ne kadar değiştiğine dair ortak bir kayıt yoktu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " belirli gözlem noktaları seçti ve bunları köy odasının duvarındaki eski haritaya işaretledi; herkes aynı yerlere bakarsa gözlemler karşılaştırılabilirdi. Tarla sahipleri, işaretlerin günlük işlerine engel olmayacağı konusunda bilgilendirildi. Bazı yamaçlarda bitki örtüsü zayıflamıştı ama "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " her yere aynı tohumu ekmeyi önermedi. Önce toprağın yapısını, suyun izlediği yolu ve yüzeyin eğimini ayrı ayrı incelemek gerekiyordu. Çalışmayı köydeki arazi sahipleriyle birlikte planladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ekip tepenin farklı yerlerinden küçük bir "
        },
        {
          "t": "kelime",
          "yuva": "hr152_orneklem"
        },
        {
          "t": "metin",
          "v": " topladı. Örneklem, bütün alanı daha iyi anlamak için seçilen sınırlı sayıda parçadır. Toprak örnekleri aynı büyüklükte kaplara kondu ve karışmasınlar diye numaralandırıldı. Kapların altına akan suyu toplayan küçük tepsiler yerleştirildi. Sonra kontrollü biçimde, her kaba aynı miktarda su verildi. Bitki köklerinin bulunduğu örnekte suyun daha yavaş aktığı görüldü. Toprakların renkleri farklıydı; bazıları kolayca dağılıyor, bazıları daha toplu duruyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yalnızca renge bakarak karar vermedi. Topraktaki organik parçaların, bitki köklerinin ve farklı büyüklükteki tanelerin suyun davranışını etkileyebileceğini anlattı. Açıktaki toprak daha kolay taşınıyordu. Verimli üst toprağın yerinden kopup başka yere taşınmasına "
        },
        {
          "t": "kelime",
          "yuva": "hr152_erozyon"
        },
        {
          "t": "metin",
          "v": " denir. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sonuçları herkesin anlayacağı bir çizimle gösterdi ama kapta görülen sonucun doğrudan bütün tepeye uygulanamayacağını da ekledi; gerçek arazide rüzgâr, yağış ve zemin birlikte etkiliydi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkinci aşamada tepeden inen küçük akış yolları işaretlendi. Biri çok dik, diğeri daha yumuşak bir "
        },
        {
          "t": "kelime",
          "yuva": "hr152_egim"
        },
        {
          "t": "metin",
          "v": " taşıyordu. Yağmur sırasında suyun nerede hızlandığı güvenli bir noktadan gözlendi. Yağmur dindikten sonra akış yollarının kenarında küçük çukurlar ve sürüklenmiş çakıllar görüldü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", toprağın az sürüklendiği yerlerde bitki örtüsünün daha sık olduğunu not etti. Komşu arazilerde aynı yağmurun farklı izler bırakması dikkat çekiciydi; yamaçlar yalnızca diklik bakımından değil, bitki örtüsü ve yüzey yapısı bakımından da birbirinden ayrılıyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Nazım"
        },
        {
          "t": "metin",
          "v": ", kendi tarlasına yapılacak düzenlemenin aşağıdaki tarlayı etkileyebileceğini ilk kez bu kadar açık gördü. Komşu arazilerin sahipleri de görüşmeye çağrıldı ve herkes kendi sınırına değil, suyun bütün yolunu gösteren haritaya baktı. Bazı noktalarda geçici su yönlendirme düzenekleri işe yarayabilirdi ama yanlış yapılırlarsa sorunu başka tarlaya taşıyabilirdi. Bu yüzden çözüm tek bir parsele göre tasarlanmadı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Plan, toprağı koruyacak bitkilendirme alanlarını ve uzmanların belirlediği küçük su yavaşlatma noktalarını içeriyordu. Bir köşede "
        },
        {
          "t": "kelime",
          "yuva": "hr152_cokeltme"
        },
        {
          "t": "metin",
          "v": " için güvenli bir alan ayrıldı; suyla gelen ince parçaların nasıl biriktiği burada gözlenecekti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " her yere aynı yöntemi uygulamak yerine koşullara göre farklı çözümler seçti. Yavaşlatma noktaları yapılırken küçük canlıların geçiş yolları korundu, eski yürüyüş patikası açık tutuldu. Toprağı gereksiz kazmak, korunmak istenen yüzeyi daha da bozabilirdi. Ekip düzeneklerin yağmurlu havada nasıl davranacağını önceden tartıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", bakım ve kontrol tarihlerinin de yazılmasını istedi; kontrol edilmeyen bir düzenek zamanla yeni bir soruna dönüşebilirdi. Bu yüzden planın yanına bir izleme çizelgesi eklendi. İşaretlerin yanına bir yağmur ölçer de kondu; böylece her ölçüm aynı gün düşen yağmurla birlikte yazılacaktı. İlk yağmur beklenirken ekip ölçüm işaretlerini yerleştirdi ve not defterlerini hazırladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yağmurdan sonraki ölçümde su tam berrak değildi; zaten bunu hemen beklemek doğru olmazdı. Fakat bazı noktalarda taşınan toprak miktarı azalmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu erken bulguyu kesin başarı diye duyurmadı. Mevsim boyunca tekrarlanacak ölçümlerin daha güvenilir bilgi sağlayacağını söyledi. Defterlerin ilk sayfasına tarih, yağış ve gözlem yeri başlıkları açıldı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Nazım"
        },
        {
          "t": "metin",
          "v": " aşağıdaki komşusunu da ölçüme çağırdı. Tarla sahipleri bakım görevlerini mevsimlere göre paylaştı: Biri bitki örtüsünü, öbürü su akış işaretlerini kontrol edecekti. Tepeye bakan biri yapılan işleri yalnızca küçük çizgiler ve yeşil yamalar olarak görüyordu. Oysa bu çizgiler toprağın yerinde kalmasına yardım eden dikkatli bir planın parçalarıydı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " giderken örnek kaplarını topladı; toprağı korumak, onu önce anlamakla başlamıştı."
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
      "metin": "Araştırmayı başlatan temel sorun neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Tepenin bütünüyle kuruyup çatlaması"
        },
        {
          "id": "B",
          "metin": "Tarlaların başka yere kayması"
        },
        {
          "id": "C",
          "metin": "Yağmur suyunun toprağı taşıması"
        },
        {
          "id": "D",
          "metin": "Bütün yolların birden kapanması"
        }
      ],
      "dogru": "C",
      "aciklama": "Yağmurdan sonra biriken bulanık su, toprağın taşındığını gösteriyordu; araştırma bunun için başladı. Tepenin kuruması, tarlaların kayması ve yolların kapanması metinde geçmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Aynı büyüklükteki kaplarda köklü toprakta su daha yavaş akıyor. Bu neyi düşündürür?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bitki kökleri toprağı tutabilir"
        },
        {
          "id": "B",
          "metin": "Bütün bitkiler aynı türdendir"
        },
        {
          "id": "C",
          "metin": "Kapların büyüklüğü hiç önemli değildir"
        },
        {
          "id": "D",
          "metin": "Yağmur yalnızca yazın yağmaktadır"
        }
      ],
      "dogru": "A",
      "aciklama": "Kökler suyu yavaşlatıyor, bu da bitki örtüsünün toprağı tutmaya yardım edebileceğini düşündürür. Bitki türü, kap büyüklüğü ve yağış mevsimi bu deneyden çıkarılamaz."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Biri çok dik, diğeri daha yumuşak bir eğim taşıyordu.” cümlesindeki “eğim” hangi özelliği anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Toprağın rengini"
        },
        {
          "id": "B",
          "metin": "Yüzeyin diklik derecesini"
        },
        {
          "id": "C",
          "metin": "Yağmurun sıcaklığını"
        },
        {
          "id": "D",
          "metin": "Bitkilerin yaprak sayısını"
        }
      ],
      "dogru": "B",
      "aciklama": "Dik ve yumuşak sözcükleri yüzeyin ne kadar yatık olduğunu anlatır; eğim diklik derecesidir. Renk, sıcaklık ve yaprak sayısı eğimle ilgili değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 5,
      "metin": "Yağmurdan sonra toprak kaybı azalınca {kahraman} bunu neden kesin başarı saymadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çalışmayı kimseye göstermemek için"
        },
        {
          "id": "B",
          "metin": "Yeni örnek almak istemediği için"
        },
        {
          "id": "C",
          "metin": "Tarlaları bir an önce satmak için"
        },
        {
          "id": "D",
          "metin": "Ölçümlerin sürmesi gerektiği için"
        }
      ],
      "dogru": "D",
      "aciklama": "Tek yağmurun sonucu erken bir bulguydu; güvenilir bilgi için ölçümlerin mevsim boyunca sürmesi gerekiyordu. Gizleme, örnek almama ya da tarla satma gerekçe değildir."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr152_erozyon",
        "tur": "kelime",
        "yazim": "erozyon",
        "anlam": "Üst toprağın su ya da rüzgârla yerinden taşınması.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr152_erozyon_b",
        "tur": "kelime",
        "yazim": "aşınma",
        "anlam": "Yüzeyin sürtünme ya da su etkisiyle zamanla bozulması.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr152_erozyon_c",
        "tur": "kelime",
        "yazim": "sürüklenme",
        "anlam": "Malzemenin bir akıntıyla başka yere taşınması.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr152_orneklem",
        "tur": "kelime",
        "yazim": "örneklem",
        "anlam": "Bir bütünü temsil etmek için seçilen sınırlı parça kümesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr152_orneklem_b",
        "tur": "kelime",
        "yazim": "numune",
        "anlam": "İncelemek için seçilmiş küçük örnek.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr152_orneklem_c",
        "tur": "kelime",
        "yazim": "örnek",
        "anlam": "Bir bütünü temsil eden parça.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr152_egim",
        "tur": "kelime",
        "yazim": "eğim",
        "anlam": "Bir yüzeyin yatıklık ya da diklik derecesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr152_egim_b",
        "tur": "kelime",
        "yazim": "diklik",
        "anlam": "Bir yüzeyin dik olma durumu.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr152_egim_c",
        "tur": "kelime",
        "yazim": "meyil",
        "anlam": "Bir yüzeyin yatay düzlemle yaptığı açı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr152_cokeltme",
        "tur": "kelime",
        "yazim": "çökeltme",
        "anlam": "Sıvı içindeki katı parçaların dibe çökmesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr152_cokeltme_b",
        "tur": "kelime",
        "yazim": "birikme",
        "anlam": "Bir yerde zamanla toplanıp kalma.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr152_cokeltme_c",
        "tur": "kelime",
        "yazim": "tortu",
        "anlam": "Suyun dibinde kalan katı madde.",
        "sinif_alt": 7,
        "sinif_ust": 7
      }
    ],
    "yuvalar": [
      {
        "ad": "hr152_erozyon",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr152_erozyon"
          },
          {
            "girdi": "hr152_erozyon_b"
          },
          {
            "girdi": "hr152_erozyon_c"
          }
        ]
      },
      {
        "ad": "hr152_orneklem",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr152_orneklem"
          },
          {
            "girdi": "hr152_orneklem_b"
          },
          {
            "girdi": "hr152_orneklem_c"
          }
        ]
      },
      {
        "ad": "hr152_egim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr152_egim"
          },
          {
            "girdi": "hr152_egim_b"
          },
          {
            "girdi": "hr152_egim_c"
          }
        ]
      },
      {
        "ad": "hr152_cokeltme",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr152_cokeltme"
          },
          {
            "girdi": "hr152_cokeltme_b"
          },
          {
            "girdi": "hr152_cokeltme_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr153-arac-kirmizi-otobusun-yeni-duragi",
    "baslik": "Kırmızı Otobüsün Yeni Durağı",
    "tur": "arkadaslik",
    "konu": "otobus_durak_uyumu",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "arac"
    ],
    "deger_anahtarlari": [
      "D14",
      "D20"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 2,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "dostluk"
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
          "id": "sozcuk1_hr153",
          "tur": "lexeme",
          "etiket": "kaldırım",
          "yuva": "hr153_kaldirim",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr153",
          "tur": "lexeme",
          "etiket": "rampa",
          "yuva": "hr153_rampa",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr153",
          "tur": "lexeme",
          "etiket": "işaret",
          "yuva": "hr153_isaret",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr153",
          "tur": "lexeme",
          "etiket": "sıra",
          "yuva": "hr153_sira",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 267,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Yeni kaldırım otobüse binmeyi güçleştiriyor. {kahraman} herkesin daha rahat yolculuğa başlayacağı durak düzenini bekliyor.",
    "durum": "taslak",
    "fis_kodu": "HR-153"
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
          "v": " kırmızı bir şehir otobüsüydü. Her gün mahalledeki aynı duraklara uğrardı. Bir gün son durakta büyük bir kalabalık gördü. Yeni yapılan "
        },
        {
          "t": "kelime",
          "yuva": "hr153_kaldirim"
        },
        {
          "t": "metin",
          "v": " yüzünden bekleyenler kapıya rahat ulaşamıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " durdu ve kapılarını açmadan önce güvenli yanaşma yerini aradı. Kaldırımın başında bir "
        },
        {
          "t": "kelime",
          "yuva": "hr153_isaret"
        },
        {
          "t": "metin",
          "v": " vardı ama biraz ötede kalmıştı. İnsanlar nereye sıraya gireceklerini bilemiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu karışıklığın çözülmesini istiyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ece"
        },
        {
          "t": "metin",
          "v": ", duraktaki sorunu ulaşıma bildirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ertesi gün aynı yere geldiğinde yeni bir çizgi çekildiğini gördü. Çizgi, sıranın başlayacağı yeri gösteriyordu. Fakat kapının açıldığı yerde hâlâ dar bir boşluk vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kaldırımın doğru noktasına yanaştı. Kapısındaki "
        },
        {
          "t": "kelime",
          "yuva": "hr153_rampa"
        },
        {
          "t": "metin",
          "v": " güvenle açılabilmeliydi. Rampa, tekerleklerin düz bir geçişle otobüse ulaşmasını sağlayan eğimli yüzeydi. Bu kez kimse telaşla kapıya koşmadı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Durağın çevresinde ölçüm yapıldı. Bekleme çizgisi biraz geri alındı. Çöp kutusu da geçiş yolundan uzaklaştırıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yeni yere yanaştığında kapının önü açıktı. Biletini hazırlayanlar "
        },
        {
          "t": "kelime",
          "yuva": "hr153_sira"
        },
        {
          "t": "metin",
          "v": " boyunca ilerledi. Bir yolcu bastonuyla rahatça yürüyebildi. Sıranın sonundakiler öne geçmeye çalışmadan beklediler. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " herkesin yolculuğa aynı rahatlıkla başlamasını istedi. Güneş otobüsün camından içeri vuruyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk deneme yolculuğunda "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ece"
        },
        {
          "t": "metin",
          "v": " durakta bekledi. Birkaç kişinin yerini şaşırdığını gördü. Bunun üzerine işaret daha görünür bir yere taşındı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ikinci kez yanaştığında herkes kapının nerede açılacağını biliyordu. Kapı önünde sıkışma olmadı. Rampanın önü boş kaldı. Ulaşım görevlisi notlarına “Sıra çizgisi işe yaradı” yazdı. Kocaman bir otobüs için bile küçük bir çizgi büyük fark yaratmıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Akşam olunca "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " son seferine çıktı. Yenilenen durakta bekleyenler düzenli bir sıra oluşturdu. Kapısı açılınca herkes rahatça bindi. Önceki günkü karışıklık yoktu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yola çıkarken aynasında düzgün kaldırımı gördü. Çizgiyi çekenleri, ölçüm yapanları ve işareti taşıyanları düşündü. Küçük bir düzeltme, bütün durağın gününü değiştirmişti. Kırmızı otobüs sonraki durağa huzurla ilerledi."
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
      "metin": "Durağın önündeki sorun neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kaldırımın zor geçilmesi"
        },
        {
          "id": "B",
          "metin": "Otobüsün renginin değişmesi"
        },
        {
          "id": "C",
          "metin": "Bütün lambaların sönmesi"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Yeni yapılan kaldırım yüzünden bekleyenler kapıya rahat ulaşamıyordu.\" cümlesi A seçeneğini doğrular. Otobüsün rengi değişmemiş, biletler kaybolmamış ve lambalar sönmemişti; B, C ve D bu yüzden yanlıştır."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Rampanın açılabilmesi neden önemlidir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Herkes güvenle binebilsin diye"
        },
        {
          "id": "B",
          "metin": "Camların daha temiz kalması için"
        },
        {
          "id": "C",
          "metin": "Durakta daha çok ışık olması için"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Kapısındaki rampa güvenle açılabilmeliydi.\" cümlesi, rampanın herkesin güvenle binmesi için gerektiğini gösterir. Hız, camların temizliği ve durağın aydınlığı metinde rampayla ilişkilendirilmez."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Sıra” sözcüğü burada neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Otobüsün büyük tekerleğini"
        },
        {
          "id": "B",
          "metin": "Bekleyenlerin dizilişini"
        },
        {
          "id": "C",
          "metin": "Yolun uzayıp giden kısmını"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Biletini hazırlayanlar sıra boyunca ilerledi.\" cümlesinde sıra, yolcuların art arda dizilmiş hâlidir. Tekerlek, tabela ve yolun kısmı bu cümlede ilerleyen kişilerle ilgili değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "İşaret neden yeniden taşındı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Çöp kutusunu büyütmek için"
        },
        {
          "id": "B",
          "metin": "Durağı başka yere almak için"
        },
        {
          "id": "C",
          "metin": "Daha kolay görülsün diye"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Bunun üzerine işaret daha görünür bir yere taşındı.\" cümlesi, bazı kişilerin yerini şaşırması üzerine işaretin daha kolay görülsün diye taşındığını gösterir. Otobüsü saklamak, çöp kutusunu büyütmek ya da durağı başka yere almak metinde yoktur."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr153_kaldirim",
        "tur": "kelime",
        "yazim": "kaldırım",
        "anlam": "Yaya yolu olarak ayrılmış, yoldan yükseltilmiş kısım.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr153_kaldirim_b",
        "tur": "kelime",
        "yazim": "yaya yolu",
        "anlam": "Yayaların yürüdüğü ayrılmış yol.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr153_kaldirim_c",
        "tur": "kelime",
        "yazim": "bordür",
        "anlam": "Kaldırımla yolu ayıran sınır taşı.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr153_rampa",
        "tur": "kelime",
        "yazim": "rampa",
        "anlam": "Yüzeyi eğimli olarak yapılan geçiş yolu.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr153_rampa_b",
        "tur": "kelime",
        "yazim": "eğim",
        "anlam": "Bir yüzeyin yatıklık derecesi.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr153_rampa_c",
        "tur": "kelime",
        "yazim": "çıkıntı",
        "anlam": "Bir yüzeyden dışarı doğru çıkan kısım.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr153_isaret",
        "tur": "kelime",
        "yazim": "işaret",
        "anlam": "Bir şeyi gösteren ya da yön belirten simge ve belirti.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr153_isaret_b",
        "tur": "kelime",
        "yazim": "tabela",
        "anlam": "Bilgi vermek için bir yere asılan levha.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr153_isaret_c",
        "tur": "kelime",
        "yazim": "levha",
        "anlam": "Üzerinde bilgi ya da uyarı yazılı düz yüzey.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr153_sira",
        "tur": "kelime",
        "yazim": "sıra",
        "anlam": "Birinin arkasına art arda dizilmiş insanlar ya da şeyler.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr153_sira_b",
        "tur": "kelime",
        "yazim": "dizi",
        "anlam": "Birbirini izleyen şeyler topluluğu.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr153_sira_c",
        "tur": "kelime",
        "yazim": "kuyruk",
        "anlam": "Bir yerde sırayla bekleyenlerin dizilişi.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "hr153_kaldirim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr153_kaldirim"
          },
          {
            "girdi": "hr153_kaldirim_b"
          },
          {
            "girdi": "hr153_kaldirim_c"
          }
        ]
      },
      {
        "ad": "hr153_rampa",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr153_rampa"
          },
          {
            "girdi": "hr153_rampa_b"
          },
          {
            "girdi": "hr153_rampa_c"
          }
        ]
      },
      {
        "ad": "hr153_isaret",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr153_isaret"
          },
          {
            "girdi": "hr153_isaret_b"
          },
          {
            "girdi": "hr153_isaret_c"
          }
        ]
      },
      {
        "ad": "hr153_sira",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr153_sira"
          },
          {
            "girdi": "hr153_sira_b"
          },
          {
            "girdi": "hr153_sira_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr154-arac-minik-teknenin-kopuk-yolu",
    "baslik": "Minik Teknenin Köpük Yolu",
    "tur": "doga",
    "konu": "gol_temizligi",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "arac"
    ],
    "deger_anahtarlari": [
      "D18",
      "D9"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 2,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "doga"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D18",
        "yardimci_deger": "D9"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr154",
          "tur": "lexeme",
          "etiket": "kıyı",
          "yuva": "hr154_kiyi",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr154",
          "tur": "lexeme",
          "etiket": "birikinti",
          "yuva": "hr154_birikinti",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr154",
          "tur": "lexeme",
          "etiket": "ağ",
          "yuva": "hr154_ag",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr154",
          "tur": "lexeme",
          "etiket": "akıntı",
          "yuva": "hr154_akinti",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 251,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Küçük bir temizlik teknesi gölde değişen bir köpük çizgisi görüyor. {kahraman} canlıları rahatsız etmeden kıyıyı temizliyor.",
    "durum": "taslak",
    "fis_kodu": "HR-154"
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
          "v": " gölde çalışan küçük bir temizlik teknesiydi. Her sabah "
        },
        {
          "t": "kelime",
          "yuva": "hr154_kiyi"
        },
        {
          "t": "metin",
          "v": " yakınındaki yaprakları ve çöpleri toplardı. Bir gün suyun üzerinde uzun bir köpük çizgisi gördü. Köpük, hafif "
        },
        {
          "t": "kelime",
          "yuva": "hr154_akinti"
        },
        {
          "t": "metin",
          "v": " ile gölün bir köşesine taşınıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " oraya hızla gitmedi. Çünkü kıyıda dinlenen ördekleri ürkütmek istemiyordu. Önce yavaşça ilerledi, sonra yüzeyde biriken parçaları gözledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Nazlı"
        },
        {
          "t": "metin",
          "v": " köpüğün nereden geldiğini anlamak için suyu inceledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise yalnızca güvenli bölgede çalışıyordu. Önündeki geniş "
        },
        {
          "t": "kelime",
          "yuva": "hr154_ag"
        },
        {
          "t": "metin",
          "v": " suyun üzerindeki küçük çöpleri topluyordu. Ağ, suyun içindeki canlılara zarar vermeyecek biçimde kullanılıyordu. Gölün kenarında bir plastik kap yüzüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dikkatle yaklaşıp kabı toplama bölümüne aldı. Köpüğün nedenini bilmeden hiçbir maddeyi suya dökmedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Rüzgâr yön değiştirince yüzeydeki "
        },
        {
          "t": "kelime",
          "yuva": "hr154_birikinti"
        },
        {
          "t": "metin",
          "v": " de başka yere kaydı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " görevlinin belirlediği yeni yola yöneldi. Sığ alanda hızını düşürdü. Su üstündeki çöp parçaları yavaşça ağa doldu. Kıyıdaki sazlar arasında küçük bir kuş dinleniyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " o bölgeye girmedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Nazlı"
        },
        {
          "t": "metin",
          "v": ", gölün temiz kalması için çöplerin kıyıda da toplanması gerektiğini söyledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğleden sonra kıyıya dönen "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", topladığı atıkları ayrılmış kutulara bıraktı. Görevli köpüğün nedenini anlamak için uzman incelemesinin sürdüğünü anlattı. Her köpüğün aynı sebeple oluşmadığını, bu yüzden acele karar verilmemesi gerektiğini belirtti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " işinin bittiğini sanmadı. Ertesi gün için yeni bir kontrol rotası hazırladı. Dalgalar teknenin yanına usulca vuruyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi sabah göl daha temiz görünüyordu. Ördekler kıyıda sakin sakin yüzüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " suyun üstündeki son yaprakları topladı. Kıyı boyunca çöpler için yeni kutular konmuştu. Ziyaretçiler atıklarını buralara bırakmaya başladı. Küçük tekne kocaman gölün tamamını bir günde değiştiremezdi. Ama her sabah kıyıdan bir avuç yaprak ve çöp eksiliyor, ördeklerin yüzdüğü su biraz daha berraklaşıyordu."
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
      "metin": "Teknenin ilk gördüğü şey neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Suyu kesen büyük bir köprü"
        },
        {
          "id": "B",
          "metin": "Uzun bir köpük çizgisi"
        },
        {
          "id": "C",
          "metin": "Kıyıya düşmüş yaşlı bir ağaç"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Bir gün suyun üzerinde uzun bir köpük çizgisi gördü.\" cümlesi B seçeneğini doğrular. Köprü, düşmüş ağaç ve yeni iskele metinde hiç geçmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "{kahraman} neden köpüğe rastgele madde dökmedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Teknenin boyası ve rengi zarar görmesin diye"
        },
        {
          "id": "B",
          "metin": "Durumu bilmeden zarar vermemek için"
        },
        {
          "id": "C",
          "metin": "Toplama kutusunda yer kalmadığı için"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Köpüğün nedenini bilmeden hiçbir maddeyi suya dökmedi.\" cümlesi, tekneyi sebebini bilmediği bir durumda zarar vermekten kaçındığını gösterir. Teknenin rengi, batan güneş ve dolu kutu metinde bu kararın nedeni olarak geçmez."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Birikinti” sözcüğü neyi belirtir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir yerde toplanan parçaları"
        },
        {
          "id": "B",
          "metin": "Güneşin suya vuran yansımasını"
        },
        {
          "id": "C",
          "metin": "Kıyıda ziyaretçilerin oturduğu yeri"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Rüzgâr yön değiştirince yüzeydeki birikinti de başka yere kaydı.\" cümlesinde birikinti, yüzeyde bir araya gelmiş parçalardır; rüzgârla birlikte kayması bunu gösterir. Gölün derinliği, yansıma ve oturma yeri kayabilecek şeyler değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 3,
      "metin": "Tekne sazlıklara neden girmedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Köpüğün biriktiği yerden daha çok toplamak için"
        },
        {
          "id": "B",
          "metin": "Görevliyi bekletmek için"
        },
        {
          "id": "C",
          "metin": "Dinlenen kuşu ürkütmemek için"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Kıyıdaki sazlar arasında küçük bir kuş dinleniyordu.\" cümlesi, teknenin sazlığa girmeyerek kuşu ürkütmemeyi seçtiğini gösterir. Yolu kısaltmak, daha çok köpük toplamak ve görevliyi bekletmek metinde sazlıktan kaçınmanın nedeni değildir."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr154_kiyi",
        "tur": "kelime",
        "yazim": "kıyı",
        "anlam": "Denizin ya da gölün karaya bitişen kenar kısmı.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr154_kiyi_b",
        "tur": "kelime",
        "yazim": "kenar",
        "anlam": "Bir yerin dış sınırına yakın bölüm.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr154_kiyi_c",
        "tur": "kelime",
        "yazim": "sahil",
        "anlam": "Denizin ya da gölün kıyısı boyunca uzanan alan.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr154_birikinti",
        "tur": "kelime",
        "yazim": "birikinti",
        "anlam": "Bir yerde toplanan parçalar ya da madde.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr154_birikinti_b",
        "tur": "kelime",
        "yazim": "yığın",
        "anlam": "Bir yerde üst üste toplanmış şey.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr154_birikinti_c",
        "tur": "kelime",
        "yazim": "köpük",
        "anlam": "Su yüzeyinde toplanan kabarcıklı tabaka.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr154_ag",
        "tur": "kelime",
        "yazim": "ağ",
        "anlam": "Su ya da havadaki parçaları yakalamak için örülmüş düzenek.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr154_ag_b",
        "tur": "kelime",
        "yazim": "süzgeç",
        "anlam": "Sıvıdaki katı parçaları ayıran gözenekli düzenek.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr154_ag_c",
        "tur": "kelime",
        "yazim": "file",
        "anlam": "İnce iplerden örülmüş tutucu.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr154_akinti",
        "tur": "kelime",
        "yazim": "akıntı",
        "anlam": "Suyun belirli bir yönde akması.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr154_akinti_b",
        "tur": "kelime",
        "yazim": "akım",
        "anlam": "Suyun ya da havanın hareket yönü ve hızı.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr154_akinti_c",
        "tur": "kelime",
        "yazim": "dalga",
        "anlam": "Su yüzeyinde ilerleyen yükseltilmiş hareket.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "hr154_kiyi",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr154_kiyi"
          },
          {
            "girdi": "hr154_kiyi_b"
          },
          {
            "girdi": "hr154_kiyi_c"
          }
        ]
      },
      {
        "ad": "hr154_birikinti",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr154_birikinti"
          },
          {
            "girdi": "hr154_birikinti_b"
          },
          {
            "girdi": "hr154_birikinti_c"
          }
        ]
      },
      {
        "ad": "hr154_ag",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr154_ag"
          },
          {
            "girdi": "hr154_ag_b"
          },
          {
            "girdi": "hr154_ag_c"
          }
        ]
      },
      {
        "ad": "hr154_akinti",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr154_akinti"
          },
          {
            "girdi": "hr154_akinti_b"
          },
          {
            "girdi": "hr154_akinti_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr155-arac-trenin-dinledigi-raylar",
    "baslik": "Trenin Dinlediği Raylar",
    "tur": "bilim",
    "konu": "ray_temasi_gozlemi",
    "sinif_alt": 6,
    "sinif_ust": 6,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "arac"
    ],
    "deger_anahtarlari": [
      "D16",
      "D12"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 6,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "bilim_teknoloji"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D16",
        "yardimci_deger": "D12"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr155",
          "tur": "lexeme",
          "etiket": "sürtünme",
          "yuva": "hr155_surtunme",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr155",
          "tur": "lexeme",
          "etiket": "titreşim",
          "yuva": "hr155_titresim",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr155",
          "tur": "lexeme",
          "etiket": "bakım",
          "yuva": "hr155_bakim",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr155",
          "tur": "lexeme",
          "etiket": "kontrol",
          "yuva": "hr155_kontrol",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (6. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 524,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Bir tren, viraj çıkışında alışılmadık bir sarsıntı hissediyor. {kahraman} güvenli bakım tamamlanana kadar raylardaki işaretleri izliyor.",
    "durum": "taslak",
    "fis_kodu": "HR-155"
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
          "v": " dağ eteklerinden geçen bir yolcu treniydi. Her seferinde tüneli geçtikten sonra kısa bir sarsıntı hissediyordu. Sarsıntı yalnızca bir virajdan çıkarken beliriyordu. Kontrol sistemleri normal çalışsa da bu değişikliğin anlaşılması gerekiyordu. "
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
          "yuva": "hr155_bakim"
        },
        {
          "t": "metin",
          "v": " merkezine girdiğinde teknisyenler yeni kayıtları inceledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ferhat"
        },
        {
          "t": "metin",
          "v": " gecikmeye ilişkin duyuruyu güncelledi, bekleyenlere alternatif saatler sunuldu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " seferlerin değişmesinin yolcuları etkilediğini biliyordu. Yine de bakım kararı belirsiz bir söylentiye değil, kayıtlarla doğrulanan bir inceleme ihtiyacına dayanıyordu. Küçük bir farklılığı görmezden gelmek, yolcuların güvenliğini şansa bırakmak olurdu. Bakım ekibi ölçümleri tamamlayana kadar planlanan sefer değiştirildi. Bu karar bazı yolcuları bekletti ama gerekçesi duyuruda açıklandı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Rayların bulunduğu bölümde uzman ekip çalıştı. İki yüzey birbirine değdiğinde oluşan "
        },
        {
          "t": "kelime",
          "yuva": "hr155_surtunme"
        },
        {
          "t": "metin",
          "v": ", trenin hareketini etkileyebiliyordu. Ekip, tekerlek ve ray temasındaki ölçümleri "
        },
        {
          "t": "kelime",
          "yuva": "hr155_kontrol"
        },
        {
          "t": "metin",
          "v": " etti. Ardından kayıt cihazındaki "
        },
        {
          "t": "kelime",
          "yuva": "hr155_titresim"
        },
        {
          "t": "metin",
          "v": " bilgilerini bir grafik üzerinde inceledi. Tekerlek yüzeyindeki izler incelenirken uzmanlar bakım geçmişine de baktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " her rayda aynı sesin oluşmadığını anımsıyordu. Bu ayrıntı, sorunun bütün hatta yayılan bir bozukluk olmayabileceğini düşündürdü. Ekip farklı olasılıkları listeden birer birer kontrol etti; henüz kanıtlanmamış bir tahmini sonuç diye yazmadı. İlk incelemede raylarda büyük bir bozukluk görünmüyordu. Fakat yağmurdan sonra bir noktada ince kum biriktiği fark edildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " aynı bölgeden geçen önceki seferlerin kayıtlarını anımsıyordu. Değişiklik, kumun artmaya başladığı günlerde belirginleşmişti. Teknisyenler bu bağlantıyı not etti ama başka olasılıkları da incelemeye devam etti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Hattın ilgili bölümü yetkililerce güvenli çalışmaya kapatıldı. Ray çevresindeki birikinti temizlendi, drenaj kontrol edildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " daha sonra boş olarak test yolculuğuna çıktı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ferhat"
        },
        {
          "t": "metin",
          "v": " kontrol ekranındaki değerleri izliyordu. Deneme sürüşünün ardından elde edilen grafikler üst üste getirildi. Bazı değerler azalmıştı ama hepsi aynı miktarda değişmemişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu fark ettiğinde daha fazla ölçüm yapılmasının iyi olacağını düşündü. Teknisyenler farklı hız aralıklarında izin verilen koşulları karşılaştırdı. Küçük ayrıntılar birlikte incelendiğinde daha açık bir tablo oluştu. Sarsıntı azalmıştı; fakat viraj çıkışında hafif bir hareket hâlâ hissediliyordu. Ekip bu kez ray bağlantılarındaki küçük ayar farklılığını inceledi. İki ölçüm arasındaki fark net biçimde kaydedildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " değişikliğin nedenini tek bir olaya bağlamanın ne kadar yanıltıcı olabileceğini gördü. Birden fazla küçük etken bir araya gelmişti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Gerekli bakım tamamlanınca tekrar deneme yapıldı. Ray boyunca kontrol noktaları işaretlenmişti. Tren her birinden geçerken hareket verileri kaydedildi. Test sonuçları uzman ekip tarafından değerlendirildi ve hat ancak uygun görülünce açıldı. Peronun kenarında bekleyen yolculara yaklaşma çizgisinin gerisinde durmaları hatırlatıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " duraklamanın ve yeniden hareket etmenin de yolculuğun önemli parçaları olduğunu düşünüyordu. Güvenli bir hat tek başına yeterli değildi; istasyondaki açık işaretler ve düzenli duyurular da yolculuğun tamamını destekliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " istasyona yaklaşırken peronun aydınlık çizgisini gördü. Peron, yolcuların tren beklediği yükseltilmiş bölümdü. Yolcular yeniden düzenlenen sefer saatini tabeladan öğrendi. Gecikme için açıklama yapılmıştı. Yolculuk sırasında saklanan bir sorun kalmamış olması, herkesi rahatlattı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sonraki hafta "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " aynı virajı geçerken sarsıntıyı hissetmedi. Ama bakım kayıtlarının düzenli tutulması devam etti. Tren, her şey yolundayken yapılan kontrollerin de önemli olduğunu biliyordu. İstasyonda bir çocuk pencerenin ardından dağları gösterdi. Dağ manzarası vagondaki pencerelerden birer birer geçiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eski sarsıntıyı artık hissetmemekle yetinmedi; düzenli kontrollerin sürmesini değerli buldu. Çünkü bir sorun ortadan kalktığında ona yol açan koşulları hatırlamak gelecekteki işleri kolaylaştırırdı. İstasyonda tutulan dosya bunun için hazırlanmıştı. Yolcular sessizce yolculuğuna devam etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " raylardan yükselen düzenli sesi dinledi. Ses düzgündü ve ritmi bir an bile aksamıyordu. Dağlar geride kalırken yol devam etti."
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
      "metin": "Sarsıntı hangi bölgede fark ediliyordu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Tünel sonrası virajda"
        },
        {
          "id": "B",
          "metin": "İstasyon kapısında"
        },
        {
          "id": "C",
          "metin": "Yolcu vagonunda"
        },
        {
          "id": "D",
          "metin": "Bakım merkezinin girişinde"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Sarsıntı yalnızca bir virajdan çıkarken beliriyordu.\" ifadesi doğru seçeneği destekler."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "İnce kumun bulunması neden önemliydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bilet fiyatını ve seferleri belirlediği için"
        },
        {
          "id": "B",
          "metin": "Sarsıntıyla ilgili olabileceği için"
        },
        {
          "id": "C",
          "metin": "Peronu büyütüp genişlettiği için"
        },
        {
          "id": "D",
          "metin": "Rayın rengini değiştirdiği için"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Fakat yağmurdan sonra bir noktada ince kum biriktiği fark edildi.\" cümlesi, kumun sarsıntının olası bir etkeni olarak incelendiğini gösterir; metinde değişikliğin kumun arttığı günlerde belirginleştiği de yazar. Bilet fiyatı, peronun boyutu ve rayın rengi kumla ilişkilendirilmez."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Birikinti” ifadesi bağlamda neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Trenin hız göstergesindeki ibreyi"
        },
        {
          "id": "B",
          "metin": "Hatta yeni eklenen bir vagonu"
        },
        {
          "id": "C",
          "metin": "Bir noktada toplanan maddeyi"
        },
        {
          "id": "D",
          "metin": "İstasyonun girişindeki büyük tabelayı"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Ray çevresindeki birikinti temizlendi, drenaj kontrol edildi.\" cümlesinde birikinti, rayın çevresinde toplanıp temizlenen maddedir; önceki bölümde biriken ince kum da bunu destekler. Hız göstergesi, vagon ve tabela temizlenen şeyler değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Hat niçin yalnızca son test uygun bulununca açıldı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Gecikmeyi artırmak için"
        },
        {
          "id": "B",
          "metin": "Treni başka yere satmak için"
        },
        {
          "id": "C",
          "metin": "Bütün istasyonları kapatmak için"
        },
        {
          "id": "D",
          "metin": "Güvenliği doğrulamak için"
        }
      ],
      "dogru": "D",
      "aciklama": "Metindeki \"Test sonuçları uzman ekip tarafından değerlendirildi ve hat ancak uygun görülünce açıldı.\" cümlesi, hattın güvenliği doğrulanmadan açılmadığını gösterir. Gecikmeyi artırmak, treni satmak ya da istasyonları kapatmak metinde hiç amaç olarak geçmez."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr155_surtunme",
        "tur": "kelime",
        "yazim": "sürtünme",
        "anlam": "İki yüzey birbirine değerken oluşan direnç.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr155_surtunme_b",
        "tur": "kelime",
        "yazim": "direnç",
        "anlam": "Bir hareketi zorlaştıran karşı etki.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr155_surtunme_c",
        "tur": "kelime",
        "yazim": "aşınma",
        "anlam": "Yüzeyin sürtünmeyle zamanla bozulması.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr155_titresim",
        "tur": "kelime",
        "yazim": "titreşim",
        "anlam": "Bir cismin ileri geri hızlı hareketi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr155_titresim_b",
        "tur": "kelime",
        "yazim": "sarsıntı",
        "anlam": "Bir cismin ani ve düzensiz sallanması.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr155_titresim_c",
        "tur": "kelime",
        "yazim": "salınım",
        "anlam": "Bir şeyin denge noktası etrafında gidip gelmesi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr155_bakim",
        "tur": "kelime",
        "yazim": "bakım",
        "anlam": "Bir şeyin iyi çalışması için yapılan düzenli işlem.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr155_bakim_b",
        "tur": "kelime",
        "yazim": "onarım",
        "anlam": "Bozulmuş bir şeyi düzeltme işi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr155_bakim_c",
        "tur": "kelime",
        "yazim": "servis",
        "anlam": "Bir aracın ya da cihazın düzenli olarak kontrol edildiği hizmet.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr155_kontrol",
        "tur": "kelime",
        "yazim": "kontrol",
        "anlam": "Bir şeyin doğru çalışıp çalışmadığını denetleme.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr155_kontrol_b",
        "tur": "kelime",
        "yazim": "denetim",
        "anlam": "Bir işin kurallara uygunluğunu inceleme.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr155_kontrol_c",
        "tur": "kelime",
        "yazim": "gözlem",
        "anlam": "Bir durumu dikkatle izleme.",
        "sinif_alt": 6,
        "sinif_ust": 6
      }
    ],
    "yuvalar": [
      {
        "ad": "hr155_surtunme",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr155_surtunme"
          },
          {
            "girdi": "hr155_surtunme_b"
          },
          {
            "girdi": "hr155_surtunme_c"
          }
        ]
      },
      {
        "ad": "hr155_titresim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr155_titresim"
          },
          {
            "girdi": "hr155_titresim_b"
          },
          {
            "girdi": "hr155_titresim_c"
          }
        ]
      },
      {
        "ad": "hr155_bakim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr155_bakim"
          },
          {
            "girdi": "hr155_bakim_b"
          },
          {
            "girdi": "hr155_bakim_c"
          }
        ]
      },
      {
        "ad": "hr155_kontrol",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr155_kontrol"
          },
          {
            "girdi": "hr155_kontrol_b"
          },
          {
            "girdi": "hr155_kontrol_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr156-arac-yeniden-kesfedilen-iskele",
    "baslik": "Yeniden Keşfedilen İskele",
    "tur": "gezi_kultur",
    "konu": "elektrikli_feribot_duraklari",
    "sinif_alt": 6,
    "sinif_ust": 6,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "arac"
    ],
    "deger_anahtarlari": [
      "D17",
      "D14"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 6,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kesif"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D17",
        "yardimci_deger": "D14"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr156",
          "tur": "lexeme",
          "etiket": "rota",
          "yuva": "hr156_rota",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr156",
          "tur": "lexeme",
          "etiket": "menzil",
          "yuva": "hr156_menzil",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr156",
          "tur": "lexeme",
          "etiket": "iskele",
          "yuva": "hr156_iskele",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr156",
          "tur": "lexeme",
          "etiket": "yoğunluk",
          "yuva": "hr156_yogunluk",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (6. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 592,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Kıyıdaki bir iskele yeni ulaşım ihtiyacına cevap verebilir mi? {kahraman} enerji, güvenlik ve bekleme sürelerini birlikte değerlendiren bir rota keşfediyor.",
    "durum": "taslak",
    "fis_kodu": "HR-156"
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
          "v": " iki kıyı arasında yolcu taşıyan elektrikli bir feribottu. Günlük rotası kısa ve sakindi. Fakat yeni açılan bir yürüyüş alanı yüzünden bir iskelede yolcu yoğunluğu artmıştı. Herkes aynı feribota binmek isteyince bekleme süresi uzuyordu. Kayıtlara göre bekleme süresi sabah ilk seferde ve akşamüstü özellikle uzuyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu "
        },
        {
          "t": "kelime",
          "yuva": "hr156_yogunluk"
        },
        {
          "t": "metin",
          "v": " verisinin, yeni durak kararını nasıl etkilediğini anlamak istedi. Sakin saatlerde ek iskeleye uğramak yolcuları pek rahatlatmayacak, gereksiz enerji kullanacaktı. İşletme ekibi sayıları günlere göre de karşılaştırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yeni bir güzergâh düşünmeye başladı. Ancak hangi iskeleye uğrayacağına yalnızca kendi isteğiyle karar veremezdi. Kıyı işletmesinin güvenlik, zaman ve enerji planına uyması gerekiyordu. Feribotun kontrol sisteminde duraklardaki bekleme bilgileri toplanıyordu. Bu bilgiler sayesinde kalabalığın yalnızca hangi saatlerde oluştuğu değil, başka iskelelerin nasıl kullanıldığı da görülebilecekti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk incelemede kıyının daha sakin bir noktasında eski bir "
        },
        {
          "t": "kelime",
          "yuva": "hr156_iskele"
        },
        {
          "t": "metin",
          "v": " bulundu. Haritada yalnızca bakım alanı olarak işaretlenmişti; yolcu kullanımına uygun olup olmadığı bilinmiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu konumu hemen rotasına eklemedi. Uzmanlar iskelenin yapısını, su derinliğini ve yanaşma koşullarını inceledi. Eski iskelenin girişinde kıyı boyunca uzanan taşlar vardı. Uzmanlar yolcu geçişinin bu alanla nasıl bağlantı kuracağını inceledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yaklaşma açısının değişmesi hâlinde rotanın da yeniden hesaplanması gerektiğini biliyordu. Yanaşma düzeni ve erişim yolu aynı planda değerlendirildi. Yalnızca feribotun ulaşması yeterli değildi. Ayrıca bataryanın "
        },
        {
          "t": "kelime",
          "yuva": "hr156_menzil"
        },
        {
          "t": "metin",
          "v": " sınırı hesaplandı. Menzil, bir aracın mevcut enerjiyle güvenle gidebileceği uzaklıktı. Yeni bir durak eklemek, yalnızca haritadaki çizgiyi uzatmak değildi. Şarj süresi, yolcu inişi ve hava koşulları da birlikte düşünülmeliydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " enerji göstergesindeki değişiklikleri izleyerek olası rotaları karşılaştırdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Önerilen ilk "
        },
        {
          "t": "kelime",
          "yuva": "hr156_rota"
        },
        {
          "t": "metin",
          "v": " bazı saatlerde beklemeyi azaltıyor ama günün sonunda fazla enerji tüketiyordu. İkinci öneri ise sakin iskeleyi yalnızca yoğun saatlerde kullanıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu seçeneğin daha dengeli olabileceğini fark etti. İşletme ekibi bekleme verilerini yeniden hesapladı. Yolculara da yeni düzenleme hakkında bilgi verildi. Yeni levhaların denenmesi için kıyıda küçük bir uygulama yapıldı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Tuna"
        },
        {
          "t": "metin",
          "v": " yolcu gibi yürüyerek her işareti takip etti. İki yön oku birbirine çok yakın duruyordu ve karışıklık yaratıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu yanlışlığın deneme başlamadan fark edilmesine sevindi. Levhaların biri kaydırıldı, duyuru metni de kısaltıldı. Kıyıda çalışan görevliler, durakların açıkça işaretlenmesi gerektiğini söyledi. Aksi hâlde insanlar yanlış sırada bekleyebilirdi. Yeni levhalar ve duyurular hazırlandı. Eski iskele uzman onayı almadan kullanılmadı. Böylece kolay görünen bir değişiklik, gerekli kontrollerle gerçek bir ulaşım planına dönüştü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Deneme günü "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yeni iskeleye güvenli hızla yaklaştı. İskele görevlileri hazırdı ve yolcular önceden belirtilmiş alanda bekliyordu. İlk yolculukta kapılar düzenli biçimde açıldı. Yaşlı bir ziyaretçi, yeni durak sayesinde uzun bir yürüyüş yapmadan sahile ulaştı. Deneme boyunca kıyının doğal alanlarına yaklaşılmadı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " iskeleye ayrılan güvenli koridorun dışına çıkmadı. Yolcuların inişinden sonra kapılar kapanmadan hareket edilmedi. Ekibin çizelgesinde bu güvenlik adımları da yer alıyordu. Zaman kazanmak uğruna düzenli kontrol basamakları atlanmadı. Rota ancak bu koşullarla sürdürülebilirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " enerji göstergesine baktı; beklenen değerlerin dışına çıkılmamıştı. Yolculuk sonunda personel zaman çizelgesini kontrol etti. Bazı seferlerde yine gecikme görülüyordu, fakat kalabalığın en yoğun olduğu saatlerde belirgin rahatlama yaşandı. Ekip yalnızca başarılı örnekleri değil, gecikmeleri de kaydetti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir ay sonra işletme yeni rotanın verilerini değerlendirdi. Yoğun saatlerdeki ek durak yararlı bulunmuş, sakin saatlerde kullanılmamasına karar verilmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " böylece boş yere uzun yol gitmeyecekti. Enerji tasarrufu yapılırken yolcuların ihtiyacı da karşılanıyordu. Aylık değerlendirme toplantısında "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Tuna"
        },
        {
          "t": "metin",
          "v": " bütün gün aynı rotayı kullanmayı önerdi. Başka bir görevli sakin saat verilerini gösterince karar yeniden ele alındı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " koşullara göre değişen planın daha uygun olduğunu gördü. Kullanılmayan enerji, ilerideki seferler için korunacaktı. Kıyı yaşamı da gereksiz hareketle meşgul edilmeyecekti. Kıyı boyunca yürüyenler artık iki farklı iskele seçeneğini görebiliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " akşam son seferinden dönerken suyun üzerindeki ışıkları izledi. Rota artık günün saatine göre değişiyordu: yoğun saatlerde iki iskeleye, sakin saatlerde yalnızca birine uğranıyordu. Eski harita tamamen atılmadı; üzerine yeni kullanım saatleri dikkatle eklendi."
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
      "metin": "Yeni rota ihtiyacı neden doğdu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Feribotun boyası döküldüğü için"
        },
        {
          "id": "B",
          "metin": "Kıyılardan biri tamamen ulaşıma kapandığı için"
        },
        {
          "id": "C",
          "metin": "Bir iskelede yolcu yoğunluğu arttığı için"
        },
        {
          "id": "D",
          "metin": "Deniz haritası kaybolduğu için"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Fakat yeni açılan bir yürüyüş alanı yüzünden bir iskelede yolcu yoğunluğu artmıştı.\" cümlesi C seçeneğini doğrular. Feribotun boyası, deniz haritası ve kıyının kapanması metinde sorun olarak geçmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Eski iskele neden hemen kullanılmadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Güvenliği henüz bilinmediği için"
        },
        {
          "id": "B",
          "metin": "Feribotun pencereleri küçük olduğu için"
        },
        {
          "id": "C",
          "metin": "Yeni tabela renkli olmadığı için"
        },
        {
          "id": "D",
          "metin": "Suyun rengi diğer iskelelerden farklı olduğu için"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Haritada yalnızca bakım alanı olarak işaretlenmişti; yolcu kullanımına uygun olup olmadığı bilinmiyordu.\" cümlesi, iskelenin yolcu için güvenli olup olmadığının belli olmadığını gösterir; bu yüzden uzman onayı beklendi. Pencerelerin boyu, tabelanın rengi ve suyun rengi metinde nedenler arasında yoktur."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "“Menzil” bu hikâyede ne demektir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bir iskelede aynı anda bekleyen kişi sayısı"
        },
        {
          "id": "B",
          "metin": "Enerjiyle gidilebilecek güvenli uzaklık"
        },
        {
          "id": "C",
          "metin": "Denizdeki dalgaların yüksekliği"
        },
        {
          "id": "D",
          "metin": "Feribotun içindeki koltuk sayısı"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Menzil, bir aracın mevcut enerjiyle güvenle gidebileceği uzaklıktı.\" cümlesi, menzilin tanımını verir. Bekleyen kişi sayısı yoğunluğu, dalga yüksekliği ve koltuk sayısı menzille ilgili değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Ekip neden gecikmeleri de kaydetti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sadece yeni levha hazırlamak için"
        },
        {
          "id": "B",
          "metin": "Yolculuğu zorlaştırmak için"
        },
        {
          "id": "C",
          "metin": "Eski rotayı gizlemek için"
        },
        {
          "id": "D",
          "metin": "Kararı verilere dayandırmak için"
        }
      ],
      "dogru": "D",
      "aciklama": "Metindeki \"Ekip yalnızca başarılı örnekleri değil, gecikmeleri de kaydetti.\" cümlesi, ekibin kararını yalnızca iyi sonuçlara değil tüm verilere dayandırmak istediğini gösterir. Levha hazırlamak, yolculuğu zorlaştırmak ve eski rotayı gizlemek metinde gecikme kaydının amacı değildir."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr156_rota",
        "tur": "kelime",
        "yazim": "rota",
        "anlam": "Bir yere gidilirken izlenecek yol ve yön planı.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr156_rota_b",
        "tur": "kelime",
        "yazim": "güzergâh",
        "anlam": "Bir yolculukta izlenen yol.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr156_rota_c",
        "tur": "kelime",
        "yazim": "hat",
        "anlam": "Düzenli sefer yapılan yol ya da bağlantı.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr156_menzil",
        "tur": "kelime",
        "yazim": "menzil",
        "anlam": "Bir aracın enerjisiyle güvenle gidebileceği uzaklık.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr156_menzil_b",
        "tur": "kelime",
        "yazim": "erişim",
        "anlam": "Bir yere ulaşabilme durumu.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr156_menzil_c",
        "tur": "kelime",
        "yazim": "kapasite",
        "anlam": "Bir sistemin taşıyabileceği en yüksek miktar.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr156_iskele",
        "tur": "kelime",
        "yazim": "iskele",
        "anlam": "Yolcu indirip bindirmek için denize uzanan yapı.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr156_iskele_b",
        "tur": "kelime",
        "yazim": "rıhtım",
        "anlam": "Gemilerin yanaşıp yük ya da yolcu aldığı yapı.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr156_iskele_c",
        "tur": "kelime",
        "yazim": "yanaşma yeri",
        "anlam": "Teknenin güvenle durabileceği kıyı noktası.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr156_yogunluk",
        "tur": "kelime",
        "yazim": "yoğunluk",
        "anlam": "Bir alanda çok sayıda kişi ya da şeyin bulunması.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr156_yogunluk_b",
        "tur": "kelime",
        "yazim": "kalabalık",
        "anlam": "Bir yerde bir araya gelmiş çok sayıda insan.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr156_yogunluk_c",
        "tur": "kelime",
        "yazim": "sıklık",
        "anlam": "Bir olayın birim zamanda kaç kez olduğu.",
        "sinif_alt": 6,
        "sinif_ust": 6
      }
    ],
    "yuvalar": [
      {
        "ad": "hr156_rota",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr156_rota"
          },
          {
            "girdi": "hr156_rota_b"
          },
          {
            "girdi": "hr156_rota_c"
          }
        ]
      },
      {
        "ad": "hr156_menzil",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr156_menzil"
          },
          {
            "girdi": "hr156_menzil_b"
          },
          {
            "girdi": "hr156_menzil_c"
          }
        ]
      },
      {
        "ad": "hr156_iskele",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr156_iskele"
          },
          {
            "girdi": "hr156_iskele_b"
          },
          {
            "girdi": "hr156_iskele_c"
          }
        ]
      },
      {
        "ad": "hr156_yogunluk",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr156_yogunluk"
          },
          {
            "girdi": "hr156_yogunluk_b"
          },
          {
            "girdi": "hr156_yogunluk_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr157-arac-bulutlarin-altindaki-sessiz-ucus",
    "baslik": "Bulutların Altındaki Uçuş",
    "tur": "bilim",
    "konu": "hava_olcum_ucusu",
    "sinif_alt": 7,
    "sinif_ust": 7,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "arac"
    ],
    "deger_anahtarlari": [
      "D3",
      "D16"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 7,
      "okuma_zorlugu": 4,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "bilim_teknoloji"
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
          "id": "sozcuk1_hr157",
          "tur": "lexeme",
          "etiket": "irtifa",
          "yuva": "hr157_irtifa",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr157",
          "tur": "lexeme",
          "etiket": "türbülans",
          "yuva": "hr157_turbulans",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr157",
          "tur": "lexeme",
          "etiket": "ölçüm",
          "yuva": "hr157_olcum",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr157",
          "tur": "lexeme",
          "etiket": "güvenlik",
          "yuva": "hr157_guvenlik",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (7. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 667,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Orman kıyısında rüzgâr beklenmedik biçimde değişiyor. {kahraman} güvenli uçuşla verileri toplamayı ve canlıların alanına saygı göstermeyi öğreniyor.",
    "durum": "taslak",
    "fis_kodu": "HR-157"
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
          "v": " bir araştırma ekibinin kullandığı küçük insansız hava aracıydı. Orman sınırındaki açık arazide rüzgâr ve sıcaklık ölçümleri yapmak için hazırlanmıştı. Bir gün ekip, ağaçlık bölgenin üstünde beklenmedik hava hareketleri gözledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " görev planını incelerken "
        },
        {
          "t": "kelime",
          "yuva": "hr157_irtifa"
        },
        {
          "t": "metin",
          "v": " sınırlarının neden belirlendiğini düşündü. Kalkış alanı seçilirken ağaçların tepesindeki rüzgârla zemindeki rüzgârın farklı olabileceği hesaba katıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " uçuş planındaki sınırları, daha uzağa gitmenin verdiği meraktan üstün tuttu. Ekip batarya durumunu kontrol edip acil dönüş için güvenli bir alan belirledi. Araştırmanın başlaması için bütün bu hazırlıkların tamamlanması gerekiyordu. Kuşların bulunduğu bölgenin haritada ayrı gösterilmesi, canlıların korunmasını kolaylaştırdı. İrtifa, aracın yerden ne kadar yüksekte bulunduğunu gösteren ölçüydü. Uçuşun amacı yüksekte görünmek değil, güvenli bölgede doğru veri toplamaktı. Ekip hava koşullarını kontrol edip gerekli izinleri doğruladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yalnızca önceden tanımlanan rota içinde hareket edecekti; çevredeki kuşların dinlendiği alanlar uçuşa kapalı bırakıldı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kalkıştan önce rüzgâr yönü tekrar ölçüldü. İlk plan, ormanın kenarını dümdüz geçiyordu. Ancak yere yakın hava akışı ağaçların oluşturduğu küçük boşluklarda değişiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kontrol sisteminden gelen uyarıyı dikkate aldı. Bazı noktalarda "
        },
        {
          "t": "kelime",
          "yuva": "hr157_turbulans"
        },
        {
          "t": "metin",
          "v": " adı verilen düzensiz hava hareketleri vardı. Uçuş öncesi toplantıda bir görevli yüksekten daha geniş görüntü alınacağını düşündü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " daha geniş görüntünün her zaman daha doğru "
        },
        {
          "t": "kelime",
          "yuva": "hr157_olcum"
        },
        {
          "t": "metin",
          "v": " anlamına gelmediğini biliyordu. İrtifa değiştiğinde sensörün örneklediği hava koşulları da değişebilirdi. Ekip hangi soruyu cevaplamak istediğini yeniden yazdı. Böylece rota yalnızca görüntü elde etmek için değil, ölçümleri karşılaştırılabilir kılmak için düzenlendi. Güvenli sınırların dışına çıkma önerisi kabul edilmedi. Yüksekte ve ağaçlara yakın uçmak aracın dengesini bozabilirdi. Ekip uçuş yüksekliğini ve rotayı "
        },
        {
          "t": "kelime",
          "yuva": "hr157_guvenlik"
        },
        {
          "t": "metin",
          "v": " sınırları içinde yeniden düzenledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ozan"
        },
        {
          "t": "metin",
          "v": ", en kısa çizgiyi izlememenin zaman kaybettirdiğini söyledi. Diğer görevli, kaliteli verinin güvenli toplanmadığında pek işe yaramayacağını hatırlattı. Uçuş, hazırlıklar tamamlanmadan başlamadı."
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
          "v": " kalktığında yerdeki ekip ekrandan ölçümleri izliyordu. Bir bölgede sıcaklık kısa sürede değişti. Aynı noktadaki rüzgâr ölçümü de beklenenden yüksekti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " iki farklı sensörün aynı koşullarda nasıl davrandığını kayıt altına aldı. İlk uçuş sırasında beklenmedik değer kaydedilen nokta haritada küçük bir daireyle işaretlendi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " o anda ölçümün neden farklı çıktığını bilemezdi. Ekip verileri bilgisayarda açınca bazı sayıların birbirine yakın, bazılarının uzak olduğu görüldü. Kayıtların saatleri, hava koşulları ve cihaz bilgileri yan yana getirildi. Ölçümün tekrarlanması kararı bu karşılaştırmaya dayandı. Acele bir sonuç yazmak yerine belirsizliklerin açıklanması tercih edildi. Ardından güvenli şekilde dönüş noktasına geldi. Ekip, ilk sonuca dayanarak arazide büyük bir değişiklik olduğunu ileri sürmedi. Cihazların ölçüm sınırlarını, günün saatini ve uçuş sırasında bulutların konumunu karşılaştırdı. Bazen beklenmedik bir sayı, gerçek bir doğa olayına; bazen de ölçüm koşuluna işaret edebilirdi. Bu ayrım yapılmadan sonuç paylaşılmadı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkinci uçuş için plan değiştirildi. Kuşların toplandığı açıklığa yaklaşmayan yeni bir hat çizildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " batarya durumunu ve dönüş için gereken enerjiyi sürekli kontrol etti. Ölçümler yeniden alındığında ilk uçuşun bazı bulguları doğrulandı. İkinci uçuşta aynı noktaya yaklaşılırken bataryada yeterli pay bırakıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir ölçüm daha alabilmek uğruna dönüş güvenliğini tehlikeye atmadı. Kuşların bulunduğu açıklık haritada sessiz bölge olarak kalıyordu. Ekip, doğa çalışmasının çevreye gereksiz rahatsızlık vermeden yapılabileceğini göstermek istiyordu. İnişten sonra cihazların yüzeyi kontrol edildi; farklı iki uçuşun kayıtları ayrı dosyalara kaydedildi. Fakat rüzgârın en yüksek olduğu nokta, haritadaki en yüksek tepe değildi. Ağaçların ve arazi biçiminin hava akışını etkilediği düşünülüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " görev bitince iniş alanına döndü. Ekip, arazide yaşayan canlıların rahatsız edilmediğini de gözlem notlarına ekledi. Doğru bir araştırmanın yalnızca rakamlara değil, çalışma ortamına da saygı göstermesi gerekiyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Son raporda ölçümlerin yapıldığı saatler, güzergâhlar ve koşullar açıkça belirtildi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bakım masasında sessizce dururken ekip uçuş kayıtlarını arşivledi. Çalışma, orman kenarındaki yerel hava hareketlerini anlamaya yardımcı olmuştu. Ne tek bir uçuş her soruyu çözmüştü ne de bütün veriler aynı açıklamaya uyuyordu. Raporun son bölümünde hangi sonuçların tekrar ölçümle desteklendiği açıkça işaretlendi. Sorumlu araştırmacı farklı renklerle çizilmiş güzergâhlara baktı. İlk planın değişmiş olması bir eksiklik olarak görülmedi. Koşullara göre güvenli karar verebilmek araştırmanın parçasıydı. Ekip ileride başka mevsimde ölçüm yapmanın yararlı olabileceğini not etti. Böylece çalışma bittiğinde yeni sorular da görünür hâle geldi. Raporda belirsizlikler de yer aldı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ozan"
        },
        {
          "t": "metin",
          "v": ", “En iyi buluşu hangi uçuşta yaptık?” diye sordu. Ekip sorumlusu, “Uçuşu gerektiğinde değiştirebildiğimizde,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu cevabı uçuş kayıtlarının arasına not etti. Ekibin bir sonraki gözlem için planı vardı ve veriler güvenle saklandı."
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
      "metin": "Uçuşun temel amacı neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kuşları kıyıdan başka bir bölgeye götürmek"
        },
        {
          "id": "B",
          "metin": "Rüzgâr ve sıcaklık verisi toplamak"
        },
        {
          "id": "C",
          "metin": "Ormana yol açmak"
        },
        {
          "id": "D",
          "metin": "Bulutları dağıtmak"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Orman sınırındaki açık arazide rüzgâr ve sıcaklık ölçümleri yapmak için hazırlanmıştı.\" cümlesi B seçeneğini doğrular. Kuşları götürmek, ormana yol açmak ve bulutları dağıtmak metinde uçuşun amacı değildir; kuşların alanı tersine uçuşa kapalı bırakılır."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Rota neden uçuş öncesi değiştirildi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Aracın boyasını korumak için"
        },
        {
          "id": "B",
          "metin": "Ekip yolu uzatmayı sevdiği için"
        },
        {
          "id": "C",
          "metin": "Hava hareketlerini hesaba katmak için"
        },
        {
          "id": "D",
          "metin": "Haritadaki yer adlarını yenilemek için"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Bazı noktalarda türbülans adı verilen düzensiz hava hareketleri vardı.\" cümlesi, rotanın bu hareketler hesaba katılarak değiştirildiğini gösterir. Boyayı korumak, yolu uzatmak ya da harita adlarını yenilemek metinde rota değişikliğinin nedeni değildir."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Ölçüm” sözcüğü burada neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Cihazla belirlenen sayısal bilgiyi"
        },
        {
          "id": "B",
          "metin": "Aracın dış görünüşünü ve boyasını"
        },
        {
          "id": "C",
          "metin": "Ormandaki yürüyüş yolunun uzunluğunu"
        },
        {
          "id": "D",
          "metin": "Görevlinin kişisel beğenisini"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Aynı noktadaki rüzgâr ölçümü de beklenenden yüksekti.\" cümlesinde ölçüm, cihazın verdiği sayısal değerdir; yüksek ya da düşük olabilmesi de bunu gösterir. Aracın görünüşü, yürüyüş yolu ve kişisel beğeni yüksek ya da düşük çıkan bir değer değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 5,
      "metin": "Ekip neden belirsizlikleri rapordan çıkarmadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Raporun sayfası artsın diye"
        },
        {
          "id": "B",
          "metin": "Uçuşu saklamak için"
        },
        {
          "id": "C",
          "metin": "Ağaçların yerini değiştirmek için"
        },
        {
          "id": "D",
          "metin": "Sınırları açıkça göstermek için"
        }
      ],
      "dogru": "D",
      "aciklama": "Metindeki \"Raporda belirsizlikler de yer aldı.\" cümlesi, ekibin bulguların sınırlarını açıkça göstermek istediğini yansıtır; hangi sonuçların tekrar ölçümle desteklendiği de işaretlenmişti. Sayfa sayısını artırmak, uçuşu saklamak ve ağaçları taşımak metinde amaç değildir."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr157_irtifa",
        "tur": "kelime",
        "yazim": "irtifa",
        "anlam": "Bir aracın yerden ya da deniz seviyesinden yüksekliği.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr157_irtifa_b",
        "tur": "kelime",
        "yazim": "yükseklik",
        "anlam": "Bir nesnenin tabandan tepeye kadar olan uzaklığı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr157_irtifa_c",
        "tur": "kelime",
        "yazim": "derinlik",
        "anlam": "Bir şeyin yüzeyden aşağı doğru uzaklığı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr157_turbulans",
        "tur": "kelime",
        "yazim": "türbülans",
        "anlam": "Hava ya da suyun düzensiz, çalkantılı hareketi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr157_turbulans_b",
        "tur": "kelime",
        "yazim": "çalkantı",
        "anlam": "Düzensiz ve sert hareket hâli.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr157_turbulans_c",
        "tur": "kelime",
        "yazim": "akım",
        "anlam": "Hava ya da suyun belirli yönde hareketi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr157_olcum",
        "tur": "kelime",
        "yazim": "ölçüm",
        "anlam": "Bir büyüklüğü cihazla ya da birimle belirleme işlemi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr157_olcum_b",
        "tur": "kelime",
        "yazim": "tartım",
        "anlam": "Bir şeyin ağırlığını belirleme işi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr157_olcum_c",
        "tur": "kelime",
        "yazim": "gözlem",
        "anlam": "Bir olguyu dikkatle izleyerek kaydetme.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr157_guvenlik",
        "tur": "kelime",
        "yazim": "güvenlik",
        "anlam": "Zarar görmekten korunmuş olma durumu.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr157_guvenlik_b",
        "tur": "kelime",
        "yazim": "emniyet",
        "anlam": "Tehlike olmadığı güvenilir hâl.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr157_guvenlik_c",
        "tur": "kelime",
        "yazim": "koruma",
        "anlam": "Bir şeyi zarar görmeden tutma işlemi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      }
    ],
    "yuvalar": [
      {
        "ad": "hr157_irtifa",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr157_irtifa"
          },
          {
            "girdi": "hr157_irtifa_b"
          },
          {
            "girdi": "hr157_irtifa_c"
          }
        ]
      },
      {
        "ad": "hr157_turbulans",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr157_turbulans"
          },
          {
            "girdi": "hr157_turbulans_b"
          },
          {
            "girdi": "hr157_turbulans_c"
          }
        ]
      },
      {
        "ad": "hr157_olcum",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr157_olcum"
          },
          {
            "girdi": "hr157_olcum_b"
          },
          {
            "girdi": "hr157_olcum_c"
          }
        ]
      },
      {
        "ad": "hr157_guvenlik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr157_guvenlik"
          },
          {
            "girdi": "hr157_guvenlik_b"
          },
          {
            "girdi": "hr157_guvenlik_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr158-arac-kitap-tasiyan-kargo-bisikleti",
    "baslik": "Kitap Taşıyan Kargo Bisikleti",
    "tur": "gezi_kultur",
    "konu": "kent_ici_teslimat",
    "sinif_alt": 7,
    "sinif_ust": 7,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "arac"
    ],
    "deger_anahtarlari": [
      "D17",
      "D20"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 7,
      "okuma_zorlugu": 4,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "kesif"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D17",
        "yardimci_deger": "D20"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr158",
          "tur": "lexeme",
          "etiket": "rota",
          "yuva": "hr158_rota",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr158",
          "tur": "lexeme",
          "etiket": "öncelik",
          "yuva": "hr158_oncelik",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr158",
          "tur": "lexeme",
          "etiket": "dağıtım",
          "yuva": "hr158_dagitim",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr158",
          "tur": "lexeme",
          "etiket": "verimlilik",
          "yuva": "hr158_verimlilik",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (7. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 646,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Festival hazırlıkları yüzünden kitapların ulaştırılacağı sokaklar kapanıyor. {kahraman} dengeli yük ve doğru rotayla okuma duraklarını buluşturuyor.",
    "durum": "taslak",
    "fis_kodu": "HR-158"
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
          "v": " kentin dar sokaklarında kitap taşıyan elektrik destekli bir kargo bisikletiydi. Gezici okuma noktasına her hafta farklı kitap kutuları götürüyordu. Bu hafta sokak festivalinin hazırlıkları nedeniyle bazı yollar kapatılacaktı. Teslimat saatleri değişmeden önce yeni bir "
        },
        {
          "t": "kelime",
          "yuva": "hr158_rota"
        },
        {
          "t": "metin",
          "v": " planlanması gerekiyordu. Kutuların üzerine yalnızca varış yerleri değil, teslim alınacak saat aralıkları da yazıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " böylece aynı sokaktan iki kez geçmek gerekip gerekmediğini görebiliyordu. Plan hazırlanırken kitapların zarar görmemesi için taşıma düzeni de incelendi. Çok ağır bir kutuyu en üste koymak uygun değildi. Görevliler yükü dengeli biçimde yerleştirdi. Bu küçük hazırlık, günün sonraki bölümünde yaşanabilecek karışıklıkları azaltacaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " taşıdığı kutuların yalnızca eşya olmadığını düşünüyordu; her kutu, yeni bir okuma durağında bekleyen okurlara ulaşacaktı. Lojistik ekibi tüm adresleri ve yol kapanışlarını haritaya işledi. Lojistik, bir eşyanın doğru zamanda doğru yere ulaştırılmasının düzenlenmesiydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yokuşları, yük ağırlığını ve güvenli bisiklet yollarını birlikte dikkate alan planı incelemeye başladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk rota, kısa görünmesine rağmen iki kez dik bir yokuştan geçiyordu. Bu güzergâh, bataryadan fazla enerji kullanacak ve dönüşte zorluk çıkarabilecekti. İkinci rota biraz daha uzundu ama bisiklet yolunun büyük bölümünü kullanıyordu. "
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
          "yuva": "hr158_oncelik"
        },
        {
          "t": "metin",
          "v": " sırasını yalnızca mesafeye göre belirlemedi. Önce erken açılan okuma noktalarının teslimatlarını, sonra öğleden sonraki noktaların kutularını ayırdı. Alternatif güzergâhın kaldırım kenarlarında dar bölümler vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu noktaları sadece haritadaki çizgiye bakarak değerlendirmedi. Görevliler yolu önceden yürüyerek kontrol etti. Yük taşıyan bir aracın nerede durabileceği, diğer yol kullanıcılarının geçişini engellemeden nasıl teslimat yapabileceği belirlendi. Dar sokakların tarihi dokusu da korunacaktı. Böylece plan, hızlı gitmekle birlikte çevreye özen göstermeyi de içerdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Veli"
        },
        {
          "t": "metin",
          "v": " tüm paketleri aynı anda taşımayı önerdi. Oysa yük sınırını aşmak güvenli değildi. Ekip kutuları iki sefere böldü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " böylece daha dengeli hareket edebilecekti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sabah ilk seferde "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " taş döşeli meydana ulaştı. Festival hazırlıkları başlamıştı; görevli alanı kapatan geçici işaretleri gösterdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " daha önce belirlenen alternatif sokaktan ilerledi. Okuma durağında "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Veli"
        },
        {
          "t": "metin",
          "v": " kutuları teslim aldı. Kitapları hemen rafa koymadı. Önce kutulardaki sayıyla listedeki sayıyı karşılaştırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu adımın önemli olduğunu düşünüyordu; yanlış kitap farklı bir noktaya giderse başka bir okur bekleyebilirdi. Bir kutunun etiketi yıpranmıştı; geçici bir işaretle yenilendi. Sonra kayıt güncellendi ve kutular güvenli biçimde taşındı. Teslimatın bitmesi yalnızca kapıya ulaşmak değil, doğru içeriğin teslim edildiğinin doğrulanmasıydı. Etiket yıpranmış olsa da içindeki kitaplar doğru yere gelmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu teslimat kaydına not etti. Dönüş yolunda bisiklet yoluna park edilmiş bir araç görüldü. Güvensiz biçimde aradan geçmek yerine izin verilen başka sokak seçildi. Birkaç dakika kaybedildi ama teslimat güvenle tamamlandı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İkinci seferde rüzgâr arttı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kutuları sabitleyen bağların gevşemediğini kontrol ettirdi. Son durak, dar bir park girişinin yanındaydı. Parkta küçük bir okuma köşesi hazırlanıyordu. Görevli, kitapların yere konulmaması için yükseltilmiş bir masa getirdi. Parkın girişinde küçük bir çukur bulunuyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " görevlilerin belirlediği güvenli yanaşma noktasında durdu. Kitaplar dışarı alınırken çevrede yürüyenlere yol verildi. Etkinlik alanında kitapların yağmurdan korunabileceği kapalı bir köşe de hazırlanmıştı. Akşam saatlerinde hava değişirse bütün kutular yeniden taşınmak zorunda kalmayacaktı. Ekip bir sonraki haftanın teslimatını planlarken bu ayrıntıyı da not etti. Böylece kâğıtlar nemden korunacaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " iki seferin enerji kullanımını karşılaştırdı. Beklenenden az enerji harcanmış, teslimatların tamamı planlanan zaman aralığında bitmişti. Ancak ekip kayıtları yalnızca başarı olarak görmedi; kapanan sokakların oluşturduğu gecikmeler de sonraki haftanın planına eklendi. Bu kayıtlar rotanın "
        },
        {
          "t": "kelime",
          "yuva": "hr158_verimlilik"
        },
        {
          "t": "metin",
          "v": " değerlendirmesinde kullanılacaktı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Akşam festivalin ışıkları yanarken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " deposuna döndü. Yollar çok kalabalıktı ama okuma noktalarında kitap bekleyen kimse kalmamıştı. Ertesi gün güzergâh yeniden değişecekti; kent yaşayan bir yerdi ve her plan aynı kalamazdı. Deponun kapısında günü değerlendiren çizelge asıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bazı yolların iyi işlemiş, bazılarının ise yalnızca o gün uygun olmuş olabileceğini biliyordu. Festival bittikten sonra kapanan sokakların çoğu açılacaktı. Bu nedenle bugünkü rota sonsuza kadar kullanılacak kesin bir çözüm değildi. Ekip farklı koşullar için iki alternatif hazırladı. Kitapların ulaşması kadar sürdürülebilir bir "
        },
        {
          "t": "kelime",
          "yuva": "hr158_dagitim"
        },
        {
          "t": "metin",
          "v": " düzeni kurmak da önem kazanmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güvenli ulaşımı, zamanında teslimatı ve enerji tasarrufunu aynı çizelgede birlikte tutmuştu. Bir görevli son kutuyu rafa kaldırıp kapıyı kapattı. Bisikletin önündeki küçük teslimat çizelgesinde bütün adreslerin yanında işaret vardı. O işaretler, dar sokakların arasında sessizce kurulan bir kitap yolunu anlatıyordu."
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
      "metin": "Yeni rota neden gerekti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bisikletin rengi değiştiği için"
        },
        {
          "id": "B",
          "metin": "Tüm kitaplar satıldığı için"
        },
        {
          "id": "C",
          "metin": "Festival yolları kapatacağı için"
        },
        {
          "id": "D",
          "metin": "Okuma noktaları başka mahalleye taşındığı için"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Bu hafta sokak festivalinin hazırlıkları nedeniyle bazı yollar kapatılacaktı.\" cümlesi C seçeneğini doğrular. Bisikletin rengi değişmemiş, kitaplar satılmamış ve okuma noktaları taşınmamıştı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Kutular neden iki seferde taşındı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yükü güvenli sınırda tutmak için"
        },
        {
          "id": "B",
          "metin": "İlk sefer çok sessiz geçtiği için"
        },
        {
          "id": "C",
          "metin": "Paketlerin rengi aynı olduğu için"
        },
        {
          "id": "D",
          "metin": "Bütün sokaklar aynı uzunlukta olduğu için"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Oysa yük sınırını aşmak güvenli değildi.\" cümlesi, kutuların tek seferde taşınmamasının nedenini verir. İlk seferin sessizliği, paketlerin rengi ve sokak uzunlukları bölme kararıyla ilişkilendirilmez."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Teslimat” sözcüğünün bağlamdaki anlamı nedir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kent haritasını baştan çizip yayımlamak"
        },
        {
          "id": "B",
          "metin": "Paketleri doğru yere ulaştırmak"
        },
        {
          "id": "C",
          "metin": "Bataryayı boyamak"
        },
        {
          "id": "D",
          "metin": "Festival için sokakları kapatmak"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Teslimatın bitmesi yalnızca kapıya ulaşmak değil, doğru içeriğin teslim edildiğinin doğrulanmasıydı.\" cümlesinde teslimat, paketlerin doğru yere ve doğru içerikle ulaştırılmasıdır. Harita çizmek, bataryayı boyamak ve sokakları kapatmak teslimat değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Ekip gecikmeleri neden sonraki plana ekledi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Festivalden kaçınmak için"
        },
        {
          "id": "B",
          "metin": "Kitapları geri toplamak için"
        },
        {
          "id": "C",
          "metin": "Bisikletin adını değiştirmek için"
        },
        {
          "id": "D",
          "metin": "Sonraki planı iyileştirmek için"
        }
      ],
      "dogru": "D",
      "aciklama": "Metindeki \"Ancak ekip kayıtları yalnızca başarı olarak görmedi; kapanan sokakların oluşturduğu gecikmeler de sonraki haftanın planına eklendi.\" cümlesi, gecikmelerin sonraki haftanın planını iyileştirmek için kaydedildiğini gösterir. Festivalden kaçınmak, kitapları geri toplamak ve bisikletin adını değiştirmek metinde yoktur."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr158_rota",
        "tur": "kelime",
        "yazim": "rota",
        "anlam": "Bir yere gidilirken izlenen yol ve yön planı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr158_rota_b",
        "tur": "kelime",
        "yazim": "güzergâh",
        "anlam": "Bir yolculukta izlenen yol.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr158_rota_c",
        "tur": "kelime",
        "yazim": "hat",
        "anlam": "Düzenli sefer yapılan yol ya da bağlantı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr158_oncelik",
        "tur": "kelime",
        "yazim": "öncelik",
        "anlam": "Önce yapılması gereken durum ya da iş.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr158_oncelik_b",
        "tur": "kelime",
        "yazim": "sıra",
        "anlam": "Bir işin yapılacağı zaman dizisi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr158_oncelik_c",
        "tur": "kelime",
        "yazim": "ivedilik",
        "anlam": "Bir işin acil olarak yapılması gereği.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr158_dagitim",
        "tur": "kelime",
        "yazim": "dağıtım",
        "anlam": "Bir şeyi çeşitli yerlere ulaştırma işi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr158_dagitim_b",
        "tur": "kelime",
        "yazim": "teslimat",
        "anlam": "Bir eşyanın alıcıya ulaştırılması.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr158_dagitim_c",
        "tur": "kelime",
        "yazim": "sevkiyat",
        "anlam": "Malların bir yerden başka yere gönderilmesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr158_verimlilik",
        "tur": "kelime",
        "yazim": "verimlilik",
        "anlam": "Kullanılan emeğe göre elde edilen sonucun iyiliği.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr158_verimlilik_b",
        "tur": "kelime",
        "yazim": "etkinlik",
        "anlam": "Bir işi amacına uygun ve başarılı yürütme durumu.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr158_verimlilik_c",
        "tur": "kelime",
        "yazim": "tasarruf",
        "anlam": "Kaynakları gereksiz harcamadan kullanma.",
        "sinif_alt": 7,
        "sinif_ust": 7
      }
    ],
    "yuvalar": [
      {
        "ad": "hr158_rota",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr158_rota"
          },
          {
            "girdi": "hr158_rota_b"
          },
          {
            "girdi": "hr158_rota_c"
          }
        ]
      },
      {
        "ad": "hr158_oncelik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr158_oncelik"
          },
          {
            "girdi": "hr158_oncelik_b"
          },
          {
            "girdi": "hr158_oncelik_c"
          }
        ]
      },
      {
        "ad": "hr158_dagitim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr158_dagitim"
          },
          {
            "girdi": "hr158_dagitim_b"
          },
          {
            "girdi": "hr158_dagitim_c"
          }
        ]
      },
      {
        "ad": "hr158_verimlilik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr158_verimlilik"
          },
          {
            "girdi": "hr158_verimlilik_b"
          },
          {
            "girdi": "hr158_verimlilik_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr159-hayvan-kaplumbaganin-yaprak-semsiyesi",
    "baslik": "Kaplumbağanın Yaprak Şemsiyesi",
    "tur": "hayvanlar",
    "konu": "yagmurlu_bahce",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "hayvan"
    ],
    "deger_anahtarlari": [
      "D4",
      "D9"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 3,
      "okuma_zorlugu": 2,
      "kavram_zorlugu": 2,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "hayvanlar"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D4",
        "yardimci_deger": "D9"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr159",
          "tur": "lexeme",
          "etiket": "sığınak",
          "yuva": "hr159_siginak",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr159",
          "tur": "lexeme",
          "etiket": "pırıltı",
          "yuva": "hr159_pirilti",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr159",
          "tur": "lexeme",
          "etiket": "patika",
          "yuva": "hr159_patika",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr159",
          "tur": "lexeme",
          "etiket": "paylaşmak",
          "yuva": "hr159_paylasmak",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 261,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Yağmur altında bir yaprak iki küçük canlıya sığınak oluyor. {kahraman} yavaş ama dikkatli adımlarla dostuna yardım ediyor.",
    "durum": "taslak",
    "fis_kodu": "HR-159"
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
          "v": " bahçede yaşayan küçük bir kaplumbağaydı. Bir gün yağmur ince ince yağmaya başladı. Bahçedeki "
        },
        {
          "t": "kelime",
          "yuva": "hr159_patika"
        },
        {
          "t": "metin",
          "v": " kısa sürede ıslandı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kocaman bir yaprağın altına girdi. Yaprak ona "
        },
        {
          "t": "kelime",
          "yuva": "hr159_siginak"
        },
        {
          "t": "metin",
          "v": " olmuştu. Tam o sırada küçük bir salyangoz, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Pamuk"
        },
        {
          "t": "metin",
          "v": ", yaklaştı. Salyangozun üzerinde yağmur damlaları "
        },
        {
          "t": "kelime",
          "yuva": "hr159_pirilti"
        },
        {
          "t": "metin",
          "v": " gibi görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " biraz kenara çekildi. Yaprağı "
        },
        {
          "t": "kelime",
          "yuva": "hr159_paylasmak"
        },
        {
          "t": "metin",
          "v": " zor olmadı, altında iki canlıya da yer vardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yağmur hızlanınca yolun ortasında minik bir su birikintisi oluştu. Salyangoz öteki tarafa geçmek istiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " acele etmeyi sevmezdi ama yardım etmek istiyordu. Önce zemine baktı. Islak taşların üzerinden gitmek kaygan olabilirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çimenlerin arasından geçen daha kuru bir yol buldu. Salyangoz da peşinden yavaşça ilerledi. Yaprak şemsiyesi hâlâ ikisinin üstündeydi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yolun sonunda küçük bir taş vardı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Pamuk"
        },
        {
          "t": "metin",
          "v": " taşı aşmakta zorlandı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " geniş yaprağı taşın kenarına bıraktı. Yaprak hafifçe eğilince geçiş kolaylaştı. Sonra yaprağı yeniden kaldırdı. Bahçenin ortasındaki çiçekler yağmurla yıkanmıştı. İki yolcu çiçeklerin yanından geçti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " acele edilmeyen yolun daha az yorduğunu fark etti. Salyangoz yorulduğunda durup bekledi. Patika çiçekler arasından kıvrılıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Büyük ağacın dibine vardıklarında yağmur hafifledi. Salyangoz kendi yuvasını gördü. Yaprağa artık ihtiyaç kalmamıştı ama "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onu aceleyle atmadı. Yaprağı çalıların üzerine dikkatle bıraktı. Belki başka küçük canlılar da altında dinlenebilirdi. Salyangoz başını hafifçe eğdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gülümser gibi bakarak ağacın çevresinde gezindi. Toprak mis gibi kokuyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Güneş bulutların arasından çıkınca bahçede küçük ışıklar belirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kabuğunun üzerine düşen damlaları izledi. Biraz önce uzun görünen yol şimdi çok kısaydı. Salyangoz güvenle yuvasına ulaşmıştı. Yaprak hâlâ çalıların üzerinde duruyordu. Bahçeyi dolaşan rüzgâr onu hafifçe salladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yavaş adımlarla kendi köşesine döndü. O gün küçücük bir yaprak, iki canlı için büyük bir iyilik olmuştu."
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
      "metin": "{kahraman} yağmur başlayınca nereye girdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bahçedeki taş kulübenin içine"
        },
        {
          "id": "B",
          "metin": "Çiçek saksısının arkasına"
        },
        {
          "id": "C",
          "metin": "Büyük yaprağın altına"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"{kahraman} kocaman bir yaprağın altına girdi.\" cümlesi C seçeneğini doğrular. Kulübe, saksı ve ağaç kovuğu metinde geçmez."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Neden kuru yola yöneldi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Daha güvenli ilerlemek için"
        },
        {
          "id": "B",
          "metin": "Çiçekleri tek tek saymak için"
        },
        {
          "id": "C",
          "metin": "Yaprağı saklamak için"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"{kahraman} çimenlerin arasından geçen daha kuru bir yol buldu.\" cümlesinden önce ıslak taşların kaygan olabileceği yazar; kuru yol bu yüzden güvenli ilerlemek için seçilmiştir. Çiçek saymak, yağmuru izlemek ve yaprağı saklamak metinde yoktur."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Patika” burada neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bahçedeki büyük bir su kabını"
        },
        {
          "id": "B",
          "metin": "Dar bir yürüme yolunu"
        },
        {
          "id": "C",
          "metin": "Salyangozun sırtındaki kabuğu"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Patika çiçekler arasından kıvrılıyordu.\" cümlesinde patika, çiçeklerin arasından kıvrılarak giden dar yoldur. Su kabı, meyve ve kabuk kıvrılarak giden şeyler değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} neden yaprağı çalıların üzerine bıraktı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yağmuru çağırmak için"
        },
        {
          "id": "B",
          "metin": "Kendi yolunu tamamen kapatmak için"
        },
        {
          "id": "C",
          "metin": "Başkalarına da yarasın diye"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Belki başka küçük canlılar da altında dinlenebilirdi.\" cümlesi, yaprağın başka canlılara da sığınak olabilsin diye bırakıldığını gösterir. Boyamak, yağmuru çağırmak ve kendi yolunu kapatmak metinde amaç olarak geçmez."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr159_siginak",
        "tur": "kelime",
        "yazim": "sığınak",
        "anlam": "Tehlikeden, yağmurdan ya da soğuktan korunmak için gidilen yer.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr159_siginak_b",
        "tur": "kelime",
        "yazim": "barınak",
        "anlam": "Canlıların kendini koruduğu yer.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr159_siginak_c",
        "tur": "kelime",
        "yazim": "siper",
        "anlam": "Bir tehlikeden korunmak için arkasına geçilen engel.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr159_pirilti",
        "tur": "kelime",
        "yazim": "pırıltı",
        "anlam": "Bir yüzeyde kısa kısa parlayan hafif ışık.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr159_pirilti_b",
        "tur": "kelime",
        "yazim": "parıltı",
        "anlam": "Işığın yansıyarak oluşturduğu parlaklık.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr159_pirilti_c",
        "tur": "kelime",
        "yazim": "ışıltı",
        "anlam": "Parlayan ve göz kamaştıran ışık.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr159_patika",
        "tur": "kelime",
        "yazim": "patika",
        "anlam": "Yaya geçişine açık, dar ve kıvrımlı yol.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr159_patika_b",
        "tur": "kelime",
        "yazim": "keçiyolu",
        "anlam": "Dağlık yerlerde yayaların kullandığı dar yol.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr159_patika_c",
        "tur": "kelime",
        "yazim": "yol",
        "anlam": "Bir yerden başka bir yere ulaşmayı sağlayan güzergâh.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr159_paylasmak",
        "tur": "kelime",
        "yazim": "paylaşmak",
        "anlam": "Bir şeyi başkasıyla birlikte kullanmak.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr159_paylasmak_b",
        "tur": "kelime",
        "yazim": "bölüşmek",
        "anlam": "Bir şeyi aralarında ortak olarak dağıtmak.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr159_paylasmak_c",
        "tur": "kelime",
        "yazim": "dağıtmak",
        "anlam": "Bir şeyi birkaç kişi arasında paylaştırmak.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "hr159_siginak",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr159_siginak"
          },
          {
            "girdi": "hr159_siginak_b"
          },
          {
            "girdi": "hr159_siginak_c"
          }
        ]
      },
      {
        "ad": "hr159_pirilti",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr159_pirilti"
          },
          {
            "girdi": "hr159_pirilti_b"
          },
          {
            "girdi": "hr159_pirilti_c"
          }
        ]
      },
      {
        "ad": "hr159_patika",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr159_patika"
          },
          {
            "girdi": "hr159_patika_b"
          },
          {
            "girdi": "hr159_patika_c"
          }
        ]
      },
      {
        "ad": "hr159_paylasmak",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr159_paylasmak"
          },
          {
            "girdi": "hr159_paylasmak_b"
          },
          {
            "girdi": "hr159_paylasmak_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr160-hayvan-sercenin-sessiz-konseri",
    "baslik": "Serçenin Ortak Şarkısı",
    "tur": "mizah",
    "konu": "kus_sesleri",
    "sinif_alt": 3,
    "sinif_ust": 3,
    "okuma_bandi": 1,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
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
      "kavram_zorlugu": 2,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "mizah"
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
          "id": "sozcuk1_hr160",
          "tur": "lexeme",
          "etiket": "ritim",
          "yuva": "hr160_ritim",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr160",
          "tur": "lexeme",
          "etiket": "sessizlik",
          "yuva": "hr160_sessizlik",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr160",
          "tur": "lexeme",
          "etiket": "hızlı",
          "yuva": "hr160_hizli",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr160",
          "tur": "lexeme",
          "etiket": "uyum",
          "yuva": "hr160_uyum",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (3. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 277,
        "tahmini_sure_dk": 4,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Parktaki kuşlar aynı anda ötünce şarkı birbirine karışıyor. {kahraman} birlikte dinlemeyi ve uyumlu ses çıkarmayı keşfediyor.",
    "durum": "taslak",
    "fis_kodu": "HR-160"
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
          "v": " küçük bir serçeydi. Parktaki büyük ağacın dalında şarkı söylemeyi severdi. Bir gün öteki kuşlar da aynı dalda toplandı. Her biri farklı bir ses çıkarıyordu. Sesler öyle karıştı ki kimse kendi melodisini duyamadı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " biraz sustu. Sonra öteki kuşların seslerini dinledi. Bazıları "
        },
        {
          "t": "kelime",
          "yuva": "hr160_hizli"
        },
        {
          "t": "metin",
          "v": ", bazıları yavaş ötüyordu. Bir arada söylemek için önce birbirlerini duymaları gerekiyordu."
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
          "v": " gagasıyla dala hafifçe vurdu. “Tak, tak, tak!” Bu ses düzenli bir "
        },
        {
          "t": "kelime",
          "yuva": "hr160_ritim"
        },
        {
          "t": "metin",
          "v": " oluşturdu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Defne"
        },
        {
          "t": "metin",
          "v": " üç vuruş bekledi, diğeri dördüncü vuruşta öttü. Başta herkes şaşırdı. Sonra denemeyi yeniden yaptılar. "
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
          "hal": "yalin",
          "yedek": "Defne"
        },
        {
          "t": "metin",
          "v": " adlı kuşun çok yüksek sesle öttüğünü fark etti. Ona kızmak yerine biraz alçak sesle başlamasını işaret etti. Parkta yürüyenler ağacın yanında durdu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Küçük prova sürerken rüzgâr esti. Dal hafifçe sallandı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kanatlarını açarak dengesini korudu. Başka bir kuş yanlış yerde ötünce kısa bir "
        },
        {
          "t": "kelime",
          "yuva": "hr160_sessizlik"
        },
        {
          "t": "metin",
          "v": " oldu. Kimse alay etmedi. Hep birlikte baştan başladılar. Birkaç denemeden sonra sesler "
        },
        {
          "t": "kelime",
          "yuva": "hr160_uyum"
        },
        {
          "t": "metin",
          "v": " içinde yükseldi. Kimse tek başına bütün şarkıyı taşımıyordu. Her sesin küçük ama önemli bir yeri vardı. Parkın çeşmesi de uzaktan şarkıya eşlik eder gibiydi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğle vakti kuşlar kısa bir dinlenme verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yere düşen küçük bir tüyü izledi. Birlikte söylemeyi öğrenmek, kendi sesinden vazgeçmek demek değildi. Öteki kuşlar kendi farklı sesleriyle şarkıya katılmıştı. Yeniden daldaki yerlerini aldılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk vuruşu yaptı. Bu kez kuşların hiçbiri acele etmedi. Şarkı yavaşça başladı ve sonra hızlandı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Konser bittiğinde parkta kısa bir sessizlik oldu. Ardından ağaçların arasında neşeli sesler duyuldu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dalın en küçük sesine sahipti. Yine de ilk vuruşu o yapmış, herkes de ona uymuştu. Kuşlar dallarına ayrılırken ritim hâlâ hafifçe sürüyordu. Rüzgâr yaprakları salladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " son bir kez öttü ve kanatlarını açıp yakınındaki dala kondu. Parktaki o gün, çok farklı seslerin güzel bir bütün oluşturabildiği gündü."
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
      "metin": "Kuşların ilk sorunu neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Seslerin birbirine karışması"
        },
        {
          "id": "B",
          "metin": "Yaprakların tamamen dökülmesi"
        },
        {
          "id": "C",
          "metin": "Ağacın ortadan kaybolması"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Sesler öyle karıştı ki kimse kendi melodisini duyamadı.\" cümlesi A seçeneğini doğrular. Yapraklar dökülmemiş, ağaç kaybolmamış ve çeşme durmamıştı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Kuşların yeniden denemesi neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Birlikte söyleyebildiklerini"
        },
        {
          "id": "B",
          "metin": "Parktan başka yere taşınacaklarını"
        },
        {
          "id": "C",
          "metin": "Dalların yerini değiştirdiklerini"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Sonra denemeyi yeniden yaptılar.\" cümlesi, kuşların vazgeçmeyip tekrar denediğini ve sonunda birlikte söyleyebildiğini gösterir. Şarkıyı unutmak, parktan ayrılmak ya da dalları değiştirmek metinde yoktur."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Uyum” sözcüğü neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yalnızca hızlı ve yüksek sesle söylemeyi"
        },
        {
          "id": "B",
          "metin": "Seslerin birbirini tamamlamasını"
        },
        {
          "id": "C",
          "metin": "Kanatların büyümesini"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Birkaç denemeden sonra sesler uyum içinde yükseldi.\" cümlesinde uyum, seslerin birbirini bozmadan tamamlamasıdır; sonraki cümle de kimsenin şarkıyı tek başına taşımadığını söyler. Hızlı söylemek, susmak ve kanat büyümesi uyum değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "Kuşların son provada acele etmemesi hangi davranışı gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Şarkı söylemekten vazgeçtiklerini"
        },
        {
          "id": "B",
          "metin": "Yalnızca en hızlı kuşu dinlediklerini"
        },
        {
          "id": "C",
          "metin": "Birbirini beklediklerini"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Bu kez kuşların hiçbiri acele etmedi.\" cümlesi, kuşların ilk vuruşu bekleyip birbirine uyduğunu gösterir. Birbirini hiç duymamak, şarkıdan vazgeçmek ve yalnızca en hızlı kuşu dinlemek metindeki davranışa uymaz."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr160_ritim",
        "tur": "kelime",
        "yazim": "ritim",
        "anlam": "Seslerin ya da hareketlerin düzenli aralıklarla tekrarlanması.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr160_ritim_b",
        "tur": "kelime",
        "yazim": "tempo",
        "anlam": "Bir şeyin yapılış hızı ve düzeni.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr160_ritim_c",
        "tur": "kelime",
        "yazim": "vuruş",
        "anlam": "Ritmi oluşturan her bir darbe ya da ses.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr160_sessizlik",
        "tur": "kelime",
        "yazim": "sessizlik",
        "anlam": "Ses çıkmama durumu.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr160_sessizlik_b",
        "tur": "kelime",
        "yazim": "durgunluk",
        "anlam": "Hareket ya da sesin olmadığı durum.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr160_sessizlik_c",
        "tur": "kelime",
        "yazim": "dinginlik",
        "anlam": "Ortamın sakin ve sessiz olması.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr160_hizli",
        "tur": "kelime",
        "yazim": "hızlı",
        "anlam": "Çok kısa sürede olan, çabuk.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr160_hizli_b",
        "tur": "kelime",
        "yazim": "çabuk",
        "anlam": "Kısa zamanda, süratli olan.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr160_hizli_c",
        "tur": "kelime",
        "yazim": "yavaş",
        "anlam": "Hareketi ya da sesi ağır olan.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr160_uyum",
        "tur": "kelime",
        "yazim": "uyum",
        "anlam": "Parçaların birbirine uygun olması.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr160_uyum_b",
        "tur": "kelime",
        "yazim": "ahenk",
        "anlam": "Birlikte çıkan seslerin hoş bir düzeni.",
        "sinif_alt": 3,
        "sinif_ust": 3
      },
      {
        "id": "hr160_uyum_c",
        "tur": "kelime",
        "yazim": "denge",
        "anlam": "Parçaların birbirini bozmadan durması.",
        "sinif_alt": 3,
        "sinif_ust": 3
      }
    ],
    "yuvalar": [
      {
        "ad": "hr160_ritim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr160_ritim"
          },
          {
            "girdi": "hr160_ritim_b"
          },
          {
            "girdi": "hr160_ritim_c"
          }
        ]
      },
      {
        "ad": "hr160_sessizlik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr160_sessizlik"
          },
          {
            "girdi": "hr160_sessizlik_b"
          },
          {
            "girdi": "hr160_sessizlik_c"
          }
        ]
      },
      {
        "ad": "hr160_hizli",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr160_hizli"
          },
          {
            "girdi": "hr160_hizli_b"
          },
          {
            "girdi": "hr160_hizli_c"
          }
        ]
      },
      {
        "ad": "hr160_uyum",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr160_uyum"
          },
          {
            "girdi": "hr160_uyum_b"
          },
          {
            "girdi": "hr160_uyum_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr161-hayvan-su-samurunun-cakil-takvimi",
    "baslik": "Su Samurunun Çakıl Takvimi",
    "tur": "doga",
    "konu": "nehir_su_seviyesi",
    "sinif_alt": 5,
    "sinif_ust": 5,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "hayvan"
    ],
    "deger_anahtarlari": [
      "D5",
      "D12"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 5,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "doga"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D5",
        "yardimci_deger": "D12"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr161",
          "tur": "lexeme",
          "etiket": "işaret",
          "yuva": "hr161_isaret",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr161",
          "tur": "lexeme",
          "etiket": "gözlem",
          "yuva": "hr161_gozlem",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr161",
          "tur": "lexeme",
          "etiket": "kıyı",
          "yuva": "hr161_kiyi",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr161",
          "tur": "lexeme",
          "etiket": "düzenli",
          "yuva": "hr161_duzenli",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (5. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 470,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Nehir kenarındaki taşlar gün gün suyun altında kalıyor. {kahraman} küçük çakıllarla su seviyesinin değişimini izliyor.",
    "durum": "taslak",
    "fis_kodu": "HR-161"
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
          "v": " nehir kenarında yaşayan bir su samuruydu. Günlerinin çoğunu suyun sesini dinleyerek geçirirdi. Sonbaharda nehrin bazı günler yükseldiğini, bazı günler ise alçaldığını fark etti. Kıyıdaki küçük taşlar bir gün su altında kalıyor, ertesi gün yeniden görünüyordu. Sabah ışığı suyun üstüne vurduğunda taşların görünüşü değişiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yalnızca renge bakıp karar vermedi; taşın gerçekten suyun altında kalıp kalmadığına dikkat etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu değişimi anlamak için taşların yanına dikkatlice bakmaya başladı. Nehirdeki canlıları rahatsız etmeden aynı noktadan "
        },
        {
          "t": "kelime",
          "yuva": "hr161_gozlem"
        },
        {
          "t": "metin",
          "v": " yapacaktı. Yaşlı bir kaplumbağa da her gün o bölgede dinlenirdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Tarık"
        },
        {
          "t": "metin",
          "v": ", “Bu taş geçen hafta görünmüyordu,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yalnızca hatırlamaya güvenmek yerine "
        },
        {
          "t": "kelime",
          "yuva": "hr161_duzenli"
        },
        {
          "t": "metin",
          "v": " bir "
        },
        {
          "t": "kelime",
          "yuva": "hr161_isaret"
        },
        {
          "t": "metin",
          "v": " sistemi düşünmeye başladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Nehir kıyısında üç yuvarlak çakıl buldu. Taşları suya atmadı; mevcut yerlerini işaret olarak kullanmayı seçti. İlk taş suyun hemen kenarındaydı. İkincisi biraz yukarıda, üçüncüsü ise küçük bir ağaç kökünün yanındaydı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " suyun seviyesini her gün aynı saatlerde gözledi. İşaretlerin çevresindeki otlar uzamaya başladığında bazı çakıllar zor görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " otları koparmak yerine bakış noktasını değiştirdi. Böylece doğal çevre bozulmadan gözlem sürdü. Taşlar olduğu yerde kaldı. Seviye, su yüzeyinin yüksekliğini anlatıyordu. Bir gün ilk iki taş görünmez oldu. Ertesi gün yalnızca ilk taş suyun altında kaldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " taşlara bakarak büyük bir değişimin tek gecede değil, gün gün izlenebildiğini fark etti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Tarık"
        },
        {
          "t": "metin",
          "v": " da gözlemlerini paylaşmaya başladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yağmurlu bir akşamdan sonra nehir hızlandı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " suya yaklaşmadı, yüksek bir "
        },
        {
          "t": "kelime",
          "yuva": "hr161_kiyi"
        },
        {
          "t": "metin",
          "v": " noktasından izledi. Ertesi gün üç taşın hiçbiri görünmüyordu. Kıyıdaki kuşlar, yuvalarına giden dar geçidin suyla kaplandığını fark etmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " onları yüksek patikaya yönlendirdi. Kimse acele etmedi; geride kalan olup olmadığını kontrol ederek yolun kuru olduğu bölümden ilerlediler. Bu sırada kaplumbağa, yağmurdan sonra suyun birden yükseldiğini hatırlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir günlük değişimle uzun süreli düzeni karıştırmamaya çalıştı. Her yeni gözlemi önceki günlerle birlikte düşündü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir süre sonra yağışlar azaldı. Çakıllar yeniden görünmeye başladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kaplumbağayla birlikte kıyı boyunca yürüdü. Yüksek suda kullanılabilecek güvenli dinlenme noktalarını belirlediler. Kaplumbağa güvenli dinlenme noktalarının yerini hatırlamak için çevredeki büyük taşları saydı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ise kıyının biçimini gözledi. İki farklı yöntem aynı yere ulaşmayı kolaylaştırdı. Küçük gözlemler paylaşılınca çevreyi tanımak kolaylaşıyordu. Bu noktalar, nehrin taşkın dönemlerinde canlıların sakin biçimde uzaklaşabileceği yerlerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yalnızca su seviyesinin değişimini izlemiyordu; bu değişimin çevrede yaşayanları nasıl etkilediğini de öğreniyordu. Nehir bazen dingin, bazen hızlı akıyordu. Çakıllar ise aynı yerde durarak gözlem yapmayı kolaylaştırıyordu. Küçük taşlar kocaman bir takvime dönüşmüştü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Kış yaklaşırken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " üçüncü çakılın yanına oturdu. Güneş soluk bir ışık veriyor, su kıyıda hafifçe dalgalanıyordu. Kaplumbağa, “Peki artık nehrin ne yapacağını biliyor muyuz?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başını hafifçe eğdi. Kış öncesi son gözlemde çakılların yalnızca araç olduğunu düşündü. Taşlar değişimi kendiliğinden açıklamıyordu; anlamı kuran dikkatli bakıştı. Kaplumbağa ile birlikte geçen günleri hatırlayınca acele etmeden öğrenmenin sevincini duydu. Nehirse akmaya devam ediyordu. Birkaç günün gözlemi bütün mevsimleri açıklayamazdı. Ama önceye göre daha dikkatliydiler. Yağmurdan sonra hangi yola bakmaları gerektiğini biliyorlardı. Çakıl taşları orada kalacaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " nehrin sesini dinlerken yarın hangi taşın görüneceğini merak etti."
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
      "metin": "Nehirde hangi değişim fark edildi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Suyun hiç değişmeden hep aynı kaldığı"
        },
        {
          "id": "B",
          "metin": "Suyun bazı günler yükselip alçaldığı"
        },
        {
          "id": "C",
          "metin": "Taşların renksizleştiği"
        },
        {
          "id": "D",
          "metin": "Kuşların hiç uçmadığı"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Sonbaharda nehrin bazı günler yükseldiğini, bazı günler ise alçaldığını fark etti.\" cümlesi B seçeneğini doğrular. Su sürekli aynı kalmamış, taşların rengi kaybolmamış, kuşlar da uçmaya devam etmişti."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Neden her gün aynı saatte gözlem yapıldı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Günleri kıyaslayabilmek için"
        },
        {
          "id": "B",
          "metin": "Taşları daha hızlı taşımak için"
        },
        {
          "id": "C",
          "metin": "Suyu durdurmak için"
        },
        {
          "id": "D",
          "metin": "Yağmuru önlemek için"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"{kahraman} suyun seviyesini her gün aynı saatlerde gözledi.\" cümlesi, ölçümlerin aynı koşullarda yapıldığını gösterir; böylece günler birbiriyle kıyaslanabilir. Taşları taşımak, suyu durdurmak ve yağmuru önlemek metinde gözlemin amacı değildir."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "“Seviye” sözcüğü bu hikâyede neyi gösterir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kuşların uçuş hızını"
        },
        {
          "id": "B",
          "metin": "Çakıl taşlarının renk tonunu"
        },
        {
          "id": "C",
          "metin": "Su yüzeyinin yüksekliğini"
        },
        {
          "id": "D",
          "metin": "Ağacın yaşını"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Seviye, su yüzeyinin yüksekliğini anlatıyordu.\" cümlesi sözcüğün anlamını doğrudan verir. Kuşların hızı, taşların rengi ve ağacın yaşı seviye ile ilgili değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 3,
      "metin": "{kahraman} neden bir günlük değişimle kesin hüküm vermedi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Taşları kimse görmesin diye gizlemek için"
        },
        {
          "id": "B",
          "metin": "Nehirden bir an önce uzaklaşmak için"
        },
        {
          "id": "C",
          "metin": "Kaplumbağa ve kuşları sürekli bekletmek için"
        },
        {
          "id": "D",
          "metin": "Düzeni uzun süre izlemek gerektiği için"
        }
      ],
      "dogru": "D",
      "aciklama": "Metindeki \"{kahraman} bir günlük değişimle uzun süreli düzeni karıştırmamaya çalıştı.\" cümlesi, tek bir günün sonucunu kalıcı düzen sanmak istemediğini gösterir; bu yüzden gözlemi önceki günlerle birlikte değerlendirdi. Taşları gizlemek, nehirden kaçmak ve arkadaşlarını bekletmek metinde yoktur."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr161_isaret",
        "tur": "kelime",
        "yazim": "işaret",
        "anlam": "Bir şeyi gösteren ya da yön belirten simge ve belirti.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr161_isaret_b",
        "tur": "kelime",
        "yazim": "tabela",
        "anlam": "Bilgi vermek için bir yere asılan levha.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr161_isaret_c",
        "tur": "kelime",
        "yazim": "iz",
        "anlam": "Bir şeyin geçtiğini ya da var olduğunu gösteren belirti.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr161_gozlem",
        "tur": "kelime",
        "yazim": "gözlem",
        "anlam": "Bir olguyu dikkatle izleyerek kaydetme.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr161_gozlem_b",
        "tur": "kelime",
        "yazim": "inceleme",
        "anlam": "Bir konunun ayrıntılarına bakma.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr161_gozlem_c",
        "tur": "kelime",
        "yazim": "izleme",
        "anlam": "Bir durumu belli aralıklarla takip etme.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr161_kiyi",
        "tur": "kelime",
        "yazim": "kıyı",
        "anlam": "Denizin ya da nehrin karaya bitiştiği kenar.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr161_kiyi_b",
        "tur": "kelime",
        "yazim": "kenar",
        "anlam": "Bir yerin dış sınırına yakın bölüm.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr161_kiyi_c",
        "tur": "kelime",
        "yazim": "sahil",
        "anlam": "Denizin ya da gölün kıyısı boyunca uzanan alan.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr161_duzenli",
        "tur": "kelime",
        "yazim": "düzenli",
        "anlam": "Belli bir sıra ve ölçüye uygun olan.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr161_duzenli_b",
        "tur": "kelime",
        "yazim": "tertipli",
        "anlam": "Düzenli biçimde sıralanmış olan.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr161_duzenli_c",
        "tur": "kelime",
        "yazim": "ardışık",
        "anlam": "Birbirini düzenli biçimde izleyen.",
        "sinif_alt": 5,
        "sinif_ust": 5
      }
    ],
    "yuvalar": [
      {
        "ad": "hr161_isaret",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr161_isaret"
          },
          {
            "girdi": "hr161_isaret_b"
          },
          {
            "girdi": "hr161_isaret_c"
          }
        ]
      },
      {
        "ad": "hr161_gozlem",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr161_gozlem"
          },
          {
            "girdi": "hr161_gozlem_b"
          },
          {
            "girdi": "hr161_gozlem_c"
          }
        ]
      },
      {
        "ad": "hr161_kiyi",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr161_kiyi"
          },
          {
            "girdi": "hr161_kiyi_b"
          },
          {
            "girdi": "hr161_kiyi_c"
          }
        ]
      },
      {
        "ad": "hr161_duzenli",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr161_duzenli"
          },
          {
            "girdi": "hr161_duzenli_b"
          },
          {
            "girdi": "hr161_duzenli_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr162-hayvan-tavsanin-sessiz-isaretleri",
    "baslik": "Tavşanın Kozalak İzleri",
    "tur": "arkadaslik",
    "konu": "orman_yon_bulma",
    "sinif_alt": 5,
    "sinif_ust": 5,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "hayvan"
    ],
    "deger_anahtarlari": [
      "D4",
      "D5"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 5,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "dostluk"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D4",
        "yardimci_deger": "D5"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr162",
          "tur": "lexeme",
          "etiket": "işaret",
          "yuva": "hr162_isaret",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr162",
          "tur": "lexeme",
          "etiket": "yol",
          "yuva": "hr162_yol",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr162",
          "tur": "lexeme",
          "etiket": "kozalak",
          "yuva": "hr162_kozalak",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr162",
          "tur": "lexeme",
          "etiket": "anlaşma",
          "yuva": "hr162_anlasma",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (5. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 477,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Yağmur orman patikalarındaki eski işaretleri silmiş. {kahraman} arkadaşlarıyla birlikte herkesin aynı şeyi anlayacağı kozalak işaretleri kuruyor.",
    "durum": "taslak",
    "fis_kodu": "HR-162"
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
          "v": " çalılıkların kenarında yaşayan bir tavşandı. Ormanın açıklığında her sonbahar meyve paylaşım günü kurulurdu. Bu kez canlılar farklı patikalardan gelecekti. Ancak yeni yağan yağmur, eski "
        },
        {
          "t": "kelime",
          "yuva": "hr162_yol"
        },
        {
          "t": "metin",
          "v": " işaretlerinin bir kısmını silmişti. Patika başlarındaki boyalı çubuklar çamura gömülmüş, ayrım noktalarındaki izler akıp gitmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce yol boyundaki taşları "
        },
        {
          "t": "kelime",
          "yuva": "hr162_isaret"
        },
        {
          "t": "metin",
          "v": " olarak kullanmayı düşündü. Ama kimi taşlar yaşlı kaplumbağanın güneşlendiği yerlerdi, kimilerinin altında böcek yuvaları vardı. Yol, hiçbir şeyi yerinden oynatmadan gösterilmeliydi. Yerde bol bulunan kozalaklar bu iş için uygun görünüyordu. İşi bitince alınıp götürülebilirlerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " açıklığa giden rotayı zihninde yürüdü: yüksek bir taş, iki çam ağacı, küçük bir köprü. İşaretleri bu üç noktaya koyacaktı. Tek kaygısı vardı. Kendisine açık gelen bir işaret, başkası için hiçbir şey söylemeyebilirdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk durak yüksek taşın önüydü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " oraya üç "
        },
        {
          "t": "kelime",
          "yuva": "hr162_kozalak"
        },
        {
          "t": "metin",
          "v": " dizdi. Kozalaklar köprünün yönünü gösteriyordu. Fakat sincap, üç kozalağı görünce bunun bir oyun işareti olduğunu sandı. Kozalakları sayarak zıpladı, sonra yanlış patikaya daldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " peşinden seslenmedi; işaretin gerçekten anlaşılıp anlaşılmadığını görmek istiyordu. Sincap çamın dibinde yolunu kaybedip geri dönünce ikisi de güldü. Sorun sincapta değil, işaretteydi. Birlikte küçük bir "
        },
        {
          "t": "kelime",
          "yuva": "hr162_anlasma"
        },
        {
          "t": "metin",
          "v": " yaptılar: yan yana iki kozalak düz yolu, köşeye konan tek kozalak dönüşü gösterecekti. Üç kozalaklı dizilişi bir daha kullanmadılar. Ağaç gövdesine çizik atılmadı, dallar kırılmadı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sincapla birlikte ilk rotayı tekrar yürüdü. Bu kez sincap her işareti doğru okudu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Köprünün az ötesinde patika ikiye ayrılıyordu. Kısa yol çamurluydu. Uzun yol ise düz ve kuruydu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kaplumbağanın kısa yolda çamura saplanacağını düşündü. Yavaş yürüyen biri için hızlı görünen yol, aslında en uzun yol olabilirdi. Düz patikanın başına iki kozalak koydu, çamurlu yolun girişine ise hiçbir şey koymadı. Sonra kaplumbağayla birlikte yola çıkıp işaretleri denedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Mert"
        },
        {
          "t": "metin",
          "v": " kuru patikada rahatça ilerledi. Yalnız bir yerde kozalaklar uzun otların arasında kaybolmuştu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Mert"
        },
        {
          "t": "metin",
          "v": " durup başını çevirdi, çünkü dönüşü göremiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kozalakları otların üstüne, göz hizasına taşıdı. Sincap da bir şey fark etti: İşareti koymak kadar, yoldan geçenin onu nereden göreceğini düşünmek de gerekiyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Paylaşım günü ilk gelenler işaretleri sorunsuz izledi. Öğleye doğru çisenen yağmur köprünün yanındaki kozalağı yuvarlayıp çamura itti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu görünce sincapla birlikte kozalağı sağlam bir taşın dibine, eğimin yukarı tarafına yerleştirdi. Artık kaymıyordu. Açıklıkta herkesin getirdiği meyveler sergileniyordu. Kimi canlı elmayı, kimi yaban eriğini seviyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " meyveleri tek yığın yapmak yerine türlerine göre ayırdı ve herkes istediği bölümden aldı. Bazı canlılar erken geldi, bazıları geç. Geç gelenleri kimse azarlamadı; onlara da ayrı bir pay kaldı. Kaplumbağa kuru patikadan en son geldi ama meyve bölümüne hiç acele etmeden, ilk gelenlerle aynı rahatlıkla yaklaştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Akşam olunca "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yolda kalan kozalakları toplamak için patikayı baştan yürüdü. Ormanın doğal görüntüsünün korunmasını istiyordu. Sincap da yanına katıldı. “Artık bütün patikaları biliyoruz,” dedi. Bir kozalağı hatıra olarak saklamak istiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " buna karşı çıkmadı, yalnızca ormandan bir kozalağın eksileceğini söyledi. Sincap biraz düşündü, kozalağı olduğu yere bıraktı ve yerine bir çam iğnesi aldı. Köprünün başındaki son kozalağı da toplarken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yarını düşündü. Orman değişirse işaretler de değişebilirdi. Bunu yine birlikte konuşup yine birlikte deneyeceklerdi."
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
      "metin": "Meyve paylaşım günü yaklaşırken eski yol işaretlerine ne olmuştu?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Renkleri solup maviye dönmüştü"
        },
        {
          "id": "B",
          "metin": "Bütün işaretler başka yere taşınmıştı"
        },
        {
          "id": "C",
          "metin": "Yağmur bir kısmını silmişti"
        },
        {
          "id": "D",
          "metin": "Üzerleri çiçeklerle örtülmüştü"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Ancak yeni yağan yağmur, eski yol işaretlerinin bir kısmını silmişti.\" cümlesi C seçeneğini doğrular. İşaretlerin rengi değişmemiş, taşınmamış ve çiçeklerle örtülmemişti; bu yüzden A, B ve D yanlıştır."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "{kahraman} üç kozalaklı ilk işareti neden değiştirdi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Sincap onu oyun sandığı için"
        },
        {
          "id": "B",
          "metin": "Kozalaklar çok ağır olduğu için"
        },
        {
          "id": "C",
          "metin": "Köprü çok yüksek olduğu için"
        },
        {
          "id": "D",
          "metin": "Yol çok kısa olduğu için"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Fakat sincap, üç kozalağı görünce bunun bir oyun işareti olduğunu sandı.\" cümlesi, işaretin yol bilgisi olarak okunmadığını gösterir; bu yüzden yeni bir anlaşma gerekti. Kozalakların ağırlığı, köprünün yüksekliği ve yolun uzunluğu metinde değişiklik nedeni olarak geçmez."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "“Rota” sözcüğü bu cümlede hangi anlamda kullanılmıştır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Meyvelerin tadı"
        },
        {
          "id": "B",
          "metin": "İzlenecek yol"
        },
        {
          "id": "C",
          "metin": "Ağaçların gölgesi"
        },
        {
          "id": "D",
          "metin": "Kozalakların rengi"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"{kahraman} sincapla birlikte ilk rotayı tekrar yürüdü.\" cümlesinde rota, yürünen yolu, yani izlenecek güzergâhı anlatır. Meyvenin tadı, gölge ve kozalağın rengi yürünebilecek bir şey değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 5,
      "metin": "{kahraman} neden günün sonunda kozalakları toplamaya çıktı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yeni bir oyun başlatmak için"
        },
        {
          "id": "B",
          "metin": "Buluşmayı unutturmak için"
        },
        {
          "id": "C",
          "metin": "Köprüyü kapatmak için"
        },
        {
          "id": "D",
          "metin": "Ormanı doğal bırakmak için"
        }
      ],
      "dogru": "D",
      "aciklama": "Metindeki \"Ormanın doğal görüntüsünün korunmasını istiyordu.\" cümlesi, toplama nedeninin ormanı olduğu gibi bırakmak olduğunu gösterir. Oyun başlatmak, buluşmayı unutturmak ya da köprüyü kapatmak metinde hiç amaç olarak geçmez."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr162_isaret",
        "tur": "kelime",
        "yazim": "işaret",
        "anlam": "Bir şeyi gösteren ya da yön belirten simge ve belirti.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr162_isaret_b",
        "tur": "kelime",
        "yazim": "tabela",
        "anlam": "Bilgi vermek için bir yere asılan levha.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr162_isaret_c",
        "tur": "kelime",
        "yazim": "iz",
        "anlam": "Bir şeyin geçtiğini gösteren belirti.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr162_yol",
        "tur": "kelime",
        "yazim": "yol",
        "anlam": "Bir yerden başka bir yere ulaşmayı sağlayan güzergâh.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr162_yol_b",
        "tur": "kelime",
        "yazim": "patika",
        "anlam": "Yaya geçişine açık, dar yol.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr162_yol_c",
        "tur": "kelime",
        "yazim": "güzergâh",
        "anlam": "Bir yolculukta izlenen yol.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr162_kozalak",
        "tur": "kelime",
        "yazim": "kozalak",
        "anlam": "Çam ve benzeri ağaçların tohum taşıyan sert meyvesi.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr162_kozalak_b",
        "tur": "kelime",
        "yazim": "tohum",
        "anlam": "Bitkilerin üremesini sağlayan tane.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr162_kozalak_c",
        "tur": "kelime",
        "yazim": "kabuk",
        "anlam": "Meyve ya da tohumu dış etkilerden koruyan sert katman.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr162_anlasma",
        "tur": "kelime",
        "yazim": "anlaşma",
        "anlam": "İki ya da daha çok tarafın birlikte kararlaştırdığı ortak düzen.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr162_anlasma_b",
        "tur": "kelime",
        "yazim": "uzlaşma",
        "anlam": "Görüş ayrılıklarını ortak bir karara bağlama.",
        "sinif_alt": 5,
        "sinif_ust": 5
      },
      {
        "id": "hr162_anlasma_c",
        "tur": "kelime",
        "yazim": "sözleşme",
        "anlam": "Yazılı olarak yapılan karşılıklı taahhüt.",
        "sinif_alt": 5,
        "sinif_ust": 5
      }
    ],
    "yuvalar": [
      {
        "ad": "hr162_isaret",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr162_isaret"
          },
          {
            "girdi": "hr162_isaret_b"
          },
          {
            "girdi": "hr162_isaret_c"
          }
        ]
      },
      {
        "ad": "hr162_yol",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr162_yol"
          },
          {
            "girdi": "hr162_yol_b"
          },
          {
            "girdi": "hr162_yol_c"
          }
        ]
      },
      {
        "ad": "hr162_kozalak",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr162_kozalak"
          },
          {
            "girdi": "hr162_kozalak_b"
          },
          {
            "girdi": "hr162_kozalak_c"
          }
        ]
      },
      {
        "ad": "hr162_anlasma",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr162_anlasma"
          },
          {
            "girdi": "hr162_anlasma_b"
          },
          {
            "girdi": "hr162_anlasma_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr163-hayvan-kunduzun-sessiz-su-yolu",
    "baslik": "Kunduzun Dere Dengesi",
    "tur": "doga",
    "konu": "akarsu_akis_dengesi",
    "sinif_alt": 6,
    "sinif_ust": 6,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "hayvan"
    ],
    "deger_anahtarlari": [
      "D16",
      "D5"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 6,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "doga"
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
          "id": "sozcuk1_hr163",
          "tur": "lexeme",
          "etiket": "akıntı",
          "yuva": "hr163_akinti",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr163",
          "tur": "lexeme",
          "etiket": "engel",
          "yuva": "hr163_engel",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr163",
          "tur": "lexeme",
          "etiket": "birikim",
          "yuva": "hr163_birikim",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr163",
          "tur": "lexeme",
          "etiket": "korunak",
          "yuva": "hr163_korunak",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (6. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 551,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Deredeki dal yığını akıntıyı değiştiriyor. {kahraman} farklı canlıların ihtiyaçlarını gözeterek suyun yolunu düzenliyor.",
    "durum": "taslak",
    "fis_kodu": "HR-163"
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
          "v": " geniş bir dere kenarında yaşayan bir kunduzdu. Su yollarını gözlemlemeye ve kıyıdaki dalları düzenlemeye meraklıydı. İlkbaharda dere, her zamankinden daha hızlı akmaya başladı. Suyun bir bölümü eski bir dal yığınının çevresinden dönüyor, başka bir bölümde ise neredeyse duruyordu. Derenin üst kısmında akan yapraklar, suyun yönünü göstermek için doğal bir işaret gibiydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yaprakların hangi kıyıya yaklaştığını izledi. Fakat rüzgârın da onları itebileceğini düşündü. Bu yüzden yalnızca yaprakların yoluna bakarak karar vermedi; su yüzeyindeki başka hareketleri de karşılaştırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun nedenini anlamak için kıyıya çıktı. Akıntı, suyun belirli yönde hareket etmesiydi. Dere kıyısındaki küçük bir balık, durgun bölümde suyun bulanıklaştığını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hemen bütün dalları kaldırmadı. Dallar bazı canlılara "
        },
        {
          "t": "kelime",
          "yuva": "hr163_korunak"
        },
        {
          "t": "metin",
          "v": " sağlıyordu; değişiklik yapmadan önce etkilerini düşünmek gerekiyordu."
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
          "v": " suyun geçtiği noktaları uzaktan izledi. Bir "
        },
        {
          "t": "kelime",
          "yuva": "hr163_engel"
        },
        {
          "t": "metin",
          "v": ", akışın yönünü değiştirebiliyordu. Fakat her engel kötü değildi; bazıları kıyının aşınmasını azaltıyordu. Sorun, eski yığının bir yanında çok fazla "
        },
        {
          "t": "kelime",
          "yuva": "hr163_birikim"
        },
        {
          "t": "metin",
          "v": " oluşmasıydı. Yapraklar ve küçük dallar burada toplanmıştı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Burak"
        },
        {
          "t": "metin",
          "v": " gölgeyi, balık ise daha açık suyu seviyordu. Bu iki istek ilk bakışta çelişiyor gibiydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " iki isteğin aynı dere içinde farklı yerlerde karşılanabileceğini fark etti. Herkesi tek bir noktaya toplamak gerekmiyordu. Küçük alanları birlikte korumak mümkündü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " suyu tamamen kesmeyen bir düzenleme yapmayı düşündü. Önce kıyıdaki küçük canlıların hangi bölümde dinlendiğini öğrendi. Her iki ihtiyacı da dikkate almak kolay değildi."
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
          "v": " yerinden oynatılması kolay birkaç küçük dalı dikkatlice değiştirdi. Büyük ve sağlam dallara dokunmadı. Suyun geçtiği açıklık biraz genişledi. İlk anda "
        },
        {
          "t": "kelime",
          "yuva": "hr163_akinti"
        },
        {
          "t": "metin",
          "v": " daha hızlı göründü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunun her yerde iyi sonuç verip vermediğini anlamak için bir süre bekledi. Dalın yerinin değiştirilmesinden sonra suyun sesi bir an değişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sesi olumlu ya da olumsuz diye hemen değerlendirmedi. Kıyıdaki otların durumuna, suyun hareketine ve canlıların davranışına da baktı. Bir işaretin anlamı, diğer işaretlerle birlikte daha iyi anlaşılabilirdi. Dere kıyısındaki otların bir bölümünde yeni bir aşınma izi belirdi. Bu, çok fazla açıklığın da sorun yaratabileceğini gösteriyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " küçük dallardan birini geri koydu. Kurbağanın gölgesi korundu, balığın bulunduğu bölgeye de daha temiz su ulaştı. Düzenleme bir kerede bitmemiş, gözlemle iyileştirilmişti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Birkaç gün sonra yoğun yağmur yağdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güvenli kıyıdan suyu izledi. Eski dal yığınında biriken yaprakların bir kısmı sürüklenmişti. Yeni açıklık suyun geçmesini kolaylaştırıyordu ama dere hâlâ doğal biçiminde akıyordu. Balık kıyıya yaklaşarak suyun daha az bulanık göründüğünü belirtti. Yağmur sonrası kıyıda küçük taşlar yer değiştirmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunların her zaman aynı noktada kalmadığını biliyordu. Derenin doğal hareketini durdurmaya çalışmak yerine zarar verebilecek düzensizlikleri anlamaya yöneldi. Bu yaklaşım, gereksiz müdahaleleri azaltıyordu. Canlıların geçiş yolları açık bırakıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu tek gözlemin tüm dere için kesin sonuç olmadığını biliyordu. Farklı noktalara bakmaya devam etti. Dere boyunca yaşayan canlılar değişikliklerden haberdardı. Herkes kendi bölgesindeki su durumunu anlatıyordu. Böylece küçük bir çalışma ortak bir gözleme dönüştü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Yaz başında dere sakinleşti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dal yığınının yanına oturup suyu dinledi. Artık tek bir yerde hızlı akan suyun başka bir yerde oluşturabileceği etkileri daha iyi anlıyordu. Denge, her noktanın aynı olması değil, farklı ihtiyaçların bir arada karşılanabilmesiydi. Akşam serinliği çöktüğünde balığın bulunduğu sığ bölüm sakinleşti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kendi yaptığı değişikliklerin yalnızca bir bölümde değil, bütün küçük canlıların yaşamında iz bırakabildiğini düşündü. Bu yüzden yeni bir dalı oynatmadan önce biraz daha uzun gözlem yapmayı tercih etti. Balık açık su bölümünde yüzüyor, "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Burak"
        },
        {
          "t": "metin",
          "v": " gölgeye çekiliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dalları kendi istediği biçime sokmak yerine derenin işleyişine uyum sağlamaya çalışmıştı. Yaprakların su üzerinde çizdiği küçük daireler yavaşça akıntıya karıştı. Dere sessizce yoluna devam etti."
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
      "metin": "Deredeki ilk sorun neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Bütün suyun kaybolması"
        },
        {
          "id": "B",
          "metin": "Akışın her yerde aynı olmaması"
        },
        {
          "id": "C",
          "metin": "Dalların hepsinin yemyeşile boyanması"
        },
        {
          "id": "D",
          "metin": "Kıyıda yeni yol açılması"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Suyun bir bölümü eski bir dal yığınının çevresinden dönüyor, başka bir bölümde ise neredeyse duruyordu.\" cümlesi, akışın her yerde aynı olmadığını gösterir. Su kaybolmamış, dallar boyanmamış ve kıyıda yeni yol açılmamıştı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 1,
      "metin": "{kahraman} neden büyük dalları hemen kaldırmadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Canlılara korunak oldukları için"
        },
        {
          "id": "B",
          "metin": "Dalların rengini hiç sevmediği için"
        },
        {
          "id": "C",
          "metin": "Dereyi tamamen kurutmak için"
        },
        {
          "id": "D",
          "metin": "Bütün balıklar uzaklaşsın diye"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Dallar bazı canlılara korunak sağlıyordu; değişiklik yapmadan önce etkilerini düşünmek gerekiyordu.\" cümlesi A seçeneğini doğrular. Kunduz dalların rengiyle ilgilenmemiş, dereyi kurutmak ya da balıkları uzaklaştırmak istememiştir."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "“Birikim” sözcüğü bağlamda neyi anlatır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Suyun güneşte buharlaşıp azalmasını"
        },
        {
          "id": "B",
          "metin": "Kıyıdaki güneşi"
        },
        {
          "id": "C",
          "metin": "Bir yerde toplanan yaprakları"
        },
        {
          "id": "D",
          "metin": "Balığın hızla yüzüp uzaklaşmasını"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Sorun, eski yığının bir yanında çok fazla birikim oluşmasıydı.\" cümlesinden sonra yaprakların ve küçük dalların burada toplandığı yazar; birikim bir yerde toplanıp yığılan şeydir. Buharlaşma, güneş ve balığın yüzmesi bu anlama uymaz."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} neden birkaç gün daha gözlem yaptı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Dalları saymak için"
        },
        {
          "id": "B",
          "metin": "Kıyıya kendine yeni bir yuva yapmak için"
        },
        {
          "id": "C",
          "metin": "Yağmuru durdurmak için"
        },
        {
          "id": "D",
          "metin": "Tek gözlemle karar vermemek için"
        }
      ],
      "dogru": "D",
      "aciklama": "Metindeki \"{kahraman} bu tek gözlemin tüm dere için kesin sonuç olmadığını biliyordu.\" cümlesi, kunduzun tek bir gözleme güvenmeyip farklı noktalara bakmaya devam ettiğini gösterir. Dalları saymak, yuva yapmak ve yağmuru durdurmak metinde yoktur."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr163_akinti",
        "tur": "kelime",
        "yazim": "akıntı",
        "anlam": "Suyun belirli bir yönde akması.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr163_akinti_b",
        "tur": "kelime",
        "yazim": "akım",
        "anlam": "Suyun ya da havanın hareket yönü ve hızı.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr163_akinti_c",
        "tur": "kelime",
        "yazim": "dalga",
        "anlam": "Su yüzeyinde ilerleyen yükseltilmiş hareket.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr163_engel",
        "tur": "kelime",
        "yazim": "engel",
        "anlam": "Bir yerin geçilmesini güçleştiren şey.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr163_engel_b",
        "tur": "kelime",
        "yazim": "kaya",
        "anlam": "Doğal olarak oluşmuş büyük ve sert taş kütlesi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr163_engel_c",
        "tur": "kelime",
        "yazim": "set",
        "anlam": "Suyun akışını tutmak için yapılan yükselti.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr163_birikim",
        "tur": "kelime",
        "yazim": "birikim",
        "anlam": "Bir yerde zamanla toplanıp kalan madde.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr163_birikim_b",
        "tur": "kelime",
        "yazim": "yığın",
        "anlam": "Bir yerde üst üste toplanmış şey.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr163_birikim_c",
        "tur": "kelime",
        "yazim": "tortu",
        "anlam": "Suyun dibinde kalan katı madde.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr163_korunak",
        "tur": "kelime",
        "yazim": "korunak",
        "anlam": "Tehlikeden ya da kötü havadan korunulan yer.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr163_korunak_b",
        "tur": "kelime",
        "yazim": "sığınak",
        "anlam": "Canlıların kendini koruduğu yer.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr163_korunak_c",
        "tur": "kelime",
        "yazim": "barınak",
        "anlam": "Canlıların içinde kalıp korunabildiği yer.",
        "sinif_alt": 6,
        "sinif_ust": 6
      }
    ],
    "yuvalar": [
      {
        "ad": "hr163_akinti",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr163_akinti"
          },
          {
            "girdi": "hr163_akinti_b"
          },
          {
            "girdi": "hr163_akinti_c"
          }
        ]
      },
      {
        "ad": "hr163_engel",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr163_engel"
          },
          {
            "girdi": "hr163_engel_b"
          },
          {
            "girdi": "hr163_engel_c"
          }
        ]
      },
      {
        "ad": "hr163_birikim",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr163_birikim"
          },
          {
            "girdi": "hr163_birikim_b"
          },
          {
            "girdi": "hr163_birikim_c"
          }
        ]
      },
      {
        "ad": "hr163_korunak",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr163_korunak"
          },
          {
            "girdi": "hr163_korunak_b"
          },
          {
            "girdi": "hr163_korunak_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr164-hayvan-arinin-cicek-rotasi",
    "baslik": "Arının Çiçek Rotası",
    "tur": "doga",
    "konu": "polen_ve_bahce",
    "sinif_alt": 6,
    "sinif_ust": 6,
    "okuma_bandi": 2,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "hayvan"
    ],
    "deger_anahtarlari": [
      "D3",
      "D15"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 6,
      "okuma_zorlugu": 3,
      "kavram_zorlugu": 3,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "doga"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D3",
        "yardimci_deger": "D15"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr164",
          "tur": "lexeme",
          "etiket": "polen",
          "yuva": "hr164_polen",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr164",
          "tur": "lexeme",
          "etiket": "çiçeklenme",
          "yuva": "hr164_ciceklenme",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr164",
          "tur": "lexeme",
          "etiket": "çeşitlilik",
          "yuva": "hr164_cesitlilik",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr164",
          "tur": "lexeme",
          "etiket": "gözlem",
          "yuva": "hr164_gozlem",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (6. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 572,
        "tahmini_sure_dk": 5,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Bahçede her çiçek aynı zamanda açmıyor. {kahraman} gözlem yaparak daha uygun bir çiçek rotası buluyor.",
    "durum": "taslak",
    "fis_kodu": "HR-164"
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
          "v": " meyve bahçesinde yaşayan bir arıydı. Bahar gelince ağaçlar çiçeklerle doldu. Bazı günler aynı ağaçlarda çok sayıda çiçek açıyor, bazı günler ise başka köşeler canlanıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yiyecek ararken bütün bahçeyi rastgele dolaşmanın yorucu olduğunu fark etti. Bahçenin girişindeki eski ağacın çiçekleri kokularıyla da birbirinden ayrılıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " renklerin her zaman tek başına yeterli ipucu vermediğini öğrendi. Bazı çiçekler uzaktan benzer görünse bile yakınlarında farklı özellikler taşıyordu. Yol seçmek için birçok işarete dikkat etmek gerekiyordu. Önce hangi bölgenin ne zaman çiçeklendiğini gözlemlemeye başladı. Bir yanda açık renkli çiçekler, öte yanda koyu yapraklı çalılar vardı. Çiçeklerin renkleri kadar konumları da önemliydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güneşin hareketiyle gölgelerin nasıl değiştiğini izledi. Dikkatli bir rota, gereksiz uçuşu azaltabilir ve her gün farklı çiçeklere ulaşmayı kolaylaştırabilirdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Sabah ilk uçuşta "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eski ağacın yanına gitti. Çiçeklerden topladığı "
        },
        {
          "t": "kelime",
          "yuva": "hr164_polen"
        },
        {
          "t": "metin",
          "v": ", çiçeklerin üreme yapılarında bulunan ince tanelerdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " poleni bacaklarının özel bölümlerinde taşıyordu. Fakat o gün aynı ağacın bazı dalları henüz tomurcuktu. Öteki köşedeki çiçekler rüzgârdan daha az etkileniyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kısa bir süre orada dinlendi. Bu bölgeyi seçmesinin tek nedeni yiyecek miktarı değildi; güvenli uçuş ve dinlenme imkânı da önemliydi. Bahçenin farklı bölümleri farklı zamanlarda işe yarıyordu. Boş yere dolaşmak yerine bahçenin güneş alan öteki köşesine geçti. Orada farklı çiçeklerin açtığını gördü. Bahçenin "
        },
        {
          "t": "kelime",
          "yuva": "hr164_cesitlilik"
        },
        {
          "t": "metin",
          "v": " bakımından zengin olması, her gün aynı kaynağa bağlı kalmasını önlüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yiyecek toplarken çiçeklerin zarar görmemesine de dikkat etti. Bir çiçekten diğerine geçiş, bahçenin canlı düzeninin parçasıydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Öğleye doğru sıcaklık arttı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gölgeli alanların bazılarında çiçeklerin yeni açtığını fark etti. Sabah açık olan birkaç çiçek ise artık kapanmıştı. Bunun üzerine rotasını günün saatine göre değiştirdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Nil"
        },
        {
          "t": "metin",
          "v": ", aynı yolu hiç değiştirmediğini anlattı. İki arı karşılaştırma yaparken biri yalnızca uçtuğu mesafeyi hatırladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dönüşte ne kadar yorulduğunu da düşündü. Daha kısa yol her koşulda daha iyi sonuç vermiyordu. Çiçeklerin ne kadar açık olduğu ve hava hareketleri de yolculuğun verimini etkiliyordu. Bu ayrıntılar denemeyi anlamlı kıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hangi yolun daha az yorucu olduğunu birlikte denemeyi önerdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Nil"
        },
        {
          "t": "metin",
          "v": " ve bir arı farklı bölgeleri gözledi, sonra buldukları kaynakları karşılaştırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tek bir günün sonucunu kesin kural saymadı. Çünkü hava, rüzgâr ve "
        },
        {
          "t": "kelime",
          "yuva": "hr164_ciceklenme"
        },
        {
          "t": "metin",
          "v": " koşulları değişebilirdi. Yol planı da bu değişikliğe uyum sağlamalıydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir gün bahçenin bir bölümünde sulama yapıldı. Çiçeklerin üstüne su püskürürken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " o alana yaklaşmadı. Diğer çiçekli bölgelere yöneldi. Bahçe görevlileri sulamayı yalnızca küçük bir bölümle sınırlı tuttu. Sulama bitince bazı yaprakların üzerinde küçük su damlaları kaldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hemen o bölgeye dönmedi; çiçeklerin yeniden uygun hâle gelmesini bekledi. Beklerken başka bir çalı grubunu inceledi. Orada yeni açan çiçeklerin bulunması, planı değiştirmenin bazen yeni fırsatlar getirdiğini gösterdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bu düzenin birçok canlı için yararlı olduğunu gözledi. Bazı çiçeklerde polen azalmıştı; yenilerinde ise daha çok kaynak vardı. Rotasını güncel duruma göre değiştirmek, bahçedeki canlıların farklı ihtiyaçlarını gözetmesine yardımcı oldu. Öğleden sonra güneş yumuşayınca eski ağaca yeniden uğradı. Bu kez dalların çoğunda çiçekler açmıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Akşamüstü "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kovana döndü. Gün boyunca izlediği farklı çiçek yolları ona aynı bahçenin bile tek biçimde olmadığını göstermişti. Bir gün işe yarayan rota ertesi gün değişebilirdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " başka arıların getirdiği işaretleri gözledi; her biri bahçenin farklı bir yerini tanıyordu. Günün sonunda diğer arıların getirdiği bilgiler birbirinden farklıydı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu bir anlaşmazlık olarak görmedi. Çünkü farklı bölgelerde uçmuşlardı. Her "
        },
        {
          "t": "kelime",
          "yuva": "hr164_gozlem"
        },
        {
          "t": "metin",
          "v": " yer ve zamanıyla birlikte düşünüldüğünde bahçenin bütününe ilişkin daha zengin bir görüntü ortaya çıkıyordu. Çiçeklerin çeşitliliği, hem arılar hem de bahçedeki başka canlılar için önem taşıyordu. Son ışıklar ağaçların arasından süzülürken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dinlendi. Ertesi gün yine çalışacaktı ama artık nereye uçacağına daha bilinçli bakıyordu. Bahçenin düzeni, küçük gözlemlerin birikimiyle daha anlaşılır olmuştu."
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
      "metin": "{kahraman} ilk olarak neyi gözlemlemeye başladı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Kovanların boyasını ve rengini"
        },
        {
          "id": "B",
          "metin": "Toprağın kaç metre derin olduğunu"
        },
        {
          "id": "C",
          "metin": "Hangi bölgenin ne zaman açtığını"
        },
        {
          "id": "D",
          "metin": "Yağmurun yağacağı tam tarihi"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Önce hangi bölgenin ne zaman çiçeklendiğini gözlemlemeye başladı.\" cümlesi C seçeneğini doğrular. Kovanın boyası, toprağın derinliği ve yağmurun tarihi arının gözlem konuları değildir."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Güneş alan köşeye gitmesinin nedeni nedir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Orada açmış çiçekler bulunması"
        },
        {
          "id": "B",
          "metin": "Orada yiyecek sağlayacak bitki olmaması"
        },
        {
          "id": "C",
          "metin": "Ağaçların taşınmış olması"
        },
        {
          "id": "D",
          "metin": "Kovanın oraya kurulması"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Orada farklı çiçeklerin açtığını gördü.\" cümlesi, arının güneş alan köşeye açmış çiçekler olduğu için gittiğini gösterir; eski ağaçta bazı dallar henüz tomurcuktu. Bitkisiz olması, ağaçların taşınması ve kovanın kurulması metinde yoktur."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 2,
      "metin": "“Çeşitlilik” hangi anlamda kullanılmıştır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yalnızca tek bir türün bulunması"
        },
        {
          "id": "B",
          "metin": "Çok türde çiçek bulunması"
        },
        {
          "id": "C",
          "metin": "Bütün yolların kapanması"
        },
        {
          "id": "D",
          "metin": "Arıların aynı anda uyuması"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Bahçenin çeşitlilik bakımından zengin olması, her gün aynı kaynağa bağlı kalmasını önlüyordu.\" cümlesinde çeşitlilik, bahçede çok sayıda farklı çiçeğin bulunmasıdır; tek tür bulunsaydı arı aynı kaynağa bağlı kalırdı. Yolların kapanması ve arıların uyuması bu anlama uymaz."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} niçin sulama sırasında başka bölgeye yöneldi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Ağaçları saymak için"
        },
        {
          "id": "B",
          "metin": "Diğer arıların gözünden saklanmak için"
        },
        {
          "id": "C",
          "metin": "Renkleri değiştirmek için"
        },
        {
          "id": "D",
          "metin": "Islak alandan uzak durmak için"
        }
      ],
      "dogru": "D",
      "aciklama": "Metindeki \"Çiçeklerin üstüne su püskürürken {kahraman} o alana yaklaşmadı.\" cümlesi, arının sulanan ve ıslanan alana uğramayıp diğer çiçekli bölgelere yöneldiğini gösterir. Ağaç saymak, diğer arılardan saklanmak ve renk değiştirmek metinde amaç değildir."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr164_polen",
        "tur": "kelime",
        "yazim": "polen",
        "anlam": "Çiçeklerin üreme yapılarında bulunan ince, toz hâlindeki tanecik.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr164_polen_b",
        "tur": "kelime",
        "yazim": "çiçek tozu",
        "anlam": "Çiçeklerden rüzgârla ya da hayvanlarla taşınan toz.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr164_polen_c",
        "tur": "kelime",
        "yazim": "tohum",
        "anlam": "Bitkinin üremesini sağlayan tane.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr164_ciceklenme",
        "tur": "kelime",
        "yazim": "çiçeklenme",
        "anlam": "Bitkilerin çiçek açma dönemi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr164_ciceklenme_b",
        "tur": "kelime",
        "yazim": "açılma",
        "anlam": "Bir çiçeğin tomurcuktan açılması.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr164_ciceklenme_c",
        "tur": "kelime",
        "yazim": "bahar",
        "anlam": "Bitkilerin canlandığı ilkbahar dönemi.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr164_cesitlilik",
        "tur": "kelime",
        "yazim": "çeşitlilik",
        "anlam": "Bir yerde çok sayıda farklı türün bulunması.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr164_cesitlilik_b",
        "tur": "kelime",
        "yazim": "çokluk",
        "anlam": "Bir yerde çok sayıda olma durumu.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr164_cesitlilik_c",
        "tur": "kelime",
        "yazim": "zenginlik",
        "anlam": "Bir yerde farklı şeylerin çok olması.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr164_gozlem",
        "tur": "kelime",
        "yazim": "gözlem",
        "anlam": "Bir olguyu dikkatle izleyerek kaydetme.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr164_gozlem_b",
        "tur": "kelime",
        "yazim": "inceleme",
        "anlam": "Bir konunun ayrıntılarına bakma.",
        "sinif_alt": 6,
        "sinif_ust": 6
      },
      {
        "id": "hr164_gozlem_c",
        "tur": "kelime",
        "yazim": "izleme",
        "anlam": "Bir durumu belli aralıklarla takip etme.",
        "sinif_alt": 6,
        "sinif_ust": 6
      }
    ],
    "yuvalar": [
      {
        "ad": "hr164_polen",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr164_polen"
          },
          {
            "girdi": "hr164_polen_b"
          },
          {
            "girdi": "hr164_polen_c"
          }
        ]
      },
      {
        "ad": "hr164_ciceklenme",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr164_ciceklenme"
          },
          {
            "girdi": "hr164_ciceklenme_b"
          },
          {
            "girdi": "hr164_ciceklenme_c"
          }
        ]
      },
      {
        "ad": "hr164_cesitlilik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr164_cesitlilik"
          },
          {
            "girdi": "hr164_cesitlilik_b"
          },
          {
            "girdi": "hr164_cesitlilik_c"
          }
        ]
      },
      {
        "ad": "hr164_gozlem",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr164_gozlem"
          },
          {
            "girdi": "hr164_gozlem_b"
          },
          {
            "girdi": "hr164_gozlem_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr165-hayvan-yunusun-kiyidaki-haritasi",
    "baslik": "Yunusun Kıyıdaki Haritası",
    "tur": "hayvanlar",
    "konu": "deniz_cayiri_koruma",
    "sinif_alt": 7,
    "sinif_ust": 7,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "hayvan"
    ],
    "deger_anahtarlari": [
      "D5",
      "D20"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 7,
      "okuma_zorlugu": 4,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "hayvanlar"
      ],
      "ders_baglantisi": [
        "turkce"
      ],
      "maarif": {
        "ana_deger": "D5",
        "yardimci_deger": "D20"
      },
      "ogrenme_hedefleri": [
        {
          "id": "sozcuk1_hr165",
          "tur": "lexeme",
          "etiket": "yankı",
          "yuva": "hr165_yanki",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr165",
          "tur": "lexeme",
          "etiket": "akıntı",
          "yuva": "hr165_akinti",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr165",
          "tur": "lexeme",
          "etiket": "kıyı",
          "yuva": "hr165_kiyi",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr165",
          "tur": "lexeme",
          "etiket": "tekne",
          "yuva": "hr165_tekne",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (7. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 644,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Koydaki deniz çayırlarının çevresinde su bulanıklaşıyor. {kahraman} canlıların doğal alanını koruyan işaretlerin önemini keşfediyor.",
    "durum": "taslak",
    "fis_kodu": "HR-165"
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
          "v": " sakin bir koyda yaşayan bir yunustu. Koyun bazı noktalarında deniz çayırları uzanıyor, başka yerlerinde kumlu zemin başlıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " her gün aynı "
        },
        {
          "t": "kelime",
          "yuva": "hr165_kiyi"
        },
        {
          "t": "metin",
          "v": " boyunca yüzdüğü için akıntının küçük değişimlerini fark ediyordu. Bir sabah koyun girişinde artan "
        },
        {
          "t": "kelime",
          "yuva": "hr165_tekne"
        },
        {
          "t": "metin",
          "v": " hareketlerinin suyu daha bulanık yaptığını gördü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yalnızca üstten bakmanın yanıltıcı olabileceğini biliyordu. Sığ kesimde hareket eden kum taneleri, dipteki canlıların bulunduğu yere kadar ulaşabiliyordu. Bu yüzden aynı bölgeyi farklı zamanlarda gözlemek yararlıydı. Koyun girişindeki tekne hareketleri de günün saatine göre değişiyordu. Gözlemler yalnızca yoğun bir sabahın görüntüsüne dayanmayacaktı. Deniz çayırlarının yakınında dinlenen küçük canlılar başka köşelere çekilmişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " değişimin yalnızca o güne mi ait olduğunu anlamak istedi. Ses çıkarıp geri dönen "
        },
        {
          "t": "kelime",
          "yuva": "hr165_yanki"
        },
        {
          "t": "metin",
          "v": " üzerinden çevresindeki nesnelerin konumunu algılayabiliyordu. Ancak yankı bütün soruları çözmüyordu; suyun rengi ve akışı da gözlemlenmeliydi. Koyun her bölümünün canlılar için farklı bir işlevi vardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Önce koyun girişindeki derinlik farklarını izledi. Derinlik, su yüzeyi ile deniz tabanı arasındaki uzaklıktı. Sığ bölümde küçük tekneler geçerken dipteki ince parçalar kolayca karışıyordu. Daha açık bölümde su çoğu zaman daha berraktı. "
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
          "hal": "yalin",
          "yedek": "Ilgın"
        },
        {
          "t": "metin",
          "v": " ile kıyıya yakın yaşayan küçük balıkların davranışını gözledi. Deniz çayırlarının kenarında küçük bir kum şeridi vardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " burada yavaşça yüzerek suyun hareketini izledi. Bir sonraki gün rüzgâr değişince aynı bölgede farklı bir "
        },
        {
          "t": "kelime",
          "yuva": "hr165_akinti"
        },
        {
          "t": "metin",
          "v": " oluştuğunu gördü. Bu fark, suyun görünüşünü etkileyebilecek başka etkenlerin de bulunduğunu düşündürdü. Koyda yaşayan canlıların nerede yoğunlaştığını anlamak için yalnızca derinliği değil, gün içindeki değişimi de dikkate almak gerekiyordu. Bazı günler balıklar deniz çayırlarının arasında rahatça dolaşıyordu. Diğer günler bulanıklık artınca açık alana yöneliyorlardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " tek bir işarete dayanmadı. Akıntı, tekne sayısı ve suyun görünüşünü birlikte değerlendirdi. Koyda yaşayan canlıların kendi düzenlerini bozmadan gözlem yapmak istiyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bir öğleden sonra koyun girişinde işaret şamandıraları yerleştirildi. Bu işaretler, teknelerin deniz çayırları bulunan hassas bölgeye yaklaşmamasına yardımcı olacaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yeni çizgiyi izleyerek yüzdü. Su hâlâ bazı yerlerde bulanıktı. Şamandıraların konduğu ilk gün bazı tekneler yeni çizgiyi uzaktan fark etmedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Ilgın"
        },
        {
          "t": "metin",
          "v": " ve kıyı görevlileri işaretlerin anlamını daha açık anlatan levhalar hazırladı. Çizgi yalnızca su üstünde bir sınır değildi; tekne kullananların onu doğru okuyabilmesi de gerekiyordu. Açıklamalarla birlikte geçiş daha düzenli hâle geldi. Böylece hassas bölgeyi korumak isteyenlerin niyeti günlük davranışlara yansıdı. Teknelerin geçtiği hat de daha belirgin olmuştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " suyun altındaki habitatın, yani canlıların yaşadığı doğal ortamın, görünmeyen ayrıntılar taşıdığını biliyordu. Deniz çayırları yalnızca yeşil bir yüzey değildi; pek çok küçük canlının sığındığı bir alandı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İzleyen günlerde koyda daha düzenli bir tekne geçişi oluştu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " deniz çayırlarının üzerindeki bulanıklığın bazı saatlerde azaldığını fark etti. Ancak bunun yalnızca yeni işaretlerden kaynaklandığını söylemek için erkendi. Rüzgârın yönü ve denizin dalgalanması da görünüşü etkileyebilirdi. Gözlem sürdükçe koyun kimi bölümünde kısa süreli bulanıklıkların devam ettiği görüldü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bunu bütün çalışmanın başarısızlığı saymadı. Mevsim, rüzgâr ve teknelerin hareketi birlikte etkiliydi. Koruma ekibi belirli saatlerde yeniden ölçüm yapıyordu. Kıyıda yaşayanlar da suyun görünüşüne dair notlar paylaşıyordu. Farklı kaynaklardan gelen bilgiler birbirini tamamlayabilirdi ama hiçbir gözlem kendi sınırlarının ötesinde kesin kanıt sayılmıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " aynı yerlerde tekrar gözlem yaptı. Koyun sakin bölümünde küçük balıklar yeniden çayırlara yaklaşmaya başlamıştı. Bir canlı için uygun olan her çözüm, başka bir canlı için aynı biçimde işlemeyebilirdi. Bu nedenle koyun bütün bölümleri birlikte düşünülüyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Mevsim değişirken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " koyun girişinden açık denize doğru yüzdü, sonra yeniden çayırlara döndü. Su daha berrak görünüyordu; dipteki yaprakların hareketi uzaktan seçilebiliyordu. Koydaki yaşam tek bir günde düzelmemişti. Tekne yollarının düzenlenmesi, ölçümlerin sürmesi ve canlıların korunması ortak çalışmanın parçaları olmuştu. Koydan ayrılmadan önce "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " çayırlara son kez yaklaştı ama aralarına hızla dalmadı. Küçük canlıların sığındığı bölgeyi rahatsız etmeden çevresinde dolaştı. Koruma çalışmasının en görünür sonucu yeni şamandıralar olabilirdi. Asıl amaç ise bunların gösterdiği güvenli mesafenin sürdürülmesiydi. Koyun haritası zamanla yeniden gözden geçirilecekti; doğal yaşam her mevsim aynı görünmeyebilirdi. Sakin deniz yüzeyi altında birçok canlı kendi düzenini sürdürüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sesinin yankısını dinledi. Geri dönen küçük işaretler ona taşları, kıyıyı ve derinliği anlatıyordu. Yankı taşların ve derinliğin yerini gösteriyordu; hangi yere dikkatle yaklaşılacağını ise koruma ekibinin şamandıraları belirtiyordu. Deniz çayırları dalgalarla hafifçe sallanırken koy yaşamını sürdürdü."
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
      "metin": "Koyda fark edilen değişim neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Suyun tamamen çekilmesi"
        },
        {
          "id": "B",
          "metin": "Tekne hareketiyle artan bulanıklık"
        },
        {
          "id": "C",
          "metin": "Bütün deniz çayırlarının birden yok olması"
        },
        {
          "id": "D",
          "metin": "Kıyıdaki taşların uçması"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Bir sabah koyun girişinde artan tekne hareketlerinin suyu daha bulanık yaptığını gördü.\" cümlesi B seçeneğini doğrular. Su çekilmemiş, çayırlar yok olmamış ve taşlar uçmamıştı."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "Sığ bölgede dip parçalarının karışması neyi düşündürür?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Derinlik de tekneler de etkili olabilir"
        },
        {
          "id": "B",
          "metin": "Koyun her yerinde su aynı derinliktedir"
        },
        {
          "id": "C",
          "metin": "Koyda hiç akıntı yoktur"
        },
        {
          "id": "D",
          "metin": "Deniz çayırları her gün başka yere taşınır"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"Sığ bölümde küçük tekneler geçerken dipteki ince parçalar kolayca karışıyordu.\" cümlesi, bulanıklığın sığ yerde tekne geçişiyle arttığını gösterir; yani derinlik ve tekne birlikte etkili olabilir. Koyun her yerinin aynı derinlikte olması, akıntının hiç bulunmaması ve çayırların taşınması metinde yoktur."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 3,
      "metin": "“Habitat” kelimesinin anlamı nedir?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Teknenin su altındaki pervane motoru"
        },
        {
          "id": "B",
          "metin": "Koyun haritası"
        },
        {
          "id": "C",
          "metin": "Canlıların doğal yaşam alanı"
        },
        {
          "id": "D",
          "metin": "Derinliğin sayısal ölçümü"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"{kahraman} suyun altındaki habitatın, yani canlıların yaşadığı doğal ortamın, görünmeyen ayrıntılar taşıdığını biliyordu.\" cümlesi habitatı canlıların yaşadığı doğal ortam olarak tanımlar. Motor, harita ve derinlik ölçümü bir yaşam alanı değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} neden bulanıklığın azalmasını tek bir nedene bağlamadı?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Gözlem yapmayı tamamen bırakmak için"
        },
        {
          "id": "B",
          "metin": "Tekneleri kovmak için"
        },
        {
          "id": "C",
          "metin": "Koydan uzaklaşmak için"
        },
        {
          "id": "D",
          "metin": "Başka etkenler de olabileceği için"
        }
      ],
      "dogru": "D",
      "aciklama": "Metindeki \"Rüzgârın yönü ve denizin dalgalanması da görünüşü etkileyebilirdi.\" cümlesi, bulanıklığın azalmasında şamandıralardan başka etkenlerin de rol oynayabileceğini gösterir. Gözlemi bırakmak, tekneleri kovmak ve koydan ayrılmak metinde yoktur."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr165_yanki",
        "tur": "kelime",
        "yazim": "yankı",
        "anlam": "Bir sesin bir yüzeyden yansıyıp geri gelmesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr165_yanki_b",
        "tur": "kelime",
        "yazim": "yansıma",
        "anlam": "Işığın ya da sesin bir yüzeyden geri dönmesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr165_yanki_c",
        "tur": "kelime",
        "yazim": "çınlama",
        "anlam": "Bir sesin uzun süre titreşerek kalması.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr165_akinti",
        "tur": "kelime",
        "yazim": "akıntı",
        "anlam": "Suyun belirli bir yönde akması.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr165_akinti_b",
        "tur": "kelime",
        "yazim": "akım",
        "anlam": "Suyun ya da havanın hareket yönü ve hızı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr165_akinti_c",
        "tur": "kelime",
        "yazim": "dalga",
        "anlam": "Su yüzeyinde ilerleyen yükseltilmiş hareket.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr165_kiyi",
        "tur": "kelime",
        "yazim": "kıyı",
        "anlam": "Denizin ya da gölün karaya bitişen kenarı.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr165_kiyi_b",
        "tur": "kelime",
        "yazim": "kenar",
        "anlam": "Bir yerin dış sınırına yakın bölüm.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr165_kiyi_c",
        "tur": "kelime",
        "yazim": "sahil",
        "anlam": "Denizin ya da gölün kıyısı boyunca uzanan alan.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr165_tekne",
        "tur": "kelime",
        "yazim": "tekne",
        "anlam": "Su üzerinde yolcu ya da yük taşımaya yarayan küçük araç.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr165_tekne_b",
        "tur": "kelime",
        "yazim": "gemi",
        "anlam": "Denizde yük ya da yolcu taşıyan büyük araç.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr165_tekne_c",
        "tur": "kelime",
        "yazim": "kayık",
        "anlam": "Küçük ve açık, genellikle kürekle yürütülen tekne.",
        "sinif_alt": 7,
        "sinif_ust": 7
      }
    ],
    "yuvalar": [
      {
        "ad": "hr165_yanki",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr165_yanki"
          },
          {
            "girdi": "hr165_yanki_b"
          },
          {
            "girdi": "hr165_yanki_c"
          }
        ]
      },
      {
        "ad": "hr165_akinti",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr165_akinti"
          },
          {
            "girdi": "hr165_akinti_b"
          },
          {
            "girdi": "hr165_akinti_c"
          }
        ]
      },
      {
        "ad": "hr165_kiyi",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr165_kiyi"
          },
          {
            "girdi": "hr165_kiyi_b"
          },
          {
            "girdi": "hr165_kiyi_c"
          }
        ]
      },
      {
        "ad": "hr165_tekne",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr165_tekne"
          },
          {
            "girdi": "hr165_tekne_b"
          },
          {
            "girdi": "hr165_tekne_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

do $m$ begin raise notice '%', public._tmp_okuma_denetim_iceri_al($json${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr166-hayvan-turnanin-bekleme-cizgisi",
    "baslik": "Turnanın Bekleme Çizgisi",
    "tur": "doga",
    "konu": "goc_sulak_alan_dinlenme",
    "sinif_alt": 7,
    "sinif_ust": 7,
    "okuma_bandi": 3,
    "dunya_tipi": "gercekci",
    "izinli_turler": [
      "hayvan"
    ],
    "deger_anahtarlari": [
      "D12",
      "D14"
    ],
    "yetiskin_uygun": false,
    "etiketler": {
      "ana_sinif": 7,
      "okuma_zorlugu": 4,
      "kavram_zorlugu": 4,
      "ilgi_egilimi": "ortak",
      "temalar": [
        "doga"
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
          "id": "sozcuk1_hr166",
          "tur": "lexeme",
          "etiket": "göç",
          "yuva": "hr166_goc",
          "islev": "first_hint"
        },
        {
          "id": "sozcuk2_hr166",
          "tur": "lexeme",
          "etiket": "enerji",
          "yuva": "hr166_enerji",
          "islev": "application"
        },
        {
          "id": "sozcuk3_hr166",
          "tur": "lexeme",
          "etiket": "sürü",
          "yuva": "hr166_suru",
          "islev": "application"
        },
        {
          "id": "sozcuk4_hr166",
          "tur": "lexeme",
          "etiket": "rehberlik",
          "yuva": "hr166_rehberlik",
          "islev": "transfer"
        }
      ],
      "kanit_duzeyi": "C",
      "program_surumu": "TYMM 2026-27 (7. sınıf); kazanım kodu yok (source_pending)",
      "denetim": {
        "ajan_a": "pending",
        "ajan_b": "pending",
        "insan": "pending"
      },
      "olculen": {
        "kelime_sayisi": 662,
        "tahmini_sure_dk": 6,
        "sayfa_sayisi": 5,
        "soru_sayisi": 4,
        "soru_beceri_dagilimi": {
          "hatirlama": 1,
          "cikarim": 1,
          "sozcuk_baglami": 1,
          "yorumlama": 1
        },
        "hedef_tur_dagilimi": {
          "lexeme": 4
        },
        "yoldas_yer_sayisi": 2,
        "simge_sayisi": 0
      }
    },
    "tanitim": "Göç eden kuşların dinlenme kıyısına yürüyüş yolu yaklaşıyor. {kahraman} sürüye güvenli bir durak bulmak için doğru zamanı bekliyor.",
    "durum": "taslak",
    "fis_kodu": "HR-166"
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
          "v": " uzun yolculuklara çıkan bir turnaydı. Her mevsim değişiminde sürüsüyle birlikte farklı sulak alanlarda dinlenirdi. Bu yıl geçiş sırasında alışılmış dinlenme alanının kıyısında yeni yürüyüş yolları açıldığını gördü. Yollar insanlara doğayı izleme fırsatı veriyordu ama bazı noktalarda kuşların sakin kaldığı bölgeye fazla yaklaşılıyordu. Gökyüzünden bakıldığında sulak alan tek parça görünüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " aşağı indikçe farklı bölümlerin birbirinden ne kadar ayrı olduğunu gördü. Bazı yerler sığ suyla, bazıları uzun sazlarla kaplıydı. Dinlenme, beslenme ve güvenli yaklaşma alanlarının aynı yerde bulunması gerekmiyordu. Sürü uzun yoldan geldiği için çok fazla deneme yapmak istemiyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " daha önce tanıdığı güvenli noktaları hatırlayarak dikkatli bir seçim yaptı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sürüyle birlikte alçaktan uçup güvenli bir iniş alanı aradı. Göç boyunca harcanan "
        },
        {
          "t": "kelime",
          "yuva": "hr166_enerji"
        },
        {
          "t": "metin",
          "v": ", dinlenme sırasında yeniden kazanılmalıydı. Bu nedenle bir yerde kısa süre durabilmek bile önemliydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " havadan gördüğü alanları aceleyle değerlendirmedi. Suyun derinliğini, kıyının sakinliğini ve dinlenen diğer kuşları birlikte gözledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk durak geniş sazlıkların yakınıydı. Burada sığ su ve korunaklı kıyı vardı. Fakat günün ilerleyen saatlerinde insan sesleri artıyordu. "
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
          "hal": "yalin",
          "yedek": "Çınar"
        },
        {
          "t": "metin",
          "v": " ile birlikte sürünün daha sakin bir bölgeye yönelmesini işaret etti. Kuşlar acele etmeden hareket etti. Sazlıkta dinlenirken "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " bir yandan da sürünün hareketlerini gözledi. Birkaç kuş erken havalanıp sonra tekrar indi. Bu kısa kalkışlar bile enerji harcatıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " daha sakin kıyının "
        },
        {
          "t": "kelime",
          "yuva": "hr166_suru"
        },
        {
          "t": "metin",
          "v": " için uygun olabileceğini düşündü. Alanın uzağındaki yürüyüş yolunda insanlar kuşları merakla izliyordu. Doğayı tanımak istemeleri anlaşılırdı ama yaklaşma mesafesi dikkatle seçilmeliydi. Herkesin yararlanacağı bir düzen için farklı ihtiyaçları bilmek gerekiyordu. Uzun uçuşun ardından gereksiz yere yeniden havalanmak yorucuydu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yakın taraftaki küçük koyu seçerken rüzgârın durumunu da düşündü. Koy, açık bölgeye göre daha az dalga alıyordu. Sulak alan farklı canlılara yiyecek ve dinlenme imkânı sağlıyordu. Fakat her köşe aynı anda herkes için uygun değildi. Sürünün güvenli biçimde birlikte kalması gerekiyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi gün kıyıdaki gözlem yolu yeniden düzenlendi. İnsanların geçebileceği çizginin ötesinde sessiz bir bölüm ayrıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " uzaktan yeni işaretleri gördü. İlk gün bazı ziyaretçiler çizginin önemini anlamadı. Gözlem alanındaki levhalarda neden sessiz kalınması gerektiği açıklanıyordu. Bazı ziyaretçiler daha iyi görmek için yakına yürümek istiyordu. Görevlinin "
        },
        {
          "t": "kelime",
          "yuva": "hr166_rehberlik"
        },
        {
          "t": "metin",
          "v": " ettiği kısa bir tanıtımda dürbünle uzaktan izlemenin de ayrıntı görmeye yardımcı olduğu anlatıldı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " dinlenirken insanların davranışları daha düzenli hâle gelmişti. Böylece kuşları görmekle onların dinlenmesine saygı göstermek aynı anda mümkün olmuştu. Kıyıdaki sessiz çizgi, bir yasaktan çok karşılıklı özenin işaretiydi. Görevliler, kuşların yakından izlendiğinde sık sık yer değiştirmek zorunda kalabileceğini açıkladı. Ziyaretçiler dürbünlerini güvenli gözlem noktasından kullanmaya başladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sürünün eskisine göre daha az ürkerek dinlendiğini fark etti. Bu, insanlarla kuşlar arasında konuşulmadan kurulmuş bir anlaşma gibiydi. Herkes aynı alanı kullanıyor ama farklı ihtiyaçlara göre sınırlar belirleniyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Birkaç gün sonra sert bir rüzgâr başladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " uçuşa geçmek için uygun koşulları beklemeyi tercih etti. Sürüdeki bazı genç kuşlar hareketlenmişti. "
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
          "yedek": "Çınar"
        },
        {
          "t": "metin",
          "v": " kıyıda sakin durarak grubun birlikte kalmasına yardımcı oldu. Rüzgârın en sert estiği gün sürü, açık suyun kenarına fazla yaklaşmadı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " güvenli bir konumda kalmanın da yolculuk kararı olduğunu düşündü. Havanın düzelmesini beklerken yiyecek bulmak ve dinlenmek mümkündü. Genç kuşların hareketleri zamanla sakinleşti. Hep birlikte uçabilmek için herkesi göz önünde tutmak gerekiyordu. Uygun an gelmeden ayrılmak, uzun yolun sonraki bölümünü gereksiz yere zorlaştırabilirdi. Beklemek, yolculuğu bırakmak anlamına gelmiyordu. Tam tersine, "
        },
        {
          "t": "kelime",
          "yuva": "hr166_goc"
        },
        {
          "t": "metin",
          "v": " sırasında doğru zamanlamayla hareket etmek enerjinin dikkatli kullanılmasını sağlıyordu. Sulak alanın sessiz bölümünde yiyecek aradılar, tüylerini temizlediler ve dinlendiler. Gözlem yolundaki görevliler yaklaşmadan uzaktan not aldı. Bir sonraki gün hava sakinleşince sürünün uçuş için daha hazır olduğu görüldü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Şafak sökmeye başladığında "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " kanatlarını açtı. Sürü önce yavaşça yükseldi, ardından gökyüzünde uzun bir çizgi oluşturdu. Sulak alan geride kalırken kıyıdaki bekleme çizgisi ilk ışıkta uzaktan seçiliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " orada birkaç gün geçirmişti ama bu kısa konaklama, uzun yolculuğun önemli bir parçasıydı. Uçuş başladıktan sonra sulak alanın kıvrımları geride küçüldü. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " sürünün düzenini bozmayacak bir hızda ilerledi. Bir sonraki durakta hangi koşullarla karşılaşacaklarını bilmiyordu ama önceki konaklamadan önemli bir deneyim kazanmışlardı. Arkada kalan sessiz bölgenin gelecek sürüler için de korunması, bu yüzden değerliydi. Gökyüzünde uzanan çizgi başka bir durağa yöneldi. Gözlem yolundaki ziyaretçiler dürbünlerini indirip sürünün yükselişini uzaktan izledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önündeki açık gökyüzüne baktı. Sürü uzaklaşırken kıyı sessizliğini korudu."
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
      "metin": "Yeni yürüyüş yoluyla ilgili sorun neydi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Yolun tamamen su altında kalmış olması"
        },
        {
          "id": "B",
          "metin": "Yolun çok kısa olması"
        },
        {
          "id": "C",
          "metin": "Yolun kuşlara fazla yaklaşması"
        },
        {
          "id": "D",
          "metin": "Yolda hiç işaret bulunmaması"
        }
      ],
      "dogru": "C",
      "aciklama": "Metindeki \"Yollar insanlara doğayı izleme fırsatı veriyordu ama bazı noktalarda kuşların sakin kaldığı bölgeye fazla yaklaşılıyordu.\" cümlesi C seçeneğini doğrular. Yol su altında kalmamış, kısa olması sorun sayılmamış ve işaretsiz de değildi."
    },
    {
      "id": "s2",
      "beceri": "cikarim",
      "dayanak_sayfa": 2,
      "metin": "{kahraman} neden daha sakin koyu seçti?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Daha az ürkerek dinlenmek için"
        },
        {
          "id": "B",
          "metin": "Koydaki bütün taşları saymak için"
        },
        {
          "id": "C",
          "metin": "Yürüyüş yoluna yaklaşmak için"
        },
        {
          "id": "D",
          "metin": "Göçü tamamen bırakmak için"
        }
      ],
      "dogru": "A",
      "aciklama": "Metindeki \"{kahraman} sürünün daha sakin bir bölgeye yönelmesini işaret etti.\" cümlesinden önce günün ilerleyen saatlerinde insan seslerinin arttığı yazar; sakin koy bu yüzden seçildi. Taş saymak, yürüyüş yoluna yaklaşmak ve göçü bırakmak metinde amaç değildir."
    },
    {
      "id": "s3",
      "beceri": "sozcuk_baglami",
      "dayanak_sayfa": 4,
      "metin": "“Enerji” bu metinde hangi anlamda kullanılmıştır?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Gözlem yolundaki levhanın parlak boyası"
        },
        {
          "id": "B",
          "metin": "Uçuş ve hareket için gereken güç"
        },
        {
          "id": "C",
          "metin": "Sulak alandaki suyun tuz oranı"
        },
        {
          "id": "D",
          "metin": "Kuşların tüy rengi"
        }
      ],
      "dogru": "B",
      "aciklama": "Metindeki \"Tam tersine, göç sırasında doğru zamanlamayla hareket etmek enerjinin dikkatli kullanılmasını sağlıyordu.\" cümlesinde enerji, kuşun uçması ve hareket etmesi için gereken güçtür; metnin başında da uzun uçuşta harcanan enerjinin dinlenirken yeniden kazanılması gerektiği yazar. Levha boyası, suyun tuz oranı ve tüy rengi enerjiyle ilgili değildir."
    },
    {
      "id": "s4",
      "beceri": "yorumlama",
      "dayanak_sayfa": 4,
      "metin": "{kahraman} neden rüzgârın dinmesini bekledi?",
      "secenekler": [
        {
          "id": "A",
          "metin": "Göç yönünü zamanla unutmak için"
        },
        {
          "id": "B",
          "metin": "Kıyıyı değiştirmek için"
        },
        {
          "id": "C",
          "metin": "Sürüyü dağıtmak için"
        },
        {
          "id": "D",
          "metin": "Uygun koşulda uçmak için"
        }
      ],
      "dogru": "D",
      "aciklama": "Metindeki \"{kahraman} uçuşa geçmek için uygun koşulları beklemeyi tercih etti.\" cümlesi, turnanın sert rüzgârda uçmak yerine koşulların düzelmesini beklediğini gösterir. Yönü unutmak, kıyıyı değiştirmek ve sürüyü dağıtmak metinde yoktur; tersine sürünün birlikte kalmasına yardım edilmiştir."
    }
  ],
  "uretim": {
    "kaynak": "llm_taslak",
    "tarih": "2026-11-10"
  },
  "sozluk": {
    "sozluk_surumu": 1,
    "girdiler": [
      {
        "id": "hr166_goc",
        "tur": "kelime",
        "yazim": "göç",
        "anlam": "Canlıların mevsimlere bağlı olarak uzun yolculuklarla yer değiştirmesi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_goc_b",
        "tur": "kelime",
        "yazim": "yolculuk",
        "anlam": "Bir yerden başka bir yere uzun süreli gidiş.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_goc_c",
        "tur": "kelime",
        "yazim": "dönüş",
        "anlam": "Bir yolculuktan sonra yeniden yerine gelme.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_enerji",
        "tur": "kelime",
        "yazim": "enerji",
        "anlam": "Bir şeyin iş yapabilme gücü.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_enerji_b",
        "tur": "kelime",
        "yazim": "güç",
        "anlam": "Bir şeyi hareket ettirebilen etki.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_enerji_c",
        "tur": "kelime",
        "yazim": "yakıt",
        "anlam": "Enerji elde etmek için yakılan madde.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_suru",
        "tur": "kelime",
        "yazim": "sürü",
        "anlam": "Aynı türden hayvanların birlikte yaşayan topluluğu.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_suru_b",
        "tur": "kelime",
        "yazim": "topluluk",
        "anlam": "Birlikte yaşayan ya da hareket eden canlılar grubu.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_suru_c",
        "tur": "kelime",
        "yazim": "grup",
        "anlam": "Birlikte hareket eden insan ya da hayvanlar topluluğu.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_rehberlik",
        "tur": "kelime",
        "yazim": "rehberlik",
        "anlam": "Birine yol göstererek destek olma işi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_rehberlik_b",
        "tur": "kelime",
        "yazim": "yönlendirme",
        "anlam": "Bir kişiyi doğru yöne çevirme işi.",
        "sinif_alt": 7,
        "sinif_ust": 7
      },
      {
        "id": "hr166_rehberlik_c",
        "tur": "kelime",
        "yazim": "danışmanlık",
        "anlam": "Bir konuda bilgi ve öneri verme hizmeti.",
        "sinif_alt": 7,
        "sinif_ust": 7
      }
    ],
    "yuvalar": [
      {
        "ad": "hr166_goc",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr166_goc"
          },
          {
            "girdi": "hr166_goc_b"
          },
          {
            "girdi": "hr166_goc_c"
          }
        ]
      },
      {
        "ad": "hr166_enerji",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr166_enerji"
          },
          {
            "girdi": "hr166_enerji_b"
          },
          {
            "girdi": "hr166_enerji_c"
          }
        ]
      },
      {
        "ad": "hr166_suru",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr166_suru"
          },
          {
            "girdi": "hr166_suru_b"
          },
          {
            "girdi": "hr166_suru_c"
          }
        ]
      },
      {
        "ad": "hr166_rehberlik",
        "tur": "kelime",
        "adaylar": [
          {
            "girdi": "hr166_rehberlik"
          },
          {
            "girdi": "hr166_rehberlik_b"
          },
          {
            "girdi": "hr166_rehberlik_c"
          }
        ]
      }
    ]
  }
}$json$::jsonb, 'pending', 'pending', true); end $m$;

drop function public._tmp_okuma_denetim_iceri_al(jsonb, text, text, boolean);

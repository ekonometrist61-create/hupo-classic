-- =====================================================================
-- Okuma Dünyası — 2. sınıf pilot güncellemesi: 4 atasözü, yeni türler, güncel okuma süresi (9 hikâye, yeni sürüm).
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
                         "id":  "s2_dikkatle",
                         "tur":  "kelime",
                         "yazim":  "dikkatle",
                         "anlam":  "Özen göstererek, işini iyi yaparak.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_uzak",
                         "tur":  "kelime",
                         "yazim":  "uzak",
                         "anlam":  "Yakın olmayan, bir yere çok ileride olan.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_yukari",
                         "tur":  "kelime",
                         "yazim":  "yukarı",
                         "anlam":  "Daha yüksek bir yöne doğru.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_harita",
                         "tur":  "kelime",
                         "yazim":  "harita",
                         "anlam":  "Bir yeri, yolları ve önemli yerleri gösteren çizim.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_yuvarlak",
                         "tur":  "kelime",
                         "yazim":  "yuvarlak",
                         "anlam":  "Köşesi olmayan, daire gibi olan.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_kosel",
                         "tur":  "kelime",
                         "yazim":  "köşeli",
                         "anlam":  "Köşesi olan, düz kenarları bulunan.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_erken",
                         "tur":  "kelime",
                         "yazim":  "erken",
                         "anlam":  "Vaktinden önce olan, normalden önce gelen.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_gec",
                         "tur":  "kelime",
                         "yazim":  "geç",
                         "anlam":  "Vakti geçmiş, normalden sonra olan.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_tahmin",
                         "tur":  "kelime",
                         "yazim":  "tahmin",
                         "anlam":  "Bir şeyin ne olabileceğini düşünerek söyleme.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_gozlem",
                         "tur":  "kelime",
                         "yazim":  "gözlem",
                         "anlam":  "Bir şeyi dikkatle izleyip inceleme.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_emek",
                         "tur":  "kelime",
                         "yazim":  "emek",
                         "anlam":  "Bir iş için harcanan çaba ve zaman.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_harclik",
                         "tur":  "kelime",
                         "yazim":  "harçlık",
                         "anlam":  "Çocuğa verilen küçük miktarda para.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_hizli",
                         "tur":  "kelime",
                         "yazim":  "hızlı",
                         "anlam":  "Çabuk hareket eden, kısa sürede giden.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_yavas",
                         "tur":  "kelime",
                         "yazim":  "yavaş",
                         "anlam":  "Hızı az olan, ağır ağır giden.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_guclu",
                         "tur":  "kelime",
                         "yazim":  "güçlü",
                         "anlam":  "Kuvvetli, çok güç harcayabilen.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_kucuk",
                         "tur":  "kelime",
                         "yazim":  "küçük",
                         "anlam":  "Boyutu ya da miktarı az olan.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_dar",
                         "tur":  "kelime",
                         "yazim":  "dar",
                         "anlam":  "Genişliği az olan, sıkışık.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_genis",
                         "tur":  "kelime",
                         "yazim":  "geniş",
                         "anlam":  "Genişliği çok olan, rahat.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_bilmece",
                         "tur":  "kelime",
                         "yazim":  "bilmece",
                         "anlam":  "Bir sorunun cevabını bulmaya dayanan kısa soru.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_cevap",
                         "tur":  "kelime",
                         "yazim":  "cevap",
                         "anlam":  "Bir soruya verilen karşılık.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_cekingen",
                         "tur":  "kelime",
                         "yazim":  "çekingen",
                         "anlam":  "Utangaç, kendini hemen göstermeyen.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_cesur",
                         "tur":  "kelime",
                         "yazim":  "cesur",
                         "anlam":  "Korkmadan iş yapabilen.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_saglam",
                         "tur":  "kelime",
                         "yazim":  "sağlam",
                         "anlam":  "Kolay bozulmayan, dayanıklı.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_onarim",
                         "tur":  "kelime",
                         "yazim":  "onarım",
                         "anlam":  "Bozulmuş bir şeyi yeniden düzeltme.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_buhar",
                         "tur":  "kelime",
                         "yazim":  "buhar",
                         "anlam":  "Isınınca havaya karışan, görünmeyen su hâli.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_damla",
                         "tur":  "kelime",
                         "yazim":  "damla",
                         "anlam":  "Çok küçük, yuvarlak bir su tanesi.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_uzun",
                         "tur":  "kelime",
                         "yazim":  "uzun",
                         "anlam":  "Boyu ya da süresi çok olan.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_kisa",
                         "tur":  "kelime",
                         "yazim":  "kısa",
                         "anlam":  "Boyu ya da süresi az olan.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_eski",
                         "tur":  "kelime",
                         "yazim":  "eski",
                         "anlam":  "Çok önce yapılmış ya da kullanılmış olan.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "s2_yeni",
                         "tur":  "kelime",
                         "yazim":  "yeni",
                         "anlam":  "Yakın zamanda yapılmış, az kullanılmış olan.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_komsu",
                         "tur":  "atasozu",
                         "yazim":  "Komşu komşunun külüne muhtaçtır",
                         "anlam":  "Komşuya her zaman ihtiyaç duyulur; komşular birbirine yardım eder.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_dost_aci",
                         "tur":  "atasozu",
                         "yazim":  "Dost acı söyler",
                         "anlam":  "Gerçek dost, bazen acı da olsa doğruyu söyler.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_emek",
                         "tur":  "atasozu",
                         "yazim":  "Emek olmadan yemek olmaz",
                         "anlam":  "Bir şeyi elde etmek için çalışmak gerekir.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_sabir",
                         "tur":  "atasozu",
                         "yazim":  "Sabreden derviş muradına ermiş",
                         "anlam":  "Sabırla bekleyen, istediğine sonunda kavuşur.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_iyilik",
                         "tur":  "atasozu",
                         "yazim":  "İyilik eden iyilik bulur",
                         "anlam":  "İyilik yapan kişi, bir gün karşılığını bulur.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_birlik",
                         "tur":  "atasozu",
                         "yazim":  "Birlikten kuvvet doğar",
                         "anlam":  "Birlikte çalışan insanlar daha çok iş başarır.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_damla",
                         "tur":  "atasozu",
                         "yazim":  "Damlaya damlaya göl olur",
                         "anlam":  "Küçük birikimler zamanla büyük bir şey olur.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_acele",
                         "tur":  "atasozu",
                         "yazim":  "Acele işe şeytan karışır",
                         "anlam":  "Aceleyle yapılan iş genellikle hataya açıktır.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_elin_nesi",
                         "tur":  "atasozu",
                         "yazim":  "Bir elin nesi var, iki elin sesi var",
                         "anlam":  "Tek kişinin gücü sınırlıdır; birlikte daha çok şey yapılır.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_parlayan",
                         "tur":  "atasozu",
                         "yazim":  "Her parlayan altın değildir",
                         "anlam":  "Dışarıdan güzel görünen her şey değerli ya da doğru değildir.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_sormakla",
                         "tur":  "atasozu",
                         "yazim":  "Sormakla yol bulunur",
                         "anlam":  "Bilmediğimiz şeyi sorarak öğrenir, çözüm buluruz.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_iyilik_yap",
                         "tur":  "atasozu",
                         "yazim":  "İyilik yap denize at, balık bilmezse Halik bilir",
                         "anlam":  "İyiliği karşılık beklemeden yapmak gerekir; kimse görmese de değeri kaybolmaz.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     },
                     {
                         "id":  "ata_derin_su",
                         "tur":  "atasozu",
                         "yazim":  "Derin su sessiz akar",
                         "anlam":  "Bilgili ve olgun insanlar çoğu zaman az konuşur, gösteriş yapmaz.",
                         "sinif_alt":  2,
                         "sinif_ust":  2,
                         "kaynak_turu":  "editor_onerisi",
                         "kazanim_kodu":  null,
                         "durum":  "taslak"
                     }
                 ],
    "kavramlar":  [

                  ],
    "yuvalar":  [
                    {
                        "ad":  "s2_dikkatle",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_dikkatle"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_uzak",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_uzak"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_yukari",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_yukari"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_harita",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_harita"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_yuvarlak",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_yuvarlak"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_kosel",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_kosel"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_erken",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_erken"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_gec",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_gec"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_tahmin",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_tahmin"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_gozlem",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_gozlem"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_emek",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_emek"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_harclik",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_harclik"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_hizli",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_hizli"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_yavas",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_yavas"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_guclu",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_guclu"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_kucuk",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_kucuk"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_dar",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_dar"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_genis",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_genis"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_bilmece",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_bilmece"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_cevap",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_cevap"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_cekingen",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_cekingen"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_cesur",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_cesur"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_saglam",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_saglam"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_onarim",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_onarim"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_buhar",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_buhar"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_damla",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_damla"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_uzun",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_uzun"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_kisa",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_kisa"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_eski",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_eski"
                                        }
                                    ]
                    },
                    {
                        "ad":  "s2_yeni",
                        "tur":  "kelime",
                        "adaylar":  [
                                        {
                                            "girdi":  "s2_yeni"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_komsu",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_komsu"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_dost_aci",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_dost_aci"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_emek",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_emek"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_sabir",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_sabir"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_iyilik",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_iyilik"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_birlik",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_birlik"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_damla",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_damla"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_acele",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_acele"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_elin_nesi",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_elin_nesi"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_parlayan",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_parlayan"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_sormakla",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_sormakla"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_iyilik_yap",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_iyilik_yap"
                                        }
                                    ]
                    },
                    {
                        "ad":  "ata_derin_su",
                        "tur":  "atasozu",
                        "adaylar":  [
                                        {
                                            "girdi":  "ata_derin_su"
                                        }
                                    ]
                    }
                ]
}$z01$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'sozluk 1: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p01${
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
        "kelime_sayisi": 229,
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
          "v": " ve serttir. Çorap yumuşaktır.\" Bu kez mavi defteri getirdi. \"Defter düz ve "
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
          "v": "\". Robot odanın köşesinden mavi bir oyuncak araba getirdi. Zeynep gülmekten sandalyeye oturdu. "
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
          "v": "Oyunu biraz zorlaştırdılar. Masaya bir çorap, bir kitap ve bir top koydular. \"Yalnız renge değil, biçime ve ne işe yaradığına da bak,\" dedi "
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
          "v": " ciddi bir sesle. Herkes güldü. O günden sonra bir şeyin ne olduğunu anlamadan önce iki kez bakmaya karar verdi. Ertesi gün mutfakta bir limon gördü. \"Sarı top!\" diye bağıracaktı ama durup kokladı. \"Hayır, bu limon.\""
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
    "tarih": "2026-10-21"
  }
}$p01$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr003-corabini-arayan-robot: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p02${
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
        "simge_sayisi": 1
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
          "v": "Çocuklardan biri gözlerini açtı: \"Koca göl yoğurt olur mu?\" Hoca gülümsedi: \"Olmayabilir. Peki bir şeyin olup olmayacağını nasıl anlarız?\" Kimi \"Kesin olmaz,\" dedi, kimi \"Belki,\" diye fısıldadı. Çocuklar birer "
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
          "v": "Sazlıkta bir kurbağa suya atlayınca halkalar oluştu. \"Hocam, maya suya yayılırsa kurbağaya bir şey olur mu?\" diye sordu en küçük çocuk. Hoca kabı kenara koydu. \"Bir şeyi merak ederken doğayı da düşünmeliyiz.\" Çocuklar göle hiçbir şey dökmemeye karar verdi."
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
          "v": " eve gidince ailesine gördüklerini anlattı. \"Her tahmin doğru olmayabilir,\" dedi, \"ama sormaktan vazgeçmemeliyiz.\" Annesi gülümsedi: \""
        },
        {
          "t": "atasozu",
          "yuva": "ata_sormakla"
        },
        {
          "t": "metin",
          "v": "\". Babası ona bir defter verdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " defterin kapağına \"Merak Kutum\" yazdı."
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
    "tarih": "2026-10-21"
  }
}$p02$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr005-hocanin-golundeki-umut: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p03${
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
        "simge_sayisi": 1
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
          "v": "Yarıştan önce orman hayvanları yeni bir kural koydu: Kimse öteki yarışmacıyla alay etmeyecekti. Tavşan kuralı duyunca biraz utandı. Karşısına geçip \"Bugün elimden geleni yapacağım,\" dedi. "
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
          "v": " ama düzenli adımlarla ilerledi. Tavşan biraz ileride bir kirpinin yardım istediğini duyunca durdu."
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
          "v": " acele etmeden sağlam taşları seçti. İki yarışmacı da farklı hızlarda doğru kararlar veriyordu. "
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
          "v": "Yolun ortasında Kirpi bir yaprağı yuvasına taşıyordu. Yaprak bir kayanın altına sıkışmıştı. Tavşan tek başına çekmeyi denedi. "
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
          "v": "Finişe yan yana geldiler. Orman bekçisi kazananı hemen söylemedi: \"Bugün iki farklı başarı gördüm. Biri hızını iyi kullandı, diğeri düzenli ilerledi. Üstelik yarış sırasında yardımı unutmadınız.\" "
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
          "v": "İkisi, farklı hızlarda yürümenin arkadaş olmaya engel olmadığını anladı. Orman bekçisi herkese su ikram etti. Tavşan, "
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
    "tarih": "2026-10-21"
  }
}$p03$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr007-kaplumbaga-ve-tavsan: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p04${
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
        "simge_sayisi": 1
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
          "v": " ormanda yardım isteyen bir ses duydu. Aslan, avcıların bıraktığı eski bir ağa takılmıştı. Ağın iplerini çekse de kurtulamıyordu."
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
          "v": " acele etmedi. \"Yavaş yapabilirim,\" dedi, \"ama dikkatli olacağım.\" Önce düğümlerin yerini buldu, sonra en gevşek ipten başladı. Dişleriyle gevşemiş ipleri kemirdi. Aslan pençelerini oynatmadan bekledi. "
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
          "v": " olduğum için her şeyi yapabileceğimi sanırdım,\" dedi. Fare gülümsedi: \"Ben de küçük olduğum için yapamayacağım şeyler olduğunu sanırdım.\" İkisi su kenarında oturup dinlendi. Aslan, \""
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
          "v": " yorgun görünce serin bir yaprakla gölge yaptı. İkisi birlikte dereye doğru yürüdü. O gün ormanda güçten başka önemli bir şey konuşuldu: birinin ihtiyacını anlayabilmek."
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
    "tarih": "2026-10-21"
  }
}$p04$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr008-aslan-ve-fare: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p05${
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
          "t": "metin",
          "v": "Eylül çantasını açınca kalem kutusundan sesler geldi. \"Bana yer kalmadı!\" diye bağırıyordu silgi. Cetvel ise \"Hepiniz yamuk duruyorsunuz,\" diye söyleniyordu. Kurşun kalem sivri ucunu koruyamamaktan yakınıyordu."
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
    "tarih": "2026-10-21"
  }
}$p05$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr009-konusan-kalem-kutusu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p06${
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
        "kelime_sayisi": 241,
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
        "simge_sayisi": 1
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
          "v": " önce ekmek düşündü. Ama ekmek paylaşıldıkça azalırdı. Sonra suyu düşündü. Su da azalıyordu."
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
          "v": " elini çenesine koydu. Bir kişi şarkı söylemeye başlayınca başkaları da katılabilirdi. \"Belki neşedir,\" dedi. Taş sessiz kaldı. "
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
          "v": " da kısa yolu hatırladı ve yardım etti."
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
          "v": " birden güldü. \"Sevinç!\" dedi. \"Birine yardım edince onun sevinci bana da geçiyor. Paylaşınca çoğalıyor.\" Taştaki çizgiler parladı. Taş, toprağa yan yatmış eski bir yol levhasının üstündeydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " levhayı yerine dikti. Köylüler artık yolda daha kolay yön buldu."
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
    "tarih": "2026-10-21"
  }
}$p06$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr010-kelogan-ve-konusan-tas: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p07${
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
        "kelime_sayisi": 210,
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
          "v": ". Kâğıda yollar çizdi: \"Burada kitapçı var, burada iki ağaç, burada küçük bir meydan.\" Arkadaşları dinledikçe haritalar gerçekçileşti. "
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
          "v": "Ece \"Bunu nasıl bu kadar güzel yaptın?\" diye sordu. "
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
          "v": "Öğretmen sonraki hafta yeni bir harita görevi verdi. Bu kez "
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
    "tarih": "2026-10-21"
  }
}$p07$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr012-yeni-arkadasin-gizli-yetenegi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p08${
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
        "kelime_sayisi": 237,
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
        "simge_sayisi": 1
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
          "v": " kırılan parçalara bakarken çok üzgündü; dün akşam onu yapmak için uğraşmıştı. Mert ise uzun süre bir köprü hayali kurduğunu anlattı. Öğretmen \"Şimdi birbirinizi dinleyin,\" dedi. "
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
          "v": " küçük bir köprü resmi çizerek fikirlerini göstermelerine yardım etti."
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
          "v": " her denemeyi bir çizelgeye işaretledi. Birbirlerini suçlamadıklarında daha çabuk çözüm bulduklarını fark ettiler. Kalın kartondan dört ayak yaptılar ve üstüne iki kat yol koydular."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Köprü, en büyük kamyon konunca hafifçe eğildi ama yıkılmadı. \"Bu kez oldu!\" diye sevindiler. Öğretmen, sorun çıktığında suçlu aramak yerine nedenini araştırmalarına sevindi. Bu "
        },
        {
          "t": "kelime",
          "yuva": "s2_onarim"
        },
        {
          "t": "metin",
          "v": " işini birlikte yaptılar. Mert gülerek \""
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
          "v": " gülümsedi. Yarış başladığında oyuncak kamyon köprünün üstünden yavaşça geçti. Köprü sallanmadı. "
        },
        {
          "t": "isaret",
          "kod": "yildiz"
        },
        {
          "t": "metin",
          "v": " Mert küçük bir bayrak kaldırdı. İkisi birbirine bakıp güldü. Bu kez yalnızca köprüyü değil, birlikte çözüm bulmayı da başarmışlardı."
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
    "tarih": "2026-10-21"
  }
}$p08$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr013-kirilan-oyuncak-kopru: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p09${
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
        "simge_sayisi": 1
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
          "v": " ve parlaktı. \"Önce bisikletin nasıl göründüğüne değil, güvenli olup olmadığına bakalım,\" dedi babası. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " de frenleri denemeye yardım etti. Kaskın tam oturduğundan emin oldular."
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
          "v": "Görevli zincirin düzeltilmesine yardım etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " babasıyla birlikte kenarda beklerken Mert son anda yarışa yetişti. İkisi yan yana başladı. Mahallede \""
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
          "v": " eski bisikletinin gidonuna küçük bir yıldız çıkartması yapıştırdı. O yıldız ona hızdan çok arkadaşlığı hatırlatıyordu. "
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
    "tarih": "2026-10-21"
  }
}$p09$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr017-mahallenin-en-hizli-bisikleti: %', v_r; end if;

end
$pilot$;

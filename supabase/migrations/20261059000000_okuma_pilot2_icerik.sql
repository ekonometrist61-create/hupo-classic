-- =====================================================================
-- Okuma Dünyası — 2. sınıf pilot (15 hikâye): sözlük, 15 fiş ve taslak paketler.
--   * Yönetici olarak çalışan ilk admin profilinin kimliğiyle içe aktarır (require_admin).
--   * Hikâyeler taslak girer (durum taslak, denetim pending); yayın ayrı bir karardır.
--   * Fiş tablosu HR-001…HR-017 pilot fişlerini alır ve hikaye_slug ile hikâyelere bağlanır.
--   * Her adım sonuç kontrolü yapar; bir hata olursa işlemin tamamı geri alınır.
-- =====================================================================

set client_encoding = 'UTF8';

do $pilot$
declare
  v_admin uuid;
  v_r     jsonb;
begin
  select id into v_admin from public.profiles where role = 'admin' order by id limit 1;
  if v_admin is null then
    raise exception 'pilot içe aktarma: yönetici profil bulunamadı';
  end if;
  perform set_config('request.jwt.claims', json_build_object('sub', v_admin, 'role', 'authenticated')::text, true);

  v_r := public.okuma_sozluk_ice_aktar($sozluk${
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
                    }
                ]
}$sozluk$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot sozluk: %', v_r; end if;

  v_r := public.okuma_fis_ice_aktar($fis$[
    {
        "fis_kodu":  "HR-001",
        "baslik":  "Kayıp Çanın İzinde",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Macera",
        "kurgu_cekirdegi":  "Okul bahçesindeki küçük çan kaybolur; Ela ve Hupo sesleri izler, çanın rüzgârla ağaca takıldığını bulur ve güvenle indirir.",
        "soz_varligi":  "ses-sessiz, yakın-uzak; olay sıralama",
        "bilgi_beceri_deger":  "Sesin kaynağı; iş birliği",
        "ikon_onerileri":  [
                               "çan",
                               "kulak",
                               "ağaç"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-002",
        "baslik":  "Renkli Uçurtmanın Peşinde",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Macera",
        "kurgu_cekirdegi":  "Rüzgârın sürüklediği uçurtma üç sokağa uğrar; Ali mahalle haritası çizerek onu sahibine ulaştırır.",
        "soz_varligi":  "yukarı-aşağı; yön bildiren sözcükler",
        "bilgi_beceri_deger":  "Yönler, rüzgâr ve yardımlaşma",
        "ikon_onerileri":  [
                               "uçurtma",
                               "pusula",
                               "rüzgâr"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-003",
        "baslik":  "Çorabını Arayan Robot",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Mizah",
        "kurgu_cekirdegi":  "Ev robotu her mavi nesneyi çorap sanar; çocuklar ona renk ve biçim ayırt etmeyi öğretir.",
        "soz_varligi":  "mavi, yuvarlak, köşeli; sesteş: yüz (sayı/surat) — sınıf uygunluğu editörce kontrol edilecek",
        "bilgi_beceri_deger":  "Sınıflandırma; hata yaparak öğrenme",
        "ikon_onerileri":  [
                               "robot",
                               "çorap",
                               "büyüteç"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-004",
        "baslik":  "Ters Gün Okulda",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Mizah",
        "kurgu_cekirdegi":  "Şaka gününde bazı tabelalar ters asılır; sınıf, yanlış anlaşılmaları gülerek ve dikkatle düzeltir.",
        "soz_varligi":  "zıt anlam: erken-geç, açık-kapalı",
        "bilgi_beceri_deger":  "Kurallar; iletişim",
        "ikon_onerileri":  [
                               "tabela",
                               "kahkaha",
                               "ok"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-005",
        "baslik":  "Hoca\u0027nın Gölündeki Umut",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Mizah",
        "kurgu_cekirdegi":  "Nasreddin Hoca\u0027nın göle maya çalma anlatısı çocukların küçük fikirlerinin nasıl denenebileceği üzerinden özgün diyaloglarla yeniden kurulur.",
        "soz_varligi":  "olur-olmaz; ihtimal, tahmin",
        "bilgi_beceri_deger":  "Deneme ve gözlem; umut",
        "ikon_onerileri":  [
                               "göl",
                               "yoğurt kabı",
                               "soru"
                           ],
        "telif_sinifi":  "A",
        "kaynak_sinifi":  "Nasreddin Hoca fıkra geleneği",
        "telif_notu":  "Geleneksel/anonim anlatı çekirdeğinden yeniden kurgu"
    },
    {
        "fis_kodu":  "HR-006",
        "baslik":  "Düdük Kimin Olacak?",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Mizah",
        "kurgu_cekirdegi":  "Düdük isteyen çocuklar hazırlık yapınca Hoca emek vermenin değerini esprili bir olayla gösterir.",
        "soz_varligi":  "emek, karşılık; atasözüyle anlam",
        "bilgi_beceri_deger":  "Sorumluluk; adalet",
        "ikon_onerileri":  [
                               "düdük",
                               "kese",
                               "tebessüm"
                           ],
        "telif_sinifi":  "A",
        "kaynak_sinifi":  "Nasreddin Hoca fıkra geleneği",
        "telif_notu":  "Geleneksel/anonim anlatı çekirdeğinden yeniden kurgu"
    },
    {
        "fis_kodu":  "HR-007",
        "baslik":  "Kaplumbağa ile Tavşanın Yeni Yarışı",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Hayvanlar",
        "kurgu_cekirdegi":  "Klasik yarış çekirdeği, rakibi küçümsememeyi ve farklı hızlarla ilerlemeyi öne çıkaran özgün bir anlatımla aktarılır.",
        "soz_varligi":  "hızlı-yavaş; sabır",
        "bilgi_beceri_deger":  "Düzenli çaba; saygı",
        "ikon_onerileri":  [
                               "tavşan",
                               "kaplumbağa",
                               "finiş"
                           ],
        "telif_sinifi":  "K",
        "kaynak_sinifi":  "Ezop\u0027a atfedilen klasik fabl",
        "telif_notu":  "Kamu malı klasik metin temel alınarak özgün uyarlama adayı"
    },
    {
        "fis_kodu":  "HR-008",
        "baslik":  "Aslan ile Farenin Yardımı",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Hayvanlar",
        "kurgu_cekirdegi":  "Küçük fare zor durumda kalan aslana yardım eder; iki hayvan gücün yalnızca büyüklük olmadığını anlar.",
        "soz_varligi":  "büyük-küçük; iyilik",
        "bilgi_beceri_deger":  "Empati ve karşılıklılık",
        "ikon_onerileri":  [
                               "aslan",
                               "fare",
                               "ağ"
                           ],
        "telif_sinifi":  "K",
        "kaynak_sinifi":  "Ezop\u0027a atfedilen klasik fabl",
        "telif_notu":  "Kamu malı klasik metin temel alınarak özgün uyarlama adayı"
    },
    {
        "fis_kodu":  "HR-009",
        "baslik":  "Konuşan Kalem Kutusu",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Arkadaşlık",
        "kurgu_cekirdegi":  "Bir kalem kutusu içindeki eşyalar yer konusunda tartışır; Eylül hepsine uygun bölme tasarlayarak barıştırır.",
        "soz_varligi":  "dar-geniş; düzen ve sıralama",
        "bilgi_beceri_deger":  "Organizasyon; iş birliği",
        "ikon_onerileri":  [
                               "kalem",
                               "kutu",
                               "yıldız"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-010",
        "baslik":  "Keloğlan ve Konuşan Taş",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Macera",
        "kurgu_cekirdegi":  "Keloğlan yolda bilmece soran taşla karşılaşır; acele yanıt yerine dikkatle dinleyerek köyün kayıp işaretini bulur.",
        "soz_varligi":  "bilmece; akıllı-düşüncesiz",
        "bilgi_beceri_deger":  "Dinleme ve akıl yürütme",
        "ikon_onerileri":  [
                               "taş",
                               "yol",
                               "bilmece"
                           ],
        "telif_sinifi":  "A",
        "kaynak_sinifi":  "Keloğlan halk masalı motifi",
        "telif_notu":  "Geleneksel/anonim anlatı çekirdeğinden yeniden kurgu"
    },
    {
        "fis_kodu":  "HR-012",
        "baslik":  "Yeni Arkadaşın Gizli Yeteneği",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Arkadaşlık",
        "kurgu_cekirdegi":  "Sınıfa yeni gelen çocuk sessizdir; grup çalışmasında çizdiği harita sayesinde herkes onu tanır.",
        "soz_varligi":  "çekingen-cesur; duygu sözcükleri",
        "bilgi_beceri_deger":  "Kapsayıcılık ve saygı",
        "ikon_onerileri":  [
                               "arkadaşlar",
                               "harita",
                               "kalp"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-013",
        "baslik":  "Kırılan Oyuncak Köprü",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Arkadaşlık",
        "kurgu_cekirdegi":  "Oyun sırasında köprü kırılır; çocuklar suçlamak yerine birlikte yeni ve sağlam bir köprü yapar.",
        "soz_varligi":  "onarım, kırık-sağlam",
        "bilgi_beceri_deger":  "Basit yapı tasarımı; uzlaşma",
        "ikon_onerileri":  [
                               "köprü",
                               "oyuncak",
                               "bant"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-014",
        "baslik":  "Yağmur Damlasının Yolculuğu",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Bilim/Doğa",
        "kurgu_cekirdegi":  "Bir damlanın buluttan toprağa ve yeniden havaya yolculuğunu Hupo gözlem defterine kaydeder.",
        "soz_varligi":  "buhar, damla; döngü",
        "bilgi_beceri_deger":  "Su döngüsü",
        "ikon_onerileri":  [
                               "damla",
                               "bulut",
                               "güneş"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-016",
        "baslik":  "Gölgeyi Kim Büyüttü?",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Bilim/Doğa",
        "kurgu_cekirdegi":  "Sokakta gölgesinin değiştiğini fark eden Mert, güneşin konumuna göre gölge boyunun değiştiğini keşfeder.",
        "soz_varligi":  "uzun-kısa; sabah-akşam",
        "bilgi_beceri_deger":  "Işık ve gölge",
        "ikon_onerileri":  [
                               "gölge",
                               "güneş",
                               "cetvel"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    },
    {
        "fis_kodu":  "HR-017",
        "baslik":  "Mahallenin En Hızlı Bisikleti",
        "sinif":  2,
        "sinif_bandi":  "2-4",
        "tur":  "Spor",
        "kurgu_cekirdegi":  "Ayşe eski bisikletiyle yarışa hazırlanırken bir arkadaşına yardım eder; finişten önce dayanışmanın değerini keşfeder.",
        "soz_varligi":  "eski-yeni, hızlı-yavaş; bir elin nesi var",
        "bilgi_beceri_deger":  "Denge, emek ve yardımlaşma",
        "ikon_onerileri":  [
                               "bisiklet",
                               "bayrak",
                               "yıldız"
                           ],
        "telif_sinifi":  "O",
        "kaynak_sinifi":  "HupoRead özgün",
        "telif_notu":  "HupoRead özgün kurgu"
    }
]$fis$::jsonb, false);
  if (v_r ->> 'ok') is distinct from 'true' then raise exception 'pilot fis: %', v_r; end if;

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
        "simge_sayisi": 1
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
          "v": " sabah zilini beklerken şaşırdı. \"Çan nereye gitti?\" diye sordu. "
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
          "v": "Tam o sırada okulun bahçesinde bir kuş öttü. "
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
          "v": " gözlerini kapadı. Ses sol taraftan geliyordu. Önlerinde üç ağaç vardı. İlk ağacın dallarında yalnızca yapraklar sallanıyordu. İkinci ağacın altında bir kedi uyuyordu. Üçüncü ağacın en alt dalında ise bir ip parçası sarkıyordu."
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
          "v": " başını salladı. Çan yeniden yerine asıldı. O gün ders zili her zamankinden güzel çaldı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi sabah "
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
    "tarih": "2026-10-21"
  }
}$p01$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr001-kayip-canin-izinde: %', v_r; end if;
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
          "hal": "yalin"
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
    "tarih": "2026-10-21"
  }
}$p02$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr002-renkli-ucurtma: %', v_r; end if;
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
        "kelime_sayisi": 218,
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
          "v": " ışıklarını yakıp söndürdü. \"Mavi. O hâlde çorap olmalı!\" \"Mendil de mavi olabilir. Renk tek başına yetmez,\" dedi Zeynep. Robot odanın köşesinden mavi bir oyuncak araba getirdi. Zeynep gülmekten sandalyeye oturdu. "
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
}$p03$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr003-corabini-arayan-robot: %', v_r; end if;
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
        "simge_sayisi": 1
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
          "v": " de bunu kabul etti: şaka herkes için komik olmayabilir. Bir arkadaşın doğru uyarısı için \""
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
          "v": "Sınıf tahtasına \"BUGÜN YARIN\" yazılmıştı. Öğretmen çocuklardan ters anlamlı sözcükler bulmalarını istedi. Bir çift de "
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
          "v": " oldu. Zeynep \"Gece ve gündüz!\" dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " \"Temiz ve kirli!\" diye ekledi. Her çift için doğru anlamı gösteren küçük bir resim çizdiler."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Gerçek yön levhaları yerinde kaldı. Oyun için ayrı bir pano yaptılar ve üstüne \"ŞAKA KÖŞESİ\" yazdılar. Orada \"ÇOK UZUN KISA CETVEL\" gibi komik ifadeler vardı. Herkes bunun bir oyun olduğunu anlayabiliyordu. Melis, şaka için başkalarını zor durumda bırakmaya gerek olmadığını kabul etti. "
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
          "v": " elini kaldırdı. \"Kahkaha sesli olur. Sessiz kahkaha nasıl olur?\" Hep birlikte ağızlarını açıp ses çıkarmadan gülmeye çalıştılar. Tabelanın sahibi Melis'ti. Özür diledi ve öğretmeninin yardımıyla şaka köşesini düzenledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Günün sonunda Melis duvarın en üstüne küçük bir not ekledi: \"Oyun ayrı, gerçek işaretler ayrı.\" "
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
    "tarih": "2026-10-21"
  }
}$p04$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr004-ters-gun-okulda: %', v_r; end if;
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
          "concept": 1
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
          "v": " eve gidince ailesine gördüklerini anlattı. \"Her tahmin doğru olmayabilir,\" dedi, \"ama sormaktan vazgeçmemeliyiz.\" Babası ona bir defter verdi. "
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
}$p05$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr005-hocanin-golundeki-umut: %', v_r; end if;
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
        "simge_sayisi": 1
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
          "v": "Hoca parayı alıp dikkatle baktı. \"Bu parayı neden biriktirdin?\" "
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
          "v": "Hoca, \"Düdük istediğinizi biliyorum,\" dedi. \"Ama nasıl alınacağını konuşmamıştık. Yarın birlikte bir iş bulup biriktirelim.\" Ertesi gün çocuklar evde kullanılmayan düdükleri tamir etti. Mahalledeki büyükler küçük bir şenlik hazırlamalarına yardım etti. "
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
          "v": "Düdük sesleri mahalleye yayılınca Hoca elini kaldırdı: \"Bir işte hem sabır hem düzen önemli.\" Çocuklar sırayla çalabilecekleri küçük bir oyun kurdu. Düdükler artık birbirine karışmıyordu. "
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
          "v": " o akşam, \"Beklemek de öğrenmekmiş,\" dedi."
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
    "tarih": "2026-10-21"
  }
}$p06$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr006-dudek-kimin-olacak: %', v_r; end if;
  v_r := public.okuma_paket_ice_aktar($p07${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr007-kaplumbaga-ve-tavsan",
    "baslik": "Kaplumbağa ile Tavşanın Yeni Yarışı",
    "tur": "macera",
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
}$p07$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr007-kaplumbaga-ve-tavsan: %', v_r; end if;
  v_r := public.okuma_paket_ice_aktar($p08${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr008-aslan-ve-fare",
    "baslik": "Aslan ile Farenin Yardımı",
    "tur": "macera",
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
}$p08$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr008-aslan-ve-fare: %', v_r; end if;
  v_r := public.okuma_paket_ice_aktar($p09${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr009-konusan-kalem-kutusu",
    "baslik": "Konuşan Kalem Kutusu",
    "tur": "mizah",
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
}$p09$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr009-konusan-kalem-kutusu: %', v_r; end if;
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
          "v": " sepeti taşımaya devam etti. Kadın rahatlayınca yüzü aydınlandı. Çarşıya vardıklarında kadın teşekkür etti ve gideceği yeri tarif etti. "
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
}$p10$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr010-kelogan-ve-konusan-tas: %', v_r; end if;
  v_r := public.okuma_paket_ice_aktar($p11${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr012-yeni-arkadasin-gizli-yetenegi",
    "baslik": "Yeni Arkadaşın Gizli Yeteneği",
    "tur": "macera",
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
        "kelime_sayisi": 201,
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
          "v": " buldu,\" dedi. "
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
}$p11$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr012-yeni-arkadasin-gizli-yetenegi: %', v_r; end if;
  v_r := public.okuma_paket_ice_aktar($p12${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr013-kirilan-oyuncak-kopru",
    "baslik": "Kırılan Oyuncak Köprü",
    "tur": "macera",
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
}$p12$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr013-kirilan-oyuncak-kopru: %', v_r; end if;
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
        "kelime_sayisi": 204,
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
          "v": " bir sabah pencereye vuran yağmur damlasını gördü. \"Acaba bu damla nereden geldi?\" diye sordu. Damla sanki onu duymuş gibi camdan aşağı kaydı. "
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
          "v": " damlanın bir bulutun içinde olduğunu hayal etti. Çevrede pek çok damlacık vardı. Rüzgâr bulutu sürükleyince hepsi sallandı. Bazı damlacıklar birleşip ağırlaştı ve aşağı düşmeye başladı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Damla önce bir yaprağa çarptı, sonra toprağa kaydı. Toprak suyu emdi; bir kısmı küçük bir su yoluna karıştı. Su yolu başka sularla birleşip dereye dönüştü. Dar bir yerde su daha hızlı, geniş bir yerde daha yavaş akıyordu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Güneş çıkınca göl parladı. Damla buharlaşıp görünmez bir "
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
          "v": " defterine üç sözcük yazdı: yağış, buharlaşma, yoğunlaşma. Her birinin yanına küçük resimler çizdiler. Bulut, dere, göl ve güneş arasına oklar koydular. Öğretmen bunun su döngüsü olduğunu söyledi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ertesi gün öğretmen soğuk bir kabın yüzeyinde su damlaları gösterdi. Havadaki su buharı soğuk yüzeyde yoğunlaşmıştı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " küçük bir not kâğıdına bir "
        },
        {
          "t": "kelime",
          "yuva": "s2_damla"
        },
        {
          "t": "metin",
          "v": " çizdi ve ona \"Yolcu\" adını verdi. \"Yağmur hiç bitiyor mu?\" diye sordu. Öğretmen, suyun döngüde sürekli dolaştığını anlattı. "
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
    "tarih": "2026-10-21"
  }
}$p13$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr014-yagmur-damlasinin-yolculugu: %', v_r; end if;
  v_r := public.okuma_paket_ice_aktar($p14${
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
        "kelime_sayisi": 181,
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
          "v": " kanadını güneşe çevirdi. \"Belki de güneşin gökyüzündeki yeri değişmiştir.\" "
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
          "v": "Öğle vakti iki işaret farklıydı. Önce gölgenin kendiliğinden küçüldüğünü sandı. Sonra yukarı baktı: güneş sabah gördüğü yerde değildi. "
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
      "dayanak_sayfa": 5,
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
    "tarih": "2026-10-21"
  }
}$p14$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr016-golgeyi-kim-buyuttu: %', v_r; end if;
  v_r := public.okuma_paket_ice_aktar($p15${
  "paket_surumu": 1,
  "hikaye": {
    "slug": "hr017-mahallenin-en-hizli-bisikleti",
    "baslik": "Mahallenin En Hızlı Bisikleti",
    "tur": "macera",
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
}$p15$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'pilot paket hr017-mahallenin-en-hizli-bisikleti: %', v_r; end if;
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr001-kayip-canin-izinde' where fis_kodu = 'HR-001';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr002-renkli-ucurtma' where fis_kodu = 'HR-002';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr003-corabini-arayan-robot' where fis_kodu = 'HR-003';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr004-ters-gun-okulda' where fis_kodu = 'HR-004';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr005-hocanin-golundeki-umut' where fis_kodu = 'HR-005';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr006-dudek-kimin-olacak' where fis_kodu = 'HR-006';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr007-kaplumbaga-ve-tavsan' where fis_kodu = 'HR-007';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr008-aslan-ve-fare' where fis_kodu = 'HR-008';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr009-konusan-kalem-kutusu' where fis_kodu = 'HR-009';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr010-kelogan-ve-konusan-tas' where fis_kodu = 'HR-010';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr012-yeni-arkadasin-gizli-yetenegi' where fis_kodu = 'HR-012';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr013-kirilan-oyuncak-kopru' where fis_kodu = 'HR-013';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr014-yagmur-damlasinin-yolculugu' where fis_kodu = 'HR-014';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr016-golgeyi-kim-buyuttu' where fis_kodu = 'HR-016';
  update public.okuma_hikaye_fisleri set hikaye_slug = 'hr017-mahallenin-en-hizli-bisikleti' where fis_kodu = 'HR-017';
end
$pilot$;

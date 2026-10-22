-- =====================================================================
-- HR-041…047: uzun sayfalar ~90 kelimelik kısa sayfalara bölündü (metin değişmedi); eski taslak sürümler silinir, yeni taslak yazılır
--   * Yönetici olarak çalışan ilk admin profilinin kimliğiyle içe aktarır (require_admin).
--   * Hikâyeler taslak girer (denetim pending); yayın ayrı bir karardır.
--   * Her adım sonuç kontrolü yapar; bir hata olursa işlemin tamamı geri alınır.
-- =====================================================================

set client_encoding = 'UTF8';

do $pilot$
declare
  v_admin uuid;
  v_r     jsonb;
  v_s     uuid;
begin
  select id into v_admin from public.profiles where role = 'admin' order by id limit 1;
  if v_admin is null then
    raise exception 'içe aktarma: yönetici profil bulunamadı';
  end if;
  perform set_config('request.jwt.claims', json_build_object('sub', v_admin, 'role', 'authenticated')::text, true);

  for v_s in select s.id from public.okuma_hikaye_surumleri s join public.okuma_hikayeleri h on h.id = s.hikaye_id where h.slug in ('hr041-yedi-adimda-kayip-ada','hr042-kapadokyanin-gizli-gecidi','hr043-kuledeki-son-isik','hr044-buz-golunun-haritasi','hr045-kutuphanenin-on-ucuncu-rafi','hr046-bilinmeyen-posta-pulu','hr047-kirmizi-defterin-sifresi') and s.durum = 'taslak' loop
    perform public.okuma_surum_sil(v_s);
  end loop;
  v_r := public.okuma_paket_ice_aktar($p01${
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
          "v": " Kampın ilk akşamı, rehberleri Suna Hanım çocuklara bir harita gösterdi. Haritada patikalar, gözlem noktaları, dere yatakları ve koruma sınırları vardı. Ancak haritanın bir köşesi öyle çok silinmişti ki koyun ortasındaki küçük kara parçası bir ada gibi görünüyordu."
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
          "v": ". Kamp başlamadan önce internette gördüğü bir paylaşımda, bölgedeki kayıp adaya ait olduğu söylenen eski bir hazine haritası vardı. Suna Hanım gülümsedi. “Haritalar bazen yanlış sorular sormamıza neden olur. Bu gördüğünüz çizimde suyun nerede başladığını bile kesin bilmiyoruz. Önce güvenilir bilgiyi bulmalıyız.” Sınıfın gözlem ekibinde dört arkadaş vardı: haritalara meraklı Selin, sabırsız ama cesur "
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
          "v": " ve gördüklerini deftere geçirmeyi seven Asya. Birlikte çalışacaklardı. Her grubun görevi, merkezdeki eski haritayı güncel haritayla karşılaştırmak ve gözlem izinleri verilen noktalara ilişkin bir rapor hazırlamaktı. Selin, eski haritanın altındaki notu fark etti: “Yedi adım, tek yol; suyun anlattığına kulak ver.”"
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
          "v": " ise tarihe bakıp “Bu harita kırk yıl önce çizilmiş. Kıyı aynı kalmış olabilir mi?” dedi. Suna Hanım onlara cevap vermek yerine yeni bir soru sordu: “Bir haritanın yaşı neden önemlidir?” Çocuklar denizlerin, rüzgârın ve akarsuların kıyıları zamanla değiştirebildiğini hatırladılar. Gruptaki herkes farklı bir "
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
          "v": " ise kuşların oraya neden toplandığını öğrenmek istiyordu. Kamptaki ilk görev aslında eski bir fotoğrafla başlamıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Fotoğrafta aynı tepe, aynı gökyüzü ve birbirinden farklı iki su çizgisi vardı. Selin ikisinin aynı yer olduğunu söylemiş, "
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
          "v": "Akşam çadırlarına dönmeden önce rapor defterlerinin ilk sayfasına bir kural yazdılar: “Varsayım kanıt değildir.” Altına ikinci bir kural eklediler: “İzinli güzergâhın dışına çıkılmayacak.” Böylece maceranın ilk adımı, bir gizem kadar bir sorumluluk da taşıyordu. Ertesi sabah Suna Hanım, ekipleri gözlem alanına götürdü. Önce herkes haritanın yönünü pusulaya göre ayarladı. Selin kâğıdı o kadar dikkatli çevirdi ki kuzey oku gerçek yönü gösterdiğinde bir an durup gülümsedi. Daha önce yönleri yalnızca ders kitabında çizilmiş oklar olarak görmüştü; şimdi rüzgârın yönü, denizin konumu ve tepenin gölgesiyle ilişkilendiriyordu."
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
          "v": ".” Yol ayrımındaki levha yeni boyanmıştı. Ancak hemen arkasındaki eski taşın üzerinde silinmiş kırmızı bir işaret görünüyordu. "
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
          "v": "Haritadaki birinci işaret, eski bir ahşap gözlem platformuydu. Gözlem kulesinin tahtaları yenilenmiş, yanına bilgilendirici levhalar konmuştu. Levhada kıyıya vuran kumun yıl içinde yer değiştirebildiği anlatılıyordu. Selin, haritanın kenarına bir not düştü: “Kıyı çizgisi sabit değildir.” İkinci işaret küçük bir tatlı su gözlem kuyusuydu. Kuyuya dokunmadılar; rehberleri, ölçüm cihazıyla tuzluluk ve su seviyesi hakkında bilgi verdi. "
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
          "v": "Öğleden sonra rüzgâr hafifledi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kayıt cihazını çıkarıp ötüşleri dinledi. Sabah duydukları martı seslerinin arasında ince bir ötüş vardı. Rehber, bu kuş türünün göç sırasında sulak alanlarda mola verdiğini anlattı. Öğrenciler, sazlıkların yalnızca su ve bitkiden oluşmadığını; göç eden canlılar için beslenme ve dinlenme alanı da olabileceğini öğrendi. Fakat eski haritada adanın bulunduğu yerde tuhaf bir sessizlik vardı. Kuş sesleri uzaktan geliyordu; sazlıkların yakınında ise iri, paslı bir levha duruyordu. Levhada yıllar önce kapanmış bir tekne iskelesinin adı yazıyordu. "
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
          "v": ", “O zaman gizem bir hazine değil, temizlenmesi gereken bir yer olabilir,” dedi. Gözlem platformunda öğle yemeği molası verdiler. Selin defterine üç sütun çizdi: “Gördüklerimiz, düşündüklerimiz, hâlâ bilmediklerimiz.” Gördüklerine eski iskele levhasını, ölçüm kuyusunu ve değişen kıyı çizgisini yazdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Düşündüklerine ise “Ada sanılan yer eski bir kum seti olabilir” notunu ekledi. Son sütunda üç soru vardı: Bu kum seti şimdi neredeydi? Kuşlar neden burada dinleniyordu? Haritada neden yedi işaret bulunuyordu? "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " son soruya takıldı. “Yedinci işaret bir sandığı gösteriyor olabilir.” Asya gözlerini devirdi. “Her şeyi sandığa bağlama.” “Belki sandık kuşlara yem doludur,” diye şaka yaptı "
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
          "v": " biraz şaşırdı. Teknolojinin her soruya anında cevap vermesine alışmıştı. Fakat bu kez cihaz yalnızca ses topluyordu; yorum yapmak kendilerine düşüyordu. Asya bunu raporun kenarına ekledi: “Kayıt, gözlemin bir parçasıdır. Doğru yorum için başka kaynaklar da gerekir.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Günün sonunda çocuklar kamp merkezine döndü. Akşamki paylaşım toplantısında başka ekiplerin bulgularını da dinlediler. Bir grubun fotoğrafında eski haritadakine benzer bir kıyı şekli görülüyordu; bir diğeri kumulların rüzgârla hareket ettiğini anlatmıştı. Selin bu bilgileri kendi haritalarına ekledi. Gece boyunca çadırların üzerinde yağmur sesi duyulmuştu. "
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
          "v": " gönülsüzce defterini açtı. Hava durumu tahminiyle gerçekleşen hava olayının her zaman birebir aynı olmayabileceğini de not etti. Böylece iptal edilen gezi, başka bir gözlem çalışmasına dönüşmüş oldu. Kampın ikinci günü hava kapalıydı. Rehber, rüzgârın hızlanabileceği uyarısıyla açık kıyı yürüyüşünü iptal etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hayal kırıklığını saklayamadı. “Tam sonuca yaklaşmıştık.” Suna Hanım, “Araştırma bazen durmayı da gerektirir,” dedi. “Bugün arşive bakacağız.” Merkezin küçük kütüphanesinde yıllara göre hazırlanmış haritalar, eski hava fotoğrafları ve kıyı raporları vardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Asya, kırk yıl önce çekilmiş bir fotoğrafı buldu. Fotoğraftaki ada, aslında denizden ayrı duran küçük bir kara parçası gibi görünüyordu. Ancak altındaki açıklama, kış aylarında suların yükseldiğini; yazın bazı yerlerde kum setlerinin belirginleştiğini söylüyordu. “Demek ada bazen görünüyormuş,” dedi "
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
          "v": " yüzü düştü. “Hazine arama oyunu yerine dosya okuyoruz.” Asya ona eski defterdeki sözlerini hatırlattı: “Varsayım kanıt değildir. Sen bizi maceraya çağırdın ama asıl macera gerçeği öğrenmek olabilir.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce itiraz edecekti. Sonra fotoğrafların farklı yıllarda çekildiğini fark etti. Aynı yeri karşılaştırmadan bir şey söylemek gerçekten zordu. “Peki,” dedi. “Hazineyi bir süreliğine unutuyorum.” Öğretmenler harita üzerinde dört yeni nokta işaretledi. Bunlar eski kumul çizgisi, yeni sazlık sınırı, ölçüm istasyonu ve mevcut gözlem platformuydu. Böylece toplam yedi durak tamamlandı. Suna Hanım, adaların ve kıyı şekillerinin değişimini anlamak için bu noktaların birlikte incelenmesi gerektiğini açıkladı."
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
          "v": " defterine uzun bir cümle yazdı: “Bir ipucunu sevmek, onun doğru olduğunu kanıtlamaz.” Altına da küçük bir sandık resmi çizdi; üstünü çizmedi. “Hayal kurmak da önemli,” dedi. “Sadece hayalle gerçeği karıştırmamak lazım.” Gecenin ilerleyen saatlerinde "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", dışarıdan gelen rüzgâr sesine uyandı. “Kıyı orada duruyor, biz burada uyuyoruz,” diye düşündü. Sandığı bir gün bulabileceğine ilişkin hayalinden vazgeçmek istemiyordu. Çadırın küçük penceresinden görünen yıldızlara baktı ve ilk defa bir maceranın sonunda hiçbir şey almadan dönmenin de değerli olabileceğini düşündü. Ertesi sabah kahvaltıda düşüncesini arkadaşlarıyla paylaştı. Selin, “Bilgi almak, eşya almak gibi değil,” dedi."
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
          "v": " kahvaltısını bitirirken sandık aramak kadar kayıt tutmanın da heyecanlı olabileceğine şaşırdı. Bu düşünce, biraz sonra görecekleri manzarayı daha dikkatli incelemesini sağlayacaktı. O sabah "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " aklında yeni bir soru vardı: “Koruma alanına kim karar veriyor?” Suna Hanım, bu tür kararların ilgili kurumlarca bilimsel çalışmalar ve mevzuat çerçevesinde alındığını anlattı. Çocuklar bir bölgenin herkese açık olmamasının, kimsenin onu sevmediği anlamına gelmediğini düşündü."
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
          "v": " sandık hayalini biraz geriye itti. Çünkü bir evin kapısını, sahibine sormadan açmayı doğru bulmuyordu. Üçüncü gün hava açınca izinli gezi yeniden başladı. Grup, görevliler eşliğinde son gözlem platformuna yürüdü. Platformdan açık deniz, kumullar ve dar bir "
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
          "v": ". “Bir sınırı gösteriyor.” Suna Hanım başını salladı. “Bu, çok önemli bir çıkarım. Ama hangi sınır?” Çocuklar, güncel koruma haritasıyla kendi çizimlerini yan yana koydu. Sınırlar tam olarak aynı değildi. Eski haritanın çizgisi bir zamanlar suyla çevrili olan kum setini, yeni haritanın çizgisi ise bugün korunması gereken sazlık ve lagünü gösteriyordu. Aynı alan, iki farklı zamanda iki farklı görünüm kazanmıştı. Asya, sahada sessiz durma işaretini gösterdi. İnsan seslerinin kuşları rahatsız edebileceğini ve gözlemi zorlaştırabileceğini öğrenmişlerdi."
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
          "v": " önce sabırsızlandı; arkadaşlarına gördüğü her şeyi yüksek sesle anlatmak istiyordu. Sonra yalnızca defterine küçük bir çizim yaptı. Bir kuşun sığ suda yürüyerek beslendiğini, bir diğerinin ise daha uzak bir taşın üzerinde dinlendiğini gördü. Aynı alanı kullanan canlıların ihtiyaçlarının farklı olabileceğini anladı. Bu sessiz bekleyiş, birkaç dakika öncesine kadar boşa harcanan zaman gibi gelmişti. Şimdi gözlemin kendisi yolculuğun en heyecanlı bölümüne dönüşüyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " gözlerini kısıp dürbünle baktı. Kıyıda bir grup kuş vardı. İki tanesi suya dalıyor, diğerleri birbirini takip ederek kumsalda yürüyordu."
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
          "v": ". Selin, “Kuşlar, su, bitkiler ve hepsinin yaşadığı yer,” diye cevap verdi. Öğretmenleri çocukların yanına gelip notlarını inceledi. “Bugün çok iyi bir şey yaptınız,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Bir yerin değerini yalnızca orada ne bulabileceğinize göre değil, orada nelerin yaşadığına göre değerlendirdiniz.” Asya son fotoğrafı çekti. Bu kez kadrajda hazine sandığı yoktu. Bir yanda su, öbür yanda sazlık, ortada güneş ışığında dinlenen kuşlar vardı. Fotoğrafın altına şu açıklamayı yazdı: “Kayıp Ada değil, korunması gereken yaşayan kıyı.” Platformdan dönerken yürüyüş grubuna yakın bir okulun öğrencileri rastladı. Onlardan biri koruma alanını neden göremediklerini sordu. "
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
          "v": "Bir alanın bazı bölümleri gözleme açık, bazıları ise hassas dönemlerde kapalı olabilirdi. Suna Hanım, ziyaret kurallarının resmî levhalardan öğrenilmesi gerektiğini gösterdi. "
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
          "v": " üçüncü bir seçenek önerdi: “Gerçek soru, kayıp adanın nerede olduğuydu. Cevabın da merak uyandırmasını sağlayabiliriz.” Böylece dinleyiciyi kandırmadan ilgi çekmenin mümkün olduğunu gördüler. Herkes kendi fikrinden bir parça vazgeçti ve ortaya daha iyi bir metin çıktı. İlk taslağı şöyleydi: “Kırk yıllık hazine bilmecesini çözdük!” Asya başını iki yana salladı. “Gerçekte olmayan bir hazineyi çözdüğümüzü söyleyemeyiz.” "
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
          "v": "“Bu hem merak uyandırıyor hem de yanlış bir iddia kurmuyor,” dedi. Sunum günü, sınıflar merkezin küçük salonunda toplandı. "
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
          "v": " kaydedilen kuş seslerini dinletti. Asya atıkların yerini ve görevlilere yapılan bildirimi anlattı. Sorular başladığında bir öğrenci, “Madem ada yok, eski haritayı çöpe atmak gerekmez mi?” diye sordu. Selin, “Hayır,” diye cevap verdi. “Eski harita bize geçmişteki durumu gösteriyor. Yanlış bilgi vermiyor; yalnızca başka bir zamanın bilgisini veriyor.”"
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
          "v": ", raporu tamamlamakla ünlü bir hazine bulmuş gibi hissetmedi. Daha güzel bir şey hissetti: Söylediklerinin başkaları için yararlı olabileceğini düşündü. Kendi fikirlerinin kontrol edilmesine de kızmıyordu. Çünkü doğruluğun alkıştan daha değerli olduğunu öğrenmişti. Rapor panoya asılmadan önce koruma görevlisi küçük bir düzeltme yapmıştı. Çocuklar kuşların beslenme alanını yalnızca “yuva” olarak adlandırmışlardı. Görevli, her göçmen kuşun o bölgede yuva yapmayabileceğini, bazılarının yalnızca dinlenip beslenmek için geldiğini anlattı."
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
          "v": " ses kaydının yanına gözlemin tarihini yazdı. Asya da çektiği kuş fotoğrafının altına kesin tanımlayamadıkları tür adı koymadı. Hep birlikte daha az iddialı ama daha güvenilir bir sergi hazırlamışlardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Bunu görmek için yedi adımdan fazlası gerekiyormuş,” diye şaka yaptı. Veda toplantısında her öğrenci kampın ona öğrettiği tek şeyi söyleyecekti. "
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
          "v": " bir kuş tüyü gördü. Onu alıp hatıra olarak saklamak istedi. Sonra kampın ilk kuralını hatırladı: Doğadaki nesneler mümkün olduğunca yerinde kalmalıydı. Tüyün fotoğrafını çekti, olduğu yerde bıraktı. Otobüsün penceresinden son kez kıyıya bakarken "
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
          "v": ", “Ben olsam başta cebime koyardım,” dedi. “Ben de,” diye güldü "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Ama fotoğraf da hatıra olur.” Otobüse binmeden önce dört arkadaş, eski haritanın kopyasına son kez baktı. Selin yedi gözlem noktasını numaralandırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk gün yazdığı hazine tahmininin yanına bir not ekledi: “En değerli şeyi almak değil, ona zarar vermeden tanımak.” Asya, bu cümlenin raporun sonunda kullanılmasını önerdi. Otobüs yola çıktığında kamp geride kaldı. Kıyı boyunca uzanan sazlıklar küçüldü. Bir süre kimse konuşmadı. Sonra "
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
          "v": ". Kamp defterini çantasına yerleştirirken ilk sayfadaki aceleyle çizdiği sandığı gördü. Yanındaki son sayfada ise kuş sesleri, kıyı haritası ve kaynak listesi vardı. Defterin nasıl değiştiğine şaşırdı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ellerini kaldırdı. “Tamam, tamam! Artık hazine avcılığı daha zor işmiş.” Okula döndüklerinde öğretmenleri raporu sınıf panosuna astı. Kayan kıyılar, göçmen kuşlar ve koruma sınırları hakkında başka öğrenciler de sorular sormaya başladı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", haritadaki yedi adımın aslında tek bir yere gitmediğini düşündü. Her adım, onu biraz daha dikkatli bir araştırmacıya dönüştürmüştü. "
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
          "v": " defterine eklediği kaynakları da düşündü. Artık bir bilgiyi duyduğunda kimin söylediğini ve nereden öğrenildiğini sormayı unutmayacaktı. Defterinin son sayfasına yeni bir başlık yazdı: “Sekizinci Adım: Öğrendiklerimi Paylaşmak.” Altını çizdi. Çünkü bir keşif, yalnızca bulununca değil, doğru anlatılınca da büyüyordu. "
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
  }
}$p01$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr041-yedi-adimda-kayip-ada: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p02${
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
          "v": " Anneleri, önce açık hava müzesini ve izinli bir yürüyüş parkurunu gezeceklerini söyledi. Gezi rehberleri Eren Bey otobüste bölgenin coğrafyasını anlattı: Volkanlardan çıkan kül ve başka malzemeler zamanla kayaçlara dönüşmüş, rüzgâr ve su bazı yerleri daha hızlı aşındırmıştı. Sert ve yumuşak katmanların farklı biçimlerde aşınması, bölgenin ilginç kaya şekillerinin ortaya çıkmasına katkıda bulunmuştu."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Peribacaları bir gecede mi oluştu?” diye sordu Bora. “Hayır,” dedi Eren Bey. “Doğadaki büyük değişimler çoğu zaman çok uzun zamanlarda gerçekleşir. Bir damla suyun bile zamanla iz bırakabileceğini düşünün. Atasözümüz der ki: ‘"
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
          "v": " gözü yol kenarındaki levhalardan birine takıldı. Levhada tepe, vadi ve oyuğun basit çizimleri vardı. Bir ok ise fotoğraftaki kayaya benzemeyen küçük bir kanala yöneliyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", “Bu kanal ne?” diye sordu. Rehber, bunun tarihî su sistemleriyle ilgili bir rota işareti olabileceğini ama levhayı incelemeden kesin konuşamayacağını söyledi."
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
          "v": ", bazı kaya başlıklarının alttaki bölümü yağmurdan ve rüzgârdan kısmen koruduğunu öğrendi. Bora ise iki fotoğrafın neredeyse aynı görünmesine rağmen yıllar arasında çekildiğini fark etti. “Bunlar sanki durmuş gibi,” dedi. Rehber, “Yavaş gerçekleşen değişimleri bir günde görmek zordur,” diye açıkladı. "
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
          "v": " ise müzelerde eserlerin yanındaki açıklamaları okumayı severdi. Kaya üzerindeki işareti görünce birlikte fotoğraf çektiler; konumunu izinli güzergâh haritasına işaretlediler. “Bu işareti birileri yakın zamanda yapmış olabilir,” dedi "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Eski olduğunu yalnızca renginden anlayamayız.” Eren Bey çocukların dikkatine şaşırmıştı. Bir süre sonra onlara yakınlardaki ziyaretçi merkezindeki sergiye bakmayı önerdi. Merkezde kaya oyma mekânların, güvercinliklerin ve eski su yollarının fotoğrafları vardı. Bir panoda “su kanalı” sözcüğü geçiyordu. Kimi yerlerde yağmur suyu toplanıyor, uygun yerlere ulaştırılıyordu."
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
          "v": ". “Bu çizimi kim yapmış, ne zaman yapmış?” Broşürün arkasında yörede yapılan bir okul araştırmasının adı yazıyordu. Kroki, tarihî bir belgenin aslı değil, eski su yollarını anlatmak için öğrencilerce hazırlanmış bir eğitim görseliydi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " biraz hayal kırıklığına uğradı. “Demek şifre değilmiş,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Eren Bey, “Şifre olmaması değersiz olduğu anlamına gelmez. Belki size çok iyi bir araştırma sorusu verdi,” diye karşılık verdi. “Üstelik tarihî yerlerde izinsiz bir kapı aramak yerine, bilgiyi güvenli biçimde inceleyebilirsiniz.” Gece Bora, gezi defterindeki su damlası simgesinin kopyasını birkaç kâğıda çizmişti. “Belki bunu her gördüğümüzde bir puan kazanırız,” dedi. "
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
          "v": " bu cümleyi not aldı; oyunun en değerli puanı ona göre doğru ayrımı yapmaktı. Ertesi sabah grup, eski bir çeşmenin bulunduğu köy meydanına gitti. Meydandaki çeşmeden hâlâ su akıyordu."
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
          "v": ", birinci gün gördüğü damla işaretine benzeyen bir simge buldu. Fakat fotoğraftaki işaretin yönü farklıydı. “İkisi aynı şey mi?” diye sordu. “Benziyorlar ama eş olmak zorunda değiller,” dedi rehber. “Bir şeklin anlamını kullanıldığı yere göre değerlendiririz.” Mert iki fotoğrafı tabletinde yan yana açtı. Kayadaki iz daha yuvarlaktı, çeşmenin üzerindeki ise üç köşeliydi. Bora farklılıkları saydı. Saadet Hanım çocuklara bir de çeşmenin eski bir fotoğrafını gösterdi."
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
          "v": ", “Onarım kötü mü?” dedi. “Hayır,” diye cevap verdi Saadet Hanım. “Önemli olan yapının korunması ve yapılan işlemlerin uzmanlarca kayıt altına alınması.” Bora eski fotoğraftaki taşları saydı, güncel fotoğrafla karşılaştırdı. Üç taşın farklı göründüğünü buldu. Böylece çevredeki bir ayrıntının değişmesini her zaman gizli bir kapıyla açıklamanın yanlış olduğunu gördü. Bazen cevap, dikkatli bir bakım çalışmasında saklıydı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İlk defa bir sırrı çözmek için hızlı davranmak yerine ayrıntıları incelemekten zevk alıyordu. Köy meydanında emekli bir öğretmen olan Saadet Hanım ile tanıştılar. Eren Bey onların sorusunu iletti. Saadet Hanım, eskiden köy çevresinde yağmurun nasıl toplandığını anlatan bir yerel araştırma hazırladıklarını söyledi. Fakat çocukların gördüğü işaretin tam olarak neyi gösterdiğinden emin değildi. “Belge bulursanız beraber bakarız,” dedi. “Siz bilmiyorsanız kim bilir?” diye sordu Bora. “Bilmemek ayıp değil,” dedi Saadet Hanım. “Bilmediğini öğrenmek istememek üzücü olabilir.” Bu cevap "
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
          "v": ", başlıklardan birini defterine geçirdi: “Suyu bulmak kadar korumak da önemlidir.” Söyleşiden önce müze salonundaki bir maket dikkatlerini çekti. Makette yağmur, tepelerin yamaçlarından aşağıya akıyor; kimi yerlerde küçük kanallar boyunca birikiyor, kimi yerlerde ise toprağa sızıyordu. Görevli, maketin gerçek bir köyün bütün ayrıntılarını göstermediğini, öğrenmeye yardımcı bir model olduğunu özellikle söyledi. Çocuklardan biri maketteki suyu artırdığında bir kanalın taşıyamayıp taştığı görüldü."
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
          "v": " “Bir kanalın yaşını nasıl anlarsınız?” diye sordu. Görevli, uzmanların malzeme, yapım tekniği, tarihî kayıtlar ve gerektiğinde bilimsel yöntemleri birlikte değerlendirdiğini söyledi. Mert, “Yalnızca fotoğrafla kesin sonuca varamaz mıyız?” diye sordu. “Çoğu zaman fotoğraf bir başlangıçtır,” dedi görevli. “Tek başına bütün soruları cevaplamaz.” Gezi tamamlanırken parkur yakınından su sesi geldi. Bora hemen arkasını döndü. Kayaların arasındaki küçük bir oluğun içinden ince bir akıntı ilerliyordu. Eren Bey bunun son yağışlardan sonra görülebilen yüzey akışı olabileceğini anlattı."
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
          "v": " olukla eski broşürdeki çizginin benzerliğini fark etti ama ikisini aynı yapı sanmadı. “Bazen bir doğa izi, insan yapımı bir kanala benzeyebilir,” dedi. Eren Bey, “İşte bu yüzden gözlem, karşılaştırma ve kaynak kontrolü yapıyoruz,” diye karşılık verdi. Bir süre sonra suyun bir kısmının küçük bir çukurda biriktiğini gördüler. Çukurun çevresindeki bitkiler daha canlı görünüyordu. "
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
          "v": " bu kez küçük bir araştırma tablosu çizdi: Bir satırda su, ötekinde rüzgâr, üçüncüsünde insan emeği vardı."
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
          "v": " herkesin gözlemini tek bir sayfaya topladı. Başlangıçta tam bir cevap beklemişlerdi. Şimdi farklı bilgi kaynakları arasında bağlantı kurmanın daha değerli olduğunu düşünüyorlardı. Rehberleri Eren Bey deftere bakınca gülümsedi. “Araştırma, yalnızca bulduğunu değil, bulamadığını da dürüstçe yazmaktır,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Çocuklar son sayfaya küçük bir kutu çizip “Kesinleşmeyen sorular” başlığı açtılar. Altına kaya yüzeyindeki su damlası işaretinin kökenini yazdılar. "
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
          "v": " araya girdi. “Başlığı değiştirmeden hikâyenin sonunda neyi keşfettiğimizi anlatabiliriz. Belki gizli geçit, bizi sorulara götüren yoldu.”"
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bora düşündü. “O zaman “Kapadokya'nın Gizli Geçidi” başlık olur. Ama içeride hayal ile gerçek ayrılır.” "
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
          "v": "“Ama bu defa yanımızda daha çok soru, daha az tahmin olsun.” “Hiç tahmin olmasın mı?” “O kadar da değil. Tahmin bizi yola çıkarır. Kanıt nereye gideceğimizi söyler.” Defterdeki son tabloyu birlikte doldurdular. Birinci sütunda gezi sırasında duydukları yeni kelimeler, ikinci sütunda anlamları, üçüncü sütunda ise kullandıkları örnek cümleler vardı. Bora “oyuk” kelimesinin yanına kayanın içeri doğru çökük bölümünü gösteren küçük bir çizim ekledi. "
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
          "v": "Çünkü onun için kanıt artık yalnızca gizli bir işaret değil, doğru soruyla incelenen bilgi demekti. Otobüs hareket etti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", defterin son sayfasına araştırmada tanıştıkları insanların adlarını da yazdı; bir keşifte yalnız olmamak güzeldi. O su damlası resmine her baktığında Kapadokya'daki kayaların yalnızca güzel görüntüler değil, uzun bir zamanın izleri olduğunu hatırlayacaktı. "
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
  }
}$p02$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr042-kapadokyanin-gizli-gecidi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p03${
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
          "v": " “Anne, kulede biri olabilir mi?” diye sordu. Annesi perdeyi açıp baktı. “Olabilir. Ama gece tek başımıza oraya gitmek doğru olmaz. Yarın belediyenin bilgi hattına sorabiliriz.” "
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
          "v": "“Belki gizli bir haberleşme sistemi,” dedi heyecanla. Üçüncü arkadaşları Defne ise hemen karşı çıktı. “Ya bakım lambasıysa? Önce gözlemimizi yazalım.” Öğretmenleri Meryem Hanım bir bilim gözlem etkinliği planlıyordu. Çocukların notlarını görünce kulenin bulunduğu tepeyi gösteren eski bir fotoğraf çıkardı. Fotoğrafta kulenin yanında rüzgâr yönünü gösteren bir ok vardı. “Bu yer eskiden hava gözlemleri için kullanılmış,” dedi. “Bugünkü işlevini bilmiyoruz. Birlikte araştırabiliriz.” "
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
          "v": " gökyüzündeki bulutların şeklini çizdi. Defne ise rüzgârın aniden yön değiştirdiğini fark etti. “Hava tahmini yalnızca bulutlara bakmak mıdır?” diye sordu "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": ". “Hayır,” dedi öğretmenleri. “Sıcaklık, basınç, nem, rüzgâr ve daha birçok veri birlikte değerlendirilir. Üstelik tahminin kesinlik derecesi vardır.” Okuldaki hava köşesinin termometresi güneş altında kaldığında daha yüksek değer gösterebiliyordu. Defne, farklı yere taşındığında ölçümün niçin değiştiğini merak etti. Öğretmenleri, ölçümlerin karşılaştırılabilir olması için araçların doğru yere konması ve aynı yöntemle kullanılması gerektiğini anlattı."
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
          "v": " yağmur ölçerin boşaltılması gerektiğini unuttuğu bir günü hatırladı. “Demek sayı kadar sayının nasıl elde edildiği de önemli,” dedi. Meryem Hanım, “Bunu raporunuzun en üstüne yazın,” diye önerdi. Çocuklar artık meteorolojiyle ilgili bir sözcük öğrendiklerinde onu doğrudan örneklerle ilişkilendirebiliyordu: nem, yağış, basınç ve rüzgâr yalnızca kitapta gördükleri kelimeler değildi. O gün okulun küçük bahçe şenliğinin duyurusu yapılacaktı. Sınıf süslemeleri hazırlıyordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " hava tahmini sitesinde akşam için gök gürültülü sağanak olasılığı gördü. Arkadaşı Tuna, “Burada güneş var, yağmur gelmez,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Defne buna itiraz etti: “Bir yerde güneş olması, birkaç saat sonra başka bir hava olayı yaşanmayacağını göstermez.” Çocuklar öğretmenlerinden resmi tahmin ve uyarıların nereden takip edildiğini öğrendi. Başka kaynaklarda farklı ifadeler görünce de tek bir videoya bakarak karar vermemeleri gerektiğini anladılar. O akşam "
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
          "v": " akşamki kule ışıklarının havayla ilişkili olabileceğini düşünmeye başladı. Öğle arasında duyuru panosuna küçük bir çizelge astılar: “Gözlem, tahmin, gerçekleşen hava”. Sınıftaki diğer öğrenciler de kendi gözlemlerini ekledi. Kimileri bulutları resmetti, kimileri rüzgârı hissettiğini yazdı. Çizelge giderek bir dedektif panosuna benziyordu. Fakat bu kez dedektiflerin peşinde bir insan değil, değişen hava vardı. Meryem Hanım, meteoroloji bölge müdürlüğündeki eski öğrencisi Burcu Hanım'ı çevrim içi görüşmeye davet etti. Burcu Hanım bir hava uzmanıydı. Öğrenciler sırayla sorularını yöneltti. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " kuledeki yanıp sönen ışığın gizli bir mesaj olup olmadığını sordu."
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
          "v": ", “Bir hava istasyonu tehlikeyi nasıl bildirir?” diye sordu. Burcu Hanım, otomatik istasyonların ölçümleri elektronik yollarla iletebildiğini anlattı. Gözlem verileri uzmanlarca incelenir, uygun görülürse resmî uyarılar yayımlanırdı. Kuledeki ışık tek başına halka yönelik bir alarm anlamına gelmiyordu. Burcu Hanım çevrim içi görüşmede bir örnek de gösterdi. İki haritada aynı bölgenin farklı zamanlardaki hava durumunu simgelerle işaretlemişti. Bir haritada yağmur olasılığı görünürken ötekinde yağışın gerçekleştiği alan gösteriliyordu."
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
          "v": " bunu çok yararlı buldu; çünkü internette dolaşan eski bir uyarıyı güncel sanmanın da yanlış kararlar doğurabileceğini fark etti. Defne, sınıf panosuna tarihi olmayan hiçbir uyarı resmi asmayacaklarına karar verdi. Görüşme bittikten sonra Meryem Hanım önemli bir soru sordu: “Bir ipucu gördüğünüzde hikâyeyi kim tamamlıyor?”"
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
          "v": " yine de kulenin ışığını unutamıyordu. Ertesi akşam balkondan baktığında ışık bir kez daha yandı. Bu kez saatini not etti ve annesiyle birlikte görüntünün kısa bir videosunu çekti. Videoda uzaktaki kule görünüyordu ama ışığın niçin yandığı belli değildi. "
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
          "v": " bildirdiğini, bu yüzden gerçekleşmeyen bir olayın bütün tahmin yöntemlerini geçersiz kılmayacağını anlattı. Meryem Hanım çocuklardan iki cümleyi karşılaştırmalarını istedi: “Mutlaka yağmur yağacak” ve “Sağanak olasılığı bulunuyor.” "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ikinci cümlenin daha doğru olduğunu söyledi; kesinlik bildiren sözcükler farklı kararlar doğurabilirdi. Öğretmenleri bunun üzerine kısa bir etkinlik yaptırdı. Çocuklar meteoroloji bültenlerindeki “olası”, “bekleniyor”, “yerel” gibi sözcükleri işaretledi. Tuna sonunda “Demek hava tahmini kehanet değil,” dedi. Sınıf güldü."
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
          "v": " görevlilerden biriydi. Ancak öğleye doğru rüzgâr kuvvetlendi. Hafif afişler sallanıyor, bazı bulutlar kısa sürede çoğalıyordu. Meryem Hanım, okul idaresiyle birlikte güncel hava uyarılarını kontrol etti. Şenliğin açık hava bölümü ertelendi. Bazı öğrenciler üzüldü. Tuna, “Belki yağmur yağmayacak. Boşuna hazırlanmış olduk,” dedi. "
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
          "v": " önce onu tek başına kaldırmayı denedi, sonra öğretmeninden yardım istedi. Birlikte taşırken “Bugün yalnızca hava değil, ekip çalışması da öğrendik,” diye şaka yaptı. Tuna kütüphane kitaplarının ıslanmadığını görünce rahatladı. Çünkü bir ay boyunca resimledikleri öyküleri ilk kez ziyaretçilere gösterecekti. Kısa süre sonra yağmur başladı. Pencereden dışarı bakarken sert damlaların bahçedeki boş masalara vurduğunu gördüler. Eşyalar zarar görmemiş, öğrenciler içeride güvendeydi. Tuna "
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
          "v": " ile birlikte salonun penceresinden bahçeyi izledi. Yağmurdan sonra rüzgâr hafifledi, bulutların bir kısmı dağıldı. Tuna “Şimdi dışarı çıkabiliriz,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", etkinliğin yeniden dışarı taşınıp taşınmayacağına öğretmenlerinin karar vereceğini hatırlattı. Çünkü hava yalnızca o anda pencereden görünen manzaradan ibaret değildi. Okul yönetimi etkinliği içeride sürdürmeyi uygun buldu. Bu karar ilk başta bazılarına gereksiz göründü ama içerideki program da çok güzel geçti. Çocuklar çizimlerini korumuş, misafirler rahatça kitapları incelemişti. Tuna, bir günün başarılı olması için bütün planların ilk biçimiyle gerçekleşmesinin gerekmediğini anladı."
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
          "v": " masaya, “Hava bir sır saklamaz; sadece onu anlamak için veri gerekir,” yazılı küçük bir kart koydu. "
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
          "v": " metni sınıf panosuna olduğu gibi asmak yerine öğretmeniyle birlikte özetledi. Kurum adını, yanıtın tarihini ve sorulan soruyu da eklediler."
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
          "v": ", “Keşke ışığın mors alfabesiyle mesaj verdiği doğru çıksaydı,” diye şaka yaptı. Defne, “O zaman da bunu kanıtlamak gerekirdi,” dedi. Hafta sonunda belediyeden yanıt geldi. Yenilenen kuledeki ışık, bakım sırasında belirli aralıklarla yapılan bir ekipman kontrolünün parçasıydı. Kule, hava verilerini ölçen sistemlerden birini barındırıyordu. Işık, "
        },
        {
          "t": "kahraman",
          "hal": "ilgi"
        },
        {
          "t": "metin",
          "v": " düşündüğü gibi insanları doğrudan uyaran bir mesaj değildi. Yine de kule, hava gözlemi için önemliydi. “Aslında çocukken ben de bulutların her şeklini bir işaret sanırdım,” dedi öğretmenleri. “Hayal kurmak güzeldir."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Bilim yaparken ise hayalimizin hangi bölümünün kanıtlandığını bilmemiz gerekir.” "
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
          "v": " biraz utanarak, “Ben onu gizli bir istasyon sandım,” dedi. Defne gülümsedi. “Aslında istasyon kısmını doğru tahmin etmişsin. Gizli kısmını kanıtlamamıştık.” Öğretmenleri raporlarını üç bölüme ayırmalarını istedi: “Ne gördük? Ne düşündük? Ne öğrendik?” Defne yazıyı yüksek sesle okuyunca bir cümlede tarih eksik olduğunu fark ettiler. Hemen eklediler; çünkü bir gözlemin ne zaman yapıldığı, ne görüldüğü kadar önemliydi."
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
          "v": "Artık ışığa bakınca aklına yalnızca gizem gelmiyordu; orada çalışan görevlilerin emeğini de düşünüyordu. Bir veri işlenmeden, kontrol edilmeden ve doğru zamanda paylaşılmadan insanların karar vermesine yardım etmeyebilirdi. Bu farkındalıkla sınıf panosunda kendi adının çok büyük yazıldığını fark etti ve yanına "
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
          "v": " bilimi tek başına parlak bir fikir bulmak değil, farklı insanların ortak dikkati olarak görmeye başladı."
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
          "v": ", ilk günkü korkusunu hatırladı. Bir ışığın neden yandığını bilmemek, onu hemen tehlike saymayı gerektirmiyordu. Doğru kaynakları araştırmak, hem merakı koruyor hem de gereksiz korkuyu azaltıyordu. Sınıf arkadaşlarının da bunu anlamasını istiyordu. Defterinin son sayfasına şunu yazdı: “Her ışık bir mesaj olabilir; ama hangi mesaj olduğunu ancak doğru kaynaklarla anlayabiliriz.” Altına bir kule, bir bulut ve küçük bir soru işareti çizdi. Çünkü ona göre iyi bir araştırmacının çantasında üç şey bulunmalıydı: dikkatli gözler, sabırlı bir akıl ve yeni sorular. "
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
  }
}$p03$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr043-kuledeki-son-isik: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p04${
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
          "v": " iki bilgiyi birlikte kullanmayı denemek istiyordu."
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
          "v": " ise eldivenleri kalın olduğu için haritayı açmakta zorlandı. “Dağda küçük işler neden bu kadar güçleşiyor?” diye söylendi. "
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
          "v": ". Ceren Hanım, “Hava ve yol şartları uygun kalırsa belirlenen seyir noktasından göreceğiz,” dedi. “Ama gölün üzerine çıkmak yok. Buzun güvenli olduğunu yalnızca görünüşünden anlayamayız.” Yola çıkmadan önce Ceren Hanım küçük bir oyun hazırladı. Masaya eldiven, çikolata, oyuncak dürbün, termos, pusula ve parlak bir madalya koydu. “Hepsini taşımaya gerek yok,” dedi. “Bu yürüyüşte hangileri yararlı, hangileri yalnızca güzel görünüyor?”"
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
          "v": " bunun su buharının soğuk havada küçük damlacıklar oluşturmasıyla ilgili olduğunu öğrenmişti. "
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
          "v": "Ceren Hanım sıcaklıkla rüzgârın birlikte nasıl hissedildiğine dikkat çekti. Grup ilk kilometrede bir gözlem yapacaktı. Karın üzerine düşen gölgeleri saymak ve güneş açısının görünüşü nasıl etkilediğini not etmek. "
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
          "v": ", “Haritadaki mavi işaretler ne demek?” diye sordu. Ceren Hanım bunların su kenarlarını, kırmızı çizginin ise yürüyüş yolunu gösterdiğini anlattı. İzinli patikanın kenarında görevli, çocuklara küçük hayvan ayak izleri gösterdi. Hangi canlıya ait olduklarını hemen söylemedi; izlerin boyutunu ve biçimini karşılaştırmalarını istedi. "
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
          "v": " ise emin olmadığını belirtti."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Ceren Hanım, izlerin yalnızca fotoğraf üzerinden kesin tanınamayabileceğini, koruma görevlilerinin bölgedeki canlıları daha iyi bildiğini söyledi. Çocuklar gördüklerini not aldı ama izleri takip etmek için patikadan ayrılmadı. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " küçük bir izin peşinden gitmenin ne kadar çekici olduğunu hissetti; sonra herkesin neden belli kurallar içinde gözlem yaptığını yeniden anladı. Yürürken uzakta göl göründü. Buzun bazı yerleri bembeyaz, bazı yerleri ise koyu maviydi. Işığın yansıması suyun ve buzun görünüşünü değiştiriyordu."
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
          "v": ", “Dönüşte havanın ne zaman değiştiğini hatırlamak için,” dedi. Kayıt tutmayı sıradan bir ödev gibi görmüyordu; gördüklerini sonradan doğru hatırlamaya yardım eden bir araç olarak düşünüyordu. Ceren Hanım onların notlarını görünce zamanı da eklemelerini önerdi. “İki olayın sırasını bilmek, neden–sonuç kurarken işinizi kolaylaştırır,” dedi. Öğleye doğru bulutlar çoğaldı. Ceren Hanım grubun mola vereceği noktayı belirledi. "
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
          "v": " öne doğru birkaç adım atınca tabelanın arkasındaki dar yolun kapatıldığını gördü. Hemen geri döndü. "
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
          "v": " bu ayrımı beğendi. Bir bilgi geçmişi anlatmakta yararlı olabilir, bugün karar verirken ise yetersiz kalabilirdi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "“Bu yol geçen yıl açıkmış,” dedi. “Neden şimdi kapalı?” Rehber, bazen bakım, hava koşulları veya doğal alanların korunması nedeniyle rotaların değişebileceğini anlattı. Eski bir harita her zaman güncel olmayabilirdi. "
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
          "v": ", “Demek yalnızca yönümüzü değil, haritanın tarihini de kontrol etmeliyiz,” dedi. Bir süre sonra hafif kar başladı. Ceren Hanım grubun geri dönmesine karar verdi. Dönüşte rüzgâr arttı ve uzaktaki ağaçlar beyaz bir perde arkasında silikleşti. Çocuklar liderlerine yakın yürüdüler. Parkurun işaretleri görünüyordu ama yürüyüşün başlangıcındaki manzara artık farklıydı."
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
          "v": "Birkaç dakika sonra kırmızı rota levhası ortaya çıktığında ikisi de doğru yolda olduklarını anladı. Rüzgâr bazen yüzlerine vuruyordu fakat artık ne yapacakları belliydi. Ceren Hanım rota kartıyla konumlarını kontrol etti, merkezle haberleşti. Yardım istemeye gerek olmadığını, yalnızca hava değişimi nedeniyle planlı geri dönüş yaptıklarını bildirdi. Böylece herkes nerede olduklarını biliyordu. "
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
          "v": " başlangıçta karşı çıktı. “Yine de daha hızlı olabilirdik,” dedi. Ceren Hanım adımları saymalarını istedi: Hızlandıkları zaman kontrolsüz nefes alıyor, yavaşladıklarında rahatça konuşabiliyorlardı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Grup için uygun hızın, en hızlı yürüyebilen kişinin temposu olmadığını fark ettiler. Hızlı olmak sporda değerliydi ama doğa yürüyüşünde dayanıklılık, birlikte hareket etme ve karar verme de önemliydi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " bunu duyunca geçen yaz bir bisiklet yarışında arkadaşını geride bırakıp yol ayrımını kaçırdığı günü hatırladı. Daha erken varacağını sanarken yanlış yola sapmıştı. Şimdi haritayı ve grubu takip etmenin neden önemli olduğunu anlıyordu. “Ama bizim amacımız bir yarış kazanmak değil,” diye yanıtladı "
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
          "v": " en başta bunları gereksiz bulmuş, enerjisi varken hızlanmak istemişti. Fakat kar yağışı ve rüzgâr arttıkça her molanın herkesi yeniden toparlamaya yardım ettiğini gördü. Gruptaki çocuklar birbirlerine nefeslerini ve adımlarını ayarlamak için zaman tanıyordu. Böylece kimse yarışın gerisinde kalmış gibi hissetmiyordu. "
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
          "v": ", yardım istemenin grubu yavaşlatmak değil, daha güvenli kılmak olduğunu gördü. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " da çantasındaki yedek boyunluğu Ayşe'ye önerdi; rehber uygun bulunca Ayşe rahatladı. Çocuklar dönüş kavşağındaki sarı işarete ulaştıklarında rüzgâr hafifledi. Hava yine bulutluydu. İleride başlangıç binasının çatısı göründü. "
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
          "v": " telefonundaki göl fotoğraflarını gösterdi. İlk fotoğrafta güneş parlıyordu, ikinci fotoğrafta aynı gölün üstünde bulutlar vardı. “İkisi de bugün çekildi,” dedi. “Ama biri yaz gibi, öbürü kış fırtınası gibi görünüyor.” Ceren Hanım, hava ve ışık değiştikçe aynı manzaranın farklı algılanabileceğini anlattı. Sonra herkese küçük bir görev verdi: Yolculuğun fotoğraf albümünün yanına “gerçek rota defteri” hazırlamak."
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
          "v": " yürüyüş saatlerini ekledi. Birlikte, hava değiştiği için planın hangi noktada değiştirildiğini işaretlediler. "
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
          "v": " yalnızca gölü göstermedi. Rüzgâr kuvvetlendiğinde birlikte durdukları kavşağın fotoğrafını da açtı. “Burada doğru karar verdik,” dedi. “Manzara kadar bunu da hatırlayacağım.” O akşam "
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
          "v": " da haritayı bir kez daha masaya serip dönüş kavşağını gösterdi. “Başlangıçta bu işareti gereksiz sandım,” dedi. “Şimdi neden haritada olduğunu çok iyi biliyorum.” "
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
          "v": " ise en çok dönüş kararını hatırlıyordu. Rehberleri hava değişince hedeflerinden vazgeçmişti. Önce bunu başarısızlık sanmış, sonra anlamıştı: Bazen hedefe varamamak değil, doğru zamanda geri dönmek en iyi karardı. Afişi hazırlarken başka sınıflardan gelen sorular onları şaşırttı. Bir öğrenci, “Buz kalın görünüyorsa üzerine çıkabilir miyiz?” diye sordu. "
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
          "v": "“Harita yanımızdaysa tek başımıza yürüyebilir miyiz?” diye sordu. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", haritanın tek başına güvenlik sağlamadığını, uygun rota, rehberlik, hava değerlendirmesi ve haberleşmenin de önemli olduğunu anlattı. Öğretmenleri çocukların bu sorulara hazırlıklı olmasına sevindi. Ertesi hafta sınıfta bir güvenli yürüyüş afişi hazırladılar. Sınıf arkadaşları onların afişine bakarken güvenli kararların bir ödev kuralından ibaret olmadığını fark etti. Hep birlikte basit bir doğa yürüyüşü kontrol listesi hazırladılar. Afişin üstünde dört işaretli rota ve büyük harflerle tek bir cümle vardı: “Doğayı seviyorsan onu tanı, kurallarına uy ve birlikte hareket et.” "
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
  }
}$p04$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr044-buz-golunun-haritasi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p05${
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
          "v": " ise katalogların da şaşırtıcı sorular doğurabileceğini düşünüyordu. “Bir kitap yanlış raftaysa onu arayan biri bulamaz,” dedi. “Bazen doğru hikâyeye ulaşmak, doğru etiketten geçer.”"
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
          "v": " gülümsemedi. Bir okul kütüphanesinin böyle bir nedenle raf atlamasını mantıklı bulmuyordu. Sevim Hanım da şaşırdı."
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
          "v": ", “Bir odanın değişmesi, içindeki hikâyelerin de değiştiği anlamına gelmez,” dedi. Bu cümleyi tam olarak niçin söylediğini kendisi de bilmiyordu. Belki yıllardır aynı odada başka başka çocukların kitap okuduğunu düşündüğü içindi. İlk defterde rafların el çizimi bir planı vardı. Planın ortasında küçük bir dolap görünüyordu. Yanına yalnızca “Emanet” yazılmıştı. Dolabın numarası ise silinmişti. "
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
          "v": " evde aile kitaplığının fotoğrafını çekip "
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
          "v": " de bütün evlerin aynı düzende olmak zorunda olmadığını fark etti. Ama okul kütüphanesi ortak kullanım içindi; bir öğrenci kitabı aldığı yerde bulabilmeliydi. Bunun için kuralların herkes tarafından anlaşılması gerekiyordu. Sevim Hanım, bazı yıllarda el yazısıyla tutulan kayıtların bilgisayara eksik aktarılabildiğini söyledi. “O zaman on üçüncü raf gerçekten kaybolmuş olabilir,” dedi "
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
          "v": ", “Tabii ki. İşaret, onu kullanan kişinin ne anlatmak istediğine bağlı,” diye cevap verdi. Böylece tablolarına “işaretin olası anlamı” sütununu da eklediler. İki arkadaş sorularını bir tabloda topladı. İlk sütunda kitap numaraları, ikinci sütunda kayıt tarihleri, üçüncü sütunda bulunduğu yer yazıyordu. "
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
          "v": ", eski plandaki koltuğun bulunduğu yere yürüdü. Çocukların bugün sessizce kitap okuduğu köşe bir zamanlar farklı bir amaçla kullanılmıştı. Bir mekânın geçmişini bilmek, ona daha dikkatli bakmasını sağladı. "
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
          "v": "Okul yönetiminin izniyle depodaki eski dolap incelendi. Dolapta birkaç boş çekmece, kullanılmayan kitap destekleri ve üstünde “Bağışlar” yazan kalın bir defter vardı. Sevim Hanım defteri dikkatle açtı. Sayfalar sararmıştı ama kayıtların çoğu okunuyordu. "
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
          "v": "Daha sonraki yıllarda bilim dergileri, çizgi romanlar ve çocuk romanları artmıştı. "
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
          "v": " bu sözleri küçük bir kartın üzerine yazdı; kütüphane düzenlenince görünür bir yere asmak istiyordu. Defterde, yıllar önce mahallede yaşayan insanların okul kütüphanesine kitap gönderdiği yazıyordu. Bazı bağışlar tek kitaptı; bazıları ise bir sınıf dolusu."
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
          "v": " notu okuyunca gözleri doldu. Bir kitabı hiç tanımadığı başka bir çocuğa gönderen kişinin ne kadar umutlu olması gerektiğini düşündü. On üçüncü rafın gizemi, ona bir odadan daha büyük bir şey göstermişti: Okulun zaman içinde büyüyen ortak hafızasını. "
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
          "v": " yeni bir sorun fark etti. Bağış defterindeki bir kitap, dijital katalogda hiç görünmüyordu. Acaba kayıp mıydı? "
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
          "v": " kaydın doğru kitapla eşleştiğini işaretledi."
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
          "v": ", “Bence asıl ilginç olan bu,” dedi. İkili sonunda afişe “On Üçüncü Rafın Unutulan İyiliği” adını verdi. Böylece dikkat çekici bir başlığın gerçekleri değiştirmeden de yazılabileceğini gördüler. O gün pek çok çocuk kütüphaneye geldiğinde yeni bir afiş gördü: “Bir kitabın yolculuğunu merak ettiniz mi?” Afişte kişisel bilgi bulunmuyordu. Yalnızca okul kütüphanesine yıllar boyunca yapılan bağışların sayısı, kitap türleri ve okuma köşesinin geçmişi anlatılıyordu."
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
          "v": " eski on üçüncü rafın yerine küçük bir işaret hazırladı: “Bir zamanlar burada bağış kitaplarının emanet dolabı bulunuyordu.” Sevim Hanım işareti okuma köşesine astı. Sevim Hanım küçük bir kütüphane etkinliği düzenlemelerini istedi."
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
          "v": " de aynı duygudaydı. Sır çözmek güzel bir başlangıçtı; ortaya çıkan bilgiyi başkalarıyla paylaşmak ise hikâyeyi tamamlıyordu. "
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
          "v": "İki arkadaş gelecek hafta küçük öğrencilere kitap seçmede yardımcı olmaya söz verdi. “O zaman da neden öyle göründüğünü öğreniriz.” Bir sonraki hafta kütüphaneye gelen çocukların sayısı biraz arttı. Özellikle "
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
          "v": " artık kitap iade tarihi geldiğinde bunu bir yük olarak görmeyecekti. Kitabı zamanında geri getirirse başka bir okur onu beklediği yerde bulabilecekti. "
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
          "v": " ile birlikte buldukları defter, onu kitaplara daha yakından bakmaya davet etmişti. Artık kütüphaneye girdiğinde yalnızca yeni hikâye değil, eski bir iz de görebiliyordu. "
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
  }
}$p05$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr045-kutuphanenin-on-ucuncu-rafi: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p06${
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
          "v": ", fotoğrafları asan ekibe yardım ederken birbirine benzeyen karelerin ne kadar farklı hikâyeler anlatabileceğini fark etmişti. Bazılarında tören kıyafetleri, bazılarında sıradan okul günleri vardı. Bir fotoğrafta tek bir kişinin adı bilinirken, diğerinde koca bir sınıfın yalnızca yılı yazıyordu. Sibel Hanım her fotoğrafın altına “Bu bilgiyi nereden biliyoruz?” sorusunu yazmalarını istemişti. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " önce bunu gereksiz buldu. Ona göre eski fotoğraf kendi başına yeterince gerçekti. Fakat etiketteki tarihi sorgulamaya başladığında bir fotoğrafın gerçekten var olmasının, altında yazan her bilginin doğru olduğu anlamına gelmediğini gördü."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Okulun kuruluş yıldönümü sergisinde en çok konuşulan şey yeni spor salonu değil, duvardaki eski bir fotoğraftı. Fotoğrafın altında “1984'te İlk Mezunlarımız” yazıyordu. Fakat fotoğraftaki çocukların önünde duran postane binası, bugünkü yerine taşınmadan önceki eski binaya benziyordu. Altıncı sınıftan "
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
          "v": " kenarına boş bir kâğıt yerleştirdi; ilerledikçe buldukları kanıtları aynı yerde tutacaklardı. İkisi farklı kalem renkleri kullandı: maviyle gördüklerini, turuncuyla tahminlerini yazdılar. Bu düzen, daha sonra bir tahminin nasıl yanlışlıkla kesin bilgiye dönüşebileceğini fark etmelerine yardım edecekti. "
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
          "v": "Fakat Sibel Hanım birinin hatırladığı şeyin değerli bir ipucu olabileceğini, tek başına kesin kanıt sayılmayacağını anlattı. Dede Ali, torununun heyecanını görünce çocukluğunu anlatmaya başladı. İlkokula giderken okul yolunun iki yanında kavak ağaçları olduğunu, postanenin yanından geçerken her gün aynı saatlerde bisikletli bir dağıtıcı gördüğünü hatırlıyordu. "
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
          "v": " heyecanı arttı. “Belki fotoğrafın tarihini bu pul söyleyecek!” Dedesi zarfı ona vermeden önce uyardı: “Bu eski bir aile belgesi."
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
          "v": ", pulu büyüteç altında incelemek için kütüphane sorumlusundan yardım istedi. Pulun üzerinde bir kuş, altında iki küçük rakam ve silik bir yazı vardı. "
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
          "v": "Kütüphanedeki eski bir kitapta benzer kuş resimli pullar vardı ancak desenlerin rengi farklıydı. "
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
          "v": ", üzerlerinde kasabanın eski sokaklarının resimleri bulunan zarflar gördü. Bazı zarfların köşesi yıpranmış, bazıları ise oldukça iyi korunmuştu. Emine Hanım, eski belgeleri doğrudan güneş ışığından korumanın ve gerektiğinde uygun koşullarda saklamanın önemini anlattı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " elindeki belgeyi sürekli bir çantadan diğerine taşımanın iyi fikir olmayabileceğini düşündü. Bu nedenle dedesinin zarfını evde bırakmış, müzeye yalnızca yüksek çözünürlüklü görüntüsünü getirmişti. Uzman bunun yerinde bir başlangıç olduğunu söyledi; fotoğrafın belgeyi tamamen incelemeye yetmeyebileceğini de hatırlattı. Çocuklar hangi bilginin görselden, hangisinin asıl belgeden öğrenilebileceğine dikkat etmeye başladı. Müzede görevli Emine Hanım, pulu fotoğraf üzerinden inceledi."
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
          "v": " ikinci çizimde yalnızca gerçekten gördüğü çizgileri aktardı; kalan kısmı boş bıraktı. Bu küçük değişiklik, doğru bir kayıt tutmanın cesaret gerektirebildiğini ona gösterdi. Çünkü herkes tamamlanmış bir şekil görmek isterdi, oysa bazen dürüst olan boşluk bırakmaktı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yarım damgayı kâğıda çizdi. Görünen rakamları işaretledi, görünmeyen yerlere soru işareti koydu. Daha önce böyle yapmaktan hoşlanmazdı; eksik bilgi onu sabırsızlandırırdı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Şimdi soru işaretlerinin araştırmanın dürüst bir parçası olduğunu anlamaya başlamıştı. "
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
          "v": ". “Önce fotoğrafın kendisine bakalım.” Fotoğraftaki okul binasının girişine asılmış bir afiş vardı. Afişte, o yıl düzenlenen bir bilim sergisinin adı okunuyordu. Çocuklar okulun eski yıllıklarını incelediler. Aynı bilim sergisinin bir başka fotoğrafını buldular. Orada tarih daha açık yazılmıştı. Yıllıkların birinde sınıf fotoğraflarının altında tarih, diğerinde yalnızca öğretmen adı vardı. "
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
          "v": "Örneğin okul binasının duvarındaki süsleme, yıllıkların birinde açıkça görünüyordu. İkili bu işareti sergi fotoğrafındaki duvarla karşılaştırdı. Tam eşleşme bulamadılar fakat yeni sorulara ulaştılar: Fotoğraf bir ders günü mü, özel bir tören sırasında mı çekilmişti? Hangi öğretmenler o dönemde okulda çalışıyordu? "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", belgelerde eksik olan bir bilginin başka belgedeki ayrıntılarla araştırılabileceğini öğreniyordu. Ancak yeni kanıt da tek başına yeterli değildi. Bilim sergisi birkaç yıl üst üste düzenlenmiş olabilirdi. "
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
          "v": "Sibel Hanım, güneşin konumunun saat ve mevsimle ilişkili olduğunu ama fotoğrafın kesin tarihini böyle belirlemenin kolay olmadığını söyledi. Binaların duruşunu, çekim açısını ve başka koşulları bilmeden iddialı sonuçlara gidilemezdi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " yine de bu öneriden bir şey öğrendi: Aynı nesneye farklı derslerde kazanılan bilgilerle bakılabilirdi. Matematik, tarih, fen ve Türkçe, bir araştırma masasında birbirine yaklaşabiliyordu. "
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
          "v": " yürürken her köşeyi fotoğraflamaya kalkıştı. Dedesi onu durdurdu: “Bir de bakarak gez. Bütün anıları ekrandan görmek zorunda değilsin.” "
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
          "v": "Dede Ali daha sonra evdeki küçük masa çekmecesinden bir davetiye buldu. Davetiyede eski okul binasının bir etkinliğine ilişkin tarih vardı. "
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
          "v": " bu bilgiyi belediyenin erişime açık tarihî adres kayıtlarıyla karşılaştırmak için öğretmenine danıştı. Kayıtlarda okulun bir dönem geçici bir binada eğitim verdiği görülüyordu. Bu bilgi, fotoğraftaki arka planda neden beklenmeyen binaların göründüğünü açıklıyordu. Çocukların önünde duran yapının gerçekten eski postane olması mümkündü; fotoğraf okulun geçici binasının önünde çekilmiş olabilirdi. Yine de kesin tarih bilinmiyordu. Bu arada okulda farklı tahminler yayılmaya başladı. Bazıları fotoğrafta tanınan bir öğretmenden söz ediyor, bazıları da sergide yazan tarihin zaten doğru olduğunu savunuyordu."
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
          "v": " ilk kez bunun sadece kendi merakı olmadığını gördü. Yanlış bir tarih, insanların aile hikâyelerini de etkileyebilirdi. Sibel Hanım bu yüzden açıklamayı değiştirmeden önce okul yönetimine kısa bir kaynak özeti sunmalarını istedi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " “Kesin bilmediğimiz şeyi de yazalım mı?” diye sordu. “Özellikle onu yazacağız,” dedi öğretmen. “Belirsizliği gizlemek, başkalarının doğru bir karar vermesini zorlaştırır.” Müze görevlisi Emine Hanım, yeniden iletişime geçti. Pulun belirli bir dönemde kullanılan bir seriye benzediğini, ancak damganın fotoğrafından kesin yıl okunamadığını söyledi. "
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
          "v": " buna önce şaşırdı. Bir müzedeki açıklamanın soru işaretiyle bitebileceğini düşünmemişti. Fakat araştırmanın asıl değerinin kesin konuşmak değil, kanıtları dürüstçe kullanmak olduğunu yavaş yavaş kavradı. Etiketi hazırlamadan önce "
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
          "v": " onun ne demek istediğini artık daha kolay anlıyordu. Sibel Hanım bu provayı görünce sevinçle “Bilmediğinizi açıkça söyleyebilmeniz güven verir,” dedi. "
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
          "v": " da aynı fikirdeydi; çalışmanın öğretmenler, arşiv görevlileri, dede ve müze uzmanıyla birlikte yapıldığını düşünüyorlardı. Sonunda hepsine teşekkür eden kısa bir not eklediler. İki öğrenci etiketteki “araştırılıyor” sözcüğünü görünce merakla yanlarına geldi. "
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
          "v": ", anlatımın uzunluğunu dinleyenin ihtiyacına göre ayarlamanın da araştırmanın bir parçası olduğunu fark etti. Sergi günü ziyaretçiler fotoğrafın önünde daha uzun süre durdu. Bazıları kendi aile albümlerindeki eski okul fotoğraflarını hatırladı. Bir veli, “Bu fotoğraf bende de olabilir,” dedi. Okul yönetimi, isterse görüntüyü aileden izin alarak karşılaştırabileceklerini söyledi."
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
          "v": " hemen adını yazmak istemedi. Önce kişinin söylediklerinin ailesindeki bir fotoğrafla desteklenip desteklenemeyeceğini sordu. Ziyaretçi bunun zaman alacağını ama araştırmaya katılmaktan mutluluk duyacağını belirtti. Sibel Hanım, okulun kişisel bilgileri koruyan bir iletişim yolu kullanacağını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " böylece bir gizemi çözmek uğruna insanların adlarını, fotoğraflarını ve hatıralarını gelişigüzel paylaşmamaları gerektiğini de öğrendi. Dede sergiye geldiğinde "
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
          "v": " güldü. “Ben de senin zarfın sayesinde araştırmaya başladım.” Sergi bittikten sonra öğretmenleri öğrencilere bir soru daha yöneltti: “Bir araştırmayı ne zaman tamamlanmış sayarsınız?” "
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
          "v": ", asıl fotoğrafın geçmişten gelen bir belge olduğunu; değişen şeyin ona eklenen açıklama olduğunu söyledi. Fotoğrafı silmek veya değiştirmek yerine doğru bilgiyi aramak daha anlamlıydı. Çocuklar bir süre birlikte kareye baktılar. Bazısı pencereleri, bazısı öğrencilerin ellerindeki defterleri fark etti. "
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
          "v": " arşiv defterini kapatırken zarfın bir kopyasına yeniden baktı. Kuş resimli pul artık ona eski bir eşya gibi görünmüyordu. O pul, yıllar önce birinin bir başkasına gönderdiği haberin küçük bir parçasıydı. Üzerindeki silik damga belki bir gün okunabilecekti, belki de hiçbir zaman kesinleşmeyecekti. "
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
          "v": " başını salladı. “Ben de isterdim. Ama artık çözemediğimiz kısmı uydurmamamız gerektiğini biliyorum.” Birlikte arşive yeni bir dosya açtılar. Dosyanın başlığı “Doğrulananlar ve Açık Sorular” oldu. İçine fotoğrafları, kaynak listelerini ve araştırma notlarını koydular. Zarfın aslı ailesinde güvenle saklandı; okulda yalnızca izinli bir kopyası kullanıldı."
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
          "v": " gülümsedi. “Ancak o saatin neden orada olduğunu ve resmin ne zaman çekildiğini araştırırsak biraz daha yaklaşırız.” Çocuklar artık her eski nesneyi bir tarih makinesi sanmıyordu. Ama her nesnenin yeni bir soru doğurabileceğini biliyorlardı. O akşam "
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
  }
}$p06$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr046-bilinmeyen-posta-pulu: %', v_r; end if;

  v_r := public.okuma_paket_ice_aktar($p07${
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
          "v": " bu maceraya özel bir nedeni daha vardı. Geçen dönem satranç turnuvasında bütün hamlelerini hesapladığını düşünmüş, son oyunda acele bir karar verip yenilmişti. Herkes ona “Biraz düşünseydin” demişti. O günden beri rakamlarla ilgili bir yarış gördüğünde kendini ispatlamak istiyordu. Kırmızı defter de ona böyle bir fırsat gibi görünmüştü. Fakat İrem'in sakinliği ve "
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
          "v": " bu kez onun sözünü kesmedi. Çünkü mühür olmasa defterdeki sayıların okul kütüphanesiyle ilişkisini çok daha geç kuracaklardı. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " ilk sayfaya baktığında şaşırdı: 104, 107, 110, 113... Her yeni sayı bir öncekinden üç büyüktü. “Bu bir oyun skoru olabilir,” dedi takım arkadaşı "
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
          "v": " itiraz etmedi. Ama hemen yanındaki listede 502, 504, 506 gibi başka bir dizi vardı. Puanların neden bir sayfada üçer, başka sayfada ikişer arttığını anlamıyordu. Defteri bulan kulüp başkanı İrem, kapakta “Nöbet” yazdığına dikkat çekti. “Önce defterin ne için tutulduğunu öğrenmeliyiz,” dedi. “Başkasının eşyasını izinsiz karıştırmak da doğru değil.” Öğretmenleri Arif Bey'e danıştılar. Öğretmen, defterin yıllar önce okul kütüphanesinde görevli olan öğrenciler tarafından tutulmuş olabileceğini söyledi. Defter okulun eski evrakları arasından çıkmıştı; içindekilerin incelenmesi için kütüphane sorumlusuyla görüşeceklerdi. "
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
          "v": "Eğer dili çözebilirlerse kimin, ne zaman, neyi kaydettiğini öğrenebileceklerdi. Fakat şifrenin anlamını bulmak için daha fazla ipucu gerekiyordu. İlk araştırma oturumunda Münevver Hanım öğrencilere renkli küçük kâğıtlar verdi. Her kâğıda bir "
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
          "v": " ise kitap kodu seçeneğini ortaya atmış olmanın gururunu yaşıyordu. İrem, “Sevdiğimiz fikri korumaya değil, doğru olanı bulmaya çalışıyoruz,” dedi."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "İki arkadaş önce itiraz etti, sonra bu yöntemle soruları daha kolay sıraya koyabildiklerini gördü. Münevver Hanım masanın üzerine temiz bir örtü serdi. Eski defteri doğrudan güneş ışığı almayan bir yerde açmalarını istedi. "
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
          "v": "Ertesi gün kütüphane sorumlusu Münevver Hanım, defteri kontrollü biçimde incelemelerine izin verdi. Bazı sayfalarda öğrenci isimleri olduğu için bunları herkesin göreceği şekilde paylaşmamalarını istedi. Çocuklar yalnızca kitap kodu olabilecek sayıları inceleyeceklerdi. Örüntünün ilk kuralını bulunca "
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
          "v": ". İrem hemen yeni bir tablo oluşturdu: “Sayı, olası açıklama, kanıt.” İlk satıra “104 — kitap kodu olabilir — henüz doğrulanmadı” yazdı. Araştırma sırasında "
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
          "v": " bunun gizli kulüp rengini temsil ettiğini söyledi. Münevver Hanım gülerek cevap verdi: “Belki de o yıllarda kırtasiyede yalnızca kırmızı defter bulunuyordu.” Çocuklar bir nesnenin her özelliğinin özel anlam taşımak zorunda olmadığını fark etti. Yine de kapak rengi onlara güzel bir isim vermişti: Kırmızı Defterin Şifresi."
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
          "v": " bu adı araştırma defterinin başına yazdı ama altına küçük harflerle “Şifre sözcüğü burada merak için kullanılmıştır” notunu ekledi. İlk kartı incelerken "
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
          "v": " bu kez acele etmedi. “Belki başka kartta daha okunaklıdır,” diye önerdi. Aradılar ve kitabın ikinci bir kaydını buldular. İki kayıt arasındaki farkı belirleyince bir sayının tek başına kaybolmuş bir kitabı göstermediğini, bazen aynı kitap için farklı kayıtlar da bulunduğunu anladılar."
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
          "v": " bunun kitapların içerikleriyle ilgili olduğunu düşündü. Münevver Hanım renklerin eski bir raf sistemine bağlı olabileceğini söyledi, ancak elindeki kayıtta açık bir açıklama bulunmadığını ekledi. Çocuklar bunu araştırma listesine yeni bir soru olarak yazdılar. Münevver Hanım çocuklara eski katalog kartlarından birini gösterdi. Kartta kitap adı, yazar, kayıt numarası ve eski raf yeri yazıyordu. "
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
          "v": ", sayının nerede kaybolduğunu kendi bulunca sevindi. Bu küçük an, yardım etmenin bazen cevabı söylemek yerine yöntemi hatırlatmak olduğunu gösterdi. “Demek bu bir tek sıra değil,” dedi "
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
          "v": " yanlış rafta duran bir kitap fark etti. Sırtında eski bir kod vardı ama raftaki yeni etiketle uyuşmuyordu. Münevver Hanım kitabı alıp güncel katalogdan kontrol etti. Gerçekten de yanlış rafa konmuştu. Defterin sayıları, yıllar önceki kayıtların nasıl tutulduğunu anlamalarına yardım ediyordu. Kırmızı çizginin yanında küçük bir yıldız da vardı. "
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
          "v": " önce hayal kırıklığına uğradı. Sonra bir araştırmacının bütün sorulara aynı anda yanıt bulmasının gerekmeyebileceğini anladı. O sabah okulun kütüphanesinde küçük bir kitap değiştirme etkinliği vardı. "
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
          "v": " kırmızı bir kalemle işaretlenmiş sayfayı gördü. Sayfanın tepesine “Tamamlanmadı” yazılmıştı. Altında beş kitap adı vardı. Üçünün yanında onay, ikisinin yanında boş kare bulunuyordu. “Acaba bu kitaplar kayıp mı?” diye sordu "
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
          "v": " doğru sonuca ulaştı. Defterdeki kodun yalnızca bir kapı anahtarı olmadığını, başka kayıtlarla birlikte kullanıldığında anlam kazandığını gördü. Öğretmenlerine hazırladıkları tabloda “eşleşti” ve “kontrol edilecek” sütunlarını ayrı tuttular. Çocuklar kitabın adını, yazarını ve eski kodunu kullanarak tarama yaptı. İki kitabın farklı bir sınıf kitaplığına aktarılmış olduğunu gösteren belge bulundu. Böylece “kayıp” sözcüğünü kullanmadan önce neden dikkatli olunması gerektiğini anladılar. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": ", sayı dizilerine bakıp bir anda bütün şifreleri çözebildiğini sanmıştı."
        }
      ]
    },
    {
      "omurga": true,
      "parcalar": [
        {
          "t": "metin",
          "v": "Şimdi her rakamın, yanında yazan kelimeye ve kullanıldığı zamana göre anlam kazandığını görüyordu. Matematikte örüntüyü bulmak önemliydi; gerçek bir belgeyi anlamak için örüntünün bağlamını da bilmek gerekiyordu. Sunum hazırlıkları sırasında küçük bir tartışma çıktı. "
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
          "v": " defteri ilk bulduğu sabah kurduğu hazine hayalini hatırladı. Başta bir kapının açılacağını, arkasından eski madalyalar çıkacağını düşünmüştü. Şimdi sıradan kitap kodlarının daha ilginç bir şeye dönüştüğünü görüyordu: Okulun yıllar önce bilgi düzenlemek için geliştirdiği bir yönteme. “Bazen gerçek hikâye hayal ettiğinden daha sessizdir,” dedi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " buna karşı çıktı: “Ama daha çok kişiye dokunabilir.” Çünkü kodlar doğru okunursa birçok öğrenci doğru kitabı daha kolay bulabilirdi."
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
          "v": ", “Ama bundan iyi bir oyun çıkarabiliriz,” diye karşılık verdi. Çocuklar bir sınıf etkinliği tasarladı. Her grubun önüne uydurma kitap kodlarından oluşan üç dizi koydular. Öğrencilerin görevi yalnızca diziyi devam ettirmek değil, farklı açıklamalar arasından hangisinin kanıtlarla uyuştuğunu seçmekti. Etkinlikte en çok tartışılan soru, verilen dizinin devamındaki sayının ne olacağı değildi. “Bu dizinin kitap kodu olduğunu nasıl anlarsınız?” sorusuydu. Bazı öğrenciler eski katalog kartlarını inceledi, bazıları başlıkların benzerliğine baktı."
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
          "v": ", bir grubun bütün sayıları doğru devam ettirdiği hâlde yanlış kitap seçtiğini gördü. Böylece örüntü kuralının doğru olmasıyla belgenin açıklamasının doğru olmasının farklı şeyler olduğunu daha iyi anladı. İrem, oyunun sonunda çocuklardan yalnızca cevabı değil, kullandıkları kanıtı da yazmalarını istedi. İlk gruptaki çocuklar sayıları çözdü ama yanlış sonuca vardı. "
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
          "v": " bunun şaşırtıcı bir bağlantı olduğunu düşündü: Birinin özenle tuttuğu kayıt, başka birinin doğruyu bulmasına yardım edebilirdi. Kırmızı defter okul arşivine güvenle kaldırıldı. Kapak sayfasına, öğrencilere ait kişisel bilgiler paylaşılmadan hazırlanmış kısa bir açıklama eklendi."
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
          "v": " bunun nedenini sorunca, araştırma için hazırladıkları kopyalarla gerçek arşiv belgelerinin ayrı tutulmasının önemini anladı. "
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
          "v": " başlangıçta “Bir yöntem seçelim, herkes ona uysun,” demişti. Münevver Hanım, farklı okurların ihtiyaçlarını dikkate almanın kütüphaneyi daha kullanışlı kılabileceğini anlattı. Çocuklar basit bir arama yönlendirmesi hazırladı: Aradığın kitabın adını biliyorsan katalogdan, konu arıyorsan raf etiketlerinden başla. Bu küçük öneri, çözülmüş bir sayı dizisinin gerçek hayatta nasıl işe yarayabileceğini gösterdi. Dönem sonu geldiğinde satranç kulübü yeni üyelerini karşılamak için tanışma günü düzenledi. "
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
          "v": " “Kırmızı defter sana satrançta da işe yaradı,” dedi. "
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
          "v": " gülümsedi. “Yirmi yedi,” diye cevap verdi. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " yanlarından geçerken “Peki bu sayı neyi gösteriyor?” diye sordu. Artık kızgın ya da acele hissettiğinde de aynı soruyu kendisine yöneltiyordu: “Bunu nereden biliyorum?” Bu, her kararını mükemmel yapmıyordu. Ama düşünmeden konuştuğu anları daha kolay fark etmesine yardım ediyordu. "
        },
        {
          "t": "yoldas",
          "hal": "yalin",
          "yedek": "Hupo"
        },
        {
          "t": "metin",
          "v": " ve İrem de yeni bir bulmaca gördüklerinde önce kanıt arıyorlardı."
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
          "v": " ona kırmızı defterdeki ilk varsayımlarını hatırlattı. “Biz de puan sandık, sonra kontrol ettik,” dedi. İrem, hatanın kaynağını anlamanın yalnızca matematikte değil birçok konuda işe yaradığını söyledi. "
        },
        {
          "t": "kahraman",
          "hal": "yalin"
        },
        {
          "t": "metin",
          "v": " eski sayı tablosuna baktı. Sayıların ardında görmediği düzeni fark etmesi için yalnızca işlem yapması yetmemişti; defterin kim tarafından ve ne amaçla tutulduğunu da anlaması gerekmişti."
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
          "v": " kalemi bıraktı. İlk gün olsaydı sayının bir puan, şifre veya gizli kapı olduğunu hemen söyleyebilirdi. Şimdi İrem'e döndü: “Önce bunun ne için yazıldığını sorayım.” İrem güldü. “Haklısın. Bu sefer yalnızca bir örüntü oyunu.” Bir gün babası "
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
          "v": "Üç yumurta yazıyorsa yanındaki üç sayı puan değil; miktar!” Babası, “İşte "
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
          "v": " okul kütüphanesinde öğrendiklerinin markette bile karşısına çıkmasına şaşırdı. Matematiğin yalnızca kâğıttaki işlemlerden ibaret olmadığını, doğru anlamanın günlük yaşamla bağlantılı olduğunu düşündü. "
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
  }
}$p07$::jsonb, false);
  if not coalesce((v_r ->> 'yazildi')::boolean, false) then raise exception 'paket hr047-kirmizi-defterin-sifresi: %', v_r; end if;

end
$pilot$;

# HR-062 · Hafızası Karışan Android · Ajan B · kör-3
Karar: review_needed
Özet: 5. sınıf bandına (~668 kelime) ve güvenliğe uygun, esprili ve vaazsız; ancak ses kaydı ayrıntıları sayfalar arasında tutarsız, s2-s3 beceri etiketleri hatırlama düzeyinde, çeldiriciler zayıf ve başlık/tanıtım içerikle tam örtüşmüyor.
Bulgular:
- [orta] Sayfa 3 ve 5 (tutarsız kayıt ayrıntısı) : Önce iki kaydın "tost hazırla" ve "çorapları getir" olduğu söyleniyor, sonra ses parçalarında "tabak sesi" ve "kapı gıcırtısı" var deniyor; hata kaynağı bulanıklaşıyor. Alıntı: "Ses parçalarından birinde mutfaktaki tabak sesi, diğerinde koridordaki kapı gıcırtısı bulunuyordu." Öneri: Sayfa 5'te aynı iki ses parçasını (tost / çorap cümleleri) kullan ya da arka plan seslerini ayrı bir bulgu olarak açıkça belirt.
- [orta] s2 ve s3 (beceri etiketi) : Yanıtlar dayanak cümlelerinin birebir karşılığı; çıkarım ve yorumlama etiketi hatırlamaya yakın. Alıntı: "Robot, iki farklı ses kaydını tek komut sanmıştı." Öneri: Yeni bir durumda hatanın nedenini sor ya da etiketi hatirlama yap.
- [orta] Mantık/anlatı (hata gerekçesi zayıf) : Karışık kayıt "yalnızca çorap" getirmesine yol açmış gibi sunuluyor, ama ilk komut tosttu; neden tost getirilmedi, açıklanmıyor ve "yalnızca eşyaları seçerken de kararsız kaldığını" cümlesi anlamsız. Alıntı: "ARO bu birleşik kaydı uygulamış, yalnızca eşyaları seçerken de kararsız kaldığını bildirmişti." Öneri: "Robot birleşik kaydın son bölümünü tek komut sanıp çorapları getirdi" gibi net bir zincir yaz.
- [düşük] s1, s2 ve s4 (çeldirici) : Çeldiriciler kolay elenir ve konuyla ilgisiz. Alıntı: "Ekmeğin masadan düşmesi". Öneri: Daha makul yanlış nedenler yaz (ör. "Mikrofonun bozulması", "Hoparlörün kapalı olması").
- [düşük] Sayfa 2 (sesteşlik kolu) : "Yüz" örneği uzun ama sonunda hikâyeyle ilgisi yok olarak çıkıyor (kırmızı ringa), hedefle ilgili soru da yok. Alıntı: "Kaydı baştan sona taradılar; böyle bir sözcük yoktu." Öneri: Kısalt veya bir soruya bağla.
- [düşük] Başlık/tanıtım : Sorun hafıza değil, işitme/kayıt birleşmesi; ARO ise robot, "android" değil; tanıtım "verideki bir eksik" derken hikâyede eksik değil birleşme var. Alıntı: "Hata nerede: robotta mı, komutta mı, verideki bir eksikte mi?" Öneri: Başlık ve tanıtımı "Kulağı Acele Eden Robot" gibi düzelt.
- [düşük] Akıcılık : Yer yer yapay cümle: "Ekrandaki algoritma, robotun izleyeceği işlem adımlarını gösteriyordu." (yukarıdaki cümlenin tekrarı). Öneri: Birine indir.
Doğrulanamayan iddialar: yetiskin_uygun ve D16 değer eşlemesi doğrulanamadı; "sesteşlik: yüz" örneği (yüz sayısı, yüz eylemi, yüz organı) dilbilgisel olarak doğru, ancak sözlük kaynağıyla karşılaştırılmadı.
Güçlü yanlar:
- Veri, hata ve doğrulama kavramı eğlenceli bir olayla işleniyor; "Kulak birimi bulunamadı" gibi esprili ama çocuk dostu detaylar var.
- Güvenlik doğru: sıcak aleti yetişkin kullanacak, robot yalnız malzeme taşıyor, eski kayıt silinmeden işaretleniyor.
- Doğrulama adımı (komutu ekranda göster, onayla) somut ve tekrar deneme ile sınanıyor.

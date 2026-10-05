/// Hupo duruşları.
///
/// İki tür var:
///  * Saydam eski duruşlar (assets/hupo/*.png): sayfaya serbestçe oturur.
///  * Master Hupo ifade kartları (assets/hupo/ifade, assets/hupo/uygulama; *.webp):
///    mavi fonlu karedir, köşeleri yuvarlatılarak "çıkartma" gibi gösterilir.
///    Yeni çizim stili bu kartlardadır; anlar (HupoMood) önce bunları kullanır.
enum HupoPose {
  // ── Eski saydam duruşlar ────────────────────────────────────────────────
  ayakta('ayakta'),
  karsilama('karsilama'),
  merakli('merakli'),
  sevimli('sevimli'),
  dost('dost'),
  tesvik('tesvik'),
  uzulen('uzulen'),
  dusunen('dusunen'),
  sorgulayan('sorgulayan'),
  sasiran('sasiran'),
  basaran('basaran'),
  tebrikler('tebrikler'),
  muthis('muthis'),
  harikasin('harikasin'),
  hizli('hizli'),
  birazCalis('biraz_calis'),
  sakinVazgecme('sakin_vazgecme'),
  sakinPesEtme('sakin_pes_etme'),
  sabirli('sabirli'),
  ozletme('ozletme'),

  // ── Master Hupo ifade kartları ──────────────────────────────────────────
  acele('acele', klasor: 'ifade'),
  adimAdim('adim_adim', klasor: 'ifade'),
  ahaaa('ahaaa', klasor: 'ifade'),
  birDahaDene('bir_daha_dene', klasor: 'ifade'),
  cokYaklastin('cok_yaklastin', klasor: 'ifade'),
  cozum('cozum', klasor: 'ifade'),
  dogru('dogru', klasor: 'ifade'),
  dusunuyor('dusunuyor', klasor: 'ifade'),
  gunlukHedef('gunluk_hedef', klasor: 'ifade'),
  harika('harika', klasor: 'ifade'),
  hazirMisin('hazir_misin', klasor: 'ifade'),
  hosgeldin('hosgeldin', klasor: 'ifade'),
  ipucuIster('ipucu_ister', klasor: 'ifade'),
  ipucuBuldu('ipucu_buldu', klasor: 'ifade'),
  konuTamamlandi('konu_tamamlandi', klasor: 'ifade'),
  merakEdiyor('merak_ediyor', klasor: 'ifade'),
  seriDevam('seri_devam', klasor: 'ifade'),
  seriTehlikede('seri_tehlikede', klasor: 'ifade'),
  zorSoruydu('zor_soruydu', klasor: 'ifade'),
  sasirmis('sasirmis', klasor: 'ifade'),
  uzgun('uzgun', klasor: 'ifade'),

  // ── Soru ekranı rehberi (dikdörtgen kart) ───────────────────────────────
  rehber('rehber', klasor: 'uygulama', oran: 0.8),
  rehberSol('rehber_sol', klasor: 'uygulama', oran: 0.75);

  const HupoPose(this.slug, {this.klasor, this.oran = 1});

  final String slug;

  /// Doluysa Master Hupo kartıdır (`assets/hupo/klasor/slug.webp`).
  final String? klasor;

  /// Kart görselinin genişlik / yükseklik oranı.
  final double oran;

  bool get kart => klasor != null;

  String get assetPath =>
      kart ? 'assets/hupo/$klasor/$slug.webp' : 'assets/hupo/$slug.png';
}

/// Uygulamadaki anlar. Her an, sırayla dönen birkaç duruş arasından seçilir;
/// böylece Hupo her seferinde aynı pozu tekrarlamaz.
enum HupoMood {
  /// Ana sayfa karşılaması.
  greeting([HupoPose.hosgeldin, HupoPose.hazirMisin, HupoPose.merakEdiyor]),

  /// Giriş / kayıt / onay ekranları.
  welcome([HupoPose.hosgeldin, HupoPose.hazirMisin]),

  /// Doğru cevap.
  correct([HupoPose.dogru, HupoPose.harika, HupoPose.ahaaa]),

  /// Yanlış cevap: asla utandırmaz, cesaretlendirir.
  wrong([
    HupoPose.zorSoruydu,
    HupoPose.cokYaklastin,
    HupoPose.birDahaDene,
    HupoPose.adimAdim,
  ]),

  /// "Tekrar dene" önerisi: yüklenemeyen bölümler, yeniden deneme düğmeleri.
  retry([HupoPose.birDahaDene]),

  /// Süre daralıyor / hız.
  hurry([HupoPose.acele]),

  /// Seri tehlikede.
  streakRisk([HupoPose.seriTehlikede]),

  /// Seri kalkanı kazanıldı.
  shieldEarned([HupoPose.harika, HupoPose.seriDevam]),

  /// Seri sürüyor.
  streakOn([HupoPose.seriDevam]),

  /// Günlük hedef tamamlandı.
  goalComplete([HupoPose.gunlukHedef]),

  /// Düşünme, yükleniyor.
  thinking([HupoPose.dusunuyor]),

  /// Soru ekranında sakin rehber.
  question([HupoPose.rehber, HupoPose.rehberSol]),

  /// İpucu önerisi ve bulunan ipucu.
  hint([HupoPose.ipucuIster, HupoPose.ipucuBuldu]),

  /// Çözüm anlatımı.
  solution([HupoPose.cozum, HupoPose.adimAdim]),

  /// Boş durumlar.
  empty([HupoPose.merakEdiyor, HupoPose.dusunuyor]),

  /// Hata / beklenmedik durum.
  error([HupoPose.sasirmis]),

  /// Sonuç ekranı: harika.
  resultHigh([HupoPose.harika, HupoPose.konuTamamlandi, HupoPose.dogru]),

  /// Sonuç ekranı: biraz daha çalışırsan olur.
  resultLow([HupoPose.cokYaklastin, HupoPose.birDahaDene, HupoPose.adimAdim]),

  /// Rozet ve tören anları.
  celebrate([HupoPose.konuTamamlandi, HupoPose.harika, HupoPose.gunlukHedef]);

  const HupoMood(this.poses);

  final List<HupoPose> poses;

  /// [variant] (örn. gün numarası ya da soru sırası) ile duruş seçer.
  HupoPose pose([int variant = 0]) => poses[variant.abs() % poses.length];
}

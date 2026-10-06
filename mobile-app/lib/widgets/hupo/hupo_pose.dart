/// Hupo duruşları: Master Hupo çizimleri, şeffaf WebP (assets/hupo/ifade, assets/hupo/uygulama).
/// Hepsi kare tuvalde, altta ortalı durur ve zemine serbestçe oturur (kart/arka plan yok).
/// Anlar (HupoMood) bunlardan birini seçer.
enum HupoPose {
  ayakta('hosgeldin', klasor: 'ifade'),
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

  // ── Soru ekranı rehberi ─────────────────────────────────────────────────
  rehber('rehber', klasor: 'uygulama'),
  rehberSol('rehber_sol', klasor: 'uygulama');

  const HupoPose(this.slug, {required this.klasor});

  final String slug;
  final String klasor;

  String get assetPath => 'assets/hupo/$klasor/$slug.webp';
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

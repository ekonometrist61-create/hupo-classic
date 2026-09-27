/// Hupo karakter sayfalarından çıkarılmış duruşlar (assets/hupo klasörü, dosya adı = slug).
enum HupoPose {
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
  ozletme('ozletme');

  const HupoPose(this.slug);

  final String slug;

  String get assetPath => 'assets/hupo/$slug.png';
}

/// Uygulamadaki anlar. Her an, sırayla dönen birkaç duruş arasından seçilir;
/// böylece Hupo her seferinde aynı pozu tekrarlamaz.
enum HupoMood {
  /// Ana sayfa karşılaması.
  greeting([HupoPose.sevimli, HupoPose.merakli, HupoPose.ayakta]),

  /// Giriş / kayıt / onay ekranları.
  welcome([HupoPose.dost, HupoPose.karsilama]),

  /// Doğru cevap.
  correct([HupoPose.tebrikler, HupoPose.muthis, HupoPose.harikasin, HupoPose.basaran]),

  /// Yanlış cevap: asla utandırmaz, cesaretlendirir.
  wrong([HupoPose.tesvik, HupoPose.sabirli]),

  /// Süre daralıyor / hız.
  hurry([HupoPose.hizli]),

  /// Seri tehlikede.
  streakRisk([HupoPose.sakinVazgecme, HupoPose.ozletme]),

  /// Seri kalkanı kazanıldı.
  shieldEarned([HupoPose.harikasin, HupoPose.basaran]),

  /// Günlük hedef tamamlandı.
  goalComplete([HupoPose.muthis]),

  /// Düşünme, ipucu, yükleniyor.
  thinking([HupoPose.dusunen]),

  /// Boş durumlar.
  empty([HupoPose.merakli, HupoPose.sorgulayan]),

  /// Hata / beklenmedik durum.
  error([HupoPose.sasiran]),

  /// Sonuç ekranı: harika.
  resultHigh([HupoPose.harikasin, HupoPose.basaran, HupoPose.muthis]),

  /// Sonuç ekranı: biraz daha çalışırsan olur.
  resultLow([HupoPose.birazCalis, HupoPose.tesvik]),

  /// Rozet ve tören anları.
  celebrate([HupoPose.muthis, HupoPose.tebrikler]);

  const HupoMood(this.poses);

  final List<HupoPose> poses;

  /// [variant] (örn. gün numarası ya da soru sırası) ile duruş seçer.
  HupoPose pose([int variant = 0]) => poses[variant.abs() % poses.length];
}

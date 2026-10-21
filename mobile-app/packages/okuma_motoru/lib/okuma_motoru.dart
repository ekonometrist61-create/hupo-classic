/// Okuma Dünyası motoru: tek giriş noktası.
///
/// Uygulama `package:okuma_motoru/okuma_motoru.dart` ile içe aktarır. Motorun parça
/// sınıfı `Metin`, uygulamadaki metin sabitleriyle karışmasın diye bu dosya yalnız
/// çözücünün dışarıya açılması gereken adlarını gösterir.
library;

export 'hikaye_cozucu.dart'
    show Baglam, Cikti, HikayeHatasi, Hikaye, Stil, YuvaAdayi, sayfalariCoz;
export 'gosterim_kurallari.dart'
    show
        SayfaButcesi,
        SayfaSecimi,
        hikayeSecimi,
        sayfaButcesi,
        kHikayeAtasozuSiniri,
        kSayfaKesifSiniri;
export 'ikon_kayit.dart'
    show
        IkonKaydi,
        ikonBul,
        ikonKimligiCoz,
        ikonKatalogu,
        kIkonVarlikKlasoru,
        kMaskotIkonKimligi;
export 'paket.dart' show hikayeFromPaket, yuvalarFromSozluk;
export 'sure.dart' show okumaDakikasi, okumaHizi;
export 'turkce_ad.dart' show Hal, ekle;

/// Bu uygulama sürümünün açabildiği en yüksek paket motoru sürümü.
/// `okuma_hikaye_getir` yanıtındaki `min_motor_surumu` bundan büyükse "güncelle" denir.
const int kMotorSurumu = 1;

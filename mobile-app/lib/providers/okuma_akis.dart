// Okuma Dünyası: tek hikâyenin akışı (kahraman → liste → okuma → sorular → anket → sonuç).
//
// Sunucu işleri repository'dedir; bu sınıf yalnız sırayı yönetir. Cevap anahtarı istemcide yoktur:
// doğru/yanlış her zaman `okuma_cevap_kontrol` yanıtından gelir.
//
// Gizlilik: kahraman ve yol arkadaşı adı yalnız bu sınıfın belleğinde ve metni çözerken kullanılır.
// Sunucu çağrılarına, hata metinlerine ve günlüğe girmez.

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:okuma_motoru/okuma_motoru.dart';

import '../models/okuma_kahraman.dart';
import '../models/okuma_models.dart';
import '../services/okuma_cihaz_deposu.dart';
import '../services/okuma_pdf_hizmeti.dart';
import '../services/okuma_repository.dart';
import '../services/okuma_sozluk.dart';

enum OkumaAsama { kahraman, liste, yukleniyor, okuma, sorular, anket, bitiriliyor, sonuc, kota, hata }

enum OkumaPdfSonucu { hazir, hakYok, hata }

const String _mesajHikayeAcilamadi = 'Bu hikâye şu an açılamıyor. Başka bir hikâye seçebilirsin.';
const String _mesajSorularIcinBaglanti = 'Sorulara geçmek için internet bağlantısı gerekiyor. Bağlanınca yeniden dene.';
const String _mesajKatalogYuklenemedi = 'Hikâyeler yüklenemedi. Yeniden dene.';
const String _mesajSonucYuklenemedi = 'Sonucun kaydedilemedi. Yeniden dene.';

/// Akışın anlık durumu. Ekranlar yalnız bunu okur.
class OkumaAkisDurumu {
  const OkumaAkisDurumu({
    this.asama = OkumaAsama.kahraman,
    this.kahraman,
    this.katalog = const [],
    this.katalogYukleniyor = false,
    this.katalogHatasi,
    this.secilen,
    this.paket,
    this.sayfalar = const [],
    this.anlamlar = const {},
    this.sorular = const [],
    this.oturum,
    this.cevrimdisi = false,
    this.dogruSayisi = 0,
    this.sonuc,
    this.hataMesaji,
    this.oneri,
    this.anketUyarisi = false,
  });

  final OkumaAsama asama;
  final KahramanSecimi? kahraman;
  final List<OkumaKatalogSatiri> katalog;
  final bool katalogYukleniyor;
  final String? katalogHatasi;
  final OkumaKatalogSatiri? secilen;
  final OkumaPaketi? paket;
  final List<List<Cikti>> sayfalar;
  final Map<String, String> anlamlar;
  final List<OkumaSoru> sorular;
  final OkumaOturum? oturum;

  /// Paket önbellekten açıldı ve oturum kurulamadı (internet yok): yalnız okuma.
  final bool cevrimdisi;
  final int dogruSayisi;
  final OkumaSonuc? sonuc;
  final String? hataMesaji;
  final OkumaSeriVeOneri? oneri;
  final bool anketUyarisi;
}

class OkumaAkisDenetleyici extends StateNotifier<OkumaAkisDurumu> {
  OkumaAkisDenetleyici({
    required OkumaRepository repo,
    required OkumaPaketOnbellegi onbellek,
    required OkumaCihazDeposu depo,
    required OkumaPdfUretici pdfUretici,
    required DateTime Function() simdi,
    required String Function() okumaModu,
  })  : _repo = repo,
        _onbellek = onbellek,
        _depo = depo,
        _pdfUretici = pdfUretici,
        _simdi = simdi,
        _modu = okumaModu,
        super(const OkumaAkisDurumu());

  final OkumaRepository _repo;
  final OkumaPaketOnbellegi _onbellek;
  final OkumaCihazDeposu _depo;
  final OkumaPdfUretici _pdfUretici;
  final DateTime Function() _simdi;
  final String Function() _modu;

  KahramanSecimi? _kahraman;
  List<OkumaKatalogSatiri> _katalog = const [];
  bool _katalogYukleniyor = false;
  String? _katalogHatasi;
  OkumaKatalogSatiri? _secilen;
  OkumaPaketi? _paket;
  OkumaSozluk? _sozluk;
  List<List<Cikti>> _sayfalar = const [];
  List<OkumaSoru> _sorular = const [];
  OkumaOturum? _oturum;
  bool _cevrimdisi = false;
  int _dogru = 0;
  OkumaSonuc? _sonuc;
  OkumaSeriVeOneri? _oneri;
  String? _hata;
  bool _anketUyarisi = false;
  OkumaAsama _asama = OkumaAsama.kahraman;
  String? _istemciAnahtari;
  Future<OkumaSonuc>? _bitirIstegi;
  final Set<String> _dokunulan = {};
  final Map<String, String> _dogruAnahtari = {};
  int _sonIlerleme = -1;

  void _yay() {
    if (!mounted) return;
    state = OkumaAkisDurumu(
      asama: _asama,
      kahraman: _kahraman,
      katalog: _katalog,
      katalogYukleniyor: _katalogYukleniyor,
      katalogHatasi: _katalogHatasi,
      secilen: _secilen,
      paket: _paket,
      sayfalar: _sayfalar,
      anlamlar: _sozluk?.anlamlar ?? const {},
      sorular: _sorular,
      oturum: _oturum,
      cevrimdisi: _cevrimdisi,
      dogruSayisi: _dogru,
      sonuc: _sonuc,
      hataMesaji: _hata,
      oneri: _oneri,
      anketUyarisi: _anketUyarisi,
    );
  }

  void _asamaDegistir(OkumaAsama a, {String? hata}) {
    _asama = a;
    _hata = hata;
    _yay();
  }

  // ── Kahraman ve liste ──────────────────────────────────────────────────────

  /// Kahraman seçildi; ad yalnız bellekte tutulur. Liste yüklenir.
  ///
  /// [ac] verilirse (Öğren kartından ya da "Okuduklarım"dan gelen hikâye) liste atlanır ve
  /// doğrudan o hikâye açılır; hikâye bu kahramana uygun değilse liste açılır.
  Future<void> kahramanSec(KahramanSecimi secim, {OkumaKatalogSatiri? ac}) async {
    _kahraman = secim;
    if (ac != null && (ac.izinliTurler.isEmpty || ac.izinliTurler.contains(secim.tur.kod))) {
      await hikayeSec(ac);
      return;
    }
    _asamaDegistir(OkumaAsama.liste);
    await katalogYukle();
  }

  Future<void> katalogYukle() async {
    final kahraman = _kahraman;
    if (kahraman == null) return;
    _katalogYukleniyor = true;
    _katalogHatasi = null;
    _yay();
    try {
      _katalog = await _repo.katalog(kahramanTuru: kahraman.tur.kod);
    } on OkumaException catch (e) {
      _katalog = const [];
      _katalogHatasi = e.hata == OkumaHatasi.baglanti ? e.mesaj : (e.mesaj.isEmpty ? _mesajKatalogYuklenemedi : e.mesaj);
    }
    _katalogYukleniyor = false;
    _yay();
  }

  void kahramanaDon() {
    _kahraman = null;
    _katalog = const [];
    _asamaDegistir(OkumaAsama.kahraman);
  }

  void listeyeDon() {
    _sonuc = null;
    _oneri = null;
    _asamaDegistir(OkumaAsama.liste);
    if (_katalog.isEmpty && !_katalogYukleniyor) katalogYukle();
  }

  // ── Hikâye açma ────────────────────────────────────────────────────────────

  /// Seçilen hikâyeyi açar: önbellek → paket indirme → oturum → çözme.
  Future<void> hikayeSec(OkumaKatalogSatiri satir) async {
    final kahraman = _kahraman;
    if (kahraman == null) return;
    _secilen = satir;
    _sonuc = null;
    _oneri = null;
    _dogru = 0;
    _dogruAnahtari.clear();
    _dokunulan.clear();
    _sonIlerleme = -1;
    _cevrimdisi = false;
    _oturum = null;
    _bitirIstegi = null;
    _istemciAnahtari = _anahtarUret();
    _asamaDegistir(OkumaAsama.yukleniyor);
    await _ac();
  }

  Future<void> _ac() async {
    final satir = _secilen;
    final kahraman = _kahraman;
    if (satir == null || kahraman == null) return;

    // 1) Paket: geçerli önbellek varsa indirme ve kota harcanmaz.
    OkumaPaketi? paket = _onbellek.gecerliPaket(satir);
    var onbellektenEski = false;
    if (paket == null) {
      try {
        paket = await _repo.hikayeGetir(satir.hikayeId);
        await _onbellek.yaz(paket);
      } on OkumaException catch (e) {
        if (e.hata == OkumaHatasi.kotaDoldu) {
          _asamaDegistir(OkumaAsama.kota);
          return;
        }
        final eski = e.hata == OkumaHatasi.baglanti ? _onbellek.oku(satir.hikayeId) : null;
        if (eski == null) {
          _hataGoster(_Adim.ac, e.mesaj);
          return;
        }
        paket = eski; // internet yok: son indirilen sürümle tekrar okuma
        onbellektenEski = true;
      }
    }
    if (paket.minMotorSurumu > kMotorSurumu) {
      _hataGoster(_Adim.ac, okumaMotorEskiHatasi.mesaj);
      return;
    }

    // 2) Cihazda çöz (ad yalnız burada metne girer).
    try {
      final sozluk = okumaSozluguKur(paket);
      _sayfalar = okumaSayfalariniCoz(
        paket,
        sozluk,
        kahramanAdi: kahraman.ad,
        kahramanTuru: kahraman.tur.kod,
        yoldasAdi: kahraman.yoldasVar ? kahraman.yoldasAd : null,
      );
      _sozluk = sozluk;
      _sorular = paket.sorular;
      _paket = paket;
    } on HikayeHatasi {
      // Hata metni (ad içerebilir) bilerek kullanıcıya ve günlüğe taşınmaz.
      _hataGoster(_Adim.ac, _mesajHikayeAcilamadi);
      return;
    } on Object {
      _hataGoster(_Adim.ac, _mesajHikayeAcilamadi);
      return;
    }

    // 3) Oturum: kota burada da denetlenir. İnternet yoksa önbellekten salt okuma.
    final oturumSonucu = await _oturumKur();
    if (oturumSonucu == OkumaHatasi.kotaDoldu) {
      _asamaDegistir(OkumaAsama.kota);
      return;
    }
    if (oturumSonucu != null && oturumSonucu != OkumaHatasi.baglanti) {
      _hataGoster(_Adim.ac, _hataMesaji(oturumSonucu));
      return;
    }
    if (oturumSonucu == OkumaHatasi.baglanti && !(onbellektenEski || _onbellek.oku(satir.hikayeId) != null)) {
      _hataGoster(_Adim.ac, okumaBaglantiHatasi.mesaj);
      return;
    }
    _cevrimdisi = _oturum == null;
    _asamaDegistir(OkumaAsama.okuma);
  }

  String _hataMesaji(OkumaHatasi h) => switch (h) {
        OkumaHatasi.hizSiniri => okumaHatasiCevir('RATE_LIMIT').mesaj,
        OkumaHatasi.cakisma => okumaHatasiCevir('IDEMPOTENCY_CONFLICT').mesaj,
        OkumaHatasi.kapali => okumaHatasiCevir('OKUMA_KAPALI').mesaj,
        OkumaHatasi.hikayeBulunamadi => okumaHatasiCevir('HIKAYE_BULUNAMADI').mesaj,
        OkumaHatasi.gecersizIstek => okumaHatasiCevir('BAD_SORU').mesaj,
        _ => okumaHatasiCevir('').mesaj,
      };

  /// Oturumu kurar. Başarısızsa hata türünü döner (null = başarılı). Aynı deneme anahtarı tekrar kullanılır.
  Future<OkumaHatasi?> _oturumKur() async {
    final satir = _secilen;
    final kahraman = _kahraman;
    if (satir == null || kahraman == null) return OkumaHatasi.bilinmeyen;
    try {
      _oturum = await _repo.oturumBaslat(
        hikayeId: satir.hikayeId,
        kahramanTuru: kahraman.tur.kod,
        yoldasVar: kahraman.yoldasVar,
        okumaModu: _modu(),
        istemciAnahtari: _istemciAnahtari ??= _anahtarUret(),
      );
      return null;
    } on OkumaException catch (e) {
      return e.hata;
    }
  }

  static String _anahtarUret() {
    final r = Random.secure();
    return List.generate(32, (_) => r.nextInt(16).toRadixString(16)).join();
  }

  // ── Okuma ──────────────────────────────────────────────────────────────────

  /// Görülen sayfa (0 tabanlı). Bırakılan sayfa analitiği içindir; başarısızlık akışı bozmaz.
  void sayfaGorundu(int indeks) {
    final oturum = _oturum;
    if (oturum == null) return;
    final sayfa = (indeks + 1).clamp(0, 12);
    if (sayfa <= _sonIlerleme) return;
    _sonIlerleme = sayfa;
    // Analitik amaçlı; hata kullanıcıya yansımaz ve okumayı kesmez (sözleşme: geri gitmez, tek yönlü).
    _repo.ilerlemeKaydet(oturumId: oturum.oturumId, sayfa: sayfa).then((_) {}, onError: (Object _) {});
  }

  /// Okuyucuda dokunulan sözcük/deyim/atasözü metni.
  void sozcukAcildi(String metin) => _dokunulan.add(metin);

  /// Son sayfadan "Sorulara geç".
  Future<void> okumaBitti() async {
    if (_oturum == null) {
      // Çevrimdışı okundu: sorular için oturum gerekir.
      final sonuc = await _oturumKur();
      if (sonuc != null) {
        _hataGoster(_Adim.oturumSorular, sonuc == OkumaHatasi.baglanti ? _mesajSorularIcinBaglanti : _hataMesaji(sonuc));
        return;
      }
      _cevrimdisi = false;
    }
    if (_sorular.isEmpty) {
      await sorularBitti(0);
      return;
    }
    _asamaDegistir(OkumaAsama.sorular);
  }

  // ── Sorular ────────────────────────────────────────────────────────────────

  /// Cevap sunucuda kontrol edilir (tek deneme; tekrar çağrı kayıtlı sonucu döner).
  Future<OkumaCevapSonucu> cevapKontrol(String soruId, String secenekId) async {
    final oturum = _oturum;
    if (oturum == null) throw okumaBaglantiHatasi;
    final sonuc = await _repo.cevapKontrol(oturumId: oturum.oturumId, soruId: soruId, secenekId: secenekId);
    _dogruAnahtari[soruId] = sonuc.dogruSecenekId;
    return sonuc;
  }

  /// Sorular bitti; sonuç arka planda alınır, çocuk anketi görür.
  Future<void> sorularBitti(int dogruSayisi) async {
    _dogru = dogruSayisi;
    _bitirBaslat();
    _asamaDegistir(OkumaAsama.anket);
  }

  void _bitirBaslat() {
    final oturum = _oturum;
    final paket = _paket;
    if (oturum == null || paket == null) return;
    final istek = _repo.oturumBitir(
      oturumId: oturum.oturumId,
      dokunulan: dokunulanHedefKimlikleri(paket, _dokunulan),
    );
    istek.then((_) {}, onError: (Object _) {}); // Hata, sonuç beklenirken ele alınır.
    _bitirIstegi = istek;
  }

  // ── Anket ve sonuç ─────────────────────────────────────────────────────────

  /// Anket tamamlandı ya da atlandı. Yanıt gönderilemezse akış yine sürer (anket ödülsüzdür).
  Future<void> anketBitti(OkumaAnketYaniti? yanit) async {
    final oturum = _oturum;
    _anketUyarisi = false;
    if (yanit != null && yanit.gonderilebilir && oturum != null) {
      try {
        await _repo.geriBildirimGonder(oturumId: oturum.oturumId, yanit: yanit);
      } on OkumaException {
        _anketUyarisi = true;
      }
    }
    await _sonucuBekle();
  }

  Future<void> _sonucuBekle() async {
    _asamaDegistir(OkumaAsama.bitiriliyor);
    if (_bitirIstegi == null) _bitirBaslat();
    final istek = _bitirIstegi;
    if (istek == null) {
      _hataGoster(_Adim.sonuc, _mesajSonucYuklenemedi);
      return;
    }
    try {
      _sonuc = await istek;
    } on OkumaException catch (e) {
      _bitirIstegi = null; // yeniden denemede taze istek (sunucu idempotent)
      _hataGoster(_Adim.sonuc, e.hata == OkumaHatasi.baglanti ? e.mesaj : _mesajSonucYuklenemedi);
      return;
    }
    final satir = _secilen;
    if (satir != null) await _depo.okunduYaz(satir, simdi: _simdi());
    try {
      _oneri = await _repo.seriVeOneri();
    } on OkumaException {
      _oneri = null; // öneri isteğe bağlı; sonuç ekranı yine de açılır
    }
    _asamaDegistir(OkumaAsama.sonuc);
  }

  /// Hata ekranındaki "Yeniden dene": hatanın geldiği adımı tekrarlar.
  Future<void> yenidenDene() async {
    switch (_hataAdimi) {
      case _Adim.ac:
        _asamaDegistir(OkumaAsama.yukleniyor);
        await _ac();
      case _Adim.oturumSorular:
        await okumaBitti();
      case _Adim.sonuc:
        await _sonucuBekle();
    }
  }

  /// Hata ekranını açar ve "Yeniden dene"nin hangi adımı tekrarlayacağını not eder.
  void _hataGoster(_Adim adim, String mesaj) {
    _hataAdimi = adim;
    _asamaDegistir(OkumaAsama.hata, hata: mesaj);
  }

  _Adim _hataAdimi = _Adim.ac;

  // ── Sonuç sonrası ──────────────────────────────────────────────────────────

  /// Önerilen hikâyeyi aynı kahramanla açar (türü uygunsa); değilse listeye döner.
  Future<void> oneriyiAc() async {
    final oneri = _oneri?.oneri;
    final kahraman = _kahraman;
    if (oneri == null || kahraman == null || !oneri.izinliTurler.contains(kahraman.tur.kod)) {
      listeyeDon();
      return;
    }
    await hikayeSec(oneri);
  }

  /// PDF: önce sunucuda hak denetimi, sonra cihazda üretim. PDF'te çocuk adı yoktur.
  Future<OkumaPdfSonucu> pdfIndir() async {
    final satir = _secilen;
    final paket = _paket;
    final kahraman = _kahraman;
    if (satir == null || paket == null || kahraman == null) return OkumaPdfSonucu.hata;
    try {
      final hak = await _repo.pdfHakkiKullan(satir.hikayeId);
      if (!hak.izin) return OkumaPdfSonucu.hakYok;
    } on OkumaException {
      return OkumaPdfSonucu.hata;
    }
    try {
      final hazirVar = paket.izinliTurler.contains('hazir');
      final sayfalar = okumaSayfalariniCoz(
        paket,
        _sozluk ?? okumaSozluguKur(paket),
        kahramanAdi: hazirVar ? kHazirKahramanAdi : 'Kahraman',
        kahramanTuru: hazirVar ? 'hazir' : kahraman.tur.kod,
      );
      await _pdfUretici(
        OkumaPdfIstegi(
          baslik: paket.baslik,
          tanitim: paket.tanitim,
          dosyaAdi: '${satir.slug}.pdf',
          sinif: satir.anaSinif,
          sahneSlug: satir.slug,
          sayfalar: sayfalar,
          sorular: [
            for (final s in paket.sorular)
              OkumaPdfSorusu(
                metin: s.metin,
                secenekler: [for (final o in s.secenekler) (o.id, o.metin)],
                dogru: _dogruAnahtari[s.id],
              ),
          ],
        ),
      );
      return OkumaPdfSonucu.hazir;
    } on Object {
      return OkumaPdfSonucu.hata;
    }
  }
}

enum _Adim { ac, oturumSorular, sonuc }

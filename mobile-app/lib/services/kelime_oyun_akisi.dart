// Kelime Evreni oyun akışı: soru sırası, cevap gönderimi, ipucu, yanlışta yeniden deneme.
// Saf Dart (Flutter widget'a bağlı değil); testleri sahte depo ile çalışır.

import 'package:flutter/foundation.dart';

import '../models/kelime_models.dart';
import 'kelime_repository.dart';

const String _mesajAlternatifHata = 'Ek soru yüklenemedi. Oyuna devam ediyoruz.';

class KelimeOyunAkisi extends ChangeNotifier {
  KelimeOyunAkisi({required this.repository, required this.iliski});

  final KelimeRepository repository;
  final KelimeIliskiTuru iliski;

  final List<KelimeSoru> _kuyruk = [];
  final Set<String> _cevaplananSoruIdleri = {};
  int _indeks = 0;
  int _dogruSayisi = 0;
  int _kazanilanXp = 0;
  int _tekrarBekleyen = 0;

  bool _yukleniyor = false;
  bool _gonderiliyor = false;
  KelimeHatasi? _hataTuru;
  String? _hataMesaji;
  String? _bilgiMesaji;

  int? _secilen;
  KelimeCevapSonucu? _sonuc;
  bool _ipucuAcik = false;
  bool _alternatifEklendi = false;
  String? _denemeAnahtari;

  bool get yukleniyor => _yukleniyor;
  bool get gonderiliyor => _gonderiliyor;
  KelimeHatasi? get hataTuru => _hataTuru;
  String? get hataMesaji => _hataMesaji;
  String? get bilgiMesaji => _bilgiMesaji;

  /// Sunucudan hiç soru gelmediyse true (bu sınıf / tür için içerik yok).
  bool get bos => !_yukleniyor && _hataTuru == null && _kuyruk.isEmpty;

  int get toplamSoru => _kuyruk.length;
  int get tamamlananSoru => _indeks;
  int get sorudaKacinci => _indeks < _kuyruk.length ? _indeks + 1 : _kuyruk.length;
  int get dogruSayisi => _dogruSayisi;
  int get kazanilanXp => _kazanilanXp;
  int get tekrarBekleyen => _tekrarBekleyen;
  int get cevaplanan => _cevaplananSoruIdleri.length;

  bool get tamamlandi => _kuyruk.isNotEmpty && _indeks >= _kuyruk.length;
  KelimeSoru? get soru => (_kuyruk.isEmpty || tamamlandi) ? null : _kuyruk[_indeks];
  KelimeCevapSonucu? get sonuc => _sonuc;
  int? get secilen => _secilen;
  bool get cevaplandi => _sonuc != null;
  bool get ipucuAcik => _ipucuAcik;
  bool get alternatifEklendi => _alternatifEklendi;

  /// İpucu yalnızca henüz cevap gönderilmeden ve soruda ipucu varsa gösterilebilir.
  /// Gönderim başladıktan sonra kilitlenir: yeniden denemede deneme anahtarı değişmesin diye.
  bool get ipucuKullanilabilir =>
      soru?.ipucu != null && !cevaplandi && _denemeAnahtari == null && !_gonderiliyor;

  /// Tekrar denenebilir hata: son gönderim başarısız oldu ve deneme anahtarı hâlâ elde.
  bool get tekrarDenenebilir => _hataTuru != null && _denemeAnahtari != null && _secilen != null && !cevaplandi;

  Future<void> baslat() async {
    _yukleniyor = true;
    _hataTuru = null;
    _hataMesaji = null;
    _bilgiMesaji = null;
    _kuyruk.clear();
    _cevaplananSoruIdleri.clear();
    _indeks = 0;
    _dogruSayisi = 0;
    _kazanilanXp = 0;
    _sifirlaSoruDurumu();
    notifyListeners();

    try {
      final oyun = await repository.oyunGetir(iliski: iliski);
      _kuyruk.addAll(oyun.sorular);
      _tekrarBekleyen = oyun.tekrarBekleyen;
    } on KelimeException catch (e) {
      _hataTuru = e.hata;
      _hataMesaji = e.mesaj;
    } finally {
      _yukleniyor = false;
      notifyListeners();
    }
  }

  void ipucuGoster() {
    if (!ipucuKullanilabilir) return;
    _ipucuAcik = true;
    notifyListeners();
  }

  /// Şık seçimi. İlk dokunuş deneme anahtarını üretir; ağ hatasında aynı anahtar yeniden kullanılır.
  Future<void> cevapla(int secim) async {
    final aktif = soru;
    if (aktif == null || _gonderiliyor || cevaplandi) return;
    if (secim < 0 || secim >= aktif.secenekler.length) return;
    // Gönderim başladıktan sonra şık değiştirilemez; aynı anahtarla aynı cevap yeniden denenir.
    if (_secilen != null && _secilen != secim) return;

    _secilen = secim;
    _denemeAnahtari ??= _yeniDenemeAnahtari(aktif.id);
    _gonderiliyor = true;
    _hataTuru = null;
    _hataMesaji = null;
    notifyListeners();

    try {
      final sonuc = await repository.cevapGonder(
        soruId: aktif.id,
        secilenIndeks: secim,
        ipucuKullanildi: _ipucuAcik,
        denemeAnahtari: _denemeAnahtari!,
      );
      _sonuc = sonuc;
      _cevaplananSoruIdleri.add(aktif.id);
      if (sonuc.dogru) _dogruSayisi++;
      _kazanilanXp += sonuc.kazanilanXp;
    } on KelimeException catch (e) {
      _hataTuru = e.hata;
      _hataMesaji = e.mesaj;
      // Sunucu bu anahtarla kaydı reddetmediyse kullanıcı aynı cevabı yeniden gönderebilir.
      // Diğer hatalarda anahtar serbest bırakılır (yeni bir deneme olarak gönderilir).
      if (e.hata != KelimeHatasi.baglanti) {
        _denemeAnahtari = null;
        _secilen = null;
      }
    } finally {
      _gonderiliyor = false;
      notifyListeners();
    }

    final sonucSon = _sonuc;
    if (sonucSon != null && !sonucSon.dogru) {
      await _alternatifEkle(aktif);
    }
  }

  /// Aynı ağ hatasında son cevabı yeniden gönderir (aynı deneme anahtarı ile).
  Future<void> tekrarDene() async {
    final secim = _secilen;
    if (!tekrarDenenebilir || secim == null) return;
    _secilen = null;
    await cevapla(secim);
  }

  /// Cevap sonrası: sonraki soruya geçer; oyun bittiyse [tamamlandi] true olur.
  void sonraki() {
    if (!cevaplandi) return;
    _indeks++;
    _sifirlaSoruDurumu();
    notifyListeners();
  }

  /// Soru artık kullanılamıyorsa (ör. sunucuda arşivlendi) bu soruyu cevaplamadan geçer.
  /// Atlanan soru doğru/yanlış sayılmaz ve XP vermez.
  void atla() {
    if (soru == null || _gonderiliyor || cevaplandi) return;
    _indeks++;
    _hataTuru = null;
    _hataMesaji = null;
    _sifirlaSoruDurumu();
    notifyListeners();
  }

  /// Yanlış cevapta, aynı kelimenin (aynı anlam) henüz sorulmamış başka bir sorusunu sıraya ekler.
  /// Böylece tek bir cevabı ezberlemek yerine kelime farklı biçimde karşımıza çıkar.
  /// Uygun soru yoksa sıra değişmez; açıklama yeterli olur.
  Future<void> _alternatifEkle(KelimeSoru yanlis) async {
    _alternatifEklendi = false;
    _bilgiMesaji = null;
    try {
      final oyun = await repository.oyunGetir(iliski: iliski, limit: 20);
      final adaylar = oyun.sorular.where((s) =>
          s.anlamId == yanlis.anlamId &&
          !_cevaplananSoruIdleri.contains(s.id) &&
          !_kuyruk.any((k) => k.id == s.id));
      if (adaylar.isNotEmpty) {
        _kuyruk.add(adaylar.first);
        _alternatifEklendi = true;
      }
    } on KelimeException {
      _bilgiMesaji = _mesajAlternatifHata;
    }
    notifyListeners();
  }

  void _sifirlaSoruDurumu() {
    _secilen = null;
    _sonuc = null;
    _ipucuAcik = false;
    _alternatifEklendi = false;
    _denemeAnahtari = null;
    _gonderiliyor = false;
  }

  /// Sunucu sınırı: 8–128 karakter. Soru kimliği + zaman damgası yeterince benzersizdir.
  static String _yeniDenemeAnahtari(String soruId) {
    final kisa = soruId.replaceAll('-', '');
    final on = kisa.length >= 8 ? kisa.substring(0, 8) : kisa;
    return 'kk-$on-${DateTime.now().microsecondsSinceEpoch}';
  }
}

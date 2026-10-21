// Okuma Dünyası testleri için sahte depo. Sunucuyu taklit eder: cevap anahtarı YALNIZ burada
// (sunucu tarafı) durur; istemciye giden paket anahtarsızdır. Tüm çağrı parametreleri kaydedilir,
// böylece "ad sunucuya gitmedi" testi yapılabilir.

import 'dart:convert';
import 'dart:io';

import 'package:ogrenci_hazirlik/models/okuma_models.dart';
import 'package:ogrenci_hazirlik/services/okuma_repository.dart';

const String kTestHikayeId = '11111111-1111-1111-1111-111111111111';
const String kTestOturumId = '22222222-2222-2222-2222-222222222222';
const String kTestSha = 'sha-1';

/// Fikstür: derleyici çıktısı (anahtarlı). Sözlük pakete gömülür (paket `sozluk` anahtarı).
Map<String, dynamic> _tamPaketYukle() {
  final paket = jsonDecode(File('test/fixtures/okuma/feneri-kim-yakiyor.paket.json').readAsStringSync()) as Map<String, dynamic>;
  final sozluk = jsonDecode(File('test/fixtures/okuma/sozluk.ornek.json').readAsStringSync()) as Map<String, dynamic>;
  paket['sozluk'] = sozluk;
  (paket['hikaye'] as Map<String, dynamic>)['tanitim'] = 'Fener bir gece söndü. Işığı kim yakıyor?';
  return paket;
}

/// Sunucunun sakladığı tam paketten, istemciye giden anahtarsız paketi üretir.
Map<String, dynamic> anahtarsizPaket(Map<String, dynamic> tam) {
  final kopya = jsonDecode(jsonEncode(tam)) as Map<String, dynamic>..remove('uretim');
  kopya['sorular'] = [
    for (final s in (kopya['sorular'] as List)) {...(s as Map<String, dynamic>)}..remove('dogru')..remove('aciklama'),
  ];
  return kopya;
}

OkumaKatalogSatiri testSatiri({String id = kTestHikayeId, String sha = kTestSha, String baslik = 'Feneri Kim Yakıyor?'}) =>
    OkumaKatalogSatiri(
      hikayeId: id,
      surumId: 'surum-$id',
      surumNo: 1,
      slug: 'feneri-kim-yakiyor',
      baslik: baslik,
      tanitim: 'Fener bir gece söndü. Işığı kim yakıyor?',
      tur: 'macera',
      anaSinif: 4,
      sha256: sha,
      izinliTurler: const ['hayvan', 'hayali', 'ben', 'baska_biri'],
      tahminiSureDk: 3,
      soruSayisi: 4,
      gorulmedi: true,
    );

class FakeOkumaRepository implements OkumaRepository {
  FakeOkumaRepository({
    this.ozellik = const OkumaOzellikDurumu(erisim: true),
    List<OkumaKatalogSatiri>? katalogSatirlari,
    this.oneri,
    this.kotaDolu = false,
    this.pdfIzni = true,
  })  : _tam = _tamPaketYukle(),
        katalogSatirlari = katalogSatirlari ?? [testSatiri()];

  OkumaOzellikDurumu ozellik;
  final List<OkumaKatalogSatiri> katalogSatirlari;
  OkumaKatalogSatiri? oneri;
  bool kotaDolu;
  bool pdfIzni;
  final Map<String, dynamic> _tam;

  /// Doluysa ilgili çağrı bu hatayı fırlatır.
  OkumaException? ozellikHatasi;
  OkumaException? katalogHatasi;
  OkumaException? getirHatasi;
  OkumaException? oturumHatasi;
  OkumaException? bitirHatasi;
  OkumaException? cevapHatasi;

  /// Çağrı günlüğü: her kayıt (fonksiyon adı, parametreler).
  final List<(String, Map<String, dynamic>)> cagrilar = [];

  int sayac(String ad) => cagrilar.where((c) => c.$1 == ad).length;

  final Map<String, (String, bool)> _cevaplar = {};

  void _kaydet(String ad, [Map<String, dynamic> p = const {}]) => cagrilar.add((ad, p));

  /// Sunucu tarafı doğru şık.
  String _dogru(String soruId) =>
      ((_tam['sorular'] as List).cast<Map<String, dynamic>>().firstWhere((s) => s['id'] == soruId))['dogru'] as String;

  @override
  Future<OkumaOzellikDurumu> ozellikDurumu() async {
    _kaydet('okuma_ozellik_durumu');
    final h = ozellikHatasi;
    if (h != null) throw h;
    return ozellik;
  }

  @override
  Future<List<OkumaKatalogSatiri>> katalog({String? kahramanTuru, int limit = 24}) async {
    _kaydet('okuma_katalog_filtre', {'p_kahraman_turu': kahramanTuru, 'p_limit': limit});
    final h = katalogHatasi;
    if (h != null) throw h;
    return [
      for (final s in katalogSatirlari)
        if (kahramanTuru == null || s.izinliTurler.contains(kahramanTuru)) s,
    ];
  }

  @override
  Future<OkumaPaketi> hikayeGetir(String hikayeId) async {
    _kaydet('okuma_hikaye_getir', {'p_hikaye_id': hikayeId});
    final h = getirHatasi;
    if (h != null) throw h;
    return OkumaPaketi(
      hikayeId: hikayeId,
      surumId: 'surum-$hikayeId',
      surum: 1,
      sha256: kTestSha,
      minMotorSurumu: 1,
      paket: anahtarsizPaket(_tam),
    );
  }

  @override
  Future<OkumaOturum> oturumBaslat({
    required String hikayeId,
    required String kahramanTuru,
    required bool yoldasVar,
    required String okumaModu,
    required String istemciAnahtari,
  }) async {
    _kaydet('okuma_oturum_baslat', {
      'p_hikaye_id': hikayeId,
      'p_kahraman_turu': kahramanTuru,
      'p_yoldas_var': yoldasVar,
      'p_okuma_modu': okumaModu,
      'p_istemci_anahtari': istemciAnahtari,
    });
    final h = oturumHatasi;
    if (h != null) throw h;
    return OkumaOturum(oturumId: kTestOturumId, hikayeId: hikayeId, soruSayisi: 4);
  }

  @override
  Future<void> ilerlemeKaydet({required String oturumId, required int sayfa}) async {
    _kaydet('okuma_ilerleme_kaydet', {'p_oturum_id': oturumId, 'p_sayfa': sayfa});
  }

  @override
  Future<OkumaCevapSonucu> cevapKontrol({
    required String oturumId,
    required String soruId,
    required String secenekId,
  }) async {
    _kaydet('okuma_cevap_kontrol', {'p_oturum_id': oturumId, 'p_soru_id': soruId, 'p_secenek_id': secenekId});
    final hata = cevapHatasi;
    if (hata != null) throw hata;
    final onceki = _cevaplar[soruId];
    final secilen = onceki?.$1 ?? secenekId; // tek deneme: ikinci çağrı kayıtlıyı döner
    final dogru = secilen == _dogru(soruId);
    _cevaplar[soruId] = (secilen, dogru);
    final soru = (_tam['sorular'] as List).cast<Map<String, dynamic>>().firstWhere((s) => s['id'] == soruId);
    return OkumaCevapSonucu(
      dogru: dogru,
      aciklama: soru['aciklama'] as String,
      dogruSecenekId: _dogru(soruId),
      tekrar: onceki != null,
    );
  }

  @override
  Future<OkumaSonuc> oturumBitir({required String oturumId, List<String> dokunulan = const []}) async {
    _kaydet('okuma_oturum_bitir', {'p_oturum_id': oturumId, 'p_dokunulan': dokunulan});
    final h = bitirHatasi;
    if (h != null) throw h;
    final dogru = _cevaplar.values.where((c) => c.$2).length;
    final soru = (_tam['sorular'] as List).length;
    return OkumaSonuc(
      soruSayisi: soru,
      dogruSayisi: dogru,
      dogruOrani: soru == 0 ? 0 : (dogru * 100 / soru).round(),
      kazanilanXp: dogru * 100 ~/ soru >= 67 ? 20 : 10,
      ilkTamamlama: true,
      seri: const OkumaSeri(seriSayisi: 3, seriDevam: true, bugunOkudu: true),
    );
  }

  @override
  Future<void> geriBildirimGonder({required String oturumId, required OkumaAnketYaniti yanit}) async {
    _kaydet('okuma_geri_bildirim_gonder', {
      'p_oturum_id': oturumId,
      'p_yildiz': yanit.yildiz,
      'p_iyilestirme_kodlari': yanit.iyilestirmeKodlari.toList(),
    });
  }

  @override
  Future<OkumaSeriVeOneri> seriVeOneri() async {
    _kaydet('okuma_seri_ve_oneri');
    return OkumaSeriVeOneri(
      seri: const OkumaSeri(seriSayisi: 3, seriDevam: true),
      kotaDolu: kotaDolu,
      oneri: oneri ?? (kotaDolu ? null : katalogSatirlari.first),
    );
  }

  @override
  Future<OkumaPdfHakki> pdfHakkiKullan(String hikayeId) async {
    _kaydet('okuma_pdf_hakki_kullan', {'p_hikaye_id': hikayeId});
    return OkumaPdfHakki(izin: pdfIzni, kalan: pdfIzni ? 2 : 0);
  }
}

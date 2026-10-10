// Kelime Evreni testleri için sahte depo. Sunucu davranışını taklit eder; yanıtlar testten kontrol edilir.

import 'package:ogrenci_hazirlik/models/kelime_models.dart';
import 'package:ogrenci_hazirlik/services/kelime_repository.dart';

class CevapIstegi {
  const CevapIstegi({
    required this.soruId,
    required this.secilenIndeks,
    required this.ipucuKullanildi,
    required this.denemeAnahtari,
  });

  final String soruId;
  final int secilenIndeks;
  final bool ipucuKullanildi;
  final String denemeAnahtari;
}

class FakeKelimeRepository implements KelimeRepository {
  FakeKelimeRepository({
    List<KelimeSoru>? sorular,
    this.oyunYanitlari,
    this.oyunHatasi,
    this.cevapYaniti,
  }) : sorular = sorular ?? const [];

  /// Varsayılan oyun yanıtı.
  final List<KelimeSoru> sorular;

  /// Verilirse n. oyunGetir çağrısı listenin n. öğesini döner (son öğe tekrarlanır).
  final List<List<KelimeSoru>>? oyunYanitlari;

  /// Doluysa oyunGetir bu hatayı fırlatır.
  KelimeException? oyunHatasi;

  /// Verilirse her cevap gönderiminde bu fonksiyon yanıt üretir. Hata fırlatabilir.
  Future<KelimeCevapSonucu> Function(CevapIstegi istek)? cevapYaniti;

  final List<CevapIstegi> cevapCagrilari = [];
  int oyunGetirSayisi = 0;

  @override
  Future<KelimeOyunSorulari> oyunGetir({required KelimeIliskiTuru iliski, int limit = 8}) async {
    oyunGetirSayisi++;
    final hata = oyunHatasi;
    if (hata != null) throw hata;
    final yanitlar = oyunYanitlari;
    final liste = yanitlar == null
        ? sorular
        : yanitlar[(oyunGetirSayisi - 1).clamp(0, yanitlar.length - 1)];
    return KelimeOyunSorulari(
      sinif: 5,
      iliski: iliski,
      sorular: liste,
      tekrarBekleyen: 2,
    );
  }

  @override
  Future<KelimeCevapSonucu> cevapGonder({
    required String soruId,
    required int secilenIndeks,
    required bool ipucuKullanildi,
    required String denemeAnahtari,
  }) async {
    final istek = CevapIstegi(
      soruId: soruId,
      secilenIndeks: secilenIndeks,
      ipucuKullanildi: ipucuKullanildi,
      denemeAnahtari: denemeAnahtari,
    );
    cevapCagrilari.add(istek);
    final yanit = cevapYaniti;
    if (yanit != null) return yanit(istek);
    // Varsayılan: doğru şık 1. indeks, ipucusuz doğruda 10 XP
    final dogru = secilenIndeks == 1;
    return KelimeCevapSonucu(
      dogru: dogru,
      dogruIndeks: 1,
      aciklama: 'Açıklama metni.',
      kazanilanXp: dogru && !ipucuKullanildi ? 10 : 0,
      tekrar: false,
      ustalikSeviyesi: dogru ? 1 : 0,
    );
  }

  @override
  Future<KelimeOzet> ozet() async => KelimeOzet.bos;

  @override
  Future<List<KelimeKaydi>> kaydedilenler() async => const [];

  @override
  Future<void> kaydet({required String anlamId, required bool kaydet}) async {}

  @override
  Future<KelimeVeliOzeti> veliOzeti({required String cocukId}) {
    throw UnimplementedError('Veli özeti bu testlerde kullanılmaz');
  }
}

KelimeSoru kelimeSoru({
  required String id,
  String anlamId = 'anlam-mutlu',
  String soruMetni = 'Mutlu kelimesinin eş anlamlısı hangisidir?',
  List<String> secenekler = const ['Üzgün', 'Sevinçli', 'Sessiz'],
  String? ipucu = 'Sevinç duygusuna bak.',
}) {
  return KelimeSoru(
    id: id,
    anlamId: anlamId,
    soruMetni: soruMetni,
    secenekler: secenekler,
    ipucu: ipucu,
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/kelime_models.dart';
import 'package:ogrenci_hazirlik/services/kelime_oyun_akisi.dart';
import 'package:ogrenci_hazirlik/services/kelime_repository.dart';

import 'kelime_fake_repository.dart';

void main() {
  final mutluA = kelimeSoru(id: 'soru-mutlu-1');
  final mutluB = kelimeSoru(id: 'soru-mutlu-2', soruMetni: 'Hangisi mutlu kelimesine yakındır?');
  final hizli = kelimeSoru(id: 'soru-hizli-1', anlamId: 'anlam-hizli', soruMetni: 'Hızlı kelimesinin eş anlamlısı?');

  KelimeOyunAkisi akisOlustur(FakeKelimeRepository repo) =>
      KelimeOyunAkisi(repository: repo, iliski: KelimeIliskiTuru.esAnlamli);

  group('yükleme', () {
    test('baslat soruları yükler ve ilk soruyu gösterir', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA, hizli]);
      final akis = akisOlustur(repo);

      await akis.baslat();

      expect(akis.bos, isFalse);
      expect(akis.toplamSoru, 2);
      expect(akis.soru?.id, 'soru-mutlu-1');
      expect(akis.sorudaKacinci, 1);
      expect(akis.tekrarBekleyen, 2);
    });

    test('içerik yoksa bos true olur (hata değil)', () async {
      final akis = akisOlustur(FakeKelimeRepository(sorular: const []));
      await akis.baslat();
      expect(akis.bos, isTrue);
      expect(akis.hataTuru, isNull);
    });

    test('sınıf eksikse sınıf hatası kullanıcıya taşınır', () async {
      final akis = akisOlustur(FakeKelimeRepository(
        oyunHatasi: const KelimeException(KelimeHatasi.sinifGerekli, 'Sınıfını seçmelisin.'),
      ));
      await akis.baslat();
      expect(akis.hataTuru, KelimeHatasi.sinifGerekli);
      expect(akis.hataMesaji, 'Sınıfını seçmelisin.');
      expect(akis.toplamSoru, 0);
      expect(akis.bos, isFalse, reason: 'hata durumu boş durum sayılmaz');
    });
  });

  group('cevap', () {
    test('doğru cevap: XP kazanılır, doğru sayısı artar, alternatif sorgusu yapılmaz', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA]);
      final akis = akisOlustur(repo);
      await akis.baslat();

      await akis.cevapla(1);

      expect(akis.sonuc?.dogru, isTrue);
      expect(akis.kazanilanXp, 10);
      expect(akis.dogruSayisi, 1);
      expect(akis.cevaplanan, 1);
      expect(repo.oyunGetirSayisi, 1, reason: 'yalnızca başlangıç çağrısı');
    });

    test('ipucu kullanılan cevap ipucu bayrağıyla gider ve XP vermez', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA]);
      final akis = akisOlustur(repo);
      await akis.baslat();

      akis.ipucuGoster();
      expect(akis.ipucuAcik, isTrue);
      await akis.cevapla(1);

      expect(repo.cevapCagrilari.single.ipucuKullanildi, isTrue);
      expect(akis.kazanilanXp, 0);
      expect(akis.dogruSayisi, 1, reason: 'ipucu ile doğru yine doğru sayılır');
    });

    test('gönderim başladıktan sonra ipucu kilitlenir (yeniden deneme anahtarı değişmesin)', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA])
        ..cevapYaniti = (_) async => throw const KelimeException(KelimeHatasi.baglanti, 'bağlantı');
      final akis = akisOlustur(repo);
      await akis.baslat();

      await akis.cevapla(1);
      expect(akis.hataTuru, KelimeHatasi.baglanti);
      expect(akis.ipucuKullanilabilir, isFalse);

      akis.ipucuGoster();
      expect(akis.ipucuAcik, isFalse);
    });

    test('ağ hatasında tekrarDene AYNI deneme anahtarını yeniden gönderir', () async {
      var deneme = 0;
      final repo = FakeKelimeRepository(sorular: [mutluA])
        ..cevapYaniti = (istek) async {
          deneme++;
          if (deneme == 1) {
            throw const KelimeException(KelimeHatasi.baglanti, 'bağlantı');
          }
          return const KelimeCevapSonucu(
            dogru:true,
            dogruIndeks: 1,
            aciklama: 'Açıklama',
            kazanilanXp: 10,
            tekrar: false,
          );
        };
      final akis = akisOlustur(repo);
      await akis.baslat();

      await akis.cevapla(1);
      expect(akis.tekrarDenenebilir, isTrue);

      await akis.tekrarDene();

      expect(repo.cevapCagrilari, hasLength(2));
      expect(repo.cevapCagrilari[0].denemeAnahtari, repo.cevapCagrilari[1].denemeAnahtari);
      expect(akis.sonuc?.dogru, isTrue);
      expect(akis.kazanilanXp, 10, reason: 'XP yalnızca bir kez eklenir');
    });

    test('ağ hatasından sonra başka şık seçilemez (anahtar-cevap eşleşmesi bozulmaz)', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA])
        ..cevapYaniti = (_) async => throw const KelimeException(KelimeHatasi.baglanti, 'bağlantı');
      final akis = akisOlustur(repo);
      await akis.baslat();

      await akis.cevapla(1);
      await akis.cevapla(0);

      expect(repo.cevapCagrilari, hasLength(1));
    });

    test('sunucu kuralı hatasında anahtar serbest kalır ve yeni deneme yapılabilir', () async {
      var cagri = 0;
      final repo = FakeKelimeRepository(sorular: [mutluA])
        ..cevapYaniti = (istek) async {
          cagri++;
          if (cagri == 1) {
            throw const KelimeException(KelimeHatasi.gecersizDeneme, 'Cevap gönderilemedi.');
          }
          return const KelimeCevapSonucu(
            dogru:false,
            dogruIndeks: 1,
            aciklama: 'Açıklama',
            kazanilanXp: 0,
            tekrar: false,
          );
        };
      final akis = akisOlustur(repo);
      await akis.baslat();

      await akis.cevapla(0);
      expect(akis.tekrarDenenebilir, isFalse);
      await akis.cevapla(2);

      expect(repo.cevapCagrilari, hasLength(2));
      expect(repo.cevapCagrilari[1].secilenIndeks, 2);
      expect(akis.sonuc, isNotNull);
    });

    test('çift dokunuş tek gönderim üretir', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA]);
      final akis = akisOlustur(repo);
      await akis.baslat();

      final ilk = akis.cevapla(1);
      final ikinci = akis.cevapla(1);
      await Future.wait([ilk, ikinci]);

      expect(repo.cevapCagrilari, hasLength(1));
    });
  });

  group('yanlış cevap ve alternatif soru', () {
    test('yanlışta aynı anlamın başka sorusu sıraya eklenir', () async {
      final repo = FakeKelimeRepository(oyunYanitlari: [
        [mutluA, hizli],
        [mutluA, mutluB, hizli],
      ]);
      final akis = akisOlustur(repo);
      await akis.baslat();

      await akis.cevapla(0);

      expect(akis.sonuc?.dogru, isFalse);
      expect(akis.alternatifEklendi, isTrue);
      expect(akis.toplamSoru, 3);
      expect(akis.kazanilanXp, 0);
    });

    test('aynı anlamda yeni soru yoksa sıra değişmez', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA, hizli]);
      final akis = akisOlustur(repo);
      await akis.baslat();

      await akis.cevapla(0);

      expect(akis.alternatifEklendi, isFalse);
      expect(akis.toplamSoru, 2);
    });

    test('alternatif sorgusu başarısız olursa oyun durmaz, bilgi mesajı gösterilir', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA, hizli]);
      final akis = akisOlustur(repo);
      await akis.baslat();
      repo.oyunHatasi = const KelimeException(KelimeHatasi.baglanti, 'bağlantı');

      await akis.cevapla(0);

      expect(akis.sonuc?.dogru, isFalse);
      expect(akis.bilgiMesaji, isNotNull);
      expect(akis.toplamSoru, 2);
    });
  });

  group('atla', () {
    test('soru kullanılamazsa atla ile sonraki soruya geçilir; XP ve doğru sayısı değişmez', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA, hizli])
        ..cevapYaniti = (istek) async {
          if (istek.soruId == 'soru-mutlu-1') {
            throw const KelimeException(KelimeHatasi.soruBulunamadi, 'Bu soru artık yok.');
          }
          return const KelimeCevapSonucu(dogru: true, dogruIndeks: 1, aciklama: 'a', kazanilanXp: 10, tekrar: false);
        };
      final akis = akisOlustur(repo);
      await akis.baslat();

      await akis.cevapla(1);
      expect(akis.hataTuru, KelimeHatasi.soruBulunamadi);

      akis.atla();

      expect(akis.soru?.id, 'soru-hizli-1');
      expect(akis.hataTuru, isNull);
      expect(akis.kazanilanXp, 0);
      expect(akis.dogruSayisi, 0);
    });

    test('gönderim sırasında atla etkisizdir', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA, hizli]);
      final akis = akisOlustur(repo);
      await akis.baslat();

      final gonderim = akis.cevapla(1);
      akis.atla();
      await gonderim;

      expect(akis.soru?.id, 'soru-mutlu-1', reason: 'cevap bitmeden soru değişmez');
    });
  });

  group('ilerleme', () {
    test('sonraki cevaplanmadan işe yaramaz', () async {
      final akis = akisOlustur(FakeKelimeRepository(sorular: [mutluA]));
      await akis.baslat();

      akis.sonraki();

      expect(akis.soru?.id, 'soru-mutlu-1');
      expect(akis.tamamlandi, isFalse);
    });

    test('son soru bittiğinde tamamlandi olur ve yeni cevap gönderilmez', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA, hizli]);
      final akis = akisOlustur(repo);
      await akis.baslat();

      await akis.cevapla(1);
      akis.sonraki();
      await akis.cevapla(1);
      akis.sonraki();

      expect(akis.tamamlandi, isTrue);
      expect(akis.soru, isNull);
      expect(akis.dogruSayisi, 2);
      expect(akis.kazanilanXp, 20);

      await akis.cevapla(0);
      expect(repo.cevapCagrilari, hasLength(2));
    });

    test('sonraki soruya geçince soru durumu sıfırlanır', () async {
      final repo = FakeKelimeRepository(sorular: [mutluA, hizli]);
      final akis = akisOlustur(repo);
      await akis.baslat();
      akis.ipucuGoster();
      await akis.cevapla(0);

      akis.sonraki();

      expect(akis.sonuc, isNull);
      expect(akis.secilen, isNull);
      expect(akis.ipucuAcik, isFalse);
      expect(akis.soru?.id, 'soru-hizli-1');
    });
  });
}

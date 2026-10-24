import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/okuma_models.dart';
import '../../providers/okuma_akis.dart';
import '../../providers/okuma_providers.dart';
import '../../services/okuma_geri_donus.dart';
import '../../widgets/hupo/hupo.dart';
import '../../widgets/okuma/okuma_bilesenler.dart';
import 'anket_ekrani.dart';
import 'hikaye_secim_ekrani.dart';
import 'kahraman_secim_ekrani.dart';
import 'okuduklarim_ekrani.dart';
import 'okuma_tema.dart';
import 'okuyucu_ekrani.dart';
import 'sonuc_ekrani.dart';
import 'sorular_ekrani.dart';

/// "Senin Hikâyen" akışı: kahraman → hikâye listesi → okuma → sorular → anket → sonuç.
///
/// Hedef: çocuk kendi kahramanıyla bir hikâye okur, sorulara cevap verir ve sonucunu görür.
/// Ana eylem her adımda tek ve belirgindir. Durumlar: yükleniyor, hata (yeniden dene), bugünkü
/// hikâye hakkı doldu, çevrimdışı salt okuma. Kahraman adı yalnız bu ağaçta, bellekte yaşar.
class OkumaAkisEkrani extends ConsumerStatefulWidget {
  const OkumaAkisEkrani({super.key, this.baslangicSatiri, this.ilkTur});

  /// Verilirse (Öğren kartı önerisi, "Okuduklarım") kahraman seçildikten sonra doğrudan açılır.
  final OkumaKatalogSatiri? baslangicSatiri;

  /// Kategori kapağından gelindiyse hikâye listesi bu türle açılır (ör. gizem).
  final String? ilkTur;

  @override
  ConsumerState<OkumaAkisEkrani> createState() => _OkumaAkisEkraniState();
}

class _OkumaAkisEkraniState extends ConsumerState<OkumaAkisEkrani> {
  OkumaKatalogSatiri? _acilacak;
  bool _sorudanCikSorusuAcik = false;

  @override
  void initState() {
    super.initState();
    _acilacak = widget.baslangicSatiri;
  }

  OkumaAkisDenetleyici get _akis => ref.read(okumaAkisProvider.notifier);

  void _geriTusu(OkumaAsama asama) {
    switch (asama) {
      case OkumaAsama.kahraman:
      case OkumaAsama.kota:
      case OkumaAsama.sonuc:
        Navigator.of(context).pop();
      case OkumaAsama.liste:
        _akis.kahramanaDon();
      case OkumaAsama.sorular:
        _sorudanCik();
      case OkumaAsama.hata:
      case OkumaAsama.okuma:
        _akis.listeyeDon();
      case OkumaAsama.anket:
        _akis.anketBitti(null);
      case OkumaAsama.yukleniyor:
      case OkumaAsama.bitiriliyor:
        // Sunucu işi sürerken de çıkış var; arka plandaki iş yeni ekranı bozmaz (nesil sayacı).
        _akis.listeyeDon();
    }
  }

  /// Sorulardan çıkış: verilen cevaplar yarım kalacağı için önce onay istenir. Geri tuşu ve ekrandaki
  /// geri düğmesi aynı yolu izler. Onay penceresi açıkken ikinci istek yok sayılır.
  Future<void> _sorudanCik() async {
    if (_sorudanCikSorusuAcik) return;
    _sorudanCikSorusuAcik = true;
    final cik = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(OkumaMetin.sorudanCikBaslik,
            style: OkumaTema.yazi(OkumaTema.yaziKartBaslik, kalinlik: OkumaTema.kalinlikBaslik)),
        content: Text(OkumaMetin.sorudanCikAciklama, style: OkumaTema.yazi(OkumaTema.yaziSecenek, satir: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(OkumaMetin.sorudanKal)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(OkumaMetin.sorudanCik)),
        ],
      ),
    );
    _sorudanCikSorusuAcik = false;
    if (cik == true && mounted) _akis.listeyeDon();
  }

  Future<void> _okuduklarimAc() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (ctx) => OkuduklarimEkrani(
          onAc: (satir) {
            Navigator.of(ctx).pop();
            _akis.hikayeSec(satir);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(okumaAkisProvider);
    final depo = ref.watch(okumaCihazDeposuProvider);
    final simdi = ref.watch(okumaSimdiProvider)();

    final Widget ekran;
    switch (d.asama) {
      case OkumaAsama.kahraman:
        ekran = KahramanSecimEkrani(
          onGeri: () => Navigator.of(context).pop(),
          onDevam: (secim) {
            final ac = _acilacak;
            _acilacak = null;
            _akis.kahramanSec(secim, ac: ac);
          },
        );
      case OkumaAsama.liste:
        final son = depo.sonOkuma;
        ekran = HikayeSecimEkrani(
          ilkTur: widget.ilkTur,
          katalog: d.katalog,
          kahramanAdi: d.kahraman?.ad ?? '',
          yukleniyor: d.katalogYukleniyor,
          hata: d.katalogHatasi,
          onYenidenDene: _akis.katalogYukle,
          onSec: _akis.hikayeSec,
          onGeri: _akis.kahramanaDon,
          onOkuduklarim: _okuduklarimAc,
          geriDonusMesaji: geriDonusGerekli(sonOkuma: son, simdi: simdi)
              ? geriDonusMetni(simdi.difference(son!).inDays)
              : null,
        );
      case OkumaAsama.yukleniyor:
        ekran = _Bekleme(
            baslik: OkumaMetin.uygulamaAdi,
            metin: OkumaMetin.hikayeAciliyor,
            onGeri: _akis.listeyeDon);
      case OkumaAsama.okuma:
        ekran = OkuyucuEkrani(
          // Hikâye değişince okuyucu sıfırdan başlar.
          key: ValueKey(d.paket?.hikayeId),
          sayfalar: d.sayfalar,
          anlamlar: d.anlamlar,
          baslik: d.paket?.baslik ?? OkumaMetin.uygulamaAdi,
          cevrimdisi: d.cevrimdisi,
          sinif: d.secilen?.anaSinif ?? 4,
          tur: d.secilen?.tur ?? 'hikaye',
          sahneSlug: d.secilen?.slug,
          ilkSayfa: d.ilkSayfa,
          onGeri: _akis.listeyeDon,
          onSayfaGorundu: _akis.sayfaGorundu,
          onSozcukAcildi: _akis.sozcukAcildi,
          onBitti: _akis.okumaBitti,
        );
      case OkumaAsama.sorular:
        ekran = SorularEkrani(
          key: ValueKey(d.oturum?.oturumId),
          sorular: d.sorular,
          cevapKontrol: _akis.cevapKontrol,
          onBitti: _akis.sorularBitti,
          onGeri: _sorudanCik,
        );
      case OkumaAsama.anket:
        ekran = AnketEkrani(onBitti: _akis.anketBitti);
      case OkumaAsama.bitiriliyor:
        ekran = _Bekleme(
            baslik: OkumaMetin.uygulamaAdi,
            metin: OkumaMetin.sonucYukleniyor,
            onGeri: _akis.listeyeDon);
      case OkumaAsama.sonuc:
        final sonuc = d.sonuc;
        ekran = sonuc == null
            ? _Bekleme(
                baslik: OkumaMetin.uygulamaAdi,
                metin: OkumaMetin.sonucYukleniyor,
                onGeri: _akis.listeyeDon)
            : SonucEkrani(
                sonuc: sonuc,
                kotaDolu: d.oneri?.kotaDolu ?? false,
                oneri: d.oneri?.oneri,
                anketUyarisi: d.anketUyarisi,
                onOneri: _akis.oneriyiAc,
                onYeni: _akis.listeyeDon,
                onKahraman: _akis.kahramanaDon,
                onKapat: () => Navigator.of(context).pop(),
                onPdf: _akis.pdfIndir,
              );
      case OkumaAsama.kota:
        ekran = _KotaEkrani(
          onTamam: () => Navigator.of(context).pop(),
          onOkuduklarim: _okuduklarimAc,
        );
      case OkumaAsama.hata:
        ekran = OkumaEkranIskeleti(
          baslik: OkumaMetin.uygulamaAdi,
          geri: _akis.listeyeDon,
          icerik: [
            DurumEkrani(
              poz: HupoPose.birDahaDene,
              baslik: d.hataMesaji ?? OkumaMetin.okuyucuBos,
              birincilEtiket: OkumaMetin.yenidenDene,
              birincil: _akis.yenidenDene,
              ikincilEtiket: OkumaMetin.hikayelereDon,
              ikincil: _akis.listeyeDon,
            ),
          ],
        );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _geriTusu(d.asama);
      },
      child: ekran,
    );
  }
}

/// Bekleme: hikâye hazırlanırken ya da sonuç alınırken. Süre uydurulmaz; geri düğmesi her zaman
/// görünür. [_zamanAsimi] dolunca sakin bir mesaj ve çıkış düğmesi de çıkar.
class _Bekleme extends StatefulWidget {
  const _Bekleme({required this.baslik, required this.metin, required this.onGeri});

  final String baslik;
  final String metin;
  final VoidCallback onGeri;

  @override
  State<_Bekleme> createState() => _BeklemeState();
}

class _BeklemeState extends State<_Bekleme> {
  static const Duration _zamanAsimi = Duration(seconds: 20);

  Timer? _zaman;
  bool _uzadi = false;

  @override
  void initState() {
    super.initState();
    _zaman = Timer(_zamanAsimi, () {
      if (mounted) setState(() => _uzadi = true);
    });
  }

  @override
  void dispose() {
    _zaman?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OkumaEkranIskeleti(
      baslik: widget.baslik,
      geri: widget.onGeri,
      icerik: [
        const SizedBox(height: OkumaTema.bosluk32),
        Semantics(
          liveRegion: true,
          label: widget.metin,
          child: Column(
            children: [
              const OkumaMaskot(
                  poz: HupoPose.dusunuyor, boyut: OkumaTema.hupoSonucKisa),
              const SizedBox(height: OkumaTema.bosluk16),
              Text(
                widget.metin,
                textAlign: TextAlign.center,
                style: OkumaTema.yazi(OkumaTema.yaziSecenek,
                    kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.muted),
              ),
              const SizedBox(height: OkumaTema.bosluk16),
              const CircularProgressIndicator(),
            ],
          ),
        ),
        if (_uzadi) ...[
          const SizedBox(height: OkumaTema.bosluk24),
          Text(
            OkumaMetin.beklemeUzadi,
            textAlign: TextAlign.center,
            style: OkumaTema.yazi(OkumaTema.yaziYardimci, renk: OkumaTema.muted, satir: OkumaTema.satirGovde),
          ),
          const SizedBox(height: OkumaTema.bosluk16),
          OkumaIkincilButon(etiket: OkumaMetin.hikayelereDon, onPressed: widget.onGeri),
        ],
      ],
    );
  }
}

/// Bugünkü hikâye hakkı doldu: sakin, teşvik edici; kart ya da ödeme isteği yok.
class _KotaEkrani extends StatelessWidget {
  const _KotaEkrani({required this.onTamam, required this.onOkuduklarim});

  final VoidCallback onTamam;
  final VoidCallback onOkuduklarim;

  @override
  Widget build(BuildContext context) {
    return OkumaEkranIskeleti(
      baslik: OkumaMetin.uygulamaAdi,
      geri: onTamam,
      icerik: [
        const SizedBox(height: OkumaTema.bosluk24),
        DurumEkrani(
          poz: HupoPose.konuTamamlandi,
          pozBoyutu: OkumaTema.hupoSonucKisa,
          baslik: OkumaMetin.kotaBaslik,
          aciklama: OkumaMetin.kotaAciklama,
          birincilEtiket: OkumaMetin.kotaTamam,
          birincil: onTamam,
          ikincilEtiket: OkumaMetin.okuduklarimBaslik,
          ikincil: onOkuduklarim,
        ),
      ],
    );
  }
}

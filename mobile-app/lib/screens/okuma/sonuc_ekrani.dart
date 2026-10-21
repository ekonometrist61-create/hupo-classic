import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../models/okuma_models.dart';
import '../../providers/okuma_akis.dart' show OkumaPdfSonucu;
import '../../widgets/hupo/hupo.dart';
import '../../widgets/okuma/okuma_bilesenler.dart';
import 'okuma_tema.dart';

/// Sonuç ekranı. Hedef: çocuk hikâyeyi bitirdiğini, ne kadar bildiğini ve sırada ne olduğunu görür.
/// Ana eylem: "Yeni hikâye seç" (kota doluysa "Tamam"). İkincil, yan yana: "Kahramanı değiştir" ve PDF.
/// Durumlar: hepsi doğru (kutlama), yüksek/orta/düşük oran (sakin teşvik), soru yok, kota dolu
/// ("yarın yeni hikâye"), sıradaki hikâye önerisi, PDF hazırlanıyor/hak yok.
/// Kutlama (yıldız ve konfeti Lottie) yalnız tüm sorular doğruysa ve hareket azaltma kapalıyken oynar.
/// XP ve seri yalnız sunucunun bildirdiği kadardır (istemci ikinci ödül üretmez).
///
/// Düzen: motivasyon kartı başlığın hemen altındadır, ana eylem alt alanda sabittir ve PDF ile
/// kahraman düğmeleri ikincil olarak yan yana durur. Telefonda (genişlik < kirilimGenis) dikey,
/// tablet ve masaüstünde maskot ile başlık yan yana yerleşir. Kısa ekranda (yükseklik <
/// kisaEkranYukseklik) maskot küçülür. Yazı ölçeği büyürse içerik kaydırılır, hiçbir öğe kesilmez.
class SonucEkrani extends StatefulWidget {
  const SonucEkrani({
    super.key,
    required this.sonuc,
    required this.onYeni,
    required this.onKahraman,
    required this.onPdf,
    required this.onKapat,
    this.kotaDolu = false,
    this.oneri,
    this.onOneri,
    this.anketUyarisi = false,
  });

  final OkumaSonuc sonuc;
  final VoidCallback onYeni;
  final VoidCallback onKahraman;

  /// Hak denetimi + üretim. Başarı/hata mesajını ekran gösterir.
  final Future<OkumaPdfSonucu> Function() onPdf;
  final VoidCallback onKapat;

  /// Bugünkü okuma hakkı doldu: yeni hikâye önerilmez, "yarın yeni hikâye" denir.
  final bool kotaDolu;
  final OkumaKatalogSatiri? oneri;
  final VoidCallback? onOneri;
  final bool anketUyarisi;

  @override
  State<SonucEkrani> createState() => _SonucEkraniState();
}

class _SonucEkraniState extends State<SonucEkrani> {
  bool _pdfBusy = false;

  Future<void> _pdf() async {
    if (_pdfBusy) return;
    setState(() => _pdfBusy = true);
    final sonuc = await widget.onPdf();
    if (!mounted) return;
    setState(() => _pdfBusy = false);
    switch (sonuc) {
      case OkumaPdfSonucu.hazir:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(OkumaMetin.pdfHazir)));
      case OkumaPdfSonucu.hata:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(OkumaMetin.pdfHata)));
      case OkumaPdfSonucu.hakYok:
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(OkumaMetin.pdfHakBaslik, style: OkumaTema.yazi(OkumaTema.yaziKartBaslik, kalinlik: OkumaTema.kalinlikBaslik)),
            content: Text(OkumaMetin.pdfHakAciklama, style: OkumaTema.yazi(OkumaTema.yaziSecenek, satir: 1.4)),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(OkumaMetin.kapat))],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final soruSayisi = widget.sonuc.soruSayisi;
    final dogruSayisi = widget.sonuc.dogruSayisi;
    final ekran = MediaQuery.sizeOf(context);
    final genis = ekran.width >= OkumaTema.kirilimGenis;
    final buyukYazi = MediaQuery.textScalerOf(context).scale(1) > OkumaTema.sonucYaziBuyukEsigi;
    final kisaEkran = ekran.height < OkumaTema.kisaEkranYukseklik;
    // Kısa ekranda büyük yazı: maskot daha da küçülür ki başlık ilk ekranda tam görünsün.
    final pozBoyutu = kisaEkran
        ? (buyukYazi ? OkumaTema.hupoSonucBuyukYazi : OkumaTema.hupoSonucKisa)
        : OkumaTema.hupoSonuc;

    final hepsiDogru = soruSayisi > 0 && dogruSayisi == soruSayisi;
    // Soru yoksa yalnız okuma tamamlanmıştır: sakin, olumlu bitiş.
    final oran = soruSayisi == 0 ? 1.0 : dogruSayisi / soruSayisi;
    final poz = hepsiDogru || oran >= 0.8
        ? HupoPose.harika
        : (oran >= 0.5 ? HupoPose.konuTamamlandi : HupoPose.cokYaklastin);
    final kutlamaAcik = hepsiDogru && !MediaQuery.disableAnimationsOf(context);

    final String altMetin;
    if (hepsiDogru || soruSayisi == 0) {
      altMetin = OkumaMetin.sonucHepsiAlt;
    } else if (oran >= 0.8) {
      altMetin = OkumaMetin.sonucYuksek;
    } else if (oran >= 0.5) {
      altMetin = OkumaMetin.sonucOrta;
    } else {
      altMetin = OkumaMetin.sonucDusuk;
    }

    // Maskot alanı: Hupo + kutlama katmanları. Yıldız köşede durur ki Hupo'nun yüzünü kapatmasın;
    // konfeti yanlara taşar ama üst kenardan kırpılmaz.
    final kabuk = pozBoyutu + OkumaTema.sonucKabukPay * 2;
    final maskotAlani = SizedBox(
      width: kabuk,
      height: kabuk,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (kutlamaAcik)
            Positioned(
              left: -OkumaTema.sonucKonfetiTasma,
              right: -OkumaTema.sonucKonfetiTasma,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/lottie/confetti.json',
                  repeat: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          OkumaMaskot(poz: poz, boyut: pozBoyutu),
          if (kutlamaAcik)
            Positioned(
              top: 0,
              right: 0,
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/lottie/star.json',
                  width: OkumaTema.sonucYildizBoyut,
                  repeat: false,
                ),
              ),
            ),
        ],
      ),
    );

    final hizaAlign = genis
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final hizaMetin = genis ? TextAlign.start : TextAlign.center;

    final baslikBlok = Column(
      crossAxisAlignment: hizaAlign,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            hepsiDogru ? OkumaMetin.sonucHepsiBaslik : OkumaMetin.sonucBitti,
            textAlign: hizaMetin,
            style: OkumaTema.yazi(
              OkumaTema.yaziEkranBaslik,
              kalinlik: OkumaTema.kalinlikBaslik,
              satir: 1.2,
            ),
          ),
        ),
        if (soruSayisi > 0) ...[
          const SizedBox(height: OkumaTema.bosluk8),
          Text(
            OkumaMetin.sonucOzet(soruSayisi, dogruSayisi),
            textAlign: hizaMetin,
            style: OkumaTema.yazi(OkumaTema.yaziSecenek, kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.muted),
          ),
        ],
      ],
    );

    final ustSatir = genis
        ? Row(
            children: [
              maskotAlani,
              const SizedBox(width: OkumaTema.bosluk32),
              Expanded(child: baslikBlok),
            ],
          )
        : Column(
            children: [
              maskotAlani,
              const SizedBox(height: OkumaTema.bosluk8),
              baslikBlok,
            ],
          );

    // Sunucunun bildirdiği XP ve seri (yoksa satır gösterilmez; istemci uydurmaz).
    final xp = widget.sonuc.kazanilanXp;
    final seri = widget.sonuc.seri?.seriSayisi ?? 0;
    final oduller = <Widget>[
      if (xp > 0) _OdulCipi(ikon: Icons.bolt_rounded, metin: OkumaMetin.sonucXp(xp)),
      if (seri > 0) _OdulCipi(ikon: Icons.local_fire_department_rounded, metin: OkumaMetin.sonucSeri(seri)),
    ];

    // Motivasyon kartı: altMetin, teşvik ve "tekrar gel" tek kartta; ilk ekranda görünür kalır.
    final motivasyonKarti = OkumaKart(
      zemin: OkumaTema.primarySoft,
      kenar: OkumaTema.primaryLight,
      child: Column(
        children: [
          Text(
            altMetin,
            textAlign: TextAlign.center,
            style: OkumaTema.yazi(OkumaTema.yaziSecenek, satir: OkumaTema.satirGovde),
          ),
          if (!hepsiDogru && soruSayisi > 0) ...[
            const SizedBox(height: OkumaTema.bosluk8),
            Text(
              OkumaMetin.sonucTesvik,
              textAlign: TextAlign.center,
              style: OkumaTema.yazi(OkumaTema.yaziYardimci, renk: OkumaTema.muted, satir: OkumaTema.satirGovde),
            ),
          ],
          if (oduller.isNotEmpty) ...[
            const SizedBox(height: OkumaTema.bosluk12),
            Wrap(alignment: WrapAlignment.center, spacing: OkumaTema.bosluk8, runSpacing: OkumaTema.bosluk8, children: oduller),
          ],
          const SizedBox(height: OkumaTema.bosluk12),
          Text(
            widget.kotaDolu ? OkumaMetin.sonucYarin : OkumaMetin.sonucTekrarGel,
            textAlign: TextAlign.center,
            style: OkumaTema.yazi(
              OkumaTema.yaziYardimci,
              kalinlik: OkumaTema.kalinlikVurgu,
              renk: OkumaTema.primaryDark,
              satir: OkumaTema.satirGovde,
            ),
          ),
        ],
      ),
    );

    // Sıradaki hikâye önerisi (kota doluysa önerilmez).
    final oneri = widget.kotaDolu ? null : widget.oneri;
    final oneriKarti = oneri == null || widget.onOneri == null
        ? null
        : OkumaKart(
            etiket: ': . .',
            onTap: widget.onOneri,
            child: Row(
              children: [
                const Icon(Icons.auto_stories_rounded, color: OkumaTema.primary, size: OkumaTema.ikonBuyuk - 12),
                const SizedBox(width: OkumaTema.bosluk12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        OkumaMetin.sonucSiradaki,
                        style: OkumaTema.yazi(OkumaTema.yaziEtiket, kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.muted),
                      ),
                      Text(
                        oneri.baslik,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OkumaTema.yazi(OkumaTema.yaziSecenek, kalinlik: OkumaTema.kalinlikVurgu, satir: 1.25),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: OkumaTema.primary),
              ],
            ),
          );

    // Alt alan: ana eylem üstte, ikincil iki eylem yan yana. Büyük yazıda (ölçek > 1.3) ikincil
    // eylemler alt alta dizilip kaydırılan içeriğe taşınır; sabit alt alanda yalnız ana eylem kalır,
    // böylece alt alan başlığı ve kartı ezmez (eski hâlde alt alan kısa ekranın yarısını alıyordu).
    final kahramanDugmesi = OkumaIkincilButon(etiket: OkumaMetin.kahramanDegistir, onPressed: widget.onKahraman);
    final pdfDugmesi = OkumaIkincilButon(
      etiket: _pdfBusy ? OkumaMetin.pdfHazirlaniyor : OkumaMetin.sonucPdf,
      onPressed: _pdfBusy ? null : _pdf,
    );
    // Kota dolduysa yeni hikâye seçtirmeyiz: ana eylem "Tamam" (Öğren sekmesine dön).
    final anaEtiket = widget.kotaDolu ? OkumaMetin.kotaTamam : OkumaMetin.sonucYeni;
    final anaEylem = widget.kotaDolu ? widget.onKapat : widget.onYeni;
    final ikincilDikey = <Widget>[
      if (!widget.kotaDolu) ...[kahramanDugmesi, const SizedBox(height: OkumaTema.bosluk8)],
      pdfDugmesi,
    ];
    final altEylemIcerik = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OkumaButon(etiket: anaEtiket, onPressed: anaEylem),
        if (!buyukYazi) ...[
          const SizedBox(height: OkumaTema.bosluk8),
          if (widget.kotaDolu)
            pdfDugmesi
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: kahramanDugmesi),
                const SizedBox(width: OkumaTema.bosluk8),
                Expanded(child: pdfDugmesi),
              ],
            ),
        ],
      ],
    );

    return OkumaEkranIskeleti(
      baslik: OkumaMetin.uygulamaAdi,
      icerik: [
        ustSatir,
        const SizedBox(height: OkumaTema.bosluk16),
        motivasyonKarti,
        if (widget.anketUyarisi) ...[
          const SizedBox(height: OkumaTema.bosluk12),
          Text(
            OkumaMetin.anketGonderilemedi,
            textAlign: TextAlign.center,
            style: OkumaTema.yazi(OkumaTema.yaziEtiket, renk: OkumaTema.muted),
          ),
        ],
        if (oneriKarti != null) ...[
          const SizedBox(height: OkumaTema.bosluk16),
          oneriKarti,
        ],
        if (buyukYazi) ...[
          const SizedBox(height: OkumaTema.bosluk16),
          ...ikincilDikey,
        ],
      ],
      altEylem: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: ekran.height * OkumaTema.sonucAltEylemOrani),
        child: SingleChildScrollView(child: altEylemIcerik),
      ),
    );
  }
}

/// XP / seri çipi: ikon + metin (renk tek başına taşıyıcı değildir).
class _OdulCipi extends StatelessWidget {
  const _OdulCipi({required this.ikon, required this.metin});

  final IconData ikon;
  final String metin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk12, vertical: OkumaTema.bosluk8),
      decoration: BoxDecoration(
        color: OkumaTema.sunSoft,
        borderRadius: BorderRadius.circular(OkumaTema.koseCip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: OkumaTema.ikonOrta, color: OkumaTema.ink),
          const SizedBox(width: OkumaTema.bosluk4),
          Flexible(child: Text(metin, style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu))),
        ],
      ),
    );
  }
}
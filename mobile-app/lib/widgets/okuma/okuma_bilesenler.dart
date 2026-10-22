// Okuma Dünyası ekranlarının ortak bileşenleri.
//
// Yeni bir tasarım sistemi DEĞİLDİR: düğmeler ChunkyButton, kartlar GameCard, maskot Hupo
// bileşenidir. Burada yalnız (1) büyük yazıda düğme yüksekliğini ayarlayan ince sarmalayıcılar,
// (2) ekran iskeleti ve (3) boş/hata bloğu bulunur.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

import '../../screens/okuma/okuma_tema.dart';
import '../../theme/app_theme.dart';
import '../ui/chunky_button.dart';
import '../ui/game_card.dart';
import '../hupo/hupo.dart';

/// Hupo maskotu. Dekoratifse ekran okuyucudan gizlenir; bilgi taşıyorsa [etiket] verilir.
class OkumaMaskot extends StatelessWidget {
  const OkumaMaskot({super.key, required this.poz, required this.boyut, this.etiket = ''});

  final HupoPose poz;
  final double boyut;
  final String etiket;

  @override
  Widget build(BuildContext context) => Hupo(pose: poz, size: boyut, semanticLabel: etiket);
}

/// Okuma ekranları için chip/girdi/alt sayfa görünümü (yalnız bu alt ağaçta geçerli).
class OkumaTemaKapsayici extends StatelessWidget {
  const OkumaTemaKapsayici({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final taban = Theme.of(context);
    // Chip/girdi yazıları uygulamanın seçili yazı tipini (Nunito/Lexend) açıkça kullanır.
    final aile = taban.textTheme.bodyMedium?.fontFamily;
    OutlineInputBorder kenar(Color renk, double kalinlik) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(OkumaTema.koseGirdi),
          borderSide: BorderSide(color: renk, width: kalinlik),
        );
    return Theme(
      data: taban.copyWith(
        chipTheme: ChipThemeData(
          backgroundColor: OkumaTema.surface,
          selectedColor: OkumaTema.primary,
          checkmarkColor: OkumaTema.surface,
          labelStyle: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu, aile: aile),
          secondaryLabelStyle: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.surface, aile: aile),
          side: const BorderSide(color: OkumaTema.muted, width: OkumaTema.kenarVarsayilan),
          shape: const StadiumBorder(),
          labelPadding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk8),
          padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk12, vertical: OkumaTema.bosluk8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: OkumaTema.surface,
          contentPadding: const EdgeInsets.all(OkumaTema.bosluk16),
          border: kenar(OkumaTema.muted, OkumaTema.kenarVarsayilan),
          enabledBorder: kenar(OkumaTema.muted, OkumaTema.kenarVarsayilan),
          focusedBorder: kenar(OkumaTema.primary, OkumaTema.odakHalkaKalinligi),
          errorBorder: kenar(OkumaTema.coralDark, OkumaTema.kenarUyari),
          focusedErrorBorder: kenar(OkumaTema.coralDark, OkumaTema.odakHalkaKalinligi),
          labelStyle: OkumaTema.yazi(OkumaTema.yaziYardimci, renk: OkumaTema.muted, aile: aile),
          hintStyle: OkumaTema.yazi(OkumaTema.yaziYardimci, renk: OkumaTema.muted, aile: aile),
          errorStyle: OkumaTema.yazi(OkumaTema.yaziHata, kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.coralDark, aile: aile),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: OkumaTema.surface,
          modalBackgroundColor: OkumaTema.surface,
          surfaceTintColor: Colors.transparent,
          showDragHandle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(OkumaTema.koseAltSayfa)),
          ),
        ),
      ),
      child: child,
    );
  }
}

/// Etiket için gereken düğme yüksekliği: en az 56 dp; büyük yazıda satır sayısına göre uzar.
double _butonYuksekligi(BuildContext context, String etiket, double genislik) {
  final olcek = MediaQuery.textScalerOf(context);
  final tp = TextPainter(
    text: TextSpan(text: etiket, style: appText(size: 17, weight: FontWeight.w800)),
    textDirection: TextDirection.ltr,
    textScaler: olcek,
    textAlign: TextAlign.center,
  )..layout(maxWidth: (genislik - 48).clamp(40.0, double.infinity));
  final gerekli = tp.height + 28;
  tp.dispose();
  return gerekli > OkumaTema.butonYukseklik ? gerekli : OkumaTema.butonYukseklik;
}

/// Ana eylem düğmesi (ChunkyButton). null ise pasif; [yukleniyor] iken dönen gösterge.
class OkumaButon extends StatelessWidget {
  const OkumaButon({super.key, required this.etiket, required this.onPressed, this.yukleniyor = false});

  final String etiket;
  final VoidCallback? onPressed;
  final bool yukleniyor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, kisit) => ChunkyButton(
        label: etiket,
        onPressed: onPressed,
        loading: yukleniyor,
        height: _butonYuksekligi(context, etiket, kisit.maxWidth.isFinite ? kisit.maxWidth : 320),
      ),
    );
  }
}

/// İkincil eylem: beyaz zeminli ChunkyButton.light.
class OkumaIkincilButon extends StatelessWidget {
  const OkumaIkincilButon({super.key, required this.etiket, required this.onPressed});

  final String etiket;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, kisit) => ChunkyButton(
        label: etiket,
        onPressed: onPressed,
        color: Colors.white,
        shadowColor: AppColors.lineDark,
        textColor: AppColors.primaryDark,
        height: _butonYuksekligi(context, etiket, kisit.maxWidth.isFinite ? kisit.maxWidth : 320),
      ),
    );
  }
}

/// Kabartmalı kart (GameCard). Dokunulabilirse tüm kart düğmedir; [etiket] ekran okuyucu içindir.
class OkumaKart extends StatelessWidget {
  const OkumaKart({
    super.key,
    required this.child,
    this.zemin = AppColors.surface,
    this.kenar = AppColors.line,
    this.onTap,
    this.etiket,
    this.secili = false,
    this.padding = const EdgeInsets.all(OkumaTema.bosluk16),
  });

  final Widget child;
  final Color zemin;
  final Color kenar;
  final VoidCallback? onTap;
  final String? etiket;
  final bool secili;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final kart = GameCard(
      color: zemin,
      borderColor: kenar,
      padding: padding,
      onTap: onTap,
      child: child,
    );
    if (etiket == null) return kart;
    return Semantics(
      button: onTap != null,
      selected: secili,
      label: etiket,
      onTap: onTap,
      child: ExcludeSemantics(child: kart),
    );
  }
}

/// Ekran kabuğu: appbar, yan boşluk (telefon 20, geniş 32), 720 dp içerik genişliği ve sabit alt eylem alanı.
class OkumaEkranIskeleti extends StatelessWidget {
  const OkumaEkranIskeleti({
    super.key,
    required this.baslik,
    required this.icerik,
    this.altEylem,
    this.geri,
    this.eylemler = const [],
    this.denetleyici,
    this.onKullaniciKaydirdi,
  });

  final String baslik;
  final List<Widget> icerik;
  final Widget? altEylem;
  final VoidCallback? geri;
  final List<Widget> eylemler;

  /// İçerik kaydırma denetleyicisi (okuyucunun otomatik kaydırması için).
  final ScrollController? denetleyici;

  /// Kullanıcı parmağıyla kaydırdığında çağrılır (otomatik kaydırmayı durdurmak için).
  final VoidCallback? onKullaniciKaydirdi;

  @override
  Widget build(BuildContext context) {
    return OkumaTemaKapsayici(
      child: Scaffold(
        backgroundColor: OkumaTema.background,
        appBar: AppBar(
          backgroundColor: OkumaTema.background,
          foregroundColor: OkumaTema.ink,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(baslik, style: OkumaTema.yazi(OkumaTema.yaziKartBaslik, kalinlik: OkumaTema.kalinlikBaslik)),
          leading: geri == null
              ? null
              : IconButton(
                  tooltip: OkumaMetin.geri,
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: geri,
                ),
          actions: eylemler,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, kisit) {
              final genis = kisit.maxWidth >= OkumaTema.kirilimGenis;
              final yan = genis ? OkumaTema.yanBoslukGenis : OkumaTema.yanBoslukTelefon;
              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: OkumaTema.icerikTablet),
                        child: NotificationListener<UserScrollNotification>(
                          onNotification: (n) {
                            if (n.direction != ScrollDirection.idle) onKullaniciKaydirdi?.call();
                            return false;
                          },
                          child: ListView(
                            controller: denetleyici,
                            // İçerik kısa; hepsi kurulu olsun ki cevap sonrası geri bildirim alanına (GlobalKey) kaydırılabilsin.
                            // ignore: deprecated_member_use
                            cacheExtent: 20000,
                            padding: EdgeInsets.fromLTRB(yan, OkumaTema.bosluk8, yan, OkumaTema.bosluk24),
                            children: icerik,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (altEylem != null)
                    Container(
                      width: double.infinity,
                      color: OkumaTema.background,
                      padding: EdgeInsets.fromLTRB(yan, OkumaTema.bosluk12, yan, OkumaTema.bosluk16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: OkumaTema.icerikTablet),
                          child: altEylem,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Hupo + başlık + kısa açıklama satırı. Maskot solda ya da sağda olabilir.
class BaslikSatiri extends StatelessWidget {
  const BaslikSatiri({
    super.key,
    required this.baslik,
    required this.maskot,
    this.alt,
    this.maskotSolda = true,
  });

  final String baslik;
  final String? alt;
  final Widget maskot;
  final bool maskotSolda;

  @override
  Widget build(BuildContext context) {
    final metin = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              baslik,
              style: OkumaTema.yazi(OkumaTema.yaziEkranBaslik, kalinlik: OkumaTema.kalinlikBaslik, satir: 1.2),
            ),
          ),
          if (alt != null) ...[
            const SizedBox(height: OkumaTema.bosluk8),
            Text(alt!, style: OkumaTema.yazi(OkumaTema.yaziYardimci, renk: OkumaTema.muted, satir: 1.4)),
          ],
        ],
      ),
    );
    return Row(
      children: maskotSolda
          ? [maskot, const SizedBox(width: OkumaTema.bosluk16), metin]
          : [metin, const SizedBox(width: OkumaTema.bosluk16), maskot],
    );
  }
}

/// Boş, hata ve uyumsuz durumlar için ortak blok: Hupo + başlık + açıklama + en çok iki eylem.
class DurumEkrani extends StatelessWidget {
  const DurumEkrani({
    super.key,
    required this.poz,
    required this.baslik,
    this.aciklama,
    this.birincilEtiket,
    this.birincil,
    this.ikincilEtiket,
    this.ikincil,
    this.pozBoyutu = OkumaTema.hupoOrta,
  });

  final HupoPose poz;
  final String baslik;
  final String? aciklama;
  final String? birincilEtiket;
  final VoidCallback? birincil;
  final String? ikincilEtiket;
  final VoidCallback? ikincil;
  final double pozBoyutu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OkumaTema.bosluk16),
      child: Column(
        children: [
          OkumaMaskot(poz: poz, boyut: pozBoyutu),
          const SizedBox(height: OkumaTema.bosluk16),
          Semantics(
            header: true,
            child: Text(
              baslik,
              textAlign: TextAlign.center,
              style: OkumaTema.yazi(OkumaTema.yaziKartBaslik + 2, kalinlik: OkumaTema.kalinlikBaslik, satir: 1.3),
            ),
          ),
          if (aciklama != null) ...[
            const SizedBox(height: OkumaTema.bosluk8),
            Text(
              aciklama!,
              textAlign: TextAlign.center,
              style: OkumaTema.yazi(OkumaTema.yaziYardimci, renk: OkumaTema.muted, satir: 1.4),
            ),
          ],
          if (birincilEtiket != null && birincil != null) ...[
            const SizedBox(height: OkumaTema.bosluk20),
            OkumaButon(etiket: birincilEtiket!, onPressed: birincil),
          ],
          if (ikincilEtiket != null && ikincil != null) ...[
            const SizedBox(height: OkumaTema.bosluk12),
            OkumaIkincilButon(etiket: ikincilEtiket!, onPressed: ikincil),
          ],
        ],
      ),
    );
  }
}

/// Hata satırı: ikon + metin (renk tek başına taşıyıcı değildir). Canlı bölgedir.
class OkumaHataSatiri extends StatelessWidget {
  const OkumaHataSatiri({super.key, required this.metin});

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: OkumaTema.coralDark, size: OkumaTema.ikonOrta),
          const SizedBox(width: OkumaTema.bosluk8),
          Expanded(
            child: Text(
              metin,
              style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.coralDark),
            ),
          ),
        ],
      ),
    );
  }
}

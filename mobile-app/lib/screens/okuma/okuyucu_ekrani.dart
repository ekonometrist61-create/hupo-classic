import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:okuma_motoru/okuma_motoru.dart'
    show
        Cikti,
        SayfaSecimi,
        Stil,
        hikayeSecimi,
        ikonBul,
        kIkonVarlikKlasoru,
        kMaskotIkonKimligi,
        okumaDakikasi;

import '../../providers/okuma_providers.dart';
import '../../services/okuma_cihaz_deposu.dart';
import '../../settings/app_settings.dart';
import '../../widgets/hupo/hupo.dart';
import '../../widgets/okuma/okuma_bilesenler.dart';
import '../../widgets/okuma/okuma_v3.dart';
import 'okuma_tema.dart';

/// Sayfa sayfa okuma ekranı. Hedef: çocuk hikâyeyi rahatça okur. Ana eylem: "Sonraki sayfa" /
/// "Sorulara geç". Durumlar: normal, boş hikâye, çevrimdışı uyarısı. Ayarlar (Sade/Zengin, yazı
/// boyutu, harf stili) cihazda saklanır.
/// Vurgu türleri: önemli yer (kalın, amber alt çizgi), kelime (teal, noktalı alt çizgi, dokununca anlam),
/// deyim (sarı zemin, dokununca anlam), atasözü (blok, dokununca anlam), çıkartma (emoji, en çok 3).
/// Sayfa başına vurgu ve çıkartma sınırı render anında uygulanır; fazlası düz metne döner.
class OkuyucuEkrani extends ConsumerStatefulWidget {
  const OkuyucuEkrani({
    super.key,
    required this.sayfalar,
    required this.anlamlar,
    required this.onBitti,
    this.baslik = 'Hikâye',
    this.onGeri,
    this.onSayfaGorundu,
    this.onSozcukAcildi,
    this.cevrimdisi = false,
    this.sinif = 4,
    this.tur = 'hikaye',
    this.sahneSlug,
  });

  /// Hikâyenin ana sınıfı; sayfa başına vurgu ve çıkartma bütçesini belirler.
  final int sinif;

  /// Tür kodu (gizem, macera, bilim, doga, mizah); başlık bandındaki çip ve sahne için.
  final String tur;

  /// Sahne görseli için hikâye adresi (assets/okuma/sahneler/<slug>.jpg); yoksa tür yedeği.
  final String? sahneSlug;

  final List<List<Cikti>> sayfalar;

  /// Sözcük yazımı → anlam.
  final Map<String, String> anlamlar;
  final VoidCallback onBitti;

  /// Appbar başlığı (hikâyenin adı).
  final String baslik;

  /// Hikâyelere dönüş; null ise geri düğmesi yoktur.
  final VoidCallback? onGeri;

  /// Yeni bir sayfa görüldü (0 tabanlı). Bırakılan sayfa analitiği içindir.
  final void Function(int indeks)? onSayfaGorundu;

  /// Bir kelime/deyim/atasözünün anlamı açıldı.
  final void Function(String metin)? onSozcukAcildi;

  /// İnternet yok, hikâye cihazdan okunuyor.
  final bool cevrimdisi;

  @override
  ConsumerState<OkuyucuEkrani> createState() => _OkuyucuEkraniState();
}

/// Bir sayfadaki hangi parçaların vurgulanacağı (bütçe sonucu, indeks kümeleri).
class _Butce {
  const _Butce(this.vurgu, this.cikartma);
  final Set<int> vurgu;
  final Set<int> cikartma;
}

class _OkuyucuEkraniState extends ConsumerState<OkuyucuEkrani>
    with TickerProviderStateMixin {
  int _sayfa = 0;
  bool _ileri = true;
  late bool _sade;
  late bool _buyuk;
  late bool _lexend;

  /// Kelime ve deyim dokunma tanıyıcıları. Sayfa ve indekse göre önbelleklenir; dispose'da kapanır.
  final Map<String, TapGestureRecognizer> _tanyicilar = {};

  /// Uzun sayfa: birkaç saniye sonra yavaşça aşağı kayar ki çocuk metnin tamamını görsün.
  /// Kullanıcı dokunduğunda durur; hareket azaltma açıksa hiç kaymaz.
  final ScrollController _kaydirma = ScrollController();
  Timer? _kaydirmaZamani;
  static const _kaydirmaBeklemesi = Duration(seconds: 3);
  static const _kaydirmaHizi = 35.0; // piksel / saniye

  void _kaydirmayiDurdur() {
    _kaydirmaZamani?.cancel();
    if (_kaydirma.hasClients && _kaydirma.position.isScrollingNotifier.value) {
      _kaydirma.jumpTo(_kaydirma.position.pixels);
    }
  }

  void _otomatikKaydirmaPlanla() {
    _kaydirmaZamani?.cancel();
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    _kaydirmaZamani = Timer(_kaydirmaBeklemesi, () {
      if (!mounted || !_kaydirma.hasClients) return;
      final son = _kaydirma.position.maxScrollExtent;
      if (son <= 0) return;
      final ms = (son / _kaydirmaHizi * 1000).round().clamp(4000, 20000);
      _kaydirma.animateTo(son, duration: Duration(milliseconds: ms), curve: Curves.easeInOut);
    });
  }

  void _sayfaBasinaDon() {
    _kaydirmaZamani?.cancel();
    if (_kaydirma.hasClients) _kaydirma.jumpTo(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _otomatikKaydirmaPlanla();
    });
  }

  List<List<Cikti>> get _sayfalar => widget.sayfalar;
  List<Cikti> get _mevcut => _sayfalar[_sayfa];

  @override
  void initState() {
    super.initState();
    final depo = ref.read(okumaCihazDeposuProvider);
    _sade = depo.okumaModu == 'sade';
    _buyuk = depo.buyukYazi;
    // Okuma yazı tipi seçilmediyse uygulamanın genel yazı tipi ayarı geçerli.
    _lexend = depo.lexend ?? ref.read(settingsProvider).font == AppFont.lexend;
    if (_sayfalar.isNotEmpty) widget.onSayfaGorundu?.call(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _otomatikKaydirmaPlanla();
    });
  }

  @override
  void dispose() {
    _kaydirmaZamani?.cancel();
    _kaydirma.dispose();
    for (final t in _tanyicilar.values) {
      t.dispose();
    }
    super.dispose();
  }

  /// Gösterim kuralları (tek kaynak: okuma_motoru `hikayeSecimi`): ilk geçiş, cümle başına tek
  /// vurgu, sınıfa ve moda göre sayfa bütçesi. Sade/Zengin değişince yeniden hesaplanır.
  List<SayfaSecimi>? _secim;
  bool? _secimSade;

  _Butce _butce(List<Cikti> sayfa) {
    if (_secim == null || _secimSade != _sade) {
      _secim = hikayeSecimi(_sayfalar, sinif: widget.sinif, sade: _sade);
      _secimSade = _sade;
    }
    final s = _secim![_sayfa.clamp(0, _secim!.length - 1)];
    return _Butce(s.vurgu, s.cikartma);
  }

  /// Kelime alt sayfasındaki örnek: sayfadaki, sözcüğü içeren ilk cümle. Yoksa null.
  String? _ornekCumle(String kelime) {
    final metin = _mevcut.map((c) => c.metin).join();
    final aranan = kelime.toLowerCase();
    for (final m in RegExp(r'[^.!?…]+[.!?…]?').allMatches(metin)) {
      final cumle = m.group(0)!.trim();
      if (cumle.isNotEmpty && cumle.toLowerCase().contains(aranan))
        return cumle;
    }
    return null;
  }

  TapGestureRecognizer _tanyici(String anahtar, VoidCallback onTap) =>
      _tanyicilar.putIfAbsent(
          '$_sayfa:$anahtar', () => TapGestureRecognizer()..onTap = onTap);

  TextStyle _taban() => OkumaTema.yazi(
        _buyuk ? OkumaTema.yaziOkumaBuyuk : OkumaTema.yaziOkuma,
        satir: _buyuk ? OkumaTema.satirOkumaBuyuk : OkumaTema.satirOkuma,
        harf: 0.2,
        aile: _lexend ? OkumaTema.yaziAileOkuma : OkumaTema.yaziAileVarsayilan,
      );

  InlineSpan _parca(int i, Cikti c, _Butce b, TextStyle taban) {
    final vurgulu = b.vurgu.contains(i);
    switch (c.stil) {
      case Stil.normal:
        return TextSpan(text: c.metin, style: taban);
      case Stil.onemli:
        return TextSpan(
          text: c.metin,
          style: vurgulu
              ? taban.copyWith(
                  fontWeight: OkumaTema.kalinlikVurgu,
                  decoration: TextDecoration.underline,
                  decorationColor: OkumaTema.vurguAmber,
                  decorationThickness: 2.5,
                )
              : taban,
        );
      case Stil.kelime:
        if (!vurgulu) return TextSpan(text: c.metin, style: taban);
        return TextSpan(
          text: c.metin,
          style: taban.copyWith(
            fontWeight: OkumaTema.kalinlikVurgu,
            color: OkumaTema.primaryDark,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: OkumaTema.primary,
            decorationThickness: 2,
          ),
          recognizer:
              _tanyici('$i', () => _sozAc(c.metin, OkumaMetin.sozlukKelime)),
        );
      case Stil.deyim:
        if (!vurgulu) return TextSpan(text: c.metin, style: taban);
        return TextSpan(
          text: c.metin,
          style: taban.copyWith(
              fontWeight: OkumaTema.kalinlikVurgu,
              backgroundColor: OkumaTema.sunSoft),
          recognizer:
              _tanyici('$i', () => _sozAc(c.metin, OkumaMetin.sozlukDeyim)),
        );
      case Stil.atasozu:
        // Sayfadaki ilk atasözü blok olarak gösterilir; ikinci ve sonrası satır içi tırnaklı metindir.
        return TextSpan(
          text: '“${c.metin}”',
          style: taban.copyWith(
              fontStyle: FontStyle.italic, fontWeight: OkumaTema.kalinlikGovde),
        );
      case Stil.isaret:
        // Emoji glifi yerine katalog SVG'si (K3). Maskot metin içinde gösterilmez (K8).
        final kimlik = c.ikonId;
        if (kimlik == null ||
            kimlik == kMaskotIkonKimligi ||
            !b.cikartma.contains(i)) return const TextSpan(text: '');
        final kayit = ikonBul(kimlik);
        if (kayit == null) return const TextSpan(text: '');
        final boy =
            (taban.fontSize ?? OkumaTema.yaziOkuma) + OkumaTema.cikartmaFarki;
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            // Çıkartma süs amaçlıdır; anlamı metin taşır, ekran okuyucuda atlanır.
            child: SvgPicture.asset('$kIkonVarlikKlasoru${kayit.renkliDosya}',
                height: boy, excludeFromSemantics: true),
          ),
        );
    }
  }

  /// Sayfayı paragraf parçalarına böler: satır içi akış, arada atasözü bloğu.
  List<Widget> _parcalar(List<Cikti> sayfa, _Butce b, TextStyle taban) {
    final parcalar = <Widget>[];
    var satir = <InlineSpan>[];
    var atasozuVar = false;

    void akit() {
      if (satir.isEmpty) return;
      parcalar.add(Text.rich(TextSpan(style: taban, children: satir)));
      satir = <InlineSpan>[];
    }

    for (var i = 0; i < sayfa.length; i++) {
      final c = sayfa[i];
      if (c.stil == Stil.atasozu && !atasozuVar) {
        atasozuVar = true;
        akit();
        parcalar.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: OkumaTema.bosluk8),
          child: OkumaAtasozuKarti(
            metin: c.metin,
            onTap: () => _sozAc(c.metin, OkumaMetin.sozlukAtasozu),
          ),
        ));
        continue;
      }
      satir.add(_parca(i, c, b, taban));
    }
    akit();
    return parcalar;
  }

  void _sozAc(String metin, String etiket) {
    widget.onSozcukAcildi?.call(metin);
    final anlam = widget.anlamlar[metin] ?? OkumaMetin.anlamYok;
    final ornek =
        etiket == OkumaMetin.sozlukAtasozu ? null : _ornekCumle(metin);
    final denetleyici = AnimationController(
      vsync: this,
      duration: OkumaTema.sure(context, OkumaTema.hareketAltSayfa),
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      transitionAnimationController: denetleyici,
      builder: (ctx) => OkumaKelimePaneli(
        etiket: etiket,
        metin: metin,
        anlam: anlam,
        ornek: ornek,
        onKapat: () => Navigator.pop(ctx),
      ),
    ).whenComplete(denetleyici.dispose);
  }

  /// "Sayfadaki kelimeler": tüm vurgular, sayfa bütçesinden bağımsız. Ekran okuyucu için yedek erişim.
  void _kelimelerAc() {
    final satirlar = <({String metin, String etiket})>[];
    final gorulen = <String>{};
    for (final c in _mevcut) {
      final etiket = switch (c.stil) {
        Stil.kelime => OkumaMetin.sozlukKelime,
        Stil.deyim => OkumaMetin.sozlukDeyim,
        Stil.atasozu => OkumaMetin.sozlukAtasozu,
        _ => null,
      };
      if (etiket == null || !gorulen.add(c.metin)) continue;
      satirlar.add((metin: c.metin, etiket: etiket));
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              OkumaTema.yanBoslukTelefon,
              OkumaTema.bosluk8,
              OkumaTema.yanBoslukTelefon,
              OkumaTema.bosluk20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                OkumaMetin.okuyucuKelimeler,
                style: OkumaTema.yazi(OkumaTema.yaziEkranBaslik - 4,
                    kalinlik: OkumaTema.kalinlikBaslik),
              ),
              const SizedBox(height: OkumaTema.bosluk12),
              if (satirlar.isEmpty)
                Text(
                  OkumaMetin.okuyucuKelimeYok,
                  style: OkumaTema.yazi(OkumaTema.yaziYardimci,
                      renk: OkumaTema.muted),
                )
              else
                for (final s in satirlar)
                  ListTile(
                    minTileHeight: OkumaTema.butonYukseklik,
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.metin,
                        style: OkumaTema.yazi(OkumaTema.yaziSecenek,
                            kalinlik: OkumaTema.kalinlikVurgu)),
                    subtitle: Text(s.etiket,
                        style: OkumaTema.yazi(OkumaTema.yaziEtiket,
                            renk: OkumaTema.muted)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: OkumaTema.primary),
                    onTap: () {
                      Navigator.pop(ctx);
                      _sozAc(s.metin, s.etiket);
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  /// Okuma ayarları: mod (Sade/Zengin), yazı boyutu, harf stili. Değişiklik hem sayfayı hem sayfayı açık alt sayfayı günceller.
  void _ayarlariAc() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void guncelle(VoidCallback degisiklik) {
            setState(degisiklik);
            setSheet(() {});
            final depo = ref.read(okumaCihazDeposuProvider);
            depo.okumaModuYaz(_sade ? 'sade' : 'zengin');
            depo.buyukYaziYaz(_buyuk);
            depo.lexendYaz(_lexend);
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  OkumaTema.yanBoslukTelefon,
                  OkumaTema.bosluk8,
                  OkumaTema.yanBoslukTelefon,
                  OkumaTema.bosluk20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OkumaMetin.okuyucuAyar,
                    style: OkumaTema.yazi(OkumaTema.yaziEkranBaslik - 4,
                        kalinlik: OkumaTema.kalinlikBaslik),
                  ),
                  const SizedBox(height: OkumaTema.bosluk16),
                  const _AyarBasligi(OkumaMetin.okuyucuMod),
                  Wrap(
                    spacing: OkumaTema.bosluk8,
                    runSpacing: OkumaTema.bosluk8,
                    children: [
                      ChoiceChip(
                        label: const Text(OkumaMetin.sade),
                        selected: _sade,
                        onSelected: (_) => guncelle(() => _sade = true),
                      ),
                      ChoiceChip(
                        label: const Text(OkumaMetin.zengin),
                        selected: !_sade,
                        onSelected: (_) => guncelle(() => _sade = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: OkumaTema.bosluk8),
                  Text(
                    _sade ? OkumaMetin.modSadeNot : OkumaMetin.modZenginNot,
                    style: OkumaTema.yazi(OkumaTema.yaziYardimci,
                        renk: OkumaTema.muted, satir: 1.4),
                  ),
                  const SizedBox(height: OkumaTema.bosluk16),
                  const _AyarBasligi(OkumaMetin.okuyucuYazi),
                  Wrap(
                    spacing: OkumaTema.bosluk8,
                    runSpacing: OkumaTema.bosluk8,
                    children: [
                      ChoiceChip(
                        label: const Text(OkumaMetin.normal),
                        selected: !_buyuk,
                        onSelected: (_) => guncelle(() => _buyuk = false),
                      ),
                      ChoiceChip(
                        label: const Text(OkumaMetin.buyukYazi),
                        selected: _buyuk,
                        onSelected: (_) => guncelle(() => _buyuk = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: OkumaTema.bosluk16),
                  const _AyarBasligi(OkumaMetin.okuyucuHarf),
                  Wrap(
                    spacing: OkumaTema.bosluk8,
                    runSpacing: OkumaTema.bosluk8,
                    children: [
                      ChoiceChip(
                        label: const Text(OkumaMetin.harfStandart),
                        selected: !_lexend,
                        onSelected: (_) => guncelle(() => _lexend = false),
                      ),
                      ChoiceChip(
                        label: const Text(OkumaMetin.harfOkuma),
                        selected: _lexend,
                        onSelected: (_) => guncelle(() => _lexend = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: OkumaTema.bosluk20),
                  OkumaIkincilButon(
                      etiket: OkumaMetin.kapat,
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Hikâyenin atasözleri (tekrarsız). Anlamı olmayan atasözü Düşün'e alınmaz: uydurma anlam gösterilmez.
  List<({String metin, String anlam})> _dusunAtasozleri() {
    final gorulen = <String>{};
    return [
      for (final sayfa in _sayfalar)
        for (final c in sayfa)
          if (c.stil == Stil.atasozu &&
              gorulen.add(c.metin) &&
              (widget.anlamlar[c.metin]?.trim().isNotEmpty ?? false))
            (metin: c.metin, anlam: widget.anlamlar[c.metin]!.trim()),
    ];
  }

  void _sayfaGec(int yeni) {
    setState(() {
      _ileri = yeni > _sayfa;
      _sayfa = yeni;
    });
    _sayfaBasinaDon();
    widget.onSayfaGorundu?.call(yeni);
  }

  @override
  Widget build(BuildContext context) {
    if (_sayfalar.isEmpty) {
      return OkumaEkranIskeleti(
        baslik: widget.baslik,
        geri: widget.onGeri,
        icerik: [
          DurumEkrani(
            poz: HupoPose.birDahaDene,
            baslik: OkumaMetin.okuyucuBos,
            birincilEtiket: OkumaMetin.hikayelereDon,
            birincil: widget.onGeri,
          ),
        ],
      );
    }
    final son = _sayfa == _sayfalar.length - 1;
    final toplam = _sayfalar.length;
    final b = _butce(_mevcut);
    final taban = _taban();
    final parcalar = _parcalar(_mevcut, b, taban);
    final dusunAtasozleri = _dusunAtasozleri();
    return OkumaEkranIskeleti(
      baslik: widget.baslik,
      geri: widget.onGeri,
      denetleyici: _kaydirma,
      onKullaniciKaydirdi: _kaydirmayiDurdur,
      eylemler: [
        IconButton(
          tooltip: OkumaMetin.okuyucuKelimeler,
          icon: const Icon(Icons.format_list_bulleted_rounded),
          onPressed: _kelimelerAc,
        ),
        IconButton(
          tooltip: OkumaMetin.okuyucuAyar,
          icon: const Icon(Icons.text_fields_rounded),
          onPressed: _ayarlariAc,
        ),
      ],
      icerik: [
        if (widget.cevrimdisi) ...[
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(OkumaTema.bosluk12),
              decoration: BoxDecoration(
                  color: OkumaTema.sunSoft,
                  borderRadius: BorderRadius.circular(OkumaTema.koseGirdi)),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: OkumaTema.ikonOrta, color: OkumaTema.ink),
                  const SizedBox(width: OkumaTema.bosluk8),
                  Expanded(
                    child: Text(
                      OkumaMetin.hikayeCevrimdisi,
                      style: OkumaTema.yazi(OkumaTema.yaziEtiket,
                          kalinlik: OkumaTema.kalinlikVurgu),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OkumaTema.bosluk12),
        ],
        OkumaBaslikBandi(
          baslik: widget.baslik,
          tur: widget.tur,
          sinifEtiketi: okumaSinifEtiketi(widget.sinif, widget.sinif),
          dakika: okumaDakikasi(_sayfalar, widget.sinif),
        ),
        const SizedBox(height: OkumaTema.bosluk16),
        OkumaIlerleme(
            deger: (_sayfa + 1) / toplam,
            etiket: OkumaMetin.okuyucuSayfa(_sayfa + 1, toplam)),
        if (dusunAtasozleri.isNotEmpty) ...[
          const SizedBox(height: OkumaTema.bosluk12),
          _AdimSatiri(dusunde: son),
        ],
        // Sahne: ilk sayfada büyük; sonraki sayfalarda dar şerit. Sade modda ve 7–8. sınıfta yalnız ilk sayfa.
        if (_sayfa == 0) ...[
          const SizedBox(height: OkumaTema.bosluk16),
          OkumaSahne(tur: widget.tur, slug: widget.sahneSlug),
        ] else if (!_sade && widget.sinif <= 6) ...[
          const SizedBox(height: OkumaTema.bosluk12),
          OkumaSahne(tur: widget.tur, yukseklik: 56, slug: widget.sahneSlug),
        ],
        const SizedBox(height: OkumaTema.bosluk16),
        // Sayfa geçişi: hafif kayma ve belirme. Hareket azaltmada süre sıfır, geçiş anlık.
        TweenAnimationBuilder<double>(
          key: ValueKey<int>(_sayfa),
          tween: Tween<double>(begin: 0, end: 1),
          duration: OkumaTema.sure(context, OkumaTema.hareketSayfa),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) {
            final gorunur = t < 0 ? 0.0 : (t > 1 ? 1.0 : t);
            final yon = _ileri ? 1.0 : -1.0;
            return Opacity(
              opacity: gorunur,
              child: Transform.translate(
                offset:
                    Offset((1 - t) * OkumaTema.hareketSayfaKaymasi * yon, 0),
                child: child,
              ),
            );
          },
          child: _SayfaKagidi(parcalar: parcalar),
        ),
        // Düşün isteğe bağlıdır: son sayfada kart görünür, sorulara geçişi engellemez.
        if (son && dusunAtasozleri.isNotEmpty) ...[
          const SizedBox(height: OkumaTema.bosluk16),
          _DusunKarti(atasozler: dusunAtasozleri),
        ],
      ],
      altEylem: _altDugmeler(son),
    );
  }
}

extension on _OkuyucuEkraniState {
  /// Önceki / Sonraki düğmeleri. Büyük yazıda (2x gibi) yan yana sığmaz ve sözcük ortadan bölünürdü;
  /// o zaman asıl eylem üstte, "Önceki" altta tam genişlikte durur.
  Widget _altDugmeler(bool son) {
    final onceki = OkumaIkincilButon(
      etiket: OkumaMetin.onceki,
      onPressed: _sayfa == 0 ? null : () => _sayfaGec(_sayfa - 1),
    );
    final sonraki = OkumaButon(
      etiket: son ? OkumaMetin.sorularaGec : OkumaMetin.sonrakiSayfa,
      onPressed: son ? widget.onBitti : () => _sayfaGec(_sayfa + 1),
    );
    if (MediaQuery.textScalerOf(context).scale(16) > 24) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [sonraki, const SizedBox(height: OkumaTema.bosluk8), onceki],
      );
    }
    return Row(
      children: [
        Expanded(flex: 2, child: onceki),
        const SizedBox(width: OkumaTema.bosluk12),
        Expanded(flex: 3, child: sonraki),
      ],
    );
  }
}

/// Sayfa kağıdı: beyaz, yuvarlak köşeli, hafif gölgeli. Metin seçimi kapalıdır.
class _SayfaKagidi extends StatelessWidget {
  const _SayfaKagidi({required this.parcalar});

  final List<Widget> parcalar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OkumaTema.bosluk24),
      decoration: BoxDecoration(
        color: OkumaTema.surface,
        borderRadius: BorderRadius.circular(OkumaTema.koseKart),
        boxShadow: OkumaTema.kartGolge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parcalar,
      ),
    );
  }
}

/// İki adımlı gösterge: Oku (sayfalar) ve Düşün (son sayfa, isteğe bağlı).
class _AdimSatiri extends StatelessWidget {
  const _AdimSatiri({required this.dusunde});

  final bool dusunde;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OkumaAdimRozeti(sira: 1, etiket: OkumaMetin.adimOku, aktif: !dusunde),
        const SizedBox(width: OkumaTema.bosluk8),
        const Icon(Icons.chevron_right_rounded,
            size: OkumaTema.ikonOrta, color: OkumaTema.muted),
        const SizedBox(width: OkumaTema.bosluk8),
        OkumaAdimRozeti(sira: 2, etiket: OkumaMetin.adimDusun, aktif: dusunde),
      ],
    );
  }
}

/// Son sayfadaki isteğe bağlı Düşün kartı: atasözü, anlamı ve cihaza "Sözlüğe ekle".
/// Ödül, XP veya süre yoktur; kayıt yalnız bu cihazda, hesap anahtarlı rafta tutulur.
class _DusunKarti extends ConsumerStatefulWidget {
  const _DusunKarti({required this.atasozler});

  final List<({String metin, String anlam})> atasozler;

  @override
  ConsumerState<_DusunKarti> createState() => _DusunKartiState();
}

class _DusunKartiState extends ConsumerState<_DusunKarti> {
  final Set<String> _eklenen = {};

  @override
  void initState() {
    super.initState();
    final depo = ref.read(okumaCihazDeposuProvider);
    for (final a in widget.atasozler) {
      if (depo.sozlugumde(a.metin)) _eklenen.add(a.metin);
    }
  }

  Future<void> _ekle(({String metin, String anlam}) a) async {
    await ref.read(okumaCihazDeposuProvider).sozlugeEkle(
          OkumaSozlukKaydi(metin: a.metin, anlam: a.anlam, at: DateTime.now()),
        );
    if (!mounted) return;
    setState(() => _eklenen.add(a.metin));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OkumaTema.bosluk16),
      decoration: BoxDecoration(
        color: OkumaTema.background,
        borderRadius: BorderRadius.circular(OkumaTema.koseGirdi),
        border: Border.all(
            color: OkumaTema.lineDark, width: OkumaTema.kenarVarsayilan),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            OkumaMetin.adimDusun,
            style: OkumaTema.yazi(OkumaTema.yaziEtiket,
                kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.muted),
          ),
          const SizedBox(height: OkumaTema.bosluk4),
          Text(
            OkumaMetin.dusunIpucu,
            style: OkumaTema.yazi(OkumaTema.yaziYardimci,
                renk: OkumaTema.muted, satir: 1.4),
          ),
          for (final a in widget.atasozler) ...[
            const SizedBox(height: OkumaTema.bosluk16),
            Text(
              '“${a.metin}”',
              style: OkumaTema.yazi(OkumaTema.yaziSozlukAnlam)
                  .copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: OkumaTema.bosluk8),
            OkumaAnlamKutusu(anlam: a.anlam),
            const SizedBox(height: OkumaTema.bosluk8),
            if (_eklenen.contains(a.metin))
              Semantics(
                liveRegion: true,
                child: Text(
                  OkumaMetin.sozlugeEklendi,
                  style: OkumaTema.yazi(OkumaTema.yaziEtiket,
                      kalinlik: OkumaTema.kalinlikVurgu,
                      renk: OkumaTema.primary),
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: OkumaIkincilButon(
                    etiket: OkumaMetin.sozlugeEkle, onPressed: () => _ekle(a)),
              ),
          ],
        ],
      ),
    );
  }
}

class _AyarBasligi extends StatelessWidget {
  const _AyarBasligi(this.metin);

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OkumaTema.bosluk8),
      child: Text(metin,
          style: OkumaTema.yazi(OkumaTema.yaziYardimci,
              kalinlik: OkumaTema.kalinlikVurgu)),
    );
  }
}

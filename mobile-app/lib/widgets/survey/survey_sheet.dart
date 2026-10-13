import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/survey_models.dart';
import '../../providers/app_providers.dart';
import '../../services/survey_repository.dart';
import '../../theme/app_theme.dart';
import '../ui/chunky_button.dart';
import '../ui/hupo_focus.dart';

const String _anonimMetni = 'Yanıtınız kimliğinizle ilişkilendirilmez.';
const String _kimlikliMetni =
    'Yanıtınız hesabınızla ilişkilendirilir; yalnızca hizmeti iyileştirmek için kullanılır, '
    'ticari iletişim izni yerine geçmez.';
const String _gonderEtiketi = 'Yanıtları gönder';
const String _kapatEtiketi = 'Kapat';
const String _tesekkur = 'Teşekkürler! Yanıtlar kaydedildi.';
const String _npsSol = '0 · hiç önermem';
const String _npsSag = '10 · kesinlikle öneririm';
const String _csatSol = 'Hiç memnun değilim';
const String _csatSag = 'Çok memnunum';
const String _evet = 'Evet';
const String _hayir = 'Hayır';
const String _metinIpucu = 'Yanıtını yaz';

/// Anketi soru soru dolduran alt sayfa. Gönderim başarılıysa teşekkür gösterilir.
class SurveySheet extends ConsumerStatefulWidget {
  const SurveySheet({super.key, required this.anket});

  final Anket anket;

  @override
  ConsumerState<SurveySheet> createState() => _SurveySheetState();
}

class _SurveySheetState extends ConsumerState<SurveySheet> {
  /// Kullanıcının verdiği ham yanıtlar. Görünmeyen sorunun değeri silinmez;
  /// yalnızca gönderimde ayıklanır (bkz. AnketDegerlendirme).
  final Map<String, Object?> _ham = {};
  bool _gonderiliyor = false;
  bool _tesekkurEdildi = false;
  String? _hata;

  void _yanitla(String soruId, Object? deger) {
    if (_gonderiliyor) return;
    setState(() {
      if (deger == null) {
        _ham.remove(soruId);
      } else {
        _ham[soruId] = deger;
      }
      _hata = null;
    });
  }

  Future<void> _gonder(AnketDegerlendirme degerlendirme) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    setState(() {
      _gonderiliyor = true;
      _hata = null;
    });
    try {
      await ref.read(surveyRepositoryProvider).yanitGonder(
            anketId: widget.anket.id,
            yanitlar: degerlendirme.gecerliYanitlar,
          );
      ref.invalidate(aktifAnketlerProvider);
      if (!mounted) return;
      setState(() {
        _gonderiliyor = false;
        _tesekkurEdildi = true;
      });
    } on AnketException catch (e) {
      if (!mounted) return;
      setState(() => _gonderiliyor = false);
      switch (e.hata) {
        case AnketHatasi.yakinZamanda || AnketHatasi.bulunamadi:
          // Bu anket artık bu veli için geçerli değil: sessizce kapat, kartı kaldır.
          ref.invalidate(aktifAnketlerProvider);
          messenger?.showSnackBar(SnackBar(content: Text(e.mesaj)));
          navigator.pop();
        default:
          setState(() => _hata = e.mesaj);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final anket = widget.anket;
    final degerlendirme = AnketDegerlendirme.hesapla(anket.sorular, _ham);
    final yukseklik = MediaQuery.sizeOf(context).height * 0.9;
    final klavye = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: klavye),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: yukseklik),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: _tesekkurEdildi
                ? _TesekkurGorunumu(onKapat: () => Navigator.of(context).pop())
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(anket.ad, style: appText(size: 20, weight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(
                        anket.anonim ? _anonimMetni : _kimlikliMetni,
                        style: appText(size: 13, weight: FontWeight.w700, color: AppColors.muted),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final soru in degerlendirme.gorunenSorular) ...[
                                _SoruBasligi(baslik: soru.baslik),
                                const SizedBox(height: 10),
                                _soruGovdesi(soru),
                                const SizedBox(height: 22),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (_hata != null) ...[
                        const SizedBox(height: 8),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _hata!,
                            textAlign: TextAlign.center,
                            style: appText(size: 14, weight: FontWeight.w800, color: AppColors.coralDark),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      ChunkyButton(
                        label: _gonderEtiketi,
                        height: 52,
                        loading: _gonderiliyor,
                        onPressed: degerlendirme.gonderilebilir && !_gonderiliyor
                            ? () => _gonder(degerlendirme)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      ChunkyButton.light(
                        label: _kapatEtiketi,
                        onPressed: _gonderiliyor ? null : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _soruGovdesi(AnketSorusu soru) {
    final deger = _ham[soru.id];
    return switch (soru.tur) {
      AnketSoruTuru.nps => _NpsSecici(
          secili: deger is int ? deger : null,
          onSec: (n) => _yanitla(soru.id, n),
        ),
      AnketSoruTuru.csat => _CsatSecici(
          secili: deger is int ? deger : null,
          onSec: (n) => _yanitla(soru.id, n),
        ),
      AnketSoruTuru.onay => Row(
          children: [
            Expanded(
              child: _Secenek(
                etiket: _evet,
                secili: deger == true,
                onSec: () => _yanitla(soru.id, true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Secenek(
                etiket: _hayir,
                secili: deger == false,
                onSec: () => _yanitla(soru.id, false),
              ),
            ),
          ],
        ),
      AnketSoruTuru.tekSecim => Column(
          children: [
            for (final secenek in soru.secenekler) ...[
              _Secenek(
                etiket: secenek,
                secili: deger == secenek,
                sola: true,
                onSec: () => _yanitla(soru.id, secenek),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      AnketSoruTuru.kisaMetin => _MetinAlani(
          key: ValueKey(soru.id),
          ilk: deger is String ? deger : null,
          uzun: false,
          onDegisti: (metin) => _yanitla(soru.id, metin),
        ),
      AnketSoruTuru.uzunMetin => _MetinAlani(
          key: ValueKey(soru.id),
          ilk: deger is String ? deger : null,
          uzun: true,
          onDegisti: (metin) => _yanitla(soru.id, metin),
        ),
    };
  }
}

class _SoruBasligi extends StatelessWidget {
  const _SoruBasligi({required this.baslik});

  final String baslik;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(baslik, style: appText(size: 17, weight: FontWeight.w800)),
    );
  }
}

/// Tek bir dokunmatik seçenek. En az 44 px; klavye odağı ve Semantics ile.
class _Secenek extends StatelessWidget {
  const _Secenek({
    required this.etiket,
    required this.secili,
    required this.onSec,
    this.sola = false,
  });

  final String etiket;
  final bool secili;
  final VoidCallback onSec;

  /// Uzun metinli seçenekler (tek seçim) sola hizalanır.
  final bool sola;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: secili,
      label: etiket,
      excludeSemantics: true,
      child: HupoFocus(
        onActivate: onSec,
        borderRadius: 14,
        builder: (context, hovered) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSec,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            constraints: const BoxConstraints(minWidth: 46, minHeight: 52),
            alignment: sola ? Alignment.centerLeft : Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: secili ? AppColors.primarySoft : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: secili ? AppColors.primary : AppColors.lineDark,
                width: secili ? 2.5 : 1.5,
              ),
            ),
            child: Text(
              etiket,
              textAlign: sola ? TextAlign.start : TextAlign.center,
              style: appText(
                weight: FontWeight.w800,
                color: secili ? AppColors.primaryDark : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// NPS: 0-10 arası, 46 px kutular; dar ekranda satırlara kendiliğinden kırılır.
class _NpsSecici extends StatelessWidget {
  const _NpsSecici({required this.secili, required this.onSec});

  final int? secili;
  final ValueChanged<int> onSec;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var n = 0; n <= 10; n++)
              _Secenek(
                etiket: '$n',
                secili: secili == n,
                onSec: () => onSec(n),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(_npsSol, style: appText(size: 13, weight: FontWeight.w700, color: AppColors.muted)),
            ),
            Text(_npsSag, style: appText(size: 13, weight: FontWeight.w700, color: AppColors.muted)),
          ],
        ),
      ],
    );
  }
}

/// CSAT: 1-5 arası beş seçenek.
class _CsatSecici extends StatelessWidget {
  const _CsatSecici({required this.secili, required this.onSec});

  final int? secili;
  final ValueChanged<int> onSec;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var n = 1; n <= 5; n++) ...[
              if (n > 1) const SizedBox(width: 6),
              Expanded(
                child: _Secenek(
                  etiket: '$n',
                  secili: secili == n,
                  onSec: () => onSec(n),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(_csatSol, style: appText(size: 13, weight: FontWeight.w700, color: AppColors.muted)),
            ),
            Text(_csatSag, style: appText(size: 13, weight: FontWeight.w700, color: AppColors.muted)),
          ],
        ),
      ],
    );
  }
}

/// Kısa ve uzun metin. Başlangıç değeri, koşul nedeniyle gizlenip geri gelen
/// soruda kaybolmasın diye dışarıdan verilir.
class _MetinAlani extends StatefulWidget {
  const _MetinAlani({super.key, required this.ilk, required this.uzun, required this.onDegisti});

  final String? ilk;
  final bool uzun;
  final ValueChanged<String> onDegisti;

  @override
  State<_MetinAlani> createState() => _MetinAlaniState();
}

class _MetinAlaniState extends State<_MetinAlani> {
  late final TextEditingController _denetleyici =
      TextEditingController(text: widget.ilk ?? '');

  @override
  void dispose() {
    _denetleyici.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _denetleyici,
      maxLength: kAnketMetinUstSiniri,
      minLines: widget.uzun ? 3 : 1,
      maxLines: widget.uzun ? 6 : 1,
      onChanged: widget.onDegisti,
      decoration: const InputDecoration(hintText: _metinIpucu),
    );
  }
}

class _TesekkurGorunumu extends StatelessWidget {
  const _TesekkurGorunumu({required this.onKapat});

  final VoidCallback onKapat;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            _tesekkur,
            textAlign: TextAlign.center,
            style: appText(size: 18, weight: FontWeight.w900, color: AppColors.mintDark),
          ),
        ),
        const SizedBox(height: 18),
        ChunkyButton(label: _kapatEtiketi, onPressed: onKapat),
      ],
    );
  }
}

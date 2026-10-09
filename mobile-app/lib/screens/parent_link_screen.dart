// Veline bağlan: çocuk, velinin veli panelinde ürettiği 6 karakterlik kodu girerek bağlanır.
//
// Geri davranışı: normalde geri tuşu ekrandan çıkar. Bağlanma isteği sürerken
// geri tuşu bekletilir; böylece sonuç kullanıcıya gösterilmeden kaybolmaz.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/parent_link_models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import '../widgets/ui/chunky_button.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/responsive_page.dart';

const _kBaslik = 'Veline bağlan';
const _kAciklama =
    'Velin, veli panelinde "Çocuğunu ekle" bölümünden bir kod oluşturur. O kodu buraya yaz.';
const _kKodEtiketi = 'Eşleştirme kodu';
const _kKodIpucu = 'ABC123';
const _kBaglanButonu = 'Bağlan';
const _kTamam = 'Tamam';
const _kGecersiz =
    'Bu kod geçersiz ya da süresi dolmuş. Velinden yeni bir kod isteyebilirsin.';
const _kCokDeneme = 'Çok fazla deneme yaptın. Biraz sonra tekrar dene.';
const _kBaglanamadi = 'Bağlanamadı, biraz sonra tekrar deneyelim.';
const _kZatenBagli = 'Bir veliye bağlısın 🎉';
const _kZatenBagliMesaji = 'İlerlemen velinle paylaşılıyor. Velin de ilerlemeni görebilecek.';
const _kGeri = 'Geri';

const _kodUzunlugu = 6;

String _baglandiMesaji(String? veliAd) => veliAd == null
    ? 'Harika! Artık velinle bağlısın. İlerlemeni velin de görebilecek.'
    : 'Harika! Artık $veliAd ile bağlısın. İlerlemeni velin de görebilecek.';

/// Kod alanı: büyük harfe çevirir, harf/rakam dışını (boşluk, tire) atar.
class _KodFormatter extends TextInputFormatter {
  const _KodFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final temiz =
        newValue.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    return TextEditingValue(
      text: temiz,
      selection: TextSelection.collapsed(offset: temiz.length),
    );
  }
}

class ParentLinkScreen extends ConsumerStatefulWidget {
  const ParentLinkScreen({super.key});

  @override
  ConsumerState<ParentLinkScreen> createState() => _ParentLinkScreenState();
}

class _ParentLinkScreenState extends ConsumerState<ParentLinkScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  /// Başarılı bağlanma sonucu; doluysa başarı görünümü gösterilir.
  ParentLinkResult? _sonuc;

  /// Form altındaki hata metni (geçersiz kod, deneme sınırı, sunucu hatası).
  String? _hata;

  bool get _kodHazir => _controller.text.trim().length == _kodUzunlugu;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _baglan() async {
    final kod = _controller.text.trim().toUpperCase();
    if (_loading || kod.length != _kodUzunlugu) return;

    AppHaptics.light();
    setState(() {
      _loading = true;
      _hata = null;
    });

    ParentLinkResult? sonuc;
    String? hata;
    try {
      sonuc = await ref.read(quizRepositoryProvider).redeemParentLinkCode(kod);
    } on PostgrestException catch (e) {
      // Sunucu kuralı mesajları (ör. "Hesabın zaten bir veliye bağlı") Türkçedir.
      hata = e.message.isNotEmpty ? e.message : _kBaglanamadi;
    } catch (_) {
      hata = _kBaglanamadi;
    }
    if (!mounted) return;

    setState(() {
      _loading = false;
      switch (sonuc?.durum) {
        case ParentLinkStatus.baglandi:
          _sonuc = sonuc;
          _hata = null;
        case ParentLinkStatus.gecersiz:
          _hata = _kGecersiz;
        case ParentLinkStatus.cokDeneme:
          _hata = _kCokDeneme;
        case null:
          _hata = hata ?? _kBaglanamadi;
      }
    });

    if (sonuc?.durum == ParentLinkStatus.baglandi) {
      // Profil (parent_id) ve üyelik (kaynak: veli) artık değişti.
      ref.invalidate(profileProvider);
      ref.invalidate(membershipProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final zatenBagli =
        ref.watch(profileProvider).valueOrNull?.hasParent ?? false;

    return PopScope(
      canPop: !_loading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            tooltip: _kGeri,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _loading ? null : () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            _kBaslik,
            style: appText(size: 18, weight: FontWeight.w800),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: ResponsivePage(
            child: SingleChildScrollView(
              child: _sonuc != null
                  ? _BaglandiGorunumu(
                      mesaj: _baglandiMesaji(_sonuc!.veliAd),
                    )
                  : zatenBagli
                      ? const _ZatenBagliGorunumu()
                      : _formGorunumu(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formGorunumu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _kAciklama,
          textAlign: TextAlign.center,
          style: appText(size: 15, weight: FontWeight.w500, color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        GameCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                textField: true,
                label: _kKodEtiketi,
                child: TextField(
                  controller: _controller,
                  enabled: !_loading,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  enableSuggestions: false,
                  maxLength: _kodUzunlugu,
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: const [_KodFormatter()],
                  style: appText(size: 28, weight: FontWeight.w900)
                      .copyWith(fontFamily: 'monospace', letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: _kKodIpucu,
                    hintStyle: appText(size: 28, weight: FontWeight.w900, color: AppColors.lineDark)
                        .copyWith(fontFamily: 'monospace', letterSpacing: 8),
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.lineDark, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2.5),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.line, width: 2),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) {
                    if (_kodHazir) _baglan();
                  },
                ),
              ),
              if (_hata != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _hata!,
                    textAlign: TextAlign.center,
                    style: appText(
                        size: 14, weight: FontWeight.w700, color: AppColors.coralDark),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ChunkyButton(
                label: _kBaglanButonu,
                icon: Icons.link_rounded,
                loading: _loading,
                onPressed: _kodHazir && !_loading ? _baglan : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BaglandiGorunumu extends StatelessWidget {
  const _BaglandiGorunumu({required this.mesaj});

  final String mesaj;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        GameCard(
          color: AppColors.mintSoft,
          borderColor: AppColors.mint,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.mint, size: 64),
              const SizedBox(height: 16),
              Text(
                mesaj,
                textAlign: TextAlign.center,
                style: appText(weight: FontWeight.w700, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ChunkyButton.success(
          label: _kTamam,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _ZatenBagliGorunumu extends StatelessWidget {
  const _ZatenBagliGorunumu();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        GameCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.family_restroom_rounded,
                  color: AppColors.primary, size: 64),
              const SizedBox(height: 16),
              Text(
                _kZatenBagli,
                textAlign: TextAlign.center,
                style: appText(size: 20, weight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                _kZatenBagliMesaji,
                textAlign: TextAlign.center,
                style: appText(size: 15, color: AppColors.muted, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ChunkyButton(
          label: _kTamam,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

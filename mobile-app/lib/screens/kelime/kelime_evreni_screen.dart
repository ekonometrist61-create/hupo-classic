// Kelime Evreni ana ekranı (Öğren sekmesinden açılır).
// Öğrenci: üç oyun türünden birini seçer, tekrar bekleyen kelimelerini ve kaydettiklerini görür.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/kelime_models.dart';
import '../../providers/kelime_providers.dart';
import '../../services/kelime_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/hupo/hupo.dart';
import '../../widgets/ui/game_card.dart';
import '../../widgets/ui/responsive_page.dart';
import 'kelime_oyun_screen.dart';
import 'kelime_tema.dart';

const String _mesajGenelHata = 'Bilgiler yüklenemedi. Birazdan tekrar deneyelim.';
const String _mesajKayitBos = "Oyunda yanlış cevapladığın kelimeyi 'Bu kelimeyi kaydet' ile buraya ekleyebilirsin.";
const String _mesajKayitSilindi = 'Kayıt kaldırıldı.';

String _hataMetni(Object e) => e is KelimeException ? e.mesaj : _mesajGenelHata;

class KelimeEvreniScreen extends ConsumerWidget {
  const KelimeEvreniScreen({super.key});

  void _yenile(WidgetRef ref) {
    ref.invalidate(kelimeOzetProvider);
    ref.invalidate(kelimeKaydedilenlerProvider);
  }

  Future<void> _oyunAc(BuildContext context, WidgetRef ref, KelimeIliskiTuru tur) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => KelimeOyunScreen(iliski: tur)),
    );
    _yenile(ref);
  }

  Future<void> _kaydiKaldir(BuildContext context, WidgetRef ref, String anlamId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(kelimeRepositoryProvider).kaydet(anlamId: anlamId, kaydet: false);
      _yenile(ref);
      messenger.showSnackBar(const SnackBar(content: Text(_mesajKayitSilindi)));
    } on KelimeException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.mesaj)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ozet = ref.watch(kelimeOzetProvider);
    final kayitlar = ref.watch(kelimeKaydedilenlerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Kelime Evreni', style: appText(size: 18, weight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsivePage(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Giris(),
                const SizedBox(height: 16),
                ozet.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => _HataKutusu(
                    mesaj: _hataMetni(e),
                    onTekrar: () => ref.invalidate(kelimeOzetProvider),
                  ),
                  data: (o) => _OzetSatiri(ozet: o),
                ),
                const SizedBox(height: 24),
                Text('Oyunlar', style: appText(size: 19, weight: FontWeight.w900)),
                const SizedBox(height: 12),
                for (final tur in KelimeIliskiTuru.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OyunKarti(tur: tur, onTap: () => _oyunAc(context, ref, tur)),
                  ),
                const SizedBox(height: 24),
                Text('Kaydettiğim kelimeler', style: appText(size: 19, weight: FontWeight.w900)),
                const SizedBox(height: 12),
                kayitlar.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _HataKutusu(
                    mesaj: _hataMetni(e),
                    onTekrar: () => ref.invalidate(kelimeKaydedilenlerProvider),
                  ),
                  data: (liste) => liste.isEmpty
                      ? Text(_mesajKayitBos, style: appText(color: AppColors.muted))
                      : Column(
                          children: [
                            for (final kayit in liste)
                              _KayitSatiri(
                                kayit: kayit,
                                onKaldir: () => _kaydiKaldir(context, ref, kayit.anlamId),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Giris extends StatelessWidget {
  const _Giris();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Hupo(pose: HupoPose.hosgeldin, size: 92),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelimelerin dostlarını ve karşıtlarını keşfet.',
                style: appText(size: 18, weight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                'Her doğru cevap bir adım. Yanlışlar da öğretir.',
                style: appText(size: 14, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OzetSatiri extends StatelessWidget {
  const _OzetSatiri({required this.ozet});

  final KelimeOzet ozet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Sayac(baslik: 'Tekrar bekleyen', deger: ozet.tekrarBekleyen, renk: AppColors.coral)),
        const SizedBox(width: 10),
        Expanded(child: _Sayac(baslik: 'Tanıdığın', deger: ozet.tanimaTamam, renk: AppColors.mint)),
        const SizedBox(width: 10),
        Expanded(child: _Sayac(baslik: 'Kaydettiğin', deger: ozet.kaydedilen, renk: AppColors.skyDark)),
      ],
    );
  }
}

class _Sayac extends StatelessWidget {
  const _Sayac({required this.baslik, required this.deger, required this.renk});

  final String baslik;
  final int deger;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$baslik: $deger',
      child: GameCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Text('$deger', style: appText(size: 24, weight: FontWeight.w900, color: renk)),
            const SizedBox(height: 2),
            Text(baslik, textAlign: TextAlign.center, style: appText(size: 12, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _OyunKarti extends StatelessWidget {
  const _OyunKarti({required this.tur, required this.onTap});

  final KelimeIliskiTuru tur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${tur.baslik}: ${tur.hedef}',
      excludeSemantics: true,
      child: GameCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: tur.renk, shape: BoxShape.circle),
              child: Icon(tur.simge, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tur.baslik, style: appText(weight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(tur.hedef, style: appText(size: 13, color: AppColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _KayitSatiri extends StatelessWidget {
  const _KayitSatiri({required this.kayit, required this.onKaldir});

  final KelimeKaydi kayit;
  final VoidCallback onKaldir;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GameCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kayit.kelime, style: appText(weight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(kayit.anlam, style: appText(size: 13, color: AppColors.muted)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Kaydı kaldır',
              onPressed: onKaldir,
              icon: const Icon(Icons.bookmark_remove_rounded, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _HataKutusu extends StatelessWidget {
  const _HataKutusu({required this.mesaj, required this.onTekrar});

  final String mesaj;
  final VoidCallback onTekrar;

  @override
  Widget build(BuildContext context) {
    return GameCard(
      color: AppColors.coralSoft,
      borderColor: AppColors.coral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mesaj, style: appText(weight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onTekrar,
            child: Text('Tekrar dene', style: appText(weight: FontWeight.w800, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

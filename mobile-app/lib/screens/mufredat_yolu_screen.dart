// Müfredat yolu: öğrencinin dersindeki okul haftalarını ve kazanımlarını gösterir.
// Yalnız işlenmiş haftaların/kazanımların soruları çözülür; gelecek haftalar bilgi amaçlıdır.
// Kaynak: get_mufredat_haritasi / get_mufredat_sorulari (docs/mufredat/PLAN_HAFTA_ETIKETLEME.md).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mufredat_models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/hupo/hupo.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/responsive_page.dart';
import 'home_screen.dart';

const String _baslik = 'Müfredat yolu';
const String _girisMetni =
    'Hangi haftada neler işlendiğini gör, o konuların sorularını çöz.';
const String _butonBuHafta = 'Bu haftanın konuları';
const String _butonBugunEkadar = 'Bugüne kadar karışık';
const String _butonKonuSec = 'Konu seç';
const String _haftalarBasligi = 'Haftalar';
const String _yukleniyor = 'Müfredat yolun hazırlanıyor...';
const String _hataMetni = 'Müfredat yolu yüklenemedi, tekrar deneyelim.';
const String _yenidenDene = 'Yeniden dene';
const String _bosDers = 'Bu derste henüz müfredata bağlı soru yok. Yakında!';
const String _planYok = 'Bu ders için müfredat planı yakında yayımlanacak.';
const String _bosKisim = 'Bu kısımda henüz soru yok. Yakında!';
const String _henuzSoruYok = 'henüz soru yok';
const String _henuzIslenmedi = 'Henüz işlenmedi';
const String _buHafta = 'Bu hafta';
const String _islendi = 'İşlendi';
const String _tatilBasligi = 'Tatil';
const String _tatilMetni = 'Okul tatilde. Dinlen, sonra devam edelim!';
const String _konuSecBaslik = 'Hangi konuyu çözmek istersin?';
const String _konuSecBos =
    'Henüz çözebileceğin bir konu yok. İşlendikçe burada görünecek.';
const String _soruYokBilgi = 'Bu kazanım için henüz soru yok.';
const String _kapat = 'Kapat';

/// Quiz başlatıcı: başlık, müfredat modu ve (varsa) hafta/kazanım kodları.
typedef _CozCagrisi = Future<void> Function({
  required String baslik,
  required String mod,
  int? hafta,
  List<String>? kodlar,
});

class MufredatYoluScreen extends ConsumerWidget {
  const MufredatYoluScreen({super.key, required this.ders});

  final String ders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final harita = ref.watch(mufredatHaritasiProvider(ders));

    Future<void> coz({
      required String baslik,
      required String mod,
      int? hafta,
      List<String>? kodlar,
    }) async {
      final repo = ref.read(quizRepositoryProvider);
      await HomeScreen.openQuiz(
        context,
        ref,
        title: baslik,
        load: () => repo.fetchMufredatSorulari(
          ders: ders,
          mod: mod,
          hafta: hafta,
          kazanimKodlari: kodlar,
        ),
        emptyMessage: _bosKisim,
      );
      // Çözülen sorularla sayılar değişti; haritayı yeniden al.
      ref.invalidate(mufredatHaritasiProvider(ders));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(_baslik, style: appText(size: 20, weight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: harita.when(
          loading: () => const _Yukleniyor(),
          error: (_, __) => _Hata(
            onRetry: () => ref.invalidate(mufredatHaritasiProvider(ders)),
          ),
          data: (h) {
            if (h.haftalar.isEmpty) return const _BosDurum(mesaj: _planYok);
            if (h.hicSoruYok) return const _BosDurum(mesaj: _bosDers);
            return _Icerik(harita: h, coz: coz);
          },
        ),
      ),
    );
  }
}

class _Icerik extends StatelessWidget {
  const _Icerik({required this.harita, required this.coz});

  final MufredatHaritasi harita;
  final _CozCagrisi coz;

  @override
  Widget build(BuildContext context) {
    final bugunHafta = harita.bugunHafta;
    return ResponsivePage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_girisMetni,
                style:
                    appText(color: AppColors.muted, weight: FontWeight.w700)),
            const SizedBox(height: 14),
            if (bugunHafta != null) ...[
              _Rozet(
                  text: 'Bugün $bugunHafta. hafta', color: AppColors.primary),
              const SizedBox(height: 14),
            ],
            _EylemDugmesi(
              label: _butonBuHafta,
              primary: true,
              onTap: () => coz(baslik: _butonBuHafta, mod: 'bu_hafta'),
            ),
            const SizedBox(height: 10),
            _EylemDugmesi(
              label: _butonBugunEkadar,
              onTap: () => coz(baslik: _butonBugunEkadar, mod: 'bugune_kadar'),
            ),
            const SizedBox(height: 10),
            _EylemDugmesi(
              label: _butonKonuSec,
              onTap: () => _konuSec(context, harita, coz),
            ),
            const SizedBox(height: 24),
            Text(_haftalarBasligi,
                style: appText(size: 19, weight: FontWeight.w900)),
            const SizedBox(height: 12),
            for (final hafta in harita.haftalar)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: hafta.tatil
                    ? _TatilKarti(hafta: hafta)
                    : _HaftaKarti(
                        hafta: hafta,
                        bugun: harita.bugun,
                        oranGoster: harita.oranGosterilir,
                        coz: coz,
                      ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// "Konu seç": işlenmiş ve soruları olan kazanımlardan birini seçtirir.
Future<void> _konuSec(
    BuildContext context, MufredatHaritasi harita, _CozCagrisi coz) {
  final secilebilir = [
    for (final h in harita.haftalar)
      for (final k in h.kazanimlar)
        if (k.islendi(harita.bugun) && k.sorusuVar) k,
  ];
  return showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_konuSecBaslik,
                style: appText(size: 18, weight: FontWeight.w900)),
            const SizedBox(height: 12),
            if (secilebilir.isEmpty)
              Text(_konuSecBos, style: appText(color: AppColors.muted))
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final k in secilebilir)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        minVerticalPadding: 8,
                        title: Text(k.metin,
                            style: appText(weight: FontWeight.w800)),
                        subtitle: Text(k.kod,
                            style: appText(size: 12, color: AppColors.muted)),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          coz(baslik: k.kod, mod: 'kazanim', kodlar: [k.kod]);
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _HaftaKarti extends StatelessWidget {
  const _HaftaKarti({
    required this.hafta,
    required this.bugun,
    required this.oranGoster,
    required this.coz,
  });

  final MufredatHafta hafta;
  final int bugun;
  final bool oranGoster;
  final _CozCagrisi coz;

  @override
  Widget build(BuildContext context) {
    final buHafta = bugun > 0 && hafta.hafta == bugun;
    final gelecek = bugun == 0 || hafta.hafta > bugun;
    final tarih = _tarihAraligi(hafta.baslangic, hafta.bitis);
    final cozulebilir = !gelecek && hafta.kazanimlar.any((k) => k.sorusuVar);

    return GameCard(
      color: buHafta ? AppColors.primarySoft : AppColors.surface,
      borderColor: buHafta ? AppColors.primary : AppColors.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${hafta.hafta}. hafta',
                    style: appText(size: 17, weight: FontWeight.w900)),
              ),
              // Flexible: büyük yazıda rozet metni sarılır, satır taşmaz.
              Flexible(
                child: buHafta
                    ? const _Rozet(text: _buHafta, color: AppColors.primary)
                    : gelecek
                        ? const _Rozet(
                            text: _henuzIslenmedi, color: AppColors.muted)
                        : const _Rozet(text: _islendi, color: AppColors.mint),
              ),
            ],
          ),
          if (tarih != null)
            Text(tarih, style: appText(size: 12, color: AppColors.muted)),
          if (hafta.uniteTema != null && hafta.uniteTema!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(hafta.uniteTema!,
                style: appText(
                    size: 13,
                    weight: FontWeight.w800,
                    color: AppColors.primaryDark)),
          ],
          for (final konu in hafta.konular)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('• $konu', style: appText(size: 14, height: 1.3)),
            ),
          if (hafta.kazanimlar.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final k in hafta.kazanimlar)
              _KazanimSatiri(
                kazanim: k,
                bugun: bugun,
                oranGoster: oranGoster,
                onTap: () {
                  if (k.islendi(bugun) && k.sorusuVar) {
                    coz(baslik: k.kod, mod: 'kazanim', kodlar: [k.kod]);
                  } else {
                    _kazanimBilgi(context, k, bugun);
                  }
                },
              ),
          ],
          if (cozulebilir)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => coz(
                  baslik: '${hafta.hafta}. haftaya kadar',
                  mod: 'hafta',
                  hafta: hafta.hafta,
                ),
                child: Text('${hafta.hafta}. haftaya kadar çöz'),
              ),
            ),
        ],
      ),
    );
  }
}

class _KazanimSatiri extends StatelessWidget {
  const _KazanimSatiri({
    required this.kazanim,
    required this.bugun,
    required this.oranGoster,
    required this.onTap,
  });

  final MufredatKazanim kazanim;
  final int bugun;
  final bool oranGoster;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final islendi = kazanim.islendi(bugun);
    // Soluk: işlenmemiş ya da soru sayısı 0 olan kazanım.
    final soluk = !islendi || !kazanim.sorusuVar;
    final oran = kazanim.oranYuzde(oranGoster);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: soluk ? AppColors.line : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      kazanim.kod,
                      style: appText(
                        size: 12,
                        weight: FontWeight.w900,
                        color: soluk ? AppColors.muted : AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kazanim.metin,
                          style: appText(
                            size: 14,
                            weight: FontWeight.w700,
                            color: soluk ? AppColors.muted : AppColors.ink,
                          ),
                        ),
                        if (!islendi)
                          Text(_henuzIslenmedi,
                              style: appText(size: 12, color: AppColors.muted))
                        else if (!kazanim.sorusuVar)
                          Text(_henuzSoruYok,
                              style: appText(size: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  if (oran != null) ...[
                    const SizedBox(width: 8),
                    Text('%$oran',
                        style: appText(
                            weight: FontWeight.w900, color: AppColors.primary)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TatilKarti extends StatelessWidget {
  const _TatilKarti({required this.hafta});

  final MufredatHafta hafta;

  @override
  Widget build(BuildContext context) {
    final tarih = _tarihAraligi(hafta.baslangic, hafta.bitis);
    return GameCard(
      color: AppColors.sunSoft,
      borderColor: AppColors.sun,
      child: Row(
        children: [
          const Icon(Icons.beach_access_rounded,
              color: AppColors.sunDark, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_tatilBasligi · ${hafta.hafta}. hafta',
                    style: appText(weight: FontWeight.w900)),
                if (tarih != null)
                  Text(tarih, style: appText(size: 12, color: AppColors.muted)),
                const SizedBox(height: 4),
                Text(_tatilMetni,
                    style: appText(size: 14, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EylemDugmesi extends StatelessWidget {
  const _EylemDugmesi(
      {required this.label, required this.onTap, this.primary = false});

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: primary
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(0, 52),
                side: const BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                textStyle:
                    appText(weight: FontWeight.w800, color: AppColors.primary),
              ),
              child: Text(label),
            ),
    );
  }
}

class _Rozet extends StatelessWidget {
  const _Rozet({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: appText(size: 12, weight: FontWeight.w800, color: color)),
    );
  }
}

class _Yukleniyor extends StatelessWidget {
  const _Yukleniyor();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(_yukleniyor, style: appText(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _Hata extends StatelessWidget {
  const _Hata({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Hupo(mood: HupoMood.retry, size: 72),
            const SizedBox(height: 8),
            Text(_hataMetni,
                textAlign: TextAlign.center,
                style: appText(color: AppColors.muted)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48)),
              child: const Text(_yenidenDene),
            ),
          ],
        ),
      ),
    );
  }
}

class _BosDurum extends StatelessWidget {
  const _BosDurum({required this.mesaj});

  final String mesaj;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Hupo(mood: HupoMood.empty, size: 90),
            const SizedBox(height: 8),
            Text(mesaj,
                textAlign: TextAlign.center,
                style: appText(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

void _kazanimBilgi(BuildContext context, MufredatKazanim k, int bugun) {
  final ilk = k.ilkHafta;
  final String mesaj;
  if (!k.islendi(bugun)) {
    mesaj = ilk != null
        ? 'Bu kazanım $ilk. haftada işlenecek. O hafta gelince sorular açılır.'
        : 'Bu kazanım henüz işlenmedi.';
  } else {
    mesaj = _soruYokBilgi;
  }
  showModalBottomSheet<void>(
    context: context,
    // Varsayılan yükseklik sınırı (9/16) büyük yazıda içeriği kesiyordu.
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(k.kod,
                  style: appText(
                      size: 12,
                      weight: FontWeight.w900,
                      color: AppColors.muted)),
              const SizedBox(height: 6),
              Text(k.metin, style: appText(size: 17, weight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(mesaj, style: appText(color: AppColors.muted)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(0, 52),
                    side: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  child: const Text(_kapat),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// "14.09 – 18.09" biçiminde hafta aralığı; tarih yoksa null.
String? _tarihAraligi(DateTime? bas, DateTime? bit) {
  if (bas == null || bit == null) return null;
  String g(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
  return '${g(bas)} – ${g(bit)}';
}

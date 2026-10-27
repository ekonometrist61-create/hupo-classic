// HupoRead vitrini (Öğren sekmesi): başlık ve seri, duruma göre ana hikâye kartı, kitap kapağı
// şeridi. Veri: seri/öneri (okumaSeriOneriProvider), cihazdaki devam kaydı (okumaDevamProvider),
// katalog sayıları (okumaVitrinKatalogProvider), sınıf (okumaSinifProvider). Bayrak kapalıysa
// hiçbir şey çizilmez. Görseller: assets/okuma/vitrin (2–4. sınıf canlı, 5–8. sınıf olgun).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/okuma_models.dart';
import '../../providers/okuma_providers.dart';
import '../../screens/okuma/hikaye_kesif_ekrani.dart';
import '../../screens/okuma/okuduklarim_ekrani.dart';
import '../../screens/okuma/okuma_tema.dart';
import '../../services/okuma_cihaz_deposu.dart';
import '../../services/okuma_geri_donus.dart';
import '../../theme/app_theme.dart';
import '../hupo/hupo.dart';
import '../ui/chunky_button.dart';
import 'okuma_v3.dart';

/// Büyük yazı ölçeğinde (>= 1.3) kart görseli metnin üstüne geçer.
const _buyukYaziEsigi = 1.3;

class OkumaVitrin extends ConsumerWidget {
  const OkumaVitrin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Çıkışta kişisel okuma verilerini silen bekçi; vitrin görünmese de çalışır.
    ref.watch(okumaOturumBekciProvider);
    final ozellik = ref.watch(okumaOzellikProvider).valueOrNull;
    if (ozellik == null || !ozellik.erisim) return const SizedBox.shrink();

    final seriAsync = ref.watch(okumaSeriOneriProvider);
    final durum = seriAsync.valueOrNull;
    final depo = ref.watch(okumaCihazDeposuProvider);
    final simdi = ref.watch(okumaSimdiProvider)();
    final son = depo.sonOkuma;
    final geriDonus = geriDonusGerekli(sonOkuma: son, simdi: simdi) ? geriDonusMetni(simdi.difference(son!).inDays) : null;
    final kotaDolu = durum?.kotaDolu ?? false;
    final ilk = okumaIlkGrup(ref.watch(okumaSinifProvider).valueOrNull);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Ust(seri: durum?.seri),
        const SizedBox(height: OkumaTema.bosluk12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk8),
          child: _AnaKart(
          ilk: ilk,
          yukleniyor: seriAsync.isLoading && durum == null,
          kotaDolu: kotaDolu,
          // Yarım kalan hikâye yalnız günlük hak kullanılmadıysa öne çıkar.
          devam: kotaDolu ? null : ref.watch(okumaDevamProvider),
          oneri: kotaDolu ? null : durum?.oneri,
          geriDonus: geriDonus,
        ),
        ),
        const SizedBox(height: OkumaTema.bosluk16),
        _KesifSeridi(ilk: ilk),
        const SizedBox(height: OkumaTema.bosluk8),
      ],
    );
  }
}

/// HupoRead başlığı ve alt açıklama; seri varsa sağda küçük bir rozet (tek satır, sade).
class _Ust extends StatelessWidget {
  const _Ust({required this.seri});

  final OkumaSeri? seri;

  @override
  Widget build(BuildContext context) {
    final serili = seri != null && seri!.seriDevam && seri!.seriSayisi > 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
          child: const Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 26),
        ),
        const SizedBox(width: OkumaTema.bosluk12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(OkumaMetin.vitrinBaslik, style: appText(size: 28, weight: FontWeight.w900, height: 1.1)),
              ),
              Text(OkumaMetin.vitrinAlt, style: appText(size: 15, color: AppColors.muted)),
            ],
          ),
        ),
        if (serili) ...[
          const SizedBox(width: OkumaTema.bosluk8),
          _SeriRozeti(gun: seri!.seriSayisi),
        ],
      ],
    );
  }
}

/// Seri rozeti: alev ve gün sayısı. Ekran okuyucu "N günlük okuma serisi" der.
class _SeriRozeti extends StatelessWidget {
  const _SeriRozeti({required this.gun});

  final int gun;

  @override
  Widget build(BuildContext context) => Semantics(
        label: OkumaMetin.kartSeri(gun),
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
            padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk8, vertical: OkumaTema.bosluk4),
            decoration: BoxDecoration(color: AppColors.coralSoft, borderRadius: BorderRadius.circular(18)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 20, color: AppColors.coralDark),
                const SizedBox(width: 2),
                Text('$gun', style: appText(size: 16, weight: FontWeight.w900, color: AppColors.coralDark)),
              ],
            ),
          ),
        ),
      );
}
/// Ana hikâye kartı. Öncelik: kota dolu → devam → öneri → yeni kullanıcı (kahraman daveti).
class _AnaKart extends ConsumerWidget {
  const _AnaKart({
    required this.ilk,
    required this.yukleniyor,
    required this.kotaDolu,
    required this.devam,
    required this.oneri,
    required this.geriDonus,
  });

  final bool ilk;
  final bool yukleniyor;
  final bool kotaDolu;
  final OkumaDevam? devam;
  final OkumaKatalogSatiri? oneri;
  final String? geriDonus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (yukleniyor) {
      return _Kabuk(
        child: Row(
          children: [
            const Hupo(pose: HupoPose.dusunuyor, size: OkumaTema.hupoKart, semanticLabel: ''),
            const SizedBox(width: OkumaTema.bosluk12),
            Expanded(child: Text(OkumaMetin.hikayeYukleniyor, style: appText(size: 16, color: AppColors.muted))),
          ],
        ),
      );
    }

    final Widget sanat;
    final Widget? etiket;
    final String baslik;
    final double baslikBoyutu;
    final String govde;
    final Widget? alt;
    final Widget cta;

    if (kotaDolu) {
      etiket = null;
      baslik = OkumaMetin.kotaBaslik;
      baslikBoyutu = 24;
      govde = OkumaMetin.vitrinKotaGovde;
      alt = null;
      sanat = const _Sanat(
        child: ColoredBox(
          color: AppColors.surface,
          child: Center(child: Hupo(pose: HupoPose.konuTamamlandi, size: 110, semanticLabel: '')),
        ),
      );
      cta = ChunkyButton.light(label: OkumaMetin.kartOkuduklarim, onPressed: () => _okuduklarim(context, ref));
    } else if (devam != null) {
      final d = devam!;
      etiket = null;
      baslik = OkumaMetin.vitrinDevamBaslik;
      baslikBoyutu = 26;
      govde = d.satir.baslik;
      alt = d.toplam > 0
          ? OkumaIlerlemeCubugu(oran: d.oran, etiket: OkumaMetin.vitrinSayfa(d.sayfa + 1, d.toplam))
          : null;
      sanat = _Sanat(child: _SahneGorseli(satir: d.satir));
      cta = ChunkyButton(label: OkumaMetin.vitrinDevam, onPressed: () => okumaAc(context, ref, satir: d.satir));
    } else if (oneri != null) {
      final o = oneri!;
      etiket = const _Etiket(OkumaMetin.kartBaslik, renk: AppColors.surface, yazi: AppColors.primaryDark);
      baslik = o.baslik;
      baslikBoyutu = 24;
      govde = geriDonus ?? _ozetSatiri(o);
      alt = null;
      sanat = _Sanat(child: _SahneGorseli(satir: o));
      cta = ChunkyButton(label: OkumaMetin.kartBasla, onPressed: () => okumaAc(context, ref, satir: o));
    } else {
      etiket = null;
      baslik = OkumaMetin.vitrinYeniBaslik;
      baslikBoyutu = 24;
      govde = OkumaMetin.vitrinYeniAlt;
      alt = null;
      sanat = _Sanat(
        child: Image.asset(
          okumaVitrinGorseli('hero', ilk: ilk),
          fit: BoxFit.cover,
          cacheWidth: 500,
          errorBuilder: (_, __, ___) => const ColoredBox(
            color: AppColors.surface,
            child: Center(child: Hupo(pose: HupoPose.merakEdiyor, size: 96, semanticLabel: '')),
          ),
        ),
      );
      cta = ChunkyButton(
        label: OkumaMetin.vitrinOlustur,
        icon: Icons.auto_awesome_rounded,
        onPressed: () => okumaAc(context, ref),
      );
    }

    final metin = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (etiket != null) ...[etiket, const SizedBox(height: OkumaTema.bosluk12)],
        Semantics(
          header: true,
          child: Text(baslik, style: appText(size: baslikBoyutu, weight: FontWeight.w900, height: 1.15)),
        ),
        const SizedBox(height: OkumaTema.bosluk8),
        Text(
          govde,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: appText(size: 16, color: AppColors.ink, height: 1.35),
        ),
        if (alt != null) ...[const SizedBox(height: OkumaTema.bosluk12), alt],
      ],
    );
    final buyuk = MediaQuery.textScalerOf(context).scale(1) >= _buyukYaziEsigi;

    return _Kabuk(
      key: const ValueKey('okuma-vitrin-kart'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (buyuk) ...[
            Center(child: sanat),
            const SizedBox(height: OkumaTema.bosluk16),
            metin,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: metin),
                const SizedBox(width: OkumaTema.bosluk16),
                sanat,
              ],
            ),
          const SizedBox(height: OkumaTema.bosluk20),
          cta,
        ],
      ),
    );
  }

  void _okuduklarim(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (ctx) => OkuduklarimEkrani(
          onAc: (satir) {
            Navigator.of(ctx).pop();
            okumaAc(context, ref, satir: satir);
          },
        ),
      ),
    );
  }

  /// "Gizem · 4. sınıf · 8 dk": tür, sınıf ve süre; bilinmeyen parçalar atlanır.
  String _ozetSatiri(OkumaKatalogSatiri o) => [
        okumaTurAdi(o.tur),
        '${o.anaSinif}. sınıf',
        if (o.tahminiSureDk != null) OkumaMetin.hikayeSure(o.tahminiSureDk!),
      ].join(' · ');
}

/// Hikâyenin sahne görseli (yoksa tür yedeği), kart görsel kutusunu doldurur.
class _SahneGorseli extends StatelessWidget {
  const _SahneGorseli({required this.satir});

  final OkumaKatalogSatiri satir;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, kutu) => OkumaSahne(tur: satir.tur, slug: satir.slug, yukseklik: kutu.maxHeight),
      );
}

class _Kabuk extends StatelessWidget {
  const _Kabuk({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(OkumaTema.bosluk20),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(28),
        ),
        child: child,
      );
}

class _Etiket extends StatelessWidget {
  const _Etiket(this.metin, {required this.renk, required this.yazi});

  final String metin;
  final Color renk;
  final Color yazi;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk12, vertical: OkumaTema.bosluk8),
        decoration: BoxDecoration(color: renk, borderRadius: BorderRadius.circular(OkumaTema.koseCip)),
        child: Text(metin, style: appText(size: 14, weight: FontWeight.w800, color: yazi)),
      );
}
/// Kart görseli: 3:4 kitap kapağı oranında (132×176), yuvarlak köşeli.
class _Sanat extends StatelessWidget {
  const _Sanat({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 132,
        height: 176,
        child: ClipRRect(borderRadius: BorderRadius.circular(22), child: child),
      );
}

/// "Keşfetmeye hazır mısın?", altında "Tüm hikâyeler" bağlantısı ve tür kapakları. Şerit, katalogdaki
/// BÜTÜN türleri gösterir (öncelikli üç tür başta; hikâyesi olmayan öncelikli tür "Yakında" der).
/// Katalog henüz yüklenmediyse öncelikli üç kapak "Yakında" yazmadan durur.
class _KesifSeridi extends ConsumerWidget {
  const _KesifSeridi({required this.ilk});

  final bool ilk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liste = ref.watch(okumaVitrinKatalogProvider).valueOrNull;
    final ozetler = okumaKategoriOzetleri(liste ?? const [], once: okumaVitrinTurleri);
    // Öncelikli türler her zaman; diğer türler yalnız katalogda hikâyesi varsa.
    final gosterilen = liste == null
        ? [for (final t in okumaVitrinTurleri) (tur: t, sayi: -1, slug: null as String?)]
        : [for (final k in ozetler) if (okumaVitrinTurleri.contains(k.tur) || k.sayi > 0) k];
    final olcek = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    // Kapak 150 genişlik × 200 yükseklik; altına tür adı (en çok 2 satır) ve sayı sığar.
    final yukseklik = 208 + 62 * olcek;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(OkumaMetin.vitrinKesif, style: appText(size: 20, weight: FontWeight.w900)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => const HikayeKesifEkrani()),
          ),
          style: TextButton.styleFrom(
            minimumSize: const Size(OkumaTema.dokunmaMin, OkumaTema.dokunmaMin),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          child: Text(
            '${OkumaMetin.vitrinTumu} →',
            style: appText(size: 14, weight: FontWeight.w800, color: AppColors.primaryDark),
          ),
        ),
        SizedBox(
          height: yukseklik,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: gosterilen.length,
            separatorBuilder: (_, __) => const SizedBox(width: OkumaTema.bosluk12),
            itemBuilder: (_, i) {
              final k = gosterilen[i];
              return SizedBox(
                width: 150,
                child: OkumaKategoriKapagi(
                  tur: k.tur,
                  ilk: ilk,
                  sayi: k.sayi < 0 ? null : k.sayi,
                  slug: k.slug,
                  onTap: () => okumaAc(context, ref, ilkTur: k.tur),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
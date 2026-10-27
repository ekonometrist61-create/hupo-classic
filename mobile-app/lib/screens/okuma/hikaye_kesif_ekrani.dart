// HupoRead keşif ekranı ("Tüm hikâyeler") ve vitrinin paylaşılan parçaları: hikâye açma,
// kategori kapağı, ilerleme çubuğu, bölüm başlığı. Hikâye akışı tek yerden, okumaAc ile açılır.
//
// Kapak görselleri assets/okuma/vitrin/<gizem|uzay|macera>_<ilk|ust>.jpg: "ilk" 2–4. sınıf (canlı),
// "ust" 5–8. sınıf (daha olgun). Kategori sayıları kataloğun gerçek verisinden gelir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/okuma_models.dart';
import '../../providers/okuma_providers.dart';
import '../../services/okuma_cihaz_deposu.dart';
import '../../theme/app_theme.dart';
import '../../widgets/okuma/okuma_v3.dart';
import 'okuduklarim_ekrani.dart';
import 'okuma_akis_ekrani.dart';
import 'okuma_tema.dart';

/// Vitrinde her zaman gösterilen kategoriler (sıra sabit).
const okumaVitrinTurleri = ['gizem', 'bilim_kurgu', 'macera'];

/// Hikâye akışını açar. [satir] verilirse o hikâye (kahraman seçildikten sonra); [ilkTur] verilirse
/// hikâye listesi o türle filtreli açılır. Dönüşte seri, öneri, Okuduklarım ve devam kaydı tazelenir.
void okumaAc(BuildContext context, WidgetRef ref, {OkumaKatalogSatiri? satir, String? ilkTur}) {
  Navigator.of(context)
      .push<void>(MaterialPageRoute(builder: (_) => OkumaAkisEkrani(baslangicSatiri: satir, ilkTur: ilkTur)))
      .then((_) {
    ref.invalidate(okumaSeriOneriProvider);
    ref.invalidate(okumaOkuduklarimProvider);
    ref.invalidate(okumaDevamProvider);
  });
}

/// 2–4. sınıf (ya da sınıf bilinmiyorsa) canlı görseller; 5–8. sınıf olgun görseller.
bool okumaIlkGrup(int? sinif) => sinif == null || sinif <= 4;

/// Vitrin görselinin yolu. [ad]: hero, gizem, uzay, macera.
String okumaVitrinGorseli(String ad, {required bool ilk}) => 'assets/okuma/vitrin/${ad}_${ilk ? 'ilk' : 'ust'}.jpg';

/// Türün vitrin kapak adı; kapağı olmayan tür için null (sahne görseline düşülür).
String? okumaKapakAdi(String tur) => switch (tur) {
      'gizem' => 'gizem',
      'bilim_kurgu' => 'uzay',
      'macera' => 'macera',
      _ => null,
    };

/// Türün Türkçe adı. Bilinmeyen kod "Hikâye" olur.
String okumaTurAdi(String kod) => switch (kod) {
      'gizem' => 'Gizem',
      'macera' => 'Macera',
      'bilim_kurgu' => 'Uzay ve Bilim Kurgu',
      'bilim' => 'Bilim',
      'doga' => 'Doğa',
      'mizah' => 'Mizah',
      'hayvanlar' => 'Hayvanlar',
      'arkadaslik' => 'Arkadaşlık',
      'fantastik' => 'Fantastik',
      'spor' => 'Spor',
      'tarih_kultur' => 'Tarih ve Kültür',
      'gezi_kultur' => 'Gezi ve Kültür',
      _ => 'Hikâye',
    };

/// Bir tür kategorisinin özeti: tür kodu, hikâye sayısı ve kapak yedeği için bir hikâyenin adresi.
typedef OkumaKategoriOzeti = ({String tur, int sayi, String? slug});

/// Kataloğu türe göre özetler. [once] verilen türler başta (hikâyesi olmasa da sayı 0 ile) gelir;
/// ardından katalogdaki diğer türler.
List<OkumaKategoriOzeti> okumaKategoriOzetleri(List<OkumaKatalogSatiri> liste, {List<String> once = const []}) {
  final kodlar = [
    ...once,
    for (final t in {for (final s in liste) s.tur}) if (t.isNotEmpty && !once.contains(t)) t,
  ];
  return [
    for (final kod in kodlar)
      (
        tur: kod,
        sayi: liste.where((s) => s.tur == kod).length,
        slug: liste.where((s) => s.tur == kod && s.slug.isNotEmpty).firstOrNull?.slug,
      ),
  ];
}

/// Bölüm başlığı (başlık anlamlı bir Semantics başlığıdır).
class OkumaBaslik extends StatelessWidget {
  const OkumaBaslik(this.metin, {super.key});

  final String metin;

  @override
  Widget build(BuildContext context) => Semantics(
        header: true,
        child: Text(metin, style: appText(size: 22, weight: FontWeight.w900)),
      );
}

/// Yarım kalan hikâyenin ilerleme çubuğu ve "Sayfa n / t" etiketi. Toplam sayfa yoksa çizilmez.
class OkumaIlerlemeCubugu extends StatelessWidget {
  const OkumaIlerlemeCubugu({super.key, required this.oran, required this.etiket});

  final double oran;
  final String etiket;

  @override
  Widget build(BuildContext context) => Semantics(
        label: etiket,
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(OkumaTema.bosluk4),
                child: LinearProgressIndicator(
                  value: oran,
                  minHeight: OkumaTema.ilerlemeYuksekligi,
                  backgroundColor: OkumaTema.lineDark,
                  color: OkumaTema.primary,
                ),
              ),
              const SizedBox(height: OkumaTema.bosluk4),
              Text(etiket, style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted)),
            ],
          ),
        ),
      );
}

/// Kategori kapağı: 3:4 kitap kapağı görseli, altında tür adı ve hikâye sayısı. [sayi] null ise
/// (katalog yüklenmedi) sayı yazılmaz; 0 ise "Yakında" yazılır. Genişliği çağıran belirler.
class OkumaKategoriKapagi extends StatelessWidget {
  const OkumaKategoriKapagi({
    super.key,
    required this.tur,
    required this.ilk,
    required this.onTap,
    this.sayi,
    this.slug,
  });

  final String tur;
  final bool ilk;
  final int? sayi;
  final String? slug;
  final VoidCallback onTap;

  Widget _gorsel() => LayoutBuilder(
        builder: (context, kutu) {
          final yedek = OkumaSahne(tur: tur, slug: slug, yukseklik: kutu.maxHeight);
          final ad = okumaKapakAdi(tur);
          if (ad == null) return yedek;
          return ClipRRect(
            borderRadius: BorderRadius.circular(OkumaTema.koseKart),
            child: Image.asset(
              okumaVitrinGorseli(ad, ilk: ilk),
              width: kutu.maxWidth,
              height: kutu.maxHeight,
              fit: BoxFit.cover,
              cacheWidth: 450,
              errorBuilder: (_, __, ___) => yedek,
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final ad = okumaTurAdi(tur);
    final alt = sayi == null ? null : (sayi == 0 ? 'Yakında' : OkumaMetin.vitrinSayi(sayi!));
    return Semantics(
      button: true,
      label: '$ad kategorisi${alt == null ? '' : ', $alt'}. Hikâyeleri aç.',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(OkumaTema.koseKart),
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(aspectRatio: 3 / 4, child: _gorsel()),
                const SizedBox(height: OkumaTema.bosluk8),
                Text(
                  ad,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: appText(size: 16, weight: FontWeight.w800, height: 1.2),
                ),
                if (alt != null)
                  Text(alt, style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tüm hikâyeler: yarım kalan hikâye, "Hikâyemi oluştur" ve tür kategorileri.
class HikayeKesifEkrani extends ConsumerWidget {
  const HikayeKesifEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devam = ref.watch(okumaDevamProvider);
    final katalog = ref.watch(okumaVitrinKatalogProvider);
    final ilk = okumaIlkGrup(ref.watch(okumaSinifProvider).valueOrNull);
    final liste = katalog.valueOrNull;
    final kategoriler = liste == null
        ? [for (final t in okumaVitrinTurleri) (tur: t, sayi: -1, slug: null as String?)]
        : okumaKategoriOzetleri(liste, once: okumaVitrinTurleri);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: Text(OkumaMetin.vitrinTumu, style: appText(size: 20, weight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: OkumaMetin.kartOkuduklarim,
            icon: const Icon(Icons.auto_stories_rounded),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (ctx) => OkuduklarimEkrani(
                  onAc: (satir) {
                    Navigator.of(ctx).pop();
                    okumaAc(context, ref, satir: satir);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          OkumaTema.yanBoslukTelefon,
          OkumaTema.bosluk8,
          OkumaTema.yanBoslukTelefon,
          OkumaTema.bosluk32,
        ),
        children: [
          if (devam != null) ...[
            const OkumaBaslik(OkumaMetin.vitrinDevamBolum),
            const SizedBox(height: OkumaTema.bosluk12),
            _DevamSatiri(devam: devam, onTap: () => okumaAc(context, ref, satir: devam.satir)),
            const SizedBox(height: OkumaTema.bosluk24),
          ],
          const OkumaBaslik(OkumaMetin.vitrinKesifBaslik),
          const SizedBox(height: OkumaTema.bosluk12),
          if (katalog.hasError)
            Padding(
              padding: const EdgeInsets.only(bottom: OkumaTema.bosluk12),
              child: Row(
                children: [
                  Expanded(child: Text(OkumaMetin.vitrinKatalogHata, style: appText(color: AppColors.muted, height: 1.35))),
                  TextButton(
                    onPressed: () => ref.invalidate(okumaVitrinKatalogProvider),
                    child: const Text(OkumaMetin.yenidenDene),
                  ),
                ],
              ),
            )
          else if (liste != null && liste.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: OkumaTema.bosluk12),
              child: Text(OkumaMetin.vitrinKesifBos, style: appText(color: AppColors.muted, height: 1.35)),
            ),
          LayoutBuilder(
            builder: (context, kutu) {
              final genislik = (kutu.maxWidth - OkumaTema.bosluk16) / 2;
              return Wrap(
                spacing: OkumaTema.bosluk16,
                runSpacing: OkumaTema.bosluk20,
                children: [
                  for (final k in kategoriler)
                    SizedBox(
                      width: genislik,
                      child: OkumaKategoriKapagi(
                        tur: k.tur,
                        ilk: ilk,
                        sayi: k.sayi < 0 ? null : k.sayi,
                        slug: k.slug,
                        onTap: () => okumaAc(context, ref, ilkTur: k.tur),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Yarım kalan hikâye satırı: kapak, başlık, ilerleme ve devam düğmesi.
class _DevamSatiri extends StatelessWidget {
  const _DevamSatiri({required this.devam, required this.onTap});

  final OkumaDevam devam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sayfa = devam.toplam > 0 ? OkumaMetin.vitrinSayfa(devam.sayfa + 1, devam.toplam) : null;
    return Semantics(
      button: true,
      label: '${devam.satir.baslik}. ${sayfa ?? ''}. ${OkumaMetin.vitrinDevam}.',
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(OkumaTema.koseKart),
          child: InkWell(
            borderRadius: BorderRadius.circular(OkumaTema.koseKart),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(OkumaTema.bosluk12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(OkumaTema.koseKart),
                border: Border.all(color: AppColors.line, width: OkumaTema.kenarVarsayilan),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 84,
                    child: OkumaSahne(tur: devam.satir.tur, slug: devam.satir.slug, yukseklik: 84),
                  ),
                  const SizedBox(width: OkumaTema.bosluk12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          devam.satir.baslik,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: appText(size: 16, weight: FontWeight.w800),
                        ),
                        if (sayfa != null) ...[
                          const SizedBox(height: OkumaTema.bosluk8),
                          OkumaIlerlemeCubugu(oran: devam.oran, etiket: sayfa),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: OkumaTema.bosluk8),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

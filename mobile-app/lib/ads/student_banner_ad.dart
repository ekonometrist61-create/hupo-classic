// Öğrenci ekranlarında güvenli, çocuklara uygun banner reklam widget'ı.
//
// COPPA uyumlu: kişiselleştirilmemiş reklamlar gösterilir, kullanıcı takibi yapılmaz.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

class StudentBannerAd extends ConsumerStatefulWidget {
  const StudentBannerAd({super.key});

  @override
  ConsumerState<StudentBannerAd> createState() => _StudentBannerAdState();
}

class _StudentBannerAdState extends ConsumerState<StudentBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Yalnızca Android ve iOS mobil platformlarında çalışır
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final adUnitId =
        ref.read(studentBannerAdUnitIdProvider) ?? AdConfig.testBannerUnitId;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(
        // Çocuk koruma standartlarına uygun istek
        nonPersonalizedAds: true,
      ),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

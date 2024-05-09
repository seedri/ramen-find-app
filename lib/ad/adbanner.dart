import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:map_sample_flutter/ad/ad_manager.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({
    Key? key,
    required this.size,
  }) : super(key: key);
  final AdSize size;

  @override
  _AdBannerState createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  late BannerAd banner;

  @override
  void initState() {
    super.initState();
    banner = _createBanner(widget.size);
  }

  @override
  void dispose() {
    banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }

  BannerAd _createBanner(AdSize size) {
    return BannerAd(
      size: size,
      adUnitId: AdManager.bannerAdUnitId,
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          banner.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();
  }
}

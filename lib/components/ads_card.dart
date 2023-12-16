import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsCard extends StatefulWidget {
  const AdsCard({
    super.key,
  });

  @override
  State<AdsCard> createState() => _AdsCardState();
}

class _AdsCardState extends State<AdsCard> {
  late BannerAd bannerAd;
  bool adLoaded = false;

  Future<void> initializeAd() async {
    const adUnitId = 'ca-app-pub-3940256099942544/6300978111';
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log(ad.adUnitId, name: 'Ad loaded');
          setState(
            () {
              adLoaded = true;
            },
          );
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          log('$error', name: 'Ad failed to load');
        },
      ),
    );

    await bannerAd.load();

  }

  @override
  void initState() {
    super.initState();
    initializeAd();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: bannerAd.size.width.toDouble(),
        height: bannerAd.size.height.toDouble(),
        margin: const EdgeInsets.only(top: 30, bottom: 20),
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: adLoaded
            ? AdWidget(
                ad: bannerAd,
              )
            : const SizedBox(),
      ),
    );
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsCard extends StatefulWidget {
  const AdsCard({
    super.key,
    this.adSize = AdSize.banner,
  });

  final AdSize adSize;

  @override
  State<AdsCard> createState() => _AdsCardState();
}

class _AdsCardState extends State<AdsCard> {
  late BannerAd bannerAd;
  bool adLoaded = false;

  Future<void> initializeAd() async {
    final adUnitId = kDebugMode
        ? remoteConfigData.testAdUnitId
        : Platform.isAndroid
            ? remoteConfigData.androidAdUnitId
            : remoteConfigData.iosAdUniId;
    bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log('${ad.adUnitId} - ti ${DateTime.now()}', name: 'Ad loaded');
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
        // margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: adLoaded
            ? AdWidget(
                ad: bannerAd,
              )
            : const Center(
                child: CupertinoActivityIndicator(),
              ),
      ),
    );
  }
}

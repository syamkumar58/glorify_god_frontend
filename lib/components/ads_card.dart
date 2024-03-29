import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String adFailedToLoad = '';

  Future<void> initializeAd() async {
    final adUnitId = kDebugMode
        ? remoteConfigData.testAdUnitId
        : Platform.isAndroid
            ? remoteConfigData.androidAdUnitId
            : remoteConfigData.iosAdUniId;
    log(adUnitId, name: 'The ad unit id');
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
          setState(() {
            adFailedToLoad = 'Ad failed to load..';
          });
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
            : Center(
                child: adFailedToLoad.isNotEmpty
                    ? AppText(
                        styles: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.dullWhite,
                        ),
                        text: adFailedToLoad,
                      )
                    : const CupertinoActivityIndicator(),
              ),
      ),
    );
  }
}

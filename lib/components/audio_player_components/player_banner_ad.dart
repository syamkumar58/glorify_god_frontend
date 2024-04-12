import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PlayerBannerAd extends StatefulWidget {
  const PlayerBannerAd({
    super.key,
    this.adSize = AdSize.banner,
  });

  final AdSize adSize;

  @override
  State<PlayerBannerAd> createState() => _PlayerBannerAdState();
}

class _PlayerBannerAdState extends State<PlayerBannerAd> {
  late BannerAd bannerAd;
  bool adLoaded = false;

  Future<void> initializeAd() async {
    final adUnitId = kDebugMode
        ? remoteConfigData.testAdUnitId
        : Platform.isAndroid
            ? remoteConfigData.playerAndroidAdUnitId
            : remoteConfigData.playerIosAdUnitId;
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
          // Retry loading the ad after a delay
          log('$error', name: 'Ad failed to load');
          Future.delayed(const Duration(seconds: 30), () {
            if (!adLoaded) {
              ad.dispose(); // Dispose the failed ad
              initializeAd(); // Attempt to load the ad again
            }
          });
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

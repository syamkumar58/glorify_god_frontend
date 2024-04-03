import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:hive/hive.dart';

class InterstitialAdConfig {
  ad.InterstitialAd? _interstitialAd;

  Future interstitialAdLogic({required Box box}) async {
    final dynamic getStoredAdShownTime =
        await box.get(HiveKeys.storeInterstitialAdLoadedTime);

    if (getStoredAdShownTime == null) {
      //<-- If the stored value is null then will put the value to the
      // hive when the add loaded and closed like on dismissed the ad will assign
      // the key and value to it
      // adDismissed Call will inside  the loadInterstitialAds Function
      // -->/
      log('', name: 'Stored value is null');
      loadInterstitialAds(box: box);
    } else {
      final presentTime = DateTime.now();
      final convertStoredValueToDateTime =
          DateTime.parse(getStoredAdShownTime.toString());

      if (presentTime.isAfter(
        convertStoredValueToDateTime.add(
          Duration(
            seconds: kDebugMode ? 1 : remoteConfigData.interstitialAdTime,
          ),
        ),
      )) {
        log('did ir came here after 2 mins when i launch the app');
        await box.delete(HiveKeys.storeInterstitialAdLoadedTime);
        loadInterstitialAds(box: box);
      }
    }
  }

  // Future showInterstitialAd() async {
  //   loadInterstitialAds(box: ).then((_) {
  //     Future.delayed(const Duration(seconds: 5), () async {
  //       if (_interstitialAd != null) {
  //         await _interstitialAd!.show();
  //       } else {
  //         log('Interstitial Ad not loaded due to null ');
  //       }
  //     });
  //   });
  // }

  Future loadInterstitialAds({required Box box}) async {
    final adUnitId = kDebugMode
        ? remoteConfigData.interstitialAdTestId
        : Platform.isAndroid
            ? remoteConfigData.androidInterstitialAdUnitId
            : remoteConfigData.iosInterstitialAdUnitId;

    log(adUnitId, name: 'loadInterstitialAds adUnitId');

    await ad.InterstitialAd.load(
      adUnitId: adUnitId,
      request: const ad.AdRequest(),
      adLoadCallback: ad.InterstitialAdLoadCallback(
        onAdLoaded: (ad.InterstitialAd advertisement) {
          log('$advertisement', name: 'Step 1');
          _interstitialAd = advertisement;
          log('$_interstitialAd', name: 'Step 2');
          _interstitialAd!.fullScreenContentCallback =
              ad.FullScreenContentCallback(
            onAdDismissedFullScreenContent: (advertisement) async {
              log('', name: 'Step 3');
              advertisement.dispose();
              await box.put(
                HiveKeys.storeInterstitialAdLoadedTime,
                DateTime.now().toString(),
              );
              //<-- Store a key value of date time and again fetch and check the that when to load the
              // interstitial ad
              // -->/
            },
            onAdFailedToShowFullScreenContent: (advertisement, error) {
              log(
                '$error',
                name: 'onAdFailedToShowFullScreenContent ad failed to load',
              );
              advertisement.dispose();
            },
          );
        },
        onAdFailedToLoad: (ad.LoadAdError error) {
          _interstitialAd!.dispose();
          log('$error', name: 'Failed to load the Interstitial ad');
        },
      ),
    );
  }

  Future showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
    } else {
      log('Interstitial Ad not loaded due to null $_interstitialAd');
    }
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meta/meta.dart';

part 'ads_state.dart';

class AdsCubit extends Cubit<AdsState> {
  AdsCubit() : super(AdsInitial());

  late BannerAd _bannerAd;

  Future<void> initializeAd() async {
    emit(AdsLoading());
    final adUnitId = kDebugMode
        ? remoteConfigData.testAdUnitId
        : Platform.isAndroid
            ? remoteConfigData.androidAdUnitId
            : remoteConfigData.iosAdUniId;
    log(adUnitId, name: 'The ad unit id');
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // emit(AdsLoaded(bannerAd: _bannerAd));
          log('$ad', name: 'Ad Loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          emit(AdsError());
          log('$error', name: 'Ad failed to load');
        },
      ),
    );

    await _bannerAd.load();
    emit(AdsLoaded(bannerAd: _bannerAd));
  }

  BannerAd get bannerAd => _bannerAd;
}

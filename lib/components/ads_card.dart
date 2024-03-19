import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/ads_cubit/ads_cubit.dart';
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
  // late BannerAd bannerAd;
  // bool adLoaded = false;
  //
  // Future<void> initializeAd() async {
  //   final adUnitId = kDebugMode
  //       ? remoteConfigData.testAdUnitId
  //       : Platform.isAndroid
  //           ? remoteConfigData.androidAdUnitId
  //           : remoteConfigData.iosAdUniId;
  //   log(adUnitId, name: 'The ad unit id');
  //   bannerAd = BannerAd(
  //     size: widget.adSize,
  //     adUnitId: adUnitId,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (ad) {
  //         log('${ad.adUnitId} - ti ${DateTime.now()}', name: 'Ad loaded');
  //         setState(
  //           () {
  //             adLoaded = true;
  //           },
  //         );
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //         log('$error', name: 'Ad failed to load');
  //       },
  //     ),
  //   );
  //
  //   await bannerAd.load();
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsCubit, AdsState>(
      bloc: BlocProvider.of<AdsCubit>(context)
        ..initializeAd(),
      builder: (context, state) {
        if (state is AdsError) {
          return const SizedBox();
        }

        if (state is AdsLoading) {
          return const SizedBox();
        }

        if (state is AdsLoaded) {
          final bannerAd = state.bannerAd;
          return Center(
            child: Container(
              width: bannerAd.size.width.toDouble(),
              height: bannerAd.size.height.toDouble(),
              // margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AdWidget(
                ad: bannerAd,
              ),
            ),
          );
        }

        return Container();
      },
    );
  }
}

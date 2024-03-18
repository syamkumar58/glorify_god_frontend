import 'package:flutter/cupertino.dart';
import 'package:glorify_god/provider/app_state.dart' as app;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart' as p;

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
  app.AppState appState = app.AppState();

  @override
  Widget build(BuildContext context) {
    appState = p.Provider.of<app.AppState>(context);
    return Center(
      child: Container(
        width: appState.bannerAd!.size.width.toDouble(),
        height: appState.bannerAd!.size.height.toDouble(),
        // margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: appState.bannerAd != null
            ? AdWidget(
                ad: appState.bannerAd!,
              )
            : const Center(
                child: CupertinoActivityIndicator(),
              ),
      ),
    );
  }
}

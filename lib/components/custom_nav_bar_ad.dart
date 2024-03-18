import 'package:flutter/material.dart';
import 'package:glorify_god/components/ads_card.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CustomNavBarAd extends StatelessWidget {
  const CustomNavBarAd({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Container(
        height: 70,
        width: width,
        color: Colors.transparent,
        child: const AdsCard(
          adSize: AdSize.banner,
        ),
      ),
    );
  }
}

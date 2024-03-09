import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class BannerCard extends StatefulWidget {
  const BannerCard({super.key});

  @override
  State<BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<BannerCard> {
  double get width => MediaQuery.of(context).size.width;
  int pageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            enableInfiniteScroll: true,
            enlargeCenterPage: true,
            aspectRatio: 2.5 / 1,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                pageIndex = index;
              });
              log('$reason', name: 'The reason');
            },
          ),
          items: [
            if (remoteConfigData.bannerMessages.isEmpty)
              Shimmer.fromColors(
                baseColor: AppColors.dullWhite.withOpacity(0.2),
                highlightColor: AppColors.dullBlack.withOpacity(0.2),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    width: width,
                    height: 100,
                  ),
                ),
              )
            else
              ...remoteConfigData.bannerMessages.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    width: width,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.dullWhite,
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          AppColors.dullWhite.withOpacity(0.2),
                          AppColors.dullBlack.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1561448817-bb90ab1327b5?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2070&q=80',
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                            text: e.message,
                            maxLines: 4,
                            styles: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                              height: 2,
                            )),
                        AppText(
                            text: e.verses,
                            maxLines: 4,
                            textAlign: TextAlign.start,
                            styles: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 2,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
        Positioned(
          left: 40,
          top: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(remoteConfigData.bannerMessages.length, (index) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      Icons.fiber_manual_record,
                      color: pageIndex == index
                          ? AppColors.redAccent
                          : AppColors.dullWhite,
                      size: 10,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

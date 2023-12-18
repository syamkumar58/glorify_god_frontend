import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/utils/app_colors.dart';

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
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            enableInfiniteScroll: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                pageIndex = index;
              });
              log('$reason', name: 'The reason');
            },
          ),
          items: [
            ...remoteConfigData.bannerMessages.map((e) {
              return Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                ),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    width: width,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.dullWhite,
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
                ),
              );
            }).toList(),
          ],
        ),
        Row(
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
                        : AppColors.dullBlack,
                    size: 10,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
}

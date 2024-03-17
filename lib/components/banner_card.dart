import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/connectivity_bloc/internet_connection_cubit.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return BlocBuilder<InternetConnectionCubit, InternetConnectionState>(
      builder: (context, state) {
        if (state is! InternetConnection) {
          return const SizedBox();
        }

        final connection = state.connectivityResult;

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
                          image: connection != ConnectivityResult.none
                              ? DecorationImage(
                                  image: NetworkImage(
                                    e.imageUrl,
                                  ),
                                  fit: BoxFit.fill,
                                )
                              : DecorationImage(
                                  image: AssetImage(
                                    AppImages.cross,
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
                              styles: GoogleFonts.manrope(
                                backgroundColor:
                                    AppColors.black.withOpacity(0.4),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.white,
                                height: 2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: AppText(
                                text: e.verses,
                                maxLines: 4,
                                textAlign: TextAlign.start,
                                styles: GoogleFonts.manrope(
                                  backgroundColor:
                                      AppColors.black.withOpacity(0.4),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                  height: 2,
                                ),
                              ),
                            ),
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
                  ...List.generate(remoteConfigData.bannerMessages.length,
                      (index) {
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
      },
    );
  }
}

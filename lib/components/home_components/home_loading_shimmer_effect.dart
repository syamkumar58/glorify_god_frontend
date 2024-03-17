import 'package:flutter/material.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmerEffect extends StatelessWidget {
  const HomeShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 12, bottom: 12),
      child: Shimmer.fromColors(
          baseColor: AppColors.dullWhite.withOpacity(0.2),
          highlightColor: AppColors.dullBlack.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(
                  3,
                  (index) => Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 13,
                              decoration: BoxDecoration(
                                color: AppColors.dullBlack,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // const SizedBox(
                            //   height: 4,
                            // ),
                            // Container(
                            //   width: 200,
                            //   height: 10,
                            //   decoration: BoxDecoration(
                            //     color: AppColors.dullBlack,
                            //     borderRadius:
                            //         BorderRadius.circular(2),
                            //   ),
                            // ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    color: AppColors.dullBlack,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    color: AppColors.dullBlack,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    color: AppColors.dullBlack,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),).toList(),
            ],
          ),),
    );
  }
}

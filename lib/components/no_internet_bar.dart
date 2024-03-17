import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';

/// NoInternetBar
class NoInternetBar extends StatelessWidget {
  /// const
  const NoInternetBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height * 0.04;
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.maroon2,
        // borderRadius: BorderRadius.circular(8)
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AutoSizeText(
          textScaleFactor: 1,
          AppStrings.offline_mode,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

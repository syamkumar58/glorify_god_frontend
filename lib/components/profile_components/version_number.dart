import 'package:flutter/material.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionNumber extends StatelessWidget {
  const VersionNumber({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> packageInfo) {
        if (!packageInfo.hasData) {
          return Container();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Center(
            child: AppText(
              text:
                  '''${AppStrings.version} ${packageInfo.data!.version}+${packageInfo.data!.buildNumber}''',
              styles: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.dullWhite,
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';

class AdLoadingComponent extends StatelessWidget {
  const AdLoadingComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            styles: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.dullWhite,
            ),
            text: AppStrings.adLoading,
          ),
          const SizedBox(
            width: 10,
          ),
          CupertinoActivityIndicator(
            color: AppColors.dullWhite,
          ),
        ],
      ),
    );
  }
}

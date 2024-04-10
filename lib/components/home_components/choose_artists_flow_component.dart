import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/components/home_components/users_choice_component.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseArtists extends StatelessWidget {
  const ChooseArtists({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Bounce(
        duration: const Duration(milliseconds: 50),
        onPressed: () {
          artistsOrderOptionsSheet(context: context);
        },
        child: Container(
          width: width * 0.6,
          margin: const EdgeInsets.only(
            top: 10,
            bottom: 20,
          ),
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dullWhite),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                styles: GoogleFonts.manrope(),
                text: AppStrings.chooseArtistYouLike,
              ),
              const SizedBox(
                width: 12,
              ),
              const Icon(
                Icons.keyboard_arrow_up,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreDetails extends StatelessWidget {
  const MoreDetails({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 12, right: 12),
      color: AppColors.dullBlack.withOpacity(0.3),
      child: Column(
        children: [
          const ListTile(
            dense: true,
            leading: AppText(
              text: AppStrings.songName,
              textAlign: TextAlign.left,
              styles: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            title: AppText(
              text: 'youtubePlayerHandler.selectedSongData.title',
              textAlign: TextAlign.left,
              styles: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const ListTile(
            dense: true,
            leading: AppText(
              text: AppStrings.singer,
              textAlign: TextAlign.left,
              styles: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            title: AppText(
              text: 'youtubePlayerHandler.selectedSongData.artist',
              textAlign: TextAlign.left,
              styles: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          ListTile(
            dense: true,
            leading: AppText(
              text: AppStrings.lyricist,
              textAlign: TextAlign.left,
              styles: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            title: AppText(
              text: 'youtubePlayerHandler.selectedSongData.lyricist',
              textAlign: TextAlign.left,
              styles: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          ListTile(
            dense: true,
            leading: AppText(
              text: AppStrings.credits,
              textAlign: TextAlign.left,
              styles: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            title: AppText(
              text: 'youtubePlayerHandler.selectedSongData.credits',
              textAlign: TextAlign.left,
              styles: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AppText(
              text: 'youtubePlayerHandler.selectedSongData.otherData',
              maxLines: 2000,
              textAlign: TextAlign.left,
              styles: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: avoid_dynamic_calls

import 'package:glorify_god/components/noisey_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleTile extends StatefulWidget {
  const TitleTile({
    super.key,
    required this.title,
    required this.onPressViewAll,
    this.showViewAll = true,
    required this.pastorImage,
  });

  final String title;
  final String pastorImage;
  final bool showViewAll;
  final Function onPressViewAll;

  @override
  // ignore: library_private_types_in_public_api
  _TitleTileState createState() => _TitleTileState();
}

class _TitleTileState extends State<TitleTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.pastorImage.isNotEmpty
          ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: AppColors.white,
            width: 1.2,
          )
        ),
            child: CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                  widget.pastorImage,
                ),
                backgroundColor: AppColors.dullBlack.withOpacity(0.5),
              ),
          )
          : CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage(
                AppImages.appWhiteIcon,
              ),
              backgroundColor: AppColors.dullBlack.withOpacity(0.5),
            ),
      title: AppText(
        text: widget.title,
        textAlign: TextAlign.start,
        styles: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: widget.showViewAll
          ? Bounce(
              duration: const Duration(
                milliseconds: 50,
              ),
              onPressed: () {
                widget.onPressViewAll();
              },
              child: AppText(
                text: 'View all',
                styles: GoogleFonts.manrope(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}

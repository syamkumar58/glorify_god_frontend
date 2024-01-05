import 'package:flutter/material.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar customAppbar(String text) => AppBar(
      leading: const SizedBox(),
      centerTitle: true,
      title: AppText(
        text: text,
        styles: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.white,
          letterSpacing: 1.2,
        ),
      ),
    );

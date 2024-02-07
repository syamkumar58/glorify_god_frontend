import 'dart:developer';

import 'package:auto_route/annotations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/components/banner_card.dart';
import 'package:glorify_god/components/custom_nav_bar_ad.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  AppState appState = AppState();
  Box? hiveBox;

  @override
  void initState() {
    appState = context.read<AppState>();
    hiveBox = Hive.box(HiveKeys.openBox);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppText(
          text: AppStrings.helpAndSupport,
          styles: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BannerCard(),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: helpLine(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBarAd(),
    );
  }

  Widget whatsAppContact() {
    return Container(
      width: width * 0.9,
      height: 120,
      decoration: BoxDecoration(
          color: AppColors.grey, borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget helpLine() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: AppText(
            text: AppStrings.helpAndSupport,
            styles: GoogleFonts.manrope(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              color: AppColors.white,
            ),
          ),
        ),
        Container(
          width: width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Need Help? We've Got You Covered!",
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    TextSpan(
                      text: '\n\nContact Us:',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    TextSpan(
                      text: '\n\n • Phone Support:',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    TextSpan(
                      text: ' 9704263451',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          log('Number tapped');
                          final phoneNumber = Uri.parse('tel:9704263451');
                          if (await canLaunchUrl(phoneNumber)) {
                            await launchUrl(phoneNumber);
                          }
                        },
                    ),
                    TextSpan(
                      text: '\n\n • Email Support:',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    TextSpan(
                      text: ' k.syam7908@gmail.com',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          log('Email tapped');
                          const url = 'k.syam7908@gmail.com';
                          final uri = Uri.parse('mailto:$url');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                    ),
                    TextSpan(
                      text: '\n\nCommon Issues:',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    TextSpan(
                      text: '\n\n'
                          '1. Trouble logging in?\n'
                          '2. Playback not working?\n'
                          '3. Audio issues?\n',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: AppText(
                  text: 'Thanks for choosing Glorify God',
                  styles: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

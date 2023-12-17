import 'dart:developer';

import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  AppState appState = AppState();
  bool helpAndSupportValue = true;

  @override
  void initState() {
    appState = context.read<AppState>();
    hiveBox = Hive.box(HiveKeys.openBox);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: height,
        width: width,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                quoteBackgroundWithProfileImage(),
                name(),
                const SizedBox(
                  height: 20,
                ),
                helpLine(),
                logoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget quoteBackgroundWithProfileImage() {
    return SizedBox(
      width: width,
      height: 230,
      child: Stack(
        children: [
          SizedBox(
            width: width,
            height: 170,
            child: Image.asset(
              AppImages.jesusName,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 30,
                right: 20,
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    appState.userData.profileUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget name() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 30),
      child: AppText(
        styles: const TextStyle(
          fontSize: 30,
          fontFamily: 'AppTitle',
        ),
        text: appState.userData.displayName,
      ),
    );
  }

  Widget helpLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
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
            trailing: Icon(
              helpAndSupportValue
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
              color: AppColors.white,
              size: 18,
            ),
            // onTap: () {
            //   setState(() {
            //     helpAndSupportValue = !helpAndSupportValue;
            //   });
            // },
          ),
          if (helpAndSupportValue)
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        TextSpan(
                          text: ' 970426',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              log('Number tapped');
                            },
                        ),
                        TextSpan(
                          text: '\n\n • Email Support:',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        TextSpan(
                          text: ' k.syam7908@gmail.com',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              log('Email tapped');
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
                              '2. layback not working?\n'
                              '3. Billing questions?\n',
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
      ),
    );
  }

  Box? hiveBox;

  Widget logoutButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 20),
      child: CupertinoButton(
        onPressed: () async {
          await GoogleSignIn().signOut();
          await hiveBox!.clear();
          await onLogOutPushScreen();
        },
        child: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.redAccent,
              size: 20,
            ),
            const SizedBox(
              width: 12,
            ),
            AppText(
              styles: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.redAccent,
              ),
              text: 'Logout',
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Future onLogOutPushScreen() async {
    await GoRouter.of(context).pushReplacement('/loginPage');
  }
}

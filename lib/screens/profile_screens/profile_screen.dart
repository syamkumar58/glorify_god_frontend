import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:glorify_god/components/custom_app_bar.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/profile_components/version_number.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/youtube_player_handler.dart';
import 'package:glorify_god/screens/login_pages/login_page.dart';
import 'package:glorify_god/screens/profile_screens/songs_info_screen.dart';
import 'package:glorify_god/screens/profile_screens/contact_support_screen.dart';
import 'package:glorify_god/screens/profile_screens/privacy_policy_screen.dart';
import 'package:glorify_god/screens/profile_screens/report_a_problem.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
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
  YoutubePlayerHandler youtubePlayerHandler = YoutubePlayerHandler();
  Box? hiveBox;
  bool onLogout = false;

  @override
  void initState() {
    appState = context.read<AppState>();
    hiveBox = Hive.box(HiveKeys.openBox);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    youtubePlayerHandler = Provider.of<YoutubePlayerHandler>(context);
    return ModalProgressHUD(
      inAsyncCall: onLogout,
      progressIndicator: const CupertinoActivityIndicator(),
      child: Scaffold(
        appBar: customAppbar('PROFILE'),
        body: SizedBox(
          height: height,
          width: width,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                profileData(),
                if (appState.artistLoginDataByEmail != null)
                  songsInformationTile(),
                restOfScreen(),
                const SizedBox(
                  height: 40,
                ),
                const VersionNumber(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget profileData() {
    return Center(
      child: Container(
        width: width * 0.9,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.dullBlack.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  width: appState.userData.profileUrl.isNotEmpty ? 4 : 0,
                  color: AppColors.white,
                ),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.dullBlack,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: appState.userData.profileUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    errorWidget: (context, error, _) {
                      log(error, name: 'The image error');
                      return Icon(
                        Icons.account_circle_outlined,
                        color: AppColors.white,
                        size: 50,
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: AppText(
                styles: TextStyle(
                  letterSpacing: 1,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
                text: appState.userData.provider == 'PHONENUMBER'
                    ? appState.userData.mobileNumber
                    : appState.userData.provider == 'EMAIL'
                        ? appState.userData.email
                        : appState.userData.displayName.isNotEmpty
                            ? appState.userData.displayName
                            : 'Name',
              ),
            ),
            if (appState.userData.provider == 'GOOGLE')
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: AppText(
                  styles: TextStyle(
                    fontSize: 14,
                    color: AppColors.dullWhite,
                  ),
                  text: appState.userData.email.isNotEmpty
                      ? '@${appState.userData.email}'
                      : '@email',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget songsInformationTile() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Center(
        child: Container(
          width: width * 0.9,
          decoration: BoxDecoration(
            color: AppColors.dullBlack.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: tile(
            icon: Icons.diamond_outlined,
            text: AppStrings.songInfo,
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => const SongsInfoScreen(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget restOfScreen() {
    return Center(
      child: Container(
        width: width * 0.9,
        padding: const EdgeInsets.only(top: 12),
        margin: EdgeInsets.only(
          top: appState.artistLoginDataByEmail != null ? 0 : 20,
        ),
        decoration: BoxDecoration(
          color: AppColors.dullBlack.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appRating(),
            tile(
              icon: Icons.contact_support_outlined,
              text: AppStrings.helpAndSupport,
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => const ContactSupportScreen(),
                  ),
                );
              },
            ),
            tile(
              icon: Icons.report_gmailerrorred,
              text: AppStrings.reportIssue,
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (_) => const ReportAProblem()),
                );
              },
            ),
            tile(
              icon: Icons.verified_user_outlined,
              text: 'Privacy Policy',
              onTap: () async {
                // final url = 'http://glorifyGod.in/privacyPolicy';

                // if (await canLaunchUrlString(url)) {
                //   await launchUrlString(url);
                // }

                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(
                      showNavBack: true,
                    ),
                  ),
                );
              },
            ),
            tile(
              icon: Icons.logout_rounded,
              text: AppStrings.logout,
              onTap: () async {
                if (appState.connectivityResult != ConnectivityResult.none) {
                  setState(() {
                    onLogout = true;
                  });

                  // await appState.removeUserFromPrivacyPolicyById();
                  await stopYoutubePlayer();
                  await hiveBox!.clear();
                  if (appState.userData.provider == 'GOOGLE') {
                    log('log out 1');
                    await GoogleSignIn().signOut();
                  } else if (appState.userData.provider == 'EMAIL' ||
                      appState.userData.provider == 'PHONENUMBER') {
                    log('log out 2');
                    await FirebaseAuth.instance.signOut();
                  }
                  Future.delayed(const Duration(seconds: 2), () async {
                    await onLogOutPushScreen();
                  });
                } else {
                  toastMessage(
                    message: 'Check your internet connection and try again',
                  );
                }
              },
            ),
            if (kDebugMode)
              tile(
                icon: Icons.telegram,
                text: 'Test Bu',
                onTap: () async {},
              ),
          ],
        ),
      ),
    );
  }

  Widget appRating() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 30,
        left: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: AppText(
              text: AppStrings.rateUs,
              styles: GoogleFonts.manrope(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
          ),
          RatingBar.builder(
            itemPadding: const EdgeInsets.only(bottom: 12),
            itemCount: 5,
            itemSize: 25,
            initialRating: appState.userGivenRating.toDouble(),
            itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) async {
              await appState
                  .updateRatings(rating: rating.toInt())
                  .then((value) {})
                  .catchError((dynamic onError) {
                if (onError.toString().contains('Connection error')) {
                  toastMessage(
                    message:
                        'Connection error. Server is under maintenance. Try again later in some time',
                  );
                }
              });
            },
          ),
          AppText(
            text: AppStrings.rateUsQuote,
            maxLines: 5,
            textAlign: TextAlign.left,
            styles: GoogleFonts.manrope(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget tile({
    required IconData icon,
    required String text,
    required Function onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: AppColors.dullWhite.withOpacity(0.8),
              size: 25,
            ),
          ),
        ),
        title: AppText(
          styles: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.dullWhite.withOpacity(0.8),
          ),
          text: text,
          textAlign: TextAlign.left,
        ),
        onTap: () {
          onTap();
        },
      ),
    );
  }

  Future stopYoutubePlayer() async {
    if (youtubePlayerHandler.youtubePlayerController != null) {
      youtubePlayerHandler.extendToFullScreen = false;
      youtubePlayerHandler.youtubePlayerController!.dispose();
      youtubePlayerHandler.youtubePlayerController = null;
    }
  }

  Future onLogOutPushScreen() async {
    await Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
    setState(() {
      onLogout = false;
    });
  }
}

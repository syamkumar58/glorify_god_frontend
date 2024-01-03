// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:ui';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/components/login_button.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/screens/bottom_tabs/bottom_tabs.dart';
import 'package:glorify_god/src/provider/user_bloc.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  late Box<dynamic> glorifyGodBox;

  bool loading = false;

  late AnimationController lottieController;

  @override
  void initState() {
    lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    lottieController.repeat();
    glorifyGodBox = Hive.box(HiveKeys.openBox);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.dullBlack,
      body: ModalProgressHUD(
        inAsyncCall: loading,
        progressIndicator: CupertinoActivityIndicator(
          color: AppColors.white,
        ),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.black,
            image: DecorationImage(
              image: AssetImage(
                AppImages.cross,
              ),
              fit: BoxFit.cover,
              opacity: 0.5,
              filterQuality: FilterQuality.high,
            ),
          ),
          child: Stack(
            children: [
              // Align(
              //   alignment: Alignment.center,
              //   child: Lottie.asset(
              //     LottieAnimations.musicSymbolAnimation,
              //     controller: lottieController,
              //     height: height,
              //     width: width,
              //     repeat: true,
              //   ),
              // ),
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        appTitle(),
                        SizedBox(
                          height: height * 0.2,
                        ),
                        googleLogoLogin(),
                        // googleLoginButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appTitle() {
    return SizedBox(
      width: width * 0.9,
      child: const AppText(
        text: AppStrings.appName2,
        styles: TextStyle(
          fontSize: 80,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'AppTitle',
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget googleLogoLogin() {
    return Column(
      children: [
        Bounce(
            duration: const Duration(milliseconds: 500),
            onPressed: () async {
              setState(() {
                loading = true;
              });
              await login();
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.dullBlack,
                borderRadius: BorderRadius.circular(50),
                image: DecorationImage(
                  image: AssetImage(
                    AppImages.googleImage,
                  ),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.dullBlack.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(2, 2)),
                  BoxShadow(
                      color: AppColors.dullWhite.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(-2, -2)),
                ],
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.dullWhite.withOpacity(0.1),
                      AppColors.dullWhite.withOpacity(0.15),
                      AppColors.dullWhite.withOpacity(0.2),
                      AppColors.dullWhite.withOpacity(0.25),
                    ]),
              ),
            )),
        const SizedBox(
          height: 12,
        ),
        AppText(
          styles: GoogleFonts.manrope(),
          text: 'Sign in with\nGoogle',
        ),
      ],
    );
  }

  Widget googleLoginButton() {
    return Center(
      child: loginButton(
        title: 'Sign in with Google',
        height: 50,
        width: width * 0.65,
        fontSize: 20,
        boxColor: Colors.white,
        textColor: Colors.black,
        backgroundImage: AppImages.googleImage,
        onPressed: () async {
          setState(() {
            loading = true;
          });
          await login();
        },
      ),
    );
  }

  Widget appleLoginButton() {
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: height * 0.2),
      child: loginButton(
        title: 'Sign in with Apple',
        height: 50,
        width: width * 0.7,
        boxColor: Colors.black12.withOpacity(0.08),
        backgroundImage: AppImages.googleImage,
        onPressed: () {},
      ),
    );
  }

  Future<dynamic> login() async {
    try {
      final userLogin = await googleLogin();
      if (userLogin != null) {
        setState(() {
          loading = false;
        });
        await Navigator.push(
          context,
          CupertinoPageRoute<BottomTabs>(
            builder: (_) => const BottomTabs(),
          ),
        );
      } else {
        setState(() {
          loading = false;
        });
        log('something went wrong on logIn');
      }
    } catch (er) {
      setState(() {
        loading = false;
      });
      log('$er', name: 'login failed with');
    }
  }
}

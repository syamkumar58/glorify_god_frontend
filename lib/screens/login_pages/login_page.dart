// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/components/login_button.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/bottom_tabs/bottom_tabs.dart';
import 'package:glorify_god/screens/login_pages/email_component.dart';
import 'package:glorify_god/src/provider/user_bloc.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AppState appState = AppState();

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  late Box<dynamic> glorifyGodBox;

  bool loading = false;

  @override
  void initState() {
    glorifyGodBox = Hive.box(HiveKeys.openBox);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: AppColors.appColor2,
      body: ModalProgressHUD(
        inAsyncCall: loading,
        progressIndicator: CupertinoActivityIndicator(
          color: AppColors.white,
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                AppColors.appColor1,
                AppColors.appColor2,
              ],
            )),
            child: SizedBox(
              width: width,
              height: height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    appTitle(),
                    // const MobileNumberScreen(),
                    EmailComponent(
                      loading: (isLoading) {
                        setState(() {
                          loading = isLoading;
                        });
                      },
                      context: context,
                    ),
                    orWidget(),
                    googleLoginWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget appTitle() {
    return Padding(
      padding: EdgeInsets.only(
        top: height * 0.1,
        bottom: height * 0.05,
      ),
      child: SizedBox(
        width: width * 0.9,
        child: const AppText(
          text: AppStrings.appName2,
          styles: TextStyle(
            fontSize: 50,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'AppTitle',
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget googleLoginWidget() {
    return Column(
      children: [
        loginButtonComponent(
          onPressed: () async {
            setState(() {
              loading = true;
            });
            await login();
          },
          image: AppImages.googleImage,
        ),
        const SizedBox(
          height: 12,
        ),
        AppText(
          text: 'Sign in with\nGoogle',
          styles: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget loginButtonComponent({
    required Function onPressed,
    required String image,
  }) {
    return Bounce(
        duration: const Duration(milliseconds: 500),
        onPressed: () async {
          onPressed();
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ));
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

  Widget orWidget() {
    return Padding(
      padding: EdgeInsets.only(top: height * 0.05, bottom: height * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width * 0.08,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: AppColors.dullWhite.withOpacity(0.2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
            ),
            child: AppText(
              styles: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
              text: AppStrings.or,
            ),
          ),
          Container(
            width: width * 0.08,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: AppColors.dullWhite.withOpacity(0.2),
              ),
            ),
          ),
        ],
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
        await Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<BottomTabs>(
              builder: (_) => const BottomTabs(),
            ),
            (route) => false);
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

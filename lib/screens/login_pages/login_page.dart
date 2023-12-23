// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:ui';
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
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
            image: DecorationImage(
              image: AssetImage(
                AppImages.cross,
              ),
              fit: BoxFit.cover,
              opacity: 0.5,
              filterQuality: FilterQuality.high,
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.2),
                      child: animationTitle(),
                    ),
                    Column(
                      children: [
                        googleLoginButton(),
                        // appleLoginButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget animationTitle() {
    return SizedBox(
      width: width * 0.9,
      child: const AppText(
        text: AppStrings.appName,
        styles: TextStyle(
          fontSize: 50,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'AppTitle',
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget googleLoginButton() {
    return Padding(
      /// Remove this padding on App login button
      padding: EdgeInsets.only(top: 20, bottom: height * 0.2),
      child: loginButton(
        title: 'Sign in with Google',
        height: 50,
        width: width * 0.6,
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

// ignore_for_file: use_build_context_synchronously
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/bottom_tabs/bottom_tabs.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  Box<dynamic>? glorifyGodBox;
  AppState appState = AppState();

  @override
  void initState() {
    glorifyGodBox = Hive.box(HiveKeys.openBox);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(seconds: 4), navigations);
    });
  }

  Future<dynamic> navigations() async {
    final userLogInData = await glorifyGodBox?.get(
      HiveKeys.logInKey,
    );
    if (userLogInData != null) {
      await Navigator.push(
        context,
        CupertinoPageRoute<BottomTabs>(
          builder: (_) => const BottomTabs(),
        ),
      );
    } else {
      await GoRouter.of(context).push('/loginPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: width * 0.9,
              child: TextLiquidFill(
                text: AppStrings.appName,
                waveColor: AppColors.redAccent,
                waveDuration: const Duration(seconds: 3),
                loadDuration: const Duration(seconds: 3),
                textStyle: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AppTitle',
                  letterSpacing: 2,
                ),
                boxHeight: 150,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

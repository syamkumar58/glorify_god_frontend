// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';

import 'package:auto_route/annotations.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/models/remote_config/remote_config_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/bottom_tabs/bottom_tabs.dart';
import 'package:glorify_god/screens/login_pages/login_page.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@RoutePage()
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
    setConfigData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(seconds: 2), navigations);
    });
  }

  Future<dynamic> navigations() async {
    final userLogInData = await glorifyGodBox?.get(
      HiveKeys.logInKey,
    );
    if (userLogInData != null) {
      await Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute<BottomTabs>(
            builder: (_) => const BottomTabs(),
          ),
          (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (_) => const LoginPage()),
          (route) => false);
    }
  }

  Future setConfigData() async {
    var remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 30),
      ),
    );
    final data = await remoteConfig.fetchAndActivate();
    final configData = remoteConfig.getString('glorify_god_config');
    remoteConfigData = remoteConfigFromJson(configData);
    log(
        '$data\n'
        '${json.decode(configData)}\n'
        '${remoteConfigData.bannerMessages}',
        name: 'Config data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // SizedBox(
              //   width: width * 0.9,
              //   child: TextLiquidFill(
              //     text: AppStrings.appName,
              //     waveColor: AppColors.redAccent,
              //     waveDuration: const Duration(seconds: 3),
              //     loadDuration: const Duration(seconds: 3),
              //     textStyle: const TextStyle(
              //       fontSize: 60,
              //       fontWeight: FontWeight.bold,
              //       fontFamily: 'AppTitle',
              //       letterSpacing: 2,
              //     ),
              //     boxHeight: 150,
              //   ),
              // ),
              Container(
                color: Colors.transparent,
                width: width * 0.9,
                height: height * 0.46,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AppText(
                    text: AppStrings.appName,
                    styles: TextStyle(
                      color: AppColors.redAccent,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AppTitle',
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
                height: height * 0.4,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CupertinoActivityIndicator(
                      color: AppColors.white,
                      radius: 14,
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
}

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/screens/splash_screen.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:provider/provider.dart' as p;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show the LoadingScreen while initializing Firebase and other services
  runApp(const LoadingScreen());

  await Firebase.initializeApp();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  final path = await getApplicationDocumentsDirectory();

  Hive.init(path.path);

  await Hive.openBox<dynamic>(HiveKeys.openBox);

  await ad.MobileAds.instance.initialize();

  runApp(
    const GlorifyGod(),
  );
}


/// LoadingScreen
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double height = MediaQuery.of(context).size.height;
    return MaterialApp(
      title: AppStrings.appName,
      theme: FlexThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black, // Set background color to black
        body: SafeArea(
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.symmetric(vertical: 200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.appWhiteIcon,
                  height: 60,
                  width: 50,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// GlorifyGod
class GlorifyGod extends StatefulWidget {
  /// const
  const GlorifyGod({super.key});

  @override
  State<GlorifyGod> createState() => _GlorifyGodState();
}

class _GlorifyGodState extends State<GlorifyGod> {
  @override
  Widget build(BuildContext context) {
    return p.MultiProvider(
      providers: [
        p.ChangeNotifierProvider(
          create: (_) => AppState(),
        ),
        p.ChangeNotifierProvider(
          create: (_) => GlobalVariables(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: FlexThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

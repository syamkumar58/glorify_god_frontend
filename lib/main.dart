import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/screens/splash_screen.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:provider/provider.dart' as p;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    p.MultiProvider(
      providers: [
        p.ChangeNotifierProvider(
          create: (_) => AppState(),
        ),
        p.ChangeNotifierProvider(
          create: (_) => GlobalVariables(),
        ),
      ],
      child: const GlorifyGod(),
    ),
  );
}

/// GlorifyGod
class GlorifyGod extends StatefulWidget {
  /// const
  const GlorifyGod({super.key});

  @override
  State<GlorifyGod> createState() => _GlorifyGodState();
}

class _GlorifyGodState extends State<GlorifyGod> {
  AppState appState = AppState();
  StreamSubscription<ConnectivityResult>? subscription;

  @override
  void initState() {
    appState = context.read<AppState>();
    super.initState();
    checkConnection();
  }

  @override
  void dispose() {
    super.dispose();
    subscription!.cancel();
  }

  Future checkConnection() async {
    subscription = Connectivity().onConnectivityChanged.listen((connection) {
      appState.connectivityResult = connection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: FlexThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

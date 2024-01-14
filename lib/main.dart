import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/screens/splash_screen.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:provider/provider.dart' as p;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  final path = await getApplicationDocumentsDirectory();

  Hive.init(path.path);

  await Hive.openBox<dynamic>(HiveKeys.openBox);

  ad.MobileAds.instance.initialize();

  runApp(
    p.MultiProvider(providers: [
      p.ChangeNotifierProvider(
        create: (_) => AppState(),
      ),
      p.ChangeNotifierProvider(
        create: (_) => GlobalVariables(),
      ),
    ], child: const GlorifyGod()),
  );
}

/// GlorifyGod
class GlorifyGod extends StatefulWidget {
  /// const
  const GlorifyGod({super.key});

  @override
  State<GlorifyGod> createState() => _GlorifyGodState();
}

class _GlorifyGodState extends State<GlorifyGod> with WidgetsBindingObserver {
  AppState appState = AppState();

  @override
  void initState() {
    appState = context.read<AppState>();
    log('${appState.audioPlayer.processingState}', name: 'From main page init');
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        if (appState.audioPlayer.processingState != ProcessingState.idle) {
          appState.audioPlayer.dispose();
        }
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = p.Provider.of<AppState>(context);
    return MaterialApp(
      title: AppStrings.appName,
      theme: FlexThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }

  @override
  void dispose() {
    log('${appState.audioPlayer.processingState}', name: 'From main page dispose');
    appState.audioPlayer.dispose();
    WidgetsBinding.instance.addObserver(this);
    super.dispose();
  }
}

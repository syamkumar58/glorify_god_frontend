import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/all_songs_cubit/all_songs_cubit.dart';
import 'package:glorify_god/bloc/profile_cubit/liked_cubit/liked_cubit.dart';
import 'package:glorify_god/bloc/profile_cubit/songs_info_cubit/songs_data_info_cubit.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/provider/youtube_player_handler.dart';
import 'package:glorify_god/screens/splash_screen.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:provider/provider.dart' as p;
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final path = await getApplicationDocumentsDirectory();

  Hive.init(path.path);

  await Hive.openBox<dynamic>(HiveKeys.openBox);

  ad.MobileAds.instance.initialize();

  WakelockPlus.enable();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    const GlorifyGod(),
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
  @override
  Widget build(BuildContext context) {
    return p.MultiProvider(
      providers: [
        p.ChangeNotifierProvider(
          create: (_) => YoutubePlayerHandler(),
        ),
        p.ChangeNotifierProvider(
          create: (_) => AppState(),
        ),
        p.ChangeNotifierProvider(
          create: (_) => GlobalVariables(),
        ),
      ],
      child: const Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  AppState appState = AppState();

  @override
  Widget build(BuildContext context) {
    appState = p.Provider.of<AppState>(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AllSongsCubit(appState: appState),
        ),
        BlocProvider(
          create: (_) => SongsDataInfoCubit(),
        ),
        BlocProvider(
          create: (_) => LikedCubit(),
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

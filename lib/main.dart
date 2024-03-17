import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/all_songs/all_songs_cubit.dart';
import 'package:glorify_god/bloc/connectivity_bloc/internet_connection_cubit.dart';
import 'package:glorify_god/bloc/profile_bloc/liked_cubit/liked_cubit.dart';
import 'package:glorify_god/bloc/profile_bloc/songs_info_cubit/songs_data_info_cubit.dart';
import 'package:glorify_god/bloc/video_player_bloc/video_player_cubit.dart';
import 'package:glorify_god/components/no_internet_bar.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
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
  void initState() {
    appState.checkConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appState = p.Provider.of<AppState>(context);
    log('${appState.connectivityResult}',
        name: 'appState connectivityResult from main');
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AllSongsCubit(appState: appState),
        ),
        BlocProvider(
          create: (_) => SongsDataInfoCubit(),
        ),
        BlocProvider(
          create: (context) => VideoPlayerCubit(
            appState: appState,
            songsDataInfoCubit: BlocProvider.of<SongsDataInfoCubit>(context),
          ),
        ),
        BlocProvider(
          create: (_) => LikedCubit(),
        ),
        //<-- In future if moved to YT player enable this -->/
        // BlocProvider(
        //   create: (_) => YoutubePlayerCubit(),
        // ),
      ],
      child: BlocProvider(
        create: (context) => InternetConnectionCubit(),
        child: Builder(
          builder: (context) {
            return BlocBuilder<InternetConnectionCubit,
                InternetConnectionState>(
              bloc: BlocProvider.of(context)..checkConnection(),
              builder: (context, state) {
                if (state is! InternetConnection) {
                  return MaterialApp(
                    title: AppStrings.appName,
                    theme: FlexThemeData.dark(),
                    debugShowCheckedModeBanner: false,
                    home: const SplashScreen(),
                  );
                }

                final connectivityResult = state.connectivityResult;
                log('$connectivityResult', name: 'Space space ');

                return Column(
                  children: [
                    SizedBox(
                      height: connectivityResult == ConnectivityResult.none
                          ? MediaQuery.of(context).size.height * 0.96
                          : MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: MaterialApp(
                        title: AppStrings.appName,
                        theme: FlexThemeData.dark(),
                        debugShowCheckedModeBanner: false,
                        home: const SplashScreen(),
                      ),
                    ),
                    if (connectivityResult == ConnectivityResult.none)
                      const NoInternetBar(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// import 'dart:developer';
//
// import 'package:flex_color_scheme/flex_color_scheme.dart';
// import 'package:flutter/material.dart';
// import 'package:glorify_god/provider/app_state.dart';
// import 'package:glorify_god/screens/splash_screen.dart';
// import 'package:glorify_god/utils/app_strings.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:provider/provider.dart';
//
// class MainPage extends StatefulWidget {
//   const MainPage({super.key});
//
//   @override
//   State<MainPage> createState() => _MainPageState();
// }
//
// class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
//   AppState appState = AppState();
//
//   @override
//   void initState() {
//     appState = context.read<AppState>();
//     log('${appState.audioPlayer.processingState}', name: 'From main page init');
//     WidgetsBinding.instance.addObserver(this);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     appState.audioPlayer.dispose();
//     WidgetsBinding.instance.addObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     switch (state) {
//       case AppLifecycleState.detached:
//         if (appState.audioPlayer.processingState != ProcessingState.idle) {
//           appState.audioPlayer.dispose();
//         }
//       case AppLifecycleState.resumed:
//       case AppLifecycleState.inactive:
//       case AppLifecycleState.hidden:
//       case AppLifecycleState.paused:
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: AppStrings.appName,
//       theme: FlexThemeData.dark(),
//       debugShowCheckedModeBanner: false,
//       home: const SplashScreen(),
//     );
//   }
// }

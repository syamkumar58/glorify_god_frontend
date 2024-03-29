// ignore_for_file: strict_raw_type, avoid_dynamic_calls

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/all_songs/all_songs_cubit.dart';
import 'package:glorify_god/bloc/video_player_bloc/video_player_cubit.dart';
import 'package:glorify_god/components/banner_card.dart';
import 'package:glorify_god/components/home_components/copy_right_text.dart';
import 'package:glorify_god/components/home_components/home_loading_shimmer_effect.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/song_card_component.dart';
import 'package:glorify_god/components/title_tile_component.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart' as app;
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/screens/video_player_screen/video_player_screen.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  app.AppState appState = app.AppState();
  GlobalVariables globalVariables = GlobalVariables();

  PackageInfo? packageInfo;

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  // bool connectionError = false;
  List<int> showShimmers = [1, 2, 3, 4];
  late AnimationController lottieController;
  bool showUpdateBanner = false;

  List<String> testingSongs = [
    'g1KiQRqfhNc',
    'irvw4_562BM',
    'BlVD1-bxABg',
    'qvVBZ0rYvOg',
  ];

  @override
  void initState() {
    lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    lottieController.repeat();
    appState = context.read<app.AppState>();
    globalVariables = context.read<GlobalVariables>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      packageInformation();
    });
  }

  Future packageInformation() async {
    packageInfo = await PackageInfo.fromPlatform();
    final versionNumber = packageInfo!.version.toString().replaceAll('.', '');
    final androidLatestVersion = remoteConfigData
        .appUpdateVersions.androidLatestVersion
        .replaceAll('.', '');
    final iosLatestVersion =
        remoteConfigData.appUpdateVersions.iosLatestVersion.replaceAll('.', '');
    log(
      '$versionNumber -- $androidLatestVersion -- $iosLatestVersion',
      name: 'versionNumber ',
    );
    setState(() {
      if (Platform.isAndroid) {
        if (int.parse(androidLatestVersion) > int.parse(versionNumber)) {
          showUpdateBanner = true;
        }
      } else if (Platform.isIOS) {
        if (int.parse(iosLatestVersion) > int.parse(versionNumber)) {
          showUpdateBanner = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<app.AppState>(context);
    globalVariables = Provider.of<GlobalVariables>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(showUpdateBanner ? 160 : 60),
        child: SafeArea(
          child: Column(
            children: [
              if (showUpdateBanner)
                ListTile(
                  tileColor: AppColors.blue,
                  title: Text(
                    AppStrings.excitingNews,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                    ),
                    child: AppText(
                      styles: GoogleFonts.manrope(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      text: 'Update',
                    ),
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        const url =
                            'https://play.google.com/store/apps/details?id=app.glorifygod.prod';
                        if (await canLaunchUrlString(url)) {
                          await launchUrlString(url);
                        }
                      }
                    },
                  ),
                ),
              appBar(appState),
            ],
          ),
        ),
      ),
      body: SizedBox(
        width: width,
        height: height,
        child: SafeArea(
          child: BlocBuilder<AllSongsCubit, AllSongsState>(
            builder: (context, state) {
              if (state is AllSongsHasError) {
                return ListView(
                  children: [
                    errorMessage(),
                    commonWidget(),
                    const HomeShimmerEffect(),
                  ],
                );
              }

              if (state is! AllSongsLoaded) {
                return ListView(
                  children: [
                    commonWidget(),
                    const HomeShimmerEffect(),
                  ],
                );
              }

              final allSongs = state.songs;

              return SingleChildScrollView(
                physics: allSongs.isNotEmpty
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    commonWidget(),
                    // if (kDebugMode)
                    //   CupertinoButton(
                    //     color: AppColors.redAccent,
                    //     onPressed: () {
                    //       Navigator.of(context).push(
                    //         CupertinoPageRoute(
                    //           builder: (_) => YoutubeVideoPlayerScreen(
                    //             songs: testingSongs,
                    //           ),
                    //         ),
                    //       );
                    //
                    //       BlocProvider.of<YoutubePlayerCubit>(context).start(
                    //         songs: testingSongs,
                    //         currentSongIndex: 0,
                    //       );
                    //     },
                    //     child: const Text('Test Button'),
                    //   ),
                    if (allSongs.isNotEmpty)
                      ...allSongs.map((e) {
                        return Container(
                          color: Colors.transparent,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (e.songs.isNotEmpty)
                                TitleTile(
                                  title: e.artistName,
                                  showViewAll: false,
                                  onPressViewAll: () {},
                                  pastorImage: e.artistImage,
                                ),
                              if (e.songs.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 12,
                                    left: 5,
                                    right: 5,
                                  ),
                                  child: songCard(e.songs),
                                ),
                            ],
                          ),
                        );
                      })
                    else
                      const HomeShimmerEffect(),
                    // TitleTile(
                    //   title: 'Most played',
                    //   onPressViewAll: () {},
                    // ),
                    // mostPlayedSongs(),
                    const CopyRightText(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget appBar(AppState appState) {
    return ListTile(
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: AppStrings.appName,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'RubikGlitch-Regular',
                // letterSpacing: 0,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
            ),
            TextSpan(
              text: '  with Songs',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontFamily: 'Memphis-Light',
              ),
            ),
          ],
        ),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Image.asset(
          AppImages.appWhiteIcon,
          width: 25,
          height: 20,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget commonWidget({bool serverFailed = false}) {
    return const Column(
      children: [
        BannerCard(),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }

  Widget errorMessage() {
    return Container(
      width: width,
      decoration: const BoxDecoration(color: Colors.blue),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "**Service Update: Servers Currently Unavailable**\n",
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          "We apologize for the inconvenience, but our servers are currently down for maintenance. Please try accessing the app again later. Thank you for your understanding.",
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getToken() async {
    final jwtToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    log('$jwtToken', name: 'jwtToken');
  }

  Widget songCard(List<Song> songs) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: songs
            .map(
              (e) => Bounce(
                duration: const Duration(milliseconds: 50),
                onPressed: () async {
                  log(e.videoUrl, name: 'tapped video url');
                  final selectedSongIndex = songs.indexOf(e);
                  musicScreenNavigation(context, songData: e, songs: songs);
                  await BlocProvider.of<VideoPlayerCubit>(context)
                      .setToInitialState();
                  await BlocProvider.of<VideoPlayerCubit>(context).startPlayer(
                    songData: e,
                    songs: songs,
                    selectedSongIndex: selectedSongIndex,
                  );
                },
                child: SongCard(
                  image: e.artUri,
                  title: e.title,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> showMusicScreen({
    required Song songData,
    required List<Song> songs,
  }) async {
    await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      // showDragHandle: true,
      backgroundColor: AppColors.black,
      barrierColor: AppColors.black.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (ctx) {
        return SizedBox(
          width: width,
          height: height * 0.9,
          child: VideoPlayerScreen(
            songData: songData,
            songs: songs,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    lottieController.dispose();
    super.dispose();
  }
}

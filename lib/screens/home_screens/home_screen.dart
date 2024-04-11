// ignore_for_file: strict_raw_type, avoid_dynamic_calls

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/all_songs_cubit/all_songs_cubit.dart';
import 'package:glorify_god/components/banner_card.dart';
import 'package:glorify_god/components/home_components/copy_right_text.dart';
import 'package:glorify_god/components/home_components/home_loading_shimmer_effect.dart';
import 'package:glorify_god/components/home_components/users_choice_component.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/song_card_component.dart';
import 'package:glorify_god/components/title_tile_component.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart' as app;
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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
  Box? box;
  app.AppState appState = app.AppState();
  GlobalVariables globalVariables = GlobalVariables();

  PackageInfo? packageInfo;

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  // bool connectionError = false;
  List<int> showShimmers = [1, 2, 3, 4];

  bool showUpdateBanner = false;

  @override
  void initState() {
    box = Hive.box<dynamic>(HiveKeys.openBox);
    appState = context.read<app.AppState>();
    globalVariables = context.read<GlobalVariables>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      packageInformation();
      Future.delayed(const Duration(seconds: 1), () async {
        final dynamic getStoreSelectedArtistIds =
            await box!.get(HiveKeys.storeSelectedArtistIds);
        if (getStoreSelectedArtistIds == null) {
          artistsOrderOptionsSheet(context: context);
        }
      });
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
              log('$state', name: 'all songs widget state');

              if (state is AllSongsHasError) {
                return ScrollConfiguration(
                  behavior: const ScrollBehavior(
                    androidOverscrollIndicator:
                        AndroidOverscrollIndicator.stretch,
                  ),
                  child: ListView(
                    children: [
                      errorMessage(),
                      commonWidget(),
                      const HomeShimmerEffect(),
                    ],
                  ),
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
              log('$allSongs', name: 'all songs');

              return ScrollConfiguration(
                behavior: const ScrollBehavior(
                  androidOverscrollIndicator:
                      AndroidOverscrollIndicator.stretch,
                ),
                child: SingleChildScrollView(
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
                      //     onPressed: () async {
                      //       Navigator.push(
                      //         context,
                      //         CupertinoPageRoute(
                      //           builder: (_) => const YoutubePlayerWidget(),
                      //         ),
                      //       );
                      //     },
                      //     child: const Text('Test Button'),
                      //   ),
                      if (allSongs.isNotEmpty)
                        ...allSongs.map((e) {
                          return Container(
                            color: Colors.transparent,
                            margin: const EdgeInsets.only(bottom: 10),
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
                        }),
                      const CopyRightText(),
                    ],
                  ),
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
      leading: SizedBox(
        width: 160,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.appWhiteIcon,
              width: 30,
              height: 25,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    text: AppStrings.appName,
                    styles: TextStyle(
                      fontSize: 16,
                      fontFamily: 'RubikGlitch-Regular',
                      // letterSpacing: 0,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                    ),
                  ),
                  AppText(
                    text: AppStrings.withSongs,
                    styles: TextStyle(
                      fontSize: 10,
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Memphis-Light',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      trailing: Bounce(
        duration: const Duration(milliseconds: 50),
        onPressed: () {
          artistsOrderOptionsSheet(context: context);
        },
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            // color: Colors.red,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: AppColors.dullWhite,
              width: 1.3,
            ),
          ),
          child: Center(
            child: AppText(
              text: AppStrings.ca,
              styles: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget commonWidget({bool serverFailed = false}) {
    return const Column(
      children: [
        BannerCard(),
        SizedBox(
          height: 20,
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
    return ScrollConfiguration(
      behavior: const ScrollBehavior(
        androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: songs
              .map(
                (e) => Bounce(
                  duration: const Duration(milliseconds: 50),
                  onPressed: () async {
                    final initialId = songs.indexOf(e);
                    log('${e.songId} , $initialId', name: 'on tap songId');
                    if (appState.audioPlayer.playing) {
                      await appState.audioPlayer.pause();
                    }

                    moveToMusicScreen(context, initialId);

                    await startAudio(
                      appState: appState,
                      audioSource: songs,
                      initialId: initialId,
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
      ),
    );
  }
}

Future startAudio({
  required AppState appState,
  required List<Song> audioSource,
  required int initialId,
}) async {
  log('$initialId', name: 'The initial index');
  final playList = ConcatenatingAudioSource(
    children: [
      //<--
      // Here is to set the audio source that the list of songs to be read
      // first.
      // Set's the mediaItem for starting the audio
      // -->/
      ...audioSource.map((e) {
        final audioSource = AudioSource.uri(
          Uri.parse(e.videoUrl),
          tag: MediaItem(
            id: e.songId.toString(),
            title: e.title,
            artist: e.artist,
            artUri: Uri.parse(e.artUri),
            extras: {
              'ytTitle': e.ytTitle,
              'ytImage': e.ytImage,
              'ytUrl': e.ytUrl,
            },
          ),
        );
        return audioSource;
      }),
    ],
  );
  await appState.audioPlayer.setLoopMode(LoopMode.all);
  //<-- Starting the audio player
  // 1. set the list of songs that should play one after one in a loop
  // 2. initialIndex is for in the above list from which position
  // the song is actually starting
  // -->/
  await appState.audioPlayer.setAudioSource(
    playList,
    // This initial id is on first tap of song in the list of songs
    // it will start playing the particular song and then it start loop
    // for next song
    initialIndex:
        initialId, // <-- 1. If enabled in ios simulator it is not working
    // (No particular reason found) -->
  );

  // Listen for changes in the currently playing index
  appState.audioPlayer.currentIndexStream.listen((index) async {
    if (index != null && index < audioSource.length) {
      //<-- When audio starts the individual song data will be set global usage -->/
      appState.songData = appState
          .emptySongData; //<-- Clear the data before setting new data -->/
      appState.songData = audioSource[index];
      //<-- -->/

      final currentSongId = audioSource[index].songId;

      final res =
          await appState.checkFavourites(songId: audioSource[index].songId);
      appState.isSongFavourite = res;
      log(
        '$currentSongId - $res - ${appState.isSongFavourite}',
        name: 'The song changed',
      );
      // Perform your API call for the current song here using currentSongId
      // ...
    }
  });

  await appState.audioPlayer.play();
}

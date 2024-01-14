// ignore_for_file: strict_raw_type, avoid_dynamic_calls

import 'dart:developer';

import 'package:glorify_god/components/ads_card.dart';
import 'package:glorify_god/components/banner_card.dart';
import 'package:glorify_god/components/home_components/home_loading_shimmer_effect.dart';
import 'package:glorify_god/components/song_card_component.dart';
import 'package:glorify_god/components/title_tile_component.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart' as app;
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  app.AppState appState = app.AppState();

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  bool connectionError = false;
  List<int> showShimmers = [1, 2, 3, 4];
  late AnimationController lottieController;

  @override
  void initState() {
    lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    lottieController.repeat();
    appState = context.read<app.AppState>();
    super.initState();
    getAllSongs();
  }

  Future getAllSongs() async {
    try {
      await appState.getAllArtistsWithSongs();
    } catch (er) {
      log('$er', name: 'The home screen error');
      if (er.toString().contains('Null check operator used on a null value')) {
        setState(() {
          connectionError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<app.AppState>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(remoteConfigData.showUpdateBanner ? 160 : 60),
        child: SafeArea(
          child: Column(
            children: [
              if (remoteConfigData.showUpdateBanner)
                ListTile(
                  tileColor: Colors.blue,
                  title: Text(
                    "Exciting news! A new version of our app is now available. Elevate your experience by updating through the Play/App Store today!",
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.close,
                        size: 22,
                        color: AppColors.white,
                      )),
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
          child: SingleChildScrollView(
            physics: appState.getArtistsWithSongsList.isNotEmpty
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (connectionError)
                  Container(
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
                  ),

                // if (kDebugMode)
                //   CupertinoButton(
                //     onPressed: () async {
                //       // Fluttertoast.showToast(
                //       //     msg: 'something went wrong on logIn');
                //       toastMessage(message: 'something went wrong on logIn');
                //     },
                //     child: const AppText(
                //       text: 'Test',
                //       styles: TextStyle(
                //         fontSize: 24,
                //       ),
                //     ),
                //   ),
                const BannerCard(),
                const AdsCard(),
                const SizedBox(
                  height: 30,
                ),
                if (appState.getArtistsWithSongsList.isNotEmpty)
                  ...appState.getArtistsWithSongsList.map((e) {
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
                          if (e.songs.isNotEmpty) songCard(e.songs),
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
                const AdsCard(),
              ],
            ),
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
                // fontStyle: FontStyle.italic,
                // foreground: Paint()
                //   ..shader = LinearGradient(
                //     colors: [
                //       AppColors.redAccent,
                //       AppColors.blueAccent,
                //       // AppColors.purple,
                //     ],
                //     begin: Alignment.bottomLeft,
                //     end: Alignment.topRight,
                //   ).createShader(
                //     const Rect.fromLTWH(10, 30, 8, 18),
                //   ),
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

  Future getToken() async {
    final jwtToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    log('$jwtToken', name: 'jwtToken');
  }

  Widget songCard(List<Song> songs) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(right: 20),
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
    );
  }

  @override
  void dispose() {
    lottieController.dispose();
    super.dispose();
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
        log(
            '${e.songUrl}\n'
            '${e.songId}\n'
            '${e.title}\n'
            '${e.artist}\n'
            '${e.artUri}\n',
            name: 'On start audios the e');
        final audioSource = AudioSource.uri(
          Uri.parse(e.songUrl),
          tag: MediaItem(
              id: e.songId.toString(),
              title: e.title,
              artist: e.artist,
              artUri: Uri.parse(e.artUri),
              extras: {
                'ytTitle': e.ytTitle,
                'ytImage': e.ytImage,
                'ytUrl': e.ytUrl,
              }),
        );
        log('${audioSource.headers}', name: 'The audio source loaded');
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
  // <-- 2. From point 1 tried this point 2 and same happened
  // If enabled in ios simulator it is not working
  //     // (No particular reason found) -->/
  // await appState.audioPlayer.seek(Duration.zero, index: initialId,);

  // Listen for changes in the currently playing index
  appState.audioPlayer.currentIndexStream.listen((index) async {
    if (index != null && index < audioSource.length) {
      final currentSongId = audioSource[index].songId;

      final res =
          await appState.checkFavourites(songId: audioSource[index].songId);
      appState.isSongFavourite = res;
      log('$currentSongId - $res - ${appState.isSongFavourite}',
          name: 'The song changed');
      // Perform your API call for the current song here using currentSongId
      // ...
    }
  });

  await appState.audioPlayer.play();
}

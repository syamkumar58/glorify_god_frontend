// ignore_for_file: strict_raw_type, avoid_dynamic_calls

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glorify_god/components/ads_card.dart';
import 'package:glorify_god/components/banner_card.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/song_card_component.dart';
import 'package:glorify_god/components/title_tile_component.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart' as app;
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  app.AppState appState = app.AppState();

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  @override
  void initState() {
    appState = context.read<app.AppState>();
    super.initState();
    getAllSongs();
  }

  Future getAllSongs() async {
    await appState.getAllArtistsWithSongs();
    for (final x in appState.getArtistsWithSongsList) {
      log(x.artistName, name: 'appState.getArtistsWithSongsList');

      for (final song in x.songs) {
        log(
            'Song Details:'
            '\n  Song ID: ${song.songId}'
            '\n  Title: ${song.title}'
            '\n  Artist: ${song.artist}'
            '\n  Art URI: ${song.artUri}'
            '\n  Song URL: ${song.songUrl}',
            name: 'appState.getArtistsWithSongsList');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<app.AppState>(context);
    return Scaffold(
      appBar: appBar(appState),
      body: SizedBox(
        width: width,
        height: height,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kDebugMode)
                  CupertinoButton(
                    onPressed: () async {
                      Fluttertoast.showToast(msg: 'something went wrong on logIn');
                      // toastMessage(message: 'something went wrong on logIn');
                    },
                    child: const AppText(
                      text: 'Test',
                      styles: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                const BannerCard(),
                const AdsCard(),
                ...appState.getArtistsWithSongsList.map((e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (e.songs.isNotEmpty)
                        TitleTile(
                          title: e.artistName,
                          showViewAll: false,
                          onPressViewAll: () {},
                        ),
                      if (e.songs.isNotEmpty) songCard(e.songs),
                    ],
                  );
                }),
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

  PreferredSizeWidget appBar(AppState appState) {
    return AppBar(
      backgroundColor: Colors.grey.shade900,
      centerTitle: false,
      elevation: 2,
      automaticallyImplyLeading: false,
      title: const AppText(
        text: AppStrings.appName,
        styles: TextStyle(
          fontSize: 26,
          fontFamily: 'AppTitle',
          letterSpacing: 4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontStyle: FontStyle.italic,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 22),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // GoRouter.of(context).push('/profileScreen');
              GoRouter.of(context).push('/searchScreen');
            },
            child: const Icon(
              Icons.search,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      ],
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
                  if (appState.audioPlayer.playing) {
                    await appState.audioPlayer.pause();
                  }
                  await startAudio(
                    appState: appState,
                    audioSource: songs,
                    //<-- This condition is because
                    // For ios it is taking by the index value 0 and
                    // Android is working from 1 also -->/
                    initialId: e.songId - 1,
                  )
                      //     .then((value) {}).catchError((dynamic onError){
                      //   log('$onError',name:'On start audio error what is it');
                      // })
                      ;
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
          ),
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
  await appState.audioPlayer.play();
}

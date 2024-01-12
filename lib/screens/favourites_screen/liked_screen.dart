import 'dart:developer';

import 'package:glorify_god/components/ads_card.dart';
import 'package:glorify_god/components/banner_card.dart';
import 'package:glorify_god/components/custom_app_bar.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/songs_tile.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/home_screens/home_screen.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LikedScreen extends StatefulWidget {
  const LikedScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LikedScreenState createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikedScreen> {
  AppState appState = AppState();
  bool isLoading = true;
  List<Song> collectedSongs = [];

  Future<void> getLikedSongs() async {
    await appState.likedSongs().whenComplete(() {
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getLikedSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: customAppbar('LIKED'),
      body: Column(
        children: [
          const BannerCard(),
          if (!isLoading && appState.likedSongsList.isNotEmpty)
            playAllButton()
          else if (!isLoading && appState.likedSongsList.isEmpty)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 50),
                  child: Center(
                    child: AppText(
                      styles: GoogleFonts.manrope(
                        fontSize: 18,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      text: AppStrings.noFavourites,
                    ),
                  ),
                ),
                const AdsCard(),
              ],
            ),
          Expanded(child: songs()),
        ],
      ),
    );
  }

  Widget playAllButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Container(
        width: 200,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.dullBlack.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await onPlay(0);
          },
          child: AppText(
            text: 'Play all',
            styles: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget songs() {
    return RefreshIndicator(
      color: Colors.transparent,
      backgroundColor: Colors.transparent,
      onRefresh: () async {
        await getLikedSongs();
      },
      child: CustomScrollView(
        slivers: [
          if (isLoading)
            SliverAppBar(
              backgroundColor: Colors.grey.withOpacity(0.1),
              centerTitle: true,
              title: const CupertinoActivityIndicator(),
              leading: const SizedBox(),
            ),
          if (!isLoading) songsWidget(),
        ],
      ),
    );
  }

  Widget songsWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: appState.likedSongsList.length,
        (context, index) {
          final songDetails = appState.likedSongsList[index];
          return Bounce(
            duration: const Duration(milliseconds: 200),
            onPressed: () async {
              final initialId = appState.likedSongsList
                  .indexOf(appState.likedSongsList[index]);
              log('$initialId', name: 'initial id in liked');
              await onPlay(initialId);
            },
            child: SongsLikesTile(
              index: index + 1,
              songTitle: songDetails.title,
              artistName: songDetails.artist,
              artUri: songDetails.artUri,
            ),
          );
        },
      ),
    );
  }

  Future<void> onPlay(int initialId) async {
    for (final song in appState.likedSongsList) {
      final eachSong = Song(
        songId: song.songId,
        songUrl: song.songUrl,
        title: song.title,
        artist: song.artist,
        artUri: song.artUri,
        lyricist: song.lyricist,
        createdAt: song.createdAt,
        ytUrl: song.ytUrl,
        ytTitle: song.ytTitle,
        ytImage: song.ytImage,
      );
      collectedSongs.add(eachSong);
    }
    await startAudio(
      appState: appState,
      audioSource: collectedSongs,
      initialId: initialId,
    );
  }
}

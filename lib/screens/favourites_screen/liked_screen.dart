
import 'package:glorify_god/components/banner_card.dart';
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
  bool isLoading = false;
  List<Song> collectedSongs = [];

  Future<void> getLikedSongs() async {
    setState(() {
      isLoading = true;
    });
    await appState.likedSongs();
    Future.delayed(const Duration(seconds: 5), () async {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
      appBar: AppBar(
        centerTitle: true,
        leading: const SizedBox(),
        title: AppText(
          text: AppStrings.favoritesTitle,
          styles: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          const BannerCard(),
          if (!isLoading) playAllButton(),
          Expanded(child: songs()),
        ],
      ),
    );
  }

  Widget playAllButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
            await onPlay(appState.likedSongsList[0].songId);
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
              await onPlay(songDetails.songId);
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

  Future<void> onPlay(int songId) async {
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
      initialId: songId - 1,
    );
  }
}

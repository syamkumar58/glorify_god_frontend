import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/profile_cubit/liked_cubit/liked_cubit.dart';
import 'package:glorify_god/components/banner_card.dart';
import 'package:glorify_god/components/custom_app_bar.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/songs_tile.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/models/get_favourites_model.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/home_screens/home_screen.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/utils/asset_images.dart';
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

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  Future<void> getLikedSongs() async {
    await BlocProvider.of<LikedCubit>(context)
        .likedSongs(
      appState.userData.userId,
    )
        .whenComplete(() {
      Future.delayed(const Duration(seconds: 1), () async {
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
    appState = context.read<AppState>();
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
      body: BlocBuilder<LikedCubit, LikedState>(
        builder: (context, state) {
          if (state is! LikedLoaded) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          final likedSongsList = state.likedSongs;

          return Column(
            children: [
              // const AdsCard(),
              const BannerCard(),
              if (!isLoading && likedSongsList.isNotEmpty)
                playAllButton(likedSongsList)
              else if (!isLoading && likedSongsList.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: height * 0.2, bottom: 50),
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          AppImages.appWhiteIcon,
                          width: 45,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          styles: GoogleFonts.manrope(
                            fontSize: 18,
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          text: AppStrings.noFavourites,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          text: AppStrings.youCanAddFavourites,
                          maxLines: 5,
                          styles: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(child: songs(likedSongsList)),
            ],
          );
        },
      ),
    );
  }

  Widget playAllButton(List<GetFavouritesModel> likedSongsList) {
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
            await onPlay(
              likedSongsList,
              likedSongsList[0],
              0,
              likedSongsList[0].songId,
            );
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

  Widget songs(List<GetFavouritesModel> likedSongsList) {
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
          if (!isLoading) songsWidget(likedSongsList),
        ],
      ),
    );
  }

  Widget songsWidget(List<GetFavouritesModel> likedSongsList) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: likedSongsList.length,
        (context, index) {
          final songDetails = likedSongsList[index];
          return Bounce(
            duration: const Duration(milliseconds: 200),
            onPressed: () async {
              final initialId = likedSongsList.indexOf(likedSongsList[index]);
              log('$initialId', name: 'initial id in liked');
              await onPlay(
                likedSongsList,
                songDetails,
                initialId,
                likedSongsList[index].songId,
              );
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

  Future<void> onPlay(
    List<GetFavouritesModel> likedSongsList,
    GetFavouritesModel songDetails,
    int initialId,
    int songId,
  ) async {
    collectedSongs.clear();
    for (final song in likedSongsList) {
      final eachSong = Song(
        songId: song.songId,
        songUrl: song.songUrl,
        videoUrl: song.videoUrl,
        title: song.title,
        artist: song.artist,
        artUri: song.artUri,
        lyricist: song.lyricist,
        createdAt: song.createdAt,
        ytUrl: song.ytUrl,
        ytTitle: song.ytTitle,
        ytImage: song.ytImage,
        artistUID: song.artistUID,
        credits: song.credits,
        otherData: song.otherData,
      );
      collectedSongs.add(eachSong);
    }

    moveToMusicScreen(context, songId);

    await startAudio(
      appState: appState,
      audioSource: collectedSongs,
      initialId: initialId,
    );
  }
}

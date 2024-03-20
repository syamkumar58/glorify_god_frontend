import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/profile_bloc/liked_cubit/liked_cubit.dart';
import 'package:glorify_god/bloc/profile_bloc/songs_info_cubit/songs_data_info_cubit.dart';
import 'package:glorify_god/bloc/youtube_player_cubit/youtube_player_cubit.dart';
import 'package:glorify_god/components/custom_nav_bar_ad.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeVideoPlayerScreen extends StatefulWidget {
  const YoutubeVideoPlayerScreen({
    super.key,
    required this.songs,
    required this.songData,
    required this.ctx,
  });

  final List<Song> songs;

  final Song songData;

  final BuildContext ctx;

  @override
  State<YoutubeVideoPlayerScreen> createState() =>
      _YoutubeVideoPlayerScreenState();
}

class _YoutubeVideoPlayerScreenState extends State<YoutubeVideoPlayerScreen>
    with TickerProviderStateMixin {
  AppState appState = AppState();
  bool landScopeMode = false;

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  bool showMoreDetails = false;

  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    animationController.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(widget.ctx);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppColors.white,
          ),
        ),
      ),
      body: BlocBuilder<YoutubePlayerCubit, YoutubePlayerState>(
        builder: (context, state) {
          log('$state', name: 'The state');

          if (state is! YoutubePlayerInitialised) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }
          final data = state;
          final ytController = state.youtubePlayerController;
          final songData = state.songData;

          log(
            '${songData.title} - ${songData.artist}',
            name: 'From widget youtube videos',
          );

          return YoutubePlayer(
            controller: ytController,
            // width: width,
            aspectRatio: 16 / 9,
          );
        },
      ),
      bottomNavigationBar:
          MediaQuery.of(context).orientation == Orientation.portrait
              ? const CustomNavBarAd()
              : const SizedBox(),
    );
  }

  Widget showMoreDetailsWidget(YoutubePlayerInitialised data) {
    return Container(
      width: width,
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 12, right: 12),
      color: AppColors.dullBlack.withOpacity(0.3),
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: const AppText(
              text: AppStrings.songName,
              textAlign: TextAlign.left,
              styles: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            title: AppText(
              text: data.songData.title,
              textAlign: TextAlign.left,
              styles: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          ListTile(
            dense: true,
            leading: const AppText(
              text: AppStrings.singer,
              textAlign: TextAlign.left,
              styles: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            title: AppText(
              text: data.songData.artist,
              textAlign: TextAlign.left,
              styles: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (data.songData.lyricist.isNotEmpty)
            ListTile(
              dense: true,
              leading: AppText(
                text: data.songData.lyricist.contains('Credits')
                    ? data.songData.lyricist
                    : AppStrings.lyricist,
                textAlign: TextAlign.left,
                styles: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              title: AppText(
                text: data.songData.lyricist.contains('Credits')
                    ? ''
                    : data.songData.lyricist,
                textAlign: TextAlign.left,
                styles: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          // if (data.songData.credits.isNotEmpty)
          //   ListTile(
          //     dense: true,
          //     leading:  AppText(
          //       text: AppStrings.lyricist,
          //       textAlign: TextAlign.left,
          //       styles: GoogleFonts.manrope(
          //         fontSize: 16,
          //         fontWeight: FontWeight.w400,
          //       ),
          //     ),
          //     title: AppText(
          //       text: data.songData.lyricist,
          //       textAlign: TextAlign.left,
          //       styles: GoogleFonts.manrope(
          //         fontSize: 16,
          //         fontWeight: FontWeight.w400,
          //       ),
          //     ),
          //   ),
          if (data.songData.ytUrl.isNotEmpty)
            ListTile(
              dense: true,
              title: AppText(
                text: data.songData.ytUrl,
                textAlign: TextAlign.left,
                styles: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.blue,
                ),
              ),
              onTap: () async {
                if (await canLaunchUrlString(data.songData.ytUrl)) {
                  await launchUrlString(data.songData.ytUrl);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget otherSongs({required int playingSongId}) {
    return Column(
      children: [
        ...widget.songs.map((e) {
          return eachTile(songData: e, playingSongId: playingSongId);
        }).toList(),
      ],
    );
  }

  Widget eachTile({required Song songData, required int playingSongId}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              leading: Container(
                height: 80,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.white,
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      songData.artUri,
                    ),
                  ),
                ),
                child: Center(
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: AppColors.dullBlack,
                    ),
                    child: const Icon(
                      Icons.play_arrow_outlined,
                    ),
                  ),
                ),
              ),
              title: AppText(
                text: songData.title,
                textAlign: TextAlign.left,
                styles: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: AppText(
                text: songData.artist,
                textAlign: TextAlign.left,
                styles: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: playingSongId == songData.songId
                  ? SizedBox(
                      height: 30,
                      width: 30,
                      child: Lottie.asset(
                        LottieAnimations.musicAnimation,
                        controller: animationController,
                      ),
                    )
                  : const SizedBox(),
              onTap: () async {
                final selectedSongIndex = widget.songs.indexOf(songData);
                BlocProvider.of<YoutubePlayerCubit>(context)
                    .initialiseThePlayer();
                BlocProvider.of<YoutubePlayerCubit>(context).selectedOtherSong(
                  videoId: songData.ytUrl,
                  songData: songData,
                  songs: widget.songs,
                  currentPlayingIndex: selectedSongIndex,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> onFav() async {
    var favourite = false;
    if (appState.isSongFavourite) {
      favourite = await appState.unFavourite(
        songId: widget.songData.songId,
      );
    } else {
      favourite = await appState.addFavourite(
        songId: widget.songData.songId,
      );
    }
    return favourite;
  }

  Future likedSongs() async {
    await BlocProvider.of<LikedCubit>(context)
        .likedSongs(appState.userData.userId);
  }

  Future changeOrientation() async {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ],
      );
    } else {
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp],
      );
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

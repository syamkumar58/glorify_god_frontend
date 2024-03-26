import 'dart:async';
import 'dart:developer';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart' as pb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/bloc/profile_bloc/liked_cubit/liked_cubit.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/youtube_player_components/minimized_screen_overlay.dart';
import 'package:glorify_god/components/youtube_player_components/play_pause_components.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/youtube_player_handler.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FloatingYoutubePlayer extends StatefulWidget {
  const FloatingYoutubePlayer({
    super.key,
    required this.songs,
    required this.songData,
  });

  final List<Song> songs;

  final Song songData;

  @override
  State<FloatingYoutubePlayer> createState() => _FloatingYoutubePlayerState();
}

class _FloatingYoutubePlayerState extends State<FloatingYoutubePlayer>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  AppState appState = AppState();
  YoutubePlayerHandler youtubePlayerHandler = YoutubePlayerHandler();

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  bool showControls = true;

  bool showMoreDetails = false;

  Timer? _controlsTimer;

  void _startControlsTimer() {
    _controlsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          showControls = false;
        });
      }
    });
  }

  void _resetControlsTimer() {
    // Cancel the existing timer if any
    _controlsTimer?.cancel();

    // Start a new timer
    _startControlsTimer();
  }

  void _toggleControlsVisibility() {
    setState(() {
      showControls = !showControls;
    });

    _resetControlsTimer();
  }

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    animationController.repeat();
    super.initState();
    _startControlsTimer();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    youtubePlayerHandler = Provider.of<YoutubePlayerHandler>(context);
    return SafeArea(
      top: !youtubePlayerHandler.fullScreenEnabled,
      left: !youtubePlayerHandler.fullScreenEnabled,
      right: youtubePlayerHandler.fullScreenEnabled,
      bottom: youtubePlayerHandler.fullScreenEnabled,
      child: Padding(
        padding: EdgeInsets.only(
          right: youtubePlayerHandler.extendToFullScreen ? 0 : 0,
          top: youtubePlayerHandler.extendToFullScreen ? 0 : 60,
        ),
        child: Container(
          height:
              !youtubePlayerHandler.extendToFullScreen ? height * 0.14 : height,
          width: !youtubePlayerHandler.extendToFullScreen ? width * 0.5 : width,
          color: Colors.black,
          child: Center(
            child: Container(
              width: !youtubePlayerHandler.fullScreenEnabled
                  ? youtubePlayerHandler.extendToFullScreen
                      ? width
                      : width * 0.5
                  : width * 0.8,
              height: !youtubePlayerHandler.fullScreenEnabled
                  ? youtubePlayerHandler.extendToFullScreen
                      ? height
                      : height * 0.14
                  : height,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(
                  youtubePlayerHandler.extendToFullScreen ? 0 : 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: youtubePlayerHandler.fullScreenEnabled
                    ? MainAxisAlignment.center
                    : youtubePlayerHandler.extendToFullScreen
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                children: [
                  ClipRect(child: youtubePlayerWidget()),
                  if (youtubePlayerHandler.extendToFullScreen &&
                      !youtubePlayerHandler.fullScreenEnabled)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 200),
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            playingSongDetails(),
                            if (showMoreDetails) showMoreDetailsWidget(),
                            otherSongs(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget youtubePlayerWidget() {
    return youtubePlayerHandler.youtubePlayerController != null
        ? GestureDetector(
            onTap: _toggleControlsVisibility,
            // youtubePlayerHandler.extendToFullScreen
            //     ? _toggleControlsVisibility
            //     : null,
            onVerticalDragEnd: (dragDownDetails) {
              if (youtubePlayerHandler.extendToFullScreen) {
                youtubePlayerHandler.extendToFullScreen =
                    !youtubePlayerHandler.extendToFullScreen;
              }
            },
            child: YoutubePlayerBuilder(
              onEnterFullScreen: () {
                youtubePlayerHandler.fullScreenEnabled = true;
              },
              onExitFullScreen: () {
                youtubePlayerHandler.fullScreenEnabled = false;
              },
              player: YoutubePlayer(
                controller: youtubePlayerHandler.youtubePlayerController!,
                onEnded: (metaData) {
                  youtubePlayerHandler.skipToNext(
                    songs: youtubePlayerHandler.selectedSongsList,
                  );
                },
                // aspectRatio: 16 / 9,
              ),
              builder: (context, player) {
                log('${youtubePlayerHandler.youtubePlayerController!.value.playerState}',
                    name: 'The state here');
                final buffering = youtubePlayerHandler
                        .youtubePlayerController!.value.playerState ==
                    PlayerState.buffering;
                final unKnown = youtubePlayerHandler
                        .youtubePlayerController!.value.playerState ==
                    PlayerState.unknown;
                final unStarted = youtubePlayerHandler
                        .youtubePlayerController!.value.playerState ==
                    PlayerState.unStarted;
                return AspectRatio(
                  aspectRatio: 21 / 11,
                  child: Stack(
                    children: [
                      player,
                      bufferingWidget(
                        buffering: buffering,
                        unKnown: unKnown,
                        unStarted: unStarted,
                      ),
                      controlsWidget(
                        buffering: buffering,
                        unKnown: unKnown,
                      ),
                      Positioned(
                        top: 2,
                        right: 10,
                        child: closeOption(),
                      ),
                      if (youtubePlayerHandler.extendToFullScreen &&
                          !buffering &&
                          !unKnown &&
                          showControls)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 20,
                            left: 12,
                            right: 12,
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: durationsWithFullScreen(),
                          ),
                        ),
                      if (youtubePlayerHandler.extendToFullScreen &&
                          showControls)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: seekBar(),
                        ),
                    ],
                  ),
                );
              },
            ),
          )
        : const CircularProgressIndicator();
  }

  Widget bufferingWidget({
    bool buffering = false,
    bool unKnown = false,
    bool unStarted = false,
  }) {
    return buffering || unKnown || unStarted
        ? Center(
            child: CircularProgressIndicator(
              color: AppColors.white,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget controlsWidget({
    bool buffering = false,
    bool unKnown = false,
  }) {
    return youtubePlayerHandler.extendToFullScreen &&
            !buffering &&
            !unKnown &&
            showControls
        ? Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.5),
            ),
            child: Center(
              child: PlayPauseControls(
                youtubePlayerHandler: youtubePlayerHandler,
                songs: widget.songs,
              ),
            ),
          )
        : !youtubePlayerHandler.extendToFullScreen && showControls
            ? MinimizedScreenOverLay(
                youtubePlayerHandler: youtubePlayerHandler,
              )
            : const SizedBox();
  }

  Widget closeOption() {
    return youtubePlayerHandler.extendToFullScreen && showControls
        ? TextButton.icon(
            label: AppText(
              styles: GoogleFonts.manrope(
                color: AppColors.white,
              ),
              text: AppStrings.close,
            ),
            onPressed: () {
              youtubePlayerHandler.extendToFullScreen = false;
              youtubePlayerHandler.youtubePlayerController!.dispose();
              youtubePlayerHandler.youtubePlayerController = null;
            },
            icon: Icon(
              Icons.close,
              color: AppColors.white,
              size: 20,
            ),
          )
        : const SizedBox();
  }

  Widget durationsWithFullScreen() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppText(
          text:
              '${youtubePlayerHandler.youtubePlayerController!.value.position.inMinutes.toString().padLeft(2, '0')}:${(youtubePlayerHandler.youtubePlayerController!.value.position.inSeconds % 60).toString().padLeft(
                    2,
                    '0',
                  )}'
              ' / ${youtubePlayerHandler.youtubePlayerController!.metadata.duration.inMinutes.toString().padLeft(
                    2,
                    '0',
                  )}:${(youtubePlayerHandler.youtubePlayerController!.metadata.duration.inSeconds % 60).toString().padLeft(
                    2,
                    '0',
                  )}',
          styles: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 0),
          child: Bounce(
            duration: const Duration(milliseconds: 50),
            onPressed: () {
              log(
                '${MediaQuery.of(context).orientation == Orientation.portrait}',
                name: 'The orientation',
              );
              changeOrientation();
            },
            child: Icon(
              !youtubePlayerHandler.fullScreenEnabled
                  ? Icons.fullscreen
                  : Icons.fullscreen_exit,
              size: 22,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget seekBar() {
    return pb.ProgressBar(
      bufferedBarColor: AppColors.dullWhite,
      thumbCanPaintOutsideBar: false,
      progressBarColor: AppColors.redAccent,
      thumbColor: Colors.transparent,
      barCapShape: pb.BarCapShape.square,
      thumbRadius: 0,
      thumbGlowRadius: 0,
      buffered: Duration(
        seconds: youtubePlayerHandler
                .youtubePlayerController!.value.position.inSeconds +
            50,
      ),
      progress: Duration(
        seconds: youtubePlayerHandler
            .youtubePlayerController!.value.position.inSeconds,
      ),
      total: Duration(
        seconds: youtubePlayerHandler
            .youtubePlayerController!.metadata.duration.inSeconds,
      ),
      timeLabelTextStyle: const TextStyle(
        color: Colors.transparent,
        fontSize: 0,
      ),
      onSeek: (duration) {
        youtubePlayerHandler.youtubePlayerController!.seekTo(duration);
      },
    );
  }

  Widget playingSongDetails() {
    return ListTile(
      tileColor: Colors.blueGrey.withOpacity(0.1),
      // leading: CircleAvatar(
      //   backgroundColor: AppColors.dullBlack,
      //   backgroundImage:
      //       NetworkImage(youtubePlayerHandler.selectedSongData.artUri),
      // ),
      title: Text(
        youtubePlayerHandler.selectedSongData.title,
        textAlign: TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      subtitle: AppText(
        text: youtubePlayerHandler.selectedSongData.artist,
        textAlign: TextAlign.start,
        maxLines: 1,
        styles: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      trailing: Container(
        color: Colors.transparent,
        width: width * 0.3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              showMoreDetails
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 25,
              color: AppColors.dullWhite,
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final favourite = await onFav();
                setState(() {
                  appState.isSongFavourite = favourite;
                });
                await likedSongs();
              },
              icon: Icon(
                appState.isSongFavourite
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 21,
                color: appState.isSongFavourite
                    ? AppColors.redAccent
                    : AppColors.dullWhite,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        setState(() {
          showMoreDetails = !showMoreDetails;
        });
      },
    );
  }

  Widget showMoreDetailsWidget() {
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
              text: youtubePlayerHandler.selectedSongData.title,
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
              text: youtubePlayerHandler.selectedSongData.artist,
              textAlign: TextAlign.left,
              styles: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (youtubePlayerHandler.selectedSongData.lyricist.isNotEmpty)
            ListTile(
              dense: true,
              leading: AppText(
                text: youtubePlayerHandler.selectedSongData.lyricist
                        .contains('Credits')
                    ? youtubePlayerHandler.selectedSongData.lyricist
                    : AppStrings.lyricist,
                textAlign: TextAlign.left,
                styles: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              title: AppText(
                text: youtubePlayerHandler.selectedSongData.lyricist
                        .contains('Credits')
                    ? ''
                    : 'https://www.youtube.com/watch?v=${youtubePlayerHandler.selectedSongData.lyricist}',
                textAlign: TextAlign.left,
                styles: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          // if (youtubePlayerHandler.selectedSongData.credits.isNotEmpty)
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
          //       text: youtubePlayerHandler.selectedSongData.lyricist,
          //       textAlign: TextAlign.left,
          //       styles: GoogleFonts.manrope(
          //         fontSize: 16,
          //         fontWeight: FontWeight.w400,
          //       ),
          //     ),
          //   ),
          if (youtubePlayerHandler.selectedSongData.ytUrl.isNotEmpty)
            ListTile(
              dense: true,
              title: AppText(
                text: youtubePlayerHandler.selectedSongData.ytUrl,
                textAlign: TextAlign.left,
                styles: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.blue,
                ),
              ),
              onTap: () async {
                if (await canLaunchUrlString(
                  youtubePlayerHandler.selectedSongData.ytUrl,
                )) {
                  await launchUrlString(
                    youtubePlayerHandler.selectedSongData.ytUrl,
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Widget otherSongs() {
    return Column(
      children: [
        ...widget.songs.map((e) {
          return eachTile(songData: e);
        }).toList(),
      ],
    );
  }

  Widget eachTile({required Song songData}) {
    return Bounce(
      duration: const Duration(milliseconds: 50),
      onPressed: () async {
        //<-- Youtube video player direction -->/
        final currentSongIndex = widget.songs.indexOf(songData);

        // youtubePlayerHandler.extendToFullScreen = true;

        youtubePlayerHandler.startPlayer(
          songData: songData,
          songs: youtubePlayerHandler.selectedSongsList,
          currentSongIndex: currentSongIndex,
        );
      },
      child: Container(
        width: width * 0.95,
        margin: const EdgeInsets.only(top: 12),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              height: 98,
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // border: Border.all(
                //   width: 1,
                //   color: AppColors.white,
                // ),
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
            SizedBox(
              width: width * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: songData.title,
                    textAlign: TextAlign.left,
                    styles: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  AppText(
                    text: songData.artist,
                    textAlign: TextAlign.left,
                    styles: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dullWhite,
                    ),
                  ),
                ],
              ),
            ),
            // playingSongId == songData.songId
            //     ? Container(
            //         color: Colors.green,
            //         height: 30,
            //         width: 30,
            //         child: Lottie.asset(
            //           LottieAnimations.musicAnimation,
            //           controller: animationController,
            //         ),
            //       )
            //     : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future changeOrientation() async {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      youtubePlayerHandler.fullScreenEnabled = false;
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ],
      );
    } else {
      youtubePlayerHandler.fullScreenEnabled = true;
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp],
      );
    }
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

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

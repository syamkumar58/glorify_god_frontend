import 'dart:async';
import 'dart:developer';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart' as pb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/bloc/profile_cubit/liked_cubit/liked_cubit.dart';
import 'package:glorify_god/bloc/profile_cubit/songs_info_cubit/songs_data_info_cubit.dart';
import 'package:glorify_god/components/close_button.dart';
import 'package:glorify_god/components/minimize_option.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/youtube_player_components/minimized_screen_overlay.dart';
import 'package:glorify_god/components/youtube_player_components/play_pause_components.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/youtube_player_handler.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
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

  bool favLoaded = false;

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
    log('tapped tapped');
    setState(() {
      showControls = !showControls;
    });

    _resetControlsTimer();
  }

  @override
  void initState() {
    appState = context.read<AppState>();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    animationController.repeat();
    super.initState();
    // _startControlsTimer();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    youtubePlayerHandler = Provider.of<YoutubePlayerHandler>(context);
    return WillPopScope(
      onWillPop: () async {
        final mediaQueryData = MediaQuery.of(context);
        await onDeviceBack();
        if (mediaQueryData.orientation == Orientation.portrait) {
          return true;
        } else {
          return false;
        }
      },
      child: SafeArea(
        top: MediaQuery.of(context).orientation == Orientation.portrait,
        left: MediaQuery.of(context).orientation == Orientation.portrait,
        right: MediaQuery.of(context).orientation != Orientation.portrait,
        bottom: MediaQuery.of(context).orientation != Orientation.portrait,
        child: youtubePlayerWidget(),
      ),
    );
  }

  Widget youtubePlayerWidget() {
    if (youtubePlayerHandler.youtubePlayerController != null) {
      return GestureDetector(
        onTap: _toggleControlsVisibility,
        onVerticalDragEnd:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? (dragDownDetails) {
                    if (youtubePlayerHandler.extendToFullScreen) {
                      youtubePlayerHandler.extendToFullScreen =
                          !youtubePlayerHandler.extendToFullScreen;
                    }
                  }
                : null,
        child: YoutubePlayerBuilder(
          onEnterFullScreen: () {
            // youtubePlayerHandler.fullScreenEnabled = true;
            SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.manual,
              overlays: [],
            );
          },
          onExitFullScreen: () {
            // youtubePlayerHandler.fullScreenEnabled = false;
            SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.manual,
              overlays: SystemUiOverlay.values,
            );
          },
          player: YoutubePlayer(
            controller: youtubePlayerHandler.youtubePlayerController!,
            onEnded: (metaData) {
              SongsDataInfoCubit songsDataInfoCubit = SongsDataInfoCubit();
              youtubePlayerHandler.skipToNext(
                songs: youtubePlayerHandler.selectedSongsList,
                appState: appState,
              );
              songsDataInfoCubit.addSongStreamData(
                artistId: youtubePlayerHandler.selectedSongData.artistUID,
                startDate: DateTime(DateTime.now().year, 1, 1),
                endDate: DateTime.now(),
              );
            },
          ),
          builder: (context, player) {
            final buffering = youtubePlayerHandler
                    .youtubePlayerController!.value.playerState ==
                PlayerState.buffering;
            final unKnown = youtubePlayerHandler
                    .youtubePlayerController!.value.playerState ==
                PlayerState.unknown;
            final unStarted = youtubePlayerHandler
                    .youtubePlayerController!.value.playerState ==
                PlayerState.unStarted;
            return Container(
              width:
                  youtubePlayerHandler.extendToFullScreen ? width : width * 0.5,
              height: youtubePlayerHandler.extendToFullScreen
                  ? height
                  : height * 0.14,
              color: AppColors.black,
              child: MediaQuery.of(context).orientation == Orientation.portrait
                  ? Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
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
                            ],
                          ),
                        ),
                        if (youtubePlayerHandler.extendToFullScreen &&
                            MediaQuery.of(context).orientation ==
                                Orientation.portrait)
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
                    )
                  : AspectRatio(
                      aspectRatio: 16 / 9,
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
                        ],
                      ),
                    ),
            );
          },
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
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
            height: width * (9 / 16),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //<-- Top left minimize the player option -->/
                      if (youtubePlayerHandler.extendToFullScreen &&
                          showControls &&
                          MediaQuery.of(context).orientation ==
                              Orientation.portrait)
                        MinimizeOption(
                          youtubePlayerHandler: youtubePlayerHandler,
                        ),
                      //<-- Top right close the player option -->/
                      closeOption(),
                    ],
                  ),
                ),
                //<-- Play pause, next and previous buttons  -->/
                PlayPauseControls(
                  youtubePlayerHandler: youtubePlayerHandler,
                  appState: appState,
                  songs: widget.songs,
                ),
                //<-- Player duration with seek bar -->/
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 0
                        : height * 0.08,
                  ),
                  child: Column(
                    children: [
                      //<-- player duration text -->/
                      if (youtubePlayerHandler.extendToFullScreen &&
                          !buffering &&
                          !unKnown &&
                          showControls)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 8,
                            left: 12,
                            right: 12,
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: durationsWithFullScreen(),
                          ),
                        ),
                      //<-- Seek Bar -->/
                      if (youtubePlayerHandler.extendToFullScreen &&
                          showControls &&
                          !buffering &&
                          !unKnown)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: seekBar(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : !youtubePlayerHandler.extendToFullScreen && showControls
            ? Align(
                alignment: Alignment.centerRight,
                child: MinimizedScreenOverLay(
                  youtubePlayerHandler: youtubePlayerHandler,
                ),
              )
            : const SizedBox();
  }

  Widget closeOption() {
    return youtubePlayerHandler.extendToFullScreen &&
            MediaQuery.of(context).orientation == Orientation.portrait
        ? CloseOption(
            onPressed: () {
              youtubePlayerHandler.clearStoredData();
              youtubePlayerHandler.extendToFullScreen = false;
              if (youtubePlayerHandler.youtubePlayerController != null) {
                youtubePlayerHandler.youtubePlayerController!.dispose();
                youtubePlayerHandler.youtubePlayerController = null;
              }
            },
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
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? Icons.fullscreen
                  : Icons.fullscreen_exit,
              size: 28,
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
      thumbColor: AppColors.redAccent.withOpacity(0.5),
      barCapShape: pb.BarCapShape.square,
      thumbRadius: 8,
      thumbGlowRadius: 10,
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
            if (!favLoaded)
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
              )
            else
              const CupertinoActivityIndicator(),
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
                text: AppStrings.lyricist,
                textAlign: TextAlign.left,
                styles: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              title: AppText(
                text: youtubePlayerHandler.selectedSongData.lyricist,
                textAlign: TextAlign.left,
                styles: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          if (youtubePlayerHandler.selectedSongData.credits.isNotEmpty &&
              !youtubePlayerHandler.selectedSongData.credits.contains('null'))
            ListTile(
              dense: true,
              leading: AppText(
                text: AppStrings.credits,
                textAlign: TextAlign.left,
                styles: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              title: AppText(
                text: youtubePlayerHandler.selectedSongData.credits,
                textAlign: TextAlign.left,
                styles: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          if (youtubePlayerHandler.selectedSongData.otherData.isNotEmpty &&
              !youtubePlayerHandler.selectedSongData.otherData.contains('null'))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppText(
                text: youtubePlayerHandler.selectedSongData.otherData,
                maxLines: 2000,
                textAlign: TextAlign.left,
                styles: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white,
                ),
              ),
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
        if (youtubePlayerHandler.selectedSongData.songId != songData.songId) {
          //<-- Youtube video player direction -->/
          final currentSongIndex = widget.songs.indexOf(songData);

          // youtubePlayerHandler.extendToFullScreen = true;

          youtubePlayerHandler.startPlayer(
            songData: songData,
            songs: youtubePlayerHandler.selectedSongsList,
            currentSongIndex: currentSongIndex,
            appState: appState,
          );
        }
      },
      child: Container(
        width: width * 0.95,
        margin: const EdgeInsets.only(top: 13),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              height: 80,
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: CachedNetworkImageProvider(
                    songData.artUri,
                  ),
                ),
              ),
              child: Center(
                child: youtubePlayerHandler.selectedSongData.songId ==
                        songData.songId
                    ? Container(
                        height: 80,
                        width: 130,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              LottieAnimations.musicAnimation,
                              controller: animationController,
                              height: 30,
                              width: 80,
                              fit: BoxFit.fill,
                            ),
                          ],
                        ),
                      )
                    : Container(
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
                      fontSize: 16,
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
          ],
        ),
      ),
    );
  }

  Future onDeviceBack() async {
    if (MediaQuery.of(context).orientation != Orientation.portrait) {
      // youtubePlayerHandler.fullScreenEnabled = true;
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );
    }
  }

  Future changeOrientation() async {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      // youtubePlayerHandler.fullScreenEnabled = false;
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ],
      );
    } else {
      // youtubePlayerHandler.fullScreenEnabled = true;
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
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

import 'dart:async';
import 'dart:developer';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/bloc/profile_cubit/liked_cubit/liked_cubit.dart';
import 'package:glorify_god/bloc/video_player_cubit/video_player_cubit.dart';

import 'package:glorify_god/components/custom_nav_bar_ad.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart' as a;
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.songs,
    required this.songData,
  });

  final Song songData;

  final List<Song> songs;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  a.AppState appState = a.AppState();

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  bool showControls = true;
  Timer? _controlsTimer;

  bool loading = false;

  bool landScopeMode = false;

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
    // Start the timer initially to hide controls after 5 seconds
    _startControlsTimer();
  }

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
  Widget build(BuildContext context) {
    appState = Provider.of<a.AppState>(context);
    return WillPopScope(
      onWillPop: () async {
        final orientation = MediaQuery.of(context).orientation;
        if (orientation == Orientation.landscape) {
          await changeOrientation();
        }
        return orientation == Orientation.landscape ? false : true;
      },
      child: Scaffold(
        appBar: MediaQuery.of(context).orientation == Orientation.portrait
            ? AppBar(
                leading: IconButton(
                  padding: const EdgeInsets.only(left: 12),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    size: 32,
                    color: AppColors.white,
                  ),
                ),
                actions: [
                  BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
                    builder: (context, state) {
                      if (state is! VideoPlayerInitialised) {
                        return const SizedBox();
                      }

                      final data = state;

                      return Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: TextButton.icon(
                          label: AppText(
                            text: 'Close',
                            styles: GoogleFonts.manrope(
                              color: data.chewieController.videoPlayerController
                                      .value.isInitialized
                                  ? AppColors.white
                                  : AppColors.dullWhite,
                            ),
                          ),
                          onPressed: data.chewieController.videoPlayerController
                                  .value.isInitialized
                              ? () async {
                                  Navigator.pop(context);
                                  await BlocProvider.of<VideoPlayerCubit>(
                                    context,
                                  ).stopVideoPlayer();
                                }
                              : null,
                          icon: Icon(
                            Icons.close,
                            size: 21,
                            color: data.chewieController.videoPlayerController
                                    .value.isInitialized
                                ? AppColors.white
                                : AppColors.dullWhite,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            : const PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: SizedBox(),
              ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
            builder: (context, state) {
              if (state is! VideoPlayerInitialised) {
                return waiting();
              }

              final data = state;
              return MediaQuery.of(context).orientation == Orientation.portrait
                  ? Column(
                      children: [
                        videoPortion(data: data),
                        if (MediaQuery.of(context).orientation ==
                            Orientation.portrait)
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListTile(
                                    tileColor: Colors.blueGrey.withOpacity(0.1),
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.dullBlack,
                                      backgroundImage:
                                          NetworkImage(data.songData.artUri),
                                    ),
                                    title: Text(
                                      data.songData.title,
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    subtitle: AppText(
                                      text: data.songData.artist,
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      styles: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    trailing: Container(
                                      color: Colors.transparent,
                                      width: width * 0.3,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
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
                                              await likedSongs();
                                              setState(() {
                                                appState.isSongFavourite =
                                                    favourite;
                                              });
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
                                  ),
                                  if (showMoreDetails)
                                    showMoreDetailsWidget(data),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: otherSongs(
                                      playingSongId: data.songData.songId,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : videoAspect(data: data);
            },
          ),
        ),
        bottomNavigationBar:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? const CustomNavBarAd()
                : const SizedBox(),
      ),
    );
  }

  Widget videoPortion({required VideoPlayerInitialised data}) {
    return videoAspect(data: data);
  }

  Widget videoAspect({required VideoPlayerInitialised data}) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: _toggleControlsVisibility,
        child: Stack(
          // alignment: Alignment.center,
          children: [
            if (data.chewieController.videoPlayerController.value.isInitialized)
              Chewie(
                controller: data.chewieController,
              ),
            if (showControls && !loading)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: AppColors.black.withOpacity(0.7),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              await skipPrevious();
                            },
                            icon: Icon(
                              Icons.skip_previous,
                              size: 30,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: AppColors.black.withOpacity(0.7),
                          ),
                          child: Center(
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (data.chewieController.videoPlayerController
                                    .value.isPlaying) {
                                  data.chewieController.pause();
                                } else {
                                  data.chewieController.play();
                                }
                              },
                              icon: Icon(
                                data.chewieController.videoPlayerController
                                        .value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 30,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: AppColors.black.withOpacity(0.7),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              await skipNext();
                            },
                            icon: Icon(
                              Icons.skip_next,
                              size: 30,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (showControls && !loading)
              Positioned(
                bottom:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 0
                        : 15,
                child: Center(
                  child: SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: width * 0.98,
                          padding: const EdgeInsets.only(bottom: 10),
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppText(
                                text:
                                    '${data.chewieController.videoPlayerController.value.position.inMinutes.toString().padLeft(2, '0')}:${(data.chewieController.videoPlayerController.value.position.inSeconds % 60).toString().padLeft(
                                          2,
                                          '0',
                                        )}'
                                    ' / ${data.chewieController.videoPlayerController.value.duration.inMinutes.toString().padLeft(
                                          2,
                                          '0',
                                        )}:${(data.chewieController.videoPlayerController.value.duration.inSeconds % 60).toString().padLeft(
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
                                    !landScopeMode
                                        ? Icons.fullscreen
                                        : Icons.fullscreen_exit,
                                    size: 22,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        seekBar(data: data),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget seekBar({required VideoPlayerInitialised data}) {
    return ProgressBar(
      bufferedBarColor: AppColors.dullWhite,
      thumbCanPaintOutsideBar: false,
      progressBarColor: AppColors.redAccent,
      thumbColor: Colors.transparent,
      barCapShape: BarCapShape.square,
      thumbRadius: 0,
      thumbGlowRadius: 0,
      buffered: Duration(
        seconds: data.chewieController.videoPlayerController.value.position
                .inSeconds +
            50,
      ),
      progress: Duration(
        seconds: data
            .chewieController.videoPlayerController.value.position.inSeconds,
      ),
      total: Duration(
        seconds: data
            .chewieController.videoPlayerController.value.duration.inSeconds,
      ),
      timeLabelTextStyle: const TextStyle(
        color: Colors.transparent,
        fontSize: 0,
      ),
      onSeek: (duration) {
        data.chewieController.videoPlayerController.seekTo(duration);
      },
    );
  }

  Widget waiting() {
    return const AspectRatio(
      aspectRatio: 16 / 9,
      child: Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget showMoreDetailsWidget(VideoPlayerInitialised data) {
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
                await BlocProvider.of<VideoPlayerCubit>(context)
                    .setToInitialState();
                await BlocProvider.of<VideoPlayerCubit>(context).startPlayer(
                  songData: songData,
                  songs: widget.songs,
                  selectedSongIndex: selectedSongIndex,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future skipNext() async {
    setState(() {
      loading = true;
    });
    await BlocProvider.of<VideoPlayerCubit>(context).setToInitialState();
    await BlocProvider.of<VideoPlayerCubit>(context).skipToNext(
      songs: widget.songs,
    );
    setState(() {
      loading = false;
    });
  }

  Future skipPrevious() async {
    setState(() {
      loading = true;
    });
    await BlocProvider.of<VideoPlayerCubit>(context).setToInitialState();
    await BlocProvider.of<VideoPlayerCubit>(context).skipToPrevious(
      songs: widget.songs,
    );
    setState(() {
      loading = false;
    });
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

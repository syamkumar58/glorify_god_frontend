// ignore_for_file: avoid_dynamic_calls

import 'dart:developer';
import 'dart:ui';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:glorify_god/components/custom_nav_bar_ad.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class PositionData {
  PositionData(this.position, this.duration);

  final Duration position;
  final Duration duration;
}

class JustAudioPlayer extends StatefulWidget {
  const JustAudioPlayer({
    super.key,
    required this.songId,
  });

  final int songId;

  @override
  // ignore: library_private_types_in_public_api
  _JustAudioPlayerState createState() => _JustAudioPlayerState();
}

class _JustAudioPlayerState extends State<JustAudioPlayer> {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  // bool isFav = false;
  bool favLoading = true;
  AppState appState = AppState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkIsFavourite();
    });
  }

  Future<void> checkIsFavourite() async {
    appState = context.read<AppState>();
    final res = await appState.checkFavourites(songId: widget.songId);
    setState(() {
      appState.isSongFavourite = res;
      favLoading = false;
    });
  }

  Stream<PositionData> get _positionDataStream => Rx.combineLatest2(
        appState.audioPlayer.positionStream,
        appState.audioPlayer.durationStream,
        (a, b) => PositionData(
          a,
          b ?? Duration.zero,
        ),
      );

  Widget spacing(double height) {
    return SizedBox(
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.white,
              size: 30,
            ),
          ),
          actions: [
            StreamBuilder(
              stream: appState.audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  log(
                    '${snapshot.error}',
                    name: 'The snapshot error from stream builder',
                  );
                }

                final playerState = snapshot.data;
                final processingState = playerState?.processingState;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Bounce(
                        duration: const Duration(milliseconds: 50),
                        onPressed: () {
                          if (processingState != ProcessingState.idle) {
                            appState.audioPlayer.stop();
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: AppColors.black.withOpacity(0.5),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.close,
                              color: AppColors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: mainBody(),
      bottomNavigationBar: const SafeArea(
        child: CustomNavBarAd(),
      ),
    );
  }

  Widget mainBody() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
      ),
      width: width,
      height: height,
      child: ScrollConfiguration(
        behavior: const ScrollBehavior(
          androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 50),
            physics: const NeverScrollableScrollPhysics(),
            child: StreamBuilder(
              stream: appState.audioPlayer.sequenceStateStream,
              builder: (context, snapShot) {
                final state = snapShot.data;

                if (state?.sequence.isEmpty ?? true) {
                  return const SizedBox();
                }

                final trackData = state?.currentSource!.tag as MediaItem;

                return StreamBuilder(
                  stream: appState.audioPlayer.playerStateStream,
                  builder: (context, snapShot) {
                    if (snapShot.hasError) {
                      log(
                        '${snapShot.error}',
                        name: 'The playerStream snap Error',
                      );
                    }

                    final playerState = snapShot.data;
                    final processingState = playerState?.processingState;
                    log(
                      '$processingState',
                      name: 'processingState from stream',
                    );
                    final playing = playerState?.playing;

                    return Center(
                      child: Column(
                        children: [
                          playerUi(
                            title: trackData.title,
                            artist: trackData.artist ?? '',
                            artUri: trackData.artUri.toString(),
                          ),
                          seekBar(),
                          controlBackgroundWithControls(
                            isPlaying: playing ?? false,
                            processingState:
                                processingState ?? ProcessingState.buffering,
                          ),
                          volumeBar(),
                          // const MoreDetails(),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget playerUi({String title = '', String artist = '', String artUri = ''}) {
    return Column(
      children: [
        Center(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 300,
              height: 300,
              constraints: const BoxConstraints(
                maxHeight: 300,
                maxWidth: 300,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                    artUri,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: width * 0.9,
          // color: Colors.greenAccent,
          child: ListTile(
            title: AppText(
              text: 'Song Title - $title',
              textAlign: TextAlign.start,
              styles: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            subtitle: AppText(
              text: 'Artist - $artist',
              maxLines: 1,
              textAlign: TextAlign.start,
              styles: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            trailing: !favLoading
                ? IconButton(
                    onPressed: () async {
                      final favourite = await onFav();
                      // await appState.likedSongs();
                      setState(() {
                        appState.isSongFavourite = favourite;
                      });
                    },
                    icon: Icon(
                      appState.isSongFavourite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          appState.isSongFavourite ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                  )
                : const CupertinoActivityIndicator(),
          ),
        ),
        spacing(10),
      ],
    );
  }

  Widget controlBackgroundWithControls({
    bool isPlaying = false,
    ProcessingState processingState = ProcessingState.buffering,
  }) {
    return Container(
      width: width * 0.85,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blueGrey.withOpacity(0.3),
      ),
      child: playerControls(
        isPlaying: isPlaying,
        processingState: processingState,
      ),
    );
  }

  Widget playerControls({
    bool isPlaying = false,
    ProcessingState processingState = ProcessingState.buffering,
  }) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                backwardButton(),
                if (processingState == ProcessingState.buffering &&
                    processingState != ProcessingState.loading)
                  const CupertinoActivityIndicator(
                    color: Colors.white,
                  )
                else
                  playPauseButton(isPlaying: isPlaying),
                forwardButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget backwardButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: appState.audioPlayer.processingState == ProcessingState.ready
          ? () async {
              await appState.audioPlayer.seekToPrevious();
              await appState.audioPlayer.pause();
              await appState.audioPlayer.play();
            }
          : null,
      child: Icon(
        Icons.skip_previous_rounded,
        size: 30,
        // color: player.position.inSeconds > 5 ? Colors.white
        // : Colors.grey[600],
        color: appState.audioPlayer.processingState == ProcessingState.ready
            ? AppColors.white
            : AppColors.dullWhite,
      ),
    );
  }

  Widget playPauseButton({bool isPlaying = false}) {
    return appState.audioPlayer.processingState == ProcessingState.ready
        ? Bounce(
            onPressed: () async {
              if (isPlaying) {
                await appState.audioPlayer.pause();
              } else {
                await appState.audioPlayer.play();
              }
            },
            duration: const Duration(milliseconds: 150),
            child: Icon(
              isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: Colors.white,
              size: 45,
            ),
          )
        : Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColors.white,
            ),
            child: Center(
              child: CupertinoActivityIndicator(
                color: AppColors.dullBlack,
              ),
            ),
          );
  }

  Widget forwardButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: appState.audioPlayer.processingState == ProcessingState.ready
          ? () async {
              // player.seek(Duration(seconds: player.position.inSeconds + 5));
              await appState.audioPlayer.seekToNext();
              await appState.audioPlayer.pause();
              await appState.audioPlayer.play();
            }
          : null,
      child: Icon(
        Icons.skip_next_rounded,
        size: 30,
        color: appState.audioPlayer.processingState == ProcessingState.ready
            ? AppColors.white
            : AppColors.dullWhite,
      ),
    );
  }

  Widget seekBar() {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      width: width * 0.85,
      child: StreamBuilder<PositionData>(
        stream: _positionDataStream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          final trackData = snapshot.data;

          final duration = trackData?.duration ?? Duration.zero;
          var position = trackData?.position ?? Duration.zero;

          return Column(
            children: [
              ProgressBar(
                bufferedBarColor: AppColors.dullWhite,
                thumbCanPaintOutsideBar: false,
                progressBarColor: AppColors.white,
                thumbColor: AppColors.white.withOpacity(0.6),
                barCapShape: BarCapShape.square,
                thumbRadius: 0,
                thumbGlowRadius: 10,
                progress: position.inSeconds.toDouble() >=
                        duration.inSeconds.toDouble()
                    ? const Duration(seconds: 0)
                    : (Duration(seconds: position.inSeconds)),
                total: Duration(seconds: duration.inSeconds),
                timeLabelPadding: 10,
                onSeek: (updatedPosition) {
                  // Debugging: Print the seek position
                  log('Seeking to: $updatedPosition seconds');

                  // Seek when the user finishes sliding
                  appState.audioPlayer.seek(updatedPosition);

                  // Debugging: Print the current audio position after seeking
                  appState.audioPlayer.positionStream.listen((position) {});
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget volumeBar() {
    return Container(
      // color: Colors.blueAccent,
      margin: const EdgeInsets.only(
        top: 30,
      ),
      width: width * 0.9,
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              appState.audioPlayer.setVolume(0);
              setState(() {});
            },
            icon: Icon(
              Icons.volume_off,
              size: 20,
              color: AppColors.white,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.white,
                thumbColor: AppColors.white.withOpacity(0.8),
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 5,
                ),
              ),
              child: Slider(
                min: 0.0,
                max: 1.0,
                value: appState.audioPlayer.volume,
                onChanged: (volume) {
                  appState.audioPlayer.setVolume(volume);
                  setState(() {});
                },
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              appState.audioPlayer.setVolume(1);
              setState(() {});
            },
            icon: Icon(
              Icons.volume_up,
              size: 20,
              color: AppColors.white,
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
        songId: widget.songId,
      );
    } else {
      favourite = await appState.addFavourite(
        songId: widget.songId,
      );
    }
    return favourite;
  }
}

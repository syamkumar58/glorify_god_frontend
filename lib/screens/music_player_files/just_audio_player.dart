// ignore_for_file: avoid_dynamic_calls

import 'dart:developer';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:glorify_god/components/ads_card.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/youtube_link_button.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: mainBody(),
    );
  }

  Widget mainBody() {
    return SizedBox(
      width: width,
      height: height,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 50),
        child: StreamBuilder(
          stream: appState.audioPlayer.sequenceStateStream,
          builder: (context, snapShot) {
            final state = snapShot.data;

            if (state?.sequence.isEmpty ?? true) {
              return const SizedBox();
            }

            final trackData = state?.currentSource!.tag as MediaItem;

            log('${trackData.extras!['ytUrl']}',
                name: 'The yt url is it there ah ');

            return Container(
              decoration: BoxDecoration(
                color: AppColors.black,
              ),
              width: width,
              height: height,
              child: StreamBuilder(
                stream: appState.audioPlayer.playerStateStream,
                builder: (context, snapShot) {
                  if (snapShot.hasError) {
                    log('${snapShot.error}',
                        name: 'The playerStream snap Error');
                  }

                  final playerState = snapShot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;

                  return Container(
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                        color: AppColors.black,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          opacity: 0.2,
                          image: NetworkImage(
                            trackData.artUri.toString(),
                          ),
                        )),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            // appBar(),
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
                            if (trackData.extras!['ytUrl']
                                .toString()
                                .isNotEmpty)
                              YoutubeLinkButton(
                                ytImage:
                                    trackData.extras!['ytImage'].toString(),
                                ytTitle:
                                    trackData.extras!['ytTitle'].toString(),
                                ytUrl: trackData.extras!['ytUrl'].toString(),
                              ),
                            const AdsCard(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget playerUi({String title = '', String artist = '', String artUri = ''}) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: height * 0.04, bottom: height * 0.04),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      artUri,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        AppText(
          text: title,
          styles: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Memphis-Bold',
            color: Colors.white,
          ),
        ),
        spacing(10),
        AppText(
          text: 'by $artist',
          styles: const TextStyle(
            fontSize: 16,
            fontFamily: 'Memphis-Bold',
            color: Colors.white,
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
      width: width * 0.9,
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
    appState = Provider.of<AppState>(context);
    log('${appState.isSongFavourite}', name: 'From widget the fav');
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 20,
        right: 20,
        left: 20,
      ),
      child: StreamBuilder<PositionData>(
        stream: _positionDataStream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          final trackData = snapshot.data;

          final duration = trackData?.duration ?? Duration.zero;
          var position = trackData?.position ?? Duration.zero;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: !favLoading
                      ? IconButton(
                          onPressed: () async {
                            final favourite = await onFav();
                            await appState.likedSongs();
                            log('$favourite', name: 'from onTap fav');
                            setState(() {
                              appState.isSongFavourite = favourite;
                            });
                          },
                          icon: Icon(
                            appState.isSongFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: appState.isSongFavourite
                                ? Colors.red
                                : Colors.grey,
                            size: 29,
                          ),
                        )
                      : const CupertinoActivityIndicator(),
                ),
              ),
              SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 6,
                ),
                child: Slider(
                  min: 0,
                  max: (duration.inSeconds.toDouble() ?? 0) as double,
                  value: (position.inSeconds.toDouble() ?? 0) as double,
                  inactiveColor: Colors.grey[600],
                  activeColor: Colors.white,
                  onChanged: (value) {
                    setState(() {
                      position = Duration(seconds: value.toInt());
                    });
                  },
                  onChangeEnd: (value) {
                    // Debugging: Print the seek position
                    log('Seeking to: $value seconds');

                    // Seek when the user finishes sliding
                    final finalPosition = Duration(seconds: value.toInt());
                    appState.audioPlayer.seek(finalPosition);

                    // Debugging: Print the current audio position after seeking
                    appState.audioPlayer.positionStream.listen((position) {
                      log('Current position after seek: $position');
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: convertDurations(position as Duration),
                      styles: GoogleFonts.manrope(
                        color: Colors.white,
                      ),
                    ),
                    AppText(
                      text: convertDurations(duration as Duration),
                      styles: GoogleFonts.manrope(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

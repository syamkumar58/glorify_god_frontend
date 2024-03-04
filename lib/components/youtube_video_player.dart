import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/bloc/youtube_player_cubit/youtube_player_cubit.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoPlayerScreen extends StatefulWidget {
  const YoutubeVideoPlayerScreen({super.key, required this.songs});

  final List<String> songs;



  @override
  State<YoutubeVideoPlayerScreen> createState() =>
      _YoutubeVideoPlayerScreenState();
}

class _YoutubeVideoPlayerScreenState extends State<YoutubeVideoPlayerScreen> {
  bool landScopeMode = false;

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<YoutubePlayerCubit, YoutubePlayerState>(
        builder: (context, state) {
          log('$state', name: 'The state');

          if (state is! YoutubePlayerInitialised) {
            return const SizedBox();
          }

          final ytController = state.youtubePlayerController;

          return YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: ytController,
              // width: width,
              aspectRatio: 16 / 9,
              showVideoProgressIndicator: true,
              progressColors: const ProgressBarColors(),
              progressIndicatorColor: Colors.red,
              bufferIndicator:
                  const Center(child: CupertinoActivityIndicator()),
              onEnded: (meteData) {
                BlocProvider.of<YoutubePlayerCubit>(context).skipToNext(
                  songs: widget.songs,
                );
              },
            ),
            builder: (context, player) {
              return Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        player,
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        await BlocProvider.of<
                                                YoutubePlayerCubit>(context)
                                            .skipToNext(songs: widget.songs);
                                      },
                                      icon: Icon(
                                        Icons.skip_previous,
                                        size: 30,
                                        color: AppColors.white,
                                      )),
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
                                            if (ytController
                                                .value
                                                .isPlaying) {
                                              ytController.pause();
                                            } else {
                                              ytController.play();
                                            }
                                          },
                                          icon: Icon(
                                            ytController
                                                    .value
                                                    .isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            size: 30,
                                            color: AppColors.white,
                                          )),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        // await skipNext();
                                      },
                                      icon: Icon(
                                        Icons.skip_next,
                                        size: 30,
                                        color: AppColors.white,
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 0
                              : 15,
                          child: Center(
                            child: SizedBox(
                              width: width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: width * 0.98,
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        AppText(
                                          text:
                                              '${ytController.value.position.inMinutes.toString().padLeft(2, '0')}:${(ytController.value.position.inSeconds % 60).toString().padLeft(2, '0')}'
                                              ' / ${ytController.metadata.duration.inMinutes.toString().padLeft(2, '0')}:${(ytController.metadata.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                                          styles: GoogleFonts.manrope(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.white,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 0),
                                          child: Bounce(
                                            duration: const Duration(
                                                milliseconds: 50),
                                            onPressed: () {
                                              log(
                                                '${MediaQuery.of(context).orientation == Orientation.portrait}',
                                                name: 'The orientation',
                                              );
                                              if (MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.portrait) {
                                                SystemChrome
                                                    .setPreferredOrientations(
                                                  [
                                                    DeviceOrientation
                                                        .landscapeRight,
                                                    DeviceOrientation
                                                        .landscapeLeft,
                                                  ],
                                                );
                                              } else {
                                                SystemChrome
                                                    .setPreferredOrientations(
                                                  [
                                                    DeviceOrientation
                                                        .portraitUp
                                                  ],
                                                );
                                              }
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
                                  // Container(
                                  //   width: width,
                                  //   height: 5,
                                  //   padding: EdgeInsets.zero,
                                  //   color: AppColors.dullWhite,
                                  //   child: FractionallySizedBox(
                                  //     widthFactor: (ytController
                                  //             .value
                                  //             .position
                                  //             .inSeconds /
                                  //         ytController.metadata
                                  //             .duration
                                  //             .inSeconds),
                                  //     child: Shimmer.fromColors(
                                  //       baseColor: AppColors.white,
                                  //       highlightColor: AppColors.white
                                  //           .withOpacity(0.7),
                                  //       enabled: true,
                                  //       child: Container(
                                  //         decoration: BoxDecoration(
                                  //           color: AppColors.white,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (ytController.value.isPlaying) {
                        ytController.pause();
                      } else {
                        ytController.play();
                      }
                      setState(() {});
                    },
                    icon: Icon(
                      ytController.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 30,
                      color: AppColors.white,
                    ),
                    label: AppText(
                      text: ytController.value.isPlaying ? 'Pause' : 'Play',
                      styles: GoogleFonts.manrope(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

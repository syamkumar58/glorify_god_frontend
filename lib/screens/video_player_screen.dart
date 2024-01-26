import 'dart:async';
import 'dart:developer';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/components/ads_card.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/screens/home_screens/home_screen.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  GlobalVariables globalVariables = GlobalVariables();

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  bool showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
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
    globalVariables = Provider.of<GlobalVariables>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 24,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        title: AppText(
          text: '',
          styles: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          children: [
            videoPortion(),
            const AdsCard(),
            otherSongs(),
          ],
        ),
      ),
    );
  }

  Widget videoPortion() {
    return StreamBuilder<ControllerWithSongData>(
        stream: globalVariables.songStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log('${snapshot.error}', name: 'The error');
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          final data = snapshot.data!;

          return Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: GestureDetector(
                  onTap: _toggleControlsVisibility,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Chewie(
                        controller: data.chewieController,
                      ),
                      if (showControls)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: () {},
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
                                            // setState(() {
                                            //   showControls = false;
                                            // });
                                            if (data
                                                .chewieController
                                                .videoPlayerController
                                                .value
                                                .isPlaying) {
                                              data.chewieController.pause();
                                            } else {
                                              data.chewieController.play();
                                            }
                                          },
                                          icon: Icon(
                                            data
                                                    .chewieController
                                                    .videoPlayerController
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
                                      onPressed: () {},
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
                      if (showControls)
                        Positioned(
                          bottom: 12,
                          child: Center(
                            child: SizedBox(
                              width: width * 0.9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 6,
                                        thumbShape:
                                            SliderComponentShape.noThumb,
                                        thumbColor: Colors.transparent,
                                        inactiveTrackColor: AppColors.dullWhite,
                                        activeTrackColor: AppColors.redAccent,
                                      ),
                                      child: Slider(
                                        min: 0,
                                        value: data
                                            .chewieController
                                            .videoPlayerController
                                            .value
                                            .position
                                            .inSeconds
                                            .toDouble(),
                                        max: data
                                            .chewieController
                                            .videoPlayerController
                                            .value
                                            .duration
                                            .inSeconds
                                            .toDouble(),
                                        onChanged: (val) {
                                          data.chewieController
                                              .videoPlayerController
                                              .seekTo(
                                            Duration(
                                              seconds: val.toInt(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AppText(
                                        text:
                                            '${data.chewieController.videoPlayerController.value.position.inMinutes.toString().padLeft(2, '0')}:${(data.chewieController.videoPlayerController.value.position.inSeconds % 60).toString().padLeft(2, '0')}',
                                        styles: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.6,
                                      ),
                                      AppText(
                                        text:
                                            '${data.chewieController.videoPlayerController.value.duration.inMinutes.toString().padLeft(2, '0')}:${(data.chewieController.videoPlayerController.value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                                        styles: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ListTile(
                tileColor: Colors.blueGrey.withOpacity(0.1),
                leading: CircleAvatar(
                  backgroundColor: AppColors.dullBlack,
                  backgroundImage: NetworkImage(widget.songData.artUri),
                ),
                title: AppText(
                  text: widget.songData.title,
                  textAlign: TextAlign.start,
                  styles: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                subtitle: AppText(
                  text: widget.songData.artist,
                  textAlign: TextAlign.start,
                  styles: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white,
                  ),
                ),
                trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.favorite_border,
                      size: 21,
                      color: AppColors.dullWhite,
                    )),
              ),
            ],
          );
        });
  }

  Widget otherSongs() {
    return Column(
      children: [
        ...widget.songs
            .where((element) => element.songId != widget.songData.songId)
            .map((e) {
          return eachTile(e);
        }).toList(),
      ],
    );
  }

  Widget eachTile(Song songData) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.1),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                    )),
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
              onTap: () async {
                await VideoHandler(
                  songData: songData,
                  songs: widget.songs,
                  globalVariables: globalVariables,
                ).startTheVideo(
                  videoUrl: songData.videoUrl,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

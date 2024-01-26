// ignore_for_file: strict_raw_type, avoid_dynamic_calls

import 'dart:async';
import 'dart:developer';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:glorify_god/components/ads_card.dart';
import 'package:glorify_god/components/banner_card.dart';
import 'package:glorify_god/components/home_components/copy_right_text.dart';
import 'package:glorify_god/components/home_components/home_loading_shimmer_effect.dart';
import 'package:glorify_god/components/song_card_component.dart';
import 'package:glorify_god/components/title_tile_component.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart' as app;
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/screens/video_player_screen.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  app.AppState appState = app.AppState();
  GlobalVariables globalVariables = GlobalVariables();

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  bool connectionError = false;
  List<int> showShimmers = [1, 2, 3, 4];
  late AnimationController lottieController;

  List<Map<String, dynamic>> videos = [
    {
      'videoUrl':
          'https://glorifygod.s3.ap-south-1.amazonaws.com/Videos+Section/thandri-deva-song/Thandri-Deva-video.mp4',
      'videoThumbnail':
          'https://glorifygod.s3.ap-south-1.amazonaws.com/Videos+Section/thandri-deva-song/thandri-deva-image.jpeg',
      'videoId': 1,
      'title': 'Thandri Deva',
      'artist': 'Raj Prakash Paul',
      'artistId': 1,
      'createdAt': '',
    },
    {
      'videoUrl':
          'https://glorifygod.s3.ap-south-1.amazonaws.com/Videos+Section/mahonathuda-song/mahonathuda-video.mp4',
      'videoThumbnail':
          'https://glorifygod.s3.ap-south-1.amazonaws.com/Videos+Section/mahonathuda-song/mahonathuda-image.jpeg',
      'videoId': 2,
      'title': 'Mahonathuda',
      'artist': 'Raj Prakash Paul',
      'artistId': 1,
      'createdAt': '',
    },
    {
      'videoUrl':
          'https://glorifygod.s3.ap-south-1.amazonaws.com/Videos+Section/thandri-deva-song/Thandri-Deva-video.mp4',
      'videoThumbnail':
          'https://glorifygod.s3.ap-south-1.amazonaws.com/Videos+Section/thandri-deva-song/thandri-deva-image.jpeg',
      'videoId': 3,
      'title': 'Thandri Deva 2',
      'artist': 'Raj Prakash Paul',
      'artistId': 1,
      'createdAt': '',
    },
    {
      'videoUrl':
          'https://glorifygod.s3.ap-south-1.amazonaws.com/Videos+Section/mahonathuda-song/mahonathuda-video.mp4',
      'videoThumbnail':
          'https://glorifygod.s3.ap-south-1.amazonaws.com/Videos+Section/mahonathuda-song/mahonathuda-image.jpeg',
      'videoId': 4,
      'title': 'Mahonathuda 2',
      'artist': 'Raj Prakash Paul',
      'artistId': 1,
      'createdAt': '',
    },
  ];

  @override
  void initState() {
    lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    lottieController.repeat();
    appState = context.read<app.AppState>();
    globalVariables = context.read<GlobalVariables>();
    super.initState();
    getAllSongs();
  }

  Future getAllSongs() async {
    try {
      await appState.getAllArtistsWithSongs();
    } catch (er) {
      log('$er', name: 'The home screen error');
      if (er.toString().contains('Null check operator used on a null value')) {
        setState(() {
          connectionError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<app.AppState>(context);
    globalVariables = Provider.of<GlobalVariables>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(remoteConfigData.showUpdateBanner ? 160 : 60),
        child: SafeArea(
          child: Column(
            children: [
              if (remoteConfigData.showUpdateBanner)
                ListTile(
                  tileColor: Colors.blue,
                  title: Text(
                    "Exciting news! A new version of our app is now available. Elevate your experience by updating through the Play/App Store today!",
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.close,
                        size: 22,
                        color: AppColors.white,
                      )),
                ),
              appBar(appState),
            ],
          ),
        ),
      ),
      body: SizedBox(
        width: width,
        height: height,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: appState.getArtistsWithSongsList.isNotEmpty
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (connectionError)
                  Container(
                    width: width,
                    decoration: const BoxDecoration(color: Colors.blue),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "**Service Update: Servers Currently Unavailable**\n",
                                    style: GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "We apologize for the inconvenience, but our servers are currently down for maintenance. Please try accessing the app again later. Thank you for your understanding.",
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const BannerCard(),
                const AdsCard(),

                // SizedBox(
                //   height: 220,
                //   child: Column(
                //     children: [
                //       TitleTile(
                //         title: 'Raj Prakash Paul',
                //         showViewAll: false,
                //         onPressViewAll: () {},
                //         pastorImage: 'pastorImage',
                //       ),
                //       SingleChildScrollView(
                //         scrollDirection: Axis.horizontal,
                //         child: Row(
                //           children: [
                //             ...videos
                //                 .map(
                //                   (e) => Bounce(
                //                     duration: const Duration(milliseconds: 50),
                //                     onPressed: () async {
                //                       Navigator.of(context).push(
                //                         CupertinoPageRoute(
                //                           builder: (_) => VideoPlayerScreen(
                //                             allVideos: videos,
                //                             songData: e,
                //                           ),
                //                         ),
                //                       );
                //                     },
                //                     child: SongCard(
                //                       image: e['videoThumbnail'].toString(),
                //                       title: e['title'].toString(),
                //                     ),
                //                   ),
                //                 )
                //                 .toList()
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // const SizedBox(
                //   height: 30,
                // ),
                // const YoutubeVideoPlayerScreen(),
                const SizedBox(
                  height: 30,
                ),
                if (appState.getArtistsWithSongsList.isNotEmpty)
                  ...appState.getArtistsWithSongsList.map((e) {
                    return Container(
                      color: Colors.transparent,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (e.songs.isNotEmpty)
                            TitleTile(
                              title: e.artistName,
                              showViewAll: false,
                              onPressViewAll: () {},
                              pastorImage: e.artistImage,
                            ),
                          if (e.songs.isNotEmpty) songCard(e.songs),
                        ],
                      ),
                    );
                  })
                else
                  const HomeShimmerEffect(),
                // TitleTile(
                //   title: 'Most played',
                //   onPressViewAll: () {},
                // ),
                // mostPlayedSongs(),
                const AdsCard(),
                const CopyRightText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget appBar(AppState appState) {
    return ListTile(
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: AppStrings.appName,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'RubikGlitch-Regular',
                // letterSpacing: 0,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
                // fontStyle: FontStyle.italic,
                // foreground: Paint()
                //   ..shader = LinearGradient(
                //     colors: [
                //       AppColors.redAccent,
                //       AppColors.blueAccent,
                //       // AppColors.purple,
                //     ],
                //     begin: Alignment.bottomLeft,
                //     end: Alignment.topRight,
                //   ).createShader(
                //     const Rect.fromLTWH(10, 30, 8, 18),
                //   ),
              ),
            ),
            TextSpan(
              text: '  with Songs',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontFamily: 'Memphis-Light',
              ),
            ),
          ],
        ),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Image.asset(
          AppImages.appWhiteIcon,
          width: 25,
          height: 20,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Future getToken() async {
    final jwtToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    log('$jwtToken', name: 'jwtToken');
  }

  Widget songCard(List<Song> songs) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        children: songs
            .map(
              (e) => Bounce(
                duration: const Duration(milliseconds: 50),
                onPressed: () async {
                  final initialId = songs.indexOf(e);
                  log('${e.songId} , $initialId', name: 'on tap songId');
                  // if (appState.audioPlayer.playing) {
                  //   await appState.audioPlayer.pause();
                  // }

                  showMusicScreen(songData: e, songs: songs);

                  await VideoHandler(
                          songData: e,
                          songs: songs,
                          globalVariables: globalVariables)
                      .startTheVideo(videoUrl: e.videoUrl);
                },
                child: SongCard(
                  image: e.artUri,
                  title: e.title,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> showMusicScreen(
      {required Song songData, required List<Song> songs}) async {
    await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      // showDragHandle: true,
      backgroundColor: AppColors.black,
      barrierColor: AppColors.black.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (ctx) {
        return SizedBox(
          width: width,
          height: height * 0.9,
          child: VideoPlayerScreen(
            songData: songData,
            songs: songs,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    lottieController.dispose();
    super.dispose();
  }
}

class VideoHandler {
  VideoHandler({
    required this.songData,
    required this.songs,
    required this.globalVariables,
  });

  final Song songData;

  final List<Song> songs;

  final GlobalVariables globalVariables;

  VideoPlayerController? videoPlayerController;
  int currentVideoIndex = 0;

  Future startTheVideo({required String videoUrl}) async {
    if (videoPlayerController != null) {
      log('did this came here');
      await videoPlayerController!.dispose();
    }

    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    globalVariables.chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      showControls: false,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.white,
        handleColor: Colors.transparent,
      ),
    );

    final songStreamData = ControllerWithSongData(
      chewieController: globalVariables.chewieController!,
      songData: songData,
      songs: songs,
    );

    globalVariables.chewieController!.videoPlayerController.addListener(() {
      globalVariables.songStreamController.add(songStreamData);
      if (globalVariables
                  .chewieController!.videoPlayerController.value.position !=
              Duration.zero &&
          globalVariables
                  .chewieController!.videoPlayerController.value.position >=
              globalVariables
                  .chewieController!.videoPlayerController.value.duration) {
        log('The song completed');
        skipToNext();
      }
    });
  }

  Future skipToNext() async {
    if (currentVideoIndex < songs.length - 1) {
      currentVideoIndex++;
    } else {
      currentVideoIndex = 0; // Loop back to the first video if at the end
    }
    startTheVideo(videoUrl: songs[currentVideoIndex].videoUrl);
  }

  Future skipToPrevious() async {
    if (currentVideoIndex > 0) {
      currentVideoIndex--;
    } else {
      currentVideoIndex = songs.length - 1;
    }
    startTheVideo(videoUrl: songs[currentVideoIndex].videoUrl);
  }
}

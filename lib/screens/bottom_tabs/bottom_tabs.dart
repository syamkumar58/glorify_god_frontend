// ignore_for_file: strict_raw_type

import 'dart:async';
import 'dart:developer';
import 'package:chewie/chewie.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/screens/favourites_screen/liked_screen.dart';
import 'package:glorify_god/screens/home_screens/home_screen.dart';
import 'package:glorify_god/screens/profile_screens/profile_screen.dart';
import 'package:glorify_god/screens/search_screens/search_screen.dart';
import 'package:glorify_god/screens/video_player_screen.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class BottomTabs extends StatefulWidget {
  /// const
  const BottomTabs({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomTabsState createState() => _BottomTabsState();
}

class _BottomTabsState extends State<BottomTabs> with WidgetsBindingObserver {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  AppState appState = AppState();
  GlobalVariables globalVariables = GlobalVariables();
  bool isLoading = false;
  int _screenIndex = 0;
  late Box box;
  bool checkItOnce = false;
  StreamSubscription<Duration>? positionStreamSubscription;
  List<Widget> screens = const [
    HomeScreen(),
    SearchScreen(),
    LikedScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    box = Hive.box(HiveKeys.openBox);
    appState = context.read<AppState>();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    initialUserCall();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      listenSongCompletion();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        appState.audioPlayer.dispose();
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
    }
  }

  Future initialUserCall() async {
    await appState.initiallySetUserDataGlobally();
    await appState.getRatings();
  }

  Future listenSongCompletion() async {
    positionStreamSubscription =
        appState.audioPlayer.positionStream.listen((songPosition) async {
      final songDuration = appState.audioPlayer.duration ?? Duration.zero;
      log('cross 1 $songPosition');
      log('cross 2 $songPosition $songDuration');
      if (!checkItOnce &&
          songPosition > Duration.zero &&
          songDuration > Duration.zero &&
          songPosition.inSeconds >= songDuration.inSeconds) {
        setState(() {
          checkItOnce = true;
        });
        log('cross 3 $songPosition $songDuration');
        //<-- If the song completed and artistUID is not Zero then update the tracker by 1
        // That one song was completed and was added to tracker details
        // -->/
        if (appState.songData.artistUID != 0) {
          log('${appState.songData.artistUID}', name: 'icyMeta data');
          await appState.updateTrackerDetails(
              artistId: appState.songData.artistUID);
        }
      } else if (checkItOnce &&
          songPosition > Duration.zero &&
          songDuration > Duration.zero &&
          songPosition.inSeconds < songDuration.inSeconds) {
        setState(() {
          checkItOnce = false;
        });
        log('cross 4 $songPosition $songDuration');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    globalVariables = Provider.of<GlobalVariables>(context);
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CupertinoActivityIndicator(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: screens[_screenIndex],
        bottomNavigationBar: gNavBar(),
      ),
    );
  }

  Widget gNavBar() {
    return StreamBuilder<ControllerWithSongData>(
        stream: globalVariables.songStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log('${snapshot.error}', name: 'snapShot has error');
            return const SizedBox();
          }

          log('${snapshot.hasData}', name: 'snapShot has data');

          return Container(
            color: Colors.transparent,
            height: snapshot.hasData ? 150 : 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (snapshot.hasData) videoBar(snapshot),
                gNav(),
              ],
            ),
          );
        });
  }

  Widget videoBar(AsyncSnapshot<ControllerWithSongData> snapshot) {
    return InkWell(
      onTap: () {
        showMusicScreen(
          songData: snapshot.data!.songData,
          songs: snapshot.data!.songs,
        );
      },
      child: Container(
        height: 60,
        width: width,
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              height: 60,
              width: width * 0.3,
              color: Colors.transparent,
              child: Chewie(
                controller: snapshot.data!.chewieController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Container(
                  height: 60,
                  width: width * 0.4,
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        text: snapshot.data!.songData.title,
                        styles: GoogleFonts.manrope(
                          fontSize: 16,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppText(
                        text: snapshot.data!.songData.artist,
                        styles: GoogleFonts.manrope(
                          fontSize: 14,
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )),
            ),
            IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (snapshot.data!.chewieController.videoPlayerController
                      .value.isPlaying) {
                    globalVariables.chewieController!.pause();
                  } else {
                    globalVariables.chewieController!.play();
                  }
                },
                icon: Icon(
                  snapshot.data!.chewieController.videoPlayerController.value
                          .isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: AppColors.white,
                )),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                // snapshot.data!.chewieController.videoPlayerController.dispose();
                // snapshot.data!.chewieController.dispose();
              },
              icon: const Icon(
                Icons.close,
                size: 21,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget gNav() {
    return SafeArea(
      child: GNav(
        gap: 8,
        // haptic: true,
        activeColor: Colors.white,
        tabBackgroundColor: Colors.blueGrey.shade800,
        padding: const EdgeInsets.all(10),
        tabMargin:
            const EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 5),
        tabs: [
          navBar(
            activeIcon: Icons.library_music,
            inactiveIcon: Icons.library_music_outlined,
            index: 0,
            tabName: AppStrings.tabSongs,
          ),
          navBar(
            tabName: AppStrings.tabSearch,
            activeIcon: Icons.search,
            inactiveIcon: Icons.search,
            index: 1,
          ),
          navBar(
            tabName: AppStrings.tabLiked,
            activeIcon: Icons.favorite,
            inactiveIcon: Icons.favorite_border_outlined,
            index: 2,
          ),
          navBar(
            tabName: AppStrings.tabProfile,
            activeIcon: Icons.account_circle,
            inactiveIcon: Icons.account_circle_outlined,
            index: 3,
          ),
        ],
      ),
    );
  }

  GButton navBar({
    required String tabName,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required int index,
  }) {
    return GButton(
      icon: _screenIndex == index ? activeIcon : inactiveIcon,
      text: tabName,
      onPressed: () {
        setState(() {
          _screenIndex = index;
        });
      },
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

  // AspectRatio(
  // aspectRatio: 16 / 9,
  // child: Chewie(
  // controller: globalVariables.chewieController,
  // ),
  // ),

  @override
  void dispose() {
    appState.audioPlayer.stop();
    if (positionStreamSubscription != null) {
      positionStreamSubscription!.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

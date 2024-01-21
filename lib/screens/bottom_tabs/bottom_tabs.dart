// ignore_for_file: strict_raw_type

import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/song_image_box.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/favourites_screen/liked_screen.dart';
import 'package:glorify_god/screens/home_screens/home_screen.dart';
import 'package:glorify_god/screens/music_player_files/just_audio_player.dart';
import 'package:glorify_god/screens/profile_screens/profile_screen.dart';
import 'package:glorify_god/screens/search_screens/search_screen.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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
  bool isLoading = false;
  int _screenIndex = 0;
  late Box box;
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

  bool checkItOnce = false;

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
    return StreamBuilder(
      stream: appState.audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log('${snapshot.error}',
              name: 'The snapshot error from stream builder');
        }

        final playerState = snapshot.data;
        final playing = playerState?.playing;
        final processingState = playerState?.processingState;
        log(
            '$playerState\n'
            '$playing\n'
            '$processingState',
            name: 'Yhe processingState');

        return SizedBox(
          height: processingState != ProcessingState.idle ? 150 : 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (processingState != ProcessingState.idle)
                musicUI(
                  playing ?? false,
                  processingState ?? ProcessingState.idle,
                ),
              gNav(),
            ],
          ),
        );
      },
    );
  }

  Widget musicUI(
    bool isPlaying,
    ProcessingState processingState,
  ) {
    return StreamBuilder(
      stream: appState.audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state?.sequence.isEmpty ?? true) {
          return const SizedBox();
        }

        final trackData = state?.currentSource!.tag as MediaItem;

        final songId = int.parse(trackData.id);

        return Container(
          width: width,
          height: 60,
          decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  opacity: 0.1,
                  image: NetworkImage(trackData.artUri.toString()))),
          child: Center(
            child: ListTile(
              dense: true,
              onTap: () {
                // showMusicScreen(songId);
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return JustAudioPlayer(songId: songId);
                  },
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ));
              },
              leading: SongImageBox(
                imageUrl: trackData.artUri.toString(),
              ),
              title: SizedBox(
                width: width * 0.3,
                child: Text(
                  trackData.title,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              subtitle: AppText(
                text: trackData.artist.toString(),
                textAlign: TextAlign.left,
                styles: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: AppColors.white,
                      size: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (processingState != ProcessingState.idle) {
                              appState.audioPlayer.stop();
                            }
                          },
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: processingState != ProcessingState.idle
                                ? AppColors.white
                                : AppColors.dullBlack,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

  Future<void> showMusicScreen(int songId) async {
    await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.black,
      barrierColor: Colors.grey.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (ctx) {
        return JustAudioPlayer(
          songId: songId,
        );
      },
    );
  }

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

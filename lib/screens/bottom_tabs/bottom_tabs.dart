// ignore_for_file: strict_raw_type

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/bloc/all_songs_cubit/all_songs_cubit.dart';
import 'package:glorify_god/bloc/video_player_cubit/video_player_cubit.dart';
import 'package:glorify_god/components/ads_card.dart';
import 'package:glorify_god/components/home_components/users_choice_component.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/provider/youtube_player_handler.dart';
import 'package:glorify_god/screens/favourites_screen/liked_screen.dart';
import 'package:glorify_god/screens/home_screens/home_screen.dart';
import 'package:glorify_god/screens/profile_screens/profile_screen.dart';
import 'package:glorify_god/screens/search_screens/search_screen.dart';
import 'package:glorify_god/screens/video_player_screen/floating_youtube_player.dart';
import 'package:glorify_god/screens/video_player_screen/video_player_screen.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
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

class _BottomTabsState extends State<BottomTabs>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  AppState appState = AppState();
  GlobalVariables globalVariables = GlobalVariables();
  YoutubePlayerHandler youtubePlayerHandler = YoutubePlayerHandler();
  bool isLoading = false;
  ChewieController? chewieController;
  late AnimationController animationController;
  double positionXRatio = 0.45;
  double positionYRatio = 0.6;

  //Offset position = const Offset(170, 478); ////<-  Bottom right alignment ->//
  //<-- const Offset(
  //     26,
  //     15,
  //   );  for top left corner -->/
  bool keyBoardCheckOnce = false;
  ad.InterstitialAd? _interstitialAd;
  bool interstitialAdClosed = false;
  int _screenIndex = 0;
  late Box box;
  bool checkItOnce = false;
  List<Widget> screens = const [
    HomeScreen(),
    SearchScreen(),
    LikedScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    box = Hive.box<dynamic>(HiveKeys.openBox);
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    animationController.repeat();
    appState = context.read<AppState>();
    initialUserCall();
    interstitialAdLogic();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final mediaQueryData = MediaQuery.of(context);
    final keyBoardHeight = mediaQueryData.viewInsets.bottom;

    if (keyBoardHeight > 0) {
      if (!keyBoardCheckOnce) {
        log('KeyBoard opened');
        setState(() {
          keyBoardCheckOnce = true;
          // position = const Offset(181, 333);
          positionXRatio = 0.45;
          positionYRatio = 0.4;
        });
      }
    } else {
      if (keyBoardCheckOnce) {
        log('KeyBoard closed');
        setState(() {
          keyBoardCheckOnce = false;
          positionXRatio = 0.45;
          positionYRatio = 0.6;
          // position = const Offset(170, 478);
          // position = const Offset(200, 500);
        });
      }
    }
  }

  List<int> storedList = [0];

  Future initialUserCall() async {
    final dynamic getStoreSelectedArtistIds =
        await box.get(HiveKeys.storeSelectedArtistIds);
    if (getStoreSelectedArtistIds != null) {
      final decodedList =
          json.decode(getStoreSelectedArtistIds) as List<dynamic>;
      storedList = decodedList.map((e) => int.parse(e.toString())).toList();
    }
    final dynamic userLogInData = await box.get(
      HiveKeys.logInKey,
    );
    await appState.initiallySetUserDataGlobally(
      userLogInData,
    );
    await appState.checkArtistLoginDataByEmail();
    await getAllSongsCall(storedList);
    await appState.getRatings();
  }

  Future getAllSongsCall(List<int> storedList) async {
    await BlocProvider.of<AllSongsCubit>(context)
        .getAllSongs(selectedList: storedList);
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    globalVariables = Provider.of<GlobalVariables>(context);
    youtubePlayerHandler = Provider.of<YoutubePlayerHandler>(context);
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CupertinoActivityIndicator(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            screens[_screenIndex],
            if (youtubePlayerHandler.youtubePlayerController != null &&
                youtubePlayerHandler
                    .youtubePlayerController!.initialVideoId.isNotEmpty)
              Positioned(
                left: youtubePlayerHandler.extendToFullScreen
                    ? 0
                    : width * positionXRatio,
                top: youtubePlayerHandler.extendToFullScreen
                    ? 0
                    : height * positionYRatio,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      positionXRatio += details.delta.dx / width;
                      positionYRatio += details.delta.dy / height;
                      // Clamp the position within the screen bounds
                      positionXRatio = positionXRatio.clamp(0.0, 1.0);
                      positionYRatio = positionYRatio.clamp(0.0, 1.0);
                      // position += details.delta;
                      // log('${position.dx} && ${position.dy}', name: 'position');
                    });
                  },
                  child: FloatingYoutubePlayer(
                    songs: youtubePlayerHandler.selectedSongsList,
                    songData: youtubePlayerHandler.selectedSongData,
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: MediaQuery.of(context).orientation == Orientation.portrait
              ? navBar()
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget navBar() {
    final android =
        youtubePlayerHandler.extendToFullScreen ? height * 0.08 : height * 0.14;
    final ios = youtubePlayerHandler.extendToFullScreen
        ? height * 0.06
        : height * 0.132;
    return Container(
      color: AppColors.black,
      width: width,
      height: Platform.isIOS ? ios : android,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const AdsCard(
            adSize: ad.AdSize.banner,
          ),
          if (!youtubePlayerHandler.extendToFullScreen) bottomBar(),
        ],
      ),
    );
  }

  Widget videoBar(VideoPlayerInitialised data) {
    return InkWell(
      onTap: () {
        musicScreenNavigation(
          context,
          songData: data.songData,
          songs: data.songs,
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
              child: data.chewieController.videoPlayerController.value
                      .isInitialized
                  ? Chewie(
                      controller: data.chewieController,
                    )
                  : const SizedBox(),
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
                    Text(
                      data.songData.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppText(
                      text: data.songData.artist,
                      styles: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (data
                    .chewieController.videoPlayerController.value.isPlaying) {
                  data.chewieController.pause();
                } else {
                  data.chewieController.play();
                }
              },
              icon: Icon(
                data.chewieController.videoPlayerController.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: AppColors.white,
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await BlocProvider.of<VideoPlayerCubit>(context)
                    .stopVideoPlayer();
              },
              icon: const Icon(
                Icons.close,
                size: 21,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      color: Colors.transparent,
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                textIcon(
                  activeIcon: Icons.library_music,
                  inactiveIcon: Icons.library_music_outlined,
                  index: 0,
                  tabName: AppStrings.tabSongs,
                ),
                textIcon(
                  tabName: AppStrings.tabSearch,
                  activeIcon: Icons.search,
                  inactiveIcon: Icons.search,
                  index: 1,
                ),
              ],
            ),
          ),
          centerPlayerIcon(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                textIcon(
                  tabName: AppStrings.tabLiked,
                  activeIcon: Icons.favorite,
                  inactiveIcon: Icons.favorite_border_outlined,
                  index: 2,
                ),
                textIcon(
                  tabName: AppStrings.tabProfile,
                  activeIcon: Icons.account_circle,
                  inactiveIcon: Icons.account_circle_outlined,
                  index: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget centerPlayerIcon() {
    return Bounce(
      duration: const Duration(milliseconds: 50),
      onPressed: () {
        artistsOrderOptionsSheet(context: context);
      },
      child: Container(
        width: Platform.isAndroid ? 50 : 60,
        height: Platform.isAndroid ? 50 : 60,
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: AppColors.darkGreyBlue,
          image: DecorationImage(
            image: AssetImage(
              AppImages.appIcon,
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget textIcon({
    required String tabName,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required int index,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          _screenIndex = index;
        });
      },
      icon: Icon(
        _screenIndex == index ? activeIcon : inactiveIcon,
        color: _screenIndex == index
            ? AppColors.white
            : AppColors.white.withOpacity(0.7),
        size: Platform.isAndroid ? 22 : 24,
      ),
    );
  }

  Future<void> showMusicScreen({
    required Song songData,
    required List<Song> songs,
  }) async {
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
          height: height * 0.95,
          child: VideoPlayerScreen(
            songData: songData,
            songs: songs,
          ),
        );
      },
    );
  }

  Future interstitialAdLogic() async {
    final dynamic getStoredAdShownTime =
        await box.get(HiveKeys.storeInterstitialAdLoadedTime);

    if (getStoredAdShownTime == null) {
      //<-- If the stored value is null then will put the value to the
      // hive when the add loaded and closed like on dismissed the ad will assign
      // the key and value to it
      // adDismissed Call will inside  the loadInterstitialAds Function
      // -->/
      log('', name: 'Stored value is null');
      showInterstitialAd();
    } else {
      final presentTime = DateTime.now();
      final convertStoredValueToDateTime =
          DateTime.parse(getStoredAdShownTime.toString());

      if (presentTime.isAfter(
        convertStoredValueToDateTime.add(
          Duration(
            seconds: remoteConfigData.interstitialAdTime,
          ),
        ),
      )) {
        log('did ir came here after 2 mins when i launch the app');
        await box.delete(HiveKeys.storeInterstitialAdLoadedTime);
        showInterstitialAd();
      }
    }
  }

  Future showInterstitialAd() async {
    loadInterstitialAds().then((_) {
      Future.delayed(const Duration(seconds: 5), () async {
        if (_interstitialAd != null) {
          await _interstitialAd!.show();
        } else {
          log('Interstitial Ad not loaded due to null ');
        }
      });
    });
  }

  Future loadInterstitialAds() async {
    final adUnitId = kDebugMode
        ? remoteConfigData.interstitialAdTestId
        : Platform.isAndroid
            ? remoteConfigData.androidInterstitialAdUnitId
            : remoteConfigData.iosInterstitialAdUnitId;

    log(adUnitId, name: 'loadInterstitialAds adUnitId');

    await ad.InterstitialAd.load(
      adUnitId: adUnitId,
      request: const ad.AdRequest(),
      adLoadCallback: ad.InterstitialAdLoadCallback(
        onAdLoaded: (ad.InterstitialAd advertisement) {
          log('$advertisement', name: 'Step 1');
          _interstitialAd = advertisement;
          log('$_interstitialAd', name: 'Step 2');
          _interstitialAd!.fullScreenContentCallback =
              ad.FullScreenContentCallback(
            onAdDismissedFullScreenContent: (advertisement) async {
              log('', name: 'Step 3');
              advertisement.dispose();
              await box.put(
                HiveKeys.storeInterstitialAdLoadedTime,
                DateTime.now().toString(),
              );
              //<-- Store a key value of date time and again fetch and check the that when to load the
              // interstitial ad
              // -->/
            },
            onAdFailedToShowFullScreenContent: (advertisement, error) {
              log(
                '$error',
                name: 'onAdFailedToShowFullScreenContent ad failed to load',
              );
              advertisement.dispose();
            },
          );
        },
        onAdFailedToLoad: (ad.LoadAdError error) {
          _interstitialAd!.dispose();
          log('$error', name: 'Failed to load the Interstitial ad');
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    animationController.dispose();
    super.dispose();
  }
}

// if (appState.ytPlayerController != null)
// BlocBuilder<YoutubePlayerCubit, YoutubePlayerState>(
// builder: (context, state) {
// if (state is! YoutubePlayerInitialised2) {
// return const SizedBox();
// }
//
// final data = state;
//
// return FloatingYoutubePlayer(
// songs: data.songs,
// songData: data.songData,
// );
// },
// ),

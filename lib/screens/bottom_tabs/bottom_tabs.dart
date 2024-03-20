// ignore_for_file: strict_raw_type

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/all_songs/all_songs_cubit.dart';
import 'package:glorify_god/bloc/video_player_bloc/video_player_cubit.dart';
import 'package:glorify_god/components/ads_card.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/screens/favourites_screen/liked_screen.dart';
import 'package:glorify_god/screens/home_screens/home_screen.dart';
import 'package:glorify_god/screens/profile_screens/profile_screen.dart';
import 'package:glorify_god/screens/search_screens/search_screen.dart';
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
  bool isLoading = false;
  ChewieController? chewieController;
  late AnimationController animationController;

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
    interstitialAdLogic();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    animationController.repeat();
    appState = context.read<AppState>();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    initialUserCall();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (mounted) {
      VideoPlayerCubit videoPlayerCubit =
          BlocProvider.of<VideoPlayerCubit>(context);

      if (videoPlayerCubit.playerController != null &&
          videoPlayerCubit
              .playerController!.videoPlayerController.value.isInitialized) {
        chewieController = BlocProvider.of<VideoPlayerCubit>(context)
                .playerController!
                .videoPlayerController
                .value
                .isInitialized
            ? BlocProvider.of<VideoPlayerCubit>(context).playerController
            : null;
        log(
          '$chewieController && state - $state',
          name: 'checking the state and the controller',
        );
        switch (state) {
          case AppLifecycleState.detached:
            if (chewieController != null &&
                chewieController!.videoPlayerController.value.isInitialized) {
              chewieController!.dispose();
              BlocProvider.of<VideoPlayerCubit>(context).pause();
            }
            break;
          case AppLifecycleState.resumed:
            // if (chewieController != null &&
            //     chewieController!.videoPlayerController.value.isInitialized) {
            //   BlocProvider.of<VideoPlayerCubit>(context).pause();
            // }
            break;
          case AppLifecycleState.inactive:
            // if (chewieController != null &&
            //     chewieController!.videoPlayerController.value.isInitialized) {
            //   BlocProvider.of<VideoPlayerCubit>(context).pause();
            // }
            break;
          case AppLifecycleState.hidden:
            if (chewieController != null &&
                chewieController!.videoPlayerController.value.isInitialized) {
              BlocProvider.of<VideoPlayerCubit>(context).pause();
            }
            break;
          case AppLifecycleState.paused:
            if (chewieController != null &&
                chewieController!.videoPlayerController.value.isInitialized) {
              BlocProvider.of<VideoPlayerCubit>(context).pause();
            }
            break;
        }
      }
    }
  }

  Future initialUserCall() async {
    await BlocProvider.of<AllSongsCubit>(context).getAllSongs();
    final dynamic userLogInData = await box.get(
      HiveKeys.logInKey,
    );
    log('$userLogInData', name: 'cached userLoginData from bottom tabs');

    await appState.initiallySetUserDataGlobally(
      userLogInData,
    );
    await appState.checkArtistLoginDataByEmail();
    await appState.getRatings();
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
        bottomNavigationBar: navBar(),
      ),
    );
  }

  Widget navBar() {
    return Container(
      color: Colors.transparent,
      width: width,
      height: Platform.isIOS ? height * 0.18 : height * 0.16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AdsCard(
            adSize: ad.AdSize.banner,
          ),
          bottomBar(),
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
    return BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
      builder: (context, state) {
        VideoPlayerInitialised? data;

        if (state is VideoPlayerInitial) {
        } else if (state is VideoPlayerInitialised) {
          data = state;
        }

        final playing = data != null &&
            data.chewieController.videoPlayerController.value.isInitialized;

        return GestureDetector(
          onTap: () {
            if (data != null &&
                data.chewieController.videoPlayerController.value
                    .isInitialized) {
              musicScreenNavigation(
                context,
                songData: data.songData,
                songs: data.songs,
              );
            }
          },
          child: Container(
            width: Platform.isAndroid ? 50 : 60,
            height: Platform.isAndroid ? 50 : 60,
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColors.dullWhite,
              border: Border.all(
                width: !playing ? 0 : 2,
                color: !playing ? Colors.transparent : AppColors.dullWhite,
              ),
              image: !playing
                  ? DecorationImage(
                      image: AssetImage(
                        AppImages.appIcon,
                      ),
                      fit: BoxFit.contain,
                    )
                  : DecorationImage(
                      image: NetworkImage(
                        data.songData.artUri,
                      ),
                      fit: BoxFit.contain,
                      opacity: 0.8,
                    ),
            ),
            child: !playing
                ? const SizedBox.shrink()
                : Center(
                    child: Icon(
                      data.chewieController.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 34,
                      color: AppColors.white,
                    ),
                  ),
          ),
        );
      },
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
            seconds: kDebugMode ? 1 : remoteConfigData.interstitialAdTime,
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
      log('${DateTime.now()}', name: 'Step 4');
      Future.delayed(const Duration(seconds: 5), () async {
        log('${DateTime.now()}', name: 'Step 5');
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
          log('${DateTime.now()}', name: 'Step 1');
          setState(() {
            _interstitialAd = advertisement;
          });
          log('${DateTime.now()}', name: 'Step 2');
          _interstitialAd!.fullScreenContentCallback =
              ad.FullScreenContentCallback(
            onAdDismissedFullScreenContent: (advertisement) async {
              log('${DateTime.now()}', name: 'Step 3');
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

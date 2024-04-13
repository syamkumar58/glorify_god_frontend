// ignore_for_file: strict_raw_type

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/bloc/all_songs_cubit/all_songs_cubit.dart';
import 'package:glorify_god/bloc/profile_cubit/songs_info_cubit/songs_data_info_cubit.dart';
import 'package:glorify_god/components/ads_card.dart';
import 'package:glorify_god/components/center_play_icon.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/config/remote_config.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/global_variables.dart';
import 'package:glorify_god/screens/favourites_screen/liked_screen.dart';
import 'package:glorify_god/screens/home_screens/home_screen.dart';
import 'package:glorify_god/screens/profile_screens/profile_screen.dart';
import 'package:glorify_god/screens/search_screens/search_screen.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
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

class _BottomTabsState extends State<BottomTabs>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  StreamSubscription<Duration>? positionStreamSubscription;
  AppState appState = AppState();
  GlobalVariables globalVariables = GlobalVariables();
  bool isLoading = false;
  List<int> storedList = [0];
  DateTime? onExitTapTime;

  // double positionXRatio = 0.45;
  // double positionYRatio = 0.57;

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
    appState = context.read<AppState>();
    initialUserCall();
    interstitialAdLogic();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      listenSongCompletion();
    });
  }

  Future initialUserCall() async {
    final dynamic userLogInData = await box.get(
      HiveKeys.logInKey,
    );
    final dynamic getStoreSelectedArtistIds =
        await box.get(HiveKeys.storeSelectedArtistIds);
    if (getStoreSelectedArtistIds != null) {
      final decodedList =
          json.decode(getStoreSelectedArtistIds) as List<dynamic>;
      storedList = decodedList.map((e) => int.parse(e.toString())).toList();
    }
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
          SongsDataInfoCubit songsDataInfoCubit = SongsDataInfoCubit();
          songsDataInfoCubit.addSongStreamData(
            artistId: appState.songData.artistUID,
            startDate: DateTime(DateTime.now().year, 1, 1),
            endDate: DateTime.now(),
          );
          // await appState.updateTrackerDetails(
          //     artistId: appState.songData.artistUID);
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

  Future<bool> willPopScope() async {
    final now = DateTime.now();
    if (onExitTapTime == null ||
        now.difference(onExitTapTime!) > const Duration(seconds: 2)) {
      onExitTapTime = now;
      toastMessage(message: 'Double click to exit app');
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    globalVariables = Provider.of<GlobalVariables>(context);
    return WillPopScope(
      onWillPop: () async {
        return await willPopScope();
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: const CupertinoActivityIndicator(),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body: screens[_screenIndex],
          bottomNavigationBar: navBar(),
        ),
      ),
    );
  }

  Widget navBar() {
    final android = height * 0.15;
    final ios = height * 0.18;
    return Container(
      color: AppColors.black,
      height: Platform.isIOS ? ios : android,
      width: width,
      child: SafeArea(
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const AdsCard(
                adSize: ad.AdSize.banner,
              ),
              bottomBar(),
            ],
          ),
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
    return StreamBuilder(
      stream: appState.audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log('${snapshot.error}', name: 'Snap has error from home tabs');
          return CenterPlayIcon(
            imageProvider: AssetImage(AppImages.appIcon),
          );
        }

        final processingState = snapshot.data != null
            ? snapshot.data!.processingState
            : ProcessingState.idle;

        if (processingState == ProcessingState.idle) {
          return CenterPlayIcon(
            imageProvider: AssetImage(AppImages.appIcon),
          );
        }

        return StreamBuilder(
          stream: appState.audioPlayer.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state?.sequence.isEmpty ?? true) {
              log('did this came here');
              return CenterPlayIcon(
                imageProvider: AssetImage(AppImages.appIcon),
              );
            }

            final trackData = state?.currentSource!.tag as MediaItem;

            final songId = int.parse(trackData.id);

            return Bounce(
              duration: const Duration(milliseconds: 50),
              onPressed: () {
                moveToMusicScreen(context, songId);
              },
              child: CenterPlayIcon(
                audioStarted: true,
                imageProvider: NetworkImage(trackData.artUri.toString()),
              ),
            );
          },
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
            seconds: kDebugMode ? 18000 : remoteConfigData.interstitialAdTime,
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
    appState.audioPlayer.stop();
    if (positionStreamSubscription != null) {
      positionStreamSubscription!.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

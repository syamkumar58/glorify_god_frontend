// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:glorify_god/components/custom_app_bar.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/songs_tile.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/models/search_model.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/home_screens/home_screen.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();

  late AnimationController animationController;

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  List<dynamic> theData = [];

  AppState appState = AppState();

  List<Song> collectedSongs = [];

  Timer? _searchDelay;

  List<SearchModel> searchedList = [];

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    animationController.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: customAppbar('SEARCH'),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 200),
          child: SizedBox(
            width: width,
            height: height,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SafeArea(
                child: Column(
                  children: [
                    // const AdsCard(),
                    const SizedBox(
                      height: 12,
                    ),
                    searchField(),
                    if (searchedList.isNotEmpty)
                      searchedSongs()
                    else if (searchedList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Center(
                          child: Column(
                            children: [
                              if (searchController.text.isNotEmpty)
                                Lottie.asset(
                                  LottieAnimations.searchMusicAni,
                                  controller: animationController,
                                  animate: true,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.high,
                                )
                              else
                                Icon(
                                  Icons.search,
                                  color: AppColors.dullBlack,
                                  size: 40,
                                ),
                              const SizedBox(
                                height: 12,
                              ),
                              AppText(
                                text: searchController.text.isEmpty
                                    ? AppStrings.searchForYourFavouriteMusic
                                    : AppStrings.searchingForYourFavouriteMusic,
                                styles: GoogleFonts.manrope(
                                  fontSize: 16,
                                  color: AppColors.dullWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget searchField() {
    return SizedBox(
      width: width * 0.9,
      child: TextFormField(
        controller: searchController,
        cursorColor: AppColors.white,
        decoration: InputDecoration(
          hintText: AppStrings.searchSongs,
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.dullWhite.withOpacity(0.4),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.dullWhite),
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.dullWhite),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.dullWhite),
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 30,
            color: Colors.grey,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              if (kDebugMode) {
                FocusScope.of(context).unfocus();
              }
              setState(() {
                searchController.clear();
                searchedList.clear();
              });
              cancelTimer();
            },
            icon: Icon(
              Icons.close,
              size: 25,
              color: Colors.blueGrey.shade300,
            ),
          ),
        ),
        onChanged: (text) {
          if (_searchDelay?.isActive ?? false) _searchDelay!.cancel();
          final filteredText = filterText(text);
          if (filteredText.trim().isNotEmpty) {
            onChangedValue(filteredText.trim());
          } else {
            setState(() {
              searchController.clear();
              searchedList.clear();
            });
            cancelTimer();
          }
        },
      ),
    );
  }

  String filterText(String inputText) {
    // Words to filter out
    List<String> filterWords = ['song', 'Song', 'songs', 'Songs'];

    // Split the input text into words
    List<String> words = inputText.split(' ');
    log('$words', name: 'Words 1');

    // Filter out unwanted words
    List<String> filteredWords =
        words.where((word) => !filterWords.contains(word)).toList();
    log('$filteredWords', name: 'Words 2');

    // Join the filtered words back into a string
    String filteredText = filteredWords.join(' ');
    log(filteredText, name: 'Words 3');

    return filteredText;
  }

  Widget searchedSongs() {
    return Expanded(
      child: ListView.separated(
        padding:
            const EdgeInsets.only(bottom: 280, top: 15, left: 12, right: 12),
        itemCount: searchedList.length,
        itemBuilder: (context, index) {
          log('$searchedList', name: 'The searchedList from the widget');
          final songDetails = searchedList[index];
          return Bounce(
            duration: const Duration(milliseconds: 200),
            onPressed: () async {
              collectedSongs.clear();
              final initialId = searchedList.indexOf(searchedList[index]);
              FocusScope.of(context).unfocus();
              for (final song in searchedList) {
                final eachSong = Song(
                  songId: song.songId,
                  artistUID: song.artistUID,
                  videoUrl: song.videoUrl,
                  title: song.title,
                  artist: song.artist,
                  artUri: song.artUri,
                  lyricist: song.lyricist,
                  credits: song.credits,
                  otherData: song.otherData,
                  createdAt: song.createdAt,
                  ytUrl: song.ytUrl,
                  ytTitle: song.ytTitle,
                  ytImage: song.ytImage,
                );
                collectedSongs.add(eachSong);
              }

              await cancelTimer();

              moveToMusicScreen(context, searchedList[index].songId);

              await startAudio(
                appState: appState,
                audioSource: collectedSongs,
                initialId: initialId,
              );
            },
            child: SongsLikesTile(
              songTitle: songDetails.title,
              artistName: songDetails.artist,
              index: index + 1,
              artUri: songDetails.artUri,
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      ),
    );
  }

  Future<dynamic> onChangedValue(String text) async {
    log('after ending 1 ${DateTime.now()}');
    _searchDelay = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final list = await appState.search(text: text);
      setState(() {
        searchedList = list;
      });
    });
    log('after ending 2 ${DateTime.now()}');
    // cancelTimer();
  }

  Future cancelTimer() async {
    if (_searchDelay != null) {
      _searchDelay!.cancel();
    }
  }

  @override
  void dispose() {
    cancelTimer();
    animationController.dispose();
    super.dispose();
  }
}

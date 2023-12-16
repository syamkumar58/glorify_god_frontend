// ignore_for_file: avoid_dynamic_calls

import 'dart:async';

import 'package:glorify_god/components/ads_card.dart';
import 'package:glorify_god/components/go_back_button.dart';
import 'package:glorify_god/components/songs_tile.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/home_screens/home_screen.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  List<dynamic> theData = [];

  AppState appState = AppState();

  List<Song> collectedSongs = [];

  Timer? _searchDelay;

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            cancelTimer();
            GoRouter.of(context).pop();
          },
          icon: const GoBackButton(),
        ),
      ),
      body: SingleChildScrollView(
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
                  const AdsCard(),
                  searchField(),
                  if (searchController.text.isNotEmpty) searchedSongs(),
                ],
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
        cursorColor: Colors.blueGrey.shade300,
        decoration: InputDecoration(
          hintText: AppStrings.searchSongs,
          border: InputBorder.none,
          disabledBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search,
            size: 30,
            color: Colors.grey,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              searchController.clear();
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
          onChangedValue(text);
        },
      ),
    );
  }

  Widget searchedSongs() {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 60, top: 15),
        itemCount: appState.searchList.length,
        itemBuilder: (context, index) {
          final songDetails = appState.searchList[index];
          return Bounce(
            duration: const Duration(milliseconds: 200),
            onPressed: () async {
              FocusScope.of(context).unfocus();
              for (final song in appState.searchList) {
                final eachSong = Song(
                  songId: song.songId,
                  songUrl: song.songUrl,
                  title: song.title,
                  artist: song.artist,
                  artUri: song.artUri,
                  lyricist: song.lyricist,
                  createdAt: song.createdAt,
                  ytUrl: song.ytUrl,
                  ytTitle: song.ytTitle,
                  ytImage: song.ytImage,
                );
                collectedSongs.add(eachSong);
              }
              await startAudio(
                appState: appState,
                audioSource: collectedSongs,
                initialId: songDetails.songId - 1,
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
    _searchDelay = Timer.periodic(const Duration(seconds: 2), (timer) {
      appState.search(text: text);
    });
  }

  void cancelTimer() {
    if (_searchDelay != null) {
      _searchDelay!.cancel();
    }
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }
}

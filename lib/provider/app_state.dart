import 'dart:developer';

import 'package:glorify_god/models/get_favourites_model.dart';
import 'package:glorify_god/models/search_model.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/models/songs_modal.dart';
import 'package:glorify_god/models/user_models/user_login_response_model.dart';
import 'package:glorify_god/src/api/api_calls.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AppState with ChangeNotifier {
  AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  set audioPlayer(AudioPlayer value) {
    _audioPlayer = value;
    notifyListeners();
  }

  UserLoginResponseModel _userData = UserLoginResponseModel(
    userId: 0,
    email: '',
    displayName: '',
    profileUrl: '',
    dob: 0,
    firebaseId: '',
    mobileNumber: '',
    city: '',
    addressLine: '',
    postalCode: '',
    citizenshipCountry: '',
    country: '',
    state: '',
    passportNumber: '',
    fcmToken: '',
    timeZone: '',
    gender: '',
    device: Device(
      uuid: '',
      platform: '',
      deviceName: '',
      versionBaseOs: '',
      manufacture: '',
      model: '',
      isPhysicalDevice: true,
    ),
  );

  UserLoginResponseModel get userData => _userData;

  set userData(UserLoginResponseModel value) {
    _userData = value;
    notifyListeners();
  }

  List<GetArtistsWithSongs> _getArtistsWithSongsList = [];

  List<GetArtistsWithSongs> get getArtistsWithSongsList =>
      _getArtistsWithSongsList;

  set getArtistsWithSongsList(List<GetArtistsWithSongs> value) {
    _getArtistsWithSongsList = value;
    notifyListeners();
  }

  Future<void> getAllArtistsWithSongs() async {
    final data = await ApiCalls().getAllArtistsWithSongs();

    if (data.statusCode == 200) {
      final allSongs = getArtistsWithSongsFromJson(data.body);

      log('$allSongs', name: 'All songs');

      getArtistsWithSongsList = allSongs;
    } else {
      log('${data.statusCode}', name: 'Failed all songs');
    }
  }

  Future<bool> addFavourite({
    required int songId,
  }) async {
    final data =
        await ApiCalls().addFavourites(userId: userData.userId, songId: songId);

    if (data.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> unFavourite({
    required int songId,
  }) async {
    final data = await ApiCalls().unFavourites(
      userId: userData.userId,
      songId: songId,
    );

    if (data.statusCode == 200) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> checkFavourites({
    required int songId,
  }) async {
    final data = await ApiCalls().checkSongIdAddedOrNot(songId: songId);
    if (data.statusCode == 200) {
      log(data.body, name: 'the res body');
      if (data.body.contains('false')) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  List<GetFavouritesModel> _likedSongsList = [];

  List<GetFavouritesModel> get likedSongsList => _likedSongsList;

  set likedSongsList(List<GetFavouritesModel> value) {
    _likedSongsList = value;
    notifyListeners();
  }

  Future<void> likedSongs() async {
    final data = await ApiCalls().getFavourites(userId: userData.userId);

    if (data.statusCode == 200) {
      final list = getFavouritesModelFromJson(data.body);
      likedSongsList = list;
    } else {
      likedSongsList = <GetFavouritesModel>[];
    }
  }

  List<SearchModel> _searchList = [];

  List<SearchModel> get searchList => _searchList;

  set searchList(List<SearchModel> value) {
    _searchList = value;
    notifyListeners();
  }

  Future<void> search({required String text}) async {
    final res = await ApiCalls().searchApi(text: text);

    if (res.statusCode == 200) {
      final searchedList = searchModelFromJson(res.body);
      searchList = searchedList;
    } else {
      searchList = <SearchModel>[];
    }
  }

  List<SongsModel> _songs = [];

  List<SongsModel> get songs => _songs;

  set songs(List<SongsModel> value) {
    _songs = value;
    notifyListeners();
  }

  Future<void> getSongs() async {
    final res = await ApiCalls().getSongs();

    if (res.statusCode == 200) {
      final allSongs = songsModelFromJson(res.body);
      songs = allSongs;
    } else {
      songs = <SongsModel>[];
    }
  }
}

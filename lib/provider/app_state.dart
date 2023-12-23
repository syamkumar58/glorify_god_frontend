import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/models/get_favourites_model.dart';
import 'package:glorify_god/models/profile_models/user_reported_isses_model.dart';
import 'package:glorify_god/models/search_model.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/models/songs_modal.dart';
import 'package:glorify_god/models/user_models/user_login_response_model.dart';
import 'package:glorify_god/src/api/api_calls.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:hive/hive.dart';
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

  Future initiallySetUserDataGlobally() async {
    final glorifyGodBox = Hive.box<dynamic>(HiveKeys.openBox);

    final userLogInData = await glorifyGodBox.get(
      HiveKeys.logInKey,
    );

    log('$userLogInData', name: 'cached userLoginData');

    try {
      if (userLogInData != null) {
        final toJson = jsonEncode(userLogInData);
        final logIn = userLoginResponseModelFromJson(toJson);

        final user = await ApiCalls().getUserById(userId: logIn.userId);

        log('$user', name: 'cached userLoginData 2');

        if (user != null) {
          final userDetails = userLoginResponseModelFromJson(user.body);
          log('$userDetails', name: 'cached userLoginData 3');
          userData = userDetails;
          log('$userData', name: 'cached userLoginData 4');
        } else {
          log('${user!.statusCode}', name: 'cached userLoginData 5');
        }
      }
    } catch (er) {
      log('$er', name: 'The error while loading data');
      toastMessage(message: 'Connection error. Server is under maintanance');
    }
  }

  List<GetArtistsWithSongs> _getArtistsWithSongsList = [];

  List<GetArtistsWithSongs> get getArtistsWithSongsList =>
      _getArtistsWithSongsList;

  set getArtistsWithSongsList(List<GetArtistsWithSongs> value) {
    _getArtistsWithSongsList = value;
    notifyListeners();
  }

  Future<List<GetArtistsWithSongs>?> getAllArtistsWithSongs() async {
    final data = await ApiCalls().getAllArtistsWithSongs();

    if (data != null && data.statusCode == 200) {
      final allSongs = getArtistsWithSongsFromJson(data.body);

      log('$allSongs', name: 'All songs');

      getArtistsWithSongsList = allSongs;
      return allSongs;
    } else {
      log('${data!.statusCode}', name: 'Failed all songs');
      return null;
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
    final data = await ApiCalls().checkSongIdAddedOrNot(
      songId: songId,
      userId: userData.userId,
    );
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

    if (data != null && data.statusCode == 200) {
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

  ConnectivityResult _connectivityResult = ConnectivityResult.other;

  ConnectivityResult get connectivityResult => _connectivityResult;

  set connectivityResult(ConnectivityResult value) {
    _connectivityResult = value;
    notifyListeners();
  }

  Future<bool> updateRatings({required int rating}) async {
    final userId = userData.userId;
    final res = await ApiCalls().updateRating(userId: userId, rating: rating);
    if (res.statusCode == 200) {
      await getRatings();
      return true;
    } else {
      return false;
    }
  }

  int _userGivenRating = 0;

  int get userGivenRating => _userGivenRating;

  set userGivenRating(int value) {
    _userGivenRating = value;
    notifyListeners();
  }

  Future getRatings() async {
    final userId = userData.userId;
    final res = await ApiCalls().getRating(userId: userId);
    final data = json.decode(res.body);
    userGivenRating = int.parse(data['ratings'].toString());
    log('$userGivenRating', name: 'The res for get Rating');
    return res;
  }

  Future<bool> updateFeedback({required String message}) async {
    final userId = userData.userId;
    final res =
        await ApiCalls().updateFeedback(userId: userId, message: message);
    if (res.statusCode == 200) {
      await reportedIssuesById();
      return true;
    } else {
      return false;
    }
  }

  List<UserReportedIssuesModel> _reportedIssue = [];

  List<UserReportedIssuesModel> get reportedIssue => _reportedIssue;

  set reportedIssue(List<UserReportedIssuesModel> value) {
    _reportedIssue = value;
    notifyListeners();
  }

  Future reportedIssuesById() async {
    final userId = userData.userId;
    final res = await ApiCalls().getUserReportedIssuesById(userId: userId);
    final data = userReportedIssuesModelFromJson(res.body);
    reportedIssue = data;
  }
}

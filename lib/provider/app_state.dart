import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:glorify_god/models/profile_models/user_reported_isses_model.dart';
import 'package:glorify_god/models/search_model.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/models/song_models/check_artist_login_with_email_model.dart';
import 'package:glorify_god/models/songs_modal.dart';
import 'package:glorify_god/models/user_models/user_login_response_model.dart';
import 'package:glorify_god/src/api/api_calls.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AppState with ChangeNotifier {
  bool _isGuestUser = false;

  bool get isGuestUser => _isGuestUser;

  set isGuestUser(bool value) {
    _isGuestUser = value;
    notifyListeners();
  }

  AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  set audioPlayer(AudioPlayer value) {
    _audioPlayer = value;
    notifyListeners();
  }

  Song emptySongData = Song(
    songId: 0,
    artistUID: 0,
    videoUrl: '',
    title: '',
    artist: '',
    artUri: '',
    lyricist: '',
    credits: '',
    otherData: '',
    ytTitle: '',
    ytUrl: '',
    ytImage: '',
    createdAt: DateTime.now(),
  );

  Song _songData = Song(
    songId: 0,
    artistUID: 0,
    videoUrl: '',
    title: '',
    artist: '',
    artUri: '',
    lyricist: '',
    credits: '',
    otherData: '',
    ytTitle: '',
    ytUrl: '',
    ytImage: '',
    createdAt: DateTime.now(),
  );

  Song get songData => _songData;

  set songData(Song value) {
    _songData = value;
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
    provider: '',
    // device: Device(
    //   uuid: '',
    //   platform: '',
    //   deviceName: '',
    //   versionBaseOs: '',
    //   manufacture: '',
    //   model: '',
    //   isPhysicalDevice: true,
    // ),
  );

  UserLoginResponseModel get userData => _userData;

  set userData(UserLoginResponseModel value) {
    _userData = value;
    notifyListeners();
  }

  Future initiallySetUserDataGlobally(dynamic userLogInData) async {
    log('$userLogInData', name: 'cached userLoginData');

    try {
      if (userLogInData != null) {
        final toJson = jsonEncode(userLogInData);
        final logIn = userLoginResponseModelFromJson(toJson);
        log('$userLogInData', name: 'cached userLoginData --');
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
      // toastMessage(message: 'Connection error. Server is under maintenance');
    }
  }

  // List<GetArtistsWithSongs> _getArtistsWithSongsList = [];
  //
  // List<GetArtistsWithSongs> get getArtistsWithSongsList =>
  //     _getArtistsWithSongsList;
  //
  // set getArtistsWithSongsList(List<GetArtistsWithSongs> value) {
  //   _getArtistsWithSongsList = value;
  //   notifyListeners();
  // }

  Future<List<GetArtistsWithSongs>?> getAllArtistsWithSongs(
      {required List<int> selectedList}) async {
    final data =
        await ApiCalls().getArtistWithSongsOnChoice(selectedList: selectedList);

    if (data != null && data.statusCode == 200) {
      final allSongs = getArtistsWithSongsFromJson(data.body);
      log('$allSongs', name: 'All songs');
      return allSongs;
    } else {
      log('${data!.statusCode}', name: 'Failed all songs');
      return null;
    }
  }

  bool _isSongFavourite = false;

  bool get isSongFavourite => _isSongFavourite;

  set isSongFavourite(bool value) {
    _isSongFavourite = value;
    notifyListeners();
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
    log(
      '${data.statusCode} && ${data.body}',
      name: 'checkFavourites status code',
    );
    if (data.statusCode == 200) {
      if (data.body.contains('false')) {
        isSongFavourite = false;
        return false;
      } else {
        isSongFavourite = true;
        return true;
      }
    } else {
      return false;
    }
  }

  // List<GetFavouritesModel> _likedSongsList = [];
  //
  // List<GetFavouritesModel> get likedSongsList => _likedSongsList;
  //
  // set likedSongsList(List<GetFavouritesModel> value) {
  //   _likedSongsList = value;
  //   notifyListeners();
  // }

  // Future<void> likedSongs() async {
  //   final data = await ApiCalls().getFavourites(userId: userData.userId);
  //
  //   if (data != null && data.statusCode == 200) {
  //     final list = getFavouritesModelFromJson(data.body);
  //
  //   } else {
  //
  //   }
  // }

  List<SearchModel> _searchList = [];

  List<SearchModel> get searchList => _searchList;

  set searchList(List<SearchModel> value) {
    _searchList = value;
    notifyListeners();
  }

  Future<List<SearchModel>> search({required String text}) async {
    final res = await ApiCalls().searchApi(text: text);

    if (res != null && res.statusCode == 200) {
      final searchedList = searchModelFromJson(res.body);
      searchList = searchedList;
      return searchedList;
    } else {
      searchList = <SearchModel>[];
      log('from app state it reached to else case');
      return searchList;
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
    if (res != null && res.statusCode == 200) {
      log(
        '${res.body} & ${res.statusCode}',
        name: 'The json body for the app rating call',
      );
      final data = json.decode(res.body);
      userGivenRating = int.parse(data['ratings'].toString());
      log('$userGivenRating', name: 'The res for get Rating');
      return res;
    } else {
      userGivenRating = 0;
      log('Something went wrong');
      // toastMessage(message: 'Connection error.');
    }
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

  Future<bool> acceptedPolicyById({required bool check}) async {
    final userId = userData.userId;
    final res =
        await ApiCalls().acceptedPolicyById(userId: userId, check: check);
    log(
      '${res.statusCode} - b ${res.body}',
      name: 'acceptedPolicyById response',
    );
    if (res.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkUserAcceptedPolicyById() async {
    final userId = userData.userId;
    final res = await ApiCalls().checkUserAcceptedPolicyById(userId: userId);
    log(
      '${res.statusCode} - b ${res.body}',
      name: 'checkUserAcceptedPolicyById response',
    );
    if (res.statusCode == 200) {
      return res.body.contains('true') ? true : false;
    } else {
      return res.body.contains('true') ? true : false;
    }
  }

  Future<bool> removeUserFromPrivacyPolicyById() async {
    final userId = userData.userId;
    final res =
        await ApiCalls().removeUserFromPrivacyPolicyById(userId: userId);
    log('${res.statusCode}', name: 'removeUserFromPrivacyPolicyById response');
    if (res.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  CheckArtistLoginDataByEmailModel? _artistLoginDataByEmail;

  CheckArtistLoginDataByEmailModel? get artistLoginDataByEmail =>
      _artistLoginDataByEmail;

  set artistLoginDataByEmail(CheckArtistLoginDataByEmailModel? value) {
    _artistLoginDataByEmail = value;
    notifyListeners();
  }

  Future checkArtistLoginDataByEmail() async {
    if (userData.email.isNotEmpty) {
//<-- Some may login with mobile number at that time there wont be email so -->/
      final data = await ApiCalls().checkArtistLoginDataByEmail(
        email: userData.email,
      );

      if (data != null) {
        final body = data.body;

        final decode = json.decode(body);
        log('Is this coming here 21 $decode');

        final status = decode['status'];

        log('Is this coming here 21.1 $status');

        if (status) {
          final artistsData =
              checkArtistLoginDataByEmailModelFromJson(data.body);
          artistLoginDataByEmail = artistsData;
        } else {
          artistLoginDataByEmail = null;
        }
      } else {
        log('Is this coming here 22');
        artistLoginDataByEmail = null;
      }
    }
  }
}

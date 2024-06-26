import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:glorify_god/models/artists_model/artists_list_model.dart';
import 'package:glorify_god/models/user_models/user_login_response_model.dart';
import 'package:glorify_god/src/api/end_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/admob/v1.dart' as adMob;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiCalls {
  String authorization = 'Authorization';
  final header = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<String> getToken() async {
    final jwtToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    log(jwtToken.toString(), name: 'jwtToken jwtToken');
    return jwtToken!;
  }

  Future<UserLoginResponseModel?> logIn({
    String email = '',
    String displayName = '',
    String profileUrl = '',
    int dob = 0,
    String firebaseId = '',
    String mobileNumber = '',
    String city = '',
    String addressLine = '',
    String postalCode = '',
    String citizenshipCountry = '',
    String country = '',
    String state = '',
    String passportNumber = '',
    String fcmToken = '',
    String timeZone = '',
    String gender = 'UNKNOWN',
    String provider = 'GOOGLE',
  }) async {
    try {
      final body = {
        'email': email,
        'display_name': displayName,
        'profile_url': profileUrl,
        'dob': dob,
        'firebase_id': firebaseId,
        'mobile_number': mobileNumber,
        'city': city,
        'address_line': addressLine,
        'postal_code': postalCode,
        'citizenship_country': citizenshipCountry,
        'country': country,
        'state': state,
        'passport_number': passportNumber,
        'fcmToken': fcmToken,
        'timeZone': timeZone,
        'provider': provider,
      };

      log(json.encode(body), name: 'Login request');

      final loginEndpoint = '$loginUrl?gender=$gender';

      final loginResponse = await http.post(
        Uri.parse(loginEndpoint),
        headers: header,
        body: json.encode(body),
      );

      if (loginResponse.statusCode == 200) {
        final response = userLoginResponseModelFromJson(loginResponse.body);
        log(loginResponse.body, name: 'User login response from api calls');
        return response;
      } else {
        log(
          '${loginResponse.statusCode}\n'
          '${loginResponse.body}',
          name: 'login call res status',
        );
        return null;
      }
    } catch (er) {
      log(er.toString(), name: 'The error');
      rethrow;
    }
  }

  Future<http.Response?> getUserById({required int userId}) async {
    final url = '$getUserByIDUrl/$userId';
    final token = await getToken();
    log(token, name: 'token to getUserById');
    try {
      final user = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      log(user.body, name: 'the user by id 1');

      if (user.statusCode == 200) {
        return user;
      } else {
        return null;
      }
    } catch (er) {
      log(er.toString(), name: 'The error from the get call');
      rethrow;
    }
  }

  Future<List<ArtistsListModel>> getAllArtists() async {
    final token = await getToken();

    try {
      final getArtistsList = await http.get(
        Uri.parse(getArtistsListUrl),
        headers: {'Content-Type': 'application/json', authorization: token},
      );

      if (getArtistsList.statusCode == 200) {
        final artistsList = artistsListModelFromJson(getArtistsList.body);
        log('$artistsList', name: 'getAllArtists response');
        return artistsList;
      } else {
        log('', name: 'getAllArtists else call again');
        return <ArtistsListModel>[];
      }
    } catch (e) {
      log('$e', name: 'getAllArtistsWithSongs error');
      rethrow;
    }
  }

  // Future<http.Response?> getAllArtistsWithSongs() async {
  //   log(getArtistWithSongsUrl, name: 'getArtistWithSongsUrl url');
  //   final token = await getToken();
  //   try {
  //     final response = await http.get(
  //       Uri.parse(getArtistWithSongsUrl),
  //       headers: {'Content-Type': 'application/json', authorization: token},
  //     );
  //     return response;
  //   } catch (e) {
  //     log('$e', name: 'getAllArtistsWithSongs error');
  //     return null;
  //   }
  // }

  Future<http.Response?> getArtistWithSongsOnChoice({
    required List<int> selectedList,
  }) async {
    log(getArtistWithSongsOnChoiceUrl, name: 'getArtistWithSongsUrl url 2');
    final token = await getToken();

    final body = json.encode(selectedList);
    log(body, name: 'getArtistWithSongsOnChoice body');
    try {
      final response = await http.post(
        Uri.parse(getArtistWithSongsOnChoiceUrl),
        body: body,
        headers: {'Content-Type': 'application/json', authorization: token},
      );
      if (response.statusCode == 200) {
        log(response.body, name: 'getArtistWithSongsOnChoice response');
        return response;
      } else {
        return null;
      }
    } catch (e) {
      log('$e', name: 'getAllArtistsWithSongs error');
      return null;
    }
  }

  /// addFavourites
  Future<http.Response> addFavourites({
    required int userId,
    required int songId,
  }) async {
    final token = await getToken();
    log('$userId - $songId', name: 'Add fav Request');
    try {
      final url = '$addFavouritesUrl?userId=$userId&songId=$songId';

      final add = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', authorization: token},
      );

      log('${add.statusCode}', name: 'add fav response');
      return add;
    } catch (e) {
      log('$e', name: 'addFavourites error');
      rethrow;
    }
  }

  /// addFavourites
  Future<http.Response> unFavourites({
    required int userId,
    required int songId,
  }) async {
    final token = await getToken();
    log('$userId - $songId', name: 'un fav Request');
    try {
      final url = '$unFavouritesUrl?userId=$userId&songId=$songId';

      final add = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', authorization: token},
      );

      log('${add.statusCode}', name: 'un fav response');

      return add;
    } catch (e) {
      log('$e', name: 'unFavourites error');
      rethrow;
    }
  }

  Future<http.Response> checkSongIdAddedOrNot({
    required int songId,
    required int userId,
  }) async {
    final token = await getToken();
    final url = '$checkFavUrl?userId=$userId&songId=$songId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', authorization: token},
      );
      return response;
    } catch (e) {
      log('$e', name: 'checkSongIdAddedOrNot error');
      rethrow;
    }
  }

  Future<http.Response?> getFavourites({required int userId}) async {
    final token = await getToken();
    final uri = '$getFavouritesUrl?userId=$userId';
    log(uri, name: 'getFavourites request sending');
    try {
      final response = await http.get(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json', authorization: token},
      );
      log('${response.statusCode}', name: 'getFavourites response');
      return response;
    } catch (e) {
      log('$e', name: 'getFavourites error');
      return null;
    }
  }

  Future<http.Response?> searchApi({
    required String text,
  }) async {
    log(text, name: 'searched text is');
    final token = await getToken();
    const uri = searchUrl;
    final body = {
      "query": text,
    };
    log('$uri -', name: 'search api url or request');
    try {
      final response = await http.post(
        Uri.parse(uri),
        body: json.encode(body),
        headers: {'Content-Type': 'application/json', authorization: token},
      );
      log('${response.statusCode}', name: 'searched response');
      return response;
    } catch (e) {
      log('$e', name: 'checkSongIdAddedOrNot error');
      return null;
    }
  }

  Future<http.Response> getSongs() async {
    final token = await getToken();
    try {
      final response = await http.get(
        Uri.parse(getAllSongs),
        headers: {'Content-Type': 'application/json', authorization: token},
      );

      return response;
    } catch (e) {
      log('$e', name: 'getSongs error');
      rethrow;
    }
  }

  Future<http.Response> updateRating({
    required int userId,
    required int rating,
  }) async {
    final token = await getToken();
    final body = {
      "userId": userId,
      "ratings": rating,
      "createdAt": "${DateTime.now()}",
    };
    final requestBody = json.encode(body);
    const uri = updateRatingUrl;
    final theHeaders = {
      'Content-Type': 'application/json',
      authorization: token,
    };

    try {
      final res = await http.post(
        Uri.parse(uri),
        headers: theHeaders,
        body: requestBody,
      );
      log('${res.statusCode}', name: 'the res from app state for update');
      return res;
    } catch (e) {
      log('$e', name: 'updateRating error');
      rethrow;
    }
  }

  Future<http.Response?> getRating({
    required int userId,
  }) async {
    final token = await getToken();
    final uri = '$getRatingUrl?userId=$userId';
    log(uri, name: 'getRating url request');
    try {
      final res = await http.get(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json', authorization: token},
      );
      return res;
    } catch (e) {
      log('$e', name: 'getRating error');
      return null;
    }
  }

  Future<http.Response> updateFeedback({
    required int userId,
    required String message,
  }) async {
    const url = feedbackUrl;
    final token = await getToken();
    final body = {
      "userId": userId,
      "feedback": message,
      "createdAt": "${DateTime.now()}",
    };

    log(json.encode(body), name: 'Feedback request');

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', authorization: token},
        body: json.encode(body),
      );

      log('${res.statusCode}', name: 'feedback response');

      return res;
    } catch (e) {
      log('$e', name: 'updateFeedback error');
      rethrow;
    }
  }

  Future<http.Response> getUserReportedIssuesById({required int userId}) async {
    final url = '$getUserReportedIssuesByIdUrl?userId=$userId';
    final token = await getToken();
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', authorization: token},
      );

      return res;
    } catch (e) {
      log('$e', name: 'getUserReportedById error');
      rethrow;
    }
  }

  Future<http.Response> acceptedPolicyById({
    required int userId,
    required bool check,
  }) async {
    final url = '$privacyPolicyUrl/?userId=$userId&check=$check';
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', authorization: token},
      );
      log(res.body, name: 'acceptedPolicyById from api services');
      return res;
    } catch (e) {
      log('$e', name: 'acceptedPolicyById error');
      rethrow;
    }
  }

  Future<http.Response> checkUserAcceptedPolicyById({
    required int userId,
  }) async {
    final url = '$privacyPolicyAcceptedUrl?userId=$userId';
    final token = await getToken();
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', authorization: token},
      );

      return res;
    } catch (e) {
      log('$e', name: 'getUserReportedById error');
      rethrow;
    }
  }

  Future<http.Response> removeUserFromPrivacyPolicyById({
    required int userId,
  }) async {
    final url = '$removeUserFromPrivacyPolicyUrl?userId=$userId';
    final token = await getToken();
    try {
      final res = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', authorization: token},
      );
      log(
        '${res.body} - ${res.statusCode}',
        name: 'removeUserFromPrivacyPolicyById response On success ',
      );
      return res;
    } catch (e) {
      log('$e', name: 'removeUserFromPrivacyPolicyById error');
      rethrow;
    }
  }

  Future<http.Response> createArtistsSongData({
    required int artistId,
    required DateTime createdAt,
  }) async {
    const url = addArtistsSongDataByIdUrl;
    final token = await getToken();

    String formattedDate =
        '${DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(createdAt.toUtc())}Z';

    final body = {
      "artistsId": artistId,
      "createdAt": formattedDate,
      "streamCount": 1,
    };
    final jsonBody = json.encode(body);

    log('$body\n$jsonBody', name: 'createArtistsSongData request body');

    try {
      final data = await http.post(
        Uri.parse(url),
        body: jsonBody,
        headers: {'Content-Type': 'application/json', authorization: token},
      );
      log(data.body, name: 'createArtistsSongData response');
      return data;
    } catch (e) {
      log('$e', name: 'createArtistsSongData error');
      rethrow;
    }
  }

  Future<http.Response> getArtistsSongDataById({
    required int artistId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    String formattedStartDate =
        DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(startDate);
    String formattedEndDate =
        DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(endDate);
    final url =
        '$getArtistsSongDataByIdUrl?artistId=$artistId&startDate=$formattedStartDate&endDate=$formattedEndDate';

    log(url, name: 'getArtistsSongDataById request url');

    final token = await getToken();

    try {
      final data = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', authorization: token},
      );
      return data;
    } catch (e) {
      log('$e', name: 'getArtistsSongDataById error');
      rethrow;
    }
  }

  Future<http.Response?> checkArtistLoginDataByEmail({
    required String email,
  }) async {
    const url = checkArtistLoginDataByIdUrl;
    final token = await getToken();

    final body = {"email": email};

    log('$body', name: 'checkArtistLoginDataByEmail request');

    try {
      final data = await http.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: {'Content-Type': 'application/json', authorization: token},
      );

      log(data.body, name: 'checkArtistLoginDataByEmail response');
      log('Is this coming here 23 ${data.statusCode}');
      if (data.statusCode == 200) {
        return data;
      } else {
        return null;
      }
    } catch (e) {
      log('$e', name: 'checkArtistLoginDataByEmail error');
      rethrow;
    }
  }

  Future fetchAdMobData() async {
    final token = await getToken();
    const parent = 'accounts/pub-9747187444998835';
    const url =
        'https://admob.googleapis.com/v1beta/$parent/networkReport:generate';
    final body = {
      "reportSpec": {
        "dateRange": {
          "startDate": {"year": 2024, "month": 1, "day": 1},
          "endDate": {"year": 2024, "month": 4, "day": 28},
        },
        "dimensions": ["DATE"],
        "metrics": ["ESTIMATED_EARNINGS"],
      },
    };

    try {
      final data = await http.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final decodeData = json.decode(data.body);
      log('${data.statusCode} - $decodeData', name: 'fetchAdMobData response');
    } catch (e) {
      log('$e', name: 'fetchAdMobData error');
      rethrow;
    }
  }

  Future fetchAdMobReport() async {
    const parent = 'accounts/pub-9747187444998835';
    const jsonKeyFilePath = 'lib/config/service_account_key.json';
    final jsonKeyFileContent = await File(jsonKeyFilePath).readAsString();
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(json.decode(jsonKeyFileContent));
    try {
      final client = await clientViaServiceAccount(
        serviceAccountCredentials,
        [
          'https://www.googleapis.com/auth/admob.readonly',
          'https://www.googleapis.com/auth/admob.report',
        ],
      );

      final adMobApi = adMob.AdMobApi(client);

      final netWorkReportRequest = adMob.GenerateNetworkReportRequest()
        ..reportSpec = adMob.NetworkReportSpec()
        ..reportSpec!.dateRange = adMob.DateRange()
        ..reportSpec!.dateRange!.startDate = adMob.Date()
        ..reportSpec!.dateRange!.startDate!.year = 2024
        ..reportSpec!.dateRange!.startDate!.month = 1
        ..reportSpec!.dateRange!.startDate!.day = 1
        ..reportSpec!.dateRange!.endDate = adMob.Date()
        ..reportSpec!.dateRange!.endDate!.year = 2024
        ..reportSpec!.dateRange!.endDate!.month = 4
        ..reportSpec!.dateRange!.endDate!.day = 28
        ..reportSpec!.dimensions = ['DATE']
        ..reportSpec!.metrics = ['ESTIMATED_EARNINGS'];

      final response = await adMobApi.accounts.networkReport
          .generate(netWorkReportRequest, parent);

      log('$response', name: 'fetchAdMobReport response');
    } catch (e) {
      log('$e', name: 'fetchAdMobReport error');
      rethrow;
    }
  }

  Future fetchAdMobReport2() async {
    const parent = 'accounts/ACCOUNT_ID';
    try {
      final client = await clientViaUserConsent(
          ClientId(
            'CLIENT_ID',
            '',
          ),
          [
            'https://www.googleapis.com/auth/admob.readonly',
            'https://www.googleapis.com/auth/admob.report',
          ], (uri) {
        log(uri, name: 'Click it');
      });

      final adMobApi = adMob.AdMobApi(client);

      final netWorkReportRequest = adMob.GenerateNetworkReportRequest()
        ..reportSpec = adMob.NetworkReportSpec()
        ..reportSpec!.dateRange = adMob.DateRange()
        ..reportSpec!.dateRange!.startDate = adMob.Date()
        ..reportSpec!.dateRange!.startDate!.year = 2024
        ..reportSpec!.dateRange!.startDate!.month = 1
        ..reportSpec!.dateRange!.startDate!.day = 1
        ..reportSpec!.dateRange!.endDate = adMob.Date()
        ..reportSpec!.dateRange!.endDate!.year = 2024
        ..reportSpec!.dateRange!.endDate!.month = 4
        ..reportSpec!.dateRange!.endDate!.day = 28
        ..reportSpec!.dimensions = ['DATE']
        ..reportSpec!.metrics = ['ESTIMATED_EARNINGS'];

      final response = await adMobApi.accounts.networkReport
          .generate(netWorkReportRequest, parent);

      log('$response', name: 'fetchAdMobReport response');
    } catch (e) {
      log('$e', name: 'fetchAdMobReport error');
      rethrow;
    }
  }
}

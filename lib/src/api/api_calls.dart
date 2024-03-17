import 'dart:convert';
import 'dart:developer';
import 'package:glorify_god/models/user_models/user_login_response_model.dart';
import 'package:glorify_god/src/api/end_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiCalls {
  String authorization = 'Authorization';
  final header = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<String> getToken() async {
    final jwtToken = await FirebaseAuth.instance.currentUser!.getIdToken();
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

      log(json.encode(body),name:'Login request');

      final loginEndpoint = '$loginUrl?gender=$gender';

      final loginResponse = await http.post(
        Uri.parse(loginEndpoint),
        headers: header,
        body: json.encode(body),
      );

      if (loginResponse.statusCode == 200) {
        final response = userLoginResponseModelFromJson(loginResponse.body);
        log(loginResponse.body,
            name: 'User login response from api calls');
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
      final user = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },);

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

  Future<http.Response?> getAllArtistsWithSongs() async {
    log(getArtistWithSongsUrl, name: 'getArtistWithSongsUrl url');
    final token = await getToken();
    try {
      final response = await http.get(
        Uri.parse(getArtistWithSongsUrl),
        headers: {'Content-Type': 'application/json', authorization: token},
      );
      return response;
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
      final response = await http.get(Uri.parse(uri),
          headers: {'Content-Type': 'application/json', authorization: token},);
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
      final response = await http.post(Uri.parse(uri),
          body: json.encode(body),
          headers: {'Content-Type': 'application/json', authorization: token},);
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
      final response = await http.get(Uri.parse(getAllSongs),
          headers: {'Content-Type': 'application/json', authorization: token},);

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
      final res = await http.get(Uri.parse(uri),
          headers: {'Content-Type': 'application/json', authorization: token},);
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
      final res = await http.get(Uri.parse(url),
          headers: {'Content-Type': 'application/json', authorization: token},);

      return res;
    } catch (e) {
      log('$e', name: 'getUserReportedById error');
      rethrow;
    }
  }

  Future<http.Response> acceptedPolicyById(
      {required int userId, required bool check,}) async {
    final url = '$privacyPolicyUrl/?userId=$userId&check=$check';
    final token = await getToken();
    try {
      final res = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json', authorization: token},);
      log(res.body, name: 'acceptedPolicyById from api services');
      return res;
    } catch (e) {
      log('$e', name: 'acceptedPolicyById error');
      rethrow;
    }
  }

  Future<http.Response> checkUserAcceptedPolicyById(
      {required int userId,}) async {
    final url = '$privacyPolicyAcceptedUrl?userId=$userId';
    final token = await getToken();
    try {
      final res = await http.get(Uri.parse(url),
          headers: {'Content-Type': 'application/json', authorization: token},);

      return res;
    } catch (e) {
      log('$e', name: 'getUserReportedById error');
      rethrow;
    }
  }

  Future<http.Response> removeUserFromPrivacyPolicyById(
      {required int userId,}) async {
    final url = '$removeUserFromPrivacyPolicyUrl?userId=$userId';
    final token = await getToken();
    try {
      final res = await http.delete(Uri.parse(url),
          headers: {'Content-Type': 'application/json', authorization: token},);
      log('${res.body} - ${res.statusCode}',
          name: 'removeUserFromPrivacyPolicyById response On success ',);
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

  Future<http.Response?> checkArtistLoginDataByEmail(
      {required String email,}) async {
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
}

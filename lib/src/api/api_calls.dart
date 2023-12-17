import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:glorify_god/models/user_models/user_login_response_model.dart';
import 'package:glorify_god/src/api/end_points.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

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
  }) async {
    var uuId = '';
    var platform = '';
    var deviceName = '';
    var versionBaseOs = '';
    var manufacture = '';
    var model = '';

    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      uuId = iosInfo.identifierForVendor!;
      platform = 'iOS';
      deviceName = iosInfo.name;
      versionBaseOs = iosInfo.systemVersion;
      manufacture = iosInfo.model;
      model = iosInfo.model;
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      uuId = androidInfo.id;
      platform = 'Android';
      deviceName = androidInfo.device;
      versionBaseOs = androidInfo.version.release;
      manufacture = androidInfo.manufacturer;
      model = androidInfo.device;
    }

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
        'device_request': {
          'UUID': uuId,
          'platform': platform,
          'device_name': deviceName,
          'version_base_os': versionBaseOs,
          'manufacture': manufacture,
          'model': model,
          'is_physical_device': true,
        },
      };
      const loginEndpoint = '$loginUrl?gender=MALE';

      final loginResponse = await http.post(
        Uri.parse(loginEndpoint),
        headers: header,
        body: json.encode(body),
      );

      if (loginResponse.statusCode == 200) {
        final response = userLoginResponseModelFromJson(loginResponse.body);
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
      final user =
          await http.get(Uri.parse(url), headers: {'Authorization': token});

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

  Future<http.Response?> createArtist({
    required String artistName,
    required String artistImage,
    String churchName = '',
    required String createdAt,
  }) async {
    const url = createArtistUrl;

    final body = {
      'artistName': artistName,
      'artistImage': artistImage,
      'churchName': churchName,
      'createdAt': createdAt,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: header,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        log(response.body, name: 'createArtist response');
        return response;
      } else {
        log('response in else ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('$e', name: 'createArtist error');
      rethrow;
    }
  }

  Future<http.Response> getAllArtistsWithSongs() async {
    final token = await getToken();
    try {
      final response = await http.get(
        Uri.parse(getArtistWithSongsUrl),
        headers: {authorization: token},
      );
      return response;
    } catch (e) {
      log('$e', name: 'getAllArtistsWithSongs error');
      rethrow;
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
        headers: {authorization: token},
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
        headers: {authorization: token},
      );

      log('${add.statusCode}', name: 'un fav response');

      return add;
    } catch (e) {
      log('$e', name: 'unFavourites error');
      rethrow;
    }
  }

  Future<http.Response> checkSongIdAddedOrNot({required int songId}) async {
    final token = await getToken();
    final url = '$checkFavUrl?songId=$songId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {authorization: token},
      );
      return response;
    } catch (e) {
      log('$e', name: 'checkSongIdAddedOrNot error');
      rethrow;
    }
  }

  Future<http.Response> getFavourites({required int userId}) async {
    final token = await getToken();
    final uri = '$getFavouritesUrl?userId=$userId';
    try {
      final response =
          await http.get(Uri.parse(uri), headers: {authorization: token});
      log('${response.statusCode}', name: 'getFavourites response');
      return response;
    } catch (e) {
      log('$e', name: 'getFavourites error');
      rethrow;
    }
  }

  Future<http.Response> searchApi({
    required String text,
  }) async {
    log(text, name: 'searched text is');
    final token = await getToken();
    final uri = '$searchUrl?query=$text';
    try {
      final response =
          await http.get(Uri.parse(uri), headers: {authorization: token});
      log('${response.statusCode}', name: 'searched response');
      return response;
    } catch (e) {
      log('$e', name: 'checkSongIdAddedOrNot error');
      rethrow;
    }
  }

  Future<http.Response> getSongs() async {
    final token = await getToken();
    try {
      final response = await http
          .get(Uri.parse(getAllSongs), headers: {authorization: token});

      return response;
    } catch (e) {
      log('$e', name: 'getSongs error');
      rethrow;
    }
  }
}

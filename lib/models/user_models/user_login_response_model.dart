// To parse this JSON data, do
//
//     final userLoginResponseModel = userLoginResponseModelFromJson(jsonString)
//     ;

import 'dart:convert';

UserLoginResponseModel userLoginResponseModelFromJson(String str) =>
    UserLoginResponseModel.fromJson(json.decode(str) as Map<String, dynamic>);

String userLoginResponseModelToJson(UserLoginResponseModel data) =>
    json.encode(data.toJson());

class UserLoginResponseModel {
  UserLoginResponseModel({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.profileUrl,
    required this.dob,
    required this.firebaseId,
    required this.mobileNumber,
    required this.city,
    required this.addressLine,
    required this.postalCode,
    required this.citizenshipCountry,
    required this.country,
    required this.state,
    required this.passportNumber,
    required this.fcmToken,
    required this.timeZone,
    required this.gender,
    required this.provider,
    // required this.device,
  });

  factory UserLoginResponseModel.fromJson(Map<String, dynamic> json) =>
      UserLoginResponseModel(
        userId: (json['user_id'] ?? 0) as int,
        email: json['email'].toString(),
        displayName: json['display_name'].toString(),
        profileUrl: json['profile_url'].toString(),
        dob: (json['dob'] ?? 0) as int,
        firebaseId: json['firebase_id'].toString(),
        mobileNumber: json['mobile_number'].toString(),
        city: json['city'].toString(),
        addressLine: json['address_line'].toString(),
        postalCode: json['postal_code'].toString(),
        citizenshipCountry: json['citizenship_country'].toString(),
        country: json['country'].toString(),
        state: json['state'].toString(),
        passportNumber: json['passport_number'].toString(),
        fcmToken: json['fcmToken'].toString(),
        timeZone: json['timeZone'].toString(),
        gender: json['gender'].toString(),
        provider: json['provider'].toString(),
        // device: Device.fromJson(json['device'] as Map<String, dynamic>),
      );
  final int userId;
  final String email;
  final String displayName;
  final String profileUrl;
  final int dob;
  final String firebaseId;
  final String mobileNumber;
  final String city;
  final String addressLine;
  final String postalCode;
  final String citizenshipCountry;
  final String country;
  final String state;
  final String passportNumber;
  final String fcmToken;
  final String timeZone;
  final String gender;
  final String provider;
  // final Device device;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
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
        'gender': gender,
        'provider': provider,
        // 'device': device.toJson(),
      };
}

class Device {
  Device({
    required this.uuid,
    required this.platform,
    required this.deviceName,
    required this.versionBaseOs,
    required this.manufacture,
    required this.model,
    required this.isPhysicalDevice,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        uuid: json['UUID'].toString(),
        platform: json['platform'].toString(),
        deviceName: json['device_name'].toString(),
        versionBaseOs: json['version_base_os'].toString(),
        manufacture: json['manufacture'].toString(),
        model: json['model'].toString(),
        isPhysicalDevice: (json['is_physical_device'] ?? true) as bool,
      );
  final String uuid;
  final String platform;
  final String deviceName;
  final String versionBaseOs;
  final String manufacture;
  final String model;
  final bool isPhysicalDevice;

  Map<String, dynamic> toJson() => {
        'UUID': uuid,
        'platform': platform,
        'device_name': deviceName,
        'version_base_os': versionBaseOs,
        'manufacture': manufacture,
        'model': model,
        'is_physical_device': isPhysicalDevice,
      };
}

// To parse this JSON data, do
//
//     final remoteConfig = remoteConfigFromJson(jsonString);

import 'dart:convert';

RemoteConfig remoteConfigFromJson(String str) =>
    RemoteConfig.fromJson(json.decode(str));

String remoteConfigToJson(RemoteConfig data) => json.encode(data.toJson());

class RemoteConfig {
  final String testAdUnitId;
  final String androidAdUnitId;
  final String playerAndroidAdUnitId;
  final String playerIosAdUnitId;
  final String iosAdUniId;
  final String interstitialAdTestId;
  final String androidInterstitialAdUnitId;
  final int interstitialAdTime;
  final String iosInterstitialAdUnitId;
  final List<BannerMessage> bannerMessages;
  final bool showUpdateBanner;
  final AppUpdateVersions appUpdateVersions;

  RemoteConfig({
    required this.testAdUnitId,
    required this.androidAdUnitId,
    required this.iosAdUniId,
    required this.playerAndroidAdUnitId,
    required this.playerIosAdUnitId,
    required this.interstitialAdTestId,
    required this.androidInterstitialAdUnitId,
    required this.iosInterstitialAdUnitId,
    required this.bannerMessages,
    required this.showUpdateBanner,
    required this.appUpdateVersions,
    required this.interstitialAdTime,
  });

  factory RemoteConfig.fromJson(Map<String, dynamic> json) => RemoteConfig(
        testAdUnitId: json["testAdUnitId"].toString(),
        androidAdUnitId: json["androidAdUnitId"].toString(),
        iosAdUniId: json["iosAdUniId"].toString(),
        playerAndroidAdUnitId: json["playerAndroidAdUnitId"].toString(),
        playerIosAdUnitId: json["playerIosAdUnitId"].toString(),
        interstitialAdTestId: json["interstitialAdTestId"].toString(),
        androidInterstitialAdUnitId:
            json["androidInterstitialAdUnitId"].toString(),
        iosInterstitialAdUnitId: json["iosInterstitialAdUnitId"].toString(),
        interstitialAdTime: int.parse(json["interstitialAdTime"].toString()),
        showUpdateBanner: json["showUpdateBanner"] ?? false,
        bannerMessages: List<BannerMessage>.from(
          json["bannerMessages"].map((x) => BannerMessage.fromJson(x)),
        ),
        appUpdateVersions:
            AppUpdateVersions.fromJson(json["appUpdateVersions"]),
      );

  Map<String, dynamic> toJson() => {
        "testAdUnitId": testAdUnitId,
        "androidAdUnitId": androidAdUnitId,
        "iosAdUniId": iosAdUniId,
        "playerAndroidAdUnitId": playerAndroidAdUnitId,
        "playerIosAdUnitId": playerIosAdUnitId,
        "interstitialAdTestId": interstitialAdTestId,
        "androidInterstitialAdUnitId": androidInterstitialAdUnitId,
        "iosInterstitialAdUnitId": iosInterstitialAdUnitId,
        "showUpdateBanner": showUpdateBanner,
        "interstitialAdTime": interstitialAdTime,
        "bannerMessages":
            List<dynamic>.from(bannerMessages.map((x) => x.toJson())),
        "appUpdateVersions": appUpdateVersions.toJson(),
      };
}

class AppUpdateVersions {
  final String androidLatestVersion;
  final String iosLatestVersion;

  AppUpdateVersions({
    required this.androidLatestVersion,
    required this.iosLatestVersion,
  });

  factory AppUpdateVersions.fromJson(Map<String, dynamic> json) =>
      AppUpdateVersions(
        androidLatestVersion: json["androidLatestVersion"].toString(),
        iosLatestVersion: json["iosLatestVersion"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "androidLatestVersion": androidLatestVersion,
        "iosLatestVersion": iosLatestVersion,
      };
}

class BannerMessage {
  final String message;
  final String verses;
  final String imageUrl;

  BannerMessage({
    required this.message,
    required this.verses,
    required this.imageUrl,
  });

  factory BannerMessage.fromJson(Map<String, dynamic> json) => BannerMessage(
        message: json["message"].toString(),
        verses: json["verses"].toString(),
        imageUrl: json["imageUrl"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "verses": verses,
        "imageUrl": imageUrl,
      };
}

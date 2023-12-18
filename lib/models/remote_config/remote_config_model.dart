// To parse this JSON data, do
//
//     final remoteConfig = remoteConfigFromJson(jsonString);

import 'dart:convert';

RemoteConfig remoteConfigFromJson(String str) =>
    RemoteConfig.fromJson(json.decode(str));

String remoteConfigToJson(RemoteConfig data) => json.encode(data.toJson());

class RemoteConfig {
  final String adUnitId;
  final List<BannerMessage> bannerMessages;

  RemoteConfig({
    required this.adUnitId,
    required this.bannerMessages,
  });

  factory RemoteConfig.fromJson(Map<String, dynamic> json) => RemoteConfig(
        adUnitId: json["adUnitId"].toString(),
        bannerMessages: List<BannerMessage>.from(
            json["bannerMessages"].map((x) => BannerMessage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "adUnitId": adUnitId,
        "bannerMessages":
            List<dynamic>.from(bannerMessages.map((x) => x.toJson())),
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

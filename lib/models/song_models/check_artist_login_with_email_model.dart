//     final checkArtistLoginDataByEmailModel = checkArtistLoginDataByEmailModelFromJson(jsonString);

import 'dart:convert';

CheckArtistLoginDataByEmailModel checkArtistLoginDataByEmailModelFromJson(String str) => CheckArtistLoginDataByEmailModel.fromJson(json.decode(str));

String checkArtistLoginDataByEmailModelToJson(CheckArtistLoginDataByEmailModel data) => json.encode(data.toJson());

class CheckArtistLoginDataByEmailModel {
  final String artistImage;
  final String churchName;
  final DateTime createAt;
  final int artistUid;
  final String artistName;
  final String language;
  final String email;

  CheckArtistLoginDataByEmailModel({
    required this.artistImage,
    required this.churchName,
    required this.createAt,
    required this.artistUid,
    required this.artistName,
    required this.language,
    required this.email,
  });

  factory CheckArtistLoginDataByEmailModel.fromJson(Map<String, dynamic> json) => CheckArtistLoginDataByEmailModel(
    artistImage: json["artistImage"],
    churchName: json["churchName"],
    createAt: DateTime.parse(json["createAt"]),
    artistUid: json["artistUID"],
    artistName: json["artistName"],
    language: json["language"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "artistImage": artistImage,
    "churchName": churchName,
    "createAt": createAt.toIso8601String(),
    "artistUID": artistUid,
    "artistName": artistName,
    "language": language,
    "email": email,
  };
}

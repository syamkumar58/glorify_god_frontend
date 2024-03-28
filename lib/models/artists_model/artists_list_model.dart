//     final artistsListModel = artistsListModelFromJson(jsonString);

import 'dart:convert';

List<ArtistsListModel> artistsListModelFromJson(String str) =>
    List<ArtistsListModel>.from(
        json.decode(str).map((x) => ArtistsListModel.fromJson(x)));

String artistsListModelToJson(List<ArtistsListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ArtistsListModel {
  final String churchName;
  final int artistUid;
  final String email;
  final String artistName;
  final String artistImage;
  final String language;
  final DateTime createAt;

  ArtistsListModel({
    required this.churchName,
    required this.artistUid,
    required this.email,
    required this.artistName,
    required this.artistImage,
    required this.language,
    required this.createAt,
  });

  factory ArtistsListModel.fromJson(Map<String, dynamic> json) =>
      ArtistsListModel(
        churchName: json["churchName"],
        artistUid: json["artistUID"],
        email: json["email"],
        artistName: json["artistName"],
        artistImage: json["artistImage"],
        language: json["language"],
        createAt: DateTime.parse(json["createAt"]),
      );

  Map<String, dynamic> toJson() => {
        "churchName": churchName,
        "artistUID": artistUid,
        "email": email,
        "artistName": artistName,
        "artistImage": artistImage,
        "language": language,
        "createAt": createAt.toIso8601String(),
      };
}

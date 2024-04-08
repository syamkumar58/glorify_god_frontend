// To parse this JSON data, do
//
//     final getFavouritesModel = getFavouritesModelFromJson(jsonString);
import 'dart:convert';

List<GetFavouritesModel> getFavouritesModelFromJson(String str) =>
    List<GetFavouritesModel>.from(
      (json.decode(str) as List<dynamic>)
          .map((x) => GetFavouritesModel.fromJson(x as Map<String, dynamic>)),
    );

String getFavouritesModelToJson(List<GetFavouritesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetFavouritesModel {
  GetFavouritesModel({
    required this.songId,
    required this.artistUID,
    required this.videoUrl,
    required this.artist,
    required this.lyricist,
    required this.credits,
    required this.otherData,
    required this.userId,
    required this.id,
    required this.title,
    required this.artUri,
    required this.createdAt,
    required this.ytUrl,
    required this.ytTitle,
    required this.ytImage,
  });

  factory GetFavouritesModel.fromJson(Map<String, dynamic> json) =>
      GetFavouritesModel(
        songId: int.parse(json['songId'].toString()),
        artistUID: int.parse(json['artistUID'].toString()),
        videoUrl: json['videoUrl'].toString(),
        artist: json['artist'].toString(),
        lyricist: json['lyricist'].toString(),
        credits: json['credits'].toString(),
        otherData: json['otherData'].toString(),
        userId: int.parse(json['userId'].toString()),
        id: int.parse(json['id'].toString()),
        title: json['title'].toString(),
        artUri: json['artUri'].toString(),
        ytTitle: json['ytTitle'].toString(),
        ytUrl: json['ytUrl'].toString(),
        ytImage: json['ytImage'].toString(),
        createdAt: DateTime.parse(json['createdAt'].toString()),
      );
  final int songId;
  final int artistUID;
  final String videoUrl;
  final String artist;
  final String lyricist;
  final String credits;
  final String otherData;
  final int userId;
  final int id;
  final String title;
  final String artUri;
  final DateTime createdAt;
  final String ytUrl;
  final String ytTitle;
  final String ytImage;

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'artistUID': artistUID,
        'videoUrl': videoUrl,
        'artist': artist,
        'lyricist': lyricist,
        'credits': credits,
        'otherData': otherData,
        'userId': userId,
        'id': id,
        'title': title,
        'artUri': artUri,
        'ytTitle': ytTitle,
        'ytUrl': ytUrl,
        'ytImage': ytImage,
        'createdAt': createdAt.toIso8601String(),
      };
}

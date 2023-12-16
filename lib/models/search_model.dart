// To parse this JSON data, do
//
//     final searchModel = searchModelFromJson(jsonString);
import 'dart:convert';

List<SearchModel> searchModelFromJson(String str) => List<SearchModel>.from(
      (json.decode(str) as List<dynamic>)
          .map((x) => SearchModel.fromJson(x as Map<String, dynamic>)),
    );

String searchModelToJson(List<SearchModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SearchModel {
  SearchModel({
    required this.artist,
    required this.songUrl,
    required this.songId,
    required this.lyricist,
    required this.artistUid,
    required this.title,
    required this.artUri,
    required this.createdAt,
    required this.ytUrl,
    required this.ytTitle,
    required this.ytImage,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
        artist: json['artist'].toString(),
        songUrl: json['songUrl'].toString(),
        songId: int.parse(json['songId'].toString()),
        lyricist: json['lyricist'].toString(),
        artistUid: int.parse(json['artistUID'].toString()),
        title: json['title'].toString(),
        artUri: json['artUri'].toString(),
        ytTitle: json['ytTitle'].toString(),
        ytUrl: json['ytUrl'].toString(),
        ytImage: json['ytImage'].toString(),
        createdAt: DateTime.parse(json['createdAt'].toString()),
      );
  final String artist;
  final String songUrl;
  final int songId;
  final String lyricist;
  final int artistUid;
  final String title;
  final String artUri;
  final DateTime createdAt;
  final String ytUrl;
  final String ytTitle;
  final String ytImage;

  Map<String, dynamic> toJson() => {
        'artist': artist,
        'songUrl': songUrl,
        'songId': songId,
        'lyricist': lyricist,
        'artistUID': artistUid,
        'title': title,
        'artUri': artUri,
        'ytTitle': ytTitle,
        'ytUrl': ytUrl,
        'ytImage': ytImage,
        'createdAt': createdAt.toIso8601String(),
      };
}

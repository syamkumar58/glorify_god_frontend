// To parse this JSON data, do
//
//     final songsModel = songsModelFromJson(jsonString);

import 'dart:convert';

List<SongsModel> songsModelFromJson(String str) => List<SongsModel>.from(
      (json.decode(str) as List<dynamic>)
          .map((x) => SongsModel.fromJson(x as Map<String, dynamic>)),
    );

String songsModelToJson(List<SongsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SongsModel {

  SongsModel({
    required this.ytUrl,
    required this.ytTitle,
    required this.ytImage,
    required this.songUrl,
    required this.songId,
    required this.artist,
    required this.lyricist,
    required this.artistUid,
    required this.title,
    required this.artUri,
    required this.createdAt,
  });

  factory SongsModel.fromJson(Map<String, dynamic> json) => SongsModel(
        songUrl: json['songUrl'].toString(),
        ytTitle: json['ytTitle'].toString(),
        ytUrl: json['ytUrl'].toString(),
        ytImage: json['ytImage'].toString(),
        songId: int.parse(json['songId'].toString()),
        artist: json['artist'].toString(),
        lyricist: json['lyricist'].toString(),
        artistUid: int.parse(json['artistUID'].toString()),
        title: json['title'].toString(),
        artUri: json['artUri'].toString(),
        createdAt: DateTime.parse(json['createdAt'].toString()),
      );
  final String songUrl;
  final int songId;
  final String artist;
  final String lyricist;
  final int artistUid;
  final String title;
  final String artUri;
  final String ytUrl;
  final String ytTitle;
  final String ytImage;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'songUrl': songUrl,
        'songId': songId,
        'artist': artist,
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

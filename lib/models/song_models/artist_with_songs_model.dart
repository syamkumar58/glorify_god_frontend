// To parse this JSON data, do
//
//     final getArtistsWithSongs = getArtistsWithSongsFromJson(jsonString);

import 'dart:convert';

List<GetArtistsWithSongs> getArtistsWithSongsFromJson(String str) =>
    List<GetArtistsWithSongs>.from(
      (json.decode(str) as List<dynamic>)
          .map((x) => GetArtistsWithSongs.fromJson(x as Map<String, dynamic>)),
    );

String getArtistsWithSongsToJson(List<GetArtistsWithSongs> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetArtistsWithSongs {
  final int artistUid;
  final String artistName;
  final String artistImage;
  final String churchName;
  final String language;
  final List<Song> songs;

  GetArtistsWithSongs({
    required this.artistUid,
    required this.artistName,
    required this.artistImage,
    required this.churchName,
    required this.language,
    required this.songs,
  });

  factory GetArtistsWithSongs.fromJson(Map<String, dynamic> json) =>
      GetArtistsWithSongs(
        artistUid: int.parse(json['artistUID'].toString()),
        artistName: json['artistName'].toString(),
        artistImage: json['artistImage'].toString(),
        churchName: json['churchName'].toString(),
        language: json['language'].toString(),
        songs: List<Song>.from(
          (json['songs'] as List<dynamic>)
              .map((x) => Song.fromJson(x as Map<String, dynamic>)),
        ),
      );

  Map<String, dynamic> toJson() => {
        'artistUID': artistUid,
        'artistName': artistName,
        'artistImage': artistImage,
        'churchName': churchName,
        'language': language,
        'songs': List<dynamic>.from(songs.map((x) => x.toJson())),
      };
}

class Song {
  final int songId;
  final int artistUID;
  final String songUrl;
  final String title;
  final String artist;
  final String artUri;
  final String lyricist;
  final String ytTitle;
  final String ytUrl;
  final String ytImage;
  final DateTime createdAt;

  Song({
    required this.songId,
    required this.artistUID,
    required this.songUrl,
    required this.title,
    required this.artist,
    required this.artUri,
    required this.lyricist,
    required this.ytTitle,
    required this.ytUrl,
    required this.ytImage,
    required this.createdAt,
  });

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        songId: int.parse(json['songId'].toString()),
        artistUID: int.parse(json['artistUID'].toString()),
        songUrl: json['songUrl'].toString(),
        title: json['title'].toString(),
        artist: json['artist'].toString(),
        artUri: json['artUri'].toString(),
        lyricist: json['lyricist'].toString(),
        ytTitle: json['ytTitle'].toString(),
        ytUrl: json['ytUrl'].toString(),
        ytImage: json['ytImage'].toString(),
        createdAt: DateTime.parse(json['createdAt'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'artistUID': artistUID,
        'songUrl': songUrl,
        'title': title,
        'artist': artist,
        'artUri': artUri,
        'lyricist': lyricist,
        'ytTitle': ytTitle,
        'ytUrl': ytUrl,
        'ytImage': ytImage,
        'createdAt': createdAt.toIso8601String(),
      };
}

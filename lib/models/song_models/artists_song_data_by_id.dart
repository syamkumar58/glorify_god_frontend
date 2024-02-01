//     final getArtistSongsDataByIdModel = getArtistSongsDataByIdModelFromJson(jsonString);

import 'dart:convert';

GetArtistSongsDataByIdModel getArtistSongsDataByIdModelFromJson(String str) =>
    GetArtistSongsDataByIdModel.fromJson(json.decode(str));

String getArtistSongsDataByIdModelToJson(GetArtistSongsDataByIdModel data) =>
    json.encode(data.toJson());

class GetArtistSongsDataByIdModel {
  final List<Datum> data;
  final int totalStreamCount;

  GetArtistSongsDataByIdModel({
    required this.data,
    required this.totalStreamCount,
  });

  factory GetArtistSongsDataByIdModel.fromJson(Map<String, dynamic> json) =>
      GetArtistSongsDataByIdModel(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        totalStreamCount: json["total_stream_count"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "total_stream_count": totalStreamCount,
      };
}

class Datum {
  final int artistsId;
  final DateTime createdAt;
  final int streamCount;
  final int id;

  Datum({
    required this.artistsId,
    required this.createdAt,
    required this.streamCount,
    required this.id,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        artistsId: json["artistsId"],
        createdAt: DateTime.parse(json["createdAt"]),
        streamCount: json["streamCount"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "artistsId": artistsId,
        "createdAt": createdAt.toIso8601String(),
        "streamCount": streamCount,
        "id": id,
      };
}

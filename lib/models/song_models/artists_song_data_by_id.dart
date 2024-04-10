//     final getArtistSongsDataByIdModel = getArtistSongsDataByIdModelFromJson(jsonString);

import 'dart:convert';

GetArtistSongsDataByIdModel getArtistSongsDataByIdModelFromJson(String str) => GetArtistSongsDataByIdModel.fromJson(json.decode(str));

String getArtistSongsDataByIdModelToJson(GetArtistSongsDataByIdModel data) => json.encode(data.toJson());

class GetArtistSongsDataByIdModel {
  final List<Datum> data;
  final int totalStreamCount;
  final int streamsCompletedAfterMonetization;
  final bool monetization;

  GetArtistSongsDataByIdModel({
    required this.data,
    required this.totalStreamCount,
    required this.streamsCompletedAfterMonetization,
    required this.monetization,
  });

  factory GetArtistSongsDataByIdModel.fromJson(Map<String, dynamic> json) => GetArtistSongsDataByIdModel(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    totalStreamCount: json["total_stream_count"],
    streamsCompletedAfterMonetization: json["streams_completed_after_monetization"],
    monetization: json["monetization"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "total_stream_count": totalStreamCount,
    "streams_completed_after_monetization": streamsCompletedAfterMonetization,
    "monetization": monetization,
  };
}

class Datum {
  final int streamCount;
  final int id;
  final int artistsId;
  final DateTime createdAt;

  Datum({
    required this.streamCount,
    required this.id,
    required this.artistsId,
    required this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    streamCount: json["streamCount"],
    id: json["id"],
    artistsId: json["artistsId"],
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "streamCount": streamCount,
    "id": id,
    "artistsId": artistsId,
    "createdAt": createdAt.toIso8601String(),
  };
}

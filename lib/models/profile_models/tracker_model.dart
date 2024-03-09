//     final trackerModel = trackerModelFromJson(jsonString);

import 'dart:convert';

TrackerModel trackerModelFromJson(String str) => TrackerModel.fromJson(json.decode(str));

String trackerModelToJson(TrackerModel data) => json.encode(data.toJson());

class TrackerModel {
  final int artistId;
  final int totalSongsCompleted;

  TrackerModel({
    required this.artistId,
    required this.totalSongsCompleted,
  });

  factory TrackerModel.fromJson(Map<String, dynamic> json) => TrackerModel(
    artistId: json["artistId"],
    totalSongsCompleted: json["totalSongsCompleted"],
  );

  Map<String, dynamic> toJson() => {
    "artistId": artistId,
    "totalSongsCompleted": totalSongsCompleted,
  };
}

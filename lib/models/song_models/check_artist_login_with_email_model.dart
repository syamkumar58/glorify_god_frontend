//     final checkArtistLoginDataByEmailModel = checkArtistLoginDataByEmailModelFromJson(jsonString);

import 'dart:convert';

CheckArtistLoginDataByEmailModel checkArtistLoginDataByEmailModelFromJson(
        String str,) =>
    CheckArtistLoginDataByEmailModel.fromJson(json.decode(str));

String checkArtistLoginDataByEmailModelToJson(
        CheckArtistLoginDataByEmailModel data,) =>
    json.encode(data.toJson());

class CheckArtistLoginDataByEmailModel {
  final bool status;
  final ArtistDetails artistDetails;

  CheckArtistLoginDataByEmailModel({
    required this.status,
    required this.artistDetails,
  });

  factory CheckArtistLoginDataByEmailModel.fromJson(
          Map<String, dynamic> json,) =>
      CheckArtistLoginDataByEmailModel(
        status: json["status"],
        artistDetails: ArtistDetails.fromJson(
            json["artistDetails"] as Map<String, dynamic>,),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "artistDetails": artistDetails.toJson(),
      };
}

class ArtistDetails {
  final String artistName;
  final String churchName;
  final DateTime createAt;
  final int artistUid;
  final String artistImage;
  final String language;
  final String email;

  ArtistDetails({
    required this.artistName,
    required this.churchName,
    required this.createAt,
    required this.artistUid,
    required this.artistImage,
    required this.language,
    required this.email,
  });

  factory ArtistDetails.fromJson(Map<String, dynamic> json) => ArtistDetails(
        artistName: json["artistName"].toString(),
        churchName: json["churchName"].toString(),
        createAt: json["createAt"].toString().isNotEmpty
            ? DateTime.parse(json["createAt"].toString())
            : DateTime.now(),
        artistUid: int.parse(json["artistUID"].toString()),
        artistImage: json["artistImage"].toString(),
        language: json["language"].toString(),
        email: json["email"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "artistName": artistName,
        "churchName": churchName,
        "createAt": createAt.toIso8601String(),
        "artistUID": artistUid,
        "artistImage": artistImage,
        "language": language,
        "email": email,
      };
}

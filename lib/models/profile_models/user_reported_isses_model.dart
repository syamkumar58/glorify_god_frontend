//     final userReportedIssuesModel = userReportedIssuesModelFromJson(jsonString);

import 'dart:convert';

List<UserReportedIssuesModel> userReportedIssuesModelFromJson(String str) =>
    List<UserReportedIssuesModel>.from(json.decode(str).map(
        (x) => UserReportedIssuesModel.fromJson(x as Map<String, dynamic>),),);

String userReportedIssuesModelToJson(List<UserReportedIssuesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserReportedIssuesModel {
  final int userId;
  final int id;
  final String feedback;
  final DateTime createdAt;

  UserReportedIssuesModel({
    required this.userId,
    required this.id,
    required this.feedback,
    required this.createdAt,
  });

  factory UserReportedIssuesModel.fromJson(Map<String, dynamic> json) =>
      UserReportedIssuesModel(
        userId: json["userId"],
        id: json["id"],
        feedback: json["feedback"],
        createdAt: DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "id": id,
        "feedback": feedback,
        "createdAt": createdAt.toIso8601String(),
      };
}

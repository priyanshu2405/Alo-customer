// To parse this JSON data, do
//
//     final getProfileModel = getProfileModelFromJson(jsonString);

import 'dart:convert';

GetProfileModel getProfileModelFromJson(String str) => GetProfileModel.fromJson(json.decode(str));

String getProfileModelToJson(GetProfileModel data) => json.encode(data.toJson());

class GetProfileModel {
  bool? success;
  Data? data;

  GetProfileModel({
    this.success,
    this.data,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) => GetProfileModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class Data {
  User? user;

  Data({
    this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
  };
}

class User {
  int? id;
  String? name;
  String? mobile;
  /// Null for users who signed up with mobile + OTP only. Stripe receipts fall
  /// back to the address typed in the payment sheet when this is missing.
  String? email;
  String? profilePhoto;
  bool? isProfileComplete;

  User({
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.profilePhoto,
    this.isProfileComplete,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    mobile: json["mobile"],
    email: json["email"],
    profilePhoto: json["profile_photo"],
    isProfileComplete: json["is_profile_complete"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "mobile": mobile,
    "email": email,
    "profile_photo": profilePhoto,
    "is_profile_complete": isProfileComplete,
  };
}

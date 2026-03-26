// To parse this JSON data, do
//
//     final getRideDetailsModel = getRideDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:alo_ride_app/api_app_folder/screen/my_rides/model/ride_history_model.dart';

GetRideDetailsModel getRideDetailsModelFromJson(String str) => GetRideDetailsModel.fromJson(json.decode(str));

String getRideDetailsModelToJson(GetRideDetailsModel data) => json.encode(data.toJson());

class GetRideDetailsModel {
  bool? success;
  Data? data;

  GetRideDetailsModel({
    this.success,
    this.data,
  });

  factory GetRideDetailsModel.fromJson(Map<String, dynamic> json) => GetRideDetailsModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class Data {
  Ride? ride;

  Data({
    this.ride,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    ride: json["ride"] == null ? null : Ride.fromJson(json["ride"]),
  );

  Map<String, dynamic> toJson() => {
    "ride": ride?.toJson(),
  };
}

class Ride {
  int? id;
  int? userId;
  int? driverId;
  int? vehicleTypeId;
  String? tripType;
  String? pickupLatitude;
  String? pickupLongitude;
  String? pickupAddress;
  String? dropLatitude;
  String? dropLongitude;
  String? dropAddress;
  DateTime? pickupDatetime;
  String? distanceKm;
  String? baseFare;
  String? commissionAmount;
  String? taxAmount;
  String? tipAmount;
  String? totalFare;
  String? status;
  DateTime? acceptedAt;
  dynamic pickupAt;
  dynamic completedAt;
  dynamic cancelledAt;
  dynamic cancellationReason;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? bookingId;
  Driver? driver;
  VehicleType? vehicleType;
  List<StatusLog>? statusLogs;
  Payment? payment;
  int? isPackageStatus;
  String? packageName;

  Ride({
    this.id,
    this.userId,
    this.driverId,
    this.vehicleTypeId,
    this.tripType,
    this.pickupLatitude,
    this.pickupLongitude,
    this.pickupAddress,
    this.dropLatitude,
    this.dropLongitude,
    this.dropAddress,
    this.pickupDatetime,
    this.distanceKm,
    this.baseFare,
    this.commissionAmount,
    this.taxAmount,
    this.tipAmount,
    this.totalFare,
    this.status,
    this.acceptedAt,
    this.pickupAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
    this.bookingId,
    this.driver,
    this.vehicleType,
    this.statusLogs,
    this.payment,this.isPackageStatus,this.packageName,
  });

  factory Ride.fromJson(Map<String, dynamic> json) => Ride(
    id: json["id"],
    userId: json["user_id"],
    driverId: json["driver_id"],
    vehicleTypeId: json["vehicle_type_id"],
    tripType: json["trip_type"],
    pickupLatitude: json["pickup_latitude"],
    pickupLongitude: json["pickup_longitude"],
    pickupAddress: json["pickup_address"],
    dropLatitude: json["drop_latitude"],
    dropLongitude: json["drop_longitude"],
    dropAddress: json["drop_address"],
    pickupDatetime: json["pickup_datetime"] == null ? null : DateTime.parse(json["pickup_datetime"]),
    distanceKm: json["distance_km"],
    baseFare: json["base_fare"],
    commissionAmount: json["commission_amount"],
    taxAmount: json["tax_amount"],
    tipAmount: json["tip_amount"],
    totalFare: json["total_fare"],
    status: json["status"],
    acceptedAt: json["accepted_at"] == null ? null : DateTime.parse(json["accepted_at"]),
    pickupAt: json["pickup_at"],
    completedAt: json["completed_at"],
    cancelledAt: json["cancelled_at"],
    cancellationReason: json["cancellation_reason"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    bookingId: json["booking_id"],
    driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
    vehicleType: json["vehicle_type"] == null ? null : VehicleType.fromJson(json["vehicle_type"]),
    statusLogs: json["status_logs"] == null ? [] : List<StatusLog>.from(json["status_logs"]!.map((x) => StatusLog.fromJson(x))),
    payment: json["payment"] == null ? null : Payment.fromJson(json['payment']),
    isPackageStatus: json['is_package_status'],
    packageName: json['package_name'],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "driver_id": driverId,
    "vehicle_type_id": vehicleTypeId,
    "trip_type": tripType,
    "pickup_latitude": pickupLatitude,
    "pickup_longitude": pickupLongitude,
    "pickup_address": pickupAddress,
    "drop_latitude": dropLatitude,
    "drop_longitude": dropLongitude,
    "drop_address": dropAddress,
    "pickup_datetime": pickupDatetime?.toIso8601String(),
    "distance_km": distanceKm,
    "base_fare": baseFare,
    "commission_amount": commissionAmount,
    "tax_amount": taxAmount,
    "tip_amount": tipAmount,
    "total_fare": totalFare,
    "status": status,
    "accepted_at": acceptedAt?.toIso8601String(),
    "pickup_at": pickupAt,
    "completed_at": completedAt,
    "cancelled_at": cancelledAt,
    "cancellation_reason": cancellationReason,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "booking_id": bookingId,
    "driver": driver?.toJson(),
    "vehicle_type": vehicleType?.toJson(),
    "status_logs": statusLogs == null ? [] : List<dynamic>.from(statusLogs!.map((x) => x.toJson())),
    "payment": payment?.toJson(),
    "is_package_status" : isPackageStatus,
    "package_name" : packageName,
  };
}

class Driver {
  int? id;
  String? name;
  String? email;
  String? mobile;
  String? vehicleNumber;
  int? vehicleTypeId;
  String? profilePhoto;
  String? status;
  bool? isOnline;
  String? latitude;
  String? longitude;
  DateTime? lastLocationUpdate;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Image>? images;
  List<Document>? documents;

  Driver({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.vehicleNumber,
    this.vehicleTypeId,
    this.profilePhoto,
    this.status,
    this.isOnline,
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
    this.createdAt,
    this.updatedAt,
    this.images,
    this.documents,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    vehicleNumber: json["vehicle_number"],
    vehicleTypeId: json["vehicle_type_id"],
    profilePhoto: json["profile_photo"],
    status: json["status"],
    isOnline: json["is_online"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    lastLocationUpdate: json["last_location_update"] == null ? null : DateTime.parse(json["last_location_update"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    images: json["images"] == null ? [] : List<Image>.from(json["images"]!.map((x) => Image.fromJson(x))),
    documents: json["documents"] == null ? [] : List<Document>.from(json["documents"]!.map((x) => Document.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
    "vehicle_number": vehicleNumber,
    "vehicle_type_id": vehicleTypeId,
    "profile_photo": profilePhoto,
    "status": status,
    "is_online": isOnline,
    "latitude": latitude,
    "longitude": longitude,
    "last_location_update": lastLocationUpdate?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x.toJson())),
    "documents": documents == null ? [] : List<dynamic>.from(documents!.map((x) => x.toJson())),
  };
}

class Document {
  int? id;
  int? driverId;
  String? documentType;
  String? documentPath;
  String? status;
  dynamic rejectionReason;
  DateTime? createdAt;
  DateTime? updatedAt;

  Document({
    this.id,
    this.driverId,
    this.documentType,
    this.documentPath,
    this.status,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json["id"],
    driverId: json["driver_id"],
    documentType: json["document_type"],
    documentPath: json["document_path"],
    status: json["status"],
    rejectionReason: json["rejection_reason"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "driver_id": driverId,
    "document_type": documentType,
    "document_path": documentPath,
    "status": status,
    "rejection_reason": rejectionReason,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Image {
  String? type;
  String? url;
  String? status;

  Image({
    this.type,
    this.url,
    this.status,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
    type: json["type"],
    url: json["url"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "url": url,
    "status": status,
  };
}


class StatusLog {
  int? id;
  int? rideId;
  String? status;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;

  StatusLog({
    this.id,
    this.rideId,
    this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory StatusLog.fromJson(Map<String, dynamic> json) => StatusLog(
    id: json["id"],
    rideId: json["ride_id"],
    status: json["status"],
    notes: json["notes"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ride_id": rideId,
    "status": status,
    "notes": notes,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class VehicleType {
  int? id;
  String? name;
  int? capacity;
  String? pricePerKm;
  String? commissionPercentage;
  bool? isActive;
  String? vehicleImage;
  DateTime? createdAt;
  DateTime? updatedAt;

  VehicleType({
    this.id,
    this.name,
    this.capacity,
    this.pricePerKm,
    this.commissionPercentage,
    this.isActive,
    this.vehicleImage,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) => VehicleType(
    id: json["id"],
    name: json["name"],
    capacity: json["capacity"],
    pricePerKm: json["price_per_km"],
    commissionPercentage: json["commission_percentage"],
    isActive: json["is_active"],
    vehicleImage: json["vehicle_image"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "capacity": capacity,
    "price_per_km": pricePerKm,
    "commission_percentage": commissionPercentage,
    "is_active": isActive,
    "vehicle_image": vehicleImage,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

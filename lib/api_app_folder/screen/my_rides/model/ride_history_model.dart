// To parse this JSON data, do
//
//     final rideHistoryModel = rideHistoryModelFromJson(jsonString);

import 'dart:convert';

RideHistoryModel rideHistoryModelFromJson(String str) => RideHistoryModel.fromJson(json.decode(str));

String rideHistoryModelToJson(RideHistoryModel data) => json.encode(data.toJson());

class RideHistoryModel {
  bool? success;
  Data? data;

  RideHistoryModel({
    this.success,
    this.data,
  });

  factory RideHistoryModel.fromJson(Map<String, dynamic> json) => RideHistoryModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class Data {
  int? currentPage;
  List<RideData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  Data({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"],
    data: json["data"] == null ? [] : List<RideData>.from(json["data"]!.map((x) => RideData.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links: json["links"] == null ? [] : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": links == null ? [] : List<dynamic>.from(links!.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class RideData {
  int? id;
  int? userId;
  dynamic driverId;
  int? vehicleTypeId;
  String? tripType;
  String? bookingId;
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
  dynamic acceptedAt;
  dynamic pickupAt;
  dynamic completedAt;
  dynamic cancelledAt;
  dynamic cancellationReason;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic driver;
  VehicleType? vehicleType;
  Payment? payment;

  RideData({
    this.id,
    this.userId,
    this.driverId,
    this.vehicleTypeId,
    this.tripType,
    this.bookingId,
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
    this.driver,
    this.vehicleType,
    this.payment,
  });

  factory RideData.fromJson(Map<String, dynamic> json) => RideData(
    id: json["id"],
    userId: json["user_id"],
    driverId: json["driver_id"],
    vehicleTypeId: json["vehicle_type_id"],
    tripType: json["trip_type"],
    bookingId: json["booking_id"],
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
    acceptedAt: json["accepted_at"],
    pickupAt: json["pickup_at"],
    completedAt: json["completed_at"],
    cancelledAt: json["cancelled_at"],
    cancellationReason: json["cancellation_reason"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    driver: json["driver"],
    vehicleType: json["vehicle_type"] == null ? null : VehicleType.fromJson(json["vehicle_type"]),
    payment: json["payment"] == null ? null : Payment.fromJson(json["payment"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "driver_id": driverId,
    "vehicle_type_id": vehicleTypeId,
    "trip_type": tripType,
    "booking_id": bookingId,
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
    "accepted_at": acceptedAt,
    "pickup_at": pickupAt,
    "completed_at": completedAt,
    "cancelled_at": cancelledAt,
    "cancellation_reason": cancellationReason,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "driver": driver,
    "vehicle_type": vehicleType?.toJson(),
    "payment": payment?.toJson(),
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

class Link {
  String? url;
  String? label;
  bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}
class Payment {
  int? id;
  int? rideId;
  String? amount;
  String? currency;
  String? status;
  dynamic paymentMethod;
  dynamic transactionId;
  dynamic stripePaymentIntentId;
  dynamic stripeChargeId;
  dynamic paidAt;
  dynamic notes;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic userId;
  dynamic driverId;

  Payment({
    this.id,
    this.rideId,
    this.amount,
    this.currency,
    this.status,
    this.paymentMethod,
    this.transactionId,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    this.paidAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.driverId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json["id"],
    rideId: json["ride_id"],
    amount: json["amount"],
    currency: json["currency"],
    status: json["status"],
    paymentMethod: json["payment_method"],
    transactionId: json["transaction_id"],
    stripePaymentIntentId: json["stripe_payment_intent_id"],
    stripeChargeId: json["stripe_charge_id"],
    paidAt: json["paid_at"],
    notes: json["notes"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    userId: json["user_id"],
    driverId: json["driver_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ride_id": rideId,
    "amount": amount,
    "currency": currency,
    "status": status,
    "payment_method": paymentMethod,
    "transaction_id": transactionId,
    "stripe_payment_intent_id": stripePaymentIntentId,
    "stripe_charge_id": stripeChargeId,
    "paid_at": paidAt,
    "notes": notes,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "user_id": userId,
    "driver_id": driverId,
  };
}


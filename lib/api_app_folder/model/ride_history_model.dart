part of 'model.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RideHistoryModel {
  final int? id;
  final int? userId;
  final int? driverId;
  final int? vehicleTypeId;
  final String? tripType;
  final String? pickupLatitude;
  final String? pickupLongitude;
  final String? pickupAddress;
  final String? dropLatitude;
  final String? dropLongitude;
  final String? dropAddress;
  final DateTime? pickupDatetime;
  final String? distanceKm;
  final String? baseFare;
  final String? commissionAmount;
  final String? taxAmount;
  final String? tipAmount;
  final String? totalFare;
  final String? status;
  final DateTime? acceptedAt;
  final DateTime? pickupAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DriverModel? driver;

   final VehicleTypeModel? vehicleType;
  // final PaymentModel? payment;

  RideHistoryModel({
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
    this.driver,
     this.vehicleType,
    // this.payment,
  });

  factory RideHistoryModel.fromJson(JsonMap json) =>
      _$RideHistoryModelFromJson(json);

  JsonMap toJson() => _$RideHistoryModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DriverModel {
  final int? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? vehicleNumber;
  final int? vehicleTypeId;
  final String? profilePhoto;
  final String? status;
  final bool? isOnline;
  final String? latitude;
  final String? longitude;
  final DateTime? lastLocationUpdate;

  DriverModel({
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
  });

  factory DriverModel.fromJson(JsonMap json) => _$DriverModelFromJson(json);

  JsonMap toJson() => _$DriverModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VehicleTypeModel {
  final int? id;
  final String? name;
  final int? capacity;
  final String? pricePerKm;
  final String? commissionPercentage;
  final bool? isActive;
  final String? vehicleImage;


  VehicleTypeModel({
     this.id,
     this.name,
     this.capacity,
     this.pricePerKm,
     this.commissionPercentage,
     this.isActive,
     this.vehicleImage,
  });
  factory VehicleTypeModel.fromJson(JsonMap json) => _$VehicleTypeModelFromJson(json);

  JsonMap toJson() => _$VehicleTypeModelToJson(this);

}


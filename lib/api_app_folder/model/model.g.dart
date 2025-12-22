// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RideModel _$RideModelFromJson(Map<String, dynamic> json) => RideModel();

Map<String, dynamic> _$RideModelToJson(RideModel instance) =>
    <String, dynamic>{};

RideHistoryModel _$RideHistoryModelFromJson(Map<String, dynamic> json) =>
    RideHistoryModel(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      driverId: (json['driver_id'] as num?)?.toInt(),
      vehicleTypeId: (json['vehicle_type_id'] as num?)?.toInt(),
      tripType: json['trip_type'] as String?,
      pickupLatitude: json['pickup_latitude'] as String?,
      pickupLongitude: json['pickup_longitude'] as String?,
      pickupAddress: json['pickup_address'] as String?,
      dropLatitude: json['drop_latitude'] as String?,
      dropLongitude: json['drop_longitude'] as String?,
      dropAddress: json['drop_address'] as String?,
      pickupDatetime: json['pickup_datetime'] == null
          ? null
          : DateTime.parse(json['pickup_datetime'] as String),
      distanceKm: json['distance_km'] as String?,
      baseFare: json['base_fare'] as String?,
      commissionAmount: json['commission_amount'] as String?,
      taxAmount: json['tax_amount'] as String?,
      tipAmount: json['tip_amount'] as String?,
      totalFare: json['total_fare'] as String?,
      status: json['status'] as String?,
      acceptedAt: json['accepted_at'] == null
          ? null
          : DateTime.parse(json['accepted_at'] as String),
      pickupAt: json['pickup_at'] == null
          ? null
          : DateTime.parse(json['pickup_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      cancellationReason: json['cancellation_reason'] as String?,
      driver: json['driver'] == null
          ? null
          : DriverModel.fromJson(json['driver'] as Map<String, dynamic>),
      vehicleType: json['vehicle_type'] == null
          ? null
          : VehicleTypeModel.fromJson(
              json['vehicle_type'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$RideHistoryModelToJson(RideHistoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'driver_id': instance.driverId,
      'vehicle_type_id': instance.vehicleTypeId,
      'trip_type': instance.tripType,
      'pickup_latitude': instance.pickupLatitude,
      'pickup_longitude': instance.pickupLongitude,
      'pickup_address': instance.pickupAddress,
      'drop_latitude': instance.dropLatitude,
      'drop_longitude': instance.dropLongitude,
      'drop_address': instance.dropAddress,
      'pickup_datetime': instance.pickupDatetime?.toIso8601String(),
      'distance_km': instance.distanceKm,
      'base_fare': instance.baseFare,
      'commission_amount': instance.commissionAmount,
      'tax_amount': instance.taxAmount,
      'tip_amount': instance.tipAmount,
      'total_fare': instance.totalFare,
      'status': instance.status,
      'accepted_at': instance.acceptedAt?.toIso8601String(),
      'pickup_at': instance.pickupAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'cancellation_reason': instance.cancellationReason,
      'driver': instance.driver,
      'vehicle_type': instance.vehicleType,
    };

DriverModel _$DriverModelFromJson(Map<String, dynamic> json) => DriverModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  email: json['email'] as String?,
  mobile: json['mobile'] as String?,
  vehicleNumber: json['vehicle_number'] as String?,
  vehicleTypeId: (json['vehicle_type_id'] as num?)?.toInt(),
  profilePhoto: json['profile_photo'] as String?,
  status: json['status'] as String?,
  isOnline: json['is_online'] as bool?,
  latitude: json['latitude'] as String?,
  longitude: json['longitude'] as String?,
  lastLocationUpdate: json['last_location_update'] == null
      ? null
      : DateTime.parse(json['last_location_update'] as String),
);

Map<String, dynamic> _$DriverModelToJson(DriverModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'mobile': instance.mobile,
      'vehicle_number': instance.vehicleNumber,
      'vehicle_type_id': instance.vehicleTypeId,
      'profile_photo': instance.profilePhoto,
      'status': instance.status,
      'is_online': instance.isOnline,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'last_location_update': instance.lastLocationUpdate?.toIso8601String(),
    };

VehicleTypeModel _$VehicleTypeModelFromJson(Map<String, dynamic> json) =>
    VehicleTypeModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      capacity: (json['capacity'] as num?)?.toInt(),
      pricePerKm: json['price_per_km'] as String?,
      commissionPercentage: json['commission_percentage'] as String?,
      isActive: json['is_active'] as bool?,
      vehicleImage: json['vehicle_image'] as String?,
    );

Map<String, dynamic> _$VehicleTypeModelToJson(VehicleTypeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'capacity': instance.capacity,
      'price_per_km': instance.pricePerKm,
      'commission_percentage': instance.commissionPercentage,
      'is_active': instance.isActive,
      'vehicle_image': instance.vehicleImage,
    };

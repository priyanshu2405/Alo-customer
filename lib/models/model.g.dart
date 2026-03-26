// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlatRatesModel _$FlatRatesModelFromJson(Map<String, dynamic> json) =>
    FlatRatesModel(
      id: (json['id'] as num?)?.toInt(),
      distanceRule: json['distance_rule'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      rideType: json['ride_type'] as String?,
      image: json['image'] as String?,
      km: json['km'],
      numRides: (json['num_rides'] as num?)?.toInt(),
      packageName: json['package_name'] as String?,
      discountPercentage: (json['discount_percentage'] as num?)?.toInt(),
      packagePriceTtc: (json['package_price_ttc'] as num?)?.toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      isPurchased: (json['is_purchased'] as num?)?.toInt(),
      name: json['name'] as String?,
      distanceLimit: json['distance_limit'],
      durationMinutes: json['duration_minutes'],
      ridesRemaining: (json['rides_remaining'] as num?)?.toInt(),
      amountPaid: json['amount_paid'],
      purchaseId: (json['purchase_id'] as num?)?.toInt(),
      totalRides: (json['total_rides'] as num?)?.toInt(),
      paidAt: json['paid_at'] as String?,
    );

Map<String, dynamic> _$FlatRatesModelToJson(FlatRatesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'km': instance.km,
      'num_rides': instance.numRides,
      'ride_type': instance.rideType,
      'distance_rule': instance.distanceRule,
      'package_name': instance.packageName,
      'distance_limit': instance.distanceLimit,
      'name': instance.name,
      'image': instance.image,
      'paid_at': instance.paidAt,
      'price': instance.price,
      'package_price_ttc': instance.packagePriceTtc,
      'original_price': instance.originalPrice,
      'discount_percentage': instance.discountPercentage,
      'is_purchased': instance.isPurchased,
      'rides_remaining': instance.ridesRemaining,
      'purchase_id': instance.purchaseId,
      'total_rides': instance.totalRides,
      'amount_paid': instance.amountPaid,
      'duration_minutes': instance.durationMinutes,
    };

PackageHistoryModel _$PackageHistoryModelFromJson(Map<String, dynamic> json) =>
    PackageHistoryModel(
      id: (json['id'] as num?)?.toInt(),
      packageName: json['package_name'] as String?,
      rideType: json['ride_type'] as String?,
      totalRides: (json['total_rides'] as num?)?.toInt(),
      ridesUsed: (json['rides_used'] as num?)?.toInt(),
      ridesRemaining: (json['rides_remaining'] as num?)?.toInt(),
      amountPaid: json['amount_paid'],
      currency: json['currency'] as String?,
      status: json['status'] as String?,
      paidAt: json['paid_at'] as String?,
    );

Map<String, dynamic> _$PackageHistoryModelToJson(
  PackageHistoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'package_name': instance.packageName,
  'ride_type': instance.rideType,
  'total_rides': instance.totalRides,
  'rides_used': instance.ridesUsed,
  'rides_remaining': instance.ridesRemaining,
  'amount_paid': instance.amountPaid,
  'currency': instance.currency,
  'status': instance.status,
  'paid_at': instance.paidAt,
};

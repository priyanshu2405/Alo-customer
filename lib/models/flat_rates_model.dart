part of 'model.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class FlatRatesModel {
  final int? id;
  final dynamic km;
  final int? numRides;
  final String? rideType;
  final String? distanceRule;
  final String? packageName;
  final dynamic distanceLimit;
  final String? name;
  final String? image;
  final String? paidAt;
  final double? price;
  final double? packagePriceTtc;
  final double? originalPrice;
  final int? discountPercentage;
  final int? isPurchased;
  final int? ridesRemaining;
  final int? purchaseId;
  final int? totalRides;
  final dynamic amountPaid;
  final dynamic durationMinutes;

  FlatRatesModel({
    this.id,
    this.distanceRule,
    this.price,
    this.rideType,
    this.image,
    this.km,
    this.numRides,
    this.packageName,
    this.discountPercentage,
    this.packagePriceTtc,
    this.originalPrice,
    this.isPurchased,
    this.name,
    this.distanceLimit,
    this.durationMinutes,
    this.ridesRemaining,
    this.amountPaid,
    this.purchaseId,this.totalRides,this.paidAt,
  });

  factory FlatRatesModel.fromJson(JsonMap json) =>
      _$FlatRatesModelFromJson(json);

  JsonMap toJson() => _$FlatRatesModelToJson(this);
}


@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class PackageHistoryModel {
  final int? id;
  final String? packageName;
  final String? rideType;
  final int? totalRides;
  final int? ridesUsed;
  final int? ridesRemaining;
  final dynamic amountPaid;
  final String? currency;
  final String? status;
  final String? paidAt;


  PackageHistoryModel({
    this.id,
    this.packageName,
    this.rideType,
    this.totalRides,
    this.ridesUsed,
    this.ridesRemaining,
    this.amountPaid,
    this.currency,
    this.status,
    this.paidAt,
  });

  factory PackageHistoryModel.fromJson(JsonMap json) =>
      _$PackageHistoryModelFromJson(json);

  JsonMap toJson() => _$PackageHistoryModelToJson(this);
}
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A single drop-off stop selected by the user while booking a ride.
/// A ride can have multiple drop-offs within the selected package.
class DropOffPoint {
  final LatLng latLng;
  final String address;

  DropOffPoint({required this.latLng, required this.address});

  Map<String, dynamic> toJson() => {
        "latitude": latLng.latitude,
        "longitude": latLng.longitude,
        "address": address,
      };
}

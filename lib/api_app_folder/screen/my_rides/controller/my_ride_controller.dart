import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/controller/dashboard_conroller.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/model/get_ride_details_model.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/view/ride_completed_screen.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:alo_ride_app/api_app_folder/services/location_services.dart';
import 'package:alo_ride_app/api_app_folder/services/socket_services.dart';
import 'package:alo_ride_app/api_app_folder/services/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// class MyRideController extends GetxController{
//   RxBool isRideHistory = false.obs;
//   RxInt selectedTab = 0.obs; // 0 = List, 1 = Calendar
//
//   String? startDate; // "2025-12-31"
//   String? endDate;   // "2025-12-31"
//   Rx<RideHistoryModel> rideHistoryModel = RideHistoryModel().obs;
//
//
//   Future<void> getRideHistory() async {
//     try {
//       isRideHistory.value = true;
//
//       /// Base endpoint (NO status)
//       String endpoint = 'rides/history';
//
//       /// Add dates only if BOTH exist
//       if (startDate?.isNotEmpty == true &&
//           endDate?.isNotEmpty == true) {
//         endpoint += '?start_date=$startDate&end_date=$endDate';
//       }
//
//       final response = await ApiService.get(
//         endpoint: endpoint,
//         isShow: false,
//       );
//
//       rideHistoryModel.value = RideHistoryModel.fromJson(response);
//
//       debugPrint(
//         "length ==> ${rideHistoryModel.value.data?.data?.length}",
//       );
//     } catch (e) {
//       debugPrint('Error fetching ride history: $e');
//     } finally {
//       isRideHistory.value = false;
//     }
//   }
//
//
// }

class MyRideController extends GetxController {
  RxBool isRideHistory = false.obs;
  RxBool isGetRideDetails = false.obs;
  RxBool isCancelRide = false.obs;
  RxInt selectedTab = 0.obs; // 0 = List, 1 = Calendar

  String? startDate;
  String? endDate;

  Rx<RideHistoryModel> rideHistoryModel = RideHistoryModel().obs;
  Rx<GetRideDetailsModel> getRideDetailsModel = GetRideDetailsModel().obs;
 // Rxn<GetRideDetailsModel> getRideDetailsModel = Rxn<GetRideDetailsModel>();
  final TextEditingController reasonController = TextEditingController();
  final List<String> upcomingStatuses = [
    'pending',
    'accepted',
    'going_to_pickup',
    'pickup_done',
  ];
  final Rxn<RouteDistanceTime> routeInfo = Rxn<RouteDistanceTime>();
  Rx<String> rideStatus = "".obs;
  /// ✅ Filtered lists
  RxList<RideData> pendingRides = <RideData>[].obs;
  RxList<RideData> completedRides = <RideData>[].obs;
  RxList<RideData> cancelRides = <RideData>[].obs;

  Rx<LatLng?> pickupLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> dropLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> driverLatLng = Rx<LatLng?>(null);

  // SocketIoService socketIoService = SocketIoService();
  final AuthController authController = Get.put(AuthController());
  DriverLocationUpdate? driverLocationUpdate;
  Position? position;
  GoogleMapController? mapController;

  /// map state
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;
  final routePoints = <LatLng>[].obs;

  /// positions
  //LatLng? pickupLatLng;
  //LatLng? driverLatLng;

  /// polyline helper
  final polylinePoints = PolylinePoints(
    apiKey: 'AIzaSyBxaqnRr_zdsjrqNvtMEXXbm8IO2lvzTRs',
  );

  /// animated driver marker id
  static const String driverMarkerId = "driver";
  final ridePhase = RidePhase.toPickup.obs;

  /// set Google map controller
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void onClose() {
    super.onClose();
    stopDriverLocationAutoGet();
  }

  void setPickupFromApi(double lat, double lng) async {
    print("dvdvd");
    pickupLatLng.value = LatLng(lat, lng);

    /*markers.add(
      Marker(
        markerId: const MarkerId("pickup"),
        position: pickupLatLng.value ?? LatLng(0.0, 0.0),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );*/

    markers.refresh();
    await drawCurrentRoute();
  }

  Future<void> updateDriverFromSocket(double lat, double lng) async {
    final newPos = LatLng(lat, lng);

    /// first time marker add
    if (driverLatLng.value == null) {
      driverLatLng.value = newPos;

      markers.add(
        Marker(
          markerId: const MarkerId(driverMarkerId),
          position: driverLatLng.value!,
          rotation: 0,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      await _fitDriverAndPickupBounds();
    } else {
      /// smooth animate movement
      await _animateDriverMovement(driverLatLng.value!, newPos);
      driverLatLng.value = newPos;
    }

    /// re-draw route each time driver moves
    if (pickupLatLng.value != null) {
      await _drawRouteDriverToPickup();
    }

    markers.refresh();
  }

  Future<void> _animateDriverMovement(LatLng from, LatLng to) async {
    const int steps = 30;
    const int ms = 15;

    for (int i = 0; i <= steps; i++) {
      final lat = from.latitude + (to.latitude - from.latitude) * (i / steps);
      final lng =
          from.longitude + (to.longitude - from.longitude) * (i / steps);

      markers.removeWhere((m) => m.markerId.value == driverMarkerId);

      markers.add(
        Marker(
          markerId: const MarkerId(driverMarkerId),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      await Future.delayed(const Duration(milliseconds: ms));
    }
  }

  Future<void> _drawRouteDriverToPickup() async {
    if (driverLatLng.value == null || pickupLatLng.value == null) return;

    polylines.clear();
    routePoints.clear();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(
          driverLatLng.value!.latitude,
          driverLatLng.value!.longitude,
        ),
        destination: PointLatLng(
          pickupLatLng.value?.latitude ?? 0.0,
          pickupLatLng.value?.longitude ?? 0.0,
        ),
        mode: TravelMode.driving,
        avoidFeatures: [AvoidFeature.ferries],
        alternatives: true,
      ),
    );

    if (result.points.isEmpty) return;

    for (final p in result.points) {
      routePoints.add(LatLng(p.latitude, p.longitude));
    }

    polylines.add(
      Polyline(
        polylineId: const PolylineId("driver_to_pickup"),
        width: 5,
        color: Colors.blue,
        points: routePoints,
      ),
    );

    polylines.refresh();
  }

  Future<void> _fitDriverAndPickupBounds() async {
    if (driverLatLng.value == null || pickupLatLng.value == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        driverLatLng.value!.latitude < pickupLatLng.value!.latitude
            ? driverLatLng.value!.latitude
            : pickupLatLng.value!.latitude,
        driverLatLng.value!.longitude < pickupLatLng.value!.longitude
            ? driverLatLng.value!.longitude
            : pickupLatLng.value!.longitude,
      ),
      northeast: LatLng(
        driverLatLng.value!.latitude > pickupLatLng.value!.latitude
            ? driverLatLng.value!.latitude
            : pickupLatLng.value!.latitude,
        driverLatLng.value!.longitude > pickupLatLng.value!.longitude
            ? driverLatLng.value!.longitude
            : pickupLatLng.value!.longitude,
      ),
    );

    await mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  static const String _singlePolylineId = "only_route";

  Future<void> drawCurrentRoute() async {
    if (driverLatLng.value == null) return;

    LatLng? target;

    if (ridePhase.value == RidePhase.toPickup) {
      target = pickupLatLng.value;
    } else {
      target = dropLatLng.value;
    }

    if (target == null) return;

    /// HARD RESET – remove all existing routes
    polylines.clear();
    routePoints.clear();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(
          driverLatLng.value!.latitude,
          driverLatLng.value!.longitude,
        ),
        destination: PointLatLng(target.latitude, target.longitude),
        mode: TravelMode.driving,
        alternatives: false,
      ),
    );

    if (result.points.isEmpty) return;

    for (final p in result.points) {
      routePoints.add(LatLng(p.latitude, p.longitude));
    }

    /// ALWAYS same id => only ONE polyline on map
    polylines.add(
      Polyline(
        polylineId: const PolylineId(_singlePolylineId),
        color: Colors.blue,
        width: 5,
        points: routePoints,
      ),
    );

    polylines.refresh();
  }

  double _currentBearing = 0;
  BitmapDescriptor? driverIcon;

  Future<void> loadDriverIcon() async {
    print("vdvdv");
    final icon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(120, 120)),
      "assets/icons/car.png",
    );

    driverIcon = icon;
    update();
  }

  void _updateDriverMarker() {
    if (driverLatLng.value == null) return;

    markers.removeWhere((m) => m.markerId.value == driverMarkerId);

    markers.add(
      Marker(
        markerId: const MarkerId(driverMarkerId),
        position: driverLatLng.value!,
        icon: /* driverIcon ?? */ BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
        rotation: _currentBearing,
        anchor: const Offset(0.5, 0.5),
      ),
    );

    markers.refresh();
  }


  //Rx<LatLng?> driverLatLng = Rx<LatLng?>(null);

  Future<void> getRideHistory1() async {
    try {
      isRideHistory.value = true;

      String endpoint = 'rides/history';

      if (startDate?.isNotEmpty == true || endDate?.isNotEmpty == true) {
        endpoint += '?start_date=$startDate&end_date=$endDate';
      }

      final response = await ApiService.get(endpoint: endpoint, isShow: false);

      rideHistoryModel.value = RideHistoryModel.fromJson(response);

      /// Clear old data
      pendingRides.clear();
      completedRides.clear();
      cancelRides.clear();

      final rides = rideHistoryModel.value.data?.data ?? [];

      for (var ride in rides) {
        if (upcomingStatuses.contains(ride.status)) {
          pendingRides.add(ride); // UPCOMING
        } else if (ride.status == 'completed') {
          completedRides.add(ride);
        } else if (ride.status == 'cancelled') {
          cancelRides.add(ride);
        }
      }

      debugPrint("Upcoming: ${pendingRides.length}");
      debugPrint("Completed: ${completedRides.length}");
      debugPrint("Cancelled: ${cancelRides.length}");
    } catch (e) {
      debugPrint('Error fetching ride history: $e');
    } finally {
      isRideHistory.value = false;
    }
  }

  Future<void> getRideHistory({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isRideHistory.value = true; // 🔥 ONLY when needed
      }

      String endpoint = 'rides/history';

      // Only send start_date when a valid date is selected.
      if (startDate?.isNotEmpty == true) {
        endpoint += '?start_date=$startDate';
      }

      final response = await ApiService.get(endpoint: endpoint, isShow: false);

      rideHistoryModel.value = RideHistoryModel.fromJson(response);

      /// Clear old data
      pendingRides.clear();
      completedRides.clear();
      cancelRides.clear();

      final rides = rideHistoryModel.value.data?.data ?? [];

      for (var ride in rides) {
        if (upcomingStatuses.contains(ride.status)) {
          pendingRides.add(ride);
        } else if (ride.status == 'completed') {
          completedRides.add(ride);
        } else if (ride.status == 'cancelled') {
          cancelRides.add(ride);
        }
      }
      if (!drawing.value) {
        drawing.value = true;
        await drawCurrentRoute();
        drawing.value = false;
      }
      //_updateDriverMarker();
      routeInfo.value = await getDistanceAndTime(
        originLat: position?.latitude ?? 0,
        originLng: position?.longitude ?? 0,
        destLat: pickupLatLng.value?.latitude ??0.0,
        destLng: pickupLatLng.value?.longitude ?? 0.0,
      );
      print(routeInfo.value?.distanceText);
      // updateDriverFromSocket(
      //   driverLocationUpdate?.latitude,
      //   driverLocationUpdate?.longitude,
      // );
    } catch (e) {
      debugPrint('Error fetching ride history: $e');
    } finally {
      if (showLoader) {
        isRideHistory.value = false;
      }
    }
  }

  /// Friendly status text
  String getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'going_to_pickup':
        return 'Driver on the way';
      case 'pickup_done':
        return 'Picked up';
      case 'completed':
        return 'Completed';
      default:
        return '';
    }
  }

  Rx<bool> drawing = false.obs;

  Future<void> getRideDetails({required int id}) async {
    position = await LocationService.getCurrentLocation();
    update();
    print(position?.latitude);
    try {
      isGetRideDetails.value = true;

      final response = await ApiService.get(
        endpoint: 'rides/$id',
        isShow: false,
      );

      getRideDetailsModel.value = GetRideDetailsModel.fromJson(response);
      log(getRideDetailsModel.value.toJson().toString());
      final ride = getRideDetailsModel.value.data?.ride;

      if (ride != null) {
        /// ✅ Convert String → double safely
        final pickupLat = double.tryParse(ride.pickupLatitude ?? '');
        final pickupLng = double.tryParse(ride.pickupLongitude ?? '');
        final dropLat = double.tryParse(ride.dropLatitude ?? '');
        final dropLng = double.tryParse(ride.dropLongitude ?? '');

        if (pickupLat != null && pickupLng != null) {
          pickupLatLng.value = LatLng(pickupLat, pickupLng);
        }

        if (dropLat != null && dropLng != null) {
          dropLatLng.value = LatLng(dropLat, dropLng);
        }
        //setPickupFromApi(pickupLat ?? 0.0, pickupLng ?? 0.0);
         print("ride status:: ${ride.status}");
        if (ride.status != "completed" || ride.status != "pending") {
          print("dvdvdv");
          startDriverLocationAutoGet(driverId: ride.driverId ?? 0,rideId: ride.id);
          /*unawaited(
            initRideSocketFlow(
              userId: ride.userId ?? 0,
              token: authController.token.value,
              rideId: ride.id ?? 0,
              onUpdate: (data) async {
                print("data--> ${data}");
                driverLocationUpdate = data;
                final newLatLng = LatLng(data.latitude, data.longitude);
                // compute bearing (optional)
                if (driverLatLng.value != null) {
                  _currentBearing = _bearingBetween(driverLatLng.value!, newLatLng);
                }
                driverLatLng.value = newLatLng;
                if (drawing.value) return;
                drawing.value = true;
                drawCurrentRoute();
                drawing.value = false;


                final result = await getDistanceAndTime(
                  originLat: position?.latitude ?? 0,
                  originLng: position?.longitude ?? 0,
                  destLat: driverLocationUpdate?.latitude,
                  destLng: driverLocationUpdate?.longitude,
                  apiKey: "AIzaSyBxaqnRr_zdsjrqNvtMEXXbm8IO2lvzTRs",
                );
                if (result != null) {
                  print("Distance: ${result.distanceText}");
                  print("Duration: ${result.durationText}");
                }
                update();
                //log("update:: ${jsonEncode(update)}");
              },
            ),
          );*/
          // socketIoService.connect(
          //   userId: ride.userId ?? 0,
          //   token: authController.token.value,
          // );
          // socketIoService.subscribeToRide(ride.id ?? 0);
          //
          // socketIoService.onDriverLocationUpdated((update) {
          //   debugPrint(
          //     'Driver location updated: ${update.latitude}, ${update.longitude}',
          //   );
          // });
        }
        routeInfo.value = await getDistanceAndTime(
          originLat: position?.latitude ?? 0,
          originLng: position?.longitude ?? 0,
          destLat: pickupLatLng.value?.latitude ??0.0,
          destLng: pickupLatLng.value?.longitude ?? 0.0,
        );
        print(routeInfo.value?.distanceText);
      }
    } catch (e) {
      debugPrint('Error fetching ride details: $e');
    } finally {
      isGetRideDetails.value = false;
    }
  }

  Timer? _locationTimer;
  bool _isSendingLocation = false;

  void stopDriverLocationAutoGet() {
    _locationTimer?.cancel();
    _locationTimer = null;
    debugPrint("🛑 Auto location getting stopped");
  }

  void startDriverLocationAutoGet({int? driverId,int? rideId}) {
    // avoid duplicate timers
    _locationTimer?.cancel();

    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_isSendingLocation) return; // avoid overlap
      _isSendingLocation = true;

      try {
        await getDriverLocation(driverId: driverId ?? 0,rideId: rideId ?? 0);
      } catch (e) {
        debugPrint("❌ Auto get error: $e");
      } finally {
        _isSendingLocation = false;
      }
    });

    //debugPrint("🚕 Auto location sending started for ride $rideId");
  }

  Future<void> getDriverLocation({required int driverId,required int rideId,}) async {
    try {
      // isLoading.value = true;

      final response = await ApiService.get(
        endpoint: 'location?id=$driverId&ride_id=$rideId',
      );

      if (response['success'] != true) return;

      final lat = double.parse(response['data']['latitude'].toString());
      final lng = double.parse(response['data']['longitude'].toString());
     print("locationStatus:: ${response}");
     rideStatus.value = response['data']['ride_status'];
     if(rideStatus.value == "completed"){
       Get.to(() => RideCompletedScreen(
         bookingId: rideId,
         isShowDialog: true,
       ));
       stopDriverLocationAutoGet();
     }
      final newPos = LatLng(lat, lng);

      // 1) animate marker
      await animateDriverMovement(newPos);

      // 2) redraw route driver -> pickup
      await drawRouteBetweenPoints(
        source: newPos,
        destination:rideStatus.value == "pickup_done" ? dropLatLng.value! : pickupLatLng.value!,
        mapController: mapController!,
        polylines: polylines,
      );

      // 3) ETA + distance
      routeInfo.value = await getDistanceAndTime(
        originLat: newPos.latitude,
        originLng: newPos.longitude,
        destLat: pickupLatLng.value!.latitude,
        destLng: pickupLatLng.value!.longitude,
      ); /*else {
        _showError(response['message'] ?? "Update failed");
      }*/
    } catch (e) {
      _isSendingLocation = false;
      print("error: ${e.toString()}");
      //_showError(e.toString());
    } finally {
      // isLoading.value = false;
    }
  }

  Future<void> drawRouteBetweenPoints({
    required LatLng source,
    required LatLng destination,
    required GoogleMapController mapController,
    required RxSet<Polyline> polylines,
  })
  async {
    //polylines.clear();
    if (driverLatLng.value == null || pickupLatLng.value == null) return;

    final polylinePoints = PolylinePoints(
      apiKey: "AIzaSyBxaqnRr_zdsjrqNvtMEXXbm8IO2lvzTRs",
    );

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(source.latitude, source.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
        alternatives: false,
      ),
    );

    if (result.points.isEmpty) return;

    routePoints.value =
        result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();
   /* final routeCoords = result.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();*/

    polylines.add(
      Polyline(
        polylineId: PolylineId(_singlePolylineId),
        width: 6,
        color: Colors.blue,
        points: routePoints,
      ),
    );
    polylines.refresh();

    //update();
  }
  void fitCameraBounds() {
    if (driverLatLng.value == null || pickupLatLng.value == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        min(driverLatLng.value!.latitude, pickupLatLng.value!.latitude),
        min(driverLatLng.value!.longitude, pickupLatLng.value!.longitude),
      ),
      northeast: LatLng(
        min(driverLatLng.value!.latitude, pickupLatLng.value!.latitude),
        min(driverLatLng.value!.longitude, pickupLatLng.value!.longitude),
      ),
    );

    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60),
    );
  }
  double currentBearing = 0.0;
  LatLng? lastDriverLatLng;

  Future<void> animateDriverMovement(LatLng newPos) async {
    if (lastDriverLatLng == null) {
      lastDriverLatLng = newPos;
      updateDriverMarker();
      return;
    }

    final latTween = Tween<double>(
      begin: lastDriverLatLng!.latitude,
      end: newPos.latitude,
    );

    final lngTween = Tween<double>(
      begin: lastDriverLatLng!.longitude,
      end: newPos.longitude,
    );

    for (double t = 0; t < 1; t += 0.02) {
      await Future.delayed(const Duration(milliseconds: 16));

      final lat = latTween.transform(t);
      final lng = lngTween.transform(t);

      driverLatLng.value = LatLng(lat, lng);

      currentBearing = Geolocator.bearingBetween(
        lastDriverLatLng!.latitude,
        lastDriverLatLng!.longitude,
        newPos.latitude,
        newPos.longitude,
      );

      updateDriverMarker();
    }

    lastDriverLatLng = newPos;
    driverLatLng.value = newPos;
    updateDriverMarker();
  }
  void updateDriverMarker() {
    if (driverLatLng.value == null) return;

    markers.removeWhere((m) => m.markerId.value == "pickup");
    markers.removeWhere((m) => m.markerId.value == "driver");

    /*markers.add(
      Marker(
        markerId: const MarkerId("driver"),
        position: driverLatLng.value!,
        rotation: currentBearing,
        anchor: const Offset(.5, .5),
        icon: driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      ),
    );*/
    markers.add(
      Marker(
        markerId: const MarkerId("pickup"),
        position: rideStatus.value == "pickup_done" ? dropLatLng.value! : pickupLatLng.value!,
        //rotation: currentBearing,
        anchor: const Offset(0.5, 0.5),
        icon: /*driverIcon ??*/ BitmapDescriptor.defaultMarker,
      ),
    );
    markers.refresh();
  }

  /*Future<void> computeDistanceEta() async {
    final distanceMeters = Geolocator.distanceBetween(
      driverLatLng.value!.latitude,
      driverLatLng.value!.longitude,
      pickupLatLng.value!.latitude,
      pickupLatLng.value!.longitude,
    );

    final km = distanceMeters / 1000;

    final avgSpeedKmh = 35;

    final etaMinutes = (km / avgSpeedKmh) * 60;

    debugPrint("Distance: ${km.toStringAsFixed(2)} km");
    debugPrint("ETA: ${etaMinutes.toStringAsFixed(0)} minutes");
  }*/


  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<RouteDistanceTime?> getDistanceAndTime({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = "driving",
  })
  async {
    final url =
        "https://maps.googleapis.com/maps/api/distancematrix/json"
        "?origins=$originLat,$originLng"
        "&destinations=$destLat,$destLng"
        "&mode=$mode"
        "&key=AIzaSyBxaqnRr_zdsjrqNvtMEXXbm8IO2lvzTRs";

    final response = await http.get(Uri.parse(url));
    // print("gettingLatlng ${response.body}");
    if (response.statusCode != 200) {
      throw Exception("Distance Matrix API failed: ${response.statusCode}");
    }

    final jsonBody = jsonDecode(response.body);

    if (jsonBody["status"] != "OK") {
      throw Exception("API error: ${jsonBody["status"]}");
    }

    final element = jsonBody["rows"][0]["elements"][0];

    if (element["status"] != "OK") {
      return null;
    }

    return RouteDistanceTime(
      distanceMeters: element["distance"]["value"],
      distanceText: element["distance"]["text"],
      durationSeconds: element["duration"]["value"],
      durationText: element["duration"]["text"],
    );
  }

  /* Future<void> initRideSocketFlow({
    required int userId,
    required String token,
    required int rideId,
    required void Function(DriverLocationUpdate update) onUpdate,
  })
  async {
    // 1) connect and authenticate
    await socketIoService.connect(userId: userId.toString(), token: token);

    socketIoService.getLocationStatus((status) async {

      debugPrint("STATUS FROM SOCKET => $status");

      if (status == "going_for_pickup") {
        ridePhase.value = RidePhase.toPickup;

        _addPickupMarker();
        _removeDropMarker();

        await drawCurrentRoute();
      }

      if (status == "pickup_done") {
        ridePhase.value = RidePhase.toDrop;

        _removePickupMarker();
        _addDropMarker();

        await drawCurrentRoute();
      }
    });
    socketIoService.onDriverLocationUpdated(onUpdate);

    // 2) subscribe to ride
    await socketIoService.rideAccept(rideId: rideId);
    await socketIoService.subScribeLocation();

    // 3) listen for updates
    print("driverLocationUpdate");

  }*/


  double get totalTripFare {
    final baseFare =
        double.tryParse(
          getRideDetailsModel.value.data?.ride?.baseFare?.toString() ?? '0',
        ) ??
        0;

    final commission =
        double.tryParse(
          getRideDetailsModel.value.data?.ride?.commissionAmount?.toString() ??
              '0',
        ) ??
        0;

    return baseFare + commission;
  }

  Future<void> cancelRide({required int id}) async {
    isCancelRide.value = true; // Start loading

    var body = {"reason": reasonController.text};
    debugPrint("body : $body");

    try {
      final response = await ApiService.post(
        endpoint: 'rides/$id/cancel',
        body: body,
      );
      print("id: ${response["otp"]}");

      debugPrint("otp verify =====>${response["otp"]}");
      if (response['success'] == true) {
        final controller = Get.put(DashBoardController());
        controller.changeIndex(1);
        Get.to(() => DashboardScreen());
        getRideHistory();
      } else {
        Get.snackbar(
          "Error",
          "${response["errors"]["mobile"]}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error in createUser: $e");
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.secondary.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      isCancelRide.value = false; // Stop loading in all cases
    }
  }
}

class RouteDistanceTime {
  final int distanceMeters;
  final String distanceText;
  final int durationSeconds;
  final String durationText;

  RouteDistanceTime({
    required this.distanceMeters,
    required this.distanceText,
    required this.durationSeconds,
    required this.durationText,
  });
}

enum RidePhase { toPickup, toDrop }

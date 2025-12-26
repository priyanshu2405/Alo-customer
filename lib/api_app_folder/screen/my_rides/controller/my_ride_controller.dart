import 'dart:developer';

import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/controller/dashboard_conroller.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/model/get_ride_details_model.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final TextEditingController reasonController = TextEditingController();
  final List<String> upcomingStatuses = [
    'pending',
    'accepted',
    'going_to_pickup',
    'pickup_done',
  ];

  /// ✅ Filtered lists
  RxList<RideData> pendingRides = <RideData>[].obs;
  RxList<RideData> completedRides = <RideData>[].obs;
  RxList<RideData> cancelRides = <RideData>[].obs;

  Rx<LatLng?> pickupLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> dropLatLng = Rx<LatLng?>(null);



  Future<void> getRideHistory() async {
    try {
      isRideHistory.value = true;

      String endpoint = 'rides/history';

      if (startDate?.isNotEmpty == true ||
          endDate?.isNotEmpty == true) {
        endpoint += '?start_date=$startDate&end_date=$endDate';
      }

      final response = await ApiService.get(
        endpoint: endpoint,
        isShow: false,
      );

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

  Future<void> getRideDetails({required int id}) async {
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
      }


    } catch (e) {
      debugPrint('Error fetching ride details: $e');
    } finally {
      isGetRideDetails.value = false;
    }
  }

  double get totalTripFare {
    final baseFare =
        double.tryParse(getRideDetailsModel.value.data?.ride?.baseFare?.toString() ?? '0') ?? 0;

    final commission =
        double.tryParse(getRideDetailsModel.value.data?.ride?.commissionAmount?.toString() ?? '0') ?? 0;

    return baseFare + commission;
  }


  Future<void> cancelRide({required int id}) async {
    isCancelRide.value = true; // Start loading

    var body = {
      "reason": reasonController.text,
    };
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
      } else{
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

import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class BookingController extends GetxController {
  RxInt selectValue = 0.obs;
  RxBool isEstimateFare = false.obs;

  Rxn<DateTime> selectedDate = Rxn<DateTime>();
  Rxn<DateTime> selectedTime = Rxn<DateTime>();

  RxDouble totalFare = 0.0.obs;

  // Add these for locations
  RxString fromLocation = "".obs;
  RxString dropOffLocation = "".obs;
  Rx<LatLng?> fromLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> dropOffLatLng = Rx<LatLng?>(null);

  // String get formattedDate => selectedDate.value == null
  //     ? "Select Date"
  //     : DateFormat("dd MMM yyyy").format(selectedDate.value!);
  //
  // String get formattedTime => selectedTime.value == null
  //     ? "Select Time"
  //     : DateFormat("hh:mm a").format(selectedTime.value!);

  String get formattedDate => DateFormat("dd MMM yyyy").format(selectedDate.value!);

  String get formattedTime => DateFormat("hh:mm a").format(selectedTime.value!);

  Future<void> pickDate(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      selectedDate.value = date;
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final now = DateTime.now();
      selectedTime.value = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
    }
  }



  Future<void> estimateFare({required int vehicleTypeId}) async {
    // ✅ ADD DEBUG PRINTS AT THE START
    debugPrint("=== ESTIMATE FARE CALLED ===");
    debugPrint("From Location: ${fromLocation.value}");
    debugPrint("From LatLng: ${fromLatLng.value}");
    debugPrint("Drop-off Location: ${dropOffLocation.value}");
    debugPrint("Drop-off LatLng: ${dropOffLatLng.value}");
    debugPrint("Vehicle Type ID: $vehicleTypeId");
    debugPrint("Trip Type: ${selectValue.value == 0 ? 'one_way' : 'round_trip'}");

    // Validation before making API call
    if (fromLatLng.value == null) {
      Get.snackbar(
        "Error",
        "Please select pickup location",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (dropOffLatLng.value == null) {
      Get.snackbar(
        "Error",
        "Please select drop-off location",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    isEstimateFare.value = true;

    String tripType = selectValue.value == 0 ? "one_way" : "round_trip";

    var body = {
      "pickup_latitude": fromLatLng.value!.latitude,
      "pickup_longitude": fromLatLng.value!.longitude,
      "drop_latitude": dropOffLatLng.value!.latitude,
      "drop_longitude": dropOffLatLng.value!.longitude,
      "vehicle_type_id": vehicleTypeId,
      "trip_type": tripType,
    };


    debugPrint("📤 API Request Body: $body");

    try {
      final response = await ApiService.post(
        endpoint: 'estimate-fare',
        body: body,
      );

      debugPrint("📥 API Response: $response");

      if (response['success'] == true) {
        debugPrint("✅ Total Fare: ${response["data"]["total_fare"]}");
        totalFare.value = response["data"]["total_fare"];

        Get.snackbar(
          "Success",
          "Fare estimated: \$${response["data"]["total_fare"]}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "${response["message"] ?? response["errors"] ?? "Failed to estimate fare"}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("❌ Error in estimateFare: $e");
      Get.snackbar(
        "Error",
        "Failed to estimate fare. Please try again.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      isEstimateFare.value = false;
    }
  }

}

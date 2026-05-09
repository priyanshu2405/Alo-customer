import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/booking/view/ride_confirmed_widget.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class BookingController extends GetxController {
  RxInt selectValue = 0.obs;
  RxBool isEstimateFare = false.obs;
  RxBool isBookRide = false.obs;

  Rxn<DateTime> selectedDate = Rxn<DateTime>();
  Rxn<DateTime> selectedTime = Rxn<DateTime>();

  RxDouble totalFare = 0.0.obs;
  RxDouble totalTax = 0.0.obs;
  RxDouble distanceKm = 0.0.obs;

  // Add these for locations
  RxString fromLocation = "".obs;
  RxString dropOffLocation = "".obs;
  Rx<LatLng?> fromLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> dropOffLatLng = Rx<LatLng?>(null);
  RxString rideBookingMessage = "".obs;

  // String get formattedDate => selectedDate.value == null
  //     ? "Select Date"
  //     : DateFormat("dd MMM yyyy").format(selectedDate.value!);
  //
  // String get formattedTime => selectedTime.value == null
  //     ? "Select Time"
  //     : DateFormat("hh:mm a").format(selectedTime.value!);

  String? get formattedDate {
    if (selectedDate.value == null) return null;
    return DateFormat("dd MMM yyyy").format(selectedDate.value!);
  }

  String? get formattedTime {
    if (selectedTime.value == null) return null;
    return DateFormat("hh:mm a").format(selectedTime.value!);
  }

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
RxBool isShowButton = false.obs;
  Future<void> estimateFare({
    required int vehicleTypeId,
    required int type,
  }) async {
    // ✅ ADD DEBUG PRINTS AT THE START
    debugPrint("=== ESTIMATE FARE CALLED ===");
    debugPrint("From Location: ${fromLocation.value}");
    debugPrint("From LatLng: ${fromLatLng.value}");
    debugPrint("Drop-off Location: ${dropOffLocation.value}");
    debugPrint("Drop-off LatLng: ${dropOffLatLng.value}");
    debugPrint("Vehicle Type ID: $vehicleTypeId");
    debugPrint(
      "Trip Type: ${selectValue.value == 0 ? 'one_way' : 'round_trip'}",
    );

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
      "id": vehicleTypeId,
      "type": type,
      //"trip_type": tripType,
    };

    debugPrint("📤 API Request Body: $body");

    try {
      final response = await ApiService.post(
        endpoint: 'estimate-fare',
        body: body,
      );

      debugPrint("📥 API Response: $response");

      if (response['success'] == true) {
        if (response["data"]['is_navigate'] == 1) {
          Get.back(); // Close loading
          Get.dialog(
            barrierDismissible: false,
            AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Error", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text("${response["message"]}"),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("OK", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
        else {
          isShowButton.value = response['success'];
          debugPrint("✅ Total Fare: ${response["data"]["total_fare"]}");
          totalFare.value = response["data"]["total_fare"];
          totalTax.value = response["data"]["tax_amount"];
          distanceKm.value =
              double.tryParse(response['data']['distance_km'].toString()) ??
              0.0;

          Get.snackbar(
            "Success",
            "Fare estimated: \$${response["data"]["total_fare"]}",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
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
        "Failed to estimate fare. $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      isEstimateFare.value = false;
    }
  }
  String? get pickupDateTimeForApi {
    final date = selectedDate.value;
    final time = selectedTime.value;

    if (date == null || time == null) {
      return null;
    }

    final combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return DateFormat("yyyy-MM-dd HH:mm:ss").format(combinedDateTime);
  }

  Future<void> bookApi(
    BuildContext context, {
    required int vehicleTypeId,
    required int type,
    required bool isAirportPickup,
    required String flightNumber,
  }) async {
    // ✅ ADD DEBUG PRINTS AT THE START
    debugPrint("=== ESTIMATE FARE CALLED ===");
    debugPrint("From Location: ${fromLocation.value}");
    debugPrint("From LatLng: ${fromLatLng.value}");
    debugPrint("Drop-off Location: ${dropOffLocation.value}");
    debugPrint("Drop-off LatLng: ${dropOffLatLng.value}");
    debugPrint("Vehicle Type ID: $vehicleTypeId");
    debugPrint(
      "Trip Type: ${selectValue.value == 0 ? 'one_way' : 'round_trip'}",
    );

    // Validation before making API call
    if (fromLatLng.value == null) {
      Get.snackbar(
        "Error",
        "Please select pickup location",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (dropOffLatLng.value == null) {
      Get.snackbar(
        "Error",
        "Please select drop-off location",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    // ✅ Date & Time validation
    if (pickupDateTimeForApi == null) {
      Get.snackbar(
        "Error",
        "Please select pickup date & time",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isBookRide.value = true;

    String tripType = selectValue.value == 0 ? "one_way" : "round_trip";

    debugPrint("time : $pickupDateTimeForApi");
    var body = {
      "pickup_latitude": fromLatLng.value!.latitude,
      "pickup_longitude": fromLatLng.value!.longitude,
      "pickup_address": fromLocation.value,
      "drop_latitude": dropOffLatLng.value!.latitude,
      "drop_longitude": dropOffLatLng.value!.longitude,
      "drop_address": dropOffLocation.value,
      "id": vehicleTypeId,
      "trip_type": tripType,
      // "pickup_datetime" :"$formattedDate $formattedTime",
      "pickup_datetime": pickupDateTimeForApi,
      "tip_amount": "0.0",
      "type": type,
      "is_flight" : isAirportPickup == true ? 1 : 0,
      "flight_number" : flightNumber,
    };

    debugPrint("📤 API Request Body: $body");

    try {
      final response = await ApiService.post(endpoint: 'rides', body: body);

      debugPrint("📥 API Response: $response");

      if (response['success'] == true) {
        // debugPrint("✅ Total Fare: $response");
        rideBookingMessage.value = response['message'];
        print(response['data']['ride']['pickup_datetime']);
        showRideConfirmed(context);

        // ✅ CLEAR DATA AFTER SUCCESS
        clearBookingData();
        /*totalFare.value = response["data"]["total_fare"];

        Get.snackbar(
          "Success",
          "Fare estimated: \$${response["data"]["total_fare"]}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );*/
      } else {
        debugPrint(
          "❌ Error in estimateFare: ${"${response["message"] ?? response["errors"] ?? "Failed to estimate fare"}"}",
        );
        Get.snackbar(
          "Error",
          "${response["message"] ?? response["errors"] ?? "Failed to estimate fare"}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("❌ Error in booking: $e");
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );
    } finally {
      isBookRide.value = false;
      //  isBookRide.value = false;
    }
  }

  void showRideConfirmed(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Obx(() {
          return RideConfirmedWidget(dateTimeText: rideBookingMessage.value);
        });
      },
    );
  }

  void clearBookingData() {
    // Locations
    fromLocation.value = "";
    dropOffLocation.value = "";
    fromLatLng.value = null;
    dropOffLatLng.value = null;

    // Date & Time (THIS FIXES THE ERROR)
    selectedDate.value = null;
    selectedTime.value = null;

    // Trip & Fare
    selectValue.value = 0; // one_way
    totalFare.value = 0.0;
    totalTax.value = 0.0;
    distanceKm.value = 0.0;

    // Flags
    isEstimateFare.value = false;
    isBookRide.value = false;

    debugPrint("🧹 Booking data cleared");
  }
}

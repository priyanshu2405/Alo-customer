import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart' show ApiService;
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RideCompletedController extends GetxController {
  RxDouble selectedStars = 3.0.obs;
  RxBool  isCreatePaymentIntent = false.obs;

  /// 🔥 SINGLE SOURCE OF TRUTH
  RxDouble tipAmount = 0.0.obs;

   RxDouble finalTotal = 0.0.obs;

  final TextEditingController amountCtrl = TextEditingController();

  /// When preset tip selected ($1, $3, $5)
  void onTipSelected(double value) {
    tipAmount.value = value;
    amountCtrl.text = value.toStringAsFixed(2);
  }

  /// When custom amount typed
  void onCustomAmountChanged(String value) {
    final parsed = double.tryParse(value) ?? 0.0;
    tipAmount.value = parsed;
  }


  Future<void> createPaymentIntent({required int id}) async {
    isCreatePaymentIntent.value = true; // Start loading

    var body = {
      "ride_id": id
    };
    debugPrint("body : $body");

    try {
      final response = await ApiService.post(
        endpoint: 'payment/create-intent',
        body: body,
      );

      // debugPrint("otp verify =====>${response["otp"]}");
      if (response['success'] == true) {
        debugPrint("payment intent id : ${response["data"]["payment_intent_id"]}");
        debugPrint("client secret : ${response["data"]["client_secret"]}");
        debugPrint("amount : ${response["data"]["amount"]}");
        debugPrint("currency : ${response["data"]["currency"]}");
        // Get.back();

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
        backgroundColor: AppColors.secondary.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isCreatePaymentIntent.value = false; // Stop loading in all cases
    }
  }



  @override
  void onClose() {
    amountCtrl.dispose();
    super.onClose();
  }
}

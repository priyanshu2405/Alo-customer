import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/controller/my_ride_controller.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart' show ApiService;
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RideCompletedController extends GetxController {
  RxDouble selectedStars = 1.0.obs;
  RxBool  isCreatePaymentIntent = false.obs;
  final MyRideController myRideController = Get.put(MyRideController());
  /// 🔥 SINGLE SOURCE OF TRUTH
  RxDouble tipAmountValue = 0.0.obs;

   RxDouble finalTotal = 0.0.obs;
  RxBool isTipAmount = false.obs;
  final TextEditingController amountCtrl = TextEditingController();

  /// When preset tip selected ($1, $3, $5)
  void onTipSelected(double value) {
    tipAmountValue.value = value;
    amountCtrl.text = value.toStringAsFixed(2);
  }

  /// When custom amount typed
  void onCustomAmountChanged(String value) {
    final parsed = double.tryParse(value) ?? 0.0;
    tipAmountValue.value = parsed;
  }




  Future<void> tipAmountApi({
    required int tipAmount,
    required int rideId,
  }) async {
    debugPrint("=== TIP API CALLED ===");
    debugPrint("tipAmount: $tipAmount");

    isTipAmount.value = true;

    final body = {
      "tip_amount": tipAmount,
      "rating": selectedStars.value,
    };

    debugPrint("📤 API Request Body: $body");

    try {
      final response = await ApiService.post(
        endpoint: 'rides/$rideId/add-tip',
        body: body,
      );

      debugPrint("📥 API Response: $response");

      if (response['success'] == true) {
        final rideData = response['data']?['ride'];

        if (rideData != null) {
          tipAmountValue.value =
              double.tryParse(rideData['tip_amount']?.toString() ?? '0') ?? 0.0;

          finalTotal.value =
              double.tryParse(rideData['total_fare']?.toString() ?? '0') ?? 0.0;
        }


        /// ✅ CLEAR TIP STATE
        selectedStars.value = 1;
        tipAmountValue.value = 0.0;
        amountCtrl.clear(); // custom input field
        myRideController.getRideDetails(id: rideId);
        Get.back();

        Get.snackbar(
          "Success",
          "Tip and rating added successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.85),
          colorText: Colors.white,
        );


      } else {
        Get.back();
        debugPrint("❌ Error in response: $response");
        // ❌ DO NOT update tip or total here
        Get.snackbar(
          "Error",
          response["message"] ?? "Failed to submit tip",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.85),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      selectedStars.value = 1;
      tipAmountValue.value = 0.0;
      amountCtrl.clear(); // custom input field
      Get.back();
      debugPrint("❌ Error in tipAmountApi: $e");
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );

      // final controller = Get.put(DashBoardController());
      // controller.changeIndex(1);
      // Get.to(() => DashboardScreen());
    } finally {
      isTipAmount.value = false;
    }
  }






  /// POST /api/user/rides/{rideId}/pay-with-saved-card
  /// `paymentMethodId` is the backend card row id (from GET /payment-methods),
  /// not the Stripe `pm_xxx`.
  ///
  /// This runs off_session with no payment sheet, so there are no billing
  /// details for the backend to fall back to — [receiptEmail] is the only
  /// address available for users whose account has no email.
  ///
  /// Returns the raw response (null on failure) so the caller can read
  /// `receipt_sent` / `receipt_email` and offer the manual resend.
  Future<Map<String, dynamic>?> payRideWithSavedCard({
    required int rideId,
    required int paymentMethodId,
    String? receiptEmail,
  }) async {
    isCreatePaymentIntent.value = true;
    try {
      final response = await ApiService.post(
        endpoint: 'rides/$rideId/pay-with-saved-card',
        body: {
          'payment_method_id': paymentMethodId,
          if (receiptEmail != null && receiptEmail.trim().isNotEmpty)
            'receipt_email': receiptEmail.trim(),
        },
        isShow: true,
      );
      debugPrint('payRideWithSavedCard response: $response');

      final isSuccess =
          response['success'] == true || response['status'] == true;
      if (isSuccess) {
        await myRideController.getRideDetails(id: rideId);
        return response;
      }
      return null;
    } catch (e) {
      debugPrint('payRideWithSavedCard error: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );
      return null;
    } finally {
      isCreatePaymentIntent.value = false;
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent({required int id}) async {
    isCreatePaymentIntent.value = true;

    var body = {"ride_id": id};
    debugPrint("Creating payment intent with body: $body");

    try {
      final response = await ApiService.post(
        endpoint: 'payment/create-intent',
        body: body,
      );

      if (response['success'] == true) {
        debugPrint("✅ Payment intent created successfully");
        debugPrint("Payment Intent ID: ${response["data"]["payment_intent_id"]}");
        debugPrint("Client Secret: ${response["data"]["client_secret"]}");
        debugPrint("Amount: ${response["data"]["amount"]}");
        debugPrint("Currency: ${response["data"]["currency"]}");

        // ✅ RETURN the payment intent data
        return {
          'id': response["data"]["payment_intent_id"],
          'client_secret': response["data"]["client_secret"],
          'amount': response["data"]["amount"],
          'currency': response["data"]["currency"],
        };
      } else {
        Get.snackbar(
          "Error",
          response["message"] ?? "Failed to create payment intent",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      print("❌ Error in createPaymentIntent: $e");
      Get.snackbar(
        "Error",
        "Failed to create payment: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return null;
    } finally {
      isCreatePaymentIntent.value = false;
    }
  }

  Future<Map<String, dynamic>> savePaymentDetails(Map<String, dynamic> body) async  {
    isCreatePaymentIntent.value = true;
    try {
      debugPrint("body : ${body}");
      final response = await ApiService.post(
        endpoint: 'payment/confirm',
        body: body,
      );

      print("message: ${response['message']}");
      // clearAgreementForm();
      return response;
    } catch (e) {
      print("Error in : $e");
      Get.snackbar(
        "Error",
        "Error in : $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return {
        'status': false,
        'message': 'Exception occurred',
      };
    } finally {
      isCreatePaymentIntent.value = false;
    }
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    super.onClose();
  }
}

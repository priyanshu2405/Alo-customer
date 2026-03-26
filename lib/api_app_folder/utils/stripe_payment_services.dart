// ==================== stripe_payment_service.dart ====================
import 'dart:convert';
import 'dart:developer';
import 'package:alo_ride_app/api_app_folder/constant/key_constants.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/packages/package_controller.dart';
import 'package:alo_ride_app/api_app_folder/utils/payment_success_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/controller/ride_completed_controller.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;


class StripePaymentService extends GetxController {
  Map<String, dynamic>? paymentIntent;


  RideCompletedController get controller => Get.find<RideCompletedController>();

  /// Call this to start the payment process
  Future<void> buyNow(
      BuildContext context,
      String amount, {
        int? id,
      }) async {
    print("Starting payment for amount: $amount");
    try {
      // ✅ FIXED: Now returns Map instead of void
      paymentIntent = await controller.createPaymentIntent(id: id??0);

      if (paymentIntent == null || !paymentIntent!.containsKey('client_secret')) {
        log("❌ Failed to create PaymentIntent.");
        showSnackBar(context, "Failed to initialize payment. Please try again.");
        return;
      }

      // Initialize Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          paymentIntentClientSecret: paymentIntent?['client_secret'],
          merchantDisplayName: 'Alo Ride',
          style: ThemeMode.dark,
          billingDetailsCollectionConfiguration:
          const BillingDetailsCollectionConfiguration(
            name: CollectionMode.always,
            phone: CollectionMode.always,
            email: CollectionMode.always,
          ),
        ),
      );

      // Display the payment sheet
      await displayPaymentSheet(
        context,
        amount: amount,
      );
    } catch (e, stackTrace) {
      log("❌ buyNow() error: $e", stackTrace: stackTrace);
      showSnackBar(context, "Something went wrong. Please try again.");
    }
  }

  /// Show the payment sheet
  Future<void> displayPaymentSheet(
      BuildContext context, {
        int? bookingId,
        int? hostId,
        String? amount,
      }) async {
    try {
      // Present the payment sheet to user
      await Stripe.instance.presentPaymentSheet();

      // Verify payment status with Stripe
      paymentIntent = await checkStripePaymentStatus(paymentIntent?['id']);
      update();

      final transactionId = paymentIntent?['id'];
      final currency = paymentIntent?['currency'];
      final status = paymentIntent?['status'];
      final paymentMethodTypes = paymentIntent?['payment_method_types'];
      final stripeToken = transactionId;

      // Convert payment method types to string
      String paymentMethodTypesValue = "";
      if (paymentMethodTypes is List) {
        paymentMethodTypesValue = paymentMethodTypes.join(",");
      } else if (paymentMethodTypes is String) {
        paymentMethodTypesValue = paymentMethodTypes;
      }

      log("✅ Payment successful");
      log("📌 Transaction ID: $transactionId");
      log("💰 Amount: $amount $currency");
      log("✔️ Status: $status");
      log("💳 Payment Method: $paymentMethodTypesValue");

      // Save payment details to backend
      await savePaymentDetails(
        bookingId: bookingId,
        hostId: hostId,
        paymentMethodTypes: paymentMethodTypesValue,
        amount: amount.toString(),
        stripeToken: stripeToken,
        context,
      );
    } on StripeException catch (e) {
      log("❌ StripeException: ${e.error.localizedMessage}");
      if (context.mounted) {
        showSnackBar(context, e.error.localizedMessage ?? "Payment failed");
      }
    } catch (e) {
      log("❌ Unexpected error: $e");
      if (context.mounted) {
        showSnackBar(context, "An unexpected error occurred.");
      }
    } finally {
      print("Final Status: ${paymentIntent?['status']}");
      paymentIntent = null;
      update();
    }
  }

  /// Save payment details to backend
  Future<void> savePaymentDetails(
      BuildContext context, {
        int? bookingId,
        int? hostId,
        String? amount,
        String? paymentMethodTypes,
        String? stripeToken,
      }) async {
    // Check if context is still valid before showing dialog
    if (!context.mounted) {
      log("❌ Context is not mounted, skipping dialog");
      return;
    }

    Get.dialog(const LoaderDialog(), barrierDismissible: false);

    try {
      final txnId = paymentIntent?['id'];
      final status = paymentIntent?['status'];

      if (txnId == null || txnId.isEmpty) {
        throw Exception("Missing transaction ID.");
      }

      final body = {
        "payment_intent_id": txnId,
        "status": "succeeded",
        // Add other fields as needed:
        // "booking_id": bookingId,
        // "host_id": hostId,
        // "amount": amount,
        // "payment_method": paymentMethodTypes,
      };

      print("Saving Payment: $body");

      final response = await controller.savePaymentDetails(body);

      if (response['status'] == true || response['success'] == true) {
        // Check context again before showing snackbar
        if (context.mounted) {
          _showSnackBarSafe(context, response['message'] ?? 'Payment successful');
        }

        // Navigate to success page if payment succeeded
        if (status == "succeeded") {
          Get.offAll(() => DashboardScreen());
        }
      } else {
        print("Payment save failed");
        Get.snackbar(
          'Error',
          response['error_message'] ?? response['message'] ?? 'Payment failed',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      log("❌ Error saving payment: $e");
      log("📍 StackTrace: $stackTrace");

      // Use Get.snackbar for error messages as it's more reliable
      Get.snackbar(
        'Error',
        "Failed to save payment: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Always close the dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  /// Safe method to show snackbar with context validation
  void _showSnackBarSafe(BuildContext context, String message) {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      // Fallback to Get.snackbar if context is invalid
      Get.snackbar(
        'Info',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  /// Show simple snackbar
  void showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: AppColors.white),
          ),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  /// Check payment status directly from Stripe
  Future<Map<String, dynamic>> checkStripePaymentStatus(
      String paymentIntentId,
      ) async {
    final response = await http.get(
      Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId'),
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    final data = jsonDecode(response.body);
    print("Stripe Status Response: $data");
    return data;
  }

  /// Safely close any open dialogs or snackbars
  void safeCloseDialogOrSnackbar() {
    if (Get.isSnackbarOpen) {
      try {
        Get.closeCurrentSnackbar();
      } catch (e) {
        // Ignore already disposed snackbar
      }
    }

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

/// Loading dialog widget
class LoaderDialog extends StatelessWidget {
  const LoaderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }
}



class SubscriptionPaymentService extends GetxController {
  Map<String, dynamic>? paymentIntent;


  PackageController get controller => Get.find<PackageController>();

  /// Call this to start the payment process
  Future<void> buyNow(
      BuildContext context,
      String amount, {
        int? id,
      }) async {
    print("Starting payment for amount: $amount");
    try {
      // ✅ FIXED: Now returns Map instead of void
      paymentIntent = await controller.createPaymentIntent(id: id??0);

      if (paymentIntent == null || !paymentIntent!.containsKey('client_secret')) {
        log("❌ Failed to create PaymentIntent.");
        showSnackBar(context, "Failed to initialize payment. Please try again.");
        return;
      }

      // Initialize Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          paymentIntentClientSecret: paymentIntent?['client_secret'],
          merchantDisplayName: 'Alo Ride',
          style: ThemeMode.dark,
          billingDetailsCollectionConfiguration:
          const BillingDetailsCollectionConfiguration(
            name: CollectionMode.always,
            phone: CollectionMode.always,
            email: CollectionMode.always,
          ),
        ),
      );

      // Display the payment sheet
      await displayPaymentSheet(
        context,
        amount: amount,
      );
    } catch (e, stackTrace) {
      log("❌ buyNow() error: $e", stackTrace: stackTrace);
      showSnackBar(context, "Something went wrong. Please try again.");
    }
  }

  /// Show the payment sheet
  Future<void> displayPaymentSheet(
      BuildContext context, {
        int? bookingId,
        int? hostId,
        String? amount,
      }) async {
    try {
      // Present the payment sheet to user
      await Stripe.instance.presentPaymentSheet();
       print("PaymentIntentId:: ${paymentIntent?['id']}");
      // Verify payment status with Stripe
      paymentIntent = await checkStripePaymentStatus(paymentIntent?['id']);
      update();

      final transactionId = paymentIntent?['id'];
      final currency = paymentIntent?['currency'];
      final status = paymentIntent?['status'];
      final paymentMethodTypes = paymentIntent?['payment_method_types'];
      final stripeToken = transactionId;

      // Convert payment method types to string
      String paymentMethodTypesValue = "";
      if (paymentMethodTypes is List) {
        paymentMethodTypesValue = paymentMethodTypes.join(",");
      } else if (paymentMethodTypes is String) {
        paymentMethodTypesValue = paymentMethodTypes;
      }

      log("✅ Payment successful");
      log("📌 Transaction ID: $transactionId");
      log("💰 Amount: $amount $currency");
      log("✔️ Status: $status");
      log("💳 Payment Method: $paymentMethodTypesValue");

      // Save payment details to backend
      await savePaymentDetails(
        // bookingId: bookingId,
        // hostId: hostId,
        // paymentMethodTypes: paymentMethodTypesValue,
        // amount: amount.toString(),
        // stripeToken: stripeToken,
        context,
      );
    } on StripeException catch (e) {
      log("❌ StripeException: ${e.error.localizedMessage}");
      if (context.mounted) {
        showSnackBar(context, e.error.localizedMessage ?? "Payment failed");
      }
    } catch (e) {
      log("❌ Unexpected error: $e");
      if (context.mounted) {
        showSnackBar(context, "An unexpected error occurred.");
      }
    } finally {
      print("Final Status: ${paymentIntent?['status']}");
      paymentIntent = null;
      update();
    }
  }

  /// Save payment details to backend
  Future<void> savePaymentDetails(
      BuildContext context, /*{
        int? bookingId,
        int? hostId,
        String? amount,
        String? paymentMethodTypes,
        String? stripeToken,
      }*/) async {
    // Check if context is still valid before showing dialog
    if (!context.mounted) {
      log("❌ Context is not mounted, skipping dialog");
      return;
    }

    Get.dialog(const LoaderDialog(), barrierDismissible: false);

    try {
      final txnId = paymentIntent?['id'];
      final status = paymentIntent?['status'];

      if (txnId == null || txnId.isEmpty) {
        throw Exception("Missing transaction ID.");
      }


      print("Saving Payment: $txnId");

      final response = await controller.savePaymentDetails(paymentIntentId:txnId );

      if (response['status'] == true || response['success'] == true) {
        // Check context again before showing snackbar
        if (context.mounted) {
          _showSnackBarSafe(context, response['message'] ?? 'Payment successful');
        }

        // Navigate to success page if payment succeeded
        if (status == "succeeded") {
          Get.offAll(() => PaymentSuccessView(
            transactionId: txnId,
            message: response['message'],
          ));
        }
      } else {
        print("Payment save failed");
        Get.snackbar(
          'Error',
          response['error_message'] ?? response['message'] ?? 'Payment failed',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      log("❌ Error saving payment: $e");
      log("📍 StackTrace: $stackTrace");

      // Use Get.snackbar for error messages as it's more reliable
      Get.snackbar(
        'Error',
        "Failed to save payment: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Always close the dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  /// Safe method to show snackbar with context validation
  void _showSnackBarSafe(BuildContext context, String message) {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      // Fallback to Get.snackbar if context is invalid
      Get.snackbar(
        'Info',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  /// Show simple snackbar
  void showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: AppColors.white),
          ),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  /// Check payment status directly from Stripe
  Future<Map<String, dynamic>> checkStripePaymentStatus(
      String paymentIntentId,
      ) async {
    final response = await http.get(
      Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId'),
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    final data = jsonDecode(response.body);
    log("Stripe Status Response: $data");
    return data;
  }

  /// Safely close any open dialogs or snackbars
  void safeCloseDialogOrSnackbar() {
    if (Get.isSnackbarOpen) {
      try {
        Get.closeCurrentSnackbar();
      } catch (e) {
        // Ignore already disposed snackbar
      }
    }

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}



// ==================== ride_completed_controller.dart ====================
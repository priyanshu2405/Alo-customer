// ==================== stripe_payment_service.dart ====================
import 'dart:developer';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/packages/package_controller.dart';
import 'package:alo_ride_app/api_app_folder/utils/payment_success_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/controller/ride_completed_controller.dart';
import 'package:flutter_stripe/flutter_stripe.dart';


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
      // Throws on failure or cancellation, so reaching the next line means
      // the payment went through. `payment/confirm` re-verifies server-side.
      await Stripe.instance.presentPaymentSheet();
      update();

      final transactionId = paymentIntent?['id'];

      log("✅ Payment successful");
      log("📌 Transaction ID: $transactionId");
      log("💰 Amount: $amount ${paymentIntent?['currency']}");

      // Save payment details to backend
      await savePaymentDetails(
        bookingId: bookingId,
        hostId: hostId,
        amount: amount.toString(),
        stripeToken: transactionId,
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
      };

      print("Saving Payment: $body");

      final response = await controller.savePaymentDetails(body);

      // `payment/confirm` verifies with Stripe server-side, so its response is
      // the authoritative signal that the payment landed.
      if (response['status'] == true || response['success'] == true) {
        // Check context again before showing snackbar
        if (context.mounted) {
          _showSnackBarSafe(context, response['message'] ?? 'Payment successful');
        }

        Get.offAll(() => DashboardScreen());
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
      // Throws on failure or cancellation, so reaching the next line means
      // the payment went through. `packages/confirm-payment` re-verifies
      // server-side.
      await Stripe.instance.presentPaymentSheet();
      update();

      log("✅ Payment successful");
      log("📌 Transaction ID: ${paymentIntent?['id']}");
      log("💰 Amount: $amount ${paymentIntent?['currency']}");

      // Save payment details to backend
      await savePaymentDetails(context);
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

      if (txnId == null || txnId.isEmpty) {
        throw Exception("Missing transaction ID.");
      }


      print("Saving Payment: $txnId");

      final response = await controller.savePaymentDetails(paymentIntentId:txnId );

      // `packages/confirm-payment` verifies with Stripe server-side, so its
      // response is the authoritative signal that the payment landed.
      if (response['status'] == true || response['success'] == true) {
        // Check context again before showing snackbar
        if (context.mounted) {
          _showSnackBarSafe(context, response['message'] ?? 'Payment successful');
        }

        Get.offAll(() => PaymentSuccessView(
          transactionId: txnId,
          message: response['message'],
        ));
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
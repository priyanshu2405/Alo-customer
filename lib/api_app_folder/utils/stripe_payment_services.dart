// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:alo_ride_app/api_app_folder/screen/ride/view/ride_completed_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
//
//
// class StripePaymentService extends GetxController {
//   Map<String, dynamic>? paymentIntent;
//
//   RideCompletedScreen get controller => Get.find<RideCompletedScreen>();
//
//   /// Call this to start the payment process
//   Future<void> buyNow(
//     BuildContext context,
//     String amount, {
//     int? bookingId,
//     int? hostId,
//   }) async {
//     print(amount);
//     try {
//       paymentIntent = await createPaymentIntent(amount, "USD");
//       if (paymentIntent == null ||
//           !paymentIntent!.containsKey('client_secret')) {
//         log("❌ Failed to create PaymentIntent.");
//         return;
//       }
//
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           customFlow: false,
//           paymentIntentClientSecret: paymentIntent?['client_secret'],
//           merchantDisplayName: 'Demo Store',
//           style: ThemeMode.dark,
//           billingDetailsCollectionConfiguration:
//               BillingDetailsCollectionConfiguration(
//                 name: CollectionMode.always,
//                 phone: CollectionMode.always,
//                 email: CollectionMode.always,
//               ),
//         ),
//       );
//
//       await displayPaymentSheet(
//         context,
//         bookingId: bookingId,
//         hostId: hostId,
//         amount: amount.toString(),
//       );
//     } catch (e, stackTrace) {
//       log("❌ buyNow() error: $e", stackTrace: stackTrace);
//       showSnackBar(context, "Something went wrong. Try again.");
//     }
//   }
//
//   /// Create a PaymentIntent via Stripe API
//   Future<Map<String, dynamic>?> createPaymentIntent(
//     String amount,
//     String currency,
//   ) async {
//     try {
//       Map<String, dynamic> body = {
//         'currency': currency,
//         'amount': ((double.parse(amount)) * 100).toInt().toString(),
//         // Stripe expects amount in cents
//         'payment_method_types[]': 'card',
//       };
//
//       var response = await http.post(
//         Uri.parse("https://api.stripe.com/v1/payment_intents"),
//         body: body,
//         headers: {
//           'Authorization': 'Bearer $secretKey',
//           // Replace with your real secret key
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//       );
//
//       final decoded = jsonDecode(response.body);
//       if (decoded['error'] != null) {
//         log("❌ Stripe error: ${decoded['error']['message']}");
//         return null;
//       }
//
//       log("✅ PaymentIntent created: $decoded");
//       return decoded;
//     } catch (e) {
//       log("❌ createPaymentIntent() error: $e");
//       return null;
//     }
//   }
//
//   /// Show the payment sheet
//   Future<void> displayPaymentSheet(
//     BuildContext context, {
//     int? bookingId,
//     int? hostId,
//     String? amount,
//   }) async {
//     try {
//       await Stripe.instance.presentPaymentSheet();
//       paymentIntent = await checkStripePaymentStatus(paymentIntent?['id']);
//       update();
//       final transactionId = paymentIntent?['id'];
//       // final amount = amount??0;
//       final currency = paymentIntent?['currency'];
//       final status = paymentIntent?['status'];
//       // final paymentMethodId = paymentIntent?['payment_method'];
//       final paymentMethodTypes =
//           paymentIntent?['payment_method_types']; // e.g. [card]
//       final stripeToken = transactionId;
//
//       String paymentMethodTypesValue = "";
//       if (paymentMethodTypes is List) {
//         paymentMethodTypesValue = paymentMethodTypes.join(",");
//       } else if (paymentMethodTypes is String) {
//         paymentMethodTypesValue = paymentMethodTypes;
//       }
//
//       log("✅ Payment successful");
//       log("📌 Transaction ID: $paymentIntent");
//       log("💰 Amount: $amount $currency");
//       log("💰 status: $status");
//       log("💰 paymentMethodTypes: $paymentMethodTypesValue");
//       log("💰 stripeToken: $stripeToken");
//
//       await savePaymentDetails(
//         bookingId: bookingId,
//         hostId: hostId,
//         paymentMethodTypes: paymentMethodTypesValue,
//         amount: amount.toString(),
//         stripeToken: stripeToken,
//         context,
//       );
//
//       // update();
//     } on StripeException catch (e) {
//       log("❌ StripeException: ${e.error.localizedMessage}");
//       // showSnackBar(context, "${e.error.localizedMessage}");
//     } catch (e) {
//       log("❌ Unexpected error: $e");
//       //   showSnackBar(context, "❌ Unexpected error occurred.");
//     } finally {
//       print("Status::->> ${paymentIntent?['status']}");
//       paymentIntent = null;
//       update();
//     }
//   }
//
//   Future<void> savePaymentDetails(
//     BuildContext context, {
//     int? bookingId,
//     int? hostId,
//     String? amount,
//     String? paymentMethodTypes,
//     String? stripeToken,
//   }) async {
//     // Check if context is still valid before showing dialog
//     if (!context.mounted) {
//       log("❌ Context is not mounted, skipping dialog");
//       return;
//     }
//
//     Get.dialog(const LoaderDialog(), barrierDismissible: false);
//
//     try {
//       final txnId = paymentIntent?['id'];
//       final status = paymentIntent?['status'];
//
//       if (txnId == null || txnId.isEmpty) {
//         throw Exception("Missing transaction ID.");
//       }
//
//       final body = {
//         "booking_id": bookingId,
//         "host_id": hostId,
//         "amount": amount,
//         "payment_method": paymentMethodTypes,
//         "transaction_id": txnId,
//         "status": status == "succeeded" ? "1" : "0",
//       };
//       // final body = {"package_id": 1, "txn_id": "pi_3ReCThRpwSodBvKe0WhGKgwu", "payment_status": 1};
//
//       print("Saving Payment: $body");
//
//       final response = await controller.savePaymentDetails(body);
//
//       if (response['status']) {
//         // Check context again before showing snackbar
//         if (context.mounted) {
//           _showSnackBarSafe(context, response['message']);
//         }
//
//         // Navigate to success page if payment succeeded
//         if (status == "succeeded") {
//           Get.offAll(() => PaymentSuccessView(txnId: response["data"]['order_id']));
//         }
//       } else {
//         print("Payment save failed");
//         Get.snackbar(
//           'Error',
//           response['error_message'] ?? 'Payment failed',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e, stackTrace) {
//       log("❌ Error saving payment: $e");
//       log("📍 StackTrace: $stackTrace");
//
//       // Use Get.snackbar for error messages as it's more reliable
//       Get.snackbar(
//         'Error',
//         "Failed to save payment: ${e.toString()}",
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       // Always close the dialog
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       }
//     }
//   }
//
//   // Safe method to show snackbar with context validation
//   void _showSnackBarSafe(BuildContext context, String message) {
//     try {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(message,style: TextStyle(color: context.colorScheme.secondary),), backgroundColor:  context.colorScheme.primary),
//         );
//       }
//     } catch (e) {
//       // Fallback to Get.snackbar if context is invalid
//       Get.snackbar(
//         'Info',
//         message,
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: context.colorScheme.primary,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   void showSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message,style: TextStyle(color: context.colorScheme.secondary),), backgroundColor:  context.colorScheme.primary),
//     );
//   }
//
//   Future<Map<String, dynamic>> checkStripePaymentStatus(
//     String paymentIntentId,
//   ) async {
//     final response = await http.get(
//       Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId'),
//       headers: {
//         'Authorization': 'Bearer $secretKey',
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//     );
//     final data = jsonDecode(response.body);
//     print("data--> $data");
//     return data;
//   }
//
//   void safeCloseDialogOrSnackbar() {
//     if (Get.isSnackbarOpen) {
//       try {
//         Get.closeCurrentSnackbar();
//       } catch (e) {
//         // Ignore already disposed snackbar
//       }
//     }
//
//     if (Get.isDialogOpen ?? false) {
//       Get.back();
//     }
//   }
// }
//
// class LoaderDialog extends StatelessWidget {
//   const LoaderDialog({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: CircularProgressIndicator(color: Colors.white));
//   }
// }

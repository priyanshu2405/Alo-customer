import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/profile/controller/profile_controller.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Receipt outcome reported by `payment/confirm`, `packages/confirm-payment`
/// and `rides/{id}/pay-with-saved-card`.
///
/// The app never sends the email itself — Stripe does. These fields only say
/// whether the backend managed to attach an address to the charge.
class ReceiptInfo {
  final String? email;
  final bool sent;

  const ReceiptInfo({this.email, this.sent = false});

  /// Reads `receipt_email` / `receipt_sent` from the response root or from
  /// `data`, since the endpoints are not consistent about where they nest it.
  factory ReceiptInfo.fromResponse(Map<String, dynamic>? response) {
    if (response == null) return const ReceiptInfo();

    dynamic pick(String key) {
      if (response.containsKey(key)) return response[key];
      final data = response['data'];
      if (data is Map<String, dynamic>) return data[key];
      return null;
    }

    final email = pick('receipt_email');
    final sent = pick('receipt_sent');

    return ReceiptInfo(
      email: email is String && email.isNotEmpty ? email : null,
      sent: sent == true || sent == 1 || sent == '1' || sent == 'true',
    );
  }
}

class ReceiptService {
  ReceiptService._();

  static final RegExp _emailPattern =
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static bool isValidEmail(String value) =>
      _emailPattern.hasMatch(value.trim());

  /// The email on the logged-in user's account, or null for OTP-only users.
  ///
  /// Used both to prefill the Stripe payment sheet and to decide whether the
  /// saved-card flow has to ask for an address before paying.
  static String? get accountEmail {
    if (!Get.isRegistered<ProfileController>()) return null;
    final email =
        Get.find<ProfileController>().profileData.value.data?.user?.email;
    if (email == null || email.trim().isEmpty) return null;
    return email.trim();
  }

  /// Same as [accountEmail], but fetches the profile first when it has not
  /// been loaded yet — payment can be started from screens that never opened
  /// the profile tab.
  static Future<String?> resolveAccountEmail() async {
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    if (controller.profileData.value.data?.user == null) {
      await controller.getProfile();
    }
    return accountEmail;
  }

  /// Persists an address the user typed in the Stripe payment sheet so future
  /// payments get a receipt without asking again. No-op when the account
  /// already has an email.
  static Future<void> saveEmailToProfileIfMissing(String? email) async {
    if (email == null || email.trim().isEmpty) return;
    if (accountEmail != null) return;
    if (!isValidEmail(email)) return;

    try {
      final controller = Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());
      await controller.editProfile(email: email.trim());
    } catch (e) {
      // Best-effort only — the receipt was already sent by Stripe.
      debugPrint('saveEmailToProfileIfMissing failed: $e');
    }
  }

  /// Asks the user for an address to send the receipt to.
  ///
  /// Returns null when dismissed.
  static Future<String?> promptForEmail({
    String title = 'Email receipt',
    String message = 'Where should we send your receipt?',
    String? prefill,
  }) async {
    final controller = TextEditingController(text: prefill ?? '');
    final error = RxString('');

    final result = await Get.dialog<String>(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(title, style: const TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            Obx(
              () => error.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        error.value,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<String>(),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (!isValidEmail(value)) {
                error.value = 'Enter a valid email address';
                return;
              }
              Get.back<String>(result: value);
            },
            child: const Text('Send'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    controller.dispose();
    return result;
  }

  /// POST /api/user/payment/send-receipt
  ///
  /// Manual fallback for when the confirm call could not resolve an address.
  static Future<bool> sendReceipt({
    required String paymentIntentId,
    required String email,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: 'payment/send-receipt',
        body: {
          'payment_intent_id': paymentIntentId,
          'email': email,
        },
      );

      final ok = response['success'] == true || response['status'] == true;
      if (ok) {
        showReceiptSent(email);
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Could not send the receipt',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.85),
          colorText: Colors.white,
        );
      }
      return ok;
    } catch (e) {
      debugPrint('sendReceipt error: $e');
      Get.snackbar(
        'Error',
        'Could not send the receipt: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Prompts for an address (prefilled with the account email when we have
  /// one) and sends the receipt. Used by the "Email receipt" / "Resend
  /// receipt" actions.
  static Future<bool> promptAndSendReceipt({
    required String? paymentIntentId,
    String? prefill,
    String title = 'Email receipt',
  }) async {
    if (paymentIntentId == null || paymentIntentId.isEmpty) {
      Get.snackbar(
        'Error',
        'No payment found for this ride',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );
      return false;
    }

    final email = await promptForEmail(
      title: title,
      prefill: prefill ?? accountEmail,
    );
    if (email == null) return false;

    return sendReceipt(paymentIntentId: paymentIntentId, email: email);
  }

  static void showReceiptSent(String email) {
    Get.snackbar(
      'Receipt sent',
      'Receipt sent to $email',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.secondary,
      colorText: Colors.white,
    );
  }
}

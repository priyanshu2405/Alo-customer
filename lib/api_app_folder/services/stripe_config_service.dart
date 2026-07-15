import 'dart:convert';
import 'dart:developer';

import 'package:alo_ride_app/api_app_folder/constant/key_constants.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:http/http.dart' as http;

/// Response of `GET /api/stripe-config`.
///
/// Only the publishable key is consumed. If the endpoint also returns a secret
/// key, it is deliberately ignored — an `sk_` key in the app can be extracted
/// from the binary and grants full Stripe account access.
class StripeConfig {
  final String? publishableKey;

  const StripeConfig({this.publishableKey});

  factory StripeConfig.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final key = root['publishableKey'] ?? root['publishable_key'];
    return StripeConfig(publishableKey: key is String ? key : null);
  }
}

class StripeConfigService {
  static const Duration _timeout = Duration(seconds: 15);

  /// Fetches the publishable key from `/api/stripe-config`.
  ///
  /// Returns null if the key can't be retrieved — there is no embedded
  /// fallback, so Stripe stays uninitialised and payments are unavailable
  /// until the endpoint responds.
  static Future<String?> fetchPublishableKey() async {
    final url = '${ApiService.baseUrl1}stripe-config';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: const {
          'X-API-Key': appApiKey,
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          final key = StripeConfig.fromJson(body).publishableKey;
          if (key != null && key.isNotEmpty) {
            log("✅ Stripe publishable key loaded from $url");
            return key;
          }
        }
        log("❌ stripe-config returned no publishable key");
      } else {
        log("❌ stripe-config returned ${response.statusCode}");
      }
    } catch (e) {
      log("❌ stripe-config fetch failed: $e");
    }
    return null;
  }
}

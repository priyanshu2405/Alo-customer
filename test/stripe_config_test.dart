import 'dart:convert';

import 'package:alo_ride_app/api_app_folder/services/stripe_config_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StripeConfig.fromJson', () {
    test('parses the live /api/stripe-config payload', () {
      // Verbatim response from GET /api/stripe-config (keys truncated).
      final body = jsonDecode('''
      {"status":true,"message":"Stripe configuration retrieved successfully.",
       "data":{"mode":"test",
               "publishable_key":"pk_test_abc123",
               "secret_key":"sk_test_shouldNeverBeUsed"}}
      ''') as Map<String, dynamic>;

      expect(StripeConfig.fromJson(body).publishableKey, 'pk_test_abc123');
    });

    test('accepts camelCase and an unwrapped body', () {
      expect(
        StripeConfig.fromJson({'publishableKey': 'pk_test_xyz'}).publishableKey,
        'pk_test_xyz',
      );
    });

    test('yields null when the key is absent', () {
      expect(
        StripeConfig.fromJson({'data': {'mode': 'test'}}).publishableKey,
        isNull,
      );
    });
  });
}

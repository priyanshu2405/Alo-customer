import 'package:alo_ride_app/api_app_folder/screen/card/view/card_list_screen.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

class CardController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Only the cardholder name is collected via our own UI.
  // Card number / expiry / CVV are handled by the inline Stripe `CardField`.
  final TextEditingController cardHolderController = TextEditingController();

  final RxBool isSaveCard = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isStripeReady = false.obs;
  final Rx<CardFieldInputDetails?> cardDetails = Rx<CardFieldInputDetails?>(null);

  final RxBool isLoadingCards = false.obs;
  final RxList<Map<String, dynamic>> cards = <Map<String, dynamic>>[].obs;

  final RxInt cardFieldResetKey = 0.obs;

  void clearCardField() {
    cardDetails.value = null;
    cardFieldResetKey.value++;
    FocusManager.instance.primaryFocus?.unfocus();
  }


  @override
  void onInit() {
    super.onInit();
    _initStripe();
  }

  @override
  void onClose() {
    cardHolderController.dispose();
    super.onClose();
  }

  Future<void> _initStripe() async {
    try {
      // publishableKey is already set from /api/stripe-config during startup.
      await Stripe.instance.applySettings();
      isStripeReady.value = true;
    } catch (e) {
      debugPrint('Stripe init failed: $e');
      isStripeReady.value = false;
    }
  }

  void onCardChanged(CardFieldInputDetails? details) {
    cardDetails.value = details;
  }

  String? validateCardHolder(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter cardholder name';
    }
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  Future<void> getCards() async {
    isLoadingCards.value = true;
    try {
      final response = await ApiService.get(endpoint: 'payment-methods');

      final raw = (response['data'] ??
          response['payment_methods'] ??
          response['cards'] ??
          response['result']);
      final list = raw is List ? raw : <dynamic>[];

      cards.assignAll(
        list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoadingCards.value = false;
    }
  }

  /// DELETE /api/user/payment-methods/{id}
  Future<void> deleteCard(String id) async {
    if (id.isEmpty) return;

    final idx = cards.indexWhere((c) => c['id']?.toString() == id);
    if (idx == -1) return;

    final removed = Map<String, dynamic>.from(cards[idx]);
    cards.removeAt(idx);

    try {
      await ApiService.delete(
        endpoint: 'payment-methods/$id',
        isShow: true,
      );
    } catch (_) {
      cards.insert(idx, removed);
    }
  }

  /// PUT /api/user/payment-methods/{id}/default
  Future<void> setDefaultCard(String id) async {
    if (id.isEmpty) return;

    final snapshot =
        cards.map((c) => Map<String, dynamic>.from(c)).toList();

    for (var i = 0; i < cards.length; i++) {
      cards[i] = {
        ...cards[i],
        'is_default': cards[i]['id']?.toString() == id,
      };
    }

    try {
      final response = await ApiService.put(
        endpoint: 'payment-methods/$id/default',
        body: {},
        isShow: true,
      );
      debugPrint("setDefaultCard response: $response");
    } catch (e) {
      debugPrint("setDefaultCard error: $e");
      cards.assignAll(snapshot);
      Get.snackbar(
        'Error',
        'Could not update default card',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> saveCard() async {
    FocusManager.instance.primaryFocus?.unfocus();
    // Stripe's CardField is a native view, so Flutter's focus tree
    // doesn't own its keyboard — ask the OS to hide it directly.
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');

    if (!(formKey.currentState?.validate() ?? false)) return;

    if (cardDetails.value?.complete != true) {
      Get.snackbar(
        'Error',
        'Please enter valid card details',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isSaving.value = true;
    try {
      // 1️⃣ Create SetupIntent on the backend.
      final setupResponse = await ApiService.post(
        endpoint: 'payment-methods/setup-intent',
        body: {},
      );

      final data = setupResponse['data'];
      final clientSecret =
          data is Map ? data['client_secret']?.toString() : null;
      final setupIntentId =
          data is Map ? data['setup_intent_id']?.toString() : null;
      final customerId =
          data is Map ? data['customer_id']?.toString() : null;
      final apiPublishableKey =
          data is Map ? data['publishable_key']?.toString() : null;

      debugPrint('────── SetupIntent ──────');
      debugPrint('client_secret   : $clientSecret');
      debugPrint('setup_intent_id : $setupIntentId');
      debugPrint('customer_id     : $customerId');
      debugPrint('publishable_key : $apiPublishableKey');
      debugPrint('─────────────────────────');

      if (clientSecret == null || clientSecret.isEmpty) {
        Get.snackbar(
          'Error',
          setupResponse['message']?.toString() ??
              'Failed to initialize card setup',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Sync the Stripe SDK with the publishable key returned by the backend
      // (falls back to the locally configured key if the API didn't send one).
      if (apiPublishableKey != null &&
          apiPublishableKey.isNotEmpty &&
          Stripe.publishableKey != apiPublishableKey) {
        Stripe.publishableKey = apiPublishableKey;
        await Stripe.instance.applySettings();
        isStripeReady.value = true;
      }

      if (!isStripeReady.value) {
        Get.snackbar(
          'Error',
          'Payment is not ready yet. Please try again.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // 2️⃣ Confirm the SetupIntent with the inline CardField data.
      // Stripe returns a SetupIntent that exposes the new pm_xxx.
      final setupIntent = await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: cardHolderController.text.trim(),
            ),
          ),
        ),
      );

      final paymentMethodId = setupIntent.paymentMethodId;
      debugPrint('paymentMethodId: $paymentMethodId');

      if (paymentMethodId == null || paymentMethodId.isEmpty) {
        Get.snackbar(
          'Error',
          'Could not retrieve payment method',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // 3️⃣ Persist pm_xxx on the backend (records display info + default flag).
      final attachResponse = await ApiService.post(
        endpoint: 'payment-methods',
        body: {
          'payment_method_id': paymentMethodId,
          'set_default': isSaveCard.value,
        },
        isShow: true,
      );

      final isSuccess = attachResponse['success'] == true ||
          attachResponse['status'] == true ||
          attachResponse['data'] != null;

      if (isSuccess) {
        final newCardRaw = attachResponse['data'] ??
            attachResponse['payment_method'] ??
            attachResponse['card'];

        if (newCardRaw is Map) {
          final newCard = Map<String, dynamic>.from(newCardRaw);
          if (newCard['is_default'] == true) {
            for (var i = 0; i < cards.length; i++) {
              cards[i] = {...cards[i], 'is_default': false};
            }
          }
          cards.insert(0, newCard);
        }

        // Clear Stripe CardField
        clearCardField();

        // Hide keyboard
        await SystemChannels.textInput.invokeMethod<void>(
          'TextInput.hide',
        );

        // Go to card list and remove current add-card screen
        Get.off(() => CardListScreen());
      }
    } on StripeException catch (e) {
      Get.snackbar(
        'Error',
        e.error.localizedMessage ??
            e.error.message ??
            'Card verification failed',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isSaving.value = false;
    }
  }
}

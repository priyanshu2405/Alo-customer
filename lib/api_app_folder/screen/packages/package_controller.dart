import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:alo_ride_app/models/model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PackageController extends GetxController {
  RxList<FlatRatesModel> packageList = <FlatRatesModel>[].obs;
  RxList<FlatRatesModel> purchasedPackageList = <FlatRatesModel>[].obs;
  RxBool isVehicleTypes = false.obs;
  RxBool isCreatePaymentIntent = false.obs;

  /// package_id -> purchase_id, built once per API response so the lookup
  /// on tap is O(1) instead of scanning `purchased_packages` every time.
  final RxMap<int, int> purchaseIdByPackageId = <int, int>{}.obs;

  /// Returns the purchase_id for a package, or -1 when it was never purchased.
  int purchaseIdOf(int? packageId) =>
      packageId == null ? -1 : (purchaseIdByPackageId[packageId] ?? -1);

  @override
  void onInit() {
    super.onInit();
    ever(isCreatePaymentIntent, (bool loading) {
      // ✅ Use addPostFrameCallback to avoid "widget tree locked" error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (loading) {
          if (!(Get.isDialogOpen ?? false)) {
            Get.dialog(
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.white,
                ),
              ),
              barrierDismissible: false,
            );
          }
        } else {
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
        }
      });
    });
  }

  Future<void> getPackageList() async {
    try {
      isVehicleTypes.value = true;

      final response = await ApiService.get1(
        endpoint: '${ApiService.baseUrl1}packages',
        isShow: false,
        useBaseUrl: false,
      );

      if (response["success"] == true) {
        final List list = response["data"]['packages'] ?? [];

        packageList.assignAll(
          list.map((e) => FlatRatesModel.fromJson(e)).toList(),
        );

        final List purchased = response["data"]['purchased_packages'] ?? [];

        purchasedPackageList.assignAll(
          purchased.map((e) => FlatRatesModel.fromJson(e)).toList(),
        );

        purchaseIdByPackageId.assignAll({
          for (final p in purchasedPackageList)
            if (p.packageId != null && (p.purchaseId ?? p.id) != null)
              p.packageId!: (p.purchaseId ?? p.id)!,
        });

        debugPrint("length ==> ${packageList.length}");
        debugPrint("purchased map ==> $purchaseIdByPackageId");
      }
    } catch (e) {
      print('Error fetching packages: $e');
    } finally {
      isVehicleTypes.value = false;
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent({required int id}) async {
    isCreatePaymentIntent.value = true;

    var body = {"package_id": id};
    debugPrint("Creating payment intent with body: $body");

    try {
      final response = await ApiService.post(
        endpoint: 'packages/purchase',
        body: body,
      );

      if (response['success'] == true) {
        debugPrint("✅ Payment intent created successfully");
        return response['data'];
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

  Future<Map<String, dynamic>> savePaymentDetails({String? paymentIntentId}) async {
    isCreatePaymentIntent.value = true;
    try {
      debugPrint("body : $paymentIntentId");
      final response = await ApiService.post(
        endpoint: 'packages/confirm-payment',
        body: {"payment_intent_id": paymentIntentId},
      );

      print("message: ${response['message']}");
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
}

import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:alo_ride_app/models/model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController{
  RxBool isLoading = false.obs;
  RxList<PackageHistoryModel> packageList = <PackageHistoryModel>[].obs;


  Future<void> getPackageHistory() async {
    try {
      isLoading.value = true;

      final response = await ApiService.get(
        endpoint: "purchase-history",
        isShow: false,
       // useBaseUrl: true
      );

      if (response["success"] == true) {

        List data = response["data"];

        packageList.assignAll(
          data.map((e) => PackageHistoryModel.fromJson(e)).toList(),
        );

        print("listLength:: ${packageList.length}");
      }

    } catch (e) {
      debugPrint("Package history error $e");
    } finally {
      isLoading.value = false;
    }
  }
}
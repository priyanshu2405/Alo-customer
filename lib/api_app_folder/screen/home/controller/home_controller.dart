import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/home/model/vehicle_types_model.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:alo_ride_app/models/model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController{


  final formKey = GlobalKey<FormState>();
  RxBool isVehicleTypes = false.obs;

  RxInt selectedItemId = (-1).obs;     // id of selected item
  RxInt selectedType = 0.obs;
  final TextEditingController nameController = TextEditingController();


  RxInt selectedVehicleIndex = (-1).obs; // SUV selected by default
  RxString selectedVehicleName = ''.obs;

  // final List<Map<String, dynamic>> vehicles = [
  //   {'name': 'Mini', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
  //   {'name': 'Sedan', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
  //   {'name': 'SUV', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
  //   {'name': 'Luxury', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
  //   {'name': 'Rentals', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
  // ];



  Rx<GetVehicleTypesModel> getVehicleTypesModel = GetVehicleTypesModel().obs;
  RxList<FlatRatesModel> flatRatesList = <FlatRatesModel>[].obs;
  RxList<FlatRatesModel> errandsList = <FlatRatesModel>[].obs;
  RxList<FlatRatesModel> myPackageList = <FlatRatesModel>[].obs;

  Future<void> getVehicleTypes() async {
    try {
      isVehicleTypes.value = true;

      final response = await ApiService.get1(endpoint: '${ApiService.baseUrl1}vehicle-types', isShow: false,useBaseUrl: false);

      // Convert the entire response to GetPackageModel (not each item)
      final vehicleTypes = GetVehicleTypesModel.fromJson(response);

      // Store the single GetPackageModel instance
      getVehicleTypesModel.value = vehicleTypes;
      debugPrint("length ==> ${getVehicleTypesModel.value.data?.length}");
    } catch (e) {
      print('Error fetching packages: $e');
    } finally {
      isVehicleTypes.value = false;
    }
  }

  Future<void> getFlatRatesList() async {
    try {
      isVehicleTypes.value = true;

      final response = await ApiService.get1(endpoint: '${ApiService.baseUrl1}flat-rates', isShow: false,useBaseUrl: false);

      // Convert the entire response to GetPackageModel (not each item)
      if (response["success"] == true) {
        final List list = response["data"];

        flatRatesList.assignAll(
          list.map((e) => FlatRatesModel.fromJson(e)).toList(),
        );

        debugPrint("length ==> ${flatRatesList.length}");
      }
    } catch (e) {
      print('Error fetching packages: $e');
    } finally {
      isVehicleTypes.value = false;
    }
  }

  Future<void> getErrandsList() async {
    try {
      isVehicleTypes.value = true;

      final response = await ApiService.get(
        endpoint: 'packages',
        isShow: false,
      );

      // Convert the entire response to GetPackageModel (not each item)
      if (response["success"] == true) {
        final List list = response["data"]['errands'];

        errandsList.assignAll(
          list.map((e) => FlatRatesModel.fromJson(e)).toList(),
        );

        debugPrint("length ==> ${errandsList.length}");
      }
    } catch (e) {
      print('Error fetching packages: $e');
    } finally {
      isVehicleTypes.value = false;
    }
  }

  Future<void> getMyPackagesList() async {
    try {
      isVehicleTypes.value = true;

      final response = await ApiService.get1(
        endpoint: '${ApiService.baseUrl1}packages',
        isShow: false,
        useBaseUrl: false,
      );

      // Convert the entire response to GetPackageModel (not each item)
      if (response["success"] == true) {
        final List list = response["data"]['purchased_packages'];

        myPackageList.assignAll(
          list.map((e) => FlatRatesModel.fromJson(e)).toList(),
        );

        debugPrint("myPackageList ==> ${myPackageList.length}");
      }
    } catch (e) {
      print('Error fetching packages: $e');
    } finally {
      isVehicleTypes.value = false;
    }
  }
}
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/home/model/vehicle_types_model.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController{


  final formKey = GlobalKey<FormState>();
  RxBool isVehicleTypes = false.obs;


  final TextEditingController nameController = TextEditingController();


  RxInt selectedVehicleIndex = (-1).obs; // SUV selected by default
  RxString selectedVehicleName = ''.obs;

  final List<Map<String, dynamic>> vehicles = [
    {'name': 'Mini', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'Sedan', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'SUV', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'Luxury', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'Rentals', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
  ];



  Rx<GetVehicleTypesModel> getVehicleTypesModel = GetVehicleTypesModel().obs;
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


}
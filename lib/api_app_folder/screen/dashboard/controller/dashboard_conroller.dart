
import 'package:alo_ride_app/api_app_folder/screen/home/view/home_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/view/my_rides_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/profile/view/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashBoardController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeIndex(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
    }
  }

  late List<Widget> pages;
  @override
  void onInit() {
    super.onInit();
    pages = [
      HomeScreen(),
      MyRidesScreen(),
      ProfileScreen(),
    ];
  }


}
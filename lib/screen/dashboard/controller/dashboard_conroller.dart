
import 'package:alo_ride_app/screen/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

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
      Text("My Rides"),
      Text("My Rides"),
    ];
  }


}
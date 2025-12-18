import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController{


  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();






  RxInt selectedVehicleIndex = 0.obs; // SUV selected by default

  final List<Map<String, dynamic>> vehicles = [
    {'name': 'Mini', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'Sedan', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'SUV', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'Luxury', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'Rentals', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
  ];
}
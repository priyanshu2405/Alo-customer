import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RideCompletedController extends GetxController{

  RxDouble selectedStars = 3.0.obs;
  final TextEditingController amountCtrl = TextEditingController();

  RxString selectedTip = "".obs;

  void onTipSelected(String value) {
    selectedTip.value = value;
    amountCtrl.text = value.replaceAll("\$", "");
  }
}
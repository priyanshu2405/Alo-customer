import 'dart:async';
import 'package:alo_ride_app/screen/login/view/login_screen.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    Timer(const Duration(seconds: 2), () {
      Get.to(() => const LoginScreen());
    });
  }

}
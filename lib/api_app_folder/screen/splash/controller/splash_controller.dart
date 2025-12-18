import 'dart:async';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/login/view/login_screen.dart';
import 'package:alo_ride_app/api_app_folder/services/token_store.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {

  final AuthController authController = Get.put(AuthController());
  @override
  void onInit() {
    super.onInit();
    checkTokenAndNavigate();
  }


  Future<void> checkTokenAndNavigate() async {
    try {
      // Add a small delay to ensure everything is initialized
      await Future.delayed(Duration(milliseconds: 200));

      final token = authController.getToken();
      print("token===>$token");
      print("isLoggedIn===> ${authController.isLoggedIn.value}");

      // Show splash for 3 seconds
      await Future.delayed(Duration(seconds: 3));

      if (authController.isAuthenticated) {
       Get.to(()=>DashboardScreen());
      } else {
        print("User is not authenticated, navigating to login");
        Get.offAll(() => LoginScreen());
      }
    } catch (e) {
      print("Error in checkTokenAndNavigate: $e");
      Get.offAll(() => LoginScreen());
    }
  }

}
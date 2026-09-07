import 'dart:async';
import 'package:alo_ride_app/api_app_folder/screen/chat/service/chat_push_router.dart';
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
        // offAll, not to: the splash must leave the stack, otherwise a chat
        // screen pushed by a notification tap sits above a dead route and
        // back-navigation lands on the splash again.
        Get.offAll(() => DashboardScreen());
      } else {
        print("User is not authenticated, navigating to login");
        Get.offAll(() => LoginScreen());
      }

      /// Startup routing is done — a push that launched the app from a
      /// terminated state can open now without being discarded by the
      /// `Get.offAll` above. Called on BOTH branches: when logged out the
      /// router keeps the tap parked until the OTP screen calls back in, so it
      /// is never silently dropped.
      ChatPushRouter.flushPending();
    } catch (e) {
      print("Error in checkTokenAndNavigate: $e");
      Get.offAll(() => LoginScreen());
      ChatPushRouter.flushPending();
    }
  }

}
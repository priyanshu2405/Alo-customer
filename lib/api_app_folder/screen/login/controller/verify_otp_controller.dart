import 'dart:async';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';

import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/home/controller/home_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/home/view/welcome_dialog.dart';
import 'package:alo_ride_app/api_app_folder/screen/profile/controller/profile_controller.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:alo_ride_app/api_app_folder/services/token_store.dart';
import 'package:alo_ride_app/firebase_api/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyOtpController extends GetxController {
  RxBool isVerifyOtp = false.obs;
  RxBool isResendLoading = false.obs;
  final AuthController authController = Get.put(AuthController());
  ProfileController profileController = Get.put(ProfileController());


  final List<TextEditingController> otpControllers = List.generate(4, (_) => TextEditingController());
  RxInt secondsRemaining = 30.obs;
  Timer? timer;

  Future<void> verifyOtp(BuildContext context,{String? countryCode,String? mobile}) async {
    isVerifyOtp.value = true;
    String? token;

    try {
      // Try to initialize notifications
      final notificationService = NotificationService();
      await notificationService.initialize();

      token = await NotificationService.getToken();
    } catch (e) {
      debugPrint("FCM token error: $e");
    }
    try {

      String otp = otpControllers.map((e) => e.text).join();

      if (otp.length != 4) {
        Get.snackbar(
          "Error",
          "Please enter valid OTP",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }
      var body = {
        "country_code": countryCode,
        "mobile": mobile,
        "otp": otp,
        "fcm_token" : token,
      };
      debugPrint("body : $body");
      final response = await ApiService.post(
        endpoint: 'verify-otp',
        body: body,
      );
      print("id: ${response['data']['user']["id"]}");
      // print("email: ${response['data']['user']["email"]}");
      print("token: ${response["data"]["token"]}");
      print("needsName: ${response["data"]["needs_name"]}");
      if (response['success'] == true) {
        await authController.storeUserData(
          accessToken: response["data"]["token"],
          id: response['data']['user']["id"].toString(),
        );
        Get.to(()=>DashboardScreen());
        if(response["data"]["needs_name"] == false){
          _showWelcomeDialog(context);
        }


      } else {
        // Handle case when API doesn't return expected data
        Get.snackbar(
          "Error",
          "${response["message"]}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }

    } catch (e) {
      print("Error in createUser: $e");
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isVerifyOtp.value = false; // Stop loading in all cases
    }
  }


  Future<void> resendOtp({String? countryCode,String? mobile}) async {
    isResendLoading.value = true; // Start loading

    var body = {
      "country_code": "+$countryCode",
      "mobile": mobile,
    };
    debugPrint("body : $body");

    try {
      final response = await ApiService.post(
        endpoint: 'send-otp',
        body: body,
      );
      print("id: ${response["otp"]}");

      debugPrint("otp verify =====>${response["otp"]}");
      if (response['success'] == true) {
        // Get.to(()=>OtpScreen(phoneNumber: phoneNumberCtrl.text));
        debugPrint("otp verify =====>${response["otp"]}");
      } else{
        Get.snackbar(
          "Error",
          "${response["errors"]["mobile"]}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error in createUser: $e");
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.secondary.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      isResendLoading.value = false; // Stop loading in all cases
    }
  }

  void _showWelcomeDialog(BuildContext context) {
    final HomeController homeController = Get.put(HomeController());
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WelcomeDialog(
          controller: homeController,
          profileController: profileController,
        );
      },
    );
  }
}
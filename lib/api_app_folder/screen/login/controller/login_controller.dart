import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/login/view/otp_screen.dart';
import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
import 'package:alo_ride_app/api_app_folder/services/token_store.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final TextEditingController phoneNumberCtrl = TextEditingController();
  final AuthController authController = Get.put(AuthController());
  RxBool isLoading = false.obs;

  Rx<Country?> countryCode = Country(
    phoneCode: "1",
    countryCode: "CA",
    name: "Canada",
    displayName: "Canada (CA) [+1]",
    displayNameNoCountryCode: "Canada (CA)",
    e164Key: "1-CA-0",
    e164Sc: 0,
    geographic: true,
    level: 1,
    example: "2041234567",
  ).obs;



  /// 🔹 Validation states
  RxString phoneError = "".obs;
  RxBool isPhoneValid = false.obs;

  /// 🔹 Call this on text change or button tap
  void validatePhone() {
    final phone = phoneNumberCtrl.text.trim();

    if (phone.isEmpty) {
      phoneError.value = "Phone number is required";
      isPhoneValid.value = false;
    } else if (phone.length < 8 || phone.length > 15) {
      phoneError.value = "Enter a valid phone number";
      isPhoneValid.value = false;
    } else {
      phoneError.value = "";
      isPhoneValid.value = true;
    }
  }

  void pickCountry() {
    showCountryPicker(
      context: Get.context!,
      showPhoneCode: true,
      onSelect: (Country country) {
        countryCode.value = country;
      },
    );
  }

  Future<void> loginApi() async {
    isLoading.value = true; // Start loading

    var body = {
      "country_code": "+${countryCode.value?.phoneCode}",
      "mobile": phoneNumberCtrl.text,
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
        Get.to(
          () => OtpScreen(
            countryCode: countryCode.value?.phoneCode??"",
            phoneNumber: phoneNumberCtrl.text,
          ),
        );
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
      isLoading.value = false; // Stop loading in all cases
    }
  }
}

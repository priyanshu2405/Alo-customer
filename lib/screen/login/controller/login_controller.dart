import 'dart:async';
import 'package:alo_ride_app/screen/login/view/login_screen.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class LoginController extends GetxController {
//   final TextEditingController phoneNumberCtrl = TextEditingController();
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // ✅ ADD
//
//
//   /// ✅ Make country reactive
//   Rx<Country?> countryCode = Country(
//     phoneCode: "91",
//     countryCode: "IN",
//     e164Sc: 0,
//     geographic: true,
//     level: 1,
//     name: "India",
//     example: "9123456789",
//     displayName: "India (IN) [+91]",
//     displayNameNoCountryCode: "India (IN)",
//     e164Key: "91-IN-0",
//   ).obs;
//
//   void pickCountry() {
//     showCountryPicker(
//       context: Get.context!,
//       showPhoneCode: true,
//       useSafeArea: true,
//       onSelect: (Country country) {
//         countryCode.value = country; // ✅ update Rx value
//       },
//     );
//   }
// }

class LoginController extends GetxController {
  final TextEditingController phoneNumberCtrl = TextEditingController();

  Rx<Country?> countryCode = Country(
    phoneCode: "91",
    countryCode: "IN",
    name: "India",
    displayName: "India (IN) [+91]",
    displayNameNoCountryCode: "India (IN)",
    e164Key: "91-IN-0",
    e164Sc: 0,
    geographic: true,
    level: 1,
    example: "9123456789",
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
}


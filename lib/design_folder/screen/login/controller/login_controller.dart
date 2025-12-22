import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class LoginController extends GetxController {
  final TextEditingController phoneNumberCtrl = TextEditingController();

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
}


import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController{
  RxBool isLoading = false.obs;


  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();




  RxString errorFullName = ''.obs;
  RxString errorEmail = ''.obs;
  RxString errorMessage = ''.obs;
  RxString errorPhoneNumber = ''.obs;

  RxBool isSave = false.obs;





}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:alo_ride_app/api_app_folder/screen/splash/view/splash_screen.dart';
import 'package:alo_ride_app/api_app_folder/services/token_store.dart';

import 'api_app_folder/constant/key_constants.dart';

// import 'package:alo_ride_app/design_folder/screen/splash/view/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 REQUIRED: Initialize GetStorage
  await GetStorage.init();

  // 🔥 REQUIRED: Register AuthController once
  Get.put(AuthController(), permanent: true);
  Stripe.publishableKey = publishKey;
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Alo Ride',
          home: const SplashScreen(),
        );
      },
    );
  }
}

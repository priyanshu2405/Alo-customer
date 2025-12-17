import 'package:alo_ride_app/screen/ride/view/ride_completed_screen.dart';
import 'package:alo_ride_app/screen/splash/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'screen/dashboard/screen/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Your Figma screen
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          home: const SplashScreen(),
          // home: const DashboardScreen(),
        );
      },
    );
  }
}

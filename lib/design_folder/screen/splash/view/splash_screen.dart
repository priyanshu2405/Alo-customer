import 'package:alo_ride_app/design_folder/res/common/app_image.dart';
import 'package:alo_ride_app/design_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/design_folder/screen/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final SplashController splashController = Get.put(SplashController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SizedBox(
        width: 1.sw,
        height: 1.sh,
        child: AppImage(
          image: AppImages.splashBg,
          imageType: ImageType.asset,
        ),
      ),
    );
  }
}

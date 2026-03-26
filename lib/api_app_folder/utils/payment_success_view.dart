import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../res/constant/app_colors.dart' show AppColors;

class PaymentSuccessView extends StatelessWidget {
  final String? transactionId;
  final String? paymentStatus;
  final String? message;

  const PaymentSuccessView({
    super.key,
    this.transactionId,
    this.message,
    this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    print("transactionId:: $transactionId");
    return Scaffold(
      appBar: AppAppBar(title: "Successful"),
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.only(
            top: 16.0,
            left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: AppButton(
          text: "gO TO My home".toUpperCase(),
          onTap: () {
            Get.off(() => DashboardScreen());
          },
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(58),
            AppText(
              text: "Subscription ID: #$transactionId ",
              fontSize: 14.sp,
              color: AppColors.black,
              fontWeight: FontWeight.w400,
            ),
            Gap(50),
            Container(
              /*   height: 156,
              width: 156,*/
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.2),
              ),
              child:AppImage(
                image: AppImages.paymentSuccess,
                imageType: ImageType.svgAsset,
                //height: 210,
                fit: BoxFit.contain,
              ),
            ),
            Gap(42),
            AppText(
              text: "Payment Completed Successfully",
              fontSize: 14.sp,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
            Gap(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppText(
                text: message ?? "",
                fontSize: 14.sp,
                color: AppColors.black,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

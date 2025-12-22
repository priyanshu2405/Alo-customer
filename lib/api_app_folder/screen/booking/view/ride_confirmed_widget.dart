import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/controller/dashboard_conroller.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class RideConfirmedWidget extends StatelessWidget {
  final String dateTimeText;

  const RideConfirmedWidget({super.key, required this.dateTimeText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.vertical(
        //   top: Radius.circular(20.r),
        // ),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Gap(10),

          /// 🔹 Title
          // AppText(
          //   text: "Ride Confirmed",
          //   fontSize: 20,
          //   fontWeight: FontWeight.w600,
          //   color: AppColors.secondary, // orange
          // ),
          //
          // Gap(12.h),

          /// 🔹 Description
          AppText(
            text: dateTimeText,
           // text: "Your Booking for $dateTimeText\nhas been confirmed.",
            fontSize: 14,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w500,
            color: AppColors.lightBlackColor,
            overflow: TextOverflow.visible,
          ),

          Gap(22.h),

          /// 🔹 Info
          AppText(
            text: "You will be notified when the Driver is on the way",
            fontSize: 14,
            textAlign: TextAlign.center,
            maxLines: 2,
            fontWeight: FontWeight.w500,
            color: AppColors.lightBlackColor,
          ),
          Gap(22.h),
          // AppButton(
          //   text: "Go To Home",
          //   onTap: () {
          //     Get.to(() => DashboardScreen());
          //   },
          // ),
          AppButton(
              text: "Go To Home",
              onTap: () {
                final controller = Get.put(DashBoardController());
                controller.changeIndex(1);
                Get.off(() => DashboardScreen());
              }
          ),
          Gap(10.h),
        ],
      ),
    );
  }
}

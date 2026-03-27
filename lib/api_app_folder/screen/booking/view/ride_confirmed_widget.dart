import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/controller/dashboard_conroller.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(10),

          /// 🔹 Description
          AppText(
            text: dateTimeText,
            fontSize: 14,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w500,
            color: AppColors.lightBlackColor,
            overflow: TextOverflow.visible,
          ),

          const Gap(22),

          /// 🔹 Info
          AppText(
            text: "You will be notified when the Driver is on the way",
            fontSize: 14,
            textAlign: TextAlign.center,
            maxLines: 2,
            fontWeight: FontWeight.w500,
            color: AppColors.lightBlackColor,
          ),
          const Gap(22),
          AppButton(
              text: "Go To Home",
              onTap: () {
                final controller = Get.put(DashBoardController());
                controller.changeIndex(1);
                Get.off(() => DashboardScreen());
              }
          ),
          const Gap(10),
        ],
      ),
    );
  }
}

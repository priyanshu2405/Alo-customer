import 'package:alo_ride_app/demo.dart';
import 'package:alo_ride_app/res/common/app_button.dart';
import 'package:alo_ride_app/res/common/app_text.dart';
import 'package:alo_ride_app/res/common/common_text_field.dart';
import 'package:alo_ride_app/res/constant/app_colors.dart';
import 'package:alo_ride_app/screen/ride/controller/ride_completed_controller.dart';
import 'package:alo_ride_app/screen/ride/view/payment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class RateTipDialog extends StatefulWidget {
  const RateTipDialog({super.key});

  @override
  State<RateTipDialog> createState() => _RateTipDialogState();
}

class _RateTipDialogState extends State<RateTipDialog> {

  final RideCompletedController rideCompletedController = Get.put(RideCompletedController());

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: 1.sw - 40.w,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: "Rate or tip",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
              Gap(12.h),

              AppText(
                text: "Add a tip for Driver",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrayColor,
              ),
              Gap(6.h),
              AppText(
                text: "Your trip was \$20.00",
                fontSize: 16,
                color: AppColors.darkGrayColor,
                fontWeight: FontWeight.w500,
              ),

              Gap(14.h),

              /// TIP BUTTONS

              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 40.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _tip("\$1"),
                        _tip("\$3"),
                        _tip("\$5"),
                      ],
                    ),

                    Gap(12.h),

                    CommonTextField(controller: rideCompletedController.amountCtrl, hintText: "Enter custom Amount",),
                  ],
                ),
              ),
              Gap(20),
              Divider(color: AppColors.darkTextColor),
              Gap(10),


              AppText(
                text: "Rate your trip",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
              Gap(6.h),

              AppText(
                text: "Thursday to 2824 Ellwood Dr sw",
                fontSize: 16,
                color: AppColors.darkGrayColor,
                fontWeight: FontWeight.w500,
              ),

              Gap(12.h),

              /// STARS
              Obx(() {
                return RatingBar.builder(
                  initialRating: rideCompletedController.selectedStars.value,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 40,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Color(0xffFBBC05),
                  ),
                  onRatingUpdate: (value) {
                    rideCompletedController.selectedStars.value = value;

                  },
                );
              },),

              Gap(20.h),
              AppButton(text: "SUBMIT", onTap: () {
                Get.to(()=>PaymentDetailsScreen());
              },),
              Gap(10.h),

            ],
          ),
        ),
      ),
    );
  }

  Widget _tip(String value) {
    return Obx(() {
      final bool isSelected =
          rideCompletedController.selectedTip.value == value;

      return GestureDetector(
        onTap: () {
          rideCompletedController.onTipSelected(value);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected
                  ? Colors.orange
                  : AppColors.borderColor,
              width: 1.5,
            ),
            color: isSelected
                ? Colors.orange.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: AppText(
            text: value,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.orange : AppColors.black,
          ),
        ),
      );
    });
  }

}

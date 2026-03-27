import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/common/common_text_field.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/controller/ride_completed_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/view/payment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class RateTipDialog extends StatefulWidget {
  final int rideId;
  final String amount;

  const RateTipDialog({super.key, required this.rideId,required this.amount,});

  @override
  State<RateTipDialog> createState() => _RateTipDialogState();
}

class _RateTipDialogState extends State<RateTipDialog> {
  final RideCompletedController rideCompletedController = Get.put(
    RideCompletedController(),
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Material(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: screenWidth - 40,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    visualDensity: const VisualDensity(
                      vertical: VisualDensity.minimumDensity,
                      horizontal: VisualDensity.minimumDensity,
                    ),
                    icon: const Icon(Icons.close), onPressed: () {
                  Get.back();
                }),
              ),
              AppText(
                text: "Rate or tip",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
              const Gap(12),

              AppText(
                text: "Add a tip for Driver",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrayColor,
              ),
              const Gap(6),
              AppText(
                text: "Your trip was \$${widget.amount}",
                fontSize: 16,
                color: AppColors.darkGrayColor,
                fontWeight: FontWeight.w500,
              ),

              const Gap(14),

              /// TIP BUTTONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [_tip(1), _tip(3), _tip(5)],
                    ),

                    const Gap(12),

                    CommonTextField(
                      controller: rideCompletedController.amountCtrl,
                      hintText: "Enter custom Amount",
                      onChanged: rideCompletedController.onCustomAmountChanged,
                    ),
                  ],
                ),
              ),
              const Gap(20),
              Divider(color: AppColors.darkTextColor),
              const Gap(10),

              AppText(
                text: "Rate your trip",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
              const Gap(6),

              AppText(
                text: "Thursday to 2824 Ellwood Dr sw",
                fontSize: 16,
                color: AppColors.darkGrayColor,
                fontWeight: FontWeight.w500,
              ),

              const Gap(12),

              /// STARS
              Obx(() {
                return RatingBar.builder(
                  initialRating: rideCompletedController.selectedStars.value,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 40,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Color(0xffFBBC05)),
                  onRatingUpdate: (value) {
                    rideCompletedController.selectedStars.value = value;
                  },
                );
              }),

              const Gap(20),
              Obx(() {
                return AppButton(
                  isLoading: rideCompletedController.isTipAmount.value,
                  text: "SUBMIT",
                  onTap: () {
                    final tip = rideCompletedController.tipAmountValue.value
                        .toInt();

                    rideCompletedController.tipAmountApi(
                      tipAmount: tip,
                      rideId: widget.rideId,
                    );
                  },
                );
              }),
              const Gap(10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tip(double value) {
    return Obx(() {
      final bool isSelected =
          rideCompletedController.tipAmountValue.value == value;

      return GestureDetector(
        onTap: () {
          rideCompletedController.onTipSelected(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.borderColor,
              width: 1.5,
            ),
            color: isSelected
                ? AppColors.secondary.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: AppText(
            text: "\$${value.toInt()}",
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.secondary : AppColors.black,
          ),
        ),
      );
    });
  }
}

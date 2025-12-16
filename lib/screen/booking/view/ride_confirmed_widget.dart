import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alo_ride_app/res/common/app_text.dart';
import 'package:alo_ride_app/res/constant/app_colors.dart';

class RideConfirmedWidget extends StatelessWidget {
  final String dateTimeText;

  const RideConfirmedWidget({
    super.key,
    required this.dateTimeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔹 Title
          AppText(
            text: "Ride Confirmed",
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary, // orange
          ),

          SizedBox(height: 12.h),

          /// 🔹 Description
          AppText(
            text:
            "Your Booking for $dateTimeText\nhas been confirmed.",
            fontSize: 14,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 10.h),

          /// 🔹 Info
          AppText(
            text:
            "You will be notified when the Driver is on the way",
            fontSize: 13,
            color: AppColors.greyColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:alo_ride_app/design_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/design_folder/res/common/app_button.dart';
import 'package:alo_ride_app/design_folder/res/common/app_image.dart';
import 'package:alo_ride_app/design_folder/res/common/app_text.dart';
import 'package:alo_ride_app/design_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/design_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/design_folder/screen/ride/view/rate_tip_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class RideCompletedScreen extends StatefulWidget {
  const RideCompletedScreen({super.key});

  @override
  State<RideCompletedScreen> createState() => _RideCompletedScreenState();
}

class _RideCompletedScreenState extends State<RideCompletedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(title: "Ride Completed"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Divider(color: AppColors.darkTextColor),
            Gap(10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  AppText(text: "Booking ID: 23356", fontWeight: FontWeight.w600,color: AppColors.blueColor,),
                  Spacer(),
                  AppText(text: "Date: 10/12/2025 10.30 AM", fontWeight: FontWeight.w500,fontSize: 12,),
                ],
              ),
            ),
            Gap(10),
            Divider(color: AppColors.darkTextColor),
            Gap(10),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16.h),
              child: InkWell(
                onTap: () {},
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundImage: const NetworkImage(
                        "https://i.pravatar.cc/150?img=3",
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: "Driver: Philippe",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          Gap(1),
                          AppText(
                            text: "2 mins away!",
                            fontSize: 12,
                            color: AppColors.lightBlackColor,
                          ),
                          Gap(5.h),
                          /// Vehicle Info
                          AppText(
                            text: "Car No: JOR 327  Chevrolet Spark (White)",
                            fontSize: 12,
                            maxLines: 2,
                            color: AppColors.lightBlackColor,
                          ),
                        ],
                      ),
                    ),
                    AppText(
                      text: "1.5 KM",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightBlackColor,
                    ),
                  ],
                ),
              ),
            ),
            Gap(10),
            Divider(color: AppColors.darkTextColor),
            Gap(10),
            Column(
              children: [
                // From location
                // Gap(10),
                _buildLocationRow(
                  icon:  AppImage(
                    height: 20.h,
                    width: 20.w,
                    image: AppImages.recordCircleFill,
                    imageType: ImageType.svgAsset,
                  ),
                  iconColor: AppColors.pinkColor,
                  title: '241-205 Barrieau Rd, Moncton.',
                  subtitle: '11 Dec,2025  7:20 PM',
                  showDivider: true,
                ),

                // Drop off location
                _buildLocationRow(
                  icon: Icon(Icons.location_on, color: AppColors.pinkColor, size: 20),
                  iconColor: AppColors.pinkColor,
                  title: '100 Holland Dr, Moncton, NB E1...',
                  subtitle: '11 Dec,2025 8:05 PM',
                  showDivider: false,
                ),

              ],
            ),
            Gap(10),
            Divider(color: AppColors.darkTextColor),
            Gap(10),
            _fareRow("Trip Fare", "\$50.00",bold: true),
            Gap(17),
            _fareRow("HST 15%", "\$7.50"),
            Gap(17),
            _fareRow("Tip", "\$0.00"),
            Gap(17),
            Divider(color: AppColors.darkTextColor),
            Gap(10),
            _fareRow(
              "Total Trip Fare",
              "\$57.50",
              fontSize: 16,
              bold: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: AppButton(
          text: "PAY NOW",
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const RateTipDialog(),
            );
          },
        ),
      ),
      floatingActionButton: AppImage(
        height: 55,width: 55,
        image: AppImages.sosButton,
        imageType: ImageType.asset,
      ),
    );
  }

  Widget _buildLocationRow({
    required Widget icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with connecting line
              Column(
                children: [
                  // Icon(icon, color: iconColor, size: 20),
                  icon,
                  if (showDivider)
                    Column(
                      children: List.generate(14, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Container(
                            height: 2,
                            width: 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.black,
                            ),
                          ),
                        );
                      }),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(text: title,  color: AppColors.textColor,),
                    const SizedBox(height: 4),
                    AppText(text: subtitle,fontSize: 10,),
                  ],
                ),
              ),


            ],
          ),
        ),
      ],
    );
  }

  Widget _fareRow(String title, String value, {bool bold = false,double fontSize = 14}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          ),
          AppText(
            text: value,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          ),
        ],
      ),
    );
  }
}

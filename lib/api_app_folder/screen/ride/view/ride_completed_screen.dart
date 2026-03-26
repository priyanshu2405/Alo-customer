import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/controller/my_ride_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/model/get_ride_details_model.dart' hide Image;
import 'package:alo_ride_app/api_app_folder/screen/ride/controller/ride_completed_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/view/payment_details_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/view/rate_tip_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RideCompletedScreen extends StatefulWidget {
  final int bookingId;
  final bool isShowDialog;

  const RideCompletedScreen({
    super.key,
    required this.bookingId,
    this.isShowDialog = true,
  });

  @override
  State<RideCompletedScreen> createState() => _RideCompletedScreenState();
}

class _RideCompletedScreenState extends State<RideCompletedScreen> {
  final MyRideController myRideController = Get.put(MyRideController());
  final RideCompletedController rideCompletedController = Get.put(
    RideCompletedController(),
  );

  @override
  void initState() {
    super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        myRideController.getRideDetails(id: widget.bookingId).then((value) {
          if(!mounted)return;
          if (/*widget.isShowDialog == true*/myRideController.getRideDetailsModel.value.data?.ride?.payment?.status != "paid") {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) =>  RateTipDialog(rideId: widget.bookingId,
              amount: myRideController.getRideDetailsModel.value.data?.ride?.totalFare ?? "",
              ),
            );
          }
        });
      });
  }

  @override
  void dispose() {
    myRideController.getRideDetailsModel.value = GetRideDetailsModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(title: "Ride Completed"),
      body: Obx(() {
        return myRideController.getRideDetailsModel.value.data == null || myRideController.isGetRideDetails.value
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Divider(color: AppColors.darkTextColor),
                    Gap(10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          AppText(
                            text:
                                "Booking ID: ${myRideController.getRideDetailsModel.value.data?.ride?.bookingId}",
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueColor,
                          ),
                          Spacer(),
                          if(myRideController.getRideDetailsModel.value.data?.ride?.pickupDatetime != null)
                          AppText(
                            text:
                                "Date: ${formatDateTime("${myRideController.getRideDetailsModel.value.data?.ride?.pickupDatetime}")}",
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                    Gap(10),
                    Divider(color: AppColors.darkTextColor),
                    Gap(10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.h),
                      child: InkWell(
                        onTap: () {},
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 60.r,
                                height: 60.r,
                                child: Image.network(
                                  "${myRideController.getRideDetailsModel.value.data?.ride?.driver?.profilePhoto}",
                                  fit: BoxFit.cover,

                                  // 🔄 Loader
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },

                                  // ❌ Error image
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: Icon(
                                        Icons.person,
                                        size: 32,
                                        color: Colors.grey.shade700,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Gap(12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text:
                                        "Driver: ${myRideController.getRideDetailsModel.value.data?.ride?.driver?.name}",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  // Gap(1),
                                  // AppText(
                                  //   text: "${myRideController.routeInfo.value?.durationText} away!",
                                  //   fontSize: 12,
                                  //   color: AppColors.lightBlackColor,
                                  // ),
                                  Gap(5.h),

                                  /// Vehicle Info
                                  AppText(
                                    text:
                                        "Car No: ${myRideController.getRideDetailsModel.value.data?.ride?.driver?.vehicleNumber}",
                                    fontSize: 12,
                                    maxLines: 2,
                                    color: AppColors.lightBlackColor,
                                  ),
                                ],
                              ),
                            ),
                            // AppText(
                            //   text: "${myRideController.routeInfo.value?.distanceText}",
                            //   fontSize: 12,
                            //   fontWeight: FontWeight.w500,
                            //   color: AppColors.lightBlackColor,
                            // ),
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
                          icon: AppImage(
                            height: 20.h,
                            width: 20.w,
                            image: AppImages.recordCircleFill,
                            imageType: ImageType.svgAsset,
                          ),
                          iconColor: AppColors.pinkColor,
                          // title: '241-205 Barrieau Rd, Moncton.',
                          title:
                              '${myRideController.getRideDetailsModel.value.data?.ride?.pickupAddress}',
                          // subtitle: '11 Dec,2025  7:20 PM',
                          subtitle:
                              '${myRideController.getRideDetailsModel.value.data?.ride?.pickupDatetime}',
                          showDivider: true,
                        ),

                        // Drop off location
                        _buildLocationRow(
                          icon: Icon(
                            Icons.location_on,
                            color: AppColors.pinkColor,
                            size: 20,
                          ),
                          iconColor: AppColors.pinkColor,
                          // title: '100 Holland Dr, Moncton, NB E1...',
                          title:
                              '${myRideController.getRideDetailsModel.value.data?.ride?.dropAddress}',
                          subtitle: '11 Dec,2025 8:05 PM',
                          showDivider: false,
                        ),
                      ],
                    ),
                    Gap(10),
                    Divider(color: AppColors.darkTextColor),
                    Gap(10),
                    _fareRow(
                      "Trip Fare",
                      "\$${myRideController.totalTripFare.toStringAsFixed(2)}",
                      bold: true,
                    ),
                    // Gap(17),
                    // _fareRow(
                    //   "HST 15%",
                    //   "\$${myRideController.getRideDetailsModel.value.data?.ride?.taxAmount}",
                    // ),
                     if(widget.isShowDialog == true)...[
                    Gap(17),
                    // _fareRow("Tip", "\$${myRideController.getRideDetailsModel.value.data?.ride?.tipAmount}"),
                    // _fareRow("Tip", "\$${rideCompletedController.amountCtrl.text}"),
                    // Obx(() => _fareRow(
                    //   "Tip",
                    //   // "\$${rideCompletedController.amountCtrl.text}",
                    //   "\$${rideCompletedController.tipAmount.value.toStringAsFixed(2)}",
                    // )),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>  RateTipDialog(rideId: widget.bookingId,
                            amount: myRideController.getRideDetailsModel.value.data?.ride?.totalFare ?? "",
                          ),
                        );
                      },
                      child: Obx(
                        () => _fareRow(
                          "Tip",
                          // "\$${rideCompletedController.tipAmountValue.value.toStringAsFixed(2)}",
                          "\$${myRideController.getRideDetailsModel.value.data?.ride?.tipAmount??0.0}",
                          trailing: "(Modify)",
                        ),
                      ),
                    ),
                      Gap(17),
                     ],

                    Divider(color: AppColors.darkTextColor),
                    Gap(10),
                    // _fareRow(
                    //   "Total Trip Fare",
                    //   "\$${myRideController.getRideDetailsModel.value.data?.ride?.totalFare}",
                    //   fontSize: 16,
                    //   bold: true,
                    // ),
                    Obx(() {
                      // final double fare =
                      //     double.tryParse(
                      //       myRideController
                      //               .getRideDetailsModel
                      //               .value
                      //               .data
                      //               ?.ride
                      //               ?.totalFare ??
                      //           '0',
                      //     ) ??
                      //     0.0;
                      //
                      // final double tip =
                      //     rideCompletedController.tipAmountValue.value;
                      //
                      // rideCompletedController.finalTotal.value =
                      //     fare + tip; // ➕ ADD
                      // final double finalTotal = fare - tip; // ➖ SUBTRACT

                      return _fareRow(
                        "Total Trip Fare",
                        // "\$${rideCompletedController.finalTotal.value.toStringAsFixed(2)}",
                        "\$${myRideController.getRideDetailsModel.value.data?.ride?.totalFare}",
                        fontSize: 16,
                        bold: true,
                      );
                    }),
                    if(myRideController.getRideDetailsModel.value.data?.ride?.isPackageStatus == 1)...[
                      Gap(10),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 16.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AppText(
                          text:
                          "Package used - ${myRideController.getRideDetailsModel.value.data?.ride?.packageName}",
                          fontSize: 12,
                          maxLines: 2,
                          color: AppColors.red,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                      ],
                  ],
                ),
              );
      }),
      bottomNavigationBar: Obx(() {
        if(myRideController.getRideDetailsModel.value.data != null) {
          return myRideController.getRideDetailsModel.value.data?.ride?.payment
              ?.status != "paid" ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: AppButton(
              text: "PAY NOW",
              onTap: () {
                debugPrint(
                  "finalTotal : ${myRideController.getRideDetailsModel.value
                      .data?.ride?.totalFare}",
                );
                Get.to(
                      () =>
                      PaymentDetailsScreen(
                        id: widget.bookingId,
                        totalFare: double.parse(myRideController
                            .getRideDetailsModel.value.data?.ride?.totalFare ??
                            ""),
                      ),
                );
              },
            ),
          ) : SizedBox.shrink();
        }
      return SizedBox.shrink();
      }),
      floatingActionButton: AppImage(
        height: 55,
        width: 55,
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
                    AppText(text: title, color: AppColors.textColor),
                    const SizedBox(height: 4),
                    AppText(text: subtitle, fontSize: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fareRow(
    String title,
    String value, {
    String? trailing,
    bool bold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            text: title,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          ),
          if (trailing != "") ...[
            const SizedBox(width: 8),
            AppText(
              text: trailing ?? "",
              fontSize: fontSize,
              color: AppColors.secondary,
              fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
            ),
          ],
          Spacer(),
          AppText(
            text: value,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          ),
        ],
      ),
    );
  }

  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '';

    final dt = DateTime.parse(dateTime).toLocal();

    return DateFormat('dd/MM/yyyy hh.mm a').format(dt);
  }
}

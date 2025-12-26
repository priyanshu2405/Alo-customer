import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_call_helper.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/controller/dashboard_conroller.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/controller/ride_completed_controller.dart';
import 'package:alo_ride_app/api_app_folder/utils/stripe_payment_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';


class PaymentDetailsScreen extends StatefulWidget {
  final int id;
  final double totalFare;
  const PaymentDetailsScreen({super.key, required this.id, required this.totalFare});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final RideCompletedController rideCompletedController = Get.put(RideCompletedController());
  final StripePaymentService _paymentService = Get.put(StripePaymentService());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppAppBar(
        title: "Payment Details",
      ),

      body:  Column(
        children: [
          Divider(color: AppColors.darkTextColor),
          Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Amount to Pay
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _row("Amount to Pay", "\$${widget.totalFare}"),
              ),

              Divider(height: 30.h),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       /// Pay by UPI App
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           AppText(
              //             text: "Pay by UPI app",
              //             fontSize: 14,
              //             fontWeight: FontWeight.w500,
              //           ),
              //           const Icon(
              //             Icons.add,
              //             color: Colors.orange,
              //           ),
              //         ],
              //       ),
              //
              //       Gap(16.h),
              //
              //       // /// UPI Options
              //       // Row(
              //       //   children: [
              //       //     _upiBox(AppImages.gPayIcon),
              //       //     Gap(12.w),
              //       //     _upiBox(AppImages.amazonPayIcon),
              //       //     Gap(12.w),
              //       //     _upiBox(AppImages.applePayIcon),
              //       //   ],
              //       // ),
              //     ],
              //   ),
              // )
            ],
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () => AppCallHelper.callSOS(),
        child: AppImage(
          height: 55,width: 55,
          image: AppImages.sosButton,
          imageType: ImageType.asset,
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Obx(() {
          return AppButton(
            isLoading: rideCompletedController.isCreatePaymentIntent.value,
            text: "Proceed to pay",
            onTap: () async {
              // rideCompletedController.createPaymentIntent(id: widget.id);
              // final controller = Get.put(DashBoardController());
              // controller.changeIndex(1);
              // Get.to(() => DashboardScreen());
              await _paymentService.buyNow(
                context,
                widget.totalFare.toString(), // amount
                id: widget.id, // ride ID
              );
            },
          );
        },),
      ),
    );
  }

  /// ================= ROW =================
  Widget _row(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(text: title, fontSize: 14),
        AppText(
          text: value,
          fontSize: 14,

        ),
      ],
    );
  }

  // /// ================= UPI BOX =================
  // Widget _upiBox(String text) {
  //   return Expanded(
  //     child: Container(
  //       height: 50.h,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(8.r),
  //         border: Border.all(color: AppColors.greyColor),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
  //         child: Center(
  //           child: AppImage(
  //             image: text,
  //             imageType: ImageType.asset,
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_call_helper.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/controller/ride_completed_controller.dart';
import 'package:alo_ride_app/api_app_folder/utils/stripe_payment_services.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final int id;
  final double totalFare;
  const PaymentDetailsScreen(
      {super.key, required this.id, required this.totalFare});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final RideCompletedController rideCompletedController =
      Get.put(RideCompletedController());
  final StripePaymentService _paymentService = Get.put(StripePaymentService());

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(title: "Payment Details"),
      floatingActionButton: InkWell(
        onTap: () => AppCallHelper.callSOS(),
        child: AppImage(
          height: 55,
          width: 55,
          image: AppImages.sosButton,
          imageType: ImageType.asset,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.darkTextColor),
          const Gap(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _row("Amount to Pay", "\$${widget.totalFare}"),
          ),
          const Divider(height: 30),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
        child: Obx(() => AppButton(
              isLoading: rideCompletedController.isCreatePaymentIntent.value,
              text: "Proceed to pay",
              onTap: () async {
                await _paymentService.buyNow(
                  context,
                  widget.totalFare.toString(),
                  id: widget.id,
                );
              },
            )),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(text: title, fontSize: 14),
        AppText(text: value, fontSize: 14),
      ],
    );
  }
}

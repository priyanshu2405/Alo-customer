import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_app/api_app_folder/services/receipt_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../res/constant/app_colors.dart' show AppColors;

class PaymentSuccessView extends StatefulWidget {
  final String? transactionId;
  final String? paymentStatus;
  final String? message;

  /// Label in front of [transactionId] — "Subscription ID" for packages,
  /// "Transaction ID" for rides.
  final String idLabel;

  /// Address Stripe sent the receipt to, from the confirm response.
  final String? receiptEmail;

  /// False when the backend had no address to attach — the screen then offers
  /// an "Email receipt" button that calls `payment/send-receipt`.
  final bool receiptSent;

  const PaymentSuccessView({
    super.key,
    this.transactionId,
    this.message,
    this.paymentStatus,
    this.idLabel = 'Subscription ID',
    this.receiptEmail,
    this.receiptSent = false,
  });

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView> {
  late bool _receiptSent = widget.receiptSent;
  late String? _receiptEmail = widget.receiptEmail;
  bool _sending = false;

  Future<void> _emailReceipt() async {
    final email = await ReceiptService.promptForEmail(
      prefill: _receiptEmail ?? ReceiptService.accountEmail,
    );
    if (email == null) return;

    setState(() => _sending = true);
    final ok = await ReceiptService.sendReceipt(
      paymentIntentId: widget.transactionId ?? '',
      email: email,
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (ok) {
        _receiptSent = true;
        _receiptEmail = email;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canEmailReceipt =
        (widget.transactionId != null && widget.transactionId!.isNotEmpty);

    return Scaffold(
      appBar: AppAppBar(title: "Successful",leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        color: AppColors.black,
        onPressed: (){
          Get.off(() => DashboardScreen());
        },
      ),),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_receiptSent && canEmailReceipt) ...[
              AppButton(
                isLoading: _sending,
                text: "Email receipt".toUpperCase(),
                onTap: _emailReceipt,
              ),
              const Gap(12),
            ],
            AppButton(
              text: "gO TO My home".toUpperCase(),
              onTap: () {
                Get.off(() => DashboardScreen());
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(58),
            AppText(
              text: "${widget.idLabel}: #${widget.transactionId} ",
              fontSize: 14,
              color: AppColors.black,
              fontWeight: FontWeight.w400,
            ),
            Gap(50),
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.2),
              ),
              child: AppImage(
                image: AppImages.paymentSuccess,
                imageType: ImageType.svgAsset,
                fit: BoxFit.contain,
              ),
            ),
            Gap(42),
            AppText(
              text: "Payment Completed Successfully",
              fontSize: 14,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
            Gap(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppText(
                text: widget.message ?? "",
                fontSize: 14,
                color: AppColors.black,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w400,
              ),
            ),
            Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppText(
                text: _receiptSent && _receiptEmail != null
                    ? "Receipt sent to $_receiptEmail"
                    : _receiptSent
                        ? "Receipt sent"
                        : "No receipt was sent for this payment.",
                fontSize: 13,
                color: _receiptSent ? AppColors.secondary : AppColors.red,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

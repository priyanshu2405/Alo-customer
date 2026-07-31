import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/card/controller/card_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/card/view/add_card_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/controller/my_ride_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/model/get_ride_details_model.dart' hide Image;
import 'package:alo_ride_app/api_app_folder/screen/ride/controller/ride_completed_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/view/payment_details_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/view/rate_tip_dialog.dart';
import 'package:alo_ride_app/api_app_folder/services/receipt_service.dart';
import 'package:alo_ride_app/api_app_folder/utils/payment_success_view.dart';
import 'package:alo_ride_app/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
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
  final CardController cardController = Get.put(CardController());

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
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(title: "Ride Completed"),
      body: Obx(() {
        if (myRideController.getRideDetailsModel.value.data == null ||
            myRideController.isGetRideDetails.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {},
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 60,
                                height: 60,
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
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (myRideController.getRideDetailsModel.value.data?.ride?.driver?.name==null || myRideController.getRideDetailsModel.value.data?.ride?.driver?.name=="")?SizedBox():AppText(
                                    text: "Driver: ${myRideController.getRideDetailsModel.value.data?.ride?.driver?.name}",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  // Gap(1),
                                  // AppText(
                                  //   text: "${myRideController.routeInfo.value?.durationText} away!",
                                  //   fontSize: 12,
                                  //   color: AppColors.lightBlackColor,
                                  // ),
                                  const Gap(5),

                                  /// Vehicle Info
                                  (myRideController.getRideDetailsModel.value.data?.ride?.driver?.vehicleNumber==null || myRideController.getRideDetailsModel.value.data?.ride?.driver?.vehicleNumber=="")?SizedBox():AppText(
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
                            height: 20,
                            width: 20,
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
                    Gap(17),
                    _fareRow(
                      "Tax Amount",
                      "\$${myRideController.getRideDetailsModel.value.data?.ride?.taxAmount}",
                      bold: true,
                    ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
        final data = myRideController.getRideDetailsModel.value.data;
        if (data != null && data.ride?.payment?.status != "paid") {
          final totalFare =
              double.tryParse(data.ride?.totalFare ?? "0") ?? 0.0;
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
            child: AppButton(
              text: "PAY NOW",
              onTap: () {
                debugPrint("finalTotal : ${data.ride?.totalFare}");
                _showPaymentOptions(totalFare);
              },
            ),
          );
        }
        return SizedBox(height: bottom);
      }),
      floatingActionButton: AppImage(
        height: 55,
        width: 55,
        image: AppImages.sosButton,
        imageType: ImageType.asset,
      ),
    );
  }

  void _showSavedCardsPicker() {
    cardController.getCards();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(16),
            const AppText(
              text: 'Choose a Card',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            const Gap(4),
            const AppText(
              text: 'Tap a card to pay for this ride',
              fontSize: 12,
              color: AppColors.lightTextColor,
            ),
            const Gap(16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetCtx).size.height * 0.5,
              ),
              child: Obx(() {
                if (cardController.isLoadingCards.value &&
                    cardController.cards.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (cardController.cards.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.credit_card_off,
                          size: 44,
                          color: AppColors.lightTextColor,
                        ),
                        const Gap(10),
                        const AppText(
                          text: 'No saved cards',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        const Gap(4),
                        const AppText(
                          text: 'Add a card to pay this ride.',
                          fontSize: 12,
                          color: AppColors.lightTextColor,
                        ),
                        const Gap(16),
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            text: 'Add Card',
                            onTap: () {
                              Navigator.pop(sheetCtx);
                              Get.to(() => AddCardScreen())?.then((_) {
                                cardController.getCards();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: cardController.cards.length,
                  separatorBuilder: (_, __) => const Gap(10),
                  itemBuilder: (_, i) {
                    final card = cardController.cards[i];
                    return _SavedCardRow(
                      card: card,
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        _payWithSavedCard(card);
                      },
                    );
                  },
                );
              }),
            ),
            const Gap(12),
            GestureDetector(
              onTap: () => Navigator.pop(sheetCtx),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: AppText(
                    text: 'Cancel',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payWithSavedCard(Map<String, dynamic> card) async {
    final paymentMethodId = int.tryParse(card['id']?.toString() ?? '');
    if (paymentMethodId == null) {
      Get.snackbar(
        'Error',
        'Invalid card',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // No payment sheet here, so nothing can supply billing details after the
    // fact — ask up front when the account has no email, otherwise the backend
    // has no address to send the receipt to.
    String? receiptEmail = await ReceiptService.resolveAccountEmail();
    if (receiptEmail == null) {
      receiptEmail = await ReceiptService.promptForEmail(
        title: 'Receipt email',
        message: 'Your account has no email. Where should we send your receipt?',
      );
    }

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      ),
      barrierDismissible: false,
    );

    try {
      final response = await rideCompletedController.payRideWithSavedCard(
        rideId: widget.bookingId,
        paymentMethodId: paymentMethodId,
        receiptEmail: receiptEmail,
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (response != null) {
        final receipt = ReceiptInfo.fromResponse(response);
        await ReceiptService.saveEmailToProfileIfMissing(receipt.email);

        Get.offAll(() => PaymentSuccessView(
              transactionId: _paymentIntentIdOf(response),
              idLabel: 'Transaction ID',
              message: response['message'] ?? 'Payment successful',
              receiptEmail: receipt.email,
              receiptSent: receipt.sent,
            ));
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    }
  }

  /// The saved-card response nests the intent id under `data`, and the key
  /// name differs between payment shapes.
  String? _paymentIntentIdOf(Map<String, dynamic> response) {
    dynamic pick(String key) {
      if (response[key] != null) return response[key];
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        if (data[key] != null) return data[key];
        final payment = data['payment'];
        if (payment is Map<String, dynamic>) return payment[key];
      }
      return null;
    }

    final id = pick('payment_intent_id') ??
        pick('stripe_payment_intent_id') ??
        pick('payment_intent');
    return id?.toString();
  }

  void _showPaymentOptions(double totalFare) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(16),
            const AppText(
              text: 'Choose Payment Method',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            const Gap(20),
            _PaymentOptionTile(
              icon: Icons.payment_rounded,
              iconBg: AppColors.blueColor.withOpacity(0.15),
              iconColor: AppColors.blueColor,
              title: 'Stripe Payment',
              subtitle: 'Pay with a new card via Stripe',
              onTap: () {
                Navigator.pop(sheetCtx);
                Get.to(
                  () => PaymentDetailsScreen(
                    id: widget.bookingId,
                    totalFare: totalFare,
                  ),
                );
              },
            ),
            const Gap(12),
            _PaymentOptionTile(
              icon: Icons.credit_card_rounded,
              iconBg: AppColors.secondary.withOpacity(0.15),
              iconColor: AppColors.secondary,
              title: 'Card Payment',
              subtitle: 'Pay with a saved card',
              onTap: () {
                Navigator.pop(sheetCtx);
                _showSavedCardsPicker();
              },
            ),
            const Gap(20),
            GestureDetector(
              onTap: () => Navigator.pop(sheetCtx),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: AppText(
                    text: 'Cancel',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
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
      padding: EdgeInsets.symmetric(horizontal: 16),
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

class _SavedCardRow extends StatelessWidget {
  final Map<String, dynamic> card;
  final VoidCallback onTap;

  const _SavedCardRow({required this.card, required this.onTap});

  String get _brand =>
      (card['brand'] ?? card['card_brand'] ?? 'CARD')
          .toString()
          .toUpperCase();

  String get _last4 => (card['last4'] ??
          card['last_four'] ??
          card['card_last4'] ??
          '')
      .toString();

  String get _expiry {
    final m = card['exp_month'] ?? card['expiry_month'];
    final y = card['exp_year'] ?? card['expiry_year'];
    if (m == null || y == null) return '';
    final yy =
        y.toString().length == 4 ? y.toString().substring(2) : y.toString();
    return '${m.toString().padLeft(2, '0')}/$yy';
  }

  bool get _isDefault =>
      card['is_default'] == true || card['default'] == true;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.credit_card_rounded,
                color: AppColors.secondary,
                size: 22,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText(
                        text: _brand,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      const Gap(8),
                      if (_isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const AppText(
                            text: 'Default',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                    ],
                  ),
                  const Gap(2),
                  AppText(
                    text:
                        '•••• ${_last4.isEmpty ? '••••' : _last4}${_expiry.isEmpty ? '' : '   ·   $_expiry'}',
                    fontSize: 12,
                    color: AppColors.lightTextColor,
                    letterSpacing: 1,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.lightTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  const Gap(2),
                  AppText(
                    text: subtitle,
                    fontSize: 12,
                    color: AppColors.lightTextColor,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.lightTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

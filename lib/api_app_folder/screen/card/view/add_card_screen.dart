import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/card/controller/card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {

  @override
  void initState() {
    // TODO: implement initState
    controller.cardHolderController.text = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearCardField();
    });
    super.initState();
  }
  final CardController controller = Get.put(CardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppAppBar(title: 'Add Card'),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
            // Stripe's CardField is a native view; Flutter's focus system
            // can't reach it. Hide the OS keyboard directly.
            SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
          },
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Form(
              key: controller.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardPreview(controller: controller),
                const Gap(24),

                const _FieldLabel(text: 'Cardholder Name'),
                const Gap(6),
                TextFormField(
                  controller: controller.cardHolderController,
                  textCapitalization: TextCapitalization.words,
                  validator: controller.validateCardHolder,
                  cursorColor: AppColors.black,
                  style: const TextStyle(color: AppColors.black, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Name on card',
                    hintStyle:
                        const TextStyle(color: AppColors.darkTextColor),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    border: _border(AppColors.lightGray),
                    enabledBorder: _border(AppColors.lightGray),
                    focusedBorder: _border(AppColors.black),
                    errorBorder: _border(AppColors.red),
                    focusedErrorBorder: _border(AppColors.red),
                  ),
                ),
                const Gap(16),

                const _FieldLabel(text: 'Card Details'),
                const Gap(6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGray),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CardField(
                    key: ValueKey(controller.cardFieldResetKey.value),
                    onCardChanged: controller.onCardChanged,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '1234 1234 1234 1234',
                      hintStyle: TextStyle(color: AppColors.darkTextColor),
                    ),
                  ),
                ),
                const Gap(16),

                Obx(
                  () => InkWell(
                    onTap: () => controller.isSaveCard.toggle(),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 22,
                            width: 22,
                            child: Checkbox(
                              value: controller.isSaveCard.value,
                              onChanged: (v) =>
                                  controller.isSaveCard.value = v ?? false,
                              activeColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const Gap(10),
                          const AppText(
                            text: 'Set as default card',
                            fontSize: 13,
                            color: AppColors.lightTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.lock_outline,
                        size: 18,
                        color: AppColors.lightTextColor,
                      ),
                      Gap(10),
                      Expanded(
                        child: AppText(
                          text:
                              'Your card details are securely encrypted and never stored on our servers.',
                          fontSize: 12,
                          maxLines: 3,
                          overflow: TextOverflow.visible,
                          color: AppColors.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(
            () => AppButton(
              text: 'Save Card',
              isLoading: controller.isSaving.value,
              onTap: () async {
                FocusScope.of(context).unfocus();

                await SystemChannels.textInput.invokeMethod<void>(
                  'TextInput.hide',
                );

                await Future.delayed(const Duration(milliseconds: 300));
                controller.saveCard();
              },
            ),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color),
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextColor,
    );
  }
}

class _CardPreview extends StatelessWidget {
  final CardController controller;

  const _CardPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.credit_card, color: AppColors.white, size: 28),
              Obx(() {
                final brand = controller.cardDetails.value?.brand;
                final brandLabel = (brand == null || brand.toString().isEmpty)
                    ? 'CARD'
                    : brand.toString().split('.').last.toUpperCase();
                return AppText(
                  text: brandLabel,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                );
              }),
            ],
          ),
          const Gap(28),
          Obx(() {
            final last4 = controller.cardDetails.value?.last4;
            final masked = (last4 == null || last4.isEmpty)
                ? '•••• •••• •••• ••••'
                : '•••• •••• •••• $last4';
            return AppText(
              text: masked,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              letterSpacing: 2,
            );
          }),
          const Gap(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      text: 'CARDHOLDER',
                      fontSize: 10,
                      color: AppColors.white,
                      letterSpacing: 1.2,
                    ),
                    const Gap(4),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller.cardHolderController,
                      builder: (_, value, __) {
                        final t = value.text.isEmpty
                            ? 'YOUR NAME'
                            : value.text.toUpperCase();
                        return AppText(
                          text: t,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          maxLines: 1,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: 'EXPIRES',
                    fontSize: 10,
                    color: AppColors.white,
                    letterSpacing: 1.2,
                  ),
                  const Gap(4),
                  Obx(() {
                    final cd = controller.cardDetails.value;
                    final m = cd?.expiryMonth;
                    final y = cd?.expiryYear;
                    final text = (m == null || y == null)
                        ? 'MM/YY'
                        : '${m.toString().padLeft(2, '0')}/${(y % 100).toString().padLeft(2, '0')}';
                    return AppText(
                      text: text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    );
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

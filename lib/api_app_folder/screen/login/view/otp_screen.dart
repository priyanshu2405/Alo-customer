import 'dart:async';
import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/login/controller/verify_otp_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final VerifyOtpController verifyOtpController =
      Get.put(VerifyOtpController());

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    verifyOtpController.timer?.cancel();
    verifyOtpController.secondsRemaining.value = 30;

    verifyOtpController.timer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (verifyOtpController.secondsRemaining.value == 0) {
        timer.cancel();
      } else {
        setState(() {
          verifyOtpController.secondsRemaining.value--;
        });
      }
    });
  }

  @override
  void dispose() {
    verifyOtpController.timer?.cancel();
    for (var c in verifyOtpController.otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String getOtp() {
    return verifyOtpController.otpControllers.map((e) => e.text).join();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(showBack: false),
      body: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(12),

                      AppText(
                        text: "OTP",
                        fontSize: 16,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                      const Gap(5),

                      /// Illustration
                      Center(
                        child: AppImage(
                          image: AppImages.loginLogo,
                          imageType: ImageType.svgAsset,
                          height: 210,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Gap(10),

                      /// Title
                      const AppText(
                        text: "Enter the code",
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),

                      const Gap(8),

                      /// Subtitle
                      AppText(
                        text:
                            "OTP was sent to your registered mobile No\n+${widget.countryCode} ${widget.phoneNumber}",
                        fontSize: 14,
                        color: AppColors.darkGrayColor,
                      ),

                      const Gap(20),

                      /// OTP Fields
                      Row(
                        children: List.generate(
                          4,
                          (index) => _otpBox(index),
                        ),
                      ),

                      const Gap(20),

                      /// Resend
                      Row(
                        children: [
                          const AppText(
                            text: "Didn't receive the code? ",
                            fontSize: 14,
                          ),
                          Obx(() {
                            if (verifyOtpController.isResendLoading.value) {
                              return const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              );
                            }
                            return InkWell(
                              onTap:
                                  verifyOtpController.secondsRemaining.value ==
                                          0
                                      ? () {
                                          verifyOtpController.resendOtp(
                                            countryCode: widget.countryCode,
                                            mobile: widget.phoneNumber,
                                          );
                                          startTimer();
                                        }
                                      : null,
                              child: AppText(
                                text: "Resend code",
                                fontSize: 14,
                                color: verifyOtpController
                                            .secondsRemaining.value ==
                                        0
                                    ? AppColors.secondary
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }),
                        ],
                      ),

                      const Gap(6),

                      /// Timer
                      Obx(() {
                        return AppText(
                          text:
                              "Time Remaining ${verifyOtpController.secondsRemaining.value}s",
                          fontSize: 12,
                        );
                      }),

                      const Gap(20),
                    ],
                  ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
        child: Obx(() => AppButton(
              isLoading: verifyOtpController.isVerifyOtp.value,
              text: "CONFIRM",
              onTap: () {
                final otp = getOtp();
                if (otp.length == 4) {
                  debugPrint("OTP Entered: $otp");
                  verifyOtpController.verifyOtp(
                    context,
                    countryCode: widget.countryCode,
                    mobile: widget.phoneNumber,
                  );
                } else {
                  Get.snackbar(
                    "Error",
                    "Please enter valid OTP",
                    backgroundColor:
                        AppColors.secondary.withOpacity(0.5),
                  );
                }
              },
            )),
      ),
    );
  }

  Widget _otpBox(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 48,
        height: 56,
        child: TextField(
          controller: verifyOtpController.otpControllers[index],
          keyboardType: TextInputType.number,
          textInputAction:
              index == 3 ? TextInputAction.done : TextInputAction.next,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            counterText: "",
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < 3) {
                FocusScope.of(context).nextFocus();
              } else {
                FocusScope.of(context).unfocus();
              }
            }
          },
          onSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }
}

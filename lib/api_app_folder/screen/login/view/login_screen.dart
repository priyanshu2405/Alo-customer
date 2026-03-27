import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/login/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppAppBar(showBack: false),
        body: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(12),

                        AppText(
                          text: "Log in",
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
                        AppText(
                          text: "Join us via Phone number",
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),

                        const Gap(8),

                        /// Subtitle
                        AppText(
                          text: "We'll text a code to verify your phone",
                          fontSize: 14,
                          color: AppColors.darkGrayColor,
                        ),

                        const Gap(25),

                        /// Phone Input
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            children: [
                              /// Country Code
                              InkWell(
                                onTap: loginController.pickCountry,
                                child: Row(
                                  children: [
                                    Obx(() {
                                      return AppText(
                                        text:
                                            "+${loginController.countryCode.value?.phoneCode ?? ""}",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      );
                                    }),
                                    const Gap(8),
                                    const Icon(Icons.keyboard_arrow_down),
                                    const Gap(10),
                                  ],
                                ),
                              ),

                              /// Divider
                              Container(
                                width: 1,
                                height: 30,
                                color: AppColors.black,
                              ),
                              const Gap(10),

                              /// Phone TextField
                              Expanded(
                                child: TextFormField(
                                  controller: loginController.phoneNumberCtrl,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLength: 13,
                                  onChanged: (_) =>
                                      loginController.validatePhone(),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                    hintText: "Phone number",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Obx(() {
                          if (loginController.phoneError.value.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: AppText(
                              text: loginController.phoneError.value,
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          );
                        }),

                        const Gap(20),
                      ],
                    ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
          child: Obx(() => AppButton(
                isLoading: loginController.isLoading.value,
                text: "NEXT",
                onTap: () => loginController.loginApi(),
              )),
        ),
      ),
    );
  }
}

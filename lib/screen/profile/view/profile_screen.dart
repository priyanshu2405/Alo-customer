import 'package:alo_ride_app/res/common/app_appbar.dart';
import 'package:alo_ride_app/res/common/app_button.dart';
import 'package:alo_ride_app/res/common/app_call_helper.dart';
import 'package:alo_ride_app/res/common/app_image.dart';
import 'package:alo_ride_app/res/common/app_text.dart';
import 'package:alo_ride_app/res/constant/app_colors.dart';
import 'package:alo_ride_app/res/constant/app_images.dart';
import 'package:alo_ride_app/screen/profile/controller/profile_controller.dart';
import 'package:alo_ride_app/screen/profile/view/common_profile_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.transparent,
        leading: Icon(Icons.menu),
        title: "Profile",
        actions: [
          InkWell(  onTap: () async {
            if (!profileController.isSave.value) {
              // ENTER EDIT MODE
              profileController.isSave.value = true;

            } else {
              profileController.isSave.value = false;
            }
          },child: AppText(text: "Edit", fontSize: 16),),
          Gap(16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 2,
              color: AppColors.darkTextColor,
            ),
            Gap(10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(20),
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 45.r,
                            backgroundImage: const NetworkImage(
                              "https://i.pravatar.cc/300",
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(30.h),
                      AppText(
                        text: "Jackson",
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.borderColor,
                      ),
                    ],
                  ),
                  Gap(50.h),
                  CommonProfileData(
                    icon: AppImages.userIcon,
                    title: "Name",
                    isSave: profileController.isSave,
                    controller: profileController.nameController,
                    subTitle: 'Jackson',
                  ),
                  Divider(
                    color: Color(0xffD9D9D9)
                  ).paddingSymmetric(vertical: 10),
                  CommonProfileData(
                    icon: AppImages.mailIcon,
                    title: "Email",
                    isSave: profileController.isSave,
                    readOnly: true,
                    controller: profileController.emailController,
                    subTitle: "jackson.123@email.com",
                  ),
                  Divider(
                    color: Color(0xffD9D9D9)
                  ).paddingSymmetric(vertical: 10),
                  CommonProfileData(
                    icon: AppImages.phoneIcon,
                    title: "Phone Number",
                    isMobile: true,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    controller: profileController.phoneNumberController,
                    isSave: profileController.isSave,

                    subTitle: "+1 985 547 2222",
                  ),
                  Gap(50),
                  Divider(color: Color(0xffD9D9D9)),
                  Gap(10),
                  Row(
                    children: [
                      AppImage(image: AppImages.logoutIcon,imageType: ImageType.svgAsset,),
                      Gap(28),
                      AppText(
                        text: "Logout",
                        color: AppColors.darkGrayColor,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(16.0),
        child: AppButton(text: "Save", onTap: () {

        },),
      ),
    );
  }

  Widget profileTile(
    IconData icon,
    String label,
    String value, {
    bool isCopy = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: Get.height * 0.03, color: AppColors.borderColor),
            const SizedBox(width: 10),
            AppText(
              text: label,
              color: AppColors.darkGrayColor,
              fontWeight: FontWeight.w400,
            ),
            Spacer(),
            if (isCopy == true)
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$label code copy successfully")),
                  );
                },
                icon: Icon(Icons.copy),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: AppText(
            text: value,
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Divider(height: 30),
      ],
    );
  }
}

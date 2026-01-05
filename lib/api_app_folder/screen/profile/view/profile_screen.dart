import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_call_helper.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/profile/controller/profile_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/profile/view/common_profile_data.dart';
import 'package:alo_ride_app/api_app_folder/services/token_store.dart';
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
  final AuthController authController = Get.put(AuthController());
  @override
  void initState() {
    profileController.getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.transparent,
        leading: SizedBox(),
        showBack: false,
        leadingWidth: 0,
        title: "Profile",
        // actions: [
        //   InkWell(
        //     onTap: () async {
        //       profileController.isSave.value = true;
        //       // if (!profileController.isSave.value) {
        //       //   // ENTER EDIT MODE
        //       //   profileController.isSave.value = true;
        //       // } else {
        //       //   profileController.isSave.value = false;
        //       // }
        //     },
        //     child: Obx(() {
        //       return AppText(
        //         text: profileController.isSave.value == true ? "Save" : "Edit",
        //         fontSize: 16,
        //       );
        //     }),
        //   ),
        //   Gap(16),
        // ],
      ),
      body: Obx(() {
        return profileController.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                          // Row(
                          //   children: [
                          //     Stack(
                          //       children: [
                          //         CircleAvatar(
                          //           radius: 45.r,
                          //           backgroundImage: const NetworkImage(
                          //             "https://i.pravatar.cc/300",
                          //           ),
                          //         ),
                          //         Positioned(
                          //           bottom: 0,
                          //           right: 0,
                          //           child: Container(
                          //             padding: EdgeInsets.all(6.w),
                          //             decoration: const BoxDecoration(
                          //               color: AppColors.secondary,
                          //               shape: BoxShape.circle,
                          //             ),
                          //             child: const Icon(
                          //               Icons.edit,
                          //               size: 14,
                          //               color: Colors.white,
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //     Gap(30.h),
                          //     AppText(
                          //       text: "Jackson",
                          //       fontSize: 18,
                          //       fontWeight: FontWeight.w500,
                          //       color: AppColors.borderColor,
                          //     ),
                          //   ],
                          // ),
                        Row(
                          children: [
                            Obx(() {
                              Widget avatarWidget;

                              // 1️⃣ PICKED IMAGE (FILE)
                              if (profileController.profileImageFile.value != null) {
                                avatarWidget = ClipOval(
                                  child: Image.file(
                                    profileController.profileImageFile.value!,
                                    width: 90.w,
                                    height: 90.w,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }

                              // 2️⃣ NETWORK IMAGE (API)
                              else if (profileController.profileImageUrl.isNotEmpty) {
                                avatarWidget = ClipOval(
                                  child: Image.network(
                                    profileController.profileImageUrl.value,
                                    width: 90.w,
                                    height: 90.w,
                                    fit: BoxFit.cover,

                                    /// 🔄 LOADER
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        width: 90.w,
                                        height: 90.w,
                                        child: const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    },

                                    /// ❌ ERROR IMAGE
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                        "https://static.vecteezy.com/system/resources/previews/019/879/186/non_2x/user-icon-on-transparent-background-free-png.png",
                                        width: 90.w,
                                        height: 90.w,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                );
                              }

                              // 3️⃣ DEFAULT AVATAR
                              else {
                                avatarWidget = ClipOval(
                                  child: Image.network(
                                    "https://static.vecteezy.com/system/resources/previews/019/879/186/non_2x/user-icon-on-transparent-background-free-png.png",
                                    width: 90.w,
                                    height: 90.w,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }

                              return Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.black,
                                        width: 2,
                                      ),
                                    ),
                                    child: avatarWidget,
                                  ),

                                  /// ✏️ EDIT ICON
                                  if (profileController.isSave.value)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: profileController.showImagePicker,
                                        child: Container(
                                          padding: EdgeInsets.all(6.w),
                                          decoration: const BoxDecoration(
                                            color: AppColors.secondary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),

                            Gap(30.h),

                            AppText(
                              text: profileController.nameController.text.isNotEmpty
                                  ? profileController.nameController.text
                                  : "",
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
                            subTitle: profileController.nameController.text,
                          ),
                          Divider(
                            color: Color(0xffD9D9D9),
                          ).paddingSymmetric(vertical: 10),
                          // CommonProfileData(
                          //   icon: AppImages.mailIcon,
                          //   title: "Email",
                          //   isSave: profileController.isSave,
                          //   readOnly: true,
                          //   controller: profileController.emailController,
                          //   subTitle: profileController.emailController.text,
                          // ),
                          // Divider(
                          //   color: Color(0xffD9D9D9),
                          // ).paddingSymmetric(vertical: 10),
                          CommonProfileData(
                            icon: AppImages.phoneIcon,
                            title: "Phone Number",
                            isMobile: true,
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            controller: profileController.phoneNumberController,
                            isSave: profileController.isSave,
                            subTitle:
                                profileController.phoneNumberController.text,
                          ),
                          Gap(50),
                          Divider(color: Color(0xffD9D9D9)),
                          Gap(10),
                          Row(
                            children: [
                              AppImage(
                                image: AppImages.logoutIcon,
                                imageType: ImageType.svgAsset,
                              ),
                              Gap(28),
                              Obx(() {
                                return profileController.isLogoutUser.value
                                    ? CircularProgressIndicator()
                                    : InkWell(
                                        onTap: () {
                                          profileController.logoutUser();
                                          authController.logout();
                                        },
                                        child: AppText(
                                          text: "Logout",
                                          color: AppColors.darkGrayColor,
                                        ),
                                      );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      }),
      floatingActionButton: InkWell(
        onTap: () => AppCallHelper.callSOS(),
        child: AppImage(
          height: 55,
          width: 55,
          image: AppImages.sosButton,
          imageType: ImageType.asset,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return AppButton(
            isLoading: profileController.isEditProfile.value,
            text: "Save",
            onTap: () {
              if (profileController.isSave.value) {
                // 👉 SAVE MODE
                profileController.editProfile();
              } else {
                // 👉 SWITCH TO SAVE MODE
                profileController.isSave.value = true;
              }
            },
            // onTap: () {
            //   if(profileController.isSave.value == true){
            //     profileController.editProfile();
            //   }
            //
            // },
          );
        },),
      ),
    );
  }
}

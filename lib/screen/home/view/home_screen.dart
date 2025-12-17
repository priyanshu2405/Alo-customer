
import 'package:alo_ride_app/res/common/app_appbar.dart';
import 'package:alo_ride_app/res/common/app_image.dart';
import 'package:alo_ride_app/res/common/app_text.dart';
import 'package:alo_ride_app/res/constant/app_colors.dart';
import 'package:alo_ride_app/res/constant/app_images.dart';
import 'package:alo_ride_app/screen/booking/view/booking_screen.dart';
import 'package:alo_ride_app/screen/home/controller/home_controller.dart';
import 'package:alo_ride_app/screen/home/controller/location_controller.dart';
import 'package:alo_ride_app/screen/home/view/welcome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final HomeController homeController = Get.put(HomeController());
  final LocationController controller = Get.put(LocationController());

  @override
  void initState() {
    super.initState();

    /// ✅ Show dialog AFTER first frame
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showWelcomeDialog();
    // });
  }

  void _showWelcomeDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WelcomeDialog(
          controller: homeController,
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: AppAppBar(
        backgroundColor: Colors.transparent,
        leading: Icon(Icons.menu),
        title: "Home",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 540.h,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: controller.currentLatLng.value ?? const LatLng(0, 0),
                        zoom: 14,
                      ),
                      onMapCreated: (mapController) {
                        if (!controller.mapController.isCompleted) {
                          controller.mapController.complete(mapController);
                        }
                        controller.googleController = mapController;

                        final latLng = controller.currentLatLng.value;
                        if (latLng != null) {
                          mapController.animateCamera(
                            CameraUpdate.newLatLng(latLng),
                          );
                        }
                      },
                      markers: controller.markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      circles: controller.currentLatLng.value == null
                          ? {}
                          : {
                        Circle(
                          circleId: const CircleId('radius'),
                          center: controller.currentLatLng.value!,
                          radius: controller.selectedDistance.value * 1000,
                          strokeColor: AppColors.secondary.withOpacity(0.5),
                          fillColor: AppColors.secondary.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                      },
                      onTap: controller.onMapTap,
                    ),
                    Positioned(
                      top: 90.h,
                      left: 16.w,
                      right: 16.w,
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.lightGray, width: 2),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(.1),
                            )
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppImage(
                              height: 20.h,
                              width: 20.w,
                              image: AppImages.recordCircleFill,
                              imageType: ImageType.svgAsset,
                            ),
                            Gap(10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppText(
                                    text: "From",
                                    fontSize: 15,
                                  ),
                                  Gap(4.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Obx(() => AppText(
                                          text: controller.currentAddress.value,
                                          color: AppColors.greyColor,
                                          fontSize: 13,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                      ),
                                      Gap(20.w),
                                      const Icon(
                                        Icons.favorite_border,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,right: 10,
                      child: AppImage(
                        height: 55,width: 55,
                        image: AppImages.sosButton,
                        imageType: ImageType.asset,
                      ),
                    ),
                  ],
                );
              }),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Gap(20.h),
                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: AppText(
                    text: "Choose Your Vehicle Type",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gap(16.h),

                // Vehicle Options
                SizedBox(
                  height: 110.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    itemCount: homeController.vehicles.length,
                    itemBuilder: (context, index) {
                      bool isSelected = homeController.selectedVehicleIndex.value == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            homeController.selectedVehicleIndex.value = index;
                          });
                        },
                        child: Container(
                          width: 85.w,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.secondary.withOpacity(0.07)
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.secondary
                                  : AppColors.greyColor,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                homeController.vehicles[index]['icon'],
                                size: 32,
                                color: isSelected
                                    ? AppColors.secondary
                                    : AppColors.greyColor,
                              ),
                              Gap(6.h),
                              AppText(
                                text: homeController.vehicles[index]['name'],
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: AppColors.black,
                              ),
                              Gap(2.h),
                              AppText(
                                text: homeController.vehicles[index]['capacity'],
                                fontSize: 9,
                                color: AppColors.lightTextColor,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Gap(16.h),

                // Book Now Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: ElevatedButton(
                    onPressed: () {
                      // Get.to(()=>BookingScreen());
                      Get.to(()=>BookingScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: AppText(
                      text: "BOOK NOW",
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Gap(16.h),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
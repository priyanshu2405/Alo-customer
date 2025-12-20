
import 'package:alo_ride_app/design_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/design_folder/res/common/app_call_helper.dart';
import 'package:alo_ride_app/design_folder/res/common/app_image.dart';
import 'package:alo_ride_app/design_folder/res/common/app_text.dart';
import 'package:alo_ride_app/design_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/design_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/design_folder/screen/booking/view/booking_screen.dart';
import 'package:alo_ride_app/design_folder/screen/home/controller/home_controller.dart';
import 'package:alo_ride_app/design_folder/screen/home/controller/location_controller.dart';
import 'package:alo_ride_app/design_folder/screen/home/view/welcome_dialog.dart';
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
        title: "",
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
                      child: InkWell(
                        onTap: () {
                          _showLocationSearchSheet(context);
                        },
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
                    ),
                    Positioned(
                      bottom: 10,right: 10,
                      child: InkWell(
                        onTap: () => AppCallHelper.callSOS(),
                        child: AppImage(
                          height: 55,width: 55,
                          image: AppImages.sosButton,
                          imageType: ImageType.asset,
                        ),
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
                          width: 90.w,
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



  void _showLocationSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.05),
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Gap(16.h),
                  // Search Field
                  TextField(
                    controller: controller.searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          controller.clearSearch();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.lightGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.secondary, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      controller.getPlaces(value);
                    },
                  ),
                ],
              ),
            ),

            // Current Location Button
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.my_location,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              title: AppText(
                text: "Use Current Location",
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              subtitle: Obx(() => AppText(
                text: controller.currentAddress.value,
                fontSize: 12,
                color: AppColors.greyColor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
              onTap: () async {
                await controller.retryLocationFetch();
                Navigator.pop(context);
              },
            ),

            Divider(height: 1),

            // Search Results
            Expanded(
              child: Obx(() {
                if (!controller.showPredictions.value ||
                    controller.predictions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        Gap(16.h),
                        AppText(
                          text: "Search for a location",
                          fontSize: 16,
                          color: AppColors.greyColor,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: controller.predictions.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final prediction = controller.predictions[index];
                    return ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      title: AppText(
                        text: prediction['structured_formatting']
                        ['main_text'] ??
                            '',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: AppText(
                        text: prediction['description'] ?? '',
                        fontSize: 12,
                        color: AppColors.greyColor,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () async {
                        await controller.getPlaceDetails(
                          prediction['place_id'],
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }




}
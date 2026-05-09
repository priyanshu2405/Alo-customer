import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_call_helper.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/booking/view/booking_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/home/controller/home_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/home/controller/location_controller.dart';
import 'package:flutter/material.dart';
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

   // homeController.getVehicleTypes();
    homeController.getFlatRatesList();
    homeController.getMyPackagesList();
    homeController.getErrandsList();
    homeController.selectedType.value = 0;
    homeController.selectedType.value = 0;
    /// ✅ Show dialog AFTER first frame
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showWelcomeDialog();
    // });
  }

  @override
  void dispose() {
    homeController.selectedItemId.value = -1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: AppAppBar(
        backgroundColor: Colors.transparent,
        leading: SizedBox(),
        showBack: false,
        leadingWidth: 0,
        title: "",
      ),
      body: Obx(() {
        return homeController.isVehicleTypes.value
            ? Center(child: CircularProgressIndicator())
            : Column(
             crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Obx(() {
                    print(controller.currentLatLng.value);
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target:
                                controller.currentLatLng.value ??
                                const LatLng(46.5, -66.0),
                            zoom: 7,
                          ),
                          onMapCreated: (mapController) {
                            if (!controller.mapController.isCompleted) {
                              controller.mapController.complete(
                                mapController,
                              );
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
                          zoomGesturesEnabled: true,
                          circles: controller.currentLatLng.value == null
                              ? {}
                              : {
                                  Circle(
                                    circleId: const CircleId('radius'),
                                    center: controller.currentLatLng.value!,
                                    radius:
                                        controller.selectedDistance.value *
                                        1000,
                                    strokeColor: AppColors.secondary
                                        .withOpacity(0.5),
                                    fillColor: AppColors.secondary
                                        .withOpacity(0.2),
                                    strokeWidth: 1,
                                  ),
                                },
                          onTap: controller.onMapTap,
                        ),
                        Positioned(
                          top: 90,
                          left: 16,
                          right: 16,
                          child: InkWell(
                            onTap: () {
                              _showLocationSearchSheet(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.lightGray,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(.1),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  AppImage(
                                    height: 20,
                                    width: 20,
                                    image: AppImages.recordCircleFill,
                                    imageType: ImageType.svgAsset,
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AppText(text: "From", fontSize: 15),
                                        const Gap(4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Obx(
                                                () => AppText(
                                                  text: controller
                                                      .currentAddress
                                                      .value,
                                                  color:
                                                      AppColors.greyColor,
                                                  fontSize: 13,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            // Gap(20.w),
                                            // const Icon(
                                            //   Icons.favorite_border,
                                            //   size: 20,
                                            // ),
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
                          bottom: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () => AppCallHelper.callSOS(),
                            child: AppImage(
                              height: 55,
                              width: 55,
                              image: AppImages.sosButton,
                              imageType: ImageType.asset,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                Expanded(
                 child: SingleChildScrollView(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           const Gap(20),
                           // Title
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 16),
                             child: AppText(
                               text: "Flats Rates",
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           const Gap(16),
                   
                           // Vehicle Options
                           Obx(() {
                             final vehicles = homeController.flatRatesList;
                   
                             if (vehicles.isEmpty) {
                               return const SizedBox();
                             }
                   
                             return SingleChildScrollView(
                               scrollDirection: Axis.horizontal,
                               padding: const EdgeInsets.symmetric(horizontal: 12),
                               child: Row(
                                 children: List.generate(vehicles.length, (index) {
                                   final vehicle = vehicles[index];

                                   bool isSelected =
                                       homeController.selectedItemId.value == vehicle.id &&
                                           homeController.selectedType.value == 1;

                                   return GestureDetector(
                                     onTap: () {
                                       if (vehicle.id != null) {
                                         homeController.selectedItemId.value = vehicle.id!;
                                         homeController.selectedType.value = 1;
                                         homeController.selectedVehicleName.value = vehicle.rideType ?? "";
                                       }
                                     },
                                     child: Container(
                                       width: 90,
                                       margin: const EdgeInsets.symmetric(horizontal: 6),
                                       padding: const EdgeInsets.symmetric(
                                         horizontal: 8,
                                         vertical: 10,
                                       ),
                                       decoration: BoxDecoration(
                                         color: isSelected
                                             ? AppColors.secondary.withOpacity(0.07)
                                             : AppColors.white,
                                         borderRadius: BorderRadius.circular(12),
                                         border: Border.all(
                                           color: isSelected
                                               ? AppColors.secondary
                                               : AppColors.greyColor,
                                         ),
                                       ),
                                       child: Column(
                                         mainAxisSize: MainAxisSize.min, // ⭐ important
                                         children: [
                                           AppImage(
                                             image: vehicle.image ?? "",
                                             imageType: ImageType.network,
                                             height: 45,
                                             width: 45,
                                             fit: BoxFit.contain,
                                           ),

                                           const SizedBox(height: 6),

                                           AppText(
                                             text: vehicle.rideType ?? "",
                                             fontSize: 12,
                                             fontWeight:
                                             isSelected ? FontWeight.bold : FontWeight.normal,
                                             color: AppColors.black,
                                             textAlign: TextAlign.center,
                                             maxLines: 1,
                                             overflow: TextOverflow.ellipsis,
                                           ),
                   
                                           const SizedBox(height: 3),

                                           AppText(
                                             text: "Distance : ${vehicle.distanceRule ?? "-"}",
                                             fontSize: 10,
                                             color: AppColors.lightTextColor,
                                             textAlign: TextAlign.center,
                                             overflow: TextOverflow.visible,
                                           ),
                   
                                           const SizedBox(height: 3),

                                           AppText(
                                             text: vehicle.price != null
                                                 ? "Price : \$${vehicle.price}"
                                                 : "Price : -",
                                             fontSize: 10,
                                             color: AppColors.lightTextColor,
                                             textAlign: TextAlign.center,
                                           ),
                                         ],
                                       ),
                                     ),
                                   );
                                 }),
                               ),
                             );
                           }),
                           // SizedBox(
                           //   height: 150.h,
                           //   child: Obx(() {
                           //     return ListView.builder(
                           //       scrollDirection: Axis.horizontal,
                           //       padding: EdgeInsets.symmetric(horizontal: 12.w),
                           //       itemCount: homeController.flatRatesList.length ?? 0,
                           //       itemBuilder: (context, index) {
                           //         final vehicle = homeController.flatRatesList[index];
                           //
                           //         bool isSelected = homeController.selectedVehicleIndex.value == vehicle.id;
                           //
                           //         return GestureDetector(
                           //           onTap: () {
                           //             if (vehicle.id != null) {
                           //              setState(() {
                           //                homeController.selectedVehicleIndex.value = vehicle.id!;
                           //               // homeController.selectedVehicleName.value = vehicle.name ?? '';
                           //
                           //
                           //                debugPrint("Selected Vehicle ID: ${vehicle.id}");
                           //               // debugPrint("Selected Vehicle Name: ${vehicle.name}");
                           //              });
                           //             }
                           //           },
                           //           child: Container(
                           //             width: 90.w,
                           //             margin: EdgeInsets.symmetric(horizontal: 4.w),
                           //             padding: EdgeInsets.all(8.w),
                           //             decoration: BoxDecoration(
                           //               color: isSelected
                           //                   ? AppColors.secondary.withOpacity(0.07)
                           //                   : AppColors.white,
                           //               borderRadius: BorderRadius.circular(12),
                           //               border: Border.all(
                           //                 color: isSelected
                           //                     ? AppColors.secondary
                           //                     : AppColors.greyColor,
                           //                 width: 1,
                           //               ),
                           //             ),
                           //             child: Column(
                           //               mainAxisAlignment: MainAxisAlignment.center,
                           //               children: [
                           //                 // Icon(
                           //                 //   Icons.directions_car,
                           //                 //   size: 32,
                           //                 //   color: isSelected
                           //                 //       ? AppColors.secondary
                           //                 //       : AppColors.greyColor,
                           //                 // ),
                           //                 AppImage(image: "${vehicle.image}",imageType: ImageType.network,height: 50.h,),
                           //                 Gap(6.h),
                           //                 AppText(
                           //                   text: vehicle.rideType ?? "",
                           //                   fontSize: 12,
                           //                   fontWeight:
                           //                   isSelected ? FontWeight.bold : FontWeight.normal,
                           //                   color: AppColors.black,
                           //                 ),
                           //                 Gap(2.h),
                           //                 AppText(
                           //                   text: "Distance : ${vehicle.distanceRule}",
                           //                   fontSize: 9,
                           //                   color: AppColors.lightTextColor,
                           //                   textAlign: TextAlign.center,
                           //                   overflow: TextOverflow.visible,
                           //                 ),
                           //                 Gap(2.h),
                           //                 AppText(
                           //                   text: "Price : ${vehicle.price}",
                           //                   fontSize: 9,
                           //                   color: AppColors.lightTextColor,
                           //                   textAlign: TextAlign.center,
                           //                 ),
                           //               ],
                           //             ),
                           //           ),
                           //         );
                           //       },
                           //     );
                           //   },),
                           // ),
                   
                   
                         ],
                       ),
                       // Column(
                       //   crossAxisAlignment: CrossAxisAlignment.start,
                       //   mainAxisSize: MainAxisSize.min,
                       //   mainAxisAlignment: MainAxisAlignment.start,
                       //   children: [
                       //     Gap(20.h),
                       //     // Title
                       //     Padding(
                       //       padding: EdgeInsets.symmetric(horizontal: 16.w),
                       //       child: AppText(
                       //         text: "Choose Your Purchased Package",
                       //         fontSize: 18,
                       //         fontWeight: FontWeight.bold,
                       //       ),
                       //     ),
                       //     Gap(16.h),
                       //
                       //     // Vehicle Options
                       //     Obx(() {
                       //       final vehicles = homeController.myPackageList;
                       //
                       //       if (vehicles.isEmpty) {
                       //         return  Center(
                       //           child: AppText(
                       //             text: "No Purchased Package Found",
                       //             fontSize: 7.sp,
                       //             fontWeight: FontWeight.normal,
                       //             color: AppColors.black,
                       //
                       //             textAlign: TextAlign.center,
                       //             overflow: TextOverflow.visible,
                       //           ),
                       //         );
                       //       }
                       //
                       //       return SingleChildScrollView(
                       //         scrollDirection: Axis.horizontal,
                       //         padding: EdgeInsets.symmetric(horizontal: 12.w),
                       //         child: Row(
                       //           crossAxisAlignment: CrossAxisAlignment.start,
                       //           mainAxisAlignment: MainAxisAlignment.start,
                       //           children: List.generate(vehicles.length, (index) {
                       //             final vehicle = vehicles[index];
                       //             bool isSelected =
                       //                 homeController.selectedItemId.value == vehicle.purchaseId &&
                       //                     homeController.selectedType.value == 2;
                       //
                       //             return GestureDetector(
                       //               onTap: () {
                       //                 if (vehicle.purchaseId != null) {
                       //                   homeController.selectedItemId.value = vehicle.purchaseId!;
                       //                   homeController.selectedType.value = 2;
                       //                   homeController.selectedVehicleName.value = vehicle.packageName ?? "";
                       //                 }
                       //               },
                       //               child: Container(
                       //                 width: 90.w,
                       //                 margin: EdgeInsets.symmetric(horizontal: 6.w),
                       //                 padding: EdgeInsets.symmetric(
                       //                   horizontal: 8.w,
                       //                   vertical: 10.h,
                       //                 ),
                       //                 decoration: BoxDecoration(
                       //                   color: isSelected
                       //                       ? AppColors.secondary.withOpacity(0.07)
                       //                       : AppColors.white,
                       //                   borderRadius: BorderRadius.circular(12.r),
                       //                   border: Border.all(
                       //                     color: isSelected
                       //                         ? AppColors.secondary
                       //                         : AppColors.greyColor,
                       //                   ),
                       //                 ),
                       //                 child: Column(
                       //
                       //                   mainAxisSize: MainAxisSize.min, // ⭐ important
                       //                   children: [
                       //                     AppImage(
                       //                       image: vehicle.image ?? "",
                       //                       imageType: ImageType.network,
                       //                       height: 45.h,
                       //                       width: 45.w,
                       //                       fit: BoxFit.contain,
                       //                     ),
                       //
                       //                     SizedBox(height: 6.h),
                       //
                       //                     AppText(
                       //                       text: vehicle.packageName ?? "",
                       //                       fontSize: 12.sp,
                       //                       fontWeight:
                       //                       isSelected ? FontWeight.bold : FontWeight.normal,
                       //                       color: AppColors.black,
                       //                       textAlign: TextAlign.center,
                       //                       overflow: TextOverflow.visible,
                       //                     ),
                       //
                       //                     SizedBox(height: 3.h),
                       //
                       //                     AppText(
                       //                       text: "Rides Remaining : ${vehicle.ridesRemaining ?? "-"}",
                       //                       fontSize: 10.sp,
                       //                       color: AppColors.lightTextColor,
                       //                       textAlign: TextAlign.center,
                       //                       overflow: TextOverflow.visible,
                       //                     ),
                       //
                       //                     AppText(
                       //                       text:  "Price : \$${vehicle.amountPaid}",
                       //                       fontSize: 10.sp,
                       //                       color: AppColors.lightTextColor,
                       //                       textAlign: TextAlign.center,
                       //                       overflow: TextOverflow.visible,
                       //                     ),
                       //                   ],
                       //                 ),
                       //               ),
                       //             );
                       //           }),
                       //         ),
                       //       );
                       //     }),
                       //   ],
                       // ),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisSize: MainAxisSize.min,
                         mainAxisAlignment: MainAxisAlignment.start,
                         children: [
                           const Gap(20),
                           // Title
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 16),
                             child: AppText(
                               text: "Choose the Errands",
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           const Gap(16),

                           // Vehicle Options
                           Obx(() {
                             final vehicles = homeController.errandsList;

                             if (vehicles.isEmpty) {
                               return const SizedBox();
                             }

                             return SingleChildScrollView(
                               scrollDirection: Axis.horizontal,
                               padding: const EdgeInsets.symmetric(horizontal: 12),
                               child: Row(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 mainAxisAlignment: MainAxisAlignment.start,
                                 children: List.generate(vehicles.length, (index) {
                                   final vehicle = vehicles[index];

                                   bool isSelected =
                                       homeController.selectedItemId.value == vehicle.id &&
                                           homeController.selectedType.value == 3;

                                   return GestureDetector(
                                     onTap: () {
                                       if (vehicle.id != null) {
                                         homeController.selectedItemId.value = vehicle.id!;
                                         homeController.selectedType.value = 3;
                                         homeController.selectedVehicleName.value = vehicle.name ?? "";
                                       }
                                     },
                                     child: Container(
                                       width: 90,
                                       margin: const EdgeInsets.symmetric(horizontal: 6),
                                       padding: const EdgeInsets.symmetric(
                                         horizontal: 8,
                                         vertical: 10,
                                       ),
                                       decoration: BoxDecoration(
                                         color: isSelected
                                             ? AppColors.secondary.withOpacity(0.07)
                                             : AppColors.white,
                                         borderRadius: BorderRadius.circular(12),
                                         border: Border.all(
                                           color: isSelected
                                               ? AppColors.secondary
                                               : AppColors.greyColor,
                                         ),
                                       ),
                                       child: Column(
                   
                                         mainAxisSize: MainAxisSize.min, // ⭐ important
                                         children: [
                                           AppImage(
                                             image: vehicle.image ?? "",
                                             imageType: ImageType.network,
                                             height: 45,
                                             width: 45,
                                             fit: BoxFit.contain,
                                           ),

                                           const SizedBox(height: 6),

                                           AppText(
                                             text: vehicle.name ?? "",
                                             fontSize: 12,
                                             fontWeight:
                                             isSelected ? FontWeight.bold : FontWeight.normal,
                                             color: AppColors.black,
                                             textAlign: TextAlign.center,
                                             maxLines: 1,
                                             overflow: TextOverflow.ellipsis,
                                           ),
                   
                                           const SizedBox(height: 3),

                                           AppText(
                                             text: "Distance : ${vehicle.distanceLimit ?? "-"}",
                                             fontSize: 10,
                                             color: AppColors.lightTextColor,
                                             textAlign: TextAlign.center,
                                             overflow: TextOverflow.visible,
                                           ),
                                           AppText(
                                             text: "Duration Minutes : ${vehicle.durationMinutes ?? "-"}",
                                             fontSize: 10,
                                             color: AppColors.lightTextColor,
                                             textAlign: TextAlign.center,
                                             overflow: TextOverflow.visible,
                                           ),
                   
                                           const SizedBox(height: 3),

                                           AppText(
                                             text: vehicle.price != null
                                                 ? "Price : \$${vehicle.price}"
                                                 : "Price : -",
                                             fontSize: 10,
                                             color: AppColors.lightTextColor,
                                             textAlign: TextAlign.center,
                                           ),
                                         ],
                                       ),
                                     ),
                                   );
                                 }),
                               ),
                             );
                           }),
                         ],
                       ),
                     ],
                   ),
                   ),
                 ),
                const Gap(16),

                //Text(homeController.selectedItemId.value.toString()),
                if(homeController.selectedItemId.value != -1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      if (homeController.selectedItemId.value == -1) {
                        Get.snackbar(
                          "Selection Required",
                          "Please select one option from Flat Rates, Packages or Errands",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red.withOpacity(0.8),
                          colorText: Colors.white,
                        );
                        return;
                      }

                      debugPrint(
                        "vehicleTypeId : ${homeController.selectedVehicleIndex.value}",
                      );
                      print("latLng:: ${controller.currentLatLng.value}");
                      Get.to(() => BookingScreen(
                        selectedType: homeController.selectedType.value,
                        vehicleTypeId: homeController.selectedItemId.value,
                        vehicleTypeName: homeController.selectedVehicleName.value,
                      ))?.then((value) async {
                        homeController.getFlatRatesList();
                        homeController.getMyPackagesList();
                        homeController.getErrandsList();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      minimumSize: const Size(double.infinity, 50),
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

                const Gap(16),
              ],
            );
      }),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(16),
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
                        borderSide: BorderSide(
                          color: AppColors.secondary,
                          width: 2,
                        ),
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
              subtitle: Obx(
                () => AppText(
                  text: controller.currentAddress.value,
                  fontSize: 12,
                  color: AppColors.greyColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
                        const Gap(16),
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
                        text:
                            prediction['structured_formatting']['main_text'] ??
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

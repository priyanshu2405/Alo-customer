import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_call_helper.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/booking/controller/booking_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/booking/view/ride_confirmed_widget.dart';
import 'package:alo_ride_app/api_app_folder/screen/home/controller/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final int vehicleTypeId;
  final String vehicleTypeName;
  const BookingScreen({super.key, required this.vehicleTypeId, required this.vehicleTypeName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final LocationController controller = Get.put(LocationController());
  final BookingController bookingController = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    // ✅ Set initial pickup location to current location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentLatLng.value != null &&
          bookingController.fromLatLng.value == null) {
        bookingController.fromLatLng.value = controller.currentLatLng.value;
        bookingController.fromLocation.value = controller.currentAddress.value;

        debugPrint("🎯 Initial Location Set:");
        debugPrint("Address: ${bookingController.fromLocation.value}");
        debugPrint("LatLng: ${bookingController.fromLatLng.value}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: AppAppBar(
        backgroundColor: Colors.transparent,
        // leading: Icon(Icons.menu),
        title: "",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 600.h,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target:
                            controller.currentLatLng.value ??
                            const LatLng(0, 0),
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
                                radius:
                                    controller.selectedDistance.value * 1000,
                                strokeColor: AppColors.secondary.withOpacity(
                                  0.5,
                                ),
                                fillColor: AppColors.secondary.withOpacity(0.2),
                                strokeWidth: 1,
                              ),
                            },
                      onTap: controller.onMapTap,
                    ),
                    Positioned(
                      top: 80.h,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: [
                          // Container(
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(6),
                          //     border: Border.all(
                          //       color: AppColors.lightGray,
                          //       width: 2,
                          //     ),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.black.withOpacity(0.1),
                          //         blurRadius: 10,
                          //         offset: const Offset(0, 4),
                          //       ),
                          //     ],
                          //   ),
                          //   child: Column(
                          //     children: [
                          //       // From location
                          //       Gap(10),
                          //       _buildLocationRow(
                          //         icon: Icons.circle,
                          //         iconColor: AppColors.pinkColor,
                          //         title: 'From',
                          //         subtitle: '341-205 Barrinou Rd, Moncton,',
                          //         showDivider: true,
                          //       ),
                          //
                          //       // Drop off location
                          //       _buildLocationRow(
                          //         icon: Icons.location_on,
                          //         iconColor: AppColors.pinkColor,
                          //         title: 'Drop off Location',
                          //         subtitle: '100 Holland Dr, Moncton, NB E1...',
                          //         showDivider: false,
                          //       ),
                          //       Gap(10),
                          //     ],
                          //   ),
                          // ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.lightGray,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Gap(10),
                                // From location
                                _buildLocationRow(
                                  icon: Icons.circle,
                                  iconColor: AppColors.pinkColor,
                                  title: 'From',
                                  subtitle: bookingController.fromLocation.value.isEmpty
                                      ? controller.currentAddress.value
                                      : bookingController.fromLocation.value,
                                  showDivider: true,
                                  onTap: () => _showLocationSearchSheet(
                                    context,
                                    isPickup: true,
                                  ),
                                ),

                                // Drop off location
                                _buildLocationRow(
                                  icon: Icons.location_on,
                                  iconColor: AppColors.pinkColor,
                                  title: 'Drop off Location',
                                  subtitle: bookingController.dropOffLocation.value.isEmpty
                                      ? 'Select drop off location'
                                      : bookingController.dropOffLocation.value,
                                  showDivider: false,
                                  onTap: () => _showLocationSearchSheet(
                                    context,
                                    isPickup: false,
                                  ),
                                ),
                                Gap(10),
                              ],
                            ),
                          ),
                          Gap(10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.lightGray,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // From location
                                  Gap(12.h),

                                  /// PICKUP TYPE
                                  Row(
                                    children: [
                                      _radioOption("Pickup & Drop", 0),
                                      Gap(20.w),
                                      // _radioOption(
                                      //   "Round-Trip Pickup & Drop",
                                      //   1,
                                      // ),
                                    ],
                                  ),

                                  Gap(14.h),

                                  AppText(
                                    text: "Ride Later",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),

                                  Gap(8.h),
                                  Row(
                                    children: [
                                      _dateTimeBox(
                                        type: "date",
                                        icon: Icons.calendar_month,
                                        title: "Select Date",
                                      ),
                                      Gap(12.w),
                                      _dateTimeBox(
                                        type: "time",
                                        icon: Icons.access_time,
                                        title: "Select Time",
                                      ),
                                      // Gap(10),
                                      // Container(
                                      //   height: 45.h,
                                      //   width: 45.w,
                                      //   decoration: BoxDecoration(
                                      //     border: Border.all(
                                      //       color: AppColors.borderColor,
                                      //     ),
                                      //     borderRadius: BorderRadius.circular(
                                      //       8.r,
                                      //     ),
                                      //   ),
                                      //   child: const Icon(Icons.add),
                                      // ),
                                    ],
                                  ),
                                  Gap(20.w),
                                ],
                              ),
                            ),
                          ),

                        ],
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
            Gap(20),
            Obx(() {
              final date = bookingController.selectedDate.value ?? DateTime.now();
              final time = bookingController.selectedTime.value ?? DateTime.now();

              return AppText(
                text:
                "Ride on ${DateFormat("dd MMM yyyy").format(date)} at ${DateFormat("hh:mm a").format(time)}",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              );
            }),
            Gap(8.h),
            Divider(color: AppColors.darkTextColor),
            Gap(8.h),
            Obx(() {
              return AppText(
                text: "Selected car : ${widget.vehicleTypeName}     Fare estimate : \$${bookingController.totalFare.value}",
                fontSize: 12,
                color: AppColors.lightBlackColor,
              );
            },),
            Gap(8.h),
            Divider(color: AppColors.darkTextColor),
            Gap(8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Note: ",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightBlackColor,
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text:
                          "This is an approximate estimate. Actual cost may be different due to traffic and waiting time.",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.lightBlackColor,
                          height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Gap(20.h),

            /// BOOK NOW BUTTON
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              child: AppButton(text: "Book Now", onTap: () {
                // bookingController.estimateFare(vehicleTypeId: widget.vehicleTypeId);
                // showRideConfirmed(context);
                // Get.to(()=>RideTrackingScreen());
              }),
            ),
            Gap(30.h),
          ],
        ),
      ),
    );
  }

  /// ================= RADIO OPTION =================
  Widget _radioOption(String text, int value) {
    return Obx(() {
      final isSelected = bookingController.selectValue.value == value;

      return InkWell(
        onTap: () {
          bookingController.selectValue.value = value; // ✅ FIX
        },
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: AppColors.black,
            ),
            Gap(6.w),
            AppText(text: text, fontSize: 12),
          ],
        ),
      );
    });
  }

  /// ================= DATE TIME BOX =================
  Widget _dateTimeBox({
    required String type, // "date" or "time"
    required String title,
    required IconData icon,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () async {  // ✅ Make it async
          if (type == "date") {
            await bookingController.pickDate(context);
          } else {
            // ✅ Pick time first
            await bookingController.pickTime(context);

            // ✅ Then call estimateFare only if time was selected
            if (bookingController.selectedTime.value != null) {
              bookingController.estimateFare(vehicleTypeId: widget.vehicleTypeId);
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: title,
              fontSize: 12,
              color: AppColors.textColor,
              fontWeight: FontWeight.w500,
            ),
            Gap(7),
            Container(
              height: 45.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      return AppText(
                        text: type == "date"
                            ? (bookingController.selectedDate.value == null?"Select Date":bookingController.formattedDate)
                            : (bookingController.selectedTime.value == null ? "Select Time" : bookingController.formattedTime),
                        fontSize: 12,
                        color: AppColors.greyColor,
                      );
                    }),
                  ),
                  Icon(icon, color: Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void showRideConfirmed(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return RideConfirmedWidget(
          dateTimeText: "10 Dec at 07:30 AM",
        );
      },
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool showDivider,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with connecting line
                Column(
                  children: [
                    Icon(icon, color: iconColor, size: 20),
                    if (showDivider)
                      Column(
                        children: List.generate(10, (index) {
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
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitle.contains('Select')
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ],
                  ),
                ),

                // Favorite icon
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  color: Colors.grey[400],
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLocationSearchSheet(BuildContext context, {required bool isPickup}) {
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
                  // Title
                  Row(
                    children: [
                      Icon(
                        isPickup ? Icons.circle : Icons.location_on,
                        color: AppColors.pinkColor,
                        size: 20,
                      ),
                      Gap(8.w),
                      AppText(
                        text: isPickup ? "Select Pickup Location" : "Select Drop-off Location",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  Gap(12.h),
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
                          color: AppColors.pinkColor,
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

            // Current Location Button (only for pickup)
            // if (isPickup)
            //   ListTile(
            //     leading: Container(
            //       padding: EdgeInsets.all(8),
            //       decoration: BoxDecoration(
            //         color: AppColors.pinkColor.withOpacity(0.1),
            //         shape: BoxShape.circle,
            //       ),
            //       child: Icon(
            //         Icons.my_location,
            //         color: AppColors.pinkColor,
            //         size: 20,
            //       ),
            //     ),
            //     title: AppText(
            //       text: "Use Current Location",
            //       fontSize: 15,
            //       fontWeight: FontWeight.w500,
            //     ),
            //     subtitle: Obx(() => AppText(
            //       text: controller.currentAddress.value,
            //       fontSize: 12,
            //       color: AppColors.greyColor,
            //       maxLines: 1,
            //       overflow: TextOverflow.ellipsis,
            //     )),
            //     onTap: () {
            //       if (controller.currentLatLng.value != null) {
            //         bookingController.fromLocation.value =
            //             controller.currentAddress.value;
            //         bookingController.fromLatLng.value =
            //             controller.currentLatLng.value;
            //
            //         // Update map
            //         controller.setMarker(controller.currentLatLng.value!);
            //         controller.moveCameraTo(controller.currentLatLng.value!);
            //       }
            //       Navigator.pop(context);
            //     },
            //   ),
            // Current Location Button (only for pickup)
            if (isPickup)
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.pinkColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.my_location,
                    color: AppColors.pinkColor,
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
                onTap: () {
                  if (controller.currentLatLng.value != null) {
                    bookingController.fromLocation.value =
                        controller.currentAddress.value;
                    bookingController.fromLatLng.value =
                        controller.currentLatLng.value;

                    // Update map
                    controller.setMarker(controller.currentLatLng.value!);
                    controller.moveCameraTo(controller.currentLatLng.value!);

                    // ✅ ADD THIS DEBUG PRINT TO VERIFY
                    debugPrint("✅ From Location Set:");
                    debugPrint("Address: ${bookingController.fromLocation.value}");
                    debugPrint("LatLng: ${bookingController.fromLatLng.value}");
                  }
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
                        ['main_text'] ?? '',
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
                        final placeId = prediction['place_id'];
                        final description = prediction['description'] ?? '';

                        // Get place details
                        await _selectLocation(
                          placeId,
                          description,
                          isPickup,
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



  Future<void> _selectLocation(
      String placeId,
      String address,
      bool isPickup,
      ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyBxaqnRr_zdsjrqNvtMEXXbm8IO2lvzTRs',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final result = body['result'];
        final geometry = result['geometry']['location'];
        final position = LatLng(geometry['lat'], geometry['lng']);

        if (isPickup) {
          bookingController.fromLocation.value = address;
          bookingController.fromLatLng.value = position;

          // ✅ ADD DEBUG PRINT
          debugPrint("✅ Pickup Location Set:");
          debugPrint("Address: $address");
          debugPrint("LatLng: $position");
        } else {
          bookingController.dropOffLocation.value = address;
          bookingController.dropOffLatLng.value = position;

          // ✅ ADD DEBUG PRINT
          debugPrint("✅ Drop-off Location Set:");
          debugPrint("Address: $address");
          debugPrint("LatLng: $position");
        }

        // Update map marker and camera
        controller.setMarker(position);
        controller.moveCameraTo(position);
        controller.searchController.clear();
      }
    } catch (e) {
      debugPrint("Error fetching place details: $e");
      Get.snackbar("Error", "Failed to load location details");
    }
  }
}

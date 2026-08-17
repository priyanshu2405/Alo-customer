import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_call_helper.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/common/common_text_field.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/chat/view/chat_entry_button.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/controller/my_ride_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/view/ride_completed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideTrackingScreen extends StatefulWidget {
  final int bookingId;
  const RideTrackingScreen({super.key, required this.bookingId});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  final MyRideController myRideController = Get.put(MyRideController());
  // GoogleMapController? mapController;
  //
  // final Set<Marker> markers = {};
  // final Set<Polyline> polylines = {};


 /* GoogleMapController? mapController;

  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};

  final PolylinePoints polylinePoints = PolylinePoints(
    apiKey: "AIzaSyBxaqnRr_zdsjrqNvtMEXXbm8IO2lvzTRs",
  );

  final List<LatLng> routePoints = [];

  bool _routeDrawn = false;*/

  @override
  void initState() {
    super.initState();
    myRideController.loadDriverIcon();
    myRideController.getRideDetails(id: widget.bookingId);
  }

  @override
  void dispose() {
    // Dispose the map controller before the widget is disposed
    //mapController?.dispose();
  //  mapController = null;
    myRideController.stopDriverLocationAutoGet();
    myRideController.mapController = null;
    myRideController.mapController?.dispose();
    myRideController.polylines.clear();
   // myRideController.socketIoService.disconnect();
    myRideController.dropLatLng.value = null;
    myRideController.pickupLatLng.value = null;
    myRideController.ridePhase.value = RidePhase.toPickup;
    super.dispose();
  }

  // void _updateMap(LatLng pickup, LatLng drop) {
  //   markers.clear();
  //   polylines.clear();
  //
  //   markers.add(
  //     Marker(
  //       markerId: const MarkerId('pickup'),
  //       position: pickup,
  //       icon:
  //       BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
  //     ),
  //   );
  //
  //   markers.add(
  //     Marker(
  //       markerId: const MarkerId('drop'),
  //       position: drop,
  //       icon:
  //       BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //     ),
  //   );
  //
  //   polylines.add(
  //     Polyline(
  //       polylineId: const PolylineId('route'),
  //       points: [pickup, drop],
  //       color: Colors.blue,
  //       width: 5,
  //     ),
  //   );
  //
  //   try {
  //     mapController?.animateCamera(
  //       CameraUpdate.newLatLngZoom(pickup, 14),
  //     );
  //   } catch (e) {
  //     debugPrint('Error animating camera: $e');
  //   }
  // }


 /* Future<void> _drawRoute(LatLng pickup, LatLng drop) async {
    markers.clear();
    polylines.clear();
    routePoints.clear();

    /// MARKERS
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId('drop'),
        position: drop,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    /// DIRECTIONS API
    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(pickup.latitude, pickup.longitude),
        destination: PointLatLng(drop.latitude, drop.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isEmpty) {
      debugPrint("❌ No route points received");
      return;
    }

    for (final p in result.points) {
      routePoints.add(LatLng(p.latitude, p.longitude));
    }

    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: routePoints,
      ),
    );

    /// CAMERA FIT
    final bounds = LatLngBounds(
      southwest: LatLng(
        pickup.latitude < drop.latitude ? pickup.latitude : drop.latitude,
        pickup.longitude < drop.longitude ? pickup.longitude : drop.longitude,
      ),
      northeast: LatLng(
        pickup.latitude > drop.latitude ? pickup.latitude : drop.latitude,
        pickup.longitude > drop.longitude ? pickup.longitude : drop.longitude,
      ),
    );

    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );

    if (mounted) setState(() {});
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: AppAppBar(
        backgroundColor: Colors.transparent,
        // leading: Icon(Icons.menu),
        title: "",
        // actions: [
        //   ElevatedButton(onPressed: () async{
        //    // myRideController.socketIoService.getLocationStatus();
        //   }, child: Text("dvdvd"))
        // ],
      ),
      body: Obx(() {

        // final pickup = myRideController.pickupLatLng.value;
        // final drop = myRideController.dropLatLng.value;
        //
        // if (pickup == null || drop == null) {
        //   return Center(child: CircularProgressIndicator());
        // }
        // if (mounted) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     _updateMap(pickup, drop);
        //   });
        // }

        final pickup = myRideController.pickupLatLng.value;
        final drop = myRideController.dropLatLng.value;

        if (pickup == null || drop == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // if (!_routeDrawn) {
        //   _routeDrawn = true;
        //   _drawRoute(pickup, drop);
        // }
        final numberPlateUrl = myRideController
            .getRideDetailsModel
            .value
            .data
            ?.ride
            ?.driver
            ?.images
            ?.firstWhere(
              (e) => e.type == "number_plate_photo",
        ).url;

        return myRideController.isGetRideDetails.value
            ? Center(child: CircularProgressIndicator())
            : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        // initialCameraPosition: CameraPosition(
                        //   target: pickupLocation,
                        //   zoom: 14,
                        // ),
                        initialCameraPosition: CameraPosition(
                          target: pickup,
                          zoom: 16,
                        ),

                        onMapCreated: (controller) => myRideController.onMapCreated(controller),
                        markers: myRideController.markers.toSet(),
                        polylines: myRideController.polylines.toSet(),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                      ),
                      Positioned(
                        top: kToolbarHeight + 40,
                        left: 16,
                        right: 16,
                        child: Column(
                          children: [
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
                                  // From location
                                  Gap(10),
                                  _buildLocationRow(
                                    icon: Icons.circle,
                                    iconColor: AppColors.pinkColor,
                                    title: 'From',
                                    subtitle: '${myRideController.getRideDetailsModel.value.data?.ride?.pickupAddress}',
                                    showDivider: true,
                                  ),

                                  // Drop off location
                                  _buildLocationRow(
                                    icon: Icons.location_on,
                                    iconColor: AppColors.pinkColor,
                                    title: 'Drop off Location',
                                    subtitle: '${myRideController.getRideDetailsModel.value.data?.ride?.dropAddress}',
                                    showDivider: false,
                                  ),
                                  Gap(10),
                                ],
                              ),
                            ),
                          ],
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
                  ),
                ),
                Gap(20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Driver Info
                    if(myRideController.getRideDetailsModel.value.data?.ride?.driver != null)...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          Get.to(() => RideCompletedScreen(bookingId: widget.bookingId,));
                        },
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
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
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
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: "Driver: ${myRideController.getRideDetailsModel.value.data?.ride?.driver?.name}",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  Gap(1),
                                  if(myRideController.routeInfo.value != null)
                                  AppText(
                                    text: "${myRideController.routeInfo.value?.durationText} away!",
                                    fontSize: 12,
                                    color: AppColors.lightBlackColor,
                                  ),
                                  const Gap(12),

                                  /// Vehicle Info
                                  // Row(
                                  //   children: [
                                  //     Container(
                                  //       padding: EdgeInsets.symmetric(
                                  //         horizontal: 10.w,
                                  //         vertical: 4.h,
                                  //       ),
                                  //       decoration: BoxDecoration(
                                  //         borderRadius:
                                  //             BorderRadius.circular(6.r),
                                  //         border: Border.all(
                                  //           color: AppColors.greyColor,
                                  //         ),
                                  //       ),
                                  //       child: AppText(
                                  //         text: "${myRideController.getRideDetailsModel.value.data?.ride?.driver?.vehicleNumber}",
                                  //         fontSize: 12,
                                  //       ),
                                  //     ),
                                  //     Gap(10.w),
                                  //     AppText(
                                  //       text: "${myRideController.getRideDetailsModel.value.data?.ride?.driver?.vehicleNumber}",
                                  //       fontSize: 12,
                                  //       color: AppColors.lightBlackColor,
                                  //     ),
                                  //   ],
                                  // ),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: AppColors.greyColor,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: numberPlateUrl != null && numberPlateUrl.isNotEmpty
                                              ? Image.network(
                                            numberPlateUrl,
                                            height: 29,
                                            width: 57,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const SizedBox(
                                                height: 20,
                                                width: 40,
                                                child: Center(
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              );
                                            },
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.directions_car,
                                              size: 20,
                                              color: AppColors.greyColor,
                                            ),
                                          )
                                              : Icon(
                                            Icons.directions_car,
                                            size: 20,
                                            color: AppColors.greyColor,
                                          ),
                                        ),
                                      ),
                                      const Gap(10),

                                      AppText(
                                        text:
                                        "${myRideController.getRideDetailsModel.value.data?.ride?.driver?.vehicleNumber}",
                                        fontSize: 12,
                                        color: AppColors.lightBlackColor,
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                            if(myRideController.routeInfo.value != null)

                              AppText(
                              text: "${myRideController.routeInfo.value?.distanceText}",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.lightBlackColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Gap(17),
                    Divider(color: AppColors.darkTextColor),
                    const Gap(17),
                    ],

                    /// Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          /// 💬 Chat with the driver — renders nothing until a
                          /// driver accepts, so no room means no button.
                          ChatEntryButton(
                            rideId: myRideController
                                .getRideDetailsModel.value.data?.ride?.id,
                            rideStatus: myRideController
                                .getRideDetailsModel.value.data?.ride?.status,
                            driverName:
                                "${myRideController.getRideDetailsModel.value.data?.ride?.driver?.name ?? ''}",
                            driverMobile:
                                "${myRideController.getRideDetailsModel.value.data?.ride?.driver?.mobile ?? ''}",
                            driverPhoto:
                                "${myRideController.getRideDetailsModel.value.data?.ride?.driver?.profilePhoto ?? ''}",
                          ),
                          if (ChatAvailability.isOpen(
                            rideId: myRideController
                                .getRideDetailsModel.value.data?.ride?.id,
                            status: myRideController
                                .getRideDetailsModel.value.data?.ride?.status,
                          ))
                            const Gap(12),
                          if(myRideController.getRideDetailsModel.value.data?.ride?.status != "pending" && myRideController.getRideDetailsModel.value.data?.ride?.status != "completed")...[
                          Expanded(
                            child: AppButton(
                              text: "CALL DRIVER",
                              onTap: () => AppCallHelper.makeCall("${myRideController.getRideDetailsModel.value.data?.ride?.driver?.mobile}"),
                            ),
                          ),
                          const Gap(12),
                          ],
                          if(myRideController.rideStatus.value != "pickup_done" && myRideController.rideStatus.value != "completed")
                          Expanded(
                            child: AppButton(
                              text: "CANCEL RIDE",
                              onTap: () {
                                showCancelRideDialog(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(20),
                  ],
                ),
              ],
            );
      }),
    );
  }


  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // // Favorite icon
              // IconButton(
              //   icon: const Icon(Icons.favorite_border),
              //   color: Colors.grey[400],
              //   onPressed: () {},
              // ),
            ],
          ),
        ),
      ],
    );
  }

  void showCancelRideDialog(BuildContext context) {


    final double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          // ✅ Responsive horizontal padding
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06, // ~6% of screen width
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ❌ Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Cancel Ride",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// 📄 Description
                const Text(
                  "Please tell us why you are cancelling this ride.",
                  style: TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 16),

                /// ✏️ Reason Input
                CommonTextField(
                  controller: myRideController.reasonController,
                  hintText: "Enter cancellation reason",
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Reason is required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                /// 🔘 Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: "NO",
                        backgroundColor: Colors.grey.shade300,
                        textColor: Colors.black,
                        onTap: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        return AppButton(
                          isLoading: myRideController.isCancelRide.value,
                          text: "YES",
                          onTap: () {
                            if (myRideController.reasonController.text.trim().isEmpty) {
                              Get.snackbar(
                                "Error",
                                "Please enter a reason",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red.withOpacity(0.8),
                                colorText: Colors.white,
                              );
                              return;
                            }

                            debugPrint(
                              "Cancel reason: ${myRideController.reasonController.text}",
                            );
                            myRideController.cancelRide(id: widget.bookingId);
                          },
                        );
                      },),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}

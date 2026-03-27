import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_call_helper.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/booking/controller/booking_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/home/controller/location_controller.dart';
import 'package:alo_ride_app/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final int vehicleTypeId;
  final int selectedType;
  final String vehicleTypeName;

  const BookingScreen({
    super.key,
    required this.selectedType,
    required this.vehicleTypeId,
    required this.vehicleTypeName,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final LocationController controller = Get.put(LocationController());
  final BookingController bookingController = Get.put(BookingController());
  final LocationController locationController = Get.put(LocationController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bookingController.dropOffLocation.value = "";
      bookingController.isShowButton.value = false;
      if (controller.currentLatLng.value != null &&
          bookingController.fromLatLng.value == null) {
        bookingController.fromLatLng.value = controller.currentLatLng.value;
        bookingController.fromLocation.value = controller.currentAddress.value;
        bookingController.selectedDate.value = DateTime.now();
        bookingController.selectedTime.value = DateTime.now();
      }
    });
  }

  @override
  void dispose() {
    bookingController.fromLatLng.value = null;
    bookingController.dropOffLatLng.value = null;
    bookingController.fromLocation.value = "";
    bookingController.dropOffLocation.value = "";
    bookingController.selectedDate.value = DateTime.now();
    bookingController.selectedTime.value = DateTime.now();
    bookingController.isShowButton.value = false;
    super.dispose();
  }

  RxBool isAirportPickup = false.obs;
  TextEditingController flightNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ Dynamic resizing when keyboard opens
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: AppAppBar(
        backgroundColor: Colors.transparent,
        title: "",
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value || bookingController.isEstimateFare.value) {
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
                      if (controller.currentLatLng.value != null) {
                        mapController.animateCamera(
                          CameraUpdate.newLatLng(controller.currentLatLng.value!),
                        );
                      }
                    },
                    markers: controller.markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
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
                  
                  // ✅ Dynamic Form Overlay – centered on tablets/iPads
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: _buildFormContent(),
                      ),
                    ),
                  ),

                  // SOS Button
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

          // Bottom Summary – centered on tablets/iPads
          if (!isKeyboardOpen)
            _buildBottomSummary(context),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(10),
          Obx(() {
            final date = bookingController.selectedDate.value ?? DateTime.now();
            final time = bookingController.selectedTime.value ?? DateTime.now();
            return AppText(
              text: "Ride on ${DateFormat("dd MMM yyyy").format(date)} at ${DateFormat("hh:mm a").format(time)}",
              fontSize: 16,
              fontWeight: FontWeight.w500,
            );
          }),
          const Gap(8),
          Divider(color: AppColors.darkTextColor),
          const Gap(8),
          Obx(() => AppText(
                text: "Fare estimate : \$${bookingController.totalFare?.value}",
                fontSize: 12,
                color: AppColors.lightBlackColor,
              )),
          const Gap(8),
          Obx(() => AppText(
                text: "Distance : ${bookingController.distanceKm.value.toStringAsFixed(2)} km",
                fontSize: 13,
                color: AppColors.lightBlackColor,
              )),
          const Gap(8),
          Divider(color: AppColors.darkTextColor),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Note: ",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightBlackColor,
                    ),
                  ),
                  const TextSpan(
                    text: "This is an approximate estimate. Actual cost may be different due to traffic and waiting time.",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.lightBlackColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(20),
          Obx(() {
            return bookingController.isShowButton.value == true
                ? AppButton(
                    isLoading: bookingController.isBookRide.value,
                    text: "Book Now",
                    onTap: () async {
                      if (isAirportPickup.value == true) {
                        if (formKey.currentState!.validate()) {
                          await bookingController.bookApi(
                            context,
                            vehicleTypeId: widget.vehicleTypeId,
                            type: widget.selectedType,
                            flightNumber: flightNumberController.text.trim(),
                            isAirportPickup: isAirportPickup.value,
                          );
                        }
                      } else {
                        await bookingController.bookApi(
                          context,
                          vehicleTypeId: widget.vehicleTypeId,
                          type: widget.selectedType,
                          flightNumber: flightNumberController.text.trim(),
                          isAirportPickup: isAirportPickup.value,
                        );
                      }
                    },
                  )
                : const SizedBox.shrink();
          }),
          Gap(MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Pickup & Drop Cards
          _buildCard(
            child: Column(
              children: [
                Gap(10),
                _buildLocationRow(
                  icon: Icons.circle,
                  iconColor: AppColors.pinkColor,
                  title: 'From',
                  subtitle: bookingController.fromLocation.value.isEmpty
                      ? controller.currentAddress.value
                      : bookingController.fromLocation.value,
                  showDivider: true,
                  onTap: () => _showLocationSearchSheet(context, isPickup: true),
                ),
                _buildLocationRow(
                  icon: Icons.location_on,
                  iconColor: AppColors.pinkColor,
                  title: 'Drop off Location',
                  subtitle: bookingController.dropOffLocation.value.isEmpty
                      ? 'Select drop off location'
                      : bookingController.dropOffLocation.value,
                  showDivider: false,
                  onTap: () => _showLocationSearchSheet(context, isPickup: false),
                ),
                Gap(10),
              ],
            ),
          ),
          Gap(10),
          
          // Ride Later Card
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(12),
                  Row(
                    children: [
                      _radioOption("Pickup & Drop", 0),
                      const Gap(20),
                    ],
                  ),
                  const Gap(14),
                  AppText(text: "Ride Later", fontSize: 16, fontWeight: FontWeight.w500),
                  const Gap(8),
                  Row(
                    children: [
                      _dateTimeBox(type: "date", icon: Icons.calendar_month, title: "Select Date"),
                      const Gap(12),
                      _dateTimeBox(type: "time", icon: Icons.access_time, title: "Select Time"),
                    ],
                  ),
                  const Gap(15),
                ],
              ),
            ),
          ),
          Gap(10),

          // Airport Pickup Card
          Obx(() {
            return _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isAirportPickup.value,
                        activeColor: AppColors.secondary,
                        onChanged: (value) => isAirportPickup.value = value ?? false,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Booking for airport pickup ?",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  if (isAirportPickup.value)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: flightNumberController,
                        validator: (value) => (value == null || value.isEmpty) ? 'Please enter a flight number' : null,
                        decoration: InputDecoration(
                          hintText: "Flight number",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const Gap(100), // Extra space to scroll past the SOS button
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.lightGray, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _radioOption(String text, int value) {
    return Obx(() {
      final isSelected = bookingController.selectValue.value == value;
      return InkWell(
        onTap: () => bookingController.selectValue.value = value,
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.black),
            const Gap(6),
            AppText(text: text, fontSize: 12),
          ],
        ),
      );
    });
  }

  Widget _dateTimeBox({required String type, required String title, required IconData icon}) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          if (type == "date") {
            await bookingController.pickDate(context);
          } else {
            await bookingController.pickTime(context);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(text: title, fontSize: 12, color: AppColors.textColor, fontWeight: FontWeight.w500),
            Gap(7),
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      final text = type == "date"
                          ? (bookingController.formattedDate ?? "Select Date")
                          : (bookingController.formattedTime ?? "Select Time");
                      return AppText(text: text, fontSize: 12, color: AppColors.greyColor);
                    }),
                  ),
                  Icon(icon, color: AppColors.secondary),
                ],
              ),
            ),
          ],
        ),
      ),
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
                Column(
                  children: [
                    Icon(icon, color: iconColor, size: 20),
                    if (showDivider)
                      Column(
                        children: List.generate(10, (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Container(
                            height: 2,
                            width: 2,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.black),
                          ),
                        )),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: subtitle.contains('Select') ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLocationSearchSheet(BuildContext context, {required bool isPickup}) {
    controller.searchController.clear();
    controller.predictions.clear();
    controller.showPredictions.value = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const Gap(16),
                  Row(
                    children: [
                      Icon(isPickup ? Icons.circle : Icons.location_on, color: AppColors.pinkColor, size: 20),
                      const Gap(8),
                      AppText(text: isPickup ? "Select Pickup Location" : "Select Drop-off Location", fontSize: 16, fontWeight: FontWeight.w600),
                    ],
                  ),
                  const Gap(12),
                  TextField(
                    controller: controller.searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => controller.clearSearch()),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.lightGray)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.pinkColor, width: 2)),
                    ),
                    onChanged: (value) => controller.getPlaces(value),
                  ),
                ],
              ),
            ),
            if (isPickup)
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.pinkColor.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.my_location, color: AppColors.pinkColor, size: 20)),
                title: const AppText(text: "Use Current Location", fontSize: 15, fontWeight: FontWeight.w500),
                subtitle: Obx(() => AppText(text: controller.currentAddress.value, fontSize: 12, color: AppColors.greyColor, maxLines: 1, overflow: TextOverflow.ellipsis)),
                onTap: () {
                  if (controller.currentLatLng.value != null) {
                    bookingController.fromLocation.value = controller.currentAddress.value;
                    bookingController.fromLatLng.value = controller.currentLatLng.value;
                    controller.setMarker(controller.currentLatLng.value!);
                    controller.moveCameraTo(controller.currentLatLng.value!);
                  }
                  Navigator.pop(context);
                },
              ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                if (!controller.showPredictions.value || controller.predictions.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.location_on_outlined, size: 64, color: Colors.grey), const Gap(16), const AppText(text: "Search for a location", fontSize: 16, color: AppColors.greyColor)]));
                }
                return ListView.separated(
                  itemCount: controller.predictions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final prediction = controller.predictions[index];
                    return ListTile(
                      leading: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle), child: const Icon(Icons.location_on, color: Colors.grey, size: 20)),
                      title: AppText(text: prediction['structured_formatting']['main_text'] ?? '', fontSize: 15, fontWeight: FontWeight.w500, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: AppText(text: prediction['description'] ?? '', fontSize: 12, color: AppColors.greyColor, maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () async {
                        await _selectLocation(prediction['place_id'], prediction['description'] ?? '', isPickup);
                        Navigator.pop(context);
                        bookingController.estimateFare(vehicleTypeId: widget.vehicleTypeId, type: widget.selectedType);
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

  Future<void> _selectLocation(String placeId, String address, bool isPickup) async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyBxaqnRr_zdsjrqNvtMEXXbm8IO2lvzTRs');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final geometry = body['result']['geometry']['location'];
        final position = LatLng(geometry['lat'], geometry['lng']);
        if (isPickup) {
          bookingController.fromLocation.value = address;
          bookingController.fromLatLng.value = position;
        } else {
          bookingController.dropOffLocation.value = address;
          bookingController.dropOffLatLng.value = position;
        }
        controller.setMarker(position);
        controller.moveCameraTo(position);
      }
    } catch (e) {
      debugPrint("Error fetching place details: $e");
    }
  }
}

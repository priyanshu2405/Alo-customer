import 'dart:async';

import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_call_helper.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/view/ride_tracking_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/controller/my_ride_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_app/api_app_folder/screen/ride/view/ride_completed_screen.dart';
import 'package:alo_ride_app/api_app_folder/services/receipt_service.dart';
import 'package:alo_ride_app/core/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// class MyRidesScreen extends StatefulWidget {
//   const MyRidesScreen({super.key});
//
//   @override
//   State<MyRidesScreen> createState() => _MyRidesScreenState();
// }
//
// class _MyRidesScreenState extends State<MyRidesScreen> {
//   final MyRideController myRideController = Get.put(MyRideController());
//   DateTime selectedDate = DateTime.now();
//
//   void _validateTimeForToday() {
//     DateTime now = DateTime.now();
//
//     bool isToday =
//         selectedDate.year == now.year &&
//         selectedDate.month == now.month &&
//         selectedDate.day == now.day;
//
//     if (!isToday) return;
//   }
//   Timer? _refreshTimer;
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       myRideController.getRideHistory();
//       // _startAutoRefresh();
//     });
//
//   }
//
//   Future<void> _onRefresh() async {
//     await myRideController.getRideHistory();
//   }
//   void _startAutoRefresh() {
//     _refreshTimer?.cancel(); // safety
//
//     _refreshTimer = Timer.periodic(
//       const Duration(seconds: 5),
//           (timer) {
//         if (!mounted) return;
//
//         myRideController.getRideHistory();
//       },
//     );
//   }
//
//
//   // @override
//   // void dispose() {
//   //   myRideController.selectedTab.value = 0;
//   //   super.dispose();
//   // }
//
//   @override
//   void dispose() {
//     _refreshTimer?.cancel();   // ✅ stop API calls
//     myRideController.selectedTab.value = 0;
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppAppBar(
//         backgroundColor: Colors.transparent,
//         leading: Icon(Icons.menu),
//         title: "My Rides",
//       ),
//       body: Obx(() {
//         return myRideController.isRideHistory.value
//             ? Center(child: CircularProgressIndicator())
//             : Column(
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     height: 2,
//                     color: AppColors.darkTextColor,
//                   ),
//                   // Gap(10),
//                   Container(
//                     color: Color(0xffEDEDED),
//                     child: Row(
//                       children: [
//                         _tab("List View", 0),
//                         _tab("Calendar View", 1),
//                       ],
//                     ),
//                   ),
//                   Obx(() {
//                     return Expanded(
//                       child: RefreshIndicator(
//                         color:AppColors.secondary,
//                         onRefresh: _onRefresh,
//                         child: myRideController.selectedTab.value == 0
//                             ? SingleChildScrollView(child: _listView())
//                             : _calendarView(),
//                       ),
//                     );
//                   }),
//                 ],
//               );
//       }),
//       floatingActionButton: InkWell(
//         onTap: () => AppCallHelper.callSOS(),
//         child: AppImage(
//           height: 55,
//           width: 55,
//           image: AppImages.sosButton,
//           imageType: ImageType.asset,
//         ),
//       ),
//     );
//   }
//
//   Widget _tab(String title, int index) {
//     return Obx(() {
//       final bool selected = myRideController.selectedTab.value == index;
//       return Expanded(
//         child: InkWell(
//           onTap:myRideController.selectedTab.value == index? null : () {
//             myRideController.startDate = null;
//             //myRideController.endDate = null;
//             setState(() => myRideController.selectedTab.value = index);
//             if(index == 1) {
//               myRideController.startDate = selectedDate.yyyymmdd;
//             }
//             myRideController.getRideHistory();
//           },
//
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 child: AppText(
//                   text: title,
//                   color: selected
//                       ? AppColors.secondary
//                       : AppColors.lightGrayText,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Container(
//                 height: 2,
//                 color: selected ? AppColors.secondary : Colors.transparent,
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _listView() {
//     return Obx(() {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// ====== PENDING ======
//           if (myRideController.pendingRides.isNotEmpty) ...[
//             Gap(20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: AppText(
//                 text: "Upcoming",
//                 color: AppColors.secondary,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Gap(10),
//             Column(
//               children: myRideController.pendingRides.map((ride) {
//                 return InkWell(
//                   onTap: () {
//                     /*       if (ride.status == 'pending') {
//                       // ❌ Do not navigate
//                       Get.snackbar(
//                         'Ride Pending',
//                         'Tracking is available once the driver accepts the ride.',
//                         snackPosition: SnackPosition.TOP,
//                         backgroundColor: AppColors.secondary.withOpacity(0.8),
//                         colorText: Colors.white,
//                         margin: const EdgeInsets.all(12),
//                       );
//                     } else {*/
//                     // ✅ Navigate
//                     Get.to(
//                       () => RideTrackingScreen(
//                         bookingId: ride.id ?? 0, // optional
//                       ),
//                     );
//                     /* }*/
//                   },
//
//                   child: _rideCard(
//                     // status: "pending",
//                     status: myRideController.getStatusText(ride.status),
//                     statusColor: AppColors.secondary,
//                     pickup: ride.pickupAddress ?? '',
//                     drop: ride.dropAddress ?? '',
//                     bookingId: ride.bookingId ?? '',
//                     // date: ride.pickupDatetime?.toString() ?? '',
//                     date: formatDateRange(
//                       start: ride.pickupDatetime?.toString(),
//                       end: ride.completedAt
//                           ?.toString(), // or dropDatetime if API gives
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//
//           /// ====== COMPLETED ======
//           if (myRideController.completedRides.isNotEmpty) ...[
//             Gap(20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: AppText(
//                 text: "Completed",
//                 color: AppColors.secondary,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Gap(10),
//             Column(
//               children: myRideController.completedRides.map((ride) {
//                 return InkWell(
//                   onTap: () {
//                     if(ride.payment?.status == "pending"){
//                       Get.to(
//                             () => RideTrackingScreen(
//                           bookingId: ride.id ?? 0, // optional
//                         ),
//                       );
//                     }else{
//                       Get.to(() => RideCompletedScreen(bookingId: ride.id ?? 0,isShowDialog: false,));
//                     }
//                   },
//                   // onTap: () => Get.to(() => RideCompletedScreen(bookingId: ride.id ?? 0,isShowDialog: false,),
//                   // ),
//                   child: _rideCard(
//                     status: "completed",
//                     statusColor: AppColors.greenColor,
//                     price: "\$${ride.totalFare}",
//                     pickup: ride.pickupAddress ?? '',
//                     drop: ride.dropAddress ?? '',
//                     bookingId: ride.bookingId ?? '',
//                     // date: ride.pickupDatetime?.toString() ?? '',
//                     date: formatDateRange(
//                       start: ride.pickupDatetime?.toString(),
//                       end: ride.completedAt
//                           ?.toString(), // or dropDatetime if API gives
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//
//           /// ====== CANCELLED ======
//           if (myRideController.cancelRides.isNotEmpty) ...[
//             Gap(20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: AppText(
//                 text: "Cancelled",
//                 color: AppColors.secondary,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Gap(10),
//             Column(
//               children: myRideController.cancelRides.map((ride) {
//                 return InkWell(
//                   onTap: () {
//                     /*       if (ride.status == 'pending') {
//                       // ❌ Do not navigate
//                       Get.snackbar(
//                         'Ride Pending',
//                         'Tracking is available once the driver accepts the ride.',
//                         snackPosition: SnackPosition.TOP,
//                         backgroundColor: AppColors.secondary.withOpacity(0.8),
//                         colorText: Colors.white,
//                         margin: const EdgeInsets.all(12),
//                       );
//                     } else {*/
//                     // ✅ Navigate
//                     Get.to(() => RideCompletedScreen(bookingId: ride.id ?? 0,isShowDialog: false,));
//                     /* }*/
//                   },
//
//                   child: _rideCard(
//                     // status: "pending",
//                     status: "Cancelled",
//                     statusColor: AppColors.secondary,
//                     pickup: ride.pickupAddress ?? '',
//                     drop: ride.dropAddress ?? '',
//                     bookingId: ride.bookingId ?? '',
//                     // date: ride.pickupDatetime?.toString() ?? '',
//                     date: formatDateRange(
//                       start: ride.pickupDatetime?.toString(),
//                       end: ride.completedAt
//                           ?.toString(), // or dropDatetime if API gives
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//           /// ====== EMPTY STATE ======
//           if (myRideController.pendingRides.isEmpty &&
//               myRideController.completedRides.isEmpty)
//             Padding(
//               padding: const EdgeInsets.all(40),
//               child: Center(
//                 child: AppText(
//                   text: "No rides found",
//                   color: AppColors.lightGrayText,
//                 ),
//               ),
//             ),
//         ],
//       );
//     });
//   }
//
//   /// ================= CALENDAR VIEW =================
//   Widget _calendarView() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           _calendarWidget(),
//           _listView(),
//          // _calendarViewRideCard(status: "Pending", statusColor: AppColors.secondary),
//         ],
//       ),
//     );
//   }
//
//   Widget _calendarWidget() {
//     return CalendarDatePicker(
//       initialDate: selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       onDateChanged: (value) {
//         if(selectedDate == value) return;
//         setState(() {
//           // print("value: $value");
//           selectedDate = value;
//           myRideController.startDate = value.yyyymmdd;
//          // myRideController.endDate = value.yyyymmdd;
//           myRideController.getRideHistory();
//           _validateTimeForToday();
//         });
//       },
//     );
//   }
//
//   /// ================= RIDE CARD =================
//   // Widget _rideCard({
//   //   required String status,
//   //   required Color statusColor,
//   //   String? price,
//   // }) {
//   //   return Column(
//   //     children: [
//   //       Padding(
//   //         padding: EdgeInsets.symmetric(horizontal: 16.h),
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Row(
//   //               children: [
//   //                 Expanded(
//   //                   child: AppText(
//   //                     text: "Booking ID: 23356",
//   //                     fontWeight: FontWeight.w600,
//   //                   ),
//   //                 ),
//   //                 if (price != null)
//   //                   AppText(text: price, fontWeight: FontWeight.bold),
//   //                 Gap(6.w),
//   //                 status == "Pending"
//   //                     ? AppText(
//   //                         text: status,
//   //                         color: statusColor,
//   //                         fontSize: 12,
//   //                         fontWeight: FontWeight.w500,
//   //                       )
//   //                     : SizedBox(),
//   //               ],
//   //             ),
//   //             Gap(6.h),
//   //             Row(
//   //               children: [
//   //                 Expanded(
//   //                   child: AppText(
//   //                     text: status == "Pending"
//   //                         ? "Date: 11/12/2025 10.30 AM to Date: 25/12/2025 09.00 AM"
//   //                         : "Date: 06/02/2025 10.30 AM",
//   //                     fontSize: 12,
//   //                     fontWeight: FontWeight.w500,
//   //                   ),
//   //                 ),
//   //                 status == "Pending"
//   //                     ? SizedBox()
//   //                     : AppText(
//   //                         text: status,
//   //                         color: statusColor,
//   //                         fontSize: 12,
//   //                         fontWeight: FontWeight.w500,
//   //                       ),
//   //               ],
//   //             ),
//   //             Gap(8.h),
//   //             _buildLocationRow(
//   //               icon: AppImage(
//   //                 height: 20.h,
//   //                 width: 20.w,
//   //                 image: AppImages.recordCircleFill,
//   //                 imageType: ImageType.svgAsset,
//   //               ),
//   //               iconColor: AppColors.pinkColor,
//   //               title: '241-205 Barrieau Rd, Moncton.',
//   //               showDivider: true,
//   //             ),
//   //             _buildLocationRow(
//   //               icon: Icon(
//   //                 Icons.location_on,
//   //                 color: AppColors.pinkColor,
//   //                 size: 20,
//   //               ),
//   //               iconColor: AppColors.pinkColor,
//   //               title: '100 Holland Dr, Moncton, NB E1...',
//   //               showDivider: false,
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //       Gap(20),
//   //       Container(
//   //         width: double.infinity,
//   //         height: 2,
//   //         color: AppColors.darkTextColor,
//   //       ),
//   //       Gap(20),
//   //     ],
//   //   );
//   // }
//
//   Widget _rideCard({
//     required String status,
//     required Color statusColor,
//     required String pickup,
//     required String drop,
//     required String date,
//     required String bookingId,
//     String? price,
//   }) {
//     return Column(
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: AppText(
//                       text: "Booking ID: $bookingId",
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//
//                   const Gap(6),
//                   Column(
//                     children: [
//                       if (price != null)
//                         AppText(text: price, fontWeight: FontWeight.bold),
//                       AppText(
//                         text: status,
//                         color: statusColor,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       const Gap(6),
//                     ],
//                   ),
//                 ],
//               ),
//               const Gap(6),
//               AppText(text: date, fontSize: 12, fontWeight: FontWeight.w500),
//               const Gap(8),
//               _buildLocationRow(
//                 icon: AppImage(
//                   height: 20.h,
//                   width: 20.w,
//                   image: AppImages.recordCircleFill,
//                   imageType: ImageType.svgAsset,
//                 ),
//                 iconColor: AppColors.pinkColor,
//                 title: pickup,
//                 showDivider: true,
//               ),
//               _buildLocationRow(
//                 icon: Icon(
//                   Icons.location_on,
//                   color: AppColors.pinkColor,
//                   size: 20,
//                 ),
//                 iconColor: AppColors.pinkColor,
//                 title: drop,
//                 showDivider: false,
//               ),
//             ],
//           ),
//         ),
//         Gap(20),
//         Divider(thickness: 1),
//         Gap(15),
//       ],
//     );
//   }
//
//   Widget _calendarViewRideCard({
//     required String status,
//     required Color statusColor,
//     String? price,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: AppText(
//                   text: "Booking ID: 23356",
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               if (price != null)
//                 AppText(text: price, fontWeight: FontWeight.bold),
//               Gap(6.w),
//               status == "Pending"
//                   ? AppText(
//                       text: status,
//                       color: statusColor,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     )
//                   : SizedBox(),
//             ],
//           ),
//           Gap(6.h),
//           Row(
//             children: [
//               Expanded(
//                 child: AppText(
//                   text: status == "Pending"
//                       ? "Date: 11/12/2025 10.30 AM to Date: 25/12/2025 09.00 AM"
//                       : "Date: 06/02/2025 10.30 AM",
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               status == "Pending"
//                   ? SizedBox()
//                   : AppText(
//                       text: status,
//                       color: statusColor,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//             ],
//           ),
//           Gap(8.h),
//           _buildLocationRow(
//             icon: AppImage(
//               height: 20.h,
//               width: 20.w,
//               image: AppImages.recordCircleFill,
//               imageType: ImageType.svgAsset,
//             ),
//             iconColor: AppColors.pinkColor,
//             title: '241-205 Barrieau Rd, Moncton.',
//             showDivider: true,
//           ),
//           _buildLocationRow(
//             icon: Icon(Icons.location_on, color: AppColors.pinkColor, size: 20),
//             iconColor: AppColors.pinkColor,
//             title: '100 Holland Dr, Moncton, NB E1...',
//             showDivider: false,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLocationRow({
//     required Widget icon,
//     required Color iconColor,
//     required String title,
//     required bool showDivider,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Icon with connecting line
//             Column(
//               children: [
//                 // Icon(icon, color: iconColor, size: 20),
//                 icon,
//                 if (showDivider)
//                   Column(
//                     children: List.generate(4, (index) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 2.0),
//                         child: Container(
//                           height: 2,
//                           width: 2,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: AppColors.black,
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//               ],
//             ),
//
//             const SizedBox(width: 12),
//
//             // Text content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [AppText(text: title, color: AppColors.textColor)],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   String formatDateTime(String? dateTime) {
//     if (dateTime == null || dateTime.isEmpty) return '';
//
//     final dt = DateTime.parse(dateTime).toLocal();
//
//     return DateFormat('dd/MM/yyyy hh.mm a').format(dt);
//   }
//
//   String formatDateRange({required String? start, required String? end}) {
//     // ❌ No start date → show nothing
//     if (start == null || start.isEmpty) return '';
//
//     // ✅ Both start & end → show range
//     if (end != null && end.isNotEmpty) {
//       return 'Date: ${formatDateTime(start)} to Date: ${formatDateTime(end)}';
//     }
//
//     // ✅ Only start → show single date
//     return 'Date: ${formatDateTime(start)}';
//   }
// }






class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> with WidgetsBindingObserver {
  final MyRideController myRideController = Get.put(MyRideController());
  DateTime selectedDate = DateTime.now();
  Timer? _refreshTimer;

  void _validateTimeForToday() {
    DateTime now = DateTime.now();

    bool isToday =
        selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day;

    if (!isToday) return;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      myRideController.getRideHistory();
      //_startAutoRefresh();
    });

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _stopAutoRefresh();
    } else if (state == AppLifecycleState.resumed) {
      // Only restart if we're still the active route
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        _startAutoRefresh();
      }
    }
  }

  Future<void> _onRefresh() async {
    await myRideController.getRideHistory();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
          (timer) {
        // Check if screen is still the current route
        final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;

        if (!mounted || !isCurrent) {
          debugPrint('🚫 MyRidesScreen: Not current route, skipping refresh');
          return;
        }

        debugPrint('🔄 MyRidesScreen: Auto-refreshing...');
        myRideController.getRideHistory(showLoader: false);
      },
    );

    debugPrint('✅ MyRidesScreen: Auto-refresh timer started');
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;

    // ✅ Disconnect socket when stopping auto-refresh
    //myRideController.socketIoService.disconnect();

    debugPrint('🚫 MyRidesScreen: Auto-refresh stopped & socket disconnected');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAutoRefresh();
    myRideController.selectedTab.value = 0;
    super.dispose();
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
        title: "My Rides",
      ),
      body: Obx(() {
        return myRideController.isRideHistory.value
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Container(
              width: double.infinity,
              height: 2,
              color: AppColors.darkTextColor,
            ),
            Container(
              color: Color(0xffEDEDED),
              child: Row(
                children: [
                  _tab("List View", 0),
                  _tab("Calendar View", 1),
                ],
              ),
            ),
            Obx(() {
              return Expanded(
                child: RefreshIndicator(
                  color: AppColors.secondary,
                  onRefresh: _onRefresh,
                  child: myRideController.selectedTab.value == 0
                      ? SingleChildScrollView(child: _listView())
                      : _calendarView(),
                ),
              );
            }),
          ],
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
    );
  }

  Widget _tab(String title, int index) {
    return Obx(() {
      final bool selected = myRideController.selectedTab.value == index;
      return Expanded(
        child: InkWell(
          onTap: myRideController.selectedTab.value == index
              ? null
              : () {
            myRideController.startDate = null;
            setState(() => myRideController.selectedTab.value = index);
            if (index == 1) {
              myRideController.startDate = selectedDate.yyyymmdd;
            }
            myRideController.getRideHistory();
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: AppText(
                  text: title,
                  color: selected
                      ? AppColors.secondary
                      : AppColors.lightGrayText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                height: 2,
                color: selected ? AppColors.secondary : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _listView() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ====== PENDING ======
          if (myRideController.pendingRides.isNotEmpty) ...[
            Gap(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: AppText(
                  text: "Upcoming Rides",
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Gap(10),
            Divider(
              color: AppColors.secondary,
thickness: 2,
            ),
            Gap(10),
            Column(
              children: myRideController.pendingRides.map((ride) {
                return InkWell(
                  onTap: () {
                    Get.to(
                          () => RideTrackingScreen(
                        bookingId: ride.id ?? 0,
                      ),
                    );
                  },
                  child: _rideCard(
                    status: myRideController.getStatusText(ride.status),
                    statusColor: AppColors.secondary,
                    pickup: ride.pickupAddress ?? '',
                    drop: ride.dropAddress ?? '',
                    stops: ride.stops,
                    bookingId: ride.bookingId ?? '',
                    date: formatDateRange(
                      start: ride.pickupDatetime?.toString(),
                      end: ride.completedAt?.toString(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          /// ====== COMPLETED ======
          if (myRideController.completedRides.isNotEmpty) ...[
            Gap(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: AppText(
                  text: "Completed Rides",
                  color: AppColors.secondary,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Gap(10),
            Divider(
              color: AppColors.secondary,
              thickness: 2,
            ),
            Gap(10),
            Column(
              children: myRideController.completedRides.map((ride) {
                //print(ride.payment?.status);
                return InkWell(
                  onTap: () {

                    Get.to(() => RideCompletedScreen(
                      bookingId: ride.id ?? 0,
                      isShowDialog: ride.payment?.status == "pending" ? true : false,
                    ));
                    /*if (ride.payment?.status == "pending") {
                      Get.to(
                            () => RideTrackingScreen(
                          bookingId: ride.id ?? 0,
                        ),
                      );
                    } else {
                      Get.to(() => RideCompletedScreen(
                        bookingId: ride.id ?? 0,
                        isShowDialog: false,
                      ));
                    }*/
                  },
                  child: _rideCard(
                    status: "completed",
                    statusColor: AppColors.greenColor,
                    // Only paid rides have a charge to email a receipt for.
                    receiptPaymentIntentId: ride.payment?.status == "pending"
                        ? null
                        : ride.payment?.stripePaymentIntentId?.toString(),
                    price: ride.payment?.status == "pending" ? "Payment Pending" : "\$${ride.totalFare}",
                    pickup: ride.pickupAddress ?? '',
                    drop: ride.dropAddress ?? '',
                    stops: ride.stops,
                    bookingId: ride.bookingId ?? '',
                    date: formatDateRange(
                      start: ride.pickupDatetime?.toString(),
                      end: ride.completedAt?.toString(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          /// ====== CANCELLED ======
          if (myRideController.cancelRides.isNotEmpty) ...[
            Gap(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: AppText(
                  text: "Cancelled Rides",
                  color: AppColors.secondary,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Gap(10),
            Divider(
              color: AppColors.secondary,
              thickness: 2,
            ),
            Gap(10),
            Column(
              children: myRideController.cancelRides.map((ride) {
                return InkWell(
                  onTap: () {
                    Get.to(() => RideCompletedScreen(
                      bookingId: ride.id ?? 0,
                      isShowDialog: false,
                    ));
                  },
                  child: _rideCard(
                    status: "Cancelled",
                    statusColor: AppColors.secondary,
                    pickup: ride.pickupAddress ?? '',
                    drop: ride.dropAddress ?? '',
                    stops: ride.stops,
                    bookingId: ride.bookingId ?? '',
                    date: formatDateRange(
                      start: ride.pickupDatetime?.toString(),
                      end: ride.completedAt?.toString(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          /// ====== EMPTY STATE ======
          if (myRideController.pendingRides.isEmpty &&
              myRideController.completedRides.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: AppText(
                  text: "No rides found",
                  color: AppColors.lightGrayText,
                ),
              ),
            ),
        ],
      );
    });
  }

  /// ================= CALENDAR VIEW =================
  Widget _calendarView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _calendarWidget(),
          _listView(),
        ],
      ),
    );
  }

  Widget _calendarWidget() {
    return CalendarDatePicker(
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      onDateChanged: (value) {
        if (selectedDate == value) return;
        setState(() {
          selectedDate = value;
          myRideController.startDate = value.yyyymmdd;
         // myRideController.endDate = value.yyyymmdd;
          myRideController.endDate = "";
          myRideController.getRideHistory();
          _validateTimeForToday();
        });
      },
    );
  }

  /// ================= RIDE CARD =================
  Widget _rideCard({
    required String status,
    required Color statusColor,
    required String pickup,
    required String drop,
    required String date,
    required String bookingId,
    String? price,
    List<Stop>? stops,
    /// When set, the card shows a "Resend receipt" action that calls
    /// `payment/send-receipt` for this charge.
    String? receiptPaymentIntentId,
  }) {
    // Prefer the full stops list (multiple drop-offs). Fall back to the single
    // drop_address when the ride has no stops array.
    final List<Stop> rideStops = stops ?? [];
    final List<String> dropAddresses = rideStops.isNotEmpty
        ? rideStops.map((s) => s.address ?? '').where((a) => a.isNotEmpty).toList()
        : [drop];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppText(
                      text: "Booking ID: $bookingId",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(6),
                  Column(
                    children: [
                      if (price != null)
                        AppText(text: price, fontWeight: FontWeight.bold),
                      AppText(
                        text: status,
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      const Gap(6),
                    ],
                  ),
                ],
              ),
              const Gap(6),
              AppText(text: date, fontSize: 12, fontWeight: FontWeight.w500),
              const Gap(8),
              _buildLocationRow(
                icon: AppImage(
                  height: 20,
                  width: 20,
                  image: AppImages.recordCircleFill,
                  imageType: ImageType.svgAsset,
                ),
                iconColor: AppColors.pinkColor,
                title: pickup,
                showDivider: true,
              ),
              // One row per drop-off (supports multiple stops).
              ...List.generate(dropAddresses.length, (index) {
                final isLast = index == dropAddresses.length - 1;
                return _buildLocationRow(
                  icon: Icon(
                    Icons.location_on,
                    color: AppColors.pinkColor,
                    size: 20,
                  ),
                  iconColor: AppColors.pinkColor,
                  title: dropAddresses[index],
                  showDivider: !isLast,
                );
              }),
              if (receiptPaymentIntentId != null &&
                  receiptPaymentIntentId.isNotEmpty) ...[
                const Gap(4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => ReceiptService.promptAndSendReceipt(
                      paymentIntentId: receiptPaymentIntentId,
                      title: 'Resend receipt',
                    ),
                    icon: const Icon(
                      Icons.receipt_long_outlined,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    label: const AppText(
                      text: 'Resend receipt',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Gap(20),
        Divider(thickness: 1),
        Gap(15),
      ],
    );
  }

  Widget _buildLocationRow({
    required Widget icon,
    required Color iconColor,
    required String title,
    required bool showDivider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                icon,
                if (showDivider)
                  Column(
                    children: List.generate(5, (index) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [AppText(text: title, color: AppColors.textColor)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '';
    final dt = DateTime.parse(dateTime).toLocal();
    return DateFormat('dd/MM/yyyy hh.mm a').format(dt);
  }

  String formatDateRange({required String? start, required String? end}) {
    if (start == null || start.isEmpty) return '';
    if (end != null && end.isNotEmpty) {
      return 'Date: ${formatDateTime(start)} to Date: ${formatDateTime(end)}';
    }
    return 'Date: ${formatDateTime(start)}';
  }
}

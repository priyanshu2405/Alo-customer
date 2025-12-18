import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_call_helper.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_image.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_images.dart';
import 'package:alo_ride_app/api_app_folder/screen/booking/view/ride_tracking_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/my_rides/controller/my_ride_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  final MyRideController myRideController = Get.put(MyRideController());
  DateTime selectedDate = DateTime.now();

  void _validateTimeForToday() {
    DateTime now = DateTime.now();

    bool isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    if (!isToday) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.transparent,
        leading: Icon(Icons.menu),
        title: "My Rides",
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 2,
            color: AppColors.darkTextColor,
          ),
          // Gap(10),
          Container(
            color: Color(0xffEDEDED),
            child: Row(
              children: [_tab("List View", 0), _tab("Calendar View", 1)],
            ),
          ),
          Obx(() {
            return Expanded(
              child: myRideController.selectedTab.value == 0
                  ? _listView()
                  : _calendarView(),
            );
          }),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () => AppCallHelper.callSOS(),
        child: AppImage(
          height: 55,width: 55,
          image: AppImages.sosButton,
          imageType: ImageType.asset,
        ),
      ),
    );
  }



  /// ================= TAB =================
  Widget _tab(String title, int index) {
    return Obx(() {
      final bool selected = myRideController.selectedTab.value == index;
      return Expanded(
        child: InkWell(
          onTap: () =>
              setState(() => myRideController.selectedTab.value = index),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
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

  /// ================= LIST VIEW =================
  Widget _listView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: AppText(
              text: "Upcoming",
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(10),
          Column(
            children: List.generate(2,  (index) {
              return InkWell(onTap: () {
                Get.to(()=>RideTrackingScreen());
              },child: _rideCard(status: "Pending", statusColor: AppColors.secondary));
            },),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: AppText(
              text: "History",
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),

          Gap(10.h),

          Column(
            children: List.generate(6,  (index) {
              return InkWell(onTap: () {
                Get.to(()=>RideTrackingScreen());
              },child: _rideCard(status: "Completed", statusColor: AppColors.greenColor, price: "\$50.00",));
            },),
          ),

          //
          // _rideCard(
          //   status: "Completed",
          //   statusColor: Colors.green,
          //   price: "\$50.00",
          // ),
          // _rideCard(
          //   status: "Completed",
          //   statusColor: Colors.green,
          //   price: "\$50.00",
          // ),
          // _rideCard(
          //   status: "Completed",
          //   statusColor: Colors.green,
          //   price: "\$50.00",
          // ),
        ],
      ),
    );
  }

  /// ================= CALENDAR VIEW =================
  Widget _calendarView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _calendarWidget(),
          _calendarViewRideCard(status: "Pending", statusColor: Colors.orange),
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
        setState(() {
          selectedDate = value;
          _validateTimeForToday();
        });
      },
    );
  }

  /// ================= RIDE CARD =================
  Widget _rideCard({
    required String status,
    required Color statusColor,
    String? price,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      text: "Booking ID: 23356",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (price != null)
                    AppText(text: price, fontWeight: FontWeight.bold),
                  Gap(6.w),
                  status == "Pending"?AppText(text: status, color: statusColor, fontSize: 12,fontWeight: FontWeight.w500,):SizedBox(),
                ],
              ),
              Gap(6.h),
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      text: status == "Pending"?"Date: 11/12/2025 10.30 AM to Date: 25/12/2025 09.00 AM":"Date: 06/02/2025 10.30 AM",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  status == "Pending"?SizedBox():AppText(text: status, color: statusColor, fontSize: 12,fontWeight: FontWeight.w500,),
                ],
              ),
              Gap(8.h),
              _buildLocationRow(
                icon: AppImage(
                  height: 20.h,
                  width: 20.w,
                  image: AppImages.recordCircleFill,
                  imageType: ImageType.svgAsset,
                ),
                iconColor: AppColors.pinkColor,
                title: '241-205 Barrieau Rd, Moncton.',
                showDivider: true,
              ),
              _buildLocationRow(
                icon: Icon(
                  Icons.location_on,
                  color: AppColors.pinkColor,
                  size: 20,
                ),
                iconColor: AppColors.pinkColor,
                title: '100 Holland Dr, Moncton, NB E1...',
                showDivider: false,
              ),
            ],
          ),
        ),
        Gap(20),
        Container(
          width: double.infinity,
          height: 2,
          color: AppColors.darkTextColor,
        ),
        Gap(20),
      ],
    );
  }

  Widget _calendarViewRideCard({
    required String status,
    required Color statusColor,
    String? price,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: "Booking ID: 23356",
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (price != null)
                AppText(text: price, fontWeight: FontWeight.bold),
              Gap(6.w),
              status == "Pending"?AppText(text: status, color: statusColor, fontSize: 12,fontWeight: FontWeight.w500,):SizedBox(),
            ],
          ),
          Gap(6.h),
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: status == "Pending"?"Date: 11/12/2025 10.30 AM to Date: 25/12/2025 09.00 AM":"Date: 06/02/2025 10.30 AM",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              status == "Pending"?SizedBox():AppText(text: status, color: statusColor, fontSize: 12,fontWeight: FontWeight.w500,),
            ],
          ),
          Gap(8.h),
          _buildLocationRow(
            icon: AppImage(
              height: 20.h,
              width: 20.w,
              image: AppImages.recordCircleFill,
              imageType: ImageType.svgAsset,
            ),
            iconColor: AppColors.pinkColor,
            title: '241-205 Barrieau Rd, Moncton.',
            showDivider: true,
          ),
          _buildLocationRow(
            icon: Icon(
              Icons.location_on,
              color: AppColors.pinkColor,
              size: 20,
            ),
            iconColor: AppColors.pinkColor,
            title: '100 Holland Dr, Moncton, NB E1...',
            showDivider: false,
          ),
        ],
      ),
    );
  }


  Widget _buildLocationRow({
    required Widget icon,
    required Color iconColor,
    required String title,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with connecting line
            Column(
              children: [
                // Icon(icon, color: iconColor, size: 20),
                icon,
                if (showDivider)
                  Column(
                    children: List.generate(4, (index) {
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
                children: [AppText(text: title, color: AppColors.textColor)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

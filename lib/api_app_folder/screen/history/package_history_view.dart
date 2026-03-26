import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/history/history_controller.dart';
import 'package:alo_ride_app/models/model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class PackageHistoryView extends StatefulWidget {
  const PackageHistoryView({super.key});

  @override
  State<PackageHistoryView> createState() => _PackageHistoryViewState();
}

class _PackageHistoryViewState extends State<PackageHistoryView> {
  final controller = Get.put(HistoryController());

  @override
  void initState() {
    super.initState();
controller.getPackageHistory();
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
        title: "Packages History",
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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 2,
            color: AppColors.darkTextColor,
          ),
          Gap(10),
          Expanded(

              child: Obx(() {

                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.packageList.isEmpty) {
                  return const Center(child: Text("No Package History Found"));
                }

                return RefreshIndicator(
                  color: AppColors.secondary,
                  onRefresh: () async {
                   await controller.getPackageHistory();
                  },
                  child: ListView.builder(
                    itemCount: controller.packageList.length,
                    itemBuilder: (context, index) {

                      final package = controller.packageList[index];

                      return packageHistoryCard(package);
                    },
                  ),
                );
              }),
          ),

        ],
      ),
    );
  }
  Widget packageHistoryCard(PackageHistoryModel package) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Package Name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Expanded(
                child: AppText(
                  text: package.packageName ?? "",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: package.status == "active"
                      ? Colors.green.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText(
                  text: package.status?.toUpperCase() ?? "",
                  fontSize: 10,
                  color: package.status == "active"
                      ? Colors.green
                      : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// Ride Type
          AppText(
            text: "Ride Type : ${package.rideType ?? "-"}",
            fontSize: 12,
            color: AppColors.lightTextColor,
          ),

          const SizedBox(height: 12),

          /// Ride Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              _historyItem("Total", package.totalRides.toString()),
              _historyItem("Used", package.ridesUsed.toString()),
              _historyItem("Remaining", package.ridesRemaining.toString()),
            ],
          ),

          const SizedBox(height: 12),

          /// Progress Bar
          LinearProgressIndicator(
            value: (package.ridesUsed ?? 0) /
                (package.totalRides == 0 ? 1 : package.totalRides?.toDouble() ?? 1),
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            color: AppColors.secondary,
          ),

          const SizedBox(height: 12),

          /// Price + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              AppText(
                text: "Purchased : ${package.paidAt ?? "-"}",
                fontSize: 11,
                color: AppColors.lightTextColor,
              ),

              AppText(
                text: "\$${package.amountPaid ?? 0}",
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _historyItem(String title, String value) {
    return Column(
      children: [
        AppText(
          text: value,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        AppText(
          text: title,
          fontSize: 11,
          color: AppColors.lightTextColor,
        ),
      ],
    );
  }}

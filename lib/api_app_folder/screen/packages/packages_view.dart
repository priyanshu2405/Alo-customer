import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/screen/booking/view/booking_screen.dart';
import 'package:alo_ride_app/api_app_folder/screen/packages/package_controller.dart';
import 'package:alo_ride_app/api_app_folder/utils/payment_success_view.dart';
import 'package:alo_ride_app/api_app_folder/utils/stripe_payment_services.dart';
import 'package:alo_ride_app/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../res/constant/app_colors.dart';

class PackagesView extends StatefulWidget {
  const PackagesView({super.key});

  @override
  State<PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<PackagesView> {
  final PackageController controller = Get.put(PackageController());
  final SubscriptionPaymentService _paymentService = Get.put(
    SubscriptionPaymentService(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getPackageList();
    });
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
        title: "Packages",
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
              if (controller.isVehicleTypes.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.packageList.isEmpty) {
                return const Center(child: Text("No Packages Available"));
              }
              return RefreshIndicator(
                color: AppColors.secondary,
                onRefresh: () async {
                  await controller.getPackageList();
                },
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Title + Discount Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: AppText(
                                    text:
                                        controller
                                            .packageList[index]
                                            .packageName ??
                                        "",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),

                                /// Discount Badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: AppText(
                                    text:
                                        "${controller.packageList[index].discountPercentage ?? ""}% OFF",
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            /// Package Info
                            _packageInfoRow(
                              "Distance",
                              "${controller.packageList[index].km ?? ""} km",
                            ),
                            const SizedBox(height: 8),

                            _packageInfoRow(
                              "No of Rides",
                              controller.packageList[index].numRides.toString(),
                            ),
                            const SizedBox(height: 8),
                            if (controller.packageList[index].isPurchased == 1)
                              _packageInfoRow(
                                "Remaining Rides",
                                controller.packageList[index].ridesRemaining
                                    .toString(),
                              ),
                            const SizedBox(height: 16),

                            /// Price + Button
                            Row(
                              children: [
                                /// Price Section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText(
                                        text: "Price",
                                        fontSize: 12,
                                        color: AppColors.lightTextColor,
                                      ),

                                      const SizedBox(height: 4),

                                      Row(
                                        children: [
                                          /// Discount Price
                                          AppText(
                                            text:
                                                "\$${controller.packageList[index].packagePriceTtc ?? ""}",
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.secondary,
                                          ),

                                          const SizedBox(width: 8),

                                          /// Original Price
                                          Text(
                                            "\$${controller.packageList[index].originalPrice ?? ""}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                /// Purchase Button
                                Expanded(
                                  child:
                                      controller
                                              .packageList[index]
                                              .isPurchased ==
                                          0
                                      ? SizedBox(
                                          height: 42,
                                          child: AppButton(
                                            // isLoading:
                                            //     controller.isCreatePaymentIntent.value == true,
                                            text: "Purchase",
                                            backgroundColor:
                                                AppColors.greenColor,
                                            onTap: () async {
                                              await _paymentService.buyNow(
                                                context,
                                                controller
                                                    .packageList[index]
                                                    .packagePriceTtc
                                                    .toString(),
                                                id: controller
                                                    .packageList[index]
                                                    .id,
                                              );
                                            },
                                          ),
                                        )
                                      : SizedBox(
                                          height: 42,
                                          child: AppButton(
                                            // isLoading:
                                            //     controller.isCreatePaymentIntent.value == true,
                                            text: "Book Now",
                                            onTap: () async {
                                              final package =
                                                  controller.packageList[index];

                                              /// Match packages[index].id with
                                              /// purchased_packages.package_id,
                                              /// -1 when nothing was purchased.
                                              final purchaseId = controller
                                                  .purchaseIdOf(package.id);

                                              debugPrint(
                                                "Package ID: ${package.id} | Purchase ID: $purchaseId | Name: ${package.packageName}",
                                              );

                                              Get.to(
                                                () => BookingScreen(
                                                  selectedType: 2,
                                                  purchaseId : purchaseId,
                                                  checkPurchase: true,
                                                  vehicleTypeId:
                                                  controller
                                                      .packageList[index]
                                                      .id ??
                                                      -1,
                                                  vehicleTypeName:
                                                      package.packageName ?? "",
                                                ),
                                              )?.then((value) async {
                                                await controller
                                                    .getPackageList();
                                              });
                                            },
                                          ),
                                        ),
                                  // AppText(
                                  //   text: "Active Package",
                                  //   fontSize: 14.sp,
                                  //   textAlign: TextAlign.right,
                                  //   fontWeight: FontWeight.bold,
                                  //   color: AppColors.greenColor,
                                  // ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, _) {
                    return Gap(8);
                  },
                  itemCount: controller.packageList.length,
                ),
              );
            }),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Container(
          //     width: double.infinity,
          //     padding: EdgeInsets.symmetric(
          //       horizontal: 10,
          //       vertical: 10,
          //     ),
          //     decoration: BoxDecoration(
          //       border: Border.all(
          //         color: AppColors.secondary,
          //         width: 1,
          //       ),
          //       borderRadius: BorderRadius.circular(8),
          //
          //     ),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         AppText(
          //           text: "CityPack 5 Zone 1",
          //           fontSize: 12.sp,
          //           fontWeight: /*isSelected ?*/ FontWeight.bold /*: FontWeight.normal*/,
          //           color: AppColors.black,
          //           textAlign: TextAlign.center,
          //           maxLines: 1,
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //         Gap(10),
          //         AppText(
          //           text: "km : 3",
          //           fontSize: 12.sp,
          //           fontWeight: FontWeight.bold,
          //           color: AppColors.black,
          //           textAlign: TextAlign.center,
          //           maxLines: 1,
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //         Gap(10),
          //         AppText(
          //           text: "No of Rides : 5",
          //           fontSize: 12.sp,
          //           fontWeight: FontWeight.bold,
          //           color: AppColors.black,
          //           textAlign: TextAlign.center,
          //           maxLines: 1,
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //         Gap(10),
          //         AppText(
          //           text: "Price : \$10",
          //           fontSize: 12.sp,
          //           fontWeight: FontWeight.bold,
          //           color: AppColors.black,
          //           textAlign: TextAlign.center,
          //           maxLines: 1,
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //         Gap(10),
          //         SizedBox(
          //             height: 40,
          //             child: AppButton(text: 'Purchase', onTap: () {  },)),
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _packageInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          text: "${title} : ",
          fontSize: 13,
          color: AppColors.lightTextColor,
        ),
        AppText(
          text: value,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ],
    );
  }
}

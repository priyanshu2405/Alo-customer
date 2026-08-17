import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/chat/controller/chat_unread_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/chat/view/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// When a ride has a live chat room.
///
/// The room is created server-side the moment a driver accepts, and closes
/// (read-only) on completion / cancellation. While the ride is still `pending`
/// there is no room at all, which is why the button has to be hidden rather
/// than disabled.
class ChatAvailability {
  const ChatAvailability._();

  static const Set<String> openStatuses = {
    'accepted',
    'going_to_pickup',
    'arrived',
    'pickup_done',
  };

  static bool isOpen({required int? rideId, required String? status}) =>
      rideId != null && rideId > 0 && openStatuses.contains(status);
}

/// Chat icon with an unread badge, for the live-tracking screen.
///
/// Renders nothing until a driver is assigned, so callers can drop it into a
/// Row unconditionally.
class ChatEntryButton extends StatelessWidget {
  final int? rideId;
  final String? rideStatus;
  final String driverName;
  final String driverMobile;
  final String driverPhoto;
  final double size;

  const ChatEntryButton({
    super.key,
    required this.rideId,
    required this.rideStatus,
    this.driverName = '',
    this.driverMobile = '',
    this.driverPhoto = '',
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    if (!ChatAvailability.isOpen(rideId: rideId, status: rideStatus)) {
      return const SizedBox.shrink();
    }

    final unread = ChatUnreadController.instance;

    return GestureDetector(
      onTap: () => openRideChat(
        rideId: rideId!,
        driverName: driverName,
        driverMobile: driverMobile,
        driverPhoto: driverPhoto,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 22,
              color: AppColors.blueColor,
            ),
            Obx(() {
              final count = unread.unreadFor(rideId!);
              if (count == 0) return const SizedBox.shrink();
              return Positioned(
                top: 8,
                right: 6,
                child: UnreadDot(count: count),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// The red count bubble, shared by the tracking screen and the rooms list.
class UnreadDot extends StatelessWidget {
  final int count;

  const UnreadDot({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AppText(
        text: count > 99 ? '99+' : '$count',
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    );
  }
}

/// Single entry point into a thread — used by the tracking screen, the rooms
/// list and the FCM deep link, so they can't drift apart.
void openRideChat({
  required int rideId,
  String driverName = '',
  String driverMobile = '',
  String driverPhoto = '',
}) {
  Get.to(
    () => ChatScreen(
      rideId: rideId,
      driverName: driverName,
      driverMobile: driverMobile,
      driverPhoto: driverPhoto,
    ),
  );
}

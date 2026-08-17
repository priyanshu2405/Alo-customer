import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/chat/controller/chat_rooms_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/chat/model/chat_models.dart';
import 'package:alo_ride_app/api_app_folder/screen/chat/view/chat_avatar.dart';
import 'package:alo_ride_app/api_app_folder/screen/chat/view/chat_entry_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// All conversations, active and ended. Closed rooms stay readable.
class ChatRoomsScreen extends StatelessWidget {
  const ChatRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatRoomsController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppAppBar(title: 'Messages'),
      body: Obx(() {
        if (controller.loading.value && controller.rooms.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.rooms.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.load(),
            child: ListView(
              children: [
                const Gap(120),
                const Icon(
                  Icons.forum_outlined,
                  size: 46,
                  color: AppColors.greyColor,
                ),
                const Gap(12),
                AppText(
                  text: controller.errorMessage.value.isEmpty
                      ? 'No conversations yet'
                      : controller.errorMessage.value,
                  fontSize: 13,
                  color: AppColors.lightGrayText,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.load(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.rooms.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.lightGray),
            itemBuilder: (context, index) =>
                _RoomTile(room: controller.rooms[index]),
          ),
        );
      }),
    );
  }
}

class _RoomTile extends StatelessWidget {
  final ChatRoomSummary room;

  const _RoomTile({required this.room});

  @override
  Widget build(BuildContext context) {
    final name = room.otherParty?.name.isNotEmpty == true
        ? room.otherParty!.name
        : 'Driver';

    return ListTile(
      onTap: () => openRideChat(
        rideId: room.rideId,
        driverName: name,
        driverMobile: room.otherParty?.mobile ?? '',
      ),
      leading: const ChatAvatar(photo: '', size: 44),
      title: Row(
        children: [
          Expanded(
            child: AppText(text: name, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          AppText(
            text: _stamp(room.lastMessageAt),
            fontSize: 11,
            color: AppColors.greyColor,
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                text: room.lastMessage?.message ?? 'No messages yet',
                fontSize: 12.5,
                color: AppColors.lightGrayText,
                maxLines: 1,
              ),
            ),
            if (room.unreadCount > 0) ...[
              const Gap(8),
              UnreadDot(count: room.unreadCount),
            ] else if (room.isClosed) ...[
              const Gap(8),
              const AppText(
                text: 'Ended',
                fontSize: 10,
                color: AppColors.greyColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Time for today, weekday inside the last week, date beyond that.
  static String _stamp(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final sameDay =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (sameDay) return DateFormat('HH:mm').format(date);
    if (now.difference(date).inDays < 7) return DateFormat('EEE').format(date);
    return DateFormat('dd MMM').format(date);
  }
}

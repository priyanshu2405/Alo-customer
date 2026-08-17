import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:flutter/material.dart';

/// Driver photo. The API sends an absolute URL for drivers; a relative path is
/// resolved against the public storage root, as elsewhere in the app.
class ChatAvatar extends StatelessWidget {
  final String photo;
  final double size;

  const ChatAvatar({super.key, required this.photo, required this.size});

  static String resolve(String? path) {
    if (path == null || path.isEmpty || path == 'null') {
      return "https://i.pravatar.cc/150?img=12";
    }
    if (path.startsWith('http')) return path;
    return "https://deliverymate.volive.me/alodrive/public/$path";
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        resolve(photo),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          color: AppColors.lightGray,
          child: Icon(
            Icons.person,
            size: size * 0.55,
            color: AppColors.greyColor,
          ),
        ),
      ),
    );
  }
}

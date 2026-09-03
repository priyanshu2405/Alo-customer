import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:flutter/material.dart';

/// Driver photo. The API sends an absolute URL for drivers; a relative path is
/// resolved against the public storage root, as elsewhere in the app.
class ChatAvatar extends StatelessWidget {
  final String photo;
  final double size;

  const ChatAvatar({super.key, required this.photo, required this.size});


  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        photo,
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

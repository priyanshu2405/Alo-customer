import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:flutter/material.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color titleColor;
  final double elevation;
  final bool centerTitle;
  final Widget? leading;
  final double? leadingWidth;

  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.backgroundColor = AppColors.white,
    this.titleColor = AppColors.black,
    this.elevation = 0,
    this.centerTitle = false,
    this.leading, this.leadingWidth,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      leadingWidth: leadingWidth,
      leading: leading ??
          (showBack
              ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: titleColor,
            onPressed: onBack ?? () => Navigator.pop(context),
          )
              : null),
      title: titleWidget ??
          (title != null
              ? Text(
            title!,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          )
              : null),
      actions: actions,
    );
  }
}

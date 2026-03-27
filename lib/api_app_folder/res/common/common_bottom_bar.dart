import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

class CommonBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CommonBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = AppResponsive.isTabletOrLarger(context);
    // Keep icon and label sizes proportional and capped on large screens
    final double iconSize = isTablet ? 22.0 : 24.0;
    final double labelFontSize = isTablet ? 11.0 : 12.0;

    return BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: AppColors.secondary,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        iconSize: iconSize,
        selectedFontSize: labelFontSize,
        unselectedFontSize: labelFontSize,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.7),
        ),
        items: [
          _buildBottomNavItem(icon: Icons.home_filled, label: 'Home', index: 0),
          _buildBottomNavItem(icon: Icons.directions_car, label: 'My Rides', index: 1),
          _buildBottomNavItem(icon: Icons.subscriptions, label: 'Packages', index: 2),
          _buildBottomNavItem(icon: Icons.history, label: 'History', index: 3),
          _buildBottomNavItem(icon: Icons.person_outline, label: 'Profile', index: 4),
        ],
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    IconData? icon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        // padding: EdgeInsets.only(top: index == 2 ? 20 : 0),
        child: icon != null ? Icon(icon) : SizedBox.shrink(),
      ),
      label: label,
    );
  }
}
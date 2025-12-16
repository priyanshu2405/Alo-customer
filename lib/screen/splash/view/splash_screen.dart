import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 Background Image
          Container(
            width: 1.sw,
            height: 1.sh,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/splash_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🔹 Overlay (optional dark effect)
          Container(
            width: 1.sw,
            height: 1.sh,
            color: Colors.black.withOpacity(0.35),
          ),

          /// 🔹 Center Logo & Text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Logo Circle
                Container(
                  height: 140.r,
                  width: 140.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange,
                      width: 4.w,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 60.sp,
                      color: Colors.orange,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                /// App Name
                Text(
                  "ALO RIDE",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),

                SizedBox(height: 8.h),

                /// Tagline
                Text(
                  "Book Now Ride Later",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:alo_ride_app/firebase_api/firebase_api.dart';
import 'package:alo_ride_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:alo_ride_app/api_app_folder/screen/splash/view/splash_screen.dart';
import 'package:alo_ride_app/api_app_folder/services/token_store.dart';

import 'package:alo_ride_app/api_app_folder/services/stripe_config_service.dart';

// import 'package:alo_ride_app/design_folder/screen/splash/view/splash_screen.dart';

/// 🔥 REQUIRED background handler
///
/// `@pragma('vm:entry-point')` is mandatory: this runs in a SEPARATE isolate
/// that Dart spawns from native code, so AOT tree-shaking drops the function in
/// release builds without it and every background push dies silently.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('📦 Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 REQUIRED: Initialize GetStorage
  await GetStorage.init();

  /// 🔥 Firebase INIT (ONLY ONCE)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// 🔥 Background message handler
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  /// 🔥 Notification service init
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 🔥 REQUIRED: Register AuthController once
  Get.put(AuthController(), permanent: true);
  final publishableKey = await StripeConfigService.fetchPublishableKey();
  debugPrint("publishableKey : $publishableKey");
  if (publishableKey != null) {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1),
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'Alo Ride',
      home: const SplashScreen(),
    );
  }
}

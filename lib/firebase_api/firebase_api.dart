
import 'dart:convert';
import 'dart:io';

import 'package:alo_ride_app/api_app_folder/screen/chat/controller/chat_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/chat/controller/chat_unread_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/chat/view/chat_entry_button.dart';
import 'package:alo_ride_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  // final DashBoardController dashBoardController = Get.find();
  final _box = GetStorage();
  static const String _tokenKey = "fcm_token";


   Future<void> initialize() async {
    await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
    );

    // Request permissions
    await _requestPermissions();




    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token safely
    String? token;
    try {
      token = await _firebaseMessaging.getToken();
      if (token == null) {
        print("⚠️ FCM token is null, retrying in 3 seconds...");
        await Future.delayed(const Duration(seconds: 3));
        token = await _firebaseMessaging.getToken();
      }
      print("✅ FCM Token: $token");
    } catch (e) {
      print("❌ Error getting FCM token: $e");
    }

    // Save token
    if (token != null) {
      // await AppPrefService.setFcmToken(fcmToken: token);
      await _box.write(_tokenKey, token);
    }

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print("🔄 New FCM Token: $newToken");
      var token = ''.obs;
      await _box.write(_tokenKey, newToken);
      // await AppPrefService.setFcmToken(fcmToken: newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Handle app launch from terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null &&
        handleChatTap(Map<String, dynamic>.from(initialMessage.data))) {
      // Chat tap from a terminated state — deep-linked, no banner needed.
    } else if (initialMessage != null) {
      _showLocalNotification(initialMessage); // optional
      // _onNotificationTapped(
      //   NotificationResponse(
      //     id: initialMessage.hashCode,
      //     payload: jsonEncode({
      //       "screen": initialMessage.data['screen'] ?? "home",
      //       ...initialMessage.data
      //     }),
      //     notificationResponseType:
      //     NotificationResponseType.selectedNotification,
      //   ),
      // );
    }
  }


  // Request notification permissions
  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    // AndroidInitializationSettings('@drawable/ic_launcher_foreground');
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
      // onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');

    // Show local notification
    _showLocalNotification(message);
  }

  // Handle background message taps
  static void _handleBackgroundMessageTap(RemoteMessage message) {
    print('Message tapped: ${message.messageId}');

    if (handleChatTap(Map<String, dynamic>.from(message.data))) return;

    // Navigate to specific screen based on message data
    if (message.data.containsKey('screen')) {
      // Handle navigation here
      print('Navigate to: ${message.data['screen']}');
    }
  }

  /// True when the push is a chat message from the driver.
  ///
  /// Chat payloads carry `ride_id` like ride pushes do, so anything that keys
  /// off `ride_id` must check this first.
  static bool isChatPayload(Map<String, dynamic> data) =>
      data['type']?.toString() == 'chat';

  /// `ride_id` / `chat_room_id` arrive as STRINGS in an FCM data payload —
  /// parsing them as int without a cast throws.
  static int? chatRideIdOf(Map<String, dynamic> data) =>
      int.tryParse(data['ride_id']?.toString() ?? '');

  /// Tap on a notification drawn by flutter_local_notifications (foreground,
  /// or a cold start from one). Only chat is routed here; every other type
  /// keeps its existing behaviour.
  static void _onLocalNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        handleChatTap(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      debugPrint('Notification payload decode failed: $e');
    }
  }

  /// Opens the thread for a chat push. Returns false when [data] is not a chat
  /// payload, so callers can fall through to their existing handling.
  static bool handleChatTap(Map<String, dynamic> data) {
    if (!isChatPayload(data)) return false;

    final rideId = chatRideIdOf(data);
    if (rideId == null) {
      debugPrint('[CHAT] tap without a usable ride_id — ignored');
      return true;
    }

    // Post-frame so Get has a live navigator on a cold start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      openRideChat(rideId: rideId, driverName: data['title']?.toString() ?? '');
    });
    return true;
  }

  // Show local notification with custom background color
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final data = Map<String, dynamic>.from(message.data);

    // A chat message for the thread the rider is already looking at must not
    // pop a banner over it — just let that screen pull the message in.
    if (isChatPayload(data)) {
      final rideId = chatRideIdOf(data);
      if (rideId != null && ChatController.activeRideId == rideId) {
        final tag = 'chat_$rideId';
        if (Get.isRegistered<ChatController>(tag: tag)) {
          Get.find<ChatController>(tag: tag).pollOnce();
        }
        debugPrint('[CHAT] push for the open thread ($rideId) — polling only');
        return;
      }
      if (Get.isRegistered<ChatUnreadController>()) {
        Get.find<ChatUnreadController>().refreshNow();
      }
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      icon: "@mipmap/ic_launcher",
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final payloadData = {
      "screen": message.data['screen'] ?? "home",
      "title": message.notification?.title ?? "New Message",
      "body": message.notification?.body ?? "You have a new message",
      ...message.data // merge other fields if present
    };

    // await _localNotifications.show(
    //  message.hashCode,
    //  message.notification?.title ?? 'New Message',
    // message.notification?.body ?? 'You have a new message',
    //   platformDetails,
    //   payload: jsonEncode(payloadData),
    // );
    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ??
          data['title']?.toString() ??
          'New Message',
      body: message.notification?.body ??
          data['body']?.toString() ??
          'You have a new message',
      notificationDetails: platformDetails,
      payload: jsonEncode(payloadData),
    );

  }




  // static void _onNotificationTapped(NotificationResponse response) {
  //   if (response.payload != null && response.payload!.isNotEmpty) {
  //     final data = jsonDecode(response.payload!);
  //     print('Notification tapped with data: $data');
  //
  //     final targetScreen = data['screen'] ?? "home";
  //
  //     if (targetScreen == "home") {
  //       final dashBoardController = Get.find<DashBoardController>();
  //       dashBoardController.selectedIndex.value = 0;
  //     } else {
  //       print("Navigate to: $targetScreen");
  //     }
  //   } else {
  //     print('Notification tapped but payload was empty');
  //     Get.to(() => HomeScreen());
  //   }
  // }



  // Get FCM token
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
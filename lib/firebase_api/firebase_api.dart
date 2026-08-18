
import 'dart:convert';
import 'dart:io';

import 'package:alo_ride_app/api_app_folder/screen/chat/service/chat_push_router.dart';
import 'package:alo_ride_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Notification channel id, VERSIONED on purpose.
///
/// Android freezes a channel's importance and sound the first time it is
/// created and ignores every later change, so a device that installed an older
/// build keeps the old (possibly silent) settings forever. Publishing a new id
/// is the only way to hand out new ones — bump the suffix whenever the sound or
/// importance changes, and list the old id in [kRetiredChannelIds].
const String kDefaultChannelId = 'alo_rider_alerts_v2';

/// Channels from earlier builds, deleted on startup so users don't end up with
/// duplicate entries in Android's notification settings.
const List<String> kRetiredChannelIds = ['high_importance_channel'];

/// Heads-up over whatever is on screen, with the device's default sound.
const AndroidNotificationChannel kDefaultChannel = AndroidNotificationChannel(
  kDefaultChannelId,
  'Ride & message alerts',
  description: 'Ride updates and chat messages.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  showBadge: true,
);

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

    // We present our own local notification in the foreground (so it has a
    // sound and a tap target on both platforms) — iOS must not also present the
    // incoming push, or it alerts twice.
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Handle app launch from terminated state.
    //
    // Deferred to after the first frame on purpose: `initialize()` runs before
    // `runApp`, so consuming the message here would resolve it against a
    // navigator that does not exist yet — the tap would silently do nothing.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage == null) return;

      debugPrint('Cold start from notification | data=${initialMessage.data}');

      // Chat deep-links into the thread; everything else keeps the previous
      // behaviour of re-showing the notification.
      if (handleChatTap(Map<String, dynamic>.from(initialMessage.data))) return;

      _showLocalNotification(initialMessage); // optional
    });
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
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    // Drop superseded channels first, so their frozen settings (and their row
    // in the system notification settings screen) go away.
    for (final retired in kRetiredChannelIds) {
      await android.deleteNotificationChannel(channelId: retired);
    }
    await android.createNotificationChannel(kDefaultChannel);
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
      ChatPushRouter.isChatPayload(data);

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
  static bool handleChatTap(Map<String, dynamic> data) =>
      ChatPushRouter.handlePushTap(data);

  // Show local notification with custom background color
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final data = Map<String, dynamic>.from(message.data);

    // The one case that must stay silent: a chat message for the thread the
    // rider is already reading. It lands in the open conversation instead.
    if (ChatPushRouter.suppressAlertFor(data)) return;

    // On Android the sound comes from the CHANNEL; these values only matter on
    // pre-Oreo devices, but they must agree with the channel or the
    // notification posts silently there.
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      kDefaultChannelId,
      'Ride & message alerts',
      channelDescription: 'Ride updates and chat messages.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
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
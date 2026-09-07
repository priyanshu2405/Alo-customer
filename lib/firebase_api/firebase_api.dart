
import 'dart:async';
import 'dart:convert';

import 'package:alo_ride_app/api_app_folder/screen/chat/service/chat_push_router.dart';
import 'package:alo_ride_app/api_app_folder/screen/dashboard/screen/dashboard_screen.dart';
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

  /// `initialize()` is reachable from `main()` and (in future) from a post-login
  /// refresh. Re-running it would register a SECOND `onMessage` /
  /// `onMessageOpenedApp` listener, so every tap would be handled twice.
  static bool _initialized = false;


   Future<void> initialize() async {
    if (_initialized) {
      debugPrint('Notification initialize() already done — skipping');
      return;
    }
    _initialized = true;

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

    // TERMINATED TAP: the tap launched the process and FCM drew the tray entry.
    //
    // Awaited here rather than deferred to the first frame: the intent extra is
    // consumed on the FIRST call and Android clears it, so it must be read
    // before anything else can race it. Routing is safe this early because
    // `handleNotificationTap` parks the tap until `ChatPushRouter.flushPending`
    // reports the navigator and the session are ready.
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    debugPrint(
      'getInitialMessage -> '
      '${initialMessage == null ? 'null (normal launch)' : initialMessage.data}',
    );
    if (initialMessage != null) {
      handleNotificationTap(Map<String, dynamic>.from(initialMessage.data));
    }

    // TERMINATED TAP on a notification WE drew (a foreground local
    // notification that outlived the process). These never surface through
    // `getInitialMessage`, so they need their own cold-start check.
    final launch = await _localNotifications.getNotificationAppLaunchDetails();
    final launchPayload = launch?.notificationResponse?.payload;
    debugPrint(
      'notificationAppLaunchDetails -> '
      'didLaunch=${launch?.didNotificationLaunchApp} | payload=$launchPayload',
    );
    if (launch?.didNotificationLaunchApp == true &&
        launchPayload != null &&
        launchPayload.isNotEmpty) {
      handleNotificationTap(_decodePayload(launchPayload));
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

  // BACKGROUND TAP: the app was alive but backgrounded and FCM drew the tray
  // entry.
  static void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('onMessageOpenedApp (background tap) | data=${message.data}');
    handleNotificationTap(Map<String, dynamic>.from(message.data));
  }

  static Map<String, dynamic> _decodePayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (e) {
      debugPrint('Notification payload decode failed: $e');
    }
    return <String, dynamic>{};
  }

  /// THE single routing function. All three delivery paths — foreground local
  /// notification, `onMessageOpenedApp`, and the cold-start
  /// `getInitialMessage` / `getNotificationAppLaunchDetails` — come through
  /// here, so a tap behaves identically in every app state.
  ///
  /// Routes on `data['type']`, never on the presence of `ride_id`: ride pushes
  /// carry one too.
  static void handleNotificationTap(Map<String, dynamic> data) {
    if (data.isEmpty) {
      debugPrint('Notification tap ignored — empty data payload');
      return;
    }

    final type = data['type']?.toString() ?? '';
    debugPrint('TAP RECEIVED | type=$type | data=$data');

    // Chat first, and before any auth check: the router parks the tap itself
    // when the navigator or the session is not ready yet.
    if (ChatPushRouter.handlePushTap(data)) return;

    switch (type) {
      case 'new_ride':
      case 'ride_update':
      case 'ride_completed':
      case 'ride_cancelled':
      case 'payment_received':
        _openDashboard();
        break;
      default:
        debugPrint('No route for notification type "$type" — opening dashboard');
        _openDashboard();
    }
  }

  /// Brings the app to the dashboard for non-chat pushes, once the navigator is
  /// attached and only when there is a session to show it to.
  static void _openDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.key.currentState == null) {
        debugPrint('Navigator not ready — skipping dashboard route');
        return;
      }
      if (!ChatPushRouter.isLoggedIn) {
        debugPrint('Not logged in — skipping dashboard route');
        return;
      }
      if (Get.currentRoute.contains('DashboardScreen')) return;
      Get.offAll(() => const DashboardScreen());
    });
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
    debugPrint('Local notification tapped | payload=${response.payload}');
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    handleNotificationTap(_decodePayload(payload));
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
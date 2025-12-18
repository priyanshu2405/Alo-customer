import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class AppCallHelper {
  AppCallHelper._(); // private constructor

  /// 📞 Make phone call (Android + iOS)
  static Future<void> makeCall(String phoneNumber) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint("Call error: $e");
    }
  }

  /// 🚨 Canada SOS
  static Future<void> callSOS() async {
    await makeCall("+14165551234");
  }
}

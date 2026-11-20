import 'package:alo_ride_app/api_app_folder/services/api_service.dart';
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

  static Future<void> makeDirectCall(String phoneNumber) async {
    await makeCall(phoneNumber);
  }
  /// 🚨 Canada SOS
  // static Future<void> callSOS() async {
  //   await makeCall("+14165551234");
  // }

  static Future<void> callSOS() async {
    try {

      final response = await ApiService.get1(endpoint: '${ApiService.baseUrl1}sos-number', isShow: false,useBaseUrl: false);
      makeDirectCall(response["data"]['phone_number']);
      // Convert the entire response to GetPackageModel (not each item)
    } catch (e) {
      print('Error fetching packages: $e');
    } finally {
    }
  }

}

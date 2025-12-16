import UIKit
import Flutter
import GoogleMaps   // ✅ ADD THIS

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ✅ ADD YOUR GOOGLE MAPS API KEY HERE
    GMSServices.provideAPIKey("AIzaSyBxaqnRr_zdsjrqNvtMEXXbm8IO2lvzTRs")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

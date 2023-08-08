import UIKit
import Flutter
import ali_iot_plugin

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    ALiAppDelegate.application(application,didFinishLaunchingWithOptions:launchOptions)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

import Flutter
import UIKit
import Foundation
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
   let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let preventScreenshotsChannel = FlutterMethodChannel(name: "prevent_screenshots", binaryMessenger: controller.binaryMessenger)
    preventScreenshotsChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if (call.method == "preventScreenshots") {
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = false
        result("Screenshots prevented")
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

import UIKit
import Flutter
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

if #available(iOS 10.0, *) {
  // For iOS 10 display notification (sent via APNS)
  UNUserNotificationCenter.current().delegate = self

  let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
  UNUserNotificationCenter.current().requestAuthorization(
    options: authOptions,
    completionHandler: { _, _ in }
  )
} else {
  let settings: UIUserNotificationSettings =
    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
  application.registerUserNotificationSettings(settings)
}

application.registerForRemoteNotifications()


    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

import Flutter
import UIKit
import UserNotifications

public class SwiftFlutterNotificationsUtilsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "flutter_notifications_utils", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterNotificationsUtilsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "clearAll":
      clearAllNotifications(result: result)
    case "clearThread":
      clearByThread(call: call, result: result)
    case "setBadgeCount":
      setBadgeCount(call: call, result: result)
    case "getNotificationsCount":
      getNotificationsCount(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func _setBadgeCountInternal(badge: Int) {
    UIApplication.shared.applicationIconBadgeNumber = badge
  }

  private func setBadgeCount(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let badgeCount = (call.arguments as? [String: Any])?["badgeCount"] as? Int

    if badgeCount == nil {
      result(
        FlutterError(
          code: "FLUTTER_NOTIFICATIONS_UTILS_MISSING_BADGE_COUNT",
          message: "Parameter 'badgeCount' is required", details: nil))
      return
    }

    if let badge = badgeCount {
      _setBadgeCountInternal(badge: badge)
      result(badge)
    }
  }

  private func getNotificationsCount(result: @escaping FlutterResult) {
    if #available(iOS 10.0, *) {
      let center = UNUserNotificationCenter.current()

      center.getDeliveredNotifications { notifications in
        let count = notifications.count
        result(count)
      }
    } else {
      result(0)
    }
  }

  private func clearAllNotifications(result: @escaping FlutterResult) {
    if #available(iOS 10.0, *) {
      let center = UNUserNotificationCenter.current()

      center.removeAllDeliveredNotifications()
      _setBadgeCountInternal(badge: 0)
      result(0)
    } else {
      result(0)
    }
  }

  private func clearByThread(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if #available(iOS 10.0, *) {
      let center = UNUserNotificationCenter.current()
      let threadIdToRemove = (call.arguments as? [String: Any])?["threadId"] as? String
      let badge = (call.arguments as? [String: Any])?["badgeCount"] as? Int

      if threadIdToRemove == nil {
        result(
          FlutterError(
            code: "FLUTTER_NOTIFICATIONS_UTILS_MISSING_THREAD_ID",
            message: "Parameter 'threadId' is required", details: nil))
        return
      }

      if let threadId = threadIdToRemove {
        center.getDeliveredNotifications { [weak self] notifications in
          let totalNotifications = notifications.count
          let filtered = notifications.filter { $0.request.content.threadIdentifier == threadId }
          let ids = filtered.map { $0.request.identifier }
          let clearedCount = ids.count

          if !ids.isEmpty {
            center.removeDeliveredNotifications(withIdentifiers: ids)
          }

          let remainingCount = totalNotifications - clearedCount

          // Set badge count to remaining count if no specific badge was provided
          let badgeToSet = badge ?? remainingCount
          self?._setBadgeCountInternal(badge: badgeToSet)

          result(remainingCount)
        }
      }
    } else {
      result(0)
    }
  }

}

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';

class FlutterNotificationsUtils {
  static const MethodChannel _channel =
      const MethodChannel("flutter_notifications_utils");

  /// Clears all notifications from the system tray.
  ///
  /// Supported on: iOS, Android
  ///
  /// Returns the number of remaining notifications
  static Future<int> clearAll() async {
    try {
      if (!Platform.isIOS && !Platform.isAndroid) {
        return 0;
      }

      return await _channel.invokeMethod("clearAll");
    } catch (e) {
      debugPrint(
          'FlutterNotificationsUtils: Error clearing all notifications: $e');
      rethrow;
    }
  }

  /// Clears notifications by thread ID.
  ///
  /// Supported on: iOS
  ///
  /// [threadId] - The thread identifier to clear notifications for.
  /// [badgeCount] -  (Optional) The badge count to set after clearing.
  /// If not set, defaults to the remaining notification count. 0 for none.
  ///
  /// Returns the number of remaining notifications.
  static Future<int?> clearThread(
    String threadId, {
    int? badgeCount,
  }) async {
    if (!Platform.isIOS) {
      return null;
    }

    try {
      final Map<String, dynamic> arguments = {};

      arguments["threadId"] = threadId;

      if (badgeCount != null) {
        arguments["badgeCount"] = badgeCount;
      }

      final result = await _channel.invokeMethod("clearThread", arguments);
      return result as int?;
    } catch (e) {
      debugPrint(
          'FlutterNotificationsUtils: Error clearing thread notifications: $e');
      rethrow;
    }
  }

  /// Clears notifications by channel ID.
  ///
  /// Supported on: Android only
  ///
  /// [channelId] - The channel identifier to clear notifications for.
  ///
  /// Returns the number of remaining notifications (Android only).
  static Future<int?> clearChannel(String channelId) async {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      final Map<String, dynamic> arguments = {};
      arguments["channelId"] = channelId;

      final result = await _channel.invokeMethod("clearChannel", arguments);
      return result as int?;
    } catch (e) {
      rethrow;
    }
  }

  /// Sets the app badge count.
  ///
  /// Supported on: iOS only
  ///
  /// [badgeCount] - The badge count to set.
  ///
  static Future<int> setBadgeCount(int badgeCount) async {
    if (!Platform.isIOS) {
      return badgeCount;
    }

    try {
      return await _channel
          .invokeMethod("setBadgeCount", {"badgeCount": badgeCount});
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the current number of delivered notifications.
  ///
  /// Supported on: iOS, Android
  ///
  /// Returns the number of currently delivered notifications.
  static Future<int?> getNotificationsCount() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod("getNotificationsCount");
      return result as int? ?? 0;
    } catch (e) {
      rethrow;
    }
  }

  /// Clears notifications by thread ID (iOS) or channel ID (Android).
  ///
  /// [id]: The thread ID (iOS) or channel ID (Android).
  /// [badgeCount]: (Optional) The badge count to set after clearing on iOS.
  ///
  /// Returns the number of remaining notifications.
  static Future<int?> clearThreadOrChannel(String id, {int? badgeCount}) async {
    if (Platform.isIOS) {
      return await clearThread(id, badgeCount: badgeCount);
    } else if (Platform.isAndroid) {
      return await clearChannel(id);
    }
    return null;
  }

  /// Clears notifications by tag.
  ///
  /// Supported on: Android only
  ///
  /// [tag] - The tag to match notifications.
  /// [mode] -  The matching mode (isEqual, contains, startsWith, endsWith). Defaults to [ClearByTagMode.isEqual].
  ///
  /// Returns the number of remaining notifications (Android only).
  static Future<int?> clearByTag(String tag,
      {ClearByTagMode mode = ClearByTagMode.isEqual}) async {
    try {
      if (!Platform.isAndroid) {
        return null;
      }

      final result = await _channel.invokeMethod('clearByTag', {
        'tag': tag,
        'mode': mode.name,
      });
      return result as int?;
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a notification channel.
  ///
  /// Supported on: Android only
  ///
  /// [channelId]: The unique channel identifier.
  /// [channelName]: The user-visible name of the channel.
  static Future<void> createAndroidNotificationsChannel({
    required String channelId,
    required String channelName,
  }) async {
    if (!Platform.isAndroid) {
      return;
    }

    final Map<String, dynamic> arguments = {};

    arguments["channelId"] = channelId;
    arguments["channelName"] = channelName;

    await _channel.invokeMethod("createChannel", arguments);
  }
}

enum ClearByTagMode {
  isEqual,
  contains,
  startsWith,
  endsWith,
}

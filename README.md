# flutter_notifications_utils

A Flutter plugin for managing Android and iOS notifications.
It's main utility is to clean the notification tray with the ability to target specific notifications.

## Features

- Clear all notifications
- Clear notifications by thread ID (iOS)
- Clear notifications by channel ID (Android)
- Clear notifications by tag (Android)
- Create notification channels (Android)
- Get notifications count
- Set app badge count (iOS)

## Platform Support

| Feature                               | iOS | Android |
| ------------------------------------- | :-: | :-----: |
| `clearAll()`                          | ✅  |   ✅    |
| `clearThread()`                       | ✅  |   ❌    |
| `clearChannel()`                      | ❌  |   ✅    |
| `clearThreadOrChannel()`              | ✅  |   ✅    |
| `clearByTag()`                        | ❌  |   ✅    |
| `createAndroidNotificationsChannel()` | ❌  |   ✅    |
| `getNotificationsCount()`             | ✅  |   ✅    |
| `setBadgeCount()`                     | ✅  |   ❌    |

### Compatiblity

- Some methods require iOS10+ or Android O+ to work. They will fail silently otherwise
- If an unsupported method is called on a Platform it'll simply return or return 0.

### Throw

Android methods can throw

## Return values

For convenience methods usually return the remaining number of notification, or `null` on unsuported platform.
Refer to each method documentation.

## Usage

### Clear All Notifications

```dart
// Clear all notifications from the system tray
await FlutterNotificationsUtils.clearAll();
```

### Clear by Thread ID (iOS)

```dart
// Clear notifications by thread ID
await FlutterNotificationsUtils.clearThread('chat_thread_123');
```

💡 By default this will set the badge count to the remaining number of notification, use the `badgeCount` parameter to force a value (0 for no badge)

### Clear by Channel ID (Android)

```dart
// Clear notifications by channel ID
await FlutterNotificationsUtils.clearChannel('chat_channel');
```

### Clear Thread and Channel

Utility method to handle iOS and Android at the same time

```dart
await FlutterNotificationsUtils.clearThreadOrChannel('id');
```

### Clear by Tag (Android only)

```dart
// Clear notifications by tag with different matching modes
await FlutterNotificationsUtils.clearByTag('fcm_message');
await FlutterNotificationsUtils.clearByTag('test', mode: ClearByTagMode.contains);
```

### Create Notification Channel (Android)

```dart
// Create a notification channel
await FlutterNotificationsUtils.createAndroidNotificationsChannel(
  channelId: 'chat_channel',
  channelName: 'Chat Notifications',
);
```

### Get Notifications Count

```dart
// Get current notifications count
int count = await FlutterNotificationsUtils.getNotificationsCount();
```

⚠️ Note Android sometime returns a number which is 1 above. It believe those are invisble notifications.

### Set App Badge Count (iOS only)

```dart
// Set the app badge count (iOS only)
await FlutterNotificationsUtils.setBadgeCount(5);
```

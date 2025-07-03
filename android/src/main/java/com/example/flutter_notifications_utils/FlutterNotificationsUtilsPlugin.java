package com.example.flutter_notifications_utils;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.app.NotificationManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.content.Context;
import android.os.Build;

/** FlutterNotificationsUtilsPlugin */
public class FlutterNotificationsUtilsPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_notifications_utils");
        channel.setMethodCallHandler(this);
        this.context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "createChannel":
                createChannel(call, result);
                break;
            case "clearChannel":
                clearByChannelId(call, result);
                break;
            case "clearByTag":
                clearByTag(call, result);
                break;
            case "clearAll":
                clearAllNotifications(result);
                break;
            case "getNotificationsCount":
                getNotificationsCount(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private void clearAllNotifications(@NonNull Result result) {
        try {
            NotificationManager notificationManager = (NotificationManager) context
                    .getSystemService(NotificationManager.class);
            notificationManager.cancelAll();
            result.success(0);
        } catch (Exception e) {
            result.error("FLUTTER_NOTIFICATIONS_UTILS_CANNOT_CLEAR_ALL", "Can not clear all notifications",
                    e.getMessage());
        }
    }

    private void clearByChannelId(@NonNull MethodCall call, @NonNull Result result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String channelId = call.argument("channelId");
            if (channelId == null) {
                result.error("FLUTTER_NOTIFICATIONS_UTILS_MISSING_CHANNEL_ID", "channelId parameter is required", null);
                return;
            }

            Integer badgeCount = call.argument("badgeCount");

            try {
                NotificationManager notificationManager = (NotificationManager) context
                        .getSystemService(NotificationManager.class);

                android.service.notification.StatusBarNotification[] activeNotifications = notificationManager
                        .getActiveNotifications();
                int totalNotifications = activeNotifications.length;
                int clearedCount = 0;

                for (android.service.notification.StatusBarNotification sbn : activeNotifications) {
                    Notification notification = sbn.getNotification();
                    if (notification.getChannelId() != null && notification.getChannelId().equals(channelId)) {
                        String tag = sbn.getTag();
                        int id = sbn.getId();

                        if (tag != null) {
                            notificationManager.cancel(tag, id);
                        } else {
                            notificationManager.cancel(id);
                        }
                        clearedCount++;
                    }
                }

                int remainingCount = totalNotifications - clearedCount;
                result.success(remainingCount);
            } catch (Exception e) {
                result.error("FLUTTER_NOTIFICATIONS_UTILS_CANNOT_CLEAR_CHANNEL",
                        "Failed to clear notifications for channelId: " + channelId,
                        e.getMessage());
            }
        } else {
            result.success(0);
        }
    }

    private void clearByTag(@NonNull MethodCall call, @NonNull Result result) {
        String tag = call.argument("tag");

        if (tag == null) {
            result.error("FLUTTER_NOTIFICATIONS_UTILS_MISSING_TAG", "tag parameter is required", null);
            return;
        }

        String modeStr = call.argument("mode");
        TagMatchMode mode = TagMatchMode.fromString(modeStr);

        try {
            NotificationManager notificationManager = (NotificationManager) context
                    .getSystemService(NotificationManager.class);

            android.service.notification.StatusBarNotification[] activeNotifications = notificationManager
                    .getActiveNotifications();
            int totalNotifications = activeNotifications.length;
            int clearedCount = 0;

            for (android.service.notification.StatusBarNotification sbn : activeNotifications) {
                String sbnTag = sbn.getTag();
                if (sbnTag == null)
                    continue;

                switch (mode) {
                    case IS_EQUAL:
                        if (tag.equals(sbnTag)) {
                            notificationManager.cancel(sbn.getTag(), sbn.getId());
                            clearedCount++;
                        }
                        break;
                    case CONTAINS:
                        if (sbnTag.contains(tag)) {
                            notificationManager.cancel(sbn.getTag(), sbn.getId());
                            clearedCount++;
                        }
                        break;
                    case STARTS_WITH:
                        if (sbnTag.startsWith(tag)) {
                            notificationManager.cancel(sbn.getTag(), sbn.getId());
                            clearedCount++;
                        }
                        break;
                    case ENDS_WITH:
                        if (sbnTag.endsWith(tag)) {
                            notificationManager.cancel(sbn.getTag(), sbn.getId());
                            clearedCount++;
                        }
                        break;
                }
            }

            // Calculate remaining count
            int remainingCount = totalNotifications - clearedCount;
            result.success(remainingCount);
        } catch (Exception e) {
            result.error("FLUTTER_NOTIFICATIONS_UTILS_CANNOT_CLEAR_TAG",
                    "Failed to clear notifications for tag: " + tag,
                    e.getMessage());
        }
    }

    private void createChannel(@NonNull MethodCall call, @NonNull Result result) {
        String channelId = call.argument("channelId");
        String channelName = call.argument("channelName");
        String channelDescription = call.argument("channelDescription");
        Integer channelImportanceObj = call.argument("channelImportance");
        int channelImportance = channelImportanceObj != null ? channelImportanceObj
                : NotificationManager.IMPORTANCE_DEFAULT;

        if (channelId == null || channelName == null) {
            result.error("FLUTTER_NOTIFICATIONS_UTILS_INVALID_ARGUMENTS", "channelId and channelName are required",
                    null);
            return;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    channelId,
                    channelName,
                    channelImportance);
            if (channelDescription != null) {
                channel.setDescription(channelDescription);
            }
            NotificationManager notificationManager = (NotificationManager) context
                    .getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
        result.success(null);
    }

    private enum TagMatchMode {
        IS_EQUAL,
        CONTAINS,
        STARTS_WITH,
        ENDS_WITH;

        public static TagMatchMode fromString(String mode) {
            if (mode == null)
                return IS_EQUAL;
            switch (mode) {
                case "contains":
                    return CONTAINS;
                case "startsWith":
                    return STARTS_WITH;
                case "endsWith":
                    return ENDS_WITH;
                case "isEqual":
                default:
                    return IS_EQUAL;
            }
        }
    }

    private void getNotificationsCount(@NonNull Result result) {
        try {
            NotificationManager notificationManager = (NotificationManager) context
                    .getSystemService(NotificationManager.class);

            android.service.notification.StatusBarNotification[] activeNotifications = notificationManager
                    .getActiveNotifications();
            int count = activeNotifications.length;

            result.success(count);
        } catch (Exception e) {
            result.error("FLUTTER_NOTIFICATIONS_UTILS_CANNOT_GET_COUNT", "Failed to get notifications count",
                    e.getMessage());
        }
    }
}
import 'dart:io' show Platform;
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_notifications_utils_example/buttons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notifications_utils/flutter_notifications_utils.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );

    if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _createNotification({String? tag, String? channelId}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          channelId ?? 'test_channel',
          'Test Channel',
          importance: Importance.max,
          priority: Priority.high,
          tag: tag,
        );
    DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(threadIdentifier: channelId);

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    int randomId = Random().nextInt(1000000);
    await flutterLocalNotificationsPlugin.show(
      randomId,
      'Test Notification $randomId',
      'Tag: $tag, channelId: $channelId, id: $randomId',
      platformChannelSpecifics,
    );
  }

  Future<void> _clearAll() async {
    try {
      await FlutterNotificationsUtils.clearAll();
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Clear Notifications')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  " Notifications Count",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final count =
                        await FlutterNotificationsUtils.getNotificationsCount();
                    debugPrint('Notifications count: $count');
                  },
                  child: const Text("getCount"),
                ),
                if (Platform.isAndroid)
                  Column(
                    children: [
                      const Text(
                        "Tag Notifications",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        children: [
                          ElevatedButton(
                            onPressed: () => _createNotification(tag: 'test1'),
                            child: const Text("test1"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _createNotification(tag: 'test2'),
                            child: const Text("test2"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () =>
                                _createNotification(tag: 'fcm_message'),
                            child: const Text("fcm_message"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Clear Tag Notifications",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        children: [
                          ClearByTagButton(tag: "test1"),
                          ClearByTagButton(tag: "test2"),
                          ClearByTagButton(tag: "fcm_message"),
                          ClearByTagButton(
                            tag: "1",
                            mode: ClearByTagMode.contains,
                          ),
                          ClearByTagButton(
                            tag: "2",
                            mode: ClearByTagMode.endsWith,
                          ),
                          ClearByTagButton(
                            tag: "fcm_",
                            mode: ClearByTagMode.startsWith,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(),
                    ],
                  ),

                const Text(
                  "Channel/Thread Notifications",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  children: [
                    ElevatedButton(
                      onPressed: () => _createNotification(channelId: 'test1'),
                      child: const Text("test1"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _createNotification(channelId: 'test2'),
                      child: const Text("test2"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Clear Thread/Channel Notifications",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final r =
                            await FlutterNotificationsUtils.clearThreadOrChannel(
                              "test1",
                            );
                        debugPrint('Remaining notifications: $r');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("clear test1"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          FlutterNotificationsUtils.clearThreadOrChannel(
                            "test2",
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("clear test2"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(),

                const SizedBox(height: 16),
                const Text(
                  "Clear All Notifications",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _clearAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Clear ALL Notifications"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

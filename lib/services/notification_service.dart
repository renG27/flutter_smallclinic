import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb check

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // #region Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Replace with your app icon name

    // #endregion
    // #region iOS Settings

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true, // Request permission to display alerts.
      requestBadgePermission: true, // Request permission to set the application badge.
      requestSoundPermission: true, // Request permission to play sounds.
    );
    // #endregion

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(), // Add iOS details here if needed
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  //Added check permission for WEB
  Future<void> requestPermissions() async {
    if (kIsWeb) {
      print('Notification permission request skipped on web.');
      return; // Skip permission request on web
    }
    // Request notification permissions
    PermissionStatus status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
      if (status.isGranted) {
        print("Notification permission granted");
      } else {
        print("Notification permission denied");
      }
    }
  }
}
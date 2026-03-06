import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const localSettings = InitializationSettings(android: android, iOS: null);

    await _notifications.initialize(settings: localSettings);
  }

  static Future<void> showNewRequest() async {
    const androidDetails = AndroidNotificationDetails(
      'driver_channel',
      'Driver Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: 1,
      title: "New Delivery Request",
      body: "You have a new delivery request",
      // payload: details,
    );
  }
}


// NotificationService.showNewRequest();
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kb_driver/core/services/location_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class DriverBackgroundService {
  static Future<void> initialize() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'driver_service',
      'Driver Background Service',
      description: 'Driver service running',
      importance: Importance.low,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'driver_service',
        initialNotificationTitle: 'Driver Online',
        initialNotificationContent: 'Waiting for delivery requests',
        foregroundServiceNotificationId: 1001,
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke("stopService");
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  Timer.periodic(const Duration(seconds: 30), (timer) async {
    print("Driver background service running");

    /// 1️⃣ Get location
    final position = await DriverLocationService.getCurrentLocation();

    print("Current location: ${position?.latitude}, ${position?.longitude}");

    // if (position != null) {
    //   /// 2️⃣ Send location to API
    //   await controller.updateDriverLocation(
    //     position.latitude,
    //     position.longitude,
    //   );
    // }

    /// 3️⃣ Check new delivery requests
    // await controller.checkForNewRequests();
  });
}

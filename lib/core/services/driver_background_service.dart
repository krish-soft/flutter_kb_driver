import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver/shipment_controller.dart';
import 'package:kb_driver/core/services/location_service.dart';
import 'package:kb_driver/utils/vibrate_manager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class DriverBackgroundService {
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings localSettings = InitializationSettings(
      android: androidInit,
    );

    await flutterLocalNotificationsPlugin.initialize(settings:localSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'driver_service',
      'Driver Online Service',
      description: 'Driver delivery updates',
      importance: Importance.high,
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
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  print("BACKGROUND SERVICE STARTED");

  final vibrateManager = VibrateManager();
  final shipmentController = ShipmentController();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    print("Foreground service enabled");
  }

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings localSettings = InitializationSettings(
    android: androidInit,
  );

  await flutterLocalNotificationsPlugin.initialize(settings:localSettings);

  final Set<int> knownShipmentIds = {};

  service.on("stopService").listen((event) {
    print("Stopping background service");
    service.stopSelf();
  });

  /// LOCATION TIMER (every 30 sec)
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    try {
      final position = await DriverLocationService.getCurrentLocation();

      print("Location sent: ${position?.latitude}, ${position?.longitude}");

      if (position != null) {
        // TODO: send location API
        // await driverController.updateDriverLocation(...)
      }
    } catch (e) {
      print("Location timer error: $e");
    }
  });

  /// SHIPMENT CHECK TIMER (every 60 sec)
  Timer.periodic(const Duration(seconds: 60), (timer) async {
    try {
      print("Checking shipment requests...");

      ApiResponseModel resp = await shipmentController
          .checkForNewShipmentRequests();

      if (resp.isSuccess == true &&
          resp.data?['has_requested_shipments'] == true) {
        List<int> shipmentIds = List<int>.from(
          resp.data?['shipment_ids'] ?? [],
        );

        bool hasNewShipment = false;

        for (var id in shipmentIds) {
          if (!knownShipmentIds.contains(id)) {
            knownShipmentIds.add(id);

            print("NEW SHIPMENT DETECTED → $id");

            hasNewShipment = true;
          }
        }

        if (hasNewShipment) {
          print("Triggering shipment notification");

          service.invoke("newShipment", {"data": resp.data});

          await vibrateManager.vibrateHeavy();

          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: "New Shipment Request",
              content: "You have new delivery requests",
            );
          }

          await flutterLocalNotificationsPlugin.show(
            id: 2001,
            title: "New Shipment Request",
            body: "You have new delivery requests",
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                "driver_service",
                "Driver Online Service",
                channelDescription: "Driver shipment alerts",
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
              ),
            ),
            payload: "new_shipment",
          );

          print("Notification displayed");
        }
      } else {
        print("No new shipments");
      }
    } catch (e) {
      print("Shipment check error: $e");
    }
  });
}

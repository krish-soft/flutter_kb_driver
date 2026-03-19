import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver/shipment_controller.dart';
import 'package:kb_driver/core/services/location_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class DriverBackgroundService {
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings localSettings = InitializationSettings(
      android: androidInit,
    );

    await flutterLocalNotificationsPlugin.initialize(settings: localSettings);

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

  final shipmentController = ShipmentController();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  final Set<int> knownShipmentIds = {};

  /// ===== LOCATION TIMER CONTROL =====
  Timer? locationTimer;
  bool currentActiveState = false;

  void startLocationTimer(bool isActiveDelivery) {
    locationTimer?.cancel();

    final interval = isActiveDelivery ? 15 : 90;

    print("Starting location timer: $interval sec");

    locationTimer = Timer.periodic(Duration(seconds: interval), (timer) async {
      print("Background location checking...");

      final position = await DriverLocationService.getCurrentLocation();

      if (position != null) {
        final lat = position.latitude;
        final lng = position.longitude;

        print("Lat: $lat, Lng: $lng");

        /// 👉 CALL YOUR API HERE
        // await sendDriverLocation(lat, lng);
      } else {
        print("Location not available");
      }
    });
  }

  /// ===== STOP SERVICE =====
  service.on("stopService").listen((event) {
    locationTimer?.cancel();
    service.stopSelf();
  });

  /// ===== INITIAL TIMER START (default idle) =====
  startLocationTimer(false);

  /// ===== SHIPMENT CHECK TIMER =====
  Timer.periodic(const Duration(seconds: 60), (timer) async {
    print("Background checking shipments...");

    bool hasNewShipment = false;
    bool hasActiveDelivery = false;

    try {
      ApiResponseModel resp = await shipmentController
          .checkForNewShipmentRequests();

      /// ===== ACTIVE DELIVERY CHECK =====
      if (resp.isSuccess == true &&
          resp.data?['has_active_shipments'] == true) {
        hasActiveDelivery = true;

        service.invoke("activeShipments", {"data": resp.data});
      }

      /// ===== 🔥 SWITCH LOCATION TIMER IF STATE CHANGED =====
      if (hasActiveDelivery != currentActiveState) {
        currentActiveState = hasActiveDelivery;
        startLocationTimer(hasActiveDelivery);
      }

      /// ===== NEW SHIPMENT CHECK =====
      if (resp.isSuccess == true &&
          resp.data?['has_requested_shipments'] == true) {
        List<int> shipmentIds = List<int>.from(
          resp.data?['shipment_ids'] ?? [],
        );

        service.invoke("newShipment", {"data": resp.data});

        for (var id in shipmentIds) {
          if (!knownShipmentIds.contains(id)) {
            knownShipmentIds.add(id);
            hasNewShipment = true;

            print("NEW SHIPMENT DETECTED → $id");
          }
        }

        if (hasNewShipment) {
          await flutterLocalNotificationsPlugin.show(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: "New Shipment Request",
            body: "You have new delivery requests",
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                "driver_service",
                "Driver Online Service",
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("Shipment check error: $e");
    }
  });
}

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // print("BACKGROUND SERVICE STARTED");

//   // final vibrateManager = VibrateManager();
//   final shipmentController = ShipmentController();

//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }

//   final Set<int> knownShipmentIds = {};

//   service.on("stopService").listen((event) {
//     service.stopSelf();
//   });

//   // Location check every 15 seconds (for future use)
//   Timer.periodic(const Duration(seconds: 15), (timer) async {
//     print("Background location checkings...");

//     final position = await DriverLocationService.getCurrentLocation();

//     if (position != null) {
//       final lat = position.latitude;
//       final lng = position.longitude;

//       print("Lat: $lat, Lng: $lng");

//       /// 👉 CALL YOUR API HERE
//       // await sendDriverLocation(lat, lng);
//     } else {
//       print("Location not available");
//     }
//   });

//   // Shipment check every 60 seconds
//   Timer.periodic(const Duration(seconds: 60), (timer) async {
//     print("Background checking shipments...");

//     try {
//       ApiResponseModel resp = await shipmentController
//           .checkForNewShipmentRequests();

//       // Check for active deliveries
//       if (resp.isSuccess == true &&
//           resp.data?['has_active_shipments'] == true) {
//         service.invoke("activeShipments", {"data": resp.data});
//       }

//       if (resp.isSuccess == true &&
//           resp.data?['has_requested_shipments'] == true) {
//         List<int> shipmentIds = List<int>.from(
//           resp.data?['shipment_ids'] ?? [],
//         );

//         service.invoke("newShipment", {"data": resp.data});

//         bool hasNewShipment = false;

//         for (var id in shipmentIds) {
//           if (!knownShipmentIds.contains(id)) {
//             knownShipmentIds.add(id);
//             hasNewShipment = true;

//             print("NEW SHIPMENT DETECTED → $id");
//           }
//         }

//         if (hasNewShipment) {
//           // print("Trigger vibration + notification");

//           /// send event to UI

//           /// local notification
//           await flutterLocalNotificationsPlugin.show(
//             id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//             title: "New Shipment Request",
//             body: "You have new delivery requests",
//             notificationDetails: const NotificationDetails(
//               android: AndroidNotificationDetails(
//                 "driver_service",
//                 "Driver Online Service",
//                 importance: Importance.max,
//                 priority: Priority.high,
//                 playSound: true,
//                 enableVibration: true,
//               ),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print("Shipment check error: $e");
//     }
//   });
// }

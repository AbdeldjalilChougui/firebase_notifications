import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings
        = InitializationSettings(android: AndroidInitializationSettings("@mipmap/ic_launcher"));

    _notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (notification) async {
      // do some work
    });
  }

  static void display(RemoteMessage message) async {
    print("message showed up on foreground");

    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "com_firebase", "com_firebase_channel",
          importance: Importance.max, priority: Priority.high,
        ),
      );

      await _notificationsPlugin.show(id, message.notification!.title,
        message.notification!.body, notificationDetails,
        payload: message.messageId,
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}

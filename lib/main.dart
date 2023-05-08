import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications/firebase_options.dart';
import 'package:firebase_notifications/foreground_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

FirebaseAuth? auth;
FirebaseApp? app;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('A bg message just showed up :  ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app!);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Send Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Firebase Send Notifications'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RemoteMessage? privateMessage;

  @override
  void initState() {
    LocalNotificationService.initialize();

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification notification = message.notification!;

      print(notification.body);
      print(notification.title);
      print(notification.android);

      privateMessage = message;
      LocalNotificationService.display(message);
    });
    super.initState();
  }

  String? apiKey = "AAAALKx5kEA:APA91bHWxTQsvFQv6zRJ1G3xYwJwCkiCqiiyFPKHNwQzmQuqBlXM0_UkWF3UcE8eLrjZvbDaTTbTRcVs8xcXa65m86Kk3LIgUEIfQsYHSWeahGSWyaomIT5BjxT5QBmnNvrtkm0P2B90";

  Future<bool> sendFcmMessage({String? title, String? message, deviceToken}) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=$apiKey",
      };
      var request = {
        "notification": {
          "title": title,
          "body": message,
          "sound": "default",
          "color": "#F9F9F9",
        },
        "priority": "high",
        "topic": "all",
        "to": deviceToken,
      };

      var response = await http.post(Uri.parse(url), headers: header, body: json.encode(request)).then((value) {
        print(value.body);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getFcmToken() async {
    print('running....');
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic('all');
    return await messaging.getToken().then((token) {
      print("firebaseToken\n" + token!);
      return token;
    });
  }

  sendFCM() async {
    String? token = await getFcmToken();
    sendFcmMessage(message: "message", title: "title", deviceToken: token!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
             Text(
              'Simple app, click to send notification and show it here',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          sendFCM();
        },
        tooltip: 'Send',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

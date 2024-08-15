import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elite/login_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'auth_tokens/tokens.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDyGS3AJmHhbYBvzPm1hGMPST4WHkzmku8',
      appId: '1:559329487158:android:5fab07ca02ce81de156b97',
      messagingSenderId: '559329487158',
      projectId: 'elitenew-f0b99',
      storageBucket: 'gs://elitenew-f0b99.appspot.com',
    ),
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "uniqueTaskName",
    "simplePeriodicTask",
    frequency: const Duration(hours: 24),
  );
  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {

    print("Executing task: $task");
    await checkBirthdaysAndSendNotifications();
    return Future.value(true);
  });
}

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"));
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    try {
      Random random = Random();
      int id = random.nextInt(1000);
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "mychannel",
          "my channel",
          importance: Importance.max,
          priority: Priority.high,
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          icon: '@mipmap/ic_launcher',
        ),
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        message.notification?.title ?? 'Default Title',
        message.notification?.body ?? 'Default Body',
        notificationDetails,
      );
    } catch (e) {
      print("Error displaying notification: $e");
    }
  }
}

Future<void> backgroundHandler(RemoteMessage msg) async {
  await Firebase.initializeApp();
  LocalNotificationService.display(msg);
}

Future<void> checkBirthdaysAndSendNotifications() async {
  final DateTime now = DateTime.now();
  final String today = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}";  print("now " + today);
  final firestore = FirebaseFirestore.instance;

  try {
    QuerySnapshot snapshot = await firestore.collection('students').get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('dob')) {
        String dobString = data['dob'];
        List<String> dobParts = dobString.split('-');
        String dobDayMonth = "${dobParts[0]}-${dobParts[1]}";
        print("hello " + dobDayMonth);
        if (dobDayMonth == today) {
          print(dobDayMonth);
          print(today);
          String name = data['student_name'];
          print("Sending birthday notification for $name");
          await sendTopicMessage(name);
        }
      }
    }
  } catch (e) {
    print("Error checking birthdays: $e");
  }
}

Future<void> sendTopicMessage(String name) async {
  final String accessToken = await getAccessToken();
  const url =
      'https://fcm.googleapis.com/v1/projects/elitenew-f0b99/messages:send';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  final body = jsonEncode({
    'message': {
      'topic': 'birthdays',
      'notification': {
        'title': 'Happy Birthday',
        'body': "Today is $name's birthday",
      }
    }
  });

  final response =
      await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    print('Message sent successfully');
  } else {
    print('Failed to send message: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  await FirebaseFirestore.instance.collection('birthday').doc().set({
    'name': name,
    'message': "Today is $name's birthday",
    'title': 'Happy Birthday',
    'timestamp': FieldValue.serverTimestamp(),
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    LocalNotificationService.initialize();
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {}
    });

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        LocalNotificationService.display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("on message opened app");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Information',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const LoginPage(),
    );
  }
}

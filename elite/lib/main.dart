import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elite/admin/Homepage.dart';
import 'package:elite/login_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'admin/Studentform.dart';
import 'auth_tokens/tokens.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
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

  print('User granted permission: ${settings.authorizationStatus}');
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  Workmanager().registerPeriodicTask(
    "1",
    "simplePeriodicTask",
    frequency: Duration(hours: 24),
  );

  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();
    await checkBirthdaysAndSendNotifications();
    return Future.value(true);
  });
}

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static void initialize() {
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"));
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    try {
      print("In Notification method");
      Random random = new Random();
      int id = random.nextInt(1000);
      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "mychannel",
          "my channel",
          importance: Importance.max,
          priority: Priority.high,
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          icon: '@mipmap/ic_launcher',
        ),
      );
      print("my id is ${id.toString()}");
      await _flutterLocalNotificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.title,
        notificationDetails,
      );
    } on Exception catch (e) {
      print('Error>>>$e');
    }
  }
}

Future<void> backgroundHandler(RemoteMessage msg) async {
  await Firebase.initializeApp();
  LocalNotificationService.display(msg);
}

Future<void> checkBirthdaysAndSendNotifications() async {
  final DateTime now = DateTime.now();
  final String today = "${now.day}-${now.month}";
  final firestore = FirebaseFirestore.instance;

  try {
    QuerySnapshot snapshot = await firestore.collection('students').get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('dob')) {
        DateTime dob = (data['dob'] as Timestamp).toDate();
        String dobString = "${dob.day}-${dob.month}";
        if (dobString == today) {
          String name = data['name'];
          await sendTopicMessage(name);
        }
      }
    }
  } catch (e) {
    print(e);
  }
}

Future<void> sendTopicMessage(String name) async {
  final String accessToken = await getAccessToken();
  const url = 'https://fcm.googleapis.com/v1/projects/elitenew-f0b99/messages:send';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  final body = jsonEncode({
    'message': {
      'topic': 'birthdays',
      'notification': {
        'body': "Today is ${name}'s birthday",
        'title': 'Happy Birthday'
      }
    }
  });

  final response = await http.post(Uri.parse(url), headers: headers, body: body);

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
      if (message != null) {
        // Handle the initial message here
      }
    });
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        LocalNotificationService.display(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("on message opened app");
      // Handle message when the app is opened from a notification
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
      home: LoginPage(),
    );
  }
}

import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elite/login_page.dart';
import 'package:elite/startpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'auth_tokens/tokens.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'],
    ),
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  DateTime now = DateTime.now();
  String unique = DateTime.now().second.toString();
  DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
  Duration timeUntilMidnight = nextMidnight.difference(now);
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "unique",
    "simplePeriodicTask",
    initialDelay: timeUntilMidnight,
    frequency: const Duration(hours: 24),
  );
  runApp(const MyApp());

}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Executing task: $task");

    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY']!,
        appId: dotenv.env['FIREBASE_APP_ID']!,
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'],
      ),
    );


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
            android: AndroidInitializationSettings("@mipmap/elitelogo"));
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
          icon: '@mipmap/elitelogo',
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
  print('entered');
  final DateTime now = DateTime.now();
  final String today =
      "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}";
  print("Current date: $today");

  final firestore = FirebaseFirestore.instance;

  try {
    print("Fetching students from Firestore");
    QuerySnapshot snapshot = await firestore.collection('students').get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('dob')) {
        String dobString = data['dob'];
        List<String> dobParts = dobString.split('-');
        String dobDayMonth = "${dobParts[0]}-${dobParts[1]}";
        print("Found DOB: $dobDayMonth");

        if (dobDayMonth == today) {
          String name = data['student_name'];

          // Check if notification has already been sent today for this person
          bool notificationSent = await hasNotificationBeenSent(name, today);
          if (!notificationSent) {
            print("Sending birthday notification for $name");
            await sendTopicMessage(name);
            await markNotificationAsSent(name, today);
          } else {
            print("Notification already sent for $name today");
          }
        }
      }
    }
  } catch (e) {
    print("Error checking birthdays: $e");
  }
}

Future<bool> hasNotificationBeenSent(String name, String date) async {
  final firestore = FirebaseFirestore.instance;
  QuerySnapshot snapshot = await firestore
      .collection('sent_notifications')
      .where('name', isEqualTo: name)
      .where('date', isEqualTo: date)
      .get();

  return snapshot.docs.isNotEmpty;
}

Future<void> markNotificationAsSent(String name, String date) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('sent_notifications').doc().set({
    'name': name,
    'date': date,
    'timestamp': FieldValue.serverTimestamp(),
  }).catchError((e) {
    print("Error marking notification as sent: $e");
  });
}

Future<void> sendTopicMessage(String name) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('birthday').doc().set({
    'name': name,
    'message': "Today is $name's birthday",
    'title': 'Happy Birthday',
    'timestamp': FieldValue.serverTimestamp(),
  }).catchError((e) {
    print("Error storing notification in Firestore: $e");
  });

  final String accessToken = await getAccessToken();
  final url = 'https://fcm.googleapis.com/v1/projects/elitenew-f0b99/messages:send';
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
      },
    },
  });

  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Notification sent successfully to $name');
    } else {
      print('Failed to send notification: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print("Error sending notification: $e");
  }
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
      home: const StartPage(),
    );
  }
}

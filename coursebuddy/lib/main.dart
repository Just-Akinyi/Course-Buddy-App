import 'package:coursebuddy/assets/theme/app_theme.dart';
import 'package:coursebuddy/widgets/auth_gate.dart';
import 'package:coursebuddy/widgets/global_fcm_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Firebase Messaging for FCM
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  String? token = await messaging.getToken();
  if (kDebugMode) {
    print("FCM Token: $token"); // only prints in debug
  }
  // print("FCM Token: $token");

  // Listen for messages while the app is in the foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      if (kDebugMode) {
        print(
          'Notification: ${message.notification!.title}',
        ); // only prints in debug
      }

      // print('Notification: ${message.notification!.title}');
    }
  });

  // Initialize Firebase Crashlytics for error reporting
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalFcmListener(
      child: MaterialApp(
        title: 'CourseBuddy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

// Proceed to build the admin UI and Cloud Function, knowing unauthorized access is prevented.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// 🚀 Tonight’s Phase 3 Plan
// 1. 🎨 Admin UI: "Add User" Screen
// Create a new screen under lib/screens/admin/add_user_screen.dart

// Form fields:

// Email

// Role (dropdown: student, teacher, parent)

// LinkedTo field (showable only if role is teacher or parent)

// Use the existing SharedButton as the submit button

// 2. ☁️ Backend: Cloud Function Setup
// Initialize Firebase Functions (Node.js / TypeScript):

// firebase init functions

// Install firebase-admin

// Define a callable function createUser() that:

// Checks if the requesting user (via context.auth.uid) has role == 'admin' in Firestore

// Creates new Firebase Auth user via Admin SDK

// Writes users/{uid} and roles/{uid} documents

// Returns success or error

// 3. ✏️ Integrate Function in Flutter
// Use cloud_functions package to call the function from the Admin UI

// Handle success: show confirmation dialog, clear form

// Handle errors: use showError(...)

// ✅ Summary Checklist Tonight
//  Create AddUserScreen UI

//  Initialize Firebase Functions

//  Implement createUser Cloud Function

//  Connect Flutter to function and test admin flow

//  Update Firestore security rules

import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'widgets/global_fcm_listener.dart'; // ✅ add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Catch Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Catch any async errors
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
      // ✅ wrap your entire app
      child: MaterialApp(
        title: 'CourseBuddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
        // home: AuthGate(),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthGate(),
          '/login': (context) => const LoginScreen(),
          // Optional: add direct routes to dashboards if needed
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("An error occurred.")),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) {
          return const LoginScreen();
        }

        // Wait a frame and route the user
        // Delay navigation to avoid rebuild conflicts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _authService.routeUserAfterLogin(snapshot.data!.uid, ctx);
        });

        return const SizedBox(); // Return empty while redirecting
      },
    );
  }
}

// add global error logging (e.g. Firebase Crashlytics or Sentry) or UI-level error dialogs✅

// Add bottom navigation/tab UIs for each dashboard

// Implement role-specific functionality (admin links, content sharing, etc.)

// Let me know if you'd like:

// 🔁 A ZIP of this organized starter✅

// ✅ Or we jump straight into the Admin dashboard logic phase

// You're doing great — ready when you are!

//***********************
// You need to save each user’s FCM token in Firestore so:

// Admins/teachers can send messages to specific users

// Parents can be notified about their children

// Students get class/quiz updates
// Add Token Saving in AuthService
// We'll do it immediately after a successful login:

// 🔁 Update signInWithGoogle() in auth_service.dart:

// import 'package:firebase_messaging/firebase_messaging.dart';

// Future<void> signInWithGoogle(BuildContext context) async {
//   try {
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) return;

//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     final userCredential = await _auth.signInWithCredential(credential);
//     final uid = userCredential.user!.uid;

//     // ✅ Save FCM token
//     final fcmToken = await FirebaseMessaging.instance.getToken();
//     if (fcmToken != null) {
//       await FirebaseFirestore.instance.collection('fcmTokens').doc(uid).set({
//         'token': fcmToken,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     }

//     await routeUserAfterLogin(uid, context);
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Sign-in failed: $e')),
//     );
//   }
// }

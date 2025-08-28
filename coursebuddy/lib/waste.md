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

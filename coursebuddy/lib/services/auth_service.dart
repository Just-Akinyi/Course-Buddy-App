import 'package:coursebuddy/utils/error_util.dart';
import 'package:coursebuddy/utils/user_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      final uid = user.uid;
      final email = user.email;

      if (email == null) {
        showError(context, "Google account has no email.");
        return;
      }

      // Save/update FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          'fcmToken': fcmToken,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Route to dashboard using shared helper
      final target = await getDashboardForUser(email);
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => target));
    } catch (e, stack) {
      showError(context, e, stack);
    }
  }
}

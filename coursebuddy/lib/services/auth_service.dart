import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../utils/error_util.dart';

import '../screens/admin/admin_dashboard.dart';
import '../screens/teacher/teacher_dashboard.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/parent/parent_dashboard.dart';
import '../screens/not_registered_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with Google, keep logged-in users even if not registered
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

      await routeUserAfterLogin(email, context);
    } catch (e, stack) {
      showError(context, e, stack);
    }
  }

  /// Checks Firestore collections to route user dynamically
  Future<void> routeUserAfterLogin(String email, BuildContext context) async {
    try {
      late final Widget target;

      // Check in students
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(email)
          .get();
      if (studentDoc.exists && studentDoc.data() != null) {
        final Map<String, dynamic> studentData = Map<String, dynamic>.from(
          studentDoc.data()!,
        );
        final courseId =
            studentData['courseId']?.toString() ?? "default_course";
        target = StudentDashboard(courseId: courseId);
      } else {
        // Check in parents
        final parentDoc = await FirebaseFirestore.instance
            .collection('parents')
            .doc(email)
            .get();
        if (parentDoc.exists) {
          target = ParentDashboard();
        } else {
          // Check in teachers
          final teacherDoc = await FirebaseFirestore.instance
              .collection('teachers')
              .doc(email)
              .get();
          if (teacherDoc.exists) {
            target = TeacherDashboard();
          } else {
            // Check in admins
            final adminDoc = await FirebaseFirestore.instance
                .collection('admins')
                .doc(email)
                .get();
            if (adminDoc.exists) {
              target = AdminDashboard();
            } else {
              // Not registered → keep logged in, show message
              target = NotRegisteredScreen();
            }
          }
        }
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => target));
    } catch (e, stack) {
      showError(context, e, stack);
    }
  }
}

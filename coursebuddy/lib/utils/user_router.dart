import 'package:coursebuddy/screens/admin/admin_dashboard.dart';
import 'package:coursebuddy/screens/guest/not_registered_screen.dart';
import 'package:coursebuddy/screens/parent/parent_dashboard.dart';
import 'package:coursebuddy/screens/student/student_dashboard.dart';
import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Returns the correct dashboard widget for a given user email.
/// NOTE: This function does NOT use BuildContext and therefore
/// should NOT check `mounted` internally. The caller must guard
/// before using `context` (e.g., before navigation).
Future<Widget> getDashboardForUser(String email, {bool mounted = true}) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Students
    final studentDoc = await firestore.collection('students').doc(email).get();
    if (studentDoc.exists) {
      final courseId =
          studentDoc.data()?['courseId']?.toString() ?? "default_course";
      return StudentDashboard(courseId: courseId);
    }

    // Parents
    final parentDoc = await firestore.collection('parents').doc(email).get();
    if (parentDoc.exists) {
      return ParentDashboard();
    }

    // Teachers
    final teacherDoc = await firestore.collection('teachers').doc(email).get();
    if (teacherDoc.exists) {
      return TeacherDashboard();
    }

    // Admins
    final adminDoc = await firestore.collection('admins').doc(email).get();
    if (adminDoc.exists) {
      return AdminDashboard();
    }

    // Guests (create a guest record if missing)
    final guestDoc = await firestore.collection("guests").doc(email).get();
    if (!guestDoc.exists) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await firestore.collection("guests").doc(email).set({
          "uid": user.uid,
          "email": email,
          "name": user.displayName ?? "Guest User",
          "status": "waiting_approval",
          "createdAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    return const NotRegisteredScreen();
  } catch (_) {
    // On any error, default to NotRegisteredScreen (safe fallback).
    return const NotRegisteredScreen();
  }
}

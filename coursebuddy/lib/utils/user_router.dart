import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/admin/admin_dashboard.dart';
import '../screens/teacher/teacher_dashboard.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/parent/parent_dashboard.dart';
import '../screens/Guest/not_registered_screen.dart';

/// Returns the correct dashboard widget for a given user email.
Future<Widget> getDashboardForUser(String email) async {
  final studentDoc = await FirebaseFirestore.instance
      .collection('students')
      .doc(email)
      .get();
  if (studentDoc.exists && studentDoc.data() != null) {
    final data = studentDoc.data()!;
    final courseId = data['courseId']?.toString() ?? "default_course";
    return StudentDashboard(courseId: courseId);
  }

  final parentDoc = await FirebaseFirestore.instance
      .collection('parents')
      .doc(email)
      .get();
  if (parentDoc.exists) return ParentDashboard();

  final teacherDoc = await FirebaseFirestore.instance
      .collection('teachers')
      .doc(email)
      .get();
  if (teacherDoc.exists) return TeacherDashboard();

  final adminDoc = await FirebaseFirestore.instance
      .collection('admins')
      .doc(email)
      .get();
  if (adminDoc.exists) return AdminDashboard();

  return NotRegisteredScreen();
}

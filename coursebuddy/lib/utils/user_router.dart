import 'package:coursebuddy/screens/admin/admin_dashboard.dart';
import 'package:coursebuddy/screens/guest/not_registered_screen.dart';
import 'package:coursebuddy/screens/parent/parent_dashboard.dart';
import 'package:coursebuddy/screens/student/student_dashboard.dart';
import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

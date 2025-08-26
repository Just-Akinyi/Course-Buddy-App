import 'package:coursebuddy/assets/theme/app_theme.dart';
import 'package:coursebuddy/models/chat.dart';
import 'package:coursebuddy/screens/teacher/material_upload_screen.dart';
import 'package:coursebuddy/screens/teacher/quiz_submission_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedCourseId;
  List<Map<String, dynamic>> courses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final teacherEmail = FirebaseAuth.instance.currentUser?.email;
    if (teacherEmail == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('teacherEmail', isEqualTo: teacherEmail)
        .get();

    final loadedCourses = snapshot.docs
        .map(
          (doc) => {
            'id': doc.id.toString(),
            'name': (doc.data()['name'] ?? doc.id).toString(),
          },
        )
        .toList();

    setState(() {
      courses = loadedCourses;
      if (courses.isNotEmpty) selectedCourseId = courses.first['id'] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCourseId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.secondaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.upload_file), text: 'Materials'),
            Tab(icon: Icon(Icons.quiz), text: 'Quizzes'),
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
          ],
        ),
        actions: [
          if (courses.isNotEmpty)
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCourseId,
                dropdownColor: AppTheme.primaryColor,
                icon: Icon(Icons.arrow_drop_down, color: AppTheme.textColor),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCourseId = value;
                    });
                  }
                },
                items: courses
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c['id'] as String,
                        child: Text(
                          c['name'] as String,
                          style: TextStyle(color: AppTheme.textColor),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MaterialUploadScreen(courseId: selectedCourseId!),
          QuizSubmissionScreen(courseId: selectedCourseId!),
          TeacherChatParentList(courseId: selectedCourseId!),
        ],
      ),
    );
  }
}

/// Chat tab: shows all parents for a course
class TeacherChatParentList extends StatelessWidget {
  final String courseId;
  const TeacherChatParentList({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final teacherEmail = FirebaseAuth.instance.currentUser?.email;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .where('courseId', isEqualTo: courseId)
          .where('assignedTeacher', isEqualTo: teacherEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data!.docs;
        if (students.isEmpty) {
          return const Center(child: Text('No students assigned yet.'));
        }

        final parents = <String>{};
        for (var s in students) {
          final parentEmail = s['parentEmail'] as String?;
          if (parentEmail != null) parents.add(parentEmail);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: parents
              .map(
                (p) => ListTile(
                  title: Text(p, style: TextStyle(color: AppTheme.textColor)),
                  trailing: IconButton(
                    icon: Icon(Icons.chat, color: AppTheme.primaryColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(otherUserEmail: p),
                        ),
                      );
                    },
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

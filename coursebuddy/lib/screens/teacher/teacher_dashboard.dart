import 'package:coursebuddy/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'material_upload_screen.dart';
import 'quiz_submission_screen.dart';

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
        bottom: TabBar(
          controller: _tabController,
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
                dropdownColor: Colors.blue,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
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
                          style: const TextStyle(color: Colors.white),
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
                  title: Text(p),
                  trailing: IconButton(
                    icon: const Icon(Icons.chat, color: Colors.blue),
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

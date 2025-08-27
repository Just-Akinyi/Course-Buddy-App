import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'student_materials_screen.dart';

class StudentDashboard extends StatelessWidget {
  final String courseId;

  const StudentDashboard({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final quizRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('quizzes')
        .where('isActive', isEqualTo: true);

    final projectRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('projects')
        .where('isActive', isEqualTo: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📚 Your Materials',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentMaterialsScreen(courseId: courseId),
                  ),
                );
              },
              child: const Text('Go to Materials'),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const Text(
              '📝 Quizzes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            StreamBuilder(
              stream: quizRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Text('🕒 No active quizzes yet.');
                }
                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    return ListTile(
                      title: Text(data['title'] ?? 'Untitled Quiz'),
                      trailing: const Icon(Icons.play_circle_outline),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Open Quiz: ${data['title'] ?? 'Untitled'}",
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(),
            const Text(
              '💼 Projects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            StreamBuilder(
              stream: projectRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Text('🕒 No active projects yet.');
                }
                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    return ListTile(
                      title: Text(data['title'] ?? 'Untitled Project'),
                      trailing: const Icon(Icons.assignment),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Open Project: ${data['title'] ?? 'Untitled'}",
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

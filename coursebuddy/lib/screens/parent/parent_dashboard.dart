import 'package:coursebuddy/assets/theme/app_theme.dart';
import 'package:coursebuddy/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  late final FirebaseMessaging _messaging;
  List<Map<String, dynamic>> children = [];

  @override
  void initState() {
    super.initState();
    _setupFCM();
    _loadChildren();
  }

  Future<void> _setupFCM() async {
    _messaging = FirebaseMessaging.instance;
    await _messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return;
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification!.body ?? "New update"),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    });
  }

  Future<void> _loadChildren() async {
    final parentEmail = FirebaseAuth.instance.currentUser?.email;
    if (parentEmail == null) return;

    final childQuery = await FirebaseFirestore.instance
        .collection('students')
        .where('parentEmail', isEqualTo: parentEmail)
        .get();

    if (!mounted) return;

    final loadedChildren = childQuery.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'name': (data['name'] ?? 'Unnamed') as String,
        'courseId': (data['courseId'] ?? 'N/A') as String,
        'assignedTeacher':
            (data['assignedTeacher'] ?? 'Not assigned') as String,
        'progress': (data['progress'] ?? 0).toDouble(),
        'classesTaken': data['classesTaken'] ?? 0,
        'totalClasses': data['totalClasses'] ?? 0,
        'topics': List<String>.from(data['topics'] ?? []),
        'quizResults': List<Map<String, dynamic>>.from(
          data['quizResults'] ?? [],
        ),
      };
    }).toList();

    setState(() {
      children = loadedChildren;
    });
  }

  void _openTeacherChat(String teacherEmail) {
    if (teacherEmail == 'Not assigned' || teacherEmail.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("A teacher has not been assigned yet.")),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(otherUserEmail: teacherEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: children.isEmpty
          ? Center(
              child: Text(
                'No children found.',
                style: TextStyle(color: AppTheme.textColor),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                final progress = (child['progress'] as double? ?? 0.0);
                final classesTaken = child['classesTaken'] as int? ?? 0;
                final totalClasses = child['totalClasses'] as int? ?? 0;
                final remainingClasses = totalClasses - classesTaken;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: Child name and Chat button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              child['name'] as String? ?? 'Unnamed',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _openTeacherChat(
                                child['assignedTeacher'] as String? ?? '',
                              ),
                              icon: const Icon(Icons.chat, color: Colors.white),
                              label: const Text("Chat"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Course: ${child['courseId'] ?? 'N/A'}',
                          style: TextStyle(color: AppTheme.textColor),
                        ),
                        Text(
                          'Teacher: ${child['assignedTeacher'] ?? 'Not assigned'}',
                          style: const TextStyle(color: Color(0xB3000000)),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 8,
                          backgroundColor: const Color(0x4D03A9F4),
                          color: AppTheme.primaryColor,
                        ),
                        Text(
                          'Progress: ${progress.toStringAsFixed(0)}%',
                          style: TextStyle(color: AppTheme.textColor),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Classes Taken: $classesTaken',
                              style: TextStyle(color: AppTheme.textColor),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Remaining: $remainingClasses',
                              style: TextStyle(color: AppTheme.textColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Topics Covered:',
                          style: TextStyle(color: AppTheme.textColor),
                        ),
                        Wrap(
                          spacing: 6,
                          children: (child['topics'] as List<String>? ?? [])
                              .map(
                                (t) => Chip(
                                  label: Text(t),
                                  backgroundColor: const Color(0x4D03A9F4),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Quiz Results:',
                          style: TextStyle(color: AppTheme.textColor),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              (child['quizResults']
                                          as List<Map<String, dynamic>>? ??
                                      [])
                                  .map<Widget>(
                                    (quiz) => Text(
                                      "${quiz['topic'] ?? 'N/A'}: ${quiz['result'] ?? 'N/A'}",
                                      style: TextStyle(
                                        color: AppTheme.textColor,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

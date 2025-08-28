import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursebuddy/assets/theme/app_theme.dart';

class QuizSubmissionScreen extends StatelessWidget {
  const QuizSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Submissions"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quiz_submissions')
            .orderBy('submittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading submissions"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final submissions = snapshot.data!.docs;
          if (submissions.isEmpty) {
            return const Center(child: Text("No submissions yet"));
          }

          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final data = submissions[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['studentEmail'] ?? "Unknown"),
                subtitle: Text("Score: ${data['score'] ?? 'N/A'}"),
                trailing: Text(
                  data['submittedAt'] != null
                      ? (data['submittedAt'] as Timestamp).toDate().toString()
                      : "Pending",
                ),
              );
            },
          );
        },
      ),
    );
  }
}

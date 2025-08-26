import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ✅ New Features:
// Student Dropdown (pulled from Firestore under /courses/{courseId}/students)

// Automatic quizId naming → e.g. unit3_quiz->?**i'm not sure yet

// Cloud Function trigger-ready → We’ll remove passed so Firebase Cloud Function can compute it

class QuizSubmissionScreen extends StatefulWidget {
  final String courseId;

  const QuizSubmissionScreen({Key? key, required this.courseId})
    : super(key: key);

  @override
  State<QuizSubmissionScreen> createState() => _QuizSubmissionScreenState();
}

class _QuizSubmissionScreenState extends State<QuizSubmissionScreen> {
  final quizTitleController = TextEditingController();
  final scoreController = TextEditingController();
  final maxScoreController = TextEditingController();

  String? selectedStudentId;
  bool isLoading = false;

  /// 🔁 Fetch students from Firestore
  Future<List<Map<String, dynamic>>> fetchStudents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('students')
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, 'name': doc.data()['name'] ?? 'Unnamed'})
        .toList();
  }

  Future<void> _submitQuiz() async {
    final quizTitle = quizTitleController.text.trim();
    final score = int.tryParse(scoreController.text.trim());
    final maxScore = int.tryParse(maxScoreController.text.trim());

    if (selectedStudentId == null ||
        quizTitle.isEmpty ||
        score == null ||
        maxScore == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    /// 🆔 Auto-generate quiz ID from title
    final quizId = quizTitle.toLowerCase().replaceAll(" ", "_");

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('students')
          .doc(selectedStudentId)
          .collection('quizzes')
          .doc(quizId)
          .set({
            'quizTitle': quizTitle,
            'score': score,
            'maxScore': maxScore,
            // 'passed': true, ❌ let Cloud Function handle it
            'timestamp': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Quiz submitted')));

      quizTitleController.clear();
      scoreController.clear();
      maxScoreController.clear();
      setState(() => selectedStudentId = null);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    quizTitleController.dispose();
    scoreController.dispose();
    maxScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchStudents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final students = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStudentId,
                  hint: const Text('Select Student'),
                  onChanged: (value) => setState(() {
                    selectedStudentId = value;
                  }),
                  items: students
                      .map(
                        (student) => DropdownMenuItem<String>(
                          value: student['id'],
                          child: Text(student['name']),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quizTitleController,
                  decoration: const InputDecoration(labelText: 'Quiz Title'),
                ),
                TextField(
                  controller: scoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Score'),
                ),
                TextField(
                  controller: maxScoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max Score'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _submitQuiz,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Submit'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// how to Use
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => QuizSubmissionScreen(
//       courseId: 'abc123',
//       studentId: 'student_uid_here',
//     ),
//   ),
// );
// *****

// ✅ Notify linked parent?

// 📜 Show all past quizzes per student?

// 🎓 Show quiz result summary per course?

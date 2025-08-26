// ✅ Updated MaterialUploadScreen with styled, dismissible status box
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class MaterialUploadScreen extends StatefulWidget {
  final String courseId;
  const MaterialUploadScreen({required this.courseId, Key? key})
    : super(key: key);

  @override
  State<MaterialUploadScreen> createState() => _MaterialUploadScreenState();
}

class _MaterialUploadScreenState extends State<MaterialUploadScreen> {
  int currentSession = 1;
  bool showStatusBanner = true;

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      final storageRef = FirebaseStorage.instance.ref(
        'courses/${widget.courseId}/materials/${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );

      final uploadTask = await storageRef.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();

      await _uploadAndSave(fileName, url);
    }
  }

  Future<void> _uploadAndSave(String name, String storageUrl) async {
    final doc = FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('materials')
        .doc();

    await doc.set({
      'title': name,
      'url': storageUrl,
      'isSent': false,
      'sessionNumber': currentSession,
    });
  }

  Future<void> _markAsSent(String materialId) async {
    final courseRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId);

    // 1. Mark the material as sent
    await courseRef.collection('materials').doc(materialId).update({
      'isSent': true,
      'sentAt': FieldValue.serverTimestamp(),
    });

    // 2. Count how many sessions have been sent
    final sentMaterialsSnapshot = await courseRef
        .collection('materials')
        .where('isSent', isEqualTo: true)
        .get();

    final sentSessions = sentMaterialsSnapshot.docs
        .map((d) => d['sessionNumber'])
        .toSet()
        .length;

    // 3. Check if totalSessions have been sent
    final courseSnap = await courseRef.get();
    final totalSessions = courseSnap.data()?['totalSessions'] ?? 0;

    if (sentSessions >= totalSessions) {
      // Mark course as completed
      await courseRef.update({'isCompleted': true});

      // Activate quizzes and projects
      final quizSnap = await courseRef.collection('quizzes').get();
      for (final doc in quizSnap.docs) {
        await doc.reference.update({'isActive': true});
      }

      final projectSnap = await courseRef.collection('projects').get();
      for (final doc in projectSnap.docs) {
        await doc.reference.update({'isActive': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('materials')
        .orderBy('sessionNumber', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickAndUploadFile,
          ),
        ],
      ),
      body: Column(
        children: [
          DropdownButton<int>(
            value: currentSession,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  currentSession = value;
                });
              }
            },
            items: List.generate(10, (i) => i + 1)
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e,
                    child: Text('Session $e'),
                  ),
                )
                .toList(),
          ),

          // ✅ Stylish, auto-refreshing, dismissible status box
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('courses')
                .doc(widget.courseId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !showStatusBanner) {
                return const SizedBox.shrink();
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final isCompleted = data['isCompleted'] ?? false;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Dismissible(
                  key: const ValueKey('statusBanner'),
                  direction: DismissDirection.horizontal,
                  onDismissed: (_) {
                    setState(() {
                      showStatusBanner = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      border: Border.all(
                        color: isCompleted ? Colors.green : Colors.orange,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.access_time_filled,
                          color: isCompleted
                              ? Colors.green
                              : Colors.orangeAccent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isCompleted
                                ? '✅ Course marked complete!'
                                : '⏳ Course in progress',
                            style: TextStyle(
                              color: isCompleted
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Icon(Icons.close, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // 📦 Display uploaded materials
          Expanded(
            child: StreamBuilder(
              stream: materialRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final id = docs[index].id;

                    return ListTile(
                      title: Text(data['title'] ?? 'No Title'),
                      subtitle: Text('Session ${data['sessionNumber']}'),
                      trailing: data['isSent'] == true
                          ? const Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () => _markAsSent(id),
                              child: const Text('Mark as Sent'),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// | Feature                               | Status                       |
// | ------------------------------------- | ---------------------------- |
// | Materials upload + mark as sent       | ✅ Already implemented        |
// | Check if all sessions sent            | ✅ New logic added            |
// | Mark course complete                  | ✅ New logic added            |
// | Unlock quiz/project after full course | ✅ New logic added            |
// | Track `isCompleted`, `totalSessions`  | ✅ Stored on course doc       |
// | Quizzes/projects use `isActive`       | ✅ Already in Firestore rules |
// TOPUP
// A refresh button to reset the dismissed banner

// Toast/snackbar when course becomes complete

// Animated transitions or confetti when course completes 🎉

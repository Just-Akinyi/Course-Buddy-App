import 'dart:io';
import 'package:coursebuddy/assets/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

    await courseRef.collection('materials').doc(materialId).update({
      'isSent': true,
      'sentAt': FieldValue.serverTimestamp(),
    });

    final sentMaterialsSnapshot = await courseRef
        .collection('materials')
        .where('isSent', isEqualTo: true)
        .get();

    final sentSessions = sentMaterialsSnapshot.docs
        .map((d) => d['sessionNumber'])
        .toSet()
        .length;

    final courseSnap = await courseRef.get();
    final totalSessions = courseSnap.data()?['totalSessions'] ?? 0;

    if (sentSessions >= totalSessions) {
      await courseRef.update({'isCompleted': true});

      final quizSnap = await courseRef.collection('quizzes').get();
      for (final doc in quizSnap.docs) {
        await doc.reference.update({'isActive': true});
      }

      final projectSnap = await courseRef.collection('projects').get();
      for (final doc in projectSnap.docs) {
        await doc.reference.update({'isActive': true});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Course completed! Quizzes/projects unlocked."),
        ),
      );
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
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickAndUploadFile,
          ),
        ],
      ),
      body: Column(
        children: [
          // Session dropdown
          DropdownButton<int>(
            value: currentSession,
            onChanged: (value) {
              if (value != null) setState(() => currentSession = value);
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

          // ✅ Stylish, dismissible status box
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
                  onDismissed: (_) => setState(() => showStatusBanner = false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(
                              0x1AFF9800,
                            ) // primaryColor at 10% opacity
                          : const Color(
                              0x1A03A9F4,
                            ), // secondaryColor at 10% opacity
                      border: Border.all(
                        color: isCompleted
                            ? AppTheme.primaryColor
                            : AppTheme.secondaryColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0x1A000000), // black at 10% opacity
                          blurRadius: 4,
                          offset: Offset(0, 2),
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
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isCompleted
                                ? '✅ Course marked complete!'
                                : '⏳ Course in progress',
                            style: TextStyle(
                              color: isCompleted
                                  ? AppTheme.primaryColor
                                  : AppTheme.secondaryColor,
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

          // Materials list
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
                      title: Text(
                        data['title'] ?? 'No Title',
                        style: TextStyle(color: AppTheme.textColor),
                      ),
                      subtitle: Text(
                        'Session ${data['sessionNumber']}',
                        style: const TextStyle(
                          color: Color(0xB3000000), // textColor at 70% opacity
                        ),
                      ),
                      trailing: data['isSent'] == true
                          ? Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () => _markAsSent(id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                              ),
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

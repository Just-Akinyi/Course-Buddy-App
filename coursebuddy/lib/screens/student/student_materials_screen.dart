import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentMaterialsScreen extends StatelessWidget {
  final String courseId;

  const StudentMaterialsScreen({super.key, required this.courseId});

  Future<void> _openMaterial(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Materials')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('materials')
            .where('isSent', isEqualTo: true)
            .orderBy('sessionNumber')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final materials = snapshot.data?.docs ?? [];
          if (materials.isEmpty) {
            return const Center(child: Text('No materials sent yet.'));
          }

          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final material = materials[index].data() as Map<String, dynamic>;
              final url = material['url'] ?? "";

              return ListTile(
                leading: const Icon(Icons.description),
                title: Text(material['title'] ?? "Untitled Material"),
                subtitle: Text('Session ${material['sessionNumber']}'),
                onTap: () {
                  if (url.isNotEmpty) {
                    _openMaterial(url); // 🚀 open directly on tap
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No URL available')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

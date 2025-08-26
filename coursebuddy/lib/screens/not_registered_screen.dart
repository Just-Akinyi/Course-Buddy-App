import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotRegisteredScreen extends StatefulWidget {
  const NotRegisteredScreen({super.key});

  @override
  State<NotRegisteredScreen> createState() => _NotRegisteredScreenState();
}

class _NotRegisteredScreenState extends State<NotRegisteredScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isSaving = false;

  Future<void> _saveGuestUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final email = user.email ?? "unknown@example.com"; // ✅ safer fallback
      final uid = user.uid;
      final name = user.displayName ?? "Guest User";

      await _firestore.collection("guests").doc(email).set({
        "uid": uid,
        "email": email,
        "name": name,
        "status": "unregistered",
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You have been added as a Guest.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Not Registered")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off,
                size: 70,
                color: Colors.red,
              ), // ✅ friendlier
              const SizedBox(height: 20),
              const Text(
                "You are not registered yet.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (user != null)
                Text(
                  "Logged in as: ${user.email}",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveGuestUser,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save as Guest"),
              ),
              const SizedBox(height: 15),
              const Text(
                "An admin will review your account and assign a role.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

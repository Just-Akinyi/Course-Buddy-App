import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursebuddy/utils/user_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotRegisteredScreen extends StatelessWidget {
  const NotRegisteredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not signed in")));
    }

    final email = user.email!;
    final uid = user.uid;

    // Save the FCM token for this guest user
    _saveGuestToken(uid);

    return Scaffold(
      appBar: AppBar(title: const Text("Awaiting Approval")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("guests")
            .doc(email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ If still in guests → show waiting message
          if (snapshot.hasData && snapshot.data!.exists) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Hello ${user.displayName ?? "Guest"},\n\n"
                "Your account has been saved. An admin will review and assign your role soon.\n"
                "You’ll be notified once approved.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          // ✅ If doc is deleted from guests, check if admin moved them
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final role = userSnapshot.data!['role'] ?? 'member';

                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!context.mounted) return;

                  // Show snackbar with role info
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "✅ You’ve been approved as a $role!",
                        style: const TextStyle(fontSize: 16),
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );

                  // Navigate after showing snackbar
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (!context.mounted) return;

                  final dashboard = await getDashboardForUser(email);
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => dashboard),
                  );
                });
              }

              return const Center(
                child: Text(
                  "Checking your approval status...",
                  style: TextStyle(fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper function to save the FCM token
  void _saveGuestToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection("guestTokens").doc(uid).set({
        "token": token,
      });
    }
  }
}

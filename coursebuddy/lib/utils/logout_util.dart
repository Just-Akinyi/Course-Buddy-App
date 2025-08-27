import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> logout(BuildContext context, {bool mounted = true}) async {
  try {
    // Try to sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Try to sign out from Google (ignore if not signed-in there)
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // No-op: GoogleSignIn may not be initialized or user may not be signed-in via Google
    }
  } finally {
    // ✅ Guard context after async
    if (!context.mounted || !mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

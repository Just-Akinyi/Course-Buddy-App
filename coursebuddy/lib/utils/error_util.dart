import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void showError(BuildContext context, Object error, [StackTrace? stackTrace]) {
  // Log to Crashlytics
  FirebaseCrashlytics.instance.recordError(error, stackTrace);

  // ScaffoldMessenger.of(
  //   context,
  // ).showSnackBar(SnackBar(content: Text(error.toString())));

  // Optional: Convert error to user-friendly message
  final errorMessage = error.toString().replaceFirst('Exception: ', '');

  // Show user-friendly dialog
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 8),
          Text("Oops!"),
        ],
      ),
      content: Text(errorMessage),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

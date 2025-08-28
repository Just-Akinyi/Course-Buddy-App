import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> showError(
  BuildContext context,
  Object error, [
  StackTrace? stackTrace,
  bool mounted = true,
]) async {
  // Log to Crashlytics
  try {
    await FirebaseCrashlytics.instance.recordError(error, stackTrace);
  } catch (_) {
    // fail silently if Crashlytics not available
  }

  final errorMessage = error.toString().replaceFirst('Exception: ', '');

  if (!context.mounted || !mounted) return;

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

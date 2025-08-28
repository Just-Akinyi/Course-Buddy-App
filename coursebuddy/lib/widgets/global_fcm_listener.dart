import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class GlobalFcmListener extends StatefulWidget {
  final Widget child;

  const GlobalFcmListener({required this.child, super.key});

  @override
  State<GlobalFcmListener> createState() => _GlobalFcmListenerState();
}

class _GlobalFcmListenerState extends State<GlobalFcmListener> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      if (!mounted) return;
      final notif = msg.notification;
      if (notif != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(notif.title ?? 'New Notification'),
            content: Text(notif.body ?? 'You have a new message'),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

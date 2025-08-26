import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();

  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
}

// use on dashboards
// appBar: AppBar(
//   title: Text("Student Dashboard"),
//   actions: [
//     IconButton(
//       icon: Icon(Icons.logout),
//       onPressed: () => logout(context),
//     ),
//   ],
// ),

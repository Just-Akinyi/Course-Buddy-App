// Deploy the function with Blaze plan or use the Emulator for local testing.
// 1. Local Emulator Setup (since Blaze isn't an option)
// 2. Cloud Function Testing
// *********
// upgrade to use storage and crashlytics
// **************
// 1. Create a User in Firebase Auth Console(First admin)
// Go to Firebase Console → Authentication → Users → Add User.

// Create an account with an email, password, and name of your choice.

// 2. Add Their Role in Firestore
// In Firestore → Data, create a document in the roles collection.

// Use the new user's UID (shown in the Auth console).

// Set the data:

// {
//   "role": "admin",
//   "name": "Your Name",
//   "linkedTo": []
// }
import 'package:flutter/material.dart';
import '../../widgets/shared_button.dart';
import '../../utils/error_util.dart';
import 'add_user_screen.dart';
import 'user_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SharedButton(
              label: 'Add User',
              icon: Icons.person_add,
              onPressed: () {
                try {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddUserScreen()),
                  );
                } catch (e, s) {
                  showError(context, e, s);
                }
              },
            ),
            const SizedBox(height: 16),
            SharedButton(
              label: 'Manage Guests',
              icon: Icons.manage_accounts,
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const UserListScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

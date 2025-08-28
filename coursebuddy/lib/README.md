# CourseBuddy

upgrade to blaze then run
firebase deploy --only firestore:rules,firestore:indexes,functions,hosting
(((((((((((((((())))))))))))))))
✅ Summary Test Checklist
 Firebase config files in the project

 Correct dependency versions installed

 Crashlytics set up and global errors caught

 Google sign-in works + dashboard routing

 Logout works cleanly

 Critical errors show UI dialog and log in Crashlytics

 Force crash test → appears in console

 (If enabled) FCM token saved & notifications tested

 Firestore read/write obey rules
 (((((((((())))))))))
 Test using the Firestore rules simulator (in the Rules tab):

Authenticated non-admin cannot write to /roles/otherUid.

Admin can write to any roles/… doc.

Users can read/write to their own user doc only.
(((((((((((((((((((())))))))))))))))))))
🔍 Phase 1–3 Test Checklist
✅ 1. Authentication & Role Routing
 Try signing in with Google Sign-In (both emulator and real).

 Use non-admin accounts (no roles/{uid} doc) and confirm error dialog appears.

 Use admin account (with roles/{uid} set to "admin") and ensure navigation to Admin Dashboard.

✅ 2. Error Handling & Crashlytics Setup
 Trigger a test error in the app to see the dialog popup and confirm it's logged in Crashlytics (emulator/local).

 Cause a minor navigation error or invalid form submission to test showError() and Crashlytics integration.

✅ 3. Firestore Security Rules
 Use emulator Rules Simulator to verify:

Users can read/write only their own users/{uid} doc.

Users can read their own roles/{uid} but not others’.

Only admins can create/update other roles/… docs.

 Try writing to unauthorized paths and confirm rules block access.

✅ 4. Cloud Functions (Admin Create User)
 Start the emulators:

sql
Copy
Edit
firebase emulators:start --only auth,firestore,functions
 In emulator UI:

Manually add an admin user and matching roles/{adminUid}.

 Configure your Flutter app to use emulator endpoints (useAuthEmulator, useFirestoreEmulator, useFunctionsEmulator).

 Log in as that admin in your app.

 Go to Admin Dashboard → Add User:

Fill form and press Create.

 In emulator UI:

Check Auth: new user exists.

Check Firestore: users/{newUid} and roles/{newUid} correctly created.

✅ 5. Linking Logic & linkedTo Field
 When creating a parent or teacher, provide linkedTo values.

 In emulator UI, confirm the roles/{uid} doc includes correct linkedTo array.

 In your app (in later phases): ensure teacher/parent dashboards correctly show linked users.

✅ 6. Overall App Workflow Testing
 Use non-admin user to verify they cannot access Add User flow.

 As admin, create a student or parent user.

 Test logging in as those new users (using emulator), ensuring proper dashboard & permissions work
 ((((((((((((((((((((((((()))))))))))))))))))))))))

Complete setup instructions for Firebase, roles, and FCM.
FOR WEB**************************
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDN4zXu3vXjjnj00z5MSPx42acDXyrgTgI",
        authDomain: "coursebuddy-ba697.firebaseapp.com",
        projectId: "coursebuddy-ba697",
        storageBucket: "coursebuddy-ba697.firebasestorage.app",
        messagingSenderId: "1050759747238",
        appId: "1:1050759747238:web:6976beddb9e2ff832dc667",
        measurementId: "G-FLZZX5GQ87",
      ),
    );
  } else {
    await Firebase.initializeApp(); // Android & iOS use google-services.json
  }

  runApp(const MyApp());
}
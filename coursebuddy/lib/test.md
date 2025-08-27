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
Phase 5: Parent Dashboard Logic

View child’s course progress

Remaining sessions

Quiz results

In-app notifications

✅ Phase 1: Auth + Role Routing + Error Handling
✅ Phase 2: Firebase + Crashlytics + FCM Setup
🔄 Phase 3: Admin Flow — User Creation → Linking → Management
🔄 Phase 4: Content/Material Management + Notifications (currently active)
The Student Dashboard filtering by isActive is part of Phase 4.
We are not yet in Phase 5.
➡️ Phase 5: Parent Dashboard
Show child progress, notify remaining classes, quiz results, countdown

run
firebase deploy --only firestore:rules
and firebase deploy --only firestore:rules, functions
before any testing

✅ Phase 1: Auth + Role Routing + Error Handling

✅ Phase 2: Firebase + Crashlytics + FCM Setup

🔄 Phase 3: Admin Flow — User Creation → Linking → Management
Phase 4: content/material management and notifications 
********
✅ Best Option: Upload the notes (PDFs/videos) to Firebase Storage, then copy the download URL and use it as the url in Firestore.

🔁 Step-by-step:
Upload your file (e.g. PDF) to Firebase Storage.

Get the public download URL.

Paste that URL into the url field in Firestore.
**************************
When all that is implemented, testing follows:

Admin user creation

Linking relationships

Ensuring dashboards respect roles

Pushing to production or using emulators

*********
🚀 1. Configure Emulators in main.dart
So you can test everything locally without Blaze, add the following in main() before runApp(...):

await Firebase.initializeApp();

// Only in debug/testing:
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
🧪 2. Start the Emulator Suite
Run this in your project's terminal:

firebase emulators:start --only auth,firestore,functions
Navigate to http://localhost:4000 to manage Auth and Firestore emulator data.

👤 3. Create a Local Admin Account in Auth Emulator
In Emulator UI, go to Authentication → Users → Add user

Use any email/password (e.g. admin@local.test / password123)

Copy its UID from the UI

🛠️ 4. Assign Admin Role in Firestore Emulator
In the Firestore emulator panel, create a new document in roles/{UID}

Paste:

{
  "role": "admin",
  "name": "Local Admin",
  "linkedTo": []
}
📋 5. Test Your App’s Admin Flow
Launch your Flutter app (makes sure emulator config is active)

Sign in using the test admin account via Google or (if enabled) Email/Password

Navigate to Admin Dashboard → Add User

Try creating a new user — it should trigger the createUser Cloud Function

🧭 6. Verify in Emulator UI
Check Authentication and Firestore in the emulator dashboard

Should see a new user created under Auth

Should see new entries under users/{newUid} and roles/{newUid}

✅ Summary Checklist
 Add emulator setup in main.dart

 Start emulators (auth, firestore, functions)

 Create test admin user in emulator Auth

 Assign admin role in Firestore

 Run app and test Add User flow

 Confirm new user is created in emulator UI
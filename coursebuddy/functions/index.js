const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// ========== Authenticated Admin-Only User Creation ==========
exports.createUser = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Login required.');
  }

  // Check caller role from Firestore
  const callerRole = await admin.firestore().collection('roles').doc(context.auth.uid).get();
  if (!callerRole.exists || callerRole.data().role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can create users.');
  }

  const { email, password, displayName, role, linkedTo } = data;

  try {
    const userRecord = await admin.auth().createUser({ email, password, displayName });
    const uid = userRecord.uid;

    const now = admin.firestore.FieldValue.serverTimestamp();
    await admin.firestore().collection('users').doc(uid).set({ email, createdAt: now });
    await admin.firestore().collection('roles').doc(uid).set({ role, name: displayName, linkedTo: linkedTo ?? [] });

    return { status: 'success', uid };
  } catch (error) {
    console.error("Error creating user:", error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// ========== FCM Notification on isSent = true ==========
exports.notifyOnMaterial = functions.firestore
  .document('courses/{cid}/materials/{mid}')
  .onUpdate(async (snap, context) => {
    const before = snap.before.data();
    const after = snap.after.data();

    if (!before.isSent && after.isSent) {
      const courseId = context.params.cid;

      // 1. Get all students assigned to the course
      const roleQuery = await admin.firestore()
        .collection('roles')
        .where('role', '==', 'student')
        .get();

      const tokens = [];

      for (const doc of roleQuery.docs) {
        const studentData = doc.data();
        if (studentData.linkedTo?.includes(courseId)) {
          const userId = doc.id;
          const userDoc = await admin.firestore().collection('users').doc(userId).get();
          if (userDoc.exists && userDoc.data().fcmToken) {
            tokens.push(userDoc.data().fcmToken);
          }
        }
      }

      // 2. Send notification if we have tokens
      if (tokens.length > 0) {
        const payload = {
          notification: {
            title: `New material: ${after.title}`,
            body: `New content is available in your course.`,
          },
        };

        // ✅ Fixed spreading issue — use proper structure
        await admin.messaging().sendEachForMulticast({
          tokens,
          notification: payload.notification
        });
      }
    }
  });

// ========== Notify Parent on Session Completion ==========
exports.onSessionComplete = functions.firestore
  .document('courses/{courseId}/students/{studentId}/sessions/{sessionId}')
  .onUpdate(async (snap, context) => {
    const before = snap.before.data();
    const after = snap.after.data();

    // Only trigger when session gets marked as complete
    if (!before.completed && after.completed) {
      const studentId = context.params.studentId;

      // 1. Get linked parents
      const studentRoleDoc = await admin.firestore().collection('roles').doc(studentId).get();
      const linkedParents = studentRoleDoc.data().linkedTo ?? [];

      const tokens = [];

      for (const parentUid of linkedParents) {
        const parentUserDoc = await admin.firestore().collection('users').doc(parentUid).get();
        if (parentUserDoc.exists && parentUserDoc.data().fcmToken) {
          tokens.push(parentUserDoc.data().fcmToken);
        }
      }

      // 2. Send FCM to parents
      if (tokens.length > 0) {
        const payload = {
          notification: {
            title: `Class Completed`,
            body: `Your child just completed a class in their course.`,
          },
        };
        await admin.messaging().sendEachForMulticast({
          tokens,
          notification: payload.notification
        });
      }
    }
  });
  
// ========== Notify Parent on Quiz Result ==========
exports.onQuizResult = functions.firestore
  .document('courses/{courseId}/students/{studentId}/quizzes/{quizId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const { quizTitle, score, maxScore, passed } = data;
    const studentId = context.params.studentId;

    // 1. Get linked parents
    const studentRoleDoc = await admin.firestore().collection('roles').doc(studentId).get();
    const linkedParents = studentRoleDoc.data().linkedTo ?? [];

    const tokens = [];

    for (const parentUid of linkedParents) {
      const parentUserDoc = await admin.firestore().collection('users').doc(parentUid).get();
      if (parentUserDoc.exists && parentUserDoc.data().fcmToken) {
        tokens.push(parentUserDoc.data().fcmToken);
      }
    }

    // 2. Build message
    const safeScore = Number(score) || 0; // ✅ safer parsing
    const safeMax = Number(maxScore) || 10;
    const result = (passed !== undefined) ? passed : (safeScore >= safeMax * 0.5); // default 50% pass
    const status = result ? "passed" : "failed";
    const message = `Your child has ${status} the quiz "${quizTitle}".`;

    // 3. Send notification
    if (tokens.length > 0) {
      const payload = {
        notification: {
          title: `Quiz ${status.charAt(0).toUpperCase() + status.slice(1)}`,
          body: message,
        },
      };
      await admin.messaging().sendEachForMulticast({
        tokens,
        notification: payload.notification
      });
    }
  });

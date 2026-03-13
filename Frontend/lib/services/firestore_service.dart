import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FS {
  static final db = FirebaseFirestore.instance;

  // === Current user IDs ===
  static String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // === Streams: current user / volunteer documents ===
  static Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream(String uid) =>
      db.collection('users').doc(uid).snapshots();

  static Stream<DocumentSnapshot<Map<String, dynamic>>> volunteerDocStream(String uid) =>
      db.collection('volunteers').doc(uid).snapshots();

  // === Users: calls list ===
  static Stream<QuerySnapshot<Map<String, dynamic>>> userCalls(String userId) => db
      .collection('calls')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .snapshots();

  // === Volunteers: request an update (goes to admin for approval) ===
  static Future<void> requestVolunteerUpdate({
    required String volunteerId,
    required Map<String, dynamic> newData,
  }) async {
    await db.collection('volunteer_update_requests').add({
      'volunteerId': volunteerId,
      'newData': newData,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // === Volunteers: delete my profile ===
  static Future<void> deleteVolunteerProfile(String uid) =>
      db.collection('volunteers').doc(uid).delete();

  // === OPTIONAL: write a call record (if you log calls from app) ===
  // Cloud Function increments totalCalls (see backend section)
  static Future<void> logCall({
    required String userId,
    required DateTime timestamp,
    required int durationMinutes,
  }) async {
    await db.collection('calls').add({
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'durationMinutes': durationMinutes,
    });
  }
}

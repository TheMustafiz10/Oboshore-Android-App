// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;

// /// Admin Firestore + REST helpers
// class AdminFS {
//   static final db = FirebaseFirestore.instance;

//   // === Users table ===
//   static Stream<QuerySnapshot<Map<String, dynamic>>> allUsers() =>
//       db.collection('users').orderBy('createdAt', descending: true).snapshots();

//   static Stream<QuerySnapshot<Map<String, dynamic>>> userCalls(String userId) =>
//       db.collection('calls')
//         .where('userId', isEqualTo: userId)
//         .orderBy('timestamp', descending: true)
//         .snapshots();

//   // === Volunteers tables ===
//   static Stream<QuerySnapshot<Map<String, dynamic>>> volunteers({
//     String? type, // 'helpline' | 'non-helpline'
//     String? duty, // for non-helpline
//     String? slot, // for helpline
//   }) {
//     Query<Map<String, dynamic>> q = db.collection('volunteers');
//     if (type != null) q = q.where('type', isEqualTo: type);
//     if (duty != null && duty.isNotEmpty) q = q.where('duty', isEqualTo: duty);
//     if (slot != null && slot.isNotEmpty) q = q.where('timeSlots', arrayContains: slot);
//     return q.orderBy('updatedAt', descending: true).snapshots();
//   }

//   // === Pending update requests list ===
//   static Stream<QuerySnapshot<Map<String, dynamic>>> pendingUpdateRequests() =>
//       db.collection('volunteer_update_requests')
//         .where('status', isEqualTo: 'pending')
//         .orderBy('createdAt', descending: true)
//         .snapshots();

//   // === Approve/reject update request via REST Cloud Function ===
//   // Use your deployed function URL (see backend/index.js). Replace REGION and PROJECT_ID.
//   static const String baseFn =
//       'https://REGION-PROJECT_ID.cloudfunctions.net';

//   static Future<void> approveUpdateRequest(String requestId, {String? adminUid}) async {
//     final url = Uri.parse('$baseFn/approveVolunteerUpdate');
//     final res = await http.post(url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'requestId': requestId, 'adminUid': adminUid}));
//     if (res.statusCode != 200) {
//       throw Exception('Approve failed: ${res.body}');
//     }
//   }

//   static Future<void> rejectUpdateRequest(String requestId, {String? adminUid}) async {
//     final url = Uri.parse('$baseFn/rejectVolunteerUpdate');
//     final res = await http.post(url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'requestId': requestId, 'adminUid': adminUid}));
//     if (res.statusCode != 200) {
//       throw Exception('Reject failed: ${res.body}');
//     }
//   }
// }





// import 'package:cloud_firestore/cloud_firestore.dart';

// class FS {
//   static final db = FirebaseFirestore.instance;

//   // Users
//   static Future<void> createUserProfile(String uid, Map<String, dynamic> data) =>
//       db.collection('users').doc(uid).set(data, SetOptions(merge: true));

//   static Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) =>
//       db.collection('users').doc(uid).snapshots();

//   // Volunteers
//   static Future<void> createVolunteerProfile(String uid, Map<String, dynamic> data) =>
//       db.collection('volunteers').doc(uid).set(data, SetOptions(merge: true));

//   static Stream<DocumentSnapshot<Map<String, dynamic>>> volunteerStream(String uid) =>
//       db.collection('volunteers').doc(uid).snapshots();

//   static Future<void> deleteVolunteer(String uid) =>
//       db.collection('volunteers').doc(uid).delete();

//   // Update Request
//   static Future<void> requestVolunteerUpdate(String volunteerId, Map<String, dynamic> newData) =>
//       db.collection('volunteer_update_requests').add({
//         'volunteerId': volunteerId,
//         'newData': newData,
//         'status': 'pending',
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//   // Calls
//   static Stream<QuerySnapshot<Map<String, dynamic>>> userCalls(String userId) =>
//       db.collection('calls').where('userId', isEqualTo: userId).orderBy('timestamp', descending: true).snapshots();

//   // Admin Queries
//   static Stream<QuerySnapshot<Map<String, dynamic>>> allUsers() =>
//       db.collection('users').orderBy('createdAt', descending: true).snapshots();

//   static Stream<QuerySnapshot<Map<String, dynamic>>> volunteers({String? type, String? duty}) {
//     var q = db.collection('volunteers').orderBy('updatedAt', descending: true);
//     if (type != null) q = q.where('type', isEqualTo: type);
//     if (duty != null) q = q.where('duty', isEqualTo: duty);
//     return q.snapshots();
//   }

//   // Helpline filters by timeSlot and date (date is stored on availability doc, optional)
//   static Stream<QuerySnapshot<Map<String, dynamic>>> helplineBySlotAndDate(String? slot, DateTime? date) {
//     var q = db.collection('volunteers').where('type', isEqualTo: 'helpline');
//     if (slot != null && slot.isNotEmpty) {
//       q = q.where('timeSlots', arrayContains: slot);
//     }
//     // If you also store availability dates, add another where here (requires index)
//     return q.snapshots();
//   }
// }









import 'package:cloud_firestore/cloud_firestore.dart';

class FS {
  static final db = FirebaseFirestore.instance;

  // Users
  static Future<void> createUserProfile(String uid, Map<String, dynamic> data) =>
      db.collection('users').doc(uid).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  static Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) =>
      db.collection('users').doc(uid).snapshots();

  // Volunteers
  static Future<void> createVolunteerProfile(String uid, Map<String, dynamic> data) =>
      db.collection('volunteers').doc(uid).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  static Stream<DocumentSnapshot<Map<String, dynamic>>> volunteerStream(String uid) =>
      db.collection('volunteers').doc(uid).snapshots();

  static Future<void> deleteVolunteer(String uid) =>
      db.collection('volunteers').doc(uid).delete();

  // Update Request
  static Future<void> requestVolunteerUpdate(String volunteerId, Map<String, dynamic> newData) =>
      db.collection('volunteer_update_requests').add({
        'volunteerId': volunteerId,
        'newData': newData,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

  // Calls
  static Stream<QuerySnapshot<Map<String, dynamic>>> userCalls(String userId) =>
      db.collection('calls')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots();

  // Admin Queries
  static Stream<QuerySnapshot<Map<String, dynamic>>> allUsers() =>
      db.collection('users').orderBy('createdAt', descending: true).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> volunteers({String? type, String? duty}) {
    Query<Map<String, dynamic>> q = db.collection('volunteers').orderBy('updatedAt', descending: true);
    if (type != null) q = q.where('type', isEqualTo: type);
    if (duty != null) q = q.where('duty', isEqualTo: duty);
    return q.snapshots();
  }

  // Helpline filters by slot and date
  static Stream<QuerySnapshot<Map<String, dynamic>>> helplineBySlotAndDate(String? slot, DateTime? date) {
    Query<Map<String, dynamic>> q = db.collection('volunteers').where('type', isEqualTo: 'helpline');
    if (slot != null && slot.isNotEmpty) {
      q = q.where('timeSlots', arrayContains: slot);
    }
    // Add date filter if you store it
    return q.snapshots();
  }

  // Volunteer Update Requests
  static Stream<QuerySnapshot<Map<String, dynamic>>> allUpdateRequests() =>
      db.collection('volunteer_update_requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
}

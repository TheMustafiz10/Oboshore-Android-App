import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  // === COMMON ===
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> authStateChanges() => _auth.authStateChanges();
  static Future<void> signOut() => _auth.signOut();

  // === USER ===
  static Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    await _db.collection('users').doc(cred.user!.uid).set({
      'role': 'user',
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'totalCalls': 0,
    }, SetOptions(merge: true));
    await _auth.signOut(); // force login after register
  }

  static Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // === VOLUNTEER ===
  static Future<void> registerVolunteer({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String type,               // 'helpline' | 'non-helpline'
    String? duty,                        // required if non-helpline
    List<String>? timeSlots,             // required if helpline
    bool requireApproval = true,         // set to false if auto-approved
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    await _db.collection('volunteers').doc(cred.user!.uid).set({
      'role': 'volunteer',
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'type': type,
      'duty': type == 'non-helpline' ? duty : null,
      'timeSlots': type == 'helpline' ? (timeSlots ?? []) : [],
      'approved': !requireApproval,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _auth.signOut(); // force login after register
  }

  static Future<void> loginVolunteer({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }
}

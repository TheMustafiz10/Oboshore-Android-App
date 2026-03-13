import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> authStateChanges() => _auth.authStateChanges();
  static Future<void> signOut() => _auth.signOut();

  // Simple admin login (email/password). You can also enforce admin claim.
  static Future<bool> loginAdmin({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    // Option A: Check Firestore role
    final doc = await _db.collection('admins').doc(_auth.currentUser!.uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      return false;
    }
    return true;
  }
}

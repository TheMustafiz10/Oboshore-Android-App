


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'volunteer_registration.dart';
import 'dart:async';

import 'helpline_volunteer_dashboard.dart';
import 'non_helpline_volunteer_dashboard.dart';

class VolunteerLoginPage extends StatefulWidget {
  @override
  _VolunteerLoginPageState createState() => _VolunteerLoginPageState();
}

class _VolunteerLoginPageState extends State<VolunteerLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _checkUserStatusAndNavigate(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('volunteers')
          .doc(uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Account not found in system')),
        );
        return;
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        await FirebaseAuth.instance.signOut();
        return;
      }

      final status = data['status'] ?? 'pending';
      final role = data['volunteerType'] ?? '';

      if (status == 'approved') {
        _navigateToDashboard(role);
      } else if (status == 'rejected') {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Your application has been rejected')),
        );
      } else {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⏳ Your application is pending approval')),
        );
      }
    } catch (e) {
      print('Error checking user status: $e');
      await FirebaseAuth.instance.signOut();
    }
  }

  void _navigateToDashboard(String role) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    if (role == 'helpline') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HelplineVolunteerDashboard()),
        (route) => false,
      );
    } else if (role == 'non-helpline') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => NonHelplineVolunteerDashboard()),
        (route) => false,
      );
    } else {

      FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Unknown volunteer role')),
      );
    }
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim().toLowerCase();

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );


      if (userCredential.user != null) {
        await _checkUserStatusAndNavigate(userCredential.user!.uid);
      }

    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String message = e.message ?? 'Login failed';
      if (e.code == 'user-not-found') message = 'Account not found';
      if (e.code == 'wrong-password') message = 'Incorrect password';
      if (e.code == 'invalid-email') message = 'Invalid email format';
      if (e.code == 'user-disabled') message = 'Account disabled';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ $message")),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Login error: $e")),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Login"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              "Volunteer Login",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Login",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => VolunteerRegistrationPage()),
                      );
                    },
              child: const Text(
                "Don't have an account? Register here",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
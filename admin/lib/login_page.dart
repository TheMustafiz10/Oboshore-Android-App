// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'admin_dashboard.dart';



// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _loading = false;

//   // fixed admin credentials
//   final String adminEmail = "admin@oboshore.com";
//   final String adminPassword = "admin123";

//   Future<void> _login() async {
//     setState(() => _loading = true);
//     try {
//       if (_emailController.text == adminEmail &&
//           _passwordController.text == adminPassword) {
//         // sign in anonymously to Firebase (so auth state exists)
//         await FirebaseAuth.instance.signInAnonymously();

//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const AdminDashboard()),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Invalid admin credentials")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             double width = constraints.maxWidth > 600 ? 400 : double.infinity;
//             return Card(
//               margin: const EdgeInsets.all(24),
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 width: width,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text("Admin Login",
//                         style: TextStyle(
//                             fontSize: 24, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 20),
//                     TextField(
//                       controller: _emailController,
//                       decoration: const InputDecoration(labelText: "Email"),
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: const InputDecoration(labelText: "Password"),
//                     ),
//                     const SizedBox(height: 20),
//                     _loading
//                         ? const CircularProgressIndicator()
//                         : ElevatedButton(
//                             onPressed: _login,
//                             child: const Text("Login"),
//                           ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
// import 'admin_dashboard.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

 
  final String adminEmail = "admin@gmail.com";
  final String adminPassword = "Admin@123";

  bool _isLoading = false;
  String? _errorMessage;

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

    
      Future.delayed(const Duration(seconds: 1), () {
        if (emailController.text == adminEmail &&
            passwordController.text == adminPassword) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = "Invalid email or password!";
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(20),
          child: isWide
              ? Row(
                  children: [
                    Expanded(
                      child: Container(
                       color: Color.fromARGB(255, 221, 219, 219),
                        child: const Center(
                          child: Text(
                            "Welcome to Admin Portal",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: _buildLoginForm(context)),
                  ],
                )
              : _buildLoginForm(context),
        ),
      ),
    );
  }



  Widget _buildLoginForm(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Admin Login",
                style: TextStyle(fontSize: 22, ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),

                validator: (value) =>
                    (value == null || value.isEmpty) ? "Enter email" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? "Enter password" : null,
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        backgroundColor: const Color.fromARGB(255, 221, 219, 219),
                      ),
                      child: const Text("Login"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'admin_dashboard.dart';
import 'login_page.dart';
import './services/firestore_service.dart';
import './services/auth_service.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyB5SFGT8ClA1JZLPIW5tqcUhXXiFwpO_Wo",
      authDomain: "oboshore-22d59.firebaseapp.com",
      projectId: "oboshore-22d59",
      storageBucket: "oboshore-22d59.firebasestorage.app",
      messagingSenderId: "76224280941",
      appId: "1:76224280941:web:743004207fee2125f18264",
      measurementId: "G-K9PQ9S4Q0Q"
    )
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
  
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}

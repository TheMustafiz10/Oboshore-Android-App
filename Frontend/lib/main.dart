
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oboshore/volunteer_registration.dart'; 
import 'user_login.dart';
import 'user_dashboard.dart'; 
import 'home_page.dart';
import 'about_page.dart';
import 'services_page.dart';
import 'contact_page.dart';
import 'more_page.dart';
import 'donation_page.dart';
import "user_registration.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB5SFGT8ClA1JZLPIW5tqcUhXXiFwpO_Wo",
        authDomain: "oboshore-22d59.firebaseapp.com",
        projectId: "oboshore-22d59",
        storageBucket: "oboshore-22d59.appspot.com",
        messagingSenderId: "76224280941",
        appId: "1:76224280941:web:743004207fee2125f18264",
        measurementId: "G-K9PQ9S4Q0Q",
      ),
    );
    print("Firebase Initialized Successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Oboshore",
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/register': (context) => RegisterUser(),
        '/LoginUser': (context) => LoginUser(),
        '/dashboard': (context) => UserDashboard(),
        '/donation': (context) => DonationPage(),
        '/VolunteerRegistrationPage': (context) => VolunteerRegistrationPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    AboutPage(),
    ServicesPage(),
    ContactPage(),
    MorePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset("assets/images/KPR-Logo.jpg", height: 40),
            if (MediaQuery.of(context).size.width > 800)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/VolunteerRegistrationPage');
                    },
                    child: const Text("Join Volunteer"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/donation');
                    },
                    child: const Text("Donate"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/LoginUser');
                    },
                    child: const Text("Login"),
                  ),
                ],
              )
            else
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'volunteer',
                    child: Text('Join Volunteer'),
                  ),
                  const PopupMenuItem(
                    value: 'donate',
                    child: Text('Donate'),
                  ),
                  const PopupMenuItem(
                    value: 'login',
                    child: Text('Login'),
                  ),
                ],
                onSelected: (String value) {
                  if (value == 'volunteer') {
                    Navigator.pushNamed(context, '/VolunteerRegistrationPage');
                  } else if (value == 'donate') {
                    Navigator.pushNamed(context, '/donation');
                  } else if (value == 'login') {
                    Navigator.pushNamed(context, '/LoginUser');
                  }
                },
              ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: "Services"),
          BottomNavigationBarItem(icon: Icon(Icons.contact_phone), label: "Contact"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'connectionPhone.dart';
import 'DialerPage.dart';
import 'homePage.dart';
import 'services.dart';
import 'profile_page.dart';
import 'chat.dart';  // Importation de la page Chat
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rebtel Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.blue),
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const ConnectionPhone(),
        '/home': (context) => const MainNavigation(),
        '/dialer': (context) => const DialerPage(),
        '/chat': (context) => const ChatPage(), // Ajout de la route pour la page Chat
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const RebtelHomePage(),
    const ServicesPage(),
    const ProfilePage(),
    const DialerPage(),
    const ChatPage(), // Page Chat ajoutée ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.widgets), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dialpad),
            label: 'Appel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Message', // Label "Message" pour la page de chat
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/HomeScreen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:app/Fishers/Screens/FishersScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FishersNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Roboto',
      ),
      home: const BubbleSplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },

      // <<==== THIS IS THE onGenerateRoute PROPERTY ====>>>
      onGenerateRoute: (settings) {
        if (settings.name == '/fisherHome') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FisherDashboard(fisherId: args['fisherId']),
          );
        }
        // You can add more routes here if needed
        return null;
      },
    );
  }
}


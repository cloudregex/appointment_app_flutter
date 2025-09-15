import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import './login_page.dart';
import './home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = false;

    try {
      // Always wait for 3 seconds for splash screen visibility
      await Future.delayed(const Duration(seconds: 3));

      // Check if the widget is still mounted before proceeding
      if (!mounted) return;

      // Try to check login status using shared_preferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      isLoggedIn = token != null;
    } catch (e) {
      // If there's an error with shared_preferences, default to not logged in
      isLoggedIn = false;
    }

    // Check again if the widget is still mounted after async operations
    if (!mounted) return;

    // Navigate to appropriate screen
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.deepPurple, Colors.blue],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Appointment App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

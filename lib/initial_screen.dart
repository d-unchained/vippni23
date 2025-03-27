// initial_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class InitialScreen extends StatefulWidget {
  final bool isLoggedIn;

  const InitialScreen({super.key, required this.isLoggedIn});

  @override
  InitialScreenState createState() => InitialScreenState();
}

class InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // Navigate to HomeScreen or LoginScreen based on isLoggedIn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // While deciding which screen to navigate to, show a loading indicator
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

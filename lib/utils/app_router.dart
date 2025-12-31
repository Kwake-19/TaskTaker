import 'package:flutter/material.dart';

import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case '/profile': // ✅ ADD THIS
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                "Route not found",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
    }
  }
}

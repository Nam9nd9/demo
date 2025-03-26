import 'package:flutter/material.dart';
import 'package:mobile/screen/account/login_screen.dart';
import 'package:mobile/screen/home_screen.dart';
import 'package:mobile/service/api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // Kiểm tra accessToken từ SharedPreferences
  Future<bool> _hasAccessToken() async {
    try {
      String? accessToken = await ApiService.getAccessToken();
      return accessToken != null && accessToken.isNotEmpty;
    } catch (e) {
      print('Lỗi khi lấy accessToken: $e');
      return false;
    }
  }

  void _navigateToNextScreen() async {
    final results = await Future.wait([
      _hasAccessToken(),
      Future.delayed(const Duration(seconds: 3)), // Hiển thị Splash trong 3s
    ]);

    bool hasToken = results[0] as bool;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => hasToken ? const HomeScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/splash.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

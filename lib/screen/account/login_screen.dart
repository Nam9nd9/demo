import 'package:flutter/material.dart';
import 'package:mobile/screen/home_screen.dart';
import 'package:mobile/service/api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

//   Future<void> checkStoredToken() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? accessToken = prefs.getString("accessToken");

//   print("🔍 Đang kiểm tra SharedPreferences...");
//   if (accessToken != null) {
//     print("🔹 Access Token đang lưu: $accessToken");
//   } else {
//     print("❌ Không tìm thấy Access Token");
//   }
// }

  void _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Vui lòng nhập tên đăng nhập và mật khẩu";
      });
      return;
    }

    String? error = await ApiService.signin(username, password);

    if (error == null) {

      // checkStoredToken();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  // void _handleLogout() async {
  //   await ApiService.signout();
  //   // Navigator.pushReplacement(
  //   //   context,
  //   //   MaterialPageRoute(builder: (context) => const LoginScreen()),
  //   // );
  //   // checkStoredToken();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 140, left: 16, right: 16),
        child: Column(
          children: [
            Image.asset('assets/images/logo.png', height: 24),
            const SizedBox(height: 24),
            const Text("Đăng nhập", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Tên đăng nhập",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline), // Thêm icon person
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Căn giữa
                children: [
                  const Icon(Icons.error_outline,size: 12, color: Color(0xFFE50000)), // Icon lỗi
                  const SizedBox(width: 8), // Khoảng cách giữa icon và text
                  const Text(
                    "Thông tin đăng nhập không đúng, hãy thử lại",
                    style: TextStyle(fontSize: 12,color: Color(0xFFE50000)), // Màu đỏ
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF338BFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Đăng nhập", style: TextStyle(fontSize: 15)),
              ),
            ),
            // const SizedBox(height: 10),
            // SizedBox(
            //   width: double.infinity,
            //   height: 44,
            //   child: ElevatedButton(
            //     onPressed: _handleLogout,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.red,
            //       foregroundColor: Colors.white,
            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            //     ),
            //     child: const Text("Đăng xuất", style: TextStyle(fontSize: 15)),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

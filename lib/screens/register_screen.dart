import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Đăng ký
  void register() async {
    final user = await _authService.register(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (user != null) {
      Navigator.pop(context); // Quay lại màn hình đăng nhập
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại')),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // FULL màn hình
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6EC6FF), // xanh nước biển
              Color(0xFFFFC1CC), // hồng nhạt
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // LOGO
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Colors.blueAccent,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Food Share',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Chia sẻ thực phẩm – Kết nối & bền vững',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Mật khẩu',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                      ),
                      child: const Text('Đăng ký'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 👉 Giữ note người trước + làm nổi bật Đăng nhập
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Đã có tài khoản? ',
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Đăng nhập',
                            style: TextStyle(
                              color: Colors.yellowAccent,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

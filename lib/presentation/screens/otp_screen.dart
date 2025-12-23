import 'package:flutter/material.dart';
import 'package:english_app/presentation/screens/login_screen.dart';

/// OTP flow is temporarily disabled. This screen shows a simple notice and returns to Login.
class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực OTP (đã tắt)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Luồng OTP tạm thời bị vô hiệu hoá. Vui lòng đăng nhập bằng email và mật khẩu.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Quay về đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

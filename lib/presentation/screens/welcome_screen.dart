import 'package:english_app/core/widgets/my_button.dart';
import 'package:english_app/presentation/screens/login_screen.dart';
import 'package:english_app/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Column(
              children: [
                Image.asset("assets/images/welcome_image.jpg", width: 300),
                const SizedBox(height: 20),
                const Text(
                  "Cùng khởi tạo kế hoạch học tập cá nhân nào",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Gradient Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7F45F4), Color(0xFF30B9C5)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MyButton(
                data: "Đi thôi",
                backgroundColor: Colors.transparent,
                textColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OnboardingScreen()),
                  );
                },
              ),
              // child: TextButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => OnboardingScreen()),
              //     );
              //   },
              //   style: TextButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(vertical: 14),
              //     backgroundColor: Colors.transparent,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   child: const Text(
              //     "Đi thôi",
              //     style: TextStyle(
              //       fontSize: 24,
              //       fontWeight: FontWeight.bold,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
            ),

            const SizedBox(height: 20),

            // Secondary Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: MyButton(
                data: "Tôi đã có tài khoản",
                textColor: Colors.grey,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
              // child: ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => LoginScreen()),
              //     );
              //   },
              //   style: TextButton.styleFrom(
              //     backgroundColor: Colors.white,
              //     foregroundColor: Colors.grey,
              //     padding: const EdgeInsets.symmetric(vertical: 14),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       side: const BorderSide(color: Colors.grey),
              //     ),
              //   ),
              //   child: const Text(
              //     "Tôi đã có tài khoản",
              //     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              //   ),
              // ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

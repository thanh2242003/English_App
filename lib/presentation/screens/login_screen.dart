import 'package:english_app/core/my_button.dart';
import 'package:english_app/presentation/screens/register_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 65),
              Text(
                'Đăng nhập',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 33,
                ),
              ),
              SizedBox(height: 1),
              //TextField Email
              TextField(
                decoration: InputDecoration(
                  hintText: 'Email',
                  contentPadding: EdgeInsets.all(25),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xCCE1DEDE), width: 2),
                    // viền chưa focus
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    // viền khi focus
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              //TextField Mật khẩu
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Mật khẩu',
                  contentPadding: EdgeInsets.all(25),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xCCE1DEDE), width: 2),
                    // viền chưa focus
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    // viền khi focus
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              MyButton(
                data: 'ĐĂNG NHẬP',
                borderColor: Colors.blue,
                onTap: () {},
              ),
              MyButton(
                data: 'ĐĂNG NHẬP BẰNG GOOGLE',
                iconPath: 'assets/images/google_logo.png',
                onTap: () {},
              ),
              MyButton(
                data: 'ĐĂNG NHẬP BẰNG FACEBOOK',
                iconPath: 'assets/images/facebook_logo.png',
                onTap: () {},
              ),
              RichText(
                text: TextSpan(
                  text: 'Bạn chưa có tài khoản?',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    TextSpan(
                      text: 'Đăng ký ngay',
                      style: TextStyle(color: Colors.blue, fontSize: 18),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return RegisterScreen();
                              },
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 65),
            ],
          ),
        ),
      ),
    );
  }
}

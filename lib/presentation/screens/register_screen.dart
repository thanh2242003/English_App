import 'package:english_app/presentation/screens/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/my_button.dart';
import '../../data/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

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
                'Đăng ký',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 33,
                ),
              ),
              SizedBox(height: 1),
              //TextField Email
              TextField(
                controller: _emailController,
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
                controller: _passwordController,
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
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Nhập lại mật khẩu',
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
                data: 'ĐĂNG KÝ',
                borderColor: Colors.blue,
                onTap: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  final confirm = _confirmController.text.trim();

                  //  Kiểm tra rỗng
                  if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng điền đủ thông tin")),
                    );
                    return;
                  }

                  //  Kiểm tra mật khẩu khớp
                  if (password != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mật khẩu không khớp!")),
                    );
                    return;
                  }

                  try {
                    //  Gọi AuthService
                    final user = await AuthService().signUp(email, password);

                    if (user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tạo tài khoản thành công!")),
                      );

                      //  Chuyển sang LoginScreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Đăng ký thất bại!")),
                      );
                    }
                  } catch (e) {
                    //  Bắt lỗi Firebase hoặc lỗi khác
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Đăng ký thất bại: $e")),
                    );
                  }
                },
              ),
              RichText(
                text: TextSpan(
                  text: 'Bạn đã có tài khoản?',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    TextSpan(
                      text: 'Đăng nhập ngay',
                      style: TextStyle(color: Colors.blue, fontSize: 18),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return LoginScreen();
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

import 'package:english_app/core/widgets/my_button.dart';
import 'package:english_app/presentation/screens/main_screen.dart';
import 'package:english_app/presentation/screens/register_screen.dart';
// Firebase auth removed: using custom backend JWT
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading  =false;
  // Đăng nhập bằng email + password (sử dụng backend JWT)
  Future<void> _handleLogin() async {
    if (_isLoading) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đủ email và mật khẩu.")));
      return;
    }

    if (!mounted) return;
    setState(() { _isLoading = true; });
    try {
      final user = await AuthService().signIn(email, password);
      if (user != null) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (r) => false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng nhập thất bại: $e')));
    } finally {
      if (!mounted) return;
      setState(() { _isLoading = false; });
    }
  }


  // legacy social/firebase sign-in removed

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
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
                SizedBox(height: 40),
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
                SizedBox(height: 20,),
                //TextField Mật khẩu
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
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
                    //ẩn hiện mật khẩu
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 40,),
                SizedBox(
                  width: double.infinity,
                  child: MyButton(
                    data: 'ĐĂNG NHẬP',
                    borderColor: Colors.blue,
                    onTap: _handleLogin,
                  ),
                ),
                SizedBox(height: 20,),
                // Social login temporarily disabled when using custom backend
                // MyButton(
                //   data: 'ĐĂNG NHẬP BẰNG GOOGLE',
                //   iconPath: 'assets/images/google_logo.png',
                //   onTap: loginWithGoogle,
                // ),
                SizedBox(height: 20,),
                // MyButton(
                //   data: 'ĐĂNG NHẬP BẰNG FACEBOOK',
                //   iconPath: 'assets/images/facebook_logo.png',
                //   onTap: () {},
                // ),
                SizedBox(height: 20,),
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
      ),
    );
  }
}

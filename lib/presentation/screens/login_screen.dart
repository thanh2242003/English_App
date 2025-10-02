import 'package:english_app/core/widgets/my_button.dart';
import 'package:english_app/presentation/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Đăng nhập bằng email + password
  Future<void> loginWithEmail() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (credential.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  // Đăng nhập bằng Google
  Future<void> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      if (userCred.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google lỗi: $e")));
    }
  }

  // Đăng nhập bằng Facebook
  // Future<void> loginWithFacebook() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();
  //     if (result.status == LoginStatus.success) {
  //       final OAuthCredential credential =
  //       FacebookAuthProvider.credential(result.accessToken!.token);
  //       await FirebaseAuth.instance.signInWithCredential(credential);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Đăng nhập Facebook thành công!")),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Facebook lỗi: ${result.message}")),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Facebook lỗi: $e")),
  //     );
  //   }
  // }
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
              SizedBox(
                width: double.infinity,
                child: MyButton(
                  data: 'ĐĂNG NHẬP',
                  borderColor: Colors.blue,
                  onTap: loginWithEmail,
                ),
              ),
              MyButton(
                data: 'ĐĂNG NHẬP BẰNG GOOGLE',
                iconPath: 'assets/images/google_logo.png',
                onTap: loginWithGoogle,
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

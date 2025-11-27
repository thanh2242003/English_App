import 'package:english_app/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/widgets/my_button.dart';
import '../utils/phone_auth_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSendingOtp = false;
  bool _otpSent = false;
  String? _verificationId;
  int? _resendToken;
  PhoneAuthCredential? _autoPhoneCredential;
  final AppDependencies _dependencies = AppDependencies();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
      );
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    try {
      final result = await PhoneAuthHelper.requestOtp(
        phone,
        resendToken: _resendToken,
      );
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _verificationId = result.verificationId ?? _verificationId;
        _resendToken = result.resendToken ?? _resendToken;
        _autoPhoneCredential = result.credential;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.credential != null
                ? 'Số điện thoại đã được xác thực tự động'
                : 'Đã gửi OTP tới số điện thoại',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gửi OTP: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
        });
      }
    }
  }

  PhoneAuthCredential? _buildPhoneCredential() {
    if (_autoPhoneCredential != null) {
      return _autoPhoneCredential;
    }

    if (_verificationId == null || _verificationId!.isEmpty) {
      return null;
    }

    final smsCode = _otpController.text.trim();
    if (smsCode.length < 6) {
      return null;
    }

    return PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty ||
        phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng điền đủ thông tin"),
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu không khớp!")),
      );
      return;
    }

    final phoneCredential = _buildPhoneCredential();
    if (phoneCredential == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng gửi và nhập OTP hợp lệ cho số điện thoại"),
        ),
      );
      return;
    }

    try {
      final user = await _dependencies.signUpWithEmail(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thất bại!")),
        );
        return;
      }

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể xác thực tài khoản")),
        );
        return;
      }

      await firebaseUser.linkWithCredential(phoneCredential);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tạo tài khoản và xác thực OTP thành công!"),
        ),
      );

      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.phoneNumber == null) {
        await firebaseUser.delete();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thất bại: ${e.message ?? e.code}")),
      );
    } catch (e) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.phoneNumber == null) {
        await firebaseUser.delete();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thất bại: $e")),
      );
    }
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
                  'Đăng ký',
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
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Số điện thoại (+84...)',
                    contentPadding: EdgeInsets.all(25),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xCCE1DEDE), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: TextButton(
                      onPressed: _isSendingOtp ? null : _sendOtp,
                      child: _isSendingOtp
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_otpSent ? 'Gửi lại' : 'Gửi OTP'),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Mã OTP',
                    contentPadding: EdgeInsets.all(25),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xCCE1DEDE), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                //TextField Mật khẩu
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 40,),
                SizedBox(
                  width: double.infinity,
                  child: MyButton(
                    data: 'ĐĂNG KÝ',
                    borderColor: Colors.blue,
                    onTap: _handleRegister,
                  ),
                ),
                SizedBox(height: 20,),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

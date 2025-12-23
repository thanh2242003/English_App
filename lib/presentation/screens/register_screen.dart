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
  //final _phoneController = TextEditingController(); // Thêm controller cho SĐT
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    //_phoneController.dispose(); // Dispose controller
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Hàm này xử lý toàn bộ logic khi nhấn nút Đăng Ký
  Future<void> _handleRegister() async {
    // 1. Kiểm tra trạng thái và đầu vào
    if (_isLoading) return; // Chặn nhấn nhiều lần khi đang xử lý

    final email = _emailController.text.trim();
    //final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    //if (email.isEmpty || phone.isEmpty || password.isEmpty || confirm.isEmpty) {
    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng điền đủ thông tin.")));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mật khẩu không khớp.")));
      return;
    }
    // Yêu cầu SĐT phải theo định dạng quốc tế của Việt Nam
    // if (!phone.startsWith('+84')) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //       content: Text("Số điện thoại phải bắt đầu bằng +84")));
    //   return;
    // }

    // 2. Bắt đầu trạng thái loading
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Gọi API đăng ký tới backend
      final user = await AuthService().signUp(email, password);
      if (user != null) {
        if (!mounted) return;
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      } else {
        if (!mounted) return;
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thất bại')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã có lỗi không xác định xảy ra: $e")),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                //Thêm TextField cho SĐT
                // TextField(
                //   controller: _phoneController,
                //   keyboardType: TextInputType.phone,
                //   decoration: InputDecoration(
                //     hintText: 'Số điện thoại (ví dụ: +84912345678)',
                //     contentPadding: EdgeInsets.all(25),
                //     enabledBorder: OutlineInputBorder(
                //       borderSide: BorderSide(color: Color(0xCCE1DEDE), width: 2),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderSide: BorderSide(color: Colors.blue, width: 2),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                // ),
                // SizedBox(height: 20),
                //TextField Mật khẩu
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu',
                    contentPadding: EdgeInsets.all(25),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xCCE1DEDE), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
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
                SizedBox(height: 20),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Nhập lại mật khẩu',
                    contentPadding: EdgeInsets.all(25),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xCCE1DEDE), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
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
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: MyButton(
                    data: 'ĐĂNG KÝ',
                    borderColor: Colors.blue,
                    onTap: _handleRegister, // Gọi hàm xử lý đã được tách ra
                  ),
                ),
                // Hiển thị vòng xoay loading
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: CircularProgressIndicator(),
                  ),

                SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: 'Bạn đã có tài khoản? ',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                    children: [
                      TextSpan(
                        text: 'Đăng nhập ngay',
                        style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Chặn điều hướng nếu đang loading
                            if (_isLoading) return;
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

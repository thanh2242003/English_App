import 'package:english_app/core/di/app_dependencies.dart';
import 'package:english_app/core/widgets/my_button.dart';
import 'package:english_app/presentation/screens/main_screen.dart';
import 'package:english_app/presentation/screens/register_screen.dart';
import 'package:english_app/presentation/utils/phone_auth_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isGoogleLoading = false;
  final AppDependencies _dependencies = AppDependencies();

  // Đăng nhập bằng email + password
  Future<void> loginWithEmail() async {
    try {
      final user = await _dependencies.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      if (user != null) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không thể xác thực tài khoản")),
          );
          await FirebaseAuth.instance.signOut();
          return;
        }

        final phoneVerified = await _ensurePhoneVerification(
          firebaseUser,
          existingPhoneMessage:
              'Đăng nhập thành công sau khi xác thực OTP',
          newPhoneMessage:
              'Đã thêm và xác thực số điện thoại cho tài khoản',
        );

        if (!phoneVerified) {
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng xác thực OTP để tiếp tục đăng nhập'),
            ),
          );
          return;
        }

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng nhập: $e")),
      );
    }
  }

  // Đăng nhập bằng Google
  Future<void> loginWithGoogle() async {
    if (_isGoogleLoading) return;
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCred.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Không thể đăng nhập với Google',
        );
      }

      final phoneVerified = await _ensurePhoneVerification(
        user,
        existingPhoneMessage:
            'Đăng nhập Google thành công sau khi xác thực OTP',
        newPhoneMessage:
            'Đã thêm và xác thực số điện thoại cho tài khoản Google',
      );
      if (!phoneVerified) {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        throw FirebaseAuthException(
          code: 'phone-verification-required',
          message: 'Bạn cần xác thực số điện thoại để tiếp tục',
        );
      }

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google lỗi: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<bool> _ensurePhoneVerification(
    User user, {
    required String existingPhoneMessage,
    required String newPhoneMessage,
  }) async {
    final hasPhone = (user.phoneNumber ?? '').isNotEmpty;
    final success = await _showOtpDialog(
      title: hasPhone ? 'Xác thực OTP' : 'Thêm số điện thoại',
      allowPhoneEdit: !hasPhone,
      initialPhone: user.phoneNumber,
      onVerified: (credential, phone) async {
        if (hasPhone) {
          await user.reauthenticateWithCredential(credential);
        } else {
          await user.linkWithCredential(credential);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasPhone ? existingPhoneMessage : newPhoneMessage,
            ),
          ),
        );
      },
    );
    return success ?? false;
  }

  Future<bool?> _showOtpDialog({
    required String title,
    required bool allowPhoneEdit,
    String? initialPhone,
    required Future<void> Function(PhoneAuthCredential credential, String phone)
        onVerified,
  }) async {
    final phoneController = TextEditingController(text: initialPhone ?? '');
    final otpController = TextEditingController();
    String? verificationId;
    int? resendToken;
    PhoneAuthCredential? autoCredential;
    bool otpSent = false;
    bool isSending = false;
    bool isVerifying = false;
    bool autoRequested = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: !isVerifying,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> sendOtp() async {
              final phone = phoneController.text.trim();
              if (phone.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
                  );
                }
                return;
              }
              setDialogState(() {
                isSending = true;
              });
              try {
                final result = await PhoneAuthHelper.requestOtp(
                  phone,
                  resendToken: resendToken,
                );
                verificationId = result.verificationId ?? verificationId;
                resendToken = result.resendToken ?? resendToken;
                autoCredential = result.credential;
                otpSent = true;
                setDialogState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result.credential != null
                            ? 'Đã tự động xác thực số điện thoại'
                            : 'OTP đã được gửi',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không thể gửi OTP: $e')),
                  );
                }
              } finally {
                setDialogState(() {
                  isSending = false;
                });
              }
            }

            Future<void> verifyOtp() async {
              final navigator = Navigator.of(ctx);
              PhoneAuthCredential? credential = autoCredential;
              if (credential == null) {
                if ((verificationId ?? '').isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng gửi OTP trước')),
                    );
                  }
                  return;
                }
                final code = otpController.text.trim();
                if (code.length < 6) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập mã OTP hợp lệ')),
                    );
                  }
                  return;
                }
                credential = PhoneAuthProvider.credential(
                  verificationId: verificationId!,
                  smsCode: code,
                );
              }

              setDialogState(() {
                isVerifying = true;
              });
              try {
                await onVerified(credential, phoneController.text.trim());
                if (!navigator.mounted) return;
                if (navigator.canPop()) {
                  navigator.pop(true);
                }
              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Xác thực OTP thất bại: ${e.message ?? e.code}'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Xác thực OTP thất bại: $e')),
                  );
                }
              } finally {
                setDialogState(() {
                  isVerifying = false;
                });
              }
            }

            if (!allowPhoneEdit && !otpSent && !autoRequested) {
              autoRequested = true;
              Future.microtask(sendOtp);
            }

            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: phoneController,
                    enabled: allowPhoneEdit,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Số điện thoại (+84...)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Mã OTP',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: isSending ? null : sendOtp,
                        child: isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(otpSent ? 'Gửi lại' : 'Gửi OTP'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying
                      ? null
                      : () {
                          if (Navigator.of(ctx).canPop()) {
                            Navigator.of(ctx).pop(false);
                          }
                        },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isVerifying ? null : verifyOtp,
                  child: isVerifying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );

    phoneController.dispose();
    otpController.dispose();
    return result;
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
                    onTap: loginWithEmail,
                  ),
                ),
                SizedBox(height: 20,),
                MyButton(
                  data: 'ĐĂNG NHẬP BẰNG GOOGLE',
                  iconPath: 'assets/images/google_logo.png',
                  onTap: loginWithGoogle,
                  isLoading: _isGoogleLoading,
                ),
                SizedBox(height: 20,),
                MyButton(
                  data: 'ĐĂNG NHẬP BẰNG FACEBOOK',
                  iconPath: 'assets/images/facebook_logo.png',
                  onTap: () {},
                ),
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

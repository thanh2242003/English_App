import 'package:english_app/data/auth_service.dart';
import 'package:english_app/presentation/screens/login_screen.dart';
import 'package:english_app/presentation/screens/main_screen.dart';
import 'package:english_app/presentation/screens/onboarding_screen.dart';
import 'package:english_app/presentation/screens/splash_screen.dart';
import 'package:english_app/presentation/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _determineInitialScreen();
  }

  Future<void> _determineInitialScreen() async {
    try {
      // Hiển thị splash screen ít nhất 2 giây
      await Future.delayed(const Duration(seconds: 2));
      
      // Kiểm tra trạng thái đăng nhập
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // User đã đăng nhập -> đi thẳng đến MainScreen
        setState(() {
          _initialScreen = const MainScreen();
          _isLoading = false;
        });
        return;
      }

      // User chưa đăng nhập -> kiểm tra onboarding
      final prefs = await SharedPreferences.getInstance();
      final isOnboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      final isWelcomeShown = prefs.getBool('welcome_shown') ?? false;

      Widget targetScreen;

      if (!isWelcomeShown) {
        // Lần đầu tiên mở app -> hiển thị WelcomeScreen
        targetScreen = const WelcomeScreen();
      } else if (!isOnboardingCompleted) {
        // Đã xem welcome nhưng chưa hoàn thành onboarding
        targetScreen = const OnboardingScreen();
      } else {
        // Đã hoàn thành onboarding -> đi đến LoginScreen
        targetScreen = const LoginScreen();
      }

      setState(() {
        _initialScreen = targetScreen;
        _isLoading = false;
      });
    } catch (e) {
      // Nếu có lỗi, mặc định đi đến LoginScreen
      setState(() {
        _initialScreen = const LoginScreen();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Hiển thị splash screen trong khi đang xác định màn hình tiếp theo
      return const SplashScreen();
    }

    return _initialScreen ?? const LoginScreen();
  }
}

// Extension để lưu trạng thái welcome đã hiển thị
extension WelcomeState on SharedPreferences {
  static const String _welcomeShownKey = 'welcome_shown';
  
  Future<bool> setWelcomeShown() async {
    return await setBool(_welcomeShownKey, true);
  }
  
  bool isWelcomeShown() {
    return getBool(_welcomeShownKey) ?? false;
  }
}

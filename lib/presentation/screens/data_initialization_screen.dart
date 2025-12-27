import 'package:flutter/material.dart';
import 'package:english_app/core/navigation/app_navigator.dart'; // Hoặc đường dẫn tới HomeScreen của bạn
import '../../data/offline_data_service.dart';

class DataInitializationScreen extends StatefulWidget {
  const DataInitializationScreen({super.key});

  @override
  State<DataInitializationScreen> createState() => _DataInitializationScreenState();
}

class _DataInitializationScreenState extends State<DataInitializationScreen> {
  final OfflineDataService _offlineService = OfflineDataService();
  double _progress = 0.0; // Thanh tiến trình giả lập cho đẹp
  String _statusText = "Đang kết nối đến máy chủ...";
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Kiểm tra xem đã có dữ liệu chưa để tránh tải lại không cần thiết
      // (Bạn có thể thêm logic check version ở đây nếu muốn update)
      final existingData = await _offlineService.getLessons();

      if (existingData.isNotEmpty) {
        // Dữ liệu đã có -> Vào Home luôn
        _navigateToHome();
        return;
      }

      // 2. Nếu chưa có -> Bắt đầu quy trình tải
      setState(() => _statusText = "Đang tải bài học về máy...");

      // Giả lập thanh tiến trình chạy 1 chút cho người dùng đỡ sốt ruột
      _fakeProgress();

      // Gọi hàm tải và lưu dữ liệu (Hàm này bạn đã viết trong OfflineDataService)
      // Lưu ý: OfflineDataService cần lấy Token từ AuthService (hoặc nơi bạn lưu token)
      await _offlineService.initializeData();

      setState(() {
        _progress = 1.0;
        _statusText = "Hoàn tất!";
      });

      // Đợi 1 chút cho user nhìn thấy chữ Hoàn tất
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToHome();

    } catch (e) {
      setState(() {
        _hasError = true;
        _statusText = "Lỗi tải dữ liệu: $e";
      });
    }
  }

  void _fakeProgress() async {
    for (var i = 1; i <= 8; i++) {
      if (_hasError || _progress >= 1.0) break;
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() => _progress = i / 10);
      }
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppNavigator()), // Thay bằng màn hình chính của bạn
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo hoặc Hình ảnh minh họa
              const Icon(Icons.cloud_download_outlined, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 30),

              Text(
                _hasError ? "Đã xảy ra lỗi" : "Đang chuẩn bị dữ liệu học tập",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Text(
                _statusText,
                style: TextStyle(color: _hasError ? Colors.red : Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              if (!_hasError)
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),

              if (_hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _progress = 0.0;
                      });
                      _initializeApp(); // Thử lại
                    },
                    child: const Text("Thử lại"),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

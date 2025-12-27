import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/api_lesson_model.dart';
import 'api_service.dart';
import 'auth_service.dart'; // <--- Thêm import này để lấy token
import 'encryption_service.dart';

class OfflineDataService {
  final ApiService _apiService = ApiService();
  final EncryptionService _encryptionService = EncryptionService();
  final AuthService _authService = AuthService(); // <--- Khởi tạo AuthService

  static const String _fileName = 'offline_lessons.enc';

  /// Hàm này sẽ được gọi ở màn hình DataInitializationScreen (sau khi login thành công)
  /// Trả về true nếu tải và lưu thành công
  Future<void> initializeData() async {
    try {
      final file = await _getLocalFile();

      // (Tùy chọn) Kiểm tra nếu file đã tồn tại và có dữ liệu thì không tải lại
      // Logic: Nếu file tồn tại -> Vào thẳng App. Nếu muốn update, phải gọi hàm forceUpdate riêng.
      if (await file.exists()) {
        final len = await file.length();
        if (len > 0) {
          print('Dữ liệu offline đã tồn tại ($len bytes). Bỏ qua tải về.');
          return;
        }
      }

      print('Bắt đầu quy trình tải dữ liệu từ Server...');

      // 1. Lấy Token xác thực (QUAN TRỌNG)
      final token = await _authService.token;

      if (token == null || token.isEmpty) {
        throw Exception("Lỗi xác thực: Không tìm thấy Token đăng nhập.");
      }

      // 2. Tải dữ liệu từ API (Gửi kèm Token)
      // Lưu ý: Bạn cần chắc chắn hàm fetchAllLessons bên ApiService đã chấp nhận tham số token
      final lessons = await _apiService.fetchAllLessons(token);

      if (lessons.isEmpty) {
        throw Exception("Server trả về danh sách bài học trống.");
      }

      print('Đã tải ${lessons.length} bài học. Đang mã hóa...');

      // 3. Chuyển sang JSON String
      final jsonString = jsonEncode(lessons.map((e) => e.toJson()).toList());

      // 4. Mã hóa bằng Key bảo mật (Random)
      final encryptedString = await _encryptionService.encryptData(jsonString);

      // 5. Lưu vào file
      await file.writeAsString(encryptedString);
      print('Đã lưu và mã hóa dữ liệu thành công!');

    } catch (e) {
      print('Lỗi khởi tạo dữ liệu offline: $e');
      // Nếu lỗi file rác, xóa đi để lần sau chạy lại từ đầu
      await clearData();
      rethrow; // Ném lỗi để UI hiển thị thông báo "Thử lại"
    }
  }

  // Hàm lấy bài học từ file local (Dùng cho HomeScreen/ExerciseScreen)
  Future<List<ApiLesson>> getLessons() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        print('File dữ liệu không tồn tại.');
        return [];
      }

      // 1. Đọc file
      final encryptedContent = await file.readAsString();

      if (encryptedContent.isEmpty) return [];

      // 2. Giải mã
      final jsonString = await _encryptionService.decryptData(encryptedContent);

      // 3. Parse JSON
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ApiLesson.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi đọc/giải mã dữ liệu offline: $e');
      // Nếu file bị lỗi format hoặc hack, trả về rỗng để UI xử lý (hoặc xóa file đi)
      return [];
    }
  }

  // Hàm xóa dữ liệu (nếu cần Reset App hoặc Logout)
  Future<void> clearData() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        await file.delete();
        print("Đã xóa dữ liệu offline.");
      }
    } catch (e) {
      print("Lỗi xóa file: $e");
    }
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:english_app/models/api_lesson_model.dart';
import 'package:english_app/data/auth_service.dart';

class ApiService {
  // Nếu chạy trên máy ảo Android, dùng 10.0.2.2 thay cho localhost
  // Nếu chạy trên máy thật, dùng IP của máy tính (ví dụ 192.168.1.x)
  final String baseUrl = "http://10.0.2.2:3000/api/lessons";

  Future<ApiLesson?> fetchLesson() async {
    try {
      final token = await AuthService().token;
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Kiểm tra xem JSON trả về có đúng format { success: true, data: [...] } không
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          List<dynamic> data = jsonResponse['data'];
          if (data.isNotEmpty) {
            // Lấy bài học đầu tiên (hoặc xử lý logic chọn bài học ở đây)
            return ApiLesson.fromJson(data[0]);
          }
        }
      } else {
        print("Lỗi khi tải bài học: ${response.statusCode}");
        print("Body: ${response.body}");
      }
    } catch (e) {
      print("Lỗi kết nối API: $e");
    }
    return null;
  }
}

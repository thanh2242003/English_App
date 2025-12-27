import 'dart:convert';
import 'dart:io'; // <--- Thêm thư viện IO để xử lý SSL
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart'; // <--- Thêm thư viện này
import 'package:english_app/models/api_lesson_model.dart';

class ApiService {
  // Đổi thành HTTPS và port 8443
  final String baseUrl = "https://10.0.2.2:8443/api/lessons";

  /// Hàm tạo Client HTTP bỏ qua lỗi SSL (Chỉ dùng cho môi trường DEV)
  http.Client _createHttpClient() {
    final ioc = HttpClient();
    ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(ioc);
  }

  Future<List<ApiLesson>> fetchAllLessons(String token) async {
    // Sử dụng client đặc biệt này thay vì http.get trực tiếp
    final client = _createHttpClient();

    try {
      final uri = Uri.parse(baseUrl);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print("Đang gọi API (HTTPS): $uri");

      // Thay http.get bằng client.get
      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          List<dynamic> data = jsonResponse['data'];
          print("API trả về ${data.length} bài học.");
          return data.map((json) => ApiLesson.fromJson(json)).toList();
        } else {
          print("API trả về lỗi logic: $jsonResponse");
          return [];
        }
      } else {
        print("Lỗi tải bài học (HTTP ${response.statusCode}): ${response.body}");
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối API (fetchAllLessons): $e");
      rethrow;
    } finally {
      client.close(); // Nhớ đóng client sau khi dùng xong
    }
  }
}

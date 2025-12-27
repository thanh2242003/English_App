import 'dart:convert';
import 'dart:io'; // <--- Thêm import này

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart'; // <--- Thêm import này
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AuthService mới: giao tiếp với backend Node.js/Express bằng JWT
class AuthService {
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  factory AuthService() => _instance;

  final _storage = const FlutterSecureStorage();

  // Đã sửa thành HTTPS và port 8443
  final String _baseUrl = 'https://10.0.2.2:8443';

  /// Hàm tạo Client HTTP bỏ qua lỗi SSL (Chỉ dùng cho môi trường DEV/Localhost)
  http.Client _createHttpClient() {
    final ioc = HttpClient();
    ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(ioc);
  }

  // Getter để lấy token từ storage
  Future<String?> get token async => await _storage.read(key: 'jwt');

  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'jwt', value: token);
  }

  Future<void> signOut() async {
    await _storage.delete(key: 'jwt');
  }

  /// Đăng nhập
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    final client = _createHttpClient(); // Tạo client HTTPS tùy chỉnh
    try {
      final uri = Uri.parse('$_baseUrl/api/auth/login');

      // Dùng client.post thay vì http.post
      final res = await client.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}));

      print('[AuthService] POST ${uri.toString()} -> ${res.statusCode}');
      print('[AuthService] response: ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final token = body['token'] as String?;

        if (token == null) {
          throw 'OTP_REQUIRED';
        }

        var user = body['user'] as Map<String, dynamic>? ?? body['data'] as Map<String, dynamic>?;
        await _saveToken(token);

        if (user == null) {
          user = await getCurrentUser();
        }

        return user;
      } else {
        final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
        final message = body != null && body['message'] != null ? body['message'] : res.body;
        throw Exception(message);
      }
    } finally {
      client.close(); // Đóng client
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final client = _createHttpClient();
    try {
      final url = Uri.parse('$_baseUrl/api/auth/change-password');
      final tokenStr = await token;
      if (tokenStr == null) throw Exception("Chưa đăng nhập");

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenStr',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Đổi mật khẩu thất bại');
      }
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Đăng ký
  Future<Map<String, dynamic>?> signUp(String email, String password) async {
    final client = _createHttpClient();
    try {
      final uri = Uri.parse('$_baseUrl/api/auth/register');
      final res = await client.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}));

      print('[AuthService] POST ${uri.toString()} -> ${res.statusCode}');
      print('[AuthService] response: ${res.body}');

      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final token = body['token'] as String?;

        if (token == null) {
          throw 'OTP_REQUIRED';
        }

        var user = body['user'] as Map<String, dynamic>? ?? body['data'] as Map<String, dynamic>?;
        await _saveToken(token);

        if (user == null) {
          if ((body['id'] ?? body['_id'] ?? body['userId']) != null || body['email'] != null) {
            user = <String, dynamic>{
              if (body['id'] != null) 'id': body['id'],
              if (body['_id'] != null) 'id': body['_id'],
              if (body['userId'] != null) 'id': body['userId'],
              if (body['email'] != null) 'email': body['email'],
            };
          }
        }

        if (user == null) {
          user = await getCurrentUser();
        }

        return user;
      } else {
        final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
        final message = body != null && body['message'] != null ? body['message'] : res.body;
        throw Exception(message);
      }
    } finally {
      client.close();
    }
  }

  /// Xác thực OTP
  Future<Map<String, dynamic>?> verifyOtp(String email, String otp) async {
    final client = _createHttpClient();
    try {
      final uri = Uri.parse('$_baseUrl/api/auth/verify-otp');
      final res = await client.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'otp': otp}));

      print('[AuthService] POST ${uri.toString()} -> ${res.statusCode}');
      print('[AuthService] response: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        final token = body['token'] as String?;

        if (token != null) {
          await _saveToken(token);
        }

        var user = body['user'] as Map<String, dynamic>? ?? body['data'] as Map<String, dynamic>?;
        if (user == null && token != null) {
          user = await getCurrentUser();
        }
        return user;
      } else {
        final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
        final message = body != null && body['message'] != null ? body['message'] : res.body;
        throw Exception(message);
      }
    } finally {
      client.close();
    }
  }

  /// Gửi lại mã OTP
  Future<void> resendOtp(String email) async {
    final client = _createHttpClient();
    try {
      final uri = Uri.parse('$_baseUrl/api/auth/resend-otp');
      await client.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}));
    } finally {
      client.close();
    }
  }

  /// Lấy thông tin user hiện tại
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final tk = await token;
    if (tk == null) return null;

    final client = _createHttpClient();
    try {
      final uri = Uri.parse('$_baseUrl/api/auth/me');
      final res = await client.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tk',
      });

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final user = body['user'] as Map<String, dynamic>? ?? body['data'] as Map<String, dynamic>?;
        return user;
      }

      // Nếu API lỗi, thử decode từ token local
      final payload = _decodeJwtPayload(tk);
      if (payload != null) {
        final id = payload['sub'] ?? payload['id'] ?? payload['_id'];
        final email = payload['email'];
        return {
          if (id != null) 'id': id,
          if (email != null) 'email': email,
        };
      }

      return null;
    } catch (e) {
      print('[AuthService] Error fetching user: $e');
      return null;
    } finally {
      client.close();
    }
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      String normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> map = jsonDecode(decoded);
      return map;
    } catch (e) {
      print('[AuthService] JWT decode error: $e');
      return null;
    }
  }
}

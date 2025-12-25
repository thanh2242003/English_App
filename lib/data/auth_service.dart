import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AuthService mới: giao tiếp với backend Node.js/Express bằng JWT
class AuthService {
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  factory AuthService() => _instance;

  final _storage = const FlutterSecureStorage();

  // TODO: thay đổi baseUrl thành địa chỉ backend của bạn
  final String _baseUrl = 'http://10.0.2.2:3000';

  Future<String?> get token async => await _storage.read(key: 'jwt');

  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'jwt', value: token);
  }

  Future<void> signOut() async {
    await _storage.delete(key: 'jwt');
  }

  /// Đăng nhập: Trả về user nếu có token, hoặc throw 'OTP_REQUIRED' nếu cần xác thực OTP
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/api/auth/login');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));

    print('[AuthService] POST ${uri.toString()} -> ${res.statusCode}');
    print('[AuthService] response: ${res.body}');

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final token = body['token'] as String?;

      // Nếu backend yêu cầu OTP, sẽ không trả token ngay mà chỉ trả message success
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
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final url = Uri.parse('$_baseUrl/api/auth/change-password');
    try {
      final tokenStr = await token;
      if (tokenStr == null) throw Exception("Chưa đăng nhập");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenStr',
        },
        body: jsonEncode({
          'currentPassword': currentPassword, // Tên field tùy backend: oldPassword, currentPassword...
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
    }
  }

  /// Đăng ký: Trả về user nếu có token, hoặc throw 'OTP_REQUIRED' nếu cần xác thực OTP
  Future<Map<String, dynamic>?> signUp(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/api/auth/register');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));

    print('[AuthService] POST ${uri.toString()} -> ${res.statusCode}');
    print('[AuthService] response: ${res.body}');

    if (res.statusCode == 201 || res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final token = body['token'] as String?;

      // Nếu backend yêu cầu OTP
      if (token == null) {
        throw 'OTP_REQUIRED';
      }

      var user = body['user'] as Map<String, dynamic>? ?? body['data'] as Map<String, dynamic>?;
      await _saveToken(token);

      if (user == null) {
        // Build user map if possible
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
  }

  /// Xác thực OTP
  Future<Map<String, dynamic>?> verifyOtp(String email, String otp) async {
    final uri = Uri.parse('$_baseUrl/api/auth/verify-otp');
    final res = await http.post(uri,
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
  }

  /// Gửi lại mã OTP (nếu cần)
  Future<void> resendOtp(String email) async {
    final uri = Uri.parse('$_baseUrl/api/auth/resend-otp'); // Endpoint giả định
    await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}));
  }

  /// Lấy thông tin user hiện tại từ backend bằng token
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final tk = await token;
    if (tk == null) return null;

    final uri = Uri.parse('$_baseUrl/api/auth/me');
    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $tk',
    });

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final user = body['user'] as Map<String, dynamic>? ?? body['data'] as Map<String, dynamic>?;
      return user;
    }

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

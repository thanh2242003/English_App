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

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/api/auth/login');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    // Debug log
    print('[AuthService] POST ${uri.toString()} -> ${res.statusCode}');
    print('[AuthService] response: ${res.body}');

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      print('[AuthService] parsed body keys: ${body is Map ? (body as Map).keys.toList() : body}');
      final token = body['token'] as String?;
      var user = body['user'] as Map<String, dynamic>? ?? body['data'] as Map<String, dynamic>?;
      if (token != null) await _saveToken(token);

      // Nếu backend chỉ trả token, thử gọi /me để lấy thông tin user
      if (user == null && token != null) {
        user = await getCurrentUser();
      }

      return user;
    } else {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      final message = body != null && body['message'] != null ? body['message'] : res.body;
      throw Exception('Login failed: $message');
    }
  }

  Future<Map<String, dynamic>?> signUp(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/api/auth/register');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    // Debug log
    print('[AuthService] POST ${uri.toString()} -> ${res.statusCode}');
    print('[AuthService] response: ${res.body}');

    if (res.statusCode == 201 || res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final token = body['token'] as String?;
      var user = body['user'] as Map<String, dynamic>? ?? body['data'] as Map<String, dynamic>?;
      if (token != null) await _saveToken(token);

      // Nếu backend trả user trong các trường top-level (id/email), tạo map từ đó
      if (user == null) {
        if ((body['id'] ?? body['_id'] ?? body['userId']) != null || body['email'] != null) {
          user = <String, dynamic>{
            if (body['id'] != null) 'id': body['id'],
            if (body['_id'] != null) 'id': body['_id'],
            if (body['userId'] != null) 'id': body['userId'],
            if (body['email'] != null) 'email': body['email'],
          };
          print('[AuthService] built user from top-level fields: $user');
        }
      }

      // Nếu backend chỉ trả token, thử gọi /me để lấy thông tin user
      if (user == null && token != null) {
        user = await getCurrentUser();
      }

      return user;
    } else {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      final message = body != null && body['message'] != null ? body['message'] : res.body;
      throw Exception('Register failed: $message');
    }
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
    print('[AuthService] GET ${uri.toString()} -> ${res.statusCode}');
    print('[AuthService] response: ${res.body}');

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final user = body['user'] as Map<String, dynamic>? ?? body['data'] as Map<String, dynamic>?;
      return user;
    }

    // Nếu backend không có endpoint /me hoặc trả 404, thử decode payload JWT
    final payload = _decodeJwtPayload(tk);
    if (payload != null) {
      // chuẩn hóa thông tin user tối thiểu
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

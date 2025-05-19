import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('${Api.baseUrl}/login');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    logger.i('LOGIN STATUS: ${response.statusCode}');
    logger.i('LOGIN BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Simpan token ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);

      return {
        'success': true,
        'token': data['access_token'],
        'role': data['user']?['role'] ?? 'user',
      };
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? 'Login gagal'};
    }
  }

  static Future<Map<String, dynamic>?> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final url = Uri.parse('${Api.baseUrl}/register');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'name': name, 'email': email, 'password': password, 'role': role},
    );

    logger.i('REGISTER STATUS: ${response.statusCode}');
    logger.i('REGISTER BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      // Simpan token ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);

      return {
        'success': true,
        'token': data['access_token'],
        'role': data['user']['role'],
      };
    } else {
      try {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal',
        };
      } catch (e) {
        return {'success': false, 'message': 'Terjadi kesalahan pada server'};
      }
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import '../models/menu.dart';

class MenuService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<Menu>> fetchMenus() async {
    final token = await _getToken();
    final url = Uri.parse('${Api.baseUrl}/menus');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('DEBUG: Token yang dikirim: $token');
    print('DEBUG: Response status ${response.statusCode}');
    print('DEBUG: Response body ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((json) => Menu.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data menu');
    }
  }

  static Future<bool> deleteMenu(int id) async {
    final token = await _getToken();
    final url = Uri.parse('${Api.baseUrl}/menus/$id');

    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> createMenu(
    String name,
    int price, {
    String description = '',
    String image = '',
  }) async {
    final token = await _getToken();
    final url = Uri.parse('${Api.baseUrl}/menus');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'name': name,
        'price': price.toString(),
        'description': description,
        'image': image,
      },
    );

    return response.statusCode == 201;
  }

  static Future<bool> updateMenu(int id, String name, int price,
      {String description = '', String image = ''}) async {
    final token = await _getToken();
    final url = Uri.parse('${Api.baseUrl}/menus/$id');

    final response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'name': name,
        'price': price.toString(),
        'description': description,
        'image': image,
      },
    );

    return response.statusCode == 200;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiServices {
  final String baseUrl;

  ApiServices({required this.baseUrl});

  static String defaultBaseUrl() {
    return kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
  }

  // SECURE STORAGE FOR TOKENS INSTANCE
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: 'access', value: token);
  }

  Future<String?> readAccessToken() async {
    return await _secureStorage.read(key: 'access');
  }

  //LOGIN USING CUSTOM LOGIN FLUTTER
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/login/');
    final resp = await http.post(
      url,
      headers: {
        'content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Login Failed: ${resp.statusCode}: ${resp.body}');
    }
  }

  // LOGIN USING DEFAULT DJANGO AND IT IS GOOD FOR MOBILE BUT CREATE A USER USING DJANGO DEFAULT
  //  Future<Map<String, dynamic>> login(String username, String password) async {
  //   final url = Uri.parse('$baseUrl/api/token/');   <-- THE DIFF IS HERE
  //   final resp = await http.post(
  //     url,
  //     headers: {
  //       'content-Type': 'application/json',
  //       'accept': 'application/json',
  //     },
  //     body: jsonEncode({'username': username, 'password': password}),
  //   );
  //   if (resp.statusCode == 200) {
  //     return jsonDecode(resp.body) as Map<String, dynamic>;
  //   } else {
  //     throw Exception('Login Failed: ${resp.statusCode}: ${resp.body}');
  //   }
  // }

  // ENDPOINT TO REGISTER A NEW USER

  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/register/');
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    final resp = await http.post(url, headers: headers, body: jsonEncode(data));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Registration Failed: ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<List<dynamic>> fetchUsers() async {
    final url = Uri.parse('$baseUrl/api/');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['users'] as List<dynamic>;
    } else {
      throw Exception('Failed GET ${response.statusCode}: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> postData(
    Map<String, dynamic> data, {
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/api/');
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final resp = await http.post(url, headers: headers, body: jsonEncode(data));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed POST ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<Map<String, dynamic>> obtainToken(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/token/');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to obtain token ${resp.statusCode}: ${resp.body}',
      );
    }
  }
}

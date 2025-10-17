import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiServices {
  final String baseUrl;

  ApiServices({required this.baseUrl});

  static String defaultBaseUrl() {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    return 'http://10.0.2.2:8000';
    // return kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
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

  // FETCHING USERS
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

  //ADDING TO CART
  Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int productId,
    required String name,
    required double price,
    int quantity = 1,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/api/cart/add/');
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = {
      'user_id': userId,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
    final resp = await http.post(url, headers: headers, body: jsonEncode(body));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('addToCart Failed: ${resp.statusCode}: ${resp.body}');
    }
  }
  // ADDING TO CART END

  // FETCH CART
  Future<Map<String, dynamic>> fetchCart({
    required int userId,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/api/cart/?user_id=$userId');
    final headers = {
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final resp = await http.get(url, headers: headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('fetchCart Failed: ${resp.statusCode}: ${resp.body}');
    }
  }
  // FETCHING CARD END

  // UPDATE CART ITEM START
  Future<void> updateCartItem({
    required int itemId,
    required int quantity,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/api/cart/item/$itemId/');
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final resp = await http.put(
      url,
      headers: headers,
      body: jsonEncode({'quantity': quantity}),
    );
    if (resp.statusCode == 200 && resp.statusCode != 204) {
      throw Exception(
        'updateCartItem Failed: ${resp.statusCode}: ${resp.body}',
      );
    }
  }
  // UPDATE CART ITEM END

  // REMOVE CART ITEM START
  Future<void> removeCartItem({required int itemId, String? token}) async {
    final url = Uri.parse('$baseUrl/api/cart/item/$itemId/');
    final headers = {
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final resp = await http.delete(url, headers: headers);
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception(
        'removeCartItem Failed: ${resp.statusCode}: ${resp.body}',
      );
    }
  }
  // REMOVE CART ITEM END

  // CHECKOUT CART START
  Future<Map<String, dynamic>> checkout({
    required int userId,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/api/cart/checkout/');
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final resp = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'user_id': userId}),
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('checkout Failed: ${resp.statusCode}: ${resp.body}');
    }
  }
  // CHECKOUT CART END

  // LOGIN PURPOSES TO GET THE ID FOR CUSTOMER
  Future<Map<String, dynamic>> getUser(String token) async {
    // COULD BE /login/me/
    final url = Uri.parse('$baseUrl/api/me/');
    final resp = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to fetch profile: ${resp.statusCode}: ${resp.body}',
      );
    }
  }
  // LOGIN PURPOSES TO GET THE ID FOR CUSTOMER END

  // FETCHING PRODUCTS
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final url = Uri.parse('$baseUrl/api/products/');
    final resp = await http.get(url, headers: {'Accept': 'application/json'});
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      if (body is Map && body.containsKey('products')) {
        return List<Map<String, dynamic>>.from(body['products']);
      } else if (body is Map && body.containsKey('results')) {
        return List<Map<String, dynamic>>.from(body['results']);
      } else if (body is List) {
        return List<Map<String, dynamic>>.from(body);
      } else {
        throw Exception(
          'Unexpected response format shape: ${body.runtimeType}',
        );
      }
    } else {
      throw Exception(
        'Failed to fetch products: ${resp.statusCode}: ${resp.body}',
      );
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

  // FETCHING PRODUCT DESCRIPTION
  Future<Map<String, dynamic>> fetchProductDetails(dynamic id) async {
    final url = Uri.parse('$baseUrl/api/products/$id/');
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    final resp = await http.get(url, headers: headers);
    if (resp.statusCode == 200) {
      print(jsonDecode(resp.body));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to load product $id: ${resp.statusCode}: ${resp.body}',
      );
    }
  }

  // DELETE HELPERS
  Future<void> deleteAccessToken() async {
    await _secureStorage.delete(key: 'access');
  }

  // TO STORE REFRESH TOKEN LATER (IN FUTURE)
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: 'refresh', value: token);
  }

  Future<String?> readRefreshToken() async {
    return await _secureStorage.read(key: 'refresh');
  }

  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: 'refresh');
  }

  // FOR GET PROFILE API
  Future<Map<String, dynamic>> getMyProfile(String token) async {
    final url = Uri.parse('$baseUrl/api/profile/');
    final resp = await http.get(
      url, // CONTENT-TYPE WAS SENDING
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load profile: ${resp.statusCode}: ${resp.body}');
  }

  // UPDATE THE PROFILE
  Future<Map<String, dynamic>> updateMyProfile({
    required String token,
    String? phoneNum,
    String? address,
  }) async {
    final url = Uri.parse('$baseUrl/api/profile/');
    final body = <String, dynamic>{};
    if (phoneNum != null) body['phoneNum'] = phoneNum;
    if (address != null) body['address'] = address;

    final resp = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Failed to update profile: ${resp.statusCode}: ${resp.body}',
    );
  }

  // FOR CHECKOUT
  Future<Map<String, dynamic>> checkoutEnhanced({
    required String token,
    required int userId, // not used by server now but ok to keep
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required String shippingMethod, // 'self' or '2days'
    required String address,
    required String phone,
    required double deliveryFee,
  }) async {
    final url = Uri.parse('$baseUrl/api/cart/checkout-enhanced/');
    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'items': items,
        'payment_method': paymentMethod,
        'shipping_method': shippingMethod,
        'address': address,
        'phone': phone,
        'delivery_fee': deliveryFee,
      }),
    );

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception(
      'checkoutEnhanced failed: ${resp.statusCode}: ${resp.body}',
    );
  }
}

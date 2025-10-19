import 'package:flutter/material.dart';

class AppAuthProvider with ChangeNotifier {
  String? _email;
  int? _userId;
  String? _token;
  String? _role;

  String? get email => _email;
  int? get userId => _userId;
  String? get token => _token;
  bool get isLoggedIn => _email != null && _token != null;

  void login({
    required String email,
    required int userId,
    required String token,
  }) {
    _email = email;
    _userId = userId;
    _token = token;
    notifyListeners();
  }

  void logout() {
    _email = null;
    _userId = null;
    _token = null;
    notifyListeners();
  }
}

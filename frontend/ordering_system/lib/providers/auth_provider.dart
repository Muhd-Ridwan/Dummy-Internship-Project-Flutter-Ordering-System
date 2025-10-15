import 'package:flutter/material.dart';

class AppAuthProvider with ChangeNotifier {
  String? _email;
  int? _userId;
  String? _token;

  String? get email => _email;
  int? get userId => _userId;
  String? get token => _token;
  bool get isLoggedIn => _email != null && _token != null;

  void login(String email) {
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
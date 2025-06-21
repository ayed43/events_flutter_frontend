// app_controller.dart


import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
class AppController with ChangeNotifier {
  late Box _authBox;

  AppController() {
    _authBox = Hive.box('authBox');
  }

  void saveLoginData(Map<String, dynamic> user, String token) {
    _authBox.put('user', user);
    _authBox.put('token', token);
    notifyListeners();
  }

  Map<String, dynamic>? get user => _authBox.get('user');
  String? get token => _authBox.get('token');

  bool get isLoggedIn => token != null;

  void logout() {
    _authBox.clear();
    notifyListeners();
  }
}

// cache_controller.dart


import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
class CacheController with ChangeNotifier {
  late Box _authBox;

  CacheController() {
    _authBox = Hive.box('authBox');
  }

  void saveLoginData(Map<String, dynamic> user, String token) {
    _authBox.put('user', user);
    _authBox.put('token', token);
    notifyListeners();
  }

  Map<String, dynamic>? get user {
    final raw = _authBox.get('user');
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  String? get token => _authBox.get('token');

  bool get isLoggedIn => token != null;

  void logout() {
    _authBox.clear();
    notifyListeners();
  }
}

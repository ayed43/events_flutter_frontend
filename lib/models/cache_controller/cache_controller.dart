import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';

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

  Future<void> logout() async {
    final currentToken = token;

    // Attempt to logout from backend
    final url = Uri.parse('$serverUrl/api/logout');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Logout successful: ${response.body}');
        // Clear all user data from Hive
        await _authBox.clear();
        notifyListeners();
      } else {
        print('Logout failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Logout error: $e');
    }


  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginController extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  bool showPassword=false;

  togglePassword(){
    showPassword=!showPassword;
    notifyListeners();

  }
  Future<bool> loginUser({
    required String email,
    required String password,
    required BuildContext context,
     })
  async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final url = Uri.parse('http://10.0.2.2:8000/api/login'); // IP for Android emulator
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {

        return true;
      } else {
        error = data['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      error = 'Network error';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupController extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final url = Uri.parse('http://192.168.196.153:8000/api/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation": confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = data['message'] ?? 'Registration failed';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      error = 'Network error';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';

class CacheController with ChangeNotifier {
  late Box _authBox;
  List userFav=[];
  bool isFavOpen=false;
  CacheController() {
    _authBox = Hive.box('authBox');
  }

  void saveLoginData(Map<String, dynamic> user, String token) {
    _authBox.put('user', user);
    _authBox.put('token', token);
    _authBox.put('userFav', userFav);
    _authBox.put('isFavOpen',isFavOpen);
    notifyListeners();
  }

  List<dynamic> getUserFav() {
    final list = _authBox.get('userFav');
    return list is List ? list : [];
  }
// Setter: Save selected favorite category IDs
  void setUserFav(List<dynamic> favList) {
    _authBox.put('userFav', favList);
    notifyListeners();
  }

// Setter: Update isFavOpen flag
  void setIsFavOpen(bool isOpen) {
    _authBox.put('isFavOpen', isOpen);
    notifyListeners();
  }

// Get isFavOpen flag directly from Hive
  bool getIsFavOpen() {
    final value = _authBox.get('isFavOpen');
    return value is bool ? value : false;
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

  // Location getters and setters
  double? get myLat {
    final lat = _authBox.get('myLat');
    return lat is double ? lat : null;
  }

  double? get myLang {
    final lang = _authBox.get('myLang');
    return lang is double ? lang : null;
  }

  // Save location data
  void saveLocation(double latitude, double longitude) {
    _authBox.put('myLat', latitude);
    _authBox.put('myLang', longitude);
    _authBox.put('lastLocationUpdate', DateTime.now().toIso8601String());
    notifyListeners();
  }

  // Get last location update timestamp
  DateTime? get lastLocationUpdate {
    final timestamp = _authBox.get('lastLocationUpdate');
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Check if location data exists
  bool get hasLocationData => myLat != null && myLang != null;

  // Get location as a map
  Map<String, double>? get locationData {
    if (hasLocationData) {
      return {
        'latitude': myLat!,
        'longitude': myLang!,
      };
    }
    return null;
  }

  // Clear only location data
  void clearLocationData() {
    _authBox.delete('myLat');
    _authBox.delete('myLang');
    _authBox.delete('lastLocationUpdate');
    notifyListeners();
  }

  // Get formatted location string
  String get formattedLocation {
    if (hasLocationData) {
      return 'Lat: ${myLat!.toStringAsFixed(6)}, Lng: ${myLang!.toStringAsFixed(6)}';
    }
    return 'Location not available';
  }

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
        // Clear all user data from Hive (including location data)
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
import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';

class CacheController with ChangeNotifier {
  late Box _authBox;
  List userFav = [];
  bool isFavOpen = false;

  CacheController() {
    _authBox = Hive.box('authBox');
  }

  void saveLoginData(Map<String, dynamic> user, String token) {
    _authBox.put('user', user);
    _authBox.put('token', token);
    _authBox.put('userFav', userFav);
    _authBox.put('isFavOpen', isFavOpen);
    notifyListeners();
  }

  List<dynamic> getUserFav() {
    final list = _authBox.get('userFav');
    return list is List ? list : [];
  }

  // Setter: Save selected favorite category names (backward compatibility)
  void setUserFav(List<dynamic> favList) {
    _authBox.put('userFav', favList);
    notifyListeners();
  }

  // NEW: Store the favorite data for server submission (category_id, user_id mapping)
  void setUserFavoriteData(Map<String, dynamic> favoriteData) {
    _authBox.put('userFavoriteData', favoriteData);
    notifyListeners();
  }

  // NEW: Get favorite data for server submission
  Map<String, dynamic> getUserFavoriteData() {
    final data = _authBox.get('userFavoriteData');
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  // NEW: Store selected category IDs
  void setUserFavoriteCategoryIds(List<int> categoryIds) {
    _authBox.put('userFavoriteCategoryIds', categoryIds);
    notifyListeners();
  }

  // NEW: Get selected category IDs
  List<int> getUserFavoriteCategoryIds() {
    final list = _authBox.get('userFavoriteCategoryIds');
    if (list is List) {
      return list.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).toList();
    }
    return [];
  }

  // NEW: Get favorite data as list for server API
  List<Map<String, dynamic>> getFavoriteListForServer() {
    final favoriteData = getUserFavoriteData();
    return favoriteData.values.map((value) => Map<String, dynamic>.from(value)).toList();
  }

  // Setter: Update isFavOpen flag (now means favorites setup is completed)
  void setIsFavOpen(bool isOpen) {
    _authBox.put('isFavOpen', isOpen);
    // Also set the completion flag when favorites are saved
    if (isOpen) {
      _authBox.put('favoritesCompleted', true);
    }
    notifyListeners();
  }

  // Get isFavOpen flag directly from Hive
  bool getIsFavOpen() {
    final value = _authBox.get('isFavOpen');
    return value is bool ? value : false; // Changed default to false
  }

  // NEW: Check if user has completed favorites setup (never show again)
  bool hasFavoritesCompleted() {
    final value = _authBox.get('favoritesCompleted');
    return value is bool ? value : false;
  }

  // NEW: Mark favorites as completed (prevents showing the page again)
  void markFavoritesCompleted() {
    _authBox.put('favoritesCompleted', true);
    _authBox.put('isFavOpen', true);
    notifyListeners();
  }

  // NEW: Reset favorites completion (for testing or if user wants to change preferences)
  void resetFavoritesCompletion() {
    _authBox.put('favoritesCompleted', false);
    _authBox.put('isFavOpen', false);
    notifyListeners();
  }

  // NEW: Get current user ID from stored user data
  int getCurrentUserId() {
    final userData = user;
    if (userData != null && userData['id'] != null) {
      return userData['id'] is int ? userData['id'] : int.tryParse(userData['id'].toString()) ?? 0;
    }
    return 0;
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

        // Clear only authentication and session-specific data
        _clearAuthData();
        notifyListeners();
      } else {
        print('Logout failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Logout error: $e');
    }
  }

// Helper method to clear only authentication data
  void _clearAuthData() {
    // Remove authentication-related data
    _authBox.delete('user');
    _authBox.delete('token');

    // Remove location data (since it's user-session specific)
    _authBox.delete('myLat');
    _authBox.delete('myLang');
    _authBox.delete('lastLocationUpdate');

    // Keep favorites data:
    // - favoritesCompleted
    // - userFavoriteData
    // - userFavoriteCategoryIds
    // - userFav
    // - isFavOpen
  }
}
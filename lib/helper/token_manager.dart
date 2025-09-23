import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _hospitalPrefixKey = 'hospital_prefix';

  static Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      return true;
    } catch (e) {
      print('Error saving token to shared_preferences: $e');
      return false;
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token from shared_preferences: $e');
      return null;
    }
  }

  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      print('Error clearing token from shared_preferences: $e');
    }
  }

  static Future<bool> saveHospitalPrefix(String prefix) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_hospitalPrefixKey, prefix);
      return true;
    } catch (e) {
      print('Error saving hospital prefix to shared_preferences: $e');
      return false;
    }
  }

  static Future<String?> getHospitalPrefix() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_hospitalPrefixKey);
    } catch (e) {
      print('Error getting hospital prefix from shared_preferences: $e');
      return null;
    }
  }

  static Future<void> clearHospitalPrefix() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hospitalPrefixKey);
    } catch (e) {
      print('Error clearing hospital prefix from shared_preferences: $e');
    }
  }
}

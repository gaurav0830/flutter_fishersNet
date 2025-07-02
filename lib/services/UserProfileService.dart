import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  static const String baseUrl = 'http://192.168.89.28/fishing1/fishing_app1/api'; // Adjust to your API location

  /// Fetches user profile details by user_id
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) return {"success": false, "message": "User ID not found"};

    final url = Uri.parse("$baseUrl/get_profile.php?user_id=$userId");

    try {
      final response = await http.get(url);
      print("Profile Fetch Response: '${response.body}'");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Invalid response from server"};
    } catch (e) {
      print("Profile Fetch Error: $e");
      return {"success": false, "message": "An error occurred"};
    }
  }

  /// Updates the user's name and contact
  static Future<Map<String, dynamic>> updateUserProfile(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) return {"success": false, "message": "User ID not found"};

    final url = Uri.parse("$baseUrl/update_profile.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "name": name,
          "phone": phone,
        }),
      );

      print("Profile Update Response: '${response.body}'");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Invalid response from server"};
    } catch (e) {
      print("Profile Update Error: $e");
      return {"success": false, "message": "An error occurred"};
    }
  }

  /// Changes the user's password
  static Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) return {"success": false, "message": "User ID not found"};

    final url = Uri.parse("$baseUrl/change_password.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      print("Change Password Response: '${response.body}'");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Invalid response from server"};
    } catch (e) {
      print("Change Password Error: $e");
      return {"success": false, "message": "An error occurred"};
    }
  }

  /// Gets user ID from shared preferences
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}

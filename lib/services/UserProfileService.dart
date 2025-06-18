import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constant.dart';

class UserProfileService {
  /// Fetch user profile by ID from shared preferences
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id')?.toString();


    if (userId == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}/get_profile.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to load profile'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Update user profile (name and contact)
  static Future<Map<String, dynamic>> updateUserProfile(
      String name, String contact) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id')?.toString();


    if (userId == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    try {
      try {
        final response = await http.post(
          Uri.parse('${ApiConstant.baseUrl}/update_profile.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': userId,
            'name': name,
            'contact': contact,
          }),
        );

        print("Status: ${response.statusCode}");
        print("Body: '${response.body}'");

        if (response.statusCode != 200 || response.body.trim().isEmpty) {
          return {
            'success': false,
            'message': 'Server error or empty response: ${response.body}',
          };
        }

        return jsonDecode(response.body);
      } catch (e) {
        return {'success': false, 'message': 'Exception: $e'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Change user password (old password and new password)
  static Future<Map<String, dynamic>> changeUserPassword(
      String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id')?.toString();

    if (userId == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstant.baseUrl}/change_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}

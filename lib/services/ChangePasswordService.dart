import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.125.76.95/fishing1/fishing_app1/api'; // Update to your actual API

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      return {"success": false, "message": "User not logged in"};
    }

    final url = Uri.parse('$baseUrl/change_password.php');

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

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Invalid server response"};
    } catch (e) {
      return {"success": false, "message": "An error occurred"};
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';

class ApiService {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstant.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = '${ApiConstant.baseServerUrl}${ApiConstant.login}';
    print('Login API URL: $url');
    print('Sending Email: $email, Password: $password');

    final response = await http.post(
      Uri.parse(ApiConstant.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );


    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    return jsonDecode(response.body);
  }


  Future<Map<String, dynamic>> viewMagazines() async {
    final response = await http.get(
      Uri.parse(ApiConstant.viewMagazine),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> viewRescues() async {
    final response = await http.get(
      Uri.parse(ApiConstant.viewRescue),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }


  Future<Map<String, dynamic>> viewFish() async {
    final response = await http.get(
      Uri.parse(ApiConstant.viewFish),
      headers: {'Content-Type': 'application/json'},
    );
    print('Fish Response: ${response.body}');
    return jsonDecode(response.body);
  }



  Future<Map<String, dynamic>> addFeedback({
    int? userId,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstant.addFeedback),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'message': message,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> bookFish({
    required int userId,
    required int fishId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstant.bookFish),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'fish_id': fishId,
        'quantity': quantity,
      }),
    );
    print('Book Fish: ${response.body}');
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> uploadFishImage({
    required int fishId,
    required File image,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstant.uploadFishImage),
    );
    request.fields['fish_id'] = fishId.toString();
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    return jsonDecode(responseBody);
  }

  Future<Map<String, dynamic>> uploadMagazineImage({
    required int magazineId,
    required File image,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstant.uploadMagazineImage),
    );
    request.fields['magazine_id'] = magazineId.toString();
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    return jsonDecode(responseBody);
  }

  Future<Map<String, dynamic>> viewOrders() async {
    final response = await http.get(
      Uri.parse(ApiConstant.viewOrders),
      headers: {'Content-Type': 'application/json'},
    );
    print('View Orders: ${response.body}');
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getFeedbacks({required int? userId}) async {
    print('Fetching feedbacks for user_id: $userId'); // Check this

    if (userId == null) {
      return {'status': 'error', 'message': 'User ID is required'};
    }

    final response = await http.get(
      Uri.parse('${ApiConstant.viewFeedback}?user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Feedback Response: ${response.body}');
    return jsonDecode(response.body);
  }



}
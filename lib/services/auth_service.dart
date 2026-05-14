import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<bool> register(
      String email,
      String password,
      String name,
      String city,
      ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "name": name,
        "city": city,
      }),
    );
    print(response.body);

    return response.statusCode == 200;
  }

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["access_token"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      return true;
    }

    return false;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse("$baseUrl/me"),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/me"),
      headers: await getAuthHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update profile");
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  static Future<String?> uploadProfilePhoto(String filePath) async {
    final token = await getToken();

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/upload-profile-photo"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath("file", filePath),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      final imageUrl = data["image_url"];

      await updateProfile({"profile_image": imageUrl});

      return imageUrl;
    }

    return null;
  }

  static Future<String?> applyMakeup({

    String? style,

    String? imagePath,

    Map<String, dynamic>? customConfig,

  }) async {

    final token = await getToken();

    var request = http.MultipartRequest(

      "POST",

      Uri.parse("$baseUrl/apply-makeup"),
    );

    request.headers["Authorization"] =
    "Bearer $token";

    if (style != null) {

      request.fields["style"] = style;
    }

    if (customConfig != null) {
      request.fields["custom_config"] = jsonEncode({
        "lipstick_color": customConfig["lipstick_color"],
        "eyeshadow_color": customConfig["eyeshadow_color"],
        "blush_color": customConfig["blush_color"],
        "lipstick_intensity": customConfig["lipstick_intensity"],
        "eyeshadow_intensity": customConfig["eyeshadow_intensity"],
        "blush_intensity": customConfig["blush_intensity"],
      });
    }

    if (imagePath != null) {

      request.files.add(

        await http.MultipartFile.fromPath(
          "file",
          imagePath,
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200) {

      final responseData = jsonDecode(

        await response.stream.bytesToString(),
      );

      return responseData["image_url"];
    }

    return null;
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/clothing_item.dart';
import 'auth_service.dart';

class WardrobeService {
  static final List<ClothingItem> wardrobe = [];

  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<ClothingItem> uploadAndAnalyze({
    required File imageFile,
  }) async {
    final uri = Uri.parse("$baseUrl/upload");

    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final token = await AuthService.getToken();
    request.headers["Authorization"] = "Bearer $token";

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body);

      final colors =
          (data['colors'] as List<dynamic>?)?.join(',') ?? "";

      final weather =
          (data['weather'] as List<dynamic>?)?.join(',') ?? "";

      final category = data['category'] ?? "Tops";
      final subcategory = data['subcategory'] ?? "";

      print("UPLOAD ANALYZE RESULT:");
      print("category: $category");
      print("subcategory: $subcategory");
      print("colors: $colors");
      print("weather: $weather");
      print("style: ${data['style']}");

      return ClothingItem(
        imageUrl: data['image_url'] ?? "",
        category: category,
        subcategory: subcategory,
        color: colors,
        weather: weather,
        brand: data['brand'] ?? "",
        style: data['style'] ?? "",
        name: subcategory.toString().isNotEmpty ? subcategory : category,
        isSaved: false,
      );
    } else {
      throw Exception("Failed to analyze image");
    }
  }

  static Future<void> addItem(ClothingItem item) async {
    final uri = Uri.parse("$baseUrl/clothing");

    final headers = await AuthService.getAuthHeaders();

    print("ADDING ITEM TO BACKEND:");
    print(item.toJson());

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(item.toJson()),
    );

    print("ADD ITEM STATUS: ${response.statusCode}");
    print("ADD ITEM RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      item.isSaved = true;
      wardrobe.add(item);
    } else {
      throw Exception("Failed to save clothing item");
    }
  }

  static Future<void> updateItem(ClothingItem item) async {
    final uri = Uri.parse("$baseUrl/clothing/${item.id}");

    final headers = await AuthService.getAuthHeaders();

    print("UPDATING ITEM:");
    print(item.toJson());

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(item.toJson()),
    );

    print("UPDATE ITEM STATUS: ${response.statusCode}");
    print("UPDATE ITEM RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to update clothing item");
    }
  }

  static Future<List<ClothingItem>> getWardrobe() async {
    final uri = Uri.parse("$baseUrl/clothing");

    final headers = await AuthService.getAuthHeaders();

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;

      final items = data.map((e) => ClothingItem.fromJson(e)).toList();

      wardrobe.clear();
      wardrobe.addAll(items);

      return items;
    } else {
      throw Exception("Failed to fetch wardrobe");
    }
  }

  static Future<void> deleteItem(String itemId) async {
    final uri = Uri.parse("$baseUrl/clothing/$itemId");

    final headers = await AuthService.getAuthHeaders();

    final response = await http.delete(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      wardrobe.removeWhere((item) => item.id == itemId);
    } else {
      throw Exception("Failed to delete clothing item");
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/outfit.dart';
import '../services/auth_service.dart';

class OutfitService {
  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<Map<String, dynamic>> generateOutfit(
      String event, {
        List<int> excludeIds = const [],
      }) async {
    final uri = Uri.parse("$baseUrl/generate_outfit");

    final headers = await AuthService.getAuthHeaders();

    final body = {
      "event": event,
      "exclude_ids": excludeIds,
    };

    print("GENERATE OUTFIT REQUEST:");
    print(body);

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    print("GENERATE OUTFIT STATUS: ${response.statusCode}");
    print("GENERATE OUTFIT RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        if (data.containsKey("error")) {
          throw Exception(data["error"]);
        }

        return data;
      }

      throw Exception("Invalid response format");
    } else {
      throw Exception("Failed to generate outfit");
    }
  }

  static Future<Map<String, dynamic>> getShoppingRecommendations(
      String event,
      ) async {
    final uri = Uri.parse("$baseUrl/shopping_recommendations");

    final headers = await AuthService.getAuthHeaders();

    final body = {
      "event": event,
    };

    print("SHOPPING RECOMMENDATIONS REQUEST:");
    print(body);

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    print("SHOPPING RECOMMENDATIONS STATUS: ${response.statusCode}");
    print("SHOPPING RECOMMENDATIONS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        if (data.containsKey("error")) {
          throw Exception(data["error"]);
        }

        return data;
      }

      throw Exception("Invalid recommendations response format");
    } else {
      throw Exception("Failed to load shopping recommendations");
    }
  }

  static Future<void> saveOutfit(Map<String, dynamic> outfit) async {
    final headers = await AuthService.getAuthHeaders();

    final response = await http.post(
      Uri.parse("$baseUrl/outfits"),
      headers: headers,
      body: jsonEncode(outfit),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to save outfit");
    }
  }

  static Future<List<Outfit>> getOutfits() async {
    final headers = await AuthService.getAuthHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl/outfits"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;

      return data.map((e) => Outfit.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load outfits");
    }
  }

  static Future<void> deleteOutfit(String? id) async {
    final headers = await AuthService.getAuthHeaders();

    final response = await http.delete(
      Uri.parse("$baseUrl/outfits/$id"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete outfit");
    }
  }
}
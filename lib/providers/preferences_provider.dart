import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class PreferencesProvider extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:8000";

  List<String> preferredStyles = [];
  String preferredFit = "Regular";
  List<String> avoidSubcategories = [];
  String bodyShape = "None";

  bool loading = false;
  bool saving = false;

  Future<void> loadPreferences() async {
    loading = true;
    notifyListeners();

    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/user_preferences"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        preferredStyles = List<String>.from(data["preferred_styles"] ?? []);
        preferredFit = data["preferred_fit"] ?? "Regular";
        avoidSubcategories =
        List<String>.from(data["avoid_subcategories"] ?? []);
        bodyShape = data["body_shape"] ?? "None";
      }
    } catch (e) {
      debugPrint("Preferences load error: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> savePreferences() async {
    saving = true;
    notifyListeners();

    try {
      final headers = await AuthService.getAuthHeaders();

      final body = {
        "preferred_styles": preferredStyles,
        "preferred_fit": preferredFit,
        "avoid_subcategories": avoidSubcategories,
        "body_shape": bodyShape,
      };

      final response = await http.put(
        Uri.parse("$baseUrl/user_preferences"),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to save preferences");
      }
    } catch (e) {
      debugPrint("Preferences save error: $e");
    }

    saving = false;
    notifyListeners();
  }

  void toggleStyle(String style, bool selected) {
    if (selected) {
      if (!preferredStyles.contains(style)) {
        preferredStyles.add(style);
      }
    } else {
      preferredStyles.remove(style);
    }
    notifyListeners();
  }

  void toggleAvoid(String item, bool selected) {
    if (selected) {
      if (!avoidSubcategories.contains(item)) {
        avoidSubcategories.add(item);
      }
    } else {
      avoidSubcategories.remove(item);
    }
    notifyListeners();
  }

  void setFit(String value) {
    preferredFit = value;
    notifyListeners();
  }

  void setBodyShape(String value) {
    bodyShape = value;
    notifyListeners();
  }

  void setPreferredStyles(List<String> styles) {
    preferredStyles = styles;
    notifyListeners();
  }

  void setAvoid(List<String> items) {
    avoidSubcategories = items;
    notifyListeners();
  }
}
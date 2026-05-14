import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherService {
  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<Map<String, dynamic>?> getWeather({
    required String city,
  }) async {

    try {

      final response = await http.get(

        Uri.parse(
          "$baseUrl/weather?city=$city",
        ),
      );

      if (response.statusCode != 200) {
        return null;
      }

      return jsonDecode(response.body);

    } catch (e) {

      return null;
    }
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../services/weather_service.dart';
import 'generate_outfit_screen.dart';
import 'generate_makeup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool loadingWeather = true;

  double? temperature;
  String? condition;
  int? conditionId;
  double? feelsLike;

  @override
  void initState() {
    super.initState();

    loadWeather();
  }

  Future<void> loadWeather() async {

    try {

      final profile = await AuthService.getProfile();

      final city = profile["city"];

      if (city == null) {

        setState(() {
          loadingWeather = false;
        });

        return;
      }

      final data = await WeatherService.getWeather(
        city: city,
      );

      if (data == null) {

        setState(() {
          loadingWeather = false;
        });

        return;
      }

      setState(() {

        temperature = data["temperature"];
        feelsLike = data["feels_like"];

        condition = data["condition"];
        conditionId = data["condition_id"];

        loadingWeather = false;
      });

    } catch (e) {

      setState(() {
        loadingWeather = false;
      });
    }
  }

  IconData getWeatherIcon(int id) {

    if (id >= 200 && id < 300) {
      return Icons.thunderstorm;
    }

    if (id >= 300 && id < 400) {
      return Icons.grain;
    }

    if (id >= 500 && id < 600) {
      return Icons.umbrella;
    }

    if (id >= 600 && id < 700) {
      return Icons.ac_unit;
    }

    if (id >= 700 && id < 800) {
      return Icons.foggy;
    }

    if (id == 800) {
      return Icons.wb_sunny;
    }

    if (id > 800 && id < 900) {
      return Icons.cloud;
    }

    return Icons.wb_cloudy;
  }

  Widget buildNavigationButton({

    required BuildContext context,

    required String title,
    required String subtitle,

    required IconData icon,

    required Widget screen,
  }) {

    final theme = Theme.of(context);

    return InkWell(

      borderRadius: BorderRadius.circular(28),

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(
            builder: (_) => screen,
          ),
        );
      },

      child: Ink(

        padding: const EdgeInsets.all(22),

        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(28),

          color: theme.colorScheme.surfaceContainerHighest,

          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(

          children: [

            Container(

              width: 64,
              height: 64,

              decoration: BoxDecoration(

                shape: BoxShape.circle,

                color: theme.colorScheme.primary
                    .withOpacity(0.12),
              ),

              child: Icon(

                icon,

                size: 32,

                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(

                    title,

                    style: theme.textTheme.titleLarge
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(

                    subtitle,

                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Icon(

              Icons.arrow_forward_ios_rounded,

              size: 18,

              color: theme.colorScheme
                  .onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("AI Wardrobe"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(24),

                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.purple.shade200,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: loadingWeather

                  ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )

                  : Row(

                children: [

                  Container(

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),

                    child: Icon(

                      getWeatherIcon(conditionId ?? 800),

                      color: Colors.white,

                      size: 42,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(

                          "${temperature?.toStringAsFixed(1)}°C",

                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(

                          condition ?? "",

                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(

                          "Feels like ${feelsLike?.toStringAsFixed(1)}°C",

                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            buildNavigationButton(

              context: context,

              title: "Outfit",

              subtitle:
              "Create your outfit for the day",

              icon: Icons.checkroom,

              screen: const GenerateOutfitScreen(),
            ),

            const SizedBox(height: 20),

            buildNavigationButton(

              context: context,

              title: "Makeup",

              subtitle:
              "Try on makeup instantly",

              icon: Icons.brush,

              screen: const GenerateMakeupScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
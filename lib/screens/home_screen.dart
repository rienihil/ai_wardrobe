import 'package:ai_wardrobe/screens/generate_makeup_screen.dart';
import 'package:flutter/material.dart';
import 'generate_outfit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  "Add your clothes and get AI outfit ideas",
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Features",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,

                children: [
                  featureCard(
                    context,
                    "Generate Outfit",
                    Icons.style,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GenerateOutfitScreen(),
                        ),
                      );
                    },
                  ),

                  featureCard(
                    context,
                    "Makeup",
                    Icons.brush,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GenerateMakeupScreen(),
                        ),
                      );
                    },
                  )

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget featureCard(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ){
    return GestureDetector(

      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}
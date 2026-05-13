import 'package:flutter/material.dart';

import 'generate_outfit_screen.dart';
import 'generate_makeup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("AI Generation"),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.checkroom),
                text: "Outfit",
              ),
              Tab(
                icon: Icon(Icons.brush),
                text: "Makeup",
              ),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            GenerateOutfitScreen(),
            GenerateMakeupScreen(),
          ],
        ),
      ),
    );
  }
}
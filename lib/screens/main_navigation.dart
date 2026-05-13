import 'dart:io';

import 'package:ai_wardrobe/screens/outfits_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clothing_item.dart';
import '../services/wardrobe_service.dart';
import 'clothing_details_screen.dart';
import 'home_screen.dart';
import 'wardrobe_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  int currentIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    WardrobeScreen(),
    SizedBox(),
    OutfitsScreen(),
    ProfileScreen(),
  ];

  void pickImageAndAnalyze(BuildContext parentContext, {bool fromCamera = true}) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (image == null) return;

    try {
      final item = await WardrobeService.uploadAndAnalyze(
        imageFile: File(image.path),
      );

      Navigator.push(
        parentContext,
        MaterialPageRoute(
          builder: (_) => ClothingDetailsScreen(item: item),
        ),
      ).then((_) {
      });

    } catch (e) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text("Failed to analyze image: $e")),
      );
    }
  }

  void openAddMenu() {

    final parentContext = context;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) {

        return Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Column(
            children: [

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take photo"),
                onTap: () {
                  Navigator.pop(context);
                  pickImageAndAnalyze(parentContext, fromCamera: true);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Upload from gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImageAndAnalyze(parentContext, fromCamera: false);
                },
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {

          if(index == 2){
            openAddMenu();
            return;
          }

          setState(() {
            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: "Wardrobe",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: "",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.style),
            label: "Outfits",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),

        ],
      ),
    );
  }
}
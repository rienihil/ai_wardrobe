import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';

class GenerateMakeupScreen extends StatefulWidget {
  const GenerateMakeupScreen({super.key});

  @override
  State<GenerateMakeupScreen> createState() => _GenerateMakeupScreenState();
}

class _GenerateMakeupScreenState extends State<GenerateMakeupScreen> {
  String selectedMakeup = "natural";

  bool makeupLoading = false;

  String? generatedMakeupUrl;

  final makeupStyles = [
    "natural",
    "glam",
    "korean",
    "goth",
    "soft_glam",
    "editorial",
  ];

  Future<void> generateMakeup({
    bool useCustomImage = false,
  }) async {
    setState(() {
      makeupLoading = true;
    });

    try {
      String? imagePath;

      if (useCustomImage) {
        final picker = ImagePicker();

        final picked =
        await picker.pickImage(source: ImageSource.gallery);

        if (picked != null) {
          imagePath = picked.path;
        }
      }

      final result = await AuthService.applyMakeup(
        style: selectedMakeup,
        imagePath: imagePath,
      );

      if (result != null) {
        setState(() {
          generatedMakeupUrl = result;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Makeup Error: $e")),
      );
    }

    setState(() {
      makeupLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Makeup Generator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Choose Makeup Style",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            DropdownButton<String>(
              value: selectedMakeup,
              isExpanded: true,
              items: makeupStyles.map((style) {
                return DropdownMenuItem(
                  value: style,
                  child: Text(
                    style.replaceAll("_", " "),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMakeup = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.face_retouching_natural),
              label: const Text(
                "Generate From Profile Photo",
              ),
              onPressed: makeupLoading
                  ? null
                  : () => generateMakeup(),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text(
                "Upload Another Face Photo",
              ),
              onPressed: makeupLoading
                  ? null
                  : () => generateMakeup(
                useCustomImage: true,
              ),
            ),

            const SizedBox(height: 24),

            if (makeupLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (generatedMakeupUrl != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      generatedMakeupUrl!,
                      height: 450,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Style: ${selectedMakeup.replaceAll("_", " ")}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
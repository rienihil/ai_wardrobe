import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/outfit_service.dart';

class GenerateOutfitScreen extends StatefulWidget {
  const GenerateOutfitScreen({super.key});

  @override
  State<GenerateOutfitScreen> createState() => _GenerateOutfitScreenState();
}

class _GenerateOutfitScreenState extends State<GenerateOutfitScreen> {
  Map<String, dynamic>? outfit;
  String explanation = "";
  double? temperature;
  String? condition;
  String? responseEvent;

  bool loading = false;
  bool saving = false;

  String selectedEvent = "walk";

  List<int> lastOutfitIds = [];
  List<dynamic> recommendations = [];

  final events = [
    "walk",
    "date",
    "office",
    "sport",
    "party",
    "university",
  ];

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

  Future<void> generate() async {
    setState(() {
      loading = true;
      recommendations = [];
    });

    try {
      final data = await OutfitService.generateOutfit(
        selectedEvent,
        excludeIds: lastOutfitIds,
      );

      final List<int> newOutfitIds = [];

      if (data["outfit_ids"] is List) {
        for (final id in data["outfit_ids"]) {
          if (id is int) {
            newOutfitIds.add(id);
          }
        }
      }

      setState(() {
        outfit = data["outfit"];
        explanation = data["explanation"] ?? "";
        temperature = (data["temperature"] as num?)?.toDouble();
        condition = data["condition"]?.toString();
        responseEvent = data["event"]?.toString();
        lastOutfitIds = newOutfitIds;
      });

      await loadRecommendations();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> loadRecommendations() async {
    try {
      final data = await OutfitService.getShoppingRecommendations(
        selectedEvent,
      );

      setState(() {
        recommendations = data["recommendations"] ?? [];
      });
    } catch (e) {
      print("Recommendations error: $e");

      setState(() {
        recommendations = [];
      });
    }
  }

  Future<void> saveOutfit() async {
    if (outfit == null || saving) return;

    setState(() {
      saving = true;
    });

    try {
      await OutfitService.saveOutfit(outfit!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Outfit saved!")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

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

  String prettyLabel(String value) {
    if (value.isEmpty) return "";

    final special = {
      "t-shirt": "T-shirt",
      "tank_top": "Tank top",
      "sport_shoes": "Sport shoes",
    };

    if (special.containsKey(value)) {
      return special[value]!;
    }

    return value
        .replaceAll("_", " ")
        .split(" ")
        .map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    })
        .join(" ");
  }



  Widget clothingImage(dynamic item) {
    if (item == null) return const SizedBox();

    final imageUrl = item["image_url"];

    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      height: 160,
      width: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported),
            );
          },
        ),
      ),
    );
  }

  Widget clothingLabel(String label, dynamic item) {
    if (item == null) return const SizedBox();

    final subcategory = item["subcategory"]?.toString();
    final style = item["style"]?.toString();
    final color = item["color"]?.toString();

    return SizedBox(
      width: 145,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          clothingImage(item),

          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),

          if (subcategory != null && subcategory.isNotEmpty)
            Text(
              prettyLabel(subcategory),
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),

          if (style != null && style.isNotEmpty)
            Text(
              style,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),

          if (color != null && color.isNotEmpty)
            Text(
              color,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget buildRecommendationsBlock() {
    if (recommendations.isEmpty) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.only(top: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Wardrobe suggestions",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "These are not required, but they could improve your wardrobe for this occasion.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            ...recommendations.map((rec) {
              final title = rec["title"]?.toString() ?? "Suggested item";
              final category = rec["category"]?.toString() ?? "";
              final subcategory = rec["subcategory"]?.toString() ?? "";
              final color = rec["color"]?.toString() ?? "";
              final style = rec["style"]?.toString() ?? "";
              final priority = rec["priority"]?.toString() ?? "";
              final reason = rec["reason"]?.toString() ?? "";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (category.isNotEmpty)
                          buildSmallChip(category),
                        if (subcategory.isNotEmpty)
                          buildSmallChip(prettyLabel(subcategory)),
                        if (color.isNotEmpty)
                          buildSmallChip(color),
                        if (style.isNotEmpty)
                          buildSmallChip(style),
                        if (priority.isNotEmpty)
                          buildSmallChip(priority),
                      ],
                    ),

                    if (reason.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        reason,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget buildSmallChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  Widget makeupSection() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Divider(height: 40),

        const Text(
          "AI Makeup Generator",
          style: TextStyle(
            fontSize: 20,
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
              child: Text(style.replaceAll("_", " ")),
            );

          }).toList(),

          onChanged: (value) {

            setState(() {
              selectedMakeup = value!;
            });
          },
        ),

        const SizedBox(height: 12),

        ElevatedButton.icon(
          icon: const Icon(Icons.face_retouching_natural),

          label: const Text(
            "Generate Makeup From Profile Photo",
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

        const SizedBox(height: 20),

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
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventLabel = prettyLabel(selectedEvent);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Outfit Generator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Occasion",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButton<String>(
              value: selectedEvent,
              isExpanded: true,
              items: events.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(prettyLabel(e)),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedEvent = value;

                  outfit = null;
                  explanation = "";
                  temperature = null;
                  condition = null;
                  responseEvent = null;
                  lastOutfitIds = [];
                  recommendations = [];
                });
              },
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: Text(
                loading ? "Generating..." : "Generate Outfit",
              ),
              onPressed: loading ? null : generate,
            ),

            const SizedBox(height: 20),

            if (loading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (!loading && outfit != null) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Generated for: ${prettyLabel(responseEvent ?? eventLabel)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      if (temperature != null)
                        Text(
                          "Temperature: $temperature°C",
                          style: const TextStyle(fontSize: 13),
                        ),

                      if (condition != null && condition!.isNotEmpty)
                        Text(
                          "Condition: $condition",
                          style: const TextStyle(fontSize: 13),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Wrap(
                children: [
                  clothingLabel("Top", outfit!["top"]),
                  clothingLabel("Bottom", outfit!["bottom"]),
                  clothingLabel("Dress", outfit!["dress"]),
                  clothingLabel("Shoes", outfit!["shoes"]),
                  clothingLabel("Outerwear", outfit!["outerwear"]),
                ],
              ),

              const SizedBox(height: 20),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    explanation,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),

              buildRecommendationsBlock(),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(saving ? "Saving..." : "Save Outfit"),
                onPressed: saving ? null : saveOutfit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
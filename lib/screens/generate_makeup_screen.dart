import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';

class GenerateMakeupScreen extends StatefulWidget {
  const GenerateMakeupScreen({super.key});

  @override
  State<GenerateMakeupScreen> createState() =>
      _GenerateMakeupScreenState();
}

class _GenerateMakeupScreenState
    extends State<GenerateMakeupScreen>
    with SingleTickerProviderStateMixin {

  late TabController tabController;

  String selectedIntensity = "soft";
  String selectedTemperature = "warm";

  bool makeupLoading = false;

  String? presetImageUrl;
  String? customImageUrl;

  final intensities = [
    "soft",
    "balanced",
    "bold",
  ];

  final temperatures = [
    "warm",
    "cool",
    "neutral",
  ];

  Color lipstickHex = const Color(0xFFBB5322);
  Color blushHex = const Color(0xFFEA9890);
  Color eyeshadowHex = const Color(0xFFBB5322);

  double lipstickIntensity = 0.35;
  double blushIntensity = 0.25;
  double eyeshadowIntensity = 0.25;

  String get selectedMakeup =>
      "${selectedIntensity}_${selectedTemperature}";

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  String toHex(Color c) {
    return '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
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

        final picked = await picker.pickImage(
          source: ImageSource.gallery,
        );

        if (picked != null) {
          imagePath = picked.path;
        }
      }

      final isCustom = tabController.index == 1;

      final config = isCustom
          ? {
        "lipstick_color": toHex(lipstickHex),
        "eyeshadow_color": toHex(eyeshadowHex),
        "blush_color": toHex(blushHex),

        "lipstick_intensity": lipstickIntensity,
        "eyeshadow_intensity": eyeshadowIntensity,
        "blush_intensity": blushIntensity,
      }
          : null;

      final result = await AuthService.applyMakeup(
        style: isCustom ? null : selectedMakeup,
        imagePath: imagePath,
        customConfig: config,
      );
      if (result != null) {
        setState(() {
          if (tabController.index == 0) {
            presetImageUrl = result;
          } else {
            customImageUrl = result;
          }
        });
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Makeup Error: $e",
          ),
        ),
      );
    }

    setState(() {
      makeupLoading = false;
    });
  }


  Color selectedColor = Colors.pink;

  Future<void> openColorPicker({
    required Color current,
    required ValueChanged<Color> onChanged,
  }) async {
    Color temp = current;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pick Color"),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: current,
              enableAlpha: false,
              onColorChanged: (c) => temp = c,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                onChanged(temp);
                Navigator.pop(context);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }
  Widget buildColorPicker({
    required String title,
    required Color color,
    required ValueChanged<Color> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => openColorPicker(
              current: color,
              onChanged: onChanged,
            ),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlider({

    required String title,
    required double value,
    required Function(double) onChanged,
  }) {

    final theme = Theme.of(context);

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(20),

        color: theme.colorScheme.surfaceContainerHighest,
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [

              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                value.toStringAsFixed(2),
              ),
            ],
          ),

          Slider(
            value: value,
            min: 0,
            max: 1,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(

      appBar: AppBar(

        leading: IconButton(

          icon: const Icon(Icons.arrow_back_ios_new),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text("Makeup"),

        bottom: TabBar(

          controller: tabController,

          tabs: const [

            Tab(
              text: "Presets",
              icon: Icon(Icons.auto_awesome),
            ),

            Tab(
              text: "Custom",
              icon: Icon(Icons.tune),
            ),
          ],
        ),
      ),

      body: TabBarView(

        controller: tabController,

        children: [

          ListView(

            padding: const EdgeInsets.all(16),

            children: [

              Text(
                "Choose Makeup Style",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Intensity",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(

                value: selectedIntensity,

                items: intensities.map((style) {

                  return DropdownMenuItem(
                    value: style,
                    child: Text(style),
                  );

                }).toList(),

                onChanged: (value) {

                  setState(() {
                    selectedIntensity = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              Text(
                "Color Temperature",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(

                value: selectedTemperature,

                items: temperatures.map((style) {

                  return DropdownMenuItem(
                    value: style,
                    child: Text(style),
                  );

                }).toList(),

                onChanged: (value) {

                  setState(() {
                    selectedTemperature = value!;
                  });
                },
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(

                icon: const Icon(
                  Icons.face_retouching_natural,
                ),

                label: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  child: Text(
                    "Generate From Profile Photo",
                  ),
                ),

                onPressed: makeupLoading
                    ? null
                    : () => generateMakeup(),
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(

                icon: const Icon(Icons.photo),

                label: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  child: Text(
                    "Upload Another Face Photo",
                  ),
                ),

                onPressed: makeupLoading
                    ? null
                    : () => generateMakeup(
                  useCustomImage: true,
                ),
              ),
              if (presetImageUrl != null) ...[
                const SizedBox(height: 24),

                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    presetImageUrl!,
                    height: 420,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),

          ListView(

            padding: const EdgeInsets.all(16),

            children: [

              buildColorPicker(

                title: "Lipstick Color",

                color: lipstickHex,

                onChanged: (c) {
                  setState(() {
                    lipstickHex = c;
                  });
                },
              ),

              const SizedBox(height: 20),

              buildSlider(

                title: "Lipstick Intensity",

                value: lipstickIntensity,

                onChanged: (v) {
                  setState(() {
                    lipstickIntensity = v;
                  });
                },
              ),

              const SizedBox(height: 20),

              buildColorPicker(

                title: "Blush Color",

                color: blushHex,

                onChanged: (c) {
                  setState(() {
                    blushHex = c;
                  });
                },
              ),

              const SizedBox(height: 20),

              buildSlider(

                title: "Blush Intensity",

                value: blushIntensity,

                onChanged: (v) {
                  setState(() {
                    blushIntensity = v;
                  });
                },
              ),

              const SizedBox(height: 20),

              buildColorPicker(

                title: "Eyeshadow Color",

                color: eyeshadowHex,

                onChanged: (c) {
                  setState(() {
                    eyeshadowHex = c;
                  });
                },
              ),

              const SizedBox(height: 20),

              buildSlider(

                title: "Eyeshadow Intensity",

                value: eyeshadowIntensity,

                onChanged: (v) {
                  setState(() {
                    eyeshadowIntensity = v;
                  });
                },
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(

                icon: const Icon(
                  Icons.face_retouching_natural,
                ),

                label: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  child: Text(
                    "Generate From Profile Photo",
                  ),
                ),

                onPressed: makeupLoading
                    ? null
                    : () => generateMakeup(),
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(

                icon: const Icon(Icons.photo),

                label: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  child: Text(
                    "Upload Another Face Photo",
                  ),
                ),

                onPressed: makeupLoading
                    ? null
                    : () => generateMakeup(
                  useCustomImage: true,
                ),
              ),
              if (customImageUrl != null) ...[
                const SizedBox(height: 24),

                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    customImageUrl!,
                    height: 420,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
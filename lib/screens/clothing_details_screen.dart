import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../services/wardrobe_service.dart';

class ClothingDetailsScreen extends StatefulWidget {
  final ClothingItem item;

  const ClothingDetailsScreen({super.key, required this.item});

  @override
  State<ClothingDetailsScreen> createState() => _ClothingDetailsScreenState();
}

class _ClothingDetailsScreenState extends State<ClothingDetailsScreen> {
  final List<String> categories = [
    "Tops",
    "Bottoms",
    "Dresses",
    "Shoes",
    "Outerwear",
    "Accessories"
  ];

  final Map<String, List<String>> subcategoriesByCategory = {
    "Tops": [
      "t-shirt",
      "tank_top",
      "longsleeve",
      "top",
      "shirt",
      "blouse",
      "sweatshirt",
      "hoodie",
      "sweater",
    ],
    "Bottoms": [
      "jeans",
      "trousers",
      "skirt",
      "shorts",
      "leggings",
      "sweatpants",
    ],
    "Dresses": [
      "dress",
    ],
    "Shoes": [
      "sneakers",
      "sport_shoes",
      "heels",
      "boots",
      "flats",
    ],
    "Outerwear": [
      "coat",
      "jacket",
      "blazer",
      "cardigan",
      "puffer",
    ],
    "Accessories": [
      "hat",
    ],
  };

  final List<String> weather = [
    "Any",
    "Hot",
    "Warm",
    "Chilly",
    "Cold",
    "Wind",
    "Rain",
    "Snow"
  ];

  final List<String> colors = [
    "Black",
    "White",
    "Gray",
    "Brown",
    "Red",
    "Blue",
    "Green",
    "Yellow",
    "Purple",
    "Pink"
  ];

  List<String> selectedWeather = [];
  List<String> selectedColors = [];

  late TextEditingController brandController;
  late TextEditingController styleController;

  bool saving = false;
  bool deleting = false;

  @override
  void initState() {
    super.initState();

    brandController = TextEditingController(text: widget.item.brand);
    styleController = TextEditingController(text: widget.item.style);

    if (!categories.contains(widget.item.category)) {
      widget.item.category = "Tops";
    }

    final availableSubcategories =
        subcategoriesByCategory[widget.item.category] ?? [];

    if (widget.item.subcategory.isEmpty ||
        !availableSubcategories.contains(widget.item.subcategory)) {
      widget.item.subcategory =
      availableSubcategories.isNotEmpty ? availableSubcategories.first : "";
    }

    selectedWeather = widget.item.weather
        .split(',')
        .map((e) => normalizeUiValue(e))
        .where((e) => e.isNotEmpty && weather.contains(e))
        .toList();

    selectedColors = widget.item.color
        .split(',')
        .map((e) => normalizeUiValue(e))
        .where((e) => e.isNotEmpty && colors.contains(e))
        .toList();
  }

  @override
  void dispose() {
    brandController.dispose();
    styleController.dispose();
    super.dispose();
  }

  String normalizeUiValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return "";

    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
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

  Future<void> saveOrUpdateItem() async {
    if (saving) return;

    setState(() {
      saving = true;
    });

    try {
      widget.item.weather = selectedWeather.join(',');
      widget.item.color = selectedColors.join(',');
      widget.item.brand = brandController.text.trim();
      widget.item.style = styleController.text.trim();

      widget.item.name = widget.item.subcategory.isNotEmpty
          ? widget.item.subcategory
          : widget.item.category;

      print("SAVE / UPDATE ITEM FROM DETAILS:");
      print(widget.item.toJson());

      if (!widget.item.isSaved) {
        await WardrobeService.addItem(widget.item);
        widget.item.isSaved = true;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Item saved!")),
          );
        }
      } else {
        await WardrobeService.updateItem(widget.item);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Item updated!")),
          );
        }
      }

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  Future<void> deleteItem() async {
    if (deleting || widget.item.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete item?"),
          content: const Text(
            "This clothing item will be removed from your wardrobe.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      deleting = true;
    });

    try {
      await WardrobeService.deleteItem(widget.item.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          deleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSubcategories =
        subcategoriesByCategory[widget.item.category] ?? [];

    final bool isExistingItem = widget.item.isSaved && widget.item.id != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isExistingItem ? "Edit Item" : "New Item"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.item.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.item.imageUrl,
                width: double.infinity,
                height: 260,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    alignment: Alignment.center,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),

          buildDropdown(
            "Category",
            widget.item.category,
            categories,
                (value) {
              if (value == null) return;

              setState(() {
                widget.item.category = value;

                final subs = subcategoriesByCategory[value] ?? [];
                widget.item.subcategory =
                subs.isNotEmpty ? subs.first : "";
              });
            },
          ),

          buildDropdown(
            "Subcategory",
            widget.item.subcategory,
            currentSubcategories,
                (value) {
              if (value == null) return;

              setState(() {
                widget.item.subcategory = value;
              });
            },
          ),

          const SizedBox(height: 16),

          const Text(
            "Weather",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weather.map((w) {
              final isSelected = selectedWeather.contains(w);

              return FilterChip(
                label: Text(w),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (!selectedWeather.contains(w)) {
                        selectedWeather.add(w);
                      }
                    } else {
                      selectedWeather.remove(w);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          const Text(
            "Colors",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((c) {
              final isSelected = selectedColors.contains(c);

              return FilterChip(
                label: Text(c),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (!selectedColors.contains(c)) {
                        selectedColors.add(c);
                      }
                    } else {
                      selectedColors.remove(c);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: brandController,
            decoration: const InputDecoration(
              labelText: "Brand",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: styleController,
            decoration: const InputDecoration(
              labelText: "Style",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: saving ? null : saveOrUpdateItem,
            child: Text(
              saving
                  ? (isExistingItem ? "Updating..." : "Saving...")
                  : (isExistingItem ? "Update Item" : "Save Item"),
            ),
          ),

          if (isExistingItem) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: Text(deleting ? "Deleting..." : "Delete Item"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: deleting ? null : deleteItem,
            ),
          ],
        ],
      ),
    );
  }

  Widget buildDropdown(
      String title,
      String value,
      List<String> items,
      Function(String?) onChanged,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: SizedBox(
        width: 170,
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: const Text("Select"),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(prettyLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
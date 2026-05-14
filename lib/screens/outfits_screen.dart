import 'dart:io';

import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/outfit_service.dart';
import 'outfit_details_screen.dart';

class OutfitsScreen extends StatefulWidget {
  @override
  _OutfitsScreenState createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  final TextEditingController searchController = TextEditingController();

  List<Outfit> allOutfits = [];
  List<Outfit> filteredOutfits = [];

  late Future<List<Outfit>> outfitsFuture;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadOutfits();
  }

  void refresh() {
    setState(() {
      outfitsFuture = OutfitService.getOutfits();
    });
  }

  Future<void> loadOutfits() async {
    final data = await OutfitService.getOutfits();

    setState(() {
      allOutfits = data;
      filteredOutfits = data;
      loading = false;
    });
  }

  void onSearch(String value) {
    setState(() {
      filteredOutfits = allOutfits.where((o) {
        final title = (o.title ?? "").toLowerCase();
        return title.contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Outfits")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search outfits by title...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: onSearch,
            ),
          ),

          Expanded(
            child: filteredOutfits.isEmpty
                ? const Center(child: Text("No matches"))
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: filteredOutfits.length,
              itemBuilder: (context, index) {
                final outfit = filteredOutfits[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OutfitDetailScreen(outfit: outfit),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GridView.count(
                              physics:
                              const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: 1,
                              children: [
                                if (outfit.top != null)
                                  _thumb(outfit.top!.imageUrl),
                                if (outfit.bottom != null)
                                  _thumb(outfit.bottom!.imageUrl),
                                if (outfit.shoes != null)
                                  _thumb(outfit.shoes!.imageUrl),
                                if (outfit.outerwear != null)
                                  _thumb(outfit.outerwear!.imageUrl),
                                if (outfit.dress != null)
                                  _thumb(outfit.dress!.imageUrl),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            outfit.title ?? "Outfit",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.image_not_supported,
                color: Theme.of(context).colorScheme.outline,
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildImage(ClothingItem? item) {
    if (item == null || item.imageUrl.isEmpty) {
      return SizedBox(width: 50);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Image.network(
        item.imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
    );
  }
}
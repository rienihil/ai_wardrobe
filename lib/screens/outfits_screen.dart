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
  late Future<List<Outfit>> outfitsFuture;

  @override
  void initState() {
    super.initState();
    outfitsFuture = OutfitService.getOutfits();
  }

  void refresh() {
    setState(() {
      outfitsFuture = OutfitService.getOutfits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Outfits")),
      body: FutureBuilder<List<Outfit>>(
        future: outfitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No outfits yet"));
          }

          final outfits = snapshot.data!;

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              final outfit = outfits[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OutfitDetailScreen(outfit: outfit),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        Container(
                          height: 120,
                          child: GridView(
                            physics: const NeverScrollableScrollPhysics(), // no scroll
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                            children: [

                              if (outfit.top != null)
                                _buildThumb(outfit.top!.imageUrl),
                              if (outfit.bottom != null)
                                _buildThumb(outfit.bottom!.imageUrl),
                              if (outfit.shoes != null)
                                _buildThumb(outfit.shoes!.imageUrl),
                              if (outfit.outerwear != null)
                                _buildThumb(outfit.outerwear!.imageUrl),
                              if (outfit.dress != null)
                                _buildThumb(outfit.dress!.imageUrl),

                            ],
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "Outfit ${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  Widget _buildThumb(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: Icon(Icons.image_not_supported, size: 30),
          );
        },
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
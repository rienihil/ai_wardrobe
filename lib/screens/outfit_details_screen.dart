import 'dart:io';

import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/outfit_service.dart';

class OutfitDetailScreen extends StatelessWidget {
  final Outfit outfit;

  const OutfitDetailScreen({required this.outfit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Outfit"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await deleteOutfit(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (outfit.title != null)
                    Text(
                      outfit.title!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 8),

                  if (outfit.description != null)
                    Text(
                      outfit.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            _buildBigImage(context, outfit.top),
            _buildBigImage(context, outfit.bottom),
            _buildBigImage(context, outfit.dress),
            _buildBigImage(context, outfit.shoes),
            _buildBigImage(context, outfit.outerwear),

          ],
        ),
      ),
    );
  }

  Widget _buildBigImage(BuildContext context, item) {
    if (item == null || item.imageUrl.isEmpty) return const SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: screenWidth * 0.75,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 220,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                child: Icon(Icons.image_not_supported, size: 50),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> deleteOutfit(BuildContext context) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete outfit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await OutfitService.deleteOutfit(outfit.id);

      Navigator.pop(context);
    }
  }
}
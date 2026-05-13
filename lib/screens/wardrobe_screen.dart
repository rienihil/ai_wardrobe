import 'package:flutter/material.dart';

import '../models/clothing_item.dart';
import '../services/wardrobe_service.dart';
import 'clothing_details_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {

  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Tops",
    "Bottoms",
    "Dresses",
    "Shoes",
    "Outerwear",
    "Accessories"
  ];

  late Future<List<ClothingItem>> wardrobeFuture;

  @override
  void initState() {
    super.initState();
    wardrobeFuture = WardrobeService.getWardrobe();
  }

  void refreshWardrobe() {
    setState(() {
      wardrobeFuture = WardrobeService.getWardrobe();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Wardrobe"),
      ),

      body: Column(
        children: [

          SizedBox(
            height: 50,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,

              itemBuilder: (context,index){

                final category = categories[index];
                final isSelected = category == selectedCategory;

                return GestureDetector(

                  onTap: (){
                    setState(() {
                      selectedCategory = category;
                    });
                  },

                  child: Container(

                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    decoration: BoxDecoration(

                      color: isSelected
                          ? Colors.black
                          : Colors.grey[200],

                      borderRadius: BorderRadius.circular(20),
                    ),

                    alignment: Alignment.center,

                    child: Text(
                      category,

                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(

            child: FutureBuilder<List<ClothingItem>>(

              future: wardrobeFuture,

              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Your wardrobe is empty"),
                  );
                }

                final items = snapshot.data!.where((item){

                  if(selectedCategory == "All") return true;

                  return item.category == selectedCategory;

                }).toList();

                if(items.isEmpty){
                  return const Center(
                    child: Text("No clothes in this category"),
                  );
                }

                return GridView.builder(

                  padding: const EdgeInsets.all(10),

                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),

                  itemCount: items.length,

                  itemBuilder: (context,index){

                    final item = items[index];

                    return GestureDetector(

                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ClothingDetailsScreen(item: item),
                          ),
                        ).then((_) => refreshWardrobe());
                      },

                      child: Container(

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey[200],
                        ),

                        child: ClipRRect(

                          borderRadius: BorderRadius.circular(15),

                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
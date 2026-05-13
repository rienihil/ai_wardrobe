class ClothingItem {
  String? id;
  String imageUrl;

  String category;
  String subcategory;

  String weather;
  String color;
  String brand;
  String style;
  String name;

  bool isSaved;

  ClothingItem({
    this.id,
    required this.imageUrl,
    this.category = "Tops",
    this.subcategory = "",
    this.weather = "",
    this.color = "",
    this.brand = "",
    this.style = "",
    this.name = "",
    this.isSaved = false,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id']?.toString(),
      imageUrl: json['image_url'] ?? "",
      category: json['category'] ?? "Tops",
      subcategory: json['subcategory'] ?? "",
      weather: json['weather'] ?? "",
      color: json['color'] ?? "",
      brand: json['brand'] ?? "",
      style: json['style'] ?? "",
      name: json['name'] ?? "",
      isSaved: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "category": category,
      "subcategory": subcategory,
      "color": color,
      "style": style,
      "weather": weather,
      "brand": brand,
      "image_url": imageUrl,
    };
  }
}
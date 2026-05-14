import 'clothing_item.dart';

class Outfit {
  String? id;

  String? title;
  String? description;

  ClothingItem? top;
  ClothingItem? bottom;
  ClothingItem? dress;
  ClothingItem? shoes;
  ClothingItem? outerwear;

  Outfit({
    this.id,
    this.title,
    this.description,
    this.top,
    this.bottom,
    this.dress,
    this.shoes,
    this.outerwear,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      top: json['top'] != null ? ClothingItem.fromJson(json['top']) : null,
      bottom: json['bottom'] != null ? ClothingItem.fromJson(json['bottom']) : null,
      dress: json['dress'] != null ? ClothingItem.fromJson(json['dress']) : null,
      shoes: json['shoes'] != null ? ClothingItem.fromJson(json['shoes']) : null,
      outerwear: json['outerwear'] != null ? ClothingItem.fromJson(json['outerwear']) : null,
    );
  }
}
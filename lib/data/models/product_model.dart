// lib/data/models/product_model.dart
class ProductModel {
  final int id;
  final String title;
  final String description;
  final num price;
  final num rating;
  final String thumbnail;
  final List<String> images;
  final String category;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.thumbnail,
    required this.images,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final images = <String>[];
    if (json['images'] != null && json['images'] is List) {
      (json['images'] as List).forEach((e) {
        images.add(e.toString());
      });
    }
    return ProductModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      rating: json['rating'] ?? 0,
      thumbnail: json['thumbnail'] ?? (images.isNotEmpty ? images.first : ''),
      images: images,
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'rating': rating,
        'thumbnail': thumbnail,
        'images': images,
        'category': category,
      };
}

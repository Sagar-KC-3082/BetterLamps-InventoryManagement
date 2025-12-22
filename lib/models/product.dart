class Product {
  String id;
  String name;
  double basePrice;
  List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.basePrice,
    List<String>? images,
  }) : images = images ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'images': images,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      basePrice: (map['basePrice'] as num).toDouble(),
      images: map['images'] != null
          ? List<String>.from(map['images'] as List)
          : [],
    );
  }

  Product copyWith({
    String? id,
    String? name,
    double? basePrice,
    List<String>? images,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      images: images ?? this.images,
    );
  }
}

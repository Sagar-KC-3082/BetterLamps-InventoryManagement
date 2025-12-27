import 'cost_price.dart';

/// Represents a 3D-printed lamp product in the inventory.
class Product {
  /// Unique identifier for the product
  final String id;

  /// Product name/title
  final String name;

  /// Product code for easy reference (e.g., "BL-001")
  final String productCode;

  /// Date when the product was created/added to inventory
  final DateTime createdDate;

  /// Original retail price (MSRP)
  final double originalPrice;

  /// Current selling price (may include discounts)
  final double currentSellingPrice;

  /// List of image URLs or local paths
  final List<String> images;

  /// Manufacturing cost breakdown
  final CostPrice costPrice;

  /// Total stock capacity for this product
  final int totalStock;

  /// Currently available stock
  final int availableStock;

  Product({
    required this.id,
    required this.name,
    required this.productCode,
    DateTime? createdDate,
    required this.originalPrice,
    double? currentSellingPrice,
    List<String>? images,
    CostPrice? costPrice,
    this.totalStock = 0,
    this.availableStock = 0,
  })  : createdDate = createdDate ?? DateTime.now(),
        currentSellingPrice = currentSellingPrice ?? originalPrice,
        images = images ?? [],
        costPrice = costPrice ?? const CostPrice.empty();

  // ============ Computed Properties ============

  /// Returns true if the product has a discount applied
  bool get hasDiscount => currentSellingPrice < originalPrice;

  /// Returns the discount percentage (0-100)
  double get discountPercentage =>
      hasDiscount ? ((originalPrice - currentSellingPrice) / originalPrice * 100) : 0;

  /// Returns the discount amount in currency
  double get discountAmount => originalPrice - currentSellingPrice;

  /// Profit per unit sold at current selling price
  double get profit => currentSellingPrice - costPrice.totalCost;

  /// Profit margin as percentage
  double get profitMargin =>
      currentSellingPrice > 0 ? (profit / currentSellingPrice * 100) : 0;

  /// Returns true if selling at a loss
  bool get isSellingAtLoss => profit < 0;

  /// Stock percentage (0-100)
  double get stockPercentage {
    if (totalStock == 0) return 0;
    return (availableStock / totalStock) * 100;
  }

  /// Returns true if stock is low (25-40%)
  bool get isLowStock {
    if (totalStock == 0) return false;
    return stockPercentage >= 25 && stockPercentage <= 40;
  }

  /// Returns true if stock is critical (< 25%)
  bool get isCriticalStock {
    if (totalStock == 0) return false;
    return stockPercentage < 25;
  }

  /// Returns true if out of stock
  bool get isOutOfStock => totalStock > 0 && availableStock == 0;

  /// Returns true if in stock
  bool get isInStock => availableStock > 0;

  /// Stock status text based on percentage
  String get stockStatus {
    if (totalStock == 0) return 'No Stock Set';
    if (stockPercentage < 25) return 'Critical';      // Red: < 25%
    if (stockPercentage <= 40) return 'Low Stock';    // Orange: 25-40%
    return 'In Stock';                                 // Green: > 40%
  }

  // ============ Serialization ============

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'productCode': productCode,
      'createdDate': createdDate.toIso8601String(),
      'originalPrice': originalPrice,
      'currentSellingPrice': currentSellingPrice,
      'images': images,
      'costPrice': costPrice.toMap(),
      'totalStock': totalStock,
      'availableStock': availableStock,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    final originalPrice = (map['originalPrice'] ?? map['basePrice'] ?? 0).toDouble();
    final currentSellingPrice = (map['currentSellingPrice'] ?? map['discountedPrice'] ?? originalPrice).toDouble();

    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      productCode: map['productCode'] as String? ?? '',
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'] as String)
          : DateTime.now(),
      originalPrice: originalPrice,
      currentSellingPrice: currentSellingPrice,
      images: map['images'] != null
          ? List<String>.from(map['images'] as List)
          : [],
      costPrice: CostPrice.fromMap(map['costPrice'] as Map<String, dynamic>?),
      totalStock: (map['totalStock'] as int?) ?? 0,
      availableStock: (map['availableStock'] as int?) ?? 0,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? productCode,
    DateTime? createdDate,
    double? originalPrice,
    double? currentSellingPrice,
    List<String>? images,
    CostPrice? costPrice,
    int? totalStock,
    int? availableStock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      productCode: productCode ?? this.productCode,
      createdDate: createdDate ?? this.createdDate,
      originalPrice: originalPrice ?? this.originalPrice,
      currentSellingPrice: currentSellingPrice ?? this.currentSellingPrice,
      images: images ?? List.from(this.images),
      costPrice: costPrice ?? this.costPrice,
      totalStock: totalStock ?? this.totalStock,
      availableStock: availableStock ?? this.availableStock,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, code: $productCode, '
        'original: $originalPrice, selling: $currentSellingPrice, '
        'cost: ${costPrice.totalCost}, profit: $profit, '
        'stock: $availableStock/$totalStock)';
  }
}

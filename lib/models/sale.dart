class Customer {
  String name;
  String phone;
  String email;
  String address;

  Customer({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
    );
  }
}

class Sale {
  String id;
  DateTime saleDate;
  String productId;
  double price;
  Customer customer;
  String? notes;

  Sale({
    required this.id,
    required this.saleDate,
    required this.productId,
    required this.price,
    required this.customer,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleDate': saleDate.toIso8601String(),
      'productId': productId,
      'price': price,
      'customer': customer.toMap(),
      'notes': notes,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as String,
      saleDate: DateTime.parse(map['saleDate'] as String),
      productId: map['productId'] as String,
      price: (map['price'] as num).toDouble(),
      customer: Customer.fromMap(map['customer'] as Map<String, dynamic>),
      notes: map['notes'] as String?,
    );
  }

  Sale copyWith({
    String? id,
    DateTime? saleDate,
    String? productId,
    double? price,
    Customer? customer,
    String? notes,
  }) {
    return Sale(
      id: id ?? this.id,
      saleDate: saleDate ?? this.saleDate,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      customer: customer ?? this.customer,
      notes: notes ?? this.notes,
    );
  }
}

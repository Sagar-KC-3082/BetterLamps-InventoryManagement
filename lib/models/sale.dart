class Customer {
  String name;
  String phone;
  String? instaId;
  String address;

  Customer({
    required this.name,
    required this.phone,
    this.instaId,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'instaId': instaId,
      'address': address,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'] as String,
      phone: map['phone'] as String,
      instaId: map['instaId'] as String?,
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
  String? source;
  bool isFollowedUp;
  String? notes;
  String accountSettledIn;

  Sale({
    required this.id,
    required this.saleDate,
    required this.productId,
    required this.price,
    required this.customer,
    this.source,
    this.isFollowedUp = false,
    this.accountSettledIn = 'Sagar',
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleDate': saleDate.toIso8601String(),
      'productId': productId,
      'price': price,
      'customer': customer.toMap(),
      'source': source,
      'isFollowedUp': isFollowedUp,
      'accountSettledIn': accountSettledIn,
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
      source: map['source'] as String?,
      isFollowedUp: map['isFollowedUp'] as bool? ?? false,
      accountSettledIn: map['accountSettledIn'] as String? ?? 'Sagar',
      notes: map['notes'] as String?,
    );
  }

  Sale copyWith({
    String? id,
    DateTime? saleDate,
    String? productId,
    double? price,
    Customer? customer,
    String? source,
    bool? isFollowedUp,
    String? accountSettledIn,
    String? notes,
  }) {
    return Sale(
      id: id ?? this.id,
      saleDate: saleDate ?? this.saleDate,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      customer: customer ?? this.customer,
      source: source ?? this.source,
      isFollowedUp: isFollowedUp ?? this.isFollowedUp,
      accountSettledIn: accountSettledIn ?? this.accountSettledIn,
      notes: notes ?? this.notes,
    );
  }
}

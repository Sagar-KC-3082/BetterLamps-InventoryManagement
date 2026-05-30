enum SaleSource {
  instagramDm,
  instagramAd,
  referral,
  walkIn,
  other;

  String get label {
    switch (this) {
      case SaleSource.instagramDm:
        return 'Instagram DM';
      case SaleSource.instagramAd:
        return 'Instagram Ad';
      case SaleSource.referral:
        return 'Referral';
      case SaleSource.walkIn:
        return 'Walk-in';
      case SaleSource.other:
        return 'Other';
    }
  }

  static SaleSource fromString(String value) {
    // Handle old free-text display values stored before enum migration
    switch (value) {
      case 'Instagram DM':
        return SaleSource.instagramDm;
      case 'Instagram Ad':
        return SaleSource.instagramAd;
      case 'Referral':
        return SaleSource.referral;
      case 'Walk-in':
        return SaleSource.walkIn;
      case 'Other':
        return SaleSource.other;
    }
    return SaleSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SaleSource.instagramAd,
    );
  }
}

enum PaymentMethod {
  cash,
  esewa,
  fonepay,
  bankTransfer;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.esewa:
        return 'eSewa';
      case PaymentMethod.fonepay:
        return 'Fonepay';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  static PaymentMethod fromString(String value) {
    // Handle old display-string values
    switch (value) {
      case 'Cash':
        return PaymentMethod.cash;
      case 'eSewa':
        return PaymentMethod.esewa;
      case 'Fonepay':
        return PaymentMethod.fonepay;
      case 'Bank Transfer':
        return PaymentMethod.bankTransfer;
    }
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.bankTransfer,
    );
  }
}

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
  int quantity;
  double price;
  PaymentMethod paymentMethod;
  Customer customer;
  SaleSource source;
  bool isFollowedUp;
  String? notes;
  String accountSettledIn;

  Sale({
    required this.id,
    required this.saleDate,
    required this.productId,
    this.quantity = 1,
    required this.price,
    this.paymentMethod = PaymentMethod.bankTransfer,
    required this.customer,
    this.source = SaleSource.instagramAd,
    this.isFollowedUp = false,
    this.accountSettledIn = 'Sagar',
    this.notes,
  });

  /// Total revenue for this sale (price per unit × quantity)
  double get totalAmount => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleDate': saleDate.toIso8601String(),
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'paymentMethod': paymentMethod.name,
      'customer': customer.toMap(),
      'source': source.name,
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
      quantity: (map['quantity'] as int?) ?? 1,
      price: (map['price'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] != null
          ? PaymentMethod.fromString(map['paymentMethod'] as String)
          : PaymentMethod.bankTransfer,
      customer: Customer.fromMap(map['customer'] as Map<String, dynamic>),
      source: map['source'] != null
          ? SaleSource.fromString(map['source'] as String)
          : SaleSource.instagramAd,
      isFollowedUp: map['isFollowedUp'] as bool? ?? false,
      accountSettledIn: map['accountSettledIn'] as String? ?? 'Sagar',
      notes: map['notes'] as String?,
    );
  }

  Sale copyWith({
    String? id,
    DateTime? saleDate,
    String? productId,
    int? quantity,
    double? price,
    PaymentMethod? paymentMethod,
    Customer? customer,
    SaleSource? source,
    bool? isFollowedUp,
    String? accountSettledIn,
    String? notes,
  }) {
    return Sale(
      id: id ?? this.id,
      saleDate: saleDate ?? this.saleDate,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customer: customer ?? this.customer,
      source: source ?? this.source,
      isFollowedUp: isFollowedUp ?? this.isFollowedUp,
      accountSettledIn: accountSettledIn ?? this.accountSettledIn,
      notes: notes ?? this.notes,
    );
  }
}

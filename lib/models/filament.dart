class Filament {
  String id;
  String type;
  String color;
  String supplier;
  DateTime purchaseDate;
  double costPerUnit;
  int quantity;
  String? notes;

  Filament({
    required this.id,
    required this.type,
    required this.color,
    required this.supplier,
    required this.purchaseDate,
    required this.costPerUnit,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'color': color,
      'supplier': supplier,
      'purchaseDate': purchaseDate.toIso8601String(),
      'costPerUnit': costPerUnit,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory Filament.fromMap(Map<String, dynamic> map) {
    return Filament(
      id: map['id'] as String,
      type: map['type'] as String,
      color: map['color'] as String,
      supplier: map['supplier'] as String,
      purchaseDate: DateTime.parse(map['purchaseDate'] as String),
      costPerUnit: (map['costPerUnit'] as num).toDouble(),
      quantity: map['quantity'] as int,
      notes: map['notes'] as String?,
    );
  }

  Filament copyWith({
    String? id,
    String? type,
    String? color,
    String? supplier,
    DateTime? purchaseDate,
    double? costPerUnit,
    int? quantity,
    String? notes,
  }) {
    return Filament(
      id: id ?? this.id,
      type: type ?? this.type,
      color: color ?? this.color,
      supplier: supplier ?? this.supplier,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}

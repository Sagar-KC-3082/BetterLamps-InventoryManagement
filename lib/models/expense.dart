class Expense {
  String id;
  String name;
  String person;
  double amount;
  DateTime date;
  String? notes;

  Expense({
    required this.id,
    required this.name,
    required this.person,
    required this.amount,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'person': person,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      name: map['name'] as String,
      person: map['person'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }

  Expense copyWith({
    String? id,
    String? name,
    String? person,
    double? amount,
    DateTime? date,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      person: person ?? this.person,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}

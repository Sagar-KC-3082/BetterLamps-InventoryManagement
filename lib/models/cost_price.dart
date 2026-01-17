/// Represents the manufacturing cost breakdown for a 3D-printed lamp.
///
/// This class encapsulates all cost components and provides a computed [totalCost].
/// The total is always derived from individual components and cannot be set manually.
class CostPrice {
  /// Weight of filament used for shade (in grams)
  final double shadeFilamentWeight;

  /// Weight of filament used for base (in grams)
  final double baseFilamentWeight;

  /// Cost of filament per KG
  final double filamentCostPerKg;

  /// Combined cost for electrical components (bulb + wire + holder)
  final double electricalAssemblyCost;

  /// Printing time for shade in hours
  final double printingTimeShadeHours;

  /// Printing time for base in hours
  final double printingTimeBaseHours;

  /// Cost of electricity per hour
  final double electricityCostPerHour;

  /// Any additional miscellaneous costs (packaging, etc.)
  final double otherCost;

  const CostPrice({
    this.shadeFilamentWeight = 0,
    this.baseFilamentWeight = 0,
    this.filamentCostPerKg = 2600, // Default 2600
    required this.electricalAssemblyCost,
    this.printingTimeShadeHours = 0,
    this.printingTimeBaseHours = 0,
    this.electricityCostPerHour = 5,
    this.otherCost = 0,
  });

  /// Creates an empty cost price with all values set to zero (except default rate)
  const CostPrice.empty()
      : shadeFilamentWeight = 0,
        baseFilamentWeight = 0,
        filamentCostPerKg = 2600,
        electricalAssemblyCost = 0,
        printingTimeShadeHours = 0,
        printingTimeBaseHours = 0,
        electricityCostPerHour = 5,
        otherCost = 0;

  /// Computed cost for shade filament
  double get shadeFilamentCost => (shadeFilamentWeight / 1000) * filamentCostPerKg;

  /// Computed cost for base filament
  double get baseFilamentCost => (baseFilamentWeight / 1000) * filamentCostPerKg;

  /// Computed electricity cost
  double get electricityCost => (printingTimeShadeHours + printingTimeBaseHours) * electricityCostPerHour;

  /// Total manufacturing cost - computed from all individual costs.
  /// This value is never stored, always derived.
  double get totalCost =>
      shadeFilamentCost +
      baseFilamentCost +
      electricalAssemblyCost +
      electricityCost +
      otherCost;

  /// Returns true if all cost values are zero
  bool get isEmpty => totalCost == 0;

  /// Returns true if any cost value is greater than zero
  bool get isNotEmpty => totalCost > 0;

  /// Serializes the cost price to a map for storage.
  /// Note: totalCost is NOT stored as it's always computed.
  Map<String, dynamic> toMap() {
    return {
      'shadeFilamentWeight': shadeFilamentWeight,
      'baseFilamentWeight': baseFilamentWeight,
      'filamentCostPerKg': filamentCostPerKg,
      'electricalAssemblyCost': electricalAssemblyCost,
      'printingTimeShadeHours': printingTimeShadeHours,
      'printingTimeBaseHours': printingTimeBaseHours,
      'electricityCostPerHour': electricityCostPerHour,
      'otherCost': otherCost,
    };
  }

  /// Creates a CostPrice from a map.
  /// Handles null/missing values gracefully with defaults of 0.
  factory CostPrice.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CostPrice.empty();

    return CostPrice(
      shadeFilamentWeight: (map['shadeFilamentWeight'] as num?)?.toDouble() ?? 0,
      baseFilamentWeight: (map['baseFilamentWeight'] as num?)?.toDouble() ?? 0,
      filamentCostPerKg: (map['filamentCostPerKg'] as num?)?.toDouble() ?? 2600,
      electricalAssemblyCost: (map['electricalAssemblyCost'] as num?)?.toDouble() ?? 0,
      printingTimeShadeHours: (map['printingTimeShadeHours'] as num?)?.toDouble() ?? 0,
      printingTimeBaseHours: (map['printingTimeBaseHours'] as num?)?.toDouble() ?? 0,
      electricityCostPerHour: (map['electricityCostPerHour'] as num?)?.toDouble() ?? 5,
      otherCost: (map['otherCost'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Creates a copy with updated values
  CostPrice copyWith({
    double? shadeFilamentWeight,
    double? baseFilamentWeight,
    double? filamentCostPerKg,
    double? electricalAssemblyCost,
    double? printingTimeShadeHours,
    double? printingTimeBaseHours,
    double? electricityCostPerHour,
    double? otherCost,
  }) {
    return CostPrice(
      shadeFilamentWeight: shadeFilamentWeight ?? this.shadeFilamentWeight,
      baseFilamentWeight: baseFilamentWeight ?? this.baseFilamentWeight,
      filamentCostPerKg: filamentCostPerKg ?? this.filamentCostPerKg,
      electricalAssemblyCost: electricalAssemblyCost ?? this.electricalAssemblyCost,
      printingTimeShadeHours: printingTimeShadeHours ?? this.printingTimeShadeHours,
      printingTimeBaseHours: printingTimeBaseHours ?? this.printingTimeBaseHours,
      electricityCostPerHour: electricityCostPerHour ?? this.electricityCostPerHour,
      otherCost: otherCost ?? this.otherCost,
    );
  }

  @override
  String toString() {
    return 'CostPrice(shade: $shadeFilamentCost, base: $baseFilamentCost, '
        'electrical: $electricalAssemblyCost, electricity: $electricityCost, '
        'other: $otherCost, total: $totalCost)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CostPrice &&
        other.shadeFilamentWeight == shadeFilamentWeight &&
        other.baseFilamentWeight == baseFilamentWeight &&
        other.filamentCostPerKg == filamentCostPerKg &&
        other.electricalAssemblyCost == electricalAssemblyCost &&
        other.printingTimeShadeHours == printingTimeShadeHours &&
        other.printingTimeBaseHours == printingTimeBaseHours &&
        other.electricityCostPerHour == electricityCostPerHour &&
        other.otherCost == otherCost;
  }

  @override
  int get hashCode {
    return Object.hash(
      shadeFilamentWeight,
      baseFilamentWeight,
      filamentCostPerKg,
      electricalAssemblyCost,
      printingTimeShadeHours,
      printingTimeBaseHours,
      electricityCostPerHour,
      otherCost,
    );
  }
}

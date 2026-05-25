enum LeadSource {
  instagramDm,
  instagramComment,
  instagramAd,
  tiktok,
  facebook,
  referral,
  repeatCustomer,
  other;

  String get label {
    switch (this) {
      case LeadSource.instagramDm:
        return 'Instagram DM';
      case LeadSource.instagramComment:
        return 'Instagram Comment';
      case LeadSource.instagramAd:
        return 'Instagram Ad';
      case LeadSource.tiktok:
        return 'TikTok';
      case LeadSource.facebook:
        return 'Facebook';
      case LeadSource.referral:
        return 'Referral';
      case LeadSource.repeatCustomer:
        return 'Repeat Customer';
      case LeadSource.other:
        return 'Other';
    }
  }

  static LeadSource fromString(String value) {
    return LeadSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LeadSource.other,
    );
  }
}

enum LeadStatus {
  newLead,
  replied,
  negotiating,
  interested,
  waiting,
  converted,
  lost;

  String get label {
    switch (this) {
      case LeadStatus.newLead:
        return 'New Lead';
      case LeadStatus.replied:
        return 'Replied';
      case LeadStatus.negotiating:
        return 'Negotiating';
      case LeadStatus.interested:
        return 'Interested';
      case LeadStatus.waiting:
        return 'Waiting';
      case LeadStatus.converted:
        return 'Converted';
      case LeadStatus.lost:
        return 'Lost';
    }
  }

  static LeadStatus fromString(String value) {
    return LeadStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LeadStatus.newLead,
    );
  }
}

enum LeadGender {
  male,
  female,
  other;

  String get label {
    switch (this) {
      case LeadGender.male:
        return 'Male';
      case LeadGender.female:
        return 'Female';
      case LeadGender.other:
        return 'Other';
    }
  }

  static LeadGender fromString(String value) {
    return LeadGender.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LeadGender.other,
    );
  }
}

enum LostReason {
  tooExpensive,
  noResponse,
  boughtElsewhere,
  justExploring,
  deliveryIssue,
  notInterested,
  waitingForSalary,
  timingIssue,
  other;

  String get label {
    switch (this) {
      case LostReason.tooExpensive:
        return 'Too Expensive';
      case LostReason.noResponse:
        return 'No Response';
      case LostReason.boughtElsewhere:
        return 'Bought Elsewhere';
      case LostReason.justExploring:
        return 'Just Exploring';
      case LostReason.deliveryIssue:
        return 'Delivery Issue';
      case LostReason.notInterested:
        return 'Not Interested';
      case LostReason.waitingForSalary:
        return 'Waiting for Salary';
      case LostReason.timingIssue:
        return 'Timing Issue';
      case LostReason.other:
        return 'Other';
    }
  }

  static LostReason fromString(String value) {
    return LostReason.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LostReason.other,
    );
  }
}

class Lead {
  final String id;

  // Basic Info
  final String name;
  final String? instaId;
  final LeadGender? gender;
  final int? age;
  final String? contactNumber;
  final String? alternateContact;
  final String? address;

  // Inquiry Info
  final LeadSource? source;
  final List<String> interestedProductIds;
  final String? budgetRange;
  final bool askedForDiscount;
  final DateTime? expectedDeliveryDate;
  final int? quantityInterested;
  final String? customRequirements;

  // Status
  final LeadStatus status;

  // Purchase Tracking
  final bool didBuy;
  final List<String> purchasedProductIds;
  final double? finalSellingAmount;
  final String? linkedSaleId;
  final LostReason? lostReason;
  final String? lostReasonNote;

  // Metadata
  final DateTime? followUpDate;
  final DateTime? lastContactedDate;
  final DateTime? inquireDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lead({
    required this.id,
    required this.name,
    this.instaId,
    this.gender,
    this.age,
    this.contactNumber,
    this.alternateContact,
    this.address,
    this.source,
    this.interestedProductIds = const [],
    this.budgetRange,
    this.askedForDiscount = false,
    this.expectedDeliveryDate,
    this.quantityInterested,
    this.customRequirements,
    this.status = LeadStatus.newLead,
    this.didBuy = false,
    this.purchasedProductIds = const [],
    this.finalSellingAmount,
    this.linkedSaleId,
    this.lostReason,
    this.lostReasonNote,
    this.followUpDate,
    this.lastContactedDate,
    this.inquireDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'instaId': instaId,
      'gender': gender?.name,
      'age': age,
      'contactNumber': contactNumber,
      'alternateContact': alternateContact,
      'address': address,
      'source': source?.name,
      'interestedProductIds': interestedProductIds,
      'budgetRange': budgetRange,
      'askedForDiscount': askedForDiscount,
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'quantityInterested': quantityInterested,
      'customRequirements': customRequirements,
      'status': status.name,
      'didBuy': didBuy,
      'purchasedProductIds': purchasedProductIds,
      'finalSellingAmount': finalSellingAmount,
      'linkedSaleId': linkedSaleId,
      'lostReason': lostReason?.name,
      'lostReasonNote': lostReasonNote,
      'followUpDate': followUpDate?.toIso8601String(),
      'lastContactedDate': lastContactedDate?.toIso8601String(),
      'inquireDate': inquireDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Lead.fromMap(Map<String, dynamic> map) {
    return Lead(
      id: map['id'] as String,
      name: map['name'] as String,
      instaId: map['instaId'] as String?,
      gender: map['gender'] != null
          ? LeadGender.fromString(map['gender'] as String)
          : null,
      age: map['age'] as int?,
      contactNumber: map['contactNumber'] as String?,
      alternateContact: map['alternateContact'] as String?,
      address: map['address'] as String?,
      source: map['source'] != null
          ? LeadSource.fromString(map['source'] as String)
          : null,
      interestedProductIds:
          List<String>.from(map['interestedProductIds'] as List? ?? []),
      budgetRange: map['budgetRange'] as String?,
      askedForDiscount: map['askedForDiscount'] as bool? ?? false,
      expectedDeliveryDate: map['expectedDeliveryDate'] != null
          ? DateTime.parse(map['expectedDeliveryDate'] as String)
          : null,
      quantityInterested: map['quantityInterested'] as int?,
      customRequirements: map['customRequirements'] as String?,
      status: map['status'] != null
          ? LeadStatus.fromString(map['status'] as String)
          : LeadStatus.newLead,
      didBuy: map['didBuy'] as bool? ?? false,
      purchasedProductIds:
          List<String>.from(map['purchasedProductIds'] as List? ?? []),
      finalSellingAmount: map['finalSellingAmount'] != null
          ? (map['finalSellingAmount'] as num).toDouble()
          : null,
      linkedSaleId: map['linkedSaleId'] as String?,
      lostReason: map['lostReason'] != null
          ? LostReason.fromString(map['lostReason'] as String)
          : null,
      lostReasonNote: map['lostReasonNote'] as String?,
      followUpDate: map['followUpDate'] != null
          ? DateTime.parse(map['followUpDate'] as String)
          : null,
      lastContactedDate: map['lastContactedDate'] != null
          ? DateTime.parse(map['lastContactedDate'] as String)
          : null,
      inquireDate: map['inquireDate'] != null
          ? DateTime.parse(map['inquireDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Lead copyWith({
    String? id,
    String? name,
    Object? instaId = _sentinel,
    Object? gender = _sentinel,
    Object? age = _sentinel,
    Object? contactNumber = _sentinel,
    Object? alternateContact = _sentinel,
    Object? address = _sentinel,
    Object? source = _sentinel,
    List<String>? interestedProductIds,
    Object? budgetRange = _sentinel,
    bool? askedForDiscount,
    Object? expectedDeliveryDate = _sentinel,
    Object? quantityInterested = _sentinel,
    Object? customRequirements = _sentinel,
    LeadStatus? status,
    bool? didBuy,
    List<String>? purchasedProductIds,
    Object? finalSellingAmount = _sentinel,
    Object? linkedSaleId = _sentinel,
    Object? lostReason = _sentinel,
    Object? lostReasonNote = _sentinel,
    Object? followUpDate = _sentinel,
    Object? lastContactedDate = _sentinel,
    Object? inquireDate = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      instaId: instaId == _sentinel ? this.instaId : instaId as String?,
      gender: gender == _sentinel ? this.gender : gender as LeadGender?,
      age: age == _sentinel ? this.age : age as int?,
      contactNumber: contactNumber == _sentinel
          ? this.contactNumber
          : contactNumber as String?,
      alternateContact: alternateContact == _sentinel
          ? this.alternateContact
          : alternateContact as String?,
      address: address == _sentinel ? this.address : address as String?,
      source: source == _sentinel ? this.source : source as LeadSource?,
      interestedProductIds: interestedProductIds ?? this.interestedProductIds,
      budgetRange:
          budgetRange == _sentinel ? this.budgetRange : budgetRange as String?,
      askedForDiscount: askedForDiscount ?? this.askedForDiscount,
      expectedDeliveryDate: expectedDeliveryDate == _sentinel
          ? this.expectedDeliveryDate
          : expectedDeliveryDate as DateTime?,
      quantityInterested: quantityInterested == _sentinel
          ? this.quantityInterested
          : quantityInterested as int?,
      customRequirements: customRequirements == _sentinel
          ? this.customRequirements
          : customRequirements as String?,
      status: status ?? this.status,
      didBuy: didBuy ?? this.didBuy,
      purchasedProductIds: purchasedProductIds ?? this.purchasedProductIds,
      finalSellingAmount: finalSellingAmount == _sentinel
          ? this.finalSellingAmount
          : finalSellingAmount as double?,
      linkedSaleId:
          linkedSaleId == _sentinel ? this.linkedSaleId : linkedSaleId as String?,
      lostReason:
          lostReason == _sentinel ? this.lostReason : lostReason as LostReason?,
      lostReasonNote: lostReasonNote == _sentinel
          ? this.lostReasonNote
          : lostReasonNote as String?,
      followUpDate: followUpDate == _sentinel
          ? this.followUpDate
          : followUpDate as DateTime?,
      lastContactedDate: lastContactedDate == _sentinel
          ? this.lastContactedDate
          : lastContactedDate as DateTime?,
      inquireDate: inquireDate == _sentinel
          ? this.inquireDate
          : inquireDate as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdueFollowUp {
    if (followUpDate == null) return false;
    return followUpDate!.isBefore(DateTime.now()) &&
        status != LeadStatus.converted &&
        status != LeadStatus.lost;
  }

  int? get daysSinceLastContact {
    if (lastContactedDate == null) return null;
    return DateTime.now().difference(lastContactedDate!).inDays;
  }
}

const _sentinel = Object();

import 'package:cloud_firestore/cloud_firestore.dart';

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
    switch (value) {
      case 'Instagram DM':
        return LeadSource.instagramDm;
      case 'Instagram Comment':
        return LeadSource.instagramComment;
      case 'Instagram Ad':
        return LeadSource.instagramAd;
      case 'TikTok':
        return LeadSource.tiktok;
      case 'Facebook':
        return LeadSource.facebook;
      case 'Referral':
        return LeadSource.referral;
      case 'Repeat Customer':
        return LeadSource.repeatCustomer;
      case 'Other':
        return LeadSource.other;
    }
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
    switch (value) {
      case 'New Lead':
        return LeadStatus.newLead;
      case 'Replied':
        return LeadStatus.replied;
      case 'Negotiating':
        return LeadStatus.negotiating;
      case 'Interested':
        return LeadStatus.interested;
      case 'Waiting':
        return LeadStatus.waiting;
      case 'Converted':
        return LeadStatus.converted;
      case 'Lost':
        return LeadStatus.lost;
    }
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
    switch (value) {
      case 'Male':
        return LeadGender.male;
      case 'Female':
        return LeadGender.female;
      case 'Other':
        return LeadGender.other;
    }
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
    switch (value) {
      case 'Too Expensive':
        return LostReason.tooExpensive;
      case 'No Response':
        return LostReason.noResponse;
      case 'Bought Elsewhere':
        return LostReason.boughtElsewhere;
      case 'Just Exploring':
        return LostReason.justExploring;
      case 'Delivery Issue':
        return LostReason.deliveryIssue;
      case 'Not Interested':
        return LostReason.notInterested;
      case 'Waiting for Salary':
        return LostReason.waitingForSalary;
      case 'Timing Issue':
        return LostReason.timingIssue;
      case 'Other':
        return LostReason.other;
    }
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

  /// Like toMap() but replaces null optional fields with FieldValue.delete()
  /// so Firestore actually clears them when doing a full .set() overwrite.
  Map<String, dynamic> toFirestoreMap() {
    dynamic firestoreValue(dynamic value) => value ?? FieldValue.delete();
    return {
      'id': id,
      'name': name,
      'instaId': firestoreValue(instaId),
      'gender': firestoreValue(gender?.name),
      'age': firestoreValue(age),
      'contactNumber': firestoreValue(contactNumber),
      'alternateContact': firestoreValue(alternateContact),
      'address': firestoreValue(address),
      'source': firestoreValue(source?.name),
      'interestedProductIds': interestedProductIds,
      'budgetRange': firestoreValue(budgetRange),
      'askedForDiscount': askedForDiscount,
      'expectedDeliveryDate': firestoreValue(
        expectedDeliveryDate?.toIso8601String(),
      ),
      'quantityInterested': firestoreValue(quantityInterested),
      'customRequirements': firestoreValue(customRequirements),
      'status': status.name,
      'didBuy': didBuy,
      'purchasedProductIds': purchasedProductIds,
      'finalSellingAmount': firestoreValue(finalSellingAmount),
      'linkedSaleId': firestoreValue(linkedSaleId),
      'lostReason': firestoreValue(lostReason?.name),
      'lostReasonNote': firestoreValue(lostReasonNote),
      'followUpDate': firestoreValue(followUpDate?.toIso8601String()),
      'lastContactedDate': firestoreValue(lastContactedDate?.toIso8601String()),
      'inquireDate': firestoreValue(inquireDate?.toIso8601String()),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Lead.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String && value.trim().isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    List<String> parseStringList(dynamic value) {
      if (value is Iterable) {
        return value
            .map((item) => item?.toString())
            .whereType<String>()
            .where((item) => item.trim().isNotEmpty)
            .toList();
      }
      return const [];
    }

    final now = DateTime.now();
    final createdAt =
        parseDate(map['createdAt']) ??
        parseDate(map['inquireDate']) ??
        parseDate(map['followUpDate']) ??
        now;
    final updatedAt = parseDate(map['updatedAt']) ?? createdAt;

    return Lead(
      id: parseString(map['id']) ?? '',
      name: parseString(map['name']) ?? '',
      instaId: parseString(map['instaId']),
      gender: map['gender'] != null
          ? LeadGender.fromString(map['gender'].toString())
          : null,
      age: parseInt(map['age']),
      contactNumber: parseString(map['contactNumber']),
      alternateContact: parseString(map['alternateContact']),
      address: parseString(map['address']),
      source: map['source'] != null
          ? LeadSource.fromString(map['source'].toString())
          : null,
      interestedProductIds: parseStringList(map['interestedProductIds']),
      budgetRange: parseString(map['budgetRange']),
      askedForDiscount: map['askedForDiscount'] as bool? ?? false,
      expectedDeliveryDate: parseDate(map['expectedDeliveryDate']),
      quantityInterested: parseInt(map['quantityInterested']),
      customRequirements: parseString(map['customRequirements']),
      status: map['status'] != null
          ? LeadStatus.fromString(map['status'].toString())
          : LeadStatus.newLead,
      didBuy: map['didBuy'] as bool? ?? false,
      purchasedProductIds: parseStringList(map['purchasedProductIds']),
      finalSellingAmount: parseDouble(map['finalSellingAmount']),
      linkedSaleId: parseString(map['linkedSaleId']),
      lostReason: map['lostReason'] != null
          ? LostReason.fromString(map['lostReason'].toString())
          : null,
      lostReasonNote: parseString(map['lostReasonNote']),
      followUpDate: parseDate(map['followUpDate']),
      lastContactedDate: parseDate(map['lastContactedDate']),
      inquireDate: parseDate(map['inquireDate']),
      createdAt: createdAt,
      updatedAt: updatedAt,
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

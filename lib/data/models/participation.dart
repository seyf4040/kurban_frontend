import 'package:equatable/equatable.dart';

class Participation extends Equatable {
  final int? id;
  final int shareCount;
  final double? shareAmount;
  final bool paid;
  final DateTime? paymentDate;
  final String? notes;
  final DateTime? createdAt;
  final int? personId;
  final String? personName;
  final int? sacrificeId;
  final int? sacrificeNumber;

  const Participation({
    this.id,
    required this.shareCount,
    this.shareAmount,
    this.paid = false,
    this.paymentDate,
    this.notes,
    this.createdAt,
    this.personId,
    this.personName,
    this.sacrificeId,
    this.sacrificeNumber,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'],
      shareCount: json['shareCount'],
      shareAmount: json['shareAmount']?.toDouble(),
      paid: json['paid'] ?? false,
      paymentDate: json['paymentDate'] != null 
        ? DateTime.parse(json['paymentDate'])
        : null,
      notes: json['notes'],
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'])
        : null,
      personId: json['personId'],
      personName: json['personName'],
      sacrificeId: json['sacrificeId'],
      sacrificeNumber: json['sacrificeNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shareCount': shareCount,
      'shareAmount': shareAmount,
      'paid': paid,
      'paymentDate': paymentDate?.toIso8601String(),
      'notes': notes,
      'personId': personId,
      'sacrificeId': sacrificeId,
    };
  }

  Participation copyWith({
    int? id,
    int? shareCount,
    double? shareAmount,
    bool? paid,
    DateTime? paymentDate,
    String? notes,
    DateTime? createdAt,
    int? personId,
    String? personName,
    int? sacrificeId,
    int? sacrificeNumber,
  }) {
    return Participation(
      id: id ?? this.id,
      shareCount: shareCount ?? this.shareCount,
      shareAmount: shareAmount ?? this.shareAmount,
      paid: paid ?? this.paid,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      personId: personId ?? this.personId,
      personName: personName ?? this.personName,
      sacrificeId: sacrificeId ?? this.sacrificeId,
      sacrificeNumber: sacrificeNumber ?? this.sacrificeNumber,
    );
  }

  @override
  List<Object?> get props => [
    id, shareCount, shareAmount, paid, paymentDate, notes,
    createdAt, personId, personName, sacrificeId, sacrificeNumber
  ];
}

class ParticipationSummary extends Equatable {
  final int? id;
  final String personName;
  final int shareCount;
  final double? shareAmount;
  final bool paid;

  const ParticipationSummary({
    this.id,
    required this.personName,
    required this.shareCount,
    this.shareAmount,
    this.paid = false,
  });

  factory ParticipationSummary.fromJson(Map<String, dynamic> json) {
    return ParticipationSummary(
      id: json['id'],
      personName: json['personName'],
      shareCount: json['shareCount'],
      shareAmount: json['shareAmount']?.toDouble(),
      paid: json['paid'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, personName, shareCount, shareAmount, paid];
}

class ParticipationCreateRequest extends Equatable {
  final int personId;
  final int sacrificeId;
  final int shareCount;
  final double? shareAmount;
  final String? notes;

  const ParticipationCreateRequest({
    required this.personId,
    required this.sacrificeId,
    this.shareCount = 1,
    this.shareAmount,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'personId': personId,
      'sacrificeId': sacrificeId,
      'shareCount': shareCount,
      'shareAmount': shareAmount,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [personId, sacrificeId, shareCount, shareAmount, notes];
}
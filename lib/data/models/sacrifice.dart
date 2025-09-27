import 'package:equatable/equatable.dart';
import 'participation.dart';

class Sacrifice extends Equatable {
  final int? id;
  final int sacrificeNumber;
  final String animalType;
  final double? totalCost;
  final String status;
  final DateTime? sacrificeDate;
  final DateTime? createdAt;
  final int totalParticipants;
  final int totalShares;
  final double? sharePrice;
  final double? totalPaidAmount;
  final List<ParticipationSummary> participations;

  const Sacrifice({
    this.id,
    required this.sacrificeNumber,
    required this.animalType,
    this.totalCost,
    this.status = 'pending',
    this.sacrificeDate,
    this.createdAt,
    this.totalParticipants = 0,
    this.totalShares = 0,
    this.sharePrice,
    this.totalPaidAmount = 0,
    this.participations = const [],
  });

  int get availableShares => 7 - totalShares;
  
  double get pendingAmount => (totalCost ?? 0) - (totalPaidAmount ?? 0);
  
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';

  factory Sacrifice.fromJson(Map<String, dynamic> json) {
    return Sacrifice(
      id: json['id'],
      sacrificeNumber: json['sacrificeNumber'],
      animalType: json['animalType'],
      totalCost: json['totalCost']?.toDouble(),
      status: json['status'] ?? 'pending',
      sacrificeDate: json['sacrificeDate'] != null 
        ? DateTime.parse(json['sacrificeDate'])
        : null,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'])
        : null,
      totalParticipants: json['totalParticipants'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      sharePrice: json['sharePrice']?.toDouble(),
      totalPaidAmount: json['totalPaidAmount']?.toDouble() ?? 0,
      participations: (json['participations'] as List<dynamic>?)
        ?.map((p) => ParticipationSummary.fromJson(p))
        .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sacrificeNumber': sacrificeNumber,
      'animalType': animalType,
      'totalCost': totalCost,
      'status': status,
      'sacrificeDate': sacrificeDate?.toIso8601String().split('T')[0],
    };
  }

  Sacrifice copyWith({
    int? id,
    int? sacrificeNumber,
    String? animalType,
    double? totalCost,
    String? status,
    DateTime? sacrificeDate,
    DateTime? createdAt,
    int? totalParticipants,
    int? totalShares,
    double? sharePrice,
    double? totalPaidAmount,
    List<ParticipationSummary>? participations,
  }) {
    return Sacrifice(
      id: id ?? this.id,
      sacrificeNumber: sacrificeNumber ?? this.sacrificeNumber,
      animalType: animalType ?? this.animalType,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      sacrificeDate: sacrificeDate ?? this.sacrificeDate,
      createdAt: createdAt ?? this.createdAt,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      totalShares: totalShares ?? this.totalShares,
      sharePrice: sharePrice ?? this.sharePrice,
      totalPaidAmount: totalPaidAmount ?? this.totalPaidAmount,
      participations: participations ?? this.participations,
    );
  }

  @override
  List<Object?> get props => [
    id, sacrificeNumber, animalType, totalCost, status, sacrificeDate,
    createdAt, totalParticipants, totalShares, sharePrice, totalPaidAmount, participations
  ];
}

class SacrificeCreateRequest extends Equatable {
  final int sacrificeNumber;
  final String animalType;
  final double totalCost;
  final DateTime? sacrificeDate;

  const SacrificeCreateRequest({
    required this.sacrificeNumber,
    required this.animalType,
    required this.totalCost,
    this.sacrificeDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'sacrificeNumber': sacrificeNumber,
      'animalType': animalType,
      'totalCost': totalCost,
      'sacrificeDate': sacrificeDate?.toIso8601String().split('T')[0],
    };
  }

  @override
  List<Object?> get props => [sacrificeNumber, animalType, totalCost, sacrificeDate];
}
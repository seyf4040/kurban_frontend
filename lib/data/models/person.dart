import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final int? id;
  final String firstname;
  final String lastname;
  final String? phone;
  final String? email;
  final bool hasContactInfo;
  final int? contactIntermediaryId;
  final String? contactIntermediaryName;
  final int totalParticipations;
  final DateTime? createdAt;

  const Person({
    this.id,
    required this.firstname,
    required this.lastname,
    this.phone,
    this.email,
    this.hasContactInfo = false,
    this.contactIntermediaryId,
    this.contactIntermediaryName,
    this.totalParticipations = 0,
    this.createdAt,
  });

  String get fullName => '$firstname $lastname';

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      phone: json['phone'],
      email: json['email'],
      hasContactInfo: json['hasContactInfo'] ?? false,
      contactIntermediaryId: json['contactIntermediaryId'],
      contactIntermediaryName: json['contactIntermediaryName'],
      totalParticipations: json['totalParticipations'] ?? 0,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'email': email,
      'contactIntermediaryId': contactIntermediaryId,
    };
  }

  Person copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? phone,
    String? email,
    bool? hasContactInfo,
    int? contactIntermediaryId,
    String? contactIntermediaryName,
    int? totalParticipations,
    DateTime? createdAt,
  }) {
    return Person(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      hasContactInfo: hasContactInfo ?? this.hasContactInfo,
      contactIntermediaryId: contactIntermediaryId ?? this.contactIntermediaryId,
      contactIntermediaryName: contactIntermediaryName ?? this.contactIntermediaryName,
      totalParticipations: totalParticipations ?? this.totalParticipations,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id, firstname, lastname, phone, email, hasContactInfo,
    contactIntermediaryId, contactIntermediaryName, totalParticipations, createdAt
  ];
}

class PersonCreateRequest extends Equatable {
  final String firstname;
  final String lastname;
  final String? phone;
  final String? email;
  final int? contactIntermediaryId;

  const PersonCreateRequest({
    required this.firstname,
    required this.lastname,
    this.phone,
    this.email,
    this.contactIntermediaryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'email': email,
      'contactIntermediaryId': contactIntermediaryId,
    };
  }

  @override
  List<Object?> get props => [firstname, lastname, phone, email, contactIntermediaryId];
}

class PersonUpdateRequest extends Equatable {
  final String firstname;
  final String lastname;
  final String? phone;
  final String? email;
  final int? contactIntermediaryId;

  const PersonUpdateRequest({
    required this.firstname,
    required this.lastname,
    this.phone,
    this.email,
    this.contactIntermediaryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'email': email,
      'contactIntermediaryId': contactIntermediaryId,
    };
  }

  @override
  List<Object?> get props => [firstname, lastname, phone, email, contactIntermediaryId];
}
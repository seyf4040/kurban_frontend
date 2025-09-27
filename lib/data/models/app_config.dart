import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppConfig extends Equatable {
  final String defaultAnimalType;
  final Map<String, double> defaultPriceByAnimalType;
  final Color primaryColor;
  final Color accentColor;
  final int defaultSacrificeDaysFromNow;

  const AppConfig({
    this.defaultAnimalType = 'cow',
    this.defaultPriceByAnimalType = const {
      'cow': 1000.0,
      'goat': 500.0,
      'sheep': 600.0,
    },
    this.primaryColor = const Color(0xFF1B4332),
    this.accentColor = const Color(0xFFFFFDD0),
    this.defaultSacrificeDaysFromNow = 30,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      defaultAnimalType: json['defaultAnimalType'] ?? 'cow',
      defaultPriceByAnimalType: Map<String, double>.from(
        json['defaultPriceByAnimalType'] ?? {
          'cow': 1000.0,
          'goat': 500.0,
          'sheep': 600.0,
        },
      ),
      primaryColor: Color(json['primaryColor'] ?? 0xFF1B4332),
      accentColor: Color(json['accentColor'] ?? 0xFFFFFDD0),
      defaultSacrificeDaysFromNow: json['defaultSacrificeDaysFromNow'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultAnimalType': defaultAnimalType,
      'defaultPriceByAnimalType': defaultPriceByAnimalType,
      'primaryColor': primaryColor.value,
      'accentColor': accentColor.value,
      'defaultSacrificeDaysFromNow': defaultSacrificeDaysFromNow,
    };
  }

  AppConfig copyWith({
    String? defaultAnimalType,
    Map<String, double>? defaultPriceByAnimalType,
    Color? primaryColor,
    Color? accentColor,
    int? defaultSacrificeDaysFromNow,
  }) {
    return AppConfig(
      defaultAnimalType: defaultAnimalType ?? this.defaultAnimalType,
      defaultPriceByAnimalType: defaultPriceByAnimalType ?? this.defaultPriceByAnimalType,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      defaultSacrificeDaysFromNow: defaultSacrificeDaysFromNow ?? this.defaultSacrificeDaysFromNow,
    );
  }

  @override
  List<Object?> get props => [
    defaultAnimalType, defaultPriceByAnimalType, primaryColor, 
    accentColor, defaultSacrificeDaysFromNow
  ];
}
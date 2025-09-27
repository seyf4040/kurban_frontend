# Kurban Management Flutter App

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── api_endpoints.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── currency_utils.dart
│   └── widgets/
│       ├── loading_widget.dart
│       ├── error_widget.dart
│       └── search_field.dart
├── data/
│   ├── models/
│   │   ├── person.dart
│   │   ├── sacrifice.dart
│   │   ├── participation.dart
│   │   └── app_config.dart
│   ├── repositories/
│   │   ├── person_repository.dart
│   │   ├── sacrifice_repository.dart
│   │   ├── participation_repository.dart
│   │   └── config_repository.dart
│   └── services/
│       └── api_service.dart
├── presentation/
│   ├── cubits/
│   │   ├── person/
│   │   ├── sacrifice/
│   │   ├── participation/
│   │   └── config/
│   └── screens/
│       ├── home/
│       ├── persons/
│       ├── sacrifices/
│       ├── settings/
│       └── main_navigation.dart
└── dependencies.dart
```

## pubspec.yaml

```yaml
name: kurban_management
description: A Flutter app for managing Kurban sacrifices and participations
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  
  # HTTP & Networking
  dio: ^5.3.2
  pretty_dio_logger: ^1.3.1
  
  # UI & Animations
  cupertino_icons: ^1.0.2
  flutter_animate: ^4.3.0
  lottie: ^2.7.0
  
  # Data & Storage
  shared_preferences: ^2.2.2
  
  # Utils
  intl: ^0.18.1
  equatable: ^2.0.5
  
  # Dependency Injection
  get_it: ^7.6.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/animations/
```

## main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const KurbanApp());
}
```

## app.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/cubits/config/config_cubit.dart';
import 'presentation/screens/main_navigation.dart';
import 'dependencies.dart';

class KurbanApp extends StatelessWidget {
  const KurbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ConfigCubit>()..loadConfig(),
      child: BlocBuilder<ConfigCubit, ConfigState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Kurban Management',
            theme: AppTheme.getTheme(
              primaryColor: state.config?.primaryColor ?? Colors.green[800]!,
              accentColor: state.config?.accentColor ?? Colors.orange[100]!,
            ),
            home: const MainNavigation(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
```

## core/constants/app_colors.dart

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color accentCream = Color(0xFFFFFDD0);
  static const Color lightGreen = Color(0xFF52B788);
  static const Color darkGreen = Color(0xFF081C15);
  static const Color mediumGreen = Color(0xFF2D6A4F);
  
  // Status colors
  static const Color pending = Color(0xFFFFA726);
  static const Color completed = Color(0xFF66BB6A);
  static const Color cancelled = Color(0xFFEF5350);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
}
```

## core/constants/api_endpoints.dart

```dart
class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Persons
  static const String persons = '$baseUrl/persons';
  static String personById(int id) => '$persons/$id';
  static const String personsWithContact = '$persons/with-contact';
  static const String personsWithoutContact = '$persons/without-contact';
  static String personsByIntermediary(int id) => '$persons/intermediary/$id';
  
  // Sacrifices
  static const String sacrifices = '$baseUrl/sacrifices';
  static String sacrificeById(int id) => '$sacrifices/$id';
  static String sacrificesByStatus(String status) => '$sacrifices/status/$status';
  static String sacrificesByAnimalType(String animalType) => '$sacrifices/animal-type/$animalType';
  static String completeSacrifice(int id) => '$sacrifices/$id/complete';
  static String cancelSacrifice(int id) => '$sacrifices/$id/cancel';
  
  // Participations
  static const String participations = '$baseUrl/participations';
  static String participationById(int id) => '$participations/$id';
  static String participationsBySacrifice(int sacrificeId) => '$participations/sacrifice/$sacrificeId';
  static String markParticipationPaid(int id) => '$participations/$id/mark-paid';
  
  // Config
  static const String config = '$baseUrl/config';
}
```

## data/models/person.dart

```dart
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
```

## data/models/sacrifice.dart

```dart
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
```

## data/models/participation.dart

```dart
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
```

## data/models/app_config.dart

```dart
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
```

## data/services/api_service.dart

```dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/person.dart';
import '../models/sacrifice.dart';
import '../models/participation.dart';
import '../models/app_config.dart';
import '../../core/constants/api_endpoints.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
  }

  // Persons API
  Future<List<Person>> getPersons() async {
    final response = await _dio.get(ApiEndpoints.persons);
    return (response.data as List).map((json) => Person.fromJson(json)).toList();
  }

  Future<Person> getPersonById(int id) async {
    final response = await _dio.get(ApiEndpoints.personById(id));
    return Person.fromJson(response.data);
  }

  Future<Person> createPerson(PersonCreateRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.persons,
      data: request.toJson(),
    );
    return Person.fromJson(response.data);
  }

  Future<Person> updatePerson(int id, PersonCreateRequest request) async {
    final response = await _dio.put(
      ApiEndpoints.personById(id),
      data: request.toJson(),
    );
    return Person.fromJson(response.data);
  }

  Future<void> deletePerson(int id) async {
    await _dio.delete(ApiEndpoints.personById(id));
  }

  // Sacrifices API
  Future<List<Sacrifice>> getSacrifices() async {
    final response = await _dio.get(ApiEndpoints.sacrifices);
    return (response.data as List).map((json) => Sacrifice.fromJson(json)).toList();
  }

  Future<Sacrifice> getSacrificeById(int id) async {
    final response = await _dio.get(ApiEndpoints.sacrificeById(id));
    return Sacrifice.fromJson(response.data);
  }

  Future<Sacrifice> createSacrifice(SacrificeCreateRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.sacrifices,
      data: request.toJson(),
    );
    return Sacrifice.fromJson(response.data);
  }

  Future<Sacrifice> updateSacrifice(int id, SacrificeCreateRequest request) async {
    final response = await _dio.put(
      ApiEndpoints.sacrificeById(id),
      data: request.toJson(),
    );
    return Sacrifice.fromJson(response.data);
  }

  Future<void> deleteSacrifice(int id) async {
    await _dio.delete(ApiEndpoints.sacrificeById(id));
  }

  Future<Sacrifice> completeSacrifice(int id) async {
    final response = await _dio.put(ApiEndpoints.completeSacrifice(id));
    return Sacrifice.fromJson(response.data);
  }

  Future<Sacrifice> cancelSacrifice(int id) async {
    final response = await _dio.put(ApiEndpoints.cancelSacrifice(id));
    return Sacrifice.fromJson(response.data);
  }

  // Participations API
  Future<List<Participation>> getParticipationsBySacrifice(int sacrificeId) async {
    final response = await _dio.get(ApiEndpoints.participationsBySacrifice(sacrificeId));
    return (response.data as List).map((json) => Participation.fromJson(json)).toList();
  }

  Future<Participation> createParticipation(ParticipationCreateRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.participations,
      data: request.toJson(),
    );
    return Participation.fromJson(response.data);
  }

  Future<Participation> updateParticipation(int id, ParticipationCreateRequest request) async {
    final response = await _dio.put(
      ApiEndpoints.participationById(id),
      data: request.toJson(),
    );
    return Participation.fromJson(response.data);
  }

  Future<void> deleteParticipation(int id) async {
    await _dio.delete(ApiEndpoints.participationById(id));
  }

  Future<Participation> markParticipationPaid(int id, double amount) async {
    final response = await _dio.put(
      ApiEndpoints.markParticipationPaid(id),
      data: amount,
    );
    return Participation.fromJson(response.data);
  }

  // Config API
  Future<AppConfig> getConfig() async {
    final response = await _dio.get(ApiEndpoints.config);
    return AppConfig.fromJson(response.data);
  }

  Future<AppConfig> updateConfig(AppConfig config) async {
    final response = await _dio.put(
      ApiEndpoints.config,
      data: config.toJson(),
    );
    return AppConfig.fromJson(response.data);
  }
}
```

## presentation/screens/main_navigation.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/person/person_cubit.dart';
import '../cubits/sacrifice/sacrifice_cubit.dart';
import '../cubits/config/config_cubit.dart';
import 'home/home_screen.dart';
import 'persons/persons_screen.dart';
import 'sacrifices/sacrifices_screen.dart';
import 'settings/settings_screen.dart';
import '../../dependencies.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PersonsScreen(),
    const SacrificesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<PersonCubit>()..loadPersons()),
        BlocProvider(create: (context) => getIt<SacrificeCubit>()..loadSacrifices()),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Persons',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.agriculture),
              label: 'Sacrifices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
```

## presentation/screens/home/home_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/sacrifice/sacrifice_cubit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurban Management'),
        centerTitle: true,
      ),
      body: BlocBuilder<SacrificeCubit, SacrificeState>(
        builder: (context, state) {
          if (state is SacrificeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is SacrificeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SacrificeCubit>().loadSacrifices(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is SacrificeLoaded) {
            final sacrifices = state.sacrifices;
            final totalSacrifices = sacrifices.length;
            final completedSacrifices = sacrifices.where((s) => s.isCompleted).length;
            final pendingSacrifices = sacrifices.where((s) => s.isPending).length;
            final totalValue = sacrifices.fold<double>(0, (sum, s) => sum + (s.totalCost ?? 0));
            final totalCollected = sacrifices.fold<double>(0, (sum, s) => sum + (s.totalPaidAmount ?? 0));
            final totalPending = totalValue - totalCollected;

            return RefreshIndicator(
              onRefresh: () async => context.read<SacrificeCubit>().loadSacrifices(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Statistics Cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          title: 'Total Sacrifices',
                          value: totalSacrifices.toString(),
                          icon: Icons.agriculture,
                          color: AppColors.primaryGreen,
                        ),
                        _StatCard(
                          title: 'Completed',
                          value: completedSacrifices.toString(),
                          icon: Icons.check_circle,
                          color: AppColors.completed,
                        ),
                        _StatCard(
                          title: 'Pending',
                          value: pendingSacrifices.toString(),
                          icon: Icons.pending,
                          color: AppColors.pending,
                        ),
                        _StatCard(
                          title: 'Total Value',
                          value: CurrencyUtils.format(totalValue),
                          icon: Icons.account_balance_wallet,
                          color: AppColors.mediumGreen,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Financial Summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Summary',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _FinancialRow(
                              label: 'Total Collected',
                              amount: totalCollected,
                              color: AppColors.completed,
                            ),
                            const SizedBox(height: 8),
                            _FinancialRow(
                              label: 'Total Pending',
                              amount: totalPending,
                              color: AppColors.pending,
                            ),
                            const Divider(),
                            _FinancialRow(
                              label: 'Total Value',
                              amount: totalValue,
                              color: AppColors.primaryGreen,
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Sacrifices
                    Text(
                      'Recent Sacrifices',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (sacrifices.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.agriculture,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No sacrifices yet',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first sacrifice to get started',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ...sacrifices.take(3).map((sacrifice) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: sacrifice.isCompleted 
                              ? AppColors.completed 
                              : AppColors.pending,
                            child: Text(
                              sacrifice.sacrificeNumber.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${sacrifice.animalType.toUpperCase()} - ${CurrencyUtils.format(sacrifice.totalCost ?? 0)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${sacrifice.totalParticipants} participants • ${sacrifice.status}',
                          ),
                          trailing: Icon(
                            sacrifice.isCompleted 
                              ? Icons.check_circle 
                              : Icons.pending,
                            color: sacrifice.isCompleted 
                              ? AppColors.completed 
                              : AppColors.pending,
                          ),
                        ),
                      )),
                  ],
                ),
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isTotal;

  const _FinancialRow({
    required this.label,
    required this.amount,
    required this.color,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          CurrencyUtils.format(amount),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
```

## core/theme/app_theme.dart

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData getTheme({
    Color? primaryColor,
    Color? accentColor,
  }) {
    final primary = primaryColor ?? AppColors.primaryGreen;
    final accent = accentColor ?? AppColors.accentCream;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: Colors.white,
        background: AppColors.lightGrey,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
```

## core/utils/currency_utils.dart

```dart
import 'package:intl/intl.dart';

class CurrencyUtils {
  static final _formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\,
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '\${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}
```

## core/utils/date_utils.dart

```dart
import 'package:intl/intl.dart';

class AppDateUtils {
  static final _dateFormatter = DateFormat('MMM dd, yyyy');
  static final _timeFormatter = DateFormat('HH:mm');
  static final _fullFormatter = DateFormat('MMM dd, yyyy HH:mm');

  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  static String formatTime(DateTime time) {
    return _timeFormatter.format(time);
  }

  static String formatFull(DateTime dateTime) {
    return _fullFormatter.format(dateTime);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
```

## core/widgets/search_field.dart

```dart
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
```

## presentation/cubits/person/person_cubit.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/person.dart';
import '../../../data/repositories/person_repository.dart';

part 'person_state.dart';

class PersonCubit extends Cubit<PersonState> {
  final PersonRepository _repository;

  PersonCubit(this._repository) : super(PersonInitial());

  Future<void> loadPersons() async {
    try {
      emit(PersonLoading());
      final persons = await _repository.getPersons();
      emit(PersonLoaded(persons));
    } catch (e) {
      emit(PersonError(e.toString()));
    }
  }

  Future<void> createPerson(PersonCreateRequest request) async {
    try {
      emit(PersonLoading());
      await _repository.createPerson(request);
      await loadPersons(); // Reload list
    } catch (e) {
      emit(PersonError(e.toString()));
    }
  }

  Future<void> updatePerson(int id, PersonCreateRequest request) async {
    try {
      emit(PersonLoading());
      await _repository.updatePerson(id, request);
      await loadPersons(); // Reload list
    } catch (e) {
      emit(PersonError(e.toString()));
    }
  }

  Future<void> deletePerson(int id) async {
    try {
      emit(PersonLoading());
      await _repository.deletePerson(id);
      await loadPersons(); // Reload list
    } catch (e) {
      emit(PersonError(e.toString()));
    }
  }

  void filterPersons(String query) {
    if (state is PersonLoaded) {
      final currentState = state as PersonLoaded;
      if (query.isEmpty) {
        emit(PersonLoaded(currentState.allPersons));
      } else {
        final filtered = currentState.allPersons
            .where((person) =>
                person.fullName.toLowerCase().contains(query.toLowerCase()) ||
                (person.email?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
        emit(PersonLoaded(filtered, allPersons: currentState.allPersons));
      }
    }
  }
}
```

## presentation/cubits/person/person_state.dart

```dart
part of 'person_cubit.dart';

abstract class PersonState extends Equatable {
  const PersonState();

  @override
  List<Object?> get props => [];
}

class PersonInitial extends PersonState {}

class PersonLoading extends PersonState {}

class PersonLoaded extends PersonState {
  final List<Person> persons;
  final List<Person> allPersons;

  const PersonLoaded(this.persons, {List<Person>? allPersons}) 
      : allPersons = allPersons ?? persons;

  @override
  List<Object?> get props => [persons, allPersons];
}

class PersonError extends PersonState {
  final String message;

  const PersonError(this.message);

  @override
  List<Object?> get props => [message];
}
```

## presentation/cubits/sacrifice/sacrifice_cubit.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/sacrifice.dart';
import '../../../data/repositories/sacrifice_repository.dart';

part 'sacrifice_state.dart';

class SacrificeCubit extends Cubit<SacrificeState> {
  final SacrificeRepository _repository;

  SacrificeCubit(this._repository) : super(SacrificeInitial());

  Future<void> loadSacrifices() async {
    try {
      emit(SacrificeLoading());
      final sacrifices = await _repository.getSacrifices();
      emit(SacrificeLoaded(sacrifices));
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> loadSacrificeById(int id) async {
    try {
      emit(SacrificeLoading());
      final sacrifice = await _repository.getSacrificeById(id);
      emit(SacrificeDetailLoaded(sacrifice));
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> createSacrifice(SacrificeCreateRequest request) async {
    try {
      emit(SacrificeLoading());
      await _repository.createSacrifice(request);
      await loadSacrifices(); // Reload list
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> updateSacrifice(int id, SacrificeCreateRequest request) async {
    try {
      emit(SacrificeLoading());
      await _repository.updateSacrifice(id, request);
      await loadSacrifices(); // Reload list
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> deleteSacrifice(int id) async {
    try {
      emit(SacrificeLoading());
      await _repository.deleteSacrifice(id);
      await loadSacrifices(); // Reload list
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> completeSacrifice(int id) async {
    try {
      await _repository.completeSacrifice(id);
      await loadSacrifices(); // Reload list
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> cancelSacrifice(int id) async {
    try {
      await _repository.cancelSacrifice(id);
      await loadSacrifices(); // Reload list
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }
}
```

## presentation/cubits/sacrifice/sacrifice_state.dart

```dart
part of 'sacrifice_cubit.dart';

abstract class SacrificeState extends Equatable {
  const SacrificeState();

  @override
  List<Object?> get props => [];
}

class SacrificeInitial extends SacrificeState {}

class SacrificeLoading extends SacrificeState {}

class SacrificeLoaded extends SacrificeState {
  final List<Sacrifice> sacrifices;

  const SacrificeLoaded(this.sacrifices);

  @override
  List<Object?> get props => [sacrifices];
}

class SacrificeDetailLoaded extends SacrificeState {
  final Sacrifice sacrifice;

  const SacrificeDetailLoaded(this.sacrifice);

  @override
  List<Object?> get props => [sacrifice];
}

class SacrificeError extends SacrificeState {
  final String message;

  const SacrificeError(this.message);

  @override
  List<Object?> get props => [message];
}
```

## presentation/cubits/participation/participation_cubit.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/participation.dart';
import '../../../data/repositories/participation_repository.dart';

part 'participation_state.dart';

class ParticipationCubit extends Cubit<ParticipationState> {
  final ParticipationRepository _repository;

  ParticipationCubit(this._repository) : super(ParticipationInitial());

  Future<void> loadParticipationsBySacrifice(int sacrificeId) async {
    try {
      emit(ParticipationLoading());
      final participations = await _repository.getParticipationsBySacrifice(sacrificeId);
      emit(ParticipationLoaded(participations));
    } catch (e) {
      emit(ParticipationError(e.toString()));
    }
  }

  Future<void> createParticipation(ParticipationCreateRequest request) async {
    try {
      await _repository.createParticipation(request);
      // Reload participations for the same sacrifice
      await loadParticipationsBySacrifice(request.sacrificeId);
    } catch (e) {
      emit(ParticipationError(e.toString()));
    }
  }

  Future<void> updateParticipation(int id, ParticipationCreateRequest request) async {
    try {
      await _repository.updateParticipation(id, request);
      // Reload participations for the same sacrifice
      await loadParticipationsBySacrifice(request.sacrificeId);
    } catch (e) {
      emit(ParticipationError(e.toString()));
    }
  }

  Future<void> deleteParticipation(int id, int sacrificeId) async {
    try {
      await _repository.deleteParticipation(id);
      // Reload participations for the same sacrifice
      await loadParticipationsBySacrifice(sacrificeId);
    } catch (e) {
      emit(ParticipationError(e.toString()));
    }
  }

  Future<void> markAsPaid(int id, double amount, int sacrificeId) async {
    try {
      await _repository.markParticipationPaid(id, amount);
      // Reload participations for the same sacrifice
      await loadParticipationsBySacrifice(sacrificeId);
    } catch (e) {
      emit(ParticipationError(e.toString()));
    }
  }
}
```

## presentation/cubits/participation/participation_state.dart

```dart
part of 'participation_cubit.dart';

abstract class ParticipationState extends Equatable {
  const ParticipationState();

  @override
  List<Object?> get props => [];
}

class ParticipationInitial extends ParticipationState {}

class ParticipationLoading extends ParticipationState {}

class ParticipationLoaded extends ParticipationState {
  final List<Participation> participations;

  const ParticipationLoaded(this.participations);

  @override
  List<Object?> get props => [participations];
}

class ParticipationError extends ParticipationState {
  final String message;

  const ParticipationError(this.message);

  @override
  List<Object?> get props => [message];
}
```

## presentation/cubits/config/config_cubit.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/app_config.dart';
import '../../../data/repositories/config_repository.dart';

part 'config_state.dart';

class ConfigCubit extends Cubit<ConfigState> {
  final ConfigRepository _repository;

  ConfigCubit(this._repository) : super(ConfigInitial());

  Future<void> loadConfig() async {
    try {
      emit(ConfigLoading());
      final config = await _repository.getConfig();
      emit(ConfigLoaded(config));
    } catch (e) {
      // If config fails to load, use default config
      emit(ConfigLoaded(const AppConfig()));
    }
  }

  Future<void> updateConfig(AppConfig config) async {
    try {
      emit(ConfigLoading());
      final updatedConfig = await _repository.updateConfig(config);
      emit(ConfigLoaded(updatedConfig));
    } catch (e) {
      emit(ConfigError(e.toString()));
    }
  }
}
```

## presentation/cubits/config/config_state.dart

```dart
part of 'config_cubit.dart';

abstract class ConfigState extends Equatable {
  const ConfigState();

  AppConfig? get config => null;

  @override
  List<Object?> get props => [];
}

class ConfigInitial extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  @override
  final AppConfig config;

  const ConfigLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class ConfigError extends ConfigState {
  final String message;

  const ConfigError(this.message);

  @override
  List<Object?> get props => [message];
}
```

## data/repositories/person_repository.dart

```dart
import '../models/person.dart';
import '../services/api_service.dart';

class PersonRepository {
  final ApiService _apiService;

  PersonRepository(this._apiService);

  Future<List<Person>> getPersons() async {
    return await _apiService.getPersons();
  }

  Future<Person> getPersonById(int id) async {
    return await _apiService.getPersonById(id);
  }

  Future<Person> createPerson(PersonCreateRequest request) async {
    return await _apiService.createPerson(request);
  }

  Future<Person> updatePerson(int id, PersonCreateRequest request) async {
    return await _apiService.updatePerson(id, request);
  }

  Future<void> deletePerson(int id) async {
    await _apiService.deletePerson(id);
  }
}
```

## data/repositories/sacrifice_repository.dart

```dart
import '../models/sacrifice.dart';
import '../services/api_service.dart';

class SacrificeRepository {
  final ApiService _apiService;

  SacrificeRepository(this._apiService);

  Future<List<Sacrifice>> getSacrifices() async {
    return await _apiService.getSacrifices();
  }

  Future<Sacrifice> getSacrificeById(int id) async {
    return await _apiService.getSacrificeById(id);
  }

  Future<Sacrifice> createSacrifice(SacrificeCreateRequest request) async {
    return await _apiService.createSacrifice(request);
  }

  Future<Sacrifice> updateSacrifice(int id, SacrificeCreateRequest request) async {
    return await _apiService.updateSacrifice(id, request);
  }

  Future<void> deleteSacrifice(int id) async {
    await _apiService.deleteSacrifice(id);
  }

  Future<Sacrifice> completeSacrifice(int id) async {
    return await _apiService.completeSacrifice(id);
  }

  Future<Sacrifice> cancelSacrifice(int id) async {
    return await _apiService.cancelSacrifice(id);
  }
}
```

## data/repositories/participation_repository.dart

```dart
import '../models/participation.dart';
import '../services/api_service.dart';

class ParticipationRepository {
  final ApiService _apiService;

  ParticipationRepository(this._apiService);

  Future<List<Participation>> getParticipationsBySacrifice(int sacrificeId) async {
    return await _apiService.getParticipationsBySacrifice(sacrificeId);
  }

  Future<Participation> createParticipation(ParticipationCreateRequest request) async {
    return await _apiService.createParticipation(request);
  }

  Future<Participation> updateParticipation(int id, ParticipationCreateRequest request) async {
    return await _apiService.updateParticipation(id, request);
  }

  Future<void> deleteParticipation(int id) async {
    await _apiService.deleteParticipation(id);
  }

  Future<Participation> markParticipationPaid(int id, double amount) async {
    return await _apiService.markParticipationPaid(id, amount);
  }
}
```

## data/repositories/config_repository.dart

```dart
import '../models/app_config.dart';
import '../services/api_service.dart';

class ConfigRepository {
  final ApiService _apiService;

  ConfigRepository(this._apiService);

  Future<AppConfig> getConfig() async {
    return await _apiService.getConfig();
  }

  Future<AppConfig> updateConfig(AppConfig config) async {
    return await _apiService.updateConfig(config);
  }
}
```

## dependencies.dart

```dart
import 'package:get_it/get_it.dart';
import 'data/services/api_service.dart';
import 'data/repositories/person_repository.dart';
import 'data/repositories/sacrifice_repository.dart';
import 'data/repositories/participation_repository.dart';
import 'data/repositories/config_repository.dart';
import 'presentation/cubits/person/person_cubit.dart';
import 'presentation/cubits/sacrifice/sacrifice_cubit.dart';
import 'presentation/cubits/participation/participation_cubit.dart';
import 'presentation/cubits/config/config_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Repositories
  getIt.registerLazySingleton<PersonRepository>(
    () => PersonRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<SacrificeRepository>(
    () => SacrificeRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<ParticipationRepository>(
    () => ParticipationRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<ConfigRepository>(
    () => ConfigRepository(getIt<ApiService>()),
  );

  // Cubits
  getIt.registerFactory<PersonCubit>(
    () => PersonCubit(getIt<PersonRepository>()),
  );
  getIt.registerFactory<SacrificeCubit>(
    () => SacrificeCubit(getIt<SacrificeRepository>()),
  );
  getIt.registerFactory<ParticipationCubit>(
    () => ParticipationCubit(getIt<ParticipationRepository>()),
  );
  getIt.registerLazySingleton<ConfigCubit>(
    () => ConfigCubit(getIt<ConfigRepository>()),
  );
}
```

## presentation/screens/sacrifices/sacrifice_detail_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/sacrifice/sacrifice_cubit.dart';
import '../../cubits/participation/participation_cubit.dart';
import '../../cubits/person/person_cubit.dart';
import '../../cubits/config/config_cubit.dart';
import '../../../data/models/sacrifice.dart';
import '../../../data/models/person.dart';
import '../../../data/models/participation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../dependencies.dart';

class SacrificeDetailScreen extends StatefulWidget {
  final int sacrificeId;

  const SacrificeDetailScreen({
    super.key,
    required this.sacrificeId,
  });

  @override
  State<SacrificeDetailScreen> createState() => _SacrificeDetailScreenState();
}

class _SacrificeDetailScreenState extends State<SacrificeDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shareCountController = TextEditingController();
  final _notesController = TextEditingController();
  
  Person? _selectedPerson;
  String _personSearchQuery = '';
  bool _isFormExpanded = true;

  @override
  void initState() {
    super.initState();
    _shareCountController.text = '1';
  }

  @override
  void dispose() {
    _shareCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<SacrificeCubit>()..loadSacrificeById(widget.sacrificeId),
        ),
        BlocProvider(
          create: (context) => getIt<ParticipationCubit>()..loadParticipationsBySacrifice(widget.sacrificeId),
        ),
        BlocProvider(
          create: (context) => getIt<PersonCubit>()..loadPersons(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sacrifice Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<SacrificeCubit>().loadSacrificeById(widget.sacrificeId);
                context.read<ParticipationCubit>().loadParticipationsBySacrifice(widget.sacrificeId);
              },
            ),
          ],
        ),
        body: BlocBuilder<SacrificeCubit, SacrificeState>(
          builder: (context, state) {
            if (state is SacrificeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is SacrificeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<SacrificeCubit>().loadSacrificeById(widget.sacrificeId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is SacrificeDetailLoaded) {
              final sacrifice = state.sacrifice;
              
              return Column(
                children: [
                  // Sacrifice Info Header
                  _buildSacrificeHeader(sacrifice),
                  
                  // Participations List (Expandable)
                  Expanded(
                    child: _buildParticipationsList(sacrifice),
                  ),
                  
                  // Add Participation Form
                  _buildAddParticipationForm(sacrifice),
                ],
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSacrificeHeader(Sacrifice sacrifice) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: sacrifice.isCompleted 
                    ? AppColors.completed 
                    : AppColors.pending,
                  radius: 24,
                  child: Text(
                    sacrifice.sacrificeNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sacrifice.animalType.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total Cost: ${CurrencyUtils.format(sacrifice.totalCost ?? 0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sacrifice.isCompleted 
                      ? AppColors.completed 
                      : AppColors.pending,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sacrifice.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Financial Summary
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Participants',
                    sacrifice.totalParticipants.toString(),
                    Icons.people,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Shares Used',
                    '${sacrifice.totalShares}/7',
                    Icons.pie_chart,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Collected',
                    CurrencyUtils.formatCompact(sacrifice.totalPaidAmount ?? 0),
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pending',
                    CurrencyUtils.formatCompact(sacrifice.pendingAmount),
                    Icons.pending,
                  ),
                ),
              ],
            ),
            
            if (sacrifice.sacrificeDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Sacrifice Date: ${AppDateUtils.formatDate(sacrifice.sacrificeDate!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildParticipationsList(Sacrifice sacrifice) {
    return BlocBuilder<ParticipationCubit, ParticipationState>(
      builder: (context, state) {
        if (state is ParticipationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is ParticipationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Error loading participations: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<ParticipationCubit>().loadParticipationsBySacrifice(widget.sacrificeId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is ParticipationLoaded) {
          final participations = state.participations;
          
          if (participations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_add,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No participations yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add the first participation below',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Participations (${participations.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Share Price: ${CurrencyUtils.format(sacrifice.sharePrice ?? 0)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: participations.length,
                  itemBuilder: (context, index) {
                    final participation = participations[index];
                    return _buildParticipationCard(participation, sacrifice);
                  },
                ),
              ),
            ],
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildParticipationCard(Participation participation, Sacrifice sacrifice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: participation.paid ? AppColors.completed : AppColors.pending,
              child: Text(
                participation.shareCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participation.personName ?? 'Unknown Person',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${participation.shareCount} ${participation.shareCount == 1 ? 'share' : 'shares'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (participation.shareAmount != null) ...[
                        Text(
                          ' • ${CurrencyUtils.format(participation.shareAmount!)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (participation.notes != null && participation.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      participation.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: participation.paid ? AppColors.completed : AppColors.pending,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    participation.paid ? 'PAID' : 'PENDING',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditParticipationDialog(participation, sacrifice),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _showDeleteParticipationDialog(participation),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddParticipationForm(Sacrifice sacrifice) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          'Add Participation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Available shares: ${sacrifice.availableShares}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        leading: const Icon(Icons.group_add),
        initiallyExpanded: _isFormExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isFormExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Person Selection
                  _buildPersonSelector(),
                  const SizedBox(height: 16),
                  
                  // Share Count
                  TextFormField(
                    controller: _shareCountController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Shares',
                      hintText: 'Enter share count (1-7)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pie_chart),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter share count';
                      }
                      final shares = int.tryParse(value);
                      if (shares == null || shares < 1 || shares > 7) {
                        return 'Share count must be between 1 and 7';
                      }
                      if (shares > sacrifice.availableShares) {
                        return 'Only ${sacrifice.availableShares} shares available';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Add any additional notes...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // Calculate Share Amount
                  if (_shareCountController.text.isNotEmpty && sacrifice.sharePrice != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentCream,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Calculated Amount:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            CurrencyUtils.format(
                              (int.tryParse(_shareCountController.text) ?? 0) * sacrifice.sharePrice!,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: sacrifice.availableShares > 0 ? () => _submitParticipation(sacrifice) : null,
                      child: Text(
                        sacrifice.availableShares > 0 
                          ? 'Add Participation' 
                          : 'No Shares Available',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonSelector() {
    return BlocBuilder<PersonCubit, PersonState>(
      builder: (context, state) {
        if (state is! PersonLoaded) {
          return const TextFormField(
            decoration: InputDecoration(
              labelText: 'Loading persons...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            enabled: false,
          );
        }
        
        final persons = state.persons
            .where((person) => person.fullName.toLowerCase().contains(_personSearchQuery.toLowerCase()))
            .toList();
        
        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Search Person',
                hintText: 'Type to search persons...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _selectedPerson != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedPerson = null;
                            _personSearchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _personSearchQuery = value;
                  if (value.isEmpty) {
                    _selectedPerson = null;
                  }
                });
              },
              validator: (value) {
                if (_selectedPerson == null) {
                  return 'Please select a person';
                }
                return null;
              },
            ),
            
            if (_selectedPerson != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGreen),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryGreen,
                      radius: 16,
                      child: Text(
                        _selectedPerson!.firstname.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPerson!.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_selectedPerson!.email != null)
                            Text(
                              _selectedPerson!.email!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
              ),
            ] else if (_personSearchQuery.isNotEmpty && persons.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    final person = persons[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryGreen,
                        radius: 16,
                        child: Text(
                          person.firstname.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(person.fullName),
                      subtitle: person.email != null ? Text(person.email!) : null,
                      onTap: () {
                        setState(() {
                          _selectedPerson = person;
                          _personSearchQuery = person.fullName;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _submitParticipation(Sacrifice sacrifice) async {
    if (!_formKey.currentState!.validate() || _selectedPerson == null) {
      return;
    }

    final shareCount = int.parse(_shareCountController.text);
    final shareAmount = shareCount * (sacrifice.sharePrice ?? 0);

    // Check if person already participates
    final participationState = context.read<ParticipationCubit>().state;
    if (participationState is ParticipationLoaded) {
      final existingParticipation = participationState.participations
          .where((p) => p.personId == _selectedPerson!.id)
          .firstOrNull;

      if (existingParticipation != null) {
        final confirmed = await _showUpdateParticipationDialog(
          existingParticipation,
          shareCount,
          shareAmount,
        );
        if (!confirmed) return;
      }
    }

    final request = ParticipationCreateRequest(
      personId: _selectedPerson!.id!,
      sacrificeId: sacrifice.id!,
      shareCount: shareCount,
      shareAmount: shareAmount,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    try {
      await context.read<ParticipationCubit>().createParticipation(request);
      
      // Reset form
      setState(() {
        _selectedPerson = null;
        _personSearchQuery = '';
        _shareCountController.text = '1';
        _notesController.clear();
      });
      
      // Refresh sacrifice data to update available shares
      context.read<SacrificeCubit>().loadSacrificeById(widget.sacrificeId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participation added successfully'),
            backgroundColor: AppColors.completed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding participation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showUpdateParticipationDialog(
    Participation existing,
    int newShareCount,
    double newShareAmount,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Participation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${existing.personName} already participates in this sacrifice.'),
            const SizedBox(height: 16),
            Text('Current: ${existing.shareCount} shares'),
            Text('Adding: $newShareCount shares'),
            Text('New Total: ${existing.shareCount + newShareCount} shares'),
            const SizedBox(height: 8),
            Text('New Amount: ${CurrencyUtils.format(newShareAmount + (existing.shareAmount ?? 0))}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showEditParticipationDialog(Participation participation, Sacrifice sacrifice) async {
    // Implementation for edit dialog
    // This would open a dialog similar to the add form but pre-filled with existing data
  }

  Future<void> _showDeleteParticipationDialog(Participation participation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Participation'),
        content: Text('Are you sure you want to delete ${participation.personName}\'s participation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && participation.id != null) {
      try {
        await context.read<ParticipationCubit>().deleteParticipation(
          participation.id!,
          widget.sacrificeId,
        );
        
        // Refresh sacrifice data
        context.read<SacrificeCubit>().loadSacrificeById(widget.sacrificeId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Participation deleted successfully'),
              backgroundColor: AppColors.completed,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting participation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
```

## presentation/screens/persons/persons_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/person/person_cubit.dart';
import '../../../data/models/person.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/search_field.dart';
import 'add_person_screen.dart';
import 'edit_person_screen.dart';

class PersonsScreen extends StatefulWidget {
  const PersonsScreen({super.key});

  @override
  State<PersonsScreen> createState() => _PersonsScreenState();
}

class _PersonsScreenState extends State<PersonsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persons'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchField(
            hintText: 'Search persons...',
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
              context.read<PersonCubit>().filterPersons(query);
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
              context.read<PersonCubit>().filterPersons('');
            },
          ),
          Expanded(
            child: BlocBuilder<PersonCubit, PersonState>(
              builder: (context, state) {
                if (state is PersonLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state is PersonError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<PersonCubit>().loadPersons(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is PersonLoaded) {
                  final persons = state.persons;
                  
                  if (persons.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isEmpty ? Icons.person_add : Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty 
                              ? 'No persons yet'
                              : 'No persons found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty 
                              ? 'Add your first person to get started'
                              : 'Try a different search term',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async => context.read<PersonCubit>().loadPersons(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: persons.length,
                      itemBuilder: (context, index) {
                        final person = persons[index];
                        return _buildPersonCard(person);
                      },
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPerson(),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildPersonCard(Person person) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: person.hasContactInfo 
            ? AppColors.primaryGreen 
            : AppColors.pending,
          child: Text(
            person.firstname.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          person.fullName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (person.email != null || person.phone != null) ...[
              if (person.email != null)
                Text(
                  person.email!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              if (person.phone != null)
                Text(
                  person.phone!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ] else ...[
              Text(
                person.contactIntermediaryName != null
                  ? 'Contact via: ${person.contactIntermediaryName}'
                  : 'No contact info',
                style: TextStyle(
                  color: Colors.orange[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (person.totalParticipations > 0)
              Text(
                '${person.totalParticipations} participation${person.totalParticipations == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _navigateToEditPerson(person),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(person),
            ),
          ],
        ),
        onTap: () => _navigateToEditPerson(person),
      ),
    );
  }

  Future<void> _navigateToAddPerson() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddPersonScreen(),
      ),
    );
    
    if (result == true) {
      context.read<PersonCubit>().loadPersons();
    }
  }

  Future<void> _navigateToEditPerson(Person person) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPersonScreen(person: person),
      ),
    );
    
    if (result == true) {
      context.read<PersonCubit>().loadPersons();
    }
  }

  Future<void> _showDeleteDialog(Person person) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${person.fullName}?'),
            if (person.totalParticipations > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Warning: This person has ${person.totalParticipations} participation${person.totalParticipations == 1 ? '' : 's'}.',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && person.id != null) {
      try {
        await context.read<PersonCubit>().deletePerson(person.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Person deleted successfully'),
              backgroundColor: AppColors.completed,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting person: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
```

## presentation/screens/persons/add_person_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/person/person_cubit.dart';
import '../../cubits/config/config_cubit.dart';
import '../../../data/models/person.dart';
import '../../../core/constants/app_colors.dart';
import '../../../dependencies.dart';

class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({super.key});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  Person? _selectedIntermediary;
  bool _needsIntermediary = false;
  List<Person> _availableIntermediaries = [];

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PersonCubit>()..loadPersons(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Person'),
          centerTitle: true,
        ),
        body: BlocListener<PersonCubit, PersonState>(
          listener: (context, state) {
            if (state is PersonLoaded) {
              _availableIntermediaries = state.persons
                  .where((person) => person.hasContactInfo)
                  .toList();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // First Name
                  TextFormField(
                    controller: _firstnameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      hintText: 'Enter first name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      if (value.length > 50) {
                        return 'First name must not exceed 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Last Name
                  TextFormField(
                    controller: _lastnameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      hintText: 'Enter last name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      if (value.length > 50) {
                        return 'Last name must not exceed 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Provide at least one contact method or select an intermediary',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter phone number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _updateContactValidation(),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length > 20) {
                        return 'Phone number must not exceed 20 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter email address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => _updateContactValidation(),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        if (value.length > 120) {
                          return 'Email must not exceed 120 characters';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Contact Intermediary Section
                  CheckboxListTile(
                    title: const Text('This person needs a contact intermediary'),
                    subtitle: const Text('Select if this person has no direct contact info'),
                    value: _needsIntermediary,
                    onChanged: (value) {
                      setState(() {
                        _needsIntermediary = value ?? false;
                        if (!_needsIntermediary) {
                          _selectedIntermediary = null;
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  
                  if (_needsIntermediary) ...[
                    const SizedBox(height: 16),
                    _buildIntermediarySelector(),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isFormValid() ? _submitForm : null,
                      child: const Text(
                        'Add Person',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntermediarySelector() {
    return BlocBuilder<PersonCubit, PersonState>(
      builder: (context, state) {
        if (state is PersonLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        if (_availableIntermediaries.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'No Contact Intermediaries Available',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You need at least one person with contact info to act as an intermediary.',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Contact Intermediary *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableIntermediaries.length,
                itemBuilder: (context, index) {
                  final intermediary = _availableIntermediaries[index];
                  return RadioListTile<Person>(
                    title: Text(intermediary.fullName),
                    subtitle: Text(
                      [intermediary.phone, intermediary.email]
                          .where((contact) => contact != null && contact.isNotEmpty)
                          .join(' • '),
                    ),
                    value: intermediary,
                    groupValue: _selectedIntermediary,
                    onChanged: (value) {
                      setState(() {
                        _selectedIntermediary = value;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateContactValidation() {
    setState(() {
      // Trigger rebuild to update form validation
    });
  }

  bool _isFormValid() {
    final hasDirectContact = _phoneController.text.trim().isNotEmpty || 
                           _emailController.text.trim().isNotEmpty;
    final hasIntermediary = _needsIntermediary && _selectedIntermediary != null;
    
    return _firstnameController.text.trim().isNotEmpty &&
           _lastnameController.text.trim().isNotEmpty &&
           (hasDirectContact || hasIntermediary);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide contact information or select an intermediary'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final request = PersonCreateRequest(
      firstname: _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      contactIntermediaryId: _selectedIntermediary?.id,
    );

    try {
      await context.read<PersonCubit>().createPerson(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Person added successfully'),
            backgroundColor: AppColors.completed,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding person: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

## presentation/screens/persons/edit_person_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/person/person_cubit.dart';
import '../../../data/models/person.dart';
import '../../../core/constants/app_colors.dart';
import '../../../dependencies.dart';

class EditPersonScreen extends StatefulWidget {
  final Person person;

  const EditPersonScreen({
    super.key,
    required this.person,
  });

  @override
  State<EditPersonScreen> createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  Person? _selectedIntermediary;
  bool _needsIntermediary = false;
  List<Person> _availableIntermediaries = [];

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController(text: widget.person.firstname);
    _lastnameController = TextEditingController(text: widget.person.lastname);
    _phoneController = TextEditingController(text: widget.person.phone ?? '');
    _emailController = TextEditingController(text: widget.person.email ?? '');
    _needsIntermediary = widget.person.contactIntermediaryId != null;
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PersonCubit>()..loadPersons(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Person'),
          centerTitle: true,
        ),
        body: BlocListener<PersonCubit, PersonState>(
          listener: (context, state) {
            if (state is PersonLoaded) {
              _availableIntermediaries = state.persons
                  .where((person) => person.hasContactInfo && person.id != widget.person.id)
                  .toList();
              
              // Find current intermediary if exists
              if (widget.person.contactIntermediaryId != null) {
                _selectedIntermediary = _availableIntermediaries
                    .where((p) => p.id == widget.person.contactIntermediaryId)
                    .firstOrNull;
              }
              setState(() {});
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Person Info Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryGreen,
                            radius: 24,
                            child: Text(
                              widget.person.firstname.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.person.fullName,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${widget.person.totalParticipations} participation${widget.person.totalParticipations == 1 ? '' : 's'}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // First Name
                  TextFormField(
                    controller: _firstnameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      if (value.length > 50) {
                        return 'First name must not exceed 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Last Name
                  TextFormField(
                    controller: _lastnameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      if (value.length > 50) {
                        return 'Last name must not exceed 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _updateContactValidation(),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length > 20) {
                        return 'Phone number must not exceed 20 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => _updateContactValidation(),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        if (value.length > 120) {
                          return 'Email must not exceed 120 characters';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Contact Intermediary Section
                  CheckboxListTile(
                    title: const Text('This person needs a contact intermediary'),
                    value: _needsIntermediary,
                    onChanged: (value) {
                      setState(() {
                        _needsIntermediary = value ?? false;
                        if (!_needsIntermediary) {
                          _selectedIntermediary = null;
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  
                  if (_needsIntermediary) ...[
                    const SizedBox(height: 16),
                    _buildIntermediarySelector(),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isFormValid() ? _submitForm : null,
                          child: const Text('Update Person'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntermediarySelector() {
    if (_availableIntermediaries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 32),
              const SizedBox(height: 8),
              const Text(
                'No Contact Intermediaries Available',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'You need at least one other person with contact info to act as an intermediary.',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Contact Intermediary *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              RadioListTile<Person?>(
                title: const Text('None (Remove intermediary)'),
                subtitle: const Text('This person will have direct contact'),
                value: null,
                groupValue: _selectedIntermediary,
                onChanged: (value) {
                  setState(() {
                    _selectedIntermediary = value;
                  });
                },
              ),
              ...(_availableIntermediaries.map((intermediary) => RadioListTile<Person>(
                title: Text(intermediary.fullName),
                subtitle: Text(
                  [intermediary.phone, intermediary.email]
                      .where((contact) => contact != null && contact.isNotEmpty)
                      .join(' • '),
                ),
                value: intermediary,
                groupValue: _selectedIntermediary,
                onChanged: (value) {
                  setState(() {
                    _selectedIntermediary = value;
                  });
                },
              ))),
            ],
          ),
        ),
      ],
    );
  }

  void _updateContactValidation() {
    setState(() {
      // Trigger rebuild to update form validation
    });
  }

  bool _isFormValid() {
    final hasDirectContact = _phoneController.text.trim().isNotEmpty || 
                           _emailController.text.trim().isNotEmpty;
    final hasIntermediary = _needsIntermediary && _selectedIntermediary != null;
    
    return _firstnameController.text.trim().isNotEmpty &&
           _lastnameController.text.trim().isNotEmpty &&
           (hasDirectContact || hasIntermediary || !_needsIntermediary);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = PersonCreateRequest(
      firstname: _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      contactIntermediaryId: _selectedIntermediary?.id,
    );

    try {
      await context.read<PersonCubit>().updatePerson(widget.person.id!, request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Person updated successfully'),
            backgroundColor: AppColors.completed,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating person: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

## presentation/screens/sacrifices/sacrifices_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/sacrifice/sacrifice_cubit.dart';
import '../../../data/models/sacrifice.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import 'add_sacrifice_screen.dart';
import 'edit_sacrifice_screen.dart';
import 'sacrifice_detail_screen.dart';

class SacrificesScreen extends StatelessWidget {
  const SacrificesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sacrifices'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SacrificeCubit>().loadSacrifices(),
          ),
        ],
      ),
      body: BlocBuilder<SacrificeCubit, SacrificeState>(
        builder: (context, state) {
          if (state is SacrificeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is SacrificeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SacrificeCubit>().loadSacrifices(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is SacrificeLoaded) {
            final sacrifices = state.sacrifices;
            
            if (sacrifices.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No sacrifices yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first sacrifice to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async => context.read<SacrificeCubit>().loadSacrifices(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sacrifices.length,
                itemBuilder: (context, index) {
                  final sacrifice = sacrifices[index];
                  return _SacrificeCard(
                    sacrifice: sacrifice,
                    onTap: () => _navigateToDetail(context, sacrifice),
                    onEdit: () => _navigateToEdit(context, sacrifice),
                    onDelete: () => _showDeleteDialog(context, sacrifice),
                    onComplete: sacrifice.isPending 
                      ? () => _completeSacrifice(context, sacrifice) 
                      : null,
                    onCancel: sacrifice.isPending 
                      ? () => _cancelSacrifice(context, sacrifice) 
                      : null,
                  );
                },
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdd(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToAdd(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddSacrificeScreen(),
      ),
    );
    
    if (result == true) {
      context.read<SacrificeCubit>().loadSacrifices();
    }
  }

  Future<void> _navigateToEdit(BuildContext context, Sacrifice sacrifice) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditSacrificeScreen(sacrifice: sacrifice),
      ),
    );
    
    if (result == true) {
      context.read<SacrificeCubit>().loadSacrifices();
    }
  }

  Future<void> _navigateToDetail(BuildContext context, Sacrifice sacrifice) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SacrificeDetailScreen(sacrificeId: sacrifice.id!),
      ),
    );
    
    // Refresh list when returning from detail screen
    context.read<SacrificeCubit>().loadSacrifices();
  }

  Future<void> _showDeleteDialog(BuildContext context, Sacrifice sacrifice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sacrifice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete Sacrifice #${sacrifice.sacrificeNumber}?'),
            if (sacrifice.totalParticipants > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Warning: This sacrifice has ${sacrifice.totalParticipants} participant${sacrifice.totalParticipants == 1 ? '' : 's'}.',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<SacrificeCubit>().deleteSacrifice(sacrifice.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sacrifice deleted successfully'),
              backgroundColor: AppColors.completed,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting sacrifice: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _completeSacrifice(BuildContext context, Sacrifice sacrifice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Sacrifice'),
        content: Text('Mark Sacrifice #${sacrifice.sacrificeNumber} as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<SacrificeCubit>().completeSacrifice(sacrifice.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sacrifice completed successfully'),
              backgroundColor: AppColors.completed,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error completing sacrifice: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _cancelSacrifice(BuildContext context, Sacrifice sacrifice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Sacrifice'),
        content: Text('Cancel Sacrifice #${sacrifice.sacrificeNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel Sacrifice'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<SacrificeCubit>().cancelSacrifice(sacrifice.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sacrifice cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error cancelling sacrifice: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _SacrificeCard extends StatelessWidget {
  final Sacrifice sacrifice;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const _SacrificeCard({
    required this.sacrifice,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getStatusColor(),
                    radius: 20,
                    child: Text(
                      sacrifice.sacrificeNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sacrifice.animalType.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          CurrencyUtils.format(sacrifice.totalCost ?? 0),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sacrifice.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stats Row
              Row(
                children: [
                  _buildStat(
                    context,
                    'Participants',
                    sacrifice.totalParticipants.toString(),
                    Icons.people,
                  ),
                  _buildStat(
                    context,
                    'Shares',
                    '${sacrifice.totalShares}/7',
                    Icons.pie_chart,
                  ),
                  _buildStat(
                    context,
                    'Collected',
                    CurrencyUtils.formatCompact(sacrifice.totalPaidAmount ?? 0),
                    Icons.account_balance_wallet,
                  ),
                  _buildStat(
                    context,
                    'Pending',
                    CurrencyUtils.formatCompact(sacrifice.pendingAmount),
                    Icons.pending,
                  ),
                ],
              ),
              
              if (sacrifice.sacrificeDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      AppDateUtils.formatDate(sacrifice.sacrificeDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  if (onComplete != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onComplete,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Complete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.completed,
                          side: const BorderSide(color: AppColors.completed),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onCancel != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (sacrifice.status) {
      case 'completed':
        return AppColors.completed;
      case 'cancelled':
        return AppColors.cancelled;
      default:
        return AppColors.pending;
    }
  }
}

# Missing Screens - Implementation Complete

## 1. Add Sacrifice Screen

**File: `lib/presentation/screens/sacrifices/add_sacrifice_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/sacrifice/sacrifice_cubit.dart';
import '../../cubits/config/config_cubit.dart';
import '../../../data/models/sacrifice.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';

class AddSacrificeScreen extends StatefulWidget {
  const AddSacrificeScreen({super.key});

  @override
  State<AddSacrificeScreen> createState() => _AddSacrificeScreenState();
}

class _AddSacrificeScreenState extends State<AddSacrificeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sacrificeNumberController = TextEditingController();
  final _totalCostController = TextEditingController();
  
  String _selectedAnimalType = 'cow';
  DateTime? _selectedDate;
  
  final List<String> _animalTypes = ['cow', 'goat', 'sheep', 'camel'];

  @override
  void initState() {
    super.initState();
    // Set default date
    _selectedDate = DateTime.now().add(const Duration(days: 30));
    
    // Set default values from config when available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final configState = context.read<ConfigCubit>().state;
      if (configState is ConfigLoaded) {
        final config = configState.config;
        setState(() {
          _selectedAnimalType = config.defaultAnimalType;
          final defaultPrice = config.defaultPriceByAnimalType[_selectedAnimalType];
          if (defaultPrice != null) {
            _totalCostController.text = defaultPrice.toString();
          }
          _selectedDate = DateTime.now().add(Duration(days: config.defaultSacrificeDaysFromNow));
        });
      }
    });
  }

  @override
  void dispose() {
    _sacrificeNumberController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sacrifice'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sacrifice Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Sacrifice Number
              TextFormField(
                controller: _sacrificeNumberController,
                decoration: const InputDecoration(
                  labelText: 'Sacrifice Number *',
                  hintText: 'Enter unique sacrifice number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sacrifice number is required';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Animal Type
              DropdownButtonFormField<String>(
                value: _selectedAnimalType,
                decoration: const InputDecoration(
                  labelText: 'Animal Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.agriculture),
                ),
                items: _animalTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Text(type.toUpperCase()),
                        const SizedBox(width: 8),
                        BlocBuilder<ConfigCubit, ConfigState>(
                          builder: (context, state) {
                            if (state is ConfigLoaded) {
                              final defaultPrice = state.config.defaultPriceByAnimalType[type];
                              if (defaultPrice != null) {
                                return Text(
                                  '(${CurrencyUtils.format(defaultPrice)})',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAnimalType = value;
                    });
                    _updateDefaultPrice(value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an animal type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Total Cost
              TextFormField(
                controller: _totalCostController,
                decoration: const InputDecoration(
                  labelText: 'Total Cost *',
                  hintText: 'Enter total cost',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Total cost is required';
                  }
                  final cost = double.tryParse(value);
                  if (cost == null || cost <= 0) {
                    return 'Please enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Share Price Calculation
              if (_totalCostController.text.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Share Price (Total ÷ 7):',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _calculateSharePrice(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Each share will cost this amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Sacrifice Date
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sacrifice Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedDate != null 
                                ? AppDateUtils.formatDate(_selectedDate!)
                                : 'Select date',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Preview Card
              Card(
                color: AppColors.lightGrey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.preview, color: AppColors.primaryGreen),
                          const SizedBox(width: 8),
                          Text(
                            'Preview',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPreviewRow('Sacrifice Number', _sacrificeNumberController.text.isEmpty ? 'Not set' : '#${_sacrificeNumberController.text}'),
                      _buildPreviewRow('Animal Type', _selectedAnimalType.toUpperCase()),
                      _buildPreviewRow('Total Cost', _totalCostController.text.isEmpty ? 'Not set' : CurrencyUtils.format(double.tryParse(_totalCostController.text) ?? 0)),
                      _buildPreviewRow('Share Price', _calculateSharePrice()),
                      _buildPreviewRow('Sacrifice Date', _selectedDate != null ? AppDateUtils.formatDate(_selectedDate!) : 'Not set'),
                      _buildPreviewRow('Status', 'PENDING'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text(
                    'Create Sacrifice',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateDefaultPrice(String animalType) {
    final configState = context.read<ConfigCubit>().state;
    if (configState is ConfigLoaded) {
      final defaultPrice = configState.config.defaultPriceByAnimalType[animalType];
      if (defaultPrice != null) {
        _totalCostController.text = defaultPrice.toString();
      }
    }
  }

  String _calculateSharePrice() {
    final cost = double.tryParse(_totalCostController.text);
    if (cost != null && cost > 0) {
      return CurrencyUtils.format(cost / 7);
    }
    return CurrencyUtils.format(0);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select Sacrifice Date',
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = SacrificeCreateRequest(
      sacrificeNumber: int.parse(_sacrificeNumberController.text),
      animalType: _selectedAnimalType,
      totalCost: double.parse(_totalCostController.text),
      sacrificeDate: _selectedDate,
    );

    try {
      await context.read<SacrificeCubit>().createSacrifice(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sacrifice created successfully'),
            backgroundColor: AppColors.completed,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating sacrifice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

## 2. Edit Sacrifice Screen

**File: `lib/presentation/screens/sacrifices/edit_sacrifice_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/sacrifice/sacrifice_cubit.dart';
import '../../../data/models/sacrifice.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';

class EditSacrificeScreen extends StatefulWidget {
  final Sacrifice sacrifice;

  const EditSacrificeScreen({
    super.key,
    required this.sacrifice,
  });

  @override
  State<EditSacrificeScreen> createState() => _EditSacrificeScreenState();
}

class _EditSacrificeScreenState extends State<EditSacrificeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sacrificeNumberController;
  late TextEditingController _totalCostController;
  
  late String _selectedAnimalType;
  DateTime? _selectedDate;
  
  final List<String> _animalTypes = ['cow', 'goat', 'sheep', 'camel'];

  @override
  void initState() {
    super.initState();
    _sacrificeNumberController = TextEditingController(
      text: widget.sacrifice.sacrificeNumber.toString(),
    );
    _totalCostController = TextEditingController(
      text: widget.sacrifice.totalCost?.toString() ?? '',
    );
    _selectedAnimalType = widget.sacrifice.animalType;
    _selectedDate = widget.sacrifice.sacrificeDate;
  }

  @override
  void dispose() {
    _sacrificeNumberController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Sacrifice'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Sacrifice Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: widget.sacrifice.isCompleted 
                          ? AppColors.completed 
                          : AppColors.pending,
                        radius: 24,
                        child: Text(
                          widget.sacrifice.sacrificeNumber.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.sacrifice.animalType.toUpperCase(),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.sacrifice.totalParticipants} participants • ${widget.sacrifice.status}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              if (widget.sacrifice.totalParticipants > 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Warning: This sacrifice has ${widget.sacrifice.totalParticipants} participant${widget.sacrifice.totalParticipants == 1 ? '' : 's'}. Changes may affect their shares.',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              Text(
                'Sacrifice Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Sacrifice Number
              TextFormField(
                controller: _sacrificeNumberController,
                decoration: const InputDecoration(
                  labelText: 'Sacrifice Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sacrifice number is required';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Animal Type
              DropdownButtonFormField<String>(
                value: _selectedAnimalType,
                decoration: const InputDecoration(
                  labelText: 'Animal Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.agriculture),
                ),
                items: _animalTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAnimalType = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an animal type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Total Cost
              TextFormField(
                controller: _totalCostController,
                decoration: const InputDecoration(
                  labelText: 'Total Cost *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Total cost is required';
                  }
                  final cost = double.tryParse(value);
                  if (cost == null || cost <= 0) {
                    return 'Please enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Share Price Calculation
              if (_totalCostController.text.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'New Share Price (Total ÷ 7):',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _calculateSharePrice(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (widget.sacrifice.sharePrice != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Current Share Price:',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              CurrencyUtils.format(widget.sacrifice.sharePrice!),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Sacrifice Date
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sacrifice Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedDate != null 
                                ? AppDateUtils.formatDate(_selectedDate!)
                                : 'No date set',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Update Sacrifice'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateSharePrice() {
    final cost = double.tryParse(_totalCostController.text);
    if (cost != null && cost > 0) {
      return CurrencyUtils.format(cost / 7);
    }
    return CurrencyUtils.format(0);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select Sacrifice Date',
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = SacrificeCreateRequest(
      sacrificeNumber: int.parse(_sacrificeNumberController.text),
      animalType: _selectedAnimalType,
      totalCost: double.parse(_totalCostController.text),
      sacrificeDate: _selectedDate,
    );

    try {
      await context.read<SacrificeCubit>().updateSacrifice(widget.sacrifice.id!, request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sacrifice updated successfully'),
            backgroundColor: AppColors.completed,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating sacrifice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

## 3. Settings Screen

**File: `lib/presentation/screens/settings/settings_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/config/config_cubit.dart';
import '../../../data/models/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _defaultAnimalType = 'cow';
  final Map<String, TextEditingController> _priceControllers = {};
  Color _primaryColor = AppColors.primaryGreen;
  Color _accentColor = AppColors.accentCream;
  int _defaultSacrificeDays = 30;
  
  final List<String> _animalTypes = ['cow', 'goat', 'sheep', 'camel'];
  final List<Color> _availableColors = [
    AppColors.primaryGreen,
    AppColors.darkGreen,
    AppColors.mediumGreen,
    Colors.teal.shade800,
    Colors.green.shade900,
    Colors.blue.shade800,
    Colors.indigo.shade800,
    Colors.purple.shade800,
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize price controllers
    for (String type in _animalTypes) {
      _priceControllers[type] = TextEditingController();
    }
    
    // Load current config
    _loadConfig();
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadConfig() {
    final configState = context.read<ConfigCubit>().state;
    if (configState is ConfigLoaded) {
      final config = configState.config;
      setState(() {
        _defaultAnimalType = config.defaultAnimalType;
        _primaryColor = config.primaryColor;
        _accentColor = config.accentColor;
        _defaultSacrificeDays = config.defaultSacrificeDaysFromNow;
        
        // Set price controllers
        for (String type in _animalTypes) {
          final price = config.defaultPriceByAnimalType[type];
          _priceControllers[type]!.text = price?.toString() ?? '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfig,
          ),
        ],
      ),
      body: BlocListener<ConfigCubit, ConfigState>(
        listener: (context, state) {
          if (state is ConfigLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings saved successfully'),
                backgroundColor: AppColors.completed,
              ),
            );
          } else if (state is ConfigError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving settings: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Default Animal Settings
                _buildSectionHeader('Default Animal Settings'),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _defaultAnimalType,
                  decoration: const InputDecoration(
                    labelText: 'Default Animal Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.agriculture),
                  ),
                  items: _animalTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _defaultAnimalType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                
                // Default Prices
                _buildSectionHeader('Default Prices by Animal Type'),
                const SizedBox(height: 16),
                
                ..._animalTypes.map((type) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _priceControllers[type],
                    decoration: InputDecoration(
                      labelText: '${type.toUpperCase()} Price',
                      hintText: 'Enter default price for $type',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final price = double.tryParse(value);
                        if (price == null || price < 0) {
                          return 'Please enter a valid price';
                        }
                      }
                      return null;
                    },
                  ),
                )),
                
                const SizedBox(height: 8),
                
                // Default Sacrifice Date
                _buildSectionHeader('Default Sacrifice Date'),
                const SizedBox(height: 16),
                
                TextFormField(
                  initialValue: _defaultSacrificeDays.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Days from now',
                    hintText: 'Number of days from today',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixText: 'days',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final days = int.tryParse(value);
                    if (days != null && days >= 0) {
                      setState(() {
                        _defaultSacrificeDays = days;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    final days = int.tryParse(value);
                    if (days == null || days < 0) {
                      return 'Please enter a valid number of days';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Theme Settings
                _buildSectionHeader('Theme Settings'),
                const SizedBox(height: 16),
                
                // Primary Color
                _buildColorSelector(
                  'Primary Color',
                  _primaryColor,
                  (color) => setState(() => _primaryColor = color),
                ),
                const SizedBox(height: 16),
                
                // Accent Color
                _buildColorSelector(
                  'Accent Color',
                  _accentColor,
                  (color) => setState(() => _accentColor = color),
                ),
                const SizedBox(height: 32),
                
                // Preview Section
                _buildSectionHeader('Preview'),
                const SizedBox(height: 16),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _primaryColor,
                              child: const Text(
                                '1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _defaultAnimalType.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    CurrencyUtils.format(
                                      double.tryParse(_priceControllers[_defaultAnimalType]!.text) ?? 0
                                    ),
                                    style: TextStyle(
                                      color: _primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'This is how your theme will look',
                            style: TextStyle(
                              color: _primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                    ),
                    onPressed: _saveConfig,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Save Settings',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Reset Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _resetToDefaults,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Reset to Defaults',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: _primaryColor,
      ),
    );
  }

  Widget _buildColorSelector(String label, Color selectedColor, ValueChanged<Color> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((color) {
            final isSelected = color.value == selectedColor.value;
            return GestureDetector(
              onTap: () => onChanged(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final priceMap = <String, double>{};
    for (String type in _animalTypes) {
      final priceText = _priceControllers[type]!.text;
      if (priceText.isNotEmpty) {
        final price = double.tryParse(priceText);
        if (price != null) {
          priceMap[type] = price;
        }
      }
    }

    final config = AppConfig(
      defaultAnimalType: _defaultAnimalType,
      defaultPriceByAnimalType: priceMap,
      primaryColor: _primaryColor,
      accentColor: _accentColor,
      defaultSacrificeDaysFromNow: _defaultSacrificeDays,
    );

    await context.read<ConfigCubit>().updateConfig(config);
  }

  void _resetToDefaults() {
    setState(() {
      _defaultAnimalType = 'cow';
      _primaryColor = AppColors.primaryGreen;
      _accentColor = AppColors.accentCream;
      _defaultSacrificeDays = 30;
      
      // Reset price controllers to default values
      _priceControllers['cow']!.text = '1000';
      _priceControllers['goat']!.text = '500';
      _priceControllers['sheep']!.text = '600';
      _priceControllers['camel']!.text = '2000';
    });
  }
}
```

## 🚀 Instructions d'Implémentation

### 1. **Créer les dossiers**
```
lib/presentation/screens/
├── sacrifices/
│   ├── add_sacrifice_screen.dart
│   └── edit_sacrifice_screen.dart
└── settings/
    └── settings_screen.dart
```

### 2. **Fonctionnalités Clés**

#### **Add Sacrifice Screen :**
- ✅ Champs validés avec numéro unique, type animal, coût total
- ✅ Calcul automatique du prix par part (total ÷ 7)
- ✅ Sélection de date avec DatePicker
- ✅ Utilisation des valeurs par défaut depuis la configuration
- ✅ Aperçu en temps réel des valeurs

#### **Edit Sacrifice Screen :**
- ✅ Pré-remplissage des valeurs existantes
- ✅ Avertissement si participations existantes
- ✅ Comparaison prix actuel vs nouveau
- ✅ Même interface cohérente

#### **Settings Screen :**
- ✅ Configuration type animal et prix par défaut
- ✅ Paramétrage date par défaut (jours)
- ✅ Sélection couleurs thème (8 options)
- ✅ Aperçu en temps réel des changements
- ✅ Sauvegarde et réinitialisation

### 3. **N'oubliez pas d'importer :**
```dart
// Dans sacrifices_screen.dart, ajoutez les imports :
import 'add_sacrifice_screen.dart';
import 'edit_sacrifice_screen.dart';
```

Voilà ! 🎉 Vos trois écrans manquants sont maintenant prêts à être implémentés avec toutes leurs fonctionnalités complètes !
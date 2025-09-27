// test/helpers/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:kurban_frontend/presentation/cubits/sacrifice/sacrifice_cubit.dart';
import 'package:kurban_frontend/presentation/cubits/participation/participation_cubit.dart';
import 'package:kurban_frontend/presentation/cubits/person/person_cubit.dart';
import 'package:kurban_frontend/presentation/cubits/config/config_cubit.dart';
import 'package:kurban_frontend/data/models/sacrifice.dart';
import 'package:kurban_frontend/data/models/person.dart';
import 'package:kurban_frontend/data/models/participation.dart';
import 'package:kurban_frontend/data/models/app_config.dart';
import 'package:kurban_frontend/data/repositories/sacrifice_repository.dart';
import 'package:kurban_frontend/data/repositories/participation_repository.dart';
import 'package:kurban_frontend/data/repositories/person_repository.dart';
import 'package:kurban_frontend/data/repositories/config_repository.dart';

// Mock Cubits
class MockSacrificeCubit extends Mock implements SacrificeCubit {}
class MockParticipationCubit extends Mock implements ParticipationCubit {}
class MockPersonCubit extends Mock implements PersonCubit {}
class MockConfigCubit extends Mock implements ConfigCubit {}

// Mock Repositories
class MockSacrificeRepository extends Mock implements SacrificeRepository {}
class MockParticipationRepository extends Mock implements ParticipationRepository {}
class MockPersonRepository extends Mock implements PersonRepository {}
class MockConfigRepository extends Mock implements ConfigRepository {}

/// Test data factory for creating consistent test objects
class TestDataFactory {
  
  static Sacrifice createTestSacrifice({
    int id = 1,
    int sacrificeNumber = 1,
    String animalType = 'cow',
    double totalCost = 1000.0,
    String status = 'pending',
    int availableShares = 5,
  }) {
    return Sacrifice(
      id: id,
      sacrificeNumber: sacrificeNumber,
      animalType: animalType,
      totalCost: totalCost,
      sharePrice: totalCost / 7, // Standard 7 shares
      status: status,
      sacrificeDate: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
    );
  }

  static Person createTestPerson({
    int id = 1,
    String firstName = 'Ahmed',
    String lastName = 'Hassan',
    String phone = '+123456789',
    String email = 'ahmed@example.com',
  }) {
    return Person(
      id: id,
      firstname: firstName,
      lastname: lastName,
      phone: phone,
      email: email,
      createdAt: DateTime.now(),
    );
  }

  static Participation createTestParticipation({
    int id = 1,
    int shareCount = 2,
    double? shareAmount,
    bool paid = false,
    int personId = 1,
    String personName = 'Ahmed Hassan',
    int sacrificeId = 1,
    int sacrificeNumber = 1,
  }) {
    return Participation(
      id: id,
      shareCount: shareCount,
      shareAmount: shareAmount ?? (shareCount * 142.86), // Default calculation
      paid: paid,
      personId: personId,
      personName: personName,
      sacrificeId: sacrificeId,
      sacrificeNumber: sacrificeNumber,
      createdAt: DateTime.now(),
    );
  }

  static ParticipationCreateRequest createTestParticipationRequest({
    int personId = 1,
    int sacrificeId = 1,
    int shareCount = 2,
    double? shareAmount,
    String? notes,
  }) {
    return ParticipationCreateRequest(
      personId: personId,
      sacrificeId: sacrificeId,
      shareCount: shareCount,
      shareAmount: shareAmount ?? (shareCount * 142.86).toDouble(),
      notes: notes,
    );
  }

  static AppConfig createTestConfig({
    String defaultAnimalType = 'cow',
    Map<String, double>? defaultPriceByAnimalType,
    Color primaryColor = const Color(0xFF1B4332),
    Color accentColor = const Color(0xFFFFFDD0),
  }) {
    return AppConfig(
      defaultAnimalType: defaultAnimalType,
      defaultPriceByAnimalType: defaultPriceByAnimalType ?? const {
        'cow': 1000.0,
        'goat': 500.0,
        'sheep': 600.0,
      },
      primaryColor: primaryColor,
      accentColor: accentColor,
    );
  }
}

/// Helper class for setting up test environment
class TestSetup {
  static late MockSacrificeCubit mockSacrificeCubit;
  static late MockParticipationCubit mockParticipationCubit;
  static late MockPersonCubit mockPersonCubit;
  static late MockConfigCubit mockConfigCubit;

  /// Initialize all mocks and register fallback values
  static void initializeMocks() {
    mockSacrificeCubit = MockSacrificeCubit();
    mockParticipationCubit = MockParticipationCubit();
    mockPersonCubit = MockPersonCubit();
    mockConfigCubit = MockConfigCubit();

    // Register fallback values for complex objects
    registerFallbackValue(TestDataFactory.createTestParticipationRequest());
    registerFallbackValue(TestDataFactory.createTestSacrifice());
  }

  /// Register mocks in GetIt
  static void registerMocksInGetIt() {
    GetIt.instance.reset();
    
    GetIt.instance.registerFactory<SacrificeCubit>(() => mockSacrificeCubit);
    GetIt.instance.registerFactory<ParticipationCubit>(() => mockParticipationCubit);
    GetIt.instance.registerFactory<PersonCubit>(() => mockPersonCubit);
    GetIt.instance.registerLazySingleton<ConfigCubit>(() => mockConfigCubit);
  }

  /// Set up default mock behaviors for successful operations
  static void setUpDefaultMockBehaviors() {
    // Sacrifice Cubit defaults
    when(() => mockSacrificeCubit.state).thenReturn(SacrificeInitial());
    when(() => mockSacrificeCubit.loadSacrificeById(any())).thenAnswer((_) async {});
    when(() => mockSacrificeCubit.loadSacrifices()).thenAnswer((_) async {});

    // Participation Cubit defaults
    when(() => mockParticipationCubit.state).thenReturn(ParticipationInitial());
    when(() => mockParticipationCubit.loadParticipationsBySacrifice(any())).thenAnswer((_) async {});
    when(() => mockParticipationCubit.createParticipation(any())).thenAnswer((_) async {});

    // Person Cubit defaults
    when(() => mockPersonCubit.state).thenReturn(PersonInitial());
    when(() => mockPersonCubit.loadPersons()).thenAnswer((_) async {});

    // Config Cubit defaults
    when(() => mockConfigCubit.state).thenReturn(ConfigLoaded(TestDataFactory.createTestConfig()));
    when(() => mockConfigCubit.loadConfig()).thenAnswer((_) async {});
  }

  /// Complete setup for tests - call this in setUp()
  static void setUp() {
    initializeMocks();
    registerMocksInGetIt();
    setUpDefaultMockBehaviors();
  }

  /// Cleanup for tests - call this in tearDown()
  static void tearDown() {
    GetIt.instance.reset();
  }
}

/// Custom matchers for testing
class ShareAmountMatchers {
  /// Matcher to verify shareAmount is a proper double type
  static Matcher isValidShareAmount(double expectedValue) {
    return predicate<ParticipationCreateRequest>((request) =>
      request.shareAmount != null &&
      request.shareAmount is double &&
      (request.shareAmount! - expectedValue).abs() < 0.01
    );
  }

  /// Matcher to verify shareAmount calculation is correct
  static Matcher hasCorrectShareAmount(int shareCount, double sharePrice) {
    final expectedAmount = (shareCount * sharePrice).toDouble();
    return predicate<ParticipationCreateRequest>((request) =>
      request.shareAmount != null &&
      request.shareAmount is double &&
      (request.shareAmount! - expectedAmount).abs() < 0.01
    );
  }
}

/// Widget test helpers
class WidgetTestHelpers {
  /// Create a basic Material app wrapper for widget testing
  static Widget createTestApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  /// Create app with bloc providers for integration testing
  static Widget createTestAppWithBlocs(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SacrificeCubit>.value(value: TestSetup.mockSacrificeCubit),
        BlocProvider<ParticipationCubit>.value(value: TestSetup.mockParticipationCubit),
        BlocProvider<PersonCubit>.value(value: TestSetup.mockPersonCubit),
        BlocProvider<ConfigCubit>.value(value: TestSetup.mockConfigCubit),
      ],
      child: MaterialApp(home: child),
    );
  }
}

/// Calculation test helpers specifically for the shareAmount fix
class CalculationTestHelpers {
  /// Test the exact calculation logic from _submitParticipation
  static double calculateShareAmount(int shareCount, double? sharePrice) {
    return (shareCount * (sharePrice ?? 0)).toDouble();
  }

  /// Verify calculation returns proper double type
  static bool isCalculationResultValid(int shareCount, double? sharePrice) {
    final result = calculateShareAmount(shareCount, sharePrice);
    return result is double;
  }

  /// Test various edge cases for calculation
  static Map<String, dynamic> testCalculationEdgeCases() {
    return {
      'normal_case': calculateShareAmount(3, 142.86),
      'null_price': calculateShareAmount(3, null),
      'zero_price': calculateShareAmount(3, 0.0),
      'zero_shares': calculateShareAmount(0, 142.86),
      'large_numbers': calculateShareAmount(7, 999999.99),
      'small_numbers': calculateShareAmount(1, 0.01),
    };
  }
}
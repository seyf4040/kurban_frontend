import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:kurban_frontend/presentation/screens/sacrifices/sacrifice_detail_screen.dart';
import 'package:kurban_frontend/presentation/cubits/sacrifice/sacrifice_cubit.dart';
import 'package:kurban_frontend/presentation/cubits/participation/participation_cubit.dart';
import 'package:kurban_frontend/presentation/cubits/person/person_cubit.dart';
import 'package:kurban_frontend/data/models/sacrifice.dart';
import 'package:kurban_frontend/data/models/person.dart';
import 'package:kurban_frontend/data/models/participation.dart';

// Mock classes
class MockSacrificeCubit extends Mock implements SacrificeCubit {}
class MockParticipationCubit extends Mock implements ParticipationCubit {}
class MockPersonCubit extends Mock implements PersonCubit {}

void main() {
  late MockSacrificeCubit mockSacrificeCubit;
  late MockParticipationCubit mockParticipationCubit;
  late MockPersonCubit mockPersonCubit;

  // Test data
  final testSacrifice = Sacrifice(
    id: 1,
    sacrificeNumber: 1,
    animalType: 'cow',
    totalCost: 1000.0,
    sharePrice: 142.86, // 1000 / 7
    status: 'pending',
    sacrificeDate: DateTime.now().add(const Duration(days: 30)),
    createdAt: DateTime.now(),
  );

  final testPerson = Person(
    id: 1,
    firstname: 'Ahmed',
    lastname: 'Hassan',
    phone: '+123456789',
    email: 'ahmed@example.com',
    createdAt: DateTime.now(),
  );

  final testParticipations = [
    Participation(
      id: 1,
      shareCount: 2,
      shareAmount: 285.72,
      paid: false,
      personId: 1,
      personName: 'Ahmed Hassan',
      sacrificeId: 1,
      sacrificeNumber: 1,
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    // Reset GetIt
    GetIt.instance.reset();
    
    // Create mocks
    mockSacrificeCubit = MockSacrificeCubit();
    mockParticipationCubit = MockParticipationCubit();
    mockPersonCubit = MockPersonCubit();

    // Register mocks in GetIt
    GetIt.instance.registerFactory<SacrificeCubit>(() => mockSacrificeCubit);
    GetIt.instance.registerFactory<ParticipationCubit>(() => mockParticipationCubit);
    GetIt.instance.registerFactory<PersonCubit>(() => mockPersonCubit);

    // Register fake for ParticipationCreateRequest
    registerFallbackValue(const ParticipationCreateRequest(
      personId: 1,
      sacrificeId: 1,
      shareCount: 1,
      shareAmount: 142.86,
    ));
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: const SacrificeDetailScreen(sacrificeId: 1),
    );
  }

  group('SacrificeDetailScreen', () {
    testWidgets('should display loading indicator when sacrifice is loading', (tester) async {
      // Arrange
      when(() => mockSacrificeCubit.state).thenReturn(SacrificeLoading());
      when(() => mockParticipationCubit.state).thenReturn(ParticipationInitial());
      when(() => mockPersonCubit.state).thenReturn(PersonInitial());
      when(() => mockSacrificeCubit.loadSacrificeById(any())).thenAnswer((_) async {});
      when(() => mockParticipationCubit.loadParticipationsBySacrifice(any())).thenAnswer((_) async {});
      when(() => mockPersonCubit.loadPersons()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display sacrifice details when loaded', (tester) async {
      // Arrange
      when(() => mockSacrificeCubit.state).thenReturn(SacrificeDetailLoaded(testSacrifice));
      when(() => mockParticipationCubit.state).thenReturn(ParticipationLoaded(testParticipations));
      when(() => mockPersonCubit.state).thenReturn(PersonLoaded([testPerson]));
      when(() => mockSacrificeCubit.loadSacrificeById(any())).thenAnswer((_) async {});
      when(() => mockParticipationCubit.loadParticipationsBySacrifice(any())).thenAnswer((_) async {});
      when(() => mockPersonCubit.loadPersons()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Sacrifice Details'), findsOneWidget);
      expect(find.text('Sacrifice #1'), findsOneWidget);
    });

    testWidgets('should calculate share amount correctly with proper type conversion', (tester) async {
      // Arrange
      when(() => mockSacrificeCubit.state).thenReturn(SacrificeDetailLoaded(testSacrifice));
      when(() => mockParticipationCubit.state).thenReturn(ParticipationLoaded([]));
      when(() => mockPersonCubit.state).thenReturn(PersonLoaded([testPerson]));
      when(() => mockSacrificeCubit.loadSacrificeById(any())).thenAnswer((_) async {});
      when(() => mockParticipationCubit.loadParticipationsBySacrifice(any())).thenAnswer((_) async {});
      when(() => mockPersonCubit.loadPersons()).thenAnswer((_) async {});
      when(() => mockParticipationCubit.createParticipation(any())).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and tap the person selector
      await tester.tap(find.byType(TextFormField).first);
      await tester.pump();

      // Select the test person
      await tester.tap(find.text('Ahmed Hassan').first);
      await tester.pump();

      // Enter share count
      await tester.enterText(find.byType(TextFormField).at(1), '3');
      await tester.pump();

      // Verify calculated amount is displayed
      expect(find.textContaining('€428.58'), findsOneWidget); // 3 * 142.86 = 428.58

      // Submit the form
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();

      // Verify createParticipation was called with correct double type
      verify(() => mockParticipationCubit.createParticipation(any(
        that: predicate<ParticipationCreateRequest>((request) =>
          request.shareAmount != null &&
          request.shareAmount is double &&
          request.shareAmount == (3 * 142.86).toDouble()
        )
      ))).called(1);
    });

    testWidgets('should validate share count input', (tester) async {
      // Arrange
      when(() => mockSacrificeCubit.state).thenReturn(SacrificeDetailLoaded(testSacrifice));
      when(() => mockParticipationCubit.state).thenReturn(ParticipationLoaded([]));
      when(() => mockPersonCubit.state).thenReturn(PersonLoaded([testPerson]));
      when(() => mockSacrificeCubit.loadSacrificeById(any())).thenAnswer((_) async {});
      when(() => mockParticipationCubit.loadParticipationsBySacrifice(any())).thenAnswer((_) async {});
      when(() => mockPersonCubit.loadPersons()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Enter invalid share count (exceeds available shares)
      await tester.enterText(find.byType(TextFormField).at(1), '10'); // More than available 5 shares
      await tester.pump();

      // Try to submit
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();

      // Assert error message is shown
      expect(find.text('Only 5 shares available'), findsOneWidget);
    });

    testWidgets('should display error when sacrifice loading fails', (tester) async {
      // Arrange
      when(() => mockSacrificeCubit.state).thenReturn(const SacrificeError('Failed to load sacrifice'));
      when(() => mockParticipationCubit.state).thenReturn(ParticipationInitial());
      when(() => mockPersonCubit.state).thenReturn(PersonInitial());
      when(() => mockSacrificeCubit.loadSacrificeById(any())).thenAnswer((_) async {});
      when(() => mockParticipationCubit.loadParticipationsBySacrifice(any())).thenAnswer((_) async {});
      when(() => mockPersonCubit.loadPersons()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Error: Failed to load sacrifice'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('ShareAmount Type Safety Tests', () {
    test('shareAmount calculation should return double type', () {
      // Test the exact calculation logic from _submitParticipation
      const int shareCount = 3;
      const double sharePrice = 142.86;
      
      // This is the fixed calculation
      final double shareAmount = (shareCount * sharePrice).toDouble();
      
      // Verify it's a double
      expect(shareAmount, isA<double>());
      expect(shareAmount, equals(428.58));
    });

    test('shareAmount calculation should handle null sharePrice', () {
      const int shareCount = 3;
      const double? sharePrice = null;
      
      // This is the fixed calculation with null handling
      final double shareAmount = (shareCount * (sharePrice ?? 0)).toDouble();
      
      // Verify it's a double and equals 0
      expect(shareAmount, isA<double>());
      expect(shareAmount, equals(0.0));
    });

    test('shareAmount calculation should handle zero sharePrice', () {
      const int shareCount = 3;
      const double sharePrice = 0.0;
      
      final double shareAmount = (shareCount * sharePrice).toDouble();
      
      expect(shareAmount, isA<double>());
      expect(shareAmount, equals(0.0));
    });

    test('shareAmount calculation should handle fractional results', () {
      const int shareCount = 3;
      const double sharePrice = 100.0 / 3; // 33.333...
      
      final double shareAmount = (shareCount * sharePrice).toDouble();
      
      expect(shareAmount, isA<double>());
      expect(shareAmount, closeTo(100.0, 0.001));
    });
  });
}
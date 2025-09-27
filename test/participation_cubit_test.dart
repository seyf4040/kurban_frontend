import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kurban_frontend/presentation/cubits/participation/participation_cubit.dart';
import 'package:kurban_frontend/data/repositories/participation_repository.dart';
import 'package:kurban_frontend/data/models/participation.dart';

// Import test helpers if in separate file
// import '../helpers/test_helpers.dart';

class MockParticipationRepository extends Mock implements ParticipationRepository {}

void main() {
  late ParticipationCubit cubit;
  late MockParticipationRepository mockRepository;

  setUp(() {
    mockRepository = MockParticipationRepository();
    cubit = ParticipationCubit(mockRepository);

    // Register fallback value for ParticipationCreateRequest
    registerFallbackValue(const ParticipationCreateRequest(
      personId: 1,
      sacrificeId: 1,
      shareCount: 1,
      shareAmount: 142.86,
    ));
  });

  tearDown(() {
    cubit.close();
  });

  group('ParticipationCubit', () {
    group('loadParticipationsBySacrifice', () {
      test('should emit ParticipationLoaded when successful', () async {
        // Arrange
        final participations = [
          Participation(
            id: 1,
            shareCount: 3,
            shareAmount: 428.58, // Proper double type
            paid: false,
            personId: 1,
            personName: 'Ahmed Hassan',
            sacrificeId: 1,
            sacrificeNumber: 1,
            createdAt: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getParticipationsBySacrifice(any()))
            .thenAnswer((_) async => participations);

        // Act
        final future = cubit.stream;
        cubit.loadParticipationsBySacrifice(1);

        // Assert
        await expectLater(
          future,
          emitsInOrder([
            ParticipationLoading(),
            ParticipationLoaded(participations),
          ]),
        );

        verify(() => mockRepository.getParticipationsBySacrifice(1)).called(1);
      });

      test('should emit ParticipationError when repository throws', () async {
        // Arrange
        when(() => mockRepository.getParticipationsBySacrifice(any()))
            .thenThrow(Exception('Failed to load participations'));

        // Act
        final future = cubit.stream;
        cubit.loadParticipationsBySacrifice(1);

        // Assert
        await expectLater(
          future,
          emitsInOrder([
            ParticipationLoading(),
            const ParticipationError('Exception: Failed to load participations'),
          ]),
        );
      });
    });

    group('createParticipation', () {
      test('should create participation with proper double shareAmount', () async {
        // Arrange
        const request = ParticipationCreateRequest(
          personId: 1,
          sacrificeId: 1,
          shareCount: 3,
          shareAmount: 428.58, // Proper double type
          notes: 'Test notes',
        );

        final participations = [
          Participation(
            id: 1,
            shareCount: 3,
            shareAmount: 428.58,
            paid: false,
            personId: 1,
            personName: 'Ahmed Hassan',
            sacrificeId: 1,
            sacrificeNumber: 1,
            createdAt: DateTime.now(),
          ),
        ];

        when(() => mockRepository.createParticipation(any()))
            .thenAnswer((_) async => Participation(
              id: 1,
              shareCount: 3,
              shareAmount: 428.58,
              paid: false,
              personId: 1,
              personName: 'Ahmed Hassan',
              sacrificeId: 1,
              sacrificeNumber: 1,
              createdAt: DateTime.now(),
            ));
        when(() => mockRepository.getParticipationsBySacrifice(any()))
            .thenAnswer((_) async => participations);

        // Act
        final future = cubit.stream;
        await cubit.createParticipation(request);

        // Assert
        await expectLater(
          future,
          emitsInOrder([
            ParticipationLoading(),
            ParticipationLoaded(participations),
          ]),
        );

        verify(() => mockRepository.createParticipation(request)).called(1);
        verify(() => mockRepository.getParticipationsBySacrifice(1)).called(1);
      });

      test('should verify shareAmount type safety in createParticipation', () async {
        // Arrange
        const request = ParticipationCreateRequest(
          personId: 1,
          sacrificeId: 1,
          shareCount: 3,
          shareAmount: 428.58,
        );

        when(() => mockRepository.createParticipation(any()))
            .thenAnswer((_) async => Participation(
              id: 0,
              shareCount: 0,
              shareAmount: 0.0,
              paid: false,
              personId: 0,
              personName: '',
              sacrificeId: 0,
              sacrificeNumber: 0,
              createdAt: DateTime.now(),
            ));
        when(() => mockRepository.getParticipationsBySacrifice(any()))
            .thenAnswer((_) async => []);

        // Act
        await cubit.createParticipation(request);

        // Assert - Verify the request passed to repository has correct type
        final capturedRequest = verify(() => mockRepository.createParticipation(captureAny()))
            .captured.first as ParticipationCreateRequest;
        
        expect(capturedRequest.shareAmount, isA<double>());
        expect(capturedRequest.shareAmount, equals(428.58));
      });

      test('should handle null shareAmount correctly', () async {
        // Arrange
        const request = ParticipationCreateRequest(
          personId: 1,
          sacrificeId: 1,
          shareCount: 3,
          shareAmount: null, // Null shareAmount should be allowed
        );

        when(() => mockRepository.createParticipation(any()))
            .thenAnswer((_) async => Participation(
              id: 0,
              shareCount: 0,
              shareAmount: 0.0,
              paid: false,
              personId: 0,
              personName: '',
              sacrificeId: 0,
              sacrificeNumber: 0,
              createdAt: DateTime.now(),
            ));
        when(() => mockRepository.getParticipationsBySacrifice(any()))
            .thenAnswer((_) async => []);

        // Act
        await cubit.createParticipation(request);

        // Assert
        final capturedRequest = verify(() => mockRepository.createParticipation(captureAny()))
            .captured.first as ParticipationCreateRequest;
        
        expect(capturedRequest.shareAmount, isNull);
      });

      test('should emit ParticipationError when create fails', () async {
        // Arrange
        const request = ParticipationCreateRequest(
          personId: 1,
          sacrificeId: 1,
          shareCount: 3,
          shareAmount: 428.58,
        );

        when(() => mockRepository.createParticipation(any()))
            .thenThrow(Exception('Failed to create participation'));

        // Act
        final future = cubit.stream;
        cubit.createParticipation(request);

        // Assert
        await expectLater(
          future,
          emits(const ParticipationError('Exception: Failed to create participation')),
        );
      });
    });

    group('updateParticipation', () {
      test('should update participation with proper shareAmount type', () async {
        // Arrange
        const request = ParticipationCreateRequest(
          personId: 1,
          sacrificeId: 1,
          shareCount: 4,
          shareAmount: 571.44, // 4 * 142.86
        );

        when(() => mockRepository.updateParticipation(any(), any()))
            .thenAnswer((_) async => Participation(
              id: 0,
              shareCount: 0,
              shareAmount: 0.0,
              paid: false,
              personId: 0,
              personName: '',
              sacrificeId: 0,
              sacrificeNumber: 0,
              createdAt: DateTime.now(),
            ));
        when(() => mockRepository.getParticipationsBySacrifice(any()))
            .thenAnswer((_) async => []);

        // Act
        await cubit.updateParticipation(1, request);

        // Assert
        final capturedRequest = verify(() => mockRepository.updateParticipation(1, captureAny()))
            .captured.first as ParticipationCreateRequest;
        
        expect(capturedRequest.shareAmount, isA<double>());
        expect(capturedRequest.shareAmount, equals(571.44));
      });
    });

    group('markAsPaid', () {
      test('should mark participation as paid with correct amount type', () async {
        // Arrange
        const id = 1;
        const amount = 428.58;
        const sacrificeId = 1;

        when(() => mockRepository.markParticipationPaid(any(), any()))
            .thenAnswer((_) async => Participation(
              id: 0,
              shareCount: 0,
              shareAmount: 0.0,
              paid: false,
              personId: 0,
              personName: '',
              sacrificeId: 0,
              sacrificeNumber: 0,
              createdAt: DateTime.now(),
            ));
        when(() => mockRepository.getParticipationsBySacrifice(any()))
            .thenAnswer((_) async => []);

        // Act
        await cubit.markAsPaid(id, amount, sacrificeId);

        // Assert
        final capturedAmount = verify(() => mockRepository.markParticipationPaid(id, captureAny()))
            .captured.first as double;
        
        expect(capturedAmount, isA<double>());
        expect(capturedAmount, equals(amount));
      });
    });

    group('deleteParticipation', () {
      test('should delete participation and reload list', () async {
        // Arrange
        when(() => mockRepository.deleteParticipation(any()))
            .thenAnswer((_) async => Participation(
              id: 0,
              shareCount: 0,
              shareAmount: 0.0,
              paid: false,
              personId: 0,
              personName: '',
              sacrificeId: 0,
              sacrificeNumber: 0,
              createdAt: DateTime.now(),
            ));
        when(() => mockRepository.getParticipationsBySacrifice(any()))
            .thenAnswer((_) async => []);

        // Act
        final future = cubit.stream;
        await cubit.deleteParticipation(1, 1);

        // Assert
        await expectLater(
          future,
          emitsInOrder([
            ParticipationLoading(),
            const ParticipationLoaded([]),
          ]),
        );

        verify(() => mockRepository.deleteParticipation(1)).called(1);
        verify(() => mockRepository.getParticipationsBySacrifice(1)).called(1);
      });
    });
  });

  group('Type Safety Integration Tests for ParticipationCubit', () {
    test('should maintain type consistency through complete workflow', () async {
      // Simulate the complete workflow that was causing the type error
      
      // 1. Calculate shareAmount (the fix we implemented)
      const int shareCount = 3;
      const double sharePrice = 142.86;
      final double calculatedAmount = (shareCount * sharePrice).toDouble();
      
      // 2. Create request
      final request = ParticipationCreateRequest(
        personId: 1,
        sacrificeId: 1,
        shareCount: shareCount,
        shareAmount: calculatedAmount,
      );
      
      // 3. Mock repository response
      final createdParticipation = Participation(
        id: 1,
        shareCount: shareCount,
        shareAmount: calculatedAmount,
        paid: false,
        personId: 1,
        personName: 'Ahmed Hassan',
        sacrificeId: 1,
        sacrificeNumber: 1,
        createdAt: DateTime.now(),
      );

      when(() => mockRepository.createParticipation(any()))
          .thenAnswer((_) async => createdParticipation);
      when(() => mockRepository.getParticipationsBySacrifice(any()))
          .thenAnswer((_) async => [createdParticipation]);

      // 4. Execute through cubit
      await cubit.createParticipation(request);

      // 5. Verify types are maintained throughout
      final capturedRequest = verify(() => mockRepository.createParticipation(captureAny()))
          .captured.first as ParticipationCreateRequest;
      
      expect(calculatedAmount, isA<double>());
      expect(request.shareAmount, isA<double>());
      expect(capturedRequest.shareAmount, isA<double>());
      expect(createdParticipation.shareAmount, isA<double>());
      
      // Verify values are correct
      expect(capturedRequest.shareAmount, equals(calculatedAmount));
    });

    test('should handle various calculation edge cases', () async {
      // Test multiple calculation scenarios
      final testCases = [
        {'shareCount': 1, 'sharePrice': 142.86, 'expected': 142.86},
        {'shareCount': 7, 'sharePrice': 100.0, 'expected': 700.0},
        {'shareCount': 3, 'sharePrice': 0.0, 'expected': 0.0},
        {'shareCount': 0, 'sharePrice': 142.86, 'expected': 0.0},
      ];

      when(() => mockRepository.createParticipation(any()))
          .thenAnswer((_) async => Participation(
            id: 0,
            shareCount: 0,
            shareAmount: 0.0,
            paid: false,
            personId: 0,
            personName: '',
            sacrificeId: 0,
            sacrificeNumber: 0,
            createdAt: DateTime.now(),
          ));
      when(() => mockRepository.getParticipationsBySacrifice(any()))
          .thenAnswer((_) async => []);

      for (final testCase in testCases) {
        final shareCount = testCase['shareCount'] as int;
        final sharePrice = testCase['sharePrice'] as double;
        final expected = testCase['expected'] as double;
        
        // Calculate using our fixed logic
        final calculatedAmount = (shareCount * sharePrice).toDouble();
        
        final request = ParticipationCreateRequest(
          personId: 1,
          sacrificeId: 1,
          shareCount: shareCount,
          shareAmount: calculatedAmount,
        );

        await cubit.createParticipation(request);

        expect(calculatedAmount, isA<double>());
        expect(calculatedAmount, equals(expected));
      }
    });
  });
}
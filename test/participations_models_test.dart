import 'package:flutter_test/flutter_test.dart';
import 'package:kurban_frontend/data/models/participation.dart';

void main() {
  group('Participation Model Tests', () {
    group('Participation', () {
      test('should create Participation with all fields', () {
        final participation = Participation(
          id: 1,
          shareCount: 3,
          shareAmount: 428.58,
          paid: true,
          paymentDate: DateTime(2024, 1, 15),
          notes: 'Test notes',
          createdAt: DateTime(2024, 1, 1),
          personId: 1,
          personName: 'Ahmed Hassan',
          sacrificeId: 1,
          sacrificeNumber: 1,
        );

        expect(participation.id, equals(1));
        expect(participation.shareCount, equals(3));
        expect(participation.shareAmount, equals(428.58));
        expect(participation.shareAmount, isA<double>());
        expect(participation.paid, isTrue);
        expect(participation.personName, equals('Ahmed Hassan'));
      });

      test('should create Participation with minimal required fields', () {
        const participation = Participation(
          shareCount: 2,
        );

        expect(participation.shareCount, equals(2));
        expect(participation.shareAmount, isNull);
        expect(participation.paid, isFalse);
        expect(participation.id, isNull);
      });

      test('should create Participation from JSON with type conversion', () {
        final json = {
          'id': 1,
          'shareCount': 3,
          'shareAmount': 428, // int in JSON, should be converted to double
          'paid': true,
          'paymentDate': '2024-01-15T10:30:00Z',
          'notes': 'Test notes',
          'createdAt': '2024-01-01T00:00:00Z',
          'personId': 1,
          'personName': 'Ahmed Hassan',
          'sacrificeId': 1,
          'sacrificeNumber': 1,
        };

        final participation = Participation.fromJson(json);

        expect(participation.shareAmount, equals(428.0));
        expect(participation.shareAmount, isA<double>());
        expect(participation.shareCount, equals(3));
        expect(participation.paid, isTrue);
      });

      test('should handle null shareAmount in JSON', () {
        final json = {
          'shareCount': 2,
          'shareAmount': null,
          'paid': false,
        };

        final participation = Participation.fromJson(json);

        expect(participation.shareAmount, isNull);
        expect(participation.shareCount, equals(2));
        expect(participation.paid, isFalse);
      });

      test('should convert to JSON correctly', () {
        const participation = Participation(
          id: 1,
          shareCount: 3,
          shareAmount: 428.58,
          paid: true,
          notes: 'Test notes',
          personId: 1,
          sacrificeId: 1,
        );

        final json = participation.toJson();

        expect(json['shareAmount'], equals(428.58));
        expect(json['shareAmount'], isA<double>());
        expect(json['shareCount'], equals(3));
        expect(json['paid'], isTrue);
      });

      test('should create copy with updated shareAmount', () {
        const original = Participation(
          shareCount: 2,
          shareAmount: 200.0,
        );

        final updated = original.copyWith(shareAmount: 300.5);

        expect(updated.shareAmount, equals(300.5));
        expect(updated.shareAmount, isA<double>());
        expect(updated.shareCount, equals(2)); // Should remain unchanged
      });
    });

    group('ParticipationSummary', () {
      test('should create ParticipationSummary with shareAmount as double', () {
        const summary = ParticipationSummary(
          personName: 'Ahmed Hassan',
          shareCount: 3,
          shareAmount: 428.58,
          paid: true,
        );

        expect(summary.shareAmount, equals(428.58));
        expect(summary.shareAmount, isA<double>());
        expect(summary.shareCount, equals(3));
        expect(summary.personName, equals('Ahmed Hassan'));
      });

      test('should create ParticipationSummary from JSON with type conversion', () {
        final json = {
          'id': 1,
          'personName': 'Ahmed Hassan',
          'shareCount': 3,
          'shareAmount': 428, // int should be converted to double
          'paid': true,
        };

        final summary = ParticipationSummary.fromJson(json);

        expect(summary.shareAmount, equals(428.0));
        expect(summary.shareAmount, isA<double>());
      });

      test('should handle null shareAmount in ParticipationSummary JSON', () {
        final json = {
          'personName': 'Ahmed Hassan',
          'shareCount': 2,
          'shareAmount': null,
          'paid': false,
        };

        final summary = ParticipationSummary.fromJson(json);

        expect(summary.shareAmount, isNull);
        expect(summary.shareCount, equals(2));
      });
    });

    group('ParticipationCreateRequest', () {
      test('should create ParticipationCreateRequest with shareAmount as double', () {
        const request = ParticipationCreateRequest(
          personId: 1,
          sacrificeId: 1,
          shareCount: 3,
          shareAmount: 428.58,
          notes: 'Test notes',
        );

        expect(request.shareAmount, equals(428.58));
        expect(request.shareAmount, isA<double>());
        expect(request.shareCount, equals(3));
        expect(request.personId, equals(1));
        expect(request.sacrificeId, equals(1));
        expect(request.notes, equals('Test notes'));
      });

      test('should create ParticipationCreateRequest with null shareAmount', () {
        const request = ParticipationCreateRequest(
          personId: 1,
          sacrificeId: 1,
          shareCount: 2,
          shareAmount: null,
        );

        expect(request.shareAmount, isNull);
        expect(request.shareCount, equals(2));
      });

      test('should create ParticipationCreateRequest with default values', () {
        const request = ParticipationCreateRequest(
          personId: 1,
          sacrificeId: 1,
        );

        expect(request.shareCount, equals(1)); // Default value
        expect(request.shareAmount, isNull);
        expect(request.notes, isNull);
      });

      test('should convert to JSON correctly maintaining double type', () {
        const request = ParticipationCreateRequest(
          personId: 1,
          sacrificeId: 1,
          shareCount: 3,
          shareAmount: 428.58,
          notes: 'Test notes',
        );

        final json = request.toJson();

        expect(json['shareAmount'], equals(428.58));
        expect(json['shareAmount'], isA<double>());
        expect(json['shareCount'], equals(3));
        expect(json['personId'], equals(1));
        expect(json['sacrificeId'], equals(1));
        expect(json['notes'], equals('Test notes'));
      });

      test('should handle null shareAmount in toJson', () {
        const request = ParticipationCreateRequest(
          personId: 1,
          sacrificeId: 1,
          shareCount: 2,
          shareAmount: null,
        );

        final json = request.toJson();

        expect(json['shareAmount'], isNull);
        expect(json['shareCount'], equals(2));
      });
    });
  });

  group('Type Safety Integration Tests', () {
    test('should maintain type consistency through full workflow', () {
      // Simulate the workflow: calculation -> create request -> JSON -> back to model
      
      // 1. Calculate shareAmount (this is the fix we implemented)
      const int shareCount = 3;
      const double sharePrice = 142.86;
      final double calculatedAmount = (shareCount * sharePrice).toDouble();
      
      // 2. Create request with calculated amount
      final request = ParticipationCreateRequest(
        personId: 1,
        sacrificeId: 1,
        shareCount: shareCount,
        shareAmount: calculatedAmount,
      );
      
      // 3. Convert to JSON (as would happen in API call)
      final json = request.toJson();
      
      // 4. Simulate response and create Participation from JSON
      final responseJson = {
        ...json,
        'id': 1,
        'personName': 'Ahmed Hassan',
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final participation = Participation.fromJson(responseJson);
      
      // Verify type consistency throughout
      expect(calculatedAmount, isA<double>());
      expect(request.shareAmount, isA<double>());
      expect(json['shareAmount'], isA<double>());
      expect(participation.shareAmount, isA<double>());
      
      // Verify values are preserved
      expect(participation.shareAmount, equals(calculatedAmount));
      expect(participation.shareCount, equals(shareCount));
    });

    test('should handle edge case calculations correctly', () {
      // Test various calculation scenarios that could cause type issues
      
      // Scenario 1: Large numbers
      const int shareCount1 = 7;
      const double sharePrice1 = 999999.99;
      final double result1 = (shareCount1 * sharePrice1).toDouble();
      expect(result1, isA<double>());
      
      // Scenario 2: Small fractional numbers
      const int shareCount2 = 1;
      const double sharePrice2 = 0.01;
      final double result2 = (shareCount2 * sharePrice2).toDouble();
      expect(result2, isA<double>());
      expect(result2, equals(0.01));
      
      // Scenario 3: Zero values
      const int shareCount3 = 0;
      const double sharePrice3 = 100.0;
      final double result3 = (shareCount3 * sharePrice3).toDouble();
      expect(result3, isA<double>());
      expect(result3, equals(0.0));
    });
  });
}
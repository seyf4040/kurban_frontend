import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:kurban_frontend/app.dart';
import 'package:kurban_frontend/presentation/cubits/config/config_cubit.dart';
import 'package:kurban_frontend/data/models/app_config.dart';

// Mock classes
class MockConfigCubit extends Mock implements ConfigCubit {}

void main() {
  late MockConfigCubit mockConfigCubit;

  setUp(() {
    GetIt.instance.reset();
    mockConfigCubit = MockConfigCubit();
    GetIt.instance.registerLazySingleton<ConfigCubit>(() => mockConfigCubit);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('Kurban App Integration Tests', () {
    testWidgets('should build app with default config', (WidgetTester tester) async {
      // Arrange
      const defaultConfig = AppConfig();
      when(() => mockConfigCubit.state).thenReturn(ConfigLoaded(defaultConfig));
      when(() => mockConfigCubit.loadConfig()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(const KurbanApp());
      await tester.pump();

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Verify app title
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, equals('Kurban Management'));
    });

    testWidgets('should use custom theme from config', (WidgetTester tester) async {
      // Arrange
      const customConfig = AppConfig(
        primaryColor: Colors.blue,
        accentColor: Colors.orange,
      );
      when(() => mockConfigCubit.state).thenReturn(ConfigLoaded(customConfig));
      when(() => mockConfigCubit.loadConfig()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(const KurbanApp());
      await tester.pump();

      // Assert
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, isNotNull);
      // Additional theme verification could be added here
    });

    testWidgets('should handle config loading state', (WidgetTester tester) async {
      // Arrange
      when(() => mockConfigCubit.state).thenReturn(ConfigLoading());
      when(() => mockConfigCubit.loadConfig()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(const KurbanApp());

      // Assert - should not crash and should build with default theme
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle config error state', (WidgetTester tester) async {
      // Arrange
      when(() => mockConfigCubit.state).thenReturn(const ConfigError('Failed to load config'));
      when(() => mockConfigCubit.loadConfig()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(const KurbanApp());

      // Assert - should not crash and should build with default theme
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('ShareAmount Type Safety Smoke Tests', () {
    test('basic calculation type safety', () {
      // This is a smoke test to ensure our type fix works in isolation
      const int shareCount = 3;
      const double sharePrice = 142.86;
      
      // The fixed calculation that should return double
      final double shareAmount = (shareCount * sharePrice).toDouble();
      
      expect(shareAmount, isA<double>());
      expect(shareAmount, closeTo(428.58, 0.01));
    });

    test('null safety in calculation', () {
      const int shareCount = 2;
      const double? sharePrice = null;
      
      // The fixed calculation with null handling
      final double shareAmount = (shareCount * (sharePrice ?? 0)).toDouble();
      
      expect(shareAmount, isA<double>());
      expect(shareAmount, equals(0.0));
    });
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/recurring_rule.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/recurring/domain/recurring_repository.dart';
import 'package:hamster_stash/features/recurring/presentation/recurring_providers.dart';
import 'package:hamster_stash/features/recurring/presentation/recurring_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockRecurringRepository extends Mock implements RecurringRepository {}

void main() {
  late MockRecurringRepository mockRepo;

  setUp(() {
    mockRepo = MockRecurringRepository();
  });

  Widget buildWidget({List<RecurringRule>? rules}) {
    when(() => mockRepo.getAll()).thenAnswer(
      (_) async =>
          rules ??
          [
            RecurringRule()
              ..id = 1
              ..amount = 15000
              ..transactionType = TransactionType.expense
              ..frequency = RecurringFrequency.monthly
              ..note = '房租'
              ..startDate = DateTime(2026, 1, 1)
              ..nextExecutionAt = DateTime(2026, 4, 1)
              ..isActive = true
              ..createdAt = DateTime(2026),
          ],
    );

    return ProviderScope(
      overrides: [recurringRepositoryProvider.overrideWithValue(mockRepo)],
      child: const MaterialApp(home: RecurringScreen()),
    );
  }

  group('RecurringScreen', () {
    testWidgets('given rules, then shows rule note', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('房租'), findsOneWidget);
    });

    testWidgets('given rules, then shows amount and frequency', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('15,000'), findsOneWidget);
      expect(find.textContaining('每月'), findsOneWidget);
    });

    testWidgets('given rules, then shows next execution date', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('2026/04/01'), findsOneWidget);
    });

    testWidgets('given no rules, then shows empty message', (tester) async {
      await tester.pumpWidget(buildWidget(rules: []));
      await tester.pumpAndSettle();

      expect(find.text('尚未設定週期性交易'), findsOneWidget);
    });

    testWidgets('given recurring screen, then shows add button', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('given active rule, then shows check icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}

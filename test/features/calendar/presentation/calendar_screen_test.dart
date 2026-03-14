import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/calendar/presentation/calendar_screen.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;

  setUp(() {
    mockRepo = MockTransactionRepository();
    // Stub any date range query
    when(() => mockRepo.getByDateRange(any(), any())).thenAnswer(
      (_) async => [
        Transaction()
          ..id = 1
          ..amount = 500
          ..type = TransactionType.expense
          ..dateTime = DateTime(2026, 3, 13)
          ..createdAt = DateTime(2026),
      ],
    );
  });

  Widget buildWidget() {
    return ProviderScope(
      overrides: [transactionRepositoryProvider.overrideWithValue(mockRepo)],
      child: const MaterialApp(home: Scaffold(body: CalendarScreen())),
    );
  }

  group('CalendarScreen with real data', () {
    testWidgets('given calendar displayed, '
        'then shows month header', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('2026'), findsWidgets);
    });

    testWidgets('given calendar displayed, '
        'then shows day cells', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('15'), findsWidgets);
    });

    testWidgets('given day selected, '
        'then shows daily transactions section', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('當日交易'), findsOneWidget);
    });
  });
}

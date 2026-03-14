import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/recurring_rule.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/recurring/domain/recurring_executor.dart';
import 'package:hamster_stash/features/recurring/domain/recurring_repository.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockRecurringRepository extends Mock implements RecurringRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

RecurringRule _makeRule({
  int id = 1,
  DateTime? nextExecutionAt,
  DateTime? endDate,
}) {
  return RecurringRule()
    ..id = id
    ..amount = 1000
    ..transactionType = TransactionType.expense
    ..frequency = RecurringFrequency.monthly
    ..startDate = DateTime(2026, 1, 1)
    ..nextExecutionAt = nextExecutionAt ?? DateTime(2026, 3, 1)
    ..endDate = endDate
    ..isActive = true
    ..createdAt = DateTime(2026);
}

void main() {
  late MockRecurringRepository mockRecurringRepo;
  late MockTransactionRepository mockTxnRepo;
  late RecurringExecutor executor;

  setUp(() {
    mockRecurringRepo = MockRecurringRepository();
    mockTxnRepo = MockTransactionRepository();
    executor = RecurringExecutor(
      recurringRepo: mockRecurringRepo,
      transactionRepo: mockTxnRepo,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      RecurringRule()
        ..amount = 0
        ..transactionType = TransactionType.expense
        ..frequency = RecurringFrequency.monthly
        ..startDate = DateTime(2026)
        ..createdAt = DateTime(2026),
    );
    registerFallbackValue(
      Transaction()
        ..amount = 0
        ..type = TransactionType.expense
        ..dateTime = DateTime(2026)
        ..createdAt = DateTime(2026),
    );
  });

  test('given one due rule, '
      'then creates transaction and updates rule', () async {
    final rule = _makeRule();
    when(() => mockRecurringRepo.getActive()).thenAnswer((_) async => [rule]);
    when(() => mockTxnRepo.add(any())).thenAnswer((_) async => 1);
    when(() => mockRecurringRepo.update(any())).thenAnswer((_) async {});

    final count = await executor.processAll(now: DateTime(2026, 3, 1));

    expect(count, 1);
    verify(() => mockTxnRepo.add(any())).called(1);
    verify(() => mockRecurringRepo.update(any())).called(1);
  });

  test('given no active rules, '
      'then creates no transactions', () async {
    when(() => mockRecurringRepo.getActive()).thenAnswer((_) async => []);

    final count = await executor.processAll(now: DateTime(2026, 3, 1));

    expect(count, 0);
    verifyNever(() => mockTxnRepo.add(any()));
  });

  test('given rule with future nextExecution, '
      'then skips it', () async {
    final rule = _makeRule(nextExecutionAt: DateTime(2026, 6, 1));
    when(() => mockRecurringRepo.getActive()).thenAnswer((_) async => [rule]);

    final count = await executor.processAll(now: DateTime(2026, 3, 1));

    expect(count, 0);
    verifyNever(() => mockTxnRepo.add(any()));
    verifyNever(() => mockRecurringRepo.update(any()));
  });

  test('given rule past endDate, '
      'then deactivates rule', () async {
    final rule = _makeRule(endDate: DateTime(2026, 3, 15));
    when(() => mockRecurringRepo.getActive()).thenAnswer((_) async => [rule]);
    when(() => mockTxnRepo.add(any())).thenAnswer((_) async => 1);
    when(() => mockRecurringRepo.update(any())).thenAnswer((_) async {});

    await executor.processAll(now: DateTime(2026, 4, 1));

    final captured = verify(
      () => mockRecurringRepo.update(captureAny()),
    ).captured;
    final updatedRule = captured.last as RecurringRule;
    expect(updatedRule.isActive, isFalse);
  });

  test('given multiple rules, '
      'then processes all of them', () async {
    final rule1 = _makeRule();
    final rule2 = _makeRule(id: 2);
    when(
      () => mockRecurringRepo.getActive(),
    ).thenAnswer((_) async => [rule1, rule2]);
    when(() => mockTxnRepo.add(any())).thenAnswer((_) async => 1);
    when(() => mockRecurringRepo.update(any())).thenAnswer((_) async {});

    final count = await executor.processAll(now: DateTime(2026, 3, 1));

    expect(count, 2);
    verify(() => mockTxnRepo.add(any())).called(2);
    verify(() => mockRecurringRepo.update(any())).called(2);
  });
}

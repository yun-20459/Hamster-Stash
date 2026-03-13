import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

Transaction _makeTxn({
  int id = 1,
  double amount = 150,
  TransactionType type = TransactionType.expense,
  int? categoryId = 1,
  int? accountId = 1,
}) {
  return Transaction()
    ..id = id
    ..amount = amount
    ..type = type
    ..dateTime = DateTime(2026, 3, 13)
    ..categoryId = categoryId
    ..accountId = accountId
    ..createdAt = DateTime(2026);
}

void main() {
  late MockTransactionRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockTransactionRepository();
    container = ProviderContainer(
      overrides: [transactionRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() => container.dispose());

  group('recentTransactionsProvider', () {
    test('given recent transactions exist, '
        'when reading provider, '
        'then returns recent list', () async {
      final txns = [_makeTxn(), _makeTxn(id: 2, amount: 200)];
      when(() => mockRepo.getRecent()).thenAnswer((_) async => txns);

      final result = await container.read(recentTransactionsProvider.future);

      expect(result, hasLength(2));
    });
  });

  group('transactionByIdProvider', () {
    test('given transaction exists, '
        'when reading by id, '
        'then returns transaction', () async {
      final txn = _makeTxn(id: 5);
      when(() => mockRepo.getById(5)).thenAnswer((_) async => txn);

      final result = await container.read(transactionByIdProvider(5).future);

      expect(result, isNotNull);
      expect(result!.id, 5);
    });
  });
}

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
  double amount = 3000,
  int? accountId = 1,
  int? toAccountId = 2,
}) {
  return Transaction()
    ..id = id
    ..amount = amount
    ..type = TransactionType.transfer
    ..dateTime = DateTime(2026, 3, 13)
    ..accountId = accountId
    ..toAccountId = toAccountId
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

  group('transfersByAccountProvider', () {
    test('given account has transfers, '
        'when reading provider, '
        'then returns only transfer type', () async {
      final txns = [
        _makeTxn(),
        // Non-transfer mixed in from repo
        Transaction()
          ..id = 99
          ..amount = 100
          ..type = TransactionType.expense
          ..dateTime = DateTime(2026, 3, 13)
          ..accountId = 1
          ..createdAt = DateTime(2026),
      ];
      when(() => mockRepo.getByAccountId(1)).thenAnswer((_) async => txns);

      final result = await container.read(transfersByAccountProvider(1).future);

      expect(result, hasLength(1));
      expect(result[0].type, TransactionType.transfer);
    });
  });
}

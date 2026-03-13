import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/accounts/domain/account_repository.dart';
import 'package:hamster_stash/features/accounts/presentation/account_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

Account _makeAccount({
  int id = 1,
  String name = '國泰世華',
  double balance = 50000,
  AssetTerm assetTerm = AssetTerm.current,
}) {
  return Account()
    ..id = id
    ..name = name
    ..type = AccountType.bank
    ..balance = balance
    ..currency = 'TWD'
    ..assetTerm = assetTerm
    ..isArchived = false
    ..createdAt = DateTime(2026);
}

void main() {
  late MockAccountRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockAccountRepository();
    container = ProviderContainer(
      overrides: [accountRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() => container.dispose());

  group('activeAccountsProvider', () {
    test(
      'given active accounts exist, when reading provider, then returns active account list',
      () async {
        final accounts = [
          _makeAccount(id: 1, name: '國泰世華'),
          _makeAccount(id: 2, name: 'Firstrade'),
        ];
        when(() => mockRepo.getActive()).thenAnswer((_) async => accounts);

        final result = await container.read(activeAccountsProvider.future);

        expect(result, hasLength(2));
        expect(result[0].name, '國泰世華');
      },
    );
  });

  group('currentAssetsProvider', () {
    test(
      'given current term accounts, when reading provider, then returns only current accounts',
      () async {
        final accounts = [
          _makeAccount(id: 1, balance: 50000, assetTerm: AssetTerm.current),
        ];
        when(
          () => mockRepo.getByAssetTerm(AssetTerm.current),
        ).thenAnswer((_) async => accounts);

        final result = await container.read(currentAssetsProvider.future);

        expect(result, hasLength(1));
        expect(result[0].assetTerm, AssetTerm.current);
      },
    );
  });

  group('accountByIdProvider', () {
    test(
      'given account exists, when reading accountByIdProvider(id), then returns account',
      () async {
        final account = _makeAccount(id: 5, name: 'Cash');
        when(() => mockRepo.getById(5)).thenAnswer((_) async => account);

        final result = await container.read(accountByIdProvider(5).future);

        expect(result, isNotNull);
        expect(result!.name, 'Cash');
      },
    );
  });
}

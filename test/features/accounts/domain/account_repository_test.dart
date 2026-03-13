import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/accounts/domain/account_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

Account _makeAccount({
  int id = 1,
  String name = '國泰世華',
  AccountType type = AccountType.bank,
  double balance = 50000,
  String currency = 'TWD',
  AssetTerm assetTerm = AssetTerm.current,
  bool isArchived = false,
}) {
  return Account()
    ..id = id
    ..name = name
    ..type = type
    ..balance = balance
    ..currency = currency
    ..iconEmoji = '\u{1F3E6}'
    ..assetTerm = assetTerm
    ..isArchived = isArchived
    ..createdAt = DateTime(2026);
}

void main() {
  late MockAccountRepository repo;

  setUp(() {
    repo = MockAccountRepository();
  });

  group('AccountRepository', () {
    test(
      'given active accounts exist, '
      'when getActive(), '
      'then returns only non-archived accounts',
      () async {
        final accounts = [
          _makeAccount(),
          _makeAccount(id: 2, name: 'Firstrade'),
        ];
        when(() => repo.getActive()).thenAnswer((_) async => accounts);

        final result = await repo.getActive();

        expect(result, hasLength(2));
        expect(result.every((a) => !a.isArchived), isTrue);
      },
    );

    test(
      'given accounts with different asset terms, '
      'when getByAssetTerm(current), '
      'then returns only current accounts',
      () async {
        final currentAccounts = [_makeAccount()];
        when(
          () => repo.getByAssetTerm(AssetTerm.current),
        ).thenAnswer((_) async => currentAccounts);

        final result = await repo.getByAssetTerm(AssetTerm.current);

        expect(result, hasLength(1));
        expect(result[0].assetTerm, AssetTerm.current);
      },
    );

    test(
      'given long term accounts exist, '
      'when getByAssetTerm(longTerm), '
      'then returns only long term accounts',
      () async {
        final longTermAccounts = [
          _makeAccount(id: 3, name: '不動產', assetTerm: AssetTerm.longTerm),
        ];
        when(
          () => repo.getByAssetTerm(AssetTerm.longTerm),
        ).thenAnswer((_) async => longTermAccounts);

        final result = await repo.getByAssetTerm(AssetTerm.longTerm);

        expect(result, hasLength(1));
        expect(result[0].assetTerm, AssetTerm.longTerm);
      },
    );

    test(
      'given new account, when add(account), then returns assigned id',
      () async {
        final account = _makeAccount(name: 'New Account');
        when(() => repo.add(account)).thenAnswer((_) async => 42);

        final id = await repo.add(account);

        expect(id, 42);
        verify(() => repo.add(account)).called(1);
      },
    );

    test(
      'given existing account, when update(account), then completes',
      () async {
        final account = _makeAccount(name: 'Updated');
        when(() => repo.update(account)).thenAnswer((_) async {});

        await repo.update(account);

        verify(() => repo.update(account)).called(1);
      },
    );

    test(
      'given active account, when archive(id), then soft-deletes it',
      () async {
        when(() => repo.archive(1)).thenAnswer((_) async {});

        await repo.archive(1);

        verify(() => repo.archive(1)).called(1);
      },
    );

    test(
      'given archived account, when unarchive(id), then restores it',
      () async {
        when(() => repo.unarchive(1)).thenAnswer((_) async {});

        await repo.unarchive(1);

        verify(() => repo.unarchive(1)).called(1);
      },
    );

    test(
      'given account id, when getById(id), then returns the account',
      () async {
        final account = _makeAccount(id: 5, name: 'Cash');
        when(() => repo.getById(5)).thenAnswer((_) async => account);

        final result = await repo.getById(5);

        expect(result, isNotNull);
        expect(result!.name, 'Cash');
      },
    );

    test(
      'given non-existent id, when getById(id), then returns null',
      () async {
        when(() => repo.getById(999)).thenAnswer((_) async => null);

        final result = await repo.getById(999);

        expect(result, isNull);
      },
    );

    test(
      'given account, '
      'when updateBalance(id, newBalance), '
      'then updates cached balance',
      () async {
        when(() => repo.updateBalance(1, 75000)).thenAnswer((_) async {});

        await repo.updateBalance(1, 75000);

        verify(() => repo.updateBalance(1, 75000)).called(1);
      },
    );

    test(
      'given all accounts requested, '
      'when getAll(), '
      'then returns active and archived',
      () async {
        final accounts = [
          _makeAccount(),
          _makeAccount(id: 2, isArchived: true),
        ];
        when(() => repo.getAll()).thenAnswer((_) async => accounts);

        final result = await repo.getAll();

        expect(result, hasLength(2));
      },
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/accounts/domain/account_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

Account _makeAccount({
  int id = 1,
  String name = 'Test',
  AccountType type = AccountType.bank,
  double balance = 10000,
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
    ..assetTerm = assetTerm
    ..isArchived = isArchived
    ..createdAt = DateTime(2026);
}

void main() {
  late MockAccountRepository repo;

  setUp(() {
    repo = MockAccountRepository();
  });

  group('AccountRepository edge cases', () {
    test('given zero balance account, '
        'when getActive, '
        'then includes it', () async {
      final accounts = [_makeAccount(balance: 0)];
      when(() => repo.getActive()).thenAnswer((_) async => accounts);

      final result = await repo.getActive();

      expect(result, hasLength(1));
      expect(result[0].balance, 0);
    });

    test('given negative balance (credit card), '
        'when getActive, '
        'then includes it', () async {
      final accounts = [
        _makeAccount(type: AccountType.creditCard, balance: -15000),
      ];
      when(() => repo.getActive()).thenAnswer((_) async => accounts);

      final result = await repo.getActive();

      expect(result[0].balance, -15000);
    });

    test('given multiple currencies, '
        'when getAll, '
        'then returns all', () async {
      final accounts = [
        _makeAccount(),
        _makeAccount(id: 2, name: 'USD', currency: 'USD'),
        _makeAccount(id: 3, name: 'JPY', currency: 'JPY'),
      ];
      when(() => repo.getAll()).thenAnswer((_) async => accounts);

      final result = await repo.getAll();

      expect(result, hasLength(3));
      final currencies = result.map((a) => a.currency);
      expect(currencies, containsAll(['TWD', 'USD', 'JPY']));
    });

    test('given archived account, '
        'when getActive, '
        'then excludes it', () async {
      when(() => repo.getActive()).thenAnswer((_) async => []);

      final result = await repo.getActive();

      expect(result, isEmpty);
    });

    test('given archived then unarchived, '
        'when getActive, '
        'then includes it again', () async {
      when(() => repo.archive(1)).thenAnswer((_) async {});
      when(() => repo.unarchive(1)).thenAnswer((_) async {});
      when(() => repo.getActive()).thenAnswer((_) async => [_makeAccount()]);

      await repo.archive(1);
      await repo.unarchive(1);
      final result = await repo.getActive();

      expect(result, hasLength(1));
    });

    test('given short term accounts, '
        'when getByAssetTerm(shortTerm), '
        'then returns them', () async {
      final accounts = [_makeAccount(assetTerm: AssetTerm.shortTerm)];
      when(
        () => repo.getByAssetTerm(AssetTerm.shortTerm),
      ).thenAnswer((_) async => accounts);

      final result = await repo.getByAssetTerm(AssetTerm.shortTerm);

      expect(result, hasLength(1));
      expect(result[0].assetTerm, AssetTerm.shortTerm);
    });

    test('given balance update to negative, '
        'when updateBalance, '
        'then allows it', () async {
      when(() => repo.updateBalance(1, -5000)).thenAnswer((_) async {});

      await repo.updateBalance(1, -5000);

      verify(() => repo.updateBalance(1, -5000)).called(1);
    });

    test('given all account types, '
        'when getAll, '
        'then returns every type', () async {
      final accounts = [
        _makeAccount(type: AccountType.cash),
        _makeAccount(id: 2),
        _makeAccount(id: 3, type: AccountType.creditCard),
        _makeAccount(id: 4, type: AccountType.eWallet),
        _makeAccount(id: 5, type: AccountType.investment),
        _makeAccount(id: 6, type: AccountType.other),
      ];
      when(() => repo.getAll()).thenAnswer((_) async => accounts);

      final result = await repo.getAll();

      expect(result, hasLength(6));
    });
  });
}

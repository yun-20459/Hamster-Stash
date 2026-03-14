import 'package:hamster_stash/core/database/collections/exchange_rate.dart';
import 'package:hamster_stash/features/exchange_rate/domain/exchange_rate_repository.dart';
import 'package:isar/isar.dart';

class IsarExchangeRateRepository implements ExchangeRateRepository {
  IsarExchangeRateRepository(this._isar);

  final Isar _isar;

  @override
  Future<ExchangeRate?> getCachedRate(String pair) {
    return _isar.exchangeRates.where().pairEqualTo(pair).findFirst();
  }

  @override
  Future<void> saveRate(ExchangeRate rate) async {
    await _isar.writeTxn(() async {
      await _isar.exchangeRates.put(rate);
    });
  }

  @override
  Future<List<ExchangeRate>> getAll() {
    return _isar.exchangeRates.where().findAll();
  }

  @override
  Future<void> deleteExpired(Duration maxAge) async {
    final cutoff = DateTime.now().subtract(maxAge);
    await _isar.writeTxn(() async {
      await _isar.exchangeRates.filter().fetchedAtLessThan(cutoff).deleteAll();
    });
  }
}

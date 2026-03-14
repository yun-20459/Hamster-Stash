import 'package:hamster_stash/core/database/collections/exchange_rate.dart';

/// Manages cached exchange rates in local storage.
abstract class ExchangeRateRepository {
  /// Get cached rate for a currency pair (e.g. "USD_TWD").
  Future<ExchangeRate?> getCachedRate(String pair);

  /// Save or update a cached rate.
  Future<void> saveRate(ExchangeRate rate);

  /// Get all cached rates.
  Future<List<ExchangeRate>> getAll();

  /// Delete expired rates older than [maxAge].
  Future<void> deleteExpired(Duration maxAge);
}

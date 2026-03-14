import 'package:hamster_stash/core/database/collections/exchange_rate.dart';
import 'package:hamster_stash/features/exchange_rate/domain/exchange_rate_repository.dart';
import 'package:hamster_stash/features/exchange_rate/domain/exchange_rate_service.dart';

/// Coordinates exchange rate lookups with cache-first strategy.
///
/// Flow: cache hit (fresh) → return cached
///       cache miss or stale → fetch API → save → return
///       API fail + stale cache → return stale (offline-first)
///       API fail + no cache → return null
class ExchangeRateManager {
  ExchangeRateManager({
    required this.repository,
    required this.service,
    this.cacheDuration = const Duration(minutes: 30),
  });

  final ExchangeRateRepository repository;
  final ExchangeRateService service;
  final Duration cacheDuration;

  /// Get the rate for converting [from] to [to].
  /// Returns 1.0 for same-currency, null if unavailable.
  Future<double?> getRate(String from, String to) async {
    if (from == to) return 1.0;

    final pair = '${from}_$to';
    final cached = await repository.getCachedRate(pair);

    if (cached != null && _isFresh(cached)) {
      return cached.rate;
    }

    // Try fetching from API
    final fetched = await service.fetchRate(from, to);
    if (fetched != null) {
      await repository.saveRate(
        ExchangeRate()
          ..pair = pair
          ..rate = fetched
          ..fetchedAt = DateTime.now(),
      );
      return fetched;
    }

    // Offline fallback: return stale cache if available
    return cached?.rate;
  }

  /// Get rates for [from] against multiple [targets].
  Future<Map<String, double>> getRatesForBase(
    String from,
    List<String> targets,
  ) async {
    final results = <String, double>{};
    final toFetch = <String>[];

    // Check cache first
    for (final to in targets) {
      if (from == to) {
        results[to] = 1.0;
        continue;
      }
      final pair = '${from}_$to';
      final cached = await repository.getCachedRate(pair);
      if (cached != null && _isFresh(cached)) {
        results[to] = cached.rate;
      } else {
        toFetch.add(to);
      }
    }

    if (toFetch.isEmpty) return results;

    // Fetch missing rates from API
    final fetched = await service.fetchRates(from, toFetch);
    for (final entry in fetched.entries) {
      results[entry.key] = entry.value;
      await repository.saveRate(
        ExchangeRate()
          ..pair = '${from}_${entry.key}'
          ..rate = entry.value
          ..fetchedAt = DateTime.now(),
      );
    }

    return results;
  }

  bool _isFresh(ExchangeRate rate) {
    return DateTime.now().difference(rate.fetchedAt) < cacheDuration;
  }
}

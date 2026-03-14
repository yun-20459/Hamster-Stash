import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/features/exchange_rate/domain/exchange_rate_manager.dart';
import 'package:hamster_stash/features/exchange_rate/domain/exchange_rate_repository.dart';
import 'package:hamster_stash/features/exchange_rate/domain/exchange_rate_service.dart';

/// Provide the repository — override in tests with a mock.
final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  throw UnimplementedError('exchangeRateRepositoryProvider must be overridden');
});

/// Provide the API service — override in tests with a mock.
final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  throw UnimplementedError('exchangeRateServiceProvider must be overridden');
});

/// The exchange rate manager (cache-first coordinator).
final exchangeRateManagerProvider = Provider<ExchangeRateManager>((ref) {
  return ExchangeRateManager(
    repository: ref.watch(exchangeRateRepositoryProvider),
    service: ref.watch(exchangeRateServiceProvider),
  );
});

/// Fetch a single exchange rate.
/// Returns null if unavailable.
final exchangeRateProvider =
    FutureProvider.family<double?, ({String from, String to})>((ref, pair) {
      final manager = ref.watch(exchangeRateManagerProvider);
      return manager.getRate(pair.from, pair.to);
    });

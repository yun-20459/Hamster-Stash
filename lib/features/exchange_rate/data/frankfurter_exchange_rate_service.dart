import 'package:dio/dio.dart';
import 'package:hamster_stash/features/exchange_rate/domain/exchange_rate_service.dart';

/// Fetches exchange rates from frankfurter.app (free, no API key).
class FrankfurterExchangeRateService implements ExchangeRateService {
  FrankfurterExchangeRateService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.frankfurter.app',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  @override
  Future<double?> fetchRate(String from, String to) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/latest',
        queryParameters: {'from': from.toUpperCase(), 'to': to.toUpperCase()},
      );
      final rates = response.data?['rates'] as Map<String, dynamic>?;
      if (rates == null) return null;
      final value = rates[to.toUpperCase()];
      if (value == null) return null;
      return (value as num).toDouble();
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, double>> fetchRates(String from, List<String> to) async {
    if (to.isEmpty) return {};
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/latest',
        queryParameters: {
          'from': from.toUpperCase(),
          'to': to.map((s) => s.toUpperCase()).join(','),
        },
      );
      final rates = response.data?['rates'] as Map<String, dynamic>?;
      if (rates == null) return {};
      return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } on DioException {
      return {};
    } catch (_) {
      return {};
    }
  }
}

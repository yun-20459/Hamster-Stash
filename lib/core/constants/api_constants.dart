class ApiConstants {
  ApiConstants._();

  static const String baseUrl = '';

  /// Frankfurter.app — free exchange rate API (no key needed).
  static const String frankfurterBaseUrl = 'https://api.frankfurter.app';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  /// Exchange rate cache duration.
  static const Duration exchangeRateCacheDuration = Duration(minutes: 30);
}

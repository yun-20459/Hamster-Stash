/// Fetches exchange rates from a remote API.
abstract class ExchangeRateService {
  /// Fetch the rate for converting [from] to [to].
  /// Returns the rate (1 [from] = rate [to]), or null on failure.
  Future<double?> fetchRate(String from, String to);

  /// Fetch rates for [from] against multiple targets.
  /// Returns a map of target currency → rate.
  Future<Map<String, double>> fetchRates(String from, List<String> to);
}

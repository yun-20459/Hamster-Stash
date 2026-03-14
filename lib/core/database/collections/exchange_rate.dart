import 'package:isar/isar.dart';

part 'exchange_rate.g.dart';

/// Cached exchange rate from API.
/// Key is "FROM_TO" (e.g. "USD_TWD").
@collection
class ExchangeRate {
  Id id = Isar.autoIncrement;

  /// Currency pair key, e.g. "USD_TWD".
  @Index(unique: true, replace: true)
  late String pair;

  /// The exchange rate value (1 FROM = rate TO).
  late double rate;

  /// When this rate was fetched from the API.
  late DateTime fetchedAt;
}

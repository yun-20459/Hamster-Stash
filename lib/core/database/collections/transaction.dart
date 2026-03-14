import 'package:hamster_stash/core/database/enums.dart';
import 'package:isar/isar.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late double amount;

  @enumerated
  late TransactionType type;

  @Index()
  late DateTime dateTime;

  @Index()
  int? categoryId;

  @Index()
  int? accountId;

  int? toAccountId;

  /// Transaction currency (e.g. "USD", "TWD").
  String? currency;

  /// Exchange rate used for this transaction.
  /// 1 [currency] = [exchangeRate] base currency.
  double exchangeRate = 1;

  /// Whether the exchange rate was manually set by the user.
  bool isManualRate = false;

  String? note;

  String? attachmentPath;

  List<String>? tags;

  bool isRecurring = false;

  int? recurringRuleId;

  late DateTime createdAt;

  DateTime? updatedAt;
}

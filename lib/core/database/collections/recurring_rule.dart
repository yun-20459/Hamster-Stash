import 'package:hamster_stash/core/database/enums.dart';
import 'package:isar/isar.dart';

part 'recurring_rule.g.dart';

@collection
class RecurringRule {
  Id id = Isar.autoIncrement;

  late double amount;

  @enumerated
  late TransactionType transactionType;

  @enumerated
  late RecurringFrequency frequency;

  int? categoryId;

  int? accountId;

  String? note;

  late DateTime startDate;

  DateTime? endDate;

  DateTime? lastExecutedAt;

  DateTime? nextExecutionAt;

  bool isActive = true;

  late DateTime createdAt;
}

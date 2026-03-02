import 'package:hamster_stash/core/database/enums.dart';
import 'package:isar/isar.dart';

part 'budget.g.dart';

@collection
class Budget {
  Id id = Isar.autoIncrement;

  late String name;

  late double amount;

  double spent = 0;

  @enumerated
  late BudgetPeriod period;

  int? categoryId;

  late DateTime startDate;

  DateTime? endDate;

  bool isActive = true;

  late DateTime createdAt;

  DateTime? updatedAt;
}

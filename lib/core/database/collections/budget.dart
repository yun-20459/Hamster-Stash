import 'package:hamster_stash/core/database/enums.dart';
import 'package:isar/isar.dart';

part 'budget.g.dart';

@collection
class Budget {
  Id id = Isar.autoIncrement;

  late String name;

  /// Budget limit amount.
  late double amount;

  /// Current period spending (recalculated from transactions).
  double spent = 0;

  @enumerated
  late BudgetPeriod period;

  /// Linked category ID (null = total budget across all categories).
  int? categoryId;

  late DateTime startDate;

  DateTime? endDate;

  /// Whether unspent amount rolls over to next period.
  bool carryOver = false;

  /// Alert threshold (0.0–1.0). Default 0.8 = warn at 80%.
  double alertThreshold = 0.8;

  bool isActive = true;

  late DateTime createdAt;

  DateTime? updatedAt;
}

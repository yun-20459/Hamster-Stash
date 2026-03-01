import 'package:isar/isar.dart';

part 'manual_valuation.g.dart';

@collection
class ManualValuation {
  Id id = Isar.autoIncrement;

  late int accountId;

  late double value;

  late DateTime valuationDate;

  String? note;

  late DateTime createdAt;
}

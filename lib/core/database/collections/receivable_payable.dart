import 'package:isar/isar.dart';

import '../enums.dart';

part 'receivable_payable.g.dart';

@collection
class ReceivablePayable {
  Id id = Isar.autoIncrement;

  late String counterparty;

  late double amount;

  double paidAmount = 0;

  @enumerated
  late ReceivablePayableType type;

  @enumerated
  ReceivablePayableStatus status = ReceivablePayableStatus.pending;

  String? note;

  DateTime? dueDate;

  late DateTime createdAt;

  DateTime? updatedAt;
}

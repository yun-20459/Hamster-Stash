import 'package:hamster_stash/core/database/collections/receivable_payable.dart';
import 'package:hamster_stash/core/database/enums.dart';

/// Records a payment and updates status accordingly.
///
/// Returns the updated ReceivablePayable (mutated in place).
/// Payment is clamped so `paidAmount` never exceeds `amount`.
ReceivablePayable recordPayment(ReceivablePayable rp, double payment) {
  final remaining = rp.amount - rp.paidAmount;
  final actual = payment > remaining ? remaining : payment;
  rp.paidAmount += actual;

  if (rp.paidAmount >= rp.amount) {
    rp.status = ReceivablePayableStatus.paid;
  } else if (rp.paidAmount > 0) {
    rp.status = ReceivablePayableStatus.partiallyPaid;
  }

  return rp;
}

/// Net balance summary for receivables and payables.
class RPBalanceSummary {
  RPBalanceSummary({required this.totalReceivable, required this.totalPayable});

  final double totalReceivable;
  final double totalPayable;

  double get netBalance => totalReceivable - totalPayable;
}

/// Computes net outstanding receivables and payables.
RPBalanceSummary computeNetBalance(List<ReceivablePayable> items) {
  var totalReceivable = 0.0;
  var totalPayable = 0.0;

  for (final item in items) {
    final outstanding = item.amount - item.paidAmount;
    if (outstanding <= 0) continue;

    if (item.type == ReceivablePayableType.receivable) {
      totalReceivable += outstanding;
    } else {
      totalPayable += outstanding;
    }
  }

  return RPBalanceSummary(
    totalReceivable: totalReceivable,
    totalPayable: totalPayable,
  );
}

/// Whether a receivable/payable is overdue.
bool isOverdue(ReceivablePayable rp, DateTime now) {
  if (rp.status == ReceivablePayableStatus.paid) return false;
  if (rp.dueDate == null) return false;
  return now.isAfter(rp.dueDate!);
}

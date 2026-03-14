import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/receivable_payable.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/receivable_payable/domain/rp_calculator.dart';

ReceivablePayable _makeRP({
  ReceivablePayableType type = ReceivablePayableType.receivable,
  double amount = 1000,
  double paidAmount = 0,
  ReceivablePayableStatus status = ReceivablePayableStatus.pending,
  DateTime? dueDate,
}) {
  return ReceivablePayable()
    ..id = 1
    ..counterparty = 'Test'
    ..amount = amount
    ..paidAmount = paidAmount
    ..type = type
    ..status = status
    ..dueDate = dueDate
    ..createdAt = DateTime(2026);
}

void main() {
  group('recordPayment', () {
    test('given pending receivable with partial payment, '
        'then status becomes partiallyPaid', () {
      final rp = _makeRP(amount: 1000);

      final result = recordPayment(rp, 300);

      expect(result.paidAmount, 300);
      expect(result.status, ReceivablePayableStatus.partiallyPaid);
    });

    test('given pending receivable with full payment, '
        'then status becomes paid', () {
      final rp = _makeRP(amount: 1000);

      final result = recordPayment(rp, 1000);

      expect(result.paidAmount, 1000);
      expect(result.status, ReceivablePayableStatus.paid);
    });

    test('given partiallyPaid receivable with remaining payment, '
        'then status becomes paid', () {
      final rp = _makeRP(
        amount: 1000,
        paidAmount: 600,
        status: ReceivablePayableStatus.partiallyPaid,
      );

      final result = recordPayment(rp, 400);

      expect(result.paidAmount, 1000);
      expect(result.status, ReceivablePayableStatus.paid);
    });

    test('given overpayment, '
        'then clamps to totalAmount and becomes paid', () {
      final rp = _makeRP(amount: 500);

      final result = recordPayment(rp, 999);

      expect(result.paidAmount, 500);
      expect(result.status, ReceivablePayableStatus.paid);
    });
  });

  group('computeNetBalance', () {
    test('given receivables and payables, '
        'then net balance is receivables minus payables', () {
      final items = [
        _makeRP(
          type: ReceivablePayableType.receivable,
          amount: 1000,
          paidAmount: 300,
        ),
        _makeRP(type: ReceivablePayableType.receivable, amount: 500),
        _makeRP(
          type: ReceivablePayableType.payable,
          amount: 800,
          paidAmount: 200,
        ),
      ];

      final result = computeNetBalance(items);

      // Outstanding receivables: (1000-300) + (500-0) = 1200
      // Outstanding payables: (800-200) = 600
      expect(result.totalReceivable, 1200);
      expect(result.totalPayable, 600);
      expect(result.netBalance, 600);
    });

    test('given only payables, '
        'then net balance is negative', () {
      final items = [
        _makeRP(type: ReceivablePayableType.payable, amount: 1000),
      ];

      final result = computeNetBalance(items);

      expect(result.totalReceivable, 0);
      expect(result.totalPayable, 1000);
      expect(result.netBalance, -1000);
    });

    test('given all settled, '
        'then net balance is zero', () {
      final items = [
        _makeRP(
          type: ReceivablePayableType.receivable,
          amount: 1000,
          paidAmount: 1000,
          status: ReceivablePayableStatus.paid,
        ),
      ];

      final result = computeNetBalance(items);

      expect(result.totalReceivable, 0);
      expect(result.netBalance, 0);
    });

    test('given empty list, '
        'then all values are zero', () {
      final result = computeNetBalance([]);

      expect(result.totalReceivable, 0);
      expect(result.totalPayable, 0);
      expect(result.netBalance, 0);
    });
  });

  group('isOverdue', () {
    test('given pending with past dueDate, '
        'then is overdue', () {
      final rp = _makeRP(dueDate: DateTime(2026, 1, 1));
      final now = DateTime(2026, 3, 1);

      expect(isOverdue(rp, now), isTrue);
    });

    test('given pending with future dueDate, '
        'then is not overdue', () {
      final rp = _makeRP(dueDate: DateTime(2026, 6, 1));
      final now = DateTime(2026, 3, 1);

      expect(isOverdue(rp, now), isFalse);
    });

    test('given paid, '
        'then is not overdue regardless of dueDate', () {
      final rp = _makeRP(
        dueDate: DateTime(2026, 1, 1),
        status: ReceivablePayableStatus.paid,
        paidAmount: 1000,
      );
      final now = DateTime(2026, 3, 1);

      expect(isOverdue(rp, now), isFalse);
    });

    test('given no dueDate, '
        'then is not overdue', () {
      final rp = _makeRP();
      final now = DateTime(2026, 3, 1);

      expect(isOverdue(rp, now), isFalse);
    });
  });
}

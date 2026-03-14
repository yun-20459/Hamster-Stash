import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/accounts/domain/account_repository.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';

/// Handles account-to-account transfers with balance
/// linkage and cross-currency support.
class TransferService {
  TransferService({
    required this.transactionRepository,
    required this.accountRepository,
  });

  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

  /// Transfers [amount] from one account to another.
  ///
  /// - [exchangeRate]: conversion multiplier applied to
  ///   the amount for the target account. Defaults to 1.0
  ///   (same currency). E.g. TWD→USD at 31.5 rate:
  ///   pass `1/31.5`.
  /// - Throws [ArgumentError] for same-account or
  ///   non-positive amount.
  /// - Throws [StateError] if either account not found.
  /// - Returns the created transaction id.
  Future<int> transfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    double exchangeRate = 1.0,
    String? note,
  }) async {
    if (fromAccountId == toAccountId) {
      throw ArgumentError('Cannot transfer to the same account');
    }
    if (amount <= 0) {
      throw ArgumentError('Transfer amount must be positive');
    }

    final from = await accountRepository.getById(fromAccountId);
    if (from == null) {
      throw StateError('Source account $fromAccountId not found');
    }

    final to = await accountRepository.getById(toAccountId);
    if (to == null) {
      throw StateError('Target account $toAccountId not found');
    }

    // Update balances
    await accountRepository.updateBalance(fromAccountId, from.balance - amount);
    await accountRepository.updateBalance(
      toAccountId,
      to.balance + amount * exchangeRate,
    );

    // Create transfer transaction (not income/expense)
    final txn = Transaction()
      ..amount = amount
      ..type = TransactionType.transfer
      ..dateTime = DateTime.now()
      ..accountId = fromAccountId
      ..toAccountId = toAccountId
      ..note = note
      ..createdAt = DateTime.now();

    return transactionRepository.add(txn);
  }
}

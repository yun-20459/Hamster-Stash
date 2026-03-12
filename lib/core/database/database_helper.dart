import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/collections/budget.dart';
import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/collections/manual_valuation.dart';
import 'package:hamster_stash/core/database/collections/receivable_payable.dart';
import 'package:hamster_stash/core/database/collections/recurring_rule.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/utils/encryption_helper.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static Isar? _isar;

  static Future<Isar> get instance async {
    _isar ??= await _openDatabase();
    return _isar!;
  }

  static Future<Isar> _openDatabase() async {
    // Initialise field-level encryption key from secure storage
    // (iOS Keychain / Android Keystore) before any DB access.
    await EncryptionHelper.init();

    final dir = await getApplicationDocumentsDirectory();

    return Isar.open(
      [
        AccountSchema,
        TransactionSchema,
        CategorySchema,
        BudgetSchema,
        RecurringRuleSchema,
        ReceivablePayableSchema,
        ManualValuationSchema,
      ],
      directory: dir.path,
      name: 'hamster_stash',
    );
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}

import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'collections/account.dart';
import 'collections/budget.dart';
import 'collections/category.dart';
import 'collections/manual_valuation.dart';
import 'collections/receivable_payable.dart';
import 'collections/recurring_rule.dart';
import 'collections/transaction.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static Isar? _isar;
  static const _encryptionKeyName = 'isar_encryption_key';
  static const _secureStorage = FlutterSecureStorage();

  static Future<Isar> get instance async {
    _isar ??= await _openDatabase();
    return _isar!;
  }

  static Future<Isar> _openDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final encryptionKey = await _getOrCreateEncryptionKey();

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
      encryptionKey: encryptionKey,
    );
  }

  static Future<String> _getOrCreateEncryptionKey() async {
    var key = await _secureStorage.read(key: _encryptionKeyName);
    if (key == null) {
      key = _generateEncryptionKey();
      await _secureStorage.write(key: _encryptionKeyName, value: key);
    }
    return key;
  }

  static String _generateEncryptionKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return String.fromCharCodes(values);
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}

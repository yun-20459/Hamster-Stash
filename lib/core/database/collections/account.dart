import 'package:isar/isar.dart';

import '../enums.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  late String name;

  @enumerated
  late AccountType type;

  late double balance;

  String? currency;

  String? iconEmoji;

  String? colorHex;

  String? note;

  @enumerated
  AssetTerm assetTerm = AssetTerm.current;

  bool isArchived = false;

  late DateTime createdAt;

  DateTime? updatedAt;
}

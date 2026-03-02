import 'package:hamster_stash/core/database/enums.dart';
import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  late String name;

  @enumerated
  late CategoryType type;

  String? iconEmoji;

  String? colorHex;

  int? parentId;

  int sortOrder = 0;

  bool isDefault = false;

  late DateTime createdAt;
}

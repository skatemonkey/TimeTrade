import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:time_vault/data/models/item.dart';
import 'package:time_vault/data/db/app_db.dart';

class ItemDao {
  ItemDao._();

  static final ItemDao instance = ItemDao._();

  Future<int> insert(Item entry) async {
    final db = await AppDb.instance.database;
    return db.insert(
      ItemFields.table,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Item>> getAll() async {
    final db = await AppDb.instance.database;
    final result = await db.query(ItemFields.table);
    return result.map((map) => Item.fromMap(map)).toList();
  }

  Future<Item?> getByKey(String key) async {
    final db = await AppDb.instance.database;
    final result = await db.query(
      ItemFields.table,
      where: '${ItemFields.key} = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Item.fromMap(result.first);
  }

  Future<int> update(Item entry) async {
    final db = await AppDb.instance.database;
    return db.update(
      ItemFields.table,
      entry.toMap(),
      where: '${ItemFields.id} = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDb.instance.database;
    return db.delete(
      ItemFields.table,
      where: '${ItemFields.id} = ?',
      whereArgs: [id],
    );
  }
}

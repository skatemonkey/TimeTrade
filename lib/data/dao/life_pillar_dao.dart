import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:time_vault/data/models/life_pillar.dart';
import 'package:time_vault/data/db/app_db.dart';

class LifePillarDao {
  LifePillarDao._();

  static final LifePillarDao instance = LifePillarDao._();

  Future<int> insert(LifePillar entry) async {
    final db = await AppDb.instance.database;
    return db.insert(
      LifePillarFields.table,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LifePillar>> getAll() async {
    final db = await AppDb.instance.database;
    final result = await db.query(LifePillarFields.table);
    return result.map((map) => LifePillar.fromMap(map)).toList();
  }

  Future<int> update(LifePillar entry) async {
    final db = await AppDb.instance.database;
    return db.update(
      LifePillarFields.table,
      entry.toMap(),
      where: '${LifePillarFields.id} = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDb.instance.database;
    return db.delete(
      LifePillarFields.table,
      where: '${LifePillarFields.id} = ?',
      whereArgs: [id],
    );
  }
}

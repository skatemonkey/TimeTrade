import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:time_vault/data/models/habit_log.dart';
import 'package:time_vault/data/db/app_db.dart';

class HabitLogDao {
  HabitLogDao._();

  static final HabitLogDao instance = HabitLogDao._();

  Future<int> insert(HabitLog log) async {
    final db = await AppDb.instance.database;
    return db.insert(
      HabitLogFields.table,
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HabitLog>> getAll() async {
    final db = await AppDb.instance.database;
    final maps = await db.query(HabitLogFields.table);
    return maps.map((e) => HabitLog.fromMap(e)).toList();
  }

  Future<List<HabitLog>> getByHabitId(int habitId) async {
    final db = await AppDb.instance.database;
    final maps = await db.query(
      HabitLogFields.table,
      where: '${HabitLogFields.habitId} = ?',
      whereArgs: [habitId],
      orderBy: '${HabitLogFields.date} DESC',
    );
    return maps.map((e) => HabitLog.fromMap(e)).toList();
  }

  Future<int> deleteByHabitId(int habitId) async {
    final db = await AppDb.instance.database;
    return db.delete(
      HabitLogFields.table,
      where: '${HabitLogFields.habitId} = ?',
      whereArgs: [habitId],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDb.instance.database;
    return db.delete(
      HabitLogFields.table,
      where: '${HabitLogFields.id} = ?',
      whereArgs: [id],
    );
  }

  /// Mark the habit as completed for `date`.
  /// If a row already exists for (habit_id, date), it will be replaced.
  Future<void> upsertCompleted(int habitId, String date) async {
    final db = await AppDb.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      HabitLogFields.table,
      {
        HabitLogFields.habitId: habitId,
        HabitLogFields.date: date, // format: yyyy-MM-dd
        HabitLogFields.createdTs: now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Unmark the habit as completed for `date`.
  /// Deletes the row for (habit_id, date).
  Future<int> deleteToday(int habitId, String date) async {
    final db = await AppDb.instance.database;
    return db.delete(
      HabitLogFields.table,
      where: '${HabitLogFields.habitId} = ? AND ${HabitLogFields.date} = ?',
      whereArgs: [habitId, date],
    );
  }

  Future<List<String>> getDatesForHabit(int habitId) async {
    final db = await AppDb.instance.database;
    final rows = await db.query(
      'habit_log',
      columns: ['date'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    return rows.map((r) => r['date'] as String).toList();
  }

}

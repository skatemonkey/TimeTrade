import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:time_vault/data/models/habit.dart';
import 'package:time_vault/data/db/app_db.dart';

class HabitDao {
  HabitDao._();

  static final HabitDao instance = HabitDao._();
  Future<Database> get _db async => AppDb.instance.database;


  Future<int> insert(Habit habit) async {
    final db = await _db;
    return db.insert(
      HabitFields.table,
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Habit>> getAll() async {
    final db = await _db;
    final maps = await db.query(HabitFields.table);
    return maps.map((e) => Habit.fromMap(e)).toList();
  }

  Future<int> update(Habit habit) async {
    final db = await _db;
    return db.update(
      HabitFields.table,
      habit.toMap(),
      where: '${HabitFields.id} = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete(
      HabitFields.table,
      where: '${HabitFields.id} = ?',
      whereArgs: [id],
    );
  }

  /// NEW: Same simple style, just a rawQuery to include today's status.
  Future<List<Map<String, Object?>>> getAllWithTodayStatus(String today) async {
    final db = await _db;
    const sql = '''
        SELECT h.id                                      AS habit_id,
               h.name                                    AS name,
               h.score_weight                            AS weight,
               hl.id                                     AS log_id,
               CASE WHEN hl.id IS NULL THEN 0 ELSE 1 END AS completed_today
        FROM habit h
                 LEFT JOIN habit_log hl
                           ON hl.habit_id = h.id
                               AND hl.date = ?
        ORDER BY h.created_ts ASC, h.id ASC
    ''';
    return db.rawQuery(sql, [today]);
  }




}

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:time_vault/data/models/focus_log.dart';

import 'package:time_vault/data/db/app_db.dart';

class FocusLogDao {
  FocusLogDao._();

  static final FocusLogDao instance = FocusLogDao._();

  Future<int> insert(FocusLog entry) async {
    final db = await AppDb.instance.database;
    return db.insert(
      FocusLogFields.table,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ✅ Get total time tracked (in seconds from DB)
  /// Converts to hours and rounds to 2 decimal places.
  Future<double> getTotalTimeTracked() async {
    final db = await AppDb.instance.database;

    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(CAST(duration AS REAL)), 0) AS total '
          'FROM ${FocusLogFields.table}',
    );

    if (rows.isEmpty || rows.first['total'] == null) return 0.0;

    // Total seconds from database
    final totalSeconds = (rows.first['total'] as num).toDouble();

    // Convert seconds → hours
    final totalHours = totalSeconds / 3600;

    // Round to 2 decimal places
    return double.parse(totalHours.toStringAsFixed(2));
  }

  /// Total sessions (rows)
  Future<int> getTotalSessions() async {
    final db = await AppDb.instance.database;
    final rows = await db.rawQuery(
        'SELECT COUNT(*) AS cnt FROM ${FocusLogFields.table}'
    );
    return (rows.first['cnt'] as num).toInt();
  }

  /// Avg session length in minutes (2 d.p.). `duration` stored in seconds.
  Future<double> getAvgSessionLengthMin() async {
    final db = await AppDb.instance.database;
    final rows = await db.rawQuery(
        'SELECT COALESCE(AVG(CAST(duration AS REAL)), 0) AS avg_secs '
            'FROM ${FocusLogFields.table}'
    );
    final avgSecs = (rows.first['avg_secs'] as num).toDouble();
    return double.parse((avgSecs / 60.0).toStringAsFixed(2));
  }




}

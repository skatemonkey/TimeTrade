import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:time_vault/data/models/points_ledger.dart';

import 'package:time_vault/data/db/app_db.dart';

class PointsLedgerDao {
  PointsLedgerDao._();

  static final PointsLedgerDao instance = PointsLedgerDao._();

  Future<int> insert(PointsLedger points) async {
    final db = await AppDb.instance.database;
    return db.insert(
      PointsLedgerFields.table,
      points.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Points balance rounded to 2 decimals
  Future<double> getAvailablePoints() async {
    final db = await AppDb.instance.database;
    final rows = await db.rawQuery('''
      SELECT COALESCE(SUM(${PointsLedgerFields.delta}), 0.0) AS balance
      FROM ${PointsLedgerFields.table}
    ''');
    return rows.isNotEmpty ? (rows.first['balance'] as num).toDouble() : 0.0;
  }
}

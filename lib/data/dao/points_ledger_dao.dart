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

  /// Returns: earnedGross, earnedUndone, earnedNet, spent, net
  Future<Map<String, double>> getTotalPointsSummary() async {
    final db = await AppDb.instance.database;

    final rows = await db.rawQuery('''
    SELECT
      COALESCE(SUM(CASE WHEN LOWER(${PointsLedgerFields.source}) = 'earn'
                  THEN CAST(${PointsLedgerFields.delta} AS REAL) END), 0) AS earned_gross,
      COALESCE(SUM(CASE WHEN LOWER(${PointsLedgerFields.source}) = 'undo'
                  THEN ABS(CAST(${PointsLedgerFields.delta} AS REAL)) END), 0) AS earned_undone,
      COALESCE(SUM(CASE WHEN LOWER(${PointsLedgerFields.source}) = 'spend'
                  THEN ABS(CAST(${PointsLedgerFields.delta} AS REAL)) END), 0) AS spent,
      COALESCE(SUM(CAST(${PointsLedgerFields.delta} AS REAL)), 0) AS net
    FROM ${PointsLedgerFields.table};
  ''');

    final r = rows.first;
    final earnedGross = (r['earned_gross'] as num).toDouble();
    final earnedUndone = (r['earned_undone'] as num).toDouble();
    final spent = (r['spent'] as num).toDouble();
    final net = (r['net'] as num).toDouble();
    final earnedNet = earnedGross - earnedUndone;

    return {
      'earnedGross': double.parse(earnedGross.toStringAsFixed(2)),
      'earnedUndone': double.parse(earnedUndone.toStringAsFixed(2)),
      'earnedNet': double.parse(earnedNet.toStringAsFixed(2)),
      'spent': double.parse(spent.toStringAsFixed(2)),
      'net': double.parse(net.toStringAsFixed(2)),
    };
  }


}

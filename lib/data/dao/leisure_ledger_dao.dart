import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:time_vault/data/models/leisure_ledger.dart';

import 'package:time_vault/data/db/app_db.dart';

class LeisureLedgerDao {
  LeisureLedgerDao._();

  static final LeisureLedgerDao instance = LeisureLedgerDao._();

  Future<int> insert(LeisureLedger entry) async {
    final db = await AppDb.instance.database;
    return db.insert(
      LeisureLedgerFields.table,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Total remaining seconds (sum of deltaSec)
  Future<int> getAvailableTime() async {
    final db = await AppDb.instance.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(${LeisureLedgerFields.deltaSec}), 0) AS remaining
      FROM ${LeisureLedgerFields.table}
    ''');

    final remaining = result.first['remaining'] as int? ?? 0;
    return remaining;
  }
}

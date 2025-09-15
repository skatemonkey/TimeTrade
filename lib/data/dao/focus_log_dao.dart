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
}

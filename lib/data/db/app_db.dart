import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

import 'package:time_vault/core/db_constants.dart';


class AppDb {
  AppDb._init();
  static final AppDb instance = AppDb._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hello_world.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    // Documents directory
    final docDir = await getApplicationDocumentsDirectory();
    final dbPath = '${docDir.path}/$fileName';

    // Init FFI for desktop/CLI
    sqfliteFfiInit();
    final databaseFactory = databaseFactoryFfi;

    // Open DB
    return databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(DbConstants().focusLogTableCreation);
          await db.execute(DbConstants().leisureLedgerTableCreation);
          await db.execute(DbConstants().pointsLedgerCreation);
        },
      ),
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

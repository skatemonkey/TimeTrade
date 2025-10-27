import 'package:time_vault/data/models/focus_log.dart';
import 'package:time_vault/data/models/leisure_ledger.dart';

import '../data/models/life_pillar.dart';
import '../data/models/points_ledger.dart';

class DbConstants {
  String focusLogTableCreation =
      '''
        CREATE TABLE ${FocusLogFields.table}
        (
            ${FocusLogFields.id}           INTEGER PRIMARY KEY AUTOINCREMENT,
            ${FocusLogFields.startTs}      INTEGER NOT NULL,
            ${FocusLogFields.endTs}        INTEGER NOT NULL,
            ${FocusLogFields.duration}     REAL    NOT NULL,
            ${FocusLogFields.lifePillarId} INTEGER NOT NULL,
            FOREIGN KEY (${FocusLogFields.lifePillarId})
                REFERENCES ${LifePillarFields.table} (${LifePillarFields.id})
                ON DELETE CASCADE
                ON UPDATE CASCADE
        );
          ''';
  String leisureLedgerTableCreation =
      '''
        CREATE TABLE ${LeisureLedgerFields.table}
        (
            ${LeisureLedgerFields.id}        INTEGER PRIMARY KEY AUTOINCREMENT,
            ${LeisureLedgerFields.ts}        INTEGER NOT NULL,
            ${LeisureLedgerFields.deltaSec}  INTEGER NOT NULL
        );
        ''';
  String pointsLedgerCreation =
      '''
        CREATE TABLE ${PointsLedgerFields.table}
        (
            ${PointsLedgerFields.id}      INTEGER PRIMARY KEY AUTOINCREMENT,
            ${PointsLedgerFields.ts}      INTEGER NOT NULL,
            ${PointsLedgerFields.source}  TEXT,
            ${PointsLedgerFields.refType} TEXT,
            ${PointsLedgerFields.refId}   INTEGER,
            ${PointsLedgerFields.delta}   REAL NOT NULL
        );
        ''';

  String lifePillarTableCreation = '''
        CREATE TABLE ${LifePillarFields.table}
        (
            ${LifePillarFields.id}          INTEGER PRIMARY KEY AUTOINCREMENT,
            ${LifePillarFields.name}        TEXT    NOT NULL,
            ${LifePillarFields.scoreWeight} REAL    NOT NULL,
            ${LifePillarFields.isActive}    INTEGER NOT NULL,
            ${LifePillarFields.sortOrder}   INTEGER NOT NULL,
            ${LifePillarFields.createdTs}   INTEGER NOT NULL,
            ${LifePillarFields.updatedTs}   INTEGER NOT NULL
        );
        ''';

}

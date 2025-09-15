import 'package:time_vault/data/models/focus_log.dart';
import 'package:time_vault/data/models/leisure_ledger.dart';

import '../data/models/points_ledger.dart';

class DbConstants {
  String focusLogTableCreation =
      '''
          CREATE TABLE ${FocusLogFields.table}
          (
              ${FocusLogFields.id}        INTEGER PRIMARY KEY AUTOINCREMENT,
              ${FocusLogFields.startTs}   INTEGER NOT NULL,
              ${FocusLogFields.endTs}     INTEGER NOT NULL,
              ${FocusLogFields.duration}  REAL NOT NULL
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
}

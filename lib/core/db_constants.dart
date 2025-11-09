import 'package:time_vault/data/models/focus_log.dart';
import 'package:time_vault/data/models/leisure_ledger.dart';

import '../data/models/habit.dart';
import '../data/models/habit_log.dart';
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

  String habitTableCreation = '''
        CREATE TABLE ${HabitFields.table}
        (
            ${HabitFields.id}           INTEGER PRIMARY KEY AUTOINCREMENT,
            ${HabitFields.name}         TEXT    NOT NULL,
            ${HabitFields.scoreWeight}  REAL    NOT NULL,
            ${HabitFields.createdTs}    INTEGER NOT NULL,
            ${HabitFields.updatedTs}    INTEGER NOT NULL
        );
        ''';


  String habitLogTableCreation = '''
        CREATE TABLE ${HabitLogFields.table}
        (
            ${HabitLogFields.id}         INTEGER PRIMARY KEY AUTOINCREMENT,
            ${HabitLogFields.habitId}    INTEGER NOT NULL,
            ${HabitLogFields.date}       TEXT    NOT NULL,
            ${HabitLogFields.note}       TEXT,
            ${HabitLogFields.createdTs}  INTEGER NOT NULL,
            FOREIGN KEY(${HabitLogFields.habitId}) REFERENCES ${HabitFields.table}(${HabitFields.id}) ON DELETE CASCADE,
            UNIQUE(${HabitLogFields.habitId}, ${HabitLogFields.date})
        );
        ''';



}

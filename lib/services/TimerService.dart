// timer_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:time_vault/data/dao/focus_log_dao.dart';
import 'package:time_vault/data/dao/leisure_ledger_dao.dart';
import 'package:time_vault/data/dao/points_ledger_dao.dart';

import 'package:time_vault/data/models/focus_log.dart';
import 'package:time_vault/data/models/leisure_ledger.dart';
import 'package:time_vault/data/models/points_ledger.dart';

enum SessionType { none, focus, entertainment }

class TimerService extends ChangeNotifier {
  // ===== Shared ticker =====
  Timer? _ticker;

  void _ensureTicker() {
    _ticker ??= Timer.periodic(const Duration(milliseconds: 200), (_) {
      // one ticker drives both modes
      notifyListeners();
    });
  }

  void _stopTickerIfIdle() {
    if (!_focusRunning && _entActive != SessionType.entertainment) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  // ===== Focus (count-up) =====
  bool _focusRunning = false;
  DateTime? _focusStartedAt;
  Duration _focusAccumulated = Duration.zero;

  bool get isFocusRunning => _focusRunning;

  DateTime? get startedAt => _focusStartedAt; // used by your DB page

  Duration get elapsed {
    if (!_focusRunning || _focusStartedAt == null) return _focusAccumulated;
    return _focusAccumulated + DateTime.now().difference(_focusStartedAt!);
  }

  void startFocus() {
    if (_focusRunning) return;
    _focusRunning = true;
    _focusStartedAt ??= DateTime.now();
    _ensureTicker();
    notifyListeners();
  }

  Future<void> stopFocusAndReset() async {
    final s = startedAt;
    final int startTs =
        s?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;

    final endTs = DateTime.now().millisecondsSinceEpoch;
    final entry = FocusLog(
      startTs: startTs,
      endTs: endTs,
      duration: double.parse(
        (elapsed.inMilliseconds / 1000).toStringAsFixed(2),
      ),
    );
    final id = await FocusLogDao.instance.insert(entry);

    final pointEntry = PointsLedger(
      ts: endTs,
      source: 'earn',
      refType: 'time',
      refId: id,
      delta: PointsLedger.pointsFromDuration(elapsed),
    );
    await PointsLedgerDao.instance.insert(pointEntry);
    print(
      'Saved time entry $id  duration=$elapsed  points=${pointEntry.delta}',
    );

    _focusRunning = false;
    _focusStartedAt = null;
    _focusAccumulated = Duration.zero;
    _stopTickerIfIdle();
    notifyListeners();
  }

  // ===== Entertainment (count-down) =====
  SessionType _entActive = SessionType.none;
  DateTime? _entStartedAt;
  int _entStartRemainingSec = 0; // snapshot at start

  bool get isEntertainmentRunning => _entActive == SessionType.entertainment;

  /// Remaining seconds while running (derived from start snapshot)
  int get entertainmentLeftSec {
    if (!isEntertainmentRunning || _entStartedAt == null) return 0;
    final used = DateTime.now().difference(_entStartedAt!).inSeconds;
    final left = (_entStartRemainingSec - used).clamp(0, _entStartRemainingSec);
    return left;
  }

  /// Begin countdown with a provided current balance (in seconds).
  void startEntertainment(int currentBalanceSec) {
    if (isEntertainmentRunning || currentBalanceSec <= 0) return;
    _entStartRemainingSec = currentBalanceSec;
    _entStartedAt = DateTime.now();
    _entActive = SessionType.entertainment;
    _ensureTicker();
    notifyListeners();
  }

  /// Stop countdown and return actual seconds used (so the page can commit to DB).
  Future<int> stopEntertainmentAndGetUsed() async {
    if (!isEntertainmentRunning || _entStartedAt == null) return 0;

    final used = DateTime.now()
        .difference(_entStartedAt!)
        .inSeconds
        .clamp(0, _entStartRemainingSec);
    final entry = LeisureLedger(
      ts: DateTime.now().millisecondsSinceEpoch,
      deltaSec: -used,
    );
    print('Saved entertainment time entry  duration=$used ');
    await LeisureLedgerDao.instance.insert(entry);

    _entActive = SessionType.none;
    _entStartedAt = null;
    _entStartRemainingSec = 0;

    _stopTickerIfIdle();
    notifyListeners();
    return used;
  }
}

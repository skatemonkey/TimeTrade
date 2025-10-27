// timer_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:time_vault/data/dao/focus_log_dao.dart';
import 'package:time_vault/data/dao/leisure_ledger_dao.dart';
import 'package:time_vault/data/dao/points_ledger_dao.dart';

import 'package:time_vault/data/models/focus_log.dart';
import 'package:time_vault/data/models/leisure_ledger.dart';
import 'package:time_vault/data/models/points_ledger.dart';

// ADD THESE:
import 'package:time_vault/data/dao/life_pillar_dao.dart';
import 'package:time_vault/data/models/life_pillar.dart';

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

    // NOTE: ensure your FocusLog model has a `lifePillarId` field/param.
    final entry = FocusLog(
      startTs: startTs,
      endTs: endTs,
      duration: double.parse(
        (elapsed.inMilliseconds / 1000).toStringAsFixed(2),
      ),
      lifePillarId: _selectedLifePillarId ?? 1, // <-- add this
    );
    final id = await FocusLogDao.instance.insert(entry);

    final pointEntry = PointsLedger(
      ts: endTs,
      source: 'earn',
      refType: 'time',
      refId: id,
      delta: PointsLedger.pointsFromDuration(
        elapsed,
        _selectedPillarWeightOrDefault(),
      ),
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

  // ===== Life Pillars (owned here so selection persists) =====
  List<LifePillar> _pillars = [];
  bool _pillarsLoaded = false;
  int? _selectedLifePillarId = 1; // default to pillar 1

  List<LifePillar> get pillars => _pillars;

  int? get selectedLifePillarId => _selectedLifePillarId;

  /// Load once (call from page init with: `svc.ensurePillarsLoaded()`).
  Future<void> ensurePillarsLoaded() async {
    if (_pillarsLoaded) return;
    _pillars = await LifePillarDao.instance.getAll();

    if (_pillars.isEmpty) {
      _selectedLifePillarId = null;
    } else if (!_pillars.any((p) => p.id == 1)) {
      _selectedLifePillarId = _pillars.first.id;
    } else {
      _selectedLifePillarId = 1;
    }

    _pillarsLoaded = true;
    notifyListeners();
  }

  /// Force reload after CRUD elsewhere.
  Future<void> reloadPillars() async {
    _pillarsLoaded = false;
    await ensurePillarsLoaded();
  }

  void setLifePillar(int id) {
    if (_selectedLifePillarId == id) return;
    _selectedLifePillarId = id;
    notifyListeners();
  }

  double _selectedPillarWeightOrDefault() {
    final id = _selectedLifePillarId;
    if (id == null) return 1.0;

    final idx = _pillars.indexWhere((p) => p.id == id);
    if (idx == -1) return 1.0;

    // Treat this as “points per minute” (or a multiplier) defined on the pillar
    return _pillars[idx].scoreWeight;
  }
}


class FocusLogFields {
  static const String table = 'focus_log';

  static final String id = 'id';
  static final String startTs = 'start_ts';
  static final String endTs = 'end_ts';
  static final String duration = 'duration';
  static final String lifePillarId = 'life_pillar_id';
}

class FocusLog {
  final int? id;
  final int startTs;
  final int endTs;
  final double duration;
  final int lifePillarId;


  FocusLog({
    this.id,
    required this.startTs,
    required this.endTs,
    required this.duration,
    required this.lifePillarId
  });

  Map<String, Object?> toMap() {
    return {
      FocusLogFields.id: id,
      FocusLogFields.startTs: startTs,
      FocusLogFields.endTs: endTs,
      FocusLogFields.duration: duration,
      FocusLogFields.lifePillarId: lifePillarId,
    };
  }

  factory FocusLog.fromMap(Map<String, Object?> map) {
    return FocusLog(
      id: map[FocusLogFields.id] as int?,
      startTs: map[FocusLogFields.startTs] as int,
      endTs: map[FocusLogFields.endTs] as int,
      duration: map[FocusLogFields.duration] as double,
      lifePillarId: map[FocusLogFields.lifePillarId] as int,
    );
  }
}

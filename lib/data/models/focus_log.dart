import 'package:time_vault/core/date_utils.dart';

class FocusLogFields {
  static const String table = 'focus_log';

  static final String id = 'id';
  static final String startTs = 'start_ts';
  static final String endTs = 'end_ts';
  static final String duration = 'duration';
}

class FocusLog {
  final int? id;
  final int startTs;
  final int endTs;
  final double duration;

  FocusLog({
    this.id,
    required this.startTs,
    required this.endTs,
    required this.duration,
  });

  Map<String, Object?> toMap() {
    return {
      FocusLogFields.id: id,
      FocusLogFields.startTs: startTs,
      FocusLogFields.endTs: endTs,
      FocusLogFields.duration: duration,
    };
  }

  factory FocusLog.fromMap(Map<String, Object?> map) {
    return FocusLog(
      id: map[FocusLogFields.id] as int?,
      startTs: map[FocusLogFields.startTs] as int,
      endTs: map[FocusLogFields.endTs] as int,
      duration: map[FocusLogFields.duration] as double,
    );
  }
}

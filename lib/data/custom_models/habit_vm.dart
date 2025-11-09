class HabitVm {
  final int id;
  final String name;
  final double scoreWeight;

  /// Timestamps from Habit table
  final int createdTs;
  final int updatedTs;

  /// Today’s state from habit_log
  final bool completedToday; // true if completed=1 for today
  final int? todayLogId;     // null if no log row for today

  const HabitVm({
    required this.id,
    required this.name,
    required this.scoreWeight,
    required this.createdTs,
    required this.updatedTs,
    required this.completedToday,
    this.todayLogId,
  });

  /// Build from JOIN query row:
  /// SELECT h.id AS habit_id, h.name, h.score_weight AS weight,
  ///        h.created_ts, h.updated_ts,
  ///        hl.id AS log_id, COALESCE(hl.completed,0) AS completed_today
  factory HabitVm.fromJoinRow(Map<String, Object?> row) {
    num _num(Object? v) => (v as num); // convenience cast

    return HabitVm(
      id: _num(row['habit_id']).toInt(),
      name: (row['name'] as String),
      scoreWeight: _num(row['weight']).toDouble(),
      createdTs: _num(row['created_ts']).toInt(),
      updatedTs: _num(row['updated_ts']).toInt(),
      todayLogId: row['log_id'] == null ? null : _num(row['log_id']).toInt(),
      completedToday: _num(row['completed_today']).toInt() == 1,
    );
  }

  HabitVm copyWith({
    int? id,
    String? name,
    double? scoreWeight,
    int? createdTs,
    int? updatedTs,
    bool? completedToday,
    int? todayLogId,
  }) {
    return HabitVm(
      id: id ?? this.id,
      name: name ?? this.name,
      scoreWeight: scoreWeight ?? this.scoreWeight,
      createdTs: createdTs ?? this.createdTs,
      updatedTs: updatedTs ?? this.updatedTs,
      completedToday: completedToday ?? this.completedToday,
      todayLogId: todayLogId ?? this.todayLogId,
    );
  }
}

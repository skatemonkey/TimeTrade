class HabitVm {
  final int id;
  final String name;
  final double scoreWeight;

  /// Today’s state from habit_log
  final bool completedToday;      // true if completed=1 for today
  final int? todayLogId;          // null if no log row for today

  const HabitVm({
    required this.id,
    required this.name,
    required this.scoreWeight,
    required this.completedToday,
    this.todayLogId,
  });

  /// Build from the custom JOIN row you queried:
  /// SELECT h.id AS habit_id, h.name AS name, h.score_weight AS weight,
  ///        hl.id AS log_id, COALESCE(hl.completed,0) AS completed_today
  factory HabitVm.fromJoinRow(Map<String, Object?> row) {
    num _num(Object? v) => (v as num); // convenience cast

    return HabitVm(
      id: _num(row['habit_id']).toInt(),
      name: (row['name'] as String),
      scoreWeight: _num(row['weight']).toDouble(),
      todayLogId: row['log_id'] == null ? null : _num(row['log_id']).toInt(),
      completedToday: _num(row['completed_today']).toInt() == 1,
    );
  }

  HabitVm copyWith({
    int? id,
    String? name,
    double? scoreWeight,
    bool? completedToday,
    int? todayLogId,
  }) {
    return HabitVm(
      id: id ?? this.id,
      name: name ?? this.name,
      scoreWeight: scoreWeight ?? this.scoreWeight,
      completedToday: completedToday ?? this.completedToday,
      todayLogId: todayLogId ?? this.todayLogId,
    );
  }
}

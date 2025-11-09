class HabitLogFields {
  static const String table = 'habit_log';

  static const String id = 'id';
  static const String habitId = 'habit_id';
  static const String date = 'date';
  static const String note = 'note';
  static const String createdTs = 'created_ts';
}

class HabitLog {
  final int? id;
  final int habitId;
  final String date;
  final String? note;
  final int createdTs;

  HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    this.note,
    required this.createdTs,
  });

  Map<String, Object?> toMap() {
    return {
      HabitLogFields.id: id,
      HabitLogFields.habitId: habitId,
      HabitLogFields.date: date,
      HabitLogFields.note: note,
      HabitLogFields.createdTs: createdTs,
    };
  }

  factory HabitLog.fromMap(Map<String, Object?> map) {
    return HabitLog(
      id: map[HabitLogFields.id] as int?,
      habitId: map[HabitLogFields.habitId] as int,
      date: map[HabitLogFields.date] as String,
      note: map[HabitLogFields.note] as String?,
      createdTs: map[HabitLogFields.createdTs] as int,
    );
  }
}

class HabitFields {
  static const String table = 'habit';

  static const String id = 'id';
  static const String name = 'name';
  static const String scoreWeight = 'score_weight';
  static const String createdTs = 'created_ts';
  static const String updatedTs = 'updated_ts';
}

class Habit {
  final int? id;
  final String name;
  final double scoreWeight;
  final int createdTs;
  final int updatedTs;

  Habit({
    this.id,
    required this.name,
    required this.scoreWeight,
    required this.createdTs,
    required this.updatedTs,
  });

  Map<String, Object?> toMap() {
    return {
      HabitFields.id: id,
      HabitFields.name: name,
      HabitFields.scoreWeight: scoreWeight,
      HabitFields.createdTs: createdTs,
      HabitFields.updatedTs: updatedTs,
    };
  }

  factory Habit.fromMap(Map<String, Object?> map) {
    return Habit(
      id: map[HabitFields.id] as int?,
      name: map[HabitFields.name] as String,
      scoreWeight: map[HabitFields.scoreWeight] as double,
      createdTs: map[HabitFields.createdTs] as int,
      updatedTs: map[HabitFields.updatedTs] as int,
    );
  }
}

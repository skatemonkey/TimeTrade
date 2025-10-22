class LifePillarFields {
  static const String table = 'life_pillar';

  static const String id = 'id';
  static const String name = 'name';
  static const String scoreWeight = 'score_weight';
  static const String isActive = 'is_active';
  static const String sortOrder = 'sort_order';
  static const String createdTs = 'created_ts';
  static const String updatedTs = 'updated_ts';
}

class LifePillar {
  final int? id;
  final String name;
  final double scoreWeight;
  final int isActive;
  final int sortOrder;
  final int createdTs;
  final int updatedTs;

  LifePillar({
    this.id,
    required this.name,
    required this.scoreWeight,
    required this.isActive,
    required this.sortOrder,
    required this.createdTs,
    required this.updatedTs,
  });

  Map<String, Object?> toMap() {
    return {
      LifePillarFields.id: id,
      LifePillarFields.name: name,
      LifePillarFields.scoreWeight: scoreWeight,
      LifePillarFields.isActive: isActive,
      LifePillarFields.sortOrder: sortOrder,
      LifePillarFields.createdTs: createdTs,
      LifePillarFields.updatedTs: updatedTs,
    };
  }

  factory LifePillar.fromMap(Map<String, Object?> map) {
    return LifePillar(
      id: map[LifePillarFields.id] as int?,
      name: map[LifePillarFields.name] as String,
      scoreWeight: map[LifePillarFields.scoreWeight] as double,
      isActive: map[LifePillarFields.isActive] as int,
      sortOrder: map[LifePillarFields.sortOrder] as int,
      createdTs: map[LifePillarFields.createdTs] as int,
      updatedTs: map[LifePillarFields.updatedTs] as int,
    );
  }
}

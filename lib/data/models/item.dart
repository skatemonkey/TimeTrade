// item.dart

class ItemFields {
  static const String table = 'items';

  static const String id = 'id';
  static const String key = 'key';
  static const String name = 'name';
  static const String description = 'description';
  static const String costPoints = 'cost_points';
  static const String createdTs = 'created_ts';
  static const String updatedTs = 'updated_ts';

  static const List<String> values = [
    id,
    key,
    name,
    description,
    costPoints,
    createdTs,
    updatedTs,
  ];
}

class Item {
  final int? id;
  final String? key;
  final String name;
  final String? description;
  final double costPoints;
  final int createdTs;
  final int updatedTs;

  Item({
    this.id,
    this.key,
    required this.name,
    this.description,
    required this.costPoints,
    required this.createdTs,
    required this.updatedTs,
  });

  Item copyWith({
    int? id,
    String? key,
    String? name,
    String? description,
    double? costPoints,
    int? createdTs,
    int? updatedTs,
  }) {
    return Item(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      description: description ?? this.description,
      costPoints: costPoints ?? this.costPoints,
      createdTs: createdTs ?? this.createdTs,
      updatedTs: updatedTs ?? this.updatedTs,
    );
  }

  Map<String, Object?> toMap() {
    return {
      ItemFields.id: id,
      ItemFields.key: key,
      ItemFields.name: name,
      ItemFields.description: description,
      ItemFields.costPoints: costPoints,
      ItemFields.createdTs: createdTs,
      ItemFields.updatedTs: updatedTs,
    };
  }

  factory Item.fromMap(Map<String, Object?> map) {
    return Item(
      id: map[ItemFields.id] as int?,
      key: map[ItemFields.key] as String,
      name: map[ItemFields.name] as String,
      description: map[ItemFields.description] as String?,
      costPoints: map[ItemFields.costPoints] as double,
      createdTs: map[ItemFields.createdTs] as int,
      updatedTs: map[ItemFields.updatedTs] as int,
    );
  }
}

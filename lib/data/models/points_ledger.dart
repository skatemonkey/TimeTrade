class PointsLedgerFields {
  static const String table = 'points_ledger';

  static const String id = 'id';
  static const String ts = 'ts'; // formatted timestamp string
  static const String source = 'source'; // 'earn' | 'spend' | 'adjust'
  static const String refType = 'ref_type'; // e.g. 'time' | 'purchase'
  static const String refId = 'ref_id'; // parent id when refType != null
  static const String delta = 'delta'; // +earned / -spent
}

class PointsLedger {
  final int? id;
  final int ts;
  final String source; // 'earn' | 'spend' | 'adjust'
  final String? refType;
  final int? refId;
  final double delta; // integer points (+/-)

  const PointsLedger({
    this.id,
    required this.ts,
    required this.source,
    this.refType,
    this.refId,
    required this.delta,
  });

  Map<String, Object?> toMap() {
    return {
      PointsLedgerFields.id: id,
      PointsLedgerFields.ts: ts,
      PointsLedgerFields.source: source,
      PointsLedgerFields.refType: refType,
      PointsLedgerFields.refId: refId,
      PointsLedgerFields.delta: delta,
    };
  }

  factory PointsLedger.fromMap(Map<String, Object?> map) {
    return PointsLedger(
      id: map[PointsLedgerFields.id] as int?,
      ts: map[PointsLedgerFields.ts] as int,
      source: map[PointsLedgerFields.source] as String,
      refType: map[PointsLedgerFields.refType] as String?,
      refId: map[PointsLedgerFields.refId] as int?,
      delta: (map[PointsLedgerFields.delta] as double),
    );
  }

  static double pointsFromDuration(Duration d) {
    final points = d.inSeconds / 3600; //todo rmb to change to3600 seconds = 1 hour 1 point
    return double.parse(points.toStringAsFixed(2));
  }
}

class LeisureLedgerFields {
  static const String table = 'leisure_ledger';

  static const String id = 'id';
  static const String ts = 'ts';
  static const String deltaSec = 'deltaSec';
}

class LeisureLedger {
  final int? id;
  final int ts;
  final int deltaSec;

  LeisureLedger({this.id, required this.ts, required this.deltaSec});

  Map<String, Object?> toMap() => {
    LeisureLedgerFields.id: id,
    LeisureLedgerFields.ts: ts,
    LeisureLedgerFields.deltaSec: deltaSec,
  };

  static LeisureLedger fromMap(Map<String, Object?> map) => LeisureLedger(
    id: map[LeisureLedgerFields.id] as int?,
    ts: map[LeisureLedgerFields.ts] as int,
    deltaSec: map[LeisureLedgerFields.deltaSec] as int,
  );
}

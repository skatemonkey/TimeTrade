import 'package:intl/intl.dart';

/// Internal helper to build the shared DateFormat.
DateFormat _buildTimeEntryFormatter() =>
    DateFormat("yyyy-MM-dd'T'HH:mm:ss.SS");

/// Convert DateTime → String (for database storage).
String formatDate(DateTime ts) =>
    _buildTimeEntryFormatter().format(ts);

/// Convert String → DateTime (for database retrieval).
DateTime parseDate(String raw) =>
    _buildTimeEntryFormatter().parse(raw);

final DateFormat _formatter = DateFormat('yyyy-MM-dd\n HH:mm:ss');

String formatTimestamp(int millis) {
  final date = DateTime.fromMillisecondsSinceEpoch(millis);
  return _formatter.format(date);
}


String formatDate1(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = two(d.inHours);
  final m = two(d.inMinutes.remainder(60));
  final s = two(d.inSeconds.remainder(60));
  return '$h:$m:$s';
}


String formatHMS(int totalSec) {
  final h = totalSec ~/ 3600;
  final m = (totalSec % 3600) ~/ 60;
  final s = totalSec % 60;
  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

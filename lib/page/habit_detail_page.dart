import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/custom_models/habit_vm.dart';
import '../data/dao/habit_log_dao.dart';
import '../data/dao/points_ledger_dao.dart';
import '../data/models/points_ledger.dart';

class HabitDetailPage extends StatefulWidget {
  final HabitVm vm;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitDetailPage({
    super.key,
    required this.vm,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> {
  final Set<DateTime> _completedDays = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedDays();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  String _format(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _loadCompletedDays() async {
    setState(() => _loading = true);
    try {
      final dates = await HabitLogDao.instance.getDatesForHabit(widget.vm.id);
      _completedDays
        ..clear()
        ..addAll(
          dates.map((s) {
            final p = s.split('-').map(int.parse).toList();
            return _normalize(DateTime(p[0], p[1], p[2]));
          }),
        );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load habit logs: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleDay(DateTime day) async {
    final d = _normalize(day);
    final dateStr = _format(d);
    final already = _completedDays.contains(d);

    try {
      if (already) {
        await HabitLogDao.instance.deleteToday(widget.vm.id, dateStr);
        _completedDays.remove(d);

        await PointsLedgerDao.instance.insert(
          PointsLedger(
            ts: DateTime.now().millisecondsSinceEpoch,
            source: 'undo',
            refType: 'habit',
            refId: widget.vm.id,
            delta: -widget.vm.scoreWeight,
          ),
        );
      } else {
        await HabitLogDao.instance.upsertCompleted(widget.vm.id, dateStr);
        _completedDays.add(d);

        await PointsLedgerDao.instance.insert(
          PointsLedger(
            ts: DateTime.now().millisecondsSinceEpoch,
            source: 'earn',
            refType: 'habit',
            refId: widget.vm.id,
            delta: widget.vm.scoreWeight,
          ),
        );
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update day: $e')));
    }
  }

  List<Object> _eventLoader(DateTime day) {
    return _completedDays.contains(_normalize(day)) ? [Object()] : [];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.vm.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: widget.onEdit,
                    tooltip: 'Edit habit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete habit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: widget.onBack,
                    tooltip: 'Back',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Calendar
          TableCalendar(
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) =>
                _selectedDay != null && _normalize(d) == _selectedDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = _normalize(selectedDay);
                _focusedDay = focusedDay;
              });
              _toggleDay(selectedDay);
            },
            eventLoader: _eventLoader,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                return Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 18,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 18,
              ),
              const SizedBox(width: 6),
              const Text('Completed days'),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:time_vault/page/template_page.dart';

import '../app_colors.dart';
import '../data/custom_models/habit_vm.dart';
import '../data/dao/habit_dao.dart';
import '../data/dao/habit_log_dao.dart';
import '../data/dao/points_ledger_dao.dart';
import '../data/models/habit.dart';
import '../data/models/points_ledger.dart';
import '../widgets/AddHabitDialog.dart';
import '../widgets/add_button.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_check.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  bool _isLoading = true;
  final List<HabitVm> _habits = [];

  final Set<int> _loadingHabitIds = {};
  bool _isCardLoading(int id) => _loadingHabitIds.contains(id);


  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);


    try {
      // Format today's date as YYYY-MM-DD
      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      final today = '${now.year}-${two(now.month)}-${two(now.day)}';

      // Query the DB for all habits with today's completion status
      final rows = await HabitDao.instance.getAllWithTodayStatus(today);

      // Map query result into HabitVm objects
      final items = rows.map((row) => HabitVm.fromJoinRow(row)).toList();

      if (!mounted) return;
      setState(() {
        _habits
          ..clear()
          ..addAll(items);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load habits: $e')),
      );
    }
  }

  Future<void> _toggleToday(HabitVm vm, bool newValue) async {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final today = '${now.year}-${two(now.month)}-${two(now.day)}';

    if (_isCardLoading(vm.id)) return; // avoid double taps
    setState(() => _loadingHabitIds.add(vm.id));

    try {
      // 1️⃣ Update habit_log
      if (newValue) {
        await HabitLogDao.instance.upsertCompleted(vm.id, today);
      } else {
        await HabitLogDao.instance.deleteToday(vm.id, today);
      }

      // 2️⃣ Update local VM (no reload)
      final i = _habits.indexWhere((h) => h.id == vm.id);
      if (i != -1) {
        _habits[i] = _habits[i].copyWith(completedToday: newValue);
      }

      // 3️⃣ Add record to points_ledger
      final ledger = PointsLedger(
        ts: DateTime.now().millisecondsSinceEpoch,
        source: newValue ? 'earn' : 'undo', // ✅ differentiate
        refType: 'habit',
        refId: vm.id,
        delta: newValue ? vm.scoreWeight : -vm.scoreWeight,
      );

      await PointsLedgerDao.instance.insert(ledger);

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingHabitIds.remove(vm.id));
    }
  }








  @override
  Widget build(BuildContext context) {
    return TemplatePage(title: "Habit",
      actions: [
        AddButton<Habit>(
          showDialogFn: (context) => showDialog<Habit>(
            context: context,
            builder: (_) => const AddHabitDialog(isEdit: false),
          ),
          onInsert: (habit) => HabitDao.instance.insert(habit),
          onReload: () => setState(() => _loadHabits()),
        ),
      ],



      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
          ? const Center(child: Text('No habits yet'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260, // controls how many per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _habits.length,
          itemBuilder: (context, i) {
            final vm = _habits[i];
            return HabitCard(
              vm: vm,
              isLoading: _isCardLoading(vm.id),
              onToggleToday: (v) => _toggleToday(vm, v),
              onTap: () {
                // TODO: navigate to details (optional)
              },


            );
          },
        ),
      ),



    );
  }
}

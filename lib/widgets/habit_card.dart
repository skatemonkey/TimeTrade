import 'package:flutter/material.dart';
import '../data/custom_models/habit_vm.dart';
import 'habit_check.dart';
import 'action_menu_button.dart';

class HabitCard extends StatelessWidget {
  final HabitVm vm;
  final bool isLoading;
  final VoidCallback? onTap;
  final ValueChanged<bool> onToggleToday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.vm,
    required this.isLoading,
    required this.onToggleToday,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = vm.completedToday
        ? Colors.green[50]
        : Theme.of(context).colorScheme.surface;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: bg,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top Row: name + check ───
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      vm.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  HabitCheck(
                    isLoading: isLoading,
                    value: vm.completedToday,
                    onChanged: onToggleToday,
                  ),
                ],
              ),

              const Spacer(),

              // ─── Bottom Row: info + menu ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: ${vm.scoreWeight}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  ActionMenuButton(
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/custom_models/habit_vm.dart';
import 'habit_check.dart';

class HabitCard extends StatelessWidget {
  final HabitVm vm;
  final bool isLoading;
  final VoidCallback? onTap;
  final ValueChanged<bool> onToggleToday;

  const HabitCard({
    super.key,
    required this.vm,
    required this.isLoading,
    required this.onToggleToday,
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
        onTap: onTap, // optional details
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                'Score Weight: ${vm.scoreWeight}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HabitCheck extends StatelessWidget {
  final bool isLoading;
  final bool value;
  final ValueChanged<bool> onChanged;

  const HabitCheck({
    super.key,
    required this.isLoading,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: isLoading
          ? const SizedBox(
        key: ValueKey('spinner'),
        width: 24,
        height: 24,
        child: Padding(
          padding: EdgeInsets.all(2),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      )
          : Checkbox(
        key: const ValueKey('checkbox'),
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

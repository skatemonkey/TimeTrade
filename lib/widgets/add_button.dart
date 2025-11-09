import 'package:flutter/material.dart';
import '../app_colors.dart';

class AddButton<T> extends StatelessWidget {
  final Future<T?> Function(BuildContext context) showDialogFn;
  final Future<void> Function(T item) onInsert;
  final VoidCallback onReload;
  final String label;

  const AddButton({
    super.key,
    required this.showDialogFn,
    required this.onInsert,
    required this.onReload,
    this.label = 'Add',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: FilledButton.icon(
        onPressed: () async {
          final created = await showDialogFn(context);
          if (created != null) {
            await onInsert(created);
            onReload();
          }
        },
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.softBlack,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }
}

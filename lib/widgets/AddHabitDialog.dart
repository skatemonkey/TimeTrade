import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../data/models/habit.dart';

class AddHabitDialog extends StatefulWidget {
  final Habit? existingItem;
  final bool isEdit;

  const AddHabitDialog({super.key, this.existingItem, this.isEdit = false});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingItem?.name ?? '');
    _weightCtrl = TextEditingController(
      text: widget.existingItem?.scoreWeight.toString() ?? '1.0',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEdit ? 'Edit Habit' : 'Add Habit';
    final buttonLabel = widget.isEdit ? 'Update' : 'Save';

    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.softBlack,
        ),
      ),
      backgroundColor: AppColors.pill,
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Habit Name'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Score Weight'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final d = double.tryParse(v);
                  if (d == null) return 'Enter a number';
                  if (d <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.softBlack),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.softBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final now = DateTime.now().millisecondsSinceEpoch;

              final item = Habit(
                id: widget.existingItem?.id,
                name: _nameCtrl.text.trim(),
                scoreWeight: double.parse(_weightCtrl.text),
                createdTs: widget.existingItem?.createdTs ?? now,
                updatedTs: now,
              );

              Navigator.pop(context, item);
            }
          },
          child: Text(
            buttonLabel,
            style: const TextStyle(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../data/models/life_pillar.dart';

class AddPillarDialog extends StatefulWidget {
  final LifePillar? existingItem;
  final bool isEdit;

  const AddPillarDialog({super.key, this.existingItem, this.isEdit = false});

  @override
  State<AddPillarDialog> createState() => _AddPillarDialogState();
}

class _AddPillarDialogState extends State<AddPillarDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _orderCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    _orderCtrl = TextEditingController(
      text: widget.existingItem?.sortOrder.toString() ?? '',
    );
    _nameCtrl = TextEditingController(text: widget.existingItem?.name ?? '');
    _weightCtrl = TextEditingController(
      text: widget.existingItem?.scoreWeight.toString() ?? '1.0',
    );
  }

  @override
  void dispose() {
    _orderCtrl.dispose();
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEdit ? 'Edit Life Pillar' : 'Add Life Pillar';
    final buttonLabel = widget.isEdit ? 'Update' : 'Save';

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _orderCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Order'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Enter a whole number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Life Pillar'),
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final now = DateTime.now().millisecondsSinceEpoch;

              final item = LifePillar(
                id: widget.existingItem?.id,
                name: _nameCtrl.text.trim(),
                scoreWeight: double.parse(_weightCtrl.text),
                isActive: widget.existingItem?.isActive ?? 1,
                sortOrder: int.parse(_orderCtrl.text),
                createdTs: widget.existingItem?.createdTs ?? now,
                updatedTs: now, // always update
              );

              Navigator.pop(context, item);
            }
          },
          child: Text(buttonLabel),
        ),
      ],
    );
  }
}

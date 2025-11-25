import 'package:flutter/material.dart';
import 'package:time_vault/data/models/item.dart';

import '../app_colors.dart';

class EditItemPriceDialog extends StatefulWidget {
  final Item item;

  const EditItemPriceDialog({super.key, required this.item});

  @override
  State<EditItemPriceDialog> createState() => _EditItemPriceDialogState();
}

class _EditItemPriceDialogState extends State<EditItemPriceDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item.costPoints.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() {
    final raw = _controller.text.trim();
    final parsed = double.tryParse(raw);

    if (parsed == null || parsed < 0) {
      setState(() {
        _errorText = 'Please enter a valid non negative number';
      });
      return;
    }

    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.pill, // dialog background
      title: Text('Edit price for "${widget.item.name}"'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Cost (points)',
          hintText: 'Enter new price',
          errorText: _errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.softBlack),
          ),
        ),
        TextButton(
          onPressed: _onSave,
          child: const Text(
            'Save',
            style: TextStyle(color: AppColors.softBlack),
          ),
        ),
      ],
    );
  }
}

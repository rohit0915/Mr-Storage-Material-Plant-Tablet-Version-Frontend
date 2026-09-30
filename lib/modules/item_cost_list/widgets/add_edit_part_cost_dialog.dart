import 'package:flutter/material.dart';
import '../model/item_cost_model.dart';

// Category and unit enums match the reference application's cost schema.
const costCategories = <String>['Insulation', 'Joist', 'Panels', 'TRIM', 'Mastic', 'Screws', 'ABolts', 'CLIPS', 'Cable', 'Flange_Brace', 'Jambs', 'DCOL', 'ZGIRT', 'OPEN CHANNEL', 'EaveStruts', 'ACCESSORIES', 'SKTLIGHT', 'ANGL1', 'TS_PANEL', 'frames'];

class AddEditPartCostDialog extends StatefulWidget {
  final ItemCostModel? itemToEdit;
  final Future<void> Function(ItemCostModel item) onSave;
  const AddEditPartCostDialog({super.key, this.itemToEdit, required this.onSave});
  @override
  State<AddEditPartCostDialog> createState() => _AddEditPartCostDialogState();
}
class _AddEditPartCostDialogState extends State<AddEditPartCostDialog> {
  final form = GlobalKey<FormState>();
  late String category = widget.itemToEdit?.category ?? '';
  late String unit = widget.itemToEdit?.costUnit ?? '';
  late final fields = <String, TextEditingController>{
    'Part name': TextEditingController(text: widget.itemToEdit?.partName ?? ''),
    'Part color': TextEditingController(text: widget.itemToEdit?.partColor ?? ''),
    'MBS cost': TextEditingController(text: widget.itemToEdit?.mbsCost?.toString() ?? ''),
    'Current market cost': TextEditingController(text: widget.itemToEdit?.currentMarketCost?.toString() ?? ''),
    'Labor cost': TextEditingController(text: widget.itemToEdit?.laborCost.toString() ?? ''),
    'Additional cost': TextEditingController(text: widget.itemToEdit?.additionalCost.toString() ?? ''),
    'Material cost': TextEditingController(text: widget.itemToEdit?.materialCost.toString() ?? ''),
    'Description': TextEditingController(text: widget.itemToEdit?.description ?? ''),
  };
  bool saving = false;
  String error = '';
  @override
  void dispose() { for (final field in fields.values) { field.dispose(); } super.dispose(); }
  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() { saving = true; error = ''; });
    String text(String name) => fields[name]!.text.trim();
    double number(String name) => double.parse(text(name));
    try {
      await widget.onSave(ItemCostModel(
        id: widget.itemToEdit?.id ?? '', category: category,
        partName: text('Part name'), partColor: category == 'frames' ? '' : text('Part color').isEmpty ? '--' : text('Part color'),
        costUnit: unit, mbsCost: number('MBS cost'), currentMarketCost: number('Current market cost'),
        laborCost: number('Labor cost'), additionalCost: number('Additional cost'), materialCost: number('Material cost'),
        description: text('Description'),
      ));
      if (mounted) Navigator.of(context).pop();
    } catch (e) { if (mounted) setState(() { error = e.toString(); }); }
    finally { if (mounted) setState(() { saving = false; }); }
  }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.itemToEdit == null ? 'Add new part cost' : 'Edit part cost'),
    content: SizedBox(width: 520, child: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [
      if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),
      DropdownButtonFormField<String>(initialValue: category.isEmpty ? null : category,
        decoration: const InputDecoration(labelText: 'Category'),
        items: <String>{...costCategories, if (category.isNotEmpty) category}.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
        validator: (value) => value == null || value.isEmpty ? 'Select a category.' : null,
        onChanged: saving ? null : (value) => setState(() { category = value ?? ''; })),
      DropdownButtonFormField<String>(initialValue: unit.isEmpty ? null : unit,
        decoration: const InputDecoration(labelText: 'Cost unit'),
        items: <String>{'FT', 'LB', 'EA', if (unit.isNotEmpty) unit}.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
        validator: (value) => value == null || value.isEmpty ? 'Select a unit.' : null,
        onChanged: saving ? null : (value) => unit = value ?? ''),
      for (final entry in fields.entries)
        if (entry.key != 'Part color' || category != 'frames')
          TextFormField(controller: entry.value, enabled: !saving,
            decoration: InputDecoration(labelText: entry.key),
            keyboardType: entry.key.endsWith('cost') ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            validator: (value) {
              if (entry.key == 'Part color') return null;
              if (entry.key.endsWith('cost')) {
                final parsed = double.tryParse(value ?? '');
                return parsed == null || !parsed.isFinite || parsed <= 0 ? 'Enter a cost greater than zero.' : null;
              }
              return value == null || value.trim().isEmpty ? '${entry.key} is required.' : null;
            }),
    ])))),
    actions: [TextButton(onPressed: saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
      ElevatedButton(onPressed: saving ? null : save, child: Text(saving ? 'Saving…' : 'Save'))],
  );
}

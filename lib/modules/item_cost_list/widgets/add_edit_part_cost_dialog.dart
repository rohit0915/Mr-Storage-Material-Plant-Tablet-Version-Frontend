import 'package:flutter/material.dart';

import '../model/item_cost_model.dart';

class AddEditPartCostDialog extends StatefulWidget {
  final ItemCostModel? itemToEdit;
  final Function(ItemCostModel item) onSave;

  const AddEditPartCostDialog({
    super.key,
    this.itemToEdit,
    required this.onSave,
  });

  @override
  State<AddEditPartCostDialog> createState() => _AddEditPartCostDialogState();
}

class _AddEditPartCostDialogState extends State<AddEditPartCostDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _partNameController;
  late TextEditingController _partColorController;
  late TextEditingController _costUnitController;
  late TextEditingController _mbsCostController;
  late TextEditingController _marketCostController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _partNameController = TextEditingController(text: item?.partName ?? "'30_VRR48'");
    _partColorController = TextEditingController(text: item?.partColor ?? "'-'");
    _costUnitController = TextEditingController(text: item?.costUnit ?? "'FT'");
    _mbsCostController = TextEditingController(
      text: item?.mbsCost != null ? item!.mbsCost.toString() : '2.9',
    );
    _marketCostController = TextEditingController(
      text: item?.currentMarketCost != null ? item!.currentMarketCost.toString() : '-',
    );
    _descriptionController = TextEditingController(text: item?.description ?? "'VRR+ Insul R10'");
  }

  @override
  void dispose() {
    _partNameController.dispose();
    _partColorController.dispose();
    _costUnitController.dispose();
    _mbsCostController.dispose();
    _marketCostController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.itemToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Part Cost' : 'Add New Part Cost',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Part Name'),
              const SizedBox(height: 6),
              _buildTextField(_partNameController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Part Color'),
                        const SizedBox(height: 6),
                        _buildTextField(_partColorController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Cost Unit'),
                        const SizedBox(height: 6),
                        _buildTextField(_costUnitController),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('MBS Cost'),
                        const SizedBox(height: 6),
                        _buildTextField(_mbsCostController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Current Market Cost'),
                        const SizedBox(height: 6),
                        _buildTextField(_marketCostController),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFieldLabel('Description'),
              const SizedBox(height: 6),
              _buildTextField(_descriptionController),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF475569),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _handleSave() {
    double? mbs = double.tryParse(_mbsCostController.text);
    double? market = double.tryParse(_marketCostController.text);

    final item = ItemCostModel(
      id: widget.itemToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      partName: _partNameController.text.trim(),
      partColor: _partColorController.text.trim(),
      costUnit: _costUnitController.text.trim(),
      mbsCost: mbs,
      currentMarketCost: market,
      description: _descriptionController.text.trim(),
    );

    widget.onSave(item);
    Navigator.of(context).pop();
  }
}

import 'package:flutter/material.dart';

import '../../../../domain/models/job_part.dart';
import '../../../../utils/result.dart';
import '../view_models/job_detail_viewmodel.dart';

/// Edits the per-use fields (unit cost, quantity, purchase date) of a part
/// already on the job — e.g. to add a price you forgot at first.
Future<void> showEditJobPartSheet(
  BuildContext context,
  JobDetailViewModel viewModel,
  JobPartLine line,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + media.viewInsets.bottom + media.padding.bottom,
        ),
        child: _EditJobPartForm(viewModel: viewModel, line: line),
      );
    },
  );
}

class _EditJobPartForm extends StatefulWidget {
  const _EditJobPartForm({required this.viewModel, required this.line});

  final JobDetailViewModel viewModel;
  final JobPartLine line;

  @override
  State<_EditJobPartForm> createState() => _EditJobPartFormState();
}

class _EditJobPartFormState extends State<_EditJobPartForm> {
  late final TextEditingController _unitCost;
  late final TextEditingController _quantity;
  late final TextEditingController _purchaseDateController;
  DateTime? _purchaseDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final link = widget.line.link;
    _unitCost = TextEditingController(
      text: link.unitCost != null ? link.unitCost!.toStringAsFixed(2) : '',
    );
    _quantity = TextEditingController(text: link.quantity.toString());
    _purchaseDate = link.purchaseDate;
    _purchaseDateController = TextEditingController(
      text: _purchaseDate != null
          ? _purchaseDate!.toIso8601String().substring(0, 10)
          : '',
    );
  }

  @override
  void dispose() {
    _unitCost.dispose();
    _quantity.dispose();
    _purchaseDateController.dispose();
    super.dispose();
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() {
        _purchaseDate = picked;
        _purchaseDateController.text = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final link = widget.line.link;
    // Build directly (not copyWith) so cost/date can be cleared to null.
    final updated = JobPart(
      id: link.id,
      jobId: link.jobId,
      partId: link.partId,
      unitCost: double.tryParse(_unitCost.text.replaceAll(',', '.')),
      quantity: int.tryParse(_quantity.text) ?? 1,
      purchaseDate: _purchaseDate,
    );

    final result = await widget.viewModel.updateJobPart(updated);
    if (!mounted) return;
    if (result is Error<void>) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save')),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.line.part.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _unitCost,
                  decoration: const InputDecoration(
                    labelText: 'Unit cost',
                    prefixText: '€ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _quantity,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _purchaseDateController,
            decoration: InputDecoration(
              labelText: 'Purchase date (optional)',
              suffixIcon: _purchaseDate == null
                  ? const Icon(Icons.calendar_today)
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _purchaseDate = null;
                        _purchaseDateController.clear();
                      }),
                    ),
            ),
            readOnly: true,
            onTap: _pickPurchaseDate,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              child: Text(_saving ? 'Saving…' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}

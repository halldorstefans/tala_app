import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../domain/models/part.dart';
import '../../../../utils/result.dart';
import '../view_models/job_detail_viewmodel.dart';

/// Bottom sheet to add a part to a job. Search the catalogue to reuse an
/// existing part, or fill in the fields to create a new one (with photos).
Future<void> showAddPartSheet(
  BuildContext context,
  JobDetailViewModel viewModel,
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
          // viewInsets covers the keyboard; padding.bottom covers the system
          // nav bar (and drops to 0 when the keyboard hides it).
          bottom: 24 + media.viewInsets.bottom + media.padding.bottom,
        ),
        child: _AddPartForm(viewModel: viewModel),
      );
    },
  );
}

class _AddPartForm extends StatefulWidget {
  const _AddPartForm({required this.viewModel});

  final JobDetailViewModel viewModel;

  @override
  State<_AddPartForm> createState() => _AddPartFormState();
}

class _AddPartFormState extends State<_AddPartForm> {
  final _formKey = GlobalKey<FormState>();
  final _search = TextEditingController();
  final _name = TextEditingController();
  final _partNumber = TextEditingController();
  final _brand = TextEditingController();
  final _supplier = TextEditingController();
  final _notes = TextEditingController();
  final _unitCost = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _purchaseDateController = TextEditingController();
  DateTime? _purchaseDate;
  final List<File> _photos = [];

  /// When set, an existing catalogue part is being reused (no new part or
  /// photos are created — only the link fields apply).
  Part? _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadCatalogue();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    for (final c in [
      _search,
      _name,
      _partNumber,
      _brand,
      _supplier,
      _notes,
      _unitCost,
      _quantity,
      _purchaseDateController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

  List<Part> get _matches {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return widget.viewModel.catalogue
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              (p.partNumber?.toLowerCase().contains(q) ?? false),
        )
        .take(6)
        .toList();
  }

  Future<void> _pickPhotos() async {
    final images = await ImagePicker().pickMultiImage(
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (images.isNotEmpty) {
      setState(() => _photos.addAll(images.map((x) => File(x.path))));
    }
  }

  Future<void> _takePhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _photos.add(File(image.path)));
    }
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final part =
        _selected ??
        Part(
          id: '',
          name: _name.text.trim(),
          partNumber: _nullIfEmpty(_partNumber.text),
          brand: _nullIfEmpty(_brand.text),
          supplier: _nullIfEmpty(_supplier.text),
          notes: _nullIfEmpty(_notes.text),
        );

    final result = await widget.viewModel.addPart(
      part: part,
      photos: _selected == null ? _photos : const [],
      unitCost: double.tryParse(_unitCost.text.replaceAll(',', '.')),
      quantity: int.tryParse(_quantity.text) ?? 1,
      purchaseDate: _purchaseDate,
    );

    if (!mounted) return;
    if (result is Error<void>) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add part')),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add part', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (_selected != null)
              _selectedPartTile(theme)
            else
              ..._newPartFields(theme),
            const SizedBox(height: 12),
            // Link fields apply to both existing and new parts.
            Row(
              children: [
                Expanded(
                  child: TextFormField(
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
                  child: TextFormField(
                    controller: _quantity,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
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
                child: Text(_saving ? 'Adding…' : 'Add part'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectedPartTile(ThemeData theme) {
    final part = _selected!;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.check_circle),
        title: Text(part.name),
        subtitle: part.partNumber != null && part.partNumber!.isNotEmpty
            ? Text(part.partNumber!)
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Choose a different part',
          onPressed: () => setState(() => _selected = null),
        ),
      ),
    );
  }

  List<Widget> _newPartFields(ThemeData theme) {
    final matches = _matches;
    return [
      TextField(
        controller: _search,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Find an existing part',
        ),
        onChanged: (_) => setState(() {}),
      ),
      for (final part in matches)
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            dense: true,
            title: Text(part.name),
            subtitle: part.partNumber != null && part.partNumber!.isNotEmpty
                ? Text(part.partNumber!)
                : null,
            onTap: () => setState(() {
              _selected = part;
              FocusScope.of(context).unfocus();
            }),
          ),
        ),
      const SizedBox(height: 8),
      Text(
        '…or enter details to create a new part',
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _name,
        decoration: const InputDecoration(labelText: 'Part name'),
        textCapitalization: TextCapitalization.sentences,
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Enter a part name' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _partNumber,
        decoration: const InputDecoration(labelText: 'Part number'),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _brand,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _supplier,
              decoration: const InputDecoration(labelText: 'Supplier'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _notes,
        decoration: const InputDecoration(labelText: 'Notes'),
        textCapitalization: TextCapitalization.sentences,
        minLines: 1,
        maxLines: 3,
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          TextButton.icon(
            onPressed: _pickPhotos,
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
          ),
          TextButton.icon(
            onPressed: _takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
          ),
          if (_photos.isNotEmpty)
            Text('${_photos.length} photo(s)', style: theme.textTheme.bodySmall),
        ],
      ),
    ];
  }
}

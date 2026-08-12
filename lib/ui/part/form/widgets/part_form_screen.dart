import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/part.dart';
import '../view_models/part_form_view_model.dart';

class PartFormScreen extends StatelessWidget {
  const PartFormScreen({super.key, required this.viewModel});

  final PartFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Part')),
      body: ListenableBuilder(
        listenable: viewModel.fetchPart,
        builder: (context, _) {
          if (viewModel.fetchPart.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.fetchPart.error) {
            return Center(child: Text('Error: ${viewModel.fetchPart.result}'));
          }
          final part = viewModel.part;
          if (part == null) {
            return const Center(child: Text('Part not found'));
          }
          return _PartFormBody(initial: part, viewModel: viewModel);
        },
      ),
    );
  }
}

class _PartFormBody extends StatefulWidget {
  const _PartFormBody({required this.initial, required this.viewModel});

  final Part initial;
  final PartFormViewModel viewModel;

  @override
  State<_PartFormBody> createState() => _PartFormBodyState();
}

class _PartFormBodyState extends State<_PartFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _partNumber;
  late final TextEditingController _brand;
  late final TextEditingController _supplier;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p.name);
    _partNumber = TextEditingController(text: p.partNumber ?? '');
    _brand = TextEditingController(text: p.brand ?? '');
    _supplier = TextEditingController(text: p.supplier ?? '');
    _notes = TextEditingController(text: p.notes ?? '');
  }

  @override
  void dispose() {
    for (final c in [_name, _partNumber, _brand, _supplier, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Preserve the id; toDrift writes catalogue fields only.
    final updated = widget.initial.copyWith(
      name: _name.text.trim(),
      partNumber: _nullIfEmpty(_partNumber.text),
      brand: _nullIfEmpty(_brand.text),
      supplier: _nullIfEmpty(_supplier.text),
      notes: _nullIfEmpty(_notes.text),
    );

    await widget.viewModel.updatePart.execute(updated);
    if (!mounted) return;
    if (widget.viewModel.updatePart.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save part')),
      );
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Part name'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter a part name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _partNumber,
                  decoration: const InputDecoration(labelText: 'Part number'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _brand,
                  decoration: const InputDecoration(labelText: 'Brand'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _supplier,
                  decoration: const InputDecoration(labelText: 'Supplier'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

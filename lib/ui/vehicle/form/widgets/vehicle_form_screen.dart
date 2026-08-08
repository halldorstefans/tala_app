import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../domain/models/vehicle.dart';
import '../../../../utils/result.dart';
import '../view_models/vehicle_form_view_model.dart';

class VehicleFormScreen extends StatelessWidget {
  const VehicleFormScreen({super.key, required this.viewModel});

  final VehicleFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
      ),
      body: ListenableBuilder(
        listenable: viewModel.fetchVehicle,
        builder: (context, _) {
          if (viewModel.fetchVehicle.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.fetchVehicle.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error: ${viewModel.fetchVehicle.result}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
          // Add-mode (never executed) OR edit-mode after successful fetch.
          // Once mounted, _VehicleFormBody seeds its controllers from `initial`
          // and owns the form state until this route is popped.
          return _VehicleFormBody(
            initial: viewModel.vehicle,
            viewModel: viewModel,
          );
        },
      ),
    );
  }
}

class _VehicleFormBody extends StatefulWidget {
  const _VehicleFormBody({required this.initial, required this.viewModel});

  final Vehicle? initial;
  final VehicleFormViewModel viewModel;

  @override
  State<_VehicleFormBody> createState() => _VehicleFormBodyState();
}

class _VehicleFormBodyState extends State<_VehicleFormBody> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _registrationController;
  late final TextEditingController _vinController;
  late final TextEditingController _colourController;
  late final TextEditingController _odometerController;
  late final TextEditingController _notesController;
  late final TextEditingController _purchaseDateController;

  DateTime? _purchaseDate;
  File? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    _makeController = TextEditingController(text: v?.make ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(
      text: v?.year.toString() ?? DateTime.now().year.toString(),
    );
    _nicknameController = TextEditingController(text: v?.nickname ?? '');
    _registrationController = TextEditingController(text: v?.registration ?? '');
    _vinController = TextEditingController(text: v?.vin ?? '');
    _colourController = TextEditingController(text: v?.colour ?? '');
    _odometerController = TextEditingController(
      text: v?.odometer?.toString() ?? '',
    );
    _notesController = TextEditingController(text: v?.notes ?? '');
    _purchaseDate = v?.purchaseDate;
    _purchaseDateController = TextEditingController(
      text: _purchaseDate != null ? _formatDate(_purchaseDate!) : '',
    );
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _nicknameController.dispose();
    _registrationController.dispose();
    _vinController.dispose();
    _colourController.dispose();
    _odometerController.dispose();
    _notesController.dispose();
    _purchaseDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => d.toIso8601String().substring(0, 10);

  String? _nullIfEmpty(String s) => s.isEmpty ? null : s;

  Future<void> _pickPhoto(ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _selectedPhoto = File(image.path));
    }
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _purchaseDate = picked;
        _purchaseDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = Vehicle(
      id: widget.initial?.id ?? '',
      make: _makeController.text,
      model: _modelController.text,
      year: int.tryParse(_yearController.text) ?? DateTime.now().year,
      nickname: _nullIfEmpty(_nicknameController.text),
      registration: _nullIfEmpty(_registrationController.text),
      vin: _nullIfEmpty(_vinController.text),
      colour: _nullIfEmpty(_colourController.text),
      odometer: int.tryParse(_odometerController.text),
      purchaseDate: _purchaseDate,
      notes: _nullIfEmpty(_notesController.text),
      photoPath: widget.initial?.photoPath,
    );

    final isNew = widget.initial == null;
    if (isNew) {
      await widget.viewModel.addVehicle.execute(vehicle);
    } else {
      await widget.viewModel.updateVehicle.execute(vehicle);
    }

    if (_selectedPhoto != null) {
      final id = widget.viewModel.vehicle?.id;
      if (id != null && id.isNotEmpty) {
        final uploadResult = await widget.viewModel.uploadVehiclePhoto(
          id,
          _selectedPhoto!,
        );
        if (!mounted) return;
        if (uploadResult case Error<String>()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo upload failed: ${uploadResult.error}'),
            ),
          );
        }
      }
    }

    if (!mounted) return;
    if (isNew) {
      context.go('/');
    } else {
      context.go('/vehicle/${vehicle.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: theme.dividerColor),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _makeController,
                        decoration: const InputDecoration(labelText: 'Make'),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter make' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(labelText: 'Model'),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter model' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(labelText: 'Year'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter year' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(
                          labelText: 'Nickname',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _registrationController,
                        decoration: const InputDecoration(
                          labelText: 'Registration',
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _vinController,
                        decoration: const InputDecoration(labelText: 'VIN'),
                        style: theme.textTheme.bodyMedium,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _colourController,
                        decoration: const InputDecoration(labelText: 'Colour'),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _odometerController,
                        decoration: const InputDecoration(
                          labelText: 'Odometer',
                        ),
                        keyboardType: TextInputType.number,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickPurchaseDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _purchaseDateController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Date (optional)',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  minLines: 3,
                  maxLines: 5,
                  style: theme.textTheme.bodyLarge,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _pickPhoto(ImageSource.gallery),
                          icon: const Icon(Icons.photo),
                          label: const Text('Pick Photo'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _pickPhoto(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_selectedPhoto != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedPhoto!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox(
                              width: 80,
                              height: 80,
                              child: Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Photo selected'),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      widget.initial == null ? 'Add Vehicle' : 'Save Changes',
                    ),
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

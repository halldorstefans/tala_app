import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tala_app/routing/routes.dart';
import '../../../../domain/models/vehicle.dart';
import '../../../../utils/result.dart';
import '../view_models/vehicle_form_viewmodel.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key, required this.viewModel});

  final VehicleFormViewmodel viewModel;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final TextEditingController _purchaseDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _make = '';
  late String _model = '';
  late int _year = DateTime.now().year;
  late String? _nickname = '';
  late String? _registration = '';
  late String? _vin = '';
  late String? _colour = '';
  late int? _odometer = 0;
  late DateTime? _purchaseDate = DateTime.now();
  late String? _notes = '';
  late String? _photoPath = '';
  late File? _selectedPhoto = File('');

  Future<void> _pickPhoto(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedPhoto = File(image.path);
      });
    }
  }

  @override
  void initState() {
    if (_purchaseDate != null) {
      _purchaseDateController.text = _purchaseDate!.toLocal().toString().split(
        ' ',
      )[0];
    }
    super.initState();

    if (widget.viewModel.vehicle != null) {
      final v = widget.viewModel.vehicle!;
      _make = v.make;
      _model = v.model;
      _year = v.year;
      _nickname = v.nickname;
      _registration = v.registration;
      _vin = v.vin;
      _colour = v.colour;
      _odometer = v.odometer;
      _purchaseDate = v.purchaseDate;
      _notes = v.notes;
      _photoPath = v.photoUrl;
    }

    widget.viewModel.addListener(_updateFormFields);
  }

  void _updateFormFields() {
    if (widget.viewModel.vehicle != null) {
      final v = widget.viewModel.vehicle!;
      setState(() {
        _make = v.make;
        _model = v.model;
        _year = v.year;
        _nickname = v.nickname;
        _registration = v.registration;
        _vin = v.vin;
        _colour = v.colour;
        _odometer = v.odometer;
        _purchaseDate = v.purchaseDate;
        _notes = v.notes;
        _photoPath = v.photoUrl;

        _purchaseDateController.text =
            _purchaseDate?.toLocal().toString().split(' ')[0] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _purchaseDateController.dispose();
    widget.viewModel.removeListener(_updateFormFields);
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        id: widget.viewModel.vehicle?.id ?? '',
        make: _make,
        model: _model,
        year: _year,
        nickname: _nickname,
        registration: _registration,
        vin: _vin,
        colour: _colour,
        odometer: _odometer,
        purchaseDate: _purchaseDate,
        notes: _notes,
        photoUrl: _photoPath,
      );

      Future<void> vehicleResult;
      if (widget.viewModel.vehicle == null) {
        vehicleResult = widget.viewModel.addVehicle.execute(vehicle);
      } else {
        vehicleResult = widget.viewModel.updateVehicle.execute(vehicle);
      }

      final result = vehicleResult.then((_) async {
        if (_selectedPhoto != null && _selectedPhoto!.path.isNotEmpty) {
          final uploadResult = await widget.viewModel.uploadVehiclePhoto(
            vehicle.id,
            _selectedPhoto!,
          );
          switch (uploadResult) {
            case Error<String>():
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Photo upload failed: ${uploadResult.error}'),
                ),
              );
            case Ok<String>():
          }
        }
      });

      result.whenComplete(() {
        if (mounted) {
          context.go(Routes.vehicleDetails(vehicle.id));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.viewModel.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle',
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.fetchVehicle,
        builder: (context, child) {
          if (widget.viewModel.fetchVehicle.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.viewModel.fetchVehicle.error) {
            return Expanded(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Error: ${widget.viewModel.fetchVehicle.result}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.red),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => widget.viewModel.fetchVehicle.execute(
                        widget.viewModel.vehicle!.id,
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return child!;
        },
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) {
            return child!;
          },
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            color: Theme.of(context).cardColor,
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
                              initialValue: _make,
                              decoration: const InputDecoration(
                                labelText: 'Make',
                              ),
                              onChanged: (v) => _make = v,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Enter make' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: _model,
                              decoration: const InputDecoration(
                                labelText: 'Model',
                              ),
                              onChanged: (v) => _model = v,
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
                              initialValue: _year.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Year',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                                  _year = int.tryParse(v) ?? _year,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Enter year' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: _nickname,
                              decoration: const InputDecoration(
                                labelText: 'Nickname',
                              ),
                              onChanged: (v) => _nickname = v,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _registration,
                              decoration: const InputDecoration(
                                labelText: 'Registration',
                              ),
                              onChanged: (v) => _registration = v,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: _vin,
                              decoration: const InputDecoration(
                                labelText: 'VIN',
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              onChanged: (v) => _vin = v,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _colour,
                              decoration: const InputDecoration(
                                labelText: 'Colour',
                              ),
                              onChanged: (v) => _colour = v,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: _odometer?.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Odometer',
                              ),
                              keyboardType: TextInputType.number,
                              style: Theme.of(context).textTheme.bodyMedium,
                              onChanged: (v) => _odometer = int.tryParse(v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _purchaseDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              _purchaseDate = picked;
                              _purchaseDateController.text = picked
                                  .toIso8601String()
                                  .substring(0, 10);
                            });
                          }
                        },
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
                        initialValue: _notes,
                        decoration: const InputDecoration(labelText: 'Notes'),
                        minLines: 3,
                        maxLines: 5,
                        style: Theme.of(context).textTheme.bodyLarge,
                        onChanged: (v) => _notes = v,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _pickPhoto(ImageSource.gallery);
                                },
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
                                onPressed: () {
                                  _pickPhoto(ImageSource.camera);
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Take Photo'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_selectedPhoto != null &&
                          _selectedPhoto!.path.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedPhoto!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('Photo selected'),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: Theme.of(context).elevatedButtonTheme.style,
                          child: Text(
                            widget.viewModel.vehicle == null
                                ? 'Add Vehicle'
                                : 'Save Changes',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

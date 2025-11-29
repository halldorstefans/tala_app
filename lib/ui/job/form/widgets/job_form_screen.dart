import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:tala_app/routing/routes.dart';
import '../../../../domain/models/job.dart';
import '../../../../utils/result.dart';
import '../view_models/job_form_view_model.dart';

class JobFormScreen extends StatefulWidget {
  const JobFormScreen({super.key, required this.viewModel});

  final JobFormViewModel viewModel;

  @override
  State<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends State<JobFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _startDateController;
  late TextEditingController _completionDateController;
  late String _title = '';
  late int? _odometer = null;
  late DateTime? _startDate = DateTime.now();
  late DateTime? _completionDate = DateTime.now();
  late String? _status = 'planned';
  late String? _category = '';
  late String? _description = '';
  late double? _cost = 0.0;
  late final List<File> _selectedPhotos = [];

  Future<void> _pickPhoto(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      //maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedPhotos.add(File(image.path));
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.viewModel.job != null) {
      _title = widget.viewModel.job?.title ?? '';
      _odometer = widget.viewModel.job?.odometer;
      _startDate = widget.viewModel.job?.startDate;
      _completionDate = widget.viewModel.job?.completionDate;
      _status = widget.viewModel.job?.status;
      _category = widget.viewModel.job?.category;
      _description = widget.viewModel.job?.description;
      _cost = widget.viewModel.job?.cost;
    }

    _startDateController = TextEditingController(
      text: _startDate?.toLocal().toString().split(' ')[0],
    );

    _completionDateController = TextEditingController(
      text: _completionDate?.toLocal().toString().split(' ')[0],
    );

    widget.viewModel.addListener(_updateFormFields);
  }

  void _updateFormFields() {
    if (widget.viewModel.job != null) {
      setState(() {
        _title = widget.viewModel.job!.title;
        _odometer = widget.viewModel.job!.odometer;
        _startDate = widget.viewModel.job!.startDate;
        _completionDate = widget.viewModel.job!.completionDate;
        _status = widget.viewModel.job!.status;
        _category = widget.viewModel.job!.category;
        _description = widget.viewModel.job!.description;
        _cost = widget.viewModel.job!.cost;

        _startDateController.text =
            _startDate?.toLocal().toString().split(' ')[0] ?? '';
        _completionDateController.text =
            _completionDate?.toLocal().toString().split(' ')[0] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _completionDateController.dispose();
    widget.viewModel.removeListener(_updateFormFields);
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final job = Job(
        id: widget.viewModel.job?.id ?? '',
        vehicleId: widget.viewModel.vehicleId,
        title: _title,
        odometer: _odometer,
        startDate: _startDate,
        completionDate: _completionDate,
        status: _status,
        category: _category,
        description: _description,
        cost: _cost,
      );

      Future<void> jobResult;
      if (widget.viewModel.job == null) {
        jobResult = widget.viewModel.addJob.execute(job);
      } else {
        jobResult = widget.viewModel.updateJob.execute(job);
      }

      final result = jobResult.then((_) async {
        // Upload photos after job is created/updated
        for (final photo in _selectedPhotos) {
          var compressedPhoto = await FlutterImageCompress.compressAndGetFile(
            photo.absolute.path,
            '${photo.parent.path}/compressed_${photo.uri.pathSegments.last}',
            quality: 85,
            //format: CompressFormat.png,
          );

          File? photoToUpload;
          if (compressedPhoto != null) {
            photoToUpload = File(compressedPhoto.path);
          } else {
            photoToUpload = photo;
          }

          final uploadResult = await widget.viewModel.uploadJobPhoto(
            job.vehicleId,
            job.id,
            photoToUpload,
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
          context.go(Routes.jobDetails(widget.viewModel.vehicleId, job.id));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.viewModel.job == null ? 'Add Job' : 'Edit Job'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.fetchJob,
        builder: (context, child) {
          if (widget.viewModel.fetchJob.running) {
            return Column(
              children: [
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }
          if (widget.viewModel.fetchJob.error) {
            return Expanded(
              child: Center(
                child: Column(
                  children: [
                    Text('Error: ${widget.viewModel.fetchJob.result}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => widget.viewModel.fetchJob.execute((
                        widget.viewModel.vehicleId,
                        widget.viewModel.job!.id,
                      )),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: _title,
                      decoration: const InputDecoration(labelText: 'Job Title'),
                      onChanged: (v) => _title = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter job title' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      onChanged: (v) => _category = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter category' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      onChanged: (v) => _description = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue:
                          _odometer?.toString() ?? '', // Show empty if 0
                      decoration: const InputDecoration(labelText: 'Odometer'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _odometer = int.tryParse(v) ?? 0,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Enter mileage';
                        }
                        final mileage = int.tryParse(v);
                        if (mileage == null || mileage < 0) {
                          return 'Enter a valid mileage';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start date',
                      ),
                      readOnly: true,
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null && pickedDate != _startDate) {
                          setState(() {
                            _startDate = pickedDate;
                            _startDateController.text = _startDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _completionDateController,
                      decoration: const InputDecoration(
                        labelText: 'Completion date',
                      ),
                      readOnly: true,
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _completionDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null &&
                            pickedDate != _completionDate) {
                          setState(() {
                            _completionDate = pickedDate;
                            _completionDateController.text = _completionDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
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
                    if (_selectedPhotos.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedPhotos.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.file(_selectedPhotos[index]),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        widget.viewModel.job == null
                            ? 'Add Job'
                            : 'Save Changes',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

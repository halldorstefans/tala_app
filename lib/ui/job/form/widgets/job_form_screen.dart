import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tala_app/routing/routes.dart';
import '../../../../domain/models/job.dart';
import '../../../../domain/models/job_category.dart';
import '../../../../domain/models/job_status.dart';
import '../../../../utils/result.dart';
import '../view_models/job_form_view_model.dart';

const _customCategorySentinel = '__custom__';

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
  String _title = '';
  int? _odometer;
  DateTime? _startDate = DateTime.now();
  DateTime? _completionDate;
  String? _status = JobStatus.planned;
  String? _category;
  late TextEditingController _customCategoryController;
  String? _categoryDropdownValue;
  String? _description;
  double? _cost;
  final List<File> _selectedPhotos = [];

  void _syncCategoryControls() {
    if (_category == null || _category!.isEmpty) {
      _categoryDropdownValue = null;
      _customCategoryController.text = '';
    } else if (JobCategory.isPredefined(_category)) {
      _categoryDropdownValue = _category;
      _customCategoryController.text = '';
    } else {
      _categoryDropdownValue = _customCategorySentinel;
      _customCategoryController.text = _category!;
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    if (source == ImageSource.gallery) {
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedPhotos.addAll(images.map((x) => File(x.path)));
        });
      }
      return;
    }

    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
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

    _customCategoryController = TextEditingController();
    _syncCategoryControls();

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
        _syncCategoryControls();
      });
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _completionDateController.dispose();
    _customCategoryController.dispose();
    widget.viewModel.removeListener(_updateFormFields);
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final isUpdate = widget.viewModel.job != null;
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

    if (isUpdate) {
      await widget.viewModel.updateJob.execute(job);
    } else {
      await widget.viewModel.addJob.execute(job);
    }

    final savedJob = widget.viewModel.job;
    if (savedJob == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save job')),
        );
      }
      return;
    }

    final uploadResult = await widget.viewModel.uploadJobPhotos(
      savedJob.vehicleId,
      savedJob.id,
      _selectedPhotos,
    );
    if (uploadResult is Error<void> && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo upload failed: ${uploadResult.error}')),
      );
    }

    if (mounted) {
      context.go(Routes.jobDetails(savedJob.vehicleId, savedJob.id));
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
          child: SafeArea(
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
                      initialValue: _title,
                      decoration: const InputDecoration(labelText: 'Job Title'),
                      onChanged: (v) => _title = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter job title' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _categoryDropdownValue,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: [
                        for (final c in JobCategory.predefined)
                          DropdownMenuItem(
                            value: c,
                            child: Text(categoryLabel(c)),
                          ),
                        const DropdownMenuItem(
                          value: _customCategorySentinel,
                          child: Text('Custom…'),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _categoryDropdownValue = v;
                          if (v == null) {
                            _category = null;
                            _customCategoryController.text = '';
                          } else if (v == _customCategorySentinel) {
                            _category = _customCategoryController.text.isEmpty
                                ? null
                                : _customCategoryController.text;
                          } else {
                            _category = v;
                            _customCategoryController.text = '';
                          }
                        });
                      },
                    ),
                    if (_categoryDropdownValue == _customCategorySentinel) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _customCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'Custom category',
                        ),
                        onChanged: (v) =>
                            _category = v.isEmpty ? null : v,
                      ),
                    ],
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: JobStatus.isKnown(_status)
                          ? _status
                          : JobStatus.planned,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: [
                        for (final s in JobStatus.all)
                          DropdownMenuItem(
                            value: s,
                            child: Text(statusLabel(s)),
                          ),
                      ],
                      onChanged: (v) {
                        setState(() => _status = v);
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      onChanged: (v) => _description = v.isEmpty ? null : v,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _odometer?.toString() ?? '',
                      decoration: const InputDecoration(labelText: 'Odometer'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _odometer = int.tryParse(v),
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
                    if (widget.viewModel.uploadTotal > 0) ...[
                      LinearProgressIndicator(
                        value: widget.viewModel.uploadTotal == 0
                            ? null
                            : widget.viewModel.uploadedCount /
                                  widget.viewModel.uploadTotal,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading ${widget.viewModel.uploadedCount}/${widget.viewModel.uploadTotal}…',
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton(
                      onPressed: widget.viewModel.uploadTotal > 0
                          ? null
                          : _submit,
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
      ),
    );
  }
}

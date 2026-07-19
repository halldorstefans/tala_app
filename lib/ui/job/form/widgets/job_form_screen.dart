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

class JobFormScreen extends StatelessWidget {
  const JobFormScreen({super.key, required this.viewModel});

  final JobFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.job == null ? 'Add Job' : 'Edit Job'),
      ),
      body: ListenableBuilder(
        // Rebuild when either data-load command changes state.
        listenable: Listenable.merge([
          viewModel.fetchJob,
          viewModel.loadDefaultCategory,
        ]),
        builder: (context, _) {
          final loading = viewModel.fetchJob.running ||
              viewModel.loadDefaultCategory.running;
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.fetchJob.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${viewModel.fetchJob.result}'),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
          return _JobFormBody(
            initial: viewModel.job,
            defaultCategory: viewModel.defaultCategory,
            viewModel: viewModel,
          );
        },
      ),
    );
  }
}

class _JobFormBody extends StatefulWidget {
  const _JobFormBody({
    required this.initial,
    required this.defaultCategory,
    required this.viewModel,
  });

  final Job? initial;
  final String? defaultCategory;
  final JobFormViewModel viewModel;

  @override
  State<_JobFormBody> createState() => _JobFormBodyState();
}

class _JobFormBodyState extends State<_JobFormBody> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _odometerController;
  late final TextEditingController _costController;
  late final TextEditingController _customCategoryController;
  late final TextEditingController _startDateController;
  late final TextEditingController _completionDateController;

  DateTime? _startDate;
  DateTime? _completionDate;
  String? _status;
  String? _category;
  String? _categoryDropdownValue;
  final List<File> _selectedPhotos = [];

  @override
  void initState() {
    super.initState();
    final j = widget.initial;

    _titleController = TextEditingController(text: j?.title ?? '');
    _descriptionController = TextEditingController(text: j?.description ?? '');
    _odometerController = TextEditingController(
      text: j?.odometer?.toString() ?? '',
    );
    _costController = TextEditingController(
      text: j?.cost?.toStringAsFixed(2) ?? '',
    );

    // Category: existing job's value wins; otherwise fall back to the
    // user's remembered default (add-mode only).
    _category = j?.category ?? widget.defaultCategory;
    _customCategoryController = TextEditingController();
    _syncCategoryControls();

    _status = j?.status ?? JobStatus.planned;

    // Start date is intentionally NOT defaulted — a blank field signals
    // "not scheduled yet" and supports the todo-list use case.
    _startDate = j?.startDate;
    _completionDate = j?.completionDate;
    _startDateController = TextEditingController(
      text: _startDate != null ? _formatDate(_startDate!) : '',
    );
    _completionDateController = TextEditingController(
      text: _completionDate != null ? _formatDate(_completionDate!) : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _customCategoryController.dispose();
    _startDateController.dispose();
    _completionDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => d.toIso8601String().substring(0, 10);

  String? _nullIfEmpty(String s) => s.isEmpty ? null : s;

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
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final images = await picker.pickMultiImage(
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() => _selectedPhotos.addAll(images.map((x) => File(x.path))));
      }
      return;
    }
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _selectedPhotos.add(File(image.path)));
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickCompletionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _completionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        _completionDate = picked;
        _completionDateController.text = _formatDate(picked);
      });
    }
  }

  void _clearStartDate() {
    setState(() {
      _startDate = null;
      _startDateController.text = '';
    });
  }

  void _clearCompletionDate() {
    setState(() {
      _completionDate = null;
      _completionDateController.text = '';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final isUpdate = widget.initial != null;
    final job = Job(
      id: widget.initial?.id ?? '',
      vehicleId: widget.viewModel.vehicleId,
      title: _titleController.text,
      odometer: int.tryParse(_odometerController.text),
      startDate: _startDate,
      completionDate: _completionDate,
      status: _status,
      category: _category,
      description: _nullIfEmpty(_descriptionController.text),
      cost: _nullIfEmpty(_costController.text) != null
          ? double.tryParse(_costController.text)
          : null,
    ).normalized();

    if (isUpdate) {
      await widget.viewModel.updateJob.execute(job);
    } else {
      await widget.viewModel.addJob.execute(job);
    }

    final savedJob = widget.viewModel.job;
    if (savedJob == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save job')),
      );
      return;
    }

    final uploadResult = await widget.viewModel.uploadJobPhotos(
      savedJob.vehicleId,
      savedJob.id,
      _selectedPhotos,
    );
    if (!mounted) return;
    if (uploadResult case Error<void>()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo upload failed: ${uploadResult.error}')),
      );
    }

    if (!mounted) return;
    context.go(Routes.jobDetails(savedJob.vehicleId, savedJob.id));
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
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Job Title'),
                  textCapitalization: TextCapitalization.sentences,
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
                        _category = _nullIfEmpty(_customCategoryController.text);
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
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (v) => _category = _nullIfEmpty(v),
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
                  onChanged: (v) => setState(() => _status = v),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _odometerController,
                  decoration: const InputDecoration(labelText: 'Odometer'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costController,
                  decoration: const InputDecoration(
                    labelText: 'Cost',
                    prefixText: '€ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start date (optional)',
                    suffixIcon: _startDate == null
                        ? const Icon(Icons.calendar_today)
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearStartDate,
                          ),
                  ),
                  readOnly: true,
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _completionDateController,
                  decoration: InputDecoration(
                    labelText: 'Completion date (optional)',
                    suffixIcon: _completionDate == null
                        ? const Icon(Icons.calendar_today)
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearCompletionDate,
                          ),
                  ),
                  readOnly: true,
                  onTap: _pickCompletionDate,
                ),
                const SizedBox(height: 16),
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
                if (_selectedPhotos.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedPhotos.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.file(
                          _selectedPhotos[index],
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                ListenableBuilder(
                  listenable: widget.viewModel,
                  builder: (context, _) {
                    final total = widget.viewModel.uploadTotal;
                    if (total == 0) return const SizedBox.shrink();
                    final done = widget.viewModel.uploadedCount;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(value: done / total),
                        const SizedBox(height: 8),
                        Text('Uploading $done/$total…'),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
                ListenableBuilder(
                  listenable: widget.viewModel,
                  builder: (context, _) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.viewModel.uploadTotal > 0
                          ? null
                          : _submit,
                      child: Text(
                        widget.initial == null ? 'Add Job' : 'Save Changes',
                      ),
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

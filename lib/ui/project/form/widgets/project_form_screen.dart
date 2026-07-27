import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/job_status.dart';
import '../../../../domain/models/project.dart';
import '../view_models/project_form_view_model.dart';

class ProjectFormScreen extends StatelessWidget {
  const ProjectFormScreen({super.key, required this.viewModel});

  final ProjectFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.project == null ? 'Add Project' : 'Edit Project'),
      ),
      body: ListenableBuilder(
        listenable: viewModel.fetchProject,
        builder: (context, _) {
          if (viewModel.fetchProject.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.fetchProject.error) {
            return Center(
              child: Text('Error: ${viewModel.fetchProject.result}'),
            );
          }
          return _ProjectFormBody(
            initial: viewModel.project,
            viewModel: viewModel,
          );
        },
      ),
    );
  }
}

class _ProjectFormBody extends StatefulWidget {
  const _ProjectFormBody({required this.initial, required this.viewModel});

  final Project? initial;
  final ProjectFormViewModel viewModel;

  @override
  State<_ProjectFormBody> createState() => _ProjectFormBodyState();
}

class _ProjectFormBodyState extends State<_ProjectFormBody> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _status;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _status = p?.status ?? JobStatus.planned;
    _startDate = p?.startDate;
    _endDate = p?.endDate;
    _startDateController = TextEditingController(
      text: _startDate != null ? _formatDate(_startDate!) : '',
    );
    _endDateController = TextEditingController(
      text: _endDate != null ? _formatDate(_endDate!) : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => d.toIso8601String().substring(0, 10);

  String? _nullIfEmpty(String s) => s.isEmpty ? null : s;

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

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = _formatDate(picked);
      });
    }
  }

  void _clearStartDate() {
    setState(() {
      _startDate = null;
      _startDateController.text = '';
    });
  }

  void _clearEndDate() {
    setState(() {
      _endDate = null;
      _endDateController.text = '';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = widget.viewModel;
    final isUpdate = widget.initial != null;
    final project = Project(
      id: widget.initial?.id ?? '',
      vehicleId: vm.vehicleId,
      title: _titleController.text,
      status: _status,
      description: _nullIfEmpty(_descriptionController.text),
      startDate: _startDate,
      endDate: _endDate,
    );

    if (isUpdate) {
      await vm.updateProject.execute(project);
      if (vm.updateProject.error) {
        _showError();
        return;
      }
    } else {
      await vm.addProject.execute(project);
      if (vm.addProject.error) {
        _showError();
        return;
      }
    }

    if (!mounted) return;
    context.pop();
  }

  void _showError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to save project')),
    );
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
                  decoration: const InputDecoration(labelText: 'Project Title'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter project title' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: JobStatus.isKnown(_status)
                      ? _status
                      : JobStatus.planned,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    for (final s in JobStatus.all)
                      DropdownMenuItem(value: s, child: Text(statusLabel(s))),
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
                  controller: _endDateController,
                  decoration: InputDecoration(
                    labelText: 'End date (optional)',
                    suffixIcon: _endDate == null
                        ? const Icon(Icons.calendar_today)
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearEndDate,
                          ),
                  ),
                  readOnly: true,
                  onTap: _pickEndDate,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      widget.initial == null
                          ? 'Add Project'
                          : 'Save Changes',
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/progress_status.dart';
import '../../../../domain/models/project.dart';
import '../../../../routing/routes.dart';
import '../../../../utils/result.dart';
import '../../../core/themes/dimens.dart';
import '../../../job/list/widgets/job_card.dart';
import '../view_models/project_detail_viewmodel.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.viewModel});

  final ProjectDetailViewModel viewModel;

  Future<void> _openEdit(BuildContext context) async {
    await context.push(
      Routes.projectFormWithId(viewModel.vehicleId, viewModel.projectId),
    );
    if (!context.mounted) return;
    viewModel.load.execute();
  }

  Future<void> _openJob(BuildContext context, String jobId) async {
    await context.push(Routes.jobDetails(viewModel.vehicleId, jobId));
    if (!context.mounted) return;
    viewModel.load.execute();
  }

  Future<void> _manageJobs(BuildContext context) async {
    await viewModel.loadVehicleJobs();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ManageJobsSheet(viewModel: viewModel),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete project?'),
        content: const Text(
          'The project will be removed. Its jobs are kept and simply '
          'unassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await viewModel.delete.execute();
    if (!context.mounted) return;
    if (viewModel.delete.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete project')),
      );
      return;
    }
    context.go(Routes.projects(viewModel.vehicleId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimens = Dimens.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit project',
            onPressed: () => _openEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete project',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel.load,
        builder: (context, _) {
          if (viewModel.load.running) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            );
          }
          if (viewModel.load.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${viewModel.load.result}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.load.execute(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final project = viewModel.project;
              if (project == null) {
                return Center(
                  child: Text(
                    'Project not found',
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              }
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  dimens.paddingScreenHorizontal,
                  dimens.paddingScreenVertical,
                  dimens.paddingScreenHorizontal,
                  // Clear the system nav bar so the last job card isn't cut off.
                  dimens.paddingScreenVertical +
                      MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  _Header(project: project),
                  const SizedBox(height: 16),
                  _StatsSummary(
                    planned: viewModel.stats.planned,
                    inProgress: viewModel.stats.inProgress,
                    completed: viewModel.stats.completed,
                    totalCost: viewModel.totalCostWithParts,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jobs', style: theme.textTheme.headlineMedium),
                      TextButton.icon(
                        onPressed: () => _manageJobs(context),
                        icon: const Icon(Icons.playlist_add_check),
                        label: const Text('Manage'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (viewModel.jobs.isEmpty)
                    Text(
                      'No jobs in this project yet. Use "Manage" to add some, '
                      'or assign one from its form.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    )
                  else
                    for (final job in viewModel.jobs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Dimens.space2),
                        child: JobCard(
                          job: job,
                          onTap: () => _openJob(context, job.id),
                        ),
                      ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final range = _dateRange(project);
    final description = project.description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(project.title, style: theme.textTheme.headlineMedium),
            ),
            if (project.status != null) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text(statusLabel(project.status)),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ],
        ),
        if (range != null) ...[
          const SizedBox(height: 4),
          Text(range, style: theme.textTheme.bodySmall),
        ],
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(description, style: theme.textTheme.bodyLarge),
        ],
      ],
    );
  }

  static String? _dateRange(Project project) {
    if (project.startDate == null && project.endDate == null) return null;
    String fmt(DateTime? d) =>
        d != null ? d.toLocal().toString().split(' ')[0] : '—';
    return '${fmt(project.startDate)} → ${fmt(project.endDate)}';
  }
}

class _StatsSummary extends StatelessWidget {
  const _StatsSummary({
    required this.planned,
    required this.inProgress,
    required this.completed,
    required this.totalCost,
  });

  final int planned;
  final int inProgress;
  final int completed;
  final double totalCost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(label: Text('Planned: $planned')),
            Chip(label: Text('In progress: $inProgress')),
            Chip(label: Text('Completed: $completed')),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Total cost: €${totalCost.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}

/// Bottom sheet to add/remove the vehicle's jobs from this project. Checked =
/// in this project. Since a job belongs to at most one project, a job already
/// in another project shows that inline and checking it moves it here.
class _ManageJobsSheet extends StatefulWidget {
  const _ManageJobsSheet({required this.viewModel});

  final ProjectDetailViewModel viewModel;

  @override
  State<_ManageJobsSheet> createState() => _ManageJobsSheetState();
}

class _ManageJobsSheetState extends State<_ManageJobsSheet> {
  late Set<String> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.viewModel.vehicleJobs
        .where((j) => j.projectId == widget.viewModel.projectId)
        .map((j) => j.id)
        .toSet();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await widget.viewModel.setJobMembership(_selected);
    if (!mounted) return;
    if (result is Error<void>) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update jobs')),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final jobs = widget.viewModel.vehicleJobs;
    final projectId = widget.viewModel.projectId;

    return Padding(
      padding: EdgeInsets.only(bottom: media.padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Manage jobs', style: theme.textTheme.titleLarge),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving…' : 'Save'),
                ),
              ],
            ),
          ),
          if (jobs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'This vehicle has no jobs yet.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: jobs.length,
                itemBuilder: (context, i) {
                  final job = jobs[i];
                  final inOther =
                      job.projectId != null && job.projectId != projectId;
                  return CheckboxListTile(
                    value: _selected.contains(job.id),
                    title: Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: inOther
                        ? Text(
                            'In another project',
                            style: theme.textTheme.bodySmall,
                          )
                        : null,
                    onChanged: (checked) => setState(() {
                      if (checked ?? false) {
                        _selected.add(job.id);
                      } else {
                        _selected.remove(job.id);
                      }
                    }),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

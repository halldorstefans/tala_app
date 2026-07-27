import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/job_status.dart';
import '../../../../domain/models/project.dart';
import '../../../../routing/routes.dart';
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
                padding: EdgeInsets.symmetric(
                  vertical: dimens.paddingScreenVertical,
                  horizontal: dimens.paddingScreenHorizontal,
                ),
                children: [
                  _Header(project: project),
                  const SizedBox(height: 16),
                  _StatsSummary(
                    planned: viewModel.stats.planned,
                    inProgress: viewModel.stats.inProgress,
                    completed: viewModel.stats.completed,
                    totalCost: viewModel.stats.totalCost,
                  ),
                  const SizedBox(height: 24),
                  Text('Jobs', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  if (viewModel.jobs.isEmpty)
                    Text(
                      'No jobs in this project yet. Assign a job from its '
                      'form.',
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
            if (project.status != null && project.status!.isNotEmpty) ...[
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

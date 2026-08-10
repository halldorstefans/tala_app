import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tala_app/data/services/tala_api/api_config.dart';
import 'package:tala_app/domain/models/progress_status.dart';
import 'package:tala_app/routing/routes.dart';
import 'package:tala_app/ui/core/widgets/app_image.dart';
import 'package:tala_app/ui/job/list/view_models/job_list_viewmodel.dart';
import 'package:tala_app/ui/job/list/widgets/job_card.dart';
import 'package:tala_app/ui/project/list/view_models/project_list_viewmodel.dart';
import 'package:tala_app/ui/project/list/widgets/project_card.dart';

import '../view_models/vehicle_detail_viewmodel.dart';
import 'package:tala_app/ui/core/themes/dimens.dart';

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({
    super.key,
    required this.viewModel,
    required this.jobListViewModel,
    required this.projectListViewModel,
  });

  final VehicleDetailViewModel viewModel;
  final JobListViewModel jobListViewModel;
  final ProjectListViewModel projectListViewModel;

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  // Refetching the job list after returning from a job-related route keeps
  // the summary + stats in sync with mutations (add/edit/delete/toggle)
  // that happen deeper in the stack.
  Future<void> _openJobsWithStatus(
    String vehicleId,
    ProgressStatus status,
  ) async {
    await context.push(Routes.jobsWithStatus(vehicleId, status));
    if (!mounted) return;
    widget.jobListViewModel.fetchJobs.execute(vehicleId);
  }

  Future<void> _openFullJobHistory(String vehicleId) async {
    await context.push(Routes.jobs(vehicleId));
    if (!mounted) return;
    widget.jobListViewModel.fetchJobs.execute(vehicleId);
  }

  Future<void> _openProjects(String vehicleId) async {
    await context.push(Routes.projects(vehicleId));
    if (!mounted) return;
    _refreshAfterProjects(vehicleId);
  }

  Future<void> _openPartsUsed(String vehicleId) async {
    await context.push(Routes.partsUsed(vehicleId));
    if (!mounted) return;
    // Parts may have been edited/deleted from the usage list; keep the total
    // in sync.
    widget.jobListViewModel.fetchJobs.execute(vehicleId);
  }

  Future<void> _openProjectDetail(String vehicleId, String projectId) async {
    await context.push(Routes.projectDetails(vehicleId, projectId));
    if (!mounted) return;
    _refreshAfterProjects(vehicleId);
  }

  // A project's status may have changed, and jobs may have been (un)assigned,
  // so refresh both summaries after returning from a project route.
  void _refreshAfterProjects(String vehicleId) {
    widget.projectListViewModel.fetchProjects.execute(vehicleId);
    widget.jobListViewModel.fetchJobs.execute(vehicleId);
  }

  Future<void> _openEdit(String vehicleId) async {
    await context.push(Routes.vehicleFormWithId(vehicleId));
    if (!mounted) return;
    widget.viewModel.fetchVehicle.execute(vehicleId);
  }

  Future<void> _confirmRemove(String vehicleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete vehicle?'),
        content: const Text(
          'This vehicle and all its jobs, projects, and photos will be '
          'removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.viewModel.remove.execute(vehicleId);
    if (!mounted) return;
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimens = Dimens.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          theme.appBarTheme.toolbarHeight ?? kToolbarHeight,
        ),
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final vehicle = widget.viewModel.vehicle;
            return AppBar(
              title: const Text('Vehicle'),
              leading: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go('/'),
              ),
              actions: [
                if (vehicle != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit vehicle',
                    onPressed: () => _openEdit(vehicle.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete vehicle',
                    onPressed: () => _confirmRemove(vehicle.id),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vehicle = widget.viewModel.vehicle;
          if (vehicle == null) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () async {
              await context.push(Routes.jobForm(vehicle.id));
              if (!context.mounted) return;
              widget.jobListViewModel.fetchJobs.execute(vehicle.id);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Job'),
          );
        },
      ),
      body: Padding(
        padding: dimens.edgeInsetsScreenSymmetric,
        child: ListenableBuilder(
          listenable: widget.viewModel.fetchVehicle,
          builder: (context, child) {
            if (widget.viewModel.fetchVehicle.running) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              );
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
            return ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, child) {
                final vehicle = widget.viewModel.vehicle;
                if (vehicle == null) {
                  return Center(
                    child: Text(
                      'Vehicle not found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 112),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ApiConfig.isValidPhotoPath(vehicle.photoPath)) ...[
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: AppImage(
                                path: vehicle.photoPath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: theme.textTheme.headlineMedium,
                      ),
                      Text('${vehicle.year}', style: theme.textTheme.bodyMedium),
                      if (vehicle.nickname != null &&
                          vehicle.nickname!.isNotEmpty)
                        Text(
                          '"${vehicle.nickname}"',
                          style: theme.textTheme.bodyLarge,
                        ),
                      const SizedBox(height: 12),
                      _SpecRow(
                        label: 'Odometer',
                        value: '${vehicle.odometer ?? 0} km',
                      ),
                      if (vehicle.registration != null &&
                          vehicle.registration!.isNotEmpty)
                        _SpecRow(
                          label: 'Registration',
                          value: vehicle.registration!,
                        ),
                      if (vehicle.vin != null && vehicle.vin!.isNotEmpty)
                        _SpecRow(label: 'VIN', value: vehicle.vin!),
                      if (vehicle.colour != null && vehicle.colour!.isNotEmpty)
                        _SpecRow(label: 'Colour', value: vehicle.colour!),
                      if (vehicle.purchaseDate != null)
                        _SpecRow(
                          label: 'Purchased',
                          value: vehicle.purchaseDate!
                              .toLocal()
                              .toString()
                              .split(' ')
                              .first,
                        ),
                      if (vehicle.notes != null && vehicle.notes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(vehicle.notes!, style: theme.textTheme.bodyLarge),
                      ],
                      const SizedBox(height: 32),
                      Text(
                        'Stats',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      ListenableBuilder(
                        listenable: widget.jobListViewModel,
                        builder: (context, _) {
                          final stats = widget.jobListViewModel.stats;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatTile(
                                      label: 'Planned',
                                      value: stats.planned.toString(),
                                      onTap: () =>
                                          _openJobsWithStatus(
                                            vehicle.id,
                                            ProgressStatus.planned,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _StatTile(
                                      label: 'In progress',
                                      value: stats.inProgress.toString(),
                                      onTap: () =>
                                          _openJobsWithStatus(
                                            vehicle.id,
                                            ProgressStatus.inProgress,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _StatTile(
                                      label: 'Completed',
                                      value: stats.completed.toString(),
                                      onTap: () =>
                                          _openJobsWithStatus(
                                            vehicle.id,
                                            ProgressStatus.completed,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _StatTile(
                                label: 'Total cost · parts used ›',
                                value:
                                    '€${widget.jobListViewModel.totalCostWithParts.toStringAsFixed(2)}',
                                onTap: () => _openPartsUsed(vehicle.id),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Active Projects',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: Theme.of(context).cardColor,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _ActiveProjects(
                            viewModel: widget.projectListViewModel,
                            onOpen: (projectId) =>
                                _openProjectDetail(vehicle.id, projectId),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () => _openProjects(vehicle.id),
                          child: const Text('View Projects'),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Active Jobs',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: Theme.of(context).cardColor,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _ActiveJobs(
                            viewModel: widget.jobListViewModel,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () => _openFullJobHistory(vehicle.id),
                          child: const Text('View Full Job History'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// A label (muted) on the left and a mono data value on the right.
class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.jetBrainsMono(
                textStyle: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                textStyle: theme.textTheme.titleLarge,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null ? InkWell(onTap: onTap, child: content) : content,
    );
  }
}

/// In-progress projects for the vehicle, rendered inline on the detail screen
/// (the projects counterpart to the "Active Jobs" job summary).
class _ActiveProjects extends StatelessWidget {
  const _ActiveProjects({required this.viewModel, required this.onOpen});

  final ProjectListViewModel viewModel;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, viewModel.fetchProjects]),
      builder: (context, _) {
        if (viewModel.fetchProjects.running) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            ),
          );
        }
        final active = viewModel.activeProjects;
        if (active.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No active projects.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < active.length; i++) ...[
              if (i > 0) const SizedBox(height: Dimens.space3),
              ProjectCard(
                project: active[i],
                summary: viewModel.summaryFor(active[i].id),
                onTap: () => onOpen(active[i].id),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// In-progress jobs for the vehicle, rendered inline on the detail screen —
/// the jobs counterpart to [_ActiveProjects], built the same way.
class _ActiveJobs extends StatelessWidget {
  const _ActiveJobs({required this.viewModel});

  final JobListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, viewModel.fetchJobs]),
      builder: (context, _) {
        if (viewModel.fetchJobs.running) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            ),
          );
        }
        final active = viewModel.inProgressJobs;
        if (active.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No active work.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < active.length; i++) ...[
              if (i > 0) const SizedBox(height: Dimens.space3),
              JobCard(
                job: active[i],
                onTap: () async {
                  await context.push(
                    Routes.jobDetails(viewModel.vehicleId, active[i].id),
                  );
                  if (!context.mounted) return;
                  viewModel.fetchJobs.execute(viewModel.vehicleId);
                },
                onToggleDone: (_) => viewModel.toggleDone.execute(active[i]),
              ),
            ],
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tala_app/data/services/tala_api/api_config.dart';
import 'package:tala_app/domain/models/job_status.dart';
import 'package:tala_app/routing/routes.dart';
import 'package:tala_app/ui/core/widgets/app_image.dart';
import 'package:tala_app/ui/job/list/view_models/job_list_viewmodel.dart';
import 'package:tala_app/ui/job/list/widgets/job_list_view.dart';
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
  Future<void> _openJobsWithStatus(String vehicleId, String status) async {
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

  @override
  Widget build(BuildContext context) {
    final dimens = Dimens.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
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
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (ApiConfig.isValidPhotoPath(vehicle.photoPath))
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
                              Text(
                                '${vehicle.make} ${vehicle.model}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              Text(
                                '${vehicle.year}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (vehicle.nickname != null &&
                                  vehicle.nickname!.isNotEmpty)
                                Text(
                                  'Nickname: ${vehicle.nickname}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              if (vehicle.colour != null &&
                                  vehicle.colour!.isNotEmpty)
                                Text(
                                  'Colour: ${vehicle.colour}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Odometer: ${vehicle.odometer ?? 0} km',
                                      style: GoogleFonts.jetBrainsMono(
                                        textStyle: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Registration: ${vehicle.registration ?? ''}',
                                      style: GoogleFonts.jetBrainsMono(
                                        textStyle: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'VIN: ${vehicle.vin ?? ''}',
                                      style: GoogleFonts.jetBrainsMono(
                                        textStyle: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Purchase: ${vehicle.purchaseDate?.toLocal().toString().split(' ').first ?? ''}',
                                      style: GoogleFonts.jetBrainsMono(
                                        textStyle: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (vehicle.notes != null &&
                                  vehicle.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Notes: ${vehicle.notes}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.push(
                                          Routes.vehicleFormWithId(vehicle.id),
                                        );
                                      },
                                      child: const Text('Edit'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                      ),
                                      onPressed: () {
                                        Future<void> result = widget
                                            .viewModel
                                            .remove
                                            .execute(vehicle.id);
                                        result.whenComplete(() {
                                          if (mounted) {
                                            context.go(Routes.home);
                                          }
                                        });
                                      },
                                      child: const Text('Remove'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
                                            JobStatus.planned,
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
                                            JobStatus.inProgress,
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
                                            JobStatus.completed,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _StatTile(
                                label: 'Total cost',
                                value: '€${stats.totalCost.toStringAsFixed(2)}',
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
                        'Active Work',
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
                          padding: const EdgeInsets.all(2),
                          child: JobListView(
                            viewModel: widget.jobListViewModel,
                            isSummary: true,
                            summarySelector: (vm) => vm.inProgressJobs,
                            summaryEmptyLabel: 'No active work.',
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
/// (the projects counterpart to the "Active Work" job summary).
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
              if (i > 0) const SizedBox(height: Dimens.space2),
              ProjectCard(
                project: active[i],
                onTap: () => onOpen(active[i].id),
              ),
            ],
          ],
        );
      },
    );
  }
}

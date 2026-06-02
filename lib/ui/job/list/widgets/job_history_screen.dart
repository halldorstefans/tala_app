import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tala_app/ui/job/list/view_models/job_list_viewmodel.dart';
import 'package:tala_app/ui/core/themes/dimens.dart';

import '../../../../domain/models/job_category.dart';
import '../../../../domain/models/job_status.dart';
import '../../../../routing/routes.dart';
import 'job_card.dart';

class JobHistoryScreen extends StatefulWidget {
  const JobHistoryScreen({
    super.key,
    required this.viewModel,
    this.isSummary = false,
    this.summaryCount = 3,
  });

  final JobListViewModel viewModel;
  final bool isSummary;
  final int summaryCount;

  @override
  State<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends State<JobHistoryScreen> {
  Future<void> _openFilterSheet() async {
    final vm = widget.viewModel;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + media.viewInsets.bottom + media.padding.bottom,
          ),
          child: ListenableBuilder(
            listenable: vm,
            builder: (context, _) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (vm.hasActiveFilters)
                          TextButton(
                            onPressed: () => vm.clearFilters(),
                            child: const Text('Clear all'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final c in JobCategory.predefined)
                          FilterChip(
                            label: Text(categoryLabel(c)),
                            selected: vm.categoryFilter.contains(c),
                            onSelected: (selected) {
                              final next = Set<String>.from(vm.categoryFilter);
                              if (selected) {
                                next.add(c);
                              } else {
                                next.remove(c);
                              }
                              vm.setCategoryFilter(next);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Date range',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vm.dateRange != null
                                ? '${_fmt(vm.dateRange!.start)} → ${_fmt(vm.dateRange!.end)}'
                                : 'Any',
                          ),
                        ),
                        if (vm.dateRange != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear date range',
                            onPressed: () => vm.setDateRange(null),
                          ),
                        TextButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: const Text('Pick'),
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDateRangePicker(
                              context: sheetContext,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(now.year + 1),
                              initialDateRange: vm.dateRange,
                            );
                            if (picked != null) {
                              vm.setDateRange(picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _fmt(DateTime d) => d.toLocal().toString().split(' ')[0];

  Widget _buildStatusFilterRow() {
    final vm = widget.viewModel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final s in JobStatus.all)
            FilterChip(
              label: Text(statusLabel(s)),
              selected: vm.statusFilter.contains(s),
              onSelected: (selected) {
                final next = Set<String>.from(vm.statusFilter);
                if (selected) {
                  next.add(s);
                } else {
                  next.remove(s);
                }
                vm.setStatusFilter(next);
              },
            ),
          if (vm.hasActiveFilters)
            ActionChip(
              avatar: const Icon(Icons.clear, size: 18),
              label: const Text('Clear'),
              onPressed: () => vm.clearFilters(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimens = Dimens.of(context);
    final content = ListenableBuilder(
      listenable: widget.viewModel.fetchJobs,
      builder: (context, child) {
        if (widget.viewModel.fetchJobs.completed) {
          return child!;
        }
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: dimens.paddingScreenVertical,
            horizontal: dimens.paddingScreenHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.viewModel.fetchJobs.running)
                Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              if (widget.viewModel.fetchJobs.error)
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        Text('Error: ${widget.viewModel.fetchJobs.result}'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => widget.viewModel.fetchJobs.execute(
                            widget.viewModel.vehicleId,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          final records = widget.isSummary
              ? widget.viewModel.jobs.take(widget.summaryCount).toList()
              : widget.viewModel.filteredJobs;
          if (records.isEmpty) {
            return Center(
              child: Text(
                widget.isSummary ||
                        !widget.viewModel.hasActiveFilters
                    ? 'No jobs found.'
                    : 'No jobs match the current filters.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: widget.isSummary,
            physics: widget.isSummary
                ? const NeverScrollableScrollPhysics()
                : null,
            itemCount: records.length,
            separatorBuilder: (context, i) => SizedBox(height: Dimens.space4),
            itemBuilder: (context, i) => JobCard(
              job: records[i],
              onTap: () {
                context.push(
                  Routes.jobDetails(widget.viewModel.vehicleId, records[i].id),
                );
              },
            ),
          );
        },
      ),
    );

    if (widget.isSummary) {
      // For summary, just return the content (no Scaffold, AppBar, or FAB)
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: dimens.paddingScreenVertical,
          horizontal: dimens.paddingScreenHorizontal,
        ),
        child: content,
      );
    }

    // Full screen mode with Scaffold
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Job History',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'More filters',
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) => _buildStatusFilterRow(),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: dimens.paddingScreenVertical,
                horizontal: dimens.paddingScreenHorizontal,
              ),
              child: content,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(Routes.jobForm(widget.viewModel.vehicleId));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Job'),
      ),
    );
  }
}

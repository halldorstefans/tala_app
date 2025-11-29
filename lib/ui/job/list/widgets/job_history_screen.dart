import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tala_app/ui/job/list/view_models/job_list_viewmodel.dart';
import 'package:tala_app/ui/core/themes/dimens.dart';
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
  @override
  void initState() {
    super.initState();
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
              : widget.viewModel.jobs;
          if (records.isEmpty) {
            return Center(
              child: Text(
                'No jobs found.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
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
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: dimens.paddingScreenVertical,
          horizontal: dimens.paddingScreenHorizontal,
        ),
        child: content,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(Routes.jobForm(widget.viewModel.vehicleId));
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Add Job',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.secondary,
      ),
    );
  }
}

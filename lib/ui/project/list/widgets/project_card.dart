import 'package:flutter/material.dart';

import '../../../../domain/models/job_status.dart';
import '../../../../domain/models/project.dart';
import '../view_models/project_list_viewmodel.dart' show ProjectSummary;

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.summary,
  });

  final Project project;
  final VoidCallback? onTap;
  final ProjectSummary? summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final range = _dateRange(project);
    final description = project.description;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (summary != null) ...[
                const SizedBox(height: 6),
                if (_totalJobs(summary!) > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: _completionFraction(summary!),
                      minHeight: 6,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  _summaryLine(summary!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static int _totalJobs(ProjectSummary s) =>
      s.planned + s.inProgress + s.completed;

  /// Share of jobs completed, 0..1. (In-progress jobs aren't sub-tracked, so
  /// they count as not-yet-done.)
  static double _completionFraction(ProjectSummary s) {
    final total = _totalJobs(s);
    return total == 0 ? 0 : s.completed / total;
  }

  static String _summaryLine(ProjectSummary s) {
    final total = _totalJobs(s);
    final jobs = total == 0
        ? 'No jobs'
        : '${s.completed}/$total done'
              '${s.inProgress > 0 ? ' · ${s.inProgress} in progress' : ''}';
    return '$jobs · €${s.totalCost.toStringAsFixed(2)}';
  }

  /// A `start → end` line, using an em dash for whichever end is unset. Null
  /// when the project has no dates at all (nothing worth showing).
  static String? _dateRange(Project project) {
    if (project.startDate == null && project.endDate == null) return null;
    String fmt(DateTime? d) => d != null ? d.toLocal().toString().split(' ')[0] : '—';
    return '${fmt(project.startDate)} → ${fmt(project.endDate)}';
  }
}

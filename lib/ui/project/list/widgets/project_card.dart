import 'package:flutter/material.dart';

import '../../../../domain/models/job_status.dart';
import '../../../../domain/models/project.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap});

  final Project project;
  final VoidCallback? onTap;

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
            ],
          ),
        ),
      ),
    );
  }

  /// A `start → end` line, using an em dash for whichever end is unset. Null
  /// when the project has no dates at all (nothing worth showing).
  static String? _dateRange(Project project) {
    if (project.startDate == null && project.endDate == null) return null;
    String fmt(DateTime? d) => d != null ? d.toLocal().toString().split(' ')[0] : '—';
    return '${fmt(project.startDate)} → ${fmt(project.endDate)}';
  }
}

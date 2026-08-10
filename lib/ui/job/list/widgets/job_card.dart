import 'package:flutter/material.dart';

import '../../../../domain/models/job.dart';
import '../../../../domain/models/job_category.dart';
import '../../../../domain/models/progress_status.dart';

/// A job list item. Vertical layout mirroring ProjectCard: title + status chip
/// on the top row, then category and date. An optional done-checkbox sits at
/// the top-right when [onToggleDone] is provided.
class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggleDone;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = job.status == ProgressStatus.completed;
    final dateToShow = isCompleted && job.completionDate != null
        ? job.completionDate
        : job.startDate;
    final dateText = dateToShow != null
        ? dateToShow.toLocal().toString().split(' ')[0]
        : '';
    final metaStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        job.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryLabel(job.category),
                        style: metaStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (dateText.isNotEmpty)
                        Text(dateText, style: metaStyle),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Right column: status chip pinned top-right (flush to the
                // card edge), done-checkbox centred in the space below it.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (job.status != null)
                      Chip(
                        label: Text(statusLabel(job.status)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    if (onToggleDone != null) ...[
                      const Spacer(),
                      Checkbox(
                        value: isCompleted,
                        onChanged: (v) => onToggleDone!(v ?? false),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Spacer(),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

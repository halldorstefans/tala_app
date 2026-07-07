import 'package:flutter/material.dart';

import '../../../../domain/models/job.dart';
import '../../../../domain/models/job_category.dart';
import '../../../../domain/models/job_status.dart';
import '../../../core/widgets/app_image.dart';

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
    final photoCount = job.photoPaths?.length ?? 0;
    final firstPhoto = (photoCount > 0) ? job.photoPaths!.first : null;
    final isCompleted = job.status == JobStatus.completed;
    final dateToShow = isCompleted && job.completionDate != null
        ? job.completionDate
        : job.startDate;
    final dateText = dateToShow != null
        ? dateToShow.toLocal().toString().split(' ')[0]
        : '';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppImage(
                  path: firstPhoto,
                  width: 56,
                  height: 56,
                  placeholderIcon: Icons.build,
                  placeholderSize: 28,
                ),
              ),
              const SizedBox(width: 12),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            categoryLabel(job.category),
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (job.status != null && job.status!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(statusLabel(job.status)),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ],
                    ),
                    if (dateText.isNotEmpty)
                      Text(dateText, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (photoCount > 1)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${photoCount - 1}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
              if (onToggleDone != null)
                Checkbox(
                  value: isCompleted,
                  onChanged: (v) => onToggleDone!(v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

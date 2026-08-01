import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/models/job_part.dart';
import '../../../../routing/routes.dart';
import '../view_models/job_detail_viewmodel.dart';
import 'add_part_sheet.dart';
import 'edit_job_part_sheet.dart';

/// The "Parts" area on the job detail screen: the job's parts with line
/// totals, an add action, and the Parts / Other / Total cost breakdown.
class JobPartsSection extends StatelessWidget {
  const JobPartsSection({super.key, required this.viewModel});

  final JobDetailViewModel viewModel;

  Future<void> _openPart(BuildContext context, String partId) async {
    await context.push(Routes.partDetails(partId));
    if (!context.mounted) return;
    viewModel.reloadParts();
  }

  Future<void> _remove(BuildContext context, String jobPartId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove part from job?'),
        content: const Text('The part stays in the catalogue; only this use '
            'is removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) await viewModel.removePart(jobPartId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final lines = viewModel.jobParts;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Parts', style: theme.textTheme.headlineMedium),
                TextButton.icon(
                  onPressed: () => showAddPartSheet(context, viewModel),
                  icon: const Icon(Icons.add),
                  label: const Text('Add part'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (lines.isEmpty)
              Text(
                'No parts on this job yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              )
            else
              for (final line in lines)
                _PartRow(
                  line: line,
                  onTap: () => _openPart(context, line.part.id),
                  onEdit: () => showEditJobPartSheet(context, viewModel, line),
                  onRemove: () => _remove(context, line.link.id),
                ),
          ],
        );
      },
    );
  }
}

class _PartRow extends StatelessWidget {
  const _PartRow({
    required this.line,
    required this.onTap,
    required this.onEdit,
    required this.onRemove,
  });

  final JobPartLine line;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final part = line.part;
    final link = line.link;
    final subtitleParts = [
      if (part.partNumber != null && part.partNumber!.isNotEmpty)
        part.partNumber!,
      if (part.supplier != null && part.supplier!.isNotEmpty) part.supplier!,
    ];
    final unit = (link.unitCost ?? 0).toStringAsFixed(2);
    final total = link.totalCost.toStringAsFixed(2);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      part.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleParts.join(' · '),
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      '${link.quantity} × €$unit = €$total',
                      style: GoogleFonts.jetBrainsMono(
                        textStyle: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit cost / quantity',
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Remove from job',
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/models/job_part.dart';
import '../../../../routing/routes.dart';
import '../../../core/themes/dimens.dart';
import '../view_models/parts_used_viewmodel.dart';

class PartsUsedScreen extends StatelessWidget {
  const PartsUsedScreen({super.key, required this.viewModel});

  final PartsUsedViewModel viewModel;

  Future<void> _openPart(BuildContext context, String partId) async {
    await context.push(Routes.partDetails(partId));
    if (!context.mounted) return;
    // A part may have been edited/deleted; refresh usage.
    viewModel.fetchUsage.execute(viewModel.vehicleId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimens = Dimens.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Parts used')),
      body: ListenableBuilder(
        listenable: viewModel.fetchUsage,
        builder: (context, _) {
          if (viewModel.fetchUsage.running) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            );
          }
          if (viewModel.fetchUsage.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${viewModel.fetchUsage.result}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        viewModel.fetchUsage.execute(viewModel.vehicleId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final usage = viewModel.usage;
              if (usage.isEmpty) {
                return Center(
                  child: Text(
                    'No parts logged for this vehicle yet.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        vertical: dimens.paddingScreenVertical,
                        horizontal: dimens.paddingScreenHorizontal,
                      ),
                      itemCount: usage.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: Dimens.space2),
                      itemBuilder: (context, i) => _UsageRow(
                        usage: usage[i],
                        onTap: () => _openPart(context, usage[i].part.id),
                      ),
                    ),
                  ),
                  _GrandTotal(total: viewModel.grandTotal),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.usage, required this.onTap});

  final PartUsage usage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final part = usage.part;
    final subtitle = [
      if (part.partNumber != null && part.partNumber!.isNotEmpty)
        part.partNumber!,
      if (part.supplier != null && part.supplier!.isNotEmpty) part.supplier!,
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          part.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            if (subtitle.isNotEmpty) subtitle,
            '×${usage.totalQuantity}',
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
        trailing: Text(
          '€${usage.totalSpent.toStringAsFixed(2)}',
          style: GoogleFonts.jetBrainsMono(textStyle: theme.textTheme.bodyMedium),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _GrandTotal extends StatelessWidget {
  const _GrandTotal({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total parts', style: theme.textTheme.titleMedium),
              Text(
                '€${total.toStringAsFixed(2)}',
                style: GoogleFonts.jetBrainsMono(
                  textStyle: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

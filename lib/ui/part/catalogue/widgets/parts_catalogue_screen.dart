import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/part.dart';
import '../../../../routing/routes.dart';
import '../../../core/themes/dimens.dart';
import '../view_models/parts_catalogue_viewmodel.dart';

class PartsCatalogueScreen extends StatelessWidget {
  const PartsCatalogueScreen({super.key, required this.viewModel});

  final PartsCatalogueViewModel viewModel;

  Future<void> _openPart(BuildContext context, String partId) async {
    await context.push(Routes.partDetails(partId));
    if (!context.mounted) return;
    // A part may have been edited or deleted; refresh the catalogue.
    viewModel.fetchParts.execute();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimens = Dimens.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parts',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search name or part number',
              ),
              onChanged: viewModel.setQuery,
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: viewModel.fetchParts,
              builder: (context, _) {
                if (viewModel.fetchParts.running) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.secondary,
                    ),
                  );
                }
                if (viewModel.fetchParts.error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Error: ${viewModel.fetchParts.result}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.fetchParts.execute(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, _) {
                    if (viewModel.isEmpty) {
                      return _empty(theme, 'No parts yet.');
                    }
                    final parts = viewModel.filteredParts;
                    if (parts.isEmpty) {
                      return _empty(theme, 'No parts match your search.');
                    }
                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        dimens.paddingScreenHorizontal,
                        dimens.paddingScreenVertical,
                        dimens.paddingScreenHorizontal,
                        // Clear the system nav bar at the bottom.
                        dimens.paddingScreenVertical +
                            MediaQuery.paddingOf(context).bottom,
                      ),
                      itemCount: parts.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: Dimens.space2),
                      itemBuilder: (context, i) => _PartRow(
                        part: parts[i],
                        onTap: () => _openPart(context, parts[i].id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(ThemeData theme, String message) => Center(
    child: Text(
      message,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    ),
  );
}

class _PartRow extends StatelessWidget {
  const _PartRow({required this.part, required this.onTap});

  final Part part;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        subtitle: subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../routing/routes.dart';
import '../../../core/attachments/view_models/attachments_view_model.dart';
import '../../../core/attachments/widgets/attachments_section.dart';
import '../view_models/part_detail_viewmodel.dart';

class PartDetailScreen extends StatefulWidget {
  const PartDetailScreen({
    super.key,
    required this.viewModel,
    required this.attachmentsViewModel,
  });

  final PartDetailViewModel viewModel;
  final AttachmentsViewModel attachmentsViewModel;

  @override
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  Future<void> _confirmDeletePart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete part?'),
        content: const Text(
          'The part is removed from the catalogue and from every job that '
          'uses it. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.viewModel.delete.execute();
    if (!mounted) return;
    if (widget.viewModel.delete.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete part')),
      );
      return;
    }
    context.pop();
  }

  Future<void> _openEdit() async {
    final id = widget.viewModel.partId;
    if (id == null) return;
    await context.push(Routes.partEdit(id));
    if (!mounted) return;
    widget.viewModel.load.execute(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Part'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit part',
            onPressed: _openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete part',
            onPressed: _confirmDeletePart,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.load,
        builder: (context, _) {
          if (widget.viewModel.load.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.viewModel.load.error) {
            return Center(child: Text('Error: ${widget.viewModel.load.result}'));
          }
          return ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              final part = widget.viewModel.part;
              if (part == null) {
                return const Center(child: Text('Part not found'));
              }
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  MediaQuery.paddingOf(context).bottom + 24,
                ),
                children: [
                  Text(part.name, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  for (final line in [
                    if (part.partNumber != null && part.partNumber!.isNotEmpty)
                      'Part no: ${part.partNumber}',
                    if (part.brand != null && part.brand!.isNotEmpty)
                      'Brand: ${part.brand}',
                    if (part.supplier != null && part.supplier!.isNotEmpty)
                      'Supplier: ${part.supplier}',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        line,
                        style: GoogleFonts.jetBrainsMono(
                          textStyle: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  if (part.notes != null && part.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Notes: ${part.notes}', style: theme.textTheme.bodyLarge),
                  ],
                  const SizedBox(height: 24),
                  AttachmentsSection(viewModel: widget.attachmentsViewModel),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../routing/routes.dart';
import '../../../core/widgets/app_image.dart';
import '../view_models/part_detail_viewmodel.dart';

class PartDetailScreen extends StatefulWidget {
  const PartDetailScreen({super.key, required this.viewModel});

  final PartDetailViewModel viewModel;

  @override
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (image == null) return;
    await widget.viewModel.addPhoto(File(image.path));
  }

  Future<void> _confirmDeletePhoto(String path) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete photo?'),
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
    if (confirmed == true) await widget.viewModel.deletePhoto(path);
  }

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
              final photos = part.photoPaths ?? const <String>[];
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Photos', style: theme.textTheme.headlineMedium),
                      TextButton.icon(
                        onPressed: _addPhoto,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (photos.isEmpty)
                    Text(
                      'No photos yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final path in photos)
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AppImage(
                                  path: path,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Material(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _confirmDeletePhoto(path),
                                    child: const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

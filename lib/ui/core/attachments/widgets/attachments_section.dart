import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../domain/models/attachment.dart';
import '../../../../domain/models/attachment_type.dart';
import '../../widgets/app_image.dart';
import '../view_models/attachments_view_model.dart';

/// A reusable "Attachments" section for any owner (vehicle, project, job,
/// part). Lists attachments as thumbnails with a type/caption, lets the user
/// add an image (tagged with a type + optional caption), view them full-screen,
/// re-caption, and delete. Drop it into a detail screen with an
/// [AttachmentsViewModel] scoped to that owner.
class AttachmentsSection extends StatelessWidget {
  const AttachmentsSection({
    super.key,
    required this.viewModel,
    this.title = 'Attachments',
  });

  final AttachmentsViewModel viewModel;
  final String title;

  Future<void> _add(BuildContext context) async {
    final source = await _pickSource(context);
    if (source == null || !context.mounted) return;

    final image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (image == null || !context.mounted) return;

    final details = await showModalBottomSheet<_AttachmentDetails>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AttachmentDetailsSheet(),
    );
    if (details == null) return;

    await viewModel.addPhoto.execute((
      file: File(image.path),
      type: details.type,
      caption: details.caption,
    ));
  }

  /// Lets the user take a new photo or choose an existing image.
  Future<ImageSource?> _pickSource(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editCaption(
    BuildContext context,
    Attachment attachment,
  ) async {
    final controller = TextEditingController(text: attachment.caption ?? '');
    final caption = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Caption'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Describe this file'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (caption == null) return;
    await viewModel.updateCaption.execute((
      id: attachment.id,
      caption: caption.isEmpty ? null : caption,
    ));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Attachment attachment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete attachment?'),
        content: const Text('This removes the file. It cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await viewModel.remove.execute(attachment.id);
  }

  Future<void> _openViewer(BuildContext context, int initialIndex) async {
    final attachments = viewModel.attachments;
    final providers = await Future.wait(
      attachments.map((a) => AppImage.resolveProvider(a.storagePath)),
    );
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: PhotoViewGallery.builder(
            itemCount: providers.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (_, i) => PhotoViewGalleryPageOptions(
              imageProvider: providers[i],
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final attachments = viewModel.attachments;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: theme.textTheme.headlineSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _add(context),
                  icon: const Icon(Icons.add_a_photo, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (attachments.isEmpty)
              Text(
                'No attachments yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < attachments.length; i++)
                    _AttachmentTile(
                      attachment: attachments[i],
                      onOpen: () => _openViewer(context, i),
                      onEditCaption: () =>
                          _editCaption(context, attachments[i]),
                      onDelete: () => _confirmDelete(context, attachments[i]),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.attachment,
    required this.onOpen,
    required this.onEditCaption,
    required this.onDelete,
  });

  final Attachment attachment;
  final VoidCallback onOpen;
  final VoidCallback onEditCaption;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: onOpen,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AppImage(
                    path: attachment.storagePath,
                    width: 96,
                    height: 96,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _TileMenu(
                  onEditCaption: onEditCaption,
                  onDelete: onDelete,
                ),
              ),
              if (attachment.type != AttachmentType.photo)
                Positioned(
                  left: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.inverseSurface.withValues(
                        alpha: 0.85,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      attachment.type.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (attachment.caption != null && attachment.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                attachment.caption!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _TileMenu extends StatelessWidget {
  const _TileMenu({required this.onEditCaption, required this.onDelete});

  final VoidCallback onEditCaption;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Attachment actions',
      icon: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(2),
        child: const Icon(Icons.more_vert, size: 18, color: Colors.white),
      ),
      onSelected: (value) {
        if (value == 'caption') onEditCaption();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'caption', child: Text('Edit caption')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}

class _AttachmentDetails {
  const _AttachmentDetails(this.type, this.caption);
  final AttachmentType type;
  final String? caption;
}

/// Collects the type + optional caption after an image is picked.
class _AttachmentDetailsSheet extends StatefulWidget {
  const _AttachmentDetailsSheet();

  @override
  State<_AttachmentDetailsSheet> createState() =>
      _AttachmentDetailsSheetState();
}

class _AttachmentDetailsSheetState extends State<_AttachmentDetailsSheet> {
  AttachmentType _type = AttachmentType.photo;
  final _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        // Clear the keyboard when open, and the system nav bar when it isn't
        // (padding.bottom collapses to 0 while the keyboard covers it, so the
        // two never double up) — otherwise Save hides behind the nav bar.
        bottom: media.viewInsets.bottom + media.padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add attachment', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          DropdownButtonFormField<AttachmentType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: [
              for (final type in AttachmentType.values)
                DropdownMenuItem(value: type, child: Text(type.label)),
            ],
            onChanged: (value) =>
                setState(() => _type = value ?? AttachmentType.photo),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              labelText: 'Caption (optional)',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final caption = _captionController.text.trim();
              Navigator.of(context).pop(
                _AttachmentDetails(_type, caption.isEmpty ? null : caption),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

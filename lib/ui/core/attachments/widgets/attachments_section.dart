import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/services/tala_api/api_config.dart';
import '../../../../domain/models/attachment.dart';
import '../../../../domain/models/attachment_type.dart';
import '../../../../utils/file_types.dart';
import '../../widgets/app_image.dart';
import '../view_models/attachments_view_model.dart';

/// Where the user is adding an attachment from.
enum _AddSource { camera, gallery, file }

/// A reusable "Attachments" section for any owner (vehicle, project, job,
/// part). Lists attachments (image thumbnails, or a file glyph for documents),
/// each tagged with a type + optional caption. The user can add from the
/// camera, the gallery (multi-select), or a file (PDF, etc.); view images
/// full-screen; open documents via the OS; re-caption; and delete. Drop it into
/// a detail screen with an [AttachmentsViewModel] scoped to that owner.
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

    switch (source) {
      case _AddSource.camera:
        final image = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          imageQuality: 85,
        );
        if (image == null || !context.mounted) return;
        await _addSingle(context, File(image.path), AttachmentType.photo);

      case _AddSource.gallery:
        // Allow picking several at once. A single pick still gets the type +
        // caption sheet; multiple are bulk-added as photos (caption later).
        final images = await ImagePicker().pickMultiImage(
          maxWidth: 1920,
          imageQuality: 85,
        );
        if (images.isEmpty || !context.mounted) return;
        if (images.length == 1) {
          await _addSingle(context, File(images.first.path), AttachmentType.photo);
        } else {
          await viewModel.addPhotos.execute((
            files: [for (final image in images) File(image.path)],
            type: AttachmentType.photo,
          ));
        }

      case _AddSource.file:
        final file = await openFile();
        if (file == null || !context.mounted) return;
        await _addSingle(context, File(file.path), AttachmentType.document);
    }
  }

  /// Adds one file after collecting its type + optional caption ([defaultType]
  /// preselects the type — photo for images, document for picked files).
  Future<void> _addSingle(
    BuildContext context,
    File file,
    AttachmentType defaultType,
  ) async {
    final details = await showModalBottomSheet<_AttachmentDetails>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AttachmentDetailsSheet(initialType: defaultType),
    );
    if (details == null) return;
    await viewModel.addPhoto.execute((
      file: file,
      type: details.type,
      caption: details.caption,
    ));
  }

  /// Lets the user take a photo, choose image(s), or pick a file (PDF, etc.).
  Future<_AddSource?> _pickSource(BuildContext context) {
    return showModalBottomSheet<_AddSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(sheetContext).pop(_AddSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(sheetContext).pop(_AddSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Choose file'),
              onTap: () => Navigator.of(sheetContext).pop(_AddSource.file),
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

  /// Images open in the full-screen viewer; anything else (a PDF, say) is
  /// handed to the OS share sheet so the user can open it in a capable app.
  Future<void> _open(BuildContext context, Attachment attachment) async {
    if (isImagePath(attachment.storagePath)) {
      final images = viewModel.attachments
          .where((a) => isImagePath(a.storagePath))
          .toList();
      await _openViewer(context, images, images.indexOf(attachment));
    } else {
      final fullPath = await ApiConfig.getLocalPhotoPath(attachment.storagePath);
      await SharePlus.instance.share(ShareParams(files: [XFile(fullPath)]));
    }
  }

  /// Full-screen swipe + pinch-zoom over the image attachments only.
  Future<void> _openViewer(
    BuildContext context,
    List<Attachment> images,
    int initialIndex,
  ) async {
    if (images.isEmpty) return;
    final providers = await Future.wait(
      images.map((a) => AppImage.resolveProvider(a.storagePath)),
    );
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: PhotoViewGallery.builder(
            itemCount: providers.length,
            pageController: PageController(
              initialPage: initialIndex < 0 ? 0 : initialIndex,
            ),
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
                  for (final attachment in attachments)
                    _AttachmentTile(
                      attachment: attachment,
                      onOpen: () => _open(context, attachment),
                      onEditCaption: () => _editCaption(context, attachment),
                      onDelete: () => _confirmDelete(context, attachment),
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
                  child: isImagePath(attachment.storagePath)
                      ? AppImage(
                          path: attachment.storagePath,
                          width: 96,
                          height: 96,
                        )
                      : _FileThumbnail(path: attachment.storagePath),
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

/// A 96×96 placeholder for a non-image attachment: a document icon plus the
/// file's extension (e.g. "PDF").
class _FileThumbnail extends StatelessWidget {
  const _FileThumbnail({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = p.extension(path).replaceFirst('.', '').toUpperCase();
    return Container(
      width: 96,
      height: 96,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ext == 'PDF' ? Icons.picture_as_pdf : Icons.insert_drive_file,
            size: 36,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          if (ext.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(ext, style: theme.textTheme.labelSmall),
          ],
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

/// Collects the type + optional caption after a file is picked.
class _AttachmentDetailsSheet extends StatefulWidget {
  const _AttachmentDetailsSheet({required this.initialType});

  final AttachmentType initialType;

  @override
  State<_AttachmentDetailsSheet> createState() =>
      _AttachmentDetailsSheetState();
}

class _AttachmentDetailsSheetState extends State<_AttachmentDetailsSheet> {
  late AttachmentType _type = widget.initialType;
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

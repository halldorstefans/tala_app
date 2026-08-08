import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tala_app/ui/core/widgets/app_image.dart';
import 'package:tala_app/ui/job/detail/view_models/job_detail_viewmodel.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../domain/models/job.dart';
import '../../../../domain/models/job_category.dart';
import '../../../../domain/models/job_status.dart';
import '../../../../routing/routes.dart';
import '../../../core/themes/dimens.dart';
import 'job_cost_breakdown.dart';
import 'job_parts_section.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.viewModel});

  final JobDetailViewModel viewModel;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Future<void> _openGallery(List<String> urls, int initialIndex) async {
    final providers = await Future.wait(urls.map(AppImage.resolveProvider));
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black,
            child: Stack(
              children: [
                PhotoViewGallery.builder(
                  itemCount: urls.length,
                  pageController: PageController(initialPage: initialIndex),
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: providers[index],
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  },
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePhoto(Job job, String photoPath) async {
    final confirm = await showDialog<bool>(
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
    if (confirm != true) return;
    await widget.viewModel.deleteJobPhoto.execute((
      job.vehicleId,
      job.id,
      photoPath,
    ));
    await widget.viewModel.fetchJob.execute((job.vehicleId, job.id));
  }

  Future<void> _openEdit(Job job) async {
    await context.push(Routes.jobFormWithId(job.vehicleId, job.id));
    if (!mounted) return;
    widget.viewModel.fetchJob.execute((job.vehicleId, job.id));
  }

  Future<void> _confirmRemove(Job job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete job?'),
        content: const Text('This job and its photos will be removed.'),
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
    await widget.viewModel.removeJob.execute((job.vehicleId, job.id));
    if (!mounted) return;
    context.go(Routes.vehicleDetails(job.vehicleId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimens = Dimens.of(context);
    return Scaffold(
      // Rebuild the bar when the job loads (it's fetched async) so the
      // title + Edit/Delete actions appear.
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          theme.appBarTheme.toolbarHeight ?? kToolbarHeight,
        ),
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final job = widget.viewModel.job;
            return AppBar(
              title: Text(job?.title ?? 'Job'),
              actions: [
                if (job != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit job',
                    onPressed: () => _openEdit(job),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete job',
                    onPressed: () => _confirmRemove(job),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.fetchJob,
        builder: (context, child) {
          if (widget.viewModel.fetchJob.running) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            );
          }
          if (widget.viewModel.fetchJob.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${widget.viewModel.fetchJob.result}'),
                  const SizedBox(height: 16),
                  if (widget.viewModel.job != null)
                    ElevatedButton(
                      onPressed: () => widget.viewModel.fetchJob.execute((
                        widget.viewModel.job!.vehicleId,
                        widget.viewModel.job!.id,
                      )),
                      child: const Text('Retry'),
                    ),
                ],
              ),
            );
          }
          return ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, child) {
              final job = widget.viewModel.job;
              if (job == null) {
                return Center(
                  child: Text('Job not found', style: theme.textTheme.bodyLarge),
                );
              }
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  dimens.paddingScreenHorizontal,
                  dimens.paddingScreenVertical,
                  dimens.paddingScreenHorizontal,
                  dimens.paddingScreenVertical +
                      MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  _Header(job: job),
                  if (job.photoPaths != null && job.photoPaths!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _Section(
                      title: 'Photos',
                      child: _PhotoGrid(
                        paths: job.photoPaths!,
                        onOpen: (i) => _openGallery(job.photoPaths!, i),
                        onDelete: (path) => _deletePhoto(job, path),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Cost',
                    child: JobCostBreakdown(viewModel: widget.viewModel),
                  ),
                  const SizedBox(height: 24),
                  JobPartsSection(viewModel: widget.viewModel),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Title-less header (the title is in the AppBar): status + category chips,
/// a spec block (dates, odometer) in mono, and the description.
class _Header extends StatelessWidget {
  const _Header({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? d(DateTime? date) =>
        date == null ? null : date.toLocal().toString().split(' ')[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            if (job.status != null && job.status!.isNotEmpty)
              Chip(
                label: Text(statusLabel(job.status)),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            if (job.category != null && job.category!.isNotEmpty)
              Chip(
                label: Text(categoryLabel(job.category)),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
        const SizedBox(height: 12),
        _SpecRow(label: 'Started', value: d(job.startDate) ?? '—'),
        _SpecRow(label: 'Completed', value: d(job.completionDate) ?? '—'),
        _SpecRow(label: 'Odometer', value: '${job.odometer ?? 0} km'),
        if (job.description != null && job.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(job.description!, style: theme.textTheme.bodyLarge),
        ],
      ],
    );
  }
}

/// A label (muted) on the left and a mono data value on the right.
class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              textStyle: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// A section: an uppercase-ish headline followed by its content.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    required this.paths,
    required this.onOpen,
    required this.onDelete,
  });

  final List<String> paths;
  final void Function(int index) onOpen;
  final void Function(String path) onDelete;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < paths.length; i++)
          Stack(
            alignment: Alignment.topRight,
            children: [
              GestureDetector(
                onTap: () => onOpen(i),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppImage(path: paths[i], width: 80, height: 80),
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
                    onTap: () => onDelete(paths[i]),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.delete, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
